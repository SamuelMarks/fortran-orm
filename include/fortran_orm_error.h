/**
 * @file fortran_orm_error.h
 * @brief Unified strongly-typed error enumeration for fortran-orm, aligned 1:1
 * with c-orm's c_orm_error_t plus Fortran FFI marshaling codes.
 */

#ifndef FORTRAN_ORM_ERROR_H
/** @brief Header guard for fortran_orm_error.h. */
#define FORTRAN_ORM_ERROR_H

/* clang-format off */
#include "fortran_orm_export.h"
/* clang-format on */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
 * @brief Unified error status enumeration returned by every function in
 * fortran-orm (`FORTRAN_ORM_OK == 0`).
 */
typedef enum fortran_orm_error {
  /** @brief Operation succeeded (`C_ORM_OK`). */
  FORTRAN_ORM_OK = 0,
  /** @brief Out-of-memory allocation failure (`C_ORM_ERROR_MEMORY`). */
  FORTRAN_ORM_ERROR_MEMORY = 1,
  /** @brief Database connection failure (`C_ORM_ERROR_CONNECTION`). */
  FORTRAN_ORM_ERROR_CONNECTION = 2,
  /** @brief SQL syntax or execution error (`C_ORM_ERROR_SQL`). */
  FORTRAN_ORM_ERROR_SQL = 3,
  /** @brief Statement parameter bind failure (`C_ORM_ERROR_BIND`). */
  FORTRAN_ORM_ERROR_BIND = 4,
  /** @brief Prepared statement step failure (`C_ORM_ERROR_STEP`). */
  FORTRAN_ORM_ERROR_STEP = 5,
  /** @brief Column or parameter type mismatch (`C_ORM_ERROR_TYPE_MISMATCH`). */
  FORTRAN_ORM_ERROR_TYPE_MISMATCH = 6,
  /** @brief Requested row or key not found (`C_ORM_ERROR_NOT_FOUND`). */
  FORTRAN_ORM_ERROR_NOT_FOUND = 7,
  /** @brief Feature not implemented by driver (`C_ORM_ERROR_NOT_IMPLEMENTED`).
   */
  FORTRAN_ORM_ERROR_NOT_IMPLEMENTED = 8,
  /** @brief Unclassified driver error (`C_ORM_ERROR_UNKNOWN`). */
  FORTRAN_ORM_ERROR_UNKNOWN = 9,
  /** @brief Cached record TTL expired (`C_ORM_ERROR_EXPIRED`). */
  FORTRAN_ORM_ERROR_EXPIRED = 10,
  /** @brief Domain or argument validation error (`C_ORM_ERROR_VALIDATION`). */
  FORTRAN_ORM_ERROR_VALIDATION = 11,
  /** @brief Maximum recursion depth exceeded (`C_ORM_ERROR_RECURSION`). */
  FORTRAN_ORM_ERROR_RECURSION = 12,
  /** @brief Mutation attempted on read-only view (`C_ORM_ERROR_READ_ONLY`). */
  FORTRAN_ORM_ERROR_READ_ONLY = 13,
  /** @brief Unexpected NULL pointer argument (`C_ORM_ERROR_NULL_POINTER`). */
  FORTRAN_ORM_ERROR_NULL_POINTER = 14,
  /** @brief File or OS CSPRNG I/O error (`C_ORM_ERROR_IO`). */
  FORTRAN_ORM_ERROR_IO = 15,
  /** @brief SQL, JSON, or schema parse failure (`C_ORM_ERROR_PARSE`). */
  FORTRAN_ORM_ERROR_PARSE = 16,
  /** @brief Arithmetic or buffer size overflow (`C_ORM_ERROR_OVERFLOW`). */
  FORTRAN_ORM_ERROR_OVERFLOW = 17,
  /** @brief Cyclic graph dependency detected (`C_ORM_ERROR_CYCLE`). */
  FORTRAN_ORM_ERROR_CYCLE = 18,
  /** @brief Database lock contention / busy (`C_ORM_ERROR_BUSY`). */
  FORTRAN_ORM_ERROR_BUSY = 19,
  /** @brief Cryptographic operation failed (`C_ORM_ERROR_CRYPTO`). */
  FORTRAN_ORM_ERROR_CRYPTO = 20,
  /** @brief Unique/FK/check constraint violation (`C_ORM_ERROR_CONSTRAINT`). */
  FORTRAN_ORM_ERROR_CONSTRAINT = 21,
  /** @brief Dynamic driver client load failure (`C_ORM_ERROR_DRIVER_LOAD`). */
  FORTRAN_ORM_ERROR_DRIVER_LOAD = 22,
  /** @brief ODBC / Db2 CLI diagnostic error (`C_ORM_ERROR_ODBC_DIAG`). */
  FORTRAN_ORM_ERROR_ODBC_DIAG = 23,
  /** @brief Pool or login timeout expired (`C_ORM_ERROR_TIMEOUT`). */
  FORTRAN_ORM_ERROR_TIMEOUT = 24,
  /** @brief Transaction deadlock detected (`C_ORM_ERROR_DEADLOCK`). */
  FORTRAN_ORM_ERROR_DEADLOCK = 25,
  /** @brief Disallowed string/binary truncation (`C_ORM_ERROR_TRUNCATION`). */
  FORTRAN_ORM_ERROR_TRUNCATION = 26,
  /** @brief Invalid decimal string or BCD nybble
     (`C_ORM_ERROR_DECIMAL_SYNTAX`). */
  FORTRAN_ORM_ERROR_DECIMAL_SYNTAX = 27,
  /** @brief Decimal overflow or divide-by-zero
     (`C_ORM_ERROR_DECIMAL_OVERFLOW`). */
  FORTRAN_ORM_ERROR_DECIMAL_OVERFLOW = 28,
  /** @brief Inexact rounding under exact mode (`C_ORM_ERROR_DECIMAL_INEXACT`).
   */
  FORTRAN_ORM_ERROR_DECIMAL_INEXACT = 29,
  /** @brief Invalid UTF-8/UTF-16/EBCDIC sequence (`C_ORM_ERROR_CODEPAGE`). */
  FORTRAN_ORM_ERROR_CODEPAGE = 30,
  /** @brief Reserved Copybook syntax code (`C_ORM_ERROR_COPYBOOK_SYNTAX`). */
  FORTRAN_ORM_ERROR_COPYBOOK_SYNTAX = 31,
  /** @brief Null, closed, or corrupted Fortran FFI handle or slot ID. */
  FORTRAN_ORM_ERROR_INVALID_HANDLE = 32,
  /** @brief Legacy integer handle slot table capacity exhausted. */
  FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL = 33,
  /** @brief Caller array/matrix capacity smaller than result count. */
  FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL = 34,
  /** @brief 1-based parameter, column, or row index out of valid bounds. */
  FORTRAN_ORM_ERROR_INVALID_INDEX = 35,
  /** @brief Unrecognized FORTRAN I / legacy dispatcher opcode. */
  FORTRAN_ORM_ERROR_INVALID_OPCODE = 36,
  /** @brief Invalid Fortran 2018 CFI_cdesc_t array rank. */
  FORTRAN_ORM_ERROR_DESCRIPTOR_RANK = 37,
  /** @brief Unsupported Fortran 2018 CFI_cdesc_t element type. */
  FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE = 38
} fortran_orm_error_t;

/**
 * @brief Copies the canonical symbolic name of `err` into a blank-padded
 * Fortran character buffer (or NUL-free fixed buffer).
 *
 * @param[in] err Error code to format.
 * @param[out] out_buf Destination character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed character length of the symbolic name.
 * @return `FORTRAN_ORM_OK` on success, `FORTRAN_ORM_ERROR_NULL_POINTER` if
 * `out_buf` or `out_len` is NULL, or `FORTRAN_ORM_ERROR_TRUNCATION` if
 * `buf_cap` is smaller than the name length.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_error_name(fortran_orm_error_t err, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* FORTRAN_ORM_ERROR_H */
