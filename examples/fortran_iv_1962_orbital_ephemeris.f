C @file fortran_iv_1962_orbital_ephemeris.f
C @brief 1962 IBM 7090 FORTRAN IV orbital ephemeris propagator example.
C
C Uses authentic 1962 FORTRAN IV features: BLOCK DATA CORMBD, explicit
C INTEGER / DOUBLE PRECISION / LOGICAL typing, logical IF (.NOT., .GT.),
C transactional rollback of an aborted burn, and column-major 2D matrix
C persistence with leading-dimension padding (LDROWS = 6, NROWS = 5).
      EXTERNAL CORMBD
      INTEGER IHURL(8), IHDDL(23), IHINS(29), IHSEL(21), IHABT(22)
      INTEGER IDB, K, NOUT
      DOUBLE PRECISION EPHEM(6, 3), EPOUT(6, 3)
      DOUBLE PRECISION GMU, SMA, RKM, VKMS, E0, DERR, ORBENG
      LOGICAL LOK
      DATA IHURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE ORB(R,V,E)" (23 chars)
      DATA IHDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,79,82,66,40,
     1            82,44,86,44,69,41/
C "INSERT INTO ORB VALUES(?,?,?)" (29 chars)
      DATA IHINS /73,78,83,69,82,84,32,73,78,84,79,32,79,82,66,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,41/
C "SELECT R,V,E FROM ORB" (21 chars)
      DATA IHSEL /83,69,76,69,67,84,32,82,44,86,44,69,32,70,82,79,77,
     1            32,79,82,66/
C "DELETE FROM ORB" + spaces (22 chars)
      DATA IHABT /68,69,76,69,84,69,32,70,82,79,77,32,79,82,66,7*32/
      GMU = 398600.4418D0
      SMA = 6778.0D0
      DO 10 K = 1, 6
        EPHEM(K, 1) = 0.0D0
        EPHEM(K, 2) = 0.0D0
        EPHEM(K, 3) = 0.0D0
        EPOUT(K, 1) = 0.0D0
        EPOUT(K, 2) = 0.0D0
        EPOUT(K, 3) = 0.0D0
   10 CONTINUE
      DO 20 K = 1, 5
        RKM = 6678.0D0 + DBLE(K - 1) * 50.0D0
        VKMS = DSQRT(GMU * (2.0D0 / RKM - 1.0D0 / SMA))
        EPHEM(K, 1) = RKM
        EPHEM(K, 2) = VKMS
        EPHEM(K, 3) = ORBENG(RKM, VKMS)
   20 CONTINUE
      IDB = 0
      CALL F4OPEN(IHURL, 8, IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4EXEC(IDB, IHDDL, 23, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4MATI(IDB, IHINS, 29, EPHEM, 6, 5, 3, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXCM(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4EXEC(IDB, IHABT, 15, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXRB(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      NOUT = 0
      CALL F4MATQ(IDB, IHSEL, 21, EPOUT, 6, 5, 3, NOUT, LOK)
      IF (.NOT. LOK .OR. NOUT .NE. 5) STOP 1
      E0 = -GMU / (2.0D0 * SMA)
      DERR = 0.0D0
      DO 30 K = 1, 5
        DERR = DERR + DABS(EPOUT(K, 3) - E0)
   30 CONTINUE
      IF (DERR .GT. 1.0D-8) STOP 1
      CALL F4CLOS(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      WRITE (6, 100) NOUT, E0
  100 FORMAT (I4, F12.4)
      STOP
      END

C @brief Computes Vis-Viva specific orbital energy (km**2 / s**2).
C @param RKM Orbital radius in kilometers.
C @param VKMS Orbital speed in kilometers per second.
C @return Specific mechanical energy v**2 / 2 - mu / r.
      DOUBLE PRECISION FUNCTION ORBENG(RKM, VKMS)
      DOUBLE PRECISION RKM, VKMS, GMU
      GMU = 398600.4418D0
      ORBENG = 0.5D0 * VKMS * VKMS - GMU / RKM
      RETURN
      END
