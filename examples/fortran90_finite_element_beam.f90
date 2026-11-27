!> @file fortran90_finite_element_beam.f90
!> @brief ISO/IEC 1539:1991 Fortran 90 Euler-Bernoulli finite-element
!> cantilever beam solver with fluent SQL queries, KV metadata, & savepoints.
!>
!> Showcases `fortran_orm_f90_orm` abstractions (`corm_query_f90_t` JOIN/WHERE/
!> ORDER/LIMIT, `corm_kv_f90_t`, generic `corm_f90_insert_vec`/`query_vec`,
!> `corm_f90_scalar_f64`, `corm_f90_count`, and nested savepoints) in strict
!> ISO Fortran 90 (`<= 31`-char identifiers, `(/ ... /)` constructors).
MODULE fem_beam_f90_mod
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: assemble_beam_k, solve_spd_dense, exact_tip_deflection

CONTAINS

  !> @brief Assembles global `(2*(nelem+1), 2*(nelem+1))` Hermite cubic
  !> Euler-Bernoulli beam stiffness matrix `k_glob` for uniform span `len_m`.
  !> @param[in] nelem Number of 2-node Hermite beam elements.
  !> @param[in] len_m Total cantilever span in meters.
  !> @param[in] ei_val Flexural rigidity E*I in N*m^2.
  !> @param[out] k_glob Global symmetric stiffness matrix.
  SUBROUTINE assemble_beam_k(nelem, len_m, ei_val, k_glob)
    INTEGER, INTENT(IN) :: nelem
    DOUBLE PRECISION, INTENT(IN) :: len_m, ei_val
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(OUT) :: k_glob
    DOUBLE PRECISION, DIMENSION(4, 4) :: ke
    DOUBLE PRECISION :: le, fac
    INTEGER :: e, i0, r, c

    k_glob = 0.0D0
    le = len_m / DBLE(nelem)
    fac = ei_val / (le * le * le)

    ke(1, :) = (/ 12.0D0, 6.0D0 * le, -12.0D0, 6.0D0 * le /)
    ke(2, :) = (/ 6.0D0 * le, 4.0D0 * le * le, -6.0D0 * le, &
                  2.0D0 * le * le /)
    ke(3, :) = (/ -12.0D0, -6.0D0 * le, 12.0D0, -6.0D0 * le /)
    ke(4, :) = (/ 6.0D0 * le, 2.0D0 * le * le, -6.0D0 * le, &
                  4.0D0 * le * le /)
    ke = fac * ke

    DO e = 1, nelem
      i0 = 2 * (e - 1)
      DO c = 1, 4
        DO r = 1, 4
          k_glob(i0 + r, i0 + c) = k_glob(i0 + r, i0 + c) + ke(r, c)
        END DO
      END DO
    END DO
  END SUBROUTINE assemble_beam_k

  !> @brief Solves dense linear system `amat * xvec = bvec` via Gaussian
  !> elimination without pivoting (positive-definite reduced stiffness).
  !> @param[in] n System dimension.
  !> @param[in] amat Positive-definite coefficient matrix `(n, n)`.
  !> @param[in] bvec Right-hand-side load vector `(n)`.
  !> @param[out] xvec Displacement/rotation solution vector `(n)`.
  SUBROUTINE solve_spd_dense(n, amat, bvec, xvec)
    INTEGER, INTENT(IN) :: n
    DOUBLE PRECISION, DIMENSION(:, :), INTENT(IN) :: amat
    DOUBLE PRECISION, DIMENSION(:), INTENT(IN) :: bvec
    DOUBLE PRECISION, DIMENSION(:), INTENT(OUT) :: xvec
    DOUBLE PRECISION, DIMENSION(n, n) :: lu
    DOUBLE PRECISION, DIMENSION(n) :: rhs
    DOUBLE PRECISION :: mult, acc
    INTEGER :: k, i, j

    lu = amat(1:n, 1:n)
    rhs = bvec(1:n)
    DO k = 1, n - 1
      DO i = k + 1, n
        mult = lu(i, k) / lu(k, k)
        lu(i, k + 1:n) = lu(i, k + 1:n) - mult * lu(k, k + 1:n)
        rhs(i) = rhs(i) - mult * rhs(k)
      END DO
    END DO

    xvec = 0.0D0
    DO i = n, 1, -1
      acc = rhs(i)
      DO j = i + 1, n
        acc = acc - lu(i, j) * xvec(j)
      END DO
      xvec(i) = acc / lu(i, i)
    END DO
  END SUBROUTINE solve_spd_dense

  !> @brief Analytical tip deflection `P * L^3 / (3 * E * I)` for a tip-loaded
  !> Euler-Bernoulli cantilever beam.
  !> @param[in] tip_load Tip point force P in Newtons.
  !> @param[in] len_m Beam span L in meters.
  !> @param[in] ei_val Flexural rigidity E*I in N*m^2.
  !> @return Exact vertical tip deflection in meters.
  DOUBLE PRECISION FUNCTION exact_tip_deflection(tip_load, len_m, ei_val)
    DOUBLE PRECISION, INTENT(IN) :: tip_load, len_m, ei_val
    exact_tip_deflection = (tip_load * (len_m ** 3)) / (3.0D0 * ei_val)
  END FUNCTION exact_tip_deflection

END MODULE fem_beam_f90_mod

!> @brief Main Fortran 90 finite-element beam ORM verification program.
PROGRAM f90_fem_beam
  USE fortran_orm_f90_orm
  USE fem_beam_f90_mod
  IMPLICIT NONE

  INTEGER, PARAMETER :: NELEM = 6
  INTEGER, PARAMETER :: NNODES = NELEM + 1
  INTEGER, PARAMETER :: NDOF = 2 * NNODES
  INTEGER, PARAMETER :: NRED = NDOF - 2

  TYPE(corm_db_f90) :: db
  TYPE(corm_stmt_f90) :: stmt
  TYPE(corm_query_f90_t) :: q
  TYPE(corm_kv_f90_t) :: kv
  DOUBLE PRECISION, DIMENSION(NDOF, NDOF) :: k_full
  DOUBLE PRECISION, DIMENSION(NRED, NRED) :: k_red
  DOUBLE PRECISION, DIMENSION(NRED) :: f_red, u_red
  DOUBLE PRECISION, DIMENSION(NNODES) :: x_coord, w_defl, th_rot, w_qry
  DOUBLE PRECISION, DIMENSION(NNODES, 3) :: node_mat, node_out
  CHARACTER(LEN=64) :: kv_val
  DOUBLE PRECISION :: span_m, ei_val, p_tip, w_exact, max_w, top_w
  INTEGER :: rc, k, n_out, n_rows, slen, top_id
  LOGICAL :: found, has_row

  span_m = 6.0D0
  ei_val = 4.2D6
  p_tip = -18000.0D0

  CALL assemble_beam_k(NELEM, span_m, ei_val, k_full)
  k_red = k_full(3:NDOF, 3:NDOF)
  f_red = 0.0D0
  f_red(NRED - 1) = p_tip
  CALL solve_spd_dense(NRED, k_red, f_red, u_red)

  w_defl(1) = 0.0D0
  th_rot(1) = 0.0D0
  DO k = 2, NNODES
    w_defl(k) = u_red(2 * (k - 2) + 1)
    th_rot(k) = u_red(2 * (k - 2) + 2)
  END DO
  DO k = 1, NNODES
    x_coord(k) = span_m * DBLE(k - 1) / DBLE(NELEM)
    node_mat(k, 1) = x_coord(k)
    node_mat(k, 2) = w_defl(k) * 1000.0D0
    node_mat(k, 3) = th_rot(k)
  END DO

  w_exact = exact_tip_deflection(p_tip, span_m, ei_val)
  IF (DABS(w_defl(NNODES) - w_exact) > 1.0D-10) STOP 1

  CALL corm_f90_open(":memory:", db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! 1. Store beam section & material metadata in `corm_kv_f90_t`
  CALL corm_f90_kv_init(db, "beam_meta", kv, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_kv_put(kv, "SECTION", "W310X38_STEEL", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_kv_put(kv, "BC_LEFT", "CLAMPED_FIXED", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_kv_get(kv, "SECTION", kv_val, slen, found, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. found) STOP 1
  IF (kv_val(1:slen) /= "W310X38_STEEL") STOP 1

  ! 2. Persist 1D deflection vector via generic `corm_f90_insert_vec` & `query_vec`
  CALL corm_f90_exec(db, "CREATE TABLE beam_w(w_mm REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "INSERT INTO beam_w VALUES(?)", &
                           node_mat(:, 2), rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_vec(db, "SELECT w_mm FROM beam_w", w_qry, n_out, rc)
  IF (rc /= CORM_F90_OK .OR. n_out /= NNODES) STOP 1
  IF (MAXVAL(DABS(w_qry - node_mat(:, 2))) > 1.0D-9) STOP 1

  ! 3. Persist nodal table + zone metadata and test savepoint rollback
  CALL corm_f90_exec(db, &
    "CREATE TABLE fem_nodes(nid INT PRIMARY KEY, zone TEXT, " // &
    "x_m REAL, w_mm REAL, rot_rad REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, &
    "CREATE TABLE fem_zones(zone TEXT PRIMARY KEY, allow_mm REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, &
    "INSERT INTO fem_zones VALUES('ROOT', 150.0), ('TIP', 400.0)", rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_tx_begin(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_prepare(db, "INSERT INTO fem_nodes VALUES(?,?,?,?,?)", &
                        stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  DO k = 1, NNODES
    CALL corm_f90_bind(stmt, 1, k, rc)
    IF (k <= 3) THEN
      CALL corm_f90_bind(stmt, 2, "ROOT", rc)
    ELSE
      CALL corm_f90_bind(stmt, 2, "TIP", rc)
    END IF
    CALL corm_f90_bind(stmt, 3, node_mat(k, 1), rc)
    CALL corm_f90_bind(stmt, 4, node_mat(k, 2), rc)
    CALL corm_f90_bind(stmt, 5, node_mat(k, 3), rc)
    CALL corm_f90_step(stmt, has_row, rc)
    CALL corm_f90_reset(stmt, rc)
    IF (rc /= CORM_F90_OK) STOP 1
  END DO
  CALL corm_f90_finalize(stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! Speculative overload node inside savepoint rolled back cleanly
  CALL corm_f90_savepoint(db, "sp_overload", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, &
    "INSERT INTO fem_nodes VALUES(99, 'TIP', 9.0, -9999.0, -1.0)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_rollback_sp(db, "sp_overload", rc)
  CALL corm_f90_release_sp(db, "sp_overload", rc)
  CALL corm_f90_tx_commit(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! 4. Persist 2D `(x, w_mm, rot)` matrix & verify via fluent `corm_query_f90_t`
  CALL corm_f90_exec(db, "CREATE TABLE fem_mat(x REAL, w REAL, r REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_insert_matrix(db, "INSERT INTO fem_mat VALUES(?,?,?)", &
                              node_mat, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_matrix(db, "SELECT x, w, r FROM fem_mat", node_out, &
                             n_rows, rc)
  IF (rc /= CORM_F90_OK .OR. n_rows /= NNODES) STOP 1

  CALL corm_f90_q_init(q, "fem_nodes n", "n.nid, n.w_mm")
  CALL corm_f90_q_join(q, "INNER", "fem_zones z", "n.zone = z.zone")
  CALL corm_f90_q_where_str(q, "n.zone", "=", "TIP")
  CALL corm_f90_q_where_i32(q, "n.nid", ">=", 4)
  CALL corm_f90_q_order_by(q, "ABS(n.w_mm)", .TRUE.)
  CALL corm_f90_q_limit_offset(q, 1, 0)
  CALL corm_f90_q_prepare(db, q, stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. has_row) STOP 1
  CALL corm_f90_col(stmt, 1, top_id, rc)
  CALL corm_f90_col(stmt, 2, top_w, rc)
  CALL corm_f90_finalize(stmt, rc)
  IF (top_id /= NNODES) STOP 1
  IF (DABS(top_w - w_exact * 1000.0D0) > 1.0D-7) STOP 1

  CALL corm_f90_count(db, "fem_nodes", n_rows, ierr=rc)
  IF (rc /= CORM_F90_OK .OR. n_rows /= NNODES) STOP 1
  CALL corm_f90_scalar_f64(db, "SELECT MIN(w_mm) FROM fem_nodes", &
                           0.0D0, max_w, rc)
  IF (rc /= CORM_F90_OK .OR. DABS(max_w - top_w) > 1.0D-7) STOP 1

  CALL corm_f90_close(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  PRINT '(A,I3,F12.4)', "FEM BEAM OK: nodes=", n_rows, top_w
END PROGRAM f90_fem_beam
