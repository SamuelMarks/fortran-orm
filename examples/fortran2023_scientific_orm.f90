!> @file fortran2023_scientific_orm.f90
!> @brief ISO Fortran 2023 F_C_STRING, assumed-rank strided slices, and
!> 38-digit decimal ORM example.
PROGRAM fortran2023_scientific_orm
  USE fortran_orm
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  REAL(REAL64), DIMENSION(6, 2) :: samples, sub_samples
  CHARACTER(LEN=:), ALLOCATABLE :: dec_total, run_uuid
  INTEGER(INT32) :: rc, nrows, i

  rc = corm_f2003_uuid_v4(run_uuid)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2023_open(db, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_exec(db, "CREATE TABLE observations(t REAL, flux REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  DO i = 1, 6
    samples(i, 1) = REAL(i, REAL64) * 0.5_REAL64
    samples(i, 2) = REAL(i * i, REAL64) * 1.25_REAL64
  END DO

  ! Persist odd-indexed strided slice directly via CFI_cdesc_t!
  rc = corm_f2018_insert_any_rank(db, &
       "INSERT INTO observations VALUES(?,?)", samples(1:6:2, :))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  sub_samples = 0.0_REAL64
  rc = corm_f2018_query_any_rank(db, &
       "SELECT t, flux FROM observations", sub_samples(1:3, :), nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 3_INT32) ERROR STOP 1

  rc = corm_f2023_dec_add_str("999999999999999999999999999999.50", &
                              "0.50", dec_total)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,1X,A)', run_uuid, dec_total
END PROGRAM fortran2023_scientific_orm
