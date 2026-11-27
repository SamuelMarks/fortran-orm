!> @file era_08_fortran_95.f95
!> @brief End-to-end ISO/IEC 1539-1:1997 Fortran 95 ORM verification suite.
PROGRAM era_08_fortran_95
  USE fortran_orm_f95
  IMPLICIT NONE

  TYPE(corm_db_f95) :: db
  DOUBLE PRECISION, DIMENSION(3, 2) :: src_mat, dst_mat
  INTEGER, DIMENSION(3) :: statuses
  LOGICAL, DIMENSION(3) :: ok_flags
  INTEGER :: rc, nrows, i

  IF (corm_f95_db_is_open(db)) STOP 1
  CALL corm_f95_open(":memory:", db, statuses(1))
  IF (.NOT. corm_f95_db_is_open(db)) STOP 1

  CALL corm_f95_exec(db, "CREATE TABLE f95_grid(u REAL, v REAL)", statuses(2))
  CALL corm_f95_query_matrix(db, "SELECT u, v FROM f95_grid", dst_mat, nrows, rc)
  IF (.NOT. corm_f95_is_ok(rc) .OR. nrows /= 0) STOP 1

  FORALL (i = 1:3)
    src_mat(i, 1) = DBLE(i)
    src_mat(i, 2) = DBLE(i * 10)
  END FORALL

  CALL corm_f95_insert_scaled_matrix(db, "INSERT INTO f95_grid VALUES(?,?)", &
                                     src_mat, 2.5D0, statuses(3))
  ok_flags = corm_f95_is_ok(statuses)
  IF (.NOT. ALL(ok_flags)) STOP 1

  CALL corm_f95_query_matrix(db, "SELECT u, v FROM f95_grid", dst_mat, nrows, rc)
  IF (.NOT. corm_f95_is_ok(rc) .OR. nrows /= 3) STOP 1
  IF (ABS(dst_mat(3, 2) - 75.0D0) > 1.0D-9) STOP 1

  CALL corm_f95_close(db, rc)
  IF (.NOT. corm_f95_is_ok(rc) .OR. corm_f95_db_is_open(db)) STOP 1
  PRINT '(A)', "PASS: Fortran 95"
END PROGRAM era_08_fortran_95
