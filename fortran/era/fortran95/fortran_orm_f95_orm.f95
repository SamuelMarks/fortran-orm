!> @file fortran_orm_f95_orm.f95
!> @module fortran_orm_f95_orm
!> @brief Extended ISO/IEC 1539-1:1997 Fortran 95 ORM module: default-init
!> statement/AST/grid2d handles (`=> NULL()`), `PURE` & `ELEMENTAL` predicates
!> and numerical kernels, generic `corm_f95_bind`/`corm_f95_col`, savepoints,
!> `FORALL` affine & masked matrix persistence, and 2D structured PDE mesh
!> checkpointing (`corm_grid2d_f95`).
!>
!> Strictly complies with `-std=f95` (`<= 31`-char identifiers, zero
!> `ISO_C_BINDING`/`CLASS`/`FINAL`/`SUBMODULE`/`CONTIGUOUS` keywords).
MODULE fortran_orm_f95_orm
  USE fortran_orm_f95
  IMPLICIT NONE
  PRIVATE

  PUBLIC :: CORM_F95_OK, corm_db_f95
  PUBLIC :: corm_f95_is_ok, corm_f95_db_is_open
  PUBLIC :: corm_f95_open, corm_f95_close, corm_f95_exec
  PUBLIC :: corm_f95_insert_scaled_matrix, corm_f95_query_matrix

  INTEGER, PARAMETER, PUBLIC :: CORM_F95_DIALECT_SQLITE = 0
  INTEGER, PARAMETER, PUBLIC :: CORM_F95_DIALECT_POSTGRES = 1
  INTEGER, PARAMETER, PUBLIC :: CORM_F95_DIALECT_MYSQL = 2
  INTEGER, PARAMETER, PUBLIC :: CORM_F95_DIALECT_DB2 = 3
  INTEGER, PARAMETER, PUBLIC :: CORM_F95_DIALECT_ODBC = 4

  !> @type corm_stmt_f95
  !> @brief Fortran 95 prepared statement handle with default initialization.
  TYPE, PUBLIC :: corm_stmt_f95
    INTEGER :: slot = 0
  END TYPE corm_stmt_f95

  !> @type corm_ast_f95
  !> @brief Fortran 95 SQL AST builder handle with default initialization.
  TYPE, PUBLIC :: corm_ast_f95
    INTEGER :: slot = 0
  END TYPE corm_ast_f95

  !> @type corm_grid2d_f95
  !> @brief Structured 2D Fortran 95 scientific mesh with `=> NULL()` pointer.
  TYPE, PUBLIC :: corm_grid2d_f95
    INTEGER :: nx = 0
    INTEGER :: ny = 0
    DOUBLE PRECISION :: dx = 1.0D0
    DOUBLE PRECISION :: dy = 1.0D0
    DOUBLE PRECISION, DIMENSION(:, :), POINTER :: cells => NULL()
  END TYPE corm_grid2d_f95

  INTERFACE
    !> @brief Low-level C89 close/free bridge.
    !> @param[in] imode Resource kind.
    !> @param[inout] ihnd Slot ID.
    !> @param[out] ierr Status code.
    SUBROUTINE cf77cl(imode, ihnd, ierr)
      INTEGER, INTENT(IN) :: imode
      INTEGER, INTENT(INOUT) :: ihnd
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77cl

    !> @brief Low-level C89 transaction/savepoint bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] idb DB slot.
    !> @param[in] sql SQL or savepoint identifier.
    !> @param[out] iout Output integer.
    !> @param[out] ierr Status code.
    SUBROUTINE cf77ex(imode, idb, sql, iout, ierr)
      INTEGER, INTENT(IN) :: imode
      INTEGER, INTENT(IN) :: idb
      CHARACTER(LEN=*), INTENT(IN) :: sql
      INTEGER, INTENT(OUT) :: iout
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77ex

    !> @brief Low-level C89 prepared statement bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] ihnd DB or statement slot.
    !> @param[in] iidx 1-based index.
    !> @param[inout] ival Integer input/output.
    !> @param[inout] dval Double input/output.
    !> @param[inout] cbuf Character buffer.
    !> @param[out] ilen Written string length.
    !> @param[out] ierr Status code.
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
    !> @param[inout] dmat Column-major matrix.
    !> @param[in] ldrows Leading dimension.
    !> @param[in] nrows Row count.
    !> @param[in] ncols Column count or dialect.
    !> @param[out] nout Output count/slot/length.
    !> @param[out] ierr Status code.
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

  !> @brief Generic overloaded Fortran 95 parameter binding interface.
  INTERFACE corm_f95_bind
    MODULE PROCEDURE corm_f95_bind_i32
    MODULE PROCEDURE corm_f95_bind_f64
    MODULE PROCEDURE corm_f95_bind_str
  END INTERFACE corm_f95_bind

  !> @brief Generic overloaded Fortran 95 column reader interface.
  INTERFACE corm_f95_col
    MODULE PROCEDURE corm_f95_col_i32
    MODULE PROCEDURE corm_f95_col_f64
    MODULE PROCEDURE corm_f95_col_str
  END INTERFACE corm_f95_col

  PUBLIC :: corm_f95_is_err, corm_f95_stmt_is_open, corm_f95_ast_is_open
  PUBLIC :: corm_f95_affine_val, corm_f95_clamp_val
  PUBLIC :: corm_f95_tx_begin, corm_f95_tx_commit, corm_f95_tx_rollback
  PUBLIC :: corm_f95_savepoint, corm_f95_rollback_sp, corm_f95_release_sp
  PUBLIC :: corm_f95_prepare, corm_f95_step, corm_f95_reset, corm_f95_finalize
  PUBLIC :: corm_f95_bind, corm_f95_col
  PUBLIC :: corm_f95_insert_affine_matrix, corm_f95_insert_masked_matrix
  PUBLIC :: corm_f95_ast_select, corm_f95_ast_to_sql, corm_f95_ast_free
  PUBLIC :: corm_f95_grid_alloc, corm_f95_grid_free
  PUBLIC :: corm_f95_grid_save, corm_f95_grid_load

CONTAINS

  !> @brief Elemental Fortran 95 predicate returning `.TRUE.` on error codes.
  !> @param[in] rc Integer status code(s).
  !> @return `.TRUE.` where `rc /= CORM_F95_OK`.
  ELEMENTAL FUNCTION corm_f95_is_err(rc) RESULT(is_err)
    INTEGER, INTENT(IN) :: rc
    LOGICAL :: is_err
    is_err = (rc /= CORM_F95_OK)
  END FUNCTION corm_f95_is_err

  !> @brief Pure Fortran 95 predicate checking whether `stmt` is prepared.
  !> @param[in] stmt Statement handle.
  !> @return `.TRUE.` when `stmt%slot > 0`.
  PURE FUNCTION corm_f95_stmt_is_open(stmt) RESULT(is_open)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    LOGICAL :: is_open
    is_open = (stmt%slot > 0)
  END FUNCTION corm_f95_stmt_is_open

  !> @brief Pure Fortran 95 predicate checking whether `ast` is allocated.
  !> @param[in] ast AST handle.
  !> @return `.TRUE.` when `ast%slot > 0`.
  PURE FUNCTION corm_f95_ast_is_open(ast) RESULT(is_open)
    TYPE(corm_ast_f95), INTENT(IN) :: ast
    LOGICAL :: is_open
    is_open = (ast%slot > 0)
  END FUNCTION corm_f95_ast_is_open

  !> @brief Elemental affine calibration kernel `gain * x + offset`.
  !> @param[in] x Raw value(s).
  !> @param[in] gain Multiplicative scale factor.
  !> @param[in] offset Additive zero-point offset.
  !> @return Calibrated `DOUBLE PRECISION` value(s).
  ELEMENTAL FUNCTION corm_f95_affine_val(x, gain, offset) RESULT(y)
    DOUBLE PRECISION, INTENT(IN) :: x, gain, offset
    DOUBLE PRECISION :: y
    y = gain * x + offset
  END FUNCTION corm_f95_affine_val

  !> @brief Elemental interval clamp kernel `MIN(MAX(x, lo), hi)`.
  !> @param[in] x Input scalar or array.
  !> @param[in] lo Lower bound.
  !> @param[in] hi Upper bound.
  !> @return Clamped `DOUBLE PRECISION` value(s).
  ELEMENTAL FUNCTION corm_f95_clamp_val(x, lo, hi) RESULT(y)
    DOUBLE PRECISION, INTENT(IN) :: x, lo, hi
    DOUBLE PRECISION :: y
    y = MIN(MAX(x, lo), hi)
  END FUNCTION corm_f95_clamp_val

  !> @brief Begins a transaction on `db`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_tx_begin(db, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: iout
    iout = 0
    CALL cf77ex(2, db%slot, " ", iout, ierr)
  END SUBROUTINE corm_f95_tx_begin

  !> @brief Commits the active transaction on `db`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_tx_commit(db, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: iout
    iout = 0
    CALL cf77ex(3, db%slot, " ", iout, ierr)
  END SUBROUTINE corm_f95_tx_commit

  !> @brief Rolls back the active transaction on `db`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_tx_rollback(db, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: iout
    iout = 0
    CALL cf77ex(4, db%slot, " ", iout, ierr)
  END SUBROUTINE corm_f95_tx_rollback

  !> @brief Creates named savepoint `sp_name` on `db`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] sp_name Savepoint identifier.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_savepoint(db, sp_name, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: iout
    iout = 0
    CALL cf77ex(5, db%slot, sp_name, iout, ierr)
  END SUBROUTINE corm_f95_savepoint

  !> @brief Rolls back `db` to named savepoint `sp_name`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] sp_name Savepoint identifier.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_rollback_sp(db, sp_name, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: iout
    iout = 0
    CALL cf77ex(6, db%slot, sp_name, iout, ierr)
  END SUBROUTINE corm_f95_rollback_sp

  !> @brief Releases named savepoint `sp_name` on `db`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] sp_name Savepoint identifier.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_release_sp(db, sp_name, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: iout
    iout = 0
    CALL cf77ex(7, db%slot, sp_name, iout, ierr)
  END SUBROUTINE corm_f95_release_sp

  !> @brief Prepares parameterized SQL into `stmt`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] sql Parameterized SQL string.
  !> @param[out] stmt Statement handle (`slot = 0` default-initialized).
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_prepare(db, sql, stmt, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    TYPE(corm_stmt_f95), INTENT(OUT) :: stmt
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=LEN(sql)) :: scopy
    dval = 0.0D0
    ilen = 0
    scopy = sql
    CALL cf77st(1, db%slot, 0, stmt%slot, dval, scopy, ilen, ierr)
  END SUBROUTINE corm_f95_prepare

  !> @brief Binds an `INTEGER` parameter at 1-based `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val Integer value.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_bind_i32(stmt, idx, val, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx, val
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: nval, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    nval = val
    dval = 0.0D0
    cdum = " "
    CALL cf77st(2, stmt%slot, idx, nval, dval, cdum, ilen, ierr)
  END SUBROUTINE corm_f95_bind_i32

  !> @brief Binds a `DOUBLE PRECISION` parameter at 1-based `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val Double-precision value.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_bind_f64(stmt, idx, val, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    DOUBLE PRECISION, INTENT(IN) :: val
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: ival, ilen
    DOUBLE PRECISION :: dtmp
    CHARACTER(LEN=1) :: cdum
    ival = 0
    dtmp = val
    cdum = " "
    CALL cf77st(3, stmt%slot, idx, ival, dtmp, cdum, ilen, ierr)
  END SUBROUTINE corm_f95_bind_f64

  !> @brief Binds a `CHARACTER` parameter at 1-based `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] val String value.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_bind_str(stmt, idx, val, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: ival, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=LEN(val)) :: vcopy
    ival = 0
    dval = 0.0D0
    vcopy = val
    CALL cf77st(4, stmt%slot, idx, ival, dval, vcopy, ilen, ierr)
  END SUBROUTINE corm_f95_bind_str

  !> @brief Steps `stmt` by one row.
  !> @param[in] stmt Active statement handle.
  !> @param[out] has_row Receives `.TRUE.` when a row is ready.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_step(stmt, has_row, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    LOGICAL, INTENT(OUT) :: has_row
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: ihas, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    ihas = 0
    dval = 0.0D0
    cdum = " "
    CALL cf77st(6, stmt%slot, 0, ihas, dval, cdum, ilen, ierr)
    has_row = (ierr == CORM_F95_OK .AND. ihas /= 0)
  END SUBROUTINE corm_f95_step

  !> @brief Resets `stmt` for re-execution.
  !> @param[in] stmt Active statement handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_reset(stmt, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: ival, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    ival = 0
    dval = 0.0D0
    cdum = " "
    CALL cf77st(7, stmt%slot, 0, ival, dval, cdum, ilen, ierr)
  END SUBROUTINE corm_f95_reset

  !> @brief Reads an `INTEGER` column at 1-based `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based column position.
  !> @param[out] val Receives integer value.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_col_i32(stmt, idx, val, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    INTEGER, INTENT(OUT) :: val
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    dval = 0.0D0
    cdum = " "
    CALL cf77st(8, stmt%slot, idx, val, dval, cdum, ilen, ierr)
  END SUBROUTINE corm_f95_col_i32

  !> @brief Reads a `DOUBLE PRECISION` column at 1-based `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based column position.
  !> @param[out] val Receives double-precision value.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_col_f64(stmt, idx, val, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    DOUBLE PRECISION, INTENT(OUT) :: val
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: ival, ilen
    CHARACTER(LEN=1) :: cdum
    ival = 0
    cdum = " "
    CALL cf77st(9, stmt%slot, idx, ival, val, cdum, ilen, ierr)
  END SUBROUTINE corm_f95_col_f64

  !> @brief Reads a `CHARACTER` column at 1-based `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based column position.
  !> @param[out] val Destination character variable.
  !> @param[out] out_len Trimmed string length.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_col_str(stmt, idx, val, out_len, ierr)
    TYPE(corm_stmt_f95), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    CHARACTER(LEN=*), INTENT(OUT) :: val
    INTEGER, INTENT(OUT) :: out_len, ierr
    INTEGER :: ival
    DOUBLE PRECISION :: dval
    ival = 0
    dval = 0.0D0
    CALL cf77st(10, stmt%slot, idx, ival, dval, val, out_len, ierr)
  END SUBROUTINE corm_f95_col_str

  !> @brief Finalizes `stmt` and resets `stmt%slot` to `0`.
  !> @param[inout] stmt Statement handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_finalize(stmt, ierr)
    TYPE(corm_stmt_f95), INTENT(INOUT) :: stmt
    INTEGER, INTENT(OUT) :: ierr
    CALL cf77cl(2, stmt%slot, ierr)
  END SUBROUTINE corm_f95_finalize

  !> @brief Applies an affine transform (`gain * mat + offset`) via `FORALL`
  !> and batch-inserts the calibrated 2D matrix.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] sql Parameterized `INSERT` SQL.
  !> @param[in] mat Source 2D `DOUBLE PRECISION` matrix.
  !> @param[in] gain Multiplicative scale factor.
  !> @param[in] offset Additive zero-point offset.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_insert_affine_matrix(db, sql, mat, gain, offset, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(IN) :: mat
    DOUBLE PRECISION, INTENT(IN) :: gain, offset
    INTEGER, INTENT(OUT) :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: buf
    CHARACTER(LEN=LEN(sql)) :: scopy
    INTEGER :: nr, nc, i, j, nout
    nr = SIZE(mat, 1)
    nc = SIZE(mat, 2)
    ALLOCATE(buf(MAX(nr, 1), MAX(nc, 1)))
    buf = 0.0D0
    FORALL (i = 1:nr, j = 1:nc)
      buf(i, j) = corm_f95_affine_val(mat(i, j), gain, offset)
    END FORALL
    scopy = sql
    CALL cf77mx(1, db%slot, scopy, buf, MAX(nr, 1), nr, nc, nout, ierr)
    DEALLOCATE(buf)
  END SUBROUTINE corm_f95_insert_affine_matrix

  !> @brief Applies a masked `FORALL` filter replacing masked-out cells with
  !> `fill_val` before batch-inserting the 2D matrix.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] sql Parameterized `INSERT` SQL.
  !> @param[in] mat Source 2D `DOUBLE PRECISION` matrix.
  !> @param[in] valid_mask 2D `LOGICAL` mask matching shape of `mat`.
  !> @param[in] fill_val Replacement value where `.NOT. valid_mask(i,j)`.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_insert_masked_matrix(db, sql, mat, valid_mask, &
                                           fill_val, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(IN) :: mat
    LOGICAL, DIMENSION(:, :), INTENT(IN) :: valid_mask
    DOUBLE PRECISION, INTENT(IN) :: fill_val
    INTEGER, INTENT(OUT) :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: buf
    CHARACTER(LEN=LEN(sql)) :: scopy
    INTEGER :: nr, nc, i, j, nout
    nr = SIZE(mat, 1)
    nc = SIZE(mat, 2)
    ALLOCATE(buf(MAX(nr, 1), MAX(nc, 1)))
    buf = fill_val
    FORALL (i = 1:nr, j = 1:nc, valid_mask(i, j))
      buf(i, j) = mat(i, j)
    END FORALL
    scopy = sql
    CALL cf77mx(1, db%slot, scopy, buf, MAX(nr, 1), nr, nc, nout, ierr)
    DEALLOCATE(buf)
  END SUBROUTINE corm_f95_insert_masked_matrix

  !> @brief Creates a `SELECT * FROM <table_name>` AST builder in Fortran 95.
  !> @param[in] table_name SQL table name.
  !> @param[in] limit_rows Optional row limit (`0` for none).
  !> @param[out] ast Default-initialized AST handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_ast_select(table_name, limit_rows, ast, ierr)
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER, INTENT(IN) :: limit_rows
    TYPE(corm_ast_f95), INTENT(OUT) :: ast
    INTEGER, INTENT(OUT) :: ierr
    DOUBLE PRECISION, DIMENSION(1, 1) :: ddum
    CHARACTER(LEN=LEN(table_name)) :: tcopy
    ddum(1, 1) = 0.0D0
    tcopy = table_name
    CALL cf77mx(3, 0, tcopy, ddum, 1, limit_rows, 1, ast%slot, ierr)
  END SUBROUTINE corm_f95_ast_select

  !> @brief Renders `ast` into dialect-specific SQL text.
  !> @param[in] ast AST handle.
  !> @param[in] dialect SQL dialect (`CORM_F95_DIALECT_*`).
  !> @param[out] out_sql Destination SQL buffer.
  !> @param[out] out_len Trimmed SQL byte length.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_ast_to_sql(ast, dialect, out_sql, out_len, ierr)
    TYPE(corm_ast_f95), INTENT(IN) :: ast
    INTEGER, INTENT(IN) :: dialect
    CHARACTER(LEN=*), INTENT(OUT) :: out_sql
    INTEGER, INTENT(OUT) :: out_len, ierr
    DOUBLE PRECISION, DIMENSION(1, 1) :: ddum
    ddum(1, 1) = 0.0D0
    out_sql = " "
    CALL cf77mx(4, ast%slot, out_sql, ddum, 1, 0, dialect, out_len, ierr)
  END SUBROUTINE corm_f95_ast_to_sql

  !> @brief Frees `ast` and resets `ast%slot` to `0`.
  !> @param[inout] ast AST handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_ast_free(ast, ierr)
    TYPE(corm_ast_f95), INTENT(INOUT) :: ast
    INTEGER, INTENT(OUT) :: ierr
    CALL cf77cl(4, ast%slot, ierr)
  END SUBROUTINE corm_f95_ast_free

  !> @brief Allocates (or reallocates) a 2D structured mesh `grid`.
  !> @param[inout] grid Structured 2D mesh handle (`cells => NULL()` default).
  !> @param[in] nx Grid count along X (`>= 1`).
  !> @param[in] ny Grid count along Y (`>= 1`).
  !> @param[in] dx Grid spacing along X.
  !> @param[in] dy Grid spacing along Y.
  SUBROUTINE corm_f95_grid_alloc(grid, nx, ny, dx, dy)
    TYPE(corm_grid2d_f95), INTENT(INOUT) :: grid
    INTEGER, INTENT(IN) :: nx, ny
    DOUBLE PRECISION, INTENT(IN) :: dx, dy
    IF (ASSOCIATED(grid%cells)) DEALLOCATE(grid%cells)
    grid%nx = MAX(nx, 1)
    grid%ny = MAX(ny, 1)
    grid%dx = dx
    grid%dy = dy
    ALLOCATE(grid%cells(grid%nx, grid%ny))
    grid%cells = 0.0D0
  END SUBROUTINE corm_f95_grid_alloc

  !> @brief Deallocates `grid%cells` and nullifies the F95 pointer.
  !> @param[inout] grid Structured 2D mesh handle.
  SUBROUTINE corm_f95_grid_free(grid)
    TYPE(corm_grid2d_f95), INTENT(INOUT) :: grid
    IF (ASSOCIATED(grid%cells)) DEALLOCATE(grid%cells)
    NULLIFY(grid%cells)
    grid%nx = 0
    grid%ny = 0
  END SUBROUTINE corm_f95_grid_free

  !> @brief Checkpoints structured 2D mesh `grid` into SQL table `table_name`
  !> as `(x_coord, y_coord, cell_val)` rows generated via `FORALL`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] table_name Target SQL checkpoint table.
  !> @param[in] grid Associated 2D mesh handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_grid_save(db, table_name, grid, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    TYPE(corm_grid2d_f95), INTENT(IN) :: grid
    INTEGER, INTENT(OUT) :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: tuples
    CHARACTER(LEN=192) :: ddl, dml, ins
    INTEGER :: ntot, i, j, nout
    IF (.NOT. ASSOCIATED(grid%cells) .OR. LEN_TRIM(table_name) <= 0) THEN
      ierr = 11
      RETURN
    END IF
    ddl = "CREATE TABLE IF NOT EXISTS " // TRIM(table_name) // &
          "(ix REAL, iy REAL, u REAL)"
    CALL corm_f95_exec(db, ddl, ierr)
    IF (corm_f95_is_err(ierr)) RETURN
    dml = "DELETE FROM " // TRIM(table_name)
    CALL corm_f95_exec(db, dml, ierr)
    IF (corm_f95_is_err(ierr)) RETURN
    ntot = grid%nx * grid%ny
    ALLOCATE(tuples(ntot, 3))
    FORALL (i = 1:grid%nx, j = 1:grid%ny)
      tuples((j - 1) * grid%nx + i, 1) = DBLE(i - 1) * grid%dx
      tuples((j - 1) * grid%nx + i, 2) = DBLE(j - 1) * grid%dy
      tuples((j - 1) * grid%nx + i, 3) = grid%cells(i, j)
    END FORALL
    ins = "INSERT INTO " // TRIM(table_name) // " VALUES(?,?,?)"
    CALL cf77mx(1, db%slot, ins, tuples, ntot, ntot, 3, nout, ierr)
    DEALLOCATE(tuples)
  END SUBROUTINE corm_f95_grid_save

  !> @brief Restores `grid%cells` from SQL checkpoint table `table_name`.
  !> @param[in] db Active Fortran 95 DB handle.
  !> @param[in] table_name Source SQL checkpoint table.
  !> @param[inout] grid Pre-allocated 2D mesh handle (`nx * ny` cells).
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_grid_load(db, table_name, grid, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    TYPE(corm_grid2d_f95), INTENT(INOUT) :: grid
    INTEGER, INTENT(OUT) :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: tuples
    CHARACTER(LEN=192) :: sel
    INTEGER :: ntot, i, j, nrows
    IF (.NOT. ASSOCIATED(grid%cells) .OR. LEN_TRIM(table_name) <= 0) THEN
      ierr = 11
      RETURN
    END IF
    ntot = grid%nx * grid%ny
    ALLOCATE(tuples(ntot, 3))
    tuples = 0.0D0
    sel = "SELECT ix, iy, u FROM " // TRIM(table_name)
    CALL cf77mx(2, db%slot, sel, tuples, ntot, ntot, 3, nrows, ierr)
    IF (corm_f95_is_ok(ierr) .AND. nrows == ntot) THEN
      FORALL (i = 1:grid%nx, j = 1:grid%ny)
        grid%cells(i, j) = tuples((j - 1) * grid%nx + i, 3)
      END FORALL
    ELSE IF (corm_f95_is_ok(ierr)) THEN
      ierr = 7
    END IF
    DEALLOCATE(tuples)
  END SUBROUTINE corm_f95_grid_load

END MODULE fortran_orm_f95_orm
