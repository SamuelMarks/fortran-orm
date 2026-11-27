C @file fortran_ii_1958_ballistics.f
C @brief 1958 IBM 704/709 FORTRAN II ballistic range recorder example.
C
C Demonstrates authentic 1958 FORTRAN II modularization: SUBROUTINE,
C CALL, RETURN, named COMMON /CORMCM/, unpacked A1 ASCII integer arrays,
C and three-way arithmetic IF statements without LOGICAL, DATA, or
C CHARACTER extensions.
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IURL(8), IDDL(29), ISEL(23)
      DIMENSION ITG1(4), ITG2(4), ITG3(4), IOUT(8)
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
      IDB = 0
      CALL F2OPEN(IURL, 8, IDB, IERR)
      IF (IERR) 900, 10, 900
   10 IF (LASTDB - IDB) 900, 15, 900
C "CREATE TABLE SHOTS(S INT,R,T)" (29 chars)
   15 IDDL(1) = 67
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
      IDDL(14) = 83
      IDDL(15) = 72
      IDDL(16) = 79
      IDDL(17) = 84
      IDDL(18) = 83
      IDDL(19) = 40
      IDDL(20) = 83
      IDDL(21) = 32
      IDDL(22) = 73
      IDDL(23) = 78
      IDDL(24) = 84
      IDDL(25) = 44
      IDDL(26) = 82
      IDDL(27) = 44
      IDDL(28) = 84
      IDDL(29) = 41
      CALL F2EXEC(IDB, IDDL, 29, IERR)
      IF (IERR) 900, 20, 900
   20 ITG1(1) = 65
      ITG1(2) = 66
      ITG1(3) = 76
      ITG1(4) = 69
      ITG2(1) = 66
      ITG2(2) = 65
      ITG2(3) = 75
      ITG2(4) = 82
      ITG3(1) = 67
      ITG3(2) = 72
      ITG3(3) = 65
      ITG3(4) = 82
      CALL LOGSHO(IDB, 1, 1200, ITG1, 4, IERR)
      IF (IERR) 900, 25, 900
   25 CALL LOGSHO(IDB, 2, 1500, ITG2, 4, IERR)
      IF (IERR) 900, 30, 900
   30 CALL LOGSHO(IDB, 3, 1800, ITG3, 4, IERR)
      IF (IERR) 900, 35, 900
C "SELECT S,R,T FROM SHOTS" (23 chars)
   35 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 83
      ISEL(9) = 44
      ISEL(10) = 82
      ISEL(11) = 44
      ISEL(12) = 84
      ISEL(13) = 32
      ISEL(14) = 70
      ISEL(15) = 82
      ISEL(16) = 79
      ISEL(17) = 77
      ISEL(18) = 32
      ISEL(19) = 83
      ISEL(20) = 72
      ISEL(21) = 79
      ISEL(22) = 84
      ISEL(23) = 83
      CALL F2PREP(IDB, ISEL, 23, IST, IERR)
      IF (IERR) 900, 40, 900
   40 ISUM = 0
      ICNT = 0
   45 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 900, 50, 900
   50 IF (IHAS) 900, 70, 55
   55 CALL F2COLI(IST, 1, IS, IERR)
      IF (IERR) 900, 58, 900
   58 CALL F2COLI(IST, 2, IR, IERR)
      IF (IERR) 900, 60, 900
   60 CALL F2COLA(IST, 3, IOUT, 8, ILEN, IERR)
      IF (IERR) 900, 62, 900
   62 IF (ILEN - 4) 900, 65, 900
   65 ISUM = ISUM + IR + 0 * IS
      ICNT = ICNT + 1
      GO TO 45
   70 IF (ICNT - 3) 900, 72, 900
   72 IF (ISUM - 4500) 900, 75, 900
   75 CALL F2FINL(IST, IERR)
      IF (IERR) 900, 80, 900
   80 CALL F2CLOS(IDB, IERR)
      IF (IERR) 900, 85, 900
   85 IF (LASTEC) 900, 88, 900
   88 WRITE (6, 100) ISUM
  100 FORMAT (I6)
      STOP
  900 STOP 1
      END

C @brief Inserts one ballistic shot record via FORTRAN II subroutines.
C @param IDB Active 1-based database slot handle.
C @param ISHOT Shot sequence number.
C @param IRNG Downrange distance in yards.
C @param ITAG Unpacked A1 ASCII shot code array.
C @param NTAG Character count in ITAG.
C @param IERR Receives 0 on success or non-zero status code.
      SUBROUTINE LOGSHO(IDB, ISHOT, IRNG, ITAG, NTAG, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION ITAG(1), IINS(31)
C "INSERT INTO SHOTS VALUES(?,?,?)" (31 chars)
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
      IINS(13) = 83
      IINS(14) = 72
      IINS(15) = 79
      IINS(16) = 84
      IINS(17) = 83
      IINS(18) = 32
      IINS(19) = 86
      IINS(20) = 65
      IINS(21) = 76
      IINS(22) = 85
      IINS(23) = 69
      IINS(24) = 83
      IINS(25) = 40
      IINS(26) = 63
      IINS(27) = 44
      IINS(28) = 63
      IINS(29) = 44
      IINS(30) = 63
      IINS(31) = 41
      CALL F2PREP(IDB, IINS, 31, IST, IERR)
      IF (IERR) 90, 10, 90
   10 IF (LASTST - IST) 90, 15, 90
   15 CALL F2BINI(IST, 1, ISHOT, IERR)
      IF (IERR) 80, 20, 80
   20 CALL F2BINI(IST, 2, IRNG, IERR)
      IF (IERR) 80, 30, 80
   30 CALL F2BINA(IST, 3, ITAG, NTAG, IERR)
      IF (IERR) 80, 40, 80
   40 CALL F2STEP(IST, IHAS, IERR)
   80 CALL F2FINL(IST, IFNL)
      IF (IERR) 90, 85, 90
   85 IERR = IFNL + 0 * IHAS
   90 RETURN
      END
