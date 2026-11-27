!> @file era_10_fortran_2008.f90
!> @brief End-to-end ISO/IEC 1539-1:2010 Fortran 2008 SUBMODULE, CONTIGUOUS
!> generic `INT32`/`INT64`/`REAL64` vectors, padded submatrices, `DO CONCURRENT`
!> standardization, and scientific checkpoint verification suite.
PROGRAM era_10_fortran_2008
  USE fortran_orm_f2008
  IMPLICIT NONE

  TYPE(orm_db_t) :: db
  TYPE(orm_checkpoint_f2008_t) :: ckpt, bad_ckpt
  INTEGER(INT32), DIMENSION(4), TARGET :: vi32_in, vi32_out
  INTEGER(INT64), DIMENSION(4), TARGET :: vi64_in, vi64_out
  REAL(REAL64), DIMENSION(4), TARGET :: v_in, v_out
  REAL(REAL64), DIMENSION(3, 3), TARGET :: m_in, m_out
  REAL(REAL64), DIMENSION(6, 4), TARGET :: pad_in, pad_out
  REAL(REAL64), DIMENSION(4, 2), TARGET :: zmat, ck_in, ck_out
  REAL(REAL64), DIMENSION(1, 2), TARGET :: tiny_mat
  REAL(REAL64) :: l2_step1, l2_step2, restored_time
  INTEGER(INT32) :: rc, n_elems, n_rows

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = db%exec("CREATE TABLE vi32_08(k INT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE vi64_08(k INT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE vec08(v REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE mat08(x REAL, y REAL, z REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE sub08(u REAL, v REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 1. Generic CONTIGUOUS 1D vectors (`INT32`, `INT64`, `REAL64`) + empty slices
  vi32_in = [101_INT32, 202_INT32, 303_INT32, 404_INT32]
  rc = corm_f2008_insert_vec(db, "INSERT INTO vi32_08 VALUES(?)", vi32_in(1:0))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_vec(db, "INSERT INTO vi32_08 VALUES(?)", vi32_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_query_vec(db, "SELECT k FROM vi32_08", vi32_out, n_elems)
  IF (rc /= FORTRAN_ORM_OK .OR. n_elems /= 4_INT32) ERROR STOP 1
  IF (ANY(vi32_in /= vi32_out)) ERROR STOP 1

  vi64_in = [10000000001_INT64, 20000000002_INT64, &
             30000000003_INT64, 40000000004_INT64]
  rc = corm_f2008_insert_vec(db, "INSERT INTO vi64_08 VALUES(?)", vi64_in(1:0))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_vec(db, "INSERT INTO vi64_08 VALUES(?)", vi64_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_query_vec(db, "SELECT k FROM vi64_08", vi64_out, n_elems)
  IF (rc /= FORTRAN_ORM_OK .OR. n_elems /= 4_INT32) ERROR STOP 1
  IF (ANY(vi64_in /= vi64_out)) ERROR STOP 1

  v_in = [1.25_REAL64, 2.50_REAL64, 3.75_REAL64, 5.00_REAL64]
  rc = corm_f2008_insert_vec(db, "INSERT INTO vec08 VALUES(?)", v_in(1:0))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_vec(db, "INSERT INTO vec08 VALUES(?)", v_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_query_vec(db, "SELECT v FROM vec08", v_out, n_elems)
  IF (rc /= FORTRAN_ORM_OK .OR. n_elems /= 4_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(v_in - v_out)) > 1.0E-12_REAL64) ERROR STOP 1

  ! 2. Full 2D CONTIGUOUS matrix + padded leading-dimension submatrix
  BLOCK
    INTEGER(INT32) :: r, c
    DO c = 1, 3
      DO r = 1, 3
        m_in(r, c) = REAL(r * 100 + c, REAL64)
      END DO
    END DO
  END BLOCK

  rc = corm_f2008_insert_matrix_f64(db, "INSERT INTO mat08 VALUES(?,?,?)", m_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_query_matrix_f64(db, "SELECT x, y, z FROM mat08", &
                                   m_out, n_rows)
  IF (rc /= FORTRAN_ORM_OK .OR. n_rows /= 3_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(m_in - m_out)) > 1.0E-12_REAL64) ERROR STOP 1

  pad_in = -999.0_REAL64
  pad_in(1:3, 1) = [10.0_REAL64, 20.0_REAL64, 30.0_REAL64]
  pad_in(1:3, 2) = [1.5_REAL64, 2.5_REAL64, 3.5_REAL64]
  rc = corm_f2008_insert_submatrix_f64(db, "INSERT INTO sub08 VALUES(?,?)", &
                                       pad_in, 9_INT32, 2_INT32)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = corm_f2008_insert_submatrix_f64(db, "INSERT INTO sub08 VALUES(?,?)", &
                                       pad_in, 3_INT32, 2_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  pad_out = 0.0_REAL64
  rc = corm_f2008_query_submatrix_f64(db, "SELECT u, v FROM sub08", &
                                      pad_out, 9_INT32, 2_INT32, n_rows)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = corm_f2008_query_submatrix_f64(db, "SELECT u, v FROM sub08", &
                                      pad_out, 3_INT32, 2_INT32, n_rows)
  IF (rc /= FORTRAN_ORM_OK .OR. n_rows /= 3_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(pad_in(1:3, 1:2) - pad_out(1:3, 1:2))) > 1.0E-12_REAL64) THEN
    ERROR STOP 1
  END IF

  ! 3. `DO CONCURRENT` column standardization (`corm_f2008_zscore_cols`)
  tiny_mat = 5.0_REAL64
  CALL corm_f2008_zscore_cols(tiny_mat)
  zmat(:, 1) = [2.0_REAL64, 4.0_REAL64, 6.0_REAL64, 8.0_REAL64]
  zmat(:, 2) = [7.0_REAL64, 7.0_REAL64, 7.0_REAL64, 7.0_REAL64]
  CALL corm_f2008_zscore_cols(zmat)
  IF (ABS(SUM(zmat(:, 1))) > 1.0E-12_REAL64) ERROR STOP 1
  IF (ABS(SUM(zmat(:, 1) ** 2) / 4.0_REAL64 - 1.0_REAL64) > 1.0E-12_REAL64) THEN
    ERROR STOP 1
  END IF
  IF (MAXVAL(ABS(zmat(:, 2) - 7.0_REAL64)) > 1.0E-12_REAL64) ERROR STOP 1

  ! 4. Multi-step scientific checkpointing (`orm_checkpoint_f2008_t`)
  rc = corm_f2008_ckpt_init(bad_ckpt, db, "", 2_INT32)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = corm_f2008_ckpt_save(bad_ckpt, db, 1_INT32, 0.1_REAL64, ck_in, l2_step1)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = corm_f2008_ckpt_load(bad_ckpt, db, 1_INT32, restored_time, &
                            ck_out, n_rows)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1

  rc = corm_f2008_ckpt_init(ckpt, db, "poisson08", 2_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  ck_in(:, 1) = [1.0_REAL64, 2.0_REAL64, 3.0_REAL64, 4.0_REAL64]
  ck_in(:, 2) = [0.5_REAL64, 1.5_REAL64, 2.5_REAL64, 3.5_REAL64]
  rc = corm_f2008_ckpt_save(ckpt, db, 10_INT32, 0.25_REAL64, ck_in, l2_step1)
  IF (rc /= FORTRAN_ORM_OK .OR. l2_step1 <= 0.0_REAL64) ERROR STOP 1

  ! Overwrite step 10 and add step 20
  ck_in = ck_in * 2.0_REAL64
  rc = corm_f2008_ckpt_save(ckpt, db, 10_INT32, 0.50_REAL64, ck_in, l2_step2)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  IF (ABS(l2_step2 - 2.0_REAL64 * l2_step1) > 1.0E-12_REAL64) ERROR STOP 1

  rc = corm_f2008_ckpt_load(ckpt, db, 99_INT32, restored_time, ck_out, n_rows)
  IF (rc /= FORTRAN_ORM_ERROR_NOT_FOUND) ERROR STOP 1

  rc = corm_f2008_ckpt_load(ckpt, db, 10_INT32, restored_time, ck_out, n_rows)
  IF (rc /= FORTRAN_ORM_OK .OR. n_rows /= 4_INT32) ERROR STOP 1
  IF (ABS(restored_time - 0.50_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
  IF (MAXVAL(ABS(ck_in - ck_out)) > 1.0E-12_REAL64) ERROR STOP 1

  rc = db%exec("DROP TABLE poisson08_data")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_ckpt_save(ckpt, db, 20_INT32, 0.75_REAL64, ck_in, l2_step2)
  IF (rc == FORTRAN_ORM_OK) ERROR STOP 1

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A)', "PASS: Fortran 2008"
END PROGRAM era_10_fortran_2008
