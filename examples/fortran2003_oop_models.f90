!> @file fortran2003_oop_models.f90
!> @brief ISO Fortran 2003 OOP RAII & BIND(C) model CRUD example.
PROGRAM fortran2003_oop_models
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  IMPLICIT NONE

  !> @type experiment_t
  !> @brief BIND(C) scientific experiment metadata record.
  TYPE, BIND(C) :: experiment_t
    INTEGER(C_INT32_T) :: exp_id
    INTEGER(C_INT32_T) :: pad
    REAL(C_DOUBLE) :: energy_mev
    CHARACTER(KIND=C_CHAR) :: facility(16)
  END TYPE experiment_t

  TYPE(orm_db_t) :: db
  TYPE(orm_schema_t) :: schema
  TYPE(orm_rs_t) :: rs
  TYPE(experiment_t), TARGET :: exp_in, exp_out
  CHARACTER(LEN=:), ALLOCATABLE :: json_doc
  INTEGER(C_INT) :: rc
  INTEGER(C_INT32_T) :: k

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = schema%create("experiments", 32_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("exp_id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, &
                      0_C_INT32_T, .TRUE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("energy_mev", FORTRAN_ORM_COL_FLOAT64, 8_C_INT32_T, &
                      0_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%add_col("facility", FORTRAN_ORM_COL_CHAR_FIXED, 16_C_INT32_T, &
                      16_C_INT32_T, .FALSE., .FALSE.)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = schema%create_table(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  exp_in%exp_id = 7_C_INT32_T
  exp_in%pad = 0_C_INT32_T
  exp_in%energy_mev = 13600.0_C_DOUBLE
  exp_in%facility = " "
  DO k = 1_C_INT32_T, 4_C_INT32_T
    exp_in%facility(k) = "CERN"(k:k)
  END DO
  rc = schema%insert_ptr(db, C_LOC(exp_in))
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  rc = schema%find_i32_ptr(db, 7_C_INT32_T, C_LOC(exp_out))
  IF (rc /= FORTRAN_ORM_OK .OR. exp_out%exp_id /= 7_C_INT32_T) STOP 1

  rc = rs%query(db, "SELECT exp_id, energy_mev, facility FROM experiments")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%to_json(json_doc)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_doc, "CERN") == 0) STOP 1

  PRINT '(A)', json_doc
END PROGRAM fortran2003_oop_models
