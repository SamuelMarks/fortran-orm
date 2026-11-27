!> @file fortran_orm_f90.f90
!> @module fortran_orm_f90
!> @brief Strict ISO/IEC 1539:1991 Fortran 90 ORM module.
!>
!> Uses exclusively ISO Fortran 90 features (MODULE, IMPLICIT NONE, derived
!> types without F95 default initialization, explicit INTERFACE blocks to the
!> C89 CF77* ABI, generic procedure overloading, assumed-shape 2D array
!> descriptors, and OPTIONAL status arguments) with zero Fortran 95/2003
!> extensions.
MODULE fortran_orm_f90
  IMPLICIT NONE
  PRIVATE

  INTEGER, PARAMETER, PUBLIC :: CORM_F90_OK = 0
  INTEGER, PARAMETER, PUBLIC :: CORM_F90_DIALECT_SQLITE = 0
  INTEGER, PARAMETER, PUBLIC :: CORM_F90_DIALECT_POSTGRES = 1
  INTEGER, PARAMETER, PUBLIC :: CORM_F90_DIALECT_MYSQL = 2
  INTEGER, PARAMETER, PUBLIC :: CORM_F90_DIALECT_DB2 = 3
  INTEGER, PARAMETER, PUBLIC :: CORM_F90_DIALECT_ODBC = 4

  !> @type corm_db_f90
  !> @brief Strongly-typed Fortran 90 database handle wrapper.
  TYPE, PUBLIC :: corm_db_f90
    INTEGER :: slot
  END TYPE corm_db_f90

  !> @type corm_stmt_f90
  !> @brief Strongly-typed Fortran 90 prepared statement handle wrapper.
  TYPE, PUBLIC :: corm_stmt_f90
    INTEGER :: slot
  END TYPE corm_stmt_f90

  !> @type corm_ast_f90
  !> @brief Strongly-typed Fortran 90 SQL AST builder handle wrapper.
  TYPE, PUBLIC :: corm_ast_f90
    INTEGER :: slot
  END TYPE corm_ast_f90

  INTERFACE
    !> @brief Low-level C89 open bridge.
    !> @param[in] url Connection URL.
    !> @param[out] idb DB slot.
    !> @param[out] ierr Error code.
    SUBROUTINE cf77op(url, idb, ierr)
      CHARACTER(LEN=*), INTENT(IN) :: url
      INTEGER, INTENT(OUT) :: idb
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77op

    !> @brief Low-level C89 close bridge.
    !> @param[in] imode Resource kind.
    !> @param[inout] ihnd Slot ID.
    !> @param[out] ierr Error code.
    SUBROUTINE cf77cl(imode, ihnd, ierr)
      INTEGER, INTENT(IN) :: imode
      INTEGER, INTENT(INOUT) :: ihnd
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77cl

    !> @brief Low-level C89 exec/tx bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] idb DB slot.
    !> @param[in] sql SQL or savepoint text.
    !> @param[out] iout Integer output.
    !> @param[out] ierr Error code.
    SUBROUTINE cf77ex(imode, idb, sql, iout, ierr)
      INTEGER, INTENT(IN) :: imode
      INTEGER, INTENT(IN) :: idb
      CHARACTER(LEN=*), INTENT(IN) :: sql
      INTEGER, INTENT(OUT) :: iout
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77ex

    !> @brief Low-level C89 statement bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] ihnd DB or statement slot.
    !> @param[in] iidx 1-based index.
    !> @param[inout] ival Integer input/output.
    !> @param[inout] dval Double input/output.
    !> @param[inout] cbuf Character buffer.
    !> @param[out] ilen Written string length.
    !> @param[out] ierr Error code.
    SUBROUTINE cf77st(imode, ihnd, iidx, ival, dval, cbuf, ilen, ierr)
      INTEGER, INTENT(IN) :: imode
      INTEGER, INTENT(IN) :: ihnd
      INTEGER, INTENT(IN) :: iidx
      INTEGER, INTENT(INOUT) :: ival
      DOUBLE PRECISION, INTENT(INOUT) :: dval
      CHARACTER(LEN=*), INTENT(INOUT) :: cbuf
      INTEGER, INTENT(OUT) :: ilen
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77st

    !> @brief Low-level C89 matrix & AST bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] ihnd DB or AST slot.
    !> @param[inout] sql SQL or table text.
    !> @param[inout] dmat Contiguous column-major matrix buffer.
    !> @param[in] ldrows Leading dimension.
    !> @param[in] nrows Row count.
    !> @param[in] ncols Column count or dialect.
    !> @param[out] nout Output count/slot/length.
    !> @param[out] ierr Error code.
    SUBROUTINE cf77mx(imode, ihnd, sql, dmat, ldrows, nrows, ncols, nout, ierr)
      INTEGER, INTENT(IN) :: imode
      INTEGER, INTENT(IN) :: ihnd
      CHARACTER(LEN=*), INTENT(INOUT) :: sql
      DOUBLE PRECISION, DIMENSION(ldrows, *), INTENT(INOUT) :: dmat
      INTEGER, INTENT(IN) :: ldrows
      INTEGER, INTENT(IN) :: nrows
      INTEGER, INTENT(IN) :: ncols
      INTEGER, INTENT(OUT) :: nout
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77mx
  END INTERFACE

  !> @brief Generic overloaded parameter binding interface.
  INTERFACE corm_f90_bind
    MODULE PROCEDURE corm_f90_bind_i32
    MODULE PROCEDURE corm_f90_bind_f64
    MODULE PROCEDURE corm_f90_bind_str
  END INTERFACE corm_f90_bind

  !> @brief Generic overloaded column reader interface.
  INTERFACE corm_f90_col
    MODULE PROCEDURE corm_f90_col_i32
    MODULE PROCEDURE corm_f90_col_f64
    MODULE PROCEDURE corm_f90_col_str
  END INTERFACE corm_f90_col

  PUBLIC :: corm_f90_open, corm_f90_close, corm_f90_exec
  PUBLIC :: corm_f90_tx_begin, corm_f90_tx_commit, corm_f90_tx_rollback
  PUBLIC :: corm_f90_prepare, corm_f90_step, corm_f90_finalize
  PUBLIC :: corm_f90_bind, corm_f90_col
  PUBLIC :: corm_f90_insert_matrix, corm_f90_query_matrix
  PUBLIC :: corm_f90_ast_select, corm_f90_ast_to_sql, corm_f90_ast_free

CONTAINS

  !> @brief Opens a database connection.
  !> @param[in] url Connection URL string.
  !> @param[out] db Initialized Fortran 90 DB handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_open(url, db, ierr)
    CHARACTER(LEN=*), INTENT(IN) :: url
    TYPE(corm_db_f90), INTENT(OUT) :: db
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc
    db%slot = 0
    CALL cf77op(url, db%slot, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_open

  !> @brief Closes a database connection.
  !> @param[inout] db Active Fortran 90 DB handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_close(db, ierr)
    TYPE(corm_db_f90), INTENT(INOUT) :: db
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc
    CALL cf77cl(1, db%slot, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_close

  !> @brief Executes DDL or DML SQL.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql SQL statement text.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_exec(db, sql, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, dummy_out
    dummy_out = 0
    CALL cf77ex(1, db%slot, sql, dummy_out, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_exec

  !> @brief Begins a database transaction.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_tx_begin(db, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, dummy_out
    dummy_out = 0
    CALL cf77ex(2, db%slot, " ", dummy_out, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_tx_begin

  !> @brief Commits the active database transaction.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_tx_commit(db, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, dummy_out
    dummy_out = 0
    CALL cf77ex(3, db%slot, " ", dummy_out, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_tx_commit

  !> @brief Rolls back the active database transaction.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_tx_rollback(db, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, dummy_out
    dummy_out = 0
    CALL cf77ex(4, db%slot, " ", dummy_out, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_tx_rollback

  !> @brief Prepares a parameterized SQL statement.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql SQL query string.
  !> @param[out] stmt Initialized statement handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_prepare(db, sql, stmt, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    TYPE(corm_stmt_f90), INTENT(OUT) :: stmt
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=LEN(sql)) :: sql_copy
    stmt%slot = 0
    dval = 0.0D0
    ilen = 0
    sql_copy = sql
    CALL cf77st(1, db%slot, 0, stmt%slot, dval, sql_copy, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_prepare

  !> @brief Binds an INTEGER parameter at 1-based index idx.
  !> @param[in] stmt Statement handle.
  !> @param[in] idx 1-based parameter index.
  !> @param[in] val Integer value.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_bind_i32(stmt, idx, val, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    INTEGER, INTENT(IN) :: val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, nval, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    nval = val
    dval = 0.0D0
    cdum = " "
    CALL cf77st(2, stmt%slot, idx, nval, dval, cdum, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_bind_i32

  !> @brief Binds a DOUBLE PRECISION parameter at 1-based index idx.
  !> @param[in] stmt Statement handle.
  !> @param[in] idx 1-based parameter index.
  !> @param[in] val Double-precision value.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_bind_f64(stmt, idx, val, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    DOUBLE PRECISION, INTENT(IN) :: val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ival, ilen
    DOUBLE PRECISION :: dtmp
    CHARACTER(LEN=1) :: cdum
    ival = 0
    dtmp = val
    cdum = " "
    CALL cf77st(3, stmt%slot, idx, ival, dtmp, cdum, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_bind_f64

  !> @brief Binds a CHARACTER string parameter at 1-based index idx.
  !> @param[in] stmt Statement handle.
  !> @param[in] idx 1-based parameter index.
  !> @param[in] val String value.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_bind_str(stmt, idx, val, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ival, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=LEN(val)) :: vcopy
    ival = 0
    dval = 0.0D0
    vcopy = val
    CALL cf77st(4, stmt%slot, idx, ival, dval, vcopy, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_bind_str

  !> @brief Steps a prepared statement by one row.
  !> @param[in] stmt Statement handle.
  !> @param[out] has_row Receives .TRUE. when a row is ready.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_step(stmt, has_row, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    LOGICAL, INTENT(OUT) :: has_row
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ihas, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    ihas = 0
    dval = 0.0D0
    cdum = " "
    CALL cf77st(6, stmt%slot, 0, ihas, dval, cdum, ilen, rc)
    has_row = (rc == 0 .AND. ihas /= 0)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_step

  !> @brief Reads an INTEGER value from 1-based column idx.
  !> @param[in] stmt Statement handle.
  !> @param[in] idx 1-based column index.
  !> @param[out] val Receives integer value.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_col_i32(stmt, idx, val, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    INTEGER, INTENT(OUT) :: val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    dval = 0.0D0
    cdum = " "
    CALL cf77st(8, stmt%slot, idx, val, dval, cdum, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_col_i32

  !> @brief Reads a DOUBLE PRECISION value from 1-based column idx.
  !> @param[in] stmt Statement handle.
  !> @param[in] idx 1-based column index.
  !> @param[out] val Receives double-precision value.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_col_f64(stmt, idx, val, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    DOUBLE PRECISION, INTENT(OUT) :: val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ival, ilen
    CHARACTER(LEN=1) :: cdum
    ival = 0
    cdum = " "
    CALL cf77st(9, stmt%slot, idx, ival, val, cdum, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_col_f64

  !> @brief Reads a CHARACTER string from 1-based column idx.
  !> @param[in] stmt Statement handle.
  !> @param[in] idx 1-based column index.
  !> @param[out] val Destination blank-padded string.
  !> @param[out] out_len Optional trimmed character length.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_col_str(stmt, idx, val, out_len, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    CHARACTER(LEN=*), INTENT(OUT) :: val
    INTEGER, INTENT(OUT), OPTIONAL :: out_len
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ival, ilen
    DOUBLE PRECISION :: dval
    ival = 0
    dval = 0.0D0
    CALL cf77st(10, stmt%slot, idx, ival, dval, val, ilen, rc)
    IF (PRESENT(out_len)) out_len = ilen
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_col_str

  !> @brief Finalizes a prepared statement handle.
  !> @param[inout] stmt Statement handle (slot cleared to 0).
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_finalize(stmt, ierr)
    TYPE(corm_stmt_f90), INTENT(INOUT) :: stmt
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc
    CALL cf77cl(2, stmt%slot, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_finalize

  !> @brief Batch-inserts an assumed-shape 2D DOUBLE PRECISION matrix.
  !> @param[in] db Active DB handle.
  !> @param[in] sql Parameterized INSERT SQL.
  !> @param[in] mat Assumed-shape 2D matrix (any slice/stride packed safely).
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_insert_matrix(db, sql, mat, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(IN) :: mat
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: buf
    CHARACTER(LEN=LEN(sql)) :: scopy
    INTEGER :: nr, nc, nout, rc
    nr = SIZE(mat, 1)
    nc = SIZE(mat, 2)
    ALLOCATE(buf(MAX(nr, 1), MAX(nc, 1)))
    buf(1:nr, 1:nc) = mat
    scopy = sql
    CALL cf77mx(1, db%slot, scopy, buf, MAX(nr, 1), nr, nc, nout, rc)
    DEALLOCATE(buf)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_insert_matrix

  !> @brief Hydrates a SQL SELECT into an assumed-shape 2D matrix.
  !> @param[in] db Active DB handle.
  !> @param[in] sql SELECT SQL query.
  !> @param[out] mat Destination 2D matrix.
  !> @param[out] out_rows Receives number of rows hydrated.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_query_matrix(db, sql, mat, out_rows, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(OUT) :: mat
    INTEGER, INTENT(OUT) :: out_rows
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: buf
    CHARACTER(LEN=LEN(sql)) :: scopy
    INTEGER :: nr, nc, rc
    nr = SIZE(mat, 1)
    nc = SIZE(mat, 2)
    ALLOCATE(buf(MAX(nr, 1), MAX(nc, 1)))
    buf = 0.0D0
    scopy = sql
    CALL cf77mx(2, db%slot, scopy, buf, MAX(nr, 1), nr, nc, out_rows, rc)
    IF (rc == 0 .AND. out_rows > 0) THEN
      mat(1:out_rows, 1:nc) = buf(1:out_rows, 1:nc)
    END IF
    DEALLOCATE(buf)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_query_matrix

  !> @brief Creates a SELECT * FROM <table> AST builder.
  !> @param[in] table_name SQL table identifier.
  !> @param[in] limit_rows Optional row limit (0 for none).
  !> @param[out] ast Initialized AST handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ast_select(table_name, limit_rows, ast, ierr)
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER, INTENT(IN) :: limit_rows
    TYPE(corm_ast_f90), INTENT(OUT) :: ast
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    DOUBLE PRECISION, DIMENSION(1, 1) :: ddum
    CHARACTER(LEN=LEN(table_name)) :: tcopy
    INTEGER :: rc
    ast%slot = 0
    ddum(1, 1) = 0.0D0
    tcopy = table_name
    CALL cf77mx(3, 0, tcopy, ddum, 1, limit_rows, 1, ast%slot, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ast_select

  !> @brief Renders an AST handle into SQL for the specified dialect.
  !> @param[in] ast AST handle.
  !> @param[in] dialect Target SQL dialect constant.
  !> @param[out] out_sql Destination SQL buffer.
  !> @param[out] out_len Receives trimmed SQL length.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ast_to_sql(ast, dialect, out_sql, out_len, ierr)
    TYPE(corm_ast_f90), INTENT(IN) :: ast
    INTEGER, INTENT(IN) :: dialect
    CHARACTER(LEN=*), INTENT(OUT) :: out_sql
    INTEGER, INTENT(OUT) :: out_len
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    DOUBLE PRECISION, DIMENSION(1, 1) :: ddum
    INTEGER :: rc
    ddum(1, 1) = 0.0D0
    out_sql = " "
    CALL cf77mx(4, ast%slot, out_sql, ddum, 1, 0, dialect, out_len, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ast_to_sql

  !> @brief Frees an AST handle.
  !> @param[inout] ast AST handle (slot cleared to 0).
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ast_free(ast, ierr)
    TYPE(corm_ast_f90), INTENT(INOUT) :: ast
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc
    CALL cf77cl(4, ast%slot, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ast_free

END MODULE fortran_orm_f90
