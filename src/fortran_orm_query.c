/**
 * @file fortran_orm_query.c
 * @brief Schema-less dynamic result-set hydration (`cdd_c_abstract_struct_t`)
 * and arena-backed SQL AST query builder across SQLite, PostgreSQL, MySQL,
 * IBM Db2, and Generic ODBC dialects.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#include <stdio.h>
#include <string.h>
/* clang-format on */

/**
 * @brief Validates a `fortran_orm_rs_t` handle.
 *
 * @param[in] rs Candidate result-set handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
check_rs(const fortran_orm_rs_t *rs) {
  if (!rs || rs->magic != FORTRAN_ORM_MAGIC_RS) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

/**
 * @brief Validates a `fortran_orm_ast_t` handle.
 *
 * @param[in] ast Candidate AST handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
check_ast(const fortran_orm_ast_t *ast) {
  if (!ast || ast->magic != FORTRAN_ORM_MAGIC_AST) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

/**
 * @brief Looks up a `cdd_c_variant_t` by 1-based `row_idx` and column name.
 *
 * @param[in] rs Result-set handle.
 * @param[in] row_idx 1-based row index.
 * @param[in] col_name Column name buffer.
 * @param[in] name_len Byte length of `col_name`.
 * @param[out] out_var Receives matched variant pointer.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t rs_lookup_var(
    const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx, const char *col_name,
    fortran_orm_u32_t name_len, cdd_c_variant_t **out_var) {
  char *c_col = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_rs(rs);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (row_idx < 1u || (size_t)row_idx > rs->arr.count) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  rc = fortran_orm_slice_to_cstr(col_name, name_len, 1, &c_col);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = cdd_c_abstract_get(&rs->arr.items[row_idx - 1u], c_col, out_var);
  frc = fortran_orm_from_c(c_orm_system_free(c_col));
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(FORTRAN_ORM_ERROR_NOT_FOUND, frc);
  }
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_query_abstract(fortran_orm_db_t *db, const char *sql,
                           fortran_orm_u32_t sql_len,
                           fortran_orm_rs_t **out_rs) {
  char *c_sql = NULL;
  fortran_orm_rs_t *wrap = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_rs) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_rs = NULL;

  rc = fortran_orm_slice_to_cstr(sql, sql_len, 1, &c_sql);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
  if (crc != C_ORM_OK) {
    frc = fortran_orm_from_c(c_orm_system_free(c_sql));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }

  crc = c_orm_find_all_abstract(db->db, c_sql, &wrap->arr);
  frc = fortran_orm_from_c(c_orm_system_free(c_sql));
  if (crc != C_ORM_OK) {
    fortran_orm_error_t fa =
        fortran_orm_from_c(c_orm_abstract_free(&wrap->arr));
    fortran_orm_error_t f2 = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(
        fortran_orm_from_c(crc),
        fortran_orm_keep_err(frc, fortran_orm_keep_err(fa, f2)));
  }

  wrap->magic = FORTRAN_ORM_MAGIC_RS;
  *out_rs = wrap;
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_row_count(const fortran_orm_rs_t *rs,
                         fortran_orm_u32_t *out_rows) {
  fortran_orm_error_t chk = check_rs(rs);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_rows) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_rows = (fortran_orm_u32_t)rs->arr.count;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_col_count(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                         fortran_orm_u32_t *out_cols) {
  fortran_orm_error_t chk = check_rs(rs);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_cols) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (row_idx < 1u || (size_t)row_idx > rs->arr.count) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  *out_cols = (fortran_orm_u32_t)rs->arr.items[row_idx - 1u].count;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_col_name(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                        fortran_orm_u32_t col_idx, char *out_buf,
                        fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len) {
  const cdd_c_abstract_struct_t *row;
  fortran_orm_error_t chk = check_rs(rs);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (row_idx < 1u || (size_t)row_idx > rs->arr.count) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  row = &rs->arr.items[row_idx - 1u];
  if (col_idx < 1u || (size_t)col_idx > row->count) {
    return FORTRAN_ORM_ERROR_INVALID_INDEX;
  }
  return fortran_orm_cstr_to_fbuf(row->kvs[col_idx - 1u].key, out_buf, buf_cap,
                                  out_len);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_is_null(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       fortran_orm_i32_t *out_is_null) {
  cdd_c_variant_t *v = NULL;
  fortran_orm_error_t rc;

  if (!out_is_null) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = rs_lookup_var(rs, row_idx, col_name, name_len, &v);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  *out_is_null = (v->type == CDD_C_VARIANT_TYPE_NULL) ? 1 : 0;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_get_i64(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       fortran_orm_i64_t *out_val) {
  cdd_c_variant_t *v = NULL;
  fortran_orm_error_t rc;

  if (!out_val) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = rs_lookup_var(rs, row_idx, col_name, name_len, &v);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (v->type == CDD_C_VARIANT_TYPE_INT) {
    *out_val = (fortran_orm_i64_t)v->value.i_val;
    return FORTRAN_ORM_OK;
  }
  if (v->type == CDD_C_VARIANT_TYPE_FLOAT) {
    *out_val = (fortran_orm_i64_t)v->value.f_val;
    return FORTRAN_ORM_OK;
  }
  return FORTRAN_ORM_ERROR_TYPE_MISMATCH;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_get_f64(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       double *out_val) {
  cdd_c_variant_t *v = NULL;
  fortran_orm_error_t rc;

  if (!out_val) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = rs_lookup_var(rs, row_idx, col_name, name_len, &v);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (v->type == CDD_C_VARIANT_TYPE_FLOAT) {
    *out_val = v->value.f_val;
    return FORTRAN_ORM_OK;
  }
  if (v->type == CDD_C_VARIANT_TYPE_INT) {
    *out_val = (double)v->value.i_val;
    return FORTRAN_ORM_OK;
  }
  return FORTRAN_ORM_ERROR_TYPE_MISMATCH;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_get_str(const fortran_orm_rs_t *rs, fortran_orm_u32_t row_idx,
                       const char *col_name, fortran_orm_u32_t name_len,
                       char *out_buf, fortran_orm_u32_t buf_cap,
                       fortran_orm_u32_t *out_len) {
  cdd_c_variant_t *v = NULL;
  fortran_orm_error_t rc = rs_lookup_var(rs, row_idx, col_name, name_len, &v);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (v->type != CDD_C_VARIANT_TYPE_STRING) {
    return FORTRAN_ORM_ERROR_TYPE_MISMATCH;
  }
  return fortran_orm_cstr_to_fbuf(v->value.s_val, out_buf, buf_cap, out_len);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_to_json(const fortran_orm_rs_t *rs, char *out_json,
                       fortran_orm_u32_t json_cap, fortran_orm_u32_t *out_len) {
  char *json_str = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_rs(rs);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_len || (json_cap > 0u && !out_json)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = cdd_c_abstract_struct_array_to_json(&rs->arr, &json_str);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  rc = fortran_orm_cstr_to_fbuf(json_str, out_json, json_cap, out_len);
  frc = fortran_orm_from_c(c_orm_system_free(json_str));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_rs_free(fortran_orm_rs_t *rs) {
  c_orm_error_t crc;
  fortran_orm_error_t frc;
  fortran_orm_error_t chk = check_rs(rs);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  rs->magic = 0u;
  crc = c_orm_abstract_free(&rs->arr);
  frc = fortran_orm_from_c(c_orm_system_free(rs));
  return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
}

/**
 * @brief Allocates and initializes a `fortran_orm_ast_t` wrapper.
 *
 * @param[out] user_out Caller output pointer (checked for NULL and zeroed).
 * @param[out] out_ast Receives allocated AST wrapper.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ast_alloc_base(fortran_orm_ast_t **user_out, fortran_orm_ast_t **out_ast) {
  fortran_orm_ast_t *wrap = NULL;
  c_orm_ast_query_t *q = NULL;
  c_orm_error_t crc;

  if (!user_out) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *user_out = NULL;
  *out_ast = NULL;

  crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  crc = c_orm_query_new(&q);
  if (crc != C_ORM_OK) {
    fortran_orm_error_t f1 = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), f1);
  }
  wrap->magic = FORTRAN_ORM_MAGIC_AST;
  wrap->q = q;
  wrap->has_where = 0;
  *out_ast = wrap;
  return FORTRAN_ORM_OK;
}

/**
 * @brief Copies a trimmed Fortran CHARACTER slice directly into `arena` as a
 * NUL-terminated string whose lifetime matches the owning AST query.
 *
 * @param[in,out] arena Owning AST memory arena.
 * @param[in] buf Fortran string slice.
 * @param[in] len Byte length of `buf`.
 * @param[out] out_str Receives arena-allocated C string.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ast_arena_slice(c_orm_arena_t *arena, const char *buf, fortran_orm_u32_t len,
                const char **out_str) {
  fortran_orm_u32_t eff = 0u;
  char *dst = NULL;
  c_orm_error_t crc;

  if (len > 0u && !buf) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  while (eff < len && buf[eff] != '\0') {
    eff++;
  }
  while (eff > 0u && buf[eff - 1u] == ' ') {
    eff--;
  }
  crc = c_orm_arena_alloc(arena, (size_t)eff + 1u, (void **)&dst);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  if (eff > 0u) {
    memcpy(dst, buf, (size_t)eff);
  }
  dst[eff] = '\0';
  *out_str = dst;
  return FORTRAN_ORM_OK;
}

/**
 * @brief Formats a signed 64-bit integer into `arena` as a NUL-terminated ASCII
 * decimal string.
 *
 * @param[in,out] arena Owning AST memory arena.
 * @param[in] val Signed 64-bit value.
 * @param[out] out_str Receives arena-allocated decimal string.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_MEMORY`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t ast_arena_i64(
    c_orm_arena_t *arena, fortran_orm_i64_t val, const char **out_str) {
  char out_buf[32];
  char rev[32];
  size_t r = 0u;
  size_t w = 0u;
  fortran_orm_u64_t uval;

  if (val < 0) {
    out_buf[w++] = '-';
    uval = ((fortran_orm_u64_t)(-(val + 1))) + 1u;
  } else {
    uval = (fortran_orm_u64_t)val;
  }
  if (uval == 0u) {
    rev[r++] = '0';
  } else {
    while (uval > 0u) {
      rev[r++] = (char)('0' + (unsigned int)(uval % 10u));
      uval /= 10u;
    }
  }
  while (r > 0u) {
    out_buf[w++] = rev[--r];
  }
  out_buf[w] = '\0';
  return fortran_orm_from_c(c_orm_arena_strdup(arena, out_buf, out_str));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_select(const char *table, fortran_orm_u32_t table_len,
                       const char *columns, fortran_orm_u32_t cols_len,
                       fortran_orm_ast_t **out_ast) {
  fortran_orm_ast_t *ast = NULL;
  const char *c_tbl = NULL;
  const char *c_cols = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  rc = ast_alloc_base(out_ast, &ast);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, table, table_len, &c_tbl);
  if (rc != FORTRAN_ORM_OK) {
    return fortran_orm_keep_err(rc, fortran_orm_ast_free(ast));
  }
  rc = ast_arena_slice(ast->q->arena, columns, cols_len, &c_cols);
  if (rc != FORTRAN_ORM_OK) {
    return fortran_orm_keep_err(rc, fortran_orm_ast_free(ast));
  }

  crc = ast->q->select_(ast->q, (c_cols[0] != '\0') ? c_cols : "*");
  if (crc == C_ORM_OK) {
    crc = ast->q->from(ast->q, c_tbl);
  }
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_ast_free(ast));
  }
  *out_ast = ast;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_insert(const char *table, fortran_orm_u32_t table_len,
                       fortran_orm_ast_t **out_ast) {
  fortran_orm_ast_t *ast = NULL;
  const char *c_tbl = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  rc = ast_alloc_base(out_ast, &ast);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, table, table_len, &c_tbl);
  if (rc != FORTRAN_ORM_OK) {
    return fortran_orm_keep_err(rc, fortran_orm_ast_free(ast));
  }
  crc = ast->q->insert_into(ast->q, c_tbl);
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_ast_free(ast));
  }
  *out_ast = ast;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_update(const char *table, fortran_orm_u32_t table_len,
                       fortran_orm_ast_t **out_ast) {
  fortran_orm_ast_t *ast = NULL;
  const char *c_tbl = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  rc = ast_alloc_base(out_ast, &ast);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, table, table_len, &c_tbl);
  if (rc != FORTRAN_ORM_OK) {
    return fortran_orm_keep_err(rc, fortran_orm_ast_free(ast));
  }
  crc = ast->q->update_table(ast->q, c_tbl);
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_ast_free(ast));
  }
  *out_ast = ast;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_delete(const char *table, fortran_orm_u32_t table_len,
                       fortran_orm_ast_t **out_ast) {
  fortran_orm_ast_t *ast = NULL;
  const char *c_tbl = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  rc = ast_alloc_base(out_ast, &ast);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, table, table_len, &c_tbl);
  if (rc != FORTRAN_ORM_OK) {
    return fortran_orm_keep_err(rc, fortran_orm_ast_free(ast));
  }
  crc = ast->q->delete_from(ast->q, c_tbl);
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_ast_free(ast));
  }
  *out_ast = ast;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_distinct(fortran_orm_ast_t *ast) {
  fortran_orm_error_t chk = check_ast(ast);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(ast->q->distinct(ast->q));
}

/**
 * @brief Attaches `cond` as `WHERE` or `AND` depending on `ast->has_where`.
 *
 * @param[in,out] ast AST handle.
 * @param[in] cond Condition expression node.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ast_attach_where(fortran_orm_ast_t *ast, c_orm_ast_node_t *cond) {
  c_orm_error_t crc;
  if (!ast->has_where) {
    crc = ast->q->where(ast->q, cond);
    if (crc == C_ORM_OK) {
      ast->has_where = 1;
    }
  } else {
    crc = ast->q->and_where(ast->q, cond);
  }
  return fortran_orm_from_c(crc);
}

/**
 * @brief Builds a binary comparison AST node (`col <op> val_str`).
 *
 * @param[in,out] ast AST handle.
 * @param[in] c_col Arena-owned column name C string.
 * @param[in] c_op Arena-owned operator C string.
 * @param[in] c_val Arena-owned literal value C string.
 * @param[in] is_str Non-zero if literal is string.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ast_where_cmp_impl(fortran_orm_ast_t *ast, const char *c_col, const char *c_op,
                   const char *c_val, int is_str) {
  c_orm_ast_node_t *lhs = NULL;
  c_orm_ast_node_t *rhs = NULL;
  c_orm_ast_node_t *cond = NULL;
  c_orm_error_t crc;

  if (strcmp(c_op, "=") == 0) {
    crc = ast->q->eq(ast->q, c_col, c_val, is_str, &cond);
  } else if (strcmp(c_op, "!=") == 0 || strcmp(c_op, "<>") == 0) {
    crc = ast->q->neq(ast->q, c_col, c_val, is_str, &cond);
  } else if (strcmp(c_op, ">") == 0) {
    crc = ast->q->gt(ast->q, c_col, c_val, is_str, &cond);
  } else if (strcmp(c_op, "<") == 0) {
    crc = ast->q->lt(ast->q, c_col, c_val, is_str, &cond);
  } else if (is_str && strcmp(c_op, "LIKE") == 0) {
    crc = ast->q->like(ast->q, c_col, c_val, &cond);
  } else {
    crc = ast->q->col(ast->q, c_col, &lhs);
    if (crc == C_ORM_OK) {
      crc = ast->q->lit(ast->q, c_val, is_str, &rhs);
    }
    if (crc == C_ORM_OK) {
      crc = ast->q->op(ast->q, c_op, lhs, rhs, &cond);
    }
  }
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return ast_attach_where(ast, cond);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_where_i64(fortran_orm_ast_t *ast, const char *col,
                          fortran_orm_u32_t col_len, const char *op_str,
                          fortran_orm_u32_t op_len, fortran_orm_i64_t val) {
  const char *c_col = NULL;
  const char *c_op = NULL;
  const char *c_num = NULL;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, col, col_len, &c_col);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, op_str, op_len, &c_op);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_i64(ast->q->arena, val, &c_num);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  return ast_where_cmp_impl(ast, c_col, c_op, c_num, 0);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_where_str(fortran_orm_ast_t *ast, const char *col,
                          fortran_orm_u32_t col_len, const char *op_str,
                          fortran_orm_u32_t op_len, const char *val,
                          fortran_orm_u32_t val_len) {
  const char *c_col = NULL;
  const char *c_op = NULL;
  const char *c_val = NULL;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, col, col_len, &c_col);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, op_str, op_len, &c_op);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, val, val_len, &c_val);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  return ast_where_cmp_impl(ast, c_col, c_op, c_val, 1);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_join(fortran_orm_ast_t *ast, const char *join_type,
                     fortran_orm_u32_t type_len, const char *table,
                     fortran_orm_u32_t table_len, const char *on_sql,
                     fortran_orm_u32_t on_len) {
  const char *c_type = NULL;
  const char *c_tbl = NULL;
  const char *c_on = NULL;
  c_orm_ast_node_t *on_node = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, join_type, type_len, &c_type);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, table, table_len, &c_tbl);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, on_sql, on_len, &c_on);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  crc = ast->q->raw(ast->q, c_on, &on_node);
  if (crc == C_ORM_OK) {
    crc = ast->q->join(ast->q, c_tbl, c_type, on_node);
  }
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_group_having(fortran_orm_ast_t *ast, const char *group_cols,
                             fortran_orm_u32_t group_len,
                             const char *having_sql,
                             fortran_orm_u32_t having_len) {
  const char *c_grp = NULL;
  const char *c_hav = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, group_cols, group_len, &c_grp);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = ast->q->group_by(ast->q, c_grp);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  if (having_len > 0u) {
    c_orm_ast_node_t *hnode = NULL;
    rc = ast_arena_slice(ast->q->arena, having_sql, having_len, &c_hav);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    if (c_hav[0] != '\0') {
      crc = ast->q->raw(ast->q, c_hav, &hnode);
      if (crc == C_ORM_OK) {
        crc = ast->q->having(ast->q, hnode);
      }
    }
    return fortran_orm_from_c(crc);
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_order_limit(fortran_orm_ast_t *ast, const char *order_col,
                            fortran_orm_u32_t col_len,
                            fortran_orm_i32_t descending,
                            fortran_orm_u32_t limit_rows,
                            fortran_orm_u32_t offset_rows) {
  c_orm_error_t crc = C_ORM_OK;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (col_len > 0u) {
    const char *c_col = NULL;
    rc = ast_arena_slice(ast->q->arena, order_col, col_len, &c_col);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    if (c_col[0] != '\0') {
      crc = ast->q->order_by(ast->q, c_col, descending ? 1 : 0);
    }
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
  }
  if (limit_rows > 0u) {
    crc = ast->q->limit(ast->q, (size_t)limit_rows);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
  }
  if (offset_rows > 0u) {
    crc = ast->q->offset(ast->q, (size_t)offset_rows);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_set_i64(fortran_orm_ast_t *ast, const char *col,
                        fortran_orm_u32_t col_len, fortran_orm_i64_t val) {
  const char *c_col = NULL;
  const char *c_num = NULL;
  c_orm_ast_node_t *lit_node = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, col, col_len, &c_col);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_i64(ast->q->arena, val, &c_num);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = ast->q->lit(ast->q, c_num, 0, &lit_node);
  if (crc == C_ORM_OK) {
    crc = ast->q->set_col(ast->q, c_col, lit_node);
  }
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_set_str(fortran_orm_ast_t *ast, const char *col,
                        fortran_orm_u32_t col_len, const char *val,
                        fortran_orm_u32_t val_len) {
  const char *c_col = NULL;
  const char *c_val = NULL;
  c_orm_ast_node_t *lit_node = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, col, col_len, &c_col);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = ast_arena_slice(ast->q->arena, val, val_len, &c_val);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = ast->q->lit(ast->q, c_val, 1, &lit_node);
  if (crc == C_ORM_OK) {
    crc = ast->q->set_col(ast->q, c_col, lit_node);
  }
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_returning_lock(fortran_orm_ast_t *ast,
                               const char *returning_cols,
                               fortran_orm_u32_t ret_len,
                               fortran_orm_i32_t db2_lock_mode) {
  c_orm_error_t crc = C_ORM_OK;
  fortran_orm_error_t rc = check_ast(ast);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (db2_lock_mode < 0 || db2_lock_mode > 5) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  if (ret_len > 0u) {
    const char *c_ret = NULL;
    rc = ast_arena_slice(ast->q->arena, returning_cols, ret_len, &c_ret);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    if (c_ret[0] != '\0') {
      crc = ast->q->returning(ast->q, c_ret);
    }
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
  }
  if (db2_lock_mode > 0) {
    crc = ast->q->with_lock(ast->q, (c_orm_ast_lock_mode_t)db2_lock_mode);
  }
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_to_sql(fortran_orm_ast_t *ast, fortran_orm_dialect_t dialect,
                       char *out_sql, fortran_orm_u32_t sql_cap,
                       fortran_orm_u32_t *out_len,
                       fortran_orm_u32_t *out_param_count) {
  char *sql_str = NULL;
  c_orm_query_params_t params;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_ast(ast);
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_len || !out_param_count || (sql_cap > 0u && !out_sql)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if ((int)dialect < 0 || (int)dialect > (int)FORTRAN_ORM_DIALECT_ODBC) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  f1 = fortran_orm_from_c(c_orm_query_params_init(&params));
  crc = c_orm_query_to_sql(ast->q, (c_orm_dialect_t)dialect, &sql_str, &params);
  if (crc != C_ORM_OK) {
    f2 = fortran_orm_from_c(c_orm_query_params_cleanup(&params));
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_keep_err(f1, f2));
  }
  *out_param_count = (fortran_orm_u32_t)params.count;
  rc = fortran_orm_keep_err(
      f1, fortran_orm_cstr_to_fbuf(sql_str, out_sql, sql_cap, out_len));
  f1 = fortran_orm_from_c(c_orm_system_free(sql_str));
  f2 = fortran_orm_from_c(c_orm_query_params_cleanup(&params));
  return fortran_orm_keep_err(rc, fortran_orm_keep_err(f1, f2));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_exec(fortran_orm_db_t *db, fortran_orm_ast_t *ast) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  chk = check_ast(ast);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(c_orm_query_execute(db->db, ast->q));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_query_rs(fortran_orm_db_t *db, fortran_orm_ast_t *ast,
                         fortran_orm_rs_t **out_rs) {
  char *sql_str = NULL;
  c_orm_query_params_t params;
  c_orm_query_t *q = NULL;
  fortran_orm_rs_t *wrap = NULL;
  size_t i;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = check_ast(ast);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_rs) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_rs = NULL;

  rc = fortran_orm_from_c(c_orm_query_params_init(&params));
  crc = c_orm_query_to_sql(ast->q, C_ORM_DIALECT_SQLITE, &sql_str, &params);
  if (crc != C_ORM_OK) {
    f1 = fortran_orm_from_c(c_orm_query_params_cleanup(&params));
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_keep_err(rc, f1));
  }

  crc = db->db->vtable->prepare(db->db, sql_str, &q);
  if (crc != C_ORM_OK) {
    f1 = fortran_orm_from_c(c_orm_system_free(sql_str));
    f2 = fortran_orm_from_c(c_orm_query_params_cleanup(&params));
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_keep_err(f1, f2));
  }

  for (i = 0u; crc == C_ORM_OK && i < params.count; i++) {
    const char *pv = params.params[i].value;
    if (!params.params[i].is_string) {
      const char *p = (*pv == '-') ? (pv + 1) : pv;
      fortran_orm_u64_t uv = 0u;
      while (*p != '\0') {
        uv = (uv * 10u) + (fortran_orm_u64_t)(*p - '0');
        p++;
      }
      crc = db->db->vtable->bind_int64(q, (int)(i + 1u),
                                       (int64_t)((*pv == '-')
                                                     ? -(fortran_orm_i64_t)uv
                                                     : (fortran_orm_i64_t)uv));
    } else {
      crc = db->db->vtable->bind_string(q, (int)(i + 1u), pv);
    }
  }

  if (crc == C_ORM_OK) {
    crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
    if (crc == C_ORM_OK) {
      crc = c_orm_hydrate_abstract_all(db->db, q, &wrap->arr);
      if (crc == C_ORM_OK) {
        wrap->magic = FORTRAN_ORM_MAGIC_RS;
        *out_rs = wrap;
      } else {
        fortran_orm_error_t fa =
            fortran_orm_from_c(c_orm_abstract_free(&wrap->arr));
        fortran_orm_error_t fw = fortran_orm_from_c(c_orm_system_free(wrap));
        rc = fortran_orm_keep_err(rc, fortran_orm_keep_err(fa, fw));
      }
    }
  }

  {
    fortran_orm_error_t fq = fortran_orm_from_c(db->db->vtable->finalize(q));
    f1 = fortran_orm_from_c(c_orm_system_free(sql_str));
    f2 = fortran_orm_from_c(c_orm_query_params_cleanup(&params));
    return fortran_orm_keep_err(
        fortran_orm_from_c(crc),
        fortran_orm_keep_err(
            rc, fortran_orm_keep_err(fq, fortran_orm_keep_err(f1, f2))));
  }
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ast_free(fortran_orm_ast_t *ast) {
  c_orm_ast_query_t *q;
  c_orm_error_t crc;
  fortran_orm_error_t frc;
  fortran_orm_error_t chk = check_ast(ast);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  q = ast->q;
  ast->magic = 0u;
  ast->q = NULL;
  crc = c_orm_query_free(q);
  frc = fortran_orm_from_c(c_orm_system_free(ast));
  return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
}
