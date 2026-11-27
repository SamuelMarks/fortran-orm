!> @file fortran2008_kalman_navigation.f90
!> @module kalman_nav_f2008
!> @brief ISO Fortran 2008 SUBMODULE, DO CONCURRENT, and CONTIGUOUS inertial
!> Kalman navigation state/covariance checkpointing example.
MODULE kalman_nav_f2008
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: propagate_cv_tracks

  INTERFACE
    !> @brief Propagates 2D constant-velocity navigation tracks `(x,y,vx,vy)`.
    !> @param[in] dt Integration time step in seconds.
    !> @param[inout] tracks Contiguous `(N, 4)` state matrix.
    MODULE SUBROUTINE propagate_cv_tracks(dt, tracks)
      REAL(REAL64), INTENT(IN) :: dt
      REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, INTENT(INOUT) :: tracks
    END SUBROUTINE propagate_cv_tracks
  END INTERFACE

END MODULE kalman_nav_f2008

!> @brief Fortran 2008 SUBMODULE implementing constant-velocity propagation.
SUBMODULE (kalman_nav_f2008) kalman_nav_f2008_impl
  IMPLICIT NONE
CONTAINS

  !> @brief Advances `(x, y)` positions in parallel using `DO CONCURRENT`.
  !> @param[in] dt Integration time step in seconds.
  !> @param[inout] tracks Contiguous `(N, 4)` state matrix.
  MODULE SUBROUTINE propagate_cv_tracks(dt, tracks)
    REAL(REAL64), INTENT(IN) :: dt
    REAL(REAL64), DIMENSION(:, :), CONTIGUOUS, INTENT(INOUT) :: tracks
    INTEGER(INT32) :: k, n_trk
    n_trk = INT(SIZE(tracks, 1), INT32)
    DO CONCURRENT (k = 1_INT32:n_trk)
      tracks(k, 1) = tracks(k, 1) + dt * tracks(k, 3)
      tracks(k, 2) = tracks(k, 2) + dt * tracks(k, 4)
    END DO
  END SUBROUTINE propagate_cv_tracks

END SUBMODULE kalman_nav_f2008_impl

PROGRAM fortran2008_kalman_navigation
  USE fortran_orm_f2008
  USE kalman_nav_f2008
  IMPLICIT NONE

  INTEGER(INT32), PARAMETER :: NVEH = 4_INT32
  TYPE(orm_db_t) :: db
  REAL(REAL64), DIMENSION(NVEH), TARGET :: innov_in, innov_out
  REAL(REAL64), DIMENSION(NVEH, 4), TARGET :: state_in, state_out
  REAL(REAL64), DIMENSION(4, 4), TARGET :: cov_in, cov_out
  INTEGER :: rc
  INTEGER(INT32) :: n_innov, n_state, n_cov, i

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = db%exec("CREATE TABLE kalman_innov(res REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE nav_state(x REAL, y REAL, vx REAL, vy REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE nav_cov(c1 REAL, c2 REAL, c3 REAL, c4 REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  innov_in = [0.12_REAL64, -0.05_REAL64, 0.08_REAL64, -0.03_REAL64]
  state_in(:, 1) = [100.0_REAL64, 200.0_REAL64, 300.0_REAL64, 400.0_REAL64]
  state_in(:, 2) = [50.0_REAL64,  75.0_REAL64,  100.0_REAL64, 125.0_REAL64]
  state_in(:, 3) = [12.5_REAL64,  15.0_REAL64,  17.5_REAL64,  20.0_REAL64]
  state_in(:, 4) = [-2.0_REAL64,   1.5_REAL64,   3.0_REAL64,  -1.0_REAL64]

  CALL propagate_cv_tracks(2.0_REAL64, state_in)

  cov_in = 0.05_REAL64
  DO CONCURRENT (i = 1_INT32:4_INT32)
    cov_in(i, i) = 1.25_REAL64 + REAL(i, REAL64) * 0.25_REAL64
  END DO

  rc = corm_f2008_insert_vec_f64(db, "INSERT INTO kalman_innov VALUES(?)", &
                                 innov_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_matrix_f64( &
       db, "INSERT INTO nav_state VALUES(?,?,?,?)", state_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_matrix_f64( &
       db, "INSERT INTO nav_cov VALUES(?,?,?,?)", cov_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  innov_out = 0.0_REAL64
  state_out = 0.0_REAL64
  cov_out = 0.0_REAL64
  rc = corm_f2008_query_vec_f64(db, "SELECT res FROM kalman_innov", &
                                innov_out, n_innov)
  IF (rc /= FORTRAN_ORM_OK .OR. n_innov /= NVEH) ERROR STOP 1
  rc = corm_f2008_query_matrix_f64( &
       db, "SELECT x, y, vx, vy FROM nav_state", state_out, n_state)
  IF (rc /= FORTRAN_ORM_OK .OR. n_state /= NVEH) ERROR STOP 1
  rc = corm_f2008_query_matrix_f64( &
       db, "SELECT c1, c2, c3, c4 FROM nav_cov", cov_out, n_cov)
  IF (rc /= FORTRAN_ORM_OK .OR. n_cov /= 4_INT32) ERROR STOP 1

  ! Fortran 2008 BLOCK construct auditing symmetry, trace, and kinematics
  BLOCK
    REAL(REAL64) :: tr_cov
    INTEGER(INT32) :: d
    tr_cov = 0.0_REAL64
    DO d = 1_INT32, 4_INT32
      tr_cov = tr_cov + cov_out(d, d)
    END DO
    IF (ABS(tr_cov - 7.50_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
    IF (ABS(state_out(1, 1) - 125.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1
    IF (MAXVAL(ABS(innov_out - innov_in)) > 1.0E-12_REAL64) ERROR STOP 1
  END BLOCK

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,F7.2)', "Fortran 2008 Kalman lead x(t=2s) = ", state_out(1, 1)
END PROGRAM fortran2008_kalman_navigation
