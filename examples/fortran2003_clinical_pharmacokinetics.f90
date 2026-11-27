!> @file fortran2003_clinical_pharmacokinetics.f90
!> @brief ISO/IEC 1539-1:2004 Fortran 2003 two-compartment IV pharmacokinetic
!> clinical trial ledger with sharding, 38-digit decimals, OAuth2, & EBCDIC.
!>
!> Showcases `fortran_orm_f2003` and `fortran_orm_f2003_ext`:
!> - `orm_shard_router_t` routing patient cohorts across shard nodes
!> - `orm_decimal_t` exact 38-digit milligram dosing & AUC accounting
!> - `orm_oauth2_store_t` clinician bearer-token scope enforcement
!> - `corm_f2003_utf8_to_ebcdic` / `utf8_to_utf16` regulatory archive codecs
MODULE pk_two_comp_f2003_mod
  USE, INTRINSIC :: ISO_C_BINDING
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: biexp_plasma_conc, trapezoidal_auc

CONTAINS

  !> @brief Evaluates bi-exponential two-compartment IV bolus plasma
  !> concentration `C(t) = A * exp(-alpha * t) + B * exp(-beta * t)` (mg/L).
  !> @param[in] dose_mg Administered IV bolus dose in mg.
  !> @param[in] v1_l Central compartment volume in Liters.
  !> @param[in] k10 Elimination rate constant (1/hr).
  !> @param[in] k12 Central-to-peripheral rate constant (1/hr).
  !> @param[in] k21 Peripheral-to-central rate constant (1/hr).
  !> @param[in] t_hr Post-infusion time in hours.
  !> @return Plasma drug concentration in mg/L.
  PURE FUNCTION biexp_plasma_conc(dose_mg, v1_l, k10, k12, k21, t_hr) RESULT(cp)
    REAL(C_DOUBLE), INTENT(IN) :: dose_mg, v1_l, k10, k12, k21, t_hr
    REAL(C_DOUBLE) :: cp, sum_k, disc, alpha, beta, c0, a_coef, b_coef
    sum_k = k10 + k12 + k21
    disc = SQRT(sum_k * sum_k - 4.0_C_DOUBLE * k10 * k21)
    alpha = 0.5_C_DOUBLE * (sum_k + disc)
    beta = 0.5_C_DOUBLE * (sum_k - disc)
    c0 = dose_mg / v1_l
    a_coef = c0 * (alpha - k21) / (alpha - beta)
    b_coef = c0 * (k21 - beta) / (alpha - beta)
    cp = a_coef * EXP(-alpha * t_hr) + b_coef * EXP(-beta * t_hr)
  END FUNCTION biexp_plasma_conc

  !> @brief Computes linear-trapezoidal Area Under the Curve `AUC_{0..T}`
  !> (mg*hr/L) across sampling schedule `t_vec` and `c_vec`.
  !> @param[in] t_vec Sampling times in hours.
  !> @param[in] c_vec Measured plasma concentrations in mg/L.
  !> @return Trapezoidal `AUC` in mg*hr/L.
  PURE FUNCTION trapezoidal_auc(t_vec, c_vec) RESULT(auc)
    REAL(C_DOUBLE), DIMENSION(:), INTENT(IN) :: t_vec, c_vec
    REAL(C_DOUBLE) :: auc
    INTEGER :: k, n
    n = SIZE(t_vec, 1)
    auc = 0.0_C_DOUBLE
    DO k = 2, n
      auc = auc + 0.5_C_DOUBLE * (c_vec(k - 1) + c_vec(k)) * &
                  (t_vec(k) - t_vec(k - 1))
    END DO
  END FUNCTION trapezoidal_auc

END MODULE pk_two_comp_f2003_mod

!> @brief Main Fortran 2003 clinical pharmacokinetics enterprise ORM program.
PROGRAM fortran2003_clinical_pk
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  USE fortran_orm_f2003_ext
  USE pk_two_comp_f2003_mod
  IMPLICIT NONE

  INTEGER, PARAMETER :: NSAMP = 7
  TYPE(orm_db_t) :: auth_db, shard1, shard2
  TYPE(orm_shard_router_t) :: router
  TYPE(orm_oauth2_store_t) :: oauth
  TYPE(orm_stmt_t) :: stmt
  TYPE(orm_decimal_t) :: d_vial, d_used, d_rem, d_unit_mg, d_tot_mg
  REAL(C_DOUBLE), DIMENSION(NSAMP) :: t_hr, cp_mgl
  INTEGER(C_INT8_T) :: ebcdic_rec(32)
  INTEGER(C_INT16_T) :: utf16_rec(32)
  CHARACTER(LEN=:), ALLOCATABLE :: uid, scopes, dec_txt, decoded_str
  CHARACTER(LEN=16), DIMENSION(4) :: subj_ids
  REAL(C_DOUBLE) :: dose_mg, auc_val, auc_read
  INTEGER(C_INT) :: rc
  INTEGER(C_INT32_T) :: k, s, target_shard, exp_sec, n_eb, n_u16
  LOGICAL :: scope_ok, has_row

  t_hr = (/ 0.0_C_DOUBLE, 0.5_C_DOUBLE, 1.0_C_DOUBLE, 2.0_C_DOUBLE, &
            4.0_C_DOUBLE, 8.0_C_DOUBLE, 12.0_C_DOUBLE /)
  subj_ids(1) = "SUBJ_BOS_101"
  subj_ids(2) = "SUBJ_ZUR_202"
  subj_ids(3) = "SUBJ_TOK_303"
  subj_ids(4) = "SUBJ_LON_404"

  ! 1. Clinician OAuth2 token validation before trial write access
  rc = auth_db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = oauth%init_tables(auth_db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = oauth%save("clin_bearer_99", "clin_ref_99", "pi_pharmacol", &
                  "pk:read pk:dose pk:export", 7200_C_INT32_T, &
                  4102444800_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = oauth%fetch("clin_bearer_99", uid, scopes, exp_sec)
  IF (rc /= FORTRAN_ORM_OK .OR. uid /= "pi_pharmacol") STOP 1
  rc = oauth%check_scopes(scopes, "pk:dose pk:export", scope_ok)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. scope_ok) STOP 1

  ! 2. Exact 38-digit pharmacy vial inventory reconciliation (`orm_decimal_t`)
  rc = d_vial%from_str("2500.0000")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d_unit_mg%from_str("175.2500")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d_used%from_i64(4_C_INT64_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d_unit_mg%mul(d_used, 4_C_INT32_T, FORTRAN_ORM_ROUND_HALF_EVEN, &
                     d_tot_mg)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d_vial%sub(d_tot_mg, d_rem)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = d_rem%to_str(dec_txt)
  IF (rc /= FORTRAN_ORM_OK .OR. dec_txt /= "1799.0000") STOP 1

  ! 3. Horizontal 2-shard clinical subject router
  rc = shard1%open(":memory:")
  rc = shard2%open(":memory:")
  rc = shard1%exec("CREATE TABLE pk_auc(subj TEXT PRIMARY KEY, auc REAL, rem_mg TEXT)")
  rc = shard2%exec("CREATE TABLE pk_auc(subj TEXT PRIMARY KEY, auc REAL, rem_mg TEXT)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = router%init(2_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = router%add_node(1_C_INT32_T, shard1)
  rc = router%add_node(2_C_INT32_T, shard2)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  dose_mg = 175.25_C_DOUBLE
  DO s = 1_C_INT32_T, 4_C_INT32_T
    DO k = 1_C_INT32_T, NSAMP
      cp_mgl(k) = biexp_plasma_conc(dose_mg, 12.0_C_DOUBLE + DBLE(s), &
                                    0.22_C_DOUBLE, 0.45_C_DOUBLE, &
                                    0.30_C_DOUBLE, t_hr(k))
    END DO
    auc_val = trapezoidal_auc(t_hr, cp_mgl)
    rc = router%route(TRIM(subj_ids(s)), target_shard)
    IF (rc /= FORTRAN_ORM_OK) STOP 1
    IF (target_shard == 1_C_INT32_T) THEN
      rc = stmt%prepare(shard1, "INSERT INTO pk_auc VALUES(?,?,?)")
    ELSE
      rc = stmt%prepare(shard2, "INSERT INTO pk_auc VALUES(?,?,?)")
    END IF
    IF (rc /= FORTRAN_ORM_OK) STOP 1
    rc = stmt%bind(1_C_INT32_T, TRIM(subj_ids(s)))
    rc = stmt%bind(2_C_INT32_T, auc_val)
    rc = stmt%bind(3_C_INT32_T, d_rem%pod)
    rc = stmt%step(has_row)
    rc = stmt%close()
    IF (rc /= FORTRAN_ORM_OK) STOP 1
  END DO

  ! Verify deterministic shard lookup for SUBJ_BOS_101
  rc = router%route(TRIM(subj_ids(1)), target_shard)
  IF (target_shard == 1_C_INT32_T) THEN
    rc = stmt%prepare(shard1, "SELECT auc FROM pk_auc WHERE subj = ?")
  ELSE
    rc = stmt%prepare(shard2, "SELECT auc FROM pk_auc WHERE subj = ?")
  END IF
  rc = stmt%bind(1_C_INT32_T, TRIM(subj_ids(1)))
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) STOP 1
  rc = stmt%col(1_C_INT32_T, auc_read)
  rc = stmt%close()
  IF (auc_read <= 20.0_C_DOUBLE) STOP 1

  ! 4. Mainframe z/OS IBM-1047 EBCDIC & UTF-16 `GRAPHIC` regulatory round-trip
  rc = corm_f2003_utf8_to_ebcdic(FORTRAN_ORM_CP_IBM1047, "NDA_2003_PASS", &
                                 ebcdic_rec, n_eb)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = corm_f2003_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM1047, ebcdic_rec, n_eb, &
                                 decoded_str)
  IF (rc /= FORTRAN_ORM_OK .OR. decoded_str /= "NDA_2003_PASS") STOP 1

  rc = corm_f2003_utf8_to_utf16("CDISC_SDTM", .FALSE., utf16_rec, n_u16)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = corm_f2003_utf16_to_utf8(utf16_rec, n_u16, .FALSE., decoded_str)
  IF (rc /= FORTRAN_ORM_OK .OR. decoded_str /= "CDISC_SDTM") STOP 1

  rc = router%free()
  rc = shard1%close()
  rc = shard2%close()
  rc = auth_db%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  PRINT '(A,F10.3,2X,A)', "PK TRIAL F2003 OK: auc1=", auc_read, dec_txt
END PROGRAM fortran2003_clinical_pk
