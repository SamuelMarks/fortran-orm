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
