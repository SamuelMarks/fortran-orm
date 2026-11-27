!> @file fortran2003_spectroscopy_crud.f90
!> @brief ISO Fortran 2003 HITRAN-style molecular absorption line catalog
!> exercising upsert, optimistic locking, bulk array hydration, and delete.
PROGRAM fortran2003_spectroscopy_crud
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_c, ONLY : fortran_orm_crud_upsert, &
                            fortran_orm_crud_update_optimistic_str, &
                            fortran_orm_crud_exists_i32, &
                            fortran_orm_crud_find_all, &
                            fortran_orm_crud_delete_i32
  USE fortran_orm_f2003
  IMPLICIT NONE

  !> @type spectral_line_t
  !> @brief 32-byte BIND(C) rovibrational molecular absorption transition.
  TYPE, BIND(C) :: spectral_line_t
    INTEGER(C_INT32_T) :: line_id
    INTEGER(C_INT32_T) :: rev_no
    REAL(C_DOUBLE) :: wavenumber_cm1
    REAL(C_DOUBLE) :: line_strength
    CHARACTER(KIND=C_CHAR) :: molecule(8)
  END TYPE spectral_line_t

  TYPE(orm_db_t) :: db
  TYPE(orm_schema_t) :: schema
  TYPE(spectral_line_t), TARGET :: rec_co2, rec_h2o, rec_ch4, rec_fetched
  TYPE(spectral_line_t), DIMENSION(4), TARGET :: catalog
  INTEGER(C_INT) :: rc
  INTEGER(C_INT32_T) :: exists_flag, n_all

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = schema%create("hitran_lines", 32_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("line_id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, &
                      0_C_INT32_T, .TRUE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("rev_no", FORTRAN_ORM_COL_INT32, 4_C_INT32_T, &
                      0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("wavenumber_cm1", FORTRAN_ORM_COL_FLOAT64, 8_C_INT32_T, &
                      0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("line_strength", FORTRAN_ORM_COL_FLOAT64, 16_C_INT32_T, &
                      0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("molecule", FORTRAN_ORM_COL_CHAR_FIXED, 24_C_INT32_T, &
                      8_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%create_table(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rec_co2%line_id = 1001_C_INT32_T
  rec_co2%rev_no = 1_C_INT32_T
  rec_co2%wavenumber_cm1 = 2349.143_C_DOUBLE
  rec_co2%line_strength = 3.52D-18
  CALL set_mol_tag(rec_co2%molecule, "CO2")
  rc = schema%insert_ptr(db, C_LOC(rec_co2))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rec_h2o%line_id = 1002_C_INT32_T
  rec_h2o%rev_no = 1_C_INT32_T
  rec_h2o%wavenumber_cm1 = 1594.750_C_DOUBLE
  rec_h2o%line_strength = 1.18D-19
  CALL set_mol_tag(rec_h2o%molecule, "H2O")
  rc = schema%insert_ptr(db, C_LOC(rec_h2o))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! Atomic dialect-aware UPSERT (inserts CH4, then updates CH4 strength in place)
  rec_ch4%line_id = 1003_C_INT32_T
  rec_ch4%rev_no = 1_C_INT32_T
  rec_ch4%wavenumber_cm1 = 3018.920_C_DOUBLE
  rec_ch4%line_strength = 8.90D-20
  CALL set_mol_tag(rec_ch4%molecule, "CH4")
  rc = fortran_orm_crud_upsert(db%ptr, schema%ptr, C_LOC(rec_ch4))
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rec_ch4%line_strength = 9.15D-20
  rc = fortran_orm_crud_upsert(db%ptr, schema%ptr, C_LOC(rec_ch4))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! Optimistic concurrency control on CO2 recalibration (`rev_no` 1 -> 2)
  rec_co2%rev_no = 2_C_INT32_T
  rec_co2%wavenumber_cm1 = 2349.146_C_DOUBLE
  rc = fortran_orm_crud_update_optimistic_str(db%ptr, schema%ptr, "rev_no", &
                                              6_C_INT32_T, C_LOC(rec_co2))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! Stale optimistic update repeating rev_no == 2 (expects DB 1, actual 2) fails
  rc = fortran_orm_crud_update_optimistic_str(db%ptr, schema%ptr, "rev_no", &
                                              6_C_INT32_T, C_LOC(rec_co2))
  IF (rc == FORTRAN_ORM_OK) STOP 1

  rc = schema%find_i32_ptr(db, 1001_C_INT32_T, C_LOC(rec_fetched))
  IF (rc /= FORTRAN_ORM_OK .OR. rec_fetched%rev_no /= 2_C_INT32_T) STOP 1
  IF (ABS(rec_fetched%wavenumber_cm1 - 2349.146_C_DOUBLE) > 1.0D-9) STOP 1

  ! Bulk hydrate all 3 transitions into contiguous BIND(C) derived-type array
  rc = fortran_orm_crud_find_all(db%ptr, schema%ptr, C_LOC(catalog(1)), &
                                 4_C_INT32_T, n_all)
  IF (rc /= FORTRAN_ORM_OK .OR. n_all /= 3_C_INT32_T) STOP 1

  ! Delete H2O line and verify existence check transitions to 0
  rc = fortran_orm_crud_exists_i32(db%ptr, schema%ptr, 1002_C_INT32_T, &
                                   exists_flag)
  IF (rc /= FORTRAN_ORM_OK .OR. exists_flag /= 1_C_INT32_T) STOP 1
  rc = fortran_orm_crud_delete_i32(db%ptr, schema%ptr, 1002_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = fortran_orm_crud_exists_i32(db%ptr, schema%ptr, 1002_C_INT32_T, &
                                   exists_flag)
  IF (rc /= FORTRAN_ORM_OK .OR. exists_flag /= 0_C_INT32_T) STOP 1

  PRINT '(A,F9.3,A,I2)', "CO2 nu = ", rec_fetched%wavenumber_cm1, &
        " rev = ", rec_fetched%rev_no

CONTAINS

  !> @brief Copies a Fortran string into a blank-padded 8-byte `C_CHAR` array.
  !> @param[out] buf Fixed 8-character `BIND(C)` field.
  !> @param[in] name Source chemical formula tag.
  SUBROUTINE set_mol_tag(buf, name)
    CHARACTER(KIND=C_CHAR), DIMENSION(8), INTENT(OUT) :: buf
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER :: idx, lim
    buf = " "
    lim = MIN(LEN_TRIM(name), 7)
    DO idx = 1, lim
      buf(idx) = name(idx:idx)
    END DO
  END SUBROUTINE set_mol_tag

END PROGRAM fortran2003_spectroscopy_crud
