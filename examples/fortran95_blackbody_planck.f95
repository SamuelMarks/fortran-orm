!> @file fortran95_blackbody_planck.f95
!> @module planck_rad_f95
!> @brief ISO Fortran 95 PURE/ELEMENTAL/FORALL stellar Planck radiance example.
MODULE planck_rad_f95
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: planck_spectral_shape, wien_peak_um

CONTAINS

  !> @brief Pure Fortran 95 Wien displacement peak wavelength (micrometers).
  !> @param[in] temp_k Effective photospheric blackbody temperature (K).
  !> @return Peak emission wavelength lambda_max in micrometers.
  PURE FUNCTION wien_peak_um(temp_k) RESULT(peak_um)
    DOUBLE PRECISION, INTENT(IN) :: temp_k
    DOUBLE PRECISION :: peak_um
    peak_um = 2897.771955D0 / temp_k
  END FUNCTION wien_peak_um

  !> @brief Elemental dimensionless Planck spectral radiance kernel.
  !> @param[in] wl_um Wavelength in micrometers.
  !> @param[in] temp_k Blackbody temperature in Kelvin.
  !> @return Relative spectral radiance proportional to B_lambda(wl_um, T).
  ELEMENTAL FUNCTION planck_spectral_shape(wl_um, temp_k) RESULT(b_rel)
    DOUBLE PRECISION, INTENT(IN) :: wl_um, temp_k
    DOUBLE PRECISION :: b_rel
    DOUBLE PRECISION :: x_exp
    x_exp = 14387.76877D0 / (wl_um * temp_k)
    b_rel = 1.0D0 / ((wl_um ** 5) * (EXP(x_exp) - 1.0D0))
  END FUNCTION planck_spectral_shape

END MODULE planck_rad_f95

PROGRAM fortran95_blackbody_planck
  USE fortran_orm_f95
  USE planck_rad_f95
  IMPLICIT NONE

  TYPE(corm_db_f95) :: db
  DOUBLE PRECISION, DIMENSION(6, 3) :: spec_grid, calibrated_out
  INTEGER, DIMENSION(4) :: statuses
  DOUBLE PRECISION :: t_sun, peak_wl, gain_factor
  INTEGER :: i, nrows

  ! Verify F95 default component initialization (`slot = 0`)
  IF (corm_f95_db_is_open(db)) STOP 1

  CALL corm_f95_open(":memory:", db, statuses(1))
  IF (.NOT. corm_f95_db_is_open(db)) STOP 1
  CALL corm_f95_exec(db, &
       "CREATE TABLE solar_spectrum(wl_s REAL, t_s REAL, flux_s REAL)", &
       statuses(2))

  t_sun = 5778.0D0
  peak_wl = wien_peak_um(t_sun)
  IF (peak_wl < 0.49D0 .OR. peak_wl > 0.51D0) STOP 1

  FORALL (i = 1:6)
    spec_grid(i, 1) = 0.35D0 + DBLE(i - 1) * 0.15D0
    spec_grid(i, 2) = t_sun
  END FORALL
  spec_grid(:, 3) = planck_spectral_shape(spec_grid(:, 1), spec_grid(:, 2))

  gain_factor = 1.191042972D2
  CALL corm_f95_insert_scaled_matrix( &
       db, "INSERT INTO solar_spectrum VALUES(?,?,?)", &
       spec_grid, gain_factor, statuses(3))

  calibrated_out = 0.0D0
  CALL corm_f95_query_matrix( &
       db, "SELECT wl_s, t_s, flux_s FROM solar_spectrum", &
       calibrated_out, nrows, statuses(4))

  IF (.NOT. ALL(corm_f95_is_ok(statuses)) .OR. nrows /= 6) STOP 1
  IF (MAXVAL(ABS(calibrated_out - spec_grid * gain_factor)) > 1.0D-9) STOP 1
  ! Peak solar radiance near 0.50 um (row 2) exceeds 0.35 um (row 1) & 1.10 um
  IF (calibrated_out(2, 3) <= calibrated_out(1, 3)) STOP 1
  IF (calibrated_out(2, 3) <= calibrated_out(6, 3)) STOP 1

  CALL corm_f95_close(db, statuses(1))
  IF (.NOT. corm_f95_is_ok(statuses(1)) .OR. corm_f95_db_is_open(db)) STOP 1
  PRINT '(A,F6.4,A,F10.3)', "Wien peak um = ", peak_wl, &
        " peak scaled radiance = ", calibrated_out(2, 3)
END PROGRAM fortran95_blackbody_planck
