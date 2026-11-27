# @file FortranStandardsProbe.cmake
# @brief Probes Fortran compiler standard flags (FORTRAN I..Fortran 2023),
# optional secondary toolchains (f2c, flang, lfortran), and ISO_Fortran_binding.h.

include(CheckFortranCompilerFlag)
include(CheckIncludeFile)

# Optional secondary Fortran compilers on PATH
find_program(FORTRAN_ORM_F2C_EXECUTABLE NAMES f2c)
find_program(FORTRAN_ORM_FLANG_EXECUTABLE NAMES flang-new flang)
find_program(FORTRAN_ORM_LFORTRAN_EXECUTABLE NAMES lfortran)

if(FORTRAN_ORM_F2C_EXECUTABLE)
  message(STATUS "Found optional f2c translator: ${FORTRAN_ORM_F2C_EXECUTABLE}")
endif()
if(FORTRAN_ORM_FLANG_EXECUTABLE)
  message(STATUS "Found optional LLVM Flang: ${FORTRAN_ORM_FLANG_EXECUTABLE}")
endif()
if(FORTRAN_ORM_LFORTRAN_EXECUTABLE)
  message(STATUS "Found optional LFortran: ${FORTRAN_ORM_LFORTRAN_EXECUTABLE}")
endif()

# Locate <ISO_Fortran_binding.h> shipped with the active Fortran compiler
set(FORTRAN_ORM_HAS_CFI_HEADER OFF)
set(FORTRAN_ORM_CFI_INCLUDE_DIR "")

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  execute_process(
    COMMAND "${CMAKE_Fortran_COMPILER}" -print-file-name=include/ISO_Fortran_binding.h
    OUTPUT_VARIABLE _gfc_cfi_hdr
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  if(_gfc_cfi_hdr AND EXISTS "${_gfc_cfi_hdr}")
    get_filename_component(FORTRAN_ORM_CFI_INCLUDE_DIR "${_gfc_cfi_hdr}" DIRECTORY)
    set(FORTRAN_ORM_HAS_CFI_HEADER ON)
    message(STATUS "Found ISO_Fortran_binding.h: ${_gfc_cfi_hdr}")
  endif()
else()
  check_include_file("ISO_Fortran_binding.h" _sys_has_cfi)
  if(_sys_has_cfi)
    set(FORTRAN_ORM_HAS_CFI_HEADER ON)
  endif()
endif()

# Probe Fortran standard flags on active compiler
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(FORTRAN_ORM_FIXED_FLAGS -std=legacy -ffixed-form -ffixed-line-length-72 -Wall -Wextra -Werror)
  set(FORTRAN_ORM_F90_FLAGS   -std=f95    -ffree-form -Wall -Wextra -Wpedantic -Werror)
  set(FORTRAN_ORM_F95_FLAGS   -std=f95    -ffree-form -Wall -Wextra -Wpedantic -Werror)
  set(FORTRAN_ORM_F2003_FLAGS -std=f2003  -ffree-form -Wall -Wextra -Wpedantic -Werror)
  set(FORTRAN_ORM_F2008_FLAGS -std=f2008  -ffree-form -Wall -Wextra -Wpedantic -Werror)
  set(FORTRAN_ORM_F2018_FLAGS -std=f2018  -ffree-form -Wall -Wextra -Wpedantic -Werror)
  check_fortran_compiler_flag("-std=f2023" FORTRAN_ORM_COMPILER_HAS_STD_F2023)
  if(FORTRAN_ORM_COMPILER_HAS_STD_F2023)
    set(FORTRAN_ORM_F2023_FLAGS -std=f2023 -ffree-form -Wall -Wextra -Wpedantic -Werror)
  else()
    set(FORTRAN_ORM_F2023_FLAGS -std=f2018 -ffree-form -Wall -Wextra -Wpedantic -Werror)
  endif()
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "LLVMFlang|Flang")
  set(FORTRAN_ORM_FIXED_FLAGS -ffixed-form -Werror)
  set(FORTRAN_ORM_F90_FLAGS   -ffree-form -Werror)
  set(FORTRAN_ORM_F95_FLAGS   -std=f95 -ffree-form -Werror)
  set(FORTRAN_ORM_F2003_FLAGS -std=f2003 -ffree-form -Werror)
  set(FORTRAN_ORM_F2008_FLAGS -std=f2008 -ffree-form -Werror)
  set(FORTRAN_ORM_F2018_FLAGS -std=f2018 -ffree-form -Werror)
  set(FORTRAN_ORM_F2023_FLAGS -ffree-form -Werror)
else()
  set(FORTRAN_ORM_FIXED_FLAGS "")
  set(FORTRAN_ORM_F90_FLAGS "")
  set(FORTRAN_ORM_F95_FLAGS "")
  set(FORTRAN_ORM_F2003_FLAGS "")
  set(FORTRAN_ORM_F2008_FLAGS "")
  set(FORTRAN_ORM_F2018_FLAGS "")
  set(FORTRAN_ORM_F2023_FLAGS "")
endif()
