/**
 * @file test_legacy_f77_cfi_oom.h
 * @brief Unit tests for `fortran_orm_legacy.c`, `fortran_orm_f77_bridge.c`,
 * `fortran_orm_cfi.c`, and deterministic OOM fault-injection sweeps.
 */

#ifndef TEST_LEGACY_F77_CFI_OOM_H
/** @brief Header guard for test_legacy_f77_cfi_oom.h. */
#define TEST_LEGACY_F77_CFI_OOM_H

#if defined(FORTRAN_ORM_HAS_CFI_HEADER)
#include <ISO_Fortran_binding.h>
#endif

/* External prototypes for multi-mangled legacy & F77 symbols */
extern fortran_orm_error_t
icormf_(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
        const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
        fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen);
extern fortran_orm_error_t
icormf(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen);
extern fortran_orm_error_t
ICORMF(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen);
extern fortran_orm_error_t icormb_(const fortran_orm_i32_t *status,
                                   const fortran_orm_i32_t *db_id,
                                   const fortran_orm_i32_t *mask,
                                   fortran_orm_i32_t *out_word);
extern fortran_orm_error_t icormb(const fortran_orm_i32_t *status,
                                  const fortran_orm_i32_t *db_id,
                                  const fortran_orm_i32_t *mask,
                                  fortran_orm_i32_t *out_word);
extern fortran_orm_error_t ICORMB(const fortran_orm_i32_t *status,
                                  const fortran_orm_i32_t *db_id,
                                  const fortran_orm_i32_t *mask,
                                  fortran_orm_i32_t *out_word);
extern fortran_orm_error_t
corm66_(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
        const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
        fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen,
        fortran_orm_i32_t *ierr);
extern fortran_orm_error_t
corm66(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen,
       fortran_orm_i32_t *ierr);
extern fortran_orm_error_t
CORM66(const fortran_orm_i32_t *iop, fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       fortran_orm_i32_t *ibuf, fortran_orm_i32_t *ilen,
       fortran_orm_i32_t *ierr);
extern fortran_orm_error_t
cormmd_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
        const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
        const fortran_orm_i32_t *ilen, double *dmat,
        const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
        const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
        fortran_orm_i32_t *ierr);
extern fortran_orm_error_t
cormmd(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
       const fortran_orm_i32_t *ilen, double *dmat,
       const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
       const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
       fortran_orm_i32_t *ierr);
extern fortran_orm_error_t
CORMMD(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *idb,
       const fortran_orm_i32_t *iholmd, const fortran_orm_i32_t *isql,
       const fortran_orm_i32_t *ilen, double *dmat,
       const fortran_orm_i32_t *ldrows, const fortran_orm_i32_t *nrows,
       const fortran_orm_i32_t *ncols, fortran_orm_i32_t *nout,
       fortran_orm_i32_t *ierr);

extern fortran_orm_error_t cf77op_(const char *url, fortran_orm_i32_t *idb,
                                   fortran_orm_i32_t *ierr,
                                   fortran_charlen_t url_len);
extern fortran_orm_error_t cf77op(const char *url, fortran_orm_i32_t *idb,
                                  fortran_orm_i32_t *ierr,
                                  fortran_charlen_t url_len);
extern fortran_orm_error_t CF77OP(const char *url, fortran_orm_i32_t *idb,
                                  fortran_orm_i32_t *ierr,
                                  fortran_charlen_t url_len);
extern fortran_orm_error_t cf77cl_(const fortran_orm_i32_t *imode,
                                   fortran_orm_i32_t *ihnd,
                                   fortran_orm_i32_t *ierr);
extern fortran_orm_error_t cf77cl(const fortran_orm_i32_t *imode,
                                  fortran_orm_i32_t *ihnd,
                                  fortran_orm_i32_t *ierr);
extern fortran_orm_error_t CF77CL(const fortran_orm_i32_t *imode,
                                  fortran_orm_i32_t *ihnd,
                                  fortran_orm_i32_t *ierr);
extern fortran_orm_error_t cf77ex_(const fortran_orm_i32_t *imode,
                                   const fortran_orm_i32_t *idb,
                                   const char *sql, fortran_orm_i32_t *iout,
                                   fortran_orm_i32_t *ierr,
                                   fortran_charlen_t sql_len);
extern fortran_orm_error_t cf77ex(const fortran_orm_i32_t *imode,
                                  const fortran_orm_i32_t *idb, const char *sql,
                                  fortran_orm_i32_t *iout,
                                  fortran_orm_i32_t *ierr,
                                  fortran_charlen_t sql_len);
extern fortran_orm_error_t CF77EX(const fortran_orm_i32_t *imode,
                                  const fortran_orm_i32_t *idb, const char *sql,
                                  fortran_orm_i32_t *iout,
                                  fortran_orm_i32_t *ierr,
                                  fortran_charlen_t sql_len);
extern fortran_orm_error_t
cf77st_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
        const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
        char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
        fortran_charlen_t cbuf_len);
extern fortran_orm_error_t
cf77st(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
       fortran_charlen_t cbuf_len);
extern fortran_orm_error_t
CF77ST(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
       const fortran_orm_i32_t *iidx, fortran_orm_i32_t *ival, double *dval,
       char *cbuf, fortran_orm_i32_t *ilen, fortran_orm_i32_t *ierr,
       fortran_charlen_t cbuf_len);
extern fortran_orm_error_t
cf77mx_(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd,
        char *sql, double *dmat, const fortran_orm_i32_t *ldrows,
        const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
        fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
        fortran_charlen_t sql_len);
extern fortran_orm_error_t
cf77mx(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd, char *sql,
       double *dmat, const fortran_orm_i32_t *ldrows,
       const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
       fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len);
extern fortran_orm_error_t
CF77MX(const fortran_orm_i32_t *imode, const fortran_orm_i32_t *ihnd, char *sql,
       double *dmat, const fortran_orm_i32_t *ldrows,
       const fortran_orm_i32_t *nrows, const fortran_orm_i32_t *ncols,
       fortran_orm_i32_t *nout, fortran_orm_i32_t *ierr,
       fortran_charlen_t sql_len);

extern fortran_orm_error_t fortran_orm_cfi_connect(const CFI_cdesc_t *url_desc,
                                                   fortran_orm_db_t **out_db);
extern fortran_orm_error_t fortran_orm_cfi_exec(fortran_orm_db_t *db,
                                                const CFI_cdesc_t *sql_desc);
extern fortran_orm_error_t fortran_orm_cfi_col_str(fortran_orm_stmt_t *stmt,
                                                   fortran_orm_i32_t col_idx,
                                                   CFI_cdesc_t *out_desc,
                                                   fortran_orm_u32_t *out_len);
extern fortran_orm_error_t
fortran_orm_cfi_insert_numeric(fortran_orm_db_t *db,
                               const CFI_cdesc_t *sql_desc,
                               const CFI_cdesc_t *arr_desc);
extern fortran_orm_error_t
fortran_orm_cfi_query_numeric(fortran_orm_db_t *db, const CFI_cdesc_t *sql_desc,
                              CFI_cdesc_t *out_arr_desc,
                              fortran_orm_u32_t *out_rows);

/**
 * @brief Tests all legacy FORTRAN I–66 symbols (`ICORMF`, `ICORMB`, `CORM66`,
 * `CORMMD`), all 21 opcodes, and slot exhaustion (`fortran_orm_legacy.c`).
 */
TEST test_legacy_bridge_all(void) {
  fortran_orm_i32_t url_a4[4];
  fortran_orm_i32_t sql_a4[16];
  fortran_orm_i32_t out_a1[16];
  fortran_orm_i32_t out_a4[8];
  fortran_orm_i32_t db_slots[65];
  fortran_orm_i32_t st_slots[65];
  fortran_orm_u32_t ulen = 0u;
  fortran_orm_i32_t op = 1, hnd = 0, idx = 0, ival = 0, ilen = 0, ierr = 0;
  fortran_orm_i32_t st_id = 0, word = 0, mask = 3, zero = 0;
  fortran_orm_i32_t ld = 2, nr = 2, nc = 1, nout = 0, mode = 1, hol = 0;
  double dval = 0.0;
  double dmat[2] = {7.5, 8.5};
  double dout[2];
  int i;

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            icormf_(NULL, &hnd, &idx, &ival, &dval, url_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            icormf_(&op, NULL, &idx, &ival, &dval, url_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            icormf_(&op, &hnd, NULL, &ival, &dval, url_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            icormf_(&op, &hnd, &idx, NULL, &dval, url_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            icormf_(&op, &hnd, &idx, &ival, NULL, url_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            icormf_(&op, &hnd, &idx, &ival, &dval, url_a4, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            corm66_(&op, &hnd, &idx, &ival, &dval, url_a4, &ilen, NULL));
  op = 99;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_OPCODE,
            icormf(&op, &hnd, &idx, &ival, &dval, url_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_OPCODE,
            ICORMF(&op, &hnd, &idx, &ival, &dval, url_a4, &ilen));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, icormb_(NULL, &hnd, &mask, &word));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, icormb_(&zero, NULL, &mask, &word));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, icormb_(&zero, &hnd, NULL, &word));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, icormb_(&zero, &hnd, &mask, NULL));
  ASSERT_EQ(FORTRAN_ORM_OK, icormb(&zero, &zero, &mask, &word));
  ASSERT_EQ(1, word);
  ival = 99;
  ASSERT_EQ(FORTRAN_ORM_OK, icormb_(&zero, &ival, &mask, &word));
  ival = 2;
  ASSERT_EQ(FORTRAN_ORM_OK, icormb_(&zero, &ival, &mask, &word));
  ASSERT_EQ(FORTRAN_ORM_OK, ICORMB(&mask, &zero, &mask, &word));
  ASSERT_EQ(0, word);

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("bad://x", url_a4, 16u, &ulen));
  ilen = 7;
  op = FORTRAN_ORM_OP_OPEN_A4;
  ASSERT_NEQ(FORTRAN_ORM_OK,
             corm66_(&op, &hnd, &idx, &ival, &dval, url_a4, &ilen, &ierr));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4(":memory:", url_a4, 16u, &ulen));
  ilen = -1;
  op = FORTRAN_ORM_OP_OPEN_A4;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            corm66_(&op, &hnd, &idx, &ival, &dval, url_a4, &ilen, &ierr));

  /* Slot exhaustion on legacy DB table (64 slots) */
  ilen = 8;
  for (i = 0; i < 64; i++) {
    db_slots[i] = 0;
    op = FORTRAN_ORM_OP_OPEN_A4;
    ASSERT_EQ(FORTRAN_ORM_OK, corm66(&op, &db_slots[i], &idx, &ival, &dval,
                                     url_a4, &ilen, &ierr));
  }
  db_slots[64] = 0;
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL,
      CORM66(&op, &db_slots[64], &idx, &ival, &dval, url_a4, &ilen, &ierr));
  for (i = 1; i < 64; i++) {
    op = FORTRAN_ORM_OP_CLOSE;
    ASSERT_EQ(FORTRAN_ORM_OK,
              icormf_(&op, &db_slots[i], &idx, &ival, &dval, url_a4, &ilen));
  }
  hnd = db_slots[0];
  ASSERT_EQ(FORTRAN_ORM_OK, icormb_(&zero, &hnd, &mask, &word));
  ASSERT_EQ(3, word);

  /* Invalid handle checks across opcodes (slot 0, closed slot 2, out-of-range
   * 99) */
  zero = 0;
  for (op = FORTRAN_ORM_OP_CLOSE; op <= FORTRAN_ORM_OP_LAST_ROWID; op++) {
    fortran_orm_i32_t bad2 = 2;
    fortran_orm_i32_t bad99 = 99;
    ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
              icormf_(&op, &zero, &idx, &ival, &dval, url_a4, &ilen));
    ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
              icormf_(&op, &bad2, &idx, &ival, &dval, url_a4, &ilen));
    ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
              icormf_(&op, &bad99, &idx, &ival, &dval, url_a4, &ilen));
  }

  /* Execute A4 DDL & error paths */
  op = FORTRAN_ORM_OP_EXEC_A4;
  ilen = -1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));
  op = FORTRAN_ORM_OP_PREP_A4;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            icormf_(&op, &hnd, &idx, &st_id, &dval, sql_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("BAD SQL", sql_a4, 64u, &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  ASSERT_NEQ(FORTRAN_ORM_OK,
             icormf_(&op, &hnd, &idx, &st_id, &dval, sql_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("CREATE TABLE lg(i INT,d REAL,s TEXT)",
                                   sql_a4, 64u, &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  op = FORTRAN_ORM_OP_EXEC_A4;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));

  op = FORTRAN_ORM_OP_TX_BEGIN;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));
  op = FORTRAN_ORM_OP_TX_ROLLBACK;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));
  op = FORTRAN_ORM_OP_TX_BEGIN;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));
  op = FORTRAN_ORM_OP_TX_COMMIT;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));

  /* Statement slot exhaustion (64 slots) */
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("SELECT 1", sql_a4, 64u, &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  op = FORTRAN_ORM_OP_PREP_A4;
  for (i = 0; i < 64; i++) {
    ASSERT_EQ(FORTRAN_ORM_OK,
              icormf_(&op, &hnd, &idx, &st_slots[i], &dval, sql_a4, &ilen));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL,
            icormf_(&op, &hnd, &idx, &st_slots[64], &dval, sql_a4, &ilen));
  for (i = 0; i < 64; i++) {
    op = FORTRAN_ORM_OP_FINALIZE;
    ASSERT_EQ(FORTRAN_ORM_OK,
              icormf_(&op, &st_slots[i], &idx, &ival, &dval, sql_a4, &ilen));
  }

  /* Bind i32/f64/A4, step, read i32/f64/A1/A4, rowid */
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("INSERT INTO lg VALUES(?,?,?)", sql_a4, 64u,
                                   &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  op = FORTRAN_ORM_OP_PREP_A4;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &st_id, &dval, sql_a4, &ilen));

  idx = 1;
  ival = 57;
  op = FORTRAN_ORM_OP_BIND_I32;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  idx = 2;
  dval = 9.25;
  op = FORTRAN_ORM_OP_BIND_F64;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("IBM704", sql_a4, 64u, &ulen));
  idx = 3;
  ilen = -1;
  op = FORTRAN_ORM_OP_BIND_A4;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  ilen = 6;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  op = FORTRAN_ORM_OP_STEP;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  op = FORTRAN_ORM_OP_FINALIZE;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));

  op = FORTRAN_ORM_OP_LAST_ROWID;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));
  ASSERT_EQ(1, ival);

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("SELECT i,d,s FROM lg", sql_a4, 64u, &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  op = FORTRAN_ORM_OP_PREP_A4;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &st_id, &dval, sql_a4, &ilen));
  op = FORTRAN_ORM_OP_STEP;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  idx = 1;
  op = FORTRAN_ORM_OP_COL_I32;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  ASSERT_EQ(57, ival);
  idx = 2;
  op = FORTRAN_ORM_OP_COL_F64;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));
  idx = 3;
  ival = 0;
  op = FORTRAN_ORM_OP_COL_A1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            icormf_(&op, &st_id, &idx, &ival, &dval, out_a1, &ilen));
  ival = 16;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            icormf_(&op, &st_id, &idx, &ival, &dval, NULL, &ilen));
  idx = 1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            icormf_(&op, &st_id, &idx, &ival, &dval, out_a1, &ilen));
  idx = 3;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, out_a1, &ilen));
  op = FORTRAN_ORM_OP_COL_A4;
  ival = 16;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, out_a4, &ilen));
  op = FORTRAN_ORM_OP_FINALIZE;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &st_id, &idx, &ival, &dval, sql_a4, &ilen));

  /* CORMMD matrix insert & query */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &nr, &nc,
                    &nout, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd(NULL, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &nr, &nc, &nout,
                   &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, NULL, &hol, sql_a4, &ilen, dmat, &ld, &nr, &nc,
                    &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, &hnd, NULL, sql_a4, &ilen, dmat, &ld, &nr, &nc,
                    &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, &hnd, &hol, sql_a4, NULL, dmat, &ld, &nr, &nc, &nout,
                    &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, NULL, &nr, &nc,
                    &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, NULL, &nc,
                    &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &nr, NULL,
                    &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &nr, &nc, NULL,
                    &ierr));
  zero = 0;
  ival = -1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            CORMMD(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &zero, &nr, &nc,
                   &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            CORMMD(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &ival, &nc,
                   &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            CORMMD(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &nr, &zero,
                   &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            cormmd_(&mode, &zero, &hol, sql_a4, &ilen, dmat, &ld, &nr, &nc,
                    &nout, &ierr));
  ilen = -1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &nr, &nc,
                    &nout, &ierr));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cstr_to_a4("CREATE TABLE md(x REAL)",
                                                   sql_a4, 64u, &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  op = FORTRAN_ORM_OP_EXEC_A4;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cstr_to_a4("INSERT INTO md VALUES(?)",
                                                   sql_a4, 64u, &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  mode = 1;
  ASSERT_EQ(FORTRAN_ORM_OK, cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld,
                                    &nr, &nc, &nout, &ierr));
  mode = 99;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_OPCODE,
            cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dmat, &ld, &nr, &nc,
                    &nout, &ierr));
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cstr_to_a4("SELECT x FROM md", sql_a4, 64u, &ulen));
  ilen = (fortran_orm_i32_t)ulen;
  mode = 2;
  ASSERT_EQ(FORTRAN_ORM_OK, cormmd_(&mode, &hnd, &hol, sql_a4, &ilen, dout, &ld,
                                    &nr, &nc, &nout, &ierr));
  ASSERT_EQ(2, nout);

  op = FORTRAN_ORM_OP_CLOSE;
  ASSERT_EQ(FORTRAN_ORM_OK,
            icormf_(&op, &hnd, &idx, &ival, &dval, sql_a4, &ilen));
  PASS();
}

/**
 * @brief Tests all F77/F90/F95 bridge symbols (`CF77OP`, `CF77CL`, `CF77EX`,
 * `CF77ST`, `CF77MX`) and Fortran 2018 `CFI_cdesc_t` bridges.
 */
TEST test_f77_and_cfi_bridges(void) {
  fortran_orm_i32_t db_slots[65];
  fortran_orm_i32_t idb = 0, ist = 0, iast = 0, ierr = 0, imode = 1;
  fortran_orm_i32_t iidx = 1, ival = 0, ilen = 0, iout = 0, zero = 0;
  fortran_orm_i32_t ld = 2, nr = 2, nc = 1, nout = 0;
  double dval = 0.0;
  double dmat[2] = {1.25, 2.50};
  double dout[2];
  char cbuf[128];
  fortran_orm_db_t *cdb = NULL;
  fortran_orm_stmt_t *cst = NULL;
  fortran_orm_u32_t uout = 0u;
#if defined(CFI_CDESC_T)
  CFI_CDESC_T(2) sdesc_buf;
  CFI_CDESC_T(2) adesc_buf;
#else
  CFI_cdesc_t sdesc_buf;
  CFI_cdesc_t adesc_buf;
#endif
  CFI_cdesc_t *sdesc = (CFI_cdesc_t *)(void *)&sdesc_buf;
  CFI_cdesc_t *adesc = (CFI_cdesc_t *)(void *)&adesc_buf;
  double cfi_mat[6] = {10.0, 20.0, 30.0, 40.0, 50.0, 60.0};
  double cfi_out[6];
  fortran_orm_i32_t cfi_ivec[2] = {7, 8};
  fortran_orm_i32_t cfi_iout[2];
  int i;

  /* CF77OP / CF77CL multi-mangled symbols & slot exhaustion */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, cf77op_(":memory:", &idb, NULL, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, cf77op(":memory:", NULL, &ierr, 8));
  ASSERT_NEQ(FORTRAN_ORM_OK, CF77OP("bad://x", &idb, &ierr, 7));

  for (i = 0; i < 64; i++) {
    ASSERT_EQ(FORTRAN_ORM_OK, cf77op_(":memory:", &db_slots[i], &ierr, 8));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL,
            cf77op_(":memory:", &db_slots[64], &ierr, 8));
  imode = 1;
  for (i = 1; i < 64; i++) {
    ASSERT_EQ(FORTRAN_ORM_OK, cf77cl_(&imode, &db_slots[i], &ierr));
  }
  idb = db_slots[0];

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, cf77cl_(&imode, &idb, NULL));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, cf77cl(NULL, &idb, &ierr));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, cf77cl_(&imode, NULL, &ierr));
  imode = 99;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_OPCODE, CF77CL(&imode, &idb, &ierr));
  imode = 1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, cf77cl_(&imode, &zero, &ierr));
  ival = 2;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, cf77cl_(&imode, &ival, &ierr));
  ival = 99;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, cf77cl_(&imode, &ival, &ierr));
  imode = 2;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, cf77cl_(&imode, &zero, &ierr));
  imode = 4;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE, cf77cl_(&imode, &zero, &ierr));

  /* CF77EX modes 1..8 + invalid */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77ex_(&imode, &idb, " ", &iout, NULL, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77ex(NULL, &idb, " ", &iout, &ierr, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77ex_(&imode, NULL, " ", &iout, &ierr, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77ex_(&imode, &idb, " ", NULL, &ierr, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            CF77EX(&imode, &zero, " ", &iout, &ierr, 1));

  imode = 1;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77ex_(&imode, &idb, "CREATE TABLE f7(i INT,d REAL,s TEXT,n INT)",
                    &iout, &ierr, 42));
  for (imode = 2; imode <= 4; imode++) {
    if (imode == 4) {
      fortran_orm_i32_t bg = 2;
      ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&bg, &idb, " ", &iout, &ierr, 1));
    }
    ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&imode, &idb, " ", &iout, &ierr, 1));
  }
  imode = 2;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&imode, &idb, " ", &iout, &ierr, 1));
  imode = 5;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&imode, &idb, "sp", &iout, &ierr, 2));
  imode = 6;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&imode, &idb, "sp", &iout, &ierr, 2));
  imode = 7;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&imode, &idb, "sp", &iout, &ierr, 2));
  imode = 3;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&imode, &idb, " ", &iout, &ierr, 1));
  imode = 99;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_OPCODE,
            cf77ex_(&imode, &idb, " ", &iout, &ierr, 1));

  /* CF77ST modes 1..11 + invalid */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77st_(&imode, &idb, &iidx, &ival, &dval, cbuf, &ilen, NULL, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77st(NULL, &idb, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77st_(&imode, NULL, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77st_(&imode, &idb, NULL, &ival, &dval, cbuf, &ilen, &ierr, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77st_(&imode, &idb, &iidx, NULL, &dval, cbuf, &ilen, &ierr, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77st_(&imode, &idb, &iidx, &ival, NULL, cbuf, &ilen, &ierr, 8));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77st_(&imode, &idb, &iidx, &ival, &dval, cbuf, NULL, &ierr, 8));
  imode = 1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            CF77ST(&imode, &zero, &iidx, &ist, &dval, cbuf, &ilen, &ierr, 8));
  strcpy(cbuf, "BAD SQL");
  ASSERT_NEQ(FORTRAN_ORM_OK,
             cf77st_(&imode, &idb, &iidx, &ist, &dval, cbuf, &ilen, &ierr, 7));

  strcpy(cbuf, "INSERT INTO f7 VALUES(?,?,?,?)");
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &idb, &iidx, &ist, &dval, cbuf, &ilen, &ierr, 30));
  imode = 2;
  iidx = 1;
  ival = 77;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 3;
  iidx = 2;
  dval = 6.5;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 4;
  iidx = 3;
  strcpy(cbuf, "F77");
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 3));
  imode = 5;
  iidx = 4;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 6;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 7;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 99;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_OPCODE,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            cf77st_(&imode, &zero, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 2;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77cl_(&imode, &ist, &ierr));

  imode = 8;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77ex_(&imode, &idb, " ", &iout, &ierr, 1));

  imode = 1;
  strcpy(cbuf, "SELECT i,d,s,n FROM f7");
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &idb, &iidx, &ist, &dval, cbuf, &ilen, &ierr, 22));
  imode = 6;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 8;
  iidx = 1;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 9;
  iidx = 2;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 10;
  iidx = 3;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 16));
  imode = 11;
  iidx = 4;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77st_(&imode, &ist, &iidx, &ival, &dval, cbuf, &ilen, &ierr, 1));
  imode = 2;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77cl_(&imode, &ist, &ierr));

  /* CF77MX modes 1..4 + invalid */
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx_(&imode, &idb, cbuf, dmat, &ld, &nr, &nc, &nout, NULL, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx(NULL, &idb, cbuf, dmat, &ld, &nr, &nc, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx_(&imode, NULL, cbuf, dmat, &ld, &nr, &nc, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx_(&imode, &idb, cbuf, dmat, NULL, &nr, &nc, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx_(&imode, &idb, cbuf, dmat, &ld, NULL, &nc, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx_(&imode, &idb, cbuf, dmat, &ld, &nr, NULL, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx_(&imode, &idb, cbuf, dmat, &ld, &nr, &nc, NULL, &ierr, 4));
  imode = 1;
  ival = -1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            CF77MX(&imode, &idb, cbuf, dmat, &zero, &nr, &nc, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            CF77MX(&imode, &idb, cbuf, dmat, &ld, &ival, &nc, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_VALIDATION,
            CF77MX(&imode, &idb, cbuf, dmat, &ld, &nr, &zero, &nout, &ierr, 4));
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            cf77mx_(&imode, &zero, cbuf, dmat, &ld, &nr, &nc, &nout, &ierr, 4));

  imode = 1;
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77ex_(&imode, &idb, "CREATE TABLE mx(v REAL)", &iout, &ierr, 23));
  strcpy(cbuf, "INSERT INTO mx VALUES(?)");
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77mx_(&imode, &idb, cbuf, dmat, &ld, &nr, &nc, &nout, &ierr, 24));
  imode = 2;
  strcpy(cbuf, "SELECT v FROM mx");
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77mx_(&imode, &idb, cbuf, dout, &ld, &nr, &nc, &nout, &ierr, 16));

  imode = 3;
  strcpy(cbuf, "mx");
  for (i = 0; i < 64; i++) {
    ASSERT_EQ(FORTRAN_ORM_OK, cf77mx_(&imode, &zero, cbuf, dout, &ld, &zero,
                                      &nc, &db_slots[i], &ierr, 2));
  }
  ASSERT_EQ(FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL,
            cf77mx_(&imode, &zero, cbuf, dout, &ld, &zero, &nc, &db_slots[64],
                    &ierr, 2));
  imode = 4;
  for (i = 0; i < 64; i++) {
    ASSERT_EQ(FORTRAN_ORM_OK, cf77cl_(&imode, &db_slots[i], &ierr));
  }
  imode = 3;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77mx_(&imode, &zero, cbuf, dout, &ld, &zero, &nc,
                                    &iast, &ierr, 2));
  imode = 4;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77cl_(&imode, &iast, &ierr));
  imode = 3;
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            cf77mx_(&imode, &zero, NULL, dout, &ld, &nr, &nc, &iast, &ierr, 2));
  ASSERT_EQ(FORTRAN_ORM_OK,
            cf77mx_(&imode, &zero, cbuf, dout, &ld, &nr, &nc, &iast, &ierr, 2));
  imode = 4;
  nc = 0;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77mx_(&imode, &iast, cbuf, dout, &ld, &nr, &nc,
                                    &nout, &ierr, 64));
  ASSERT_EQ(
      FORTRAN_ORM_ERROR_INVALID_HANDLE,
      cf77mx_(&imode, &zero, cbuf, dout, &ld, &nr, &nc, &nout, &ierr, 64));
  imode = 99;
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_OPCODE,
            cf77mx_(&imode, &idb, cbuf, dout, &ld, &nr, &nc, &nout, &ierr, 4));
  imode = 4;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77cl_(&imode, &iast, &ierr));
  imode = 1;
  ASSERT_EQ(FORTRAN_ORM_OK, cf77cl_(&imode, &idb, &ierr));

  /* CFI_cdesc_t descriptor edge cases & strided arrays */
  memset(&sdesc_buf, 0, sizeof(sdesc_buf));
  memset(&adesc_buf, 0, sizeof(adesc_buf));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_connect(NULL, &cdb));
  sdesc->rank = 1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_DESCRIPTOR_RANK,
            fortran_orm_cfi_connect(sdesc, &cdb));
  sdesc->rank = 0;
  sdesc->elem_len = 8u;
  sdesc->base_addr = NULL;
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_connect(sdesc, &cdb));

  strcpy(cbuf, ":memory:");
  sdesc->base_addr = cbuf;
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cfi_connect(sdesc, &cdb));

  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER, fortran_orm_cfi_exec(cdb, NULL));
  sdesc->elem_len = 0u;
  sdesc->base_addr = NULL;
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_cfi_exec(cdb, sdesc));
  strcpy(cbuf, "CREATE TABLE cfi(a REAL UNIQUE, b REAL)");
  sdesc->base_addr = cbuf;
  sdesc->elem_len = strlen(cbuf);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cfi_exec(cdb, sdesc));

  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_stmt_prepare(cdb, "SELECT 'CFI'", 12u, &cst));
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_step(cst, &ival));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_col_str(cst, 1, NULL, &uout));
  sdesc->elem_len = 16u;
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cfi_col_str(cst, 1, sdesc, &uout));
  ASSERT_EQ(3u, uout);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_finalize(cst));

  strcpy(cbuf, "INSERT INTO cfi VALUES(?,?)");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_cfi_insert_numeric(NULL, sdesc, adesc));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_insert_numeric(cdb, NULL, adesc));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_insert_numeric(cdb, sdesc, NULL));
  adesc->rank = 3;
  ASSERT_EQ(FORTRAN_ORM_ERROR_DESCRIPTOR_RANK,
            fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  adesc->rank = 2;
  adesc->elem_len = 2u;
  ASSERT_EQ(FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE,
            fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  adesc->elem_len = sizeof(double);
  adesc->dim[0].extent = 0;
  adesc->dim[1].extent = 2;
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  adesc->dim[0].extent = 2;
  adesc->dim[1].extent = 0;
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  adesc->dim[1].extent = 2;
  adesc->base_addr = NULL;
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));

  adesc->base_addr = cfi_mat;
  adesc->dim[0].sm = (ptrdiff_t)(sizeof(double));
  adesc->dim[1].sm = (ptrdiff_t)(3u * sizeof(double));
  strcpy(cbuf, "BAD SQL");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  strcpy(cbuf, "SELECT 1");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  strcpy(cbuf, "INSERT INTO cfi VALUES(?,?)");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  /* Duplicate UNIQUE exercises step error in cfi_insert_numeric */
  ASSERT_NEQ(FORTRAN_ORM_OK, fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));

  strcpy(cbuf, "SELECT a, b FROM cfi");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_EQ(FORTRAN_ORM_ERROR_INVALID_HANDLE,
            fortran_orm_cfi_query_numeric(NULL, sdesc, adesc, &uout));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_query_numeric(cdb, NULL, adesc, &uout));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_query_numeric(cdb, sdesc, NULL, &uout));
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, NULL));
  adesc->rank = 3;
  ASSERT_EQ(FORTRAN_ORM_ERROR_DESCRIPTOR_RANK,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  adesc->rank = 2;
  adesc->elem_len = 2u;
  ASSERT_EQ(FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  adesc->elem_len = sizeof(double);
  adesc->base_addr = NULL;
  adesc->dim[0].extent = 0;
  ASSERT_EQ(FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  adesc->dim[0].extent = 2;
  adesc->dim[1].extent = 0;
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  adesc->dim[1].extent = 2;
  ASSERT_EQ(FORTRAN_ORM_ERROR_NULL_POINTER,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  adesc->base_addr = cfi_out;
  strcpy(cbuf, "BAD SQL");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  strcpy(cbuf, "SELECT abs(-9223372036854775808), 1.0");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_NEQ(FORTRAN_ORM_OK,
             fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  strcpy(cbuf, "SELECT 'txt', 1.0");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  strcpy(cbuf, "SELECT a, b FROM cfi");
  sdesc->elem_len = strlen(cbuf);
  adesc->dim[0].extent = 1;
  ASSERT_EQ(FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  adesc->dim[0].extent = 2;
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  ASSERT_EQ(2u, uout);

  /* Rank-1 INT32 CFI path */
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_exec_cstr(cdb, "CREATE TABLE cfii(k INT);"));
  strcpy(cbuf, "INSERT INTO cfii VALUES(?)");
  sdesc->elem_len = strlen(cbuf);
  adesc->rank = 1;
  adesc->elem_len = sizeof(fortran_orm_i32_t);
  adesc->base_addr = cfi_ivec;
  adesc->dim[0].extent = 2;
  adesc->dim[0].sm = (ptrdiff_t)sizeof(fortran_orm_i32_t);
  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_cfi_insert_numeric(cdb, sdesc, adesc));
  strcpy(cbuf, "SELECT 'txt'");
  sdesc->elem_len = strlen(cbuf);
  adesc->base_addr = cfi_iout;
  ASSERT_EQ(FORTRAN_ORM_ERROR_TYPE_MISMATCH,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  strcpy(cbuf, "SELECT k FROM cfii");
  sdesc->elem_len = strlen(cbuf);
  ASSERT_EQ(FORTRAN_ORM_OK,
            fortran_orm_cfi_query_numeric(cdb, sdesc, adesc, &uout));
  ASSERT_EQ(2u, uout);

  ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(cdb));
  PASS();
}

/**
 * @brief Deterministic OOM fault-injection sweep across connection, pool,
 * shard, statement, schema, AST, abstract query, and transcoding allocations.
 */
TEST test_oom_fault_injection_sweep(void) {
  int k;

  for (k = 1; k <= 60; k++) {
    fortran_orm_db_t *db = NULL;
    fortran_orm_error_t rc;
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
    rc = fortran_orm_connect(":memory:", 8u, &db);
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
    if (rc == FORTRAN_ORM_OK) {
      ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db));
      break;
    }
  }

  for (k = 1; k <= 40; k++) {
    fortran_orm_pool_t *pool = NULL;
    fortran_orm_error_t rc;
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
    rc = fortran_orm_pool_init(":memory:", 8u, 1, 2, 10, &pool);
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
    if (rc == FORTRAN_ORM_OK) {
      fortran_orm_db_t *ldb = NULL;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(1));
      ASSERT_EQ(FORTRAN_ORM_ERROR_MEMORY, fortran_orm_pool_acquire(pool, &ldb));
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_pool_destroy(pool));
      break;
    }
  }

  for (k = 1; k <= 20; k++) {
    fortran_orm_shard_t *sh = NULL;
    fortran_orm_error_t rc;
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
    rc = fortran_orm_shard_init(2u, &sh);
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
    if (rc == FORTRAN_ORM_OK) {
      ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_shard_free(sh));
      break;
    }
  }

  /* Schema + AST + Query + Escape + EBCDIC/UTF16 OOM paths */
  {
    fortran_orm_db_t *db = NULL;
    char buf[128];
    fortran_orm_u32_t out_n = 0u;
    fortran_orm_u32_t pcnt = 0u;
    fortran_orm_u8_t eb[4] = {0xC9u, 0xC2u, 0xD4u, 0u};
    fortran_orm_u16_t u16[4] = {65u, 66u, 0u, 0u};
    test_item_pod_t rec;

    memset(&rec, 0, sizeof(rec));
    rec.id = 1;
    ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_connect_cstr(":memory:", &db));
    ASSERT_EQ(FORTRAN_ORM_OK,
              fortran_orm_exec_cstr(
                  db, "CREATE TABLE items(id INT PRIMARY KEY, version INT, "
                      "price REAL, tag TEXT);"));
    ASSERT_EQ(
        FORTRAN_ORM_OK,
        fortran_orm_exec_cstr(db, "INSERT INTO items VALUES(1,1,2.0,'A');"));

    for (k = 1; k <= 12; k++) {
      fortran_orm_stmt_t *st = NULL;
      fortran_orm_error_t rc;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
      rc = fortran_orm_stmt_prepare(db, "SELECT 1", 8u, &st);
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (st) {
        ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_stmt_finalize(st));
      }
      if (rc == FORTRAN_ORM_OK) {
        break;
      }
    }

    for (k = 1; k <= 20; k++) {
      fortran_orm_mig_t *mg = NULL;
      fortran_orm_error_t rc;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
      rc = fortran_orm_mig_init(db, "/tmp", 4u, &mg);
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (mg) {
        ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_mig_free(mg));
      }
      if (rc == FORTRAN_ORM_OK) {
        break;
      }
    }

    for (k = 1; k <= 12; k++) {
      fortran_orm_error_t rc;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
      rc = fortran_orm_escape_string(db, "abc", 3u, buf, 32u, &out_n);
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (rc == FORTRAN_ORM_OK) {
        break;
      }
    }

    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(1));
    ASSERT_EQ(FORTRAN_ORM_ERROR_MEMORY,
              fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, eb, 3u, buf,
                                         16u, &out_n));
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(1));
    ASSERT_EQ(FORTRAN_ORM_ERROR_MEMORY,
              fortran_orm_utf16_to_utf8(u16, 2u, 0, buf, 16u, &out_n));
    ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));

    for (k = 1; k <= 150; k++) {
      fortran_orm_schema_t *sc = NULL;
      fortran_orm_error_t rc;
      int m;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
      rc = fortran_orm_schema_create("items", 5u,
                                     (fortran_orm_u32_t)sizeof(rec), &sc);
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_schema_add_col(sc, "id", 2u, FORTRAN_ORM_COL_INT32, 0u,
                                        0u, 1, 0);
      }
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_schema_add_col(sc, "version", 7u,
                                        FORTRAN_ORM_COL_INT32, 4u, 0u, 0, 0);
      }
      for (m = 0; rc == FORTRAN_ORM_OK && m < 9; m++) {
        char rn[8];
        rn[0] = 'r';
        rn[1] = (char)('a' + m);
        rn[2] = '\0';
        rc = fortran_orm_schema_add_relation(
            sc, rn, 2u, FORTRAN_ORM_REL_ONE_TO_MANY, sc, "id", 2u, "id", 2u);
      }
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_schema_build_ddl(sc, buf, 128u, &out_n);
      }
      if (rc == FORTRAN_ORM_OK) {
        rec.id = 500 + k;
        rc = fortran_orm_crud_insert(db, sc, &rec);
      }
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (sc) {
        ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_schema_free(sc));
      }
      if (rc == FORTRAN_ORM_OK) {
        break;
      }
    }

    {
      char pad4088[4088];
      char q4049[4049];
      memset(pad4088, 'x', sizeof(pad4088));
      memset(q4049, 'x', sizeof(q4049));
      q4049[4048] = '\'';

      for (k = 1; k <= 12; k++) {
        fortran_orm_ast_t *ast = NULL;
        fortran_orm_error_t rc;
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
        rc = fortran_orm_ast_select(pad4088, 4088u, pad4088, 4088u, &ast);
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
        if (ast) {
          ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));
        }
        if (rc == FORTRAN_ORM_OK) {
          break;
        }
      }
      for (k = 1; k <= 10; k++) {
        fortran_orm_ast_t *ast = NULL;
        fortran_orm_error_t rc;
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
        rc = fortran_orm_ast_insert(pad4088, 4088u, &ast);
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
        if (ast) {
          ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));
        }
        if (rc == FORTRAN_ORM_OK) {
          break;
        }
      }
      for (k = 1; k <= 10; k++) {
        fortran_orm_ast_t *ast = NULL;
        fortran_orm_error_t rc;
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
        rc = fortran_orm_ast_update(pad4088, 4088u, &ast);
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
        if (ast) {
          ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));
        }
        if (rc == FORTRAN_ORM_OK) {
          break;
        }
      }
      for (k = 1; k <= 10; k++) {
        fortran_orm_ast_t *ast = NULL;
        fortran_orm_error_t rc;
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
        rc = fortran_orm_ast_delete(pad4088, 4088u, &ast);
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
        if (ast) {
          ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));
        }
        if (rc == FORTRAN_ORM_OK) {
          break;
        }
      }
      for (k = 1; k <= 25; k++) {
        fortran_orm_ast_t *ast = NULL;
        fortran_orm_error_t rc;
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
        rc = fortran_orm_ast_select("items", 5u, "*", 1u, &ast);
        if (rc == FORTRAN_ORM_OK) {
          rc = fortran_orm_ast_where_str(ast, "tag", 3u, "=", 1u, q4049, 4049u);
        }
        if (rc == FORTRAN_ORM_OK) {
          rc = fortran_orm_ast_where_i64(ast, "id", 2u, pad4088, 4088u, 1);
        }
        if (rc == FORTRAN_ORM_OK) {
          rc = fortran_orm_ast_group_having(ast, "id", 2u, pad4088, 4088u);
        }
        if (rc == FORTRAN_ORM_OK) {
          rc = fortran_orm_ast_set_i64(ast, pad4088, 4088u, 1);
        }
        ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
        if (ast) {
          ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));
        }
        if (rc == FORTRAN_ORM_OK) {
          break;
        }
      }
    }

    for (k = 1; k <= 60; k++) {
      fortran_orm_ast_t *ast = NULL;
      fortran_orm_rs_t *rs = NULL;
      fortran_orm_error_t rc;
      char big_s[4200];
      memset(big_s, 'x', sizeof(big_s));
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
      rc = fortran_orm_ast_select("items", 5u, "*", 1u, &ast);
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_ast_where_str(ast, "tag", 3u, "!=", 2u, big_s, 4200u);
      }
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_ast_where_i64(ast, "id", 2u, "=", 1u, 1);
      }
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_ast_to_sql(ast, FORTRAN_ORM_DIALECT_SQLITE, buf, 128u,
                                    &out_n, &pcnt);
      }
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_ast_query_rs(db, ast, &rs);
      }
      if (rc == FORTRAN_ORM_OK) {
        rc = fortran_orm_rs_to_json(rs, buf, 128u, &out_n);
      }
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (rs) {
        ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_free(rs));
      }
      if (ast) {
        ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_ast_free(ast));
      }
      if (rc == FORTRAN_ORM_OK) {
        break;
      }
    }

    for (k = 1; k <= 25; k++) {
      fortran_orm_rs_t *rs = NULL;
      fortran_orm_error_t rc;
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(k));
      rc = fortran_orm_query_abstract(db, "SELECT * FROM items", 19u, &rs);
      ASSERT_EQ(FORTRAN_ORM_OK, set_oom_at(0));
      if (rs) {
        ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_rs_free(rs));
      }
      if (rc == FORTRAN_ORM_OK) {
        break;
      }
    }

    ASSERT_EQ(FORTRAN_ORM_OK, fortran_orm_disconnect(db));
  }

  PASS();
}

#endif /* TEST_LEGACY_F77_CFI_OOM_H */
