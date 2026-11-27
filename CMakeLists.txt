cmake_minimum_required(VERSION 3.14)

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()
if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
  set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
endif()
if(POLICY CMP0091)
  cmake_policy(SET CMP0091 NEW)
endif()

if(APPLE)
  execute_process(
    COMMAND sw_vers -productVersion
    OUTPUT_VARIABLE _macos_host_ver
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  string(REGEX MATCH "^[0-9]+\\.[0-9]+" _macos_maj_min "${_macos_host_ver}")
  if(_macos_maj_min AND (NOT CMAKE_OSX_DEPLOYMENT_TARGET OR CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS "11.0"))
    set(CMAKE_OSX_DEPLOYMENT_TARGET "${_macos_maj_min}" CACHE STRING "Minimum macOS deployment version" FORCE)
  endif()
endif()

project(fortran-orm VERSION 0.1.0 LANGUAGES C Fortran)

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(GNUInstallDirs)
include(FetchContent)
include(FortranStandardsProbe)

option(FORTRAN_ORM_BUILD_TESTS "Build C89 and 12-era Fortran test suites" ON)
option(FORTRAN_ORM_BUILD_EXAMPLES "Build runnable Fortran example programs" ON)
option(FORTRAN_ORM_ENABLE_COVERAGE "Enable GCC/Clang coverage instrumentation on fortran-orm C targets" OFF)
option(FORTRAN_ORM_ENABLE_ASAN "Enable AddressSanitizer and UndefinedBehaviorSanitizer" OFF)

# Default c-orm backend configuration (all drivers enabled, COBOL copybook off)
set(C_ORM_SQLITE "LINKED" CACHE STRING "Enable SQLite driver (LINKED, DYNAMIC, OFF)")
set(C_ORM_POSTGRESQL "DYNAMIC" CACHE STRING "Enable PostgreSQL driver (LINKED, DYNAMIC, OFF)")
set(C_ORM_MYSQL "DYNAMIC" CACHE STRING "Enable MySQL driver (LINKED, DYNAMIC, OFF)")
option(C_ORM_ENABLE_ODBC "Enable Generic ODBC 3.52 driver support" ON)
option(C_ORM_ENABLE_DB2 "Enable IBM Db2 CLI/ODBC driver support" ON)
option(C_ORM_ENABLE_COPYBOOK "Enable COBOL Copybook parser" OFF)
option(C_ORM_THREADING "Enable multi-threading" ON)

# Preserve instrumentation flags so fetched dependencies compile cleanly
set(_fortran_orm_saved_c_flags "${CMAKE_C_FLAGS}")
set(_fortran_orm_saved_fc_flags "${CMAKE_Fortran_FLAGS}")
set(_fortran_orm_saved_exe_flags "${CMAKE_EXE_LINKER_FLAGS}")
set(_fortran_orm_saved_shared_flags "${CMAKE_SHARED_LINKER_FLAGS}")
set(_fortran_orm_saved_osx_target "${CMAKE_OSX_DEPLOYMENT_TARGET}")
set(_fortran_orm_old_build_testing "${BUILD_TESTING}")

set(BUILD_TESTING OFF)
set(C_ORM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(C_ORM_TESTING OFF CACHE BOOL "" FORCE)
set(C_ORM_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(C_ORM_BUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)
set(C_CDD_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(C_FS_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(C_FS_BUILD_TESTING OFF CACHE BOOL "" FORCE)

set(FORTRAN_ORM_C_ORM_DIR "" CACHE PATH "Optional local path to c-orm repository")
if(NOT FORTRAN_ORM_C_ORM_DIR AND EXISTS "${CMAKE_CURRENT_LIST_DIR}/../c-orm/CMakeLists.txt")
  set(FORTRAN_ORM_C_ORM_DIR "${CMAKE_CURRENT_LIST_DIR}/../c-orm")
endif()

if(FORTRAN_ORM_C_ORM_DIR AND EXISTS "${FORTRAN_ORM_C_ORM_DIR}/CMakeLists.txt")
  FetchContent_Declare(c_orm SOURCE_DIR "${FORTRAN_ORM_C_ORM_DIR}")
else()
  FetchContent_Declare(
    c_orm
    GIT_REPOSITORY https://github.com/SamuelMarks/c-orm.git
    GIT_TAG master
  )
endif()
if(NOT TARGET c-orm)
  FetchContent_MakeAvailable(c_orm)
endif()

if(FORTRAN_ORM_BUILD_TESTS AND TARGET c-orm)
  target_compile_definitions(c-orm PUBLIC C_ORM_TEST_ALLOCATOR=1)
endif()

set(BUILD_TESTING "${_fortran_orm_old_build_testing}")
set(CMAKE_C_FLAGS "${_fortran_orm_saved_c_flags}")
set(CMAKE_Fortran_FLAGS "${_fortran_orm_saved_fc_flags}")
set(CMAKE_EXE_LINKER_FLAGS "${_fortran_orm_saved_exe_flags}")
set(CMAKE_SHARED_LINKER_FLAGS "${_fortran_orm_saved_shared_flags}")
if(APPLE AND _fortran_orm_saved_osx_target)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "${_fortran_orm_saved_osx_target}" CACHE STRING "Minimum macOS deployment version" FORCE)
endif()

# Strict ISO C89 warning flags (zero -Wno-* suppressions)
if(MSVC)
  set(FORTRAN_ORM_C_STRICT_OPTIONS /W4 /WX)
  if(NOT MSVC_VERSION LESS 1700)
    list(APPEND FORTRAN_ORM_C_STRICT_OPTIONS /sdl)
  endif()
else()
  set(FORTRAN_ORM_C_STRICT_OPTIONS
    -std=c90
    -pedantic
    -Wall
    -Wextra
    -Werror
    -Wdeclaration-after-statement
    -Wmissing-prototypes
    -Wstrict-prototypes
    -Wold-style-definition
    -Wwrite-strings
    -Wcast-qual
  )
endif()

set(FORTRAN_ORM_INSTR_COMPILE_FLAGS)
set(FORTRAN_ORM_INSTR_C_LINK_FLAGS)
set(FORTRAN_ORM_INSTR_EXTRA_LIBS)
if(FORTRAN_ORM_ENABLE_COVERAGE AND NOT MSVC)
  list(APPEND FORTRAN_ORM_INSTR_COMPILE_FLAGS --coverage -O0 -g)
  list(APPEND FORTRAN_ORM_INSTR_C_LINK_FLAGS --coverage)
  if(APPLE AND CMAKE_C_COMPILER_ID MATCHES "Clang")
    execute_process(
      COMMAND "${CMAKE_C_COMPILER}" -print-resource-dir
      OUTPUT_VARIABLE _clang_res_dir
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    if(EXISTS "${_clang_res_dir}/lib/darwin/libclang_rt.profile_osx.a")
      list(APPEND FORTRAN_ORM_INSTR_EXTRA_LIBS "${_clang_res_dir}/lib/darwin/libclang_rt.profile_osx.a")
    endif()
  else()
    list(APPEND FORTRAN_ORM_INSTR_EXTRA_LIBS --coverage)
  endif()
endif()
if(FORTRAN_ORM_ENABLE_ASAN AND NOT MSVC)
  list(APPEND FORTRAN_ORM_INSTR_COMPILE_FLAGS -fsanitize=address,undefined -fno-omit-frame-pointer -g)
  list(APPEND FORTRAN_ORM_INSTR_C_LINK_FLAGS -fsanitize=address,undefined)
endif()

set(FORTRAN_ORM_C_SOURCES
  src/fortran_orm_str.c
  src/fortran_orm_db.c
  src/fortran_orm_pool.c
  src/fortran_orm_tx.c
  src/fortran_orm_stmt.c
  src/fortran_orm_matrix.c
  src/fortran_orm_crud.c
  src/fortran_orm_query.c
  src/fortran_orm_ext.c
  src/fortran_orm_legacy.c
  src/fortran_orm_f77_bridge.c
  src/fortran_orm_cfi.c
)

# 1. Core ISO C89 FFI & Legacy/CFI Bridge Library (`libfortran_orm`)
add_library(fortran_orm_c ${FORTRAN_ORM_C_SOURCES})
set_target_properties(fortran_orm_c PROPERTIES
  OUTPUT_NAME "fortran_orm"
  WINDOWS_EXPORT_ALL_SYMBOLS ON
  POSITION_INDEPENDENT_CODE ON
  EXPORT_COMPILE_COMMANDS ON
)
target_include_directories(fortran_orm_c
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
if(FORTRAN_ORM_HAS_CFI_HEADER)
  target_compile_definitions(fortran_orm_c PRIVATE FORTRAN_ORM_HAS_CFI_HEADER=1)
  if(FORTRAN_ORM_CFI_INCLUDE_DIR)
    target_include_directories(fortran_orm_c SYSTEM PRIVATE "${FORTRAN_ORM_CFI_INCLUDE_DIR}")
  endif()
endif()
target_link_libraries(fortran_orm_c PRIVATE c-orm PUBLIC ${FORTRAN_ORM_INSTR_EXTRA_LIBS})
target_compile_definitions(fortran_orm_c PUBLIC $<$<BOOL:${BUILD_SHARED_LIBS}>:FORTRAN_ORM_SHARED>)
target_compile_options(fortran_orm_c PRIVATE ${FORTRAN_ORM_C_STRICT_OPTIONS} ${FORTRAN_ORM_INSTR_COMPILE_FLAGS})

# Reproducible binding regeneration target using ../cdd-c
add_custom_target(fortran_orm_regen
  COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/scripts/generate_bindings.sh"
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  COMMENT "Regenerating Fortran ISO_C_BINDING module via cdd-c"
)

# Helper function to create an isolated Fortran standard library target
function(fortran_orm_add_mod_lib TARGET_NAME MOD_SUBDIR FLAGS_LIST)
  set(_mod_dir "${CMAKE_CURRENT_BINARY_DIR}/mod/${MOD_SUBDIR}")
  file(MAKE_DIRECTORY "${_mod_dir}")
  add_library(${TARGET_NAME} STATIC ${ARGN})
  set_target_properties(${TARGET_NAME} PROPERTIES
    Fortran_MODULE_DIRECTORY "${_mod_dir}"
    POSITION_INDEPENDENT_CODE ON
  )
  target_include_directories(${TARGET_NAME} PUBLIC
    $<BUILD_INTERFACE:${_mod_dir}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/fortran-orm/mod/${MOD_SUBDIR}>
  )
  target_compile_options(${TARGET_NAME} PRIVATE ${FLAGS_LIST})
  target_link_libraries(${TARGET_NAME} PUBLIC fortran_orm_c)
endfunction()

# 2. Pre-90 Fixed-Form Subroutine Libraries (FORTRAN II, III, IV, 66, 77)
fortran_orm_add_mod_lib(fortran_orm_f2  f2  "${FORTRAN_ORM_FIXED_FLAGS}" fortran/era/fortran_ii/cormf2.f)
fortran_orm_add_mod_lib(fortran_orm_f3  f3  "${FORTRAN_ORM_FIXED_FLAGS}" fortran/era/fortran_iii/cormf3.f)
fortran_orm_add_mod_lib(fortran_orm_f4  f4  "${FORTRAN_ORM_FIXED_FLAGS}" fortran/era/fortran_iv/cormf4.f)
fortran_orm_add_mod_lib(fortran_orm_f66 f66 "${FORTRAN_ORM_FIXED_FLAGS}" fortran/era/fortran66/corm66_lib.f)
fortran_orm_add_mod_lib(fortran_orm_f77 f77 "${FORTRAN_ORM_FIXED_FLAGS}" fortran/era/fortran77/corm77_lib.f)
target_include_directories(fortran_orm_f77 PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/fortran>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/fortran-orm>
)

# 3. Free-Form Module Libraries (Fortran 90, 95, cdd-c ISO_C_BINDING, 2003..2023)
fortran_orm_add_mod_lib(fortran_orm_f90   f90   "${FORTRAN_ORM_F90_FLAGS}"   fortran/era/fortran90/fortran_orm_f90.f90)
fortran_orm_add_mod_lib(fortran_orm_f95   f95   "${FORTRAN_ORM_F95_FLAGS}"   fortran/era/fortran95/fortran_orm_f95.f95)
fortran_orm_add_mod_lib(fortran_orm_gen   gen   "${FORTRAN_ORM_F2003_FLAGS}" generated/fortran_orm_c.f90)

fortran_orm_add_mod_lib(fortran_orm_f2003 f2003 "${FORTRAN_ORM_F2003_FLAGS}" fortran/era/fortran2003/fortran_orm_f2003.f90)
target_link_libraries(fortran_orm_f2003 PUBLIC fortran_orm_gen)

fortran_orm_add_mod_lib(fortran_orm_f2008 f2008 "${FORTRAN_ORM_F2008_FLAGS}"
  fortran/era/fortran2008/fortran_orm_f2008.f90
  fortran/era/fortran2008/fortran_orm_f2008_sub.f90
)
target_link_libraries(fortran_orm_f2008 PUBLIC fortran_orm_f2003)

fortran_orm_add_mod_lib(fortran_orm_f2018 f2018 "${FORTRAN_ORM_F2018_FLAGS}" fortran/era/fortran2018/fortran_orm_f2018.f90)
target_link_libraries(fortran_orm_f2018 PUBLIC fortran_orm_f2003)

fortran_orm_add_mod_lib(fortran_orm_f2023 f2023 "${FORTRAN_ORM_F2023_FLAGS}" fortran/era/fortran2023/fortran_orm_f2023.f90)
target_link_libraries(fortran_orm_f2023 PUBLIC fortran_orm_f2018)

fortran_orm_add_mod_lib(fortran_orm_mod umbrella "${FORTRAN_ORM_F2023_FLAGS}" fortran/fortran_orm.f90)
target_link_libraries(fortran_orm_mod PUBLIC fortran_orm_f2008 fortran_orm_f2023)

# 4. CTest Suites (C89 Unit + OOM, cdd-c ABI Layout, and All 12 Fortran Eras)
if(FORTRAN_ORM_BUILD_TESTS)
  include(CTest)
  enable_testing()

  set(_greatest_inc "${greatest_SOURCE_DIR}")
  if(NOT _greatest_inc AND EXISTS "${CMAKE_BINARY_DIR}/_deps/greatest-src")
    set(_greatest_inc "${CMAKE_BINARY_DIR}/_deps/greatest-src")
  endif()
  if(NOT _greatest_inc AND EXISTS "${CMAKE_CURRENT_LIST_DIR}/../greatest")
    set(_greatest_inc "${CMAKE_CURRENT_LIST_DIR}/../greatest")
  endif()

  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/c/test_fortran_orm.c")
    add_executable(test_fortran_orm_c tests/c/test_fortran_orm.c)
    target_link_libraries(test_fortran_orm_c PRIVATE fortran_orm_c c-orm)
    target_include_directories(test_fortran_orm_c PRIVATE "${_greatest_inc}" "${CMAKE_CURRENT_SOURCE_DIR}/src")
    if(FORTRAN_ORM_HAS_CFI_HEADER)
      target_compile_definitions(test_fortran_orm_c PRIVATE FORTRAN_ORM_HAS_CFI_HEADER=1)
      if(FORTRAN_ORM_CFI_INCLUDE_DIR)
        target_include_directories(test_fortran_orm_c SYSTEM PRIVATE "${FORTRAN_ORM_CFI_INCLUDE_DIR}")
      endif()
    endif()
    target_compile_definitions(test_fortran_orm_c PRIVATE C_ORM_TEST_ALLOCATOR=1)
    target_compile_options(test_fortran_orm_c PRIVATE ${FORTRAN_ORM_C_STRICT_OPTIONS} ${FORTRAN_ORM_INSTR_COMPILE_FLAGS})
    if(FORTRAN_ORM_INSTR_C_LINK_FLAGS)
      target_link_options(test_fortran_orm_c PRIVATE ${FORTRAN_ORM_INSTR_C_LINK_FLAGS})
    endif()
    add_test(NAME c89_unit_and_oom_suite COMMAND test_fortran_orm_c)
  endif()

  function(fortran_orm_add_ftest TEST_NAME SRC_FILE FLAGS_LIST LINK_LIBS)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILE}")
      add_executable(${TEST_NAME} "${SRC_FILE}")
      set(_tmod "${CMAKE_CURRENT_BINARY_DIR}/mod/tests_${TEST_NAME}")
      file(MAKE_DIRECTORY "${_tmod}")
      set_target_properties(${TEST_NAME} PROPERTIES Fortran_MODULE_DIRECTORY "${_tmod}")
      target_include_directories(${TEST_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include/fortran")
      target_compile_options(${TEST_NAME} PRIVATE ${FLAGS_LIST})
      target_link_libraries(${TEST_NAME} PRIVATE ${LINK_LIBS})
      add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})
    endif()
  endfunction()

  # Auto-generated cdd-c ISO_C_BINDING ABI struct size test across F2003..F2023
  fortran_orm_add_ftest(abi_layout_generated generated/fortran_orm_c_test.f90 "${FORTRAN_ORM_F2003_FLAGS}" "fortran_orm_gen")
  fortran_orm_add_ftest(era_00_fortran_i_deck fortran/era/fortran_i/cormf1.f  "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_c")

  # All 12 Standard Era End-to-End Test Suites
  fortran_orm_add_ftest(era_01_fortran_i    tests/fortran/era_01_fortran_i.f      "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_c")
  fortran_orm_add_ftest(era_02_fortran_ii   tests/fortran/era_02_fortran_ii.f     "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f2")
  fortran_orm_add_ftest(era_03_fortran_iii  tests/fortran/era_03_fortran_iii.f    "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f3")
  fortran_orm_add_ftest(era_04_fortran_iv   tests/fortran/era_04_fortran_iv.f     "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f4")
  fortran_orm_add_ftest(era_05_fortran_66   tests/fortran/era_05_fortran_66.f     "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f66")
  fortran_orm_add_ftest(era_06_fortran_77   tests/fortran/era_06_fortran_77.f     "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f77")
  fortran_orm_add_ftest(era_07_fortran_90   tests/fortran/era_07_fortran_90.f90   "${FORTRAN_ORM_F90_FLAGS}"   "fortran_orm_f90")
  fortran_orm_add_ftest(era_08_fortran_95   tests/fortran/era_08_fortran_95.f95   "${FORTRAN_ORM_F95_FLAGS}"   "fortran_orm_f95")
  fortran_orm_add_ftest(era_09_fortran_2003 tests/fortran/era_09_fortran_2003.f90 "${FORTRAN_ORM_F2003_FLAGS}" "fortran_orm_f2003")
  fortran_orm_add_ftest(era_10_fortran_2008 tests/fortran/era_10_fortran_2008.f90 "${FORTRAN_ORM_F2008_FLAGS}" "fortran_orm_f2008")
  fortran_orm_add_ftest(era_11_fortran_2018 tests/fortran/era_11_fortran_2018.f90 "${FORTRAN_ORM_F2018_FLAGS}" "fortran_orm_f2018")
  fortran_orm_add_ftest(era_12_fortran_2023 tests/fortran/era_12_fortran_2023.f90 "${FORTRAN_ORM_F2023_FLAGS}" "fortran_orm_mod")

  # Optional f2c ANSI FORTRAN 77 cross-verification test when f2c is installed
  if(FORTRAN_ORM_F2C_EXECUTABLE)
    add_test(
      NAME f2c_fortran77_syntax_check
      COMMAND "${FORTRAN_ORM_F2C_EXECUTABLE}" -A -I"${CMAKE_CURRENT_SOURCE_DIR}/include/fortran"
              -d "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/fortran/era/fortran77/corm77_lib.f"
    )
  endif()
endif()

# 5. Runnable Example Applications
if(FORTRAN_ORM_BUILD_EXAMPLES)
  function(fortran_orm_add_example EX_NAME SRC_FILE FLAGS_LIST LINK_LIBS)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILE}")
      add_executable(${EX_NAME} "${SRC_FILE}")
      set(_emod "${CMAKE_CURRENT_BINARY_DIR}/mod/ex_${EX_NAME}")
      file(MAKE_DIRECTORY "${_emod}")
      set_target_properties(${EX_NAME} PROPERTIES Fortran_MODULE_DIRECTORY "${_emod}")
      target_include_directories(${EX_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include/fortran")
      target_compile_options(${EX_NAME} PRIVATE ${FLAGS_LIST})
      target_link_libraries(${EX_NAME} PRIVATE ${LINK_LIBS})
      if(FORTRAN_ORM_BUILD_TESTS)
        add_test(NAME example_${EX_NAME} COMMAND ${EX_NAME})
      endif()
    endif()
  endfunction()

  fortran_orm_add_example(fortran_i_1957_telemetry              examples/fortran_i_1957_telemetry.f               "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_c")
  fortran_orm_add_example(fortran_i_1957_census_tabulator       examples/fortran_i_1957_census_tabulator.f        "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_c")
  fortran_orm_add_example(fortran_ii_1958_ballistics            examples/fortran_ii_1958_ballistics.f             "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f2")
  fortran_orm_add_example(fortran_ii_1958_hydro_reservoir       examples/fortran_ii_1958_hydro_reservoir.f        "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f2")
  fortran_orm_add_example(fortran_iii_1958_reactor_scram        examples/fortran_iii_1958_reactor_scram.f         "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f3")
  fortran_orm_add_example(fortran_iii_1958_radar_track          examples/fortran_iii_1958_radar_track.f           "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f3")
  fortran_orm_add_example(fortran_iv_1962_orbital_ephemeris     examples/fortran_iv_1962_orbital_ephemeris.f      "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f4")
  fortran_orm_add_example(fortran_iv_1962_structural_truss      examples/fortran_iv_1962_structural_truss.f       "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f4")
  fortran_orm_add_example(fortran66_steam_tables                examples/fortran66_steam_tables.f                 "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f66")
  fortran_orm_add_example(fortran66_chemical_kinetics           examples/fortran66_chemical_kinetics.f            "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f66")
  fortran_orm_add_example(fortran77_ledger                      examples/fortran77_ledger.f                       "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f77")
  fortran_orm_add_example(fortran77_ast_seismic                 examples/fortran77_ast_seismic.f                  "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f77")
  fortran_orm_add_example(fortran77_ocean_hydrography           examples/fortran77_ocean_hydrography.f            "${FORTRAN_ORM_FIXED_FLAGS}" "fortran_orm_f77")
  fortran_orm_add_example(fortran90_matrix_sim                  examples/fortran90_matrix_sim.f90                 "${FORTRAN_ORM_F90_FLAGS}"   "fortran_orm_f90")
  fortran_orm_add_example(fortran90_weather_stations            examples/fortran90_weather_stations.f90           "${FORTRAN_ORM_F90_FLAGS}"   "fortran_orm_f90")
  fortran_orm_add_example(fortran90_power_grid_dispatch         examples/fortran90_power_grid_dispatch.f90        "${FORTRAN_ORM_F90_FLAGS}"   "fortran_orm_f90")
  fortran_orm_add_example(fortran95_forall_cfd                  examples/fortran95_forall_cfd.f95                 "${FORTRAN_ORM_F95_FLAGS}"   "fortran_orm_f95")
  fortran_orm_add_example(fortran95_blackbody_planck            examples/fortran95_blackbody_planck.f95           "${FORTRAN_ORM_F95_FLAGS}"   "fortran_orm_f95")
  fortran_orm_add_example(fortran2003_oop_models                examples/fortran2003_oop_models.f90               "${FORTRAN_ORM_F2003_FLAGS}" "fortran_orm_f2003")
  fortran_orm_add_example(fortran2003_pool_and_ast              examples/fortran2003_pool_and_ast.f90             "${FORTRAN_ORM_F2003_FLAGS}" "fortran_orm_f2003")
  fortran_orm_add_example(fortran2003_spectroscopy_crud         examples/fortran2003_spectroscopy_crud.f90        "${FORTRAN_ORM_F2003_FLAGS}" "fortran_orm_f2003")
  fortran_orm_add_example(fortran2008_contiguous_nbody          examples/fortran2008_contiguous_nbody.f90         "${FORTRAN_ORM_F2008_FLAGS}" "fortran_orm_f2008")
  fortran_orm_add_example(fortran2008_kalman_navigation         examples/fortran2008_kalman_navigation.f90        "${FORTRAN_ORM_F2008_FLAGS}" "fortran_orm_f2008")
  fortran_orm_add_example(fortran2018_cfi_strided_stencil       examples/fortran2018_cfi_strided_stencil.f90      "${FORTRAN_ORM_F2018_FLAGS}" "fortran_orm_f2018")
  fortran_orm_add_example(fortran2018_acoustic_wavefield        examples/fortran2018_acoustic_wavefield.f90       "${FORTRAN_ORM_F2018_FLAGS}" "fortran_orm_f2018")
  fortran_orm_add_example(fortran2023_scientific_orm            examples/fortran2023_scientific_orm.f90           "${FORTRAN_ORM_F2023_FLAGS}" "fortran_orm_mod")
  fortran_orm_add_example(fortran2023_mainframe_ebcdic_decimal  examples/fortran2023_mainframe_ebcdic_decimal.f90 "${FORTRAN_ORM_F2023_FLAGS}" "fortran_orm_mod")
  fortran_orm_add_example(fortran2023_isotope_decay_ledger      examples/fortran2023_isotope_decay_ledger.f90     "${FORTRAN_ORM_F2023_FLAGS}" "fortran_orm_mod")
endif()

# 6. Install & pkg-config
install(TARGETS
  fortran_orm_c
  fortran_orm_f2 fortran_orm_f3 fortran_orm_f4 fortran_orm_f66 fortran_orm_f77
  fortran_orm_f90 fortran_orm_f95 fortran_orm_gen
  fortran_orm_f2003 fortran_orm_f2008 fortran_orm_f2018 fortran_orm_f2023
  fortran_orm_mod
  EXPORT fortran-orm-targets
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(DIRECTORY generated/ DESTINATION "${CMAKE_INSTALL_DATADIR}/fortran-orm/generated")
install(DIRECTORY fortran/ DESTINATION "${CMAKE_INSTALL_DATADIR}/fortran-orm/fortran")
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mod/"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/fortran-orm/mod"
  FILES_MATCHING PATTERN "*.mod" PATTERN "*.smod"
)

set(FORTRAN_ORM_PC_FILE "${CMAKE_CURRENT_BINARY_DIR}/fortran-orm.pc")
file(WRITE "${FORTRAN_ORM_PC_FILE}"
  "prefix=${CMAKE_INSTALL_PREFIX}\n"
  "exec_prefix=\${prefix}\n"
  "libdir=\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}\n"
  "includedir=\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}\n\n"
  "Name: fortran-orm\n"
  "Description: FORTRAN I through Fortran 2023 FFI Library for c-orm generated via cdd-c\n"
  "Version: ${PROJECT_VERSION}\n"
  "Libs: -L\${libdir} -lfortran_orm -lc-orm\n"
  "Cflags: -I\${includedir}\n"
)
install(FILES "${FORTRAN_ORM_PC_FILE}" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
