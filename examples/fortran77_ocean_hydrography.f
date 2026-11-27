C @file fortran77_ocean_hydrography.f
C @brief ANSI FORTRAN 77 oceanographic CTD hydrographic cast profiler.
C
C Exercises ANSI X3.9-1978 CHARACTER*(*) metadata, savepoint release
C (F7RLSP) and rollback (F7RBSP), SQL NULL bottle salinity handling
C (F7BINN/F7COLN), F7ROW rowid inspection, and 2D thermocline profile
C matrix persistence (F7MATI/F7MATQ).
      PROGRAM CTD77
      INCLUDE 'fortran_orm_f77.inc'
      INTEGER IDB, IST, IERR, ICHK, IROWID, ILEN, NNUL, NOUT, K
      DOUBLE PRECISION PROF(5, 3), PQ(5, 3), DSAL, DSIG, SIGT77
      LOGICAL LROW, LNUL
      CHARACTER*16 VESS
      ICHK = CMEMER + CCNNER + CSQLER + CBNDER + CSTPER + CTYPER +
     1       CNTFND + CVALER + CNULPT + CCONER + CTIMER + CTRUNC +
     2       CHNDER + CFULER + CBUFER + CIDXER + COPCER + CDSQLT +
     3       CDPG + CDMY + CDDB2 + CDODBC
      IF (ICHK .LE. 0) STOP 1
      CALL F7OPEN(':memory:', IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7EXEC(IDB,
     1 'CREATE TABLE CASTS(STN INT, VESS TEXT, LAT REAL, SAL REAL)',
     2 IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7EXEC(IDB,
     1 'CREATE TABLE CTDZ(Z REAL, TC REAL, SAL REAL)', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7TXBG(IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7SVPT(IDB, 'CAST_BATCH_OK', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL ADDCST(IDB, 401, 'RV_ATLANTIS', -36.85D0, 35.42D0, .TRUE.,
     1 IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL ADDCST(IDB, 402, 'RV_KNORR', -41.28D0, 0.0D0, .FALSE.,
     1 IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7RLSP(IDB, 'CAST_BATCH_OK', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7SVPT(IDB, 'WINCH_SPIKE', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL ADDCST(IDB, 999, 'BAD_SENSOR', 0.0D0, 99.9D0, .TRUE., IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7RBSP(IDB, 'WINCH_SPIKE', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7TXCM(IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7ROW(IDB, IROWID, IERR)
      IF (IERR .NE. CORMOK .OR. IROWID .LT. 2) STOP 1
      CALL F7PREP(IDB,
     1 'SELECT VESS, SAL FROM CASTS ORDER BY STN', IST, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      NNUL = 0
      DSAL = 0.0D0
   10 CALL F7STEP(IST, LROW, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      IF (LROW) THEN
        CALL F7COLC(IST, 1, VESS, ILEN, IERR)
        IF (IERR .NE. CORMOK .OR. ILEN .LE. 0) STOP 1
        CALL F7COLN(IST, 2, LNUL, IERR)
        IF (IERR .NE. CORMOK) STOP 1
        IF (LNUL) THEN
          NNUL = NNUL + 1
        ELSE
          CALL F7COLD(IST, 2, DSAL, IERR)
          IF (IERR .NE. CORMOK) STOP 1
        END IF
        GO TO 10
      END IF
      CALL F7FINL(IST, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      IF (NNUL .NE. 1 .OR. DABS(DSAL - 35.42D0) .GT. 1.0D-9) STOP 1
      DO 20 K = 1, 5
        PROF(K, 1) = DBLE(K - 1) * 250.0D0
        PROF(K, 2) = 18.5D0 - DBLE(K - 1) * 3.2D0
        PROF(K, 3) = 35.40D0 - DBLE(K - 1) * 0.18D0
        PQ(K, 1) = 0.0D0
        PQ(K, 2) = 0.0D0
        PQ(K, 3) = 0.0D0
   20 CONTINUE
      CALL F7MATI(IDB, 'INSERT INTO CTDZ VALUES(?,?,?)', PROF, 5, 5,
     1 3, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7MATQ(IDB, 'SELECT Z, TC, SAL FROM CTDZ', PQ, 5, 5, 3,
     1 NOUT, IERR)
      IF (IERR .NE. CORMOK .OR. NOUT .NE. 5) STOP 1
      DSIG = SIGT77(PQ(5, 2), PQ(5, 3))
      IF (DSIG .LE. SIGT77(PQ(1, 2), PQ(1, 3))) STOP 1
      CALL F7CLOS(IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      WRITE (6, '(A,F8.3)') 'DEEP SIGMA-T = ', DSIG
      END

C @brief Inserts one hydrographic station header with optional NULL SAL.
C @param IDB Active 1-based database slot handle.
C @param ISTN Station number.
C @param VESS Research vessel callsign.
C @param DLAT Station latitude in decimal degrees.
C @param DSAL Surface bottle salinity in PSU.
C @param LSAL .TRUE. if bottle salinity is present, .FALSE. for NULL.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE ADDCST(IDB, ISTN, VESS, DLAT, DSAL, LSAL, IERR)
      INTEGER IDB, ISTN, IERR
      CHARACTER*(*) VESS
      DOUBLE PRECISION DLAT, DSAL
      LOGICAL LSAL
      INTEGER IST, IFNL
      LOGICAL LROW
      CALL F7PREP(IDB, 'INSERT INTO CASTS VALUES(?,?,?,?)', IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7BINI(IST, 1, ISTN, IERR)
      IF (IERR .EQ. 0) CALL F7BINC(IST, 2, VESS, IERR)
      IF (IERR .EQ. 0) CALL F7BIND(IST, 3, DLAT, IERR)
      IF (IERR .EQ. 0) THEN
        IF (LSAL) THEN
          CALL F7BIND(IST, 4, DSAL, IERR)
        ELSE
          CALL F7BINN(IST, 4, IERR)
        END IF
      END IF
      IF (IERR .EQ. 0) CALL F7STEP(IST, LROW, IERR)
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0 .AND. .NOT. LROW) IERR = IFNL
      RETURN
      END

C @brief Computes linearized seawater density anomaly sigma-t (kg/m**3).
C @param DTC In-situ temperature in degrees Celsius.
C @param DSAL Practical salinity in PSU.
C @return Seawater density anomaly sigma-t.
      DOUBLE PRECISION FUNCTION SIGT77(DTC, DSAL)
      DOUBLE PRECISION DTC, DSAL
      SIGT77 = 28.14D0 - 0.0735D0 * DTC - 0.00469D0 * DTC * DTC +
     1         (0.802D0 - 0.002D0 * DTC) * (DSAL - 35.0D0)
      RETURN
      END
