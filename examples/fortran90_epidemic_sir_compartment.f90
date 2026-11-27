!> @file fortran90_epidemic_sir_compartment.f90
!> @brief ISO/IEC 1539:1991 Fortran 90 4th-order Runge-Kutta compartmental
!> SIR epidemiology solver with `corm_ts_f90_t` time-series checkpointing.
!>
!> Showcases `fortran_orm_f90_orm` (`corm_ts_f90_t` `ts_init`, `ts_append`,
!> `ts_latest`, `ts_max_val`, `ts_prune_after`, `corm_kv_f90_t`, `corm_query_f90_t`,
!> and 2D trajectory matrix persistence) in strict ISO Fortran 90.
MODULE sir_rk4_f90_mod
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: sir_rhs, sir_rk4_step

CONTAINS

  !> @brief Evaluates compartmental Kermack-McKendrick SIR derivatives
  !> `(dS/dt, dI/dt, dR/dt)` for population `n_pop`.
  !> @param[in] state_y Current `(S, I, R)` vector of length 3.
  !> @param[in] beta_rate Transmission contact rate (1/day).
  !> @param[in] gamma_rate Recovery rate (1/day).
  !> @param[in] n_pop Total conserved population `S + I + R`.
  !> @param[out] dydt Time derivative vector `(dS/dt, dI/dt, dR/dt)`.
  SUBROUTINE sir_rhs(state_y, beta_rate, gamma_rate, n_pop, dydt)
    DOUBLE PRECISION, DIMENSION(3), INTENT(IN) :: state_y
    DOUBLE PRECISION, INTENT(IN) :: beta_rate, gamma_rate, n_pop
    DOUBLE PRECISION, DIMENSION(3), INTENT(OUT) :: dydt
    DOUBLE PRECISION :: inf_flux
    inf_flux = beta_rate * state_y(1) * state_y(2) / n_pop
    dydt(1) = -inf_flux
    dydt(2) = inf_flux - gamma_rate * state_y(2)
    dydt(3) = gamma_rate * state_y(2)
  END SUBROUTINE sir_rhs

  !> @brief Advances `(S, I, R)` by one classical RK4 step `dt`.
  !> @param[inout] state_y State vector `(S, I, R)` updated in place.
  !> @param[in] dt Time step in days.
  !> @param[in] beta_rate Transmission contact rate (1/day).
  !> @param[in] gamma_rate Recovery rate (1/day).
  !> @param[in] n_pop Total population.
  SUBROUTINE sir_rk4_step(state_y, dt, beta_rate, gamma_rate, n_pop)
    DOUBLE PRECISION, DIMENSION(3), INTENT(INOUT) :: state_y
    DOUBLE PRECISION, INTENT(IN) :: dt, beta_rate, gamma_rate, n_pop
    DOUBLE PRECISION, DIMENSION(3) :: k1, k2, k3, k4, y_tmp
    CALL sir_rhs(state_y, beta_rate, gamma_rate, n_pop, k1)
    y_tmp = state_y + 0.5D0 * dt * k1
    CALL sir_rhs(y_tmp, beta_rate, gamma_rate, n_pop, k2)
    y_tmp = state_y + 0.5D0 * dt * k2
    CALL sir_rhs(y_tmp, beta_rate, gamma_rate, n_pop, k3)
    y_tmp = state_y + dt * k3
    CALL sir_rhs(y_tmp, beta_rate, gamma_rate, n_pop, k4)
    state_y = state_y + (dt / 6.0D0) * (k1 + 2.0D0 * k2 + 2.0D0 * k3 + k4)
  END SUBROUTINE sir_rk4_step

END MODULE sir_rk4_f90_mod

!> @brief Main Fortran 90 SIR epidemic checkpointing & rollback program.
PROGRAM f90_sir_epidemic
  USE fortran_orm_f90_orm
  USE sir_rk4_f90_mod
  IMPLICIT NONE

  INTEGER, PARAMETER :: NSTEPS = 40
  TYPE(corm_db_f90) :: db
  TYPE(corm_ts_f90_t) :: ts_inf
  TYPE(corm_kv_f90_t) :: kv_cfg
  TYPE(corm_query_f90_t) :: q
  TYPE(corm_stmt_f90) :: stmt
  DOUBLE PRECISION, DIMENSION(3) :: y_sir, y_ckpt
  DOUBLE PRECISION, DIMENSION(NSTEPS, 4) :: traj_in, traj_out
  CHARACTER(LEN=32) :: regime_tag
  DOUBLE PRECISION :: n_pop, beta_base, beta_lock, gamma_rec, dt
  DOUBLE PRECISION :: t_days, t_lat, val_lat, peak_inf, r0_basic, pop_sum
  INTEGER :: step_k, lat_step, n_rows, rc
  LOGICAL :: found, has_row

  n_pop = 100000.0D0
  beta_base = 0.45D0
  beta_lock = 0.18D0
  gamma_rec = 0.10D0
  dt = 1.0D0
  r0_basic = beta_base / gamma_rec

  CALL corm_f90_open(":memory:", db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_kv_init(db, "sir_params", kv_cfg, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_kv_put(kv_cfg, "MODEL", "KERMACK_MCKENDRICK_RK4", rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_ts_init(db, "sir_infected_ts", ts_inf, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! 1. Integrate unmitigated outbreak to day 30, checkpointing day 15
  y_sir = (/ 99900.0D0, 100.0D0, 0.0D0 /)
  y_ckpt = y_sir
  DO step_k = 1, 30
    CALL sir_rk4_step(y_sir, dt, beta_base, gamma_rec, n_pop)
    t_days = DBLE(step_k) * dt
    CALL corm_f90_ts_append(ts_inf, step_k, t_days, y_sir(2), &
                            "UNMITIGATED", rc)
    IF (rc /= CORM_F90_OK) STOP 1
    IF (step_k == 15) y_ckpt = y_sir
    traj_in(step_k, :) = (/ t_days, y_sir(1), y_sir(2), y_sir(3) /)
  END DO

  ! 2. Rewind speculative unmitigated horizon after day 15 & apply intervention
  CALL corm_f90_ts_prune_after(ts_inf, 15, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_ts_latest(ts_inf, lat_step, t_lat, val_lat, found, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. found .OR. lat_step /= 15) STOP 1
  IF (DABS(val_lat - y_ckpt(2)) > 1.0D-9) STOP 1

  y_sir = y_ckpt
  DO step_k = 16, NSTEPS
    CALL sir_rk4_step(y_sir, dt, beta_lock, gamma_rec, n_pop)
    t_days = DBLE(step_k) * dt
    CALL corm_f90_ts_append(ts_inf, step_k, t_days, y_sir(2), &
                            "INTERVENTION", rc)
    IF (rc /= CORM_F90_OK) STOP 1
    traj_in(step_k, :) = (/ t_days, y_sir(1), y_sir(2), y_sir(3) /)
  END DO

  ! 3. Persist full 40x4 `(t, S, I, R)` trajectory & verify mass conservation
  CALL corm_f90_exec(db, &
    "CREATE TABLE sir_traj(t_d REAL, s REAL, i REAL, r REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_insert_matrix(db, "INSERT INTO sir_traj VALUES(?,?,?,?)", &
                              traj_in, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_matrix(db, "SELECT t_d, s, i, r FROM sir_traj", &
                             traj_out, n_rows, rc)
  IF (rc /= CORM_F90_OK .OR. n_rows /= NSTEPS) STOP 1

  DO step_k = 1, NSTEPS
    pop_sum = traj_out(step_k, 2) + traj_out(step_k, 3) + traj_out(step_k, 4)
    IF (DABS(pop_sum - n_pop) > 1.0D-6) STOP 1
  END DO

  ! 4. Query peak active infections & verify fluent query on intervention rows
  CALL corm_f90_ts_max_val(ts_inf, peak_inf, rc)
  IF (rc /= CORM_F90_OK .OR. peak_inf <= 100.0D0 .OR. r0_basic < 4.0D0) STOP 1

  CALL corm_f90_q_init(q, "sir_infected_ts", "step_no, tag")
  CALL corm_f90_q_where_str(q, "tag", "=", "INTERVENTION")
  CALL corm_f90_q_order_by(q, "step_no", .FALSE.)
  CALL corm_f90_q_limit_offset(q, 1, 0)
  CALL corm_f90_q_prepare(db, q, stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. has_row) STOP 1
  CALL corm_f90_col(stmt, 1, lat_step, rc)
  CALL corm_f90_col(stmt, 2, regime_tag, n_rows, rc)
  CALL corm_f90_finalize(stmt, rc)
  IF (lat_step /= 16 .OR. regime_tag(1:n_rows) /= "INTERVENTION") STOP 1

  CALL corm_f90_count(db, "sir_infected_ts", n_rows, "tag = 'INTERVENTION'", &
                      rc)
  IF (rc /= CORM_F90_OK .OR. n_rows /= 25) STOP 1

  CALL corm_f90_close(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  PRINT '(A,F12.2,F10.2)', "SIR RK4 OK: peak_I=", peak_inf, r0_basic
END PROGRAM f90_sir_epidemic
