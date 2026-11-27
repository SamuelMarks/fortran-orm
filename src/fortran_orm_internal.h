/**
 * @file fortran_orm_internal.h
 * @brief Private ISO C89 structures, magic handle tags, and marshaling helpers
 * shared across fortran-orm implementation translation units.
 */

#ifndef FORTRAN_ORM_INTERNAL_H
/** @brief Header guard for fortran_orm_internal.h. */
#define FORTRAN_ORM_INTERNAL_H

/* clang-format off */
#include "fortran_orm_ffi.h"
#include "c_orm_api.h"
#include "c_orm_ast.h"
#include "c_orm_db2.h"
#include "c_orm_decimal.h"
#include "c_orm_ebcdic.h"
#include "c_orm_migrations.h"
#include "c_orm_oauth2.h"
#include "c_orm_odbc.h"
#include "c_orm_uuid.h"
#include "abstract_struct.h"
/* clang-format on */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/** @brief Active magic tag for `fortran_orm_db_t`. */
#define FORTRAN_ORM_MAGIC_DB 0x464F4442u
/** @brief Active magic tag for `fortran_orm_stmt_t`. */
#define FORTRAN_ORM_MAGIC_STMT 0x464F5354u
/** @brief Active magic tag for `fortran_orm_pool_t`. */
#define FORTRAN_ORM_MAGIC_POOL 0x464F504Cu
/** @brief Active magic tag for `fortran_orm_ast_t`. */
#define FORTRAN_ORM_MAGIC_AST 0x464F4153u
/** @brief Active magic tag for `fortran_orm_rs_t`. */
#define FORTRAN_ORM_MAGIC_RS 0x464F5253u
/** @brief Active magic tag for `fortran_orm_mig_t`. */
#define FORTRAN_ORM_MAGIC_MIG 0x464F4D47u
/** @brief Active magic tag for `fortran_orm_schema_t`. */
#define FORTRAN_ORM_MAGIC_SCHEMA 0x464F5343u
/** @brief Active magic tag for `fortran_orm_shard_t`. */
#define FORTRAN_ORM_MAGIC_SHARD 0x464F5348u

/**
 * @brief Concrete database connection handle wrapper.
 */
struct fortran_orm_db {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_DB`). */
  fortran_orm_u32_t magic;
  /** @brief Underlying `c-orm` database connection. */
  c_orm_db_t *db;
  /** @brief Non-zero if leased from a `fortran_orm_pool_t`. */
  int is_pooled;
  /** @brief Optional heap-owned IANA timezone name string. */
  char *owned_tz_name;
};

/**
 * @brief Concrete prepared statement handle wrapper.
 */
struct fortran_orm_stmt {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_STMT`). */
  fortran_orm_u32_t magic;
  /** @brief Owning `c-orm` database connection. */
  c_orm_db_t *db;
  /** @brief Underlying driver statement pointer. */
  c_orm_query_t *query;
  /** @brief Non-zero if leased via `c_orm_prepare_cached`. */
  int is_cached;
};

/**
 * @brief Concrete connection pool handle wrapper.
 */
struct fortran_orm_pool {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_POOL`). */
  fortran_orm_u32_t magic;
  /** @brief Underlying `c-orm` connection pool. */
  c_orm_pool_t *pool;
};

/**
 * @brief Concrete arena-backed AST query builder handle wrapper.
 */
struct fortran_orm_ast {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_AST`). */
  fortran_orm_u32_t magic;
  /** @brief Underlying `c-orm` fluent AST query builder. */
  c_orm_ast_query_t *q;
  /** @brief Non-zero once at least one `WHERE` clause has been added. */
  int has_where;
};

/**
 * @brief Concrete dynamic abstract result-set handle wrapper.
 */
struct fortran_orm_rs {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_RS`). */
  fortran_orm_u32_t magic;
  /** @brief Underlying array of hydrated key-value row dictionaries. */
  cdd_c_abstract_struct_array_t arr;
};

/**
 * @brief Concrete schema migration runner handle wrapper.
 */
struct fortran_orm_mig {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_MIG`). */
  fortran_orm_u32_t magic;
  /** @brief Target `c-orm` database connection. */
  c_orm_db_t *db;
  /** @brief Heap-owned directory path containing `.sql` migrations. */
  char *dir_path;
};

/**
 * @brief Concrete runtime struct reflection schema handle.
 */
struct fortran_orm_schema {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_SCHEMA`). */
  fortran_orm_u32_t magic;
  /** @brief Synthesized `c-orm` table metadata descriptor. */
  c_orm_table_meta_t meta;
  /** @brief Dynamically grown column metadata array. */
  c_orm_column_meta_t *cols;
  /** @brief Allocated capacity of `cols`. */
  size_t cols_cap;
  /** @brief Dynamically grown relationship metadata array. */
  c_orm_relation_meta_t *rels;
  /** @brief Allocated capacity of `rels`. */
  size_t rels_cap;
  /** @brief Heap-owned string pool freed on `fortran_orm_schema_free`. */
  char **owned_strs;
  /** @brief Number of strings stored in `owned_strs`. */
  size_t owned_strs_count;
  /** @brief Capacity of `owned_strs`. */
  size_t owned_strs_cap;
  /** @brief Non-zero once SQL query templates have been compiled. */
  int built;
};

/**
 * @brief Concrete horizontal shard manager handle wrapper.
 */
struct fortran_orm_shard {
  /** @brief Handle validity tag (`FORTRAN_ORM_MAGIC_SHARD`). */
  fortran_orm_u32_t magic;
  /** @brief Underlying `c-orm` shard manager. */
  c_orm_shard_manager_t *mgr;
  /** @brief Configured shard slot count. */
  fortran_orm_u32_t num_shards;
  /** @brief Array of bound `c_orm_db_t *` pointers for 1-based reverse lookup.
   */
  c_orm_db_t **nodes;
};

/**
 * @brief Preserves `primary` error if non-OK, otherwise returns `secondary`.
 *
 * @param[in] primary Primary operation status.
 * @param[in] secondary Cleanup operation status.
 * @return Combined error enum without discarding either status.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t fortran_orm_keep_err(
    fortran_orm_error_t primary, fortran_orm_error_t secondary);

/**
 * @brief Converts a `c_orm_error_t` status into `fortran_orm_error_t`.
 *
 * @param[in] rc Source `c-orm` status code.
 * @return Corresponding `fortran_orm_error_t` value.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t fortran_orm_from_c(c_orm_error_t rc);

/**
 * @brief Validates a `fortran_orm_db_t` handle pointer.
 *
 * @param[in] db Candidate DB handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_check_db(const fortran_orm_db_t *db);

/**
 * @brief Validates a `fortran_orm_stmt_t` handle pointer.
 *
 * @param[in] stmt Candidate statement handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_check_stmt(const fortran_orm_stmt_t *stmt);

/**
 * @brief Allocates a NUL-terminated C string from a Fortran character slice.
 *
 * @param[in] buf Source Fortran character buffer (may be NULL if `len == 0`).
 * @param[in] len Byte length of `buf`.
 * @param[in] trim_right Non-zero to strip trailing ASCII spaces (`0x20`).
 * @param[out] out_cstr Receives heap-allocated NUL-terminated string (free via
 * `c_orm_system_free`).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t fortran_orm_slice_to_cstr(
    const char *buf, fortran_orm_u32_t len, int trim_right, char **out_cstr);

/**
 * @brief Copies a NUL-terminated C string into a blank-padded Fortran buffer.
 *
 * @param[in] cstr Source NUL-terminated C string (treated as `""` if NULL).
 * @param[out] out_buf Destination Fortran character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives full source byte length excluding NUL.
 * @return `FORTRAN_ORM_OK` on success, `FORTRAN_ORM_ERROR_NULL_POINTER`, or
 * `FORTRAN_ORM_ERROR_TRUNCATION` when `strlen(cstr) > buf_cap`.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cstr_to_fbuf(const char *cstr, char *out_buf,
                         fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Allocates a NUL-terminated C string from an unpacked `A1` `INTEGER*4`
 * array (`1` character code per integer).
 *
 * @param[in] a1_codes Source `INTEGER*4` array.
 * @param[in] count Number of integer elements.
 * @param[out] out_cstr Receives heap-allocated NUL-terminated string.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_a1_to_cstr(const fortran_orm_i32_t *a1_codes,
                       fortran_orm_u32_t count, char **out_cstr);

/**
 * @brief Allocates a NUL-terminated C string from a packed `A4` Hollerith
 * `INTEGER*4` buffer of `byte_len` bytes.
 *
 * @param[in] a4_words Source packed Hollerith integer buffer.
 * @param[in] byte_len Number of valid character bytes in `a4_words`.
 * @param[out] out_cstr Receives heap-allocated NUL-terminated string.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_a4_to_cstr(const fortran_orm_i32_t *a4_words,
                       fortran_orm_u32_t byte_len, char **out_cstr);

/**
 * @brief Copies a NUL-terminated C string into a packed `A4` Hollerith
 * `INTEGER*4` buffer (blank-padded with `' '` up to `byte_cap`).
 *
 * @param[in] cstr Source NUL-terminated C string.
 * @param[out] out_words Destination `INTEGER*4` buffer.
 * @param[in] byte_cap Capacity of `out_words` in bytes.
 * @param[out] out_len Receives source string byte length.
 * @return `FORTRAN_ORM_OK` on success, or truncation/NULL error.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cstr_to_a4(const char *cstr, fortran_orm_i32_t *out_words,
                       fortran_orm_u32_t byte_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Converts `fortran_orm_decimal_t` into `c_orm_decimal_t`.
 *
 * @param[in] src Source Fortran POD decimal.
 * @param[out] dst Destination `c-orm` decimal.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NULL_POINTER`.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_to_c(const fortran_orm_decimal_t *src, c_orm_decimal_t *dst);

/**
 * @brief Converts `c_orm_decimal_t` into `fortran_orm_decimal_t`.
 *
 * @param[in] src Source `c-orm` decimal.
 * @param[out] dst Destination Fortran POD decimal.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NULL_POINTER`.
 */
FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_from_c(const c_orm_decimal_t *src, fortran_orm_decimal_t *dst);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* FORTRAN_ORM_INTERNAL_H */
