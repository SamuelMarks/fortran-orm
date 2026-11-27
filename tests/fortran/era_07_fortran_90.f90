!> @file era_07_fortran_90.f90
!> @brief End-to-end ISO/IEC 1539:1991 Fortran 90 ORM verification suite.
PROGRAM era_07_fortran_90
  USE fortran_orm_f90
  IMPLICIT NONE

  TYPE(corm_db_f90) :: db
  TYPE(corm_stmt_f90) :: stmt
  TYPE(corm_ast_f90) :: ast
  DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: m_in, m_out
  CHARACTER(LEN=64) :: str_val
  CHARACTER(LEN=128) :: sql_rendered
  INTEGER :: rc, iv, slen, nrows
  DOUBLE PRECISION :: dv
  LOGICAL :: has_row

  CALL corm_f90_open(":memory:", db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_exec(db, "CREATE TABLE f90_items(id INT, score REAL, tag TEXT)", rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_tx_begin(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_prepare(db, "INSERT INTO f90_items VALUES(?,?,?)", stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind(stmt, 1, 90, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind(stmt, 2, 99.5D0, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind(stmt, 3, "ISO1991", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_finalize(stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_tx_commit(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_prepare(db, "SELECT id, score, tag FROM f90_items", stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. has_row) STOP 1
  CALL corm_f90_col(stmt, 1, iv, rc)
  IF (rc /= CORM_F90_OK .OR. iv /= 90) STOP 1
  CALL corm_f90_col(stmt, 2, dv, rc)
  IF (rc /= CORM_F90_OK .OR. ABS(dv - 99.5D0) > 1.0D-9) STOP 1
  CALL corm_f90_col(stmt, 3, str_val, slen, rc)
  IF (rc /= CORM_F90_OK .OR. str_val(1:slen) /= "ISO1991") STOP 1
  CALL corm_f90_finalize(stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_exec(db, "CREATE TABLE f90_mat(c1 REAL, c2 REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  ALLOCATE(m_in(3, 2), m_out(3, 2))
  m_in(:, 1) = (/ 1.0D0, 2.0D0, 3.0D0 /)
  m_in(:, 2) = (/ 4.0D0, 5.0D0, 6.0D0 /)
  CALL corm_f90_insert_matrix(db, "INSERT INTO f90_mat VALUES(?,?)", m_in, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_matrix(db, "SELECT c1, c2 FROM f90_mat", m_out, nrows, rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 3) STOP 1
  IF (ABS(m_out(3, 2) - 6.0D0) > 1.0D-9) STOP 1
  DEALLOCATE(m_in, m_out)

  CALL corm_f90_ast_select("f90_mat", 10, ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_DB2, sql_rendered, slen, rc)
  IF (rc /= CORM_F90_OK .OR. slen <= 0) STOP 1
  CALL corm_f90_ast_free(ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_close(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  PRINT '(A)', "PASS: Fortran 90"
END PROGRAM era_07_fortran_90
