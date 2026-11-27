!> @file fortran_orm_f2008.f90
!> @module fortran_orm_f2008
!> @brief ISO/IEC 1539-1:2010 Fortran 2008 SUBMODULE-separated ORM interface.
!>
!> Showcases authentic Fortran 2008 innovations: `SUBMODULE` interface/body
!> separation, `ISO_FORTRAN_ENV` (`INT32`, `INT64`, `REAL64`), `CONTIGUOUS`
!> zero-copy 1D vector and 2D column-major matrix persistence via direct array
!> `C_LOC`, `BLOCK` constructs, and `C_SIZEOF`.
MODULE fortran_orm_f2008
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, INT64, REAL64
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT
  USE fortran_orm_f2003, ONLY : orm_db_t, FORTRAN_ORM_OK
  IMPLICIT NONE
  PRIVATE

  PUBLIC :: INT32, INT64, REAL64, FORTRAN_ORM_OK, orm_db_t
  PUBLIC :: corm_f2008_insert_vec_f64, corm_f2008_query_vec_f64
  PUBLIC :: corm_f2008_insert_matrix_f64, corm_f2008_query_matrix_f64

  INTERFACE
    !> @brief Zero-copy batch insert of a CONTIGUOUS 1D REAL64 vector.
    !> @param[in] db Active Fortran 2003/2008 database object.
    !> @param[in] sql Single-parameter INSERT SQL.
    !> @param[in] vec Contiguous 1D REAL64 array.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_insert_vec_f64(db, sql, vec) RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      REAL(REAL64), DIMENSION(:), CONTIGUOUS, TARGET, INTENT(IN) :: vec
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_insert_vec_f64

    !> @brief Zero-copy hydration of a CONTIGUOUS 1D REAL64 vector.
    !> @param[in] db Active database object.
    !> @param[in] sql SELECT SQL query.
    !> @param[out] vec Contiguous destination 1D REAL64 array.
    !> @param[out] out_count Number of hydrated elements.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_query_vec_f64(db, sql, vec, out_count) &
        RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      REAL(REAL64), DIMENSION(:), CONTIGUOUS, TARGET, INTENT(OUT) :: vec
      INTEGER(INT32), INTENT(OUT) :: out_count
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_query_vec_f64

    !> @brief Zero-copy batch insert of a CONTIGUOUS 2D column-major matrix.
    !> @param[in] db Active database object.
    !> @param[in] sql Multi-parameter INSERT SQL.
    !> @param[in] mat Contiguous 2D REAL64 matrix (no transpose copy).
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_insert_matrix_f64(db, sql, mat) RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, TARGET, INTENT(IN) :: mat
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_insert_matrix_f64

    !> @brief Zero-copy hydration into a CONTIGUOUS 2D column-major matrix.
    !> @param[in] db Active database object.
    !> @param[in] sql Multi-column SELECT SQL query.
    !> @param[out] mat Contiguous destination 2D REAL64 matrix.
    !> @param[out] out_rows Number of hydrated rows.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_query_matrix_f64(db, sql, mat, out_rows) &
        RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, TARGET, INTENT(OUT) :: mat
      INTEGER(INT32), INTENT(OUT) :: out_rows
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_query_matrix_f64
  END INTERFACE

END MODULE fortran_orm_f2008
