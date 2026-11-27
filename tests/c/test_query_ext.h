/**
 * @file test_query_ext.h
 * @brief Unit tests for `fortran_orm_query.c` (dynamic abstract rows & fluent
 * AST) and `fortran_orm_ext.c` (migrations, 38-digit decimal, EBCDIC/UTF-16,
 * Db2/ODBC helpers, UUID v4, OAuth2).
 */

#ifndef TEST_QUERY_EXT_H
/** @brief Header guard for test_query_ext.h. */
#define TEST_QUERY_EXT_H

/**
 * @brief Tests dynamic `cdd_c_abstract_struct_array_t` result sets and fluent
 * AST builder across all 5 dialects (`fortran_orm_query.c`).
 */
TEST test_abstract_rs_and_ast(void) {
  fortran_orm_db_t *db = NULL;
  fortran_orm_rs_t *rs = NULL;
  fortran_orm_ast_t *ast = NULL;
  fortran_orm_u32_t rows = 0u;
  fortran_orm_u32_t cols = 0u;
  fortran_orm_u32_t out_len = 0u;
  fortran_orm_u32_t pcnt = 0u;
  fortran_orm_i32_t is_null = 0;
  fortran_orm_i64_t iv = 0;
  double dv = 0.0;
  char sbuf[512];
  int d;

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_connect_cstr(":memory:", &db));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(
                db, "CREATE TABLE q(id INT, w REAL, nm TEXT, nl INT);"));
  ASSERT_EQ(
      FORTRAN_ORM_OK,
      fortran_orm_exec_cstr(db, "INSERT INTO q VALUES(7, 3.5, 'ADA', NULL);"));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_query_abstract(NULL, "SELECT * FROM q", 15u, &rs));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_query_abstract(db, "SELECT * FROM q", 15u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_query_abstract(db, NULL, 15u, &rs));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_query_abstract(db, "BAD SQL", 7u, &rs));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_query_abstract(db, "SELECT * FROM q", 15u, &rs));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_rs_row_count(NULL, &rows));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_rs_row_count(rs, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_row_count(rs, &rows));
  ASSERT_EQ(1u, rows);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_rs_col_count(NULL, 1u, &cols));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_rs_col_count(rs, 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_col_count(rs, 0u, &cols));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_col_count(rs, 99u, &cols));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_col_count(rs, 1u, &cols));
  ASSERT_EQ(4u, cols);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_rs_col_name(NULL, 1u, 1u, sbuf, 32u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_col_name(rs, 0u, 1u, sbuf, 32u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_col_name(rs, 99u, 1u, sbuf, 32u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_col_name(rs, 1u, 0u, sbuf, 32u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_col_name(rs, 1u, 99u, sbuf, 32u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_rs_col_name(rs, 1u, 1u, sbuf, 32u, &out_len));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_rs_is_null(rs, 1u, "nl", 2u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_rs_is_null(NULL, 1u, "nl", 2u, &is_null));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_is_null(rs, 0u, "nl", 2u, &is_null));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_INDEX,
            fortran_orm_rs_is_null(rs, 99u, "nl", 2u, &is_null));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_rs_is_null(rs, 1u, NULL, 2u, &is_null));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_rs_is_null(rs, 1u, "missing", 7u, &is_null));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_is_null(rs, 1u, "nl", 2u, &is_null));
  ASSERT_EQ(1, is_null);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_is_null(rs, 1u, "id", 2u, &is_null));
  ASSERT_EQ(0, is_null);

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_rs_get_i64(rs, 1u, "id", 2u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_rs_get_i64(rs, 1u, "missing", 7u, &iv));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_get_i64(rs, 1u, "id", 2u, &iv));
  ASSERT_EQ(7, (int)iv);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_get_i64(rs, 1u, "w", 1u, &iv));
  ASSERT_EQ(3, (int)iv);
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_rs_get_i64(rs, 1u, "nm", 2u, &iv));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_rs_get_f64(rs, 1u, "w", 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_rs_get_f64(rs, 1u, "missing", 7u, &dv));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_get_f64(rs, 1u, "w", 1u, &dv));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_get_f64(rs, 1u, "id", 2u, &dv));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_rs_get_f64(rs, 1u, "nm", 2u, &dv));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_rs_get_str(rs, 1u, "missing", 7u, sbuf, 32u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_rs_get_str(rs, 1u, "nm", 2u, sbuf, 32u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_rs_get_str(rs, 1u, "id", 2u, sbuf, 32u, &out_len));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_rs_to_json(NULL, sbuf, 256u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_rs_to_json(rs, sbuf, 256u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_rs_to_json(rs, NULL, 256u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_rs_to_json(rs, NULL, 0u, &out_len));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_to_json(rs, sbuf, 256u, &out_len));
  {
    fortran_orm_rs_t bad_rs;
    memset(&bad_rs, 0, sizeof(bad_rs));
    ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_rs_free(&bad_rs));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_rs_free(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_free(rs));

  /* Fluent AST: SELECT, JOIN, WHERE, GROUP/HAVING, ORDER/LIMIT, LOCK, DIALECTS
   */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_select("q", 1u, "*", 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_select(NULL, 1u, "*", 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_select("q", 1u, NULL, 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_select("q", 1u, NULL, 0u, &ast));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_select("q --", 4u, "*", 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 1));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 2));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_ast_query_rs(db, ast, &rs));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_select("q\0 ", 3u, "   ", 3u, &ast));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_ast_distinct(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_distinct(ast));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_where_i64(NULL, "id", 2u, "=", 1u, 7));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_where_i64(ast, NULL, 2u, "=", 1u, 7));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_where_i64(ast, "id", 2u, NULL, 1u, 7));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 7));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "!=", 2u, 0));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "<>", 2u, 0));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, ">", 1u, -5));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "<", 1u, 100));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, ">=", 2u, 1));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_where_str(NULL, "nm", 2u, "=", 1u, "ADA", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_where_str(ast, NULL, 2u, "=", 1u, "ADA", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_where_str(ast, "nm", 2u, NULL, 1u, "ADA", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_where_str(ast, "nm", 2u, "=", 1u, NULL, 3u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_str(ast, "nm", 2u, "LIKE", 4u, "A%", 2u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_str(ast, "nm", 2u, ">=", 2u, "A", 1u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_order_limit(NULL, "id", 2u, 1, 5u, 0u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_order_limit(ast, NULL, 2u, 1, 5u, 0u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_order_limit(ast, "  ", 2u, 0, 0u, 0u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_order_limit(ast, "id", 2u, 1, 5u, 0u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_query_rs(NULL, ast, &rs));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_query_rs(db, NULL, &rs));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_query_rs(db, ast, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_query_rs(db, ast, &rs));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_row_count(rs, &rows));
  ASSERT_EQ(1u, rows);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_free(rs));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_join(ast, "LEFT", 4u, "q", 1u, "1=1", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_join(NULL, "LEFT", 4u, "q", 1u, "1=1", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_join(ast, NULL, 4u, "q", 1u, "1=1", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_join(ast, "LEFT", 4u, NULL, 1u, "1=1", 3u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_join(ast, "LEFT", 4u, "q", 1u, NULL, 3u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_group_having(NULL, "id", 2u, "", 0u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_group_having(ast, NULL, 2u, "", 0u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_group_having(ast, "id", 2u, "", 0u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_group_having(ast, "id", 2u, NULL, 2u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_group_having(ast, "id", 2u, "  ", 2u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_group_having(ast, "id", 2u, "COUNT(*)>0", 10u));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_order_limit(ast, "id", 2u, 0, 5u, 1u));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_returning_lock(NULL, "id", 2u, 0));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_ast_returning_lock(ast, "id", 2u, -1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_ast_returning_lock(ast, "id", 2u, 6));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_returning_lock(ast, NULL, 2u, 0));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_returning_lock(ast, "  ", 2u, 0));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_returning_lock(ast, "", 0u, 1));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_returning_lock(ast, "id", 2u, 1));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_to_sql(NULL, FORTRAN_ORM_DIALECT_SQLITE, sbuf, 512u,
                                   &out_len, &pcnt));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_to_sql(ast, FORTRAN_ORM_DIALECT_SQLITE, sbuf, 512u,
                                   NULL, &pcnt));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_to_sql(ast, FORTRAN_ORM_DIALECT_SQLITE, sbuf, 512u,
                                   &out_len, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_to_sql(ast, FORTRAN_ORM_DIALECT_SQLITE, NULL, 512u,
                                   &out_len, &pcnt));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_ast_to_sql(ast, FORTRAN_ORM_DIALECT_SQLITE, NULL, 0u,
                                   &out_len, &pcnt));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_ast_to_sql(ast, (fortran_orm_dialect_t)-1, sbuf, 512u,
                                   &out_len, &pcnt));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_ast_to_sql(ast, (fortran_orm_dialect_t)99, sbuf, 512u,
                                   &out_len, &pcnt));
  for (d = 0; d <= 4; d++) {
    ASSERT_EQ(FORTRAN_ORM_OK,
              fortran_orm_ast_to_sql(ast, (fortran_orm_dialect_t)d, sbuf, 512u,
                                     &out_len, &pcnt));
  }
  /* AST internal error-state propagation across fluent methods */
  ast->q->error = 1;
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 1));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_where_i64(ast, "id", 2u, "LIKE", 4u, 1));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_join(ast, "LEFT", 4u, "q", 1u, "1=1", 3u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_group_having(ast, "id", 2u, "1=1", 3u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_order_limit(ast, "id", 2u, 1, 5u, 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_order_limit(ast, "", 0u, 0, 5u, 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_order_limit(ast, "", 0u, 0, 0u, 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_ast_set_i64(ast, "id", 2u, 1));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_ast_set_str(ast, "nm", 2u, "X", 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_ast_returning_lock(ast, "id", 2u, 1));
  ast->q->error = 0;
  ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_MEMORY,
            fortran_orm_ast_to_sql(ast, FORTRAN_ORM_DIALECT_SQLITE, sbuf, 512u,
                                   &out_len, &pcnt));
  ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_MEMORY, fortran_orm_ast_query_rs(db, ast, &rs));
  ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));

  {
    fortran_orm_ast_t bad_ast;
    memset(&bad_ast, 0, sizeof(bad_ast));
    ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_ast_free(&bad_ast));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_ast_free(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_select("missing_tbl", 11u, "*", 1u, &ast));
  ast->q->error = 1;
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 1));
  ast->q->error = 0;
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_ast_query_rs(db, ast, &rs));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));

  /* INSERT, UPDATE, DELETE AST execution */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_insert(NULL, 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_insert("q", 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_insert("q", 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_set_i64(NULL, "id", 2u, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_set_i64(ast, NULL, 2u, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_ast_set_str(NULL, "nm", 2u, "GRACE", 5u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_set_str(ast, NULL, 2u, "GRACE", 5u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_set_str(ast, "nm", 2u, NULL, 5u));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_set_i64(ast, "id", 2u, 8));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_set_str(ast, "nm", 2u, "GRACE", 5u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_ast_exec(NULL, ast));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_ast_exec(db, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_exec(db, ast));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_update("q", 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_update(NULL, 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_update("q", 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_set_str(ast, "nm", 2u, "HOPPER", 6u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 8));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_exec(db, ast));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_delete("q", 1u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ast_delete(NULL, 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_delete("q", 1u, &ast));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 8));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_exec(db, ast));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db));
  PASS();
}

/**
 * @brief Tests migrations, 38-digit decimal arithmetic, EBCDIC/UTF-16,
 * Db2/ODBC helpers, UUID v4, and OAuth2 (`fortran_orm_ext.c`).
 */
TEST test_extensions_all(void) {
  fortran_orm_db_t *db = NULL;
  fortran_orm_mig_t *mig = NULL;
  fortran_orm_decimal_t da;
  fortran_orm_decimal_t db_dec;
  fortran_orm_decimal_t dr;
  fortran_orm_i64_t iv64 = 0;
  fortran_orm_i32_t cmp = 0;
  fortran_orm_i32_t valid = 0;
  fortran_orm_u32_t out_n = 0u;
  fortran_orm_u8_t ebcdic[16];
  fortran_orm_u16_t u16[16];
  fortran_orm_oauth2_token_pod_t pod_in;
  fortran_orm_oauth2_token_pod_t pod_out;
  char sbuf[128];
  char mig_dir[128];
  char sql_file[160];
  FILE *fp;

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_connect_cstr(":memory:", &db));

  /* Migrations */
  strcpy(mig_dir, "/tmp/fortran_orm_mig_test");
#if defined(_WIN32)
  _mkdir(mig_dir);
#else
  mkdir(mig_dir, 0700);
#endif
  strcpy(sql_file, mig_dir);
  strcat(sql_file, "/001_create_m.sql");
  fp = fopen(sql_file, "wb");
  ASSERT(fp != NULL);
  fputs("-- UP\nCREATE TABLE mig_tbl(id INT);\n-- DOWN\nDROP TABLE mig_tbl;\n",
        fp);
  fclose(fp);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_mig_init(NULL, mig_dir,
                                 (fortran_orm_u32_t)strlen(mig_dir), &mig));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_mig_init(db, mig_dir,
                                 (fortran_orm_u32_t)strlen(mig_dir), NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_mig_init(db, NULL, 4u, &mig));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_mig_init(db, mig_dir,
                                 (fortran_orm_u32_t)strlen(mig_dir), &mig));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_mig_version(NULL, sbuf, 64u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_version(mig, sbuf, 64u, &out_n));
  ASSERT_EQ(0u, out_n);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_mig_up(NULL, 0, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_mig_up(mig, 0, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_up(mig, 1, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_up(mig, 0, &out_n));
  ASSERT_EQ(1u, out_n);
  {
    int mk;
    for (mk = 1; mk <= 80; mk++) {
      fortran_orm_error_t mrc;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(mk));
      mrc = fortran_orm_mig_up(mig, 1, &out_n);
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (mrc != FORTRAN_ORM_OK) {
        fortran_orm_error_t rrc = fortran_orm_tx_rollback(db);
        ASSERT((int)rrc >= (int)FORTRAN_ORM_OK &&
               (int)rrc <= (int)FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE);
      } else {
        break;
      }
    }
    for (mk = 1; mk <= 80; mk++) {
      fortran_orm_error_t mrc;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(mk));
      mrc = fortran_orm_mig_down(mig, 1u, 1, &out_n);
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (mrc != FORTRAN_ORM_OK) {
        fortran_orm_error_t rrc = fortran_orm_tx_rollback(db);
        ASSERT((int)rrc >= (int)FORTRAN_ORM_OK &&
               (int)rrc <= (int)FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE);
      } else {
        break;
      }
    }
  }
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_version(mig, sbuf, 64u, &out_n));
  ASSERT(out_n > 0u);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_mig_down(NULL, 1u, 0, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_mig_down(mig, 1u, 0, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_down(mig, 1u, 1, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_down(mig, 1u, 0, &out_n));
  ASSERT_EQ(0u, out_n);

  /* Bad UP and DOWN SQL error paths in migrations */
  fp = fopen(sql_file, "wb");
  ASSERT(fp != NULL);
  fputs("-- UP\nBAD UP SQL;\n-- DOWN\nDROP TABLE mig_tbl;\n", fp);
  fclose(fp);
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_mig_up(mig, 0, &out_n));

  fp = fopen(sql_file, "wb");
  ASSERT(fp != NULL);
  fputs("-- UP\nCREATE TABLE mig_tbl2(id INT);\n-- DOWN\nBAD DOWN SQL;\n", fp);
  fclose(fp);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_up(mig, 0, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_mig_down(mig, 1u, 0, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(db, "DROP TABLE _c_orm_migrations;"));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_mig_version(mig, sbuf, 64u, &out_n));

  {
    fortran_orm_mig_t bad_mig;
    memset(&bad_mig, 0, sizeof(bad_mig));
    ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_mig_free(&bad_mig));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, fortran_orm_mig_free(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_free(mig));
  remove(sql_file);
  rmdir(mig_dir);

  /* 38-digit Decimal */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_from_str("1.0", 3u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_from_str(NULL, 3u, &da));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_dec_from_str("not_num", 7u, &da));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_dec_from_str("99999999999999999999999999999999999999",
                                     38u, &da));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_dec_from_i64((fortran_orm_i64_t)5, &db_dec));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_dec_add(&da, &db_dec, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_DECIMAL_OVERFLOW,
      fortran_orm_dec_mul(&da, &db_dec, 0u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_dec_from_str("-99999999999999999999999999999999999999",
                                     39u, &da));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_dec_sub(&da, &db_dec, &dr));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_dec_from_str("  12.50  ", 9u, &da));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_to_str(NULL, sbuf, 64u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_dec_to_str(&da, sbuf, 64u, &out_n));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_from_i64((fortran_orm_i64_t)5, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_dec_from_i64((fortran_orm_i64_t)5, &db_dec));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_to_i64(NULL, FORTRAN_ORM_ROUND_HALF_UP, &iv64));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_to_i64(&da, FORTRAN_ORM_ROUND_HALF_UP, NULL));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_DECIMAL_INEXACT,
      fortran_orm_dec_to_i64(&da, FORTRAN_ORM_ROUND_ERROR_IF_INEXACT, &iv64));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_dec_to_i64(&da, FORTRAN_ORM_ROUND_HALF_UP, &iv64));
  ASSERT_EQ(13, (int)iv64);

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_add(&da, &db_dec, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_add(NULL, &db_dec, &dr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_add(&da, NULL, &dr));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_dec_add(&da, &db_dec, &dr));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_sub(&da, &db_dec, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_sub(NULL, &db_dec, &dr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_sub(&da, NULL, &dr));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_dec_sub(&da, &db_dec, &dr));

  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_mul(&da, &db_dec, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, NULL));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_DECIMAL_OVERFLOW,
      fortran_orm_dec_mul(&da, &db_dec, 39u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_mul(NULL, &db_dec, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_mul(&da, NULL, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_OK,
      fortran_orm_dec_mul(&da, &db_dec, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));

  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_div(&da, &db_dec, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, NULL));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_DECIMAL_OVERFLOW,
      fortran_orm_dec_div(&da, &db_dec, 39u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_div(NULL, &db_dec, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_div(&da, NULL, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_OK,
      fortran_orm_dec_div(&da, &db_dec, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_dec_from_i64((fortran_orm_i64_t)0, &db_dec));
  ASSERT_NEQ(
      FORTRAN_ORM_OK,
      fortran_orm_dec_div(&da, &db_dec, 4u, FORTRAN_ORM_ROUND_HALF_EVEN, &dr));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_cmp(&da, &db_dec, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_cmp(NULL, &db_dec, &cmp));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_dec_cmp(&da, NULL, &cmp));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_dec_cmp(&da, &db_dec, &cmp));
  ASSERT_EQ(1, cmp);

  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_rescale(&da, 10u, 1u, FORTRAN_ORM_ROUND_TRUNCATE, NULL));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_VALIDATION,
      fortran_orm_dec_rescale(&da, 0u, 0u, FORTRAN_ORM_ROUND_TRUNCATE, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_VALIDATION,
      fortran_orm_dec_rescale(&da, 39u, 1u, FORTRAN_ORM_ROUND_TRUNCATE, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_VALIDATION,
      fortran_orm_dec_rescale(&da, 4u, 5u, FORTRAN_ORM_ROUND_TRUNCATE, &dr));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_NULL_POINTER,
      fortran_orm_dec_rescale(NULL, 10u, 1u, FORTRAN_ORM_ROUND_TRUNCATE, &dr));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_dec_rescale(
                                &da, 10u, 1u, FORTRAN_ORM_ROUND_TRUNCATE, &dr));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_dec_rescale(
                                 &da, 1u, 0u, FORTRAN_ORM_ROUND_TRUNCATE, &dr));

  /* EBCDIC & UTF-16 */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf8_to_ebcdic(FORTRAN_ORM_CP_IBM037, "IBM", 3u, ebcdic,
                                       16u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf8_to_ebcdic(FORTRAN_ORM_CP_IBM037, "IBM", 3u, NULL,
                                       16u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_utf8_to_ebcdic(FORTRAN_ORM_CP_IBM037, "", 0u, NULL, 0u,
                                       &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf8_to_ebcdic(FORTRAN_ORM_CP_IBM037, NULL, 3u, ebcdic,
                                       16u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_utf8_to_ebcdic((fortran_orm_codepage_t)99, "IBM", 3u,
                                        ebcdic, 16u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_utf8_to_ebcdic(FORTRAN_ORM_CP_IBM037, "IBM", 3u, ebcdic,
                                       16u, &out_n));
  ASSERT_EQ(3u, out_n);

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, ebcdic, 3u, sbuf,
                                       16u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, NULL, 3u, sbuf,
                                       16u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, ebcdic, 3u, NULL,
                                       16u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, NULL, 0u, NULL,
                                       0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, ebcdic, 3u, NULL,
                                       0u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_ebcdic_to_utf8((fortran_orm_codepage_t)99, ebcdic, 3u,
                                        sbuf, 16u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, ebcdic, 3u, sbuf,
                                       16u, &out_n));
  ASSERT_EQ(3u, out_n);

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf8_to_utf16("ZOS", 3u, 1, u16, 16u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf8_to_utf16("ZOS", 3u, 1, NULL, 16u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_utf8_to_utf16("", 0u, 1, NULL, 0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf8_to_utf16(NULL, 3u, 1, u16, 16u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_utf8_to_utf16("ZOS", 3u, 0, u16, 1u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_utf8_to_utf16("ZOS", 3u, 1, u16, 16u, &out_n));
  ASSERT_EQ(3u, out_n);

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf16_to_utf8(u16, 3u, 1, sbuf, 16u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf16_to_utf8(NULL, 3u, 1, sbuf, 16u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_utf16_to_utf8(u16, 3u, 1, NULL, 16u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_utf16_to_utf8(NULL, 0u, 1, NULL, 0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_utf16_to_utf8(u16, 3u, 1, NULL, 0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_utf16_to_utf8(u16, 3u, 1, sbuf, 16u, &out_n));
  ASSERT_EQ(3u, out_n);
  u16[0] = 0xD800u; /* lone surrogate error */
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_utf16_to_utf8(u16, 1u, 0, sbuf, 16u, &out_n));

  /* ODBC / Db2 helpers */
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_odbc_sqlstate(NULL, sbuf, 8u, &out_n));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_odbc_sqlstate(db, sbuf, 8u, &out_n));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_set_isolation(NULL, FORTRAN_ORM_ISO_CS));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_set_isolation(db, (fortran_orm_isolation_t)-1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            fortran_orm_set_isolation(db, (fortran_orm_isolation_t)99));
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_set_isolation(db, FORTRAN_ORM_ISO_CS));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_db2_configure(NULL, "u", 1u, "a", 1u, "s", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_db2_configure(db, NULL, 1u, "a", 1u, "s", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_db2_configure(db, "u", 1u, NULL, 1u, "s", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_db2_configure(db, "", 0u, NULL, 1u, "s", 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_db2_configure(db, "u", 1u, "a", 1u, NULL, 1u));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_db2_configure(db, "", 0u, "", 0u, NULL, 1u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_db2_configure(db, "", 0u, "", 0u, "", 0u));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_db2_configure(db, "", 0u, "", 0u, "   ", 3u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_db2_configure(db, "", 0u, "a", 1u, "", 0u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_db2_configure(db, "u", 1u, "a", 1u, "s", 1u));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_db2_configure(db, "", 0u, "", 0u, "SYSIBM", 6u));

  /* UUID & OAuth2 */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_uuid_v4(sbuf, 40u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_uuid_v4(NULL, 40u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_ERROR_TRUNCATION,
            fortran_orm_uuid_v4(NULL, 0u, &out_n));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_uuid_v4(sbuf, 40u, &out_n));
  ASSERT_EQ(36u, out_n);

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_oauth2_init_tables(NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_oauth2_init_tables(db));

  memset(&pod_in, ' ', sizeof(pod_in));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_oauth2_save_token(NULL, &pod_in));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_oauth2_save_token(db, NULL));
  memcpy(pod_in.access_token, "tok_abc", 7u);
  /* Leave refresh_token all spaces to test trimming to len == 0 */
  memset(pod_in.token_type, 'B', sizeof(pod_in.token_type));
  pod_in.expires_in = 3600;
  pod_in.created_at = (fortran_orm_i64_t)time(NULL);
  strcpy(pod_in.user_id, "u42");
  strcpy(pod_in.scopes, "read write");
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_oauth2_save_token(db, &pod_in));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(
                db, "UPDATE tokens SET refresh_token = NULL, token_type = "
                    "'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
                    "BBBBBBBBBBBB';"));

  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_oauth2_get_token(NULL, "tok_abc", 7u, &pod_out));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_oauth2_get_token(db, "tok_abc", 7u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_oauth2_get_token(db, NULL, 7u, &pod_out));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NOT_FOUND,
            fortran_orm_oauth2_get_token(db, "missing", 7u, &pod_out));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_oauth2_get_token(db, "tok_abc  ", 9u, &pod_out));
  ASSERT_STR_EQ("u42", pod_out.user_id);

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_oauth2_revoke_or_check(db, "tok_abc", 7u, 0, "read", 4u,
                                               "read", 4u, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_oauth2_revoke_or_check(NULL, "tok_abc", 7u, 1, "read",
                                               4u, "read", 4u, &valid));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_oauth2_revoke_or_check(db, NULL, 7u, 1, "read", 4u,
                                               "read", 4u, &valid));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_oauth2_revoke_or_check(db, "tok_abc", 7u, 0, NULL, 4u,
                                               "read", 4u, &valid));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_oauth2_revoke_or_check(db, "tok_abc", 7u, 0, "read", 4u,
                                               NULL, 4u, &valid));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_oauth2_revoke_or_check(NULL, "", 0u, 0, "read write",
                                               10u, "read", 4u, &valid));
  ASSERT_EQ(1, valid);
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_oauth2_revoke_or_check(db, "tok_abc", 7u, 1, "read", 4u,
                                               "admin", 5u, &valid));
  ASSERT_EQ(0, valid);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_exec_cstr(db, "DROP TABLE tokens;"));
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_oauth2_revoke_or_check(db, "tok_abc", 7u, 1, "read",
                                                4u, "read", 4u, &valid));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db));
  PASS();
}

#endif /* TEST_QUERY_EXT_H */
