/**
 * @file fortran_orm_cfi.c
 * @brief ISO/IEC TS 29113 (Fortran 2018 & Fortran 2023) `CFI_cdesc_t`
 * enhanced C interoperability descriptor bridge (`<ISO_Fortran_binding.h>`).
 *
 * Enables Fortran 2018 and Fortran 2023 `BIND(C)` callers to pass native
 * `CHARACTER(LEN=*)` scalar strings and assumed-rank `DIMENSION(..)` arrays
 * (including strided non-contiguous array slices such as `A(1:10:2, :)`)
 * directly without manual `C_LOC` or `C_NULL_CHAR` boilerplate.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#if defined(FORTRAN_ORM_HAS_CFI_HEADER)
#include <ISO_Fortran_binding.h>
#else
/** @brief Portable fallback ABI layout matching ISO/IEC TS 29113 CFI_dim_t. */
typedef struct fortran_cfi_dim {
  /** @brief Lower bound of dimension (ISO ABI slot). */
  /* cppcheck-suppress unusedStructMember */
  ptrdiff_t lower_bound;
  /** @brief Number of elements along dimension. */
  ptrdiff_t extent;
  /** @brief Byte stride (`sm`) between consecutive elements. */
  ptrdiff_t sm;
} CFI_dim_t;

/** @brief Portable fallback ABI layout matching ISO/IEC TS 29113 CFI_cdesc_t. */
typedef struct fortran_cfi_cdesc {
  /** @brief Base address of object data. */
  void *base_addr;
  /** @brief Element byte size (`elem_len`). */
  size_t elem_len;
  /** @brief Descriptor ABI version (`CFI_VERSION`). */
  /* cppcheck-suppress unusedStructMember */
  int version;
  /** @brief Array rank (`0..15`). */
  signed char rank;
  /** @brief Pointer/allocatable attribute code. */
  /* cppcheck-suppress unusedStructMember */
  signed char attribute;
  /** @brief Interoperable type code (`CFI_type_*`). */
  /* cppcheck-suppress unusedStructMember */
  signed char type;
  /** @brief Per-dimension triples (`lower_bound`, `extent`, `sm`). */
  CFI_dim_t dim[15];
} CFI_cdesc_t;
#endif
/* clang-format on */

/**
 * @brief Validates a rank-0 `CHARACTER(LEN=*)` `CFI_cdesc_t` descriptor.
 *
 * @param[in] desc Candidate CFI descriptor.
 * @return `FORTRAN_ORM_OK` or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cfi_check_char0(const CFI_cdesc_t *desc) {
  if (!desc) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (desc->rank != 0) {
    return FORTRAN_ORM_ERROR_DESCRIPTOR_RANK;
  }
  if (desc->elem_len > 0u && !desc->base_addr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  return FORTRAN_ORM_OK;
}

/**
 * @brief Connects to a database directly from a Fortran 2018/2023
 * `CHARACTER(LEN=*)` `BIND(C)` descriptor.
 *
 * @param[in] url_desc Scalar `CHARACTER(LEN=*)` CFI descriptor.
 * @param[out] out_db Receives allocated database handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_connect(const CFI_cdesc_t *url_desc, fortran_orm_db_t **out_db);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_connect(const CFI_cdesc_t *url_desc,
                        fortran_orm_db_t **out_db) {
  fortran_orm_error_t rc = cfi_check_char0(url_desc);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  return fortran_orm_connect((const char *)url_desc->base_addr,
                             (fortran_orm_u32_t)url_desc->elem_len, out_db);
}

/**
 * @brief Executes DDL/DML SQL directly from a Fortran 2018/2023
 * `CHARACTER(LEN=*)` `BIND(C)` descriptor.
 *
 * @param[in] db Active database handle.
 * @param[in] sql_desc Scalar `CHARACTER(LEN=*)` CFI descriptor.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_exec(fortran_orm_db_t *db, const CFI_cdesc_t *sql_desc);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_exec(fortran_orm_db_t *db, const CFI_cdesc_t *sql_desc) {
  fortran_orm_error_t rc = cfi_check_char0(sql_desc);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  return fortran_orm_exec_sql(db, (const char *)sql_desc->base_addr,
                              (fortran_orm_u32_t)sql_desc->elem_len);
}

/**
 * @brief Reads a text column from `stmt` directly into a caller
 * `CHARACTER(LEN=*)` `BIND(C)` descriptor (blank-padded).
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index.
 * @param[out] out_desc Scalar `CHARACTER(LEN=*)` CFI descriptor.
 * @param[out] out_len Receives trimmed character length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_col_str(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                        CFI_cdesc_t *out_desc, fortran_orm_u32_t *out_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_col_str(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                        CFI_cdesc_t *out_desc, fortran_orm_u32_t *out_len) {
  fortran_orm_error_t rc = cfi_check_char0(out_desc);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  return fortran_orm_stmt_col_str(stmt, col_idx, (char *)out_desc->base_addr,
                                  (fortran_orm_u32_t)out_desc->elem_len,
                                  out_len);
}

/**
 * @brief Persists an assumed-rank `DIMENSION(..)` numeric array (`REAL(REAL64)`
 * or `INTEGER(INT32)`) of rank 1 (`N`) or rank 2 (`N x M`, including arbitrary
 * byte strides `sm` from Fortran slices like `A(1:10:2, :)`!) into `db`.
 *
 * @param[in] db Active database handle.
 * @param[in] sql_desc Scalar `CHARACTER(LEN=*)` `INSERT` SQL descriptor.
 * @param[in] arr_desc Assumed-rank (`rank == 1` or `rank == 2`) CFI descriptor.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_insert_numeric(fortran_orm_db_t *db,
                               const CFI_cdesc_t *sql_desc,
                               const CFI_cdesc_t *arr_desc);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_insert_numeric(fortran_orm_db_t *db,
                               const CFI_cdesc_t *sql_desc,
                               const CFI_cdesc_t *arr_desc) {
  fortran_orm_stmt_t *stmt = NULL;
  ptrdiff_t n_rows;
  ptrdiff_t n_cols;
  ptrdiff_t r;
  ptrdiff_t c;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = cfi_check_char0(sql_desc);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!arr_desc) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (arr_desc->rank != 1 && arr_desc->rank != 2) {
    return FORTRAN_ORM_ERROR_DESCRIPTOR_RANK;
  }
  if (arr_desc->elem_len != sizeof(double) &&
      arr_desc->elem_len != sizeof(fortran_orm_i32_t)) {
    return FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE;
  }

  n_rows = arr_desc->dim[0].extent;
  n_cols = (arr_desc->rank == 2) ? arr_desc->dim[1].extent : (ptrdiff_t)1;
  if (n_rows <= 0 || n_cols <= 0) {
    return FORTRAN_ORM_OK;
  }
  if (!arr_desc->base_addr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  rc = fortran_orm_stmt_prepare(db, (const char *)sql_desc->base_addr,
                                (fortran_orm_u32_t)sql_desc->elem_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  for (r = 0; rc == FORTRAN_ORM_OK && r < n_rows; r++) {
    for (c = 0; rc == FORTRAN_ORM_OK && c < n_cols; c++) {
      const char *elem =
          (const char *)arr_desc->base_addr + (r * arr_desc->dim[0].sm) +
          ((arr_desc->rank == 2) ? (c * arr_desc->dim[1].sm) : 0);
      if (arr_desc->elem_len == sizeof(double)) {
        double dv;
        memcpy(&dv, elem, sizeof(double));
        rc = fortran_orm_stmt_bind_f64(stmt, (fortran_orm_i32_t)(c + 1), dv);
      } else {
        fortran_orm_i32_t iv;
        memcpy(&iv, elem, sizeof(fortran_orm_i32_t));
        rc = fortran_orm_stmt_bind_i32(stmt, (fortran_orm_i32_t)(c + 1), iv);
      }
    }
    if (rc == FORTRAN_ORM_OK) {
      rc = fortran_orm_stmt_step(stmt, &has_row);
    }
    if (rc == FORTRAN_ORM_OK) {
      rc = fortran_orm_stmt_reset(stmt);
    }
  }

  frc = fortran_orm_stmt_finalize(stmt);
  return fortran_orm_keep_err(rc, frc);
}

/**
 * @brief Hydrates a SQL `SELECT` query directly into an assumed-rank
 * `DIMENSION(..)` numeric array (`REAL(REAL64)` or `INTEGER(INT32)`, rank 1 or
 * rank 2, including strided slices!).
 *
 * @param[in] db Active database handle.
 * @param[in] sql_desc Scalar `CHARACTER(LEN=*)` `SELECT` SQL descriptor.
 * @param[in,out] out_arr_desc Assumed-rank (`rank == 1` or `rank == 2`) output
 * CFI descriptor.
 * @param[out] out_rows Receives number of rows hydrated.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_query_numeric(fortran_orm_db_t *db, const CFI_cdesc_t *sql_desc,
                              CFI_cdesc_t *out_arr_desc,
                              fortran_orm_u32_t *out_rows);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cfi_query_numeric(fortran_orm_db_t *db, const CFI_cdesc_t *sql_desc,
                              CFI_cdesc_t *out_arr_desc,
                              fortran_orm_u32_t *out_rows) {
  fortran_orm_stmt_t *stmt = NULL;
  ptrdiff_t max_rows;
  ptrdiff_t n_cols;
  ptrdiff_t r = 0;
  ptrdiff_t c;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = cfi_check_char0(sql_desc);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_arr_desc || !out_rows) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_rows = 0u;
  if (out_arr_desc->rank != 1 && out_arr_desc->rank != 2) {
    return FORTRAN_ORM_ERROR_DESCRIPTOR_RANK;
  }
  if (out_arr_desc->elem_len != sizeof(double) &&
      out_arr_desc->elem_len != sizeof(fortran_orm_i32_t)) {
    return FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE;
  }

  max_rows = out_arr_desc->dim[0].extent;
  n_cols =
      (out_arr_desc->rank == 2) ? out_arr_desc->dim[1].extent : (ptrdiff_t)1;
  if (max_rows > 0 && n_cols > 0 && !out_arr_desc->base_addr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  rc = fortran_orm_stmt_prepare(db, (const char *)sql_desc->base_addr,
                                (fortran_orm_u32_t)sql_desc->elem_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  while (rc == FORTRAN_ORM_OK) {
    rc = fortran_orm_stmt_step(stmt, &has_row);
    if (rc != FORTRAN_ORM_OK || !has_row) {
      break;
    }
    if (r >= max_rows) {
      rc = FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL;
      break;
    }
    for (c = 0; rc == FORTRAN_ORM_OK && c < n_cols; c++) {
      char *elem =
          (char *)out_arr_desc->base_addr + (r * out_arr_desc->dim[0].sm) +
          ((out_arr_desc->rank == 2) ? (c * out_arr_desc->dim[1].sm) : 0);
      if (out_arr_desc->elem_len == sizeof(double)) {
        double dv = 0.0;
        rc = fortran_orm_stmt_col_f64(stmt, (fortran_orm_i32_t)(c + 1), &dv);
        memcpy(elem, &dv, sizeof(double));
      } else {
        fortran_orm_i32_t iv = 0;
        rc = fortran_orm_stmt_col_i32(stmt, (fortran_orm_i32_t)(c + 1), &iv);
        memcpy(elem, &iv, sizeof(fortran_orm_i32_t));
      }
    }
    if (rc == FORTRAN_ORM_OK) {
      r++;
    }
  }

  *out_rows = (fortran_orm_u32_t)r;
  frc = fortran_orm_stmt_finalize(stmt);
  return fortran_orm_keep_err(rc, frc);
}
