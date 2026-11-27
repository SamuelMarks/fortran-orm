!> @file fortran_orm_f2008_sub.f90
!> @module fortran_orm_f2008_impl
!> @brief ISO Fortran 2008 SUBMODULE implementation for `fortran_orm_f2008`.
SUBMODULE (fortran_orm_f2008) fortran_orm_f2008_impl
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_LOC, C_SIZEOF, C_INT32_T, &
                                          C_SIZE_T, C_NULL_PTR
  USE fortran_orm_c, ONLY : fortran_orm_insert_vec_f64, &
                            fortran_orm_query_vec_f64, &
                            fortran_orm_insert_matrix_f64, &
                            fortran_orm_query_matrix_f64
  IMPLICIT NONE

CONTAINS

  !> @brief Implements zero-copy 1D REAL64 vector batch insert.
  !> @param[in] db Active database object.
  !> @param[in] sql Single-parameter INSERT SQL.
  !> @param[in] vec Contiguous 1D REAL64 array.
  !> @return Unified `fortran_orm_error_t` status code.
  MODULE PROCEDURE corm_f2008_insert_vec_f64
    BLOCK
      INTEGER(C_INT32_T) :: n_elems
      INTEGER(C_SIZE_T) :: byte_check
      n_elems = INT(SIZE(vec, 1), C_INT32_T)
      byte_check = C_SIZEOF(vec)
      IF (n_elems <= 0_C_INT32_T .OR. byte_check == 0_C_SIZE_T) THEN
        rc = fortran_orm_insert_vec_f64(db%ptr, sql, &
                                        INT(LEN(sql), C_INT32_T), &
                                        C_NULL_PTR, 0_C_INT32_T)
      ELSE
        rc = fortran_orm_insert_vec_f64(db%ptr, sql, &
                                        INT(LEN(sql), C_INT32_T), &
                                        C_LOC(vec), n_elems)
      END IF
    END BLOCK
  END PROCEDURE corm_f2008_insert_vec_f64

  !> @brief Implements zero-copy 1D REAL64 vector query hydration.
  !> @param[in] db Active database object.
  !> @param[in] sql SELECT SQL query.
  !> @param[out] vec Contiguous destination 1D REAL64 array.
  !> @param[out] out_count Number of hydrated elements.
  !> @return Unified `fortran_orm_error_t` status code.
  MODULE PROCEDURE corm_f2008_query_vec_f64
    BLOCK
      INTEGER(C_INT32_T) :: cap_elems
      cap_elems = INT(SIZE(vec, 1), C_INT32_T)
      vec = 0.0_REAL64
      rc = fortran_orm_query_vec_f64(db%ptr, sql, INT(LEN(sql), C_INT32_T), &
                                     C_LOC(vec), cap_elems, out_count)
    END BLOCK
  END PROCEDURE corm_f2008_query_vec_f64

  !> @brief Implements zero-copy 2D column-major REAL64 matrix insert.
  !> @param[in] db Active database object.
  !> @param[in] sql Multi-parameter INSERT SQL.
  !> @param[in] mat Contiguous 2D REAL64 matrix.
  !> @return Unified `fortran_orm_error_t` status code.
  MODULE PROCEDURE corm_f2008_insert_matrix_f64
    BLOCK
      INTEGER(C_INT32_T) :: nr, nc
      nr = INT(SIZE(mat, 1), C_INT32_T)
      nc = INT(SIZE(mat, 2), C_INT32_T)
      rc = fortran_orm_insert_matrix_f64(db%ptr, sql, &
                                         INT(LEN(sql), C_INT32_T), &
                                         C_LOC(mat), MAX(nr, 1_C_INT32_T), &
                                         nr, nc)
    END BLOCK
  END PROCEDURE corm_f2008_insert_matrix_f64

  !> @brief Implements zero-copy 2D column-major REAL64 matrix query.
  !> @param[in] db Active database object.
  !> @param[in] sql Multi-column SELECT SQL.
  !> @param[out] mat Contiguous destination 2D REAL64 matrix.
  !> @param[out] out_rows Number of hydrated rows.
  !> @return Unified `fortran_orm_error_t` status code.
  MODULE PROCEDURE corm_f2008_query_matrix_f64
    BLOCK
      INTEGER(C_INT32_T) :: nr, nc
      nr = INT(SIZE(mat, 1), C_INT32_T)
      nc = INT(SIZE(mat, 2), C_INT32_T)
      mat = 0.0_REAL64
      rc = fortran_orm_query_matrix_f64(db%ptr, sql, &
                                        INT(LEN(sql), C_INT32_T), &
                                        C_LOC(mat), MAX(nr, 1_C_INT32_T), &
                                        nr, nc, out_rows)
    END BLOCK
  END PROCEDURE corm_f2008_query_matrix_f64

END SUBMODULE fortran_orm_f2008_impl
