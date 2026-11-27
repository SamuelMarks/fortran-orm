!> @file era_12_fortran_2023.f90
!> @brief End-to-end ISO/IEC 1539-1:2023 Fortran 2023 F_C_STRING, umbrella
!> module, and 38-digit decimal verification suite.
PROGRAM era_12_fortran_2023
  USE fortran_orm
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  REAL(REAL64), DIMENSION(2, 2) :: g_in, g_out
  CHARACTER(LEN=:), ALLOCATABLE :: dec_sum, uuid_val
  INTEGER(INT32) :: rc, nrows

  rc = corm_f2023_open(db, ":memory:   ", ASIS=.FALSE.)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2023_exec(db, "CREATE TABLE f23_mesh(u REAL, v REAL)   ", &
                       ASIS=.FALSE.)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  g_in = RESHAPE([1.5_REAL64, 2.5_REAL64, 3.5_REAL64, 4.5_REAL64], [2, 2])
  rc = corm_f2018_insert_any_rank(db, "INSERT INTO f23_mesh VALUES(?,?)", g_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  g_out = 0.0_REAL64
  rc = corm_f2018_query_any_rank(db, "SELECT u, v FROM f23_mesh", g_out, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 2_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(g_in - g_out)) > 1.0E-12_REAL64) ERROR STOP 1

  rc = corm_f2023_dec_add_str("bad", "0.875", dec_sum)
  IF (rc == FORTRAN_ORM_OK .OR. dec_sum /= "") ERROR STOP 1
  rc = corm_f2023_dec_add_str("1.0", "bad", dec_sum)
  IF (rc == FORTRAN_ORM_OK .OR. dec_sum /= "") ERROR STOP 1
  rc = corm_f2023_dec_add_str("99999999999999999999999999999999999999", &
                              "5", dec_sum)
  IF (rc == FORTRAN_ORM_OK .OR. dec_sum /= "") ERROR STOP 1
  rc = corm_f2023_dec_add_str("123456789012345678901234567890.125", &
                              "0.875", dec_sum)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  IF (dec_sum /= "123456789012345678901234567891.000") ERROR STOP 1

  rc = corm_f2003_uuid_v4(uuid_val)
  IF (rc /= FORTRAN_ORM_OK .OR. LEN(uuid_val) /= 36) ERROR STOP 1

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A)', "PASS: Fortran 2023"
END PROGRAM era_12_fortran_2023
