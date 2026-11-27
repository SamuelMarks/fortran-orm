/**
 * @file fortran_orm_f77_bridge.c
 * @brief Tier-2 & Tier-3 `CHARACTER*(*)` C89 bridge for ANSI FORTRAN 77
 * (X3.9-1978), Fortran 90 (ISO/IEC 1539:1991), and Fortran 95
 * (ISO/IEC 1539-1:1997).
 *
 * All entry points use 6-character collision-free external names (`CF77*`)
 * without embedded underscores, exported simultaneously in `cf77xx_`,
 * `cf77xx`, and `CF77XX` forms, and accept Fortran `CHARACTER*(*)` hidden
 * trailing `fortran_charlen_t` lengths cleanly.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
/* clang-format on */

/** @brief Slot table of active F77/F90/F95 DB handles (`1..64`). */
static fortran_orm_db_t *g_f77_dbs[FORTRAN_ORM_LEGACY_INIT_SLOTS];
/** @brief Slot table of active F77/F90/F95 statement handles (`1..64`). */
static fortran_orm_stmt_t *g_f77_stmts[FORTRAN_ORM_LEGACY_INIT_SLOTS];
/** @brief Slot table of active F77/F90/F95 AST handles (`1..64`). */
static fortran_orm_ast_t *g_f77_asts[FORTRAN_ORM_LEGACY_INIT_SLOTS];

/**
 * @brief Allocates a 1-based slot in a generic pointer table.
 *
 * @param[in] tbl Slot table of size `FORTRAN_ORM_LEGACY_INIT_SLOTS`.
 * @param[out] out_id Receives 1-based slot ID.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
f77_alloc_slot(void **tbl, fortran_orm_i32_t *out_id) {
  int i;
  for (i = 0; i < FORTRAN_ORM_LEGACY_INIT_SLOTS; i++) {
    if (!tbl[i]) {
      *out_id = (fortran_orm_i32_t)(i + 1);
      return FORTRAN_ORM_OK;
    }
  }
  return FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL;
}

/**
 * @brief Looks up a 1-based slot in a generic pointer table.
 *
 * @param[in] tbl Slot table.
 * @param[in] id 1-based slot ID.
 * @param[out] out_ptr Receives stored pointer.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
f77_get_slot(void **tbl, fortran_orm_i32_t id, void **out_ptr) {
  if (id < 1 || id > FORTRAN_ORM_LEGACY_INIT_SLOTS || !tbl[id - 1]) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  *out_ptr = tbl[id - 1];
  return FORTRAN_ORM_OK;
}

/**
 * @brief Opens a DB connection (`CF77OP(URL, IDB, IERR)`).
 *
 * @param[in] url Blank-padded `CHARACTER*(*)` URL.
 * @param[out] idb Receives 1-based DB slot ID.
 * @param[out] ierr Receives integer status code.
 * @param[in] url_len Hidden Fortran character length of `url`.
 * @return `fortran_orm_error_t` status.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77op_impl(const char *url, fortran_orm_i32_t *idb, fortran_orm_i32_t *ierr,
            fortran_charlen_t url_len) {
  fortran_orm_db_t *db = NULL;
  fortran_orm_i32_t slot = 0;
  fortran_orm_error_t rc;

  if (!ierr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (!idb) {
    *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_NULL_POINTER;
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = f77_alloc_slot((void **)g_f77_dbs, &slot);
  if (rc == FORTRAN_ORM_OK) {
    rc = fortran_orm_connect(url, (fortran_orm_u32_t)url_len, &db);
    if (rc == FORTRAN_ORM_OK) {
      g_f77_dbs[slot - 1] = db;
      *idb = slot;
    }
  }
  *ierr = (fortran_orm_i32_t)rc;
  return rc;
}

/**
 * @brief Closes a DB connection or connection pool (`CF77CL(IMODE, IHND, IERR)`
 * where `IMODE == 1` closes DB, `IMODE == 2` finalizes stmt, `IMODE == 3`
 * destroys pool, `IMODE == 4` frees AST).
 *
 * @param[in] imode Resource kind (`1` DB, `2` Stmt, `3` Pool, `4` AST).
 * @param[in,out] ihnd 1-based slot ID (cleared to `0` on success).
 * @param[out] ierr Receives integer status code.
 * @return `fortran_orm_error_t` status.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77cl_impl(const fortran_orm_i32_t *imode, fortran_orm_i32_t *ihnd,
            fortran_orm_i32_t *ierr) {
  void *ptr = NULL;
  fortran_orm_error_t rc;

  if (!ierr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (!imode || !ihnd) {
    *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_NULL_POINTER;
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (*imode == 1) {
    rc = f77_get_slot((void **)g_f77_dbs, *ihnd, &ptr);
    if (rc == FORTRAN_ORM_OK) {
      g_f77_dbs[*ihnd - 1] = NULL;
      *ihnd = 0;
      rc = fortran_orm_disconnect((fortran_orm_db_t *)ptr);
    }
  } else if (*imode == 2) {
    rc = f77_get_slot((void **)g_f77_stmts, *ihnd, &ptr);
    if (rc == FORTRAN_ORM_OK) {
      g_f77_stmts[*ihnd - 1] = NULL;
      *ihnd = 0;
      rc = fortran_orm_stmt_finalize((fortran_orm_stmt_t *)ptr);
    }
  } else if (*imode == 4) {
    rc = f77_get_slot((void **)g_f77_asts, *ihnd, &ptr);
    if (rc == FORTRAN_ORM_OK) {
      g_f77_asts[*ihnd - 1] = NULL;
      *ihnd = 0;
      rc = fortran_orm_ast_free((fortran_orm_ast_t *)ptr);
    }
  } else {
    rc = FORTRAN_ORM_ERROR_INVALID_OPCODE;
  }
  *ierr = (fortran_orm_i32_t)rc;
  return rc;
}

/**
 * @brief Executes SQL or transaction control on DB (`CF77EX(IMODE, IDB, SQL,
 * IOUT, IERR)` where `IMODE == 1` execs SQL, `2` BEGIN, `3` COMMIT, `4`
 * ROLLBACK, `5` SAVEPOINT, `6` ROLLBACK TO SP, `7` RELEASE SP, `8` LAST ROWID).
 *
 * @param[in] imode Operation selector (`1..8`).
 * @param[in] idb 1-based DB slot ID pointer.
 * @param[in] sql Blank-padded `CHARACTER*(*)` SQL or savepoint name.
 * @param[out] iout Output integer (e.g. rowid on `IMODE == 8`).
 * @param[out] ierr Status output pointer.
 * @param[in] sql_len Hidden Fortran character length of `sql`.
 * @return `fortran_orm_error_t` status.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77ex_impl(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
            const char *sql, fortran_orm_i32_t *iout, fortran_orm_i32_t *ierr,
            fortran_charlen_t sql_len) {
  void *ptr = NULL;
  fortran_orm_db_t *db;
  fortran_orm_u32_t ulen;
  fortran_orm_i64_t rid = 0;
  fortran_orm_error_t rc;

  if (!ierr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (!imode || !idb || !iout) {
    *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_NULL_POINTER;
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = f77_get_slot((void **)g_f77_dbs, *idb, &ptr);
  if (rc != FORTRAN_ORM_OK) {
    *ierr = (fortran_orm_i32_t)rc;
    return rc;
  }
  db = (fortran_orm_db_t *)ptr;
  ulen = (fortran_orm_u32_t)sql_len;

  switch (*imode) {
  case 1:
    rc = fortran_orm_exec_sql(db, sql, ulen);
    break;
  case 2:
    rc = fortran_orm_tx_begin(db);
    break;
  case 3:
    rc = fortran_orm_tx_commit(db);
    break;
  case 4:
    rc = fortran_orm_tx_rollback(db);
    break;
  case 5:
    rc = fortran_orm_tx_savepoint(db, sql, ulen);
    break;
  case 6:
    rc = fortran_orm_tx_rollback_sp(db, sql, ulen);
    break;
  case 7:
    rc = fortran_orm_tx_release_sp(db, sql, ulen);
    break;
  case 8:
    rc = fortran_orm_last_insert_rowid(db, &rid);
    *iout = (fortran_orm_i32_t)rid;
    break;
  default:
    rc = FORTRAN_ORM_ERROR_INVALID_OPCODE;
    break;
  }
  *ierr = (fortran_orm_i32_t)rc;
  return rc;
}

/**
 * @brief Prepares, steps, binds, and reads prepared statements (`CF77ST(IMODE,
 * IHND, IIDX, IVAL, DVAL, CBUF, ILEN, IERR)`).
 * `IMODE`:
 * - `1`: prepare statement on DB `*ihnd`, write stmt slot into `*ival`
 * - `2`: bind `INTEGER*4` (`*ival`) at `*iidx`
 * - `3`: bind `DOUBLE PRECISION` (`*dval`) at `*iidx`
 * - `4`: bind `CHARACTER*(*)` (`cbuf`) at `*iidx`
 * - `5`: bind `NULL` at `*iidx`
 * - `6`: step (`*ival = 1` row, `0` done)
 * - `7`: reset statement
 * - `8`: read `INTEGER*4` column `*iidx` into `*ival`
 * - `9`: read `DOUBLE PRECISION` column `*iidx` into `*dval`
 * - `10`: read `CHARACTER*(*)` column `*iidx` into `cbuf`, length into `*ilen`
 * - `11`: check `IS NULL` at `*iidx` into `*ival`
 *
 * @param[in] imode Operation selector (`1..11`).
 * @param[in] ihnd DB slot (`IMODE == 1`) or statement slot (`2..11`).
 * @param[in] iidx 1-based parameter or column index.
 * @param[in,out] ival Integer input/output.
 * @param[in,out] dval Double-precision input/output.
 * @param[in,out] cbuf `CHARACTER*(*)` input/output buffer.
 * @param[out] ilen Written trimmed string length on `IMODE == 10`.
 * @param[out] ierr Status output pointer.
 * @param[in] cbuf_len Hidden Fortran character length of `cbuf`.
 * @return `fortran_orm_error_t` status.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77st_impl(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
            const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival,
            double *dval, char *cbuf, fortran_orm_i32_t *ilen,
            fortran_orm_i32_t *ierr, fortran_charlen_t cbuf_len) {
  void *ptr = NULL;
  fortran_orm_stmt_t *st = NULL;
  fortran_orm_u32_t out_u = 0u;
  fortran_orm_error_t rc;

  if (!ierr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (!imode || !ihnd || !iidx || !ival || !dval || !ilen) {
    *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_NULL_POINTER;
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  if (*imode == 1) {
    fortran_orm_i32_t slot = 0;
    rc = f77_get_slot((void **)g_f77_dbs, *ihnd, &ptr);
    if (rc == FORTRAN_ORM_OK) {
      rc = f77_alloc_slot((void **)g_f77_stmts, &slot);
    }
    if (rc == FORTRAN_ORM_OK) {
      rc = fortran_orm_stmt_prepare((fortran_orm_db_t *)ptr, cbuf,
                                    (fortran_orm_u32_t)cbuf_len, &st);
      if (rc == FORTRAN_ORM_OK) {
        g_f77_stmts[slot - 1] = st;
        *ival = slot;
      }
    }
    *ierr = (fortran_orm_i32_t)rc;
    return rc;
  }

  rc = f77_get_slot((void **)g_f77_stmts, *ihnd, &ptr);
  if (rc != FORTRAN_ORM_OK) {
    *ierr = (fortran_orm_i32_t)rc;
    return rc;
  }
  st = (fortran_orm_stmt_t *)ptr;

  switch (*imode) {
  case 2:
    rc = fortran_orm_stmt_bind_i32(st, *iidx, *ival);
    break;
  case 3:
    rc = fortran_orm_stmt_bind_f64(st, *iidx, *dval);
    break;
  case 4:
    rc =
        fortran_orm_stmt_bind_str(st, *iidx, cbuf, (fortran_orm_u32_t)cbuf_len);
    break;
  case 5:
    rc = fortran_orm_stmt_bind_null(st, *iidx);
    break;
  case 6:
    rc = fortran_orm_stmt_step(st, ival);
    break;
  case 7:
    rc = fortran_orm_stmt_reset(st);
    break;
  case 8:
    rc = fortran_orm_stmt_col_i32(st, *iidx, ival);
    break;
  case 9:
    rc = fortran_orm_stmt_col_f64(st, *iidx, dval);
    break;
  case 10:
    rc = fortran_orm_stmt_col_str(st, *iidx, cbuf, (fortran_orm_u32_t)cbuf_len,
                                  &out_u);
    *ilen = (fortran_orm_i32_t)out_u;
    break;
  case 11:
    rc = fortran_orm_stmt_col_is_null(st, *iidx, ival);
    break;
  default:
    rc = FORTRAN_ORM_ERROR_INVALID_OPCODE;
    break;
  }
  *ierr = (fortran_orm_i32_t)rc;
  return rc;
}

/**
 * @brief Pool, AST query builder, and 2D matrix helper for F77/F90/F95
 * (`CF77EX2` -> 6-char `CF77MX(IMODE, IHND, SQL, DMAT, LDROWS, NROWS, NCOLS,
 * NOUT, IERR)`).
 * `IMODE == 1`: insert 2D matrix; `IMODE == 2`: query 2D matrix;
 * `IMODE == 3`: create `SELECT * FROM <SQL>` AST (`*nout` receives AST slot);
 * `IMODE == 4`: render AST `*ihnd` for dialect `*ncols` (`0..4`) into `sql`
 * (`*nout` receives SQL length).
 *
 * @param[in] imode Operation mode (`1..4`).
 * @param[in] ihnd DB slot (`1..2`) or AST slot (`4`).
 * @param[in,out] sql `CHARACTER*(*)` SQL input or rendered SQL output.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix.
 * @param[in] ldrows Leading dimension pointer.
 * @param[in] nrows Row count / capacity pointer.
 * @param[in] ncols Column count or dialect selector pointer.
 * @param[out] nout Output row count, AST slot, or SQL length.
 * @param[out] ierr Status output pointer.
 * @param[in] sql_len Hidden Fortran character length of `sql`.
 * @return `fortran_orm_error_t` status.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77mx_impl(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
            char *sql, double *dmat, const fortran_orm_i32_t *ldrows,
            const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
            fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
            fortran_charlen_t sql_len) {
  void *ptr = NULL;
  fortran_orm_u32_t u_out = 0u;
  fortran_orm_u32_t p_cnt = 0u;
  fortran_orm_error_t rc;

  if (!ierr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (!imode || !ihnd || !ldrows || !nrows || !ncols || !nout) {
    *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_NULL_POINTER;
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  if (*imode == 1 || *imode == 2) {
    if (*ldrows < 1 || *nrows < 0 || *ncols < 1) {
      *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_VALIDATION;
      return FORTRAN_ORM_ERROR_VALIDATION;
    }
    rc = f77_get_slot((void **)g_f77_dbs, *ihnd, &ptr);
    if (rc == FORTRAN_ORM_OK) {
      if (*imode == 1) {
        rc = fortran_orm_insert_matrix_f64(
            (fortran_orm_db_t *)ptr, sql, (fortran_orm_u32_t)sql_len, dmat,
            (fortran_orm_u32_t)(*ldrows), (fortran_orm_u32_t)(*nrows),
            (fortran_orm_u32_t)(*ncols));
        *nout = *nrows;
      } else {
        rc = fortran_orm_query_matrix_f64(
            (fortran_orm_db_t *)ptr, sql, (fortran_orm_u32_t)sql_len, dmat,
            (fortran_orm_u32_t)(*ldrows), (fortran_orm_u32_t)(*nrows),
            (fortran_orm_u32_t)(*ncols), &u_out);
        *nout = (fortran_orm_i32_t)u_out;
      }
    }
  } else if (*imode == 3) {
    fortran_orm_i32_t slot = 0;
    fortran_orm_ast_t *ast = NULL;
    rc = f77_alloc_slot((void **)g_f77_asts, &slot);
    if (rc == FORTRAN_ORM_OK) {
      rc = fortran_orm_ast_select(sql, (fortran_orm_u32_t)sql_len, "*", 1u,
                                  &ast);
      if (rc == FORTRAN_ORM_OK && *nrows > 0) {
        fortran_orm_error_t lrc = fortran_orm_ast_order_limit(
            ast, "", 0u, 0, (fortran_orm_u32_t)(*nrows), 0u);
        rc = lrc;
      }
      if (rc == FORTRAN_ORM_OK) {
        g_f77_asts[slot - 1] = ast;
        *nout = slot;
      }
    }
  } else if (*imode == 4) {
    rc = f77_get_slot((void **)g_f77_asts, *ihnd, &ptr);
    if (rc == FORTRAN_ORM_OK) {
      rc = fortran_orm_ast_to_sql((fortran_orm_ast_t *)ptr,
                                  (fortran_orm_dialect_t)(*ncols), sql,
                                  (fortran_orm_u32_t)sql_len, &u_out, &p_cnt);
      *nout = (fortran_orm_i32_t)u_out;
    }
  } else {
    rc = FORTRAN_ORM_ERROR_INVALID_OPCODE;
  }
  *ierr = (fortran_orm_i32_t)rc;
  return rc;
}

/* ==========================================================================
 * Multi-Mangling Symbol Exports (`cf77xx_`, `cf77xx`, `CF77XX`)
 * ========================================================================== */

/** @brief F77 open (`cf77op_`).
 * @param[in] url URL string.
 * @param[out] idb DB slot ID.
 * @param[out] ierr Status code.
 * @param[in] url_len Hidden URL length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77op_(const char *url, fortran_orm_i32_t *idb, fortran_orm_i32_t *ierr,
        fortran_charlen_t url_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77op_(const char *url, fortran_orm_i32_t *idb, fortran_orm_i32_t *ierr,
        fortran_charlen_t url_len) {
  return cf77op_impl(url, idb, ierr, url_len);
}

/** @brief F77 open (`cf77op`).
 * @param[in] url URL string.
 * @param[out] idb DB slot ID.
 * @param[out] ierr Status code.
 * @param[in] url_len Hidden URL length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77op(const char *url, fortran_orm_i32_t *idb, fortran_orm_i32_t *ierr,
       fortran_charlen_t url_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77op(const char *url, fortran_orm_i32_t *idb, fortran_orm_i32_t *ierr,
       fortran_charlen_t url_len) {
  return cf77op_impl(url, idb, ierr, url_len);
}

/** @brief F77 open (`CF77OP`).
 * @param[in] url URL string.
 * @param[out] idb DB slot ID.
 * @param[out] ierr Status code.
 * @param[in] url_len Hidden URL length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77OP(const char *url, fortran_orm_i32_t *idb, fortran_orm_i32_t *ierr,
       fortran_charlen_t url_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77OP(const char *url, fortran_orm_i32_t *idb, fortran_orm_i32_t *ierr,
       fortran_charlen_t url_len) {
  return cf77op_impl(url, idb, ierr, url_len);
}

/** @brief F77 close/free (`cf77cl_`).
 * @param[in] imode Resource kind.
 * @param[in,out] ihnd Slot ID.
 * @param[out] ierr Status code.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77cl_(const fortran_orm_i32_t *imode, fortran_orm_i32_t *ihnd,
        fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77cl_(const fortran_orm_i32_t *imode, fortran_orm_i32_t *ihnd,
        fortran_orm_i32_t *ierr) {
  return cf77cl_impl(imode, ihnd, ierr);
}

/** @brief F77 close/free (`cf77cl`).
 * @param[in] imode Resource kind.
 * @param[in,out] ihnd Slot ID.
 * @param[out] ierr Status code.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77cl(const fortran_orm_i32_t *imode, fortran_orm_i32_t *ihnd,
       fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77cl(const fortran_orm_i32_t *imode, fortran_orm_i32_t *ihnd,
       fortran_orm_i32_t *ierr) {
  return cf77cl_impl(imode, ihnd, ierr);
}

/** @brief F77 close/free (`CF77CL`).
 * @param[in] imode Resource kind.
 * @param[in,out] ihnd Slot ID.
 * @param[out] ierr Status code.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77CL(const fortran_orm_i32_t *imode, fortran_orm_i32_t *ihnd,
       fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77CL(const fortran_orm_i32_t *imode, fortran_orm_i32_t *ihnd,
       fortran_orm_i32_t *ierr) {
  return cf77cl_impl(imode, ihnd, ierr);
}

/** @brief F77 SQL/tx execute (`cf77ex_`).
 * @param[in] imode Mode (`1..8`).
 * @param[in] idb DB slot ID.
 * @param[in] sql SQL or savepoint name.
 * @param[out] iout Output integer.
 * @param[out] ierr Status code.
 * @param[in] sql_len Hidden SQL length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77ex_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
        const char *sql, fortran_orm_i32_t *iout, fortran_orm_i32_t *ierr,
        fortran_charlen_t sql_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77ex_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
        const char *sql, fortran_orm_i32_t *iout, fortran_orm_i32_t *ierr,
        fortran_charlen_t sql_len) {
  return cf77ex_impl(imode, idb, sql, iout, ierr, sql_len);
}

/** @brief F77 SQL/tx execute (`cf77ex`).
 * @param[in] imode Mode (`1..8`).
 * @param[in] idb DB slot ID.
 * @param[in] sql SQL or savepoint name.
 * @param[out] iout Output integer.
 * @param[out] ierr Status code.
 * @param[in] sql_len Hidden SQL length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77ex(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const char *sql, fortran_orm_i32_t *iout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77ex(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const char *sql, fortran_orm_i32_t *iout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len) {
  return cf77ex_impl(imode, idb, sql, iout, ierr, sql_len);
}

/** @brief F77 SQL/tx execute (`CF77EX`).
 * @param[in] imode Mode (`1..8`).
 * @param[in] idb DB slot ID.
 * @param[in] sql SQL or savepoint name.
 * @param[out] iout Output integer.
 * @param[out] ierr Status code.
 * @param[in] sql_len Hidden SQL length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77EX(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const char *sql, fortran_orm_i32_t *iout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77EX(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const char *sql, fortran_orm_i32_t *iout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len) {
  return cf77ex_impl(imode, idb, sql, iout, ierr, sql_len);
}

/** @brief F77 statement dispatcher (`cf77st_`).
 * @param[in] imode Mode (`1..11`).
 * @param[in] ihnd DB or statement slot ID.
 * @param[in] iidx 1-based index.
 * @param[in,out] ival Integer input/output.
 * @param[in,out] dval Double input/output.
 * @param[in,out] cbuf Character buffer.
 * @param[out] ilen Written string length.
 * @param[out] ierr Status code.
 * @param[in] cbuf_len Hidden character length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77st_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
        const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
        char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
        fortran_charlen_t cbuf_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77st_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
        const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
        char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
        fortran_charlen_t cbuf_len) {
  return cf77st_impl(imode, ihnd, iidx, ival, dval, cbuf, ilen, ierr, cbuf_len);
}

/** @brief F77 statement dispatcher (`cf77st`).
 * @param[in] imode Mode (`1..11`).
 * @param[in] ihnd DB or statement slot ID.
 * @param[in] iidx 1-based index.
 * @param[in,out] ival Integer input/output.
 * @param[in,out] dval Double input/output.
 * @param[in,out] cbuf Character buffer.
 * @param[out] ilen Written string length.
 * @param[out] ierr Status code.
 * @param[in] cbuf_len Hidden character length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77st(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
       fortran_charlen_t cbuf_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77st(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
       fortran_charlen_t cbuf_len) {
  return cf77st_impl(imode, ihnd, iidx, ival, dval, cbuf, ilen, ierr, cbuf_len);
}

/** @brief F77 statement dispatcher (`CF77ST`).
 * @param[in] imode Mode (`1..11`).
 * @param[in] ihnd DB or statement slot ID.
 * @param[in] iidx 1-based index.
 * @param[in,out] ival Integer input/output.
 * @param[in,out] dval Double input/output.
 * @param[in,out] cbuf Character buffer.
 * @param[out] ilen Written string length.
 * @param[out] ierr Status code.
 * @param[in] cbuf_len Hidden character length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77ST(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
       fortran_charlen_t cbuf_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77ST(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
       fortran_charlen_t cbuf_len) {
  return cf77st_impl(imode, ihnd, iidx, ival, dval, cbuf, ilen, ierr, cbuf_len);
}

/** @brief F77/F90/F95 matrix & AST dispatcher (`cf77mx_`).
 * @param[in] imode Mode (`1..4`).
 * @param[in] ihnd DB or AST slot ID.
 * @param[in,out] sql SQL or table character buffer.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix.
 * @param[in] ldrows Leading dimension.
 * @param[in] nrows Row count / limit.
 * @param[in] ncols Column count / dialect.
 * @param[out] nout Output count / slot / length.
 * @param[out] ierr Status code.
 * @param[in] sql_len Hidden character length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77mx_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
        char *sql, double *dmat, const fortran_orm_i32_t *ldrows,
        const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
        fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
        fortran_charlen_t sql_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77mx_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
        char *sql, double *dmat, const fortran_orm_i32_t *ldrows,
        const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
        fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
        fortran_charlen_t sql_len) {
  return cf77mx_impl(imode, ihnd, sql, dmat, ldrows, nrows, ncols, nout, ierr,
                     sql_len);
}

/** @brief F77/F90/F95 matrix & AST dispatcher (`cf77mx`).
 * @param[in] imode Mode (`1..4`).
 * @param[in] ihnd DB or AST slot ID.
 * @param[in,out] sql SQL or table character buffer.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix.
 * @param[in] ldrows Leading dimension.
 * @param[in] nrows Row count / limit.
 * @param[in] ncols Column count / dialect.
 * @param[out] nout Output count / slot / length.
 * @param[out] ierr Status code.
 * @param[in] sql_len Hidden character length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77mx(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd, char *sql,
       double *dmat, const fortran_orm_i32_t *ldrows,
       const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
       fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cf77mx(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd, char *sql,
       double *dmat, const fortran_orm_i32_t *ldrows,
       const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
       fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len) {
  return cf77mx_impl(imode, ihnd, sql, dmat, ldrows, nrows, ncols, nout, ierr,
                     sql_len);
}

/** @brief F77/F90/F95 matrix & AST dispatcher (`CF77MX`).
 * @param[in] imode Mode (`1..4`).
 * @param[in] ihnd DB or AST slot ID.
 * @param[in,out] sql SQL or table character buffer.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix.
 * @param[in] ldrows Leading dimension.
 * @param[in] nrows Row count / limit.
 * @param[in] ncols Column count / dialect.
 * @param[out] nout Output count / slot / length.
 * @param[out] ierr Status code.
 * @param[in] sql_len Hidden character length.
 * @return `fortran_orm_error_t`. */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77MX(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd, char *sql,
       double *dmat, const fortran_orm_i32_t *ldrows,
       const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
       fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CF77MX(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd, char *sql,
       double *dmat, const fortran_orm_i32_t *ldrows,
       const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
       fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len) {
  return cf77mx_impl(imode, ihnd, sql, dmat, ldrows, nrows, ncols, nout, ierr,
                     sql_len);
}
