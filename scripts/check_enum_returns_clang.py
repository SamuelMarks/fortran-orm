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
import subprocess
import sys
from pathlib import Path


def bootstrap_clang_module():
    """Ensure `clang.cindex` is importable across system, venv, and Homebrew Pythons."""
    try:
        import clang.cindex as _ci  # noqa: F401

        return
    except ModuleNotFoundError:
        py_ver = f"python{sys.version_info.major}.{sys.version_info.minor}"
        search_Site = []
        for pat in (
            f"/opt/homebrew/opt/llvm/lib/{py_ver}/site-packages",
            f"/opt/homebrew/Cellar/llvm*/*/lib/{py_ver}/site-packages",
            f"/usr/local/opt/llvm*/lib/{py_ver}/site-packages",
            "/opt/homebrew/opt/llvm/lib/python*/site-packages",
            "/opt/homebrew/Cellar/llvm*/*/lib/python*/site-packages",
            "/usr/local/opt/llvm*/lib/python*/site-packages",
            "/usr/lib/python3/dist-packages",
        ):
            search_Site.extend(sorted(glob.glob(pat), reverse=True))
        for sp in search_Site:
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


def init_libclang():
    """Locate and initialize libclang shared library across macOS and Linux."""
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


def collect_clang_args():
    """Build complete `-I` and sysroot flags for both local and CI FetchContent trees.

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

    # Ensure Clang builtin headers (<stddef.h>, <stdint.h>) resolve on standalone libclang
    builtin_patterns = (
        "/usr/lib/llvm-*/lib/clang/*/include",
        "/usr/lib/clang/*/include",
        "/opt/homebrew/opt/llvm/lib/clang/*/include",
        "/opt/homebrew/Cellar/llvm*/*/lib/clang/*/include",
    )
    for pat in builtin_patterns:
        matches = sorted(glob.glob(pat), reverse=True)
        if matches and os.path.isdir(matches[0]):
            clang_args.extend(["-isystem", matches[0]])
            break

    if sys.platform == "darwin":
        try:
            sdk = subprocess.check_output(
                ["xcrun", "--show-sdk-path"], text=True
            ).strip()
            if sdk and os.path.exists(sdk):
                clang_args.extend(["-isysroot", sdk])
        except (subprocess.SubprocessError, OSError):
            pass
    return clang_args


def main():
    """CLI entry point checking enum return types and zero `(void)` discards.

    @return Process exit status (`0` on full compliance, `1` otherwise).
    """
    parser = argparse.ArgumentParser(description="Enforce enum return types in C89.")
    parser.add_argument("paths", nargs="*", default=["include", "src"])
    args = parser.parse_args()

    init_libclang()
    idx = Index.create()
    clang_args = collect_clang_args()

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

    if errors:
        return 1
    print(
        f"OK: All {len(files)} C89 headers/sources return `fortran_orm_error_t` with zero `(void)` discards."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
