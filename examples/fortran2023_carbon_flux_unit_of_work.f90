!> @file fortran2023_carbon_flux_unit_of_work.f90
!> @brief ISO/IEC 1539-1:2023 Fortran 2023 eddy-covariance biosphere Net
!> Ecosystem Exchange (NEE) & 38-digit carbon-credit Unit-of-Work ledger.
!>
!> Showcases `fortran_orm` / `fortran_orm_f2023`:
!> - `orm_session_f2023_t` nested Unit-of-Work transactions (`begin_uow`,
!>   `commit_uow`, `rollback_uow`, `telemetry`) rejecting rain-contaminated
!>   sonic-anemometer bursts via savepoint rollback
!> - Full 38-digit decimal accounting (`corm_f2023_dec_add_str`, `sub_str`,
!>   `mul_str`, `div_str`, `cmp_str`, `rescale_str`)
MODULE carbon_nee_f2023_mod
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : REAL64
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE
  PUBLIC :: lloyd_taylor_reco, rectangular_hyperbola_gpp

CONTAINS

  !> @brief Lloyd-Taylor ecosystem respiration `R_eco(T)` (umol CO2 m^-2 s^-1).
  !> @param[in] t_soil_k Soil temperature at 5 cm depth in Kelvin.
  !> @param[in] r_ref Base respiration at `T_ref = 283.15 K`.
  !> @return Ecosystem respiration flux `R_eco >= 0`.
  ELEMENTAL FUNCTION lloyd_taylor_reco(t_soil_k, r_ref) RESULT(r_eco)
    REAL(REAL64), INTENT(IN) :: t_soil_k, r_ref
    REAL(REAL64) :: r_eco
    REAL(REAL64), PARAMETER :: E0_K = 308.56_REAL64
    REAL(REAL64), PARAMETER :: T0_K = 227.13_REAL64
    REAL(REAL64), PARAMETER :: INV_REF = 1.0_REAL64 / (283.15_REAL64 - T0_K)
    r_eco = r_ref * EXP(E0_K * (INV_REF - 1.0_REAL64 / (t_soil_k - T0_K)))
  END FUNCTION lloyd_taylor_reco

  !> @brief Michaelis-Menten canopy Gross Primary Productivity `GPP(PPFD)`.
  !> @param[in] ppfd Photosynthetic photon flux density (umol photons m^-2 s^-1).
  !> @param[in] alpha_qe Apparent quantum yield.
  !> @param[in] gpp_max Canopy light-saturated assimilation capacity.
  !> @return Gross primary carbon uptake `GPP >= 0` (umol CO2 m^-2 s^-1).
  ELEMENTAL FUNCTION rectangular_hyperbola_gpp(ppfd, alpha_qe, gpp_max) &
      RESULT(gpp)
    REAL(REAL64), INTENT(IN) :: ppfd, alpha_qe, gpp_max
    REAL(REAL64) :: gpp
    IF (ppfd <= 0.0_REAL64) THEN
      gpp = 0.0_REAL64
    ELSE
      gpp = (alpha_qe * ppfd * gpp_max) / (alpha_qe * ppfd + gpp_max)
    END IF
  END FUNCTION rectangular_hyperbola_gpp

END MODULE carbon_nee_f2023_mod

!> @brief Main Fortran 2023 eddy-covariance carbon-flux Unit-of-Work program.
PROGRAM fortran2023_carbon_uow
  USE fortran_orm
  USE carbon_nee_f2023_mod
  IMPLICIT NONE (TYPE, EXTERNAL)

  INTEGER(INT32), PARAMETER :: NHALFHR = 8_INT32
  TYPE(orm_session_f2023_t) :: sess
  TYPE(orm_stmt_t) :: stmt
  TYPE(fortran_orm_pool_stats) :: stats
  REAL(REAL64), DIMENSION(NHALFHR) :: ppfd, t_soil_k, ustar, reco, gpp, nee
  CHARACTER(LEN=:), ALLOCATABLE :: acc_tco2, acc_next, fee_tco2, net_tco2
  CHARACTER(LEN=:), ALLOCATABLE :: price_usd, payout_raw, payout_usd, slot_str
  CHARACTER(LEN=32) :: dec_buf
  REAL(REAL64) :: sink_tco2_ha
  INTEGER(INT32) :: k, n_valid, cmp_flag, rc
  LOGICAL :: has_row

  ppfd = [0.0_REAL64, 180.0_REAL64, 650.0_REAL64, 1250.0_REAL64, &
          1550.0_REAL64, 1100.0_REAL64, 420.0_REAL64, 0.0_REAL64]
  t_soil_k = [284.0_REAL64, 285.5_REAL64, 288.0_REAL64, 291.5_REAL64, &
              293.0_REAL64, 292.0_REAL64, 289.5_REAL64, 286.0_REAL64]
  ! Period 6 has low friction velocity u* = 0.04 m/s (turbulence QC failure!)
  ustar = [0.28_REAL64, 0.34_REAL64, 0.45_REAL64, 0.52_REAL64, &
           0.49_REAL64, 0.04_REAL64, 0.36_REAL64, 0.25_REAL64]

  reco = lloyd_taylor_reco(t_soil_k, 2.4_REAL64)
  gpp = rectangular_hyperbola_gpp(ppfd, 0.055_REAL64, 28.0_REAL64)
  ! Micrometeorological convention: NEE < 0 indicates net biosphere carbon sink
  nee = reco - gpp

  rc = sess%open(":memory:", 8_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%exec( &
    "CREATE TABLE eddy_flux(slot INT PRIMARY KEY, nee REAL, sink_tco2 TEXT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! Outer Unit-of-Work for the daily tower QA/QC batch
  rc = sess%begin_uow("daily_batch")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  acc_tco2 = "0.000000"
  DO k = 1_INT32, NHALFHR
    rc = sess%begin_uow("slot_sp")
    IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

    ! Convert half-hour net uptake (-NEE) across 500 ha forest to metric tCO2
    sink_tco2_ha = MAX(-nee(k), 0.0_REAL64) * 1800.0_REAL64 * &
                   44.0095E-6_REAL64 * 0.01_REAL64 * 500.0_REAL64
    WRITE (dec_buf, '(F16.6)') sink_tco2_ha
    slot_str = TRIM(ADJUSTL(dec_buf))

    rc = stmt%prepare_cached(sess%db, "INSERT INTO eddy_flux VALUES(?,?,?)")
    rc = stmt%bind(1_INT32, k)
    rc = stmt%bind(2_INT32, nee(k))
    rc = stmt%bind(3_INT32, slot_str)
    rc = stmt%step(has_row)
    rc = stmt%close()
    IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

    IF (ustar(k) < 0.15_REAL64) THEN
      ! Reject low-turbulence slot 6 via nested savepoint rollback!
      rc = sess%rollback_uow("slot_sp")
      IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
    ELSE
      rc = sess%commit_uow("slot_sp")
      IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
      rc = corm_f2023_dec_add_str(acc_tco2, slot_str, acc_next)
      IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
      acc_tco2 = acc_next
    END IF
  END DO

  rc = sess%commit_uow("daily_batch")
  IF (rc /= FORTRAN_ORM_OK .OR. sess%tx_depth /= 0_INT32) ERROR STOP 1

  ! Verify 7 QC-passed half-hour intervals persisted (slot 6 rolled back)
  rc = stmt%prepare(sess%db, "SELECT COUNT(*) FROM eddy_flux")
  rc = stmt%step(has_row)
  rc = stmt%col(1_INT32, n_valid)
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK .OR. n_valid /= 7_INT32) ERROR STOP 1

  ! Exact 38-digit buffer-pool deduction (12.5%) & registry valuation ($36.40/t)
  rc = corm_f2023_dec_div_str(acc_tco2, "8.0", 6_INT32, &
                              FORTRAN_ORM_ROUND_HALF_EVEN, fee_tco2)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_sub_str(acc_tco2, fee_tco2, net_tco2)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  price_usd = "36.40"
  rc = corm_f2023_dec_mul_str(net_tco2, price_usd, 4_INT32, &
                              FORTRAN_ORM_ROUND_HALF_EVEN, payout_raw)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_rescale_str(payout_raw, 24_INT32, 2_INT32, &
                                  FORTRAN_ORM_ROUND_HALF_EVEN, payout_usd)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_cmp_str(payout_usd, "100.00", cmp_flag)
  IF (rc /= FORTRAN_ORM_OK .OR. cmp_flag <= 0_INT32) ERROR STOP 1

  rc = sess%telemetry(stats)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,I2,2X,A,2X,A)', "CARBON UOW F2023 OK: qc_rows=", &
    n_valid, net_tco2, payout_usd
END PROGRAM fortran2023_carbon_uow
