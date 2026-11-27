# Usage Guide

## 1. Fortran 2023 / 2018 Modern Scientific ORM

```fortran
PROGRAM demo_modern
  USE fortran_orm
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  REAL(REAL64), DIMENSION(6, 2) :: mesh, out_mesh
  INTEGER(INT32) :: rc, nrows

  rc = corm_f2023_open(db, ":memory:")
  rc = corm_f2023_exec(db, "CREATE TABLE mesh(x REAL, y REAL)")

  mesh(:, 1) = [1d0, 2d0, 3d0, 4d0, 5d0, 6d0]
  mesh(:, 2) = [10d0, 20d0, 30d0, 40d0, 50d0, 60d0]

  ! Persist odd-row strided slice directly via ISO Fortran 2018 CFI_cdesc_t
  rc = corm_f2018_insert_any_rank(db, "INSERT INTO mesh VALUES(?,?)", mesh(1:6:2, :))
  rc = corm_f2018_query_any_rank(db, "SELECT x, y FROM mesh", out_mesh(1:3, :), nrows)
  rc = db%close()
END PROGRAM demo_modern
```

---

## 2. Fortran 2003 OOP RAII & `BIND(C)` Derived-Type CRUD

```fortran
PROGRAM demo_f2003
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  IMPLICIT NONE

  TYPE, BIND(C) :: particle_t
    INTEGER(C_INT32_T) :: id
    INTEGER(C_INT32_T) :: pad
    REAL(C_DOUBLE) :: mass
    CHARACTER(KIND=C_CHAR) :: symbol(8)
  END TYPE particle_t

  TYPE(orm_db_t) :: db
  TYPE(orm_schema_t) :: schema
  TYPE(particle_t), TARGET :: p_in, p_out
  INTEGER(C_INT) :: rc

  rc = db%open(":memory:")
  rc = schema%create("particles", 24_C_INT32_T)
  rc = schema%add_col("id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, 0_C_INT32_T, .TRUE., .FALSE.)
  rc = schema%add_col("mass", FORTRAN_ORM_COL_FLOAT64, 8_C_INT32_T, 0_C_INT32_T, .FALSE., .FALSE.)
  rc = schema%add_col("symbol", FORTRAN_ORM_COL_CHAR_FIXED, 16_C_INT32_T, 8_C_INT32_T, .FALSE., .FALSE.)
  rc = schema%create_table(db)

  p_in%id = 1_C_INT32_T
  p_in%mass = 938.272_C_DOUBLE
  p_in%symbol = ["P", "R", "O", "T", "O", "N", " ", " "]
  rc = schema%insert_ptr(db, C_LOC(p_in))
  rc = schema%find_i32_ptr(db, 1_C_INT32_T, C_LOC(p_out))
  ! RAII FINAL destructors automatically release schema and db on scope exit!
END PROGRAM demo_f2003
```

---

## 3. ANSI FORTRAN 77 (`CHARACTER*(*)` + `INCLUDE`)

```fortran
      PROGRAM DEMO77
      INCLUDE 'fortran_orm_f77.inc'
      INTEGER IDB, IST, IERR, IV
      LOGICAL LROW
      CALL F7OPEN(':memory:', IDB, IERR)
      CALL F7EXEC(IDB, 'CREATE TABLE T(V INT)', IERR)
      CALL F7EXEC(IDB, 'INSERT INTO T VALUES(77)', IERR)
      CALL F7PREP(IDB, 'SELECT V FROM T', IST, IERR)
      CALL F7STEP(IST, LROW, IERR)
      CALL F7COLI(IST, 1, IV, IERR)
      CALL F7FINL(IST, IERR)
      CALL F7CLOS(IDB, IERR)
      END
```

---

## 4. 1957 IBM 704 FORTRAN (I) (`ICORMF` External Integer Function)

Because 1957 FORTRAN (I) predated `SUBROUTINE` and `CALL`, `ICORMF` is invoked directly inside three-way arithmetic `IF (expr) neg, zero, pos` statements (where `0` branches to the success label):

```fortran
      DIMENSION IURL(8), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
      IDB = 0
      IF (ICORMF(1, IDB, 0, 0, DDUM, IURL, 8)) 900, 10, 900
   10 IF (ICORMF(3, IDB, 0, 0, DDUM, IURL, 0)) 900, 20, 900
   20 STOP
  900 STOP 1
      END
```

---

## 5. Complete Example Directory (`examples/`)

All 28 runnable example applications across all 12 standards are compiled automatically when `-DFORTRAN_ORM_BUILD_EXAMPLES=ON` (default) and executed by `ctest --test-dir build`:

1. `examples/fortran_i_1957_telemetry.f` — **FORTRAN (I)** (1957) wind-tunnel Mach telemetry
2. `examples/fortran_i_1957_census_tabulator.f` — **FORTRAN (I)** (1957) municipal census & tax-roll tabulator (`ICORMF` tx commit/rollback & rowid)
3. `examples/fortran_ii_1958_ballistics.f` — **FORTRAN II** (1958) `SUBROUTINE` & `COMMON /CORMCM/` ballistic range recorder
4. `examples/fortran_ii_1958_hydro_reservoir.f` — **FORTRAN II** (1958) multi-subroutine hydroelectric dam spillway/turbine mass-balance ledger
5. `examples/fortran_iii_1958_reactor_scram.f` — **FORTRAN III** (1958–59) `ICORMB` boolean status/handle bitmask audit
6. `examples/fortran_iii_1958_radar_track.f` — **FORTRAN III** (1958–59) SAGE radar range-azimuth gate tracker (`F3MASK` selectors `1`, `2`, `3`)
7. `examples/fortran_iv_1962_orbital_ephemeris.f` — **FORTRAN IV** (1962) `BLOCK DATA` & padded `6x3` orbital ephemeris matrix
8. `examples/fortran_iv_1962_structural_truss.f` — **FORTRAN IV** (1962) aerospace pin-jointed truss axial stress/strain solver & padded `8x4` matrix
9. `examples/fortran66_steam_tables.f` — **FORTRAN 66** (1966) ASME saturated steam property tables & interpolation
10. `examples/fortran66_chemical_kinetics.f` — **FORTRAN 66** (1966) Arrhenius chemical reaction-rate curve & transactional batch rollback
11. `examples/fortran77_ledger.f` — **FORTRAN 77** (1978) savepoint financial ledger
12. `examples/fortran77_ast_seismic.f` — **FORTRAN 77** (1978) seismic arrival catalog, `NULL` columns, & 5-dialect AST
13. `examples/fortran77_ocean_hydrography.f` — **FORTRAN 77** (1978) oceanographic CTD cast profiler (`F7RLSP`/`F7RBSP`, `NULL` salinity, thermocline matrix)
14. `examples/fortran90_matrix_sim.f90` — **Fortran 90** (1991) 2D heat-equation mesh persistence
15. `examples/fortran90_weather_stations.f90` — **Fortran 90** (1991) synoptic weather stations with generic `corm_f90_bind`/`corm_f90_col`
16. `examples/fortran90_power_grid_dispatch.f90` — **Fortran 90** (1991) economic power-grid load dispatch, subarray matrix slice, & multi-dialect AST
17. `examples/fortran95_forall_cfd.f95` — **Fortran 95** (1997) `PURE`/`ELEMENTAL`/`FORALL` supersonic nozzle flow
18. `examples/fortran95_blackbody_planck.f95` — **Fortran 95** (1997) `PURE`/`ELEMENTAL`/`FORALL` stellar Planck spectral radiance & Wien peak
19. `examples/fortran2003_oop_models.f90` — **Fortran 2003** (2004) RAII `BIND(C)` model CRUD & JSON serialization
20. `examples/fortran2003_pool_and_ast.f90` — **Fortran 2003** (2004) `orm_pool_t` connection pooling & multi-dialect `orm_ast_t`
21. `examples/fortran2003_spectroscopy_crud.f90` — **Fortran 2003** (2004) HITRAN molecular spectroscopy (`upsert`, optimistic locking, `find_all`, `delete_i32`)
22. `examples/fortran2008_contiguous_nbody.f90` — **Fortran 2008** (2010) `SUBMODULE` & `CONTIGUOUS` zero-copy N-body checkpointing
23. `examples/fortran2008_kalman_navigation.f90` — **Fortran 2008** (2010) `SUBMODULE`, `DO CONCURRENT`, & `CONTIGUOUS` inertial Kalman state/covariance checkpointing
24. `examples/fortran2018_cfi_strided_stencil.f90` — **Fortran 2018** (2018) `CFI_cdesc_t` strided 1D/2D slices & `CHARACTER(LEN=*)`
25. `examples/fortran2018_acoustic_wavefield.f90` — **Fortran 2018** (2018) 2D acoustic FDTD wavefield strided `(1:9:3, 2:6:2)` receiver-gather decimation
26. `examples/fortran2023_scientific_orm.f90` — **Fortran 2023** (2023) `F_C_STRING`, strided slices, UUID v4, & 38-digit decimals
27. `examples/fortran2023_mainframe_ebcdic_decimal.f90` — **Fortran 2023** (2023) z/OS `EBCDIC`, exact decimal settlement, sharding, & OAuth2
28. `examples/fortran2023_isotope_decay_ledger.f90` — **Fortran 2023** (2023) `F_C_STRING(..., ASIS=)`, 38-digit radioisotope decay mass balance, & UTF-16 `GRAPHIC`
