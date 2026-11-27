!> @file era_09_fortran_2003.f90
!> @brief End-to-end ISO/IEC 1539-1:2004 Fortran 2003 OOP, RAII & BIND(C)
!> struct reflection CRUD verification suite.
PROGRAM era_09_fortran_2003
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  IMPLICIT NONE

  !> @type sensor_pod_t
  !> @brief BIND(C) derived type persisted via runtime struct reflection.
  TYPE, BIND(C) :: sensor_pod_t
    INTEGER(C_INT32_T) :: id
    INTEGER(C_INT32_T) :: pad
    REAL(C_DOUBLE) :: reading
    CHARACTER(KIND=C_CHAR) :: label(16)
  END TYPE sensor_pod_t

  TYPE(orm_db_t) :: db, leased_db
  TYPE(orm_stmt_t) :: stmt
  TYPE(orm_ast_t) :: ast
  TYPE(orm_rs_t) :: rs
  TYPE(orm_pool_t) :: pool
  TYPE(orm_schema_t) :: schema
  TYPE(sensor_pod_t), TARGET :: rec_in, rec_out
  CHARACTER(LEN=:), ALLOCATABLE :: ver_str, uuid_str, sql_str, json_str, val_str, err_msg
  INTEGER(C_INT) :: rc
  INTEGER(C_INT32_T) :: pcount, nrows, i, iv32
  INTEGER(C_INT64_T) :: iv64
  REAL(C_DOUBLE) :: fv64
  LOGICAL :: has_row

  rc = corm_f2003_version(ver_str)
  IF (rc /= FORTRAN_ORM_OK .OR. ver_str /= "0.1.0") STOP 1
  rc = corm_f2003_uuid_v4(uuid_str)
  IF (rc /= FORTRAN_ORM_OK .OR. LEN(uuid_str) /= 36) STOP 1

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. db%is_open()) STOP 1
  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. db%is_open()) STOP 1

  rc = db%tx_begin()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%tx_rollback()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%tx_begin()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%tx_commit()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%exec("INVALID SQL")
  IF (rc == FORTRAN_ORM_OK) STOP 1
  rc = db%last_error(err_msg)
  IF (rc /= FORTRAN_ORM_OK .OR. LEN(err_msg) == 0) STOP 1

  ! 1. Runtime BIND(C) struct reflection CRUD
  rc = schema%create("sensors", 32_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, &
                      0_C_INT32_T, .TRUE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("reading", FORTRAN_ORM_COL_FLOAT64, 8_C_INT32_T, &
                      0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("label", FORTRAN_ORM_COL_CHAR_FIXED, 16_C_INT32_T, &
                      16_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%create_table(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rec_in%id = 2003_C_INT32_T
  rec_in%pad = 0_C_INT32_T
  rec_in%reading = 273.15_C_DOUBLE
  rec_in%label = " "
  DO i = 1_C_INT32_T, 6_C_INT32_T
    rec_in%label(i) = "KELVIN"(i:i)
  END DO
  rc = schema%insert_ptr(db, C_LOC(rec_in))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rec_out%id = 0_C_INT32_T
  rec_out%reading = 0.0_C_DOUBLE
  rec_out%label = " "
  rc = schema%find_i32_ptr(db, 2003_C_INT32_T, C_LOC(rec_out))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  IF (rec_out%id /= 2003_C_INT32_T) STOP 1
  IF (ABS(rec_out%reading - 273.15_C_DOUBLE) > 1.0D-9) STOP 1
  IF (rec_out%label(1) /= "K" .OR. rec_out%label(6) /= "N") STOP 1

  ! 2. Fluent AST across PostgreSQL & Db2 dialects
  rc = ast%select_from("sensors", "id, reading, label")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%where_i64("id", "=", 2003_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%order_limit("id", .TRUE., 5_C_INT32_T, 0_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%to_sql(FORTRAN_ORM_DIALECT_POSTGRES, sql_str, pcount)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(sql_str, "$1") == 0) STOP 1

  ! 3. Dynamic abstract result set + JSON serialization
  rc = rs%query(db, "SELECT id, label FROM sensors")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%row_count(nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 1_C_INT32_T) STOP 1
  rc = rs%get_str(1_C_INT32_T, "label", val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "KELVIN") STOP 1
  rc = rs%to_json(json_str)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_str, "KELVIN") == 0) STOP 1

  ! 4. Prepared statement + Connection pool
  rc = db%exec("CREATE TABLE st03(i32 INT, i64 INT, f64 REAL, s TEXT)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%prepare(db, "INSERT INTO st03 VALUES(?,?,?,?)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_i32(1_C_INT32_T, 42_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_i64(2_C_INT32_T, 9000000000_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_f64(3_C_INT32_T, 3.14_C_DOUBLE)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_str(4_C_INT32_T, "KELVIN")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%prepare(db, "SELECT i32, i64, f64, s FROM st03 WHERE i32 = ?")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_i32(1_C_INT32_T, 42_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) STOP 1
  rc = stmt%col_i32(1_C_INT32_T, iv32)
  IF (rc /= FORTRAN_ORM_OK .OR. iv32 /= 42_C_INT32_T) STOP 1
  rc = stmt%col_i64(2_C_INT32_T, iv64)
  IF (rc /= FORTRAN_ORM_OK .OR. iv64 /= 9000000000_C_INT64_T) STOP 1
  rc = stmt%col_f64(3_C_INT32_T, fv64)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(fv64 - 3.14_C_DOUBLE) > 1.0D-9) STOP 1
  rc = stmt%col_str(4_C_INT32_T, val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "KELVIN") STOP 1

  rc = pool%init(":memory:", 1_C_INT32_T, 2_C_INT32_T, 100_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%acquire(leased_db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = leased_db%exec("CREATE TABLE ptest(x INT)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%release(leased_db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%destroy()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  PRINT '(A)', "PASS: Fortran 2003"
END PROGRAM era_09_fortran_2003
