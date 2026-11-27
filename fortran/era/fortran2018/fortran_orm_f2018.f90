!> @file fortran_orm_f2018.f90
!> @module fortran_orm_f2018
!> @brief ISO/IEC 1539-1:2018 Fortran 2018 Enhanced C Interoperability
!> (`CFI_cdesc_t` / TS 29113) ORM module.
!>
!> Uses Fortran 2018 `IMPLICIT NONE (TYPE, EXTERNAL)`, direct `CHARACTER(LEN=*)`
!> `BIND(C)` descriptor arguments (zero `C_NULL_CHAR` copies), and assumed-rank
!> `TYPE(*), DIMENSION(..)` `BIND(C)` interfaces supporting arbitrary strided
!> non-contiguous Fortran array slices such as `A(1:10:2, :)`!
MODULE fortran_orm_f2018
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_PTR, C_INT, C_INT32_T, C_CHAR
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE fortran_orm_f2003, ONLY : orm_db_t, orm_stmt_t, FORTRAN_ORM_OK
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE

  PUBLIC :: FORTRAN_ORM_OK, orm_db_t, orm_stmt_t
  PUBLIC :: fortran_orm_cfi_connect, fortran_orm_cfi_exec
  PUBLIC :: fortran_orm_cfi_col_str
  PUBLIC :: fortran_orm_cfi_insert_numeric, fortran_orm_cfi_query_numeric
  PUBLIC :: corm_f2018_open, corm_f2018_exec
  PUBLIC :: corm_f2018_insert_any_rank, corm_f2018_query_any_rank

  INTERFACE
    !> @brief Direct Fortran 2018 CHARACTER(LEN=*) CFI descriptor connect.
    !> @param[in] url_desc Native Fortran string passed via CFI_cdesc_t.
    !> @param[out] out_db Allocated database C_PTR handle.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_connect(url_desc, out_db) &
        BIND(C, NAME="fortran_orm_cfi_connect") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: url_desc
      TYPE(C_PTR), INTENT(OUT) :: out_db
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_connect

    !> @brief Direct Fortran 2018 CHARACTER(LEN=*) CFI descriptor SQL exec.
    !> @param[in] db Active database C_PTR handle.
    !> @param[in] sql_desc Native Fortran SQL string passed via CFI_cdesc_t.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_exec(db, sql_desc) &
        BIND(C, NAME="fortran_orm_cfi_exec") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: db
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: sql_desc
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_exec

    !> @brief Direct Fortran 2018 CHARACTER(LEN=*) CFI descriptor column reader.
    !> @param[in] stmt Active prepared statement C_PTR handle.
    !> @param[in] col_idx 1-based column index.
    !> @param[out] out_desc Destination CHARACTER(LEN=*) CFI descriptor.
    !> @param[out] out_len Trimmed string length.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_col_str(stmt, col_idx, out_desc, out_len) &
        BIND(C, NAME="fortran_orm_cfi_col_str") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_INT32_T, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(OUT) :: out_desc
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_col_str

    !> @brief Direct Fortran 2018 assumed-rank & assumed-type numeric insert
    !> supporting rank-1 vectors and rank-2 strided matrix slices!
    !> @param[in] db Active database C_PTR handle.
    !> @param[in] sql_desc Parameterized INSERT SQL string descriptor.
    !> @param[in] arr_desc Assumed-rank `DIMENSION(..)` array or slice.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_insert_numeric(db, sql_desc, arr_desc) &
        BIND(C, NAME="fortran_orm_cfi_insert_numeric") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: db
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: sql_desc
      TYPE(*), DIMENSION(..), INTENT(IN) :: arr_desc
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_insert_numeric

    !> @brief Direct Fortran 2018 assumed-rank & assumed-type numeric query
    !> hydrating rank-1 vectors or rank-2 strided matrix slices!
    !> @param[in] db Active database C_PTR handle.
    !> @param[in] sql_desc SELECT SQL string descriptor.
    !> @param[inout] out_arr_desc Assumed-rank destination array or slice.
    !> @param[out] out_rows Number of rows hydrated.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_query_numeric(db, sql_desc, out_arr_desc, &
                                           out_rows) &
        BIND(C, NAME="fortran_orm_cfi_query_numeric") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_INT32_T, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: db
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: sql_desc
      TYPE(*), DIMENSION(..), INTENT(INOUT) :: out_arr_desc
      INTEGER(C_INT32_T), INTENT(OUT) :: out_rows
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_query_numeric
  END INTERFACE

CONTAINS

  !> @brief Opens `db` directly via Fortran 2018 CFI `CHARACTER(LEN=*)`.
  !> @param[inout] db Database RAII object.
  !> @param[in] url Connection URL string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_open(db, url) RESULT(rc)
    CLASS(orm_db_t), INTENT(INOUT) :: db
    CHARACTER(LEN=*), INTENT(IN) :: url
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    prev_rc = db%close()
    rc = fortran_orm_cfi_connect(url, db%ptr)
  END FUNCTION corm_f2018_open

  !> @brief Executes SQL directly via Fortran 2018 CFI `CHARACTER(LEN=*)`.
  !> @param[in] db Active database RAII object.
  !> @param[in] sql SQL text.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_exec(db, sql) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT) :: rc
    rc = fortran_orm_cfi_exec(db%ptr, sql)
  END FUNCTION corm_f2018_exec

  !> @brief Inserts any rank-1 or rank-2 INT32/REAL64 array or strided slice.
  !> @param[in] db Active database RAII object.
  !> @param[in] sql Parameterized INSERT SQL.
  !> @param[in] arr Assumed-rank INT32 or REAL64 array/slice.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_insert_any_rank(db, sql, arr) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    TYPE(*), DIMENSION(..), INTENT(IN) :: arr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_cfi_insert_numeric(db%ptr, sql, arr)
  END FUNCTION corm_f2018_insert_any_rank

  !> @brief Hydrates any rank-1 or rank-2 INT32/REAL64 array or strided slice.
  !> @param[in] db Active database RAII object.
  !> @param[in] sql SELECT SQL query.
  !> @param[inout] arr Assumed-rank destination INT32 or REAL64 array/slice.
  !> @param[out] out_rows Number of hydrated rows.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_query_any_rank(db, sql, arr, out_rows) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    TYPE(*), DIMENSION(..), INTENT(INOUT) :: arr
    INTEGER(INT32), INTENT(OUT) :: out_rows
    INTEGER(C_INT) :: rc
    rc = fortran_orm_cfi_query_numeric(db%ptr, sql, arr, out_rows)
  END FUNCTION corm_f2018_query_any_rank

END MODULE fortran_orm_f2018
