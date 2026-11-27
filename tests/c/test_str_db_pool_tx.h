/**
 * @file test_str_db_pool_tx.h
 * @brief Unit tests for `fortran_orm_str.c`, `fortran_orm_db.c`,
 * `fortran_orm_pool.c`, and `fortran_orm_tx.c`.
 */

#ifndef TEST_STR_DB_POOL_TX_H
/** @brief Header guard for test_str_db_pool_tx.h. */
#define TEST_STR_DB_POOL_TX_H

/**
 * @brief Tests ABI struct sizes, error names, blank-padded string helpers, and
 * A1/A4 Hollerith codecs (`fortran_orm_str.c`).
 */
TEST test_str_and_abi(void) {
  char buf[64];
  char *cstr = NULL;
  fortran_orm_i32_t a1[8];
  fortran_orm_i32_t a4[4];
  fortran_orm_u32_t out_len = 0u;
  fortran_orm_decimal_t fdec;
  c_orm_decimal_t cdec;
  fortran_orm_db_t bad_db;
  fortran_orm_stmt_t bad_st;
  int i;

  ASSERT_EQ((size_t)44, sizeof(fortran_orm_decimal_t));
  ASSERT_EQ((size_t)40, sizeof(fortran_orm_pool_stats_t));
  ASSERT_EQ((size_t)976, sizeof(fortran_orm_oauth2_token_pod_t));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_keep_err(FORTRAN_ORM_OK, FORTRAN_ORM_OK));
  ASSERT_EQ(FORTRAN_ORM_ERROR_IO,
            fortran_orm_keep_err(FORTRAN_ORM_OK, FORTRAN_ORM_ERROR_IO));
  ASSERT_EQ(FORTRAN_ORM_ERROR_SQL,
            fortran_orm_keep_err(FORTRAN_ORM_ERROR_SQL, FORTRAN_ORM_ERROR_IO));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_from_c(C_ORM_OK));

  memset(&bad_db, 0, sizeof(bad_db));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_check_db(NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_check_db(&bad_db));
  bad_db.magic = FORTRAN_ORM_MAGIC_DB;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_check_db(&bad_db));

  memset(&bad_st, 0, sizeof(bad_st));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_check_stmt(NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_check_stmt(&bad_st));
  bad_st.magic = FORTRAN_ORM_MAGIC_STMT;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_check_stmt(&bad_st));
  bad_st.query = (c_orm_query_t *)&bad_st;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_check_stmt(&bad_st));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_slice_to_cstr("abc", 3u, 1, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_slice_to_cstr(NULL, 3u, 1, &cstr));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_slice_to_cstr(NULL, 0u, 1, &cstr));
  ASSERT_STR_EQ("", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_slice_to_cstr("AB\0CD", 5u, 1, &cstr));
  ASSERT_STR_EQ("AB", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_slice_to_cstr("XY  ", 4u, 0, &cstr));
  ASSERT_STR_EQ("XY  ", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_slice_to_cstr("   ", 3u, 1, &cstr));
  ASSERT_STR_EQ("", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cstr_to_fbuf("hi", buf, 8u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cstr_to_fbuf("hi", NULL, 8u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cstr_to_fbuf(NULL, NULL, 0u, &out_len));
  ASSERT_EQ(0u, out_len);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cstr_to_fbuf("AB", buf, 2u, &out_len));
  ASSERT_EQ(2u, out_len);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cstr_to_fbuf("AB", buf, 4u, &out_len));
  ASSERT_EQ(' ', buf[3]);
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_cstr_to_fbuf("ABCD", buf, 2u, &out_len));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_a1_to_cstr(a1, 2u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_a1_to_cstr(NULL, 2u, &cstr));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_a1_to_cstr(NULL, 0u, &cstr));
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));
  a1[0] = (fortran_orm_i32_t)' ';
  a1[1] = (fortran_orm_i32_t)' ';
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_a1_to_cstr(a1, 2u, &cstr));
  ASSERT_STR_EQ("", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));
  ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_MEMORY, fortran_orm_a1_to_cstr(a1, 0u, &cstr));
  ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));

  a1[0] = (fortran_orm_i32_t)'F';
  a1[1] = (fortran_orm_i32_t)' ';
  a1[2] = 0;
  a1[3] = (fortran_orm_i32_t)'X';
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_a1_to_cstr(a1, 4u, &cstr));
  ASSERT_STR_EQ("F", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_a1_to_str(a1, 4u, buf, 8u, &out_len));
  ASSERT_EQ(1u, out_len);
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_a1_to_str(NULL, 2u, buf, 8u, &out_len));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_str_to_a1("A", 1u, a1, 4u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_str_to_a1("A", 1u, NULL, 4u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_str_to_a1("", 0u, NULL, 0u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_str_to_a1(NULL, 2u, a1, 4u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_str_to_a1("IBM  ", 5u, a1, 5u, &out_len));
  ASSERT_EQ(3u, out_len);
  ASSERT_EQ((fortran_orm_i32_t)' ', a1[4]);
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_str_to_a1("FORTRAN", 7u, a1, 3u, &out_len));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_a4_to_cstr(a4, 4u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_a4_to_cstr(NULL, 4u, &cstr));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_a4_to_cstr(NULL, 0u, &cstr));
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cstr_to_a4("X", a4, 4u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cstr_to_a4("X", NULL, 4u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cstr_to_a4("", NULL, 0u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cstr_to_a4("TEST", a4, 8u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_a4_to_cstr(a4, 8u, &cstr));
  ASSERT_STR_EQ("TEST", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));

  memset(&fdec, 0, sizeof(fdec));
  memset(&cdec, 0, sizeof(cdec));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_dec_to_c(NULL, &cdec));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_dec_to_c(&fdec, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_from_c(NULL, &fdec));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_from_c(&cdec, NULL));

  for (i = -1; i <= 40; i++) {
    ASSERT_EQ(FORTRAN_ORM_OK,
              fortran_orm_error_name((fortran_orm_error_t)i, buf,
                                     (fortran_orm_u32_t)sizeof(buf), &out_len));
    ASSERT(out_len > 0u);
  }
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_version(buf, 16u, &out_len));
  ASSERT_EQ(5u, out_len);
  PASS();
}

/**
 * @brief Tests `fortran_orm_db.c`, `fortran_orm_pool.c`, and
 * `fortran_orm_tx.c` across valid, boundary, and error paths.
 */
TEST test_db_pool_shard_and_tx(void) {
  fortran_orm_db_t *db = NULL;
  fortran_orm_db_t *db2 = NULL;
  fortran_orm_db_t *leased = NULL;
  fortran_orm_db_t *leased2 = NULL;
  fortran_orm_pool_t *pool = NULL;
  fortran_orm_shard_t *shard = NULL;
  fortran_orm_pool_t bad_pool;
  fortran_orm_shard_t bad_shard;
  fortran_orm_pool_stats_t stats;
  fortran_orm_i64_t rowid = 0;
  fortran_orm_u32_t out_len = 0u;
  fortran_orm_u32_t sidx = 0u;
  char buf[128];

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_connect_cstr(NULL, &db));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_connect_cstr(":memory:", NULL));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_connect_cstr("bad://url", &db));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_connect(":memory:", 8u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_connect(NULL, 8u, &db));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_connect(":memory:   ", 11u, &db));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_disconnect(NULL));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_exec_cstr(NULL, "SELECT 1"));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_exec_cstr(db, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_exec_sql(NULL, "SELECT 1", 8u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_exec_sql(db, NULL, 8u));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_exec_cstr(db, "BAD SQL SYNTAX"));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_last_error(NULL, buf, 64u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_last_error(db, buf, 128u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_last_trace(NULL, buf, 64u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_last_trace(db, buf, 128u, &out_len));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(db, "CREATE TABLE t(x INT);"));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_sql(db, "INSERT INTO t VALUES(9)  ", 25u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_last_insert_rowid(NULL, &rowid));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_last_insert_rowid(db, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_last_insert_rowid(db, &rowid));
  ASSERT_EQ(1, (int)rowid);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_enable_stmt_cache(NULL, 4u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_enable_stmt_cache(db, 4u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_enable_stmt_cache(db, 0u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_set_timezone(NULL, 0, "UTC", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_set_timezone(db, 0, NULL, 3u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_set_timezone(db, 780, "Pacific/Auckland", 16u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_set_timezone(db, 0, "UTC", 3u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_set_timezone(db, 0, "", 0u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_set_slow_query_ms(NULL, 10u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_set_slow_query_ms(db, 50u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_db_telemetry(NULL, &stats));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_db_telemetry(db, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_db_telemetry(db, &stats));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_escape_string(NULL, "a", 1u, buf, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_escape_string(db, "a", 1u, buf, 16u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_escape_string(db, "a", 1u, NULL, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_escape_string(db, "a", 1u, NULL, 0u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_escape_string(db, NULL, 2u, buf, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_escape_string(db, "O'Brien  ", 9u, buf, 32u, &out_len));
  ASSERT_EQ(8u, out_len);

  /* Transactions & savepoints */
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_tx_begin(NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_tx_commit(NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_tx_rollback(NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_tx_savepoint(NULL, "s", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_tx_release_sp(NULL, "s", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_tx_rollback_sp(NULL, "s", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_tx_savepoint(db, NULL, 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_tx_release_sp(db, NULL, 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_tx_rollback_sp(db, NULL, 2u));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_tx_begin(db));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_tx_savepoint(db, "sp1 ", 4u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_tx_rollback_sp(db, "sp1 ", 4u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_tx_release_sp(db, "sp1 ", 4u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_tx_commit(db));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_tx_begin(db));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_tx_rollback(db));

  /* Connection pool */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_pool_init(":memory:", 8u, 1, 2, 10, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_pool_init(":memory:", 8u, -1, 2, 10, &pool));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_pool_init(":memory:", 8u, 0, 0, 10, &pool));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_pool_init(":memory:", 8u, 3, 2, 10, &pool));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_pool_init(NULL, 8u, 0, 1, 10, &pool));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_pool_init("bad://url", 9u, 1, 1, 10, &pool));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_pool_init(":memory:", 8u, 1, 1, 1, &pool));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_pool_acquire(NULL, &leased));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_pool_acquire(pool, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_acquire(pool, &leased));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_pool_acquire(pool, &leased2));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_set_timezone(leased, 60, "CET", 3u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_pool_release(NULL, leased));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_pool_release(pool, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION, fortran_orm_pool_release(pool, db));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_release(pool, leased));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_acquire(pool, &leased));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_release(pool, leased));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_acquire(pool, &leased));
  /* Disconnect on a pooled wrapper skips raw disconnect cleanly */
  ASSERT_EQ(C_ORM_OK, c_orm_pool_release(pool->pool, leased->db));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(leased));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_pool_telemetry(NULL, &stats));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_pool_telemetry(pool, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_telemetry(pool, &stats));
  memset(&bad_pool, 0, sizeof(bad_pool));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_pool_destroy(NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_pool_destroy(&bad_pool));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_destroy(pool));

  /* Horizontal sharding */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_shard_init(2u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION, fortran_orm_shard_init(0u, &shard));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_shard_init(2u, &shard));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_connect_cstr(":memory:", &db2));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_shard_add_node(NULL, 1u, db));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_shard_add_node(shard, 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_shard_add_node(shard, 0u, db));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_shard_add_node(shard, 3u, db));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_shard_route(shard, "user_1", 6u, &sidx));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_shard_add_node(shard, 1u, db));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_shard_add_node(shard, 2u, db2));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_shard_route(NULL, "k", 1u, &sidx));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_shard_route(shard, "k", 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_shard_route(shard, NULL, 2u, &sidx));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_shard_route(shard, "k1", 2u, &sidx));
  ASSERT(sidx == 1u || sidx == 2u);

  shard->nodes[0] = NULL;
  shard->nodes[1] = NULL;
  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_shard_route(shard, "k1", 2u, &sidx));
  memset(&bad_shard, 0, sizeof(bad_shard));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_shard_free(NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_shard_free(&bad_shard));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_shard_free(shard));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_set_timezone(db2, 60, "CET", 3u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db2));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db));
  PASS();
}

#endif /* TEST_STR_DB_POOL_TX_H */
