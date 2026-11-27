# 12-Era Fortran Standards Compliance Matrix

Every standard requested is implemented as a dedicated library unit, verified by an isolated CTest executable, and statically audited by `scripts/check_fortran_era_compliance.py`.

| # | Standard | Year | Source Form | Max Ident | Source File | CTest Target | Key Era Idioms Exercised |
| :-: | :--- | :-: | :--- | :-: | :--- | :--- | :--- |
| 1 | **FORTRAN (I)** | 1957 | Fixed cols 1–72 | 6 | `fortran/era/fortran_i/cormf1.f` | `era_01_fortran_i` | `ICORMF` external function in 3-way arithmetic `IF`, `NAMF()` statement functions, unpacked `A1` `DIMENSION` arrays; zero `SUBROUTINE`/`CALL`/`COMMON` |
| 2 | **FORTRAN II** | 1958 | Fixed cols 1–72 | 6 | `fortran/era/fortran_ii/cormf2.f` | `era_02_fortran_ii` | `SUBROUTINE` (`F2OPEN..F2CLOS`), `CALL`, named `COMMON /CORMCM/`, `RETURN`, arithmetic `IF`; zero `LOGICAL`/`DATA`/`CHARACTER` |
| 3 | **FORTRAN III** | 1958–59 | Fixed cols 1–72 | 6 | `fortran/era/fortran_iii/cormf3.f` | `era_03_fortran_iii` | Portable `ICORMB` boolean status/handle bitmask words (`F3OPEN`, `F3EXEC`, `F3MASK`, `F3CLOS`) replacing IBM 704 col-1 `S` cards |
| 4 | **FORTRAN IV** | 1962 | Fixed cols 1–72 | 6 | `fortran/era/fortran_iv/cormf4.f` | `era_04_fortran_iv` | `BLOCK DATA CORMBD`, `DATA` initialization, explicit `INTEGER` / `DOUBLE PRECISION` / `LOGICAL`, logical `IF`, `F4MATI`/`F4MATQ` 2D matrices |
| 5 | **FORTRAN 66** | 1966 | Fixed cols 1–72 | 6 | `fortran/era/fortran66/corm66_lib.f` | `era_05_fortran_66` | Strict ANSI X3.9-1966 (`C6OPEN..C6MATQ`), zero `CHARACTER`, zero `PARAMETER`, zero block `IF/THEN/ENDIF` |
| 6 | **FORTRAN 77** | 1978 | Fixed cols 1–72 | 6 | `fortran/era/fortran77/corm77_lib.f` | `era_06_fortran_77` | ANSI X3.9-1978 `CHARACTER*(*)`, `INCLUDE 'fortran_orm_f77.inc'`, `PARAMETER`, block `IF/THEN/ELSE/END IF`, savepoints, AST, 2D matrices |
| 7 | **Fortran 90** | 1991 | Free `.f90` | 31 | `fortran/era/fortran90/fortran_orm_f90.f90` | `era_07_fortran_90` | `MODULE`, `IMPLICIT NONE`, derived types, explicit `INTERFACE`, generic `corm_f90_bind`/`corm_f90_col`, `ALLOCATABLE` 2D matrices, `OPTIONAL` |
| 8 | **Fortran 95** | 1997 | Free `.f95` (`-std=f95`) | 31 | `fortran/era/fortran95/fortran_orm_f95.f95` | `era_08_fortran_95` | Default component initialization (`slot = 0`), `PURE` & `ELEMENTAL` predicates, `FORALL` array-parallel matrix scaling |
| 9 | **Fortran 2003** | 2004 | Free `.f90` (`-std=f2003`) | 63 | `fortran/era/fortran2003/fortran_orm_f2003.f90` | `era_09_fortran_2003` | `USE fortran_orm_c` (`cdd-c`), OOP classes (`orm_db_t`, `orm_stmt_t`, `orm_pool_t`, `orm_ast_t`, `orm_rs_t`, `orm_schema_t`), `FINAL` RAII, `BIND(C)` CRUD |
| 10 | **Fortran 2008** | 2010 | Free `.f90` (`-std=f2008`) | 63 | `fortran/era/fortran2008/fortran_orm_f2008*.f90` | `era_10_fortran_2008` | `MODULE` + `SUBMODULE` separation, `ISO_FORTRAN_ENV`, `CONTIGUOUS` zero-copy vector & matrix `C_LOC`, `BLOCK`, `C_SIZEOF` |
| 11 | **Fortran 2018** | 2018 | Free `.f90` (`-std=f2018`) | 63 | `fortran/era/fortran2018/fortran_orm_f2018.f90` | `era_11_fortran_2018` | `IMPLICIT NONE (TYPE, EXTERNAL)`, `<ISO_Fortran_binding.h>` `CFI_cdesc_t` direct `CHARACTER(LEN=*)` & strided `DIMENSION(..)` slices |
| 12 | **Fortran 2023** | 2023 | Free `.f90` (`-std=f2023`) | 63 | `fortran/era/fortran2023/fortran_orm_f2023.f90` | `era_12_fortran_2023` | ISO Fortran 2023 `F_C_STRING(..., ASIS=)` intrinsic, 38-digit decimal helpers, and `MODULE fortran_orm` umbrella |
