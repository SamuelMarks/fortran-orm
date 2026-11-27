!> @file fortran2018_3d_heat_tensor_cfi.f90
!> @brief ISO/IEC 1539-1:2018 Fortran 2018 3D anisotropic heat-diffusion brick
!> persisted & sliced via TS 29113 `CFI_cdesc_t` and `SELECT RANK`.
!>
!> Showcases `fortran_orm_f2018`:
!> - `corm_f2018_save_tensor_f64` & `corm_f2018_load_tensor_f64` across Rank-3
!>   `(nx, ny, nz)` volumetric bricks, Rank-2 mid-plane slices, Rank-1 borehole
!>   cores, and Rank-0 thermal energy scalars
!> - `corm_f2018_is_contig` & `corm_f2018_rank_of` inspection on strided views
MODULE heat3d_f2018_mod
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE
  PUBLIC :: heat3d_ftcs_step

CONTAINS

  !> @brief Explicit 7-point 3D anisotropic FTCS heat-conduction step with
  !> homogeneous Dirichlet boundary faces.
  !> @param[inout] temp_brick 3D temperature field `(nx, ny, nz)` in Kelvin.
  !> @param[in] kx_dt_dx2 Zonal Fourier number `alpha_x * dt / dx^2`.
  !> @param[in] ky_dt_dy2 Meridional Fourier number `alpha_y * dt / dy^2`.
  !> @param[in] kz_dt_dz2 Vertical Fourier number `alpha_z * dt / dz^2`.
  PURE SUBROUTINE heat3d_ftcs_step(temp_brick, kx_dt_dx2, ky_dt_dy2, kz_dt_dz2)
    REAL(REAL64), DIMENSION(:, :, :), INTENT(INOUT) :: temp_brick
    REAL(REAL64), INTENT(IN) :: kx_dt_dx2, ky_dt_dy2, kz_dt_dz2
    REAL(REAL64), DIMENSION(SIZE(temp_brick, 1), SIZE(temp_brick, 2), &
                            SIZE(temp_brick, 3)) :: t_next
    INTEGER(INT32) :: nx, ny, nz, i, j, k

    nx = INT(SIZE(temp_brick, 1), INT32)
    ny = INT(SIZE(temp_brick, 2), INT32)
    nz = INT(SIZE(temp_brick, 3), INT32)
    t_next = temp_brick

    DO k = 2_INT32, nz - 1_INT32
      DO j = 2_INT32, ny - 1_INT32
        DO i = 2_INT32, nx - 1_INT32
          t_next(i, j, k) = temp_brick(i, j, k) + &
            kx_dt_dx2 * (temp_brick(i - 1, j, k) - 2.0_REAL64 * &
                         temp_brick(i, j, k) + temp_brick(i + 1, j, k)) + &
            ky_dt_dy2 * (temp_brick(i, j - 1, k) - 2.0_REAL64 * &
                         temp_brick(i, j, k) + temp_brick(i, j + 1, k)) + &
            kz_dt_dz2 * (temp_brick(i, j, k - 1) - 2.0_REAL64 * &
                         temp_brick(i, j, k) + temp_brick(i, j, k + 1))
        END DO
      END DO
    END DO
    temp_brick = t_next
  END SUBROUTINE heat3d_ftcs_step

END MODULE heat3d_f2018_mod

!> @brief Main Fortran 2018 3D anisotropic heat tensor CFI ORM program.
PROGRAM fortran2018_3d_heat_cfi
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE fortran_orm_f2018
  USE heat3d_f2018_mod
  IMPLICIT NONE (TYPE, EXTERNAL)

  INTEGER(INT32), PARAMETER :: NX = 6_INT32
  INTEGER(INT32), PARAMETER :: NY = 6_INT32
  INTEGER(INT32), PARAMETER :: NZ = 5_INT32
  TYPE(orm_db_t) :: db
  REAL(REAL64), DIMENSION(NX, NY, NZ) :: t_brick, t_loaded
  REAL(REAL64), DIMENSION(3, 3, NZ) :: coarse_sub, coarse_loaded
  REAL(REAL64), DIMENSION(NX, NZ) :: y_mid_plane
  REAL(REAL64) :: peak_k, peak_loaded
  INTEGER(INT32) :: rc, step_n, n_items, i, j, k

  ! Initialize 300 K host rock with 1150 K magmatic sill intrusion at center
  t_brick = 300.0_REAL64
  DO k = 2_INT32, 4_INT32
    DO j = 3_INT32, 4_INT32
      DO i = 3_INT32, 4_INT32
        t_brick(i, j, k) = 1150.0_REAL64
      END DO
    END DO
  END DO

  DO step_n = 1_INT32, 8_INT32
    CALL heat3d_ftcs_step(t_brick, 0.10_REAL64, 0.08_REAL64, 0.05_REAL64)
  END DO
  peak_k = MAXVAL(t_brick)
  IF (peak_k >= 1150.0_REAL64 .OR. peak_k <= 400.0_REAL64) ERROR STOP 1

  rc = corm_f2018_open(db, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 1. Verify runtime rank & contiguity of full brick vs strided 3D subgrid
  IF (corm_f2018_rank_of(t_brick) /= 3_INT32) ERROR STOP 1
  IF (.NOT. corm_f2018_is_contig(t_brick)) ERROR STOP 1
  IF (corm_f2018_is_contig(t_brick(1:NX:2, 1:NY:2, :))) ERROR STOP 1

  ! 2. Persist full Rank-3 `(6, 6, 5)` temperature brick via `SELECT RANK`
  rc = corm_f2018_save_tensor_f64(db, "heat_brick_full", t_brick)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  t_loaded = 0.0_REAL64
  rc = corm_f2018_load_tensor_f64(db, "heat_brick_full", t_loaded, n_items)
  IF (rc /= FORTRAN_ORM_OK .OR. n_items /= NX * NZ) ERROR STOP 1
  IF (MAXVAL(ABS(t_loaded - t_brick)) > 1.0E-12_REAL64) ERROR STOP 1

  ! 3. Persist strided non-contiguous Rank-3 decimated view `t_brick(2:6:2,2:6:2,:)`!
  coarse_sub = t_brick(2:NX:2, 2:NY:2, :)
  rc = corm_f2018_save_tensor_f64(db, "heat_brick_decim", &
                                  t_brick(2:NX:2, 2:NY:2, :))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  coarse_loaded = 0.0_REAL64
  rc = corm_f2018_load_tensor_f64(db, "heat_brick_decim", coarse_loaded, &
                                  n_items)
  IF (rc /= FORTRAN_ORM_OK .OR. n_items /= 3_INT32 * NZ) ERROR STOP 1
  IF (MAXVAL(ABS(coarse_loaded - coarse_sub)) > 1.0E-12_REAL64) ERROR STOP 1

  ! 4. Persist strided Rank-2 cross-section `t_brick(:, 3, :)` & Rank-0 scalar
  rc = corm_f2018_save_tensor_f64(db, "heat_xz_slice", t_brick(:, 3, :))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  y_mid_plane = 0.0_REAL64
  rc = corm_f2018_load_tensor_f64(db, "heat_xz_slice", y_mid_plane, n_items)
  IF (rc /= FORTRAN_ORM_OK .OR. n_items /= NX) ERROR STOP 1
  IF (MAXVAL(ABS(y_mid_plane - t_brick(:, 3, :))) > 1.0E-12_REAL64) THEN
    ERROR STOP 1
  END IF

  rc = corm_f2018_save_tensor_f64(db, "heat_peak_k", peak_k)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_load_tensor_f64(db, "heat_peak_k", peak_loaded, n_items)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(peak_loaded - peak_k) > 1.0E-12_REAL64) THEN
    ERROR STOP 1
  END IF

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,F10.3)', "HEAT3D CFI F2018 OK: peak_K=", peak_loaded
END PROGRAM fortran2018_3d_heat_cfi
