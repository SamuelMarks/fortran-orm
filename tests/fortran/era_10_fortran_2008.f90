!> @file era_10_fortran_2008.f90
!> @brief End-to-end ISO/IEC 1539-1:2010 Fortran 2008 SUBMODULE & CONTIGUOUS
!> zero-copy scientific array verification suite.
PROGRAM era_10_fortran_2008
  USE fortran_orm_f2008
  IMPLICIT NONE

  TYPE(orm_db_t) :: db
  REAL(REAL64), DIMENSION(4), TARGET :: v_in, v_out
  REAL(REAL64), DIMENSION(3, 3), TARGET :: m_in, m_out
  INTEGER(INT32) :: rc, n_elems, n_rows

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = db%exec("CREATE TABLE vec08(v REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE mat08(x REAL, y REAL, z REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  v_in = [1.25_REAL64, 2.50_REAL64, 3.75_REAL64, 5.00_REAL64]
  rc = corm_f2008_insert_vec_f64(db, "INSERT INTO vec08 VALUES(?)", v_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2008_query_vec_f64(db, "SELECT v FROM vec08", v_out, n_elems)
  IF (rc /= FORTRAN_ORM_OK .OR. n_elems /= 4_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(v_in - v_out)) > 1.0E-12_REAL64) ERROR STOP 1

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

  rc = corm_f2008_query_matrix_f64(db, "SELECT x, y, z FROM mat08", m_out, n_rows)
  IF (rc /= FORTRAN_ORM_OK .OR. n_rows /= 3_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(m_in - m_out)) > 1.0E-12_REAL64) ERROR STOP 1

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A)', "PASS: Fortran 2008"
END PROGRAM era_10_fortran_2008
