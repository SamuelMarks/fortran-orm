!> @file fortran95_lattice_boltzmann_d2q9.f95
!> @brief ISO/IEC 1539-1:1997 Fortran 95 BGK D2Q9 Lattice Boltzmann Poiseuille
!> channel flow solver with `FORALL` affine calibration & AST SQL rendering.
!>
!> Showcases `fortran_orm_f95_orm` (`PURE`/`ELEMENTAL` kernels, `FORALL`,
!> `corm_f95_insert_affine_matrix`, `corm_ast_f95`, savepoints, and generic
!> `corm_f95_bind`/`corm_f95_col`) in strict ISO Fortran 95.
MODULE lbm_d2q9_f95_mod
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: lbm_feq_scalar, lbm_bgk_channel_step

CONTAINS

  !> @brief Elemental D2Q9 Maxwell-Boltzmann equilibrium distribution `f_eq`
  !> at lattice speed of sound `cs^2 = 1/3`.
  !> @param[in] wt Lattice weight `w_k`.
  !> @param[in] rho Macroscopic density.
  !> @param[in] cx Discrete velocity x-component `c_{kx}`.
  !> @param[in] cy Discrete velocity y-component `c_{ky}`.
  !> @param[in] ux Macroscopic x-velocity.
  !> @param[in] uy Macroscopic y-velocity.
  !> @return Equilibrium population `f_k^{eq}`.
  ELEMENTAL FUNCTION lbm_feq_scalar(wt, rho, cx, cy, ux, uy) RESULT(feq)
    DOUBLE PRECISION, INTENT(IN) :: wt, rho, cx, cy, ux, uy
    DOUBLE PRECISION :: feq, cu, u2
    cu = 3.0D0 * (cx * ux + cy * uy)
    u2 = 1.5D0 * (ux * ux + uy * uy)
    feq = wt * rho * (1.0D0 + cu + 0.5D0 * cu * cu - u2)
  END FUNCTION lbm_feq_scalar

  !> @brief Advances 1D-periodic channel D2Q9 populations `f_pop(nx, ny, 9)` by
  !> one BGK collision + streaming + bounce-back wall step under body force `gx`.
  !> @param[inout] f_pop D2Q9 distribution array `(nx, ny, 9)`.
  !> @param[out] rho_out Macroscopic fluid density `(nx, ny)`.
  !> @param[out] ux_out Macroscopic streamwise velocity `(nx, ny)`.
  !> @param[in] omega BGK relaxation frequency `1 / tau`.
  !> @param[in] gx Body-force acceleration along +x.
  PURE SUBROUTINE lbm_bgk_channel_step(f_pop, rho_out, ux_out, omega, gx)
    DOUBLE PRECISION, DIMENSION(:, :, :), INTENT(INOUT) :: f_pop
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(OUT) :: rho_out, ux_out
    DOUBLE PRECISION, INTENT(IN) :: omega, gx
    DOUBLE PRECISION, DIMENSION(SIZE(f_pop, 1), SIZE(f_pop, 2)) :: uy
    DOUBLE PRECISION, DIMENSION(SIZE(f_pop, 1), SIZE(f_pop, 2), 9) :: f_post
    DOUBLE PRECISION, DIMENSION(9) :: wt, cx, cy
    INTEGER, DIMENSION(9) :: icx, icy
    INTEGER :: nx, ny, i, j, k, ip, jp

    wt = (/ 4.0D0 / 9.0D0, &
            1.0D0 / 9.0D0, 1.0D0 / 9.0D0, 1.0D0 / 9.0D0, 1.0D0 / 9.0D0, &
            1.0D0 / 36.0D0, 1.0D0 / 36.0D0, 1.0D0 / 36.0D0, 1.0D0 / 36.0D0 /)
    icx = (/ 0, 1, 0, -1, 0, 1, -1, -1, 1 /)
    icy = (/ 0, 0, 1, 0, -1, 1, 1, -1, -1 /)
    cx = DBLE(icx)
    cy = DBLE(icy)

    nx = SIZE(f_pop, 1)
    ny = SIZE(f_pop, 2)

    rho_out = SUM(f_pop, DIM=3)
    ux_out = 0.0D0
    uy = 0.0D0
    DO k = 1, 9
      ux_out = ux_out + cx(k) * f_pop(:, :, k)
      uy = uy + cy(k) * f_pop(:, :, k)
    END DO
    ux_out = (ux_out + 0.5D0 * gx) / rho_out
    uy = uy / rho_out
    ux_out(:, 1) = 0.0D0
    ux_out(:, ny) = 0.0D0
    uy(:, 1) = 0.0D0
    uy(:, ny) = 0.0D0

    DO k = 1, 9
      f_post(:, :, k) = f_pop(:, :, k) - omega * (f_pop(:, :, k) - &
        lbm_feq_scalar(wt(k), rho_out, cx(k), cy(k), ux_out, uy)) + &
        3.0D0 * wt(k) * cx(k) * gx
    END DO

    ! Periodic x-streaming + interior y-streaming via FORALL
    DO k = 1, 9
      FORALL (i = 1:nx, j = 2:ny - 1)
        f_pop(i, j, k) = f_post(MODULO(i - 1 - icx(k), nx) + 1, &
                                j - icy(k), k)
      END FORALL
    END DO

    ! Halfway bounce-back no-slip top & bottom channel walls
    DO i = 1, nx
      ip = i
      jp = 1
      f_pop(ip, jp, 3) = f_post(ip, jp, 5)
      f_pop(ip, jp, 6) = f_post(ip, jp, 8)
      f_pop(ip, jp, 7) = f_post(ip, jp, 9)
      jp = ny
      f_pop(ip, jp, 5) = f_post(ip, jp, 3)
      f_pop(ip, jp, 8) = f_post(ip, jp, 6)
      f_pop(ip, jp, 9) = f_post(ip, jp, 7)
    END DO
  END SUBROUTINE lbm_bgk_channel_step

END MODULE lbm_d2q9_f95_mod

!> @brief Main Fortran 95 D2Q9 Lattice Boltzmann Poiseuille ORM program.
PROGRAM f95_lbm_d2q9
  USE fortran_orm_f95_orm
  USE lbm_d2q9_f95_mod
  IMPLICIT NONE

  INTEGER, PARAMETER :: NX = 6
  INTEGER, PARAMETER :: NY = 9
  TYPE(corm_db_f95) :: db
  TYPE(corm_ast_f95) :: ast
  TYPE(corm_stmt_f95) :: stmt
  DOUBLE PRECISION, DIMENSION(NX, NY, 9) :: f_pop
  DOUBLE PRECISION, DIMENSION(NX, NY) :: rho, ux
  DOUBLE PRECISION, DIMENSION(NY, 3) :: prof_lat, prof_phys
  DOUBLE PRECISION, DIMENSION(9) :: wt
  CHARACTER(LEN=128) :: pg_sql
  DOUBLE PRECISION :: omega, gx, vel_scale, u_center, u_wall
  INTEGER :: k, step_n, n_rows, slen, rc
  LOGICAL :: has_row

  wt = (/ 4.0D0 / 9.0D0, &
          1.0D0 / 9.0D0, 1.0D0 / 9.0D0, 1.0D0 / 9.0D0, 1.0D0 / 9.0D0, &
          1.0D0 / 36.0D0, 1.0D0 / 36.0D0, 1.0D0 / 36.0D0, 1.0D0 / 36.0D0 /)
  DO k = 1, 9
    f_pop(:, :, k) = wt(k)
  END DO

  omega = 1.25D0
  gx = 1.5D-4
  DO step_n = 1, 120
    CALL lbm_bgk_channel_step(f_pop, rho, ux, omega, gx)
  END DO

  ! Verify parabolic Poiseuille profile: zero at walls (1, NY), peak at center (5)
  IF (ux(3, 5) <= ux(3, 2) .OR. DABS(ux(3, 1)) > 1.0D-12) STOP 1

  DO k = 1, NY
    prof_lat(k, 1) = DBLE(k - 1)
    prof_lat(k, 2) = ux(3, k)
    prof_lat(k, 3) = rho(3, k)
  END DO

  CALL corm_f95_open(":memory:", db, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_exec(db, &
    "CREATE TABLE lbm_prof(y_scaled REAL, u_mms REAL, rho_scaled REAL)", rc)
  IF (corm_f95_is_err(rc)) STOP 1

  ! Persist affine-calibrated velocity profile (`1000 * mat + 0`) via FORALL
  vel_scale = 1000.0D0
  CALL corm_f95_tx_begin(db, rc)
  CALL corm_f95_savepoint(db, "sp_lbm", rc)
  CALL corm_f95_insert_affine_matrix(db, &
    "INSERT INTO lbm_prof VALUES(?,?,?)", prof_lat, vel_scale, 0.0D0, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_release_sp(db, "sp_lbm", rc)
  CALL corm_f95_tx_commit(db, rc)
  IF (corm_f95_is_err(rc)) STOP 1

  CALL corm_f95_query_matrix(db, &
    "SELECT y_scaled, u_mms, rho_scaled FROM lbm_prof", prof_phys, n_rows, rc)
  IF (corm_f95_is_err(rc) .OR. n_rows /= NY) STOP 1

  u_wall = prof_phys(1, 2)
  u_center = prof_phys(5, 2)
  IF (DABS(u_wall) > 1.0D-9 .OR. u_center <= 0.5D0) STOP 1

  ! Render PostgreSQL AST query & verify generic statement column reader
  CALL corm_f95_ast_select("lbm_prof", 3, ast, rc)
  IF (corm_f95_is_err(rc) .OR. .NOT. corm_f95_ast_is_open(ast)) STOP 1
  CALL corm_f95_ast_to_sql(ast, CORM_F95_DIALECT_POSTGRES, pg_sql, slen, rc)
  IF (corm_f95_is_err(rc) .OR. INDEX(pg_sql(1:slen), "LIMIT 3") == 0) STOP 1
  CALL corm_f95_ast_free(ast, rc)

  CALL corm_f95_prepare(db, "SELECT MAX(u_mms) FROM lbm_prof", stmt, rc)
  CALL corm_f95_step(stmt, has_row, rc)
  IF (corm_f95_is_err(rc) .OR. .NOT. has_row) STOP 1
  CALL corm_f95_col(stmt, 1, vel_scale, rc)
  CALL corm_f95_finalize(stmt, rc)
  IF (DABS(vel_scale - u_center) > 1.0D-9) STOP 1

  CALL corm_f95_close(db, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  PRINT '(A,F12.5)', "LBM D2Q9 OK: u_center_mms=", u_center
END PROGRAM f95_lbm_d2q9
