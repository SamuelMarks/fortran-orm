/**
 * @file fortran_orm_stmt.c
 * @brief Prepared and LRU-cached statements with 1-based Fortran parameter
 * bindings and 1-based typed result column readers.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#include <string.h>
/* clang-format on */

/**
 * @brief Internal statement preparation shared by uncached and cached modes.
 *
 * @param[in] db Active DB handle.
 * @param[in] sql SQL text slice.
 * @param[in] sql_len Byte length of `sql`.
 * @param[in] use_cache Non-zero to use `c_orm_prepare_cached`.
 * @param[out] out_stmt Receives initialized statement handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t stmt_prepare_impl(
    fortran_orm_db_t *db, const char *sql, fortran_orm_u32_t sql_len,
    int use_cache, fortran_orm_stmt_t **out_stmt) {
  char *c_sql = NULL;
  fortran_orm_stmt_t *wrap = NULL;
  c_orm_query_t *q = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_stmt) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_stmt = NULL;

  rc = fortran_orm_slice_to_cstr(sql, sql_len, 1, &c_sql);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
  if (crc != C_ORM_OK) {
    frc = fortran_orm_from_c(c_orm_system_free(c_sql));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }

  if (use_cache) {
    crc = c_orm_prepare_cached(db->db, c_sql, &q);
  } else {
    crc = db->db->vtable->prepare(db->db, c_sql, &q);
  }
  frc = fortran_orm_from_c(c_orm_system_free(c_sql));
  if (crc != C_ORM_OK) {
    fortran_orm_error_t f2 = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_keep_err(frc, f2));
  }

  wrap->magic = FORTRAN_ORM_MAGIC_STMT;
  wrap->db = db->db;
  wrap->query = q;
  wrap->is_cached = use_cache;
  *out_stmt = wrap;
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_prepare(fortran_orm_db_t *db, const char *sql,
                         fortran_orm_u32_t sql_len,
                         fortran_orm_stmt_t **out_stmt) {
  return stmt_prepare_impl(db, sql, sql_len, 0, out_stmt);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_prepare_cached(fortran_orm_db_t *db, const char *sql,
                                fortran_orm_u32_t sql_len,
                                fortran_orm_stmt_t **out_stmt) {
  return stmt_prepare_impl(db, sql, sql_len, 1, out_stmt);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_i32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          fortran_orm_i32_t val) {
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (param_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  return fortran_orm_from_c(
      stmt->db->vtable->bind_int32(stmt->query, (int)param_idx, (int32_t)val));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_i64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          fortran_orm_i64_t val) {
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (param_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  return fortran_orm_from_c(
      stmt->db->vtable->bind_int64(stmt->query, (int)param_idx, (int64_t)val));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_f32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          float val) {
  return fortran_orm_stmt_bind_f64(stmt, param_idx, (double)val);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_f64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          double val) {
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (param_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  return fortran_orm_from_c(
      stmt->db->vtable->bind_double(stmt->query, (int)param_idx, val));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_logical(fortran_orm_stmt_t *stmt,
                              fortran_orm_i32_t param_idx,
                              fortran_orm_i32_t flag) {
  return fortran_orm_stmt_bind_i32(stmt, param_idx, flag ? 1 : 0);
}

/**
 * @brief Shared string bind implementation with configurable trailing trim.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter index.
 * @param[in] val Character buffer.
 * @param[in] val_len Byte length of `val`.
 * @param[in] trim_right Non-zero to strip trailing ASCII spaces.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
stmt_bind_str_impl(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                   const char *val, fortran_orm_u32_t val_len, int trim_right) {
  char *c_str = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_stmt(stmt);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (param_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  rc = fortran_orm_slice_to_cstr(val, val_len, trim_right, &c_str);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_from_c(
      stmt->db->vtable->bind_string(stmt->query, (int)param_idx, c_str));
  frc = fortran_orm_from_c(c_orm_system_free(c_str));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_str(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          const char *val, fortran_orm_u32_t val_len) {
  return stmt_bind_str_impl(stmt, param_idx, val, val_len, 1);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_str_raw(fortran_orm_stmt_t *stmt,
                              fortran_orm_i32_t param_idx, const char *val,
                              fortran_orm_u32_t val_len) {
  return stmt_bind_str_impl(stmt, param_idx, val, val_len, 0);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_blob(fortran_orm_stmt_t *stmt,
                           fortran_orm_i32_t param_idx,
                           const fortran_orm_u8_t *data,
                           fortran_orm_u32_t data_len) {
  static const fortran_orm_u8_t k_empty = 0u;
  const void *ptr;
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (param_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  if (data_len > 0u && !data) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  ptr = (data_len > 0u) ? (const void *)data : (const void *)&k_empty;
  return fortran_orm_from_c(stmt->db->vtable->bind_blob(
      stmt->query, (int)param_idx, ptr, (size_t)data_len));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_decimal(fortran_orm_stmt_t *stmt,
                              fortran_orm_i32_t param_idx,
                              const fortran_orm_decimal_t *dec) {
  c_orm_decimal_t c_dec;
  fortran_orm_error_t rc = fortran_orm_check_stmt(stmt);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (param_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  rc = fortran_orm_dec_to_c(dec, &c_dec);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  return fortran_orm_from_c(
      stmt->db->vtable->bind_decimal(stmt->query, (int)param_idx, &c_dec));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_null(fortran_orm_stmt_t *stmt,
                           fortran_orm_i32_t param_idx) {
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (param_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  return fortran_orm_from_c(
      stmt->db->vtable->bind_null(stmt->query, (int)param_idx));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_step(fortran_orm_stmt_t *stmt,
                      fortran_orm_i32_t *out_has_row) {
  int has_row = 0;
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_has_row) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->step(stmt->query, &has_row);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_has_row = (fortran_orm_i32_t)has_row;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_reset(fortran_orm_stmt_t *stmt) {
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(stmt->db->vtable->reset(stmt->query));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_finalize(fortran_orm_stmt_t *stmt) {
  c_orm_db_t *db;
  c_orm_query_t *q;
  int cached;
  c_orm_error_t crc;
  fortran_orm_error_t frc;
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  db = stmt->db;
  q = stmt->query;
  cached = stmt->is_cached;
  stmt->magic = 0u;
  stmt->db = NULL;
  stmt->query = NULL;

  if (cached) {
    crc = c_orm_finalize_cached(db, q);
  } else {
    crc = db->vtable->finalize(q);
  }
  frc = fortran_orm_from_c(c_orm_system_free(stmt));
  return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
}

/**
 * @brief Validates `stmt` and converts a 1-based Fortran column index into a
 * bounds-checked 0-based `c-orm` column index.
 *
 * @param[in] stmt Candidate statement handle.
 * @param[in] col_idx 1-based Fortran column index.
 * @param[out] out_zero_idx Receives 0-based driver column index.
 * @return `FORTRAN_ORM_OK`, `FORTRAN_ORM_ERROR_INVALID_HANDLE`, or
 * `FORTRAN_ORM_ERROR_INVALID_INDEX`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
stmt_resolve_col(const fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                 int *out_zero_idx) {
  int ncols = 0;
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (col_idx < 1) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  crc = stmt->db->vtable->get_column_count(stmt->query, &ncols);
  if ((int)col_idx > ncols) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                FORTRAN_ORM_ERROR_INVALID_INDEX);
  }
  *out_zero_idx = (int)col_idx - 1;
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_count(fortran_orm_stmt_t *stmt,
                           fortran_orm_i32_t *out_count) {
  int ncols = 0;
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_stmt(stmt);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_count) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->get_column_count(stmt->query, &ncols);
  *out_count = (fortran_orm_i32_t)ncols;
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_name(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                          char *out_buf, fortran_orm_u32_t buf_cap,
                          fortran_orm_u32_t *out_len) {
  int zidx = 0;
  const char *cname = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = stmt->db->vtable->get_column_name(stmt->query, zidx, &cname);
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_cstr_to_fbuf(cname, out_buf, buf_cap, out_len));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_is_null(fortran_orm_stmt_t *stmt,
                             fortran_orm_i32_t col_idx,
                             fortran_orm_i32_t *out_is_null) {
  int zidx = 0;
  int nul = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_is_null) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->is_null(stmt->query, zidx, &nul);
  *out_is_null = (fortran_orm_i32_t)(nul ? 1 : 0);
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_i32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         fortran_orm_i32_t *out_val) {
  int zidx = 0;
  int32_t v = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_val) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->get_int32(stmt->query, zidx, &v);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_val = (fortran_orm_i32_t)v;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_i64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         fortran_orm_i64_t *out_val) {
  int zidx = 0;
  int64_t v = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_val) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->get_int64(stmt->query, zidx, &v);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_val = (fortran_orm_i64_t)v;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_f32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         float *out_val) {
  double dv = 0.0;
  fortran_orm_error_t rc;

  if (!out_val) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_stmt_col_f64(stmt, col_idx, &dv);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  *out_val = (float)dv;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_f64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         double *out_val) {
  int zidx = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_val) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->get_double(stmt->query, zidx, out_val);
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_logical(fortran_orm_stmt_t *stmt,
                             fortran_orm_i32_t col_idx,
                             fortran_orm_i32_t *out_flag) {
  fortran_orm_i32_t iv = 0;
  fortran_orm_error_t rc;

  if (!out_flag) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_stmt_col_i32(stmt, col_idx, &iv);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  *out_flag = iv ? 1 : 0;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_str(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         char *out_buf, fortran_orm_u32_t buf_cap,
                         fortran_orm_u32_t *out_len) {
  int zidx = 0;
  const char *sval = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = stmt->db->vtable->get_string(stmt->query, zidx, &sval);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return fortran_orm_cstr_to_fbuf(sval, out_buf, buf_cap, out_len);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_blob(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                          fortran_orm_u8_t *out_buf, fortran_orm_u32_t buf_cap,
                          fortran_orm_u32_t *out_len) {
  int zidx = 0;
  const void *bptr = NULL;
  size_t bsz = 0u;
  size_t ncopy;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_len || (buf_cap > 0u && !out_buf)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->get_blob(stmt->query, zidx, &bptr, &bsz);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_len = (fortran_orm_u32_t)bsz;
  ncopy = (bsz < (size_t)buf_cap) ? bsz : (size_t)buf_cap;
  if (ncopy > 0u) {
    memcpy(out_buf, bptr, ncopy);
  }
  if (bsz > (size_t)buf_cap) {
    return FORTRAN_ORM_ERROR_TRUNCATION;
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_decimal(fortran_orm_stmt_t *stmt,
                             fortran_orm_i32_t col_idx,
                             fortran_orm_decimal_t *out_dec) {
  int zidx = 0;
  c_orm_decimal_t c_dec;
  c_orm_error_t crc;
  fortran_orm_error_t rc = stmt_resolve_col(stmt, col_idx, &zidx);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_dec) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->vtable->get_decimal(stmt->query, zidx, &c_dec);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return fortran_orm_dec_from_c(&c_dec, out_dec);
}
