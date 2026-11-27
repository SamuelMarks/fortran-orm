C @file fortran77_atmospheric_radiosonde.f
C @brief Strict ANSI X3.9-1978 FORTRAN 77 WMO mandatory-level upper-air
C radiosonde hypsometric sounding, lapse-rate & tropopause finder.
C
C Showcases extended FORTRAN 77 ORM abstractions from corm77_orm.f:
C F7KVCR, F7KVPT, F7KVGT, F7VECD, F7QRYD, F7QDBL, F7QINT, F7CNT, and
C LF7TRM alongside INCLUDE 'fortran_orm_f77.inc'.

C @brief Integrates geopotential thickness DZ (m) between pressure P1
C and P2 (hPa) using the dry/moist virtual-temperature hypsometric law.
C @param P1 Lower-altitude mandatory pressure in hPa.
C @param P2 Upper-altitude mandatory pressure in hPa.
C @param TK1 Virtual temperature at P1 in Kelvin.
C @param TK2 Virtual temperature at P2 in Kelvin.
C @return Layer geopotential thickness in meters.
      DOUBLE PRECISION FUNCTION DHYPS7(P1, P2, TK1, TK2)
      DOUBLE PRECISION P1, P2, TK1, TK2
      DOUBLE PRECISION RD, G0, TBAR
      RD = 287.058D0
      G0 = 9.80665D0
      TBAR = 0.5D0 * (TK1 + TK2)
      DHYPS7 = (RD * TBAR / G0) * DLOG(P1 / P2)
      RETURN
      END

C @brief Main ANSI X3.9-1978 WMO radiosonde sounding program.
      PROGRAM RSONDE
      INCLUDE 'fortran_orm_f77.inc'
      INTEGER IDB, IST, K, NOUT, NROWS, ILEN, ITROP, IERR, ICHK, LF7TRM
      LOGICAL LFOUND, LROW
      CHARACTER*32 CSTA, CVAL
      DOUBLE PRECISION PMB(7), TCEL(7), ZGPM(7), ZQRY(7), SMAT(8, 3)
      DOUBLE PRECISION TK1, TK2, DZ, LAPSE, PTROP, ZMAX, DHYPS7
      DATA PMB  /1000.0D0, 850.0D0, 700.0D0, 500.0D0, 300.0D0,
     1           200.0D0, 100.0D0/
      DATA TCEL /15.0D0, 5.2D0, -4.6D0, -21.0D0, -44.5D0,
     1           -56.2D0, -56.5D0/
      ICHK = CMEMER + CCNNER + CSQLER + CBNDER + CSTPER + CTYPER +
     1       CNTFND + CVALER + CNULPT + CCONER + CTIMER + CTRUNC +
     2       CHNDER + CFULER + CBUFER + CIDXER + COPCER + CDSQLT +
     3       CDPG + CDMY + CDDB2 + CDODBC
      IF (ICHK .LE. 0) STOP 1
      CALL F7OPEN(':memory:', IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
C 1. Store WMO station header metadata in F7 Key-Value repository
      CALL F7KVCR(IDB, 'WMO_META', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7KVPT(IDB, 'WMO_META', 'WMO_ID', '72493_OAKLAND', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7KVPT(IDB, 'WMO_META', 'SYNOP_UTC', '1978-11-27T00Z', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7KVGT(IDB, 'WMO_META', 'WMO_ID', CSTA, ILEN, LFOUND, IERR)
      IF (IERR .NE. CORMOK .OR. .NOT. LFOUND) STOP 1
      IF (CSTA(1:ILEN) .NE. '72493_OAKLAND') STOP 1
C 2. Integrate mandatory-level geopotential heights & detect tropopause
      ZGPM(1) = 110.0D0
      ITROP = 0
      PTROP = 0.0D0
      DO 20 K = 2, 7
        TK1 = TCEL(K - 1) + 273.15D0
        TK2 = TCEL(K) + 273.15D0
        DZ = DHYPS7(PMB(K - 1), PMB(K), TK1, TK2)
        ZGPM(K) = ZGPM(K - 1) + DZ
        LAPSE = -(TCEL(K) - TCEL(K - 1)) / (DZ / 1000.0D0)
        IF (ITROP .EQ. 0 .AND. PMB(K) .LE. 500.0D0 .AND.
     1      LAPSE .LE. 2.0D0) THEN
          ITROP = K
          PTROP = PMB(K)
        END IF
   20 CONTINUE
C 3. Savepoint-guarded 1D vector persistence via F7VECD / F7QRYD
      CALL F7EXEC(IDB, 'CREATE TABLE ZLEV(Z REAL)', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7VECD(IDB, 'INSERT INTO ZLEV VALUES(?)', ZGPM, 7, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7QRYD(IDB, 'SELECT Z FROM ZLEV ORDER BY Z', ZQRY, 7, NOUT,
     1            IERR)
      IF (IERR .NE. CORMOK .OR. NOUT .NE. 7) STOP 1
C 4. Persist full 7x3 sounding profile (P, T, Z) & audit with F7QDBL/CNT
      CALL F7EXEC(IDB,
     1  'CREATE TABLE SOUNDING(P_HPA REAL, T_C REAL, Z_M REAL)', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      DO 30 K = 1, 7
        SMAT(K, 1) = PMB(K)
        SMAT(K, 2) = TCEL(K)
        SMAT(K, 3) = ZQRY(K)
   30 CONTINUE
      CALL F7MATI(IDB, 'INSERT INTO SOUNDING VALUES(?,?,?)', SMAT, 8,
     1            7, 3, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7CNT(IDB, 'SOUNDING', NROWS, IERR)
      IF (IERR .NE. CORMOK .OR. NROWS .NE. 7) STOP 1
      CALL F7QDBL(IDB, 'SELECT MAX(Z_M) FROM SOUNDING', 0.0D0, ZMAX,
     1            IERR)
      IF (IERR .NE. CORMOK) STOP 1
      IF (DABS(ZMAX - ZGPM(7)) .GT. 1.0D-6 .OR. ZMAX .LT. 15500.0D0)
     1  STOP 1
C Verify WMO tropopause detected at level 7 (100 hPa, lapse < 2 K/km)
      CALL F7PREP(IDB, 'SELECT COUNT(*) FROM SOUNDING WHERE T_C < -40',
     1            IST, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7STEP(IST, LROW, IERR)
      IF (IERR .NE. CORMOK .OR. .NOT. LROW) STOP 1
      CALL F7FINL(IST, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7QINT(IDB, 'SELECT COUNT(*) FROM SOUNDING WHERE T_C < -40',
     1            0, NOUT, IERR)
      IF (IERR .NE. CORMOK .OR. NOUT .NE. 3) STOP 1
      WRITE (CVAL, '(F6.1)') PTROP
      CALL F7KVPT(IDB, 'WMO_META', 'TROP_HPA', CVAL, IERR)
      IF (IERR .NE. CORMOK .OR. LF7TRM(CVAL) .LE. 0) STOP 1
      IF (ITROP .NE. 7) STOP 1
      CALL F7CLOS(IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      WRITE (6, '(A,I3,2F10.2)') CSTA(1:13), NROWS, PTROP, ZMAX
      END
