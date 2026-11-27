# Architecture

## 1. Design Philosophy

`fortran-orm` bridges [`c-orm`](../c-orm)'s strict ISO C89 multi-backend ORM engine to every generation of FORTRAN/Fortran without compromising either historical dialect authenticity or modern zero-copy scientific performance.

### Five-Tier ABI Architecture

| Tier | Standards Covered | Interop Mechanism | C89 Bridge Unit |
| :--- | :--- | :--- | :--- |
| **Tier 1** | `FORTRAN (I)`, `FORTRAN II`, `FORTRAN III`, `FORTRAN IV`, `FORTRAN 66` | 6-char symbols (`ICORMF`, `ICORMB`, `CORM66`, `CORMMD`) in `name_`, `name`, and `NAME` forms; integer handle slots (`1..64`); unpacked `A1` & packed `A4` Hollerith arrays | `src/fortran_orm_legacy.c` |
| **Tier 2** | `FORTRAN 77` | 6-char `CF77*` subroutines accepting `CHARACTER*(*)` with hidden trailing `fortran_charlen_t` lengths + `include/fortran/fortran_orm_f77.inc` | `src/fortran_orm_f77_bridge.c` |
| **Tier 3** | `Fortran 90`, `Fortran 95` | Free-form `MODULE` wrappers with explicit `INTERFACE` blocks, generic `corm_f90_bind`/`corm_f90_col` overloads, `ALLOCATABLE` 2D matrices, and `PURE`/`ELEMENTAL`/`FORALL` | `src/fortran_orm_f77_bridge.c` |
| **Tier 4** | `Fortran 2003`, `Fortran 2008` | `generated/fortran_orm_c.f90` emitted by `../cdd-c` (`ISO_C_BINDING`), OOP RAII classes with `FINAL` destructors, `SUBMODULE` separation, and `CONTIGUOUS` zero-copy array `C_LOC` | `src/fortran_orm_*.c` |
| **Tier 5** | `Fortran 2018`, `Fortran 2023` | `<ISO_Fortran_binding.h>` `CFI_cdesc_t` descriptors for native `CHARACTER(LEN=*)` and strided `DIMENSION(..)` slices, plus Fortran 2023 `F_C_STRING` | `src/fortran_orm_cfi.c` |

---

## 2. `cdd-c` Code Generation Pipeline

1. `scripts/header_to_cdd_ir.py` parses `include/fortran_orm_ffi.h` using `libclang` (`-std=c90 -fparse-all-comments`), extracting exact evaluated enum constants, `BIND(C)` POD structs (`fortran_orm_decimal_t`, `fortran_orm_pool_stats_t`, `fortran_orm_oauth2_token_pod_t`), `@param[in|out|in,out]` intents, and `fortran_orm_*` function signatures into `ffi/fortran_orm_ffi.json`.
2. `scripts/generate_bindings.sh` invokes `../cdd-c/bin/cdd-c bind -i ffi/fortran_orm_ffi.json -o generated -l fortran -n fortran_orm -m fortran_orm_c --generate-tests`, emitting:
   - `generated/fortran_orm_c.f90` — complete `ISO_C_BINDING` module + `*_str` `CHARACTER(LEN=*)` wrappers.
   - `generated/fortran_orm_c_test.f90` — `TRANSFER`-based ABI byte-size assertions portable across `-std=f2003..f2023`.
   - `generated/fpm.toml` — Fortran Package Manager manifest.

---

## 3. 1-Based Indexing & Blank-Padded String Semantics

- **1-Based Indices Everywhere**: Fortran arrays and character substrings are 1-based by convention. Every parameter index (`param_idx`), result column index (`col_idx`), abstract row index (`row_idx`), and shard slot (`shard_idx`) in `fortran-orm` is **1-based**, internally bounds-checked and translated to `c-orm`'s 0-based column/row vtables.
- **Blank-Padded `CHARACTER` Marshaling**: Input `CHARACTER` slices automatically trim trailing ASCII spaces (`0x20`) unless `fortran_orm_stmt_bind_str_raw` or `F_C_STRING(..., ASIS=.TRUE.)` is called. Output `CHARACTER` buffers are filled with spaces past the logical string length (`out_len`) without corrupting Fortran fixed-length variables with embedded C `NUL` bytes.
