C @file fortran_iv_1962_structural_truss.f
C @brief 1962 IBM 7090 FORTRAN IV aerospace truss stress/strain solver.
C
C Uses authentic 1962 FORTRAN IV features: BLOCK DATA CORMBD, explicit
C INTEGER / DOUBLE PRECISION / LOGICAL declarations, logical IF,
C DOUBLE PRECISION and LOGICAL external functions, and padded 8x4
C column-major matrix persistence (NROWS = 5, LDROWS = 8) via F4MATI
C and F4MATQ.
      EXTERNAL CORMBD
      INTEGER IHURL(8), IHDDL(25), IHINS(31), IHSEL(23)
      INTEGER IDB, K, J, NOUT
      DOUBLE PRECISION TRUSS(8, 4), TROUT(8, 4)
      DOUBLE PRECISION DYMOD, DYLD, DAREA, DFORC, DSTRS, DEPS, UENG
      DOUBLE PRECISION UTOT, UCHK, STRAIN
      LOGICAL LOK, LYLD, ISYLD
      DATA IHURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE TRS(A,F,S,U)" (25 chars)
      DATA IHDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,84,82,83,40,
     1            65,44,70,44,83,44,85,41/
C "INSERT INTO TRS VALUES(?,?,?,?)" (31 chars)
      DATA IHINS /73,78,83,69,82,84,32,73,78,84,79,32,84,82,83,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,44,63,41/
C "SELECT A,F,S,U FROM TRS" (23 chars)
      DATA IHSEL /83,69,76,69,67,84,32,65,44,70,44,83,44,85,32,70,82,
     1            79,77,32,84,82,83/
C 7075-T6 aluminum Young's modulus (MPa) and yield strength (MPa)
      DYMOD = 71700.0D0
      DYLD = 503.0D0
      DO 15 J = 1, 4
        DO 10 K = 1, 8
          TRUSS(K, J) = 0.0D0
          TROUT(K, J) = 0.0D0
   10   CONTINUE
   15 CONTINUE
      UTOT = 0.0D0
      DO 20 K = 1, 5
        DAREA = 12.0D0 + DBLE(K - 1) * 3.0D0
        DFORC = 180.0D0 + DBLE(K - 1) * 45.0D0
        DSTRS = (DFORC * 10.0D0) / DAREA
        DEPS = STRAIN(DFORC * 10.0D0, DAREA, DYMOD)
        UENG = 0.5D0 * DSTRS * DEPS
        TRUSS(K, 1) = DAREA
        TRUSS(K, 2) = DFORC
        TRUSS(K, 3) = DSTRS
        TRUSS(K, 4) = UENG
        UTOT = UTOT + UENG
   20 CONTINUE
      IDB = 0
      CALL F4OPEN(IHURL, 8, IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4EXEC(IDB, IHDDL, 25, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4MATI(IDB, IHINS, 31, TRUSS, 8, 5, 4, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXCM(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      NOUT = 0
      CALL F4MATQ(IDB, IHSEL, 23, TROUT, 8, 5, 4, NOUT, LOK)
      IF (.NOT. LOK .OR. NOUT .NE. 5) STOP 1
      UCHK = 0.0D0
      DO 30 K = 1, 5
        LYLD = ISYLD(TROUT(K, 3), DYLD)
        IF (LYLD) STOP 1
        UCHK = UCHK + TROUT(K, 4)
   30 CONTINUE
      IF (DABS(UCHK - UTOT) .GT. 1.0D-10) STOP 1
      CALL F4CLOS(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      WRITE (6, 100) NOUT, UCHK
  100 FORMAT (I4, F12.6)
      STOP
      END

C @brief Computes axial Hookean engineering strain F / (A * E).
C @param DFORC Axial force scaled to Newtons per mm**2 * area.
C @param DAREA Cross-sectional member area.
C @param DYMOD Elastic modulus E in MPa.
C @return Dimensionless axial engineering strain.
      DOUBLE PRECISION FUNCTION STRAIN(DFORC, DAREA, DYMOD)
      DOUBLE PRECISION DFORC, DAREA, DYMOD
      STRAIN = DFORC / (DAREA * DYMOD)
      RETURN
      END

C @brief Evaluates whether axial stress exceeds material yield strength.
C @param DSTRS Member axial stress magnitude in MPa.
C @param DYLD Material yield limit in MPa.
C @return .TRUE. when DABS(DSTRS) .GE. DYLD, else .FALSE.
      LOGICAL FUNCTION ISYLD(DSTRS, DYLD)
      DOUBLE PRECISION DSTRS, DYLD
      ISYLD = (DABS(DSTRS) .GE. DYLD)
      RETURN
      END
