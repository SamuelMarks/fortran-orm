!> @file fortran95_shallow_water_tsunami.f95
!> @brief ISO/IEC 1539-1:1997 Fortran 95 2D linearized shallow-water wave
!> bathymetry solver with `corm_grid2d_f95` mesh checkpointing & `FORALL` masks.
!>
!> Showcases `fortran_orm_f95_orm` (`corm_grid2d_f95` `=> NULL()` pointer
!> initialization, `corm_f95_grid_save`/`grid_load`, `corm_f95_insert_masked_matrix`,
!> `ELEMENTAL` kernels, and `FORALL` stencil updates) in strict `-std=f95`.
MODULE swe_tsunami_f95_mod
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: swe_leapfrog_step, wave_potential_energy

CONTAINS

  !> @brief Pure 2D shallow-water gravity wave step updating free-surface
  !> elevation `eta` and depth-integrated fluxes `(hu, hv)` via `FORALL`.
  !> @param[inout] eta Free-surface anomaly `(nx, ny)` in meters.
  !> @param[inout] hu Zonal volume flux `(nx, ny)` in m^2/s.
  !> @param[inout] hv Meridional volume flux `(nx, ny)` in m^2/s.
  !> @param[in] depth_h Still-water ocean depth `(nx, ny)` in meters.
  !> @param[in] wet_mask `.TRUE.` for ocean cells, `.FALSE.` for dry shelf/island.
  !> @param[in] dx Grid spacing in meters.
  !> @param[in] dt Time step in seconds.
  PURE SUBROUTINE swe_leapfrog_step(eta, hu, hv, depth_h, wet_mask, dx, dt)
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(INOUT) :: eta, hu, hv
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(IN) :: depth_h
    LOGICAL, DIMENSION(:, :), INTENT(IN) :: wet_mask
    DOUBLE PRECISION, INTENT(IN) :: dx, dt
    DOUBLE PRECISION, DIMENSION(SIZE(eta, 1), SIZE(eta, 2)) :: hu_new, hv_new
    DOUBLE PRECISION, DIMENSION(SIZE(eta, 1), SIZE(eta, 2)) :: eta_new
    DOUBLE PRECISION, PARAMETER :: G_ACC = 9.80665D0
    INTEGER :: nx, ny, i, j

    nx = SIZE(eta, 1)
    ny = SIZE(eta, 2)
    hu_new = 0.0D0
    hv_new = 0.0D0
    eta_new = eta

    FORALL (i = 2:nx - 1, j = 2:ny - 1, wet_mask(i, j))
      hu_new(i, j) = hu(i, j) - (dt / (2.0D0 * dx)) * G_ACC * &
                     depth_h(i, j) * (eta(i + 1, j) - eta(i - 1, j))
      hv_new(i, j) = hv(i, j) - (dt / (2.0D0 * dx)) * G_ACC * &
                     depth_h(i, j) * (eta(i, j + 1) - eta(i, j - 1))
    END FORALL
    hu = hu_new
    hv = hv_new

    FORALL (i = 2:nx - 1, j = 2:ny - 1, wet_mask(i, j))
      eta_new(i, j) = eta(i, j) - (dt / (2.0D0 * dx)) * &
                      ((hu(i + 1, j) - hu(i - 1, j)) + &
                       (hv(i, j + 1) - hv(i, j - 1)))
    END FORALL
    eta = eta_new
  END SUBROUTINE swe_leapfrog_step

  !> @brief Pure potential energy integral `0.5 * rho * g * SUM(eta^2) * dx^2`.
  !> @param[in] eta Free-surface elevation `(nx, ny)` in meters.
  !> @param[in] wet_mask Ocean cell mask.
  !> @param[in] dx Grid cell size in meters.
  !> @return Potential energy in Gigajoules.
  PURE FUNCTION wave_potential_energy(eta, wet_mask, dx) RESULT(pe_gj)
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(IN) :: eta
    LOGICAL, DIMENSION(:, :), INTENT(IN) :: wet_mask
    DOUBLE PRECISION, INTENT(IN) :: dx
    DOUBLE PRECISION :: pe_gj
    DOUBLE PRECISION, PARAMETER :: RHO_SW = 1025.0D0
    DOUBLE PRECISION, PARAMETER :: G_ACC = 9.80665D0
    pe_gj = 0.5D0 * RHO_SW * G_ACC * SUM(eta * eta, MASK=wet_mask) * &
            (dx * dx) * 1.0D-9
  END FUNCTION wave_potential_energy

END MODULE swe_tsunami_f95_mod

!> @brief Main Fortran 95 shallow-water tsunami checkpoint & mask program.
PROGRAM f95_shallow_tsunami
  USE fortran_orm_f95_orm
  USE swe_tsunami_f95_mod
  IMPLICIT NONE

  INTEGER, PARAMETER :: NX = 10
  INTEGER, PARAMETER :: NY = 10
  TYPE(corm_db_f95) :: db
  TYPE(corm_grid2d_f95) :: eta_grid, eta_restored
  TYPE(corm_stmt_f95) :: stmt
  DOUBLE PRECISION, DIMENSION(NX, NY) :: depth_h, hu, hv, masked_out
  LOGICAL, DIMENSION(NX, NY) :: wet_mask
  DOUBLE PRECISION :: dx, dt, r2, pe0, pe_end, dry_sentinel
  INTEGER :: i, j, step_n, n_rows, n_dry, rc
  LOGICAL :: has_row

  ! Verify F95 default component pointer initialization (`=> NULL()`)
  IF (ASSOCIATED(eta_grid%cells) .OR. corm_f95_db_is_open(db)) STOP 1

  dx = 5000.0D0
  dt = 8.0D0
  CALL corm_f95_grid_alloc(eta_grid, NX, NY, dx, dx)
  CALL corm_f95_grid_alloc(eta_restored, NX, NY, dx, dx)

  ! Continental shelf shoaling bathymetry + central dry seamount island (6,6)
  wet_mask = .TRUE.
  wet_mask(6, 6) = .FALSE.
  wet_mask(6, 7) = .FALSE.
  FORALL (i = 1:NX, j = 1:NY)
    depth_h(i, j) = corm_f95_clamp_val(4000.0D0 - 280.0D0 * DBLE(i - 1), &
                                       400.0D0, 4000.0D0)
  END FORALL
  WHERE (.NOT. wet_mask) depth_h = 0.0D0

  hu = 0.0D0
  hv = 0.0D0
  DO j = 1, NY
    DO i = 1, NX
      r2 = DBLE((i - 4) ** 2 + (j - 5) ** 2)
      IF (wet_mask(i, j)) THEN
        eta_grid%cells(i, j) = 2.4D0 * DEXP(-0.35D0 * r2)
      ELSE
        eta_grid%cells(i, j) = 0.0D0
      END IF
    END DO
  END DO
  pe0 = wave_potential_energy(eta_grid%cells, wet_mask, dx)

  DO step_n = 1, 12
    CALL swe_leapfrog_step(eta_grid%cells, hu, hv, depth_h, wet_mask, dx, dt)
  END DO
  pe_end = wave_potential_energy(eta_grid%cells, wet_mask, dx)
  IF (pe0 <= 0.0D0 .OR. pe_end <= 0.0D0) STOP 1

  CALL corm_f95_open(":memory:", db, rc)
  IF (corm_f95_is_err(rc)) STOP 1

  ! 1. Checkpoint 2D structured mesh via `corm_f95_grid_save` & restore
  CALL corm_f95_grid_save(db, "tsunami_ckpt", eta_grid, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_grid_load(db, "tsunami_ckpt", eta_restored, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  IF (MAXVAL(DABS(eta_restored%cells - eta_grid%cells)) > 1.0D-12) STOP 1

  ! 2. Persist wet/dry masked elevation slices via `corm_f95_insert_masked_matrix`
  dry_sentinel = -9999.0D0
  CALL corm_f95_exec(db, &
    "CREATE TABLE eta_slab(c1 REAL, c2 REAL, c3 REAL, c4 REAL, c5 REAL, " // &
    "c6 REAL, c7 REAL, c8 REAL, c9 REAL, c10 REAL)", rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_insert_masked_matrix(db, &
    "INSERT INTO eta_slab VALUES(?,?,?,?,?,?,?,?,?,?)", &
    eta_grid%cells, wet_mask, dry_sentinel, rc)
  IF (corm_f95_is_err(rc)) STOP 1

  CALL corm_f95_query_matrix(db, "SELECT * FROM eta_slab", masked_out, &
                             n_rows, rc)
  IF (corm_f95_is_err(rc) .OR. n_rows /= NX) STOP 1
  n_dry = COUNT(DABS(masked_out - dry_sentinel) < 1.0D-9)
  IF (n_dry /= 2) STOP 1

  ! 3. Log energy audit row using generic `corm_f95_bind` & `corm_f95_col`
  CALL corm_f95_exec(db, &
    "CREATE TABLE swe_log(step_id INT, tag TEXT, pe_gj REAL)", rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_prepare(db, "INSERT INTO swe_log VALUES(?,?,?)", stmt, rc)
  IF (corm_f95_is_err(rc) .OR. .NOT. corm_f95_stmt_is_open(stmt)) STOP 1
  CALL corm_f95_bind(stmt, 1, 12, rc)
  CALL corm_f95_bind(stmt, 2, "PACIFIC_SHELF", rc)
  CALL corm_f95_bind(stmt, 3, pe_end, rc)
  CALL corm_f95_step(stmt, has_row, rc)
  CALL corm_f95_finalize(stmt, rc)
  IF (corm_f95_is_err(rc)) STOP 1

  CALL corm_f95_grid_free(eta_restored)
  CALL corm_f95_grid_free(eta_grid)
  CALL corm_f95_close(db, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  PRINT '(A,I3,2F12.4)', "SWE TSUNAMI OK: dry=", n_dry, pe0, pe_end
END PROGRAM f95_shallow_tsunami
