C @file fortran_i_1957_drum_inventory.f
C @brief 1957 IBM 704 Type 733 magnetic-drum spare-parts inventory,
C reorder-point audit, and Economic Order Quantity (EOQ) ledger.
C
C Strictly adheres to the October 15, 1956 IBM 704 FORTRAN (I) manual:
C - Fixed-form 72-column cards, <= 6-char uppercase names, no underscore
C - Zero SUBROUTINE, CALL, COMMON, DATA, LOGICAL, CHARACTER, PARAMETER
C - Uses EQUIVALENCE drum-buffer sharing, statement functions (*F),
C   computed GO TO dispatch, three-way arithmetic IF, and ICORMF.
      DIMENSION IURL(8), IDDL(30), IINS(30), ISEL(26), DDUM(2)
      DIMENSION ISKU(6), IONHD(6), IROPT(6), ICOST(6), IDEM(6)
      DIMENSION IBUF(30)
      EQUIVALENCE (IDDL(1), IBUF(1))
C Statement functions for ICORMF opcodes and EOQ integer arithmetic
      IOPOPF(IDUM) = 1 + 0 * IDUM
      IOPCLF(IDUM) = 3 + 0 * IDUM
      IOPEXF(IDUM) = 4 + 0 * IDUM
      IOPBGF(IDUM) = 6 + 0 * IDUM
      IOPCMF(IDUM) = 7 + 0 * IDUM
      IOPRBF(IDUM) = 8 + 0 * IDUM
      IOPPRF(IDUM) = 9 + 0 * IDUM
      IOPBIF(IDUM) = 11 + 0 * IDUM
      IOPSPF(IDUM) = 15 + 0 * IDUM
      IOPCIF(IDUM) = 16 + 0 * IDUM
      IOPFNF(IDUM) = 20 + 0 * IDUM
      IOPRWF(IDUM) = 21 + 0 * IDUM
      IDEFF(IQOH, IROP) = IROP - IQOH
      IEOQF(IDMD, ICST) = (200 * IDMD) / ICST + 10
      DDUM(1) = 0.0
      DDUM(2) = 0.0
C Initialize 6 vacuum-tube & drum-head spare parts on IBM 704 stock
      DO 5 K = 1, 6
      GO TO (1, 2, 3, 4, 41, 42), K
    1 ISKU(K) = 7041
      IONHD(K) = 18
      IROPT(K) = 40
      ICOST(K) = 12
      IDEM(K) = 240
      GO TO 5
    2 ISKU(K) = 7042
      IONHD(K) = 95
      IROPT(K) = 50
      ICOST(K) = 8
      IDEM(K) = 160
      GO TO 5
    3 ISKU(K) = 7043
      IONHD(K) = 12
      IROPT(K) = 36
      ICOST(K) = 20
      IDEM(K) = 300
      GO TO 5
    4 ISKU(K) = 7044
      IONHD(K) = 64
      IROPT(K) = 60
      ICOST(K) = 15
      IDEM(K) = 150
      GO TO 5
   41 ISKU(K) = 7045
      IONHD(K) = 5
      IROPT(K) = 30
      ICOST(K) = 25
      IDEM(K) = 500
      GO TO 5
   42 ISKU(K) = 7046
      IONHD(K) = 44
      IROPT(K) = 44
      ICOST(K) = 10
      IDEM(K) = 200
    5 CONTINUE
C Connect to ":memory:" in unpacked A1 ASCII codes
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
      IDB = 0
      IIDX = 0
      IVAL = 0
      ILEN = 8
      IOP = IOPOPF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IURL, ILEN)) 900, 10, 900
C Execute DDL via EQUIVALENCE buffer IBUF: "CREATE TABLE DR(S,Q,R,E)" (24)
   10 IBUF(1) = 67
      IBUF(2) = 82
      IBUF(3) = 69
      IBUF(4) = 65
      IBUF(5) = 84
      IBUF(6) = 69
      IBUF(7) = 32
      IBUF(8) = 84
      IBUF(9) = 65
      IBUF(10) = 66
      IBUF(11) = 76
      IBUF(12) = 69
      IBUF(13) = 32
      IBUF(14) = 68
      IBUF(15) = 82
      IBUF(16) = 40
      IBUF(17) = 83
      IBUF(18) = 44
      IBUF(19) = 81
      IBUF(20) = 44
      IBUF(21) = 82
      IBUF(22) = 44
      IBUF(23) = 69
      IBUF(24) = 41
      ILEN = 24
      IOP = IOPEXF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)) 900, 15, 900
C Prepare "INSERT INTO DR VALUES(?,?,?,?)" (30 chars)
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
      IINS(13) = 68
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
C Stage bogus negative-quantity card inside a transaction & roll back
      IOP = IOPBGF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IURL, 0)) 900, 16, 900
   16 ILEN = 30
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, IINS, ILEN)) 900, 17, 900
   17 IOP = IOPBIF(0)
      IF (ICORMF(IOP, IST, 1, 9999, DDUM, IINS, 0)) 900, 18, 900
   18 IF (ICORMF(IOP, IST, 2, -50, DDUM, IINS, 0)) 900, 19, 900
   19 IF (ICORMF(IOP, IST, 3, 10, DDUM, IINS, 0)) 900, 21, 900
   21 IF (ICORMF(IOP, IST, 4, 0, DDUM, IINS, 0)) 900, 22, 900
   22 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, 0, IHAS, DDUM, IINS, 0)) 900, 23, 900
   23 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, 0, IVAL, DDUM, IINS, 0)) 900, 24, 900
   24 IOP = IOPRBF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DDUM, IURL, 0)) 900, 25, 900
C Commit valid 6-part drum inventory batch inside a transaction
   25 IOP = IOPBGF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DDUM, IURL, 0)) 900, 26, 900
   26 DO 40 K = 1, 6
      IDFC = IDEFF(IONHD(K), IROPT(K))
      IF (IDFC) 27, 28, 28
   27 IORD = 0
      GO TO 29
   28 IORD = IEOQF(IDEM(K), ICOST(K))
   29 ILEN = 30
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, 0, IST, DDUM, IINS, ILEN)) 900, 31, 900
   31 IOP = IOPBIF(0)
      IF (ICORMF(IOP, IST, 1, ISKU(K), DDUM, IINS, 0)) 900, 32, 900
   32 IF (ICORMF(IOP, IST, 2, IONHD(K), DDUM, IINS, 0)) 900, 33, 900
   33 IF (ICORMF(IOP, IST, 3, IROPT(K), DDUM, IINS, 0)) 900, 34, 900
   34 IF (ICORMF(IOP, IST, 4, IORD, DDUM, IINS, 0)) 900, 35, 900
   35 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, 0, IHAS, DDUM, IINS, 0)) 900, 36, 900
   36 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, 0, IVAL, DDUM, IINS, 0)) 900, 40, 900
   40 CONTINUE
      IOP = IOPCMF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DDUM, IURL, 0)) 900, 45, 900
   45 IOP = IOPRWF(0)
      IF (ICORMF(IOP, IDB, 0, IRWID, DDUM, IURL, 0)) 900, 46, 900
   46 IF (IRWID - 6) 900, 50, 900
C Query all rows: "SELECT S,Q,R,E FROM DR" (22 chars)
   50 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 83
      ISEL(9) = 44
      ISEL(10) = 81
      ISEL(11) = 44
      ISEL(12) = 82
      ISEL(13) = 44
      ISEL(14) = 69
      ISEL(15) = 32
      ISEL(16) = 70
      ISEL(17) = 82
      ISEL(18) = 79
      ISEL(19) = 77
      ISEL(20) = 32
      ISEL(21) = 68
      ISEL(22) = 82
      ILEN = 22
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, 0, IST, DDUM, ISEL, ILEN)) 900, 52, 900
   52 NROWS = 0
      NREOR = 0
      ITEOQ = 0
   55 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, 0, IHAS, DDUM, ISEL, 0)) 900, 56, 900
   56 IF (IHAS) 900, 70, 58
   58 IOP = IOPCIF(0)
      IF (ICORMF(IOP, IST, 1, JSKU, DDUM, ISEL, 0)) 900, 60, 900
   60 IF (ICORMF(IOP, IST, 2, JQOH, DDUM, ISEL, 0)) 900, 62, 900
   62 IF (ICORMF(IOP, IST, 3, JROP, DDUM, ISEL, 0)) 900, 64, 900
   64 IF (ICORMF(IOP, IST, 4, JEOQ, DDUM, ISEL, 0)) 900, 66, 900
   66 NROWS = NROWS + 1
      IF (JSKU - 7040) 900, 900, 67
   67 IF (JQOH - JROP) 68, 68, 69
   68 NREOR = NREOR + 1
   69 ITEOQ = ITEOQ + JEOQ
      GO TO 55
C Verify 6 parts persisted, 4 at/below reorder point, EOQ sum = 240
C SKU1: (200*240)/12+10=4010; SKU3: (200*300)/20+10=3010;
C SKU5: (200*500)/25+10=4010; SKU6: (200*200)/10+10=4010 -> 15040
   70 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, 0, IVAL, DDUM, ISEL, 0)) 900, 72, 900
   72 IOP = IOPCLF(0)
      IF (ICORMF(IOP, IDB, 0, IVAL, DDUM, IURL, 0)) 900, 74, 900
   74 IF (NROWS - 6) 900, 76, 900
   76 IF (NREOR - 4) 900, 78, 900
   78 IF (ITEOQ - 15040) 900, 80, 900
   80 WRITE (6, 100) NROWS, NREOR, ITEOQ
  100 FORMAT (3I8)
      STOP
  900 STOP 1
      END
