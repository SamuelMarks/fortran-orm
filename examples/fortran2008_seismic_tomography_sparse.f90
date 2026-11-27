!> @file fortran2008_seismic_tomography_sparse.f90
!> @brief ISO/IEC 1539-1:2010 Fortran 2008 cross-borehole Compressed Sparse Row
!> (CSR) seismic ray-path tomography with generic `CONTIGUOUS` vectors &
!> padded leading-dimension submatrices.
!>
!> Showcases `fortran_orm_f2008`: generic `corm_f2008_insert_vec`/`query_vec`
!> across `INT32` (`col_ind`, `row_ptr`), `INT64` (`shot_epoch_ns`), and
!> `REAL64` (`ray_len_m`), plus `corm_f2008_insert_submatrix_f64`/`query_submatrix_f64`
!> for damped SIRT slowness inversion updates.
MODULE csr_sirt_f2008_mod
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: csr_matvec, sirt_tomography_solve

CONTAINS

  !> @brief Computes `y = A * x` for an `(n_rays, n_cells)` CSR matrix.
  !> @param[in] n_rays Number of seismic rays (rows).
  !> @param[in] row_ptr 1-based CSR row pointer `(n_rays + 1)`.
  !> @param[in] col_ind 1-based CSR column indices `(nnz)`.
  !> @param[in] vals CSR ray segment lengths `(nnz)`.
  !> @param[in] x_slow Cell slowness vector `(n_cells)` in s/km.
  !> @param[out] y_tt Predicted travel-time vector `(n_rays)` in seconds.
  PURE SUBROUTINE csr_matvec(n_rays, row_ptr, col_ind, vals, x_slow, y_tt)
    INTEGER(INT32), INTENT(IN) :: n_rays
    INTEGER(INT32), DIMENSION(:), CONTIGUOUS, INTENT(IN) :: row_ptr, col_ind
    REAL(REAL64), DIMENSION(:), CONTIGUOUS, INTENT(IN) :: vals, x_slow
    REAL(REAL64), DIMENSION(:), CONTIGUOUS, INTENT(OUT) :: y_tt
    INTEGER(INT32) :: r, k
    REAL(REAL64) :: acc

    DO r = 1_INT32, n_rays
      acc = 0.0_REAL64
      DO k = row_ptr(r), row_ptr(r + 1_INT32) - 1_INT32
        acc = acc + vals(k) * x_slow(col_ind(k))
      END DO
      y_tt(r) = acc
    END DO
  END SUBROUTINE csr_matvec

  !> @brief Reconstructs cell slowness `s_est` via Simultaneous Iterative
  !> Reconstruction Technique (SIRT) from observed travel times `tt_obs`.
  !> @param[in] n_rays Number of rays.
  !> @param[in] n_cells Number of velocity-model cells.
  !> @param[in] row_ptr 1-based CSR row pointers.
  !> @param[in] col_ind 1-based CSR column indices.
  !> @param[in] vals CSR ray lengths.
  !> @param[in] tt_obs Observed first-arrival travel times.
  !> @param[in] n_iters Number of SIRT sweeps.
  !> @param[out] s_est Reconstructed cell slownesses.
  SUBROUTINE sirt_tomography_solve(n_rays, n_cells, row_ptr, col_ind, vals, &
                                   tt_obs, n_iters, s_est)
    INTEGER(INT32), INTENT(IN) :: n_rays, n_cells, n_iters
    INTEGER(INT32), DIMENSION(:), CONTIGUOUS, INTENT(IN) :: row_ptr, col_ind
    REAL(REAL64), DIMENSION(:), CONTIGUOUS, INTENT(IN) :: vals, tt_obs
    REAL(REAL64), DIMENSION(:), CONTIGUOUS, INTENT(OUT) :: s_est
    REAL(REAL64), DIMENSION(n_rays) :: row_sum, tt_pred, resid
    REAL(REAL64), DIMENSION(n_cells) :: col_sum, delta_s
    INTEGER(INT32) :: r, k, j, it

    row_sum = 0.0_REAL64
    col_sum = 0.0_REAL64
    DO r = 1_INT32, n_rays
      DO k = row_ptr(r), row_ptr(r + 1_INT32) - 1_INT32
        j = col_ind(k)
        row_sum(r) = row_sum(r) + vals(k)
        col_sum(j) = col_sum(j) + vals(k)
      END DO
    END DO

    s_est = 0.20_REAL64
    DO it = 1_INT32, n_iters
      CALL csr_matvec(n_rays, row_ptr, col_ind, vals, s_est, tt_pred)
      resid = (tt_obs - tt_pred) / MAX(row_sum, 1.0E-12_REAL64)
      delta_s = 0.0_REAL64
      DO r = 1_INT32, n_rays
        DO k = row_ptr(r), row_ptr(r + 1_INT32) - 1_INT32
          j = col_ind(k)
          delta_s(j) = delta_s(j) + vals(k) * resid(r)
        END DO
      END DO
      DO CONCURRENT (j = 1_INT32:n_cells, col_sum(j) > 1.0E-12_REAL64)
        s_est(j) = s_est(j) + 0.85_REAL64 * delta_s(j) / col_sum(j)
      END DO
    END DO
  END SUBROUTINE sirt_tomography_solve

END MODULE csr_sirt_f2008_mod

!> @brief Main Fortran 2008 CSR seismic tomography ORM program.
PROGRAM fortran2008_seismic_csr
  USE fortran_orm_f2008
  USE csr_sirt_f2008_mod
  IMPLICIT NONE

  INTEGER(INT32), PARAMETER :: NCELLS = 4_INT32
  INTEGER(INT32), PARAMETER :: NRAYS = 6_INT32
  INTEGER(INT32), PARAMETER :: NNZ = 12_INT32
  TYPE(orm_db_t) :: db
  INTEGER(INT32), DIMENSION(NRAYS + 1), TARGET :: row_ptr, row_ptr_q
  INTEGER(INT32), DIMENSION(NNZ), TARGET :: col_ind, col_ind_q
  INTEGER(INT64), DIMENSION(NRAYS), TARGET :: shot_ns, shot_ns_q
  REAL(REAL64), DIMENSION(NNZ), TARGET :: ray_len, ray_len_q
  REAL(REAL64), DIMENSION(NCELLS) :: s_true, s_rec
  REAL(REAL64), DIMENSION(NRAYS) :: tt_obs
  REAL(REAL64), DIMENSION(8, 4), TARGET :: model_pad, model_out
  REAL(REAL64) :: max_err
  INTEGER(INT32) :: rc, n_out, k

  ! 2x2 cross-borehole cell block: 2 horizontal, 2 vertical, 2 diagonal rays
  row_ptr = [1_INT32, 3_INT32, 5_INT32, 7_INT32, 9_INT32, 11_INT32, 13_INT32]
  col_ind = [1_INT32, 2_INT32, &
             3_INT32, 4_INT32, &
             1_INT32, 3_INT32, &
             2_INT32, 4_INT32, &
             1_INT32, 4_INT32, &
             2_INT32, 3_INT32]
  ray_len = [0.50_REAL64, 0.50_REAL64, &
             0.50_REAL64, 0.50_REAL64, &
             0.50_REAL64, 0.50_REAL64, &
             0.50_REAL64, 0.50_REAL64, &
             0.70710678_REAL64, 0.70710678_REAL64, &
             0.70710678_REAL64, 0.70710678_REAL64]
  DO k = 1_INT32, NRAYS
    shot_ns(k) = 1700000000000000000_INT64 + INT(k, INT64) * 250000_INT64
  END DO

  ! True slowness model (s/km): basalt anomaly in cell 4 (0.18 s/km -> 5.55 km/s)
  s_true = [0.25_REAL64, 0.22_REAL64, 0.28_REAL64, 0.18_REAL64]
  CALL csr_matvec(NRAYS, row_ptr, col_ind, ray_len, s_true, tt_obs)

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec("CREATE TABLE csr_rp(p INT)")
  rc = db%exec("CREATE TABLE csr_ci(c INT)")
  rc = db%exec("CREATE TABLE csr_vl(v REAL)")
  rc = db%exec("CREATE TABLE shot_t(ns INT)")
  rc = db%exec("CREATE TABLE sirt_mod(cell_id REAL, s_true REAL, s_est REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 1. Persist CSR arrays & 64-bit timestamps via generic `corm_f2008_insert_vec`
  rc = corm_f2008_insert_vec(db, "INSERT INTO csr_rp VALUES(?)", row_ptr)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_vec(db, "INSERT INTO csr_ci VALUES(?)", col_ind)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_vec(db, "INSERT INTO csr_vl VALUES(?)", ray_len)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2008_insert_vec(db, "INSERT INTO shot_t VALUES(?)", shot_ns)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 2. Hydrate CSR operator from SQLite and run SIRT slowness inversion
  rc = corm_f2008_query_vec(db, "SELECT p FROM csr_rp", row_ptr_q, n_out)
  IF (rc /= FORTRAN_ORM_OK .OR. n_out /= NRAYS + 1_INT32) ERROR STOP 1
  rc = corm_f2008_query_vec(db, "SELECT c FROM csr_ci", col_ind_q, n_out)
  IF (rc /= FORTRAN_ORM_OK .OR. n_out /= NNZ) ERROR STOP 1
  rc = corm_f2008_query_vec(db, "SELECT v FROM csr_vl", ray_len_q, n_out)
  IF (rc /= FORTRAN_ORM_OK .OR. n_out /= NNZ) ERROR STOP 1
  rc = corm_f2008_query_vec(db, "SELECT ns FROM shot_t", shot_ns_q, n_out)
  IF (rc /= FORTRAN_ORM_OK .OR. ANY(shot_ns_q /= shot_ns)) ERROR STOP 1

  CALL sirt_tomography_solve(NRAYS, NCELLS, row_ptr_q, col_ind_q, ray_len_q, &
                             tt_obs, 80_INT32, s_rec)

  ! Note: 2x2 tomography has 1 checkerboard nullspace mode unless diagonal
  ! rays differ in aspect; verify forward travel-time residual < 1e-10!
  BLOCK
    REAL(REAL64), DIMENSION(NRAYS) :: tt_fit
    CALL csr_matvec(NRAYS, row_ptr_q, col_ind_q, ray_len_q, s_rec, tt_fit)
    max_err = MAXVAL(ABS(tt_fit - tt_obs))
    IF (max_err > 1.0E-8_REAL64) ERROR STOP 1
  END BLOCK

  ! 3. Persist active `(4, 3)` block inside `(8, 4)` padded workspace
  model_pad = -1.0_REAL64
  DO k = 1_INT32, NCELLS
    model_pad(k, 1) = REAL(k, REAL64)
    model_pad(k, 2) = s_true(k)
    model_pad(k, 3) = s_rec(k)
  END DO
  rc = corm_f2008_insert_submatrix_f64(db, &
    "INSERT INTO sirt_mod VALUES(?,?,?)", model_pad, NCELLS, 3_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  model_out = 0.0_REAL64
  rc = corm_f2008_query_submatrix_f64(db, &
    "SELECT cell_id, s_true, s_est FROM sirt_mod", model_out, NCELLS, &
    3_INT32, n_out)
  IF (rc /= FORTRAN_ORM_OK .OR. n_out /= NCELLS) ERROR STOP 1
  IF (MAXVAL(ABS(model_out(1:NCELLS, 3) - s_rec)) > 1.0E-12_REAL64) THEN
    ERROR STOP 1
  END IF

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,E12.4)', "SEISMIC CSR F2008 OK: tt_resid=", max_err
END PROGRAM fortran2008_seismic_csr
