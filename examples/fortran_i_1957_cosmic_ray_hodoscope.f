C @file fortran_i_1957_cosmic_ray_hodoscope.f
C @brief IGY 1957 high-altitude balloon Geiger-Mueller 3-tray cosmic-ray
C hodoscope coincidence telescope and barometric flux correction deck.
C
C Strictly adheres to the 1957 IBM 704 FORTRAN (I) specification:
C - Fixed-form 72-column punch cards, <= 6-char uppercase identifiers
C - Zero SUBROUTINE, CALL, COMMON, DATA, LOGICAL, CHARACTER, PARAMETER
C - Uses statement functions (*F), EQUIVALENCE, computed GO TO,
C   DOUBLE PRECISION / floating barometric scaling, and ICORMF.
      DIMENSION IURL(8), IDDL(26), IINS(30), ISEL(22), DVAL(2)
      DIMENSION ITRAYA(8), ITRAYB(8), ITRAYC(8), IMBAR(8), ISCR(26)
      EQUIVALENCE (IDDL(1), ISCR(1))
C Statement functions for ICORMF opcodes & triple-coincidence physics
      IOPOPF(IDUM) = 1 + 0 * IDUM
      IOPCLF(IDUM) = 3 + 0 * IDUM
      IOPEXF(IDUM) = 4 + 0 * IDUM
      IOPBGF(IDUM) = 6 + 0 * IDUM
      IOPCMF(IDUM) = 7 + 0 * IDUM
      IOPPRF(IDUM) = 9 + 0 * IDUM
      IOPBIF(IDUM) = 11 + 0 * IDUM
      IOPBDF(IDUM) = 12 + 0 * IDUM
      IOPSPF(IDUM) = 15 + 0 * IDUM
      IOPCIF(IDUM) = 16 + 0 * IDUM
      IOPCDF(IDUM) = 17 + 0 * IDUM
      IOPFNF(IDUM) = 20 + 0 * IDUM
      ICOINF(IA, IB, IC) = IA * IB * IC
      ACCIDF(IA, IB, IC) = 0.0002 * FLOAT(IA * IB + IB * IC)
      BAROCF(RATE, MBAR) = RATE * (1.0 + 0.0072 * FLOAT(MBAR - 1013))
C Populate 8 balloon ascent altitude frames (1013 mbar sea level..80 mb)
      DO 9 K = 1, 8
      GO TO (1, 2, 3, 4, 5, 6, 7, 8), K
    1 ITRAYA(K) = 12
      ITRAYB(K) = 10
      ITRAYC(K) = 1
      IMBAR(K) = 1013
      GO TO 9
    2 ITRAYA(K) = 18
      ITRAYB(K) = 15
      ITRAYC(K) = 1
      IMBAR(K) = 850
      GO TO 9
    3 ITRAYA(K) = 26
      ITRAYB(K) = 22
      ITRAYC(K) = 1
      IMBAR(K) = 700
      GO TO 9
    4 ITRAYA(K) = 40
      ITRAYB(K) = 35
      ITRAYC(K) = 1
      IMBAR(K) = 500
      GO TO 9
    5 ITRAYA(K) = 62
      ITRAYB(K) = 54
      ITRAYC(K) = 1
      IMBAR(K) = 300
      GO TO 9
    6 ITRAYA(K) = 88
      ITRAYB(K) = 78
      ITRAYC(K) = 1
      IMBAR(K) = 200
      GO TO 9
    7 ITRAYA(K) = 95
      ITRAYB(K) = 86
      ITRAYC(K) = 1
      IMBAR(K) = 120
      GO TO 9
    8 ITRAYA(K) = 74
      ITRAYB(K) = 66
      ITRAYC(K) = 0
      IMBAR(K) = 80
    9 CONTINUE
C Open ":memory:" via unpacked A1 ASCII array
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
      DVAL(1) = 0.0
      DVAL(2) = 0.0
      IDB = 0
      IOP = IOPOPF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DVAL, IURL, 8)) 900, 10, 900
C Create hodoscope table via EQUIVALENCE: "CREATE TABLE CR(F,P,C,X)" (24)
   10 ISCR(1) = 67
      ISCR(2) = 82
      ISCR(3) = 69
      ISCR(4) = 65
      ISCR(5) = 84
      ISCR(6) = 69
      ISCR(7) = 32
      ISCR(8) = 84
      ISCR(9) = 65
      ISCR(10) = 66
      ISCR(11) = 76
      ISCR(12) = 69
      ISCR(13) = 32
      ISCR(14) = 67
      ISCR(15) = 82
      ISCR(16) = 40
      ISCR(17) = 70
      ISCR(18) = 44
      ISCR(19) = 80
      ISCR(20) = 44
      ISCR(21) = 67
      ISCR(22) = 44
      ISCR(23) = 88
      ISCR(24) = 41
      IOP = IOPEXF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DVAL, IDDL, 24)) 900, 15, 900
C Prepare "INSERT INTO CR VALUES(?,?,?,?)" (30 chars)
   15 IINS(1) = 73
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
      IINS(13) = 67
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
      IOP = IOPBGF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DVAL, IURL, 0)) 900, 18, 900
   18 DO 40 K = 1, 8
      ICNT = ICOINF(ITRAYA(K), ITRAYB(K), ITRAYC(K))
      RTRU = FLOAT(ICNT) - ACCIDF(ITRAYA(K), ITRAYB(K), ITRAYC(K))
      IF (RTRU) 20, 22, 22
   20 RTRU = 0.0
   22 RCOR = BAROCF(RTRU, IMBAR(K))
      IF (RCOR) 24, 26, 26
   24 RCOR = 0.1 * RTRU
   26 IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, 0, IST, DVAL, IINS, 30)) 900, 28, 900
   28 IOP = IOPBIF(0)
      IF (ICORMF(IOP, IST, 1, K, DVAL, IINS, 0)) 900, 30, 900
   30 IF (ICORMF(IOP, IST, 2, IMBAR(K), DVAL, IINS, 0)) 900, 32, 900
   32 IF (ICORMF(IOP, IST, 3, ICNT, DVAL, IINS, 0)) 900, 34, 900
   34 DVAL(1) = RCOR
      DVAL(2) = 0.0
      IOP = IOPBDF(0)
      IF (ICORMF(IOP, IST, 4, 0, DVAL, IINS, 0)) 900, 36, 900
   36 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, 0, IHAS, DVAL, IINS, 0)) 900, 38, 900
   38 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, 0, IVAL, DVAL, IINS, 0)) 900, 40, 900
   40 CONTINUE
      IOP = IOPCMF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DVAL, IURL, 0)) 900, 45, 900
C Query Regener-Pfotzer maximum: "SELECT F,P,C,X FROM CR" (22 chars)
   45 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 70
      ISEL(9) = 44
      ISEL(10) = 80
      ISEL(11) = 44
      ISEL(12) = 67
      ISEL(13) = 44
      ISEL(14) = 88
      ISEL(15) = 32
      ISEL(16) = 70
      ISEL(17) = 82
      ISEL(18) = 79
      ISEL(19) = 77
      ISEL(20) = 32
      ISEL(21) = 67
      ISEL(22) = 82
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, 0, IST, DVAL, ISEL, 22)) 900, 48, 900
   48 NACT = 0
      IPKFR = 0
      IPKCN = 0
      SUMFX = 0.0
   50 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, 0, IHAS, DVAL, ISEL, 0)) 900, 52, 900
   52 IF (IHAS) 900, 70, 54
   54 IOP = IOPCIF(0)
      IF (ICORMF(IOP, IST, 1, JFRM, DVAL, ISEL, 0)) 900, 56, 900
   56 IF (ICORMF(IOP, IST, 2, JMBR, DVAL, ISEL, 0)) 900, 58, 900
   58 IF (ICORMF(IOP, IST, 3, JCNT, DVAL, ISEL, 0)) 900, 60, 900
   60 IOP = IOPCDF(0)
      IF (ICORMF(IOP, IST, 4, 0, DVAL, ISEL, 0)) 900, 62, 900
   62 IF (JCNT) 50, 50, 64
   64 NACT = NACT + 1
      SUMFX = SUMFX + DVAL(1)
      IF (JCNT - IPKCN) 50, 50, 66
   66 IPKCN = JCNT
      IPKFR = JFRM
      IPKMB = JMBR
      GO TO 50
C Verify 7 active coincidence frames (frame 8 Tray C = 0 vetoed) and
C Regener-Pfotzer peak at frame 7 (120 mbar, 95 * 86 = 8170 counts)
   70 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, 0, IVAL, DVAL, ISEL, 0)) 900, 72, 900
   72 IOP = IOPCLF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DVAL, IURL, 0)) 900, 74, 900
   74 IF (NACT - 7) 900, 76, 900
   76 IF (IPKFR - 7) 900, 78, 900
   78 IF (IPKMB - 120) 900, 80, 900
   80 IF (IPKCN - 8170) 900, 82, 900
   82 IF (SUMFX - 1000.0) 900, 900, 84
   84 WRITE (6, 100) NACT, IPKFR, IPKMB, IPKCN
  100 FORMAT (4I8)
      STOP
  900 STOP 1
      END
