C @file era_02_fortran_ii.f
C @brief End-to-end 1958 IBM FORTRAN II SUBROUTINE & COMMON test suite.
C
C Exercises F2OPEN, F2EXEC, F2PREP, F2BINI, F2BINA, F2STEP, F2COLI,
C F2COLA, F2FINL, F2CLOS, and /CORMCM/ COMMON diagnostics using strict
C 1958 FORTRAN II syntax (no LOGICAL, no DATA, no CHARACTER).
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IURL(8), IDDL(27), IINS(27), ISEL(19)
      DIMENSION INAM(3), IOUT(8)
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
      CALL F2OPEN(IURL, -1, IDB, IERR)
      IF (IERR) 5, 900, 5
    5 CALL F2PREP(0, IURL, 8, IST, IERR)
      IF (IERR) 8, 900, 8
    8 CALL F2OPEN(IURL, 8, IDB, IERR)
      IF (IERR) 900, 10, 900
   10 IF (LASTDB - IDB) 900, 15, 900
C "CREATE TABLE T2(K INT,S TEXT)" -> 29 chars: use "CREATE TABLE T2(K INT,S)" 24
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
      IDDL(14) = 84
      IDDL(15) = 50
      IDDL(16) = 40
      IDDL(17) = 75
      IDDL(18) = 32
      IDDL(19) = 73
      IDDL(20) = 78
      IDDL(21) = 84
      IDDL(22) = 44
      IDDL(23) = 83
      IDDL(24) = 41
      CALL F2EXEC(IDB, IDDL, 24, IERR)
      IF (IERR) 900, 20, 900
C "INSERT INTO T2 VALUES(?,?)" (26 chars)
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
      IINS(14) = 50
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
      CALL F2PREP(IDB, IINS, 26, IST, IERR)
      IF (IERR) 900, 25, 900
   25 CALL F2BINI(IST, 1, 77, IERR)
      IF (IERR) 900, 30, 900
   30 INAM(1) = 73
      INAM(2) = 66
      INAM(3) = 77
      CALL F2BINA(IST, 2, INAM, 3, IERR)
      IF (IERR) 900, 35, 900
   35 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 900, 40, 900
   40 CALL F2FINL(IST, IERR)
      IF (IERR) 900, 45, 900
C "SELECT K,S FROM T2" (18 chars)
   45 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 75
      ISEL(9) = 44
      ISEL(10) = 83
      ISEL(11) = 32
      ISEL(12) = 70
      ISEL(13) = 82
      ISEL(14) = 79
      ISEL(15) = 77
      ISEL(16) = 32
      ISEL(17) = 84
      ISEL(18) = 50
      CALL F2PREP(IDB, ISEL, 18, IST, IERR)
      IF (IERR) 900, 50, 900
   50 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 900, 55, 900
   55 IF (IHAS - 1) 900, 60, 900
   60 CALL F2COLI(IST, 1, IK, IERR)
      IF (IERR) 900, 65, 900
   65 IF (IK - 77) 900, 70, 900
   70 CALL F2COLA(IST, 2, IOUT, 8, ILEN, IERR)
      IF (IERR) 900, 75, 900
   75 IF (ILEN - 3) 900, 80, 900
   80 IF (IOUT(1) - 73) 900, 82, 900
   82 CALL F2FINL(IST, IERR)
      IF (IERR) 900, 85, 900
   85 CALL F2CLOS(IDB, IERR)
      IF (IERR) 900, 88, 900
   88 WRITE (6, 100) IK
  100 FORMAT (I6)
      STOP
  900 STOP 1
      END
