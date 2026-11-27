!> @file fortran90_weather_stations.f90
!> @module weather_obs_f90
!> @brief ISO Fortran 90 synoptic weather-station network & SQL AST example.
MODULE weather_obs_f90
  USE fortran_orm_f90
  IMPLICIT NONE
  PRIVATE

  !> @type station_obs_t
  !> @brief Synoptic surface meteorological observation derived type.
  TYPE, PUBLIC :: station_obs_t
    INTEGER :: wmo_id
    CHARACTER(LEN=16) :: icao_code
    DOUBLE PRECISION :: temp_c
    DOUBLE PRECISION :: pressure_hpa
  END TYPE station_obs_t

  PUBLIC :: record_observation

CONTAINS

  !> @brief Inserts a single meteorological observation using generic F90 binds.
  !> @param[in] db Active Fortran 90 database handle.
  !> @param[in] obs Meteorological observation record.
  !> @param[out] ierr Status code (`CORM_F90_OK` on success).
  SUBROUTINE record_observation(db, obs, ierr)
    TYPE(corm_db_f90), INTENT(IN) :: db
    TYPE(station_obs_t), INTENT(IN) :: obs
    INTEGER, INTENT(OUT) :: ierr
    TYPE(corm_stmt_f90) :: stmt
    LOGICAL :: has_row
    INTEGER :: f_rc

    CALL corm_f90_prepare(db, &
         "INSERT INTO wx_obs VALUES(?,?,?,?)", stmt, ierr)
    IF (ierr /= CORM_F90_OK) RETURN
    CALL corm_f90_bind(stmt, 1, obs%wmo_id, ierr)
    IF (ierr == CORM_F90_OK) CALL corm_f90_bind(stmt, 2, obs%icao_code, ierr)
    IF (ierr == CORM_F90_OK) CALL corm_f90_bind(stmt, 3, obs%temp_c, ierr)
    IF (ierr == CORM_F90_OK) CALL corm_f90_bind(stmt, 4, obs%pressure_hpa, ierr)
    IF (ierr == CORM_F90_OK) CALL corm_f90_step(stmt, has_row, ierr)
    CALL corm_f90_finalize(stmt, f_rc)
    IF (ierr == CORM_F90_OK) ierr = f_rc
  END SUBROUTINE record_observation

END MODULE weather_obs_f90

PROGRAM fortran90_weather_stations
  USE fortran_orm_f90
  USE weather_obs_f90
  IMPLICIT NONE

  TYPE(corm_db_f90) :: db
  TYPE(corm_stmt_f90) :: qstmt
  TYPE(corm_ast_f90) :: ast
  TYPE(station_obs_t), DIMENSION(3) :: network
  CHARACTER(LEN=16) :: code_out
  CHARACTER(LEN=128) :: db2_sql, pg_sql
  DOUBLE PRECISION :: mean_temp, t_val, p_val
  LOGICAL :: has_row
  INTEGER :: rc, k, n_read, slen

  CALL corm_f90_open(":memory:", db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, &
       "CREATE TABLE wx_obs(wmo INT, icao TEXT, tc REAL, hpa REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1

  network(1) = station_obs_t(93110, "NZAA", 19.5D0, 1016.2D0)
  network(2) = station_obs_t(93439, "NZWN", 15.0D0, 1009.8D0)
  network(3) = station_obs_t(93781, "NZCH", 13.5D0, 1012.4D0)

  CALL corm_f90_tx_begin(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  DO k = 1, 3
    CALL record_observation(db, network(k), rc)
    IF (rc /= CORM_F90_OK) STOP 1
  END DO
  CALL corm_f90_tx_commit(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! Verify transactional rollback discards uncalibrated sensor spike
  CALL corm_f90_tx_begin(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, &
       "INSERT INTO wx_obs VALUES(99999,'BAD',99.9,500.0)", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_tx_rollback(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_prepare(db, &
       "SELECT icao, tc, hpa FROM wx_obs ORDER BY wmo", qstmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  mean_temp = 0.0D0
  n_read = 0
  DO
    CALL corm_f90_step(qstmt, has_row, rc)
    IF (rc /= CORM_F90_OK) STOP 1
    IF (.NOT. has_row) EXIT
    CALL corm_f90_col(qstmt, 1, code_out, slen, rc)
    IF (rc /= CORM_F90_OK .OR. slen /= 4) STOP 1
    CALL corm_f90_col(qstmt, 2, t_val, rc)
    IF (rc /= CORM_F90_OK) STOP 1
    CALL corm_f90_col(qstmt, 3, p_val, rc)
    IF (rc /= CORM_F90_OK .OR. p_val < 900.0D0) STOP 1
    mean_temp = mean_temp + t_val
    n_read = n_read + 1
  END DO
  CALL corm_f90_finalize(qstmt, rc)
  IF (rc /= CORM_F90_OK .OR. n_read /= 3) STOP 1
  mean_temp = mean_temp / DBLE(n_read)
  IF (ABS(mean_temp - 16.0D0) > 1.0D-9) STOP 1

  CALL corm_f90_ast_select("wx_obs", 2, ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_POSTGRES, pg_sql, slen, rc)
  IF (rc /= CORM_F90_OK .OR. INDEX(pg_sql, "LIMIT 2") == 0) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_DB2, db2_sql, slen, rc)
  IF (rc /= CORM_F90_OK .OR. INDEX(db2_sql, "FETCH FIRST") == 0) STOP 1
  CALL corm_f90_ast_free(ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_close(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  PRINT '(A,F6.2)', "Fortran 90 synoptic mean C = ", mean_temp
END PROGRAM fortran90_weather_stations
