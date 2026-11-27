C @file fortran_ii_1958_lunar_ranging_doppler.f
C @brief 1958 VHF 108 MHz lunar radar bounce & Doppler range-rate pass
C ledger using packed A4 Hollerith ORM entry points.
C
C Exercises F2PKA4, F2OPA4, F2EXA4, F2PRA4, F2BNA4, F2CLA4, F2TXBG,
C F2TXCM, F2TXRB, F2BINI, F2BIND, F2COLD, F2COLI, F2RWID, F2A1CP, and
C IF2AEQ in authentic 1958 IBM FORTRAN II (zero LOGICAL/DATA/CHARACTER).

C @brief Computes two-way VHF lunar radar Doppler shift DFHZ (Hz) and
C round-trip light time RTTSEC (s) at slant range RKM and rate VRDKMS.
C @param FCARHZ Carrier frequency in Hz (108.0D6 Hz).
C @param RKM Instantaneous station-to-Moon slant range in km.
C @param VRDKMS Radial range rate in km/s (negative approaching).
C @param DFHZ Receives two-way Doppler shift in Hz.
C @param RTTSEC Receives two-way radar echo delay in seconds.
      SUBROUTINE DOP58(FCARHZ, RKM, VRDKMS, DFHZ, RTTSEC)
      DOUBLE PRECISION FCARHZ, RKM, VRDKMS, DFHZ, RTTSEC
      DOUBLE PRECISION CKMS
      CKMS = 299792.458D0
      DFHZ = -2.0D0 * FCARHZ * (VRDKMS / CKMS)
      RTTSEC = (2.0D0 * RKM) / CKMS
      RETURN
      END

C @brief Loads 4-char station callsign into packed A4 word IHW(1).
C @param ISTA Station index (1=JODR, 2=EVAN, 3=GOLD, 4=MILL, 5=WOOM).
C @param IHW Receives 1-word packed A4 Hollerith station code.
      SUBROUTINE STA58(ISTA, IHW)
      DIMENSION IHW(1), IA1(4)
      GO TO (10, 20, 30, 40, 50), ISTA
   10 IA1(1) = 74
      IA1(2) = 79
      IA1(3) = 68
      IA1(4) = 82
      GO TO 60
   20 IA1(1) = 69
      IA1(2) = 86
      IA1(3) = 65
      IA1(4) = 78
      GO TO 60
   30 IA1(1) = 71
      IA1(2) = 79
      IA1(3) = 76
      IA1(4) = 68
      GO TO 60
   40 IA1(1) = 77
      IA1(2) = 73
      IA1(3) = 76
      IA1(4) = 76
      GO TO 60
   50 IA1(1) = 87
      IA1(2) = 79
      IA1(3) = 79
      IA1(4) = 77
   60 CALL F2PKA4(IA1, 4, IHW, 1)
      RETURN
      END

C @brief Populates packed A4 SQL buffers IHURL, IHDDL, IHINS, IHSEL.
C @param IHURL Receives ":memory:" (2 words, 8 bytes).
C @param IHDDL Receives "CREATE TABLE LR(P,S,F,T)" (6 words, 24 bytes).
C @param IHINS Receives "INSERT INTO LR VALUES(?,?,?,?)" (8 words, 30B).
C @param IHSEL Receives "SELECT P,S,F,T FROM LR" (6 words, 22 bytes).
      SUBROUTINE SQL58L(IHURL, IHDDL, IHINS, IHSEL)
      DIMENSION IHURL(2), IHDDL(6), IHINS(8), IHSEL(6)
      DIMENSION IURL(8), IDDL(24), IINS(30), ISEL(22)
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
      CALL F2PKA4(IURL, 8, IHURL, 2)
      IDDL(1) = 67
      IDDL(2) = 82
      IDDL(3) = 69
      IDDL(4) = 65
      IDDL(5) = 84
      IDDL(6) = 69
      IDDL(7) = 32
      IDDL(8) = 84
      IDDL(9) = 65
      IDDL(10) = 66
      IDDL(11) = 76
      IDDL(12) = 69
      IDDL(13) = 32
      IDDL(14) = 76
      IDDL(15) = 82
      IDDL(16) = 40
      IDDL(17) = 80
      IDDL(18) = 44
      IDDL(19) = 83
      IDDL(20) = 44
      IDDL(21) = 70
      IDDL(22) = 44
      IDDL(23) = 84
      IDDL(24) = 41
      CALL F2PKA4(IDDL, 24, IHDDL, 6)
      IINS(1) = 73
      IINS(2) = 78
      IINS(3) = 83
      IINS(4) = 69
      IINS(5) = 82
      IINS(6) = 84
      IINS(7) = 32
      IINS(8) = 73
      IINS(9) = 78
      IINS(10) = 84
      IINS(11) = 79
      IINS(12) = 32
      IINS(13) = 76
      IINS(14) = 82
      IINS(15) = 32
      IINS(16) = 86
      IINS(17) = 65
      IINS(18) = 76
      IINS(19) = 85
      IINS(20) = 69
      IINS(21) = 83
      IINS(22) = 40
      IINS(23) = 63
      IINS(24) = 44
      IINS(25) = 63
      IINS(26) = 44
      IINS(27) = 63
      IINS(28) = 44
      IINS(29) = 63
      IINS(30) = 41
      CALL F2PKA4(IINS, 30, IHINS, 8)
      ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 80
      ISEL(9) = 44
      ISEL(10) = 83
      ISEL(11) = 44
      ISEL(12) = 70
      ISEL(13) = 44
      ISEL(14) = 84
      ISEL(15) = 32
      ISEL(16) = 70
      ISEL(17) = 82
      ISEL(18) = 79
      ISEL(19) = 77
      ISEL(20) = 32
      ISEL(21) = 76
      ISEL(22) = 82
      CALL F2PKA4(ISEL, 22, IHSEL, 6)
      RETURN
      END

C @brief Main 1958 FORTRAN II lunar radar Doppler pass program.
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION FCAR, RKM(5), VRAD(5), DFHZ, RTT, DFOUT, RTTOUT
      DOUBLE PRECISION SUMRTT, DERR
      DIMENSION IHURL(2), IHDDL(6), IHINS(8), IHSEL(6)
      DIMENSION IHSTA(1), IHOUT(2), IA1SRC(4), IA1DST(6)
      FCAR = 108.0D6
      RKM(1) = 363300.0D0
      VRAD(1) = -0.385D0
      RKM(2) = 371450.0D0
      VRAD(2) = -0.210D0
      RKM(3) = 384400.0D0
      VRAD(3) = 0.012D0
      RKM(4) = 396200.0D0
      VRAD(4) = 0.245D0
      RKM(5) = 405500.0D0
      VRAD(5) = 0.410D0
      CALL SQL58L(IHURL, IHDDL, IHINS, IHSEL)
      CALL F2OPA4(IHURL, 8, IDB, IERR)
      IF (IERR) 900, 10, 900
   10 IF (IF2OK(0) - 1) 900, 12, 900
   12 CALL F2EXA4(IDB, IHDDL, 24, IERR)
      IF (IERR) 900, 15, 900
C Stage a noisy solar-burst pass and abort via F2TXRB
   15 CALL F2TXBG(IDB, IERR)
      IF (IERR) 900, 16, 900
   16 CALL F2PRA4(IDB, IHINS, 30, IST, IERR)
      IF (IERR) 900, 17, 900
   17 CALL STA58(1, IHSTA)
      CALL F2BINI(IST, 1, 99, IERR)
      IF (IERR) 900, 18, 900
   18 CALL F2BNA4(IST, 2, IHSTA, 4, IERR)
      IF (IERR) 900, 19, 900
   19 CALL F2BIND(IST, 3, 99999.0D0, IERR)
      IF (IERR) 900, 20, 900
   20 CALL F2BIND(IST, 4, 0.0D0, IERR)
      IF (IERR) 900, 21, 900
   21 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 900, 22, 900
   22 CALL F2FINL(IST, IERR)
      IF (IERR) 900, 23, 900
   23 CALL F2TXRB(IDB, IERR)
      IF (IERR) 900, 25, 900
C Persist 5 calibrated lunar radar passes atomically via F2TXBG/F2TXCM
   25 CALL F2TXBG(IDB, IERR)
      IF (IERR) 900, 26, 900
   26 DO 40 K = 1, 5
      CALL STA58(K, IHSTA)
      CALL DOP58(FCAR, RKM(K), VRAD(K), DFHZ, RTT)
      CALL F2PRA4(IDB, IHINS, 30, IST, IERR)
      IF (IERR) 900, 28, 900
   28 CALL F2BINI(IST, 1, K, IERR)
      IF (IERR) 900, 30, 900
   30 CALL F2BNA4(IST, 2, IHSTA, 4, IERR)
      IF (IERR) 900, 32, 900
   32 CALL F2BIND(IST, 3, DFHZ, IERR)
      IF (IERR) 900, 34, 900
   34 CALL F2BIND(IST, 4, RTT, IERR)
      IF (IERR) 900, 36, 900
   36 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 900, 38, 900
   38 CALL F2FINL(IST, IERR)
      IF (IERR) 900, 40, 900
   40 CONTINUE
      CALL F2TXCM(IDB, IERR)
      IF (IERR) 900, 42, 900
   42 CALL F2RWID(IDB, IRWID, IERR)
      IF (IERR) 900, 44, 900
   44 IF (IRWID - 5) 900, 45, 900
   45 CALL F2PRA4(IDB, IHSEL, 22, IST, IERR)
      IF (IERR) 900, 48, 900
   48 NPASS = 0
      NAPPR = 0
      SUMRTT = 0.0D0
   50 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 900, 52, 900
   52 IF (IHAS) 900, 70, 54
   54 CALL F2COLI(IST, 1, JP, IERR)
      IF (IERR) 900, 56, 900
   56 CALL F2CLA4(IST, 2, IHOUT, 8, ILEN, IERR)
      IF (IERR) 900, 58, 900
   58 IF (ILEN - 4) 900, 60, 900
   60 CALL F2COLD(IST, 3, DFOUT, IERR)
      IF (IERR) 900, 62, 900
   62 CALL F2COLD(IST, 4, RTTOUT, IERR)
      IF (IERR) 900, 64, 900
   64 NPASS = NPASS + 1
      IF (JP - NPASS) 900, 65, 900
   65 SUMRTT = SUMRTT + RTTOUT
      IF (DFOUT) 50, 50, 66
   66 NAPPR = NAPPR + 1
      GO TO 50
   70 CALL F2FINL(IST, IERR)
      IF (IERR) 900, 72, 900
   72 IA1SRC(1) = 74
      IA1SRC(2) = 79
      IA1SRC(3) = 68
      IA1SRC(4) = 82
      CALL F2A1CP(IA1SRC, 4, IA1DST, 6)
      IF (IF2AEQ(IA1SRC, IA1DST, 4) - 1) 900, 74, 900
   74 IF (NPASS - 5 + 0 * LASTEC + 0 * LASTDB + 0 * LASTST) 900, 76, 900
   76 IF (NAPPR - 2) 900, 78, 900
   78 DERR = SUMRTT - 12.8132D0
      IF (DERR * DERR - 1.0D-4) 80, 80, 900
   80 CALL F2CLOS(IDB, IERR)
      IF (IERR) 900, 85, 900
   85 WRITE (6, 100) NPASS, NAPPR, SUMRTT
  100 FORMAT (2I6, F12.6)
      STOP
  900 STOP 1
      END
