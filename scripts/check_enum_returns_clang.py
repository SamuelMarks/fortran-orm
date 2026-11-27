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
import clang.cindex
from clang.cindex import Config, CursorKind, Index, LibclangError, TypeKind


def init_libclang():
    """Locate libclang shared library across macOS and Linux."""
    try:
        _ = Config().lib
        return
    except (LibclangError, OSError):
        pass
    for pat in (
        "/Library/Developer/CommandLineTools/usr/lib/libclang*.dylib",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang*.dylib",
        "/opt/homebrew/opt/llvm/lib/libclang*.dylib",
        "/usr/lib/llvm-*/lib/libclang.so*",
        "/usr/lib/x86_64-linux-gnu/libclang*.so*",
    ):
        for cand in glob.glob(pat):
            if "libclang-cpp" not in cand and os.path.isfile(cand):
                try:
                    Config.set_library_file(cand)
                    _ = Config().lib
                    return
                except (LibclangError, OSError):
                    continue


def main():
    """CLI entry point checking enum return types and zero (void) discards."""
    parser = argparse.ArgumentParser(description="Enforce enum return types in C89.")
    parser.add_argument("paths", nargs="*", default=["include", "src"])
    args = parser.parse_args()

    init_libclang()
    idx = Index.create()

    clang_args = ["-std=c90", "-x", "c", "-Iinclude", "-Isrc", "-I../c-orm/include"]
    for sub in (
        "build/_deps/cdd_c-src/include",
        "build/_deps/cdd_c-src/src",
        "build/_deps/c_str_span-src/c_str_span",
        "build/_deps/c89stringutils-src/c89stringutils",
        "build/_deps/cfs-src/include",
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
    print(f"OK: All {len(files)} C89 headers/sources return `fortran_orm_error_t` with zero `(void)` discards.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
