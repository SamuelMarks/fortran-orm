!> @file fortran2023_isotope_decay_ledger.f90
!> @brief ISO Fortran 2023 F_C_STRING, exact 38-digit radioisotope mass-balance
!> decimal accounting, UTF-16 GRAPHIC transcoding, and UUID v4 audit example.
PROGRAM fortran2023_isotope_decay_ledger
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT16_T, C_INT32_T, C_CHAR, C_LOC
  USE fortran_orm
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  TYPE(orm_stmt_t) :: stmt
  TYPE(orm_rs_t) :: rs
  TYPE(fortran_orm_decimal) :: initial_g, two_dec, rem_g, daughter_g, db_rem
  INTEGER(C_INT16_T), DIMENSION(32), TARGET :: graphic_be
  CHARACTER(LEN=32, KIND=C_CHAR) :: decoded_vial, rem_buf, dau_buf
  CHARACTER(LEN=:), ALLOCATABLE :: batch_uuid, recon_sum, json_audit
  CHARACTER(LEN=*), PARAMETER :: VIAL_TAG = "CO60-GAMMA-LAB"
  LOGICAL :: has_row
  INTEGER(C_INT32_T) :: rc, u16_units, utf8_len, rem_len, dau_len, cmp_res

  ! 1. Generate RFC 4122 UUID v4 provenance ID and transcode vial tag via UTF-16BE
  rc = corm_f2003_uuid_v4(batch_uuid)
  IF (rc /= FORTRAN_ORM_OK .OR. LEN(batch_uuid) /= 36) ERROR STOP 1

  graphic_be = 0_C_INT16_T
  rc = fortran_orm_utf8_to_utf16_str(VIAL_TAG, &
       INT(LEN(VIAL_TAG), C_INT32_T), 1_C_INT32_T, C_LOC(graphic_be(1)), &
       32_C_INT32_T, u16_units)
  IF (rc /= FORTRAN_ORM_OK .OR. u16_units /= INT(LEN(VIAL_TAG), C_INT32_T)) &
    ERROR STOP 1

  decoded_vial = " "
  rc = fortran_orm_utf16_to_utf8(C_LOC(graphic_be(1)), u16_units, &
       1_C_INT32_T, decoded_vial, 32_C_INT32_T, utf8_len)
  IF (rc /= FORTRAN_ORM_OK .OR. decoded_vial(1:utf8_len) /= VIAL_TAG) &
    ERROR STOP 1

  ! 2. Exact 38-digit decimal mass conservation across 3 half-lives (M0 / 8)
  rc = fortran_orm_dec_from_str_str("24.000000000000000000", 21_C_INT32_T, &
                                    initial_g)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_from_str_str("8", 1_C_INT32_T, two_dec)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_div(initial_g, two_dec, 18_C_INT32_T, &
                           FORTRAN_ORM_ROUND_HALF_EVEN, rem_g)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_sub(initial_g, rem_g, daughter_g)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rem_buf = " "
  dau_buf = " "
  rc = fortran_orm_dec_to_str(rem_g, rem_buf, 32_C_INT32_T, rem_len)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_to_str(daughter_g, dau_buf, 32_C_INT32_T, dau_len)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2023_dec_add_str(rem_buf(1:rem_len), dau_buf(1:dau_len), &
                              recon_sum)
  IF (rc /= FORTRAN_ORM_OK .OR. recon_sum /= "24.000000000000000000") &
    ERROR STOP 1

  ! 3. Open & execute DDL using Fortran 2023 F_C_STRING(..., ASIS=...)
  rc = corm_f2023_open(db, ":memory:   ", asis=.FALSE.)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_exec(db, &
       "CREATE TABLE isotope_vault(uuid TEXT, vial TEXT, rem_g TEXT, dau_g TEXT)", &
       asis=.TRUE.)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = stmt%prepare(db, "INSERT INTO isotope_vault VALUES(?,?,?,?)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%bind_str(1_C_INT32_T, batch_uuid)
  IF (rc == FORTRAN_ORM_OK) rc = stmt%bind_str(2_C_INT32_T, &
                                               decoded_vial(1:utf8_len))
  IF (rc == FORTRAN_ORM_OK) rc = fortran_orm_stmt_bind_decimal(stmt%ptr, &
                                               3_C_INT32_T, rem_g)
  IF (rc == FORTRAN_ORM_OK) rc = fortran_orm_stmt_bind_decimal(stmt%ptr, &
                                               4_C_INT32_T, daughter_g)
  IF (rc == FORTRAN_ORM_OK) rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = stmt%prepare(db, "SELECT rem_g FROM isotope_vault")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) ERROR STOP 1
  rc = fortran_orm_stmt_col_decimal(stmt%ptr, 1_C_INT32_T, db_rem)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_cmp(db_rem, rem_g, cmp_res)
  IF (rc /= FORTRAN_ORM_OK .OR. cmp_res /= 0_C_INT32_T) ERROR STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = rs%query(db, "SELECT uuid, vial, rem_g, dau_g FROM isotope_vault")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = rs%to_json(json_audit)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_audit, VIAL_TAG) == 0) ERROR STOP 1

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,1X,A)', decoded_vial(1:utf8_len), recon_sum
END PROGRAM fortran2023_isotope_decay_ledger
