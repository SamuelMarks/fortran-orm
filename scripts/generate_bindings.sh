#!/usr/bin/env bash
# @file generate_bindings.sh
# @module fortran_orm_codegen
# @brief Reproducibly extracts fortran-orm FFI IR via libclang and invokes
# ../cdd-c (`cdd-c bind -l fortran`) to generate ISO_C_BINDING module
# `generated/fortran_orm_c.f90`, `generated/fpm.toml`, and ABI layout tests
# `generated/fortran_orm_c_test.f90`.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_MODE=0
if [ "${1:-}" = "--check" ]; then
  CHECK_MODE=1
fi

CDD_BIN="${FORTRAN_ORM_CDD_C_BIN:-}"
if [ -z "$CDD_BIN" ]; then
  if [ -x "$ROOT_DIR/../cdd-c/bin/cdd-c" ]; then
    CDD_BIN="$ROOT_DIR/../cdd-c/bin/cdd-c"
  elif command -v cdd-c >/dev/null 2>&1; then
    CDD_BIN="$(command -v cdd-c)"
  else
    echo "Error: cdd-c binary not found (set FORTRAN_ORM_CDD_C_BIN or build ../cdd-c)" >&2
    exit 1
  fi
fi

WORK_DIR="$ROOT_DIR"
TMP_STAGE=""
if [ "$CHECK_MODE" -eq 1 ]; then
  TMP_STAGE="$(mktemp -d)"
  trap 'rm -rf "$TMP_STAGE"' EXIT
  WORK_DIR="$TMP_STAGE"
fi

mkdir -p "$WORK_DIR/ffi" "$WORK_DIR/generated"

# Step 1: Extract lossless normalized FFI IR JSON from ISO C89 headers
python3 "$ROOT_DIR/scripts/header_to_cdd_ir.py" \
  -i "$ROOT_DIR/include/fortran_orm_ffi.h" \
  -I "$ROOT_DIR/include" \
  -o "$WORK_DIR/ffi/fortran_orm_ffi.json"

# Step 2: Run cdd-c bind -l fortran on the normalized FFI IR
"$CDD_BIN" bind \
  -i "$WORK_DIR/ffi/fortran_orm_ffi.json" \
  -o "$WORK_DIR/generated" \
  -l fortran \
  -n fortran_orm \
  -m fortran_orm_c \
  --generate-tests

if [ "$CHECK_MODE" -eq 1 ]; then
  diff -ru "$ROOT_DIR/ffi/fortran_orm_ffi.json" "$WORK_DIR/ffi/fortran_orm_ffi.json"
  diff -ru "$ROOT_DIR/generated" "$WORK_DIR/generated"
  echo "OK: generated Fortran FFI bindings match live cdd-c output byte-for-byte."
else
  echo "Generated Fortran FFI bindings via $CDD_BIN successfully."
fi
