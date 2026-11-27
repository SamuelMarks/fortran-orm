!> @file fortran90_power_grid_dispatch.f90
!> @module grid_dispatch_f90
!> @brief ISO Fortran 90 economic power-grid load dispatch & multi-dialect AST
!> example.
MODULE grid_dispatch_f90
  USE fortran_orm_f90
  IMPLICIT NONE
  PRIVATE

  !> @type generator_unit_t
  !> @brief Dispatchable thermal/hydro generating unit metadata.
  TYPE, PUBLIC :: generator_unit_t
    INTEGER :: bus_id
    CHARACTER(LEN=16) :: plant_code
    DOUBLE PRECISION :: heat_rate_gj
    DOUBLE PRECISION :: fuel_usd_gj
  END TYPE generator_unit_t

  PUBLIC :: register_generator, marginal_cost_mwh

CONTAINS

  !> @brief Computes incremental energy cost ($/MWh) from heat rate and fuel.
  !> @param[in] heat_rate_gj Net station heat rate (GJ / MWh).
  !> @param[in] fuel_usd_gj Delivered fuel price ($ / GJ).
  !> @return Marginal generation cost in $/MWh.
  FUNCTION marginal_cost_mwh(heat_rate_gj, fuel_usd_gj) RESULT(cost)
    DOUBLE PRECISION, INTENT(IN) :: heat_rate_gj, fuel_usd_gj
    DOUBLE PRECISION :: cost
    cost = heat_rate_gj * fuel_usd_gj
  END FUNCTION marginal_cost_mwh

  !> @brief Persists one generator unit using generic Fortran 90 `corm_f90_bind`.
  !> @param[in] db Active Fortran 90 database handle.
  !> @param[in] gen Generator metadata derived-type instance.
  !> @param[out] ierr Status code (`CORM_F90_OK` on success).
  SUBROUTINE register_generator(db, gen, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    TYPE(generator_unit_t), INTENT(IN) :: gen
    INTEGER, INTENT(OUT) :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    INTEGER :: f_rc
    DOUBLE PRECISION :: mcost

    mcost = marginal_cost_mwh(gen%heat_rate_gj, gen%fuel_usd_gj)
    CALL corm_f90_prepare(db, &
         "INSERT INTO gen_fleet VALUES(?,?,?)", stmt, ierr)
    IF (ierr /= CORM_F90_OK) RETURN
    CALL corm_f90_bind(stmt, 1, gen%bus_id, ierr)
    IF (ierr == CORM_F90_OK) CALL corm_f90_bind(stmt, 2, gen%plant_code, ierr)
    IF (ierr == CORM_F90_OK) CALL corm_f90_bind(stmt, 3, mcost, ierr)
    IF (ierr == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, ierr)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (ierr == CORM_F90_OK) ierr = f_rc
  END SUBROUTINE register_generator

END MODULE grid_dispatch_f90

PROGRAM fortran90_power_grid_dispatch
  USE fortran_orm_f90
  USE grid_dispatch_f90
  IMPLICIT NONE

  TYPE(corm_db_f90) :: db
  TYPE(corm_stmt_f90) :: qstmt
  TYPE(corm_ast_f90) :: ast
  TYPE(generator_unit_t), DIMENSION(3) :: fleet
  DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: schedule_in, schedule_out
  CHARACTER(LEN=16) :: cheapest_code
  CHARACTER(LEN=128) :: sqlite_sql, mysql_sql, odbc_sql, db2_sql
  DOUBLE PRECISION :: cheapest_cost
  LOGICAL :: has_row
  INTEGER :: rc, k, bus_out, slen, nrows

  CALL corm_f90_open(":memory:", db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, &
       "CREATE TABLE gen_fleet(bus INT, code TEXT, mcost REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, &
       "CREATE TABLE hourly_mw(hour_idx REAL, load_mw REAL, reserve_mw REAL)", &
       rc)
  IF (rc /= CORM_F90_OK) STOP 1

  fleet(1) = generator_unit_t(101, "CCGT_NORTH", 7.20D0, 4.50D0)
  fleet(2) = generator_unit_t(102, "HYDRO_DAM",  3.60D0, 1.25D0)
  fleet(3) = generator_unit_t(103, "PEAK_GT",   10.50D0, 6.00D0)

  CALL corm_f90_tx_begin(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  DO k = 1, 3
    CALL register_generator(db, fleet(k), rc)
    IF (rc /= CORM_F90_OK) STOP 1
  END DO
  CALL corm_f90_tx_commit(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_prepare(db, &
       "SELECT bus, code, mcost FROM gen_fleet ORDER BY mcost ASC", qstmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(qstmt, has_row, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. has_row) STOP 1
  CALL corm_f90_col(qstmt, 1, bus_out, rc)
  IF (rc /= CORM_F90_OK .OR. bus_out /= 102) STOP 1
  CALL corm_f90_col(qstmt, 2, cheapest_code, slen, rc)
  IF (rc /= CORM_F90_OK .OR. cheapest_code(1:slen) /= "HYDRO_DAM") STOP 1
  CALL corm_f90_col(qstmt, 3, cheapest_cost, rc)
  IF (rc /= CORM_F90_OK .OR. ABS(cheapest_cost - 4.50D0) > 1.0D-9) STOP 1
  CALL corm_f90_finalize(qstmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ALLOCATE(schedule_in(4, 3), schedule_out(3, 3))
  DO k = 1, 4
    schedule_in(k, 1) = DBLE(k)
    schedule_in(k, 2) = 450.0D0 + DBLE(k) * 35.0D0
    schedule_in(k, 3) = 45.0D0 + DBLE(k) * 3.5D0
  END DO
  ! Persist first 3 hours via assumed-shape subarray slice
  CALL corm_f90_insert_matrix(db, "INSERT INTO hourly_mw VALUES(?,?,?)", &
                              schedule_in(1:3, :), rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_matrix(db, &
       "SELECT hour_idx, load_mw, reserve_mw FROM hourly_mw", &
       schedule_out, nrows, rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 3) STOP 1
  IF (MAXVAL(ABS(schedule_out - schedule_in(1:3, :))) > 1.0D-10) STOP 1
  DEALLOCATE(schedule_in, schedule_out)

  CALL corm_f90_ast_select("gen_fleet", 3, ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_SQLITE, sqlite_sql, slen, rc)
  IF (rc /= CORM_F90_OK .OR. INDEX(sqlite_sql, "LIMIT 3") == 0) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_MYSQL, mysql_sql, slen, rc)
  IF (rc /= CORM_F90_OK .OR. INDEX(mysql_sql, "LIMIT 3") == 0) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_ODBC, odbc_sql, slen, rc)
  IF (rc /= CORM_F90_OK .OR. slen <= 0 .OR. &
      INDEX(odbc_sql, "gen_fleet") == 0) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_DB2, db2_sql, slen, rc)
  IF (rc /= CORM_F90_OK .OR. INDEX(db2_sql, "FETCH FIRST") == 0) STOP 1
  CALL corm_f90_ast_free(ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_close(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  PRINT '(A,A,A,F6.2)', "Merit-order lead: ", cheapest_code(1:slen), &
        " $/MWh = ", cheapest_cost
END PROGRAM fortran90_power_grid_dispatch
