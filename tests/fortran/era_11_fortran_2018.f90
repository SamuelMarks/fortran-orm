!> @file era_11_fortran_2018.f90
!> @brief End-to-end ISO/IEC 1539-1:2018 Fortran 2018 CFI_cdesc_t assumed-rank
!> and strided array slice verification suite.
PROGRAM era_11_fortran_2018
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE fortran_orm_f2018
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  TYPE(orm_stmt_t) :: stmt
  REAL(REAL64), DIMENSION(6, 2) :: full_grid, recv_grid
  INTEGER(INT32), DIMENSION(4) :: ivec_in, ivec_out
  CHARACTER(LEN=32) :: col_txt
  INTEGER(INT32) :: rc, nrows, slen
  LOGICAL :: has_row

  rc = corm_f2018_open(db, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2018_exec(db, "CREATE TABLE slice18(a REAL, b REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "CREATE TABLE iv18(k INT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  full_grid(:, 1) = [10.0_REAL64, 20.0_REAL64, 30.0_REAL64, &
                     40.0_REAL64, 50.0_REAL64, 60.0_REAL64]
  full_grid(:, 2) = [1.0_REAL64, 2.0_REAL64, 3.0_REAL64, &
                     4.0_REAL64, 5.0_REAL64, 6.0_REAL64]

  ! Non-contiguous strided slice `full_grid(1:6:2, :)` (rows 1, 3, 5)!
  rc = corm_f2018_insert_any_rank(db, "INSERT INTO slice18 VALUES(?,?)", &
                                  full_grid(1:6:2, :))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  recv_grid = 0.0_REAL64
  ! Hydrate directly into non-contiguous strided slice `recv_grid(2:6:2, :)`!
  rc = corm_f2018_query_any_rank(db, "SELECT a, b FROM slice18", &
                                 recv_grid(2:6:2, :), nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 3_INT32) ERROR STOP 1
  IF (ABS(recv_grid(2, 1) - 10.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
  IF (ABS(recv_grid(4, 1) - 30.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
  IF (ABS(recv_grid(6, 2) - 5.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1

  ! Rank-1 INT32 vector via the exact same assumed-rank CFI interface!
  ivec_in = [11_INT32, 22_INT32, 33_INT32, 44_INT32]
  rc = corm_f2018_insert_any_rank(db, "INSERT INTO iv18 VALUES(?)", ivec_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  ivec_out = 0_INT32
  rc = corm_f2018_query_any_rank(db, "SELECT k FROM iv18", ivec_out, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 4_INT32) ERROR STOP 1
  IF (ANY(ivec_in /= ivec_out)) ERROR STOP 1

  ! Direct CHARACTER(LEN=*) CFI column read
  rc = stmt%prepare(db, "SELECT 'TS29113_CFI'")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) ERROR STOP 1
  rc = fortran_orm_cfi_col_str(stmt%ptr, 1_INT32, col_txt, slen)
  IF (rc /= FORTRAN_ORM_OK .OR. col_txt(1:slen) /= "TS29113_CFI") ERROR STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A)', "PASS: Fortran 2018"
END PROGRAM era_11_fortran_2018
