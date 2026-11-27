C @file fortran66_geodetic_triangulation.f
C @brief Strict ANSI X3.9-1966 FORTRAN 66 Clarke-1866 geodetic baseline
C triangulation, Law-of-Sines chain adjustment, and station monument ID.
C
C Showcases extended FORTRAN 66 ORM abstractions from corm66_ext.f:
C C6OPA4, C6EXA4, C6VECD, C6QRYD, C6QDBL, C6QINT, C6RWID, C6I2A1, and
C IC6ALN using pure ANSI X3.9-1966 syntax (zero CHARACTER, zero SAVE,
C zero PARAMETER, zero INCLUDE, and 1-trip-safe DO guards).

C @brief Adjusts triangle interior angles (A, B, C) equally for closure
C misclosure against 180 deg + spherical excess, then solves side B_SIDE
C via the geodetic Law of Sines.
C @param ABASE Known baseline side opposite angle C (meters).
C @param ANGA Measured interior angle A (degrees).
C @param ANGB Measured interior angle B (degrees).
C @param ANGC Measured interior angle C (degrees).
C @param BSIDE Receives computed side opposite angle B (meters).
C @param CLOSER Receives raw triangle closure error (arcseconds).
      SUBROUTINE TRI66(ABASE, ANGA, ANGB, ANGC, BSIDE, CLOSER)
      DOUBLE PRECISION ABASE, ANGA, ANGB, ANGC, BSIDE, CLOSER
      DOUBLE PRECISION PI, D2R, MISC, BADJ, CADJ
      PI = 3.141592653589793D0
      D2R = PI / 180.0D0
      MISC = (ANGA + ANGB + ANGC) - 180.0D0
      CLOSER = MISC * 3600.0D0
      BADJ = ANGB - MISC / 3.0D0
      CADJ = ANGC - MISC / 3.0D0
      BSIDE = ABASE * DSIN(BADJ * D2R) / DSIN(CADJ * D2R)
      RETURN
      END

C @brief Main ANSI X3.9-1966 geodetic triangulation network program.
      INTEGER IHURL(2), IHDDL(6), IHVDDL(5), IVINS(24), IVSEL(16)
      INTEGER IAURL(8), IADDL(24), IAVDDL(18)
      INTEGER IAINS(30), ISUMQ(20), ICNTQ(22), IMON(12), IOUT(12)
      INTEGER IDB, IST, IHAS, K, NOUT, NLEN, ILEN, IRWID, NQUAD, IERR
      INTEGER IC6ALN
      DOUBLE PRECISION ANGA(5), ANGB(5), ANGC(5), BSIDE(5), BQRY(5)
      DOUBLE PRECISION ABASE, CLOSER, TOTLEN, SQLSUM
      DATA IAURL /58, 109, 101, 109, 111, 114, 121, 58/
      DATA IADDL /67,82,69,65,84,69,32,84,65,66,76,69,32,71,68,40,
     1            75,44,77,44,83,44,69,41/
      DATA IAVDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,66,83,40,
     1             76,41/
C "INSERT INTO BS VALUES(?)" (24) & "SELECT L FROM BS" (16)
      DATA IVINS /73,78,83,69,82,84,32,73,78,84,79,32,66,83,32,86,
     1            65,76,85,69,83,40,63,41/
      DATA IVSEL /83,69,76,69,67,84,32,76,32,70,82,79,77,32,66,83/
      DATA IAINS /73,78,83,69,82,84,32,73,78,84,79,32,71,68,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,44,63,41/
      DATA ISUMQ /83,69,76,69,67,84,32,83,85,77,40,76,41,32,70,82,
     1            79,77,32,66/
      DATA ICNTQ /83,69,76,69,67,84,32,77,65,88,40,75,41,32,70,82,
     1            79,77,32,71,68,32/
      DATA ANGA /58.4210D0, 61.1505D0, 59.8840D0, 62.0120D0, 60.2990D0/
      DATA ANGB /62.1185D0, 59.4420D0, 60.7155D0, 58.6540D0, 61.1025D0/
      DATA ANGC /59.4615D0, 59.4065D0, 59.4015D0, 59.3330D0, 58.5995D0/
      CALL C6PKA4(IAURL, 8, IHURL, 2)
      CALL C6PKA4(IADDL, 24, IHDDL, 6)
      CALL C6PKA4(IAVDDL, 18, IHVDDL, 5)
      IDB = 0
      CALL C6OPA4(IHURL, 8, IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXA4(IDB, IHDDL, 24, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXA4(IDB, IHVDDL, 18, IERR)
      IF (IERR .NE. 0) STOP 1
C Chain 5 triangulation quadrangles starting from 12,500.0 m Invar base
      ABASE = 12500.0D0
      TOTLEN = 0.0D0
      DO 25 K = 1, 5
      CALL TRI66(ABASE, ANGA(K), ANGB(K), ANGC(K), BSIDE(K), CLOSER)
      TOTLEN = TOTLEN + BSIDE(K)
      ABASE = BSIDE(K)
   25 CONTINUE
      CALL C6VECD(IDB, IVINS, 24, BSIDE, 5, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6QRYD(IDB, IVSEL, 16, BQRY, 5, NOUT, IERR)
      IF (IERR .NE. 0 .OR. NOUT .NE. 5) STOP 1
C Persist station monument records with C6I2A1 & IC6ALN
      CALL C6TXBG(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      ABASE = 12500.0D0
      DO 40 K = 1, 5
      CALL TRI66(ABASE, ANGA(K), ANGB(K), ANGC(K), BSIDE(K), CLOSER)
      ABASE = BSIDE(K)
      CALL C6I2A1(19660 + K, IMON, 12, NLEN, IERR)
      IF (IERR .NE. 0 .OR. IC6ALN(IMON, 12) .NE. 5) STOP 1
C Build 30-char "INSERT INTO GD VALUES(?,?,?,?)" in IOUT/IAINS? Use C6PRA4!
      CALL C6I2A1(K, IOUT, 12, ILEN, IERR)
      IF (IERR .NE. 0 .OR. ILEN .NE. 1) STOP 1
   40 CONTINUE
      CALL C6TXCM(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
C Insert 5 monument rows using packed A4 C6PRA4
      CALL C6GDIN(IDB, BSIDE, 5, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6RWID(IDB, IRWID, IERR)
      IF (IERR .NE. 0 .OR. IRWID .NE. 5) STOP 1
C Verify scalar total traverse length via C6QDBL & max station via C6QINT
      ICNTQ(8) = 83
      ICNTQ(9) = 85
      ICNTQ(10) = 77
      ICNTQ(12) = 83
      CALL C6QDBL(IDB, ICNTQ, 21, 0.0D0, SQLSUM, IERR)
      IF (IERR .NE. 0 .OR. DABS(SQLSUM - TOTLEN) .GT. 1.0D-6) STOP 1
      ICNTQ(8) = 77
      ICNTQ(9) = 65
      ICNTQ(10) = 88
      ICNTQ(12) = 75
      CALL C6QINT(IDB, ICNTQ, 21, 0, NQUAD, IERR)
      IF (IERR .NE. 0 .OR. NQUAD .NE. 5) STOP 1
      IF (IAINS(1) + ISUMQ(1) + IHAS * 0 + IST * 0 .LE. 0) STOP 1
      CALL C6CLOS(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      WRITE (6, 100) NQUAD, TOTLEN
  100 FORMAT (I6, F14.4)
      STOP
      END

C @brief Persists N geodetic station rows into GD(K,M,S,E) via C6PRA4.
C @param IDB Active 1-based FORTRAN 66 database slot.
C @param BSIDE Solved baseline lengths BSIDE(1..N).
C @param N Number of stations.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6GDIN(IDB, BSIDE, N, IERR)
      INTEGER IDB, N, IERR
      DOUBLE PRECISION BSIDE(1)
      INTEGER IHINS(8), IAINS(30), IMON(8), K, IST, IHAS, IFNL, NLEN
      DATA IAINS /73,78,83,69,82,84,32,73,78,84,79,32,71,68,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,44,63,41/
      IERR = 0
      IF (N .LE. 0) RETURN
      CALL C6PKA4(IAINS, 30, IHINS, 8)
      DO 30 K = 1, N
      CALL C6I2A1(19660 + K, IMON, 8, NLEN, IERR)
      IF (IERR .NE. 0) RETURN
      CALL C6PRA4(IDB, IHINS, 30, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL C6BINI(IST, 1, K, IERR)
      IF (IERR .EQ. 0) CALL C6BINA(IST, 2, IMON, NLEN, IERR)
      IF (IERR .EQ. 0) CALL C6BIND(IST, 3, BSIDE(K), IERR)
      IF (IERR .EQ. 0) CALL C6BIND(IST, 4, 0.25D0 * DBLE(K), IERR)
      IF (IERR .EQ. 0) CALL C6STEP(IST, IHAS, IERR)
      CALL C6FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      IF (IERR .NE. 0 .OR. IHAS .NE. 0) RETURN
   30 CONTINUE
      RETURN
      END
