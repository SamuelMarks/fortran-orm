C @file fortran77_distillation_tray_column.f
C @brief Strict ANSI X3.9-1978 FORTRAN 77 McCabe-Thiele binary
C benzene-toluene rectification column tray solver & SQL AST auditor.
C
C Showcases F7CNT, F7EXST, F7DELI, F7QINT, F7QDBL, F7QCHR, F7KVCR,
C F7KVPT, F7KVGT, and F7ASAL across SQLite, PostgreSQL, and IBM Db2.

C @brief Vapor-liquid equilibrium mole fraction Y(X) at constant
C relative volatility ALPHA: Y = ALPHA * X / (1 + (ALPHA - 1) * X).
C @param XLIQ Liquid mole fraction of benzene on tray.
C @param ALPHA Relative volatility (2.45 for benzene-toluene at 1 atm).
C @return Equilibrium vapor mole fraction Y.
      DOUBLE PRECISION FUNCTION DVLE77(XLIQ, ALPHA)
      DOUBLE PRECISION XLIQ, ALPHA
      DVLE77 = (ALPHA * XLIQ) / (1.0D0 + (ALPHA - 1.0D0) * XLIQ)
      RETURN
      END

C @brief Inverse VLE liquid mole fraction X(Y) in equilibrium with Y.
C @param YVAP Vapor mole fraction rising from tray below.
C @param ALPHA Relative volatility.
C @return Equilibrium liquid mole fraction X.
      DOUBLE PRECISION FUNCTION DXEQ77(YVAP, ALPHA)
      DOUBLE PRECISION YVAP, ALPHA
      DXEQ77 = YVAP / (ALPHA - (ALPHA - 1.0D0) * YVAP)
      RETURN
      END

C @brief Main ANSI X3.9-1978 binary distillation column solver.
      PROGRAM DIST77
      INCLUDE 'fortran_orm_f77.inc'
      INTEGER IDB, IST, NTRAY, NROWS, ILEN, IERR, ICHK
      LOGICAL LEX, LROW, LFOUND
      CHARACTER*64 CFEED, CASTPG, CASTDB
      DOUBLE PRECISION ALPHA, XD, XF, XB, RREFL, LS, VS, XCUR, YNEXT
      DOUBLE PRECISION XMIN, DVLE77, DXEQ77
      ICHK = CMEMER + CCNNER + CSQLER + CBNDER + CSTPER + CTYPER +
     1       CNTFND + CVALER + CNULPT + CCONER + CTIMER + CTRUNC +
     2       CHNDER + CFULER + CBUFER + CIDXER + COPCER + CDSQLT +
     3       CDPG + CDMY + CDDB2 + CDODBC
      IF (ICHK .LE. 0) STOP 1
      ALPHA = 2.45D0
      XD = 0.960D0
      XF = 0.450D0
      XB = 0.040D0
      RREFL = 2.60D0
C Saturated-liquid feed q = 1: stripping L'/V' from intersection at XF
      YNEXT = (RREFL / (RREFL + 1.0D0)) * XF + XD / (RREFL + 1.0D0)
      LS = (YNEXT - XB) / (XF - XB)
      VS = 1.0D0
      CALL F7OPEN(':memory:', IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7KVCR(IDB, 'COL_CFG', IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7KVPT(IDB, 'COL_CFG', 'SYSTEM', 'BENZENE_TOLUENE_1ATM',
     1            IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7EXEC(IDB,
     1  'CREATE TABLE TRAYS(N INT PRIMARY KEY, SEC TEXT, X REAL, ' //
     2  'Y REAL)', IERR)
      IF (IERR .NE. CORMOK) STOP 1
C Step off theoretical equilibrium stages from overhead condenser XD
      CALL F7TXBG(IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7PREP(IDB, 'INSERT INTO TRAYS VALUES(?,?,?,?)', IST, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      YNEXT = XD
      NTRAY = 0
   10 NTRAY = NTRAY + 1
      XCUR = DXEQ77(YNEXT, ALPHA)
      CALL F7BINI(IST, 1, NTRAY, IERR)
      IF (XCUR .GE. XF) THEN
        CALL F7BINC(IST, 2, 'RECTIFYING', IERR)
      ELSE
        CALL F7BINC(IST, 2, 'STRIPPING', IERR)
      END IF
      IF (IERR .EQ. CORMOK) CALL F7BIND(IST, 3, XCUR, IERR)
      IF (IERR .EQ. CORMOK) CALL F7BIND(IST, 4, YNEXT, IERR)
      IF (IERR .EQ. CORMOK) CALL F7STEP(IST, LROW, IERR)
      IF (IERR .EQ. CORMOK) CALL F7RSET(IST, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      IF (XCUR .GE. XF) THEN
        YNEXT = (RREFL / (RREFL + 1.0D0)) * XCUR + XD / (RREFL + 1.0D0)
      ELSE
        YNEXT = (LS / VS) * (XCUR - XB) + XB
      END IF
      IF (XCUR .GT. XB .AND. NTRAY .LT. 25) GO TO 10
C Insert a dummy maintenance stage 99 and prune it via F7EXST + F7DELI
      CALL F7BINI(IST, 1, 99, IERR)
      IF (IERR .EQ. CORMOK) CALL F7BINC(IST, 2, 'BYPASS', IERR)
      IF (IERR .EQ. CORMOK) CALL F7BIND(IST, 3, 0.0D0, IERR)
      IF (IERR .EQ. CORMOK) CALL F7BIND(IST, 4, DVLE77(0.0D0, ALPHA),
     1                                  IERR)
      IF (IERR .EQ. CORMOK) CALL F7STEP(IST, LROW, IERR)
      CALL F7FINL(IST, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7TXCM(IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7EXST(IDB, 'TRAYS', 'N', 99, LEX, IERR)
      IF (IERR .NE. CORMOK .OR. .NOT. LEX) STOP 1
      CALL F7DELI(IDB, 'TRAYS', 'N', 99, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      CALL F7EXST(IDB, 'TRAYS', 'N', 99, LEX, IERR)
      IF (IERR .NE. CORMOK .OR. LEX) STOP 1
C Audit stage count, bottoms purity, and AST dialect SQL generation
      CALL F7CNT(IDB, 'TRAYS', NROWS, IERR)
      IF (IERR .NE. CORMOK .OR. NROWS .NE. NTRAY) STOP 1
      IF (NTRAY .LT. 8 .OR. NTRAY .GT. 16) STOP 1
      CALL F7QDBL(IDB, 'SELECT MIN(X) FROM TRAYS', 1.0D0, XMIN, IERR)
      IF (IERR .NE. CORMOK .OR. XMIN .GT. XB) STOP 1
      CALL F7QCHR(IDB, 'SELECT SEC FROM TRAYS WHERE N = 1', 'NONE',
     1            CFEED, ILEN, IERR)
      IF (IERR .NE. CORMOK .OR. CFEED(1:ILEN) .NE. 'RECTIFYING') STOP 1
      CALL F7KVGT(IDB, 'COL_CFG', 'SYSTEM', CFEED, ILEN, LFOUND, IERR)
      IF (IERR .NE. CORMOK .OR. .NOT. LFOUND) STOP 1
      CALL F7ASAL('TRAYS', 5, CDPG, CASTPG, ILEN, IERR)
      IF (IERR .NE. CORMOK .OR. INDEX(CASTPG, 'LIMIT 5') .EQ. 0) STOP 1
      CALL F7ASAL('TRAYS', 5, CDDB2, CASTDB, ILEN, IERR)
      IF (IERR .NE. CORMOK .OR. INDEX(CASTDB, 'FETCH FIRST') .EQ. 0)
     1  STOP 1
      CALL F7CLOS(IDB, IERR)
      IF (IERR .NE. CORMOK) STOP 1
      WRITE (6, '(A,I4,F10.5)') CFEED(1:20), NTRAY, XMIN
      END
