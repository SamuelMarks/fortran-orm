!> @file fortran_orm_f2003.f90
!> @module fortran_orm_f2003
!> @brief Idiomatic ISO/IEC 1539-1:2004 Fortran 2003 Object-Oriented &
!> ISO_C_BINDING ORM module.
!>
!> Wraps the cdd-c generated `fortran_orm_c` `BIND(C)` interfaces in RAII
!> extensible derived types (`orm_db_t`, `orm_stmt_t`, `orm_pool_t`,
!> `orm_ast_t`, `orm_rs_t`, `orm_schema_t`) with type-bound procedures,
!> generic `bind` and `col` overloads, automatic `FINAL` destructors,
!> deferred-length `CHARACTER(LEN=:), ALLOCATABLE` string helpers, and
!> `TYPE, BIND(C)` struct reflection CRUD.
MODULE fortran_orm_f2003
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_c
  IMPLICIT NONE
  PRIVATE

  PUBLIC :: FORTRAN_ORM_OK, FORTRAN_ORM_ERROR_NOT_FOUND
  PUBLIC :: FORTRAN_ORM_ERROR_VALIDATION, FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL
  PUBLIC :: FORTRAN_ORM_ERROR_DECIMAL_INEXACT
  PUBLIC :: FORTRAN_ORM_DIALECT_SQLITE, FORTRAN_ORM_DIALECT_POSTGRES
  PUBLIC :: FORTRAN_ORM_DIALECT_MYSQL, FORTRAN_ORM_DIALECT_DB2
  PUBLIC :: FORTRAN_ORM_DIALECT_ODBC
  PUBLIC :: FORTRAN_ORM_COL_INT32, FORTRAN_ORM_COL_INT64
  PUBLIC :: FORTRAN_ORM_COL_FLOAT32, FORTRAN_ORM_COL_FLOAT64
  PUBLIC :: FORTRAN_ORM_COL_BOOL, FORTRAN_ORM_COL_STRING
  PUBLIC :: FORTRAN_ORM_COL_BLOB, FORTRAN_ORM_COL_CHAR_FIXED
  PUBLIC :: FORTRAN_ORM_COL_DECIMAL
  PUBLIC :: FORTRAN_ORM_ROUND_TRUNCATE, FORTRAN_ORM_ROUND_HALF_UP
  PUBLIC :: FORTRAN_ORM_ROUND_HALF_EVEN, FORTRAN_ORM_ROUND_ERROR_IF_INEXACT
  PUBLIC :: FORTRAN_ORM_CP_IBM037, FORTRAN_ORM_CP_IBM1047
  PUBLIC :: FORTRAN_ORM_CP_IBM500, FORTRAN_ORM_CP_IBM1140
  PUBLIC :: FORTRAN_ORM_ISO_UR, FORTRAN_ORM_ISO_CS
  PUBLIC :: FORTRAN_ORM_ISO_RS, FORTRAN_ORM_ISO_RR
  PUBLIC :: FORTRAN_ORM_REL_ONE_TO_ONE, FORTRAN_ORM_REL_BELONGS_TO
  PUBLIC :: FORTRAN_ORM_REL_ONE_TO_MANY, FORTRAN_ORM_REL_MANY_TO_MANY
  PUBLIC :: fortran_orm_decimal, fortran_orm_pool_stats
  PUBLIC :: fortran_orm_oauth2_token_pod

  !> @type orm_db_t
  !> @brief RAII Fortran 2003 database connection class.
  TYPE, PUBLIC :: orm_db_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
    LOGICAL :: from_pool = .FALSE.
  CONTAINS
    PROCEDURE :: open => db_open
    PROCEDURE :: close => db_close
    PROCEDURE :: is_open => db_is_open
    PROCEDURE :: exec => db_exec
    PROCEDURE :: tx_begin => db_tx_begin
    PROCEDURE :: tx_commit => db_tx_commit
    PROCEDURE :: tx_rollback => db_tx_rollback
    PROCEDURE :: savepoint => db_savepoint
    PROCEDURE :: release_sp => db_release_sp
    PROCEDURE :: rollback_sp => db_rollback_sp
    PROCEDURE :: last_error => db_last_error
    PROCEDURE :: last_trace => db_last_trace
    PROCEDURE :: last_rowid => db_last_rowid
    PROCEDURE :: enable_cache => db_enable_cache
    PROCEDURE :: set_timezone => db_set_timezone
    PROCEDURE :: set_slow_ms => db_set_slow_ms
    PROCEDURE :: telemetry => db_telemetry
    PROCEDURE :: escape_str => db_escape_str
    FINAL :: db_finalize_raii
  END TYPE orm_db_t

  !> @type orm_stmt_t
  !> @brief RAII Fortran 2003 prepared statement class with 1-based indexing
  !> and generic `bind` / `col` overloads.
  TYPE, PUBLIC :: orm_stmt_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: prepare => stmt_prepare
    PROCEDURE :: prepare_cached => stmt_prepare_cached
    PROCEDURE :: bind_i32 => stmt_bind_i32
    PROCEDURE :: bind_i64 => stmt_bind_i64
    PROCEDURE :: bind_f32 => stmt_bind_f32
    PROCEDURE :: bind_f64 => stmt_bind_f64
    PROCEDURE :: bind_logical => stmt_bind_logical
    PROCEDURE :: bind_str => stmt_bind_str
    PROCEDURE :: bind_str_raw => stmt_bind_str_raw
    PROCEDURE :: bind_decimal => stmt_bind_decimal
    PROCEDURE :: bind_null => stmt_bind_null
    GENERIC :: bind => bind_i32, bind_i64, bind_f32, bind_f64, &
                       bind_logical, bind_str, bind_decimal
    PROCEDURE :: step => stmt_step
    PROCEDURE :: reset => stmt_reset
    PROCEDURE :: col_count => stmt_col_count
    PROCEDURE :: col_name => stmt_col_name
    PROCEDURE :: col_is_null => stmt_col_is_null
    PROCEDURE :: col_i32 => stmt_col_i32
    PROCEDURE :: col_i64 => stmt_col_i64
    PROCEDURE :: col_f32 => stmt_col_f32
    PROCEDURE :: col_f64 => stmt_col_f64
    PROCEDURE :: col_logical => stmt_col_logical
    PROCEDURE :: col_str => stmt_col_str
    PROCEDURE :: col_decimal => stmt_col_decimal
    GENERIC :: col => col_i32, col_i64, col_f32, col_f64, &
                      col_logical, col_str, col_decimal
    PROCEDURE :: close => stmt_close
    FINAL :: stmt_finalize_raii
  END TYPE orm_stmt_t

  !> @type orm_pool_t
  !> @brief RAII Fortran 2003 thread-safe connection pool class.
  TYPE, PUBLIC :: orm_pool_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: init => pool_init
    PROCEDURE :: acquire => pool_acquire
    PROCEDURE :: release => pool_release
    PROCEDURE :: telemetry => pool_telemetry
    PROCEDURE :: destroy => pool_destroy
    FINAL :: pool_finalize_raii
  END TYPE orm_pool_t

  !> @type orm_rs_t
  !> @brief RAII Fortran 2003 dynamic abstract result-set class.
  TYPE, PUBLIC :: orm_rs_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: query => rs_query
    PROCEDURE :: row_count => rs_row_count
    PROCEDURE :: col_count => rs_col_count
    PROCEDURE :: col_name => rs_col_name
    PROCEDURE :: is_null => rs_is_null
    PROCEDURE :: get_i64 => rs_get_i64
    PROCEDURE :: get_f64 => rs_get_f64
    PROCEDURE :: get_str => rs_get_str
    PROCEDURE :: to_json => rs_to_json
    PROCEDURE :: free => rs_free
    FINAL :: rs_finalize_raii
  END TYPE orm_rs_t

  !> @type orm_ast_t
  !> @brief RAII Fortran 2003 arena-backed fluent SQL AST builder class.
  TYPE, PUBLIC :: orm_ast_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: select_from => ast_select_from
    PROCEDURE :: insert_into => ast_insert_into
    PROCEDURE :: update_table => ast_update_table
    PROCEDURE :: delete_from => ast_delete_from
    PROCEDURE :: distinct => ast_distinct
    PROCEDURE :: where_i64 => ast_where_i64
    PROCEDURE :: where_str => ast_where_str
    PROCEDURE :: join => ast_join
    PROCEDURE :: group_having => ast_group_having
    PROCEDURE :: order_limit => ast_order_limit
    PROCEDURE :: set_i64 => ast_set_i64
    PROCEDURE :: set_str => ast_set_str
    PROCEDURE :: returning_lock => ast_returning_lock
    PROCEDURE :: to_sql => ast_to_sql
    PROCEDURE :: exec => ast_exec
    PROCEDURE :: query_rs => ast_query_rs
    PROCEDURE :: free => ast_free
    FINAL :: ast_finalize_raii
  END TYPE orm_ast_t

  !> @type orm_schema_t
  !> @brief RAII Fortran 2003 runtime BIND(C) struct reflection schema class.
  TYPE, PUBLIC :: orm_schema_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: create => schema_create
    PROCEDURE :: add_col => schema_add_col
    PROCEDURE :: add_relation => schema_add_relation
    PROCEDURE :: build_ddl => schema_build_ddl
    PROCEDURE :: create_table => schema_create_table
    PROCEDURE :: insert_ptr => schema_insert_ptr
    PROCEDURE :: upsert_ptr => schema_upsert_ptr
    PROCEDURE :: update_ptr => schema_update_ptr
    PROCEDURE :: update_opt_ptr => schema_update_opt_ptr
    PROCEDURE :: find_i32_ptr => schema_find_i32_ptr
    PROCEDURE :: find_lock_ptr => schema_find_lock_ptr
    PROCEDURE :: exists_i32 => schema_exists_i32
    PROCEDURE :: delete_i32 => schema_delete_i32
    PROCEDURE :: find_all_ptr => schema_find_all_ptr
    PROCEDURE :: free => schema_free
    FINAL :: schema_finalize_raii
  END TYPE orm_schema_t

  PUBLIC :: corm_f2003_uuid_v4, corm_f2003_version, corm_f2003_error_name

CONTAINS

  !> @brief Opens a database connection on `self`.
  !> @param[inout] self Database class instance.
  !> @param[in] url Connection URL string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_open(self, url) RESULT(rc)
    CLASS(orm_db_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: url
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr) .AND. .NOT. self%from_pool) THEN
      prev_rc = fortran_orm_disconnect(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    self%from_pool = .FALSE.
    rc = fortran_orm_connect(url, INT(LEN(url), C_INT32_T), self%ptr)
  END FUNCTION db_open

  !> @brief Explicitly closes `self` if open and owned.
  !> @param[inout] self Database class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_close(self) RESULT(rc)
    CLASS(orm_db_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr) .AND. .NOT. self%from_pool) THEN
      rc = fortran_orm_disconnect(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION db_close

  !> @brief Checks whether `self` holds an active connection pointer.
  !> @param[in] self Database class instance.
  !> @return `.TRUE.` if `self%ptr` is associated.
  FUNCTION db_is_open(self) RESULT(ok)
    CLASS(orm_db_t), INTENT(IN) :: self
    LOGICAL :: ok
    ok = C_ASSOCIATED(self%ptr)
  END FUNCTION db_is_open

  !> @brief Executes DDL or DML SQL text on `self`.
  !> @param[in] self Database class instance.
  !> @param[in] sql SQL statement string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_exec(self, sql) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT) :: rc
    rc = fortran_orm_exec_sql(self%ptr, sql, INT(LEN(sql), C_INT32_T))
  END FUNCTION db_exec

  !> @brief Begins an explicit transaction on `self`.
  !> @param[in] self Database class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_tx_begin(self) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    INTEGER(C_INT) :: rc
    rc = fortran_orm_tx_begin(self%ptr)
  END FUNCTION db_tx_begin

  !> @brief Commits the active transaction on `self`.
  !> @param[in] self Database class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_tx_commit(self) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    INTEGER(C_INT) :: rc
    rc = fortran_orm_tx_commit(self%ptr)
  END FUNCTION db_tx_commit

  !> @brief Rolls back the active transaction on `self`.
  !> @param[in] self Database class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_tx_rollback(self) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    INTEGER(C_INT) :: rc
    rc = fortran_orm_tx_rollback(self%ptr)
  END FUNCTION db_tx_rollback

  !> @brief Creates named savepoint `sp_name` on `self`.
  !> @param[in] self Database class instance.
  !> @param[in] sp_name Savepoint identifier.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_savepoint(self, sp_name) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER(C_INT) :: rc
    rc = fortran_orm_tx_savepoint(self%ptr, sp_name, &
                                  INT(LEN(sp_name), C_INT32_T))
  END FUNCTION db_savepoint

  !> @brief Releases named savepoint `sp_name` on `self`.
  !> @param[in] self Database class instance.
  !> @param[in] sp_name Savepoint identifier.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_release_sp(self, sp_name) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER(C_INT) :: rc
    rc = fortran_orm_tx_release_sp(self%ptr, sp_name, &
                                   INT(LEN(sp_name), C_INT32_T))
  END FUNCTION db_release_sp

  !> @brief Rolls back `self` to named savepoint `sp_name`.
  !> @param[in] self Database class instance.
  !> @param[in] sp_name Savepoint identifier.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_rollback_sp(self, sp_name) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER(C_INT) :: rc
    rc = fortran_orm_tx_rollback_sp(self%ptr, sp_name, &
                                    INT(LEN(sp_name), C_INT32_T))
  END FUNCTION db_rollback_sp

  !> @brief Returns the last driver error as a deferred-length Fortran string.
  !> @param[in] self Database class instance.
  !> @param[out] msg Allocatable output message string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_last_error(self, msg) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: msg
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    msg = ""
    rc = fortran_orm_last_error(self%ptr, buf, 512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      msg = buf(1:out_n)
    END IF
  END FUNCTION db_last_error

  !> @brief Returns the last contextual trace string on `self`.
  !> @param[in] self Database class instance.
  !> @param[out] trace Allocatable output trace string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_last_trace(self, trace) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: trace
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    trace = ""
    rc = fortran_orm_last_trace(self%ptr, buf, 512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      trace = buf(1:out_n)
    END IF
  END FUNCTION db_last_trace

  !> @brief Retrieves the 64-bit row ID generated by the last `INSERT`.
  !> @param[in] self Database class instance.
  !> @param[out] rowid Receives 64-bit row identifier.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_last_rowid(self, rowid) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    INTEGER(C_INT64_T), INTENT(OUT) :: rowid
    INTEGER(C_INT) :: rc
    rc = fortran_orm_last_insert_rowid(self%ptr, rowid)
  END FUNCTION db_last_rowid

  !> @brief Enables or disables `self`'s LRU prepared statement cache.
  !> @param[in] self Database class instance.
  !> @param[in] cap Maximum cached statements (`0` disables cache).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_enable_cache(self, cap) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: cap
    INTEGER(C_INT) :: rc
    rc = fortran_orm_enable_stmt_cache(self%ptr, cap)
  END FUNCTION db_enable_cache

  !> @brief Configures session UTC offset and IANA timezone name on `self`.
  !> @param[in] self Database class instance.
  !> @param[in] offset_min Offset from UTC in minutes.
  !> @param[in] tz_name Timezone identifier string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_set_timezone(self, offset_min, tz_name) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: offset_min
    CHARACTER(LEN=*), INTENT(IN) :: tz_name
    INTEGER(C_INT) :: rc
    rc = fortran_orm_set_timezone(self%ptr, offset_min, tz_name, &
                                  INT(LEN(tz_name), C_INT32_T))
  END FUNCTION db_set_timezone

  !> @brief Configures slow-query logging threshold (ms) on `self`.
  !> @param[in] self Database class instance.
  !> @param[in] threshold_ms Slow-query threshold in milliseconds.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_set_slow_ms(self, threshold_ms) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: threshold_ms
    INTEGER(C_INT) :: rc
    rc = fortran_orm_set_slow_query_ms(self%ptr, threshold_ms)
  END FUNCTION db_set_slow_ms

  !> @brief Snapshots single-connection telemetry counters on `self`.
  !> @param[in] self Database class instance.
  !> @param[out] stats Telemetry POD snapshot.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_telemetry(self, stats) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    TYPE(fortran_orm_pool_stats), INTENT(OUT) :: stats
    INTEGER(C_INT) :: rc
    rc = fortran_orm_db_telemetry(self%ptr, stats)
  END FUNCTION db_telemetry

  !> @brief Escapes `raw_str` against SQL injection using driver rules.
  !> @param[in] self Database class instance.
  !> @param[in] raw_str Unescaped input literal.
  !> @param[out] escaped Allocatable escaped literal.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION db_escape_str(self, raw_str, escaped) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: raw_str
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: escaped
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    escaped = ""
    rc = fortran_orm_escape_string(self%ptr, raw_str, &
                                   INT(LEN(raw_str), C_INT32_T), buf, &
                                   512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      escaped = buf(1:out_n)
    END IF
  END FUNCTION db_escape_str

  !> @brief RAII FINAL destructor for `orm_db_t`.
  !> @param[inout] self Database class instance leaving scope.
  SUBROUTINE db_finalize_raii(self)
    TYPE(orm_db_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr) .AND. .NOT. self%from_pool) THEN
      rc = fortran_orm_disconnect(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE db_finalize_raii

  !> @brief Prepares a parameterized SQL statement on `db`.
  !> @param[inout] self Statement class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] sql Parameterized SQL query.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_prepare(self, db, sql) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_stmt_finalize(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_stmt_prepare(db%ptr, sql, INT(LEN(sql), C_INT32_T), &
                                  self%ptr)
  END FUNCTION stmt_prepare

  !> @brief Prepares or recycles a cached SQL statement from `db`'s LRU cache.
  !> @param[inout] self Statement class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] sql Parameterized SQL query.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_prepare_cached(self, db, sql) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_stmt_finalize(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_stmt_prepare_cached(db%ptr, sql, &
                                         INT(LEN(sql), C_INT32_T), self%ptr)
  END FUNCTION stmt_prepare_cached

  !> @brief Binds a 32-bit integer at 1-based parameter `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val 32-bit integer value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_i32(self, idx, val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    INTEGER(C_INT32_T), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_i32(self%ptr, idx, val)
  END FUNCTION stmt_bind_i32

  !> @brief Binds a 64-bit integer at 1-based parameter `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val 64-bit integer value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_i64(self, idx, val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    INTEGER(C_INT64_T), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_i64(self%ptr, idx, val)
  END FUNCTION stmt_bind_i64

  !> @brief Binds an IEEE 32-bit float at 1-based parameter `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val 32-bit real value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_f32(self, idx, val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    REAL(C_FLOAT), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_f32(self%ptr, idx, val)
  END FUNCTION stmt_bind_f32

  !> @brief Binds an IEEE 64-bit float at 1-based parameter `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val 64-bit real value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_f64(self, idx, val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    REAL(C_DOUBLE), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_f64(self%ptr, idx, val)
  END FUNCTION stmt_bind_f64

  !> @brief Binds a Fortran `LOGICAL` flag at 1-based parameter `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] flag Logical value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_logical(self, idx, flag) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    LOGICAL, INTENT(IN) :: flag
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: iflg
    iflg = MERGE(1_C_INT32_T, 0_C_INT32_T, flag)
    rc = fortran_orm_stmt_bind_logical(self%ptr, idx, iflg)
  END FUNCTION stmt_bind_logical

  !> @brief Binds a blank-trimmed Fortran string slice at 1-based `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val Character string value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_str(self, idx, val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_str(self%ptr, idx, val, &
                                   INT(LEN(val), C_INT32_T))
  END FUNCTION stmt_bind_str

  !> @brief Binds an untrimmed raw string slice preserving trailing spaces.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val Raw character buffer.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_str_raw(self, idx, val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_str_raw(self%ptr, idx, val, &
                                       INT(LEN(val), C_INT32_T))
  END FUNCTION stmt_bind_str_raw

  !> @brief Binds an exact 38-digit decimal POD at 1-based parameter `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] dec Decimal POD instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_decimal(self, idx, dec) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    TYPE(fortran_orm_decimal), INTENT(IN) :: dec
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_decimal(self%ptr, idx, dec)
  END FUNCTION stmt_bind_decimal

  !> @brief Binds SQL `NULL` at 1-based parameter `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based parameter position.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_bind_null(self, idx) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_bind_null(self%ptr, idx)
  END FUNCTION stmt_bind_null

  !> @brief Advances `self` by one row.
  !> @param[in] self Statement class instance.
  !> @param[out] has_row Receives `.TRUE.` if a row is available.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_step(self, has_row) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    LOGICAL, INTENT(OUT) :: has_row
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: ihas
    ihas = 0_C_INT32_T
    rc = fortran_orm_stmt_step(self%ptr, ihas)
    has_row = (rc == FORTRAN_ORM_OK .AND. ihas /= 0_C_INT32_T)
  END FUNCTION stmt_step

  !> @brief Resets `self` for re-execution with fresh parameter bindings.
  !> @param[in] self Statement class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_reset(self) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_reset(self%ptr)
  END FUNCTION stmt_reset

  !> @brief Queries result column count of `self`.
  !> @param[in] self Statement class instance.
  !> @param[out] n_cols Receives column count.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_count(self, n_cols) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(OUT) :: n_cols
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_col_count(self%ptr, n_cols)
  END FUNCTION stmt_col_count

  !> @brief Reads the 1-based column name on `self`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] name_out Allocatable column name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_name(self, idx, name_out) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: name_out
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=128, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    name_out = ""
    rc = fortran_orm_stmt_col_name(self%ptr, idx, buf, 128_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      name_out = buf(1:out_n)
    END IF
  END FUNCTION stmt_col_name

  !> @brief Checks whether 1-based column `idx` is SQL `NULL`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] is_null Receives `.TRUE.` if SQL `NULL`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_is_null(self, idx, is_null) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    LOGICAL, INTENT(OUT) :: is_null
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: inul
    inul = 0_C_INT32_T
    rc = fortran_orm_stmt_col_is_null(self%ptr, idx, inul)
    is_null = (rc == FORTRAN_ORM_OK .AND. inul /= 0_C_INT32_T)
  END FUNCTION stmt_col_is_null

  !> @brief Reads a 32-bit integer from 1-based column `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] out_val Receives 32-bit integer value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_i32(self, idx, out_val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    INTEGER(C_INT32_T), INTENT(OUT) :: out_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_col_i32(self%ptr, idx, out_val)
  END FUNCTION stmt_col_i32

  !> @brief Reads a 64-bit integer from 1-based column `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] out_val Receives 64-bit integer value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_i64(self, idx, out_val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    INTEGER(C_INT64_T), INTENT(OUT) :: out_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_col_i64(self%ptr, idx, out_val)
  END FUNCTION stmt_col_i64

  !> @brief Reads a 32-bit float from 1-based column `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] out_val Receives 32-bit float value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_f32(self, idx, out_val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    REAL(C_FLOAT), INTENT(OUT) :: out_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_col_f32(self%ptr, idx, out_val)
  END FUNCTION stmt_col_f32

  !> @brief Reads a 64-bit float from 1-based column `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] out_val Receives 64-bit float value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_f64(self, idx, out_val) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    REAL(C_DOUBLE), INTENT(OUT) :: out_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_col_f64(self%ptr, idx, out_val)
  END FUNCTION stmt_col_f64

  !> @brief Reads a Fortran `LOGICAL` flag from 1-based column `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] out_flag Receives `.TRUE.` if non-zero.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_logical(self, idx, out_flag) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    LOGICAL, INTENT(OUT) :: out_flag
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: iflg
    iflg = 0_C_INT32_T
    rc = fortran_orm_stmt_col_logical(self%ptr, idx, iflg)
    out_flag = (rc == FORTRAN_ORM_OK .AND. iflg /= 0_C_INT32_T)
  END FUNCTION stmt_col_logical

  !> @brief Reads a deferred-length allocatable string from 1-based column `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] out_str Receives trimmed allocatable string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_str(self, idx, out_str) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_str = ""
    rc = fortran_orm_stmt_col_str(self%ptr, idx, buf, 512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    END IF
  END FUNCTION stmt_col_str

  !> @brief Reads an exact 38-digit decimal POD from 1-based column `idx`.
  !> @param[in] self Statement class instance.
  !> @param[in] idx 1-based column position.
  !> @param[out] out_dec Receives decimal POD value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_col_decimal(self, idx, out_dec) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: idx
    TYPE(fortran_orm_decimal), INTENT(OUT) :: out_dec
    INTEGER(C_INT) :: rc
    rc = fortran_orm_stmt_col_decimal(self%ptr, idx, out_dec)
  END FUNCTION stmt_col_decimal

  !> @brief Explicitly finalizes `self`.
  !> @param[inout] self Statement class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION stmt_close(self) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_stmt_finalize(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION stmt_close

  !> @brief RAII FINAL destructor for `orm_stmt_t`.
  !> @param[inout] self Statement class instance leaving scope.
  SUBROUTINE stmt_finalize_raii(self)
    TYPE(orm_stmt_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_stmt_finalize(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE stmt_finalize_raii

  !> @brief Initializes a bounded connection pool.
  !> @param[inout] self Pool class instance.
  !> @param[in] url Connection URL string.
  !> @param[in] min_c Minimum connections.
  !> @param[in] max_c Maximum connections.
  !> @param[in] timeout_ms Acquisition timeout in milliseconds.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION pool_init(self, url, min_c, max_c, timeout_ms) RESULT(rc)
    CLASS(orm_pool_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: url
    INTEGER(C_INT32_T), INTENT(IN) :: min_c, max_c, timeout_ms
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_pool_destroy(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_pool_init(url, INT(LEN(url), C_INT32_T), min_c, max_c, &
                               timeout_ms, self%ptr)
  END FUNCTION pool_init

  !> @brief Acquires a leased connection from `self`.
  !> @param[in] self Pool class instance.
  !> @param[inout] db Leased database connection wrapper.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION pool_acquire(self, db) RESULT(rc)
    CLASS(orm_pool_t), INTENT(IN) :: self
    TYPE(orm_db_t), INTENT(INOUT) :: db
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    prev_rc = db%close()
    rc = fortran_orm_pool_acquire(self%ptr, db%ptr)
    IF (rc == FORTRAN_ORM_OK) db%from_pool = .TRUE.
  END FUNCTION pool_acquire

  !> @brief Releases a leased connection back into `self`.
  !> @param[in] self Pool class instance.
  !> @param[inout] db Leased database connection wrapper.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION pool_release(self, db) RESULT(rc)
    CLASS(orm_pool_t), INTENT(IN) :: self
    TYPE(orm_db_t), INTENT(INOUT) :: db
    INTEGER(C_INT) :: rc
    rc = fortran_orm_pool_release(self%ptr, db%ptr)
    db%ptr = C_NULL_PTR
    db%from_pool = .FALSE.
  END FUNCTION pool_release

  !> @brief Snapshots live pool telemetry counters on `self`.
  !> @param[in] self Pool class instance.
  !> @param[out] stats Pool telemetry POD snapshot.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION pool_telemetry(self, stats) RESULT(rc)
    CLASS(orm_pool_t), INTENT(IN) :: self
    TYPE(fortran_orm_pool_stats), INTENT(OUT) :: stats
    INTEGER(C_INT) :: rc
    rc = fortran_orm_pool_telemetry(self%ptr, stats)
  END FUNCTION pool_telemetry

  !> @brief Destroys connection pool `self`.
  !> @param[inout] self Pool class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION pool_destroy(self) RESULT(rc)
    CLASS(orm_pool_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_pool_destroy(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION pool_destroy

  !> @brief RAII FINAL destructor for `orm_pool_t`.
  !> @param[inout] self Pool class instance leaving scope.
  SUBROUTINE pool_finalize_raii(self)
    TYPE(orm_pool_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_pool_destroy(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE pool_finalize_raii

  !> @brief Initializes a `SELECT` AST builder on `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] table_name Target SQL table name.
  !> @param[in] cols Comma-separated column projection.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_select_from(self, table_name, cols) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    CHARACTER(LEN=*), INTENT(IN) :: cols
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_ast_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_ast_select(table_name, INT(LEN(table_name), C_INT32_T), &
                                cols, INT(LEN(cols), C_INT32_T), self%ptr)
  END FUNCTION ast_select_from

  !> @brief Initializes an `INSERT INTO` AST builder on `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] table_name Target SQL table name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_insert_into(self, table_name) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_ast_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_ast_insert(table_name, INT(LEN(table_name), C_INT32_T), &
                                self%ptr)
  END FUNCTION ast_insert_into

  !> @brief Initializes an `UPDATE` AST builder on `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] table_name Target SQL table name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_update_table(self, table_name) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_ast_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_ast_update(table_name, INT(LEN(table_name), C_INT32_T), &
                                self%ptr)
  END FUNCTION ast_update_table

  !> @brief Initializes a `DELETE FROM` AST builder on `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] table_name Target SQL table name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_delete_from(self, table_name) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_ast_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_ast_delete(table_name, INT(LEN(table_name), C_INT32_T), &
                                self%ptr)
  END FUNCTION ast_delete_from

  !> @brief Enables `SELECT DISTINCT` on `self`.
  !> @param[inout] self AST class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_distinct(self) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_distinct(self%ptr)
  END FUNCTION ast_distinct

  !> @brief Appends an integer `WHERE` predicate to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] col Column name.
  !> @param[in] op Comparison operator (`"="`, `">"`, etc.).
  !> @param[in] val 64-bit integer value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_where_i64(self, col, op, val) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: col, op
    INTEGER(C_INT64_T), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_where_i64(self%ptr, col, INT(LEN(col), C_INT32_T), &
                                   op, INT(LEN(op), C_INT32_T), val)
  END FUNCTION ast_where_i64

  !> @brief Appends a string `WHERE` predicate (`"="`, `"!="`, `"LIKE"`) to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] col Column name.
  !> @param[in] op Comparison operator.
  !> @param[in] val String value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_where_str(self, col, op, val) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: col, op, val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_where_str(self%ptr, col, INT(LEN(col), C_INT32_T), &
                                   op, INT(LEN(op), C_INT32_T), val, &
                                   INT(LEN(val), C_INT32_T))
  END FUNCTION ast_where_str

  !> @brief Appends a `JOIN` clause to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] join_kind Join type (`"INNER"`, `"LEFT"`, `"RIGHT"`).
  !> @param[in] table_name Joined table name.
  !> @param[in] on_sql Join `ON` expression.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_join(self, join_kind, table_name, on_sql) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: join_kind, table_name, on_sql
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_join(self%ptr, join_kind, &
                              INT(LEN(join_kind), C_INT32_T), table_name, &
                              INT(LEN(table_name), C_INT32_T), on_sql, &
                              INT(LEN(on_sql), C_INT32_T))
  END FUNCTION ast_join

  !> @brief Appends `GROUP BY` and optional `HAVING` clauses to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] group_cols Comma-separated `GROUP BY` columns.
  !> @param[in] having_sql Optional `HAVING` expression (empty to skip).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_group_having(self, group_cols, having_sql) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: group_cols, having_sql
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_group_having(self%ptr, group_cols, &
                                      INT(LEN(group_cols), C_INT32_T), &
                                      having_sql, &
                                      INT(LEN(having_sql), C_INT32_T))
  END FUNCTION ast_group_having

  !> @brief Appends `ORDER BY`, `LIMIT`, and `OFFSET` clauses to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] order_col Order column (empty to skip).
  !> @param[in] desc `.TRUE.` for DESC, `.FALSE.` for ASC.
  !> @param[in] lim Row limit (`0` to skip).
  !> @param[in] off Row offset (`0` to skip).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_order_limit(self, order_col, desc, lim, off) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: order_col
    LOGICAL, INTENT(IN) :: desc
    INTEGER(C_INT32_T), INTENT(IN) :: lim, off
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: idesc
    idesc = MERGE(1_C_INT32_T, 0_C_INT32_T, desc)
    rc = fortran_orm_ast_order_limit(self%ptr, order_col, &
                                     INT(LEN(order_col), C_INT32_T), idesc, &
                                     lim, off)
  END FUNCTION ast_order_limit

  !> @brief Appends a 64-bit integer assignment (`INSERT`/`UPDATE`) to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] col Column name.
  !> @param[in] val 64-bit integer value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_set_i64(self, col, val) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: col
    INTEGER(C_INT64_T), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_set_i64(self%ptr, col, INT(LEN(col), C_INT32_T), val)
  END FUNCTION ast_set_i64

  !> @brief Appends a string assignment (`INSERT`/`UPDATE`) to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] col Column name.
  !> @param[in] val String value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_set_str(self, col, val) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: col, val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_set_str(self%ptr, col, INT(LEN(col), C_INT32_T), &
                                 val, INT(LEN(val), C_INT32_T))
  END FUNCTION ast_set_str

  !> @brief Appends `RETURNING` and/or Db2 isolation lock clause to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] returning_cols Returning projection (empty to skip).
  !> @param[in] db2_lock Db2 lock mode (`0` none, `1..5`).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_returning_lock(self, returning_cols, db2_lock) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: returning_cols
    INTEGER(C_INT32_T), INTENT(IN) :: db2_lock
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_returning_lock(self%ptr, returning_cols, &
                                        INT(LEN(returning_cols), C_INT32_T), &
                                        db2_lock)
  END FUNCTION ast_returning_lock

  !> @brief Compiles `self` into parameterized SQL for `dialect`.
  !> @param[in] self AST class instance.
  !> @param[in] dialect Target SQL dialect enum constant.
  !> @param[out] sql_out Allocatable SQL output string.
  !> @param[out] param_count Extracted bind parameter count.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_to_sql(self, dialect, sql_out, param_count) RESULT(rc)
    CLASS(orm_ast_t), INTENT(IN) :: self
    INTEGER(C_INT), INTENT(IN) :: dialect
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: sql_out
    INTEGER(C_INT32_T), INTENT(OUT) :: param_count
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=1024, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    param_count = 0_C_INT32_T
    sql_out = ""
    rc = fortran_orm_ast_to_sql(self%ptr, dialect, buf, 1024_C_INT32_T, &
                                out_n, param_count)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      sql_out = buf(1:out_n)
    END IF
  END FUNCTION ast_to_sql

  !> @brief Executes non-query (`INSERT`/`UPDATE`/`DELETE`) AST `self` on `db`.
  !> @param[in] self AST class instance.
  !> @param[in] db Active database class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_exec(self, db) RESULT(rc)
    CLASS(orm_ast_t), INTENT(IN) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT) :: rc
    rc = fortran_orm_ast_exec(db%ptr, self%ptr)
  END FUNCTION ast_exec

  !> @brief Executes `SELECT` AST `self` on `db` into dynamic result set `rs`.
  !> @param[in] self AST class instance.
  !> @param[in] db Active database class instance.
  !> @param[inout] rs Destination result-set class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_query_rs(self, db, rs) RESULT(rc)
    CLASS(orm_ast_t), INTENT(IN) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CLASS(orm_rs_t), INTENT(INOUT) :: rs
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    prev_rc = rs%free()
    rc = fortran_orm_ast_query_rs(db%ptr, self%ptr, rs%ptr)
  END FUNCTION ast_query_rs

  !> @brief Frees AST builder `self`.
  !> @param[inout] self AST class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION ast_free(self) RESULT(rc)
    CLASS(orm_ast_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_ast_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION ast_free

  !> @brief RAII FINAL destructor for `orm_ast_t`.
  !> @param[inout] self AST class instance leaving scope.
  SUBROUTINE ast_finalize_raii(self)
    TYPE(orm_ast_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_ast_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE ast_finalize_raii

  !> @brief Hydrates arbitrary SQL into dynamic result set `self`.
  !> @param[inout] self Result-set class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] sql SELECT SQL query.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_query(self, db, sql) RESULT(rc)
    CLASS(orm_rs_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_rs_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_query_abstract(db%ptr, sql, INT(LEN(sql), C_INT32_T), &
                                    self%ptr)
  END FUNCTION rs_query

  !> @brief Queries total row count of `self`.
  !> @param[in] self Result-set class instance.
  !> @param[out] nrows Receives row count.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_row_count(self, nrows) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(OUT) :: nrows
    INTEGER(C_INT) :: rc
    rc = fortran_orm_rs_row_count(self%ptr, nrows)
  END FUNCTION rs_row_count

  !> @brief Queries column count of 1-based `row_idx` in `self`.
  !> @param[in] self Result-set class instance.
  !> @param[in] row_idx 1-based row index.
  !> @param[out] ncols Receives column count.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_col_count(self, row_idx, ncols) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: row_idx
    INTEGER(C_INT32_T), INTENT(OUT) :: ncols
    INTEGER(C_INT) :: rc
    rc = fortran_orm_rs_col_count(self%ptr, row_idx, ncols)
  END FUNCTION rs_col_count

  !> @brief Queries column name at 1-based `(row_idx, col_idx)` in `self`.
  !> @param[in] self Result-set class instance.
  !> @param[in] row_idx 1-based row index.
  !> @param[in] col_idx 1-based column index.
  !> @param[out] name_out Allocatable column name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_col_name(self, row_idx, col_idx, name_out) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: row_idx, col_idx
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: name_out
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=128, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    name_out = ""
    rc = fortran_orm_rs_col_name(self%ptr, row_idx, col_idx, buf, &
                                 128_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      name_out = buf(1:out_n)
    END IF
  END FUNCTION rs_col_name

  !> @brief Checks whether `col_name` on 1-based `row_idx` is `NULL`.
  !> @param[in] self Result-set class instance.
  !> @param[in] row_idx 1-based row index.
  !> @param[in] col_name Column identifier.
  !> @param[out] is_null Receives `.TRUE.` if SQL `NULL`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_is_null(self, row_idx, col_name, is_null) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    LOGICAL, INTENT(OUT) :: is_null
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: inul
    inul = 0_C_INT32_T
    rc = fortran_orm_rs_is_null(self%ptr, row_idx, col_name, &
                                INT(LEN(col_name), C_INT32_T), inul)
    is_null = (rc == FORTRAN_ORM_OK .AND. inul /= 0_C_INT32_T)
  END FUNCTION rs_is_null

  !> @brief Reads a 64-bit integer by column name from 1-based `row_idx`.
  !> @param[in] self Result-set class instance.
  !> @param[in] row_idx 1-based row index.
  !> @param[in] col_name Column identifier.
  !> @param[out] out_val Receives 64-bit integer value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_get_i64(self, row_idx, col_name, out_val) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    INTEGER(C_INT64_T), INTENT(OUT) :: out_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_rs_get_i64(self%ptr, row_idx, col_name, &
                                INT(LEN(col_name), C_INT32_T), out_val)
  END FUNCTION rs_get_i64

  !> @brief Reads a 64-bit float by column name from 1-based `row_idx`.
  !> @param[in] self Result-set class instance.
  !> @param[in] row_idx 1-based row index.
  !> @param[in] col_name Column identifier.
  !> @param[out] out_val Receives 64-bit float value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_get_f64(self, row_idx, col_name, out_val) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    REAL(C_DOUBLE), INTENT(OUT) :: out_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_rs_get_f64(self%ptr, row_idx, col_name, &
                                INT(LEN(col_name), C_INT32_T), out_val)
  END FUNCTION rs_get_f64

  !> @brief Reads a string column by name from 1-based `row_idx`.
  !> @param[in] self Result-set class instance.
  !> @param[in] row_idx 1-based row index.
  !> @param[in] col_name Column identifier.
  !> @param[out] out_str Allocatable output string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_get_str(self, row_idx, col_name, out_str) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_str = ""
    rc = fortran_orm_rs_get_str(self%ptr, row_idx, col_name, &
                                INT(LEN(col_name), C_INT32_T), buf, &
                                512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    END IF
  END FUNCTION rs_get_str

  !> @brief Serializes `self` to a JSON array string.
  !> @param[in] self Result-set class instance.
  !> @param[out] json_out Allocatable JSON string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_to_json(self, json_out) RESULT(rc)
    CLASS(orm_rs_t), INTENT(IN) :: self
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: json_out
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=2048, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    json_out = ""
    rc = fortran_orm_rs_to_json(self%ptr, buf, 2048_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      json_out = buf(1:out_n)
    END IF
  END FUNCTION rs_to_json

  !> @brief Frees result set `self`.
  !> @param[inout] self Result-set class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION rs_free(self) RESULT(rc)
    CLASS(orm_rs_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_rs_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION rs_free

  !> @brief RAII FINAL destructor for `orm_rs_t`.
  !> @param[inout] self Result-set class instance leaving scope.
  SUBROUTINE rs_finalize_raii(self)
    TYPE(orm_rs_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_rs_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE rs_finalize_raii

  !> @brief Creates a runtime BIND(C) struct schema descriptor.
  !> @param[inout] self Schema class instance.
  !> @param[in] table_name SQL table name.
  !> @param[in] byte_size Byte size of the BIND(C) derived type.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_create(self, table_name, byte_size) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(C_INT32_T), INTENT(IN) :: byte_size
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      prev_rc = fortran_orm_schema_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
    rc = fortran_orm_schema_create(table_name, &
                                   INT(LEN(table_name), C_INT32_T), &
                                   byte_size, self%ptr)
  END FUNCTION schema_create

  !> @brief Registers a mapped struct column on `self`.
  !> @param[inout] self Schema class instance.
  !> @param[in] col_name Column name.
  !> @param[in] col_type Column enum type (`FORTRAN_ORM_COL_*`).
  !> @param[in] byte_offset 0-based byte offset in struct.
  !> @param[in] fixed_len Fixed byte width for `CHAR_FIXED` (`>= 2`), else `0`.
  !> @param[in] is_pk `.TRUE.` for primary key column.
  !> @param[in] is_nullable `.TRUE.` if nullable.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_add_col(self, col_name, col_type, byte_offset, fixed_len, &
                          is_pk, is_nullable) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    INTEGER(C_INT), INTENT(IN) :: col_type
    INTEGER(C_INT32_T), INTENT(IN) :: byte_offset, fixed_len
    LOGICAL, INTENT(IN) :: is_pk, is_nullable
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: ipk, inul
    ipk = MERGE(1_C_INT32_T, 0_C_INT32_T, is_pk)
    inul = MERGE(1_C_INT32_T, 0_C_INT32_T, is_nullable)
    rc = fortran_orm_schema_add_col(self%ptr, col_name, &
                                    INT(LEN(col_name), C_INT32_T), col_type, &
                                    byte_offset, fixed_len, ipk, inul)
  END FUNCTION schema_add_col

  !> @brief Registers a foreign-key relation metadata descriptor on `self`.
  !> @param[inout] self Parent schema class instance.
  !> @param[in] field_name Association name.
  !> @param[in] rel_kind Relation enum (`FORTRAN_ORM_REL_*`).
  !> @param[in] target_schema Target table schema class instance.
  !> @param[in] fk_col Foreign-key column name.
  !> @param[in] local_col Local key column name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_add_relation(self, field_name, rel_kind, target_schema, &
                               fk_col, local_col) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: field_name, fk_col, local_col
    INTEGER(C_INT), INTENT(IN) :: rel_kind
    CLASS(orm_schema_t), INTENT(IN) :: target_schema
    INTEGER(C_INT) :: rc
    rc = fortran_orm_schema_add_relation(self%ptr, field_name, &
                                         INT(LEN(field_name), C_INT32_T), &
                                         rel_kind, target_schema%ptr, fk_col, &
                                         INT(LEN(fk_col), C_INT32_T), &
                                         local_col, &
                                         INT(LEN(local_col), C_INT32_T))
  END FUNCTION schema_add_relation

  !> @brief Emits `CREATE TABLE IF NOT EXISTS` DDL for `self`.
  !> @param[inout] self Schema class instance.
  !> @param[out] ddl_out Allocatable DDL string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_build_ddl(self, ddl_out) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: ddl_out
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=1024, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    ddl_out = ""
    rc = fortran_orm_schema_build_ddl(self%ptr, buf, 1024_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      ddl_out = buf(1:out_n)
    END IF
  END FUNCTION schema_build_ddl

  !> @brief Creates the SQL table described by `self` on `db`.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_create_table(self, db) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_create_table(db%ptr, self%ptr)
  END FUNCTION schema_create_table

  !> @brief Inserts a BIND(C) struct record via `C_LOC(rec)`.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] rec_ptr `C_LOC` pointer to BIND(C) struct instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_insert_ptr(self, db, rec_ptr) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    TYPE(C_PTR), VALUE :: rec_ptr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_insert(db%ptr, self%ptr, rec_ptr)
  END FUNCTION schema_insert_ptr

  !> @brief Dialect-aware atomic `UPSERT` of a BIND(C) struct via `C_LOC`.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] rec_ptr `C_LOC` pointer to BIND(C) struct instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_upsert_ptr(self, db, rec_ptr) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    TYPE(C_PTR), VALUE :: rec_ptr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_upsert(db%ptr, self%ptr, rec_ptr)
  END FUNCTION schema_upsert_ptr

  !> @brief Updates a BIND(C) struct row matching PK via `C_LOC`.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] rec_ptr `C_LOC` pointer to BIND(C) struct instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_update_ptr(self, db, rec_ptr) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    TYPE(C_PTR), VALUE :: rec_ptr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_update(db%ptr, self%ptr, rec_ptr)
  END FUNCTION schema_update_ptr

  !> @brief Performs optimistic-locked `UPDATE` checking `version_col`.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] version_col Version column identifier.
  !> @param[in] rec_ptr `C_LOC` pointer to BIND(C) struct instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_update_opt_ptr(self, db, version_col, rec_ptr) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: version_col
    TYPE(C_PTR), VALUE :: rec_ptr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_update_optimistic(db%ptr, self%ptr, version_col, &
                                            INT(LEN(version_col), C_INT32_T), &
                                            rec_ptr)
  END FUNCTION schema_update_opt_ptr

  !> @brief Hydrates a BIND(C) struct record by 32-bit PK into `rec_ptr`.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] id_val 32-bit primary key value.
  !> @param[in] rec_ptr `C_LOC` pointer to destination BIND(C) struct.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_find_i32_ptr(self, db, id_val, rec_ptr) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT32_T), INTENT(IN) :: id_val
    TYPE(C_PTR), VALUE :: rec_ptr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_find_i32(db%ptr, self%ptr, id_val, rec_ptr)
  END FUNCTION schema_find_i32_ptr

  !> @brief Hydrates a BIND(C) struct by 32-bit PK with `FOR UPDATE` locking.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] id_val 32-bit primary key value.
  !> @param[in] rec_ptr `C_LOC` pointer to destination BIND(C) struct.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_find_lock_ptr(self, db, id_val, rec_ptr) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT32_T), INTENT(IN) :: id_val
    TYPE(C_PTR), VALUE :: rec_ptr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_find_for_update_i32(db%ptr, self%ptr, id_val, &
                                              rec_ptr)
  END FUNCTION schema_find_lock_ptr

  !> @brief Checks whether 32-bit PK `id_val` exists in `self`'s table.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] id_val 32-bit primary key value.
  !> @param[out] exists_flag Receives `.TRUE.` when row is present.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_exists_i32(self, db, id_val, exists_flag) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT32_T), INTENT(IN) :: id_val
    LOGICAL, INTENT(OUT) :: exists_flag
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: iex
    iex = 0_C_INT32_T
    rc = fortran_orm_crud_exists_i32(db%ptr, self%ptr, id_val, iex)
    exists_flag = (rc == FORTRAN_ORM_OK .AND. iex /= 0_C_INT32_T)
  END FUNCTION schema_exists_i32

  !> @brief Deletes row matching 32-bit PK `id_val` from `self`'s table.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] id_val 32-bit primary key value.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_delete_i32(self, db, id_val) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT32_T), INTENT(IN) :: id_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_delete_i32(db%ptr, self%ptr, id_val)
  END FUNCTION schema_delete_i32

  !> @brief Bulk-hydrates all rows of `self` into a BIND(C) struct array.
  !> @param[inout] self Schema class instance.
  !> @param[in] db Active database class instance.
  !> @param[in] arr_ptr `C_LOC(arr(1))` pointer to struct array.
  !> @param[in] max_records Capacity of `arr_ptr` in records.
  !> @param[out] out_count Number of hydrated records.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_find_all_ptr(self, db, arr_ptr, max_records, out_count) &
      RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    TYPE(C_PTR), VALUE :: arr_ptr
    INTEGER(C_INT32_T), INTENT(IN) :: max_records
    INTEGER(C_INT32_T), INTENT(OUT) :: out_count
    INTEGER(C_INT) :: rc
    rc = fortran_orm_crud_find_all(db%ptr, self%ptr, arr_ptr, max_records, &
                                   out_count)
  END FUNCTION schema_find_all_ptr

  !> @brief Frees runtime schema `self`.
  !> @param[inout] self Schema class instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION schema_free(self) RESULT(rc)
    CLASS(orm_schema_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_schema_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION schema_free

  !> @brief RAII FINAL destructor for `orm_schema_t`.
  !> @param[inout] self Schema class instance leaving scope.
  SUBROUTINE schema_finalize_raii(self)
    TYPE(orm_schema_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_schema_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE schema_finalize_raii

  !> @brief Generates a 36-character RFC 4122 UUID v4 string.
  !> @param[out] out_uuid Allocatable 36-char UUID string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_uuid_v4(out_uuid) RESULT(rc)
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_uuid
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=40, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_uuid = ""
    rc = fortran_orm_uuid_v4(buf, 40_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_uuid = buf(1:out_n)
    END IF
  END FUNCTION corm_f2003_uuid_v4

  !> @brief Queries the semantic version of `fortran-orm`.
  !> @param[out] out_ver Allocatable version string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_version(out_ver) RESULT(rc)
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_ver
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=32, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_ver = ""
    rc = fortran_orm_version(buf, 32_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_ver = buf(1:out_n)
    END IF
  END FUNCTION corm_f2003_version

  !> @brief Formats a `fortran_orm_error_t` status code into its symbolic name.
  !> @param[in] err_code Error status code.
  !> @param[out] out_name Allocatable symbolic name string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_error_name(err_code, out_name) RESULT(rc)
    INTEGER(C_INT32_T), INTENT(IN) :: err_code
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_name
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=64, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_name = ""
    rc = fortran_orm_error_name(err_code, buf, 64_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_name = buf(1:out_n)
    END IF
  END FUNCTION corm_f2003_error_name

END MODULE fortran_orm_f2003
