!> @file fortran2008_contiguous_nbody.f90
!> @brief ISO Fortran 2008 SUBMODULE & CONTIGUOUS zero-copy N-body phase-space
!> checkpointing example.
PROGRAM fortran2008_contiguous_nbody
  USE fortran_orm_f2008
  IMPLICIT NONE

  INTEGER(INT32), PARAMETER :: NBODIES = 4_INT32
  TYPE(orm_db_t) :: db
  REAL(REAL64), DIMENSION(NBODIES), TARGET :: masses_in, masses_out
  REAL(REAL64), DIMENSION(NBODIES, 6), TARGET :: phase_in, phase_out
  INTEGER :: rc
  INTEGER(INT32) :: out_m, out_p

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = db%exec("CREATE TABLE body_mass(m REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%exec( &
       "CREATE TABLE phase_space(x REAL,y REAL,z REAL,vx REAL,vy REAL,vz REAL)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  masses_in = [1.00000_REAL64, 0.00095_REAL64, 0.00029_REAL64, 0.00005_REAL64]
  phase_in(:, 1) = [0.0_REAL64,  5.20_REAL64,  9.58_REAL64, 19.20_REAL64]
  phase_in(:, 2) = [0.0_REAL64,  0.00_REAL64,  0.00_REAL64,  0.00_REAL64]
  phase_in(:, 3) = [0.0_REAL64,  0.05_REAL64, -0.09_REAL64,  0.02_REAL64]
  phase_in(:, 4) = [0.0_REAL64,  0.00_REAL64,  0.00_REAL64,  0.00_REAL64]
  phase_in(:, 5) = [-0.00294_REAL64, 2.75_REAL64, 2.04_REAL64, 1.43_REAL64]
  phase_in(:, 6) = [0.0_REAL64,  0.00_REAL64,  0.00_REAL64,  0.00_REAL64]

  rc = corm_f2008_insert_vec_f64(db, "INSERT INTO body_mass VALUES(?)", &
                                 masses_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2008_insert_matrix_f64( &
       db, "INSERT INTO phase_space VALUES(?,?,?,?,?,?)", phase_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  masses_out = 0.0_REAL64
  phase_out = 0.0_REAL64
  rc = corm_f2008_query_vec_f64(db, "SELECT m FROM body_mass", &
                                masses_out, out_m)
  IF (rc /= FORTRAN_ORM_OK .OR. out_m /= NBODIES) ERROR STOP 1

  rc = corm_f2008_query_matrix_f64( &
       db, "SELECT x,y,z,vx,vy,vz FROM phase_space", phase_out, out_p)
  IF (rc /= FORTRAN_ORM_OK .OR. out_p /= NBODIES) ERROR STOP 1

  ! Fortran 2008 BLOCK construct verifying momentum conservation
  BLOCK
    REAL(REAL64) :: py_in, py_out
    py_in = DOT_PRODUCT(masses_in, phase_in(:, 5))
    py_out = DOT_PRODUCT(masses_out, phase_out(:, 5))
    IF (ABS(py_in - py_out) > 1.0E-12_REAL64) ERROR STOP 1
  END BLOCK

  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,I2,A)', "Fortran 2008 CONTIGUOUS ", out_p, &
        "-body phase-space checkpoint verified."
END PROGRAM fortran2008_contiguous_nbody
