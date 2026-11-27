!> @file era_11_fortran_2018.f90
!> @brief End-to-end ISO/IEC 1539-1:2018 Fortran 2018 CFI_cdesc_t assumed-rank,
!> strided slice, and `SELECT RANK` Rank 0..3 volumetric tensor verification.
PROGRAM era_11_fortran_2018
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE fortran_orm_f2018
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  TYPE(orm_stmt_t) :: stmt
  REAL(REAL64) :: sc_in, sc_out
  REAL(REAL64), DIMENSION(6) :: v1_in, v1_out
  REAL(REAL64), DIMENSION(6, 2) :: full_grid, recv_grid
  REAL(REAL64), DIMENSION(4, 2, 3) :: brick_in, brick_out
  REAL(REAL64), DIMENSION(1, 1, 1, 1) :: rank4_arr
  INTEGER(INT32), DIMENSION(4) :: ivec_in, ivec_out
  CHARACTER(LEN=32) :: col_txt
  CHARACTER(LEN=:), ALLOCATABLE :: alloc_txt
  INTEGER(INT32) :: rc, nrows, slen, i, j, k
  LOGICAL :: has_row

  ! 1. `corm_f2018_rank_of` & `corm_f2018_is_contig` across Ranks 0..4
  sc_in = 42.5_REAL64
  v1_in = [1.0_REAL64, 2.0_REAL64, 3.0_REAL64, &
           4.0_REAL64, 5.0_REAL64, 6.0_REAL64]
  rank4_arr = 1.0_REAL64
  IF (corm_f2018_rank_of(sc_in) /= 0_INT32) ERROR STOP 1
  IF (corm_f2018_rank_of(v1_in) /= 1_INT32) ERROR STOP 1
  IF (corm_f2018_rank_of(full_grid) /= 2_INT32) ERROR STOP 1
  IF (corm_f2018_rank_of(brick_in) /= 3_INT32) ERROR STOP 1
  IF (corm_f2018_rank_of(rank4_arr) /= 4_INT32) ERROR STOP 1

  IF (.NOT. corm_f2018_is_contig(sc_in)) ERROR STOP 1
  IF (.NOT. corm_f2018_is_contig(v1_in)) ERROR STOP 1
  IF (corm_f2018_is_contig(v1_in(1:6:2))) ERROR STOP 1
  IF (.NOT. corm_f2018_is_contig(full_grid)) ERROR STOP 1
  IF (corm_f2018_is_contig(full_grid(1:6:2, :))) ERROR STOP 1
  IF (.NOT. corm_f2018_is_contig(brick_in)) ERROR STOP 1
  IF (corm_f2018_is_contig(brick_in(1:4:2, :, :))) ERROR STOP 1
  IF (corm_f2018_is_contig(rank4_arr)) ERROR STOP 1

  rc = corm_f2018_open(db, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2018_exec(db, "CREATE TABLE slice18(a REAL, b REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "CREATE TABLE iv18(k INT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  full_grid(:, 1) = [10.0_REAL64, 20.0_REAL64, 30.0_REAL64, &
                     40.0_REAL64, 50.0_REAL64, 60.0_REAL64]
  full_grid(:, 2) = [1.0_REAL64, 2.0_REAL64, 3.0_REAL64, &
                     4.0_REAL64, 5.0_REAL64, 6.0_REAL64]

  ! 2. Non-contiguous strided slice `full_grid(1:6:2, :)` (rows 1, 3, 5)
  rc = corm_f2018_insert_any_rank(db, "INSERT INTO slice18 VALUES(?,?)", &
                                  full_grid(1:6:2, :))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  recv_grid = 0.0_REAL64
  rc = corm_f2018_query_any_rank(db, "SELECT a, b FROM slice18", &
                                 recv_grid(2:6:2, :), nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 3_INT32) ERROR STOP 1
  IF (ABS(recv_grid(2, 1) - 10.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
  IF (ABS(recv_grid(4, 1) - 30.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
  IF (ABS(recv_grid(6, 2) - 5.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1

  ! 3. Rank-1 INT32 vector via the exact same assumed-rank CFI interface
  ivec_in = [11_INT32, 22_INT32, 33_INT32, 44_INT32]
  rc = corm_f2018_insert_any_rank(db, "INSERT INTO iv18 VALUES(?)", ivec_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  ivec_out = 0_INT32
  rc = corm_f2018_query_any_rank(db, "SELECT k FROM iv18", ivec_out, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 4_INT32) ERROR STOP 1
  IF (ANY(ivec_in /= ivec_out)) ERROR STOP 1

  ! 4. Direct CHARACTER(LEN=*) CFI column read + allocatable helper
  rc = stmt%prepare(db, "SELECT 'TS29113_CFI', ''")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) ERROR STOP 1
  rc = fortran_orm_cfi_col_str(stmt%ptr, 1_INT32, col_txt, slen)
  IF (rc /= FORTRAN_ORM_OK .OR. col_txt(1:slen) /= "TS29113_CFI") ERROR STOP 1
  rc = corm_f2018_col_str_alloc(stmt, 1_INT32, alloc_txt)
  IF (rc /= FORTRAN_ORM_OK .OR. alloc_txt /= "TS29113_CFI") ERROR STOP 1
  rc = corm_f2018_col_str_alloc(stmt, 2_INT32, alloc_txt)
  IF (rc /= FORTRAN_ORM_OK .OR. alloc_txt /= "") ERROR STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 5. `SELECT RANK` volumetric tensor store across Ranks 0, 1, 2, 3 & Default
  rc = corm_f2018_save_tensor_f64(db, "", sc_in)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = corm_f2018_load_tensor_f64(db, "", sc_out, nrows)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1

  rc = corm_f2018_save_tensor_f64(db, "t_r0", sc_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  sc_out = 0.0_REAL64
  rc = corm_f2018_load_tensor_f64(db, "t_r0", sc_out, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 1_INT32) ERROR STOP 1
  IF (ABS(sc_out - sc_in) > 1.0E-12_REAL64) ERROR STOP 1

  rc = corm_f2018_save_tensor_f64(db, "t_r1", v1_in(1:6:2))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  v1_out = 0.0_REAL64
  rc = corm_f2018_load_tensor_f64(db, "t_r1", v1_out(2:6:2), nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 3_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(v1_out(2:6:2) - v1_in(1:6:2))) > 1.0E-12_REAL64) ERROR STOP 1

  rc = corm_f2018_save_tensor_f64(db, "t_r2", full_grid)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  recv_grid = 0.0_REAL64
  rc = corm_f2018_load_tensor_f64(db, "t_r2", recv_grid, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 6_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(recv_grid - full_grid)) > 1.0E-12_REAL64) ERROR STOP 1

  DO k = 1, 3
    DO j = 1, 2
      DO i = 1, 4
        brick_in(i, j, k) = REAL(100 * k + 10 * j + i, REAL64)
      END DO
    END DO
  END DO
  rc = corm_f2018_save_tensor_f64(db, "t_r3", brick_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  brick_out = 0.0_REAL64
  rc = corm_f2018_load_tensor_f64(db, "t_r3", brick_out, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 12_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(brick_out - brick_in)) > 1.0E-12_REAL64) ERROR STOP 1

  rc = corm_f2018_exec(db, "CREATE VIEW bad_r3 AS SELECT 1.0 AS c1, 2.0 AS c2")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_save_tensor_f64(db, "bad_r3", brick_in)
  IF (rc == FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2018_save_tensor_f64(db, "t_r4", rank4_arr)
  IF (rc /= FORTRAN_ORM_ERROR_DESCRIPTOR_RANK) ERROR STOP 1
  rc = corm_f2018_load_tensor_f64(db, "t_r4", rank4_arr, nrows)
  IF (rc /= FORTRAN_ORM_ERROR_DESCRIPTOR_RANK) ERROR STOP 1

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A)', "PASS: Fortran 2018"
END PROGRAM era_11_fortran_2018
