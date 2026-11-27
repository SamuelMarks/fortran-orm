!> @file fortran_orm_f2003.f90
!> @module fortran_orm_f2003
!> @brief Idiomatic ISO/IEC 1539-1:2004 Fortran 2003 Object-Oriented &
!> ISO_C_BINDING ORM module.
!>
!> Wraps the cdd-c generated `fortran_orm_c` `BIND(C)` interfaces in RAII
!> extensible derived types (`orm_db_t`, `orm_stmt_t`, `orm_pool_t`,
!> `orm_ast_t`, `orm_rs_t`, `orm_schema_t`) with type-bound procedures,
!> automatic `FINAL` destructors, deferred-length `CHARACTER(LEN=:),
!> ALLOCATABLE` string helpers, and `TYPE, BIND(C)` struct reflection CRUD.
MODULE fortran_orm_f2003
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_c
  IMPLICIT NONE
  PRIVATE

  PUBLIC :: FORTRAN_ORM_OK, FORTRAN_ORM_ERROR_NOT_FOUND
  PUBLIC :: FORTRAN_ORM_DIALECT_SQLITE, FORTRAN_ORM_DIALECT_POSTGRES
  PUBLIC :: FORTRAN_ORM_DIALECT_MYSQL, FORTRAN_ORM_DIALECT_DB2
  PUBLIC :: FORTRAN_ORM_DIALECT_ODBC
  PUBLIC :: FORTRAN_ORM_COL_INT32, FORTRAN_ORM_COL_INT64
  PUBLIC :: FORTRAN_ORM_COL_FLOAT64, FORTRAN_ORM_COL_STRING
  PUBLIC :: FORTRAN_ORM_COL_CHAR_FIXED, FORTRAN_ORM_COL_DECIMAL
  PUBLIC :: FORTRAN_ORM_ROUND_HALF_EVEN
  PUBLIC :: fortran_orm_decimal, fortran_orm_pool_stats

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
    PROCEDURE :: last_error => db_last_error
    FINAL :: db_finalize_raii
  END TYPE orm_db_t

  !> @type orm_stmt_t
  !> @brief RAII Fortran 2003 prepared statement class with 1-based indexing.
  TYPE, PUBLIC :: orm_stmt_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: prepare => stmt_prepare
    PROCEDURE :: bind_i32 => stmt_bind_i32
    PROCEDURE :: bind_i64 => stmt_bind_i64
    PROCEDURE :: bind_f64 => stmt_bind_f64
    PROCEDURE :: bind_str => stmt_bind_str
    PROCEDURE :: step => stmt_step
    PROCEDURE :: col_i32 => stmt_col_i32
    PROCEDURE :: col_i64 => stmt_col_i64
    PROCEDURE :: col_f64 => stmt_col_f64
    PROCEDURE :: col_str => stmt_col_str
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
    PROCEDURE :: destroy => pool_destroy
    FINAL :: pool_finalize_raii
  END TYPE orm_pool_t

  !> @type orm_ast_t
  !> @brief RAII Fortran 2003 arena-backed fluent SQL AST builder class.
  TYPE, PUBLIC :: orm_ast_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: select_from => ast_select_from
    PROCEDURE :: where_i64 => ast_where_i64
    PROCEDURE :: order_limit => ast_order_limit
    PROCEDURE :: to_sql => ast_to_sql
    PROCEDURE :: free => ast_free
    FINAL :: ast_finalize_raii
  END TYPE orm_ast_t

  !> @type orm_rs_t
  !> @brief RAII Fortran 2003 dynamic abstract result-set class.
  TYPE, PUBLIC :: orm_rs_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: query => rs_query
    PROCEDURE :: row_count => rs_row_count
    PROCEDURE :: get_str => rs_get_str
    PROCEDURE :: to_json => rs_to_json
    PROCEDURE :: free => rs_free
    FINAL :: rs_finalize_raii
  END TYPE orm_rs_t

  !> @type orm_schema_t
  !> @brief RAII Fortran 2003 runtime BIND(C) struct reflection schema class.
  TYPE, PUBLIC :: orm_schema_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: create => schema_create
    PROCEDURE :: add_col => schema_add_col
    PROCEDURE :: create_table => schema_create_table
    PROCEDURE :: insert_ptr => schema_insert_ptr
    PROCEDURE :: find_i32_ptr => schema_find_i32_ptr
    PROCEDURE :: free => schema_free
    FINAL :: schema_finalize_raii
  END TYPE orm_schema_t

  PUBLIC :: corm_f2003_uuid_v4, corm_f2003_version

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
  !> @return .TRUE. if `self%ptr` is associated.
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
    rc = fortran_orm_last_error(self%ptr, buf, 512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      msg = buf(1:out_n)
    ELSE
      msg = ""
    END IF
  END FUNCTION db_last_error

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

  !> @brief Binds a Fortran string slice at 1-based parameter `idx`.
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

  !> @brief Advances `self` by one row.
  !> @param[in] self Statement class instance.
  !> @param[out] has_row Receives .TRUE. if a row is available.
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
    rc = fortran_orm_stmt_col_str(self%ptr, idx, buf, 512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    ELSE
      out_str = ""
    END IF
  END FUNCTION stmt_col_str

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

  !> @brief Appends `ORDER BY`, `LIMIT`, and `OFFSET` clauses to `self`.
  !> @param[inout] self AST class instance.
  !> @param[in] order_col Order column (empty to skip).
  !> @param[in] desc .TRUE. for DESC, .FALSE. for ASC.
  !> @param[in] lim Row limit (0 to skip).
  !> @param[in] off Row offset (0 to skip).
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
    rc = fortran_orm_ast_to_sql(self%ptr, dialect, buf, 1024_C_INT32_T, &
                                out_n, param_count)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      sql_out = buf(1:out_n)
    ELSE
      sql_out = ""
    END IF
  END FUNCTION ast_to_sql

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
    rc = fortran_orm_rs_get_str(self%ptr, row_idx, col_name, &
                                INT(LEN(col_name), C_INT32_T), buf, &
                                512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    ELSE
      out_str = ""
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
    rc = fortran_orm_rs_to_json(self%ptr, buf, 2048_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      json_out = buf(1:out_n)
    ELSE
      json_out = ""
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
  !> @param[in] is_pk .TRUE. for primary key column.
  !> @param[in] is_nullable .TRUE. if nullable.
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
    rc = fortran_orm_uuid_v4(buf, 40_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_uuid = buf(1:out_n)
    ELSE
      out_uuid = ""
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
    rc = fortran_orm_version(buf, 32_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_ver = buf(1:out_n)
    ELSE
      out_ver = ""
    END IF
  END FUNCTION corm_f2003_version

END MODULE fortran_orm_f2003
