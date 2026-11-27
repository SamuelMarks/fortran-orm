!> @file era_09_fortran_2003.f90
!> @brief End-to-end ISO/IEC 1539-1:2004 Fortran 2003 OOP, RAII, BIND(C)
!> reflection, polymorphic `ABSTRACT` models, decimal, sharding, OAuth2,
!> migration, and EBCDIC/UTF-16/A1 verification suite.
MODULE era_09_models_mod
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  USE fortran_orm_f2003_ext
  IMPLICIT NONE
  PRIVATE

  !> @type sensor_pod_t
  !> @brief BIND(C) derived type persisted via runtime struct reflection.
  TYPE, BIND(C), PUBLIC :: sensor_pod_t
    INTEGER(C_INT32_T) :: id
    INTEGER(C_INT32_T) :: ver
    REAL(C_DOUBLE) :: reading
    CHARACTER(KIND=C_CHAR) :: label(16)
  END TYPE sensor_pod_t

  !> @type site_pod_t
  !> @brief Parent BIND(C) derived type for relation metadata testing.
  TYPE, BIND(C), PUBLIC :: site_pod_t
    INTEGER(C_INT32_T) :: site_id
    INTEGER(C_INT32_T) :: region_code
  END TYPE site_pod_t

  !> @type particle_pod_t
  !> @brief Backing BIND(C) payload for polymorphic `particle_model_t`.
  TYPE, BIND(C), PUBLIC :: particle_pod_t
    INTEGER(C_INT32_T) :: id
    INTEGER(C_INT32_T) :: charge
    REAL(C_DOUBLE) :: mass_gev
  END TYPE particle_pod_t

  !> @type particle_model_t
  !> @brief Concrete Fortran 2003 ActiveRecord extending `orm_model_base_t`.
  TYPE, EXTENDS(orm_model_base_t), PUBLIC :: particle_model_t
    INTEGER(C_INT32_T) :: charge = 0_C_INT32_T
    REAL(C_DOUBLE) :: mass_gev = 0.0_C_DOUBLE
  CONTAINS
    PROCEDURE :: configure_schema => particle_configure_schema
    PROCEDURE :: save => particle_save
    PROCEDURE :: load_by_id => particle_load_by_id
  END TYPE particle_model_t

CONTAINS

  !> @brief Configures runtime reflection columns for `particle_model_t`.
  !> @param[in] self Polymorphic particle model instance.
  !> @param[inout] schema Runtime reflection schema to populate.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION particle_configure_schema(self, schema) RESULT(rc)
    CLASS(particle_model_t), INTENT(IN) :: self
    CLASS(orm_schema_t), INTENT(INOUT) :: schema
    INTEGER(C_INT) :: rc
    IF (self%pk_id < -999999_C_INT32_T) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    rc = schema%create("particles03", 16_C_INT32_T)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, &
                        0_C_INT32_T, .TRUE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("charge", FORTRAN_ORM_COL_INT32, 4_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("mass_gev", FORTRAN_ORM_COL_FLOAT64, 8_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
  END FUNCTION particle_configure_schema

  !> @brief Persists `self` via runtime `UPSERT` onto `db`.
  !> @param[inout] self Polymorphic particle model instance.
  !> @param[in] db Active database connection.
  !> @param[inout] schema Configured runtime reflection schema.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION particle_save(self, db, schema) RESULT(rc)
    CLASS(particle_model_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CLASS(orm_schema_t), INTENT(INOUT) :: schema
    INTEGER(C_INT) :: rc
    TYPE(particle_pod_t), TARGET :: pod
    pod%id = self%pk_id
    pod%charge = self%charge
    pod%mass_gev = self%mass_gev
    rc = schema%upsert_ptr(db, C_LOC(pod))
  END FUNCTION particle_save

  !> @brief Hydrates `id_val` from `db` into polymorphic `self`.
  !> @param[inout] self Polymorphic particle model instance.
  !> @param[in] db Active database connection.
  !> @param[inout] schema Configured runtime reflection schema.
  !> @param[in] id_val 32-bit primary key value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION particle_load_by_id(self, db, schema, id_val) RESULT(rc)
    CLASS(particle_model_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CLASS(orm_schema_t), INTENT(INOUT) :: schema
    INTEGER(C_INT32_T), INTENT(IN) :: id_val
    INTEGER(C_INT) :: rc
    TYPE(particle_pod_t), TARGET :: pod
    pod%id = 0_C_INT32_T
    pod%charge = 0_C_INT32_T
    pod%mass_gev = 0.0_C_DOUBLE
    rc = schema%find_i32_ptr(db, id_val, C_LOC(pod))
    IF (rc == FORTRAN_ORM_OK) THEN
      self%pk_id = pod%id
      self%charge = pod%charge
      self%mass_gev = pod%mass_gev
    END IF
  END FUNCTION particle_load_by_id

END MODULE era_09_models_mod

!> @brief Main Fortran 2003 era verification driver.
PROGRAM era_09_fortran_2003
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  USE fortran_orm_f2003_ext
  USE era_09_models_mod
  IMPLICIT NONE

  TYPE(orm_db_t) :: db, leased_db, shard_db1, shard_db2, raii_db, zero_db
  TYPE(orm_stmt_t) :: stmt, raii_stmt, zero_stmt
  TYPE(orm_ast_t) :: ast, raii_ast, zero_ast
  TYPE(orm_rs_t) :: rs, raii_rs, zero_rs
  TYPE(orm_pool_t) :: pool, raii_pool, zero_pool
  TYPE(orm_schema_t) :: schema, site_schema, p_schema, raii_schema, zero_schema
  TYPE(orm_tx_guard_t) :: tx_guard, guard_uncommitted, zero_guard
  TYPE(orm_decimal_t) :: d1, d2, d3
  TYPE(orm_migration_t) :: mig, raii_mig, zero_mig
  TYPE(orm_shard_router_t) :: router, raii_shard, zero_shard
  TYPE(orm_oauth2_store_t) :: oauth
  TYPE(fortran_orm_pool_stats) :: stats
  TYPE(fortran_orm_decimal) :: pod_dec_in, pod_dec_out
  TYPE(sensor_pod_t), TARGET :: rec_in, rec_out, all_recs(4)
  TYPE(site_pod_t), TARGET :: site_in
  CLASS(orm_model_base_t), ALLOCATABLE :: poly_model
  TYPE(particle_model_t) :: p_loaded
  CHARACTER(LEN=:), ALLOCATABLE :: ver_str, uuid_str, sql_str, json_str
  CHARACTER(LEN=:), ALLOCATABLE :: val_str, err_msg, trace_msg, esc_str
  CHARACTER(LEN=:), ALLOCATABLE :: ddl_str, cname, ename, uid_out, scp_out
  CHARACTER(LEN=:), ALLOCATABLE :: mig_ver
  INTEGER(C_INT8_T) :: ebcdic_buf(32)
  INTEGER(C_INT16_T) :: u16_buf(32)
  INTEGER(C_INT32_T) :: a1_buf(32)
  CHARACTER(LEN=64) :: mig_dir, mig_file
  INTEGER(C_INT) :: rc
  INTEGER(C_INT32_T) :: pcount, nrows, ncols, i, iv32, cmp_res, shard_slot
  INTEGER(C_INT32_T) :: n_ebcdic, n_u16, n_a1, exp_out, n_applied, n_rem
  INTEGER(C_INT64_T) :: iv64, rowid
  REAL(C_FLOAT) :: fv32
  REAL(C_DOUBLE) :: fv64
  LOGICAL :: has_row, is_nul, bflag, ex_flag, scp_ok

  rc = corm_f2003_version(ver_str)
  IF (rc /= FORTRAN_ORM_OK .OR. ver_str /= "0.1.0") STOP 1
  rc = corm_f2003_uuid_v4(uuid_str)
  IF (rc /= FORTRAN_ORM_OK .OR. LEN(uuid_str) /= 36) STOP 1
  rc = corm_f2003_error_name(FORTRAN_ORM_OK, ename)
  IF (rc /= FORTRAN_ORM_OK .OR. ename /= "FORTRAN_ORM_OK") STOP 1

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. db%is_open()) STOP 1
  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. db%is_open()) STOP 1

  ! Session controls, savepoints, trace, escape, telemetry
  rc = db%enable_cache(8_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%set_timezone(0_C_INT32_T, "UTC")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%set_slow_ms(250_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%escape_str("O'Neill", esc_str)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(esc_str, "''") == 0) STOP 1

  rc = db%tx_begin()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%savepoint("sp_a")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%rollback_sp("sp_a")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%release_sp("sp_a")
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
  rc = db%last_trace(trace_msg)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%telemetry(stats)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! 1. Runtime BIND(C) struct reflection CRUD (insert, upsert, update, opt, lock, find_all, delete)
  rc = site_schema%create("sites", 8_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = site_schema%add_col("site_id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, &
                           0_C_INT32_T, .TRUE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = site_schema%add_col("region_code", FORTRAN_ORM_COL_INT32, 4_C_INT32_T, &
                           0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = site_schema%create_table(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  site_in%site_id = 2003_C_INT32_T
  site_in%region_code = 42_C_INT32_T
  rc = site_schema%insert_ptr(db, C_LOC(site_in))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = schema%create("sensors", 32_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%create("sensors", 32_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, &
                      0_C_INT32_T, .TRUE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("ver", FORTRAN_ORM_COL_INT32, 4_C_INT32_T, &
                      0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("reading", FORTRAN_ORM_COL_FLOAT64, 8_C_INT32_T, &
                      0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("label", FORTRAN_ORM_COL_CHAR_FIXED, 16_C_INT32_T, &
                      16_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = site_schema%add_relation("sensors_rel", FORTRAN_ORM_REL_ONE_TO_MANY, &
                                schema, "id", "site_id")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%build_ddl(ddl_str)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(ddl_str, "CREATE TABLE") == 0) STOP 1
  rc = schema%create_table(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rec_in%id = 2003_C_INT32_T
  rec_in%ver = 1_C_INT32_T
  rec_in%reading = 273.15_C_DOUBLE
  rec_in%label = " "
  DO i = 1_C_INT32_T, 6_C_INT32_T
    rec_in%label(i) = "KELVIN"(i:i)
  END DO
  rc = schema%insert_ptr(db, C_LOC(rec_in))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%last_rowid(rowid)
  IF (rc /= FORTRAN_ORM_OK .OR. rowid <= 0_C_INT64_T) STOP 1

  rec_in%reading = 298.15_C_DOUBLE
  rc = schema%update_ptr(db, C_LOC(rec_in))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rec_in%ver = 2_C_INT32_T
  rc = schema%update_opt_ptr(db, "ver", C_LOC(rec_in))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rec_in%ver = 3_C_INT32_T
  rec_in%reading = 310.15_C_DOUBLE
  rc = schema%upsert_ptr(db, C_LOC(rec_in))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = schema%exists_i32(db, 2003_C_INT32_T, ex_flag)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. ex_flag) STOP 1
  rc = schema%find_i32_ptr(db, 2003_C_INT32_T, C_LOC(rec_out))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  IF (ABS(rec_out%reading - 310.15_C_DOUBLE) > 1.0D-9) STOP 1
  rc = schema%find_lock_ptr(db, 2003_C_INT32_T, C_LOC(rec_out))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%find_all_ptr(db, C_LOC(all_recs(1)), 4_C_INT32_T, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 1_C_INT32_T) STOP 1

  ! 2. Fluent AST across SELECT, INSERT, UPDATE, DELETE, JOIN, GROUP, RETURNING
  rc = ast%select_from("sensors", "id, reading, label")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%distinct()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%join("LEFT", "sensors s2", "sensors.id = s2.id")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%where_i64("sensors.id", "=", 2003_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%where_str("sensors.label", "LIKE", "KEL%")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%group_having("sensors.id", "COUNT(*) >= 1")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%order_limit("sensors.id", .TRUE., 5_C_INT32_T, 0_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%returning_lock("", 1_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%to_sql(FORTRAN_ORM_DIALECT_DB2, sql_str, pcount)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(sql_str, "WITH UR") == 0) STOP 1

  rc = db%exec("CREATE TABLE ast_kv(k INT, v TEXT)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%insert_into("ast_kv")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%set_i64("k", 7_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%set_str("v", "SEVEN")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%exec(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = ast%update_table("ast_kv")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%set_str("v", "SEVEN_UP")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%where_i64("k", "=", 7_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%exec(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = ast%select_from("ast_kv", "k, v")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%query_rs(db, rs)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%row_count(nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 1_C_INT32_T) STOP 1
  rc = rs%col_count(1_C_INT32_T, ncols)
  IF (rc /= FORTRAN_ORM_OK .OR. ncols /= 2_C_INT32_T) STOP 1
  rc = rs%col_name(1_C_INT32_T, 2_C_INT32_T, cname)
  IF (rc /= FORTRAN_ORM_OK .OR. cname /= "v") STOP 1
  rc = rs%is_null(1_C_INT32_T, "v", is_nul)
  IF (rc /= FORTRAN_ORM_OK .OR. is_nul) STOP 1
  rc = rs%get_i64(1_C_INT32_T, "k", iv64)
  IF (rc /= FORTRAN_ORM_OK .OR. iv64 /= 7_C_INT64_T) STOP 1
  rc = rs%get_str(1_C_INT32_T, "v", val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "SEVEN_UP") STOP 1

  rc = ast%delete_from("ast_kv")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%where_i64("k", "=", 7_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%exec(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! 3. Dynamic abstract result set + JSON + f64
  rc = rs%query(db, "SELECT id, reading, label FROM sensors")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%get_f64(1_C_INT32_T, "reading", fv64)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(fv64 - 310.15_C_DOUBLE) > 1.0D-9) STOP 1
  rc = rs%to_json(json_str)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_str, "KELVIN") == 0) STOP 1
  rc = schema%delete_i32(db, 2003_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! 4. Prepared statement generic `bind` & `col` overloads + cached prepare
  rc = db%exec( &
    "CREATE TABLE st03(i32 INT, i64 INT, f32 REAL, f64 REAL, " // &
    "b INT, s TEXT, raw_s TEXT, dec_s TEXT, nul_c INT)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d1%from_str("9876543210.125")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  pod_dec_in = d1%pod

  rc = stmt%prepare_cached(db, &
    "INSERT INTO st03 VALUES(?,?,?,?,?,?,?,?,?)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%prepare_cached(db, &
    "INSERT INTO st03 VALUES(?,?,?,?,?,?,?,?,?)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(1_C_INT32_T, 42_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(2_C_INT32_T, 9000000000_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(3_C_INT32_T, 2.5_C_FLOAT)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(4_C_INT32_T, 3.14_C_DOUBLE)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(5_C_INT32_T, .TRUE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(6_C_INT32_T, "KELVIN")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_str_raw(7_C_INT32_T, "RAW ")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(8_C_INT32_T, pod_dec_in)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind_null(9_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%reset()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = stmt%prepare(db, "SELECT * FROM st03 WHERE i32 = ?")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%bind(1_C_INT32_T, 42_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) STOP 1
  rc = stmt%col_count(ncols)
  IF (rc /= FORTRAN_ORM_OK .OR. ncols /= 9_C_INT32_T) STOP 1
  rc = stmt%col_name(1_C_INT32_T, cname)
  IF (rc /= FORTRAN_ORM_OK .OR. cname /= "i32") STOP 1
  rc = stmt%col(1_C_INT32_T, iv32)
  IF (rc /= FORTRAN_ORM_OK .OR. iv32 /= 42_C_INT32_T) STOP 1
  rc = stmt%col(2_C_INT32_T, iv64)
  IF (rc /= FORTRAN_ORM_OK .OR. iv64 /= 9000000000_C_INT64_T) STOP 1
  rc = stmt%col(3_C_INT32_T, fv32)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(fv32 - 2.5_C_FLOAT) > 1.0E-5_C_FLOAT) STOP 1
  rc = stmt%col(4_C_INT32_T, fv64)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(fv64 - 3.14_C_DOUBLE) > 1.0D-9) STOP 1
  rc = stmt%col(5_C_INT32_T, bflag)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. bflag) STOP 1
  rc = stmt%col(6_C_INT32_T, val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "KELVIN") STOP 1
  rc = stmt%col(8_C_INT32_T, pod_dec_out)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%col_is_null(9_C_INT32_T, is_nul)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. is_nul) STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%enable_cache(0_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! 5. Connection pool + telemetry
  rc = pool%init(":memory:", 1_C_INT32_T, 2_C_INT32_T, 100_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%init(":memory:", 1_C_INT32_T, 2_C_INT32_T, 100_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%acquire(leased_db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = leased_db%exec("CREATE TABLE ptest(x INT)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%telemetry(stats)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%release(leased_db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = pool%destroy()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! 6. `orm_tx_guard_t` (tx commit, tx rollback, savepoint commit, savepoint rollback, RAII FINAL)
  rc = db%exec("CREATE TABLE guard03(v INT)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%begin(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%exec("INSERT INTO guard03 VALUES(10)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%commit()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%commit()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%rollback()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = db%tx_begin()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%begin_sp(db, "g_sp1")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%begin_sp(db, "g_sp1")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%exec("INSERT INTO guard03 VALUES(20)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%rollback()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%begin_sp(db, "g_sp2")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%exec("INSERT INTO guard03 VALUES(30)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = tx_guard%commit()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%tx_commit()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! 7. `orm_decimal_t` OOP 38-digit fixed-point operations
  rc = d1%from_i64(-125_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. d1%is_negative()) STOP 1
  rc = d2%from_str("25.50")
  IF (rc /= FORTRAN_ORM_OK .OR. d2%is_negative()) STOP 1
  rc = d1%add(d2, d3)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d3%to_str(val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "-99.50") STOP 1
  rc = d2%sub(d1, d3)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d3%mul(d2, 4_C_INT32_T, FORTRAN_ORM_ROUND_HALF_EVEN, d1)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d1%div(d2, 2_C_INT32_T, FORTRAN_ORM_ROUND_HALF_UP, d3)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d3%cmp(d2, cmp_res)
  IF (rc /= FORTRAN_ORM_OK .OR. cmp_res <= 0_C_INT32_T) STOP 1
  rc = d3%rescale(18_C_INT32_T, 1_C_INT32_T, FORTRAN_ORM_ROUND_TRUNCATE, d1)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d1%to_i64(FORTRAN_ORM_ROUND_HALF_UP, iv64)
  IF (rc /= FORTRAN_ORM_OK .OR. iv64 /= 151_C_INT64_T) STOP 1

  ! 8. `orm_migration_t` with temporary `.sql` file
  mig_dir = "era09_mig_" // uuid_str(1:8)
  CALL EXECUTE_COMMAND_LINE_F03(mig_dir, mig_file)
  rc = mig%init(db, TRIM(mig_dir))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = mig%init(db, TRIM(mig_dir))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = mig%up(.FALSE., n_applied)
  IF (rc /= FORTRAN_ORM_OK .OR. n_applied /= 1_C_INT32_T) STOP 1
  rc = mig%version(mig_ver)
  IF (rc /= FORTRAN_ORM_OK .OR. LEN(mig_ver) == 0) STOP 1
  rc = mig%down(1_C_INT32_T, .FALSE., n_rem)
  IF (rc /= FORTRAN_ORM_OK .OR. n_rem /= 0_C_INT32_T) STOP 1

  ! Exercise all 9 RAII `FINAL` destructors via ISO Fortran 2003 §4.5.5.2
  ! intrinsic assignment finalization (`lhs = zero_*` finalizes `lhs`).
  rc = raii_db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = raii_stmt%prepare(raii_db, "SELECT 1")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = raii_pool%init(":memory:", 1_C_INT32_T, 1_C_INT32_T, 50_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = raii_rs%query(raii_db, "SELECT 1 AS k")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = raii_ast%select_from("t", "*")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = raii_schema%create("tmp_s", 8_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = raii_shard%init(2_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = raii_mig%init(raii_db, TRIM(mig_dir))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = guard_uncommitted%begin(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%exec("INSERT INTO guard03 VALUES(999)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  raii_stmt = zero_stmt
  raii_rs = zero_rs
  raii_ast = zero_ast
  raii_schema = zero_schema
  raii_shard = zero_shard
  raii_mig = zero_mig
  raii_pool = zero_pool
  raii_db = zero_db
  guard_uncommitted = zero_guard
  CALL CLEANUP_MIG_F03(mig_dir, mig_file)

  ! Verify guard_uncommitted rolled back row 999 on scope exit!
  rc = rs%query(db, "SELECT v FROM guard03 ORDER BY v")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%row_count(nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 2_C_INT32_T) STOP 1

  ! 9. `orm_shard_router_t` & `orm_oauth2_store_t`
  rc = shard_db1%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = shard_db2%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = router%init(2_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = router%init(2_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = router%add_node(1_C_INT32_T, shard_db1)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = router%add_node(2_C_INT32_T, shard_db2)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = router%route("tenant_alpha", shard_slot)
  IF (rc /= FORTRAN_ORM_OK .OR. shard_slot < 1_C_INT32_T .OR. &
      shard_slot > 2_C_INT32_T) STOP 1
  rc = router%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = oauth%init_tables(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = oauth%save("tok_f2003", "ref_f2003", "dr_hopper", &
                  "mesh:read mesh:write", 3600_C_INT32_T, 4102444800_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = oauth%fetch("tok_f2003", uid_out, scp_out, exp_out)
  IF (rc /= FORTRAN_ORM_OK .OR. uid_out /= "dr_hopper" .OR. &
      exp_out /= 3600_C_INT32_T) STOP 1
  rc = oauth%check_scopes(scp_out, "mesh:read", scp_ok)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. scp_ok) STOP 1
  rc = oauth%revoke("tok_f2003")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = oauth%fetch("tok_f2003", uid_out, scp_out, exp_out)
  IF (rc /= FORTRAN_ORM_ERROR_NOT_FOUND) STOP 1

  ! 10. Polymorphic `CLASS(orm_model_base_t)` ActiveRecord dispatch
  ALLOCATE(particle_model_t :: poly_model)
  SELECT TYPE (poly_model)
  TYPE IS (particle_model_t)
    poly_model%pk_id = 125_C_INT32_T
    poly_model%charge = 0_C_INT32_T
    poly_model%mass_gev = 125.25_C_DOUBLE
  END SELECT
  rc = poly_model%configure_schema(p_schema)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = p_schema%create_table(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = poly_model%save(db, p_schema)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = p_loaded%load_by_id(db, p_schema, 125_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  IF (ABS(p_loaded%mass_gev - 125.25_C_DOUBLE) > 1.0D-9) STOP 1
  DEALLOCATE(poly_model)

  ! 11. EBCDIC, UTF-16 `GRAPHIC`, and unpacked `A1` codecs
  rc = corm_f2003_utf8_to_ebcdic(FORTRAN_ORM_CP_IBM037, "IBM704", &
                                 ebcdic_buf, n_ebcdic)
  IF (rc /= FORTRAN_ORM_OK .OR. n_ebcdic /= 6_C_INT32_T) STOP 1
  rc = corm_f2003_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, ebcdic_buf, &
                                 n_ebcdic, val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "IBM704") STOP 1

  rc = corm_f2003_utf8_to_utf16("DB2_ZOS", .TRUE., u16_buf, n_u16)
  IF (rc /= FORTRAN_ORM_OK .OR. n_u16 /= 7_C_INT32_T) STOP 1
  rc = corm_f2003_utf16_to_utf8(u16_buf, n_u16, .TRUE., val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "DB2_ZOS") STOP 1

  rc = corm_f2003_str_to_a1("HOLLERITH", a1_buf, n_a1)
  IF (rc /= FORTRAN_ORM_OK .OR. n_a1 /= 9_C_INT32_T) STOP 1
  rc = corm_f2003_a1_to_str(a1_buf, n_a1, val_str)
  IF (rc /= FORTRAN_ORM_OK .OR. val_str /= "HOLLERITH") STOP 1

  rc = mig%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = ast%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = p_schema%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = site_schema%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%free()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = shard_db1%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = shard_db2%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  PRINT '(A)', "PASS: Fortran 2003"

CONTAINS

  !> @brief Creates a temporary `.sql` migration file in the current directory.
  !> @param[out] out_dir Migration directory path (`"."` when using current dir).
  !> @param[out] out_file Created `.sql` migration filename.
  SUBROUTINE EXECUTE_COMMAND_LINE_F03(out_dir, out_file)
    CHARACTER(LEN=*), INTENT(INOUT) :: out_dir
    CHARACTER(LEN=*), INTENT(OUT) :: out_file
    INTEGER :: u, ios
    out_file = "9991_era09_mig_test.sql"
    out_dir = "."
    u = 77
    OPEN(UNIT=u, FILE=TRIM(out_file), STATUS="REPLACE", ACTION="WRITE", &
         IOSTAT=ios)
    IF (ios /= 0) STOP 1
    WRITE (u, '(A)') "-- UP"
    WRITE (u, '(A)') "CREATE TABLE mig03_test(id INT PRIMARY KEY);"
    WRITE (u, '(A)') "-- DOWN"
    WRITE (u, '(A)') "DROP TABLE mig03_test;"
    CLOSE(u)
  END SUBROUTINE EXECUTE_COMMAND_LINE_F03

  !> @brief Deletes the temporary `.sql` migration file using standard F2003 I/O.
  !> @param[in] dir_unused Directory path placeholder.
  !> @param[in] file_path Temporary `.sql` file to remove.
  SUBROUTINE CLEANUP_MIG_F03(dir_unused, file_path)
    CHARACTER(LEN=*), INTENT(IN) :: dir_unused, file_path
    INTEGER :: u, ios
    IF (LEN_TRIM(dir_unused) < 0) STOP 1
    u = 78
    OPEN(UNIT=u, FILE=TRIM(file_path), STATUS="OLD", IOSTAT=ios)
    IF (ios == 0) CLOSE(u, STATUS="DELETE")
  END SUBROUTINE CLEANUP_MIG_F03

END PROGRAM era_09_fortran_2003
