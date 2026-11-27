# Error Handling & `fortran_orm_error_t`

`fortran-orm` enforces a **single unified error enum** (`fortran_orm_error_t` in `include/fortran_orm_error.h`) across the entire codebase, annotated with `FORTRAN_ORM_NO_DISCARD` (`[[nodiscard]]` / `__attribute__((warn_unused_result))`). Zero `unwrap` patterns and zero `(void)` return discards are permitted.

| Value | Symbolic Name | Meaning |
| :-: | :--- | :--- |
| `0` | `FORTRAN_ORM_OK` | Operation succeeded |
| `1..31` | `FORTRAN_ORM_ERROR_MEMORY` .. `COPYBOOK_SYNTAX` | Exact 1:1 mapping from `c-orm`'s `c_orm_error_t` |
| `32` | `FORTRAN_ORM_ERROR_INVALID_HANDLE` | `NULL`, closed, or magic-corrupted handle / legacy slot |
| `33` | `FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL` | All 64 concurrent legacy/F77 integer handle slots are occupied |
| `34` | `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL` | Caller vector, matrix, or struct array capacity exceeded |
| `35` | `FORTRAN_ORM_ERROR_INVALID_INDEX` | 1-based parameter, column, row, or shard index out of bounds |
| `36` | `FORTRAN_ORM_ERROR_INVALID_OPCODE` | Unrecognized legacy (`ICORMF`/`CORM66`) or F77 mode selector |
| `37` | `FORTRAN_ORM_ERROR_DESCRIPTOR_RANK` | Unsupported `CFI_cdesc_t` rank (must be `0` for `CHARACTER`, `1` or `2` for numeric arrays) |
| `38` | `FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE` | Unsupported `CFI_cdesc_t` element byte size (must be `4`-byte `INT32` or `8`-byte `REAL64`) |
