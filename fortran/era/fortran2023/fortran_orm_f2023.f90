!> @file fortran_orm_f2023.f90
!> @module fortran_orm_f2023
!> @brief ISO/IEC 1539-1:2023 Fortran 2023 ORM module.
!>
!> Showcases authentic Fortran 2023 `ISO_C_BINDING` enhancements (`F_C_STRING`
!> intrinsic with `ASIS` blank-preservation control) alongside assumed-rank
!> scientific persistence, exact 38-digit decimal arithmetic, and RAII handles.
MODULE fortran_orm_f2023
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT, C_INT32_T, F_C_STRING
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, INT64, REAL64
  USE fortran_orm_c, ONLY : fortran_orm_connect_cstr, fortran_orm_exec_cstr, &
                            fortran_orm_decimal, fortran_orm_dec_from_str, &
                            fortran_orm_dec_add, fortran_orm_dec_to_str
  USE fortran_orm_f2003, ONLY : orm_db_t, orm_stmt_t, orm_ast_t, orm_rs_t, &
                                orm_pool_t, orm_schema_t, FORTRAN_ORM_OK, &
                                corm_f2003_uuid_v4, corm_f2003_version
  USE fortran_orm_f2018, ONLY : corm_f2018_insert_any_rank, &
                                corm_f2018_query_any_rank
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE

  PUBLIC :: INT32, INT64, REAL64, FORTRAN_ORM_OK
  PUBLIC :: orm_db_t, orm_stmt_t, orm_ast_t, orm_rs_t, orm_pool_t, orm_schema_t
  PUBLIC :: fortran_orm_decimal
  PUBLIC :: corm_f2023_open, corm_f2023_exec
  PUBLIC :: corm_f2023_dec_add_str
  PUBLIC :: corm_f2018_insert_any_rank, corm_f2018_query_any_rank
  PUBLIC :: corm_f2003_uuid_v4, corm_f2003_version

CONTAINS

  !> @brief Connects `db` using the Fortran 2023 `F_C_STRING` intrinsic.
  !> @param[inout] db RAII database connection object.
  !> @param[in] url Connection URL string.
  !> @param[in] asis Optional flag preserving trailing blanks when .TRUE.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_open(db, url, asis) RESULT(rc)
    CLASS(orm_db_t), INTENT(INOUT) :: db
    CHARACTER(LEN=*), INTENT(IN) :: url
    LOGICAL, INTENT(IN), OPTIONAL :: asis
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    LOGICAL :: keep_blanks
    keep_blanks = .FALSE.
    IF (PRESENT(asis)) keep_blanks = asis
    prev_rc = db%close()
    rc = fortran_orm_connect_cstr(F_C_STRING(url, ASIS=keep_blanks), db%ptr)
  END FUNCTION corm_f2023_open

  !> @brief Executes SQL on `db` using Fortran 2023 `F_C_STRING`.
  !> @param[in] db Active RAII database connection object.
  !> @param[in] sql SQL DDL or DML text.
  !> @param[in] asis Optional flag preserving trailing blanks when .TRUE.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_exec(db, sql, asis) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    LOGICAL, INTENT(IN), OPTIONAL :: asis
    INTEGER(C_INT) :: rc
    LOGICAL :: keep_blanks
    keep_blanks = .FALSE.
    IF (PRESENT(asis)) keep_blanks = asis
    rc = fortran_orm_exec_cstr(db%ptr, F_C_STRING(sql, ASIS=keep_blanks))
  END FUNCTION corm_f2023_exec

  !> @brief Exact 38-digit base-10 decimal addition helper returning an
  !> allocatable canonical string.
  !> @param[in] lhs_str Left base-10 decimal string.
  !> @param[in] rhs_str Right base-10 decimal string.
  !> @param[out] sum_str Allocatable canonical decimal sum string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_dec_add_str(lhs_str, rhs_str, sum_str) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: lhs_str, rhs_str
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: sum_str
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_decimal) :: da, db, ds
    CHARACTER(LEN=64) :: buf
    INTEGER(C_INT32_T) :: out_n
    rc = fortran_orm_dec_from_str(lhs_str, INT(LEN(lhs_str), C_INT32_T), da)
    IF (rc /= FORTRAN_ORM_OK) THEN
      sum_str = ""
      RETURN
    END IF
    rc = fortran_orm_dec_from_str(rhs_str, INT(LEN(rhs_str), C_INT32_T), db)
    IF (rc /= FORTRAN_ORM_OK) THEN
      sum_str = ""
      RETURN
    END IF
    rc = fortran_orm_dec_add(da, db, ds)
    IF (rc /= FORTRAN_ORM_OK) THEN
      sum_str = ""
      RETURN
    END IF
    out_n = 0_C_INT32_T
    rc = fortran_orm_dec_to_str(ds, buf, 64_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      sum_str = buf(1:out_n)
    ELSE
      sum_str = ""
    END IF
  END FUNCTION corm_f2023_dec_add_str

END MODULE fortran_orm_f2023
