/**
 * @file fortran_orm_ffi.h
 * @brief Complete strongly-typed ISO C89 FFI umbrella header for fortran-orm,
 * consumed by `../cdd-c` (`cdd-c bind -l fortran`) to generate ISO_C_BINDING
 * bindings and paired with legacy FORTRAN I–95 & Fortran 2018 CFI bridges.
 */

#ifndef FORTRAN_ORM_FFI_H
/** @brief Header guard for fortran_orm_ffi.h. */
#define FORTRAN_ORM_FFI_H

/* clang-format off */
#include "fortran_orm_types.h"
/* clang-format on */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/* ==========================================================================
 * 1. Library Version & String / Hollerith Marshaling Utilities
 * ========================================================================== */

/**
 * @brief Writes the library semantic version into a blank-padded Fortran
 * buffer.
 *
 * @param[out] out_buf Destination character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed length of the version string.
 * @return `FORTRAN_ORM_OK` on success, or error code on NULL/truncation.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_version(char *out_buf, fortran_orm_u32_t buf_cap,
                    fortran_orm_u32_t *out_len);

/**
 * @brief Converts an unpacked `A1` `INTEGER*4` character-code array (`1` ASCII
 * codepoint per integer element) into a blank-padded character buffer.
 *
 * @param[in] a1_codes Input array of `count` 32-bit ASCII character codes.
 * @param[in] count Number of elements in `a1_codes`.
 * @param[out] out_buf Destination character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed string length.
 * @return `FORTRAN_ORM_OK` on success, or error code on NULL/truncation.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_a1_to_str(const fortran_orm_i32_t *a1_codes,
                      fortran_orm_u32_t count, char *out_buf,
                      fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Encodes a character buffer of length `str_len` into an unpacked `A1`
 * `INTEGER*4` array (`1` ASCII codepoint per element, space-padded to `cap`).
 *
 * @param[in] str Source character buffer.
 * @param[in] str_len Length of `str` in bytes.
 * @param[out] out_a1 Destination `INTEGER*4` array of capacity `cap`.
 * @param[in] cap Number of `INTEGER*4` slots in `out_a1`.
 * @param[out] out_len Receives trimmed character length.
 * @return `FORTRAN_ORM_OK` on success, or error code on NULL/truncation.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_str_to_a1(const char *str, fortran_orm_u32_t str_len,
                      fortran_orm_i32_t *out_a1, fortran_orm_u32_t cap,
                      fortran_orm_u32_t *out_len);

/* ==========================================================================
 * 2. Database Connections, Session Control & Telemetry
 * ========================================================================== */

/**
 * @brief Connects to any supported `c-orm` backend (`sqlite://`, `memory://`,
 * `postgres://`, `mysql://`, `db2://`, `odbc://`) from a Fortran string slice.
 *
 * @param[in] url Connection URL buffer (trailing spaces are trimmed).
 * @param[in] url_len Byte length of `url`.
 * @param[out] out_db Receives allocated database handle.
 * @return `FORTRAN_ORM_OK` on success, or driver/memory error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_connect(const char *url, fortran_orm_u32_t url_len,
                    fortran_orm_db_t **out_db);

/**
 * @brief Connects to any supported `c-orm` backend from a NUL-terminated C
 * string (`CHARACTER(KIND=C_CHAR)`).
 *
 * @param[in] url_cstr NUL-terminated connection URL.
 * @param[out] out_db Receives allocated database handle.
 * @return `FORTRAN_ORM_OK` on success, or driver/memory error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_connect_cstr(const char *url_cstr, fortran_orm_db_t **out_db);

/**
 * @brief Closes and frees a database connection handle.
 *
 * @param[in,out] db Database handle to close.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_disconnect(fortran_orm_db_t *db);

/**
 * @brief Executes a non-query DDL or DML SQL statement string slice.
 *
 * @param[in] db Active database handle.
 * @param[in] sql SQL text buffer (trailing spaces trimmed).
 * @param[in] sql_len Byte length of `sql`.
 * @return `FORTRAN_ORM_OK` on success, or SQL error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_exec_sql(fortran_orm_db_t *db, const char *sql,
                     fortran_orm_u32_t sql_len);

/**
 * @brief Executes a NUL-terminated DDL or DML SQL C string.
 *
 * @param[in] db Active database handle.
 * @param[in] sql_cstr NUL-terminated SQL text.
 * @return `FORTRAN_ORM_OK` on success, or SQL error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_exec_cstr(fortran_orm_db_t *db, const char *sql_cstr);

/**
 * @brief Copies the last driver error message into a blank-padded buffer.
 *
 * @param[in] db Active database handle.
 * @param[out] out_buf Destination character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed message length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_last_error(fortran_orm_db_t *db, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Copies the last contextual diagnostic trace into a blank-padded
 * buffer.
 *
 * @param[in] db Active database handle.
 * @param[out] out_buf Destination character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed trace length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_last_trace(fortran_orm_db_t *db, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Retrieves the 64-bit row ID generated by the most recent `INSERT`.
 *
 * @param[in] db Active database handle.
 * @param[out] out_rowid Receives 64-bit row ID.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_last_insert_rowid(fortran_orm_db_t *db,
                              fortran_orm_i64_t *out_rowid);

/**
 * @brief Enables or disables the per-connection prepared-statement LRU cache.
 *
 * @param[in] db Active database handle.
 * @param[in] capacity Maximum cached statements (`0` disables caching).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_enable_stmt_cache(fortran_orm_db_t *db, fortran_orm_u32_t capacity);

/**
 * @brief Configures the session UTC offset and optional IANA timezone name.
 *
 * @param[in] db Active database handle.
 * @param[in] offset_minutes Offset from UTC in minutes.
 * @param[in] tz_name Optional timezone name buffer (may be empty).
 * @param[in] tz_len Byte length of `tz_name`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_set_timezone(fortran_orm_db_t *db, fortran_orm_i32_t offset_minutes,
                         const char *tz_name, fortran_orm_u32_t tz_len);

/**
 * @brief Sets the slow-query threshold in milliseconds (`0` disables logging).
 *
 * @param[in] db Active database handle.
 * @param[in] threshold_ms Slow-query threshold in milliseconds.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_set_slow_query_ms(fortran_orm_db_t *db,
                              fortran_orm_u32_t threshold_ms);

/**
 * @brief Retrieves telemetry counters from a single database connection.
 *
 * @param[in] db Active database handle.
 * @param[out] out_stats Receives connection telemetry snapshot.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_db_telemetry(fortran_orm_db_t *db,
                         fortran_orm_pool_stats_t *out_stats);

/**
 * @brief Escapes a string literal against SQL injection using driver rules.
 *
 * @param[in] db Active database handle.
 * @param[in] src Source string buffer (trailing spaces trimmed).
 * @param[in] src_len Byte length of `src`.
 * @param[out] out_buf Destination blank-padded character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives escaped string length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_escape_string(fortran_orm_db_t *db, const char *src,
                          fortran_orm_u32_t src_len, char *out_buf,
                          fortran_orm_u32_t buf_cap,
                          fortran_orm_u32_t *out_len);

/* ==========================================================================
 * 3. Connection Pooling & Horizontal Sharding
 * ========================================================================== */

/**
 * @brief Initializes a bounded thread-safe database connection pool.
 *
 * @param[in] url Connection URL buffer.
 * @param[in] url_len Byte length of `url`.
 * @param[in] min_conns Pre-warmed minimum connections (`>= 0`).
 * @param[in] max_conns Maximum concurrent connections (`>= 1`).
 * @param[in] timeout_ms Acquisition wait timeout in milliseconds.
 * @param[out] out_pool Receives initialized pool handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_init(const char *url, fortran_orm_u32_t url_len,
                      fortran_orm_i32_t min_conns, fortran_orm_i32_t max_conns,
                      fortran_orm_i32_t timeout_ms,
                      fortran_orm_pool_t **out_pool);

/**
 * @brief Leases an active database connection from `pool`.
 *
 * @param[in] pool Connection pool handle.
 * @param[out] out_db Receives leased database handle (release with
 * `fortran_orm_pool_release`).
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_TIMEOUT`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_acquire(fortran_orm_pool_t *pool, fortran_orm_db_t **out_db);

/**
 * @brief Returns a leased connection back to `pool` and invalidates `db`
 * wrapper.
 *
 * @param[in] pool Connection pool handle.
 * @param[in,out] db Leased database handle wrapper to release.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_release(fortran_orm_pool_t *pool, fortran_orm_db_t *db);

/**
 * @brief Snapshots live telemetry metrics from `pool`.
 *
 * @param[in] pool Connection pool handle.
 * @param[out] out_stats Receives telemetry counters.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_telemetry(fortran_orm_pool_t *pool,
                           fortran_orm_pool_stats_t *out_stats);

/**
 * @brief Destroys `pool` and closes all idle connections.
 *
 * @param[in,out] pool Connection pool handle to destroy.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_pool_destroy(fortran_orm_pool_t *pool);

/**
 * @brief Initializes a horizontal shard router for `num_shards` nodes.
 *
 * @param[in] num_shards Number of shard slots (`>= 1`).
 * @param[out] out_shard Receives initialized shard manager handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_init(fortran_orm_u32_t num_shards,
                       fortran_orm_shard_t **out_shard);

/**
 * @brief Binds `db` to 1-based shard slot `shard_idx` (`1..num_shards`).
 *
 * @param[in] shard Shard manager handle.
 * @param[in] shard_idx 1-based shard index (`1..num_shards`).
 * @param[in] db Connected database handle for this shard.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_add_node(fortran_orm_shard_t *shard,
                           fortran_orm_u32_t shard_idx, fortran_orm_db_t *db);

/**
 * @brief Routes `routing_key` via deterministic hash to a 1-based shard index.
 *
 * @param[in] shard Shard manager handle.
 * @param[in] routing_key Routing key buffer (trailing spaces trimmed).
 * @param[in] key_len Byte length of `routing_key`.
 * @param[out] out_shard_idx Receives 1-based selected shard index.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_route(fortran_orm_shard_t *shard, const char *routing_key,
                        fortran_orm_u32_t key_len,
                        fortran_orm_u32_t *out_shard_idx);

/**
 * @brief Frees a shard manager handle (does not close attached `db` nodes).
 *
 * @param[in,out] shard Shard manager handle to free.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_shard_free(fortran_orm_shard_t *shard);

/* ==========================================================================
 * 4. Transactions & Nested Savepoints
 * ========================================================================== */

/**
 * @brief Begins an explicit database transaction on `db`.
 *
 * @param[in] db Active database handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_begin(fortran_orm_db_t *db);

/**
 * @brief Commits the active database transaction on `db`.
 *
 * @param[in] db Active database handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_commit(fortran_orm_db_t *db);

/**
 * @brief Rolls back the active database transaction on `db`.
 *
 * @param[in] db Active database handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_rollback(fortran_orm_db_t *db);

/**
 * @brief Creates a named transaction savepoint.
 *
 * @param[in] db Active database handle.
 * @param[in] name Savepoint identifier buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `name`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_savepoint(fortran_orm_db_t *db, const char *name,
                         fortran_orm_u32_t name_len);

/**
 * @brief Releases a named transaction savepoint.
 *
 * @param[in] db Active database handle.
 * @param[in] name Savepoint identifier buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `name`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_release_sp(fortran_orm_db_t *db, const char *name,
                          fortran_orm_u32_t name_len);

/**
 * @brief Rolls back to a named transaction savepoint.
 *
 * @param[in] db Active database handle.
 * @param[in] name Savepoint identifier buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `name`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_rollback_sp(fortran_orm_db_t *db, const char *name,
                           fortran_orm_u32_t name_len);

/* ==========================================================================
 * 5. Prepared Statements, 1-Based Binds & 1-Based Column Readers
 * ========================================================================== */

/**
 * @brief Prepares a parameterized SQL statement (`?` or `$1..$N`).
 *
 * @param[in] db Active database handle.
 * @param[in] sql SQL statement buffer (trailing spaces trimmed).
 * @param[in] sql_len Byte length of `sql`.
 * @param[out] out_stmt Receives prepared statement handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_prepare(fortran_orm_db_t *db, const char *sql,
                         fortran_orm_u32_t sql_len,
                         fortran_orm_stmt_t **out_stmt);

/**
 * @brief Prepares or recycles a statement from `db`'s LRU statement cache.
 *
 * @param[in] db Active database handle.
 * @param[in] sql SQL statement buffer (trailing spaces trimmed).
 * @param[in] sql_len Byte length of `sql`.
 * @param[out] out_stmt Receives cached statement handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_prepare_cached(fortran_orm_db_t *db, const char *sql,
                                fortran_orm_u32_t sql_len,
                                fortran_orm_stmt_t **out_stmt);

/**
 * @brief Binds a 32-bit signed integer to 1-based parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] val 32-bit integer value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_i32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          fortran_orm_i32_t val);

/**
 * @brief Binds a 64-bit signed integer to 1-based parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] val 64-bit integer value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_i64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          fortran_orm_i64_t val);

/**
 * @brief Binds a 32-bit IEEE float (`REAL*4`) to 1-based parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] val 32-bit floating-point value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_f32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          float val);

/**
 * @brief Binds a 64-bit IEEE double (`REAL*8` / `DOUBLE PRECISION`) to 1-based
 * parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] val 64-bit floating-point value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_f64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          double val);

/**
 * @brief Binds a boolean/logical flag (`0` false, non-zero true) to 1-based
 * parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] flag Logical value (`0` or non-zero).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_logical(fortran_orm_stmt_t *stmt,
                              fortran_orm_i32_t param_idx,
                              fortran_orm_i32_t flag);

/**
 * @brief Binds a blank-trimmed Fortran string slice to 1-based parameter
 * `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] val Source character buffer (trailing ASCII spaces trimmed).
 * @param[in] val_len Byte length of `val`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_str(fortran_orm_stmt_t *stmt, fortran_orm_i32_t param_idx,
                          const char *val, fortran_orm_u32_t val_len);

/**
 * @brief Binds an untrimmed fixed-length string slice (preserving trailing
 * spaces) to 1-based parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] val Source character buffer.
 * @param[in] val_len Exact byte length to preserve.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_str_raw(fortran_orm_stmt_t *stmt,
                              fortran_orm_i32_t param_idx, const char *val,
                              fortran_orm_u32_t val_len);

/**
 * @brief Binds raw binary bytes (`BLOB`) to 1-based parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] data Binary byte buffer.
 * @param[in] data_len Byte count to bind.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_blob(fortran_orm_stmt_t *stmt,
                           fortran_orm_i32_t param_idx,
                           const fortran_orm_u8_t *data,
                           fortran_orm_u32_t data_len);

/**
 * @brief Binds an exact 38-digit decimal value to 1-based parameter
 * `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @param[in] dec Exact decimal structure.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_decimal(fortran_orm_stmt_t *stmt,
                              fortran_orm_i32_t param_idx,
                              const fortran_orm_decimal_t *dec);

/**
 * @brief Binds SQL `NULL` to 1-based parameter `param_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] param_idx 1-based parameter position (`>= 1`).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_bind_null(fortran_orm_stmt_t *stmt,
                           fortran_orm_i32_t param_idx);

/**
 * @brief Advances execution of `stmt` by one row.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[out] out_has_row Receives `1` if a row is available, `0` if complete.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_step(fortran_orm_stmt_t *stmt, fortran_orm_i32_t *out_has_row);

/**
 * @brief Resets `stmt` for re-execution with new parameter bindings.
 *
 * @param[in] stmt Prepared statement handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_reset(fortran_orm_stmt_t *stmt);

/**
 * @brief Finalizes (or returns to LRU cache) and frees `stmt`.
 *
 * @param[in,out] stmt Prepared statement handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_finalize(fortran_orm_stmt_t *stmt);

/**
 * @brief Queries the number of result columns on `stmt`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[out] out_count Receives result column count.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_count(fortran_orm_stmt_t *stmt,
                           fortran_orm_i32_t *out_count);

/**
 * @brief Copies the 1-based result column name (`1..col_count`) into `out_buf`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_buf Destination blank-padded character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed column name length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_name(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                          char *out_buf, fortran_orm_u32_t buf_cap,
                          fortran_orm_u32_t *out_len);

/**
 * @brief Checks whether 1-based result column `col_idx` is SQL `NULL`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_is_null Receives `1` if `NULL`, `0` otherwise.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_is_null(fortran_orm_stmt_t *stmt,
                             fortran_orm_i32_t col_idx,
                             fortran_orm_i32_t *out_is_null);

/**
 * @brief Reads a 32-bit signed integer from 1-based result column `col_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_val Receives 32-bit integer value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_i32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         fortran_orm_i32_t *out_val);

/**
 * @brief Reads a 64-bit signed integer from 1-based result column `col_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_val Receives 64-bit integer value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_i64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         fortran_orm_i64_t *out_val);

/**
 * @brief Reads a 32-bit IEEE float (`REAL*4`) from 1-based column `col_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_val Receives 32-bit float value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_f32(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         float *out_val);

/**
 * @brief Reads a 64-bit IEEE double (`REAL*8`) from 1-based column `col_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_val Receives 64-bit double value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_f64(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         double *out_val);

/**
 * @brief Reads a logical flag (`0` / `1`) from 1-based column `col_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_flag Receives `0` for zero, `1` for non-zero.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_logical(fortran_orm_stmt_t *stmt,
                             fortran_orm_i32_t col_idx,
                             fortran_orm_i32_t *out_flag);

/**
 * @brief Reads a text string from 1-based column `col_idx` into blank-padded
 * `out_buf`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_buf Destination blank-padded character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives actual string byte length.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_TRUNCATION`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_str(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                         char *out_buf, fortran_orm_u32_t buf_cap,
                         fortran_orm_u32_t *out_len);

/**
 * @brief Reads raw binary `BLOB` bytes from 1-based column `col_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_buf Destination byte buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives actual blob byte length.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_TRUNCATION`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_blob(fortran_orm_stmt_t *stmt, fortran_orm_i32_t col_idx,
                          fortran_orm_u8_t *out_buf, fortran_orm_u32_t buf_cap,
                          fortran_orm_u32_t *out_len);

/**
 * @brief Reads an exact 38-digit decimal value from 1-based column `col_idx`.
 *
 * @param[in] stmt Prepared statement handle.
 * @param[in] col_idx 1-based column index (`>= 1`).
 * @param[out] out_dec Receives exact decimal value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_stmt_col_decimal(fortran_orm_stmt_t *stmt,
                             fortran_orm_i32_t col_idx,
                             fortran_orm_decimal_t *out_dec);

/* ==========================================================================
 * 6. Scientific Columnar Vectors & Column-Major 2D Matrix Batch Engine
 * ========================================================================== */

/**
 * @brief Batch-inserts a contiguous 1D `INTEGER*4` vector using a single-param
 * `INSERT` statement (`?`) inside a savepoint/transaction.
 *
 * @param[in] db Active database handle.
 * @param[in] insert_sql Parameterized SQL (e.g. `INSERT INTO v VALUES (?)`).
 * @param[in] sql_len Byte length of `insert_sql`.
 * @param[in] vec Contiguous 32-bit integer array.
 * @param[in] count Number of elements in `vec`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_vec_i32(fortran_orm_db_t *db, const char *insert_sql,
                           fortran_orm_u32_t sql_len,
                           const fortran_orm_i32_t *vec,
                           fortran_orm_u32_t count);

/**
 * @brief Batch-inserts a contiguous 1D `INTEGER*8` vector.
 *
 * @param[in] db Active database handle.
 * @param[in] insert_sql Parameterized SQL (`INSERT INTO v VALUES (?)`).
 * @param[in] sql_len Byte length of `insert_sql`.
 * @param[in] vec Contiguous 64-bit integer array.
 * @param[in] count Number of elements in `vec`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_vec_i64(fortran_orm_db_t *db, const char *insert_sql,
                           fortran_orm_u32_t sql_len,
                           const fortran_orm_i64_t *vec,
                           fortran_orm_u32_t count);

/**
 * @brief Batch-inserts a contiguous 1D `DOUBLE PRECISION` (`REAL*8`) vector.
 *
 * @param[in] db Active database handle.
 * @param[in] insert_sql Parameterized SQL (`INSERT INTO v VALUES (?)`).
 * @param[in] sql_len Byte length of `insert_sql`.
 * @param[in] vec Contiguous `double` array.
 * @param[in] count Number of elements in `vec`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_vec_f64(fortran_orm_db_t *db, const char *insert_sql,
                           fortran_orm_u32_t sql_len, const double *vec,
                           fortran_orm_u32_t count);

/**
 * @brief Executes `select_sql` and hydrates column 1 into a 1D `INTEGER*4`
 * vector.
 *
 * @param[in] db Active database handle.
 * @param[in] select_sql `SELECT` query buffer.
 * @param[in] sql_len Byte length of `select_sql`.
 * @param[out] out_vec Destination 32-bit integer array.
 * @param[in] cap_elems Maximum element capacity of `out_vec`.
 * @param[out] out_count Receives number of elements hydrated.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_vec_i32(fortran_orm_db_t *db, const char *select_sql,
                          fortran_orm_u32_t sql_len, fortran_orm_i32_t *out_vec,
                          fortran_orm_u32_t cap_elems,
                          fortran_orm_u32_t *out_count);

/**
 * @brief Executes `select_sql` and hydrates column 1 into a 1D `INTEGER*8`
 * vector.
 *
 * @param[in] db Active database handle.
 * @param[in] select_sql `SELECT` query buffer.
 * @param[in] sql_len Byte length of `select_sql`.
 * @param[out] out_vec Destination 64-bit integer array.
 * @param[in] cap_elems Maximum element capacity of `out_vec`.
 * @param[out] out_count Receives number of elements hydrated.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_vec_i64(fortran_orm_db_t *db, const char *select_sql,
                          fortran_orm_u32_t sql_len, fortran_orm_i64_t *out_vec,
                          fortran_orm_u32_t cap_elems,
                          fortran_orm_u32_t *out_count);

/**
 * @brief Executes `select_sql` and hydrates column 1 into a 1D `REAL*8` vector.
 *
 * @param[in] db Active database handle.
 * @param[in] select_sql `SELECT` query buffer.
 * @param[in] sql_len Byte length of `select_sql`.
 * @param[out] out_vec Destination `double` array.
 * @param[in] cap_elems Maximum element capacity of `out_vec`.
 * @param[out] out_count Receives number of elements hydrated.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_vec_f64(fortran_orm_db_t *db, const char *select_sql,
                          fortran_orm_u32_t sql_len, double *out_vec,
                          fortran_orm_u32_t cap_elems,
                          fortran_orm_u32_t *out_count);

/**
 * @brief Batch-persists a Fortran column-major 2D `DOUBLE PRECISION` matrix
 * `A(ld_rows, n_cols)` (`element(r, c) = matrix[c * ld_rows + r]` for `0`-based
 * `r < n_rows, c < n_cols`) using a parameterized `INSERT` with `n_cols` `?`
 * placeholders.
 *
 * @param[in] db Active database handle.
 * @param[in] insert_sql Parameterized SQL with `n_cols` placeholders.
 * @param[in] sql_len Byte length of `insert_sql`.
 * @param[in] matrix_col_major Column-major `double` buffer.
 * @param[in] ld_rows Leading dimension (`>= n_rows`) of the Fortran array.
 * @param[in] n_rows Number of active rows to insert.
 * @param[in] n_cols Number of active columns (`>= 1`).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_insert_matrix_f64(fortran_orm_db_t *db, const char *insert_sql,
                              fortran_orm_u32_t sql_len,
                              const double *matrix_col_major,
                              fortran_orm_u32_t ld_rows,
                              fortran_orm_u32_t n_rows,
                              fortran_orm_u32_t n_cols);

/**
 * @brief Hydrates a multi-column numeric SQL `SELECT` directly into a Fortran
 * column-major 2D `DOUBLE PRECISION` matrix `A(ld_rows, n_cols)` without
 * transpose copies.
 *
 * @param[in] db Active database handle.
 * @param[in] select_sql `SELECT` query returning at least `n_cols` columns.
 * @param[in] sql_len Byte length of `select_sql`.
 * @param[out] out_matrix Column-major `double` buffer (`ld_rows * n_cols`).
 * @param[in] ld_rows Leading dimension (`>= max_rows`) of `out_matrix`.
 * @param[in] max_rows Maximum rows to write (`<= ld_rows`).
 * @param[in] n_cols Number of numeric columns to extract (`>= 1`).
 * @param[out] out_rows Receives number of rows hydrated.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_matrix_f64(fortran_orm_db_t *db, const char *select_sql,
                             fortran_orm_u32_t sql_len, double *out_matrix,
                             fortran_orm_u32_t ld_rows,
                             fortran_orm_u32_t max_rows,
                             fortran_orm_u32_t n_cols,
                             fortran_orm_u32_t *out_rows);

/* ==========================================================================
 * 7. Runtime Struct Reflection, Model CRUD, Optimistic Locking & Relations
 * ========================================================================== */

/**
 * @brief Creates a dynamic `c_orm_table_meta_t` builder for a Fortran
 * `TYPE, BIND(C)` derived type of byte size `struct_size`.
 *
 * @param[in] table_name SQL table identifier buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `table_name`.
 * @param[in] struct_size Total byte size of the `BIND(C)` Fortran struct.
 * @param[out] out_schema Receives allocated runtime schema handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_create(const char *table_name, fortran_orm_u32_t name_len,
                          fortran_orm_u32_t struct_size,
                          fortran_orm_schema_t **out_schema);

/**
 * @brief Appends a mapped column descriptor to `schema`.
 *
 * For `FORTRAN_ORM_COL_CHAR_FIXED`, the field in the Fortran `BIND(C)` struct
 * is a fixed `char[fixed_len]` buffer (blank-padded or NUL-terminated) rather
 * than a `char *` heap pointer.
 *
 * @param[in,out] schema Runtime schema handle.
 * @param[in] col_name Column identifier buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `col_name`.
 * @param[in] col_type Column data type enum.
 * @param[in] byte_offset 0-based byte offset within the `BIND(C)` struct.
 * @param[in] fixed_len Fixed byte width for `CHAR_FIXED` (`0` otherwise).
 * @param[in] is_pk Non-zero if primary key column.
 * @param[in] is_nullable Non-zero if column permits SQL `NULL`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_add_col(fortran_orm_schema_t *schema, const char *col_name,
                           fortran_orm_u32_t name_len,
                           fortran_orm_col_type_t col_type,
                           fortran_orm_u32_t byte_offset,
                           fortran_orm_u32_t fixed_len, fortran_orm_i32_t is_pk,
                           fortran_orm_i32_t is_nullable);

/**
 * @brief Registers a foreign-key relationship metadata descriptor on `schema`.
 *
 * @param[in,out] schema Parent runtime schema handle.
 * @param[in] field_name Relation name buffer.
 * @param[in] field_len Byte length of `field_name`.
 * @param[in] rel_kind Relationship kind enum.
 * @param[in] target_schema Target table runtime schema handle.
 * @param[in] fk_col Foreign key column name buffer.
 * @param[in] fk_len Byte length of `fk_col`.
 * @param[in] local_col Local key column name buffer.
 * @param[in] local_len Byte length of `local_col`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_add_relation(fortran_orm_schema_t *schema,
                                const char *field_name,
                                fortran_orm_u32_t field_len,
                                fortran_orm_relation_kind_t rel_kind,
                                const fortran_orm_schema_t *target_schema,
                                const char *fk_col, fortran_orm_u32_t fk_len,
                                const char *local_col,
                                fortran_orm_u32_t local_len);

/**
 * @brief Finalizes SQL query templates on `schema` and emits `CREATE TABLE IF
 * NOT EXISTS` DDL into `out_ddl`.
 *
 * @param[in,out] schema Runtime schema handle.
 * @param[out] out_ddl Destination blank-padded DDL buffer.
 * @param[in] ddl_cap Capacity of `out_ddl` in bytes.
 * @param[out] out_len Receives trimmed DDL length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_build_ddl(fortran_orm_schema_t *schema, char *out_ddl,
                             fortran_orm_u32_t ddl_cap,
                             fortran_orm_u32_t *out_len);

/**
 * @brief Creates the SQL table defined by `schema` on `db`.
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_create_table(fortran_orm_db_t *db,
                              fortran_orm_schema_t *schema);

/**
 * @brief Inserts a single `BIND(C)` Fortran struct instance (`C_LOC(rec)`).
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] in_record Pointer to `BIND(C)` Fortran struct (`TYPE(C_PTR)`).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_insert(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                        const void *in_record);

/**
 * @brief Dialect-aware atomic `UPSERT` (`ON CONFLICT` / `MERGE INTO`) of a
 * `BIND(C)` Fortran struct instance.
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] in_record Pointer to `BIND(C)` Fortran struct.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_upsert(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                        const void *in_record);

/**
 * @brief Updates an existing row matching the primary key in `in_record`.
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] in_record Pointer to `BIND(C)` Fortran struct.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_update(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                        const void *in_record);

/**
 * @brief Performs an optimistic-locked `UPDATE` checking and incrementing
 * integer `version_col` (returns `FORTRAN_ORM_ERROR_NOT_FOUND` on conflict).
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] version_col Version column name buffer.
 * @param[in] col_len Byte length of `version_col`.
 * @param[in] in_record Pointer to `BIND(C)` Fortran struct.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_update_optimistic(fortran_orm_db_t *db,
                                   fortran_orm_schema_t *schema,
                                   const char *version_col,
                                   fortran_orm_u32_t col_len,
                                   const void *in_record);

/**
 * @brief Finds and hydrates a single `BIND(C)` Fortran struct by 32-bit PK.
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] id_val 32-bit primary key value.
 * @param[out] out_record Pointer to pre-allocated `BIND(C)` Fortran struct.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_find_i32(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                          fortran_orm_i32_t id_val, void *out_record);

/**
 * @brief Finds a single `BIND(C)` Fortran struct with pessimistic `FOR UPDATE`
 * row locking.
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] id_val 32-bit primary key value.
 * @param[out] out_record Pointer to pre-allocated `BIND(C)` Fortran struct.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_find_for_update_i32(fortran_orm_db_t *db,
                                     fortran_orm_schema_t *schema,
                                     fortran_orm_i32_t id_val,
                                     void *out_record);

/**
 * @brief Checks whether a row with 32-bit primary key `id_val` exists.
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] id_val 32-bit primary key value.
 * @param[out] out_exists Receives `1` if present, `0` otherwise.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_exists_i32(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                            fortran_orm_i32_t id_val,
                            fortran_orm_i32_t *out_exists);

/**
 * @brief Deletes a row by 32-bit primary key `id_val`.
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[in] id_val 32-bit primary key value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_delete_i32(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                            fortran_orm_i32_t id_val);

/**
 * @brief Hydrates all rows of `schema` into a contiguous Fortran array of
 * `BIND(C)` structs (`max_records * struct_size` bytes).
 *
 * @param[in] db Active database handle.
 * @param[in,out] schema Runtime schema handle.
 * @param[out] out_array Contiguous array of `BIND(C)` structs.
 * @param[in] max_records Capacity of `out_array` in records.
 * @param[out] out_count Receives number of records hydrated.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_find_all(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                          void *out_array, fortran_orm_u32_t max_records,
                          fortran_orm_u32_t *out_count);

/**
 * @brief Frees a runtime schema handle and all owned column/query strings.
 *
 * @param[in,out] schema Runtime schema handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_free(fortran_orm_schema_t *schema);

/* ==========================================================================
 * 8. Dynamic Abstract Row Hydration & Fluent AST Query Builder
 * ========================================================================== */

/**
 * @brief Executes arbitrary `SELECT` SQL and hydrates all rows into a dynamic
 * `cdd_c_abstract_struct_array_t` result-set handle.
 *
 * @param[in] db Active database handle.
 * @param[in] sql `SELECT` SQL buffer (trailing spaces trimmed).
 * @param[in] sql_len Byte length of `sql`.
 * @param[out] out_rs Receives dynamic result-set handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_abstract(fortran_orm_db_t *db, const char *sql,
                           fortran_orm_u32_t sql_len,
                           fortran_orm_rs_t **out_rs);

/**
 * @brief Queries total number of rows in dynamic result set `rs`.
 *
 * @param[in] rs Result-set handle.
 * @param[out] out_rows Receives row count.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_row_count(const fortran_orm_rs_t *rs,
                         fortran_orm_u32_t *out_rows);

/**
 * @brief Queries column count of 1-based row `row_idx` (`1..row_count`).
 *
 * @param[in] rs Result-set handle.
 * @param[in] row_idx 1-based row index.
 * @param[out] out_cols Receives column count.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_col_count(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                         fortran_orm_u32_t *out_cols);

/**
 * @brief Copies the name of 1-based `(row_idx, col_idx)` into `out_buf`.
 *
 * @param[in] rs Result-set handle.
 * @param[in] row_idx 1-based row index.
 * @param[in] col_idx 1-based column index.
 * @param[out] out_buf Destination blank-padded character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed column name length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_col_name(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                        fortran_orm_u32_t col_idx, char *out_buf,
                        fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Checks whether column `col_name` on 1-based `row_idx` is `NULL`.
 *
 * @param[in] rs Result-set handle.
 * @param[in] row_idx 1-based row index.
 * @param[in] col_name Column name buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `col_name`.
 * @param[out] out_is_null Receives `1` if `NULL`, `0` otherwise.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_is_null(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       fortran_orm_i32_t *out_is_null);

/**
 * @brief Reads a 64-bit integer by column name from 1-based `row_idx`.
 *
 * @param[in] rs Result-set handle.
 * @param[in] row_idx 1-based row index.
 * @param[in] col_name Column name buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `col_name`.
 * @param[out] out_val Receives 64-bit integer value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_get_i64(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       fortran_orm_i64_t *out_val);

/**
 * @brief Reads a `DOUBLE PRECISION` value by column name from 1-based
 * `row_idx`.
 *
 * @param[in] rs Result-set handle.
 * @param[in] row_idx 1-based row index.
 * @param[in] col_name Column name buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `col_name`.
 * @param[out] out_val Receives `double` value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_get_f64(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       double *out_val);

/**
 * @brief Reads a blank-padded string by column name from 1-based `row_idx`.
 *
 * @param[in] rs Result-set handle.
 * @param[in] row_idx 1-based row index.
 * @param[in] col_name Column name buffer (trailing spaces trimmed).
 * @param[in] name_len Byte length of `col_name`.
 * @param[out] out_buf Destination blank-padded character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed string length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_get_str(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       char *out_buf, fortran_orm_u32_t buf_cap,
                       fortran_orm_u32_t *out_len);

/**
 * @brief Serializes dynamic result set `rs` into a JSON array string.
 *
 * @param[in] rs Result-set handle.
 * @param[out] out_json Destination blank-padded character buffer.
 * @param[in] json_cap Capacity of `out_json` in bytes.
 * @param[out] out_len Receives JSON byte length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_to_json(const fortran_orm_rs_t *rs, char *out_json,
                       fortran_orm_u32_t json_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Frees a dynamic result-set handle.
 *
 * @param[in,out] rs Result-set handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_free(fortran_orm_rs_t *rs);

/**
 * @brief Creates a `SELECT <columns> FROM <table>` arena-backed AST builder.
 *
 * @param[in] table Table identifier buffer (trailing spaces trimmed).
 * @param[in] table_len Byte length of `table`.
 * @param[in] columns Comma-separated projection buffer (e.g. `"*"`).
 * @param[in] cols_len Byte length of `columns`.
 * @param[out] out_ast Receives allocated AST query handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_select(const char *table, fortran_orm_u32_t table_len,
                       const char *columns, fortran_orm_u32_t cols_len,
                       fortran_orm_ast_t **out_ast);

/**
 * @brief Creates an `INSERT INTO <table>` arena-backed AST builder.
 *
 * @param[in] table Table identifier buffer.
 * @param[in] table_len Byte length of `table`.
 * @param[out] out_ast Receives allocated AST query handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_insert(const char *table, fortran_orm_u32_t table_len,
                       fortran_orm_ast_t **out_ast);

/**
 * @brief Creates an `UPDATE <table>` arena-backed AST builder.
 *
 * @param[in] table Table identifier buffer.
 * @param[in] table_len Byte length of `table`.
 * @param[out] out_ast Receives allocated AST query handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_update(const char *table, fortran_orm_u32_t table_len,
                       fortran_orm_ast_t **out_ast);

/**
 * @brief Creates a `DELETE FROM <table>` arena-backed AST builder.
 *
 * @param[in] table Table identifier buffer.
 * @param[in] table_len Byte length of `table`.
 * @param[out] out_ast Receives allocated AST query handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_delete(const char *table, fortran_orm_u32_t table_len,
                       fortran_orm_ast_t **out_ast);

/**
 * @brief Enables `SELECT DISTINCT` on `ast`.
 *
 * @param[in,out] ast AST handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_distinct(fortran_orm_ast_t *ast);

/**
 * @brief Appends an integer comparison `WHERE` / `AND` predicate (`=`, `!=`,
 * `<`, `>`).
 *
 * @param[in,out] ast AST handle.
 * @param[in] col Column name buffer.
 * @param[in] col_len Byte length of `col`.
 * @param[in] op_str Operator (`"="`, `"!="`, `"<"`, `">"`).
 * @param[in] op_len Byte length of `op_str`.
 * @param[in] val 64-bit integer value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_where_i64(fortran_orm_ast_t *ast, const char *col,
                          fortran_orm_u32_t col_len, const char *op_str,
                          fortran_orm_u32_t op_len, fortran_orm_i64_t val);

/**
 * @brief Appends a string comparison `WHERE` / `AND` predicate (`=`, `!=`,
 * `LIKE`).
 *
 * @param[in,out] ast AST handle.
 * @param[in] col Column name buffer.
 * @param[in] col_len Byte length of `col`.
 * @param[in] op_str Operator (`"="`, `"!="`, `"LIKE"`).
 * @param[in] op_len Byte length of `op_str`.
 * @param[in] val String literal buffer.
 * @param[in] val_len Byte length of `val`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_where_str(fortran_orm_ast_t *ast, const char *col,
                          fortran_orm_u32_t col_len, const char *op_str,
                          fortran_orm_u32_t op_len, const char *val,
                          fortran_orm_u32_t val_len);

/**
 * @brief Appends a `JOIN` clause (`INNER`, `LEFT`, `RIGHT`) to `ast`.
 *
 * @param[in,out] ast AST handle.
 * @param[in] join_type Join type (`"INNER"`, `"LEFT"`, `"RIGHT"`).
 * @param[in] type_len Byte length of `join_type`.
 * @param[in] table Joined table name buffer.
 * @param[in] table_len Byte length of `table`.
 * @param[in] on_sql Raw `ON` condition expression (e.g. `"a.id = b.a_id"`).
 * @param[in] on_len Byte length of `on_sql`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_join(fortran_orm_ast_t *ast, const char *join_type,
                     fortran_orm_u32_t type_len, const char *table,
                     fortran_orm_u32_t table_len, const char *on_sql,
                     fortran_orm_u32_t on_len);

/**
 * @brief Appends `GROUP BY` and optional `HAVING` expression to `ast`.
 *
 * @param[in,out] ast AST handle.
 * @param[in] group_cols Comma-separated `GROUP BY` column list.
 * @param[in] group_len Byte length of `group_cols`.
 * @param[in] having_sql Optional `HAVING` raw expression (`0` length to skip).
 * @param[in] having_len Byte length of `having_sql`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_group_having(fortran_orm_ast_t *ast, const char *group_cols,
                             fortran_orm_u32_t group_len,
                             const char *having_sql,
                             fortran_orm_u32_t having_len);

/**
 * @brief Appends `ORDER BY`, `LIMIT`, and `OFFSET` clauses to `ast`.
 *
 * @param[in,out] ast AST handle.
 * @param[in] order_col Sort column (`0` length to skip `ORDER BY`).
 * @param[in] col_len Byte length of `order_col`.
 * @param[in] descending Non-zero for `DESC`, `0` for `ASC`.
 * @param[in] limit_rows Maximum rows (`0` to skip `LIMIT`).
 * @param[in] offset_rows Initial rows to skip (`0` to skip `OFFSET`).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_order_limit(fortran_orm_ast_t *ast, const char *order_col,
                            fortran_orm_u32_t col_len,
                            fortran_orm_i32_t descending,
                            fortran_orm_u32_t limit_rows,
                            fortran_orm_u32_t offset_rows);

/**
 * @brief Appends a column assignment (`INSERT` / `UPDATE`) with a 64-bit
 * integer value.
 *
 * @param[in,out] ast AST handle.
 * @param[in] col Column name buffer.
 * @param[in] col_len Byte length of `col`.
 * @param[in] val 64-bit integer value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_set_i64(fortran_orm_ast_t *ast, const char *col,
                        fortran_orm_u32_t col_len, fortran_orm_i64_t val);

/**
 * @brief Appends a column assignment (`INSERT` / `UPDATE`) with a string value.
 *
 * @param[in,out] ast AST handle.
 * @param[in] col Column name buffer.
 * @param[in] col_len Byte length of `col`.
 * @param[in] val String value buffer.
 * @param[in] val_len Byte length of `val`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_set_str(fortran_orm_ast_t *ast, const char *col,
                        fortran_orm_u32_t col_len, const char *val,
                        fortran_orm_u32_t val_len);

/**
 * @brief Appends `RETURNING` projection and/or Db2 isolation lock clause (`1`
 * UR, `2` CS, `3` RS, `4` RR, `5` FOR FETCH ONLY).
 *
 * @param[in,out] ast AST handle.
 * @param[in] returning_cols Returning columns (`0` length to skip).
 * @param[in] ret_len Byte length of `returning_cols`.
 * @param[in] db2_lock_mode Db2 lock mode (`0` none, `1..5`).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_returning_lock(fortran_orm_ast_t *ast,
                               const char *returning_cols,
                               fortran_orm_u32_t ret_len,
                               fortran_orm_i32_t db2_lock_mode);

/**
 * @brief Renders `ast` into parameterized SQL for `dialect`.
 *
 * @param[in] ast AST handle.
 * @param[in] dialect Target SQL dialect enum.
 * @param[out] out_sql Destination blank-padded SQL character buffer.
 * @param[in] sql_cap Capacity of `out_sql` in bytes.
 * @param[out] out_len Receives trimmed SQL byte length.
 * @param[out] out_param_count Receives number of extracted bind parameters.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_to_sql(fortran_orm_ast_t *ast, fortran_orm_dialect_t dialect,
                       char *out_sql, fortran_orm_u32_t sql_cap,
                       fortran_orm_u32_t *out_len,
                       fortran_orm_u32_t *out_param_count);

/**
 * @brief Compiles and executes a non-query (`INSERT` / `UPDATE` / `DELETE`)
 * AST directly against `db`.
 *
 * @param[in] db Active database handle.
 * @param[in] ast AST handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_exec(fortran_orm_db_t *db, fortran_orm_ast_t *ast);

/**
 * @brief Compiles and executes a `SELECT` AST against `db`, hydrating results
 * into a dynamic `fortran_orm_rs_t` handle.
 *
 * @param[in] db Active database handle.
 * @param[in] ast AST handle.
 * @param[out] out_rs Receives hydrated dynamic result-set handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_query_rs(fortran_orm_db_t *db, fortran_orm_ast_t *ast,
                         fortran_orm_rs_t **out_rs);

/**
 * @brief Frees an arena-backed AST builder handle.
 *
 * @param[in,out] ast AST handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_free(fortran_orm_ast_t *ast);

/* ==========================================================================
 * 9. Schema Migrations, 38-Digit Decimal, EBCDIC, Db2/ODBC, UUID & OAuth2
 * ========================================================================== */

/**
 * @brief Initializes a schema migration runner scanning `dir_path`.
 *
 * @param[in] db Active database handle.
 * @param[in] dir_path Filesystem directory containing `.sql` migrations.
 * @param[in] dir_len Byte length of `dir_path`.
 * @param[out] out_mig Receives migration runner handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_init(fortran_orm_db_t *db, const char *dir_path,
                     fortran_orm_u32_t dir_len, fortran_orm_mig_t **out_mig);

/**
 * @brief Applies pending `-- UP` SQL migrations.
 *
 * @param[in] mig Migration runner handle.
 * @param[in] dry_run Non-zero to validate without mutating database.
 * @param[out] out_total_applied Receives total count of applied migrations.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_up(fortran_orm_mig_t *mig, fortran_orm_i32_t dry_run,
                   fortran_orm_u32_t *out_total_applied);

/**
 * @brief Rolls back the last `steps` applied migrations (`-- DOWN`).
 *
 * @param[in] mig Migration runner handle.
 * @param[in] steps Number of migrations to revert (`0` reverts all).
 * @param[in] dry_run Non-zero to validate without mutating database.
 * @param[out] out_remaining Receives remaining applied migration count.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_down(fortran_orm_mig_t *mig, fortran_orm_u32_t steps,
                     fortran_orm_i32_t dry_run,
                     fortran_orm_u32_t *out_remaining);

/**
 * @brief Copies the latest applied migration version string into `out_ver`.
 *
 * @param[in] mig Migration runner handle.
 * @param[out] out_ver Destination blank-padded character buffer.
 * @param[in] ver_cap Capacity of `out_ver` in bytes.
 * @param[out] out_len Receives version string length (`0` if none applied).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_version(fortran_orm_mig_t *mig, char *out_ver,
                        fortran_orm_u32_t ver_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Frees a migration runner handle.
 *
 * @param[in,out] mig Migration runner handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_free(fortran_orm_mig_t *mig);

/**
 * @brief Parses a base-10 numeric string slice into an exact 38-digit decimal.
 *
 * @param[in] str Decimal text buffer (leading/trailing spaces trimmed).
 * @param[in] str_len Byte length of `str`.
 * @param[out] out_dec Receives parsed `fortran_orm_decimal_t`.
 * @return `FORTRAN_ORM_OK` on success, or decimal syntax/overflow error.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_from_str(const char *str, fortran_orm_u32_t str_len,
                         fortran_orm_decimal_t *out_dec);

/**
 * @brief Formats `dec` into a canonical base-10 string in blank-padded
 * `out_buf`.
 *
 * @param[in] dec Source decimal value.
 * @param[out] out_buf Destination blank-padded character buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives trimmed string length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_to_str(const fortran_orm_decimal_t *dec, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len);

/**
 * @brief Converts a 64-bit signed integer into a scale-0 decimal.
 *
 * @param[in] val 64-bit integer value.
 * @param[out] out_dec Receives decimal value.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_from_i64(fortran_orm_i64_t val, fortran_orm_decimal_t *out_dec);

/**
 * @brief Converts `dec` to a 64-bit signed integer using `round_mode`.
 *
 * @param[in] dec Source decimal value.
 * @param[in] round_mode Rounding mode enum.
 * @param[out] out_val Receives rounded 64-bit integer.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_to_i64(const fortran_orm_decimal_t *dec,
                       fortran_orm_round_mode_t round_mode,
                       fortran_orm_i64_t *out_val);

/**
 * @brief Computes exact fixed-point sum `a + b`.
 *
 * @param[in] a Left addend.
 * @param[in] b Right addend.
 * @param[out] out_res Receives sum.
 * @return `FORTRAN_ORM_OK` on success, or overflow error.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_add(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b,
                    fortran_orm_decimal_t *out_res);

/**
 * @brief Computes exact fixed-point difference `a - b`.
 *
 * @param[in] a Minuend.
 * @param[in] b Subtrahend.
 * @param[out] out_res Receives difference.
 * @return `FORTRAN_ORM_OK` on success, or overflow error.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_sub(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b,
                    fortran_orm_decimal_t *out_res);

/**
 * @brief Computes fixed-point product `a * b` bounded to `max_scale`.
 *
 * @param[in] a Multiplicand.
 * @param[in] b Multiplier.
 * @param[in] max_scale Maximum fractional scale (`0..38`).
 * @param[in] round_mode Rounding mode when reducing scale.
 * @param[out] out_res Receives product.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_mul(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b, fortran_orm_u32_t max_scale,
                    fortran_orm_round_mode_t round_mode,
                    fortran_orm_decimal_t *out_res);

/**
 * @brief Computes fixed-point quotient `a / b` at `result_scale`.
 *
 * @param[in] a Dividend.
 * @param[in] b Divisor.
 * @param[in] result_scale Desired fractional scale (`0..38`).
 * @param[in] round_mode Remainder rounding mode.
 * @param[out] out_res Receives quotient.
 * @return `FORTRAN_ORM_OK` on success, or divide-by-zero / overflow error.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_div(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b,
                    fortran_orm_u32_t result_scale,
                    fortran_orm_round_mode_t round_mode,
                    fortran_orm_decimal_t *out_res);

/**
 * @brief Numerically compares two decimals (`-1`, `0`, `+1`).
 *
 * @param[in] a Left decimal.
 * @param[in] b Right decimal.
 * @param[out] out_cmp Receives `-1` (`a < b`), `0` (`a == b`), or `1` (`a >
 * b`).
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_cmp(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b, fortran_orm_i32_t *out_cmp);

/**
 * @brief Rescales `dec` to `(target_precision, target_scale)` under
 * `round_mode`.
 *
 * @param[in] dec Source decimal.
 * @param[in] target_precision Maximum allowed digits (`1..38`).
 * @param[in] target_scale Target fractional digits (`0..target_precision`).
 * @param[in] round_mode Rounding mode enum.
 * @param[out] out_dec Receives rescaled decimal.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_rescale(const fortran_orm_decimal_t *dec,
                        fortran_orm_u32_t target_precision,
                        fortran_orm_u32_t target_scale,
                        fortran_orm_round_mode_t round_mode,
                        fortran_orm_decimal_t *out_dec);

/**
 * @brief Transcodes single-byte mainframe EBCDIC bytes into blank-padded UTF-8.
 *
 * @param[in] codepage Source EBCDIC codepage enum.
 * @param[in] ebcdic_bytes Source EBCDIC byte buffer.
 * @param[in] byte_len Number of source bytes.
 * @param[out] out_utf8 Destination blank-padded UTF-8 character buffer.
 * @param[in] out_cap Capacity of `out_utf8` in bytes.
 * @param[out] out_len Receives decoded UTF-8 byte count.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ebcdic_to_utf8(fortran_orm_codepage_t codepage,
                           const fortran_orm_u8_t *ebcdic_bytes,
                           fortran_orm_u32_t byte_len, char *out_utf8,
                           fortran_orm_u32_t out_cap,
                           fortran_orm_u32_t *out_len);

/**
 * @brief Transcodes UTF-8 text into single-byte mainframe EBCDIC bytes.
 *
 * @param[in] codepage Target EBCDIC codepage enum.
 * @param[in] utf8_str Source UTF-8 character buffer.
 * @param[in] str_len Byte length of `utf8_str`.
 * @param[out] out_ebcdic Destination EBCDIC byte buffer.
 * @param[in] out_cap Capacity of `out_ebcdic` in bytes.
 * @param[out] out_len Receives encoded EBCDIC byte count.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_utf8_to_ebcdic(fortran_orm_codepage_t codepage,
                           const char *utf8_str, fortran_orm_u32_t str_len,
                           fortran_orm_u8_t *out_ebcdic,
                           fortran_orm_u32_t out_cap,
                           fortran_orm_u32_t *out_len);

/**
 * @brief Transcodes UTF-8 text into UTF-16 code units (`GRAPHIC` / `SQLWCHAR`).
 *
 * @param[in] utf8_str Source UTF-8 character buffer.
 * @param[in] str_len Byte length of `utf8_str`.
 * @param[in] big_endian Non-zero for big-endian z/OS `GRAPHIC` byte order.
 * @param[out] out_u16 Destination 16-bit code unit array.
 * @param[in] u16_cap Capacity of `out_u16` in 16-bit units (`>= units + 1`).
 * @param[out] out_units Receives written 16-bit unit count.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_utf8_to_utf16(const char *utf8_str, fortran_orm_u32_t str_len,
                          fortran_orm_i32_t big_endian,
                          fortran_orm_u16_t *out_u16, fortran_orm_u32_t u16_cap,
                          fortran_orm_u32_t *out_units);

/**
 * @brief Transcodes UTF-16 code units into blank-padded UTF-8 text.
 *
 * @param[in] u16_units Source 16-bit UTF-16 code unit array.
 * @param[in] unit_count Number of 16-bit units to decode.
 * @param[in] big_endian Non-zero if `u16_units` are big-endian.
 * @param[out] out_utf8 Destination blank-padded UTF-8 character buffer.
 * @param[in] out_cap Capacity of `out_utf8` in bytes.
 * @param[out] out_len Receives decoded UTF-8 byte length.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_utf16_to_utf8(const fortran_orm_u16_t *u16_units,
                          fortran_orm_u32_t unit_count,
                          fortran_orm_i32_t big_endian, char *out_utf8,
                          fortran_orm_u32_t out_cap,
                          fortran_orm_u32_t *out_len);

/**
 * @brief Retrieves the 5-character ANSI `SQLSTATE` recorded on an ODBC/Db2
 * connection.
 *
 * @param[in] db Active ODBC/Db2 database handle.
 * @param[out] out_state Destination blank-padded buffer (`>= 5` bytes).
 * @param[in] state_cap Capacity of `out_state` in bytes.
 * @param[out] out_len Receives length (`5`).
 * @return `FORTRAN_ORM_OK` on success, or validation error if not ODBC/Db2.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_odbc_sqlstate(fortran_orm_db_t *db, char *out_state,
                          fortran_orm_u32_t state_cap,
                          fortran_orm_u32_t *out_len);

/**
 * @brief Configures transaction isolation level (`UR`, `CS`, `RS`, `RR`) on an
 * ODBC or IBM Db2 connection.
 *
 * @param[in] db Active ODBC/Db2 database handle.
 * @param[in] iso_level Isolation level enum.
 * @return `FORTRAN_ORM_OK` on success, or diagnostic/validation error.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_set_isolation(fortran_orm_db_t *db,
                          fortran_orm_isolation_t iso_level);

/**
 * @brief Configures IBM Db2 Workload Manager (WLM) client registers and active
 * `CURRENT SCHEMA`.
 *
 * @param[in] db Active Db2 connection handle.
 * @param[in] userid Client user ID (`0` length to skip).
 * @param[in] userid_len Byte length of `userid`.
 * @param[in] applname Client application name (`0` length to skip).
 * @param[in] appl_len Byte length of `applname`.
 * @param[in] schema Target Db2 `CURRENT SCHEMA` (`0` length to skip).
 * @param[in] schema_len Byte length of `schema`.
 * @return `FORTRAN_ORM_OK` on success, or diagnostic/validation error.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_db2_configure(fortran_orm_db_t *db, const char *userid,
                          fortran_orm_u32_t userid_len, const char *applname,
                          fortran_orm_u32_t appl_len, const char *schema,
                          fortran_orm_u32_t schema_len);

/**
 * @brief Generates a RFC 4122 random UUID v4 (`36` ASCII chars) into
 * blank-padded `out_uuid`.
 *
 * @param[out] out_uuid Destination character buffer (`>= 36` bytes).
 * @param[in] uuid_cap Capacity of `out_uuid` in bytes.
 * @param[out] out_len Receives `36`.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_uuid_v4(char *out_uuid, fortran_orm_u32_t uuid_cap,
                    fortran_orm_u32_t *out_len);

/**
 * @brief Creates the standard `c-orm` OAuth2 tables (`users`, `tokens`,
 * `clients`, `auth_codes`) on `db`.
 *
 * @param[in] db Active database handle.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_init_tables(fortran_orm_db_t *db);

/**
 * @brief Persists an OAuth2 token POD structure into `db`.
 *
 * @param[in] db Active database handle.
 * @param[in] token_pod Populated OAuth2 token POD struct.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_save_token(fortran_orm_db_t *db,
                              const fortran_orm_oauth2_token_pod_t *token_pod);

/**
 * @brief Retrieves an OAuth2 token POD structure by `access_token`.
 *
 * @param[in] db Active database handle.
 * @param[in] access_token Access token string buffer (trailing spaces trimmed).
 * @param[in] token_len Byte length of `access_token`.
 * @param[out] out_pod Receives hydrated OAuth2 token POD struct.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_get_token(fortran_orm_db_t *db, const char *access_token,
                             fortran_orm_u32_t token_len,
                             fortran_orm_oauth2_token_pod_t *out_pod);

/**
 * @brief Revokes an OAuth2 token by `access_token` and validates scope subsets.
 *
 * @param[in] db Active database handle (may be NULL if `revoke_flag == 0`).
 * @param[in] access_token Access token to revoke when `revoke_flag != 0`.
 * @param[in] token_len Byte length of `access_token`.
 * @param[in] revoke_flag Non-zero to delete token from `db`.
 * @param[in] granted_scopes Space-delimited granted scopes.
 * @param[in] granted_len Byte length of `granted_scopes`.
 * @param[in] req_scopes Space-delimited requested scopes.
 * @param[in] req_len Byte length of `req_scopes`.
 * @param[out] out_scope_valid Receives `1` if `req_scopes` is a subset.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_revoke_or_check(
    fortran_orm_db_t *db, const char *access_token, fortran_orm_u32_t token_len,
    fortran_orm_i32_t revoke_flag, const char *granted_scopes,
    fortran_orm_u32_t granted_len, const char *req_scopes,
    fortran_orm_u32_t req_len, fortran_orm_i32_t *out_scope_valid);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* FORTRAN_ORM_FFI_H */
