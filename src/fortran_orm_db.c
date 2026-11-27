/**
 * @file fortran_orm_db.c
 * @brief Database connection lifecycle, raw SQL execution, diagnostics,
 * prepared-statement LRU cache configuration, timezones, and telemetry.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#include <string.h>
/* clang-format on */

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_connect_cstr(const char *url_cstr, fortran_orm_db_t **out_db) {
  fortran_orm_db_t *wrap = NULL;
  c_orm_db_t *raw_db = NULL;
  c_orm_error_t crc;

  if (!url_cstr || !out_db) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_db = NULL;

  crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }

  crc = c_orm_connect_url(url_cstr, &raw_db);
  if (crc != C_ORM_OK) {
    fortran_orm_error_t frc = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }

  wrap->magic = FORTRAN_ORM_MAGIC_DB;
  wrap->db = raw_db;
  wrap->is_pooled = 0;
  wrap->owned_tz_name = NULL;
  *out_db = wrap;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_connect(const char *url, fortran_orm_u32_t url_len,
                    fortran_orm_db_t **out_db) {
  char *c_url = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_db) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_db = NULL;

  rc = fortran_orm_slice_to_cstr(url, url_len, 1, &c_url);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_connect_cstr(c_url, out_db);
  frc = fortran_orm_from_c(c_orm_system_free(c_url));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_disconnect(fortran_orm_db_t *db) {
  c_orm_db_t *raw;
  char *tz;
  int pooled;
  c_orm_error_t drc = C_ORM_OK;
  fortran_orm_error_t frc1 = FORTRAN_ORM_OK;
  fortran_orm_error_t frc2;
  fortran_orm_error_t chk = fortran_orm_check_db(db);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }

  raw = db->db;
  tz = db->owned_tz_name;
  pooled = db->is_pooled;
  db->magic = 0u;
  db->db = NULL;
  db->owned_tz_name = NULL;

  if (tz) {
    raw->timezone.name = NULL;
    frc1 = fortran_orm_from_c(c_orm_system_free(tz));
  }
  if (!pooled) {
    drc = raw->vtable->disconnect(raw);
  }
  frc2 = fortran_orm_from_c(c_orm_system_free(db));
  return fortran_orm_keep_err(fortran_orm_from_c(drc),
                              fortran_orm_keep_err(frc1, frc2));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_exec_cstr(fortran_orm_db_t *db, const char *sql_cstr) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!sql_cstr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  return fortran_orm_from_c(c_orm_execute_raw(db->db, sql_cstr));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_exec_sql(fortran_orm_db_t *db, const char *sql,
                     fortran_orm_u32_t sql_len) {
  char *c_sql = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_slice_to_cstr(sql, sql_len, 1, &c_sql);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_exec_cstr(db, c_sql);
  frc = fortran_orm_from_c(c_orm_system_free(c_sql));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_last_error(fortran_orm_db_t *db, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len) {
  const char *msg = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_db(db);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  crc = c_orm_get_last_error_message(db->db, &msg);
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_cstr_to_fbuf(msg, out_buf, buf_cap, out_len));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_last_trace(fortran_orm_db_t *db, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len) {
  const char *tr = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_db(db);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  crc = c_orm_get_last_error_trace(db->db, &tr);
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_cstr_to_fbuf(tr, out_buf, buf_cap, out_len));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_last_insert_rowid(fortran_orm_db_t *db,
                              fortran_orm_i64_t *out_rowid) {
  int64_t rid = 0;
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_db(db);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_rowid) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = db->db->vtable->get_last_insert_rowid(db->db, &rid);
  *out_rowid = (fortran_orm_i64_t)rid;
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_enable_stmt_cache(fortran_orm_db_t *db,
                              fortran_orm_u32_t capacity) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (capacity == 0u) {
    return fortran_orm_from_c(c_orm_disable_statement_caching(db->db));
  }
  return fortran_orm_from_c(
      c_orm_enable_statement_caching(db->db, (size_t)capacity));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_set_timezone(fortran_orm_db_t *db, fortran_orm_i32_t offset_minutes,
                         const char *tz_name, fortran_orm_u32_t tz_len) {
  char *new_tz = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc = FORTRAN_ORM_OK;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (tz_len > 0u) {
    rc = fortran_orm_slice_to_cstr(tz_name, tz_len, 1, &new_tz);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
  }
  if (db->owned_tz_name) {
    frc = fortran_orm_from_c(c_orm_system_free(db->owned_tz_name));
  }
  db->owned_tz_name = new_tz;
  db->db->timezone.offset_minutes = (int)offset_minutes;
  db->db->timezone.name = new_tz;
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_set_slow_query_ms(fortran_orm_db_t *db,
                              fortran_orm_u32_t threshold_ms) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(
      c_orm_set_slow_query_threshold(db->db, (uint32_t)threshold_ms));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_db_telemetry(fortran_orm_db_t *db,
                         fortran_orm_pool_stats_t *out_stats) {
  c_orm_pool_telemetry_t tel;
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_db(db);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_stats) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  memset(&tel, 0, sizeof(tel));
  crc = c_orm_get_telemetry(db->db, &tel);
  out_stats->active_connections = (fortran_orm_i64_t)tel.active_connections;
  out_stats->idle_connections = (fortran_orm_i64_t)tel.idle_connections;
  out_stats->exhaustion_count = (fortran_orm_i64_t)tel.exhaustion_count;
  out_stats->average_wait_time_ms = tel.average_wait_time_ms;
  out_stats->slow_queries_logged = (fortran_orm_i64_t)tel.slow_queries_logged;
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_escape_string(fortran_orm_db_t *db, const char *src,
                          fortran_orm_u32_t src_len, char *out_buf,
                          fortran_orm_u32_t buf_cap,
                          fortran_orm_u32_t *out_len) {
  char *c_in = NULL;
  char *c_esc = NULL;
  size_t esc_cap;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_len || (buf_cap > 0u && !out_buf)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_slice_to_cstr(src, src_len, 1, &c_in);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  esc_cap = (strlen(c_in) * 2u) + 4u;
  crc = c_orm_system_malloc(esc_cap, (void **)&c_esc);
  if (crc != C_ORM_OK) {
    f1 = fortran_orm_from_c(c_orm_system_free(c_in));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), f1);
  }
  c_esc[0] = '\0';
  crc = c_orm_escape_string(db->db, c_in, c_esc, esc_cap);
  rc = fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_cstr_to_fbuf(c_esc, out_buf, buf_cap, out_len));
  f1 = fortran_orm_from_c(c_orm_system_free(c_esc));
  f2 = fortran_orm_from_c(c_orm_system_free(c_in));
  return fortran_orm_keep_err(rc, fortran_orm_keep_err(f1, f2));
}
