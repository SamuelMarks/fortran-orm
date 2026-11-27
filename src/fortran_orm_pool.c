/**
 * @file fortran_orm_pool.c
 * @brief Thread-safe connection pool and horizontal shard router bridges.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
/* clang-format on */

/**
 * @brief Validates a `fortran_orm_pool_t` handle.
 *
 * @param[in] pool Candidate pool handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
check_pool(const fortran_orm_pool_t *pool) {
  if (!pool || pool->magic != FORTRAN_ORM_MAGIC_POOL) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

/**
 * @brief Validates a `fortran_orm_shard_t` handle.
 *
 * @param[in] shard Candidate shard manager handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
check_shard(const fortran_orm_shard_t *shard) {
  if (!shard || shard->magic != FORTRAN_ORM_MAGIC_SHARD) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_init(const char *url, fortran_orm_u32_t url_len,
                      fortran_orm_i32_t min_conns, fortran_orm_i32_t max_conns,
                      fortran_orm_i32_t timeout_ms,
                      fortran_orm_pool_t **out_pool) {
  char *c_url = NULL;
  fortran_orm_pool_t *wrap = NULL;
  c_orm_pool_t *raw_pool = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_pool) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_pool = NULL;
  if (min_conns < 0 || max_conns < 1 || min_conns > max_conns) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  rc = fortran_orm_slice_to_cstr(url, url_len, 1, &c_url);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
  if (crc != C_ORM_OK) {
    frc = fortran_orm_from_c(c_orm_system_free(c_url));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }

  crc = c_orm_pool_init(c_url, (int)min_conns, (int)max_conns, (int)timeout_ms,
                        &raw_pool);
  frc = fortran_orm_from_c(c_orm_system_free(c_url));
  if (crc != C_ORM_OK) {
    fortran_orm_error_t f2 = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_keep_err(frc, f2));
  }

  wrap->magic = FORTRAN_ORM_MAGIC_POOL;
  wrap->pool = raw_pool;
  *out_pool = wrap;
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_acquire(fortran_orm_pool_t *pool, fortran_orm_db_t **out_db) {
  fortran_orm_db_t *db_wrap = NULL;
  c_orm_db_t *raw_db = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t chk = check_pool(pool);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_db) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_db = NULL;

  crc = c_orm_system_calloc(1u, sizeof(*db_wrap), (void **)&db_wrap);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }

  crc = c_orm_pool_acquire(pool->pool, &raw_db);
  if (crc != C_ORM_OK) {
    fortran_orm_error_t frc = fortran_orm_from_c(c_orm_system_free(db_wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }

  db_wrap->magic = FORTRAN_ORM_MAGIC_DB;
  db_wrap->db = raw_db;
  db_wrap->is_pooled = 1;
  db_wrap->owned_tz_name = NULL;
  *out_db = db_wrap;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_release(fortran_orm_pool_t *pool, fortran_orm_db_t *db) {
  c_orm_db_t *raw_db;
  char *tz;
  c_orm_error_t crc;
  fortran_orm_error_t f1 = FORTRAN_ORM_OK;
  fortran_orm_error_t f2;
  fortran_orm_error_t chk = check_pool(pool);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!db->is_pooled) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  raw_db = db->db;
  tz = db->owned_tz_name;
  db->magic = 0u;
  db->db = NULL;
  db->owned_tz_name = NULL;

  if (tz) {
    raw_db->timezone.name = NULL;
    f1 = fortran_orm_from_c(c_orm_system_free(tz));
  }
  crc = c_orm_pool_release(pool->pool, raw_db);
  f2 = fortran_orm_from_c(c_orm_system_free(db));
  return fortran_orm_keep_err(fortran_orm_from_c(crc),
                              fortran_orm_keep_err(f1, f2));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_telemetry(fortran_orm_pool_t *pool,
                           fortran_orm_pool_stats_t *out_stats) {
  c_orm_pool_telemetry_t tel;
  c_orm_error_t crc;
  fortran_orm_error_t chk = check_pool(pool);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_stats) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_pool_get_telemetry(pool->pool, &tel);
  out_stats->active_connections = (fortran_orm_i64_t)tel.active_connections;
  out_stats->idle_connections = (fortran_orm_i64_t)tel.idle_connections;
  out_stats->exhaustion_count = (fortran_orm_i64_t)tel.exhaustion_count;
  out_stats->average_wait_time_ms = tel.average_wait_time_ms;
  out_stats->slow_queries_logged = (fortran_orm_i64_t)tel.slow_queries_logged;
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_destroy(fortran_orm_pool_t *pool) {
  c_orm_pool_t *raw;
  c_orm_error_t crc;
  fortran_orm_error_t frc;
  fortran_orm_error_t chk = check_pool(pool);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  raw = pool->pool;
  pool->magic = 0u;
  pool->pool = NULL;
  crc = c_orm_pool_destroy(raw);
  frc = fortran_orm_from_c(c_orm_system_free(pool));
  return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_init(fortran_orm_u32_t num_shards,
                       fortran_orm_shard_t **out_shard) {
  fortran_orm_shard_t *wrap = NULL;
  c_orm_error_t crc;

  if (!out_shard) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_shard = NULL;
  if (num_shards == 0u) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  crc = c_orm_system_calloc((size_t)num_shards, sizeof(c_orm_db_t *),
                            (void **)&wrap->nodes);
  if (crc != C_ORM_OK) {
    fortran_orm_error_t f1 = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), f1);
  }
  crc = c_orm_shard_manager_init((size_t)num_shards, &wrap->mgr);
  if (crc != C_ORM_OK) {
    fortran_orm_error_t f1 = fortran_orm_from_c(c_orm_system_free(wrap->nodes));
    fortran_orm_error_t f2 = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_keep_err(f1, f2));
  }
  wrap->magic = FORTRAN_ORM_MAGIC_SHARD;
  wrap->num_shards = num_shards;
  *out_shard = wrap;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_add_node(fortran_orm_shard_t *shard,
                           fortran_orm_u32_t shard_idx, fortran_orm_db_t *db) {
  c_orm_error_t crc;
  fortran_orm_error_t chk = check_shard(shard);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (shard_idx < 1u || shard_idx > shard->num_shards) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  crc = c_orm_shard_manager_add_node(shard->mgr, (size_t)(shard_idx - 1u),
                                     db->db);
  shard->nodes[shard_idx - 1u] = db->db;
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_route(fortran_orm_shard_t *shard, const char *routing_key,
                        fortran_orm_u32_t key_len,
                        fortran_orm_u32_t *out_shard_idx) {
  char *c_key = NULL;
  c_orm_db_t *routed = NULL;
  fortran_orm_u32_t i;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = check_shard(shard);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_shard_idx) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_slice_to_cstr(routing_key, key_len, 1, &c_key);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_shard_route_hash(shard->mgr, c_key, &routed);
  frc = fortran_orm_from_c(c_orm_system_free(c_key));
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }
  for (i = 0u; i < shard->num_shards; i++) {
    if (shard->nodes[i] == routed) {
      *out_shard_idx = i + 1u;
      return frc;
    }
  }
  return fortran_orm_keep_err(FORTRAN_ORM_ERROR_NOT_FOUND, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_free(fortran_orm_shard_t *shard) {
  c_orm_shard_manager_t *mgr;
  c_orm_db_t **nodes;
  c_orm_error_t crc;
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;
  fortran_orm_error_t chk = check_shard(shard);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  mgr = shard->mgr;
  nodes = shard->nodes;
  shard->magic = 0u;
  shard->mgr = NULL;
  shard->nodes = NULL;
  crc = c_orm_shard_manager_free(mgr);
  f1 = fortran_orm_from_c(c_orm_system_free(nodes));
  f2 = fortran_orm_from_c(c_orm_system_free(shard));
  return fortran_orm_keep_err(fortran_orm_from_c(crc),
                              fortran_orm_keep_err(f1, f2));
}
