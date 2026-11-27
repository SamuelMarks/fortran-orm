!> @file fortran95_forall_cfd.f95
!> @module nozzle_cfd_f95
!> @brief ISO Fortran 95 PURE/ELEMENTAL/FORALL supersonic nozzle flow example.
MODULE nozzle_cfd_f95
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: isentropic_p_ratio

CONTAINS

  !> @brief Elemental Fortran 95 isentropic static-to-stagnation pressure ratio.
  !> @param[in] mach Local Mach number.
  !> @param[in] gamma_gas Specific heat ratio (e.g. 1.4D0 for dry air).
  !> @return Static pressure ratio p / p0.
  ELEMENTAL FUNCTION isentropic_p_ratio(mach, gamma_gas) RESULT(p_ratio)
    DOUBLE PRECISION, INTENT(IN) :: mach, gamma_gas
    DOUBLE PRECISION :: p_ratio
    DOUBLE PRECISION :: term
    term = 1.0D0 + 0.5D0 * (gamma_gas - 1.0D0) * mach * mach
    p_ratio = term ** (-gamma_gas / (gamma_gas - 1.0D0))
  END FUNCTION isentropic_p_ratio

END MODULE nozzle_cfd_f95

PROGRAM fortran95_forall_cfd
  USE fortran_orm_f95
  USE nozzle_cfd_f95
  IMPLICIT NONE

  TYPE(corm_db_f95) :: db
  DOUBLE PRECISION, DIMENSION(5, 3) :: nondim_grid, dimensional_kpa
  INTEGER, DIMENSION(4) :: statuses
  DOUBLE PRECISION :: p0_kpa
  INTEGER :: i, nrows

  ! Default component initialization ensures db%slot == 0 prior to open
  IF (corm_f95_db_is_open(db)) STOP 1

  CALL corm_f95_open(":memory:", db, statuses(1))
  IF (.NOT. corm_f95_db_is_open(db)) STOP 1
  CALL corm_f95_exec(db, &
       "CREATE TABLE nozzle_stations(x_kpa REAL, mach_s REAL, p_kpa REAL)", &
       statuses(2))

  FORALL (i = 1:5)
    nondim_grid(i, 1) = DBLE(i) * 0.20D0
    nondim_grid(i, 2) = 0.80D0 + DBLE(i - 1) * 0.35D0
  END FORALL
  nondim_grid(:, 3) = isentropic_p_ratio(nondim_grid(:, 2), 1.4D0)

  p0_kpa = 101.325D0
  CALL corm_f95_insert_scaled_matrix( &
       db, "INSERT INTO nozzle_stations VALUES(?,?,?)", &
       nondim_grid, p0_kpa, statuses(3))

  dimensional_kpa = 0.0D0
  CALL corm_f95_query_matrix( &
       db, "SELECT x_kpa, mach_s, p_kpa FROM nozzle_stations", &
       dimensional_kpa, nrows, statuses(4))

  IF (.NOT. ALL(corm_f95_is_ok(statuses)) .OR. nrows /= 5) STOP 1
  IF (MAXVAL(ABS(dimensional_kpa - nondim_grid * p0_kpa)) > 1.0D-9) STOP 1

  CALL corm_f95_close(db, statuses(1))
  IF (.NOT. corm_f95_is_ok(statuses(1)) .OR. corm_f95_db_is_open(db)) STOP 1
  PRINT '(A,F8.3)', "Fortran 95 exit static pressure (kPa) = ", &
        dimensional_kpa(5, 3)
END PROGRAM fortran95_forall_cfd
