C @file fortran_iii_1958_magnet_coil_quench.f
C @brief 1958-59 IBM FORTRAN III Alternating-Gradient Synchrotron (AGS)
C magnet-sector current-ramp 2D matrix & quench-interlock rollback deck.
C
C Exercises F3OPEN, F3GEX, F3TXBG, F3TXCM, F3TXRB, F3MATI, F3MATQ,
C F3PREP, F3STEP, F3COLD, F3FINL, IF3BIT, IF3ALL, and /CORM3C/.

C @brief Computes stored magnetic energy EMJ (MJ) and resistive bus
C voltage VBUS (V) for synchrotron dipole sector K at current AMPS.
C @param LSEC Inductance in Henries.
C @param RSEC Warm copper coil resistance in Ohms.
C @param DIDT Ramp rate dI/dt in Amperes/second.
C @param AMPS Instantaneous excitation current in Amperes.
C @param EMJ Receives stored magnetic field energy in Megajoules.
C @param VBUS Receives terminal excitation voltage L*dI/dt + I*R.
      SUBROUTINE MAG59(LSEC, RSEC, DIDT, AMPS, EMJ, VBUS)
      DOUBLE PRECISION LSEC, RSEC, DIDT, AMPS, EMJ, VBUS
      EMJ = 0.5D0 * LSEC * AMPS * AMPS * 1.0D-6
      VBUS = LSEC * DIDT + RSEC * AMPS
      RETURN
      END

C @brief Returns boolean status word 3 if sector bus voltage is within
C ignitron rectifier ceiling VMAX, else 0 (quench/crowbar trip).
C @param VBUS Terminal sector voltage in Volts.
C @param VMAX Maximum safe ignitron voltage in Volts.
C @return 3 when safe, 0 on crowbar trip.
      INTEGER FUNCTION IQCHK(VBUS, VMAX)
      DOUBLE PRECISION VBUS, VMAX
      IF (VBUS - VMAX) 10, 10, 20
   10 IQCHK = 3
      RETURN
   20 IQCHK = 0
      RETURN
      END

C @brief Main 1958-59 FORTRAN III synchrotron magnet quench program.
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION RMAT(8, 3), QMAT(8, 3), AMPS(6), LSEC, RSEC
      DOUBLE PRECISION DIDT, EMJ, VBUS, ETOT, DERR, EMAX
      DIMENSION IURL(8), IDDL(22), IMINS(28), IMSEL(20), IMAXQ(21)
      DATA IURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE MG(I,E,V)" (22 chars)
      DATA IDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,77,71,40,
     1           73,44,69,44,86,41/
C "INSERT INTO MG VALUES(?,?,?)" (28 chars)
      DATA IMINS /73,78,83,69,82,84,32,73,78,84,79,32,77,71,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,41/
C "SELECT I,E,V FROM MG" (20 chars)
      DATA IMSEL /83,69,76,69,67,84,32,73,44,69,44,86,32,70,82,79,
     1            77,32,77,71/
C "SELECT MAX(E) FROM MG" (21 chars)
      DATA IMAXQ /83,69,76,69,67,84,32,77,65,88,40,69,41,32,70,82,
     1            79,77,32,77,71/
      DATA AMPS /1000.0D0, 2200.0D0, 3400.0D0, 4600.0D0, 5800.0D0,
     1           6500.0D0/
      LSEC = 0.72D0
      RSEC = 0.18D0
      CALL F3OPEN(IURL, 8, IDB, IW)
      IF (IW - 3) 900, 10, 900
   10 CALL F3GEX(IDB, IDDL, 22, IW)
      IF (IW - 3) 900, 15, 900
C 1. Simulate excessive ramp rate dI/dt = 9500 A/s -> crowbar rollback!
   15 DIDT = 9500.0D0
      CALL F3TXBG(IDB, IW)
      IF (IW - 3) 900, 18, 900
   18 ISAFE = 3
      DO 25 K = 1, 6
      CALL MAG59(LSEC, RSEC, DIDT, AMPS(K), EMJ, VBUS)
      RMAT(K, 1) = AMPS(K)
      RMAT(K, 2) = EMJ
      RMAT(K, 3) = VBUS
      ISAFE = IF3ALL(ISAFE, IQCHK(VBUS, 7500.0D0))
   25 CONTINUE
      CALL F3MATI(IDB, IMINS, 28, RMAT, 8, 6, 3, IWM)
      IF (IWM - 3) 900, 28, 900
C ISAFE must have tripped to 0 -> roll back quenched ramp!
   28 IF (ISAFE) 900, 30, 900
   30 CALL F3TXRB(IDB, IW)
      IF (IW - 3) 900, 35, 900
C 2. Nominal flattop ramp dI/dt = 6000 A/s -> commit 6-step matrix!
   35 DIDT = 6000.0D0
      CALL F3TXBG(IDB, IW)
      IF (IW - 3) 900, 38, 900
   38 ISAFE = 3
      DO 45 K = 1, 6
      CALL MAG59(LSEC, RSEC, DIDT, AMPS(K), EMJ, VBUS)
      RMAT(K, 1) = AMPS(K)
      RMAT(K, 2) = EMJ
      RMAT(K, 3) = VBUS
      ISAFE = IF3ALL(ISAFE, IQCHK(VBUS, 7500.0D0))
   45 CONTINUE
      RMAT(7, 1) = 0.0D0
      RMAT(8, 1) = 0.0D0
      IF (ISAFE - 3) 900, 48, 900
   48 CALL F3MATI(IDB, IMINS, 28, RMAT, 8, 6, 3, IWM)
      IW = IF3ALL(IW, IWM)
      IF (IW - 3) 900, 50, 900
   50 CALL F3TXCM(IDB, IW)
      IF (IW - 3) 900, 55, 900
C Hydrate 2D ramp matrix via F3MATQ and verify peak stored energy
   55 CALL F3MATQ(IDB, IMSEL, 20, QMAT, 8, 8, 3, NROWS, IW)
      IF (IW - 3) 900, 58, 900
   58 IF (NROWS - 6) 900, 60, 900
   60 ETOT = 0.0D0
      DO 62 K = 1, 6
      ETOT = ETOT + QMAT(K, 2)
   62 CONTINUE
      CALL F3PREP(IDB, IMAXQ, 21, IST, IW)
      CALL F3STEP(IDB, IST, IHAS, IWS)
      CALL F3COLD(IDB, IST, 1, EMAX, IWC)
      CALL F3FINL(IDB, IST, IWF)
      IW = IF3ALL(IF3ALL(IW, IWS), IF3ALL(IWC, IWF))
      IF (IF3BIT(IW, 1) * IF3BIT(IW, 2) - 1 + 0 * IHAS) 900, 65, 900
C Peak energy at 6500 A: 0.5 * 0.72 * 6500^2 * 1e-6 = 15.21 MJ
   65 DERR = EMAX - 15.21D0
      IF (DERR * DERR - 1.0D-12) 70, 70, 900
   70 CALL F3CLOS(IDB, IW)
      IF (IW - 1 + 0 * I3STAT + 0 * I3WORD + 0 * I3DB + 0 * I3STMT)
     1 900, 75, 900
   75 WRITE (6, 100) NROWS, EMAX, ETOT
  100 FORMAT (I6, 2F12.4)
      STOP
  900 STOP 1
      END
