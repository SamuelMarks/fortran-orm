!> @file fortran_orm_f2008.f90
!> @module fortran_orm_f2008
!> @brief ISO/IEC 1539-1:2010 Fortran 2008 SUBMODULE-separated ORM interface.
!>
!> Showcases authentic Fortran 2008 innovations: hierarchical `SUBMODULE`
!> interface/body separation (`fortran_orm_f2008_impl` and
!> `fortran_orm_f2008_ckpt`), `ISO_FORTRAN_ENV` (`INT32`, `INT64`, `REAL64`),
!> `CONTIGUOUS` zero-copy `INT32`/`INT64`/`REAL64` 1D vectors and padded 2D
!> column-major submatrices via direct array `C_LOC`, `DO CONCURRENT` column
!> standardization, `BLOCK` constructs, `C_SIZEOF`, and versioned simulation
!> checkpoint management (`orm_checkpoint_f2008_t`).
MODULE fortran_orm_f2008
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, INT64, REAL64
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT
  USE fortran_orm_f2003, ONLY : orm_db_t, orm_stmt_t, FORTRAN_ORM_OK, &
                                FORTRAN_ORM_ERROR_VALIDATION, &
                                FORTRAN_ORM_ERROR_NOT_FOUND
  IMPLICIT NONE
  PRIVATE

  PUBLIC :: INT32, INT64, REAL64, FORTRAN_ORM_OK
  PUBLIC :: FORTRAN_ORM_ERROR_VALIDATION, FORTRAN_ORM_ERROR_NOT_FOUND
  PUBLIC :: orm_db_t, orm_stmt_t
  PUBLIC :: corm_f2008_insert_vec_i32, corm_f2008_query_vec_i32
  PUBLIC :: corm_f2008_insert_vec_i64, corm_f2008_query_vec_i64
  PUBLIC :: corm_f2008_insert_vec_f64, corm_f2008_query_vec_f64
  PUBLIC :: corm_f2008_insert_vec, corm_f2008_query_vec
  PUBLIC :: corm_f2008_insert_matrix_f64, corm_f2008_query_matrix_f64
  PUBLIC :: corm_f2008_insert_submatrix_f64, corm_f2008_query_submatrix_f64
  PUBLIC :: corm_f2008_zscore_cols
  PUBLIC :: corm_f2008_ckpt_init, corm_f2008_ckpt_save, corm_f2008_ckpt_load

  !> @type orm_checkpoint_f2008_t
  !> @brief Multi-step Fortran 2008 scientific field checkpoint descriptor.
  TYPE, PUBLIC :: orm_checkpoint_f2008_t
    CHARACTER(LEN=48) :: prefix = "ckpt"
    INTEGER(INT32) :: n_cols = 1_INT32
    LOGICAL :: initialized = .FALSE.
  END TYPE orm_checkpoint_f2008_t

  !> @brief Generic zero-copy CONTIGUOUS 1D vector batch-insert interface.
  INTERFACE corm_f2008_insert_vec
    MODULE PROCEDURE corm_f2008_insert_vec_i32
    MODULE PROCEDURE corm_f2008_insert_vec_i64
    MODULE PROCEDURE corm_f2008_insert_vec_f64
  END INTERFACE corm_f2008_insert_vec

  !> @brief Generic zero-copy CONTIGUOUS 1D vector query hydration interface.
  INTERFACE corm_f2008_query_vec
    MODULE PROCEDURE corm_f2008_query_vec_i32
    MODULE PROCEDURE corm_f2008_query_vec_i64
    MODULE PROCEDURE corm_f2008_query_vec_f64
  END INTERFACE corm_f2008_query_vec

  INTERFACE
    !> @brief Zero-copy batch insert of a CONTIGUOUS 1D INT32 vector.
    !> @param[in] db Active database object.
    !> @param[in] sql Single-parameter INSERT SQL.
    !> @param[in] vec Contiguous 1D INT32 array.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_insert_vec_i32(db, sql, vec) RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      INTEGER(INT32), DIMENSION(:), CONTIGUOUS, TARGET, INTENT(IN) :: vec
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_insert_vec_i32

    !> @brief Zero-copy hydration of a CONTIGUOUS 1D INT32 vector.
    !> @param[in] db Active database object.
    !> @param[in] sql SELECT SQL query.
    !> @param[out] vec Contiguous destination 1D INT32 array.
    !> @param[out] out_count Number of hydrated elements.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_query_vec_i32(db, sql, vec, out_count) &
        RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      INTEGER(INT32), DIMENSION(:), CONTIGUOUS, TARGET, INTENT(OUT) :: vec
      INTEGER(INT32), INTENT(OUT) :: out_count
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_query_vec_i32

    !> @brief Zero-copy batch insert of a CONTIGUOUS 1D INT64 vector.
    !> @param[in] db Active database object.
    !> @param[in] sql Single-parameter INSERT SQL.
    !> @param[in] vec Contiguous 1D INT64 array.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_insert_vec_i64(db, sql, vec) RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      INTEGER(INT64), DIMENSION(:), CONTIGUOUS, TARGET, INTENT(IN) :: vec
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_insert_vec_i64

    !> @brief Zero-copy hydration of a CONTIGUOUS 1D INT64 vector.
    !> @param[in] db Active database object.
    !> @param[in] sql SELECT SQL query.
    !> @param[out] vec Contiguous destination 1D INT64 array.
    !> @param[out] out_count Number of hydrated elements.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_query_vec_i64(db, sql, vec, out_count) &
        RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      INTEGER(INT64), DIMENSION(:), CONTIGUOUS, TARGET, INTENT(OUT) :: vec
      INTEGER(INT32), INTENT(OUT) :: out_count
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_query_vec_i64

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

    !> @brief Zero-copy insert of active `(n_rows, n_cols)` inside padded `mat`.
    !> @param[in] db Active database object.
    !> @param[in] sql Multi-parameter INSERT SQL.
    !> @param[in] mat Padded CONTIGUOUS 2D REAL64 buffer (`ld_rows >= n_rows`).
    !> @param[in] n_rows Active leading rows to insert.
    !> @param[in] n_cols Active columns to insert.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_insert_submatrix_f64(db, sql, mat, n_rows, &
                                                    n_cols) RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, TARGET, INTENT(IN) :: mat
      INTEGER(INT32), INTENT(IN) :: n_rows, n_cols
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_insert_submatrix_f64

    !> @brief Zero-copy query into active `(max_rows, n_cols)` of padded `mat`.
    !> @param[in] db Active database object.
    !> @param[in] sql Multi-column SELECT SQL.
    !> @param[inout] mat Padded CONTIGUOUS 2D REAL64 buffer.
    !> @param[in] max_rows Maximum rows to write (`<= SIZE(mat, 1)`).
    !> @param[in] n_cols Number of columns to read (`<= SIZE(mat, 2)`).
    !> @param[out] out_rows Number of hydrated rows.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_query_submatrix_f64(db, sql, mat, max_rows, &
                                                   n_cols, out_rows) RESULT(rc)
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: sql
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, TARGET, INTENT(INOUT) :: mat
      INTEGER(INT32), INTENT(IN) :: max_rows, n_cols
      INTEGER(INT32), INTENT(OUT) :: out_rows
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_query_submatrix_f64

    !> @brief Column-wise `DO CONCURRENT` z-score standardization in place.
    !> @param[inout] mat Contiguous 2D REAL64 matrix standardized per column.
    MODULE SUBROUTINE corm_f2008_zscore_cols(mat)
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, INTENT(INOUT) :: mat
    END SUBROUTINE corm_f2008_zscore_cols

    !> @brief Initializes metadata and data tables for `ckpt` on `db`.
    !> @param[out] ckpt Checkpoint manager descriptor.
    !> @param[in] db Active database object.
    !> @param[in] prefix SQL table prefix (`<= 32` chars).
    !> @param[in] n_cols Number of REAL64 field columns (`1..8`).
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_ckpt_init(ckpt, db, prefix, n_cols) RESULT(rc)
      TYPE(orm_checkpoint_f2008_t), INTENT(OUT) :: ckpt
      CLASS(orm_db_t), INTENT(IN) :: db
      CHARACTER(LEN=*), INTENT(IN) :: prefix
      INTEGER(INT32), INTENT(IN) :: n_cols
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_ckpt_init

    !> @brief Atomically checkpoints 2D CONTIGUOUS field `mat` at `step_no`.
    !> @param[in] ckpt Initialized checkpoint descriptor.
    !> @param[in] db Active database object.
    !> @param[in] step_no Simulation time-step number.
    !> @param[in] sim_time Physical simulation time.
    !> @param[in] mat Contiguous `(N, n_cols)` field state.
    !> @param[out] out_l2 Computed Frobenius L2 norm stored in metadata.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_ckpt_save(ckpt, db, step_no, sim_time, mat, &
                                         out_l2) RESULT(rc)
      TYPE(orm_checkpoint_f2008_t), INTENT(IN) :: ckpt
      CLASS(orm_db_t), INTENT(IN) :: db
      INTEGER(INT32), INTENT(IN) :: step_no
      REAL(REAL64), INTENT(IN) :: sim_time
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, INTENT(IN) :: mat
      REAL(REAL64), INTENT(OUT) :: out_l2
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_ckpt_save

    !> @brief Restores checkpoint `step_no` into CONTIGUOUS `out_mat`.
    !> @param[in] ckpt Initialized checkpoint descriptor.
    !> @param[in] db Active database object.
    !> @param[in] step_no Simulation time-step number to restore.
    !> @param[out] out_sim_time Restored physical simulation time.
    !> @param[out] out_mat Contiguous destination `(N, n_cols)` matrix.
    !> @param[out] out_rows Number of restored rows.
    !> @return Unified `fortran_orm_error_t` status code.
    MODULE FUNCTION corm_f2008_ckpt_load(ckpt, db, step_no, out_sim_time, &
                                         out_mat, out_rows) RESULT(rc)
      TYPE(orm_checkpoint_f2008_t), INTENT(IN) :: ckpt
      CLASS(orm_db_t), INTENT(IN) :: db
      INTEGER(INT32), INTENT(IN) :: step_no
      REAL(REAL64), INTENT(OUT) :: out_sim_time
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, TARGET, INTENT(OUT) :: out_mat
      INTEGER(INT32), INTENT(OUT) :: out_rows
      INTEGER(C_INT) :: rc
    END FUNCTION corm_f2008_ckpt_load
  END INTERFACE

END MODULE fortran_orm_f2008
