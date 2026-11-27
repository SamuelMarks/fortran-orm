!> @file fortran2018_cfi_strided_stencil.f90
!> @brief ISO Fortran 2018 CFI_cdesc_t strided subarray & CHARACTER(LEN=*)
!> descriptor persistence example.
PROGRAM fortran2018_cfi_strided_stencil
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT, C_INT32_T
  USE fortran_orm_f2018
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  TYPE(orm_stmt_t) :: stmt
  INTEGER(INT32), DIMENSION(8) :: sensor_ids, restored_ids
  REAL(REAL64), DIMENSION(7, 4) :: full_stencil, restored_stencil
  CHARACTER(LEN=32) :: grid_label
  LOGICAL :: has_row
  INTEGER(C_INT) :: rc
  INTEGER(INT32) :: r, c, n_ids, n_sub
  INTEGER(C_INT32_T) :: lbl_len

  rc = corm_f2018_open(db, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2018_exec(db, "CREATE TABLE active_sensors(sid INTEGER)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "CREATE TABLE coarse_nodes(u REAL, v REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "CREATE TABLE meta(label TEXT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "INSERT INTO meta VALUES('CFI_STENCIL_V1')")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  sensor_ids = [101_INT32, 202_INT32, 303_INT32, 404_INT32, &
                505_INT32, 606_INT32, 707_INT32, 808_INT32]
  DO c = 1_INT32, 4_INT32
    DO r = 1_INT32, 7_INT32
      full_stencil(r, c) = REAL(r * 10_INT32 + c, REAL64) * 0.5_REAL64
    END DO
  END DO

  ! Persist non-contiguous stride-2 slices directly via ISO_Fortran_binding.h!
  rc = corm_f2018_insert_any_rank(db, &
       "INSERT INTO active_sensors VALUES(?)", sensor_ids(2:8:2))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2018_insert_any_rank(db, &
       "INSERT INTO coarse_nodes VALUES(?,?)", full_stencil(2:6:2, 1:3:2))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  restored_ids = 0_INT32
  rc = corm_f2018_query_any_rank(db, &
       "SELECT sid FROM active_sensors", restored_ids(2:8:2), n_ids)
  IF (rc /= FORTRAN_ORM_OK .OR. n_ids /= 4_INT32) ERROR STOP 1
  IF (ANY(restored_ids(2:8:2) /= sensor_ids(2:8:2))) ERROR STOP 1

  restored_stencil = 0.0_REAL64
  rc = corm_f2018_query_any_rank(db, &
       "SELECT u, v FROM coarse_nodes", restored_stencil(2:6:2, 1:3:2), n_sub)
  IF (rc /= FORTRAN_ORM_OK .OR. n_sub /= 3_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(restored_stencil(2:6:2, 1:3:2) - &
                 full_stencil(2:6:2, 1:3:2))) > 1.0E-12_REAL64) ERROR STOP 1

  ! Read column directly into CHARACTER(LEN=*) descriptor via CFI_cdesc_t
  rc = stmt%prepare(db, "SELECT label FROM meta")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) ERROR STOP 1
  rc = fortran_orm_cfi_col_str(stmt%ptr, 1_C_INT32_T, grid_label, lbl_len)
  IF (rc /= FORTRAN_ORM_OK .OR. grid_label(1:lbl_len) /= "CFI_STENCIL_V1") &
    ERROR STOP 1

  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,1X,I2)', grid_label(1:lbl_len), n_sub
END PROGRAM fortran2018_cfi_strided_stencil
