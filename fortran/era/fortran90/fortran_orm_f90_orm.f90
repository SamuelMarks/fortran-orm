!> @file fortran_orm_f90_orm.f90
!> @module fortran_orm_f90_orm
!> @brief High-level ISO/IEC 1539:1991 Fortran 90 ORM abstractions: savepoints,
!> NULL & LOGICAL marshaling, generic 1D vector persistence, scalar aggregates,
!> fluent derived-type SQL query builder (`corm_query_f90_t`), persistent
!> Key-Value store (`corm_kv_f90_t`), and time-series checkpoint ledger
!> (`corm_ts_f90_t`).
!>
!> Strictly adheres to ISO Fortran 90 (`<= 31`-char identifiers, `(/ ... /)`
!> array constructors, zero `PURE`/`ELEMENTAL`/`FORALL`/`ISO_C_BINDING`/`CLASS`
!> extensions).
MODULE fortran_orm_f90_orm
  USE fortran_orm_f90
  IMPLICIT NONE
  PRIVATE

  PUBLIC :: CORM_F90_OK
  PUBLIC :: CORM_F90_DIALECT_SQLITE, CORM_F90_DIALECT_POSTGRES
  PUBLIC :: CORM_F90_DIALECT_MYSQL, CORM_F90_DIALECT_DB2
  PUBLIC :: CORM_F90_DIALECT_ODBC
  PUBLIC :: corm_db_f90, corm_stmt_f90, corm_ast_f90
  PUBLIC :: corm_f90_open, corm_f90_close, corm_f90_exec
  PUBLIC :: corm_f90_tx_begin, corm_f90_tx_commit, corm_f90_tx_rollback
  PUBLIC :: corm_f90_prepare, corm_f90_step, corm_f90_finalize
  PUBLIC :: corm_f90_bind, corm_f90_col
  PUBLIC :: corm_f90_insert_matrix, corm_f90_query_matrix
  PUBLIC :: corm_f90_ast_select, corm_f90_ast_to_sql, corm_f90_ast_free

  INTEGER, PARAMETER, PUBLIC :: CORM_F90_ERR_VAL = 11
  INTEGER, PARAMETER, PUBLIC :: CORM_F90_ERR_BUF = 34

  !> @type corm_query_f90_t
  !> @brief Pure ISO Fortran 90 fluent SELECT SQL query builder state.
  TYPE, PUBLIC :: corm_query_f90_t
    CHARACTER(LEN=64) :: table_name
    CHARACTER(LEN=128) :: select_cols
    CHARACTER(LEN=256) :: join_clause
    CHARACTER(LEN=256) :: where_clause
    CHARACTER(LEN=128) :: group_clause
    CHARACTER(LEN=128) :: having_clause
    CHARACTER(LEN=128) :: order_clause
    LOGICAL :: is_distinct
    INTEGER :: where_count
    INTEGER :: limit_rows
    INTEGER :: offset_rows
  END TYPE corm_query_f90_t

  !> @type corm_kv_f90_t
  !> @brief Persistent ISO Fortran 90 Key-Value configuration repository.
  TYPE, PUBLIC :: corm_kv_f90_t
    TYPE(corm_db_f90) :: db
    CHARACTER(LEN=48) :: table_name
  END TYPE corm_kv_f90_t

  !> @type corm_ts_f90_t
  !> @brief Checkpointed ISO Fortran 90 scientific time-series table handle.
  TYPE, PUBLIC :: corm_ts_f90_t
    TYPE(corm_db_f90) :: db
    CHARACTER(LEN=48) :: table_name
  END TYPE corm_ts_f90_t

  INTERFACE
    !> @brief Low-level C89 exec/savepoint/rowid bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] idb DB slot.
    !> @param[in] sql SQL or savepoint identifier.
    !> @param[out] iout Integer output.
    !> @param[out] ierr Status code.
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
  END INTERFACE

  !> @brief Generic overloaded 1D vector batch-insert interface.
  INTERFACE corm_f90_insert_vec
    MODULE PROCEDURE corm_f90_insert_vec_i32
    MODULE PROCEDURE corm_f90_insert_vec_f64
  END INTERFACE corm_f90_insert_vec

  !> @brief Generic overloaded 1D vector query hydration interface.
  INTERFACE corm_f90_query_vec
    MODULE PROCEDURE corm_f90_query_vec_i32
    MODULE PROCEDURE corm_f90_query_vec_f64
  END INTERFACE corm_f90_query_vec

  PUBLIC :: corm_f90_savepoint, corm_f90_rollback_sp, corm_f90_release_sp
  PUBLIC :: corm_f90_last_rowid, corm_f90_reset
  PUBLIC :: corm_f90_bind_null, corm_f90_col_is_null
  PUBLIC :: corm_f90_bind_logical, corm_f90_col_logical
  PUBLIC :: corm_f90_insert_vec, corm_f90_query_vec
  PUBLIC :: corm_f90_scalar_i32, corm_f90_scalar_f64, corm_f90_scalar_str
  PUBLIC :: corm_f90_count, corm_f90_exists_i32, corm_f90_delete_i32
  PUBLIC :: corm_f90_q_init, corm_f90_q_distinct, corm_f90_q_join
  PUBLIC :: corm_f90_q_where_raw, corm_f90_q_where_i32, corm_f90_q_where_str
  PUBLIC :: corm_f90_q_group_by, corm_f90_q_order_by, corm_f90_q_limit_offset
  PUBLIC :: corm_f90_q_render, corm_f90_q_prepare
  PUBLIC :: corm_f90_kv_init, corm_f90_kv_put, corm_f90_kv_get
  PUBLIC :: corm_f90_kv_delete
  PUBLIC :: corm_f90_ts_init, corm_f90_ts_append, corm_f90_ts_latest
  PUBLIC :: corm_f90_ts_max_val, corm_f90_ts_prune_after

CONTAINS

  !> @brief Formats a signed 32-bit integer into a trimmed decimal string.
  !> @param[in] val Signed integer value.
  !> @param[out] out_buf Character buffer (`LEN >= 16`).
  !> @param[out] out_len Number of characters written.
  SUBROUTINE fmt_i32_f90(val, out_buf, out_len)
    INTEGER, INTENT(IN) :: val
    CHARACTER(LEN=*), INTENT(OUT) :: out_buf
    INTEGER, INTENT(OUT) :: out_len
    CHARACTER(LEN=24) :: tmp
    INTEGER :: k, first_nb
    WRITE (tmp, '(I20)') val
    first_nb = 1
    DO k = 1, 20
      IF (tmp(k:k) /= " ") THEN
        first_nb = k
        EXIT
      END IF
    END DO
    out_len = 20 - first_nb + 1
    out_buf = " "
    out_buf(1:out_len) = tmp(first_nb:20)
  END SUBROUTINE fmt_i32_f90

  !> @brief Creates a named SQL savepoint on `db`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sp_name Savepoint identifier.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_savepoint(db, sp_name, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, iout
    iout = 0
    CALL cf77ex(5, db%slot, sp_name, iout, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_savepoint

  !> @brief Rolls back `db` to named savepoint `sp_name`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sp_name Savepoint identifier.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_rollback_sp(db, sp_name, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, iout
    iout = 0
    CALL cf77ex(6, db%slot, sp_name, iout, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_rollback_sp

  !> @brief Releases named savepoint `sp_name` on `db`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sp_name Savepoint identifier.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_release_sp(db, sp_name, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, iout
    iout = 0
    CALL cf77ex(7, db%slot, sp_name, iout, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_release_sp

  !> @brief Queries the last inserted 32-bit row identifier on `db`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[out] rowid Receives last inserted row ID.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_last_rowid(db, rowid, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    INTEGER, INTENT(OUT) :: rowid
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc
    rowid = 0
    CALL cf77ex(8, db%slot, " ", rowid, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_last_rowid

  !> @brief Resets `stmt` for re-execution with fresh parameter bindings.
  !> @param[in] stmt Active statement handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_reset(stmt, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ival, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    ival = 0
    dval = 0.0D0
    cdum = " "
    CALL cf77st(7, stmt%slot, 0, ival, dval, cdum, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_reset

  !> @brief Binds SQL `NULL` at 1-based parameter index `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based parameter position.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_bind_null(stmt, idx, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, ival, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    ival = 0
    dval = 0.0D0
    cdum = " "
    CALL cf77st(5, stmt%slot, idx, ival, dval, cdum, ilen, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_bind_null

  !> @brief Checks whether 1-based result column `idx` is SQL `NULL`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based column position.
  !> @param[out] is_null Receives `.TRUE.` if SQL `NULL`, `.FALSE.` otherwise.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_col_is_null(stmt, idx, is_null, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    LOGICAL, INTENT(OUT) :: is_null
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, inul, ilen
    DOUBLE PRECISION :: dval
    CHARACTER(LEN=1) :: cdum
    inul = 0
    dval = 0.0D0
    cdum = " "
    CALL cf77st(11, stmt%slot, idx, inul, dval, cdum, ilen, rc)
    is_null = (rc == CORM_F90_OK .AND. inul /= 0)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_col_is_null

  !> @brief Binds a Fortran `LOGICAL` flag (`1` or `0`) at 1-based `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based parameter position.
  !> @param[in] flag Logical value to bind.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_bind_logical(stmt, idx, flag, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    LOGICAL, INTENT(IN) :: flag
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, iv
    iv = 0
    IF (flag) iv = 1
    CALL corm_f90_bind(stmt, idx, iv, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_bind_logical

  !> @brief Reads a Fortran `LOGICAL` flag from 1-based column `idx`.
  !> @param[in] stmt Active statement handle.
  !> @param[in] idx 1-based column position.
  !> @param[out] flag Receives `.TRUE.` when integer column /= 0.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_col_logical(stmt, idx, flag, ierr)
    TYPE(corm_stmt_f90), INTENT(IN) :: stmt
    INTEGER, INTENT(IN) :: idx
    LOGICAL, INTENT(OUT) :: flag
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    INTEGER :: rc, iv
    iv = 0
    CALL corm_f90_col(stmt, idx, iv, rc)
    flag = (rc == CORM_F90_OK .AND. iv /= 0)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_col_logical

  !> @brief Savepoint-guarded batch insert of an assumed-shape 1D `INTEGER` vec.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql Single-parameter `INSERT` SQL.
  !> @param[in] vec Source 1D integer array.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_insert_vec_i32(db, sql, vec, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER, DIMENSION(:), INTENT(IN) :: vec
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    INTEGER :: n, k, rc, f_rc, sp_rc
    n = SIZE(vec, 1)
    IF (n <= 0) THEN
      IF (PRESENT(ierr)) ierr = CORM_F90_OK
      RETURN
    END IF
    CALL corm_f90_savepoint(db, "f90_vi32", rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      CALL corm_f90_rollback_sp(db, "f90_vi32", sp_rc)
      CALL corm_f90_release_sp(db, "f90_vi32", sp_rc)
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    DO k = 1, n
      CALL corm_f90_bind(stmt, 1, vec(k), rc)
      IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, rc)
      IF (rc == CORM_F90_OK) CALL corm_f90_reset(stmt, rc)
      IF (rc /= CORM_F90_OK) EXIT
    END DO
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (rc == CORM_F90_OK) THEN
      CALL corm_f90_release_sp(db, "f90_vi32", rc)
    ELSE
      CALL corm_f90_rollback_sp(db, "f90_vi32", sp_rc)
      CALL corm_f90_release_sp(db, "f90_vi32", sp_rc)
    END IF
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_insert_vec_i32

  !> @brief Savepoint-guarded batch insert of a 1D `DOUBLE PRECISION` vector.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql Single-parameter `INSERT` SQL.
  !> @param[in] vec Source 1D double-precision array.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_insert_vec_f64(db, sql, vec, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:), INTENT(IN) :: vec
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    INTEGER :: n, k, rc, f_rc, sp_rc
    n = SIZE(vec, 1)
    IF (n <= 0) THEN
      IF (PRESENT(ierr)) ierr = CORM_F90_OK
      RETURN
    END IF
    CALL corm_f90_savepoint(db, "f90_vf64", rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      CALL corm_f90_rollback_sp(db, "f90_vf64", sp_rc)
      CALL corm_f90_release_sp(db, "f90_vf64", sp_rc)
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    DO k = 1, n
      CALL corm_f90_bind(stmt, 1, vec(k), rc)
      IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, rc)
      IF (rc == CORM_F90_OK) CALL corm_f90_reset(stmt, rc)
      IF (rc /= CORM_F90_OK) EXIT
    END DO
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (rc == CORM_F90_OK) THEN
      CALL corm_f90_release_sp(db, "f90_vf64", rc)
    ELSE
      CALL corm_f90_rollback_sp(db, "f90_vf64", sp_rc)
      CALL corm_f90_release_sp(db, "f90_vf64", sp_rc)
    END IF
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_insert_vec_f64

  !> @brief Hydrates column 1 of `sql` into an assumed-shape 1D `INTEGER` vec.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql `SELECT` SQL query.
  !> @param[out] out_vec Destination 1D integer array.
  !> @param[out] out_count Number of elements hydrated.
  !> @param[out] ierr Optional status code (`34` on capacity overflow).
  SUBROUTINE corm_f90_query_vec_i32(db, sql, out_vec, out_count, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER, DIMENSION(:), INTENT(OUT) :: out_vec
    INTEGER, INTENT(OUT) :: out_count
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    INTEGER :: cap, rc, f_rc
    out_vec = 0
    out_count = 0
    cap = SIZE(out_vec, 1)
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    DO
      CALL corm_f90_step(stmt, has_row, rc)
      IF (rc /= CORM_F90_OK .OR. .NOT. has_row) EXIT
      IF (out_count >= cap) THEN
        rc = CORM_F90_ERR_BUF
        EXIT
      END IF
      out_count = out_count + 1
      CALL corm_f90_col(stmt, 1, out_vec(out_count), rc)
      IF (rc /= CORM_F90_OK) EXIT
    END DO
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_query_vec_i32

  !> @brief Hydrates column 1 of `sql` into a 1D `DOUBLE PRECISION` vector.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql `SELECT` SQL query.
  !> @param[out] out_vec Destination 1D double-precision array.
  !> @param[out] out_count Number of elements hydrated.
  !> @param[out] ierr Optional status code (`34` on capacity overflow).
  SUBROUTINE corm_f90_query_vec_f64(db, sql, out_vec, out_count, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:), INTENT(OUT) :: out_vec
    INTEGER, INTENT(OUT) :: out_count
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    INTEGER :: cap, rc, f_rc
    out_vec = 0.0D0
    out_count = 0
    cap = SIZE(out_vec, 1)
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    DO
      CALL corm_f90_step(stmt, has_row, rc)
      IF (rc /= CORM_F90_OK .OR. .NOT. has_row) EXIT
      IF (out_count >= cap) THEN
        rc = CORM_F90_ERR_BUF
        EXIT
      END IF
      out_count = out_count + 1
      CALL corm_f90_col(stmt, 1, out_vec(out_count), rc)
      IF (rc /= CORM_F90_OK) EXIT
    END DO
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_query_vec_f64

  !> @brief Executes a scalar `INTEGER` query with `NULL` default fallback.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql `SELECT` SQL returning 1 integer column.
  !> @param[in] default_val Fallback value when empty or SQL `NULL`.
  !> @param[out] out_val Receives scalar integer result.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_scalar_i32(db, sql, default_val, out_val, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER, INTENT(IN) :: default_val
    INTEGER, INTENT(OUT) :: out_val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row, is_null
    INTEGER :: rc, f_rc
    out_val = default_val
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_step(stmt, has_row, rc)
    IF (rc == CORM_F90_OK .AND. has_row) THEN
      CALL corm_f90_col_is_null(stmt, 1, is_null, rc)
      IF (rc == CORM_F90_OK .AND. .NOT. is_null) THEN
        CALL corm_f90_col(stmt, 1, out_val, rc)
      END IF
    END IF
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_scalar_i32

  !> @brief Executes a scalar `DOUBLE PRECISION` query with `NULL` fallback.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql `SELECT` SQL returning 1 float column.
  !> @param[in] default_val Fallback value when empty or SQL `NULL`.
  !> @param[out] out_val Receives scalar double-precision result.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_scalar_f64(db, sql, default_val, out_val, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, INTENT(IN) :: default_val
    DOUBLE PRECISION, INTENT(OUT) :: out_val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row, is_null
    INTEGER :: rc, f_rc
    out_val = default_val
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_step(stmt, has_row, rc)
    IF (rc == CORM_F90_OK .AND. has_row) THEN
      CALL corm_f90_col_is_null(stmt, 1, is_null, rc)
      IF (rc == CORM_F90_OK .AND. .NOT. is_null) THEN
        CALL corm_f90_col(stmt, 1, out_val, rc)
      END IF
    END IF
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_scalar_f64

  !> @brief Executes a scalar `CHARACTER` query with `NULL` default fallback.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] sql `SELECT` SQL returning 1 string column.
  !> @param[in] default_val Fallback string when empty or SQL `NULL`.
  !> @param[out] out_str Destination blank-padded string.
  !> @param[out] out_len Trimmed string length.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_scalar_str(db, sql, default_val, out_str, out_len, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql, default_val
    CHARACTER(LEN=*), INTENT(OUT) :: out_str
    INTEGER, INTENT(OUT) :: out_len
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row, is_null
    INTEGER :: rc, f_rc
    out_str = default_val
    out_len = LEN_TRIM(default_val)
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_step(stmt, has_row, rc)
    IF (rc == CORM_F90_OK .AND. has_row) THEN
      CALL corm_f90_col_is_null(stmt, 1, is_null, rc)
      IF (rc == CORM_F90_OK .AND. .NOT. is_null) THEN
        CALL corm_f90_col(stmt, 1, out_str, out_len, rc)
      END IF
    END IF
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_scalar_str

  !> @brief Counts rows in `table_name` (with optional `where_sql` filter).
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] table_name Target SQL table name.
  !> @param[out] nrows Receives total matching row count.
  !> @param[in] where_sql Optional `WHERE` predicate expression.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_count(db, table_name, nrows, where_sql, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER, INTENT(OUT) :: nrows
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: where_sql
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    CHARACTER(LEN=256) :: sql
    INTEGER :: lt, lw, rc
    nrows = 0
    lt = LEN_TRIM(table_name)
    IF (lt <= 0) THEN
      IF (PRESENT(ierr)) ierr = CORM_F90_ERR_VAL
      RETURN
    END IF
    sql = "SELECT COUNT(*) FROM " // table_name(1:lt)
    IF (PRESENT(where_sql)) THEN
      lw = LEN_TRIM(where_sql)
      IF (lw > 0) sql = TRIM(sql) // " WHERE " // where_sql(1:lw)
    END IF
    CALL corm_f90_scalar_i32(db, sql, 0, nrows, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_count

  !> @brief Checks whether a row with integer key `id_val` exists in `table_name`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] table_name Target SQL table name.
  !> @param[in] pk_col Primary-key column name.
  !> @param[in] id_val Integer key value to probe.
  !> @param[out] exists_flag Receives `.TRUE.` if row exists.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_exists_i32(db, table_name, pk_col, id_val, exists_flag, &
                                 ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name, pk_col
    INTEGER, INTENT(IN) :: id_val
    LOGICAL, INTENT(OUT) :: exists_flag
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    CHARACTER(LEN=160) :: sql
    INTEGER :: lt, lc, rc, f_rc
    exists_flag = .FALSE.
    lt = LEN_TRIM(table_name)
    lc = LEN_TRIM(pk_col)
    IF (lt <= 0 .OR. lc <= 0) THEN
      IF (PRESENT(ierr)) ierr = CORM_F90_ERR_VAL
      RETURN
    END IF
    sql = "SELECT 1 FROM " // table_name(1:lt) // " WHERE " // &
          pk_col(1:lc) // " = ?"
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_bind(stmt, 1, id_val, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, exists_flag, rc)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_exists_i32

  !> @brief Deletes rows matching integer key `id_val` from `table_name`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] table_name Target SQL table name.
  !> @param[in] pk_col Primary-key column name.
  !> @param[in] id_val Integer key value to delete.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_delete_i32(db, table_name, pk_col, id_val, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name, pk_col
    INTEGER, INTENT(IN) :: id_val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    CHARACTER(LEN=160) :: sql
    INTEGER :: lt, lc, rc, f_rc
    lt = LEN_TRIM(table_name)
    lc = LEN_TRIM(pk_col)
    IF (lt <= 0 .OR. lc <= 0) THEN
      IF (PRESENT(ierr)) ierr = CORM_F90_ERR_VAL
      RETURN
    END IF
    sql = "DELETE FROM " // table_name(1:lt) // " WHERE " // &
          pk_col(1:lc) // " = ?"
    CALL corm_f90_prepare(db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_bind(stmt, 1, id_val, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, rc)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_delete_i32

  !> @brief Initializes a pure Fortran 90 fluent `SELECT` query builder `q`.
  !> @param[out] q Query builder instance.
  !> @param[in] table_name Source SQL table name.
  !> @param[in] cols Optional comma-separated projection (defaults to `"*"`).
  SUBROUTINE corm_f90_q_init(q, table_name, cols)
    TYPE(corm_query_f90_t), INTENT(OUT) :: q
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: cols
    q%table_name = table_name
    q%select_cols = "*"
    IF (PRESENT(cols)) THEN
      IF (LEN_TRIM(cols) > 0) q%select_cols = cols
    END IF
    q%join_clause = " "
    q%where_clause = " "
    q%group_clause = " "
    q%having_clause = " "
    q%order_clause = " "
    q%is_distinct = .FALSE.
    q%where_count = 0
    q%limit_rows = 0
    q%offset_rows = 0
  END SUBROUTINE corm_f90_q_init

  !> @brief Enables `SELECT DISTINCT` on fluent query builder `q`.
  !> @param[inout] q Query builder instance.
  SUBROUTINE corm_f90_q_distinct(q)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    q%is_distinct = .TRUE.
  END SUBROUTINE corm_f90_q_distinct

  !> @brief Appends a `JOIN` clause to fluent query builder `q`.
  !> @param[inout] q Query builder instance.
  !> @param[in] join_kind Join type (`"INNER"`, `"LEFT"`, etc.).
  !> @param[in] target_tbl Joined table identifier.
  !> @param[in] on_expr Join condition expression.
  SUBROUTINE corm_f90_q_join(q, join_kind, target_tbl, on_expr)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    CHARACTER(LEN=*), INTENT(IN) :: join_kind, target_tbl, on_expr
    CHARACTER(LEN=256) :: seg
    seg = TRIM(join_kind) // " JOIN " // TRIM(target_tbl) // &
          " ON " // TRIM(on_expr)
    IF (LEN_TRIM(q%join_clause) == 0) THEN
      q%join_clause = seg
    ELSE
      q%join_clause = TRIM(q%join_clause) // " " // TRIM(seg)
    END IF
  END SUBROUTINE corm_f90_q_join

  !> @brief Appends a raw `WHERE` / `AND` predicate to `q`.
  !> @param[inout] q Query builder instance.
  !> @param[in] expr SQL boolean expression.
  SUBROUTINE corm_f90_q_where_raw(q, expr)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    CHARACTER(LEN=*), INTENT(IN) :: expr
    IF (q%where_count == 0) THEN
      q%where_clause = TRIM(expr)
    ELSE
      q%where_clause = TRIM(q%where_clause) // " AND " // TRIM(expr)
    END IF
    q%where_count = q%where_count + 1
  END SUBROUTINE corm_f90_q_where_raw

  !> @brief Appends an integer comparison predicate `<col> <op> <val>` to `q`.
  !> @param[inout] q Query builder instance.
  !> @param[in] col Column name.
  !> @param[in] op Comparison operator (`"="`, `">"`, `"<="`, etc.).
  !> @param[in] val Integer literal value.
  SUBROUTINE corm_f90_q_where_i32(q, col, op, val)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    CHARACTER(LEN=*), INTENT(IN) :: col, op
    INTEGER, INTENT(IN) :: val
    CHARACTER(LEN=24) :: num_buf
    INTEGER :: nlen
    CALL fmt_i32_f90(val, num_buf, nlen)
    CALL corm_f90_q_where_raw(q, TRIM(col) // " " // TRIM(op) // " " // &
                              num_buf(1:nlen))
  END SUBROUTINE corm_f90_q_where_i32

  !> @brief Appends a single-quoted string predicate `<col> <op> '<val>'` to `q`.
  !> @param[inout] q Query builder instance.
  !> @param[in] col Column name.
  !> @param[in] op Comparison operator (`"="`, `"LIKE"`, `"<>"`).
  !> @param[in] val Unquoted string value (embedded `'` doubled safely).
  SUBROUTINE corm_f90_q_where_str(q, col, op, val)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    CHARACTER(LEN=*), INTENT(IN) :: col, op, val
    CHARACTER(LEN=128) :: esc
    INTEGER :: k, pos, lv
    esc = " "
    pos = 0
    lv = LEN_TRIM(val)
    DO k = 1, lv
      IF (pos < 126) THEN
        pos = pos + 1
        esc(pos:pos) = val(k:k)
        IF (val(k:k) == "'") THEN
          pos = pos + 1
          esc(pos:pos) = "'"
        END IF
      END IF
    END DO
    IF (pos == 0) THEN
      CALL corm_f90_q_where_raw(q, TRIM(col) // " " // TRIM(op) // " ''")
    ELSE
      CALL corm_f90_q_where_raw(q, TRIM(col) // " " // TRIM(op) // &
                                " '" // esc(1:pos) // "'")
    END IF
  END SUBROUTINE corm_f90_q_where_str

  !> @brief Configures `GROUP BY` and optional `HAVING` clauses on `q`.
  !> @param[inout] q Query builder instance.
  !> @param[in] group_cols Comma-separated `GROUP BY` columns.
  !> @param[in] having_expr Optional `HAVING` predicate expression.
  SUBROUTINE corm_f90_q_group_by(q, group_cols, having_expr)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    CHARACTER(LEN=*), INTENT(IN) :: group_cols
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: having_expr
    q%group_clause = group_cols
    IF (PRESENT(having_expr)) q%having_clause = having_expr
  END SUBROUTINE corm_f90_q_group_by

  !> @brief Configures `ORDER BY` direction on fluent query builder `q`.
  !> @param[inout] q Query builder instance.
  !> @param[in] col Sort column expression.
  !> @param[in] descending `.TRUE.` for `DESC`, `.FALSE.` for `ASC`.
  SUBROUTINE corm_f90_q_order_by(q, col, descending)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    CHARACTER(LEN=*), INTENT(IN) :: col
    LOGICAL, INTENT(IN) :: descending
    IF (descending) THEN
      q%order_clause = TRIM(col) // " DESC"
    ELSE
      q%order_clause = TRIM(col) // " ASC"
    END IF
  END SUBROUTINE corm_f90_q_order_by

  !> @brief Configures `LIMIT` and `OFFSET` bounds on fluent query builder `q`.
  !> @param[inout] q Query builder instance.
  !> @param[in] limit_rows Maximum rows (`0` for unlimited).
  !> @param[in] offset_rows Initial skipped rows (`0` for none).
  SUBROUTINE corm_f90_q_limit_offset(q, limit_rows, offset_rows)
    TYPE(corm_query_f90_t), INTENT(INOUT) :: q
    INTEGER, INTENT(IN) :: limit_rows, offset_rows
    q%limit_rows = limit_rows
    q%offset_rows = offset_rows
  END SUBROUTINE corm_f90_q_limit_offset

  !> @brief Renders fluent query builder `q` into a complete SQL `SELECT` string.
  !> @param[in] q Query builder instance.
  !> @param[out] out_sql Destination SQL string buffer.
  !> @param[out] out_len Trimmed character length of `out_sql`.
  SUBROUTINE corm_f90_q_render(q, out_sql, out_len)
    TYPE(corm_query_f90_t), INTENT(IN) :: q
    CHARACTER(LEN=*), INTENT(OUT) :: out_sql
    INTEGER, INTENT(OUT) :: out_len
    CHARACTER(LEN=24) :: lbuf, obuf
    INTEGER :: llen, olen
    IF (q%is_distinct) THEN
      out_sql = "SELECT DISTINCT " // TRIM(q%select_cols) // &
                " FROM " // TRIM(q%table_name)
    ELSE
      out_sql = "SELECT " // TRIM(q%select_cols) // &
                " FROM " // TRIM(q%table_name)
    END IF
    IF (LEN_TRIM(q%join_clause) > 0) THEN
      out_sql = TRIM(out_sql) // " " // TRIM(q%join_clause)
    END IF
    IF (q%where_count > 0) THEN
      out_sql = TRIM(out_sql) // " WHERE " // TRIM(q%where_clause)
    END IF
    IF (LEN_TRIM(q%group_clause) > 0) THEN
      out_sql = TRIM(out_sql) // " GROUP BY " // TRIM(q%group_clause)
    END IF
    IF (LEN_TRIM(q%having_clause) > 0) THEN
      out_sql = TRIM(out_sql) // " HAVING " // TRIM(q%having_clause)
    END IF
    IF (LEN_TRIM(q%order_clause) > 0) THEN
      out_sql = TRIM(out_sql) // " ORDER BY " // TRIM(q%order_clause)
    END IF
    IF (q%limit_rows > 0) THEN
      CALL fmt_i32_f90(q%limit_rows, lbuf, llen)
      out_sql = TRIM(out_sql) // " LIMIT " // lbuf(1:llen)
    END IF
    IF (q%offset_rows > 0) THEN
      CALL fmt_i32_f90(q%offset_rows, obuf, olen)
      out_sql = TRIM(out_sql) // " OFFSET " // obuf(1:olen)
    END IF
    out_len = LEN_TRIM(out_sql)
  END SUBROUTINE corm_f90_q_render

  !> @brief Compiles fluent query `q` directly into prepared statement `stmt`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] q Query builder instance.
  !> @param[out] stmt Prepared statement handle ready to `corm_f90_step`.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_q_prepare(db, q, stmt, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    TYPE(corm_query_f90_t), INTENT(IN) :: q
    TYPE(corm_stmt_f90), INTENT(OUT) :: stmt
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    CHARACTER(LEN=512) :: sql_buf
    INTEGER :: slen, rc
    CALL corm_f90_q_render(q, sql_buf, slen)
    CALL corm_f90_prepare(db, sql_buf(1:MAX(slen, 1)), stmt, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_q_prepare

  !> @brief Initializes persistent Key-Value store `kv` on `db`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] table_name Key-value SQL table name.
  !> @param[out] kv Initialized KV store handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_kv_init(db, table_name, kv, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    TYPE(corm_kv_f90_t), INTENT(OUT) :: kv
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    CHARACTER(LEN=160) :: ddl
    INTEGER :: lt, rc
    kv%db = db
    kv%table_name = table_name
    lt = LEN_TRIM(table_name)
    IF (lt <= 0) THEN
      IF (PRESENT(ierr)) ierr = CORM_F90_ERR_VAL
      RETURN
    END IF
    ddl = "CREATE TABLE IF NOT EXISTS " // table_name(1:lt) // &
          "(k TEXT PRIMARY KEY, v TEXT)"
    CALL corm_f90_exec(db, ddl, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_kv_init

  !> @brief Upserts a `(key, val)` string pair into `kv`.
  !> @param[in] kv Key-value store handle.
  !> @param[in] key Key identifier.
  !> @param[in] val Value string.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_kv_put(kv, key, val, ierr)
    TYPE(corm_kv_f90_t), INTENT(IN) :: kv
    CHARACTER(LEN=*), INTENT(IN) :: key, val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    CHARACTER(LEN=160) :: sql
    INTEGER :: rc, f_rc
    sql = "INSERT OR REPLACE INTO " // TRIM(kv%table_name) // " VALUES(?,?)"
    CALL corm_f90_prepare(kv%db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_bind(stmt, 1, key, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_bind(stmt, 2, val, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, rc)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_kv_put

  !> @brief Retrieves a value by `key` from `kv`.
  !> @param[in] kv Key-value store handle.
  !> @param[in] key Key identifier.
  !> @param[out] out_val Destination value string.
  !> @param[out] out_len Trimmed value length (`0` if missing).
  !> @param[out] found Receives `.TRUE.` if key exists.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_kv_get(kv, key, out_val, out_len, found, ierr)
    TYPE(corm_kv_f90_t), INTENT(IN) :: kv
    CHARACTER(LEN=*), INTENT(IN) :: key
    CHARACTER(LEN=*), INTENT(OUT) :: out_val
    INTEGER, INTENT(OUT) :: out_len
    LOGICAL, INTENT(OUT) :: found
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    CHARACTER(LEN=160) :: sql
    INTEGER :: rc, f_rc
    out_val = " "
    out_len = 0
    found = .FALSE.
    sql = "SELECT v FROM " // TRIM(kv%table_name) // " WHERE k = ?"
    CALL corm_f90_prepare(kv%db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_bind(stmt, 1, key, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, found, rc)
    IF (rc == CORM_F90_OK .AND. found) THEN
      CALL corm_f90_col(stmt, 1, out_val, out_len, rc)
    END IF
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_kv_get

  !> @brief Deletes `key` from `kv`.
  !> @param[in] kv Key-value store handle.
  !> @param[in] key Key identifier to delete.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_kv_delete(kv, key, ierr)
    TYPE(corm_kv_f90_t), INTENT(IN) :: kv
    CHARACTER(LEN=*), INTENT(IN) :: key
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    CHARACTER(LEN=160) :: sql
    INTEGER :: rc, f_rc
    sql = "DELETE FROM " // TRIM(kv%table_name) // " WHERE k = ?"
    CALL corm_f90_prepare(kv%db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_bind(stmt, 1, key, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, rc)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_kv_delete

  !> @brief Initializes scientific time-series checkpoint ledger `ts` on `db`.
  !> @param[in] db Active Fortran 90 DB handle.
  !> @param[in] table_name Time-series SQL table name.
  !> @param[out] ts Initialized time-series handle.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ts_init(db, table_name, ts, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    TYPE(corm_ts_f90_t), INTENT(OUT) :: ts
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    CHARACTER(LEN=192) :: ddl
    INTEGER :: lt, rc
    ts%db = db
    ts%table_name = table_name
    lt = LEN_TRIM(table_name)
    IF (lt <= 0) THEN
      IF (PRESENT(ierr)) ierr = CORM_F90_ERR_VAL
      RETURN
    END IF
    ddl = "CREATE TABLE IF NOT EXISTS " // table_name(1:lt) // &
          "(step_no INT PRIMARY KEY, t_sim REAL, val REAL, tag TEXT)"
    CALL corm_f90_exec(db, ddl, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ts_init

  !> @brief Appends or replaces one simulation sample in `ts`.
  !> @param[in] ts Time-series handle.
  !> @param[in] step_no Discrete integration step index.
  !> @param[in] t_sim Simulation physical time.
  !> @param[in] val Observable value.
  !> @param[in] tag Regime or diagnostic tag.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ts_append(ts, step_no, t_sim, val, tag, ierr)
    TYPE(corm_ts_f90_t), INTENT(IN) :: ts
    INTEGER, INTENT(IN) :: step_no
    DOUBLE PRECISION, INTENT(IN) :: t_sim, val
    CHARACTER(LEN=*), INTENT(IN) :: tag
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    CHARACTER(LEN=160) :: sql
    INTEGER :: rc, f_rc
    sql = "INSERT OR REPLACE INTO " // TRIM(ts%table_name) // &
          " VALUES(?,?,?,?)"
    CALL corm_f90_prepare(ts%db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_bind(stmt, 1, step_no, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_bind(stmt, 2, t_sim, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_bind(stmt, 3, val, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_bind(stmt, 4, tag, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, rc)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ts_append

  !> @brief Queries the most recent checkpointed step in `ts`.
  !> @param[in] ts Time-series handle.
  !> @param[out] step_no Latest step index (`0` if empty).
  !> @param[out] t_sim Latest simulation time (`0.0D0` if empty).
  !> @param[out] val Latest observable value (`0.0D0` if empty).
  !> @param[out] found Receives `.TRUE.` if at least one sample exists.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ts_latest(ts, step_no, t_sim, val, found, ierr)
    TYPE(corm_ts_f90_t), INTENT(IN) :: ts
    INTEGER, INTENT(OUT) :: step_no
    DOUBLE PRECISION, INTENT(OUT) :: t_sim, val
    LOGICAL, INTENT(OUT) :: found
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    CHARACTER(LEN=192) :: sql
    INTEGER :: rc, f_rc
    step_no = 0
    t_sim = 0.0D0
    val = 0.0D0
    found = .FALSE.
    sql = "SELECT step_no, t_sim, val FROM " // TRIM(ts%table_name) // &
          " ORDER BY step_no DESC LIMIT 1"
    CALL corm_f90_prepare(ts%db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_step(stmt, found, rc)
    IF (rc == CORM_F90_OK .AND. found) THEN
      CALL corm_f90_col(stmt, 1, step_no, rc)
      IF (rc == CORM_F90_OK) CALL corm_f90_col(stmt, 2, t_sim, rc)
      IF (rc == CORM_F90_OK) CALL corm_f90_col(stmt, 3, val, rc)
    END IF
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ts_latest

  !> @brief Queries peak `MAX(val)` across all samples in `ts`.
  !> @param[in] ts Time-series handle.
  !> @param[out] max_val Peak observable value (`0.0D0` if empty).
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ts_max_val(ts, max_val, ierr)
    TYPE(corm_ts_f90_t), INTENT(IN) :: ts
    DOUBLE PRECISION, INTENT(OUT) :: max_val
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    CHARACTER(LEN=160) :: sql
    INTEGER :: rc
    sql = "SELECT MAX(val) FROM " // TRIM(ts%table_name)
    CALL corm_f90_scalar_f64(ts%db, sql, 0.0D0, max_val, rc)
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ts_max_val

  !> @brief Prunes speculative time-series samples strictly after `keep_step`.
  !> @param[in] ts Time-series handle.
  !> @param[in] keep_step Highest step number to retain.
  !> @param[out] ierr Optional status code.
  SUBROUTINE corm_f90_ts_prune_after(ts, keep_step, ierr)
    TYPE(corm_ts_f90_t), INTENT(IN) :: ts
    INTEGER, INTENT(IN) :: keep_step
    INTEGER, INTENT(OUT), OPTIONAL :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    CHARACTER(LEN=160) :: sql
    INTEGER :: rc, f_rc
    sql = "DELETE FROM " // TRIM(ts%table_name) // " WHERE step_no > ?"
    CALL corm_f90_prepare(ts%db, sql, stmt, rc)
    IF (rc /= CORM_F90_OK) THEN
      IF (PRESENT(ierr)) ierr = rc
      RETURN
    END IF
    CALL corm_f90_bind(stmt, 1, keep_step, rc)
    IF (rc == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, rc)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (rc == CORM_F90_OK) rc = f_rc
    IF (PRESENT(ierr)) ierr = rc
  END SUBROUTINE corm_f90_ts_prune_after

END MODULE fortran_orm_f90_orm
