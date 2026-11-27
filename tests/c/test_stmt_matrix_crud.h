/**
 * @file test_stmt_matrix_crud.h
 * @brief Unit tests for `fortran_orm_stmt.c`, `fortran_orm_matrix.c`, and
 * `fortran_orm_crud.c`.
 */

#ifndef TEST_STMT_MATRIX_CRUD_H
/** @brief Header guard for test_stmt_matrix_crud.h. */
#define TEST_STMT_MATRIX_CRUD_H

/**
 * @brief Sample BIND(C) record layout for runtime struct reflection tests.
 */
typedef struct test_item_pod {
  /** @brief Primary key. */
  fortran_orm_i32_t id;
  /** @brief Optimistic lock version. */
  fortran_orm_i32_t version;
  /** @brief Floating-point price. */
  double price;
  /** @brief Fixed-width character tag. */
  char tag[8];
} test_item_pod_t;

/**
 * @brief Tests all prepared statement binds, steps, and 1-based column readers
 * (`fortran_orm_stmt.c`).
 */
TEST test_stmt_all_types(void) {
  fortran_orm_db_t *db = NULL;
  fortran_orm_stmt_t *st = NULL;
  fortran_orm_decimal_t dec_in;
  fortran_orm_decimal_t dec_out;
  fortran_orm_u8_t blob_in[3] = {0xAAu, 0xBBu, 0xCCu};
  fortran_orm_u8_t blob_out[4];
  fortran_orm_i32_t has_row = 0;
  fortran_orm_i32_t ncols = 0;
  fortran_orm_i32_t is_null = 0;
  fortran_orm_i32_t iv32 = 0;
  fortran_orm_i64_t iv64 = 0;
  float fv32 = 0.0f;
  double fv64 = 0.0;
  fortran_orm_i32_t lflag = 0;
  fortran_orm_u32_t out_len = 0u;
  char sbuf[32];

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_connect_cstr(":memory:", &db));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_enable_stmt_cache(db, 4u));
  ASSERT_EQ(
      FORTRAN_ORM_OK,
      fortran_orm_exec_cstr(
          db, "CREATE TABLE st(i32 INT UNIQUE, i64 INT, f32 REAL, f64 REAL, "
              "lg INT, s1 TEXT, s2 TEXT, b1 BLOB, b2 BLOB, dc TEXT, nl INT);"));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_prepare(NULL, "SELECT 1", 8u, &st));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_prepare(db, "SELECT 1", 8u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_prepare(db, NULL, 8u, &st));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_stmt_prepare(db, "SELECT * FROM nope", 18u, &st));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_prepare_cached(
                db, "INSERT INTO st VALUES(?,?,?,?,?,?,?,?,?,?,?)", 44u, &st));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_dec_from_str("42.75", 5u, &dec_in));

  /* Invalid handle & index checks on binds */
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_bind_i32(NULL, 1, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_bind_i32(st, 0, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_bind_i64(NULL, 1, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_bind_i64(st, 0, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_bind_f64(NULL, 1, 1.0));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_bind_f64(st, 0, 1.0));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_bind_str(NULL, 1, "a", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_bind_str(st, 0, "a", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_bind_str(st, 1, NULL, 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_bind_blob(NULL, 1, blob_in, 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_bind_blob(st, 0, blob_in, 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_bind_blob(st, 8, NULL, 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_bind_decimal(NULL, 1, &dec_in));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_bind_decimal(st, 0, &dec_in));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_bind_decimal(st, 10, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_bind_null(NULL, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX, fortran_orm_stmt_bind_null(st, 0));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_i32(st, 1, 101));
  ASSERT_EQ(
      FORTRAN_ORM_OK,
      fortran_orm_stmt_bind_i64(
          st, 2, ((fortran_orm_i64_t)9000000 * (fortran_orm_i64_t)1000) + 1));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_f32(st, 3, 1.5f));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_f64(st, 4, 2.25));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_logical(st, 5, 1));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_str(st, 6, "TRIM  ", 6u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_str_raw(st, 7, "RAW ", 4u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_blob(st, 8, blob_in, 3u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_blob(st, 9, NULL, 0u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_decimal(st, 10, &dec_in));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_null(st, 11));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_step(NULL, &has_row));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_stmt_step(st, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_step(st, &has_row));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_stmt_reset(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_reset(st));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_i32(st, 1, 101));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_bind_logical(st, 5, 0));
  /* Duplicate UNIQUE i32 = 101 exercises step error path */
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_stmt_step(st, &has_row));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_stmt_finalize(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_finalize(st));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_prepare(db, "SELECT * FROM st", 16u, &st));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_step(st, &has_row));
  ASSERT_EQ(1, has_row);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_col_count(NULL, &ncols));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_count(st, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_count(st, &ncols));
  ASSERT_EQ(11, ncols);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_stmt_col_name(NULL, 1, sbuf, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_name(st, 0, sbuf, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_name(st, 99, sbuf, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_col_name(st, 1, sbuf, 16u, &out_len));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_is_null(st, 0, &is_null));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_is_null(st, 1, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_is_null(st, 1, &is_null));
  ASSERT_EQ(0, is_null);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_is_null(st, 11, &is_null));
  ASSERT_EQ(1, is_null);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_i32(st, 0, &iv32));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_i32(st, 1, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_i32(st, 1, &iv32));
  ASSERT_EQ(101, iv32);
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_stmt_col_i32(st, 6, &iv32));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_i64(st, 0, &iv64));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_i64(st, 2, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_i64(st, 2, &iv64));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_stmt_col_i64(st, 6, &iv64));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_f32(st, 3, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_f32(st, 0, &fv32));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_f32(st, 3, &fv32));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_stmt_col_f32(st, 6, &fv32));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_f64(st, 0, &fv64));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_f64(st, 4, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_f64(st, 4, &fv64));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_logical(st, 5, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_logical(st, 0, &lflag));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_logical(st, 5, &lflag));
  ASSERT_EQ(1, lflag);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_logical(st, 11, &lflag));
  ASSERT_EQ(0, lflag);
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_stmt_col_logical(st, 6, &lflag));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_str(st, 0, sbuf, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_stmt_col_str(st, 1, sbuf, 16u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_col_str(st, 6, sbuf, 16u, &out_len));
  ASSERT_EQ(4u, out_len);
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_col_str(st, 7, sbuf, 16u, &out_len));
  ASSERT_EQ(4u, out_len);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_blob(st, 0, blob_out, 4u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_blob(st, 8, blob_out, 4u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_blob(st, 8, NULL, 4u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_stmt_col_blob(st, 8, NULL, 0u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_stmt_col_blob(st, 1, blob_out, 4u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_col_blob(st, 8, blob_out, 4u, &out_len));
  ASSERT_EQ(3u, out_len);
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_stmt_col_blob(st, 8, blob_out, 2u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_col_blob(st, 9, blob_out, 4u, &out_len));
  ASSERT_EQ(0u, out_len);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_stmt_col_decimal(st, 0, &dec_out));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_stmt_col_decimal(st, 10, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_decimal(st, 10, &dec_out));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_stmt_col_decimal(st, 6, &dec_out));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_finalize(st));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db));
  PASS();
}

/**
 * @brief Tests 1D vectors, 2D column-major matrices (`fortran_orm_matrix.c`),
 * and runtime struct reflection CRUD (`fortran_orm_crud.c`).
 */
TEST test_matrix_and_crud(void) {
  fortran_orm_db_t *db = NULL;
  fortran_orm_schema_t *sc = NULL;
  fortran_orm_schema_t *sc_nopk = NULL;
  fortran_orm_schema_t *sc_pko = NULL;
  fortran_orm_schema_t *sc_many = NULL;
  fortran_orm_i32_t vi32[2] = {10, 20};
  fortran_orm_i32_t vo32[2];
  fortran_orm_i64_t vi64[2] = {(fortran_orm_i64_t)100, (fortran_orm_i64_t)200};
  fortran_orm_i64_t vo64[2];
  double vf64[2] = {1.5, 2.5};
  double vo_f64[2];
  double mat_in[6] = {1.0, 2.0, 99.0, 3.0, 4.0, 99.0}; /* ld=3, 2x2 */
  double mat_out[6];
  fortran_orm_u32_t out_n = 0u;
  fortran_orm_i32_t ex = 0;
  test_item_pod_t rec1;
  test_item_pod_t rec2;
  test_item_pod_t arr[2];
  char ddl_buf[256];
  char cname[16];
  int k;

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_connect_cstr(":memory:", &db));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(db, "CREATE TABLE v(x UNIQUE);"));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_exec_cstr(
                                db, "CREATE TABLE m(a REAL UNIQUE, b REAL);"));

  /* Vector error & success paths */
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_insert_vec_i32(NULL, "INSERT INTO v VALUES(?)", 23u,
                                       vi32, 2u));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_insert_vec_i32(db, "INSERT INTO v VALUES(?)", 23u, NULL, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_i32(
                                db, "INSERT INTO v VALUES(?)", 23u, NULL, 0u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_vec_i32(db, "BAD", 3u, vi32, 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_vec_i32(db, "SELECT 1", 8u, vi32, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_i32(
                                db, "INSERT INTO v VALUES(?)", 23u, vi32, 2u));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_i32(
                                 db, "INSERT INTO v VALUES(?)", 23u, vi32, 2u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_query_vec_i32(NULL, "SELECT x FROM v", 15u, vo32, 2u,
                                      &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_query_vec_i32(db, "SELECT x FROM v", 15u, vo32, 2u, NULL));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_query_vec_i32(db, "SELECT x FROM v", 15u, NULL, 2u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_vec_i32(db, "BAD", 3u, vo32, 2u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_vec_i32(db, "SELECT abs(-9223372036854775808)",
                                       32u, vo32, 2u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_TYPE_MISMATCH,
      fortran_orm_query_vec_i32(db, "SELECT 'txt'", 12u, vo32, 2u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
      fortran_orm_query_vec_i32(db, "SELECT x FROM v", 15u, NULL, 0u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
      fortran_orm_query_vec_i32(db, "SELECT x FROM v", 15u, vo32, 1u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_query_vec_i32(db, "SELECT x FROM v",
                                                      15u, vo32, 2u, &out_n));
  ASSERT_EQ(2u, out_n);

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_exec_cstr(db, "DELETE FROM v;"));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_insert_vec_i64(NULL, "INSERT INTO v VALUES(?)", 23u,
                                       vi64, 2u));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_insert_vec_i64(db, "INSERT INTO v VALUES(?)", 23u, NULL, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_i64(
                                db, "INSERT INTO v VALUES(?)", 23u, NULL, 0u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_vec_i64(db, "BAD", 3u, vi64, 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_vec_i64(db, "SELECT 1", 8u, vi64, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_i64(
                                db, "INSERT INTO v VALUES(?)", 23u, vi64, 2u));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_i64(
                                 db, "INSERT INTO v VALUES(?)", 23u, vi64, 2u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_query_vec_i64(NULL, "SELECT x FROM v", 15u, vo64, 2u,
                                      &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_query_vec_i64(db, "SELECT x FROM v", 15u, vo64, 2u, NULL));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_query_vec_i64(db, "SELECT x FROM v", 15u, NULL, 2u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
      fortran_orm_query_vec_i64(db, "SELECT x FROM v", 15u, NULL, 0u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_vec_i64(db, "BAD", 3u, vo64, 2u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_vec_i64(db, "SELECT abs(-9223372036854775808)",
                                       32u, vo64, 2u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_TYPE_MISMATCH,
      fortran_orm_query_vec_i64(db, "SELECT 'txt'", 12u, vo64, 2u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
      fortran_orm_query_vec_i64(db, "SELECT x FROM v", 15u, vo64, 1u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_query_vec_i64(db, "SELECT x FROM v",
                                                      15u, vo64, 2u, &out_n));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_exec_cstr(db, "DELETE FROM v;"));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_insert_vec_f64(NULL, "INSERT INTO v VALUES(?)", 23u,
                                       vf64, 2u));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_insert_vec_f64(db, "INSERT INTO v VALUES(?)", 23u, NULL, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_f64(
                                db, "INSERT INTO v VALUES(?)", 23u, NULL, 0u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_vec_f64(db, "BAD", 3u, vf64, 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_vec_f64(db, "SELECT 1", 8u, vf64, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_f64(
                                db, "INSERT INTO v VALUES(?)", 23u, vf64, 2u));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_insert_vec_f64(
                                 db, "INSERT INTO v VALUES(?)", 23u, vf64, 2u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_query_vec_f64(NULL, "SELECT x FROM v", 15u, vo_f64, 2u,
                                      &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_query_vec_f64(db, "SELECT x FROM v", 15u, vo_f64, 2u, NULL));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_query_vec_f64(db, "SELECT x FROM v", 15u, NULL, 2u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
      fortran_orm_query_vec_f64(db, "SELECT x FROM v", 15u, NULL, 0u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_vec_f64(db, "BAD", 3u, vo_f64, 2u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_vec_f64(db, "SELECT abs(-9223372036854775808)",
                                       32u, vo_f64, 2u, &out_n));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_TYPE_MISMATCH,
      fortran_orm_query_vec_f64(db, "SELECT 'txt'", 12u, vo_f64, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
            fortran_orm_query_vec_f64(db, "SELECT x FROM v", 15u, vo_f64, 1u,
                                      &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_query_vec_f64(db, "SELECT x FROM v",
                                                      15u, vo_f64, 2u, &out_n));

  /* 2D Column-Major Matrix */
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_insert_matrix_f64(NULL, "INSERT INTO m VALUES(?,?)",
                                          25u, mat_in, 3u, 2u, 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_insert_matrix_f64(db, "INSERT INTO m VALUES(?,?)", 25u,
                                          mat_in, 3u, 2u, 0u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_insert_matrix_f64(db, "INSERT INTO m VALUES(?,?)", 25u,
                                          mat_in, 1u, 2u, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_insert_matrix_f64(db, "INSERT INTO m VALUES(?,?)", 25u,
                                          NULL, 3u, 0u, 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_insert_matrix_f64(db, "INSERT INTO m VALUES(?,?)", 25u,
                                          NULL, 3u, 2u, 2u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_matrix_f64(db, "BAD", 3u, mat_in, 3u, 2u, 2u));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_insert_matrix_f64(db, "SELECT 1", 8u,
                                                           mat_in, 3u, 2u, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_insert_matrix_f64(db, "INSERT INTO m VALUES(?,?)", 25u,
                                          mat_in, 3u, 2u, 2u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_insert_matrix_f64(db, "INSERT INTO m VALUES(?,?)", 25u,
                                           mat_in, 3u, 2u, 2u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_query_matrix_f64(NULL, "SELECT a,b FROM m", 17u,
                                         mat_out, 3u, 2u, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_query_matrix_f64(db, "SELECT a,b FROM m", 17u, mat_out,
                                         3u, 2u, 2u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_query_matrix_f64(db, "SELECT a,b FROM m", 17u, NULL, 3u,
                                         2u, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_query_matrix_f64(db, "SELECT a,b FROM m", 17u, mat_out,
                                         3u, 2u, 0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_query_matrix_f64(db, "SELECT a,b FROM m", 17u, mat_out,
                                         1u, 2u, 2u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_query_matrix_f64(
                                 db, "BAD", 3u, mat_out, 3u, 2u, 2u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_query_matrix_f64(
                                 db, "SELECT abs(-9223372036854775808)", 32u,
                                 mat_out, 3u, 2u, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
            fortran_orm_query_matrix_f64(db, "SELECT a,b FROM m", 17u, NULL, 3u,
                                         0u, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
            fortran_orm_query_matrix_f64(db, "SELECT a,b FROM m", 17u, mat_out,
                                         3u, 1u, 2u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_matrix_f64(db, "SELECT a FROM m", 15u, mat_out,
                                          3u, 2u, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_query_matrix_f64(db, "SELECT a,b FROM m", 17u, mat_out,
                                         3u, 2u, 2u, &out_n));
  ASSERT_EQ(2u, out_n);
  ASSERT_EQ(4.0, mat_out[4]);

  /* Runtime Struct Reflection & Model CRUD */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_schema_create("items", 5u, 24u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_create("items", 5u, 0u, &sc));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_create("   ", 3u, 24u, &sc));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_schema_create(NULL, 3u, 24u, &sc));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_create("items", 5u,
                                      (fortran_orm_u32_t)sizeof(rec1), &sc));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_build_ddl(sc, ddl_buf, 128u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_schema_build_ddl(sc, ddl_buf, 128u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_schema_build_ddl(sc, NULL, 128u, &out_n));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_schema_add_col(NULL, "id", 2u, FORTRAN_ORM_COL_INT32,
                                       0u, 0u, 1, 0));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_col(sc, "id", 2u, FORTRAN_ORM_COL_INT32,
                                       999u, 0u, 1, 0));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_col(
                sc, "tag", 3u, FORTRAN_ORM_COL_CHAR_FIXED, 16u, 1u, 0, 0));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_col(
                sc, "tag", 3u, FORTRAN_ORM_COL_CHAR_FIXED, 16u, 99u, 0, 0));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_col(sc, "   ", 3u, FORTRAN_ORM_COL_INT32, 0u,
                                       0u, 1, 0));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_add_col(
                sc, "id", 2u, FORTRAN_ORM_COL_INT32,
                (fortran_orm_u32_t)offsetof(test_item_pod_t, id), 0u, 1, 0));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_add_col(
                sc, "version", 7u, FORTRAN_ORM_COL_INT32,
                (fortran_orm_u32_t)offsetof(test_item_pod_t, version), 0u, 0,
                0));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_add_col(
                sc, "price", 5u, FORTRAN_ORM_COL_FLOAT64,
                (fortran_orm_u32_t)offsetof(test_item_pod_t, price), 0u, 0, 0));
  {
    fortran_orm_schema_t *sc_cf0 = NULL;
    ASSERT_EQ(FORTRAN_ORM_OK,
              fortran_orm_schema_create(
                  "cf0", 3u, (fortran_orm_u32_t)sizeof(rec1), &sc_cf0));
    ASSERT_EQ(FORTRAN_ORM_OK,
              fortran_orm_schema_add_col(
                  sc_cf0, "tag", 3u, FORTRAN_ORM_COL_CHAR_FIXED,
                  (fortran_orm_u32_t)offsetof(test_item_pod_t, tag), 8u, 0, 0));
    ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_schema_free(sc_cf0));
  }
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_add_col(
                sc, "tag", 3u, FORTRAN_ORM_COL_CHAR_FIXED,
                (fortran_orm_u32_t)offsetof(test_item_pod_t, tag), 8u, 0, 1));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_build_ddl(sc, ddl_buf, 256u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_schema_build_ddl(sc, NULL, 0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_create_table(NULL, sc));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_create_table(db, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_create_table(db, sc));

  memset(&rec1, 0, sizeof(rec1));
  rec1.id = 1;
  rec1.version = 1;
  rec1.price = 12.5;
  memcpy(rec1.tag, "        ", 8u);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_insert(NULL, sc, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_insert(db, NULL, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_insert(db, sc, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_insert(db, sc, &rec1));

  rec1.price = 15.0;
  memcpy(rec1.tag, "BETA\0   ", 8u);
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_upsert(NULL, sc, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_upsert(db, NULL, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_upsert(db, sc, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_upsert(db, sc, &rec1));

  rec1.price = 18.0;
  memcpy(rec1.tag, "ABCDEFGH", 8u); /* full 8 non-NUL bytes */
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_update(NULL, sc, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_update(db, NULL, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_update(db, sc, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_update(db, sc, &rec1));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_update_optimistic(NULL, sc, "version", 7u, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_update_optimistic(db, NULL, "version", 7u, &rec1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_update_optimistic(db, sc, "version", 7u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_update_optimistic(db, sc, NULL, 7u, &rec1));
  rec1.version = 2;
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_crud_update_optimistic(db, sc, "version", 7u, &rec1));
  /* Stale version 2 (expects DB version 1, actual 2) fails optimistic check */
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_crud_update_optimistic(db, sc, "version", 7u, &rec1));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_find_i32(NULL, sc, 1, &rec2));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_find_i32(db, sc, 1, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_find_i32(db, NULL, 1, &rec2));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_crud_find_i32(db, sc, 999, &rec2));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_find_i32(db, sc, 1, &rec2));
  ASSERT_EQ(2, rec2.version);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_find_for_update_i32(NULL, sc, 1, &rec2));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_find_for_update_i32(db, sc, 1, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_find_for_update_i32(db, NULL, 1, &rec2));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_crud_find_for_update_i32(db, sc, 1, &rec2));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_crud_find_for_update_i32(db, sc, 999, &rec2));
  db->db->driver_name = "postgres";
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_crud_find_for_update_i32(db, sc, 1, &rec2));
  db->db->driver_name = "sqlite";

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_exists_i32(NULL, sc, 1, &ex));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_exists_i32(db, sc, 1, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_exists_i32(db, NULL, 1, &ex));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_exists_i32(db, sc, 1, &ex));
  ASSERT_EQ(1, ex);

  rec1.id = 2;
  rec1.version = 1;
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_insert(db, sc, &rec1));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_find_all(NULL, sc, arr, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_find_all(db, sc, arr, 2u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_crud_find_all(db, sc, NULL, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
            fortran_orm_crud_find_all(db, sc, NULL, 0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_find_all(db, NULL, arr, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
            fortran_orm_crud_find_all(db, sc, arr, 1u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_find_all(db, sc, arr, 2u, &out_n));
  ASSERT_EQ(2u, out_n);

  ASSERT_EQ(
      FORTRAN_ORM_OK,
      fortran_orm_exec_cstr(
          db, "INSERT INTO items VALUES(99, 1, 'bad_float', 'ABCDEFGH');"));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_crud_find_all(db, sc, arr, 4u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_delete_i32(db, sc, 99));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(
                db, "INSERT INTO items VALUES(99, 1, 1.0, 'ABCDEFGHIJ');"));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_find_i32(db, sc, 99, &rec2));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_delete_i32(db, sc, 99));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_delete_i32(NULL, sc, 2));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_crud_delete_i32(db, NULL, 2));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_crud_delete_i32(db, sc, 2));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_exec_cstr(db, "DROP TABLE items;"));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_crud_exists_i32(db, sc, 1, &ex));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_crud_find_all(db, sc, arr, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(
                db, "CREATE VIEW items AS SELECT abs(-9223372036854775808) AS "
                    "id, 1 AS version, 1.0 AS price, 'A' AS tag;"));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_crud_find_all(db, sc, arr, 2u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_exec_cstr(db, "DROP VIEW items;"));

  /* Schema edge cases: no-PK table, PK-only table, BLOB/STRING cols, relations
   * & cap growth */
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_create("nopk", 4u, 16u, &sc_nopk));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_add_col(sc_nopk, "b", 1u, FORTRAN_ORM_COL_BLOB,
                                       0u, 0u, 0, 1));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_add_col(sc_nopk, "s", 1u, FORTRAN_ORM_COL_STRING,
                                       8u, 0u, 0, 1));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_build_ddl(sc_nopk, ddl_buf, 256u, &out_n));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_schema_create("pko", 3u, 8u, &sc_pko));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_add_col(sc_pko, "id", 2u, FORTRAN_ORM_COL_INT32,
                                       0u, 0u, 1, 0));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_build_ddl(sc_pko, ddl_buf, 256u, &out_n));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_schema_create("many", 4u, 128u, &sc_many));
  for (k = 0; k < 10; k++) {
    cname[0] = 'c';
    cname[1] = (char)('0' + k);
    cname[2] = '\0';
    ASSERT_EQ(FORTRAN_ORM_OK,
              fortran_orm_schema_add_col(
                  sc_many, cname, 2u, FORTRAN_ORM_COL_INT32,
                  (fortran_orm_u32_t)(k * 4), 0u, (k == 0) ? 1 : 0, 0));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_schema_add_relation(NULL, "r", 1u,
                                            FORTRAN_ORM_REL_BELONGS_TO, sc,
                                            "fk", 2u, "id", 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_schema_add_relation(sc_many, "r", 1u,
                                            FORTRAN_ORM_REL_BELONGS_TO, NULL,
                                            "fk", 2u, "id", 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_relation(sc_many, "r", 1u,
                                            (fortran_orm_relation_kind_t)-1, sc,
                                            "fk", 2u, "id", 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_relation(sc_many, "r", 1u,
                                            (fortran_orm_relation_kind_t)99, sc,
                                            "fk", 2u, "id", 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_relation(sc_many, " ", 1u,
                                            FORTRAN_ORM_REL_BELONGS_TO, sc,
                                            "fk", 2u, "id", 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_relation(sc_many, "r", 1u,
                                            FORTRAN_ORM_REL_BELONGS_TO, sc, " ",
                                            1u, "id", 2u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_schema_add_relation(sc_many, "r", 1u,
                                            FORTRAN_ORM_REL_BELONGS_TO, sc,
                                            "fk", 2u, " ", 1u));
  for (k = 0; k < 5; k++) {
    cname[0] = 'r';
    cname[1] = (char)('0' + k);
    cname[2] = '\0';
    ASSERT_EQ(FORTRAN_ORM_OK,
              fortran_orm_schema_add_relation(sc_many, cname, 2u,
                                              FORTRAN_ORM_REL_ONE_TO_MANY, sc,
                                              "id", 2u, "c0", 2u));
  }

  {
    fortran_orm_schema_t bad_sc;
    memset(&bad_sc, 0, sizeof(bad_sc));
    ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
              fortran_orm_schema_free(&bad_sc));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_schema_free(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_schema_free(sc_many));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_schema_free(sc_pko));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_schema_free(sc_nopk));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_schema_free(sc));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db));
  PASS();
}

#endif /* TEST_STMT_MATRIX_CRUD_H */
