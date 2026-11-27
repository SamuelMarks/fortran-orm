!> @file fortran2018_mhd_alfven_strided.f90
!> @brief ISO/IEC 1539-1:2018 Fortran 2018 1D/2D ideal Magnetohydrodynamics
!> (MHD) shear Alfven-wave solver using strided `CFI_cdesc_t` array views.
!>
!> Showcases `fortran_orm_f2018`: zero-transpose strided CFI persistence of
!> interleaved `(vy, by)` state arrays (`state(:, 1:2)` and decimated spatial
!> probes `state(1:nx:3, :)`) plus `corm_f2018_col_str_alloc`.
MODULE mhd_alfven_f2018_mod
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE
  PUBLIC :: mhd_alfven_rk2_step, elsasser_energies

CONTAINS

  !> @brief Advances linear shear Alfven system `d(vy)/dt = vA * d(by)/dx`,
  !> `d(by)/dt = vA * d(vy)/dx` on a periodic `[0, L)` domain via midpoint RK2.
  !> @param[inout] state `(nx, 2)` array where `col 1 = vy`, `col 2 = by`.
  !> @param[in] va Alfven speed `B0 / sqrt(mu0 * rho0)`.
  !> @param[in] dx Grid spacing.
  !> @param[in] dt Time step (`vA * dt / dx <= 0.5`).
  PURE SUBROUTINE mhd_alfven_rk2_step(state, va, dx, dt)
    REAL(REAL64), DIMENSION(:, :), INTENT(INOUT) :: state
    REAL(REAL64), INTENT(IN) :: va, dx, dt
    REAL(REAL64), DIMENSION(SIZE(state, 1), 2) :: k1, s_mid, k2

    CALL alfven_rhs(state, va, dx, k1)
    s_mid = state + 0.5_REAL64 * dt * k1
    CALL alfven_rhs(s_mid, va, dx, k2)
    state = state + dt * k2
  END SUBROUTINE mhd_alfven_rk2_step

  !> @brief Evaluates centered periodic spatial derivatives for `(vy, by)`.
  !> @param[in] s `(nx, 2)` state array.
  !> @param[in] va Alfven speed.
  !> @param[in] dx Grid spacing.
  !> @param[out] dsdt `(nx, 2)` time derivative array.
  PURE SUBROUTINE alfven_rhs(s, va, dx, dsdt)
    REAL(REAL64), DIMENSION(:, :), INTENT(IN) :: s
    REAL(REAL64), INTENT(IN) :: va, dx
    REAL(REAL64), DIMENSION(:, :), INTENT(OUT) :: dsdt
    INTEGER(INT32) :: nx, i, im, ip
    REAL(REAL64) :: c_fac

    nx = INT(SIZE(s, 1), INT32)
    c_fac = va / (2.0_REAL64 * dx)
    DO i = 1_INT32, nx
      im = MODULO(i - 2_INT32, nx) + 1_INT32
      ip = MODULO(i, nx) + 1_INT32
      dsdt(i, 1) = c_fac * (s(ip, 2) - s(im, 2))
      dsdt(i, 2) = c_fac * (s(ip, 1) - s(im, 1))
    END DO
  END SUBROUTINE alfven_rhs

  !> @brief Computes Elsasser `z+ = vy - by` and `z- = vy + by` wave energies.
  !> @param[in] state `(nx, 2)` state array.
  !> @param[in] dx Grid spacing.
  !> @param[out] ez_plus Forward-propagating Elsasser energy.
  !> @param[out] ez_minus Backward-propagating Elsasser energy.
  PURE SUBROUTINE elsasser_energies(state, dx, ez_plus, ez_minus)
    REAL(REAL64), DIMENSION(:, :), INTENT(IN) :: state
    REAL(REAL64), INTENT(IN) :: dx
    REAL(REAL64), INTENT(OUT) :: ez_plus, ez_minus
    ez_plus = 0.25_REAL64 * dx * SUM((state(:, 1) - state(:, 2)) ** 2)
    ez_minus = 0.25_REAL64 * dx * SUM((state(:, 1) + state(:, 2)) ** 2)
  END SUBROUTINE elsasser_energies

END MODULE mhd_alfven_f2018_mod

!> @brief Main Fortran 2018 strided MHD Alfven-wave CFI ORM program.
PROGRAM fortran2018_mhd_alfven
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE fortran_orm_f2018
  USE mhd_alfven_f2018_mod
  IMPLICIT NONE (TYPE, EXTERNAL)

  INTEGER(INT32), PARAMETER :: NX = 24_INT32
  REAL(REAL64), PARAMETER :: TWO_PI = 6.283185307179586_REAL64
  TYPE(orm_db_t) :: db
  TYPE(orm_stmt_t) :: stmt
  REAL(REAL64), DIMENSION(NX, 4) :: yee_grid, yee_recv
  CHARACTER(LEN=:), ALLOCATABLE :: mode_label
  REAL(REAL64) :: dx, va, dt, x, ezp0, ezm0, ezp1, ezm1
  INTEGER(INT32) :: i, step_k, nrows, rc
  LOGICAL :: has_row

  dx = 1.0_REAL64 / REAL(NX, REAL64)
  va = 2.0_REAL64
  dt = 0.01_REAL64

  ! Pure rightward Elsasser `z+` Alfven eigenmode (`by = -vy`): `z- == 0`!
  yee_grid = 0.0_REAL64
  DO i = 1_INT32, NX
    x = REAL(i - 1_INT32, REAL64) * dx
    yee_grid(i, 1) = x
    yee_grid(i, 2) =  SIN(TWO_PI * x)
    yee_grid(i, 3) = -SIN(TWO_PI * x)
    yee_grid(i, 4) =  0.5_REAL64 * (yee_grid(i, 2) ** 2 + yee_grid(i, 3) ** 2)
  END DO

  CALL elsasser_energies(yee_grid(:, 2:3), dx, ezp0, ezm0)
  DO step_k = 1_INT32, 50_INT32
    CALL mhd_alfven_rk2_step(yee_grid(:, 2:3), va, dx, dt)
  END DO
  yee_grid(:, 4) = 0.5_REAL64 * (yee_grid(:, 2) ** 2 + yee_grid(:, 3) ** 2)
  CALL elsasser_energies(yee_grid(:, 2:3), dx, ezp1, ezm1)
  IF (ezm1 > 1.0E-6_REAL64 .OR. ABS(ezp1 - ezp0) > 1.0E-2_REAL64) ERROR STOP 1

  rc = corm_f2018_open(db, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, &
    "CREATE TABLE mhd_probes(x REAL, vy REAL, by REAL, emag REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "CREATE TABLE mhd_meta(regime TEXT)")
  rc = corm_f2018_exec(db, "INSERT INTO mhd_meta VALUES('SHEAR_ALFVEN_ZPLUS')")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! Persist every 3rd spatial probe (`1:24:3`, 8 strided rows) via CFI!
  IF (corm_f2018_is_contig(yee_grid(1:NX:3, :))) ERROR STOP 1
  rc = corm_f2018_insert_any_rank(db, &
    "INSERT INTO mhd_probes VALUES(?,?,?,?)", yee_grid(1:NX:3, :))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  yee_recv = -999.0_REAL64
  rc = corm_f2018_query_any_rank(db, &
    "SELECT x, vy, by, emag FROM mhd_probes", yee_recv(2:NX:3, :), nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 8_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(yee_recv(2:NX:3, :) - yee_grid(1:NX:3, :))) > &
      1.0E-12_REAL64) ERROR STOP 1

  ! Verify `corm_f2018_col_str_alloc` descriptor column reader
  rc = stmt%prepare(db, "SELECT regime FROM mhd_meta")
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) ERROR STOP 1
  rc = corm_f2018_col_str_alloc(stmt, 1_INT32, mode_label)
  IF (rc /= FORTRAN_ORM_OK .OR. mode_label /= "SHEAR_ALFVEN_ZPLUS") THEN
    ERROR STOP 1
  END IF
  rc = stmt%close()

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,2F10.5)', "MHD ALFVEN F2018 OK: ez+,ez-=", ezp1, ezm1
END PROGRAM fortran2018_mhd_alfven
