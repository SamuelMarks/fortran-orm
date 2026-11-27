!> @file fortran90_matrix_sim.f90
!> @brief ISO Fortran 90 2D heat-equation grid persistence example.
PROGRAM fortran90_matrix_sim
  USE fortran_orm_f90
  IMPLICIT NONE

  TYPE(corm_db_f90) :: db
  DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: grid_t0, grid_restored
  INTEGER :: rc, r, nrows

  CALL corm_f90_open(":memory:", db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_exec(db, "CREATE TABLE heat_mesh(x REAL, y REAL, temp REAL)", rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ALLOCATE(grid_t0(4, 3), grid_restored(4, 3))
  DO r = 1, 4
    grid_t0(r, 1) = DBLE(r) * 0.25D0
    grid_t0(r, 2) = DBLE(r) * 0.50D0
    grid_t0(r, 3) = 300.0D0 + DBLE(r) * 12.5D0
  END DO

  CALL corm_f90_insert_matrix(db, "INSERT INTO heat_mesh VALUES(?,?,?)", &
                              grid_t0, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_query_matrix(db, "SELECT x, y, temp FROM heat_mesh", &
                             grid_restored, nrows, rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 4) STOP 1
  IF (MAXVAL(ABS(grid_t0 - grid_restored)) > 1.0D-10) STOP 1

  DEALLOCATE(grid_t0, grid_restored)
  CALL corm_f90_close(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  PRINT '(A)', "Fortran 90 heat-mesh simulation persisted & verified."
END PROGRAM fortran90_matrix_sim
