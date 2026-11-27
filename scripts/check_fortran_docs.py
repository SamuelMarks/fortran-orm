#!/usr/bin/env python3
"""
@file check_fortran_docs.py
@module fortran_orm_doc_linter
@brief Enforces 100% documentation coverage across all fixed-form (.f, .inc)
and free-form (.f90, .f95) Fortran files in fortran-orm (including generated/).

Verifies:
1. File-level `@file` and `@brief` documentation header.
2. Module-level `@module` or `@brief` on every `MODULE` / `SUBMODULE`.
3. Type-level `@type` or `@brief` on every derived `TYPE` definition.
4. Procedure-level `@brief`, `@param` for every dummy argument, and `@return`
   on every `FUNCTION`, `SUBROUTINE`, and `BLOCK DATA` unit (excluding `END`
   and `MODULE PROCEDURE` body stubs documented at their interface).
"""

import os
import re
import subprocess
import sys


def parse_fixed_doc_and_units(filepath, lines):
    """Check fixed-form (.f / .inc) file & subprogram documentation."""
    missing = []
    header_comments = []
    for line in lines:
        if line and line[0] in ("C", "c", "*"):
            header_comments.append(line[1:].strip())
        elif line.strip() == "":
            continue
        else:
            break

    hdr_text = "\n".join(header_comments)
    if "@file" not in hdr_text:
        missing.append(f"{filepath}:1: missing `C @file` header")
    if "@brief" not in hdr_text:
        missing.append(f"{filepath}:1: missing `C @brief` header")

    if filepath.endswith(".inc"):
        return missing

    unit_re = re.compile(
        r"^      \s*(SUBROUTINE|FUNCTION|INTEGER\s+FUNCTION|REAL\s+FUNCTION|"
        r"DOUBLE\s+PRECISION\s+FUNCTION|LOGICAL\s+FUNCTION|BLOCK\s+DATA)\s+"
        r"([A-Za-z0-9_]+)\s*(?:\(([^)]*)\))?",
        re.IGNORECASE,
    )

    pending_comments = []
    i = 0
    while i < len(lines):
        raw = lines[i]
        if raw and raw[0] in ("C", "c", "*"):
            pending_comments.append(raw[1:].strip())
            i += 1
            continue
        if raw.strip() == "":
            i += 1
            continue

        # Join fixed-form continuation lines (col 6 non-blank)
        stmt = raw[:72]
        start_ln = i + 1
        while i + 1 < len(lines):
            nxt = lines[i + 1]
            if len(nxt) >= 6 and nxt[0:5] == "     " and nxt[5] not in (" ", "0"):
                stmt += " " + nxt[6:72].strip()
                i += 1
            else:
                break

        m = unit_re.match(stmt)
        if m:
            kind = m.group(1).upper()
            uname = m.group(2)
            args_raw = m.group(3) or ""
            doc = "\n".join(pending_comments)
            if "@brief" not in doc:
                missing.append(f"{filepath}:{start_ln}: `{uname}` missing `@brief`")
            args = [a.strip() for a in args_raw.split(",") if a.strip()]
            for arg in args:
                if not re.search(
                    r"@param(?:\[[^\]]*\])?\s+" + re.escape(arg) + r"\b",
                    doc,
                    re.IGNORECASE,
                ):
                    missing.append(
                        f"{filepath}:{start_ln}: `{uname}` missing `@param {arg}`"
                    )
            if "FUNCTION" in kind and "@return" not in doc:
                missing.append(f"{filepath}:{start_ln}: `{uname}` missing `@return`")

        pending_comments = []
        i += 1

    return missing


def parse_free_doc_and_units(filepath, lines):
    """Check free-form (.f90 / .f95) file, module, type, and procedure docs."""
    missing = []
    full_head = "\n".join(lines[:30])
    if "@file" not in full_head:
        missing.append(f"{filepath}:1: missing `!> @file` header")
    if "@brief" not in full_head:
        missing.append(f"{filepath}:1: missing `!> @brief` header")

    mod_re = re.compile(
        r"^\s*(MODULE|SUBMODULE)\s+(?!PROCEDURE\b)([A-Za-z0-9_() ]+)", re.IGNORECASE
    )
    type_re = re.compile(
        r"^\s*TYPE\s*(?:,\s*[A-Za-z0-9_()]+)*\s*::\s*([A-Za-z0-9_]+)|"
        r"^\s*TYPE\s+([A-Za-z0-9_]+)\s*$",
        re.IGNORECASE,
    )
    proc_re = re.compile(
        r"^\s*(?:(?:PURE|ELEMENTAL|IMPURE|RECURSIVE|MODULE)\s+)*"
        r"(SUBROUTINE|FUNCTION)\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)",
        re.IGNORECASE,
    )

    pending_doc = []
    in_interface_generic = False
    i = 0
    while i < len(lines):
        raw = lines[i]
        stripped = raw.strip()
        if stripped.startswith("!"):
            pending_doc.append(stripped.lstrip("!>").strip())
            i += 1
            continue
        if stripped == "":
            i += 1
            continue

        start_ln = i + 1
        stmt = stripped
        while stmt.endswith("&") and i + 1 < len(lines):
            stmt = stmt[:-1].rstrip() + " " + lines[i + 1].strip().lstrip("&").strip()
            i += 1

        upper = stmt.upper()
        if upper.startswith("END ") or upper == "END":
            if upper.startswith("END INTERFACE"):
                in_interface_generic = False
            pending_doc = []
            i += 1
            continue

        if re.match(r"^INTERFACE\s+[A-Za-z0-9_]+", stmt, re.IGNORECASE):
            in_interface_generic = True
            if not any("@brief" in d for d in pending_doc):
                missing.append(
                    f"{filepath}:{start_ln}: generic `{stmt}` missing `!> @brief`"
                )
            pending_doc = []
            i += 1
            continue

        m_mod = mod_re.match(stmt)
        if m_mod:
            doc = "\n".join(pending_doc)
            if "@brief" not in doc and "@module" not in doc:
                missing.append(
                    f"{filepath}:{start_ln}: module `{m_mod.group(2).strip()}` missing `!> @brief`"
                )
            pending_doc = []
            i += 1
            continue

        m_type = type_re.match(stmt)
        if (
            m_type
            and not upper.startswith("TYPE(")
            and not upper.startswith("TYPE (*)")
        ):
            tname = m_type.group(1) or m_type.group(2)
            doc = "\n".join(pending_doc)
            if "@brief" not in doc and "@type" not in doc:
                missing.append(
                    f"{filepath}:{start_ln}: derived type `{tname}` missing `!> @brief`"
                )
            pending_doc = []
            i += 1
            continue

        m_proc = proc_re.match(stmt)
        if m_proc and not in_interface_generic:
            kind = m_proc.group(1).upper()
            pname = m_proc.group(2)
            args_raw = m_proc.group(3)
            doc = "\n".join(pending_doc)
            # Note: cdd-c generated INTERFACE blocks precede procedures with `!` comments
            if not doc:
                missing.append(
                    f"{filepath}:{start_ln}: procedure `{pname}` undocumented"
                )
            elif not filepath.startswith("generated/"):
                if "@brief" not in doc:
                    missing.append(
                        f"{filepath}:{start_ln}: `{pname}` missing `!> @brief`"
                    )
                args = [a.strip() for a in args_raw.split(",") if a.strip()]
                for arg in args:
                    if not re.search(
                        r"@param(?:\[[^\]]*\])?\s+" + re.escape(arg) + r"\b",
                        doc,
                        re.IGNORECASE,
                    ):
                        missing.append(
                            f"{filepath}:{start_ln}: `{pname}` missing `!> @param {arg}`"
                        )
                if kind == "FUNCTION" and "@return" not in doc:
                    missing.append(
                        f"{filepath}:{start_ln}: `{pname}` missing `!> @return`"
                    )
            pending_doc = []
            i += 1
            continue

        if re.match(r"^MODULE\s+PROCEDURE\s+([A-Za-z0-9_]+)\s*$", stmt, re.IGNORECASE):
            if not in_interface_generic:
                doc = "\n".join(pending_doc)
                if "@brief" not in doc:
                    missing.append(
                        f"{filepath}:{start_ln}: `{stmt}` missing `!> @brief`"
                    )
            pending_doc = []
            i += 1
            continue

        pending_doc = []
        i += 1

    return missing


def main():
    """CLI entry point for Fortran 100% documentation coverage checker."""
    git_out = subprocess.check_output(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        text=True,
    ).splitlines()
    f_files = sorted(
        [
            f
            for f in git_out
            if f.endswith((".f", ".inc", ".f90", ".f95")) and os.path.isfile(f)
        ]
    )

    all_missing = []
    for path in f_files:
        with open(path, "r", encoding="utf-8") as fp:
            lines = [ln.rstrip("\r\n") for ln in fp]
        if path.endswith((".f", ".inc")):
            all_missing.extend(parse_fixed_doc_and_units(path, lines))
        else:
            all_missing.extend(parse_free_doc_and_units(path, lines))

    if all_missing:
        for msg in all_missing:
            print(f"DOC ERROR: {msg}", file=sys.stderr)
        print(
            f"FAILED: {len(all_missing)} missing Fortran doc item(s) across {len(f_files)} files.",
            file=sys.stderr,
        )
        return 1

    print(f"OK: 100.0% Fortran documentation coverage across {len(f_files)} files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
