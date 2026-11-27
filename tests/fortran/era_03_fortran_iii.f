C @file era_03_fortran_iii.f
C @brief End-to-end 1958-59 IBM FORTRAN III boolean-mask ORM test suite
C exercising F3OPEN, F3EXEC, F3GEX, F3TXBG/CM/RB, F3PREP..F3FINL,
C F3MATI/F3MATQ, IF3BIT, IF3ALL, F3MASK, and F3CLOS.
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DMAT(2, 2), DOUT(3, 2), DV, DERR
      DIMENSION IURL(8), IDDL(20), IINS(26), ISEL(18)
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
C Bit helper coverage across bit selectors 0, 1, 2, 3
      IF (IF3BIT(3, 0)) 900, 2, 900
    2 IF (IF3BIT(3, 3)) 900, 4, 900
    4 IF (IF3BIT(3, 1) - 1) 900, 6, 900
    6 IF (IF3BIT(3, 2) - 1) 900, 8, 900
    8 IF (IF3ALL(3, 2) - 2) 900, 9, 900
    9 IDB = 0
      CALL F3OPEN(IURL, 8, IDB, IWORD)
      IF (IWORD - 3) 900, 10, 900
C "CREATE TABLE T3(K,V)" (20 chars)
   10 IDDL(1) = 67
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
      IDDL(14) = 84
      IDDL(15) = 51
      IDDL(16) = 40
      IDDL(17) = 75
      IDDL(18) = 44
      IDDL(19) = 86
      IDDL(20) = 41
      IWBAD = 1
      CALL F3GEX(IDB, IDDL, 20, IWBAD)
      IF (IWBAD) 900, 12, 900
   12 CALL F3GEX(IDB, IDDL, 20, IWORD)
      IF (IWORD - 3) 900, 14, 900
C Transactions with boolean mask words
   14 CALL F3TXBG(IDB, IWORD)
      IF (IWORD - 3) 900, 16, 900
   16 CALL F3TXRB(IDB, IWORD)
      IF (IWORD - 3) 900, 18, 900
   18 CALL F3TXBG(IDB, IWORD)
      IF (IWORD - 3) 900, 20, 900
C "INSERT INTO T3 VALUES(?,?)" (26 chars)
   20 IINS(1) = 73
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
      IINS(13) = 84
      IINS(14) = 51
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
      IINS(26) = 41
      CALL F3PREP(IDB, IINS, 26, IST, IWORD)
      IF (IWORD - 3) 900, 22, 900
   22 CALL F3BINI(IDB, IST, 1, 59, IWORD)
      IF (IWORD - 3) 900, 24, 900
   24 CALL F3BIND(IDB, IST, 2, 7.25D0, IWORD)
      IF (IWORD - 3) 900, 26, 900
   26 CALL F3STEP(IDB, IST, IHAS, IWORD)
      IF (IWORD - 3) 900, 28, 900
   28 CALL F3FINL(IDB, IST, IWORD)
      IF (IWORD - 3) 900, 30, 900
   30 CALL F3TXCM(IDB, IWORD)
      IF (IWORD - 3) 900, 32, 900
C "SELECT K,V FROM T3" (18 chars)
   32 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 75
      ISEL(9) = 44
      ISEL(10) = 86
      ISEL(11) = 32
      ISEL(12) = 70
      ISEL(13) = 82
      ISEL(14) = 79
      ISEL(15) = 77
      ISEL(16) = 32
      ISEL(17) = 84
      ISEL(18) = 51
      CALL F3PREP(IDB, ISEL, 18, IST, IWORD)
      IF (IWORD - 3) 900, 34, 900
   34 CALL F3STEP(IDB, IST, IHAS, IWORD)
      IF (IWORD - 3) 900, 36, 900
   36 IF (IHAS - 1) 900, 38, 900
   38 CALL F3COLI(IDB, IST, 1, IK, IWORD)
      IF (IWORD - 3) 900, 40, 900
   40 IF (IK - 59) 900, 42, 900
   42 CALL F3COLD(IDB, IST, 2, DV, IWORD)
      IF (IWORD - 3) 900, 44, 900
   44 DERR = DV - 7.25D0
      IF (DERR * DERR - 1.0D-16) 46, 46, 900
   46 CALL F3FINL(IDB, IST, IWORD)
      IF (IWORD - 3) 900, 48, 900
C 2D matrix persistence on T3
   48 DMAT(1, 1) = 1.0D0
      DMAT(2, 1) = 2.0D0
      DMAT(1, 2) = 3.0D0
      DMAT(2, 2) = 4.0D0
      CALL F3EXEC(IDB,
     1 IDDL, 0, IWBAD)
      CALL F3MATI(IDB, IINS, 26, DMAT, 2, 2, 2, IWORD)
      IF (IWORD - 3) 900, 50, 900
   50 CALL F3MATQ(IDB, ISEL, 18, DOUT, 3, 3, 2, NOUT, IWORD)
      IF (IWORD - 3) 900, 52, 900
   52 IF (NOUT - 3) 900, 54, 900
   54 CALL F3MASK(0, IDB, 2, IWORD)
      IF (IWORD - 2) 900, 56, 900
   56 CALL F3CLOS(IDB, IWORD)
      IF (IWORD - 1 + 0 * I3STAT * I3WORD * I3DB * I3STMT) 900, 60, 900
   60 WRITE (6, 100) IK
  100 FORMAT (I6)
      STOP
  900 STOP 1
      END
