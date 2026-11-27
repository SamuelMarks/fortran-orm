!> @file fortran_orm_f95.f95
!> @module fortran_orm_f95
!> @brief Strict ISO/IEC 1539-1:1997 Fortran 95 ORM module.
!>
!> Showcases authentic Fortran 95 capabilities under `-std=f95`: default
!> derived-type component initialization (`slot = 0`), `PURE` and `ELEMENTAL`
!> status/handle predicates, and `FORALL` array-parallel scientific matrix
!> transformations persisted directly via `c-orm`.
MODULE fortran_orm_f95
  IMPLICIT NONE
  PRIVATE

  INTEGER, PARAMETER, PUBLIC :: CORM_F95_OK = 0

  !> @type corm_db_f95
  !> @brief Fortran 95 database handle with default component initialization.
  TYPE, PUBLIC :: corm_db_f95
    INTEGER :: slot = 0
  END TYPE corm_db_f95

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

    !> @brief Low-level C89 SQL execution bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] idb DB slot.
    !> @param[in] sql SQL text.
    !> @param[out] iout Output integer.
    !> @param[out] ierr Error code.
    SUBROUTINE cf77ex(imode, idb, sql, iout, ierr)
      INTEGER, INTENT(IN) :: imode
      INTEGER, INTENT(IN) :: idb
      CHARACTER(LEN=*), INTENT(IN) :: sql
      INTEGER, INTENT(OUT) :: iout
      INTEGER, INTENT(OUT) :: ierr
    END SUBROUTINE cf77ex

    !> @brief Low-level C89 2D matrix bridge.
    !> @param[in] imode Mode selector.
    !> @param[in] ihnd DB slot.
    !> @param[inout] sql SQL text.
    !> @param[inout] dmat Column-major matrix.
    !> @param[in] ldrows Leading dimension.
    !> @param[in] nrows Row count.
    !> @param[in] ncols Column count.
    !> @param[out] nout Output count.
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

  PUBLIC :: corm_f95_is_ok, corm_f95_db_is_open
  PUBLIC :: corm_f95_open, corm_f95_close, corm_f95_exec
  PUBLIC :: corm_f95_insert_scaled_matrix, corm_f95_query_matrix

CONTAINS

  !> @brief Elemental Fortran 95 predicate checking scalar or array statuses.
  !> @param[in] rc Integer status code(s).
  !> @return .TRUE. where rc == CORM_F95_OK.
  ELEMENTAL FUNCTION corm_f95_is_ok(rc) RESULT(ok)
    INTEGER, INTENT(IN) :: rc
    LOGICAL :: ok
    ok = (rc == CORM_F95_OK)
  END FUNCTION corm_f95_is_ok

  !> @brief Pure Fortran 95 predicate testing whether a DB handle is open.
  !> @param[in] db Fortran 95 database handle.
  !> @return .TRUE. when db%slot > 0.
  PURE FUNCTION corm_f95_db_is_open(db) RESULT(is_open)
    TYPE(corm_db_f95), INTENT(IN) :: db
    LOGICAL :: is_open
    is_open = (db%slot > 0)
  END FUNCTION corm_f95_db_is_open

  !> @brief Opens a database connection.
  !> @param[in] url Connection URL.
  !> @param[out] db Database handle.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_open(url, db, ierr)
    CHARACTER(LEN=*), INTENT(IN) :: url
    TYPE(corm_db_f95), INTENT(OUT) :: db
    INTEGER, INTENT(OUT) :: ierr
    CALL cf77op(url, db%slot, ierr)
  END SUBROUTINE corm_f95_open

  !> @brief Closes a database connection.
  !> @param[inout] db Database handle (reset to default slot = 0).
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_close(db, ierr)
    TYPE(corm_db_f95), INTENT(INOUT) :: db
    INTEGER, INTENT(OUT) :: ierr
    CALL cf77cl(1, db%slot, ierr)
  END SUBROUTINE corm_f95_close

  !> @brief Executes DDL or DML SQL.
  !> @param[in] db Active database handle.
  !> @param[in] sql SQL text.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_exec(db, sql, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER, INTENT(OUT) :: ierr
    INTEGER :: dummy_out
    dummy_out = 0
    CALL cf77ex(1, db%slot, sql, dummy_out, ierr)
  END SUBROUTINE corm_f95_exec

  !> @brief Scales a 2D matrix using a Fortran 95 FORALL construct and
  !> batch-inserts it into the database.
  !> @param[in] db Active database handle.
  !> @param[in] sql Parameterized INSERT SQL.
  !> @param[in] mat Source 2D DOUBLE PRECISION matrix.
  !> @param[in] scale Multiplicative scale factor.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_insert_scaled_matrix(db, sql, mat, scale, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(IN) :: mat
    DOUBLE PRECISION, INTENT(IN) :: scale
    INTEGER, INTENT(OUT) :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: scaled
    CHARACTER(LEN=LEN(sql)) :: scopy
    INTEGER :: nr, nc, i, j, nout
    nr = SIZE(mat, 1)
    nc = SIZE(mat, 2)
    ALLOCATE(scaled(MAX(nr, 1), MAX(nc, 1)))
    scaled = 0.0D0
    FORALL (i = 1:nr, j = 1:nc)
      scaled(i, j) = mat(i, j) * scale
    END FORALL
    scopy = sql
    CALL cf77mx(1, db%slot, scopy, scaled, MAX(nr, 1), nr, nc, nout, ierr)
    DEALLOCATE(scaled)
  END SUBROUTINE corm_f95_insert_scaled_matrix

  !> @brief Hydrates a SQL SELECT into a 2D DOUBLE PRECISION matrix.
  !> @param[in] db Active database handle.
  !> @param[in] sql SELECT SQL query.
  !> @param[out] mat Destination 2D matrix.
  !> @param[out] out_rows Number of hydrated rows.
  !> @param[out] ierr Status code.
  SUBROUTINE corm_f95_query_matrix(db, sql, mat, out_rows, ierr)
    TYPE(corm_db_f95), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(OUT) :: mat
    INTEGER, INTENT(OUT) :: out_rows
    INTEGER, INTENT(OUT) :: ierr
    DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: buf
    CHARACTER(LEN=LEN(sql)) :: scopy
    INTEGER :: nr, nc, i, j
    nr = SIZE(mat, 1)
    nc = SIZE(mat, 2)
    ALLOCATE(buf(MAX(nr, 1), MAX(nc, 1)))
    buf = 0.0D0
    scopy = sql
    CALL cf77mx(2, db%slot, scopy, buf, MAX(nr, 1), nr, nc, out_rows, ierr)
    IF (ierr == CORM_F95_OK .AND. out_rows > 0) THEN
      FORALL (i = 1:out_rows, j = 1:nc)
        mat(i, j) = buf(i, j)
      END FORALL
    END IF
    DEALLOCATE(buf)
  END SUBROUTINE corm_f95_query_matrix

END MODULE fortran_orm_f95
