/**
 * @file fortran_orm_legacy.c
 * @brief Tier-1 pre-CHARACTER C89 legacy symbol and integer-handle bridge for
 * FORTRAN (I) (1957), FORTRAN II (1958), FORTRAN III (1958–59), FORTRAN IV
 * (1962), and ANSI FORTRAN 66 (X3.9-1966).
 *
 * Exports 6-character collision-free entry points simultaneously in trailing
 * underscore (`name_`), bare lowercase (`name`), and uppercase (`NAME`) symbol
 * forms, including `ICORMF` (1957 FORTRAN I external integer function) and
 * `ICORMB` (FORTRAN III boolean status mask helper).
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#include <string.h>
/* clang-format on */

/** @brief Fixed slot table of active legacy DB handles (`1..64`). */
static fortran_orm_db_t *g_leg_dbs[FORTRAN_ORM_LEGACY_INIT_SLOTS];

/** @brief Fixed slot table of active legacy statement handles (`1..64`). */
static fortran_orm_stmt_t *g_leg_stmts[FORTRAN_ORM_LEGACY_INIT_SLOTS];

/**
 * @brief Allocates a 1-based slot in `g_leg_dbs`.
 *
 * @param[out] out_id Receives 1-based slot index.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
leg_alloc_db(fortran_orm_i32_t *out_id) {
  int i;
  for (i = 0; i < FORTRAN_ORM_LEGACY_INIT_SLOTS; i++) {
    if (!g_leg_dbs[i]) {
      *out_id = (fortran_orm_i32_t)(i + 1);
      return FORTRAN_ORM_OK;
    }
  }
  return FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL;
}

/**
 * @brief Resolves a 1-based DB slot ID to `fortran_orm_db_t *`.
 *
 * @param[in] id 1-based slot index.
 * @param[out] out_db Receives live DB handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
leg_get_db(fortran_orm_i32_t id, fortran_orm_db_t **out_db) {
  if (id < 1 || id > FORTRAN_ORM_LEGACY_INIT_SLOTS || !g_leg_dbs[id - 1]) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  *out_db = g_leg_dbs[id - 1];
  return FORTRAN_ORM_OK;
}

/**
 * @brief Allocates a 1-based slot in `g_leg_stmts`.
 *
 * @param[out] out_id Receives 1-based slot index.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
leg_alloc_stmt(fortran_orm_i32_t *out_id) {
  int i;
  for (i = 0; i < FORTRAN_ORM_LEGACY_INIT_SLOTS; i++) {
    if (!g_leg_stmts[i]) {
      *out_id = (fortran_orm_i32_t)(i + 1);
      return FORTRAN_ORM_OK;
    }
  }
  return FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL;
}

/**
 * @brief Resolves a 1-based statement slot ID to `fortran_orm_stmt_t *`.
 *
 * @param[in] id 1-based slot index.
 * @param[out] out_stmt Receives live statement handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
leg_get_stmt(fortran_orm_i32_t id, fortran_orm_stmt_t **out_stmt) {
  if (id < 1 || id > FORTRAN_ORM_LEGACY_INIT_SLOTS || !g_leg_stmts[id - 1]) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  *out_stmt = g_leg_stmts[id - 1];
  return FORTRAN_ORM_OK;
}

/**
 * @brief Marshals either an unpacked `A1` (`mode == 1`) or packed `A4`
 * Hollerith (`mode != 1`) `INTEGER*4` buffer into a newly allocated C string.
 *
 * @param[in] mode `1` for unpacked A1, `0`/`2` for packed A4 Hollerith.
 * @param[in] ibuf Source `INTEGER*4` array.
 * @param[in] ilen Element count (`mode == 1`) or byte count (`mode != 1`).
 * @param[out] out_cstr Receives allocated NUL-terminated C string.
 * @return `FORTRAN_ORM_OK` on success, or error code.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
leg_hollerith_to_cstr(fortran_orm_i32_t mode, const fortran_orm_i32_t *ibuf,
                      fortran_orm_i32_t ilen, char **out_cstr) {
  if (ilen < 0) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  if (mode == 1) {
    return fortran_orm_a1_to_cstr(ibuf, (fortran_orm_u32_t)ilen, out_cstr);
  }
  return fortran_orm_a4_to_cstr(ibuf, (fortran_orm_u32_t)ilen, out_cstr);
}

/**
 * @brief Core 1957 FORTRAN (I) external integer function implementation
 * (`ICORMF`). Because FORTRAN I predates `SUBROUTINE` and `CALL` (introduced in
 * FORTRAN II), callers invoke `IERR = ICORMF(IOP, IHND, IIDX, IVAL, DVAL, IBUF,
 * ILEN)` directly inside assignment statements and arithmetic `IF` expressions!
 *
 * @param[in] iop Pointer to `fortran_orm_legacy_op_t` opcode.
 * @param[in,out] ihnd Pointer to DB or statement slot ID (populated on
 * `OP_OPEN_*` and `OP_PREP_*` where input `*ihnd` is DB ID and output `*ival`
 * receives statement ID).
 * @param[in] iidx Pointer to 1-based parameter or column index.
 * @param[in,out] ival Pointer to integer input/output (or output statement ID).
 * @param[in,out] dval Pointer to `DOUBLE PRECISION` input/output.
 * @param[in,out] ibuf Pointer to A1/A4 Hollerith `INTEGER` array.
 * @param[in,out] ilen Pointer to character/byte length or output string length.
 * @return `FORTRAN_ORM_OK` (`0`) on success, or non-zero `fortran_orm_error_t`
 * so `IF (ICORMF(...)) 900, 10, 900` branches to `10` on `0` and `900` on err!
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormf_impl(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
            const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival,
            double *dval, fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen) {
  fortran_orm_db_t *db = NULL;
  fortran_orm_stmt_t *st = NULL;
  fortran_orm_i32_t slot = 0;
  char *c_str = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!iop || !ihnd || !iidx || !ival || !dval || !ilen) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  switch ((fortran_orm_legacy_op_t)(*iop)) {
  case FORTRAN_ORM_OP_OPEN_A1:
  case FORTRAN_ORM_OP_OPEN_A4:
    rc = leg_alloc_db(&slot);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = leg_hollerith_to_cstr((*iop == (int)FORTRAN_ORM_OP_OPEN_A1) ? 1 : 0,
                               ibuf, *ilen, &c_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = fortran_orm_connect_cstr(c_str, &db);
    frc = fortran_orm_from_c(c_orm_system_free(c_str));
    if (rc == FORTRAN_ORM_OK) {
      g_leg_dbs[slot - 1] = db;
      *ihnd = slot;
    }
    return fortran_orm_keep_err(rc, frc);

  case FORTRAN_ORM_OP_CLOSE:
    rc = leg_get_db(*ihnd, &db);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    g_leg_dbs[*ihnd - 1] = NULL;
    *ihnd = 0;
    return fortran_orm_disconnect(db);

  case FORTRAN_ORM_OP_EXEC_A1:
  case FORTRAN_ORM_OP_EXEC_A4:
    rc = leg_get_db(*ihnd, &db);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = leg_hollerith_to_cstr((*iop == (int)FORTRAN_ORM_OP_EXEC_A1) ? 1 : 0,
                               ibuf, *ilen, &c_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = fortran_orm_exec_cstr(db, c_str);
    frc = fortran_orm_from_c(c_orm_system_free(c_str));
    return fortran_orm_keep_err(rc, frc);

  case FORTRAN_ORM_OP_TX_BEGIN:
    rc = leg_get_db(*ihnd, &db);
    return (rc != FORTRAN_ORM_OK) ? rc : fortran_orm_tx_begin(db);

  case FORTRAN_ORM_OP_TX_COMMIT:
    rc = leg_get_db(*ihnd, &db);
    return (rc != FORTRAN_ORM_OK) ? rc : fortran_orm_tx_commit(db);

  case FORTRAN_ORM_OP_TX_ROLLBACK:
    rc = leg_get_db(*ihnd, &db);
    return (rc != FORTRAN_ORM_OK) ? rc : fortran_orm_tx_rollback(db);

  case FORTRAN_ORM_OP_PREP_A1:
  case FORTRAN_ORM_OP_PREP_A4:
    rc = leg_get_db(*ihnd, &db);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = leg_alloc_stmt(&slot);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = leg_hollerith_to_cstr((*iop == (int)FORTRAN_ORM_OP_PREP_A1) ? 1 : 0,
                               ibuf, *ilen, &c_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = fortran_orm_stmt_prepare(db, c_str, (fortran_orm_u32_t)strlen(c_str),
                                  &st);
    frc = fortran_orm_from_c(c_orm_system_free(c_str));
    if (rc == FORTRAN_ORM_OK) {
      g_leg_stmts[slot - 1] = st;
      *ival = slot;
    }
    return fortran_orm_keep_err(rc, frc);

  case FORTRAN_ORM_OP_BIND_I32:
    rc = leg_get_stmt(*ihnd, &st);
    return (rc != FORTRAN_ORM_OK) ? rc
                                  : fortran_orm_stmt_bind_i32(st, *iidx, *ival);

  case FORTRAN_ORM_OP_BIND_F64:
    rc = leg_get_stmt(*ihnd, &st);
    return (rc != FORTRAN_ORM_OK) ? rc
                                  : fortran_orm_stmt_bind_f64(st, *iidx, *dval);

  case FORTRAN_ORM_OP_BIND_A1:
  case FORTRAN_ORM_OP_BIND_A4:
    rc = leg_get_stmt(*ihnd, &st);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = leg_hollerith_to_cstr((*iop == (int)FORTRAN_ORM_OP_BIND_A1) ? 1 : 0,
                               ibuf, *ilen, &c_str);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = fortran_orm_stmt_bind_str(st, *iidx, c_str,
                                   (fortran_orm_u32_t)strlen(c_str));
    frc = fortran_orm_from_c(c_orm_system_free(c_str));
    return fortran_orm_keep_err(rc, frc);

  case FORTRAN_ORM_OP_STEP:
    rc = leg_get_stmt(*ihnd, &st);
    return (rc != FORTRAN_ORM_OK) ? rc : fortran_orm_stmt_step(st, ival);

  case FORTRAN_ORM_OP_COL_I32:
    rc = leg_get_stmt(*ihnd, &st);
    return (rc != FORTRAN_ORM_OK) ? rc
                                  : fortran_orm_stmt_col_i32(st, *iidx, ival);

  case FORTRAN_ORM_OP_COL_F64:
    rc = leg_get_stmt(*ihnd, &st);
    return (rc != FORTRAN_ORM_OK) ? rc
                                  : fortran_orm_stmt_col_f64(st, *iidx, dval);

  case FORTRAN_ORM_OP_COL_A1:
  case FORTRAN_ORM_OP_COL_A4: {
    char tmp[256];
    fortran_orm_u32_t out_n = 0u;
    fortran_orm_u32_t cap_u;
    rc = leg_get_stmt(*ihnd, &st);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    if (*ival <= 0 || !ibuf) {
      return FORTRAN_ORM_ERROR_VALIDATION;
    }
    cap_u = (fortran_orm_u32_t)(*ival);
    rc = fortran_orm_stmt_col_str(st, *iidx, tmp,
                                  (fortran_orm_u32_t)sizeof(tmp), &out_n);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    if (*iop == (int)FORTRAN_ORM_OP_COL_A1) {
      rc = fortran_orm_str_to_a1(tmp, out_n, ibuf, cap_u, &out_n);
    } else {
      char c_tmp[257];
      memcpy(c_tmp, tmp, (size_t)out_n);
      c_tmp[out_n] = '\0';
      rc = fortran_orm_cstr_to_a4(c_tmp, ibuf, cap_u, &out_n);
    }
    *ilen = (fortran_orm_i32_t)out_n;
    return rc;
  }

  case FORTRAN_ORM_OP_FINALIZE:
    rc = leg_get_stmt(*ihnd, &st);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    g_leg_stmts[*ihnd - 1] = NULL;
    *ihnd = 0;
    return fortran_orm_stmt_finalize(st);

  case FORTRAN_ORM_OP_LAST_ROWID: {
    fortran_orm_i64_t rid = 0;
    rc = leg_get_db(*ihnd, &db);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = fortran_orm_last_insert_rowid(db, &rid);
    *ival = (fortran_orm_i32_t)rid;
    return rc;
  }

  default:
    return FORTRAN_ORM_ERROR_INVALID_OPCODE;
  }
}

/* ==========================================================================
 * 1957 FORTRAN (I) & FORTRAN III External Functions (`name_`, `name`, `NAME`)
 * ========================================================================== */

/**
 * @brief FORTRAN (I) 1957 external function (`icormf_` trailing-underscore
 * ABI).
 *
 * @param[in] iop Opcode pointer.
 * @param[in,out] ihnd DB or statement slot pointer.
 * @param[in] iidx 1-based parameter/column index pointer.
 * @param[in,out] ival Integer input/output pointer.
 * @param[in,out] dval Double-precision input/output pointer.
 * @param[in,out] ibuf Hollerith A1/A4 array pointer.
 * @param[in,out] ilen String length input/output pointer.
 * @return `FORTRAN_ORM_OK` (`0`) or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormf_(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
        const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
        fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormf_(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
        const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
        fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen) {
  return icormf_impl(iop, ihnd, iidx, ival, dval, ibuf, ilen);
}

/**
 * @brief FORTRAN (I) 1957 external function (`icormf` no-underscore ABI).
 *
 * @param[in] iop Opcode pointer.
 * @param[in,out] ihnd DB or statement slot pointer.
 * @param[in] iidx 1-based parameter/column index pointer.
 * @param[in,out] ival Integer input/output pointer.
 * @param[in,out] dval Double-precision input/output pointer.
 * @param[in,out] ibuf Hollerith A1/A4 array pointer.
 * @param[in,out] ilen String length input/output pointer.
 * @return `FORTRAN_ORM_OK` (`0`) or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormf(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormf(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen) {
  return icormf_impl(iop, ihnd, iidx, ival, dval, ibuf, ilen);
}

/**
 * @brief FORTRAN (I) 1957 external function (`ICORMF` uppercase ABI).
 *
 * @param[in] iop Opcode pointer.
 * @param[in,out] ihnd DB or statement slot pointer.
 * @param[in] iidx 1-based parameter/column index pointer.
 * @param[in,out] ival Integer input/output pointer.
 * @param[in,out] dval Double-precision input/output pointer.
 * @param[in,out] ibuf Hollerith A1/A4 array pointer.
 * @param[in,out] ilen String length input/output pointer.
 * @return `FORTRAN_ORM_OK` (`0`) or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ICORMF(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ICORMF(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen) {
  return icormf_impl(iop, ihnd, iidx, ival, dval, ibuf, ilen);
}

/**
 * @brief FORTRAN III (1958–59) boolean status-mask word evaluator (`icormb_`).
 * Computes `out_mask = ((status == 0 ? 1 : 0) | ((db_id > 0 ? 2 : 0))) & mask`.
 *
 * @param[in] status ORM status code pointer.
 * @param[in] db_id Legacy DB slot ID pointer.
 * @param[in] mask Bitwise filter mask pointer.
 * @param[out] out_word Receives masked boolean word (`0` or non-zero).
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_NULL_POINTER`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormb_impl(const fortran_orm_i32_t *status, const fortran_orm_i32_t *db_id,
            const fortran_orm_i32_t *mask, fortran_orm_i32_t *out_word) {
  fortran_orm_i32_t bits = 0;
  if (!status || !db_id || !mask || !out_word) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (*status == 0) {
    bits |= 1;
  }
  if (*db_id >= 1 && *db_id <= FORTRAN_ORM_LEGACY_INIT_SLOTS &&
      g_leg_dbs[*db_id - 1] != NULL) {
    bits |= 2;
  }
  *out_word = bits & (*mask);
  return FORTRAN_ORM_OK;
}

/**
 * @brief FORTRAN III boolean status-mask helper (`icormb_` ABI).
 *
 * @param[in] status ORM status code pointer.
 * @param[in] db_id DB slot ID pointer.
 * @param[in] mask Bitwise mask pointer.
 * @param[out] out_word Output masked boolean word.
 * @return `FORTRAN_ORM_OK` or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormb_(const fortran_orm_i32_t *status, const fortran_orm_i32_t *db_id,
        const fortran_orm_i32_t *mask, fortran_orm_i32_t *out_word);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormb_(const fortran_orm_i32_t *status, const fortran_orm_i32_t *db_id,
        const fortran_orm_i32_t *mask, fortran_orm_i32_t *out_word) {
  return icormb_impl(status, db_id, mask, out_word);
}

/**
 * @brief FORTRAN III boolean status-mask helper (`icormb` no-underscore ABI).
 *
 * @param[in] status ORM status code pointer.
 * @param[in] db_id DB slot ID pointer.
 * @param[in] mask Bitwise mask pointer.
 * @param[out] out_word Output masked boolean word.
 * @return `FORTRAN_ORM_OK` or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormb(const fortran_orm_i32_t *status, const fortran_orm_i32_t *db_id,
       const fortran_orm_i32_t *mask, fortran_orm_i32_t *out_word);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
icormb(const fortran_orm_i32_t *status, const fortran_orm_i32_t *db_id,
       const fortran_orm_i32_t *mask, fortran_orm_i32_t *out_word) {
  return icormb_impl(status, db_id, mask, out_word);
}

/**
 * @brief FORTRAN III boolean status-mask helper (`ICORMB` uppercase ABI).
 *
 * @param[in] status ORM status code pointer.
 * @param[in] db_id DB slot ID pointer.
 * @param[in] mask Bitwise mask pointer.
 * @param[out] out_word Output masked boolean word.
 * @return `FORTRAN_ORM_OK` or error code.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ICORMB(const fortran_orm_i32_t *status, const fortran_orm_i32_t *db_id,
       const fortran_orm_i32_t *mask, fortran_orm_i32_t *out_word);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
ICORMB(const fortran_orm_i32_t *status, const fortran_orm_i32_t *db_id,
       const fortran_orm_i32_t *mask, fortran_orm_i32_t *out_word) {
  return icormb_impl(status, db_id, mask, out_word);
}

/* ==========================================================================
 * FORTRAN II / III / IV / 66 6-Character Subroutines (`CORM*`)
 * ========================================================================== */

/**
 * @brief Shared subroutine dispatcher `CALL CORM66(IOP, IHND, IIDX, IVAL, DVAL,
 * IBUF, ILEN, IERR)` writing status into `*ierr` AND returning the enum.
 *
 * @param[in] iop Opcode pointer.
 * @param[in,out] ihnd DB or statement slot pointer.
 * @param[in] iidx 1-based index pointer.
 * @param[in,out] ival Integer input/output pointer.
 * @param[in,out] dval Double-precision input/output pointer.
 * @param[in,out] ibuf Hollerith A1/A4 buffer pointer.
 * @param[in,out] ilen Length pointer.
 * @param[out] ierr Receives integer status code.
 * @return `fortran_orm_error_t` status.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t corm66_impl(
    const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
    const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
    fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr) {
  fortran_orm_error_t rc;
  if (!ierr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = icormf_impl(iop, ihnd, iidx, ival, dval, ibuf, ilen);
  *ierr = (fortran_orm_i32_t)rc;
  return rc;
}

/**
 * @brief FORTRAN II–66 subroutine dispatcher (`corm66_` ABI).
 *
 * @param[in] iop Opcode pointer.
 * @param[in,out] ihnd Handle slot pointer.
 * @param[in] iidx 1-based index pointer.
 * @param[in,out] ival Integer input/output pointer.
 * @param[in,out] dval Double input/output pointer.
 * @param[in,out] ibuf Hollerith buffer pointer.
 * @param[in,out] ilen Length pointer.
 * @param[out] ierr Status output pointer.
 * @return `fortran_orm_error_t` status.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t corm66_(
    const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
    const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
    fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t corm66_(
    const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
    const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
    fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr) {
  return corm66_impl(iop, ihnd, iidx, ival, dval, ibuf, ilen, ierr);
}

/**
 * @brief FORTRAN II–66 subroutine dispatcher (`corm66` no-underscore ABI).
 *
 * @param[in] iop Opcode pointer.
 * @param[in,out] ihnd Handle slot pointer.
 * @param[in] iidx 1-based index pointer.
 * @param[in,out] ival Integer input/output pointer.
 * @param[in,out] dval Double input/output pointer.
 * @param[in,out] ibuf Hollerith buffer pointer.
 * @param[in,out] ilen Length pointer.
 * @param[out] ierr Status output pointer.
 * @return `fortran_orm_error_t` status.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t corm66(
    const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
    const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
    fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t corm66(
    const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
    const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
    fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr) {
  return corm66_impl(iop, ihnd, iidx, ival, dval, ibuf, ilen, ierr);
}

/**
 * @brief FORTRAN II–66 subroutine dispatcher (`CORM66` uppercase ABI).
 *
 * @param[in] iop Opcode pointer.
 * @param[in,out] ihnd Handle slot pointer.
 * @param[in] iidx 1-based index pointer.
 * @param[in,out] ival Integer input/output pointer.
 * @param[in,out] dval Double input/output pointer.
 * @param[in,out] ibuf Hollerith buffer pointer.
 * @param[in,out] ilen Length pointer.
 * @param[out] ierr Status output pointer.
 * @return `fortran_orm_error_t` status.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t CORM66(
    const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
    const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
    fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t CORM66(
    const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
    const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
    fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr) {
  return corm66_impl(iop, ihnd, iidx, ival, dval, ibuf, ilen, ierr);
}

/**
 * @brief FORTRAN IV / 66 scientific 2D column-major matrix insert/query helper
 * (`CALL CORMMD(IMODE, IDB, IHOLMD, ISQL, ILEN, DMAT, LDROWS, NROWS, NCOLS,
 * NOUT, IERR)`). `IMODE == 1` inserts `NROWS x NCOLS`; `IMODE == 2` queries up
 * to `NROWS` rows into `DMAT` and sets `NOUT`.
 *
 * @param[in] imode `1` for matrix insert, `2` for matrix query.
 * @param[in] idb Legacy DB slot ID pointer.
 * @param[in] iholmd `1` for unpacked A1 SQL, `0`/`2` for packed A4 Hollerith.
 * @param[in] isql Hollerith SQL buffer.
 * @param[in] ilen SQL length pointer.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix buffer.
 * @param[in] ldrows Leading dimension pointer.
 * @param[in] nrows Row count / max row capacity pointer.
 * @param[in] ncols Column count pointer.
 * @param[out] nout Hydrated row count output pointer.
 * @param[out] ierr Status output pointer.
 * @return `fortran_orm_error_t` status.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cormmd_impl(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
            const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
            const fortran_orm_i32_t *ilen, double *dmat,
            const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
            const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
            fortran_orm_i32_t *ierr) {
  fortran_orm_db_t *db = NULL;
  char *c_sql = NULL;
  fortran_orm_u32_t u_out = 0u;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!ierr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (!imode || !idb || !iholmd || !ilen || !ldrows || !nrows || !ncols ||
      !nout) {
    *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_NULL_POINTER;
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (*ldrows < 1 || *nrows < 0 || *ncols < 1) {
    *ierr = (fortran_orm_i32_t)FORTRAN_ORM_ERROR_VALIDATION;
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  rc = leg_get_db(*idb, &db);
  if (rc != FORTRAN_ORM_OK) {
    *ierr = (fortran_orm_i32_t)rc;
    return rc;
  }
  rc = leg_hollerith_to_cstr(*iholmd, isql, *ilen, &c_sql);
  if (rc != FORTRAN_ORM_OK) {
    *ierr = (fortran_orm_i32_t)rc;
    return rc;
  }

  if (*imode == 1) {
    rc = fortran_orm_insert_matrix_f64(
        db, c_sql, (fortran_orm_u32_t)strlen(c_sql), dmat,
        (fortran_orm_u32_t)(*ldrows), (fortran_orm_u32_t)(*nrows),
        (fortran_orm_u32_t)(*ncols));
    *nout = *nrows;
  } else if (*imode == 2) {
    rc = fortran_orm_query_matrix_f64(
        db, c_sql, (fortran_orm_u32_t)strlen(c_sql), dmat,
        (fortran_orm_u32_t)(*ldrows), (fortran_orm_u32_t)(*nrows),
        (fortran_orm_u32_t)(*ncols), &u_out);
    *nout = (fortran_orm_i32_t)u_out;
  } else {
    rc = FORTRAN_ORM_ERROR_INVALID_OPCODE;
  }
  frc = fortran_orm_from_c(c_orm_system_free(c_sql));
  rc = fortran_orm_keep_err(rc, frc);
  *ierr = (fortran_orm_i32_t)rc;
  return rc;
}

/**
 * @brief FORTRAN IV/66 2D matrix helper (`cormmd_` ABI).
 *
 * @param[in] imode Mode (`1` insert, `2` query).
 * @param[in] idb DB slot pointer.
 * @param[in] iholmd Hollerith mode pointer.
 * @param[in] isql Hollerith SQL buffer.
 * @param[in] ilen SQL length pointer.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix.
 * @param[in] ldrows Leading dimension pointer.
 * @param[in] nrows Row count pointer.
 * @param[in] ncols Column count pointer.
 * @param[out] nout Output row count pointer.
 * @param[out] ierr Status output pointer.
 * @return `fortran_orm_error_t` status.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cormmd_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
        const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
        const fortran_orm_i32_t *ilen, double *dmat,
        const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
        const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
        fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cormmd_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
        const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
        const fortran_orm_i32_t *ilen, double *dmat,
        const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
        const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
        fortran_orm_i32_t *ierr) {
  return cormmd_impl(imode, idb, iholmd, isql, ilen, dmat, ldrows, nrows, ncols,
                     nout, ierr);
}

/**
 * @brief FORTRAN IV/66 2D matrix helper (`cormmd` no-underscore ABI).
 *
 * @param[in] imode Mode (`1` insert, `2` query).
 * @param[in] idb DB slot pointer.
 * @param[in] iholmd Hollerith mode pointer.
 * @param[in] isql Hollerith SQL buffer.
 * @param[in] ilen SQL length pointer.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix.
 * @param[in] ldrows Leading dimension pointer.
 * @param[in] nrows Row count pointer.
 * @param[in] ncols Column count pointer.
 * @param[out] nout Output row count pointer.
 * @param[out] ierr Status output pointer.
 * @return `fortran_orm_error_t` status.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cormmd(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
       const fortran_orm_i32_t *ilen, double *dmat,
       const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
       const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
       fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cormmd(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
       const fortran_orm_i32_t *ilen, double *dmat,
       const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
       const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
       fortran_orm_i32_t *ierr) {
  return cormmd_impl(imode, idb, iholmd, isql, ilen, dmat, ldrows, nrows, ncols,
                     nout, ierr);
}

/**
 * @brief FORTRAN IV/66 2D matrix helper (`CORMMD` uppercase ABI).
 *
 * @param[in] imode Mode (`1` insert, `2` query).
 * @param[in] idb DB slot pointer.
 * @param[in] iholmd Hollerith mode pointer.
 * @param[in] isql Hollerith SQL buffer.
 * @param[in] ilen SQL length pointer.
 * @param[in,out] dmat Column-major `DOUBLE PRECISION` matrix.
 * @param[in] ldrows Leading dimension pointer.
 * @param[in] nrows Row count pointer.
 * @param[in] ncols Column count pointer.
 * @param[out] nout Output row count pointer.
 * @param[out] ierr Status output pointer.
 * @return `fortran_orm_error_t` status.
 */
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CORMMD(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
       const fortran_orm_i32_t *ilen, double *dmat,
       const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
       const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
       fortran_orm_i32_t *ierr);
FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
CORMMD(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
       const fortran_orm_i32_t *ilen, double *dmat,
       const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
       const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
       fortran_orm_i32_t *ierr) {
  return cormmd_impl(imode, idb, iholmd, isql, ilen, dmat, ldrows, nrows, ncols,
                     nout, ierr);
}
