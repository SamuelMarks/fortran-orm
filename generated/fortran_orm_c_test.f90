!> @file fortran_orm_c_test.f90
!> @brief Auto-generated Fortran ISO_C_BINDING C_SIZEOF ABI tests for fortran_orm_c.
PROGRAM fortran_orm_c_test_f90
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_c
  IMPLICIT NONE
  TYPE(fortran_orm_decimal) :: v_11
  TYPE(fortran_orm_pool_stats) :: v_12
  TYPE(fortran_orm_oauth2_token_pod) :: v_13
  IF (SIZE(TRANSFER(v_11, (/ 0_C_INT8_T /)), KIND=C_SIZE_T) <= 0_C_SIZE_T) STOP 1
  IF (SIZE(TRANSFER(v_12, (/ 0_C_INT8_T /)), KIND=C_SIZE_T) <= 0_C_SIZE_T) STOP 1
  IF (SIZE(TRANSFER(v_13, (/ 0_C_INT8_T /)), KIND=C_SIZE_T) <= 0_C_SIZE_T) STOP 1
END PROGRAM fortran_orm_c_test_f90
