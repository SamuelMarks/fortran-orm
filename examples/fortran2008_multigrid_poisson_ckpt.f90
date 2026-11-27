!> @file fortran2008_multigrid_poisson_ckpt.f90
!> @brief ISO/IEC 1539-1:2010 Fortran 2008 2D electrostatic Poisson solver
!> (`DO CONCURRENT` red-black SOR) with `orm_checkpoint_f2008_t` restart &
!> `corm_f2008_zscore_cols` feature standardization.
MODULE poisson_sor_f2008_mod
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: red_black_sor_sweep, poisson_residual_l2

CONTAINS

  !> @brief Performs one red-black Gauss-Seidel SOR sweep on `-Laplacian(phi) =
  !> rho` over interior `(2..nx-1, 2..ny-1)` using `DO CONCURRENT`.
  !> @param[inout] phi Electrostatic potential grid `(nx, ny)`.
  !> @param[in] rhs Charge-density source `h^2 * rho / eps0` `(nx, ny)`.
  !> @param[in] omega_sor Over-relaxation factor (`1 < omega < 2`).
  SUBROUTINE red_black_sor_sweep(phi, rhs, omega_sor)
    REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, INTENT(INOUT) :: phi
    REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, INTENT(IN) :: rhs
    REAL(REAL64), INTENT(IN) :: omega_sor
    INTEGER(INT32) :: nx, ny, i, j, parity
    REAL(REAL64) :: gs_est

    nx = INT(SIZE(phi, 1), INT32)
    ny = INT(SIZE(phi, 2), INT32)

    DO parity = 0_INT32, 1_INT32
      DO CONCURRENT (j = 2_INT32:ny - 1_INT32, i = 2_INT32:nx - 1_INT32, &
                     MOD(i + j, 2_INT32) == parity)
        gs_est = 0.25_REAL64 * (phi(i - 1, j) + phi(i + 1, j) + &
                                phi(i, j - 1) + phi(i, j + 1) + rhs(i, j))
        phi(i, j) = (1.0_REAL64 - omega_sor) * phi(i, j) + omega_sor * gs_est
      END DO
    END DO
  END SUBROUTINE red_black_sor_sweep

  !> @brief Computes discrete L2 residual norm of `-Laplacian(phi) - rhs`.
  !> @param[in] phi Potential grid `(nx, ny)`.
  !> @param[in] rhs Scaled source grid `(nx, ny)`.
  !> @return Euclidean L2 residual norm.
  PURE FUNCTION poisson_residual_l2(phi, rhs) RESULT(res_l2)
    REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, INTENT(IN) :: phi, rhs
    REAL(REAL64) :: res_l2
    REAL(REAL64), DIMENSION(SIZE(phi, 1), SIZE(phi, 2)) :: rgrid
    INTEGER(INT32) :: nx, ny, i, j
    nx = INT(SIZE(phi, 1), INT32)
    ny = INT(SIZE(phi, 2), INT32)
    rgrid = 0.0_REAL64
    DO CONCURRENT (j = 2_INT32:ny - 1_INT32, i = 2_INT32:nx - 1_INT32)
      rgrid(i, j) = rhs(i, j) - (4.0_REAL64 * phi(i, j) - &
                    phi(i - 1, j) - phi(i + 1, j) - &
                    phi(i, j - 1) - phi(i, j + 1))
    END DO
    res_l2 = SQRT(SUM(rgrid * rgrid))
  END FUNCTION poisson_residual_l2

END MODULE poisson_sor_f2008_mod

!> @brief Main Fortran 2008 Poisson SOR checkpoint/restart & z-score program.
PROGRAM fortran2008_poisson_ckpt
  USE fortran_orm_f2008
  USE poisson_sor_f2008_mod
  IMPLICIT NONE

  INTEGER(INT32), PARAMETER :: NX = 8_INT32
  INTEGER(INT32), PARAMETER :: NY = 8_INT32
  TYPE(orm_db_t) :: db
  TYPE(orm_checkpoint_f2008_t) :: ckpt
  REAL(REAL64), DIMENSION(NX, NY), TARGET :: phi, rhs, phi_mid, phi_restored
  REAL(REAL64), DIMENSION(40), TARGET :: res_hist, res_qry
  REAL(REAL64) :: h, omega, res0, res_final, l2_saved, t_restored
  INTEGER(INT32) :: rc, iter, n_rows, n_hist

  h = 1.0_REAL64 / REAL(NX - 1_INT32, REAL64)
  omega = 1.45_REAL64
  phi = 0.0_REAL64
  rhs = 0.0_REAL64
  ! Quadrupole-dipole interior charge distribution
  rhs(3, 3) =  10.0_REAL64 * h * h
  rhs(6, 6) = -10.0_REAL64 * h * h
  rhs(3, 6) =  -5.0_REAL64 * h * h
  rhs(6, 3) =   5.0_REAL64 * h * h

  res0 = poisson_residual_l2(phi, rhs)

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_ckpt_init(ckpt, db, "sor_phi", NY)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  DO iter = 1_INT32, 20_INT32
    CALL red_black_sor_sweep(phi, rhs, omega)
    res_hist(iter) = poisson_residual_l2(phi, rhs)
  END DO
  phi_mid = phi

  ! Checkpoint iteration 20 via `corm_f2008_ckpt_save`
  rc = corm_f2008_ckpt_save(ckpt, db, 20_INT32, 0.20_REAL64, phi, l2_saved)
  IF (rc /= FORTRAN_ORM_OK .OR. l2_saved <= 0.0_REAL64) ERROR STOP 1

  ! Corrupt `phi` to simulate node preemption, then restore from checkpoint 20!
  phi = 999.0_REAL64
  rc = corm_f2008_ckpt_load(ckpt, db, 20_INT32, t_restored, &
                            phi_restored, n_rows)
  IF (rc /= FORTRAN_ORM_OK .OR. n_rows /= NX) ERROR STOP 1
  IF (ABS(t_restored - 0.20_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
  IF (MAXVAL(ABS(phi_restored - phi_mid)) > 1.0E-12_REAL64) ERROR STOP 1

  phi = phi_restored
  DO iter = 21_INT32, 40_INT32
    CALL red_black_sor_sweep(phi, rhs, omega)
    res_hist(iter) = poisson_residual_l2(phi, rhs)
  END DO
  res_final = res_hist(40)
  IF (res_final >= 1.0E-4_REAL64 * res0) ERROR STOP 1

  ! Persist CONTIGUOUS 1D residual convergence history via generic `insert_vec`
  rc = db%exec("CREATE TABLE sor_res(r_l2 REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_vec(db, "INSERT INTO sor_res VALUES(?)", res_hist)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_query_vec(db, "SELECT r_l2 FROM sor_res", res_qry, n_hist)
  IF (rc /= FORTRAN_ORM_OK .OR. n_hist /= 40_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(res_qry - res_hist)) > 1.0E-12_REAL64) ERROR STOP 1

  ! Standardize interior columns `(2:7, 2:7)` via `DO CONCURRENT` z-score
  BLOCK
    REAL(REAL64), DIMENSION(6, 6) :: inner_pot
    inner_pot = phi(2:7, 2:7)
    CALL corm_f2008_zscore_cols(inner_pot)
    IF (MAXVAL(ABS(SUM(inner_pot, DIM=1))) > 1.0E-11_REAL64) ERROR STOP 1
  END BLOCK

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,2E13.5)', "POISSON F2008 OK: res0,res40=", res0, res_final
END PROGRAM fortran2008_poisson_ckpt
