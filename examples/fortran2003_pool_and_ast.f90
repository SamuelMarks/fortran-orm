!> @file fortran2003_pool_and_ast.f90
!> @brief ISO Fortran 2003 RAII connection pool, multi-dialect AST, and JSON
!> result-set serialization example.
PROGRAM fortran2003_pool_and_ast
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT, C_INT32_T, C_INT64_T, C_DOUBLE
  USE fortran_orm_f2003
  IMPLICIT NONE

  TYPE(orm_pool_t) :: pool
  TYPE(orm_db_t) :: db
  TYPE(orm_stmt_t) :: stmt
  TYPE(orm_ast_t) :: ast
  TYPE(orm_rs_t) :: rs
  CHARACTER(LEN=:), ALLOCATABLE :: pg_sql, db2_sql, odbc_sql, top_run, json_doc
  LOGICAL :: has_row
  INTEGER(C_INT) :: rc
  INTEGER(C_INT32_T) :: pcnt, nrows

  rc = pool%init(":memory:", 1_C_INT32_T, 2_C_INT32_T, 500_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = pool%acquire(db)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. db%is_open()) STOP 1

  rc = db%exec("CREATE TABLE collider_runs(run_no INTEGER, tag TEXT, lumi REAL)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = db%tx_begin()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%prepare(db, "INSERT INTO collider_runs VALUES(?,?,?)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = stmt%bind_i64(1_C_INT32_T, 401001_C_INT64_T)
  IF (rc == FORTRAN_ORM_OK) rc = stmt%bind_str(2_C_INT32_T, "ATLAS_HI_LUMI")
  IF (rc == FORTRAN_ORM_OK) rc = stmt%bind_f64(3_C_INT32_T, 2.45_C_DOUBLE)
  IF (rc == FORTRAN_ORM_OK) rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = stmt%prepare(db, "INSERT INTO collider_runs VALUES(?,?,?)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_i64(1_C_INT32_T, 401002_C_INT64_T)
  IF (rc == FORTRAN_ORM_OK) rc = stmt%bind_str(2_C_INT32_T, "CMS_CALIB")
  IF (rc == FORTRAN_ORM_OK) rc = stmt%bind_f64(3_C_INT32_T, 1.15_C_DOUBLE)
  IF (rc == FORTRAN_ORM_OK) rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%tx_commit()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! Compile a single AST across PostgreSQL, IBM Db2, and ANSI ODBC 3.52
  rc = ast%select_from("collider_runs", "run_no, tag, lumi")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%where_i64("run_no", ">", 401000_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%order_limit("lumi", .TRUE., 5_C_INT32_T, 0_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = ast%to_sql(FORTRAN_ORM_DIALECT_POSTGRES, pg_sql, pcnt)
  IF (rc /= FORTRAN_ORM_OK .OR. pcnt /= 1_C_INT32_T .OR. &
      INDEX(pg_sql, "$1") == 0) STOP 1

  rc = ast%to_sql(FORTRAN_ORM_DIALECT_DB2, db2_sql, pcnt)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(db2_sql, "FETCH FIRST") == 0) STOP 1

  rc = ast%select_from("collider_runs", "run_no, tag, lumi")
  IF (rc == FORTRAN_ORM_OK) rc = ast%order_limit("lumi", .TRUE., &
                                                 5_C_INT32_T, 1_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%to_sql(FORTRAN_ORM_DIALECT_ODBC, odbc_sql, pcnt)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(odbc_sql, "FETCH NEXT") == 0) STOP 1

  rc = rs%query(db, "SELECT tag, lumi FROM collider_runs ORDER BY lumi DESC")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%row_count(nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 2_C_INT32_T) STOP 1
  rc = rs%get_str(1_C_INT32_T, "tag", top_run)
  IF (rc /= FORTRAN_ORM_OK .OR. top_run /= "ATLAS_HI_LUMI") STOP 1
  rc = rs%to_json(json_doc)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_doc, "CMS_CALIB") == 0) STOP 1

  rc = pool%release(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%destroy()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  PRINT '(A)', db2_sql
END PROGRAM fortran2003_pool_and_ast
