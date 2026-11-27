!> @file fortran_orm_f2008_sub.f90
!> @module fortran_orm_f2008_impl
!> @brief ISO Fortran 2008 SUBMODULE implementing CONTIGUOUS zero-copy
!> `INT32`/`INT64`/`REAL64` vectors and padded 2D submatrices.
SUBMODULE (fortran_orm_f2008) fortran_orm_f2008_impl
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_LOC, C_SIZEOF, C_INT32_T, &
                                          C_SIZE_T, C_NULL_PTR
  USE fortran_orm_c, ONLY : fortran_orm_insert_vec_i32, &
                            fortran_orm_query_vec_i32, &
                            fortran_orm_insert_vec_i64, &
                            fortran_orm_query_vec_i64, &
                            fortran_orm_insert_vec_f64, &
                            fortran_orm_query_vec_f64, &
                            fortran_orm_insert_matrix_f64, &
                            fortran_orm_query_matrix_f64
  IMPLICIT NONE

CONTAINS

  !> @brief Implements zero-copy 1D INT32 vector batch insert.
  MODULE PROCEDURE corm_f2008_insert_vec_i32
    BLOCK
      INTEGER(C_INT32_T) :: n_elems
      n_elems = INT(SIZE(vec, 1), C_INT32_T)
      IF (n_elems <= 0_C_INT32_T) THEN
        rc = fortran_orm_insert_vec_i32(db%ptr, sql, &
                                        INT(LEN(sql), C_INT32_T), &
                                        C_NULL_PTR, 0_C_INT32_T)
      ELSE
        rc = fortran_orm_insert_vec_i32(db%ptr, sql, &
                                        INT(LEN(sql), C_INT32_T), &
                                        C_LOC(vec), n_elems)
      END IF
    END BLOCK
  END PROCEDURE corm_f2008_insert_vec_i32

  !> @brief Implements zero-copy 1D INT32 vector query hydration.
  MODULE PROCEDURE corm_f2008_query_vec_i32
    BLOCK
      INTEGER(C_INT32_T) :: cap_elems
      cap_elems = INT(SIZE(vec, 1), C_INT32_T)
      vec = 0_INT32
      rc = fortran_orm_query_vec_i32(db%ptr, sql, INT(LEN(sql), C_INT32_T), &
                                     C_LOC(vec), cap_elems, out_count)
    END BLOCK
  END PROCEDURE corm_f2008_query_vec_i32

  !> @brief Implements zero-copy 1D INT64 vector batch insert.
  MODULE PROCEDURE corm_f2008_insert_vec_i64
    BLOCK
      INTEGER(C_INT32_T) :: n_elems
      n_elems = INT(SIZE(vec, 1), C_INT32_T)
      IF (n_elems <= 0_C_INT32_T) THEN
        rc = fortran_orm_insert_vec_i64(db%ptr, sql, &
                                        INT(LEN(sql), C_INT32_T), &
                                        C_NULL_PTR, 0_C_INT32_T)
      ELSE
        rc = fortran_orm_insert_vec_i64(db%ptr, sql, &
                                        INT(LEN(sql), C_INT32_T), &
                                        C_LOC(vec), n_elems)
      END IF
    END BLOCK
  END PROCEDURE corm_f2008_insert_vec_i64

  !> @brief Implements zero-copy 1D INT64 vector query hydration.
  MODULE PROCEDURE corm_f2008_query_vec_i64
    BLOCK
      INTEGER(C_INT32_T) :: cap_elems
      cap_elems = INT(SIZE(vec, 1), C_INT32_T)
      vec = 0_INT64
      rc = fortran_orm_query_vec_i64(db%ptr, sql, INT(LEN(sql), C_INT32_T), &
                                     C_LOC(vec), cap_elems, out_count)
    END BLOCK
  END PROCEDURE corm_f2008_query_vec_i64

  !> @brief Implements zero-copy 1D REAL64 vector batch insert.
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

  !> @brief Implements zero-copy leading-dimension padded submatrix insert.
  MODULE PROCEDURE corm_f2008_insert_submatrix_f64
    BLOCK
      INTEGER(C_INT32_T) :: ld_r, tot_c
      ld_r = INT(SIZE(mat, 1), C_INT32_T)
      tot_c = INT(SIZE(mat, 2), C_INT32_T)
      IF (n_rows < 0_INT32 .OR. n_rows > ld_r .OR. &
          n_cols < 1_INT32 .OR. n_cols > tot_c) THEN
        rc = FORTRAN_ORM_ERROR_VALIDATION
      ELSE
        rc = fortran_orm_insert_matrix_f64(db%ptr, sql, &
                                           INT(LEN(sql), C_INT32_T), &
                                           C_LOC(mat), MAX(ld_r, 1_C_INT32_T), &
                                           n_rows, n_cols)
      END IF
    END BLOCK
  END PROCEDURE corm_f2008_insert_submatrix_f64

  !> @brief Implements zero-copy leading-dimension padded submatrix query.
  MODULE PROCEDURE corm_f2008_query_submatrix_f64
    BLOCK
      INTEGER(C_INT32_T) :: ld_r, tot_c
      out_rows = 0_INT32
      ld_r = INT(SIZE(mat, 1), C_INT32_T)
      tot_c = INT(SIZE(mat, 2), C_INT32_T)
      IF (max_rows < 0_INT32 .OR. max_rows > ld_r .OR. &
          n_cols < 1_INT32 .OR. n_cols > tot_c) THEN
        rc = FORTRAN_ORM_ERROR_VALIDATION
      ELSE
        rc = fortran_orm_query_matrix_f64(db%ptr, sql, &
                                          INT(LEN(sql), C_INT32_T), &
                                          C_LOC(mat), MAX(ld_r, 1_C_INT32_T), &
                                          max_rows, n_cols, out_rows)
      END IF
    END BLOCK
  END PROCEDURE corm_f2008_query_submatrix_f64

END SUBMODULE fortran_orm_f2008_impl
