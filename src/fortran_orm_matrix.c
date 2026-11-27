/**
 * @file fortran_orm_matrix.c
 * @brief Scientific 1D contiguous vector and Fortran column-major 2D matrix
 * (`A(ld_rows, n_cols)`) batch persistence and SQL hydration engine.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
/* clang-format on */

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_vec_i32(fortran_orm_db_t *db, const char *insert_sql,
                           fortran_orm_u32_t sql_len,
                           const fortran_orm_i32_t *vec,
                           fortran_orm_u32_t count) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t i;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (count > 0u && !vec) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (count == 0u) {
    return FORTRAN_ORM_OK;
  }

  rc = fortran_orm_stmt_prepare(db, insert_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  for (i = 0u; rc == FORTRAN_ORM_OK && i < count; i++) {
    rc = fortran_orm_stmt_bind_i32(stmt, 1, vec[i]);
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

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_vec_i64(fortran_orm_db_t *db, const char *insert_sql,
                           fortran_orm_u32_t sql_len,
                           const fortran_orm_i64_t *vec,
                           fortran_orm_u32_t count) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t i;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (count > 0u && !vec) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (count == 0u) {
    return FORTRAN_ORM_OK;
  }

  rc = fortran_orm_stmt_prepare(db, insert_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  for (i = 0u; rc == FORTRAN_ORM_OK && i < count; i++) {
    rc = fortran_orm_stmt_bind_i64(stmt, 1, vec[i]);
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

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_vec_f64(fortran_orm_db_t *db, const char *insert_sql,
                           fortran_orm_u32_t sql_len, const double *vec,
                           fortran_orm_u32_t count) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t i;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (count > 0u && !vec) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (count == 0u) {
    return FORTRAN_ORM_OK;
  }

  rc = fortran_orm_stmt_prepare(db, insert_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  for (i = 0u; rc == FORTRAN_ORM_OK && i < count; i++) {
    rc = fortran_orm_stmt_bind_f64(stmt, 1, vec[i]);
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

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_vec_i32(fortran_orm_db_t *db, const char *select_sql,
                          fortran_orm_u32_t sql_len, fortran_orm_i32_t *out_vec,
                          fortran_orm_u32_t cap_elems,
                          fortran_orm_u32_t *out_count) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t n = 0u;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_count || (cap_elems > 0u && !out_vec)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_count = 0u;

  rc = fortran_orm_stmt_prepare(db, select_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  for (;;) {
    rc = fortran_orm_stmt_step(stmt, &has_row);
    if (rc != FORTRAN_ORM_OK || !has_row) {
      break;
    }
    if (n >= cap_elems) {
      rc = FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL;
      break;
    }
    rc = fortran_orm_stmt_col_i32(stmt, 1, &out_vec[n]);
    if (rc != FORTRAN_ORM_OK) {
      break;
    }
    n++;
  }
  *out_count = n;
  frc = fortran_orm_stmt_finalize(stmt);
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_vec_i64(fortran_orm_db_t *db, const char *select_sql,
                          fortran_orm_u32_t sql_len, fortran_orm_i64_t *out_vec,
                          fortran_orm_u32_t cap_elems,
                          fortran_orm_u32_t *out_count) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t n = 0u;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_count || (cap_elems > 0u && !out_vec)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_count = 0u;

  rc = fortran_orm_stmt_prepare(db, select_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  for (;;) {
    rc = fortran_orm_stmt_step(stmt, &has_row);
    if (rc != FORTRAN_ORM_OK || !has_row) {
      break;
    }
    if (n >= cap_elems) {
      rc = FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL;
      break;
    }
    rc = fortran_orm_stmt_col_i64(stmt, 1, &out_vec[n]);
    if (rc != FORTRAN_ORM_OK) {
      break;
    }
    n++;
  }
  *out_count = n;
  frc = fortran_orm_stmt_finalize(stmt);
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_vec_f64(fortran_orm_db_t *db, const char *select_sql,
                          fortran_orm_u32_t sql_len, double *out_vec,
                          fortran_orm_u32_t cap_elems,
                          fortran_orm_u32_t *out_count) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t n = 0u;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_count || (cap_elems > 0u && !out_vec)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_count = 0u;

  rc = fortran_orm_stmt_prepare(db, select_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  for (;;) {
    rc = fortran_orm_stmt_step(stmt, &has_row);
    if (rc != FORTRAN_ORM_OK || !has_row) {
      break;
    }
    if (n >= cap_elems) {
      rc = FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL;
      break;
    }
    rc = fortran_orm_stmt_col_f64(stmt, 1, &out_vec[n]);
    if (rc != FORTRAN_ORM_OK) {
      break;
    }
    n++;
  }
  *out_count = n;
  frc = fortran_orm_stmt_finalize(stmt);
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_matrix_f64(fortran_orm_db_t *db, const char *insert_sql,
                              fortran_orm_u32_t sql_len,
                              const double *matrix_col_major,
                              fortran_orm_u32_t ld_rows,
                              fortran_orm_u32_t n_rows,
                              fortran_orm_u32_t n_cols) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t r;
  fortran_orm_u32_t c;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (n_cols == 0u || ld_rows < n_rows) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  if (n_rows == 0u) {
    return FORTRAN_ORM_OK;
  }
  if (!matrix_col_major) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  rc = fortran_orm_stmt_prepare(db, insert_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  for (r = 0u; rc == FORTRAN_ORM_OK && r < n_rows; r++) {
    for (c = 0u; rc == FORTRAN_ORM_OK && c < n_cols; c++) {
      size_t idx = ((size_t)c * (size_t)ld_rows) + (size_t)r;
      rc = fortran_orm_stmt_bind_f64(stmt, (fortran_orm_i32_t)(c + 1u),
                                     matrix_col_major[idx]);
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

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_matrix_f64(fortran_orm_db_t *db, const char *select_sql,
                             fortran_orm_u32_t sql_len, double *out_matrix,
                             fortran_orm_u32_t ld_rows,
                             fortran_orm_u32_t max_rows,
                             fortran_orm_u32_t n_cols,
                             fortran_orm_u32_t *out_rows) {
  fortran_orm_stmt_t *stmt = NULL;
  fortran_orm_u32_t r = 0u;
  fortran_orm_u32_t c;
  fortran_orm_i32_t has_row = 0;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_rows || (max_rows > 0u && !out_matrix)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (n_cols == 0u || ld_rows < max_rows) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  *out_rows = 0u;

  rc = fortran_orm_stmt_prepare(db, select_sql, sql_len, &stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  for (;;) {
    rc = fortran_orm_stmt_step(stmt, &has_row);
    if (rc != FORTRAN_ORM_OK || !has_row) {
      break;
    }
    if (r >= max_rows) {
      rc = FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL;
      break;
    }
    for (c = 0u; c < n_cols; c++) {
      size_t idx = ((size_t)c * (size_t)ld_rows) + (size_t)r;
      rc = fortran_orm_stmt_col_f64(stmt, (fortran_orm_i32_t)(c + 1u),
                                    &out_matrix[idx]);
      if (rc != FORTRAN_ORM_OK) {
        break;
      }
    }
    if (rc != FORTRAN_ORM_OK) {
      break;
    }
    r++;
  }

  *out_rows = r;
  frc = fortran_orm_stmt_finalize(stmt);
  return fortran_orm_keep_err(rc, frc);
}
