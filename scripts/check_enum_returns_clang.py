#!/usr/bin/env python3
"""
@file check_enum_returns_clang.py
@module fortran_orm_lint
@brief Enforces via libclang AST inspection that every C function and function
pointer across `include/` and `src/` returns `fortran_orm_error_t` (an enum)
and zero `(void)` return discards exist in `src/`.
"""

import argparse
import glob
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


def bootstrap_clang_module():
    """Ensure `clang.cindex` is importable across system, venv, and Homebrew Pythons.

    @return None.
    """
    try:
        import clang.cindex as _ci  # noqa: F401

        return
    except ModuleNotFoundError:
        py_ver = f"python{sys.version_info.major}.{sys.version_info.minor}"
        search_sites = []
        for pat in (
            f"/opt/homebrew/opt/llvm/lib/{py_ver}/site-packages",
            f"/opt/homebrew/Cellar/llvm*/*/lib/{py_ver}/site-packages",
            f"/usr/local/opt/llvm*/lib/{py_ver}/site-packages",
            "/opt/homebrew/opt/llvm/lib/python*/site-packages",
            "/opt/homebrew/Cellar/llvm*/*/lib/python*/site-packages",
            "/usr/local/opt/llvm*/lib/python*/site-packages",
            "/usr/lib/python3/dist-packages",
        ):
            search_sites.extend(sorted(glob.glob(pat), reverse=True))
        for sp in search_sites:
            if os.path.isdir(os.path.join(sp, "clang")) and sp not in sys.path:
                sys.path.append(sp)


bootstrap_clang_module()
from clang.cindex import (  # noqa: E402
    Config,
    CursorKind,
    Diagnostic,
    Index,
    LibclangError,
    TypeKind,
)

_STD_PROBE_SRC = (
    "#include <stddef.h>\n"
    "#include <stdint.h>\n"
    "typedef size_t fortran_orm_probe_size_t;\n"
    "typedef ptrdiff_t fortran_orm_probe_ptrdiff_t;\n"
    "typedef int8_t fortran_orm_probe_i8_t;\n"
    "typedef uint8_t fortran_orm_probe_u8_t;\n"
    "typedef int16_t fortran_orm_probe_i16_t;\n"
    "typedef uint16_t fortran_orm_probe_u16_t;\n"
    "typedef int32_t fortran_orm_probe_i32_t;\n"
    "typedef uint32_t fortran_orm_probe_u32_t;\n"
    "typedef int64_t fortran_orm_probe_i64_t;\n"
    "typedef uint64_t fortran_orm_probe_u64_t;\n"
)


def init_libclang():
    """Locate and initialize libclang shared library across macOS and Linux.

    @return None.
    """
    try:
        _ = Config().lib
        return
    except (LibclangError, OSError):
        pass

    candidates = []
    if os.environ.get("LIBCLANG_PATH"):
        env_p = os.environ["LIBCLANG_PATH"]
        if os.path.isdir(env_p):
            candidates.extend(sorted(glob.glob(os.path.join(env_p, "libclang*"))))
        else:
            candidates.append(env_p)

    for pat in (
        "/opt/homebrew/opt/llvm/lib/libclang*.dylib",
        "/opt/homebrew/Cellar/llvm*/*/lib/libclang*.dylib",
        "/usr/local/opt/llvm*/lib/libclang*.dylib",
        "/usr/lib/llvm-*/lib/libclang.so*",
        "/usr/lib/x86_64-linux-gnu/libclang*.so*",
        "/usr/lib/aarch64-linux-gnu/libclang*.so*",
        "/Library/Developer/CommandLineTools/usr/lib/libclang*.dylib",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang*.dylib",
    ):
        candidates.extend(sorted(glob.glob(pat), reverse=True))

    filtered = [c for c in candidates if "libclang-cpp" not in c and os.path.isfile(c)]
    for compat in (True, False):
        Config.set_compatibility_check(compat)
        for cand in filtered:
            try:
                Config.set_library_file(cand)
                _ = Config().lib
                return
            except (LibclangError, OSError):
                continue


def _version_sort_key(path_str):
    """Extract numeric version tuple from a toolchain path for descending sort.

    @param path_str Candidate filesystem path containing LLVM/Clang version numbers.
    @return Tuple of integers suitable for numeric version comparison.
    """
    nums = [int(tok) for tok in re.findall(r"\d+", path_str)]
    return (nums, path_str)


def candidate_resource_dirs():
    """Discover candidate Clang resource directories (`<res_dir>/include/stddef.h`).

    Unlike passing `-isystem <dir>/include` (which prepends a second Clang builtin
    directory ahead of `libclang`'s own `<resource-dir>/include` and breaks
    `#include_next <stdint.h>` via `__CLANG_STDINT_H` guard re-entry when multiple
    LLVM versions are installed), passing `-resource-dir=<res_dir>` replaces
    Clang's single `ResourceDir` cleanly.

    @return Ordered list of unique Clang resource directory paths.
    """
    raw = []
    if os.environ.get("CLANG_RESOURCE_DIR"):
        raw.append(os.environ["CLANG_RESOURCE_DIR"])

    clang_bin = shutil.which("clang")
    if clang_bin:
        try:
            res_dir = subprocess.check_output(
                [clang_bin, "-print-resource-dir"],
                text=True,
                stderr=subprocess.DEVNULL,
            ).strip()
            if res_dir:
                raw.append(res_dir)
        except (subprocess.SubprocessError, OSError):
            pass

    glob_hits = []
    for pat in (
        "/usr/lib/llvm-*/lib/clang/*",
        "/usr/lib/clang/*",
        "/opt/homebrew/opt/llvm/lib/clang/*",
        "/opt/homebrew/Cellar/llvm*/*/lib/clang/*",
        "/usr/local/opt/llvm*/lib/clang/*",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/*",
        "/Library/Developer/CommandLineTools/usr/lib/clang/*",
    ):
        glob_hits.extend(glob.glob(pat))
    raw.extend(sorted(glob_hits, key=_version_sort_key, reverse=True))

    seen = set()
    valid = []
    for cand in raw:
        norm = os.path.abspath(cand)
        if norm in seen:
            continue
        seen.add(norm)
        if os.path.isfile(os.path.join(norm, "include", "stddef.h")):
            valid.append(norm)
    return valid


def can_parse_std_headers(idx, clang_args):
    """Verify via in-memory parse that `<stddef.h>` and `<stdint.h>` types resolve.

    @param idx Active `clang.cindex.Index` instance.
    @param clang_args Candidate compiler arguments passed to `Index.parse`.
    @return `True` when zero error/fatal diagnostics occur, `False` otherwise.
    """
    probe_file = "__fortran_orm_std_probe.c"
    try:
        tu = idx.parse(
            probe_file,
            args=clang_args,
            unsaved_files=[(probe_file, _STD_PROBE_SRC)],
        )
    except (LibclangError, OSError):
        return False
    return not any(d.severity >= Diagnostic.Error for d in tu.diagnostics)


def resolve_std_header_args(idx, base_args):
    """Ensure `<stddef.h>` and `<stdint.h>` resolve cleanly on `idx`.

    Probes `base_args` unmodified first so system `libclang` installations (such
    as Debian/Ubuntu `python3-clang`) keep their native matched `ResourceDir`
    untouched. Only when the probe fails (such as standalone PyPI `libclang`
    wheels lacking bundled builtin headers) does it test `-resource-dir=<dir>`.

    @param idx Active `clang.cindex.Index` instance.
    @param base_args Base compiler flags prior to resource-directory fallback.
    @return Validated list of compiler arguments for `Index.parse`.
    """
    if can_parse_std_headers(idx, base_args):
        return base_args

    multiarch_dirs = []
    if sys.platform.startswith("linux"):
        cc_bin = shutil.which("gcc") or shutil.which("cc")
        if cc_bin:
            try:
                triplet = subprocess.check_output(
                    [cc_bin, "-print-multiarch"],
                    text=True,
                    stderr=subprocess.DEVNULL,
                ).strip()
                if triplet and os.path.isdir(f"/usr/include/{triplet}"):
                    multiarch_dirs.append(f"/usr/include/{triplet}")
            except (subprocess.SubprocessError, OSError):
                pass
        for ma in sorted(glob.glob("/usr/include/*-linux-gnu*")):
            if os.path.isdir(ma) and ma not in multiarch_dirs:
                multiarch_dirs.append(ma)

    res_dirs = candidate_resource_dirs()
    for res_dir in res_dirs:
        trial = base_args + [f"-resource-dir={res_dir}"]
        if can_parse_std_headers(idx, trial):
            return trial
        for ma_dir in multiarch_dirs:
            trial_ma = trial + ["-isystem", ma_dir]
            if can_parse_std_headers(idx, trial_ma):
                return trial_ma

    return base_args


def collect_clang_args(idx):
    """Build complete `-I`, sysroot, and validated resource-dir flags for libclang.

    @param idx Active `clang.cindex.Index` instance used to validate headers.
    @return List of clang command-line flags for `Index.parse`.
    """
    clang_args = ["-std=c90", "-x", "c", "-Iinclude", "-Isrc"]
    for sub in (
        "../c-orm/include",
        "build/_deps/c_orm-src/include",
        "build/_deps/c_orm-build/include",
        "build/_deps/cdd_c-src/include",
        "build/_deps/cdd_c-src/src",
        "build/_deps/c_str_span-src/c_str_span",
        "build/_deps/c89stringutils-src/c89stringutils",
        "build/_deps/cfs-src/include",
        "build-cov/_deps/c_orm-src/include",
        "build-cov/_deps/cdd_c-src/include",
        "build-cov/_deps/cdd_c-src/src",
        "build-cov/_deps/c_str_span-src/c_str_span",
        "build-cov/_deps/c89stringutils-src/c89stringutils",
        "build-cov/_deps/cfs-src/include",
    ):
        if os.path.isdir(sub):
            clang_args.append(f"-I{sub}")

    if sys.platform == "darwin":
        try:
            sdk = subprocess.check_output(
                ["xcrun", "--show-sdk-path"], text=True
            ).strip()
            if sdk and os.path.exists(sdk):
                clang_args.extend(["-isysroot", sdk])
        except (subprocess.SubprocessError, OSError):
            pass

    return resolve_std_header_args(idx, clang_args)


def check_fn_ptr_return_enum(cur, fpath):
    """Check whether a cursor declaring a function pointer returns an enum.

    @param cur AST `Cursor` to inspect for function-pointer types.
    @param fpath Source file `Path` owning `cur` for diagnostic reporting.
    @return `1` if `cur` declares a non-enum-returning function pointer, else `0`.
    """
    t = cur.type
    if t.kind == TypeKind.TYPEDEF:
        t = cur.underlying_typedef_type
    while t.kind == TypeKind.POINTER:
        t = t.get_pointee()
    canon = t.get_canonical()
    if canon.kind in (TypeKind.FUNCTIONPROTO, TypeKind.FUNCTIONNOPROTO):
        res_canon = canon.get_result().get_canonical()
        if res_canon.kind != TypeKind.ENUM:
            print(
                f"{fpath}:{cur.location.line}: error: function pointer `{cur.spelling}` "
                f"returns `{canon.get_result().spelling}` instead of enum `fortran_orm_error_t`",
                file=sys.stderr,
            )
            return 1
    return 0


def main():
    """CLI entry point checking enum return types and zero `(void)` discards.

    @return Process exit status (`0` on full compliance, `1` otherwise).
    """
    parser = argparse.ArgumentParser(description="Enforce enum return types in C89.")
    parser.add_argument("paths", nargs="*", default=["include", "src"])
    args = parser.parse_args()

    init_libclang()
    idx = Index.create()
    clang_args = collect_clang_args(idx)

    files = []
    for p in args.paths:
        pt = Path(p)
        if pt.is_file() and pt.suffix in (".c", ".h"):
            files.append(pt)
        elif pt.is_dir():
            files.extend(sorted(pt.rglob("*.h")))
            files.extend(sorted(pt.rglob("*.c")))

    errors = 0
    void_cast_re = re.compile(r"\(\s*void\s*\)\s*[A-Za-z_]")
    for fpath in files:
        f_abs = str(fpath.resolve())
        txt = fpath.read_text(encoding="utf-8")
        for lno, line in enumerate(txt.splitlines(), start=1):
            if fpath.suffix == ".c" and void_cast_re.search(line):
                print(
                    f"{fpath}:{lno}: error: forbidden `(void)` discard in C implementation",
                    file=sys.stderr,
                )
                errors += 1

        tu = idx.parse(f_abs, args=clang_args)
        for diag in tu.diagnostics:
            if diag.severity >= Diagnostic.Error:
                print(f"{fpath}: clang parse error: {diag}", file=sys.stderr)
                errors += 1

        for cur in tu.cursor.walk_preorder():
            if not cur.location.file:
                continue
            if os.path.abspath(cur.location.file.name) != f_abs:
                continue
            if cur.kind == CursorKind.FUNCTION_DECL:
                canon = cur.result_type.get_canonical()
                if canon.kind != TypeKind.ENUM:
                    print(
                        f"{fpath}:{cur.location.line}: error: function `{cur.spelling}` "
                        f"returns `{cur.result_type.spelling}` instead of enum `fortran_orm_error_t`",
                        file=sys.stderr,
                    )
                    errors += 1
            elif cur.kind in (
                CursorKind.TYPEDEF_DECL,
                CursorKind.FIELD_DECL,
                CursorKind.PARM_DECL,
                CursorKind.VAR_DECL,
            ):
                errors += check_fn_ptr_return_enum(cur, fpath)

    if errors:
        return 1
    print(
        f"OK: All {len(files)} C89 headers/sources return `fortran_orm_error_t` with zero `(void)` discards."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
