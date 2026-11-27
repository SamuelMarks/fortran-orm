C @file cormf1.f
C @brief 1957 IBM 704 FORTRAN (I) master-tape reference deck for
C fortran-orm.
C
C In 1957 IBM 704 FORTRAN (I), SUBROUTINE, FUNCTION, CALL, COMMON,
C DATA, LOGICAL, and CHARACTER did not yet exist. Programs invoked
C external library functions on the master system tape directly inside
C arithmetic expressions and three-way arithmetic IF statements:
C   IF (ICORMF(IOP, IDB, IIDX, IVAL, DVAL, IBUF, ILEN)) 900, 10, 900
C
C This reference deck demonstrates complete 1957 FORTRAN (I) ORM
C abstractions using 1-line statement functions (ending in F per IBM
C 704 convention), EQUIVALENCE record overlays, computed GO TO query
C state dispatch, transactional rollback/commit, integer & text A1
C persistence, and rowid inspection.
C
      DIMENSION IURL(8), IDDL(26), IINS(28), IDEL(14), ISEL(20)
      DIMENSION ITAG(4), IOUT(8), IREC(2), JREC(2), DDUM(2)
      EQUIVALENCE (IREC(1), JREC(1))
C 1957 IBM 704 statement functions (names 4-6 chars ending in F)
      IOPOPF(IDUM) = 1 + 0 * IDUM
      IOPCLF(IDUM) = 3 + 0 * IDUM
      IOPEXF(IDUM) = 4 + 0 * IDUM
      IOPBGF(IDUM) = 6 + 0 * IDUM
      IOPCMF(IDUM) = 7 + 0 * IDUM
      IOPRBF(IDUM) = 8 + 0 * IDUM
      IOPPRF(IDUM) = 9 + 0 * IDUM
      IOPBIF(IDUM) = 11 + 0 * IDUM
      IOPBAF(IDUM) = 13 + 0 * IDUM
      IOPSPF(IDUM) = 15 + 0 * IDUM
      IOPCIF(IDUM) = 16 + 0 * IDUM
      IOPCAF(IDUM) = 18 + 0 * IDUM
      IOPFNF(IDUM) = 20 + 0 * IDUM
      IOPRWF(IDUM) = 21 + 0 * IDUM
      ISCALF(IX, IG, IB) = IX * IG + IB
      DDUM(1) = 0.0
      DDUM(2) = 0.0
C Unpacked A1 ASCII codes for ":memory:" (8 chars)
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
      IRC = ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IURL, ILEN)
      ISTATE = IRC + 1
      GO TO (10, 900), ISTATE
C "CREATE TABLE DECK(K,V,TAG)" (26 chars)
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
      IDDL(14) = 68
      IDDL(15) = 69
      IDDL(16) = 67
      IDDL(17) = 75
      IDDL(18) = 40
      IDDL(19) = 75
      IDDL(20) = 44
      IDDL(21) = 86
      IDDL(22) = 44
      IDDL(23) = 84
      IDDL(24) = 65
      IDDL(25) = 71
      IDDL(26) = 41
      ILEN = 26
      IOP = IOPEXF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)
      ISTATE = IRC + 1
      GO TO (15, 900), ISTATE
   15 ILEN = 0
      IOP = IOPBGF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)
      ISTATE = IRC + 1
      GO TO (20, 900), ISTATE
C "INSERT INTO DECK VALUES(?,?,?)" -> "INSERT INTO DECK(K,V,TAG)..."
C Use "INSERT INTO DECK VALUES(?,?,?)" (30 chars) - resize IINS in dim:
C Wait: IINS is 28 -> use table "D1" -> "CREATE TABLE D1(K,V,T)" (22)
   20 IDDL(14) = 68
      IDDL(15) = 49
      IDDL(16) = 40
      IDDL(17) = 75
      IDDL(18) = 44
      IDDL(19) = 86
      IDDL(20) = 44
      IDDL(21) = 84
      IDDL(22) = 41
      ILEN = 22
      IOP = IOPEXF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)
      ISTATE = IRC + 1
      GO TO (22, 900), ISTATE
C "INSERT INTO D1 VALUES(?,?,?)" (28 chars)
   22 IINS(1) = 73
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
      IINS(14) = 49
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
      IINS(28) = 41
      ITAG(1) = 84
      ITAG(2) = 65
      ITAG(3) = 80
      ITAG(4) = 0
      DO 45 K = 1, 3
      IREC(1) = K
      IREC(2) = ISCALF(K, 14, 0)
      ITAG(4) = 48 + K
      ILEN = 28
      IOP = IOPPRF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IST, DDUM, IINS, ILEN)
      ISTATE = IRC + 1
      GO TO (26, 900), ISTATE
   26 IIDX = 1
      IVAL = JREC(1)
      IOP = IOPBIF(0)
      IRC = ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)
      ISTATE = IRC + 1
      GO TO (30, 900), ISTATE
   30 IIDX = 2
      IVAL = JREC(2)
      IOP = IOPBIF(0)
      IRC = ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)
      ISTATE = IRC + 1
      GO TO (34, 900), ISTATE
   34 IIDX = 3
      ILEN = 4
      IOP = IOPBAF(0)
      IRC = ICORMF(IOP, IST, IIDX, IVAL, DDUM, ITAG, ILEN)
      ISTATE = IRC + 1
      GO TO (38, 900), ISTATE
   38 IOP = IOPSPF(0)
      IRC = ICORMF(IOP, IST, IIDX, IHAS, DDUM, IINS, ILEN)
      ISTATE = IRC + 1
      GO TO (42, 900), ISTATE
   42 IOP = IOPFNF(0)
      IRC = ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)
      ISTATE = IRC + 1
      GO TO (45, 900), ISTATE
   45 CONTINUE
      ILEN = 0
      IOP = IOPCMF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IINS, ILEN)
      ISTATE = IRC + 1
      GO TO (48, 900), ISTATE
   48 IOP = IOPRWF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IRID, DDUM, IINS, ILEN)
      ISTATE = (IRID - 3) + 1
      GO TO (50, 900), ISTATE
C Verify transactional rollback on accidental "DELETE FROM D1" (14)
   50 IOP = IOPBGF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IINS, ILEN)
      IDEL(1) = 68
      IDEL(2) = 69
      IDEL(3) = 76
      IDEL(4) = 69
      IDEL(5) = 84
      IDEL(6) = 69
      IDEL(7) = 32
      IDEL(8) = 70
      IDEL(9) = 82
      IDEL(10) = 79
      IDEL(11) = 77
      IDEL(12) = 32
      IDEL(13) = 68
      IDEL(14) = 49
      ILEN = 14
      IOP = IOPEXF(0)
      IRC = IRC + ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDEL, ILEN)
      ILEN = 0
      IOP = IOPRBF(0)
      IRC = IRC + ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDEL, ILEN)
      ISTATE = IRC + 1
      GO TO (55, 900), ISTATE
C "SELECT K,V,T FROM D1" (20 chars)
   55 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 75
      ISEL(9) = 44
      ISEL(10) = 86
      ISEL(11) = 44
      ISEL(12) = 84
      ISEL(13) = 32
      ISEL(14) = 70
      ISEL(15) = 82
      ISEL(16) = 79
      ISEL(17) = 77
      ISEL(18) = 32
      ISEL(19) = 68
      ISEL(20) = 49
      ILEN = 20
      IOP = IOPPRF(0)
      IRC = ICORMF(IOP, IDB, IIDX, IST, DDUM, ISEL, ILEN)
      ISTATE = IRC + 1
      GO TO (58, 900), ISTATE
   58 ISUM = 0
      NROW = 0
   60 IOP = IOPSPF(0)
      IRC = ICORMF(IOP, IST, IIDX, IHAS, DDUM, ISEL, ILEN)
      IF (IHAS) 900, 75, 62
   62 IIDX = 2
      IOP = IOPCIF(0)
      IRC = IRC + ICORMF(IOP, IST, IIDX, IOUTV, DDUM, ISEL, ILEN)
      IIDX = 3
      ICAP = 8
      IOP = IOPCAF(0)
      IRC = IRC + ICORMF(IOP, IST, IIDX, ICAP, DDUM, IOUT, NLEN)
      ISUM = ISUM + IOUTV + (NLEN - 4) + (IOUT(1) - 84)
      NROW = NROW + 1
      GO TO 60
   75 IOP = IOPFNF(0)
      IRC = IRC + ICORMF(IOP, IST, IIDX, IVAL, DDUM, ISEL, ILEN)
      IOP = IOPCLF(0)
      IRC = IRC + ICORMF(IOP, IDB, IIDX, IVAL, DDUM, ISEL, ILEN)
      ICHK = IRC + (ISUM - 84) * (ISUM - 84) + (NROW - 3) * (NROW - 3)
      ISTATE = ICHK + 1
      GO TO (80, 900), ISTATE
   80 WRITE (6, 100) ISUM, NROW
  100 FORMAT (2I6)
      STOP
  900 WRITE (6, 100) -1, -1
      STOP 1
      END
