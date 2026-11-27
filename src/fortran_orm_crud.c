/**
 * @file fortran_orm_crud.c
 * @brief Runtime `c_orm_table_meta_t` reflection builder and `BIND(C)` Fortran
 * derived-type CRUD, atomic upsert, optimistic/pessimistic locking, and
 * foreign-key relation registration.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#include "c_orm_string_builder.h"
#include <string.h>
/* clang-format on */

/**
 * @brief Validates a `fortran_orm_schema_t` handle.
 *
 * @param[in] schema Candidate schema handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
check_schema(const fortran_orm_schema_t *schema) {
  if (!schema || schema->magic != FORTRAN_ORM_MAGIC_SCHEMA) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

/**
 * @brief Ensures `schema->owned_strs` has capacity for at least `extra`
 * additional string pointers (`extra <= 16`).
 *
 * @param[in,out] schema Schema handle.
 * @param[in] extra Additional slot count required (`1..16`).
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_MEMORY`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
schema_reserve_strs(fortran_orm_schema_t *schema, size_t extra) {
  if (schema->owned_strs_count + extra > schema->owned_strs_cap) {
    size_t new_cap =
        (schema->owned_strs_cap == 0u) ? 16u : (schema->owned_strs_cap * 2u);
    char **new_arr = NULL;
    c_orm_error_t crc = c_orm_system_realloc(
        schema->owned_strs, new_cap * sizeof(char *), (void **)&new_arr);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    schema->owned_strs = new_arr;
    schema->owned_strs_cap = new_cap;
  }
  return FORTRAN_ORM_OK;
}

/**
 * @brief Interns a heap-allocated C string into `schema->owned_strs` so it is
 * automatically released by `fortran_orm_schema_free`.
 *
 * @param[in,out] schema Schema handle.
 * @param[in] owned_str Heap-allocated string (freed immediately on OOM).
 * @param[out] out_ref Receives interned `const char *` pointer.
 * @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_MEMORY`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t schema_own_str(
    fortran_orm_schema_t *schema, char *owned_str, const char **out_ref) {
  fortran_orm_error_t rc = schema_reserve_strs(schema, 1u);
  if (rc != FORTRAN_ORM_OK) {
    fortran_orm_error_t f1 = fortran_orm_from_c(c_orm_system_free(owned_str));
    return fortran_orm_keep_err(rc, f1);
  }
  schema->owned_strs[schema->owned_strs_count++] = owned_str;
  *out_ref = owned_str;
  return FORTRAN_ORM_OK;
}

/**
 * @brief Slices, trims, duplicates, and interns a Fortran string on `schema`.
 *
 * @param[in,out] schema Schema handle.
 * @param[in] buf Fortran string buffer.
 * @param[in] len Byte length of `buf`.
 * @param[out] out_ref Receives interned non-empty C string.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
schema_intern_slice(fortran_orm_schema_t *schema, const char *buf,
                    fortran_orm_u32_t len, const char **out_ref) {
  char *dup = NULL;
  fortran_orm_error_t rc = fortran_orm_slice_to_cstr(buf, len, 1, &dup);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (dup[0] == '\0') {
    fortran_orm_error_t f1 = fortran_orm_from_c(c_orm_system_free(dup));
    return fortran_orm_keep_err(FORTRAN_ORM_ERROR_VALIDATION, f1);
  }
  return schema_own_str(schema, dup, out_ref);
}

/**
 * @brief Appends `str` to `sb` when `prev == FORTRAN_ORM_OK`, otherwise
 * preserves `prev`.
 *
 * @param[in,out] sb Active string builder.
 * @param[in] prev Accumulated builder status.
 * @param[in] str NUL-terminated string to append.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
sb_cat(c_orm_string_builder_t *sb, fortran_orm_error_t prev, const char *str) {
  if (prev != FORTRAN_ORM_OK) {
    return prev;
  }
  return fortran_orm_from_c(c_orm_string_builder_append(sb, str));
}

/**
 * @brief Extracts a heap-duplicated string from `sb` when
 * `prev == FORTRAN_ORM_OK` and unconditionally frees `sb`, preserving any
 * primary or cleanup error.
 *
 * @param[in] sb Active string builder to finalize and free.
 * @param[in] prev Accumulated builder status prior to finalization.
 * @param[out] out_dup Receives newly allocated C string on success.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t sb_finish_dup(
    c_orm_string_builder_t *sb, fortran_orm_error_t prev, char **out_dup) {
  const char *raw = NULL;
  fortran_orm_error_t rc = prev;
  fortran_orm_error_t frc;

  if (rc == FORTRAN_ORM_OK) {
    c_orm_error_t grc = c_orm_string_builder_get(sb, &raw);
    rc = fortran_orm_keep_err(fortran_orm_from_c(grc),
                              fortran_orm_from_c(c_orm_strdup(raw, out_dup)));
  }
  frc = fortran_orm_from_c(c_orm_string_builder_free(sb));
  return fortran_orm_keep_err(rc, frc);
}

/**
 * @brief Compiles `SELECT`, `INSERT`, `UPDATE`, `DELETE`, and `FOR UPDATE` SQL
 * query templates onto `schema->meta` if not yet built, and optionally builds
 * `CREATE TABLE IF NOT EXISTS` DDL.
 *
 * @param[in,out] schema Schema handle.
 * @param[out] out_ddl_cstr Optional output receiving heap-allocated DDL string.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
schema_ensure_built(fortran_orm_schema_t *schema, char **out_ddl_cstr) {
  size_t i;
  const char *pk_name = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_schema(schema);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (schema->meta.num_columns == 0u) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  for (i = 0u; i < schema->meta.num_columns; i++) {
    if (schema->cols[i].is_pk) {
      pk_name = schema->cols[i].name;
      break;
    }
  }
  if (!pk_name) {
    pk_name = schema->cols[0].name;
  }

  if (!schema->built) {
    c_orm_string_builder_t *sb = NULL;
    char *q_str = NULL;

    rc = schema_reserve_strs(schema, 6u);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }

    /* 1. query_select_all */
    crc = c_orm_string_builder_init(&sb);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    rc = sb_cat(sb, FORTRAN_ORM_OK, "SELECT ");
    for (i = 0u; i < schema->meta.num_columns; i++) {
      if (i > 0u) {
        rc = sb_cat(sb, rc, ", ");
      }
      rc = sb_cat(sb, rc, schema->cols[i].name);
    }
    rc = sb_cat(sb, rc, " FROM ");
    rc = sb_cat(sb, rc, schema->meta.name);
    rc = sb_finish_dup(sb, rc, &q_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    schema->owned_strs[schema->owned_strs_count++] = q_str;
    schema->meta.query_select_all = q_str;

    /* 2. query_select_by_pk */
    crc = c_orm_string_builder_init(&sb);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    rc = sb_cat(sb, FORTRAN_ORM_OK, schema->meta.query_select_all);
    rc = sb_cat(sb, rc, " WHERE ");
    rc = sb_cat(sb, rc, pk_name);
    rc = sb_cat(sb, rc, " = ?");
    rc = sb_finish_dup(sb, rc, &q_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    schema->owned_strs[schema->owned_strs_count++] = q_str;
    schema->meta.query_select_by_pk = q_str;

    /* 3. query_select_by_pk_for_update */
    crc = c_orm_string_builder_init(&sb);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    rc = sb_cat(sb, FORTRAN_ORM_OK, schema->meta.query_select_by_pk);
    rc = sb_cat(sb, rc, " FOR UPDATE");
    rc = sb_finish_dup(sb, rc, &q_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    schema->owned_strs[schema->owned_strs_count++] = q_str;
    schema->meta.query_select_by_pk_for_update = q_str;

    /* 4. query_insert */
    crc = c_orm_string_builder_init(&sb);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    rc = sb_cat(sb, FORTRAN_ORM_OK, "INSERT INTO ");
    rc = sb_cat(sb, rc, schema->meta.name);
    rc = sb_cat(sb, rc, " (");
    for (i = 0u; i < schema->meta.num_columns; i++) {
      if (i > 0u) {
        rc = sb_cat(sb, rc, ", ");
      }
      rc = sb_cat(sb, rc, schema->cols[i].name);
    }
    rc = sb_cat(sb, rc, ") VALUES (");
    for (i = 0u; i < schema->meta.num_columns; i++) {
      if (i > 0u) {
        rc = sb_cat(sb, rc, ", ");
      }
      rc = sb_cat(sb, rc, "?");
    }
    rc = sb_cat(sb, rc, ")");
    rc = sb_finish_dup(sb, rc, &q_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    schema->owned_strs[schema->owned_strs_count++] = q_str;
    schema->meta.query_insert = q_str;

    /* 5. query_update (all columns in SET, PK in WHERE as expected by c-orm) */
    crc = c_orm_string_builder_init(&sb);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    rc = sb_cat(sb, FORTRAN_ORM_OK, "UPDATE ");
    rc = sb_cat(sb, rc, schema->meta.name);
    rc = sb_cat(sb, rc, " SET ");
    for (i = 0u; i < schema->meta.num_columns; i++) {
      if (i > 0u) {
        rc = sb_cat(sb, rc, ", ");
      }
      rc = sb_cat(sb, rc, schema->cols[i].name);
      rc = sb_cat(sb, rc, " = ?");
    }
    rc = sb_cat(sb, rc, " WHERE ");
    rc = sb_cat(sb, rc, pk_name);
    rc = sb_cat(sb, rc, " = ?");
    rc = sb_finish_dup(sb, rc, &q_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    schema->owned_strs[schema->owned_strs_count++] = q_str;
    schema->meta.query_update = q_str;

    /* 6. query_delete_by_pk */
    crc = c_orm_string_builder_init(&sb);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    rc = sb_cat(sb, FORTRAN_ORM_OK, "DELETE FROM ");
    rc = sb_cat(sb, rc, schema->meta.name);
    rc = sb_cat(sb, rc, " WHERE ");
    rc = sb_cat(sb, rc, pk_name);
    rc = sb_cat(sb, rc, " = ?");
    rc = sb_finish_dup(sb, rc, &q_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    schema->owned_strs[schema->owned_strs_count++] = q_str;
    schema->meta.query_delete_by_pk = q_str;

    schema->built = 1;
  }

  if (out_ddl_cstr) {
    c_orm_string_builder_t *sb = NULL;
    char *ddl = NULL;
    crc = c_orm_string_builder_init(&sb);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    rc = sb_cat(sb, FORTRAN_ORM_OK, "CREATE TABLE IF NOT EXISTS ");
    rc = sb_cat(sb, rc, schema->meta.name);
    rc = sb_cat(sb, rc, " (");
    for (i = 0u; i < schema->meta.num_columns; i++) {
      const char *sql_t = "TEXT";
      if (i > 0u) {
        rc = sb_cat(sb, rc, ", ");
      }
      rc = sb_cat(sb, rc, schema->cols[i].name);
      rc = sb_cat(sb, rc, " ");
      switch (schema->cols[i].type) {
      case C_ORM_TYPE_INT32:
      case C_ORM_TYPE_INT64:
      case C_ORM_TYPE_BOOL:
        sql_t = "INTEGER";
        break;
      case C_ORM_TYPE_FLOAT:
      case C_ORM_TYPE_DOUBLE:
        sql_t = "REAL";
        break;
      case C_ORM_TYPE_BLOB:
        sql_t = "BLOB";
        break;
      default:
        sql_t = "TEXT";
        break;
      }
      rc = sb_cat(sb, rc, sql_t);
      if (schema->cols[i].is_pk) {
        rc = sb_cat(sb, rc, " PRIMARY KEY");
      } else if (!schema->cols[i].is_nullable) {
        rc = sb_cat(sb, rc, " NOT NULL");
      }
    }
    rc = sb_cat(sb, rc, ")");
    rc = sb_finish_dup(sb, rc, &ddl);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    *out_ddl_cstr = ddl;
  }
  return FORTRAN_ORM_OK;
}

/**
 * @brief Allocates a temporary copy of `in_record` where blank-padded Fortran
 * `CHAR_FIXED` fields (`fixed_length + 1` bytes) are trimmed and NUL-terminated
 * for `c-orm` serialization.
 *
 * @param[in] schema Built schema handle.
 * @param[in] in_record Source `BIND(C)` Fortran struct.
 * @param[out] out_scratch Receives heap-allocated scratch record.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
record_prepare_in(const fortran_orm_schema_t *schema, const void *in_record,
                  void **out_scratch) {
  unsigned char *buf = NULL;
  size_t i;
  c_orm_error_t crc;

  if (!in_record) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_system_malloc(schema->meta.struct_size, (void **)&buf);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  memcpy(buf, in_record, schema->meta.struct_size);

  for (i = 0u; i < schema->meta.num_columns; i++) {
    const c_orm_column_meta_t *col = &schema->cols[i];
    if (col->type == C_ORM_TYPE_CHAR_FIXED) {
      char *fld = (char *)(buf + col->offset);
      size_t cap = col->fixed_length + 1u;
      size_t len = 0u;
      while (len < cap && fld[len] != '\0') {
        len++;
      }
      if (len > col->fixed_length) {
        len = col->fixed_length;
      }
      while (len > 0u && fld[len - 1u] == ' ') {
        len--;
      }
      fld[len] = '\0';
    }
  }
  *out_scratch = buf;
  return FORTRAN_ORM_OK;
}

/**
 * @brief Converts NUL-terminated `CHAR_FIXED` fields hydrated by `c-orm` into
 * blank-padded Fortran `CHARACTER` fields across `out_record`.
 *
 * @param[in] schema Built schema handle.
 * @param[in,out] out_record Hydrated `BIND(C)` Fortran struct.
 * @return `FORTRAN_ORM_OK`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
record_pad_out(const fortran_orm_schema_t *schema, void *out_record) {
  size_t i;
  unsigned char *buf = (unsigned char *)out_record;

  for (i = 0u; i < schema->meta.num_columns; i++) {
    const c_orm_column_meta_t *col = &schema->cols[i];
    if (col->type == C_ORM_TYPE_CHAR_FIXED) {
      char *fld = (char *)(buf + col->offset);
      size_t cap = col->fixed_length + 1u;
      size_t len = strlen(fld);
      memset(fld + len, ' ', cap - len);
    }
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_create(const char *table_name, fortran_orm_u32_t name_len,
                          fortran_orm_u32_t struct_size,
                          fortran_orm_schema_t **out_schema) {
  fortran_orm_schema_t *sc = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  if (!out_schema) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_schema = NULL;
  if (struct_size == 0u) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  crc = c_orm_system_calloc(1u, sizeof(*sc), (void **)&sc);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  sc->magic = FORTRAN_ORM_MAGIC_SCHEMA;
  sc->meta.struct_size = (size_t)struct_size;

  rc = schema_intern_slice(sc, table_name, name_len, &sc->meta.name);
  if (rc != FORTRAN_ORM_OK) {
    sc->meta.name = "invalid";
    return fortran_orm_keep_err(rc, fortran_orm_schema_free(sc));
  }
  *out_schema = sc;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_add_col(fortran_orm_schema_t *schema, const char *col_name,
                           fortran_orm_u32_t name_len,
                           fortran_orm_col_type_t col_type,
                           fortran_orm_u32_t byte_offset,
                           fortran_orm_u32_t fixed_len, fortran_orm_i32_t is_pk,
                           fortran_orm_i32_t is_nullable) {
  const char *interned_name = NULL;
  c_orm_column_meta_t *col;
  fortran_orm_error_t rc = check_schema(schema);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if ((size_t)byte_offset >= schema->meta.struct_size) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  if (col_type == FORTRAN_ORM_COL_CHAR_FIXED &&
      (fixed_len < 2u ||
       (size_t)byte_offset + (size_t)fixed_len > schema->meta.struct_size)) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  if (schema->meta.num_columns >= schema->cols_cap) {
    size_t new_cap = (schema->cols_cap == 0u) ? 8u : (schema->cols_cap * 2u);
    c_orm_column_meta_t *new_cols = NULL;
    c_orm_error_t crc = c_orm_system_realloc(
        schema->cols, new_cap * sizeof(*new_cols), (void **)&new_cols);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    schema->cols = new_cols;
    schema->cols_cap = new_cap;
    schema->meta.columns = schema->cols;
  }

  rc = schema_intern_slice(schema, col_name, name_len, &interned_name);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  col = &schema->cols[schema->meta.num_columns++];
  memset(col, 0, sizeof(*col));
  col->name = interned_name;
  col->type = (c_orm_type_t)col_type;
  col->offset = (size_t)byte_offset;
  col->is_pk = (unsigned char)(is_pk ? 1 : 0);
  /* Flat BIND(C) Fortran structs store values inline, never via T** pointer */
  col->is_nullable = (unsigned char)((col_type == FORTRAN_ORM_COL_CHAR_FIXED &&
                                      is_nullable != 0)
                                         ? 1
                                         : 0);
  if (col_type == FORTRAN_ORM_COL_CHAR_FIXED) {
    col->fixed_length = (size_t)(fixed_len - 1u);
  }
  schema->built = 0;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_add_relation(fortran_orm_schema_t *schema,
                                const char *field_name,
                                fortran_orm_u32_t field_len,
                                fortran_orm_relation_kind_t rel_kind,
                                const fortran_orm_schema_t *target_schema,
                                const char *fk_col, fortran_orm_u32_t fk_len,
                                const char *local_col,
                                fortran_orm_u32_t local_len) {
  const char *i_field = NULL;
  const char *i_fk = NULL;
  const char *i_loc = NULL;
  c_orm_relation_meta_t *rel;
  fortran_orm_error_t rc = check_schema(schema);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = check_schema(target_schema);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if ((int)rel_kind < 0 || (int)rel_kind > (int)FORTRAN_ORM_REL_MANY_TO_MANY) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }

  if (schema->meta.num_relations >= schema->rels_cap) {
    size_t new_cap = (schema->rels_cap == 0u) ? 4u : (schema->rels_cap * 2u);
    c_orm_relation_meta_t *new_rels = NULL;
    c_orm_error_t crc = c_orm_system_realloc(
        schema->rels, new_cap * sizeof(*new_rels), (void **)&new_rels);
    if (crc != C_ORM_OK) {
      return fortran_orm_from_c(crc);
    }
    schema->rels = new_rels;
    schema->rels_cap = new_cap;
    schema->meta.relations = schema->rels;
  }

  rc = schema_intern_slice(schema, field_name, field_len, &i_field);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_intern_slice(schema, fk_col, fk_len, &i_fk);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_intern_slice(schema, local_col, local_len, &i_loc);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  rel = &schema->rels[schema->meta.num_relations++];
  memset(rel, 0, sizeof(*rel));
  rel->field_name = i_field;
  rel->type = (c_orm_relation_type_t)rel_kind;
  rel->target_table = target_schema->meta.name;
  rel->foreign_key = i_fk;
  rel->local_key = i_loc;
  rel->target_meta = &target_schema->meta;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_build_ddl(fortran_orm_schema_t *schema, char *out_ddl,
                             fortran_orm_u32_t ddl_cap,
                             fortran_orm_u32_t *out_len) {
  char *ddl_str = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_len || (ddl_cap > 0u && !out_ddl)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = schema_ensure_built(schema, &ddl_str);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_cstr_to_fbuf(ddl_str, out_ddl, ddl_cap, out_len);
  frc = fortran_orm_from_c(c_orm_system_free(ddl_str));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_create_table(fortran_orm_db_t *db,
                              fortran_orm_schema_t *schema) {
  char *ddl_str = NULL;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_ensure_built(schema, &ddl_str);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_exec_cstr(db, ddl_str);
  frc = fortran_orm_from_c(c_orm_system_free(ddl_str));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_insert(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                        const void *in_record) {
  void *scratch = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = record_prepare_in(schema, in_record, &scratch);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_insert(db->db, &schema->meta, scratch);
  frc = fortran_orm_from_c(c_orm_system_free(scratch));
  return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_upsert(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                        const void *in_record) {
  void *scratch = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = record_prepare_in(schema, in_record, &scratch);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_upsert(db->db, &schema->meta, scratch);
  frc = fortran_orm_from_c(c_orm_system_free(scratch));
  return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_update(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                        const void *in_record) {
  void *scratch = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = record_prepare_in(schema, in_record, &scratch);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_update(db->db, &schema->meta, scratch);
  frc = fortran_orm_from_c(c_orm_system_free(scratch));
  return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_update_optimistic(fortran_orm_db_t *db,
                                   fortran_orm_schema_t *schema,
                                   const char *version_col,
                                   fortran_orm_u32_t col_len,
                                   const void *in_record) {
  char *c_ver = NULL;
  void *scratch = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = record_prepare_in(schema, in_record, &scratch);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_slice_to_cstr(version_col, col_len, 1, &c_ver);
  if (rc != FORTRAN_ORM_OK) {
    f1 = fortran_orm_from_c(c_orm_system_free(scratch));
    return fortran_orm_keep_err(rc, f1);
  }
  crc = c_orm_update_optimistic(db->db, &schema->meta, c_ver, scratch);
  f1 = fortran_orm_from_c(c_orm_system_free(c_ver));
  f2 = fortran_orm_from_c(c_orm_system_free(scratch));
  return fortran_orm_keep_err(fortran_orm_from_c(crc),
                              fortran_orm_keep_err(f1, f2));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_find_i32(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                          fortran_orm_i32_t id_val, void *out_record) {
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_record) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_find_by_id_int32(db->db, &schema->meta, (int32_t)id_val,
                               out_record);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return record_pad_out(schema, out_record);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_find_for_update_i32(fortran_orm_db_t *db,
                                     fortran_orm_schema_t *schema,
                                     fortran_orm_i32_t id_val,
                                     void *out_record) {
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_record) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  /* SQLite lacks FOR UPDATE syntax; execute standard PK lookup on sqlite */
  if (strcmp(db->db->driver_name, "sqlite") == 0) {
    crc = c_orm_find_by_id_int32(db->db, &schema->meta, (int32_t)id_val,
                                 out_record);
  } else {
    crc = c_orm_find_for_update_by_id_int32(db->db, &schema->meta,
                                            (int32_t)id_val, out_record);
  }
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return record_pad_out(schema, out_record);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_exists_i32(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                            fortran_orm_i32_t id_val,
                            fortran_orm_i32_t *out_exists) {
  int ex = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_exists) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_exists_int32(db->db, &schema->meta, (int32_t)id_val, &ex);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_exists = (fortran_orm_i32_t)ex;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_delete_i32(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                            fortran_orm_i32_t id_val) {
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  return fortran_orm_from_c(
      c_orm_delete_by_id_int32(db->db, &schema->meta, (int32_t)id_val));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_crud_find_all(fortran_orm_db_t *db, fortran_orm_schema_t *schema,
                          void *out_array, fortran_orm_u32_t max_records,
                          fortran_orm_u32_t *out_count) {
  c_orm_query_t *q = NULL;
  fortran_orm_u32_t n = 0u;
  int has_row = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_count || (max_records > 0u && !out_array)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_count = 0u;
  rc = schema_ensure_built(schema, NULL);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }

  crc = db->db->vtable->prepare(db->db, schema->meta.query_select_all, &q);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  for (;;) {
    void *slot;
    crc = db->db->vtable->step(q, &has_row);
    if (crc != C_ORM_OK || !has_row) {
      rc = fortran_orm_from_c(crc);
      break;
    }
    if (n >= max_records) {
      rc = FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL;
      break;
    }
    slot = (unsigned char *)out_array + ((size_t)n * schema->meta.struct_size);
    crc = c_orm_hydrate_row_from(db->db, q, &schema->meta, slot, 0u);
    if (crc != C_ORM_OK) {
      rc = fortran_orm_from_c(crc);
      break;
    }
    rc = record_pad_out(schema, slot);
    n++;
  }
  *out_count = n;
  frc = fortran_orm_from_c(db->db->vtable->finalize(q));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_schema_free(fortran_orm_schema_t *schema) {
  size_t i;
  fortran_orm_error_t rc = check_schema(schema);
  fortran_orm_error_t f1;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  schema->magic = 0u;
  for (i = 0u; i < schema->owned_strs_count; i++) {
    f1 = fortran_orm_from_c(c_orm_system_free(schema->owned_strs[i]));
    rc = fortran_orm_keep_err(rc, f1);
  }
  f1 = fortran_orm_from_c(c_orm_system_free(schema->owned_strs));
  rc = fortran_orm_keep_err(rc, f1);
  f1 = fortran_orm_from_c(c_orm_system_free(schema->cols));
  rc = fortran_orm_keep_err(rc, f1);
  f1 = fortran_orm_from_c(c_orm_system_free(schema->rels));
  rc = fortran_orm_keep_err(rc, f1);
  f1 = fortran_orm_from_c(c_orm_system_free(schema));
  return fortran_orm_keep_err(rc, f1);
}
