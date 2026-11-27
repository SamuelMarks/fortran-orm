!> @file fortran2023_exoplanet_transit_dataframe.f90
!> @brief ISO/IEC 1539-1:2023 Fortran 2023 space-telescope exoplanet transit
!> photometry pipeline using `orm_dataframe_f2023_t`, `F_C_STRING`, and JSON.
!>
!> Showcases `fortran_orm` / `fortran_orm_f2023`:
!> - `orm_dataframe_f2023_t` columnar photometry storage, summary statistics
!>   (`col_mean`, `col_variance`, `col_min_max`), in-transit dip filtering
!>   (`filter_gt`), SQL persistence (`save_sql`, `load_sql`), and JSON export
!> - Exact 38-digit planet-to-star radius ratio `Rp / R*` decimal arithmetic
MODULE exoplanet_lc_f2023_mod
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE
  PUBLIC :: box_limb_transit_flux

CONTAINS

  !> @brief Computes normalized exoplanet transit light-curve flux `F(t)` with
  !> quadratic-like limb-darkened ingress/egress tapers.
  !> @param[in] phase_hr Orbital time relative to mid-transit `T0` in hours.
  !> @param[in] depth_ppm Transit depth `(Rp/R*)^2` in parts per million.
  !> @param[in] dur_hr Full transit duration `T_14` in hours.
  !> @param[in] tau_hr Ingress/egress duration in hours.
  !> @return Normalized stellar flux (`1.0` out-of-transit).
  ELEMENTAL FUNCTION box_limb_transit_flux(phase_hr, depth_ppm, dur_hr, &
                                           tau_hr) RESULT(flux)
    REAL(REAL64), INTENT(IN) :: phase_hr, depth_ppm, dur_hr, tau_hr
    REAL(REAL64) :: flux, dt_abs, half_dur, half_flat, dip, frac

    dip = depth_ppm * 1.0E-6_REAL64
    dt_abs = ABS(phase_hr)
    half_dur = 0.5_REAL64 * dur_hr
    half_flat = half_dur - tau_hr

    IF (dt_abs >= half_dur) THEN
      flux = 1.0_REAL64
    ELSE IF (dt_abs <= half_flat) THEN
      flux = 1.0_REAL64 - dip
    ELSE
      frac = (half_dur - dt_abs) / tau_hr
      flux = 1.0_REAL64 - dip * (frac * frac * (3.0_REAL64 - 2.0_REAL64 * frac))
    END IF
  END FUNCTION box_limb_transit_flux

END MODULE exoplanet_lc_f2023_mod

!> @brief Main Fortran 2023 exoplanet transit DataFrame pipeline program.
PROGRAM fortran2023_exoplanet_df
  USE fortran_orm
  USE exoplanet_lc_f2023_mod
  IMPLICIT NONE (TYPE, EXTERNAL)

  INTEGER(INT32), PARAMETER :: NCAD = 21_INT32
  TYPE(orm_db_t) :: db
  TYPE(orm_dataframe_f2023_t) :: lc_df, dip_df, reload_df
  REAL(REAL64), DIMENSION(NCAD) :: phase_hr, norm_flux, dip_ppm, snr_col
  CHARACTER(LEN=16), DIMENSION(4) :: schema_cols
  CHARACTER(LEN=:), ALLOCATABLE :: json_payload, r_raw, r_planet_rearth
  REAL(REAL64) :: mu_flux, var_flux, min_flux, max_flux
  INTEGER(INT32) :: k, rc, nrows

  DO k = 1_INT32, NCAD
    phase_hr(k) = -2.5_REAL64 + 0.25_REAL64 * REAL(k - 1_INT32, REAL64)
  END DO
  norm_flux = box_limb_transit_flux(phase_hr, 8400.0_REAL64, 3.0_REAL64, &
                                    0.5_REAL64)
  dip_ppm = (1.0_REAL64 - norm_flux) * 1.0E6_REAL64
  snr_col = dip_ppm / 120.0_REAL64

  rc = corm_f2023_open(db, ":memory:", ASIS=.FALSE.)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 1. Populate 4-column scientific photometry DataFrame
  rc = lc_df%init(NCAD, 4_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = lc_df%set_col_name(1_INT32, "phase_hr")
  rc = lc_df%set_col_name(2_INT32, "norm_flux")
  rc = lc_df%set_col_name(3_INT32, "dip_ppm")
  rc = lc_df%set_col_name(4_INT32, "det_snr")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = lc_df%set_col(1_INT32, phase_hr)
  rc = lc_df%set_col(2_INT32, norm_flux)
  rc = lc_df%set_col(3_INT32, dip_ppm)
  rc = lc_df%set_col(4_INT32, snr_col)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 2. Evaluate photometry statistics & isolate >= 5-sigma transit cadences
  rc = lc_df%col_mean(2_INT32, mu_flux)
  rc = lc_df%col_variance(2_INT32, var_flux)
  rc = lc_df%col_min_max(2_INT32, min_flux, max_flux)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  IF (ABS(min_flux - 0.9916_REAL64) > 1.0E-10_REAL64) ERROR STOP 1
  IF (ABS(max_flux - 1.0_REAL64) > 1.0E-10_REAL64 .OR. var_flux <= 0.0_REAL64) THEN
    ERROR STOP 1
  END IF

  rc = lc_df%filter_gt(4_INT32, 5.0_REAL64, dip_df)
  IF (rc /= FORTRAN_ORM_OK .OR. dip_df%n_rows < 9_INT32) ERROR STOP 1

  ! 3. Persist both DataFrames to SQLite via `F_C_STRING` & export JSON
  rc = lc_df%save_sql(db, "kepler_lc")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = dip_df%save_sql(db, "kepler_in_transit")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  schema_cols = ["phase_hr        ", "norm_flux       ", &
                 "dip_ppm         ", "det_snr         "]
  rc = reload_df%load_sql(db, "kepler_lc", NCAD, schema_cols, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= NCAD) ERROR STOP 1
  IF (MAXVAL(ABS(reload_df%data - lc_df%data)) > 1.0E-12_REAL64) ERROR STOP 1

  rc = dip_df%to_json_sql(db, "kepler_in_transit", json_payload)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_payload, "det_snr") == 0) THEN
    ERROR STOP 1
  END IF

  ! 4. Exact 38-digit decimal planetary radius `Rp = (Rp/R*) * R* * 109.076 R_earth`
  rc = corm_f2023_dec_mul_str("0.0916515139", "109.076000", 6_INT32, &
                              FORTRAN_ORM_ROUND_HALF_EVEN, r_raw)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_rescale_str(r_raw, 18_INT32, 3_INT32, &
                                  FORTRAN_ORM_ROUND_HALF_EVEN, r_planet_rearth)
  IF (rc /= FORTRAN_ORM_OK .OR. r_planet_rearth /= "9.997") ERROR STOP 1

  rc = reload_df%free()
  rc = dip_df%free()
  rc = lc_df%free()
  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,I3,2X,A,F10.6)', "EXOPLANET DF F2023 OK: hits=", &
    nrows, r_planet_rearth, mu_flux
END PROGRAM fortran2023_exoplanet_df
