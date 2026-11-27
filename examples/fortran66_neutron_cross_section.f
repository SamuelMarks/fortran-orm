C @file fortran66_neutron_cross_section.f
C @brief Strict ANSI X3.9-1966 FORTRAN 66 ENDF thermal/epithermal U-235
C 1/v + Breit-Wigner resonance cross-section lookup & reaction-rate deck.
C
C Showcases C6OPA4, C6EXA4, C6KVIN, C6KVIT, C6MATI, C6MATQ, and C6QDBL
C from corm66_lib.f and corm66_ext.f in pure 1966 ANSI standard syntax.

C @brief Evaluates U-235 microscopic absorption cross section SIGB
C (barns) combining a 1/v thermal tail and 0.29 eV Breit-Wigner peak.
C @param EEV Incident neutron kinetic energy in electron-volts (eV).
C @param SIGB Receives microscopic cross section in barns.
      SUBROUTINE XS66(EEV, SIGB)
      DOUBLE PRECISION EEV, SIGB
      DOUBLE PRECISION E0, ER, GAM, S0, DEN
      E0 = 0.0253D0
      ER = 0.290D0
      GAM = 0.135D0
      S0 = 681.0D0
      DEN = 4.0D0 * (EEV - ER) * (EEV - ER) + GAM * GAM
      SIGB = S0 * DSQRT(E0 / EEV) + (240.0D0 * GAM * GAM) / DEN
      RETURN
      END

C @brief Main ANSI X3.9-1966 neutron cross-section interpolation program.
      INTEGER IHURL(2), IHDDL(6), IMINS(28), IMSEL(20), IAVGQ(20)
      INTEGER IAURL(8), IADDL(22)
      INTEGER IDB, K, NROWS, IERR
      DOUBLE PRECISION EKNOT(7), SKNOT(7), EQRY(5), RMAT(6, 3)
      DOUBLE PRECISION QMAT(6, 3), SINT, SEXACT, FLUX, RRATE, AVGR
      DATA IAURL /58, 109, 101, 109, 111, 114, 121, 58/
      DATA IADDL /67,82,69,65,84,69,32,84,65,66,76,69,32,82,88,40,
     1            69,44,83,44,82,41/
C "INSERT INTO RX VALUES(?,?,?)" (28 chars)
      DATA IMINS /73,78,83,69,82,84,32,73,78,84,79,32,82,88,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,41/
C "SELECT E,S,R FROM RX" (20 chars)
      DATA IMSEL /83,69,76,69,67,84,32,69,44,83,44,82,32,70,82,79,
     1            77,32,82,88/
      DATA IAVGQ /83,69,76,69,67,84,32,83,85,77,40,82,41,32,70,82,
     1            79,77,32,82/
      DATA EKNOT /0.010D0, 0.0253D0, 0.080D0, 0.200D0, 0.290D0,
     1            0.450D0, 1.000D0/
      DATA EQRY  /0.0253D0, 0.050D0, 0.245D0, 0.290D0, 0.725D0/
      CALL C6PKA4(IAURL, 8, IHURL, 2)
      CALL C6PKA4(IADDL, 22, IHDDL, 6)
      IDB = 0
      CALL C6OPA4(IHURL, 8, IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXA4(IDB, IHDDL, 22, IERR)
      IF (IERR .NE. 0) STOP 1
C Populate 7-knot ENDF empirical lookup table L6 via C6KVIN
      DO 15 K = 1, 7
      CALL XS66(EKNOT(K), SKNOT(K))
   15 CONTINUE
      CALL C6KVIN(IDB, EKNOT, SKNOT, 7, IERR)
      IF (IERR .NE. 0) STOP 1
C Interpolate 5 energies via C6KVIT and compute macroscopic reaction rate
      FLUX = 2.5D13
      AVGR = 0.0D0
      DO 30 K = 1, 5
      CALL C6KVIT(IDB, EQRY(K), SINT, IERR)
      IF (IERR .NE. 0 .OR. SINT .LE. 100.0D0) STOP 1
      RRATE = 0.048D0 * SINT * FLUX * 1.0D-12
      RMAT(K, 1) = EQRY(K)
      RMAT(K, 2) = SINT
      RMAT(K, 3) = RRATE
      AVGR = AVGR + RRATE
   30 CONTINUE
      RMAT(6, 1) = 0.0D0
      RMAT(6, 2) = 0.0D0
      RMAT(6, 3) = 0.0D0
C Verify exact knot reproduction at thermal 0.0253 eV & 0.290 eV peak
      CALL XS66(0.0253D0, SEXACT)
      IF (DABS(RMAT(1, 2) - SEXACT) .GT. 1.0D-9) STOP 1
      CALL XS66(0.290D0, SEXACT)
      IF (DABS(RMAT(4, 2) - SEXACT) .GT. 1.0D-9) STOP 1
C Persist 5x3 group reaction-rate matrix into RX via C6MATI & C6MATQ
      CALL C6MATI(IDB, IMINS, 28, RMAT, 6, 5, 3, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6MATQ(IDB, IMSEL, 20, QMAT, 6, 6, 3, NROWS, IERR)
      IF (IERR .NE. 0 .OR. NROWS .NE. 5) STOP 1
      IF (DABS(QMAT(5, 3) - RMAT(5, 3)) .GT. 1.0D-9) STOP 1
C Check scalar query on IMSEL (first energy 0.0253)
      CALL C6QDBL(IDB, IMSEL, 20, 0.0D0, SEXACT, IERR)
      IF (IERR .NE. 0 .OR. DABS(SEXACT - 0.0253D0) .GT. 1.0D-9) STOP 1
      IF (IAVGQ(1) .LE. 0) STOP 1
      CALL C6CLOS(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      WRITE (6, 100) NROWS, QMAT(1, 2), AVGR
  100 FORMAT (I6, 2F14.4)
      STOP
      END
