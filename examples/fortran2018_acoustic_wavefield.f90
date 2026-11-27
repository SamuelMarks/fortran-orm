!> @file fortran2018_acoustic_wavefield.f90
!> @brief ISO Fortran 2018 CFI_cdesc_t 2D acoustic FDTD wavefield strided
!> receiver-gather decimation example.
PROGRAM fortran2018_acoustic_wavefield
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT, C_INT32_T
  USE fortran_orm_f2018
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  TYPE(orm_stmt_t) :: stmt
  INTEGER(INT32), DIMENSION(9) :: chan_ids, decimated_chans
  REAL(REAL64), DIMENSION(9, 6) :: p_prev, p_curr, p_next, gather_grid
  CHARACTER(LEN=32) :: survey_tag
  REAL(REAL64) :: courant_sq, lap
  LOGICAL :: has_row
  INTEGER(C_INT) :: rc
  INTEGER(INT32) :: ix, iz, n_ch, n_rec
  INTEGER(C_INT32_T) :: tag_len

  rc = corm_f2018_open(db, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2018_exec(db, "CREATE TABLE receiver_chans(cid INTEGER)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, &
       "CREATE TABLE shot_gather(z2 REAL, z4 REAL, z6 REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "CREATE TABLE survey_hdr(line_id TEXT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2018_exec(db, "INSERT INTO survey_hdr VALUES('MARINE_2D_FDTD')")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  DO ix = 1_INT32, 9_INT32
    chan_ids(ix) = 1000_INT32 + ix * 10_INT32
  END DO

  p_prev = 0.0_REAL64
  DO iz = 1_INT32, 6_INT32
    DO ix = 1_INT32, 9_INT32
      p_curr(ix, iz) = EXP(-0.25_REAL64 * REAL((ix - 5_INT32) ** 2 + &
                                               (iz - 3_INT32) ** 2, REAL64))
    END DO
  END DO

  ! Advance one 2D acoustic FDTD step with Courant number c*dt/h = 0.4
  courant_sq = 0.16_REAL64
  p_next = p_curr
  DO iz = 2_INT32, 5_INT32
    DO ix = 2_INT32, 8_INT32
      lap = p_curr(ix - 1, iz) + p_curr(ix + 1, iz) + &
            p_curr(ix, iz - 1) + p_curr(ix, iz + 1) - 4.0_REAL64 * p_curr(ix, iz)
      p_next(ix, iz) = 2.0_REAL64 * p_curr(ix, iz) - p_prev(ix, iz) + &
                       courant_sq * lap
    END DO
  END DO

  ! Persist stride-3 channel slice and (1:9:3, 2:6:2) 2D subarray via CFI_cdesc_t
  rc = corm_f2018_insert_any_rank(db, &
       "INSERT INTO receiver_chans VALUES(?)", chan_ids(1:9:3))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2018_insert_any_rank(db, &
       "INSERT INTO shot_gather VALUES(?,?,?)", p_next(1:9:3, 2:6:2))
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  decimated_chans = 0_INT32
  rc = corm_f2018_query_any_rank(db, &
       "SELECT cid FROM receiver_chans", decimated_chans(1:9:3), n_ch)
  IF (rc /= FORTRAN_ORM_OK .OR. n_ch /= 3_INT32) ERROR STOP 1
  IF (ANY(decimated_chans(1:9:3) /= chan_ids(1:9:3))) ERROR STOP 1

  gather_grid = 0.0_REAL64
  rc = corm_f2018_query_any_rank(db, &
       "SELECT z2, z4, z6 FROM shot_gather", gather_grid(1:9:3, 2:6:2), n_rec)
  IF (rc /= FORTRAN_ORM_OK .OR. n_rec /= 3_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(gather_grid(1:9:3, 2:6:2) - &
                 p_next(1:9:3, 2:6:2))) > 1.0E-12_REAL64) ERROR STOP 1

  rc = stmt%prepare(db, "SELECT line_id FROM survey_hdr")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) ERROR STOP 1
  rc = fortran_orm_cfi_col_str(stmt%ptr, 1_C_INT32_T, survey_tag, tag_len)
  IF (rc /= FORTRAN_ORM_OK .OR. survey_tag(1:tag_len) /= "MARINE_2D_FDTD") &
    ERROR STOP 1

  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,1X,F9.6)', survey_tag(1:tag_len), gather_grid(4, 2)
END PROGRAM fortran2018_acoustic_wavefield
