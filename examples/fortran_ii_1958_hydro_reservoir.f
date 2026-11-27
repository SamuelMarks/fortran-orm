C @file fortran_ii_1958_hydro_reservoir.f
C @brief 1958 IBM 704/709 FORTRAN II hydroelectric dam ledger example.
C
C Showcases 1958 FORTRAN II modular structure across multiple
C SUBROUTINE units sharing named COMMON blocks (/CORMCM/ and /HYDRCM/)
C with unpacked A1 ASCII gate tags and arithmetic IF flow control.
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      COMMON /HYDRCM/ NTOTQ, NGATES
      DIMENSION IURL(8), IDDL(25), ICD1(4), ICD2(4)
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
C "CREATE TABLE DAM(G,I,O,C)" (25 chars)
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
      IDDL(14) = 68
      IDDL(15) = 65
      IDDL(16) = 77
      IDDL(17) = 40
      IDDL(18) = 71
      IDDL(19) = 44
      IDDL(20) = 73
      IDDL(21) = 44
      IDDL(22) = 79
      IDDL(23) = 44
      IDDL(24) = 67
      IDDL(25) = 41
      CALL F2EXEC(IDB, IDDL, 25, IERR)
      IF (IERR) 900, 20, 900
C "SPIL" and "TURB" gate tags
   20 ICD1(1) = 83
      ICD1(2) = 80
      ICD1(3) = 73
      ICD1(4) = 76
      ICD2(1) = 84
      ICD2(2) = 85
      ICD2(3) = 82
      ICD2(4) = 66
      CALL ADDGAT(IDB, 1, 420, 150, ICD1, 4, IERR)
      IF (IERR) 900, 25, 900
   25 CALL ADDGAT(IDB, 2, 310, 180, ICD2, 4, IERR)
      IF (IERR) 900, 30, 900
   30 CALL ADDGAT(IDB, 3, 260, 160, ICD2, 4, IERR)
      IF (IERR) 900, 35, 900
   35 CALL SUMNET(IDB, IERR)
      IF (IERR) 900, 40, 900
   40 IF (NGATES - 3) 900, 45, 900
   45 IF (NTOTQ - 500) 900, 50, 900
   50 CALL F2CLOS(IDB, IERR)
      IF (IERR) 900, 55, 900
   55 IF (LASTEC) 900, 60, 900
   60 WRITE (6, 100) NGATES, NTOTQ
  100 FORMAT (2I6)
      STOP
  900 STOP 1
      END

C @brief Records one spillway or turbine gate discharge observation.
C @param IDB Active 1-based database slot handle.
C @param IGAT Gate number.
C @param INFL Upstream inflow rate in cubic feet per second.
C @param IOUTF Downstream release rate in cubic feet per second.
C @param ICOD Unpacked A1 ASCII gate mode code.
C @param NCOD Character length of ICOD.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE ADDGAT(IDB, IGAT, INFL, IOUTF, ICOD, NCOD, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION ICOD(1), IINS(31)
C "INSERT INTO DAM VALUES(?,?,?,?)" (31 chars)
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
      IINS(13) = 68
      IINS(14) = 65
      IINS(15) = 77
      IINS(16) = 32
      IINS(17) = 86
      IINS(18) = 65
      IINS(19) = 76
      IINS(20) = 85
      IINS(21) = 69
      IINS(22) = 83
      IINS(23) = 40
      IINS(24) = 63
      IINS(25) = 44
      IINS(26) = 63
      IINS(27) = 44
      IINS(28) = 63
      IINS(29) = 44
      IINS(30) = 63
      IINS(31) = 41
      CALL F2PREP(IDB, IINS, 31, IST, IERR)
      IF (IERR) 90, 10, 90
   10 IF (LASTST - IST) 90, 15, 90
   15 CALL F2BINI(IST, 1, IGAT, IERR)
      IF (IERR) 80, 20, 80
   20 CALL F2BINI(IST, 2, INFL, IERR)
      IF (IERR) 80, 25, 80
   25 CALL F2BINI(IST, 3, IOUTF, IERR)
      IF (IERR) 80, 30, 80
   30 CALL F2BINA(IST, 4, ICOD, NCOD, IERR)
      IF (IERR) 80, 35, 80
   35 CALL F2STEP(IST, IHAS, IERR)
   80 CALL F2FINL(IST, IFNL)
      IF (IERR) 90, 85, 90
   85 IERR = IFNL + 0 * IHAS
   90 RETURN
      END

C @brief Aggregates net reservoir storage rate into /HYDRCM/ COMMON.
C @param IDB Active 1-based database slot handle.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE SUMNET(IDB, IERR)
      COMMON /HYDRCM/ NTOTQ, NGATES
      DIMENSION ISEL(23), IOUT(8)
C "SELECT G,I,O,C FROM DAM" (23 chars)
      ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 71
      ISEL(9) = 44
      ISEL(10) = 73
      ISEL(11) = 44
      ISEL(12) = 79
      ISEL(13) = 44
      ISEL(14) = 67
      ISEL(15) = 32
      ISEL(16) = 70
      ISEL(17) = 82
      ISEL(18) = 79
      ISEL(19) = 77
      ISEL(20) = 32
      ISEL(21) = 68
      ISEL(22) = 65
      ISEL(23) = 77
      NTOTQ = 0
      NGATES = 0
      CALL F2PREP(IDB, ISEL, 23, IST, IERR)
      IF (IERR) 90, 10, 90
   10 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 80, 15, 80
   15 IF (IHAS) 80, 70, 20
   20 CALL F2COLI(IST, 1, IG, IERR)
      IF (IERR) 80, 25, 80
   25 CALL F2COLI(IST, 2, INF, IERR)
      IF (IERR) 80, 30, 80
   30 CALL F2COLI(IST, 3, IOU, IERR)
      IF (IERR) 80, 35, 80
   35 CALL F2COLA(IST, 4, IOUT, 8, ILEN, IERR)
      IF (IERR) 80, 40, 80
   40 IF (ILEN - 4) 75, 45, 75
   45 NTOTQ = NTOTQ + (INF - IOU) + 0 * IG
      NGATES = NGATES + 1
      GO TO 10
   70 CALL F2FINL(IST, IERR)
      RETURN
   75 IERR = 1
   80 CALL F2FINL(IST, IFNL)
      IF (IERR) 90, 85, 90
   85 IERR = IFNL
   90 RETURN
      END
