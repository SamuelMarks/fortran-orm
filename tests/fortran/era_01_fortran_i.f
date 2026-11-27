C @file era_01_fortran_i.f
C @brief End-to-end 1957 IBM 704 FORTRAN (I) ORM verification suite.
C
C Strictly adheres to 1957 IBM 704 FORTRAN (I): zero SUBROUTINE, zero
C CALL, zero COMMON, zero DATA, zero LOGICAL, zero CHARACTER. Invokes
C external integer function ICORMF inside arithmetic IF statements to
C open SQLite :memory:, create table T1, insert two rows inside a
C transaction, query their sum, verify rowid, and disconnect.
      DIMENSION IURL(8), IDDL(27), IINS(25), ISEL(20), DDUM(2)
      IOPOPF(IDUM) = 1 + 0 * IDUM
      IOPCLF(IDUM) = 3 + 0 * IDUM
      IOPEXF(IDUM) = 4 + 0 * IDUM
      IOPBGF(IDUM) = 6 + 0 * IDUM
      IOPCMF(IDUM) = 7 + 0 * IDUM
      IOPPRF(IDUM) = 9 + 0 * IDUM
      IOPBIF(IDUM) = 11 + 0 * IDUM
      IOPSPF(IDUM) = 15 + 0 * IDUM
      IOPCIF(IDUM) = 16 + 0 * IDUM
      IOPFNF(IDUM) = 20 + 0 * IDUM
      IOPRWF(IDUM) = 21 + 0 * IDUM
      DDUM(1) = 0.0
      DDUM(2) = 0.0
C ":memory:" in unpacked A1 ASCII codes
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
C "CREATE TABLE T1(ID INT,V INT)" (29 chars -> shortened "CREATE TABLE T1(V INT)" 22 chars)
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
      IDDL(15) = 49
      IDDL(16) = 40
      IDDL(17) = 86
      IDDL(18) = 32
      IDDL(19) = 73
      IDDL(20) = 78
      IDDL(21) = 84
      IDDL(22) = 41
      ILEN = 22
      IOP = IOPEXF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)) 900, 20, 900
C BEGIN TRANSACTION
   20 IOP = IOPBGF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)) 900, 30, 900
C "INSERT INTO T1 VALUES(?)" (24 chars)
   30 IINS(1) = 73
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
      IINS(24) = 41
      DO 45 K = 1, 2
      ILEN = 24
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, IINS, ILEN)) 900, 35, 900
   35 IIDX = 1
      IVAL = K * 10
      IOP = IOPBIF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 40, 900
   40 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, IIDX, IHAS, DDUM, IINS, ILEN)) 900, 42, 900
   42 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 45, 900
   45 CONTINUE
C COMMIT & verify LAST_ROWID == 2
      IOP = IOPCMF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 50, 900
   50 IOP = IOPRWF(0)
      IF (ICORMF(IOP, IDB, IIDX, IRID, DDUM, IINS, ILEN)) 900, 55, 900
   55 IF (IRID - 2) 900, 60, 900
C "SELECT SUM(V) FROM T1" -> "SELECT V FROM T1" (16 chars)
   60 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 86
      ISEL(9) = 32
      ISEL(10) = 70
      ISEL(11) = 82
      ISEL(12) = 79
      ISEL(13) = 77
      ISEL(14) = 32
      ISEL(15) = 84
      ISEL(16) = 49
      ILEN = 16
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, ISEL, ILEN)) 900, 65, 900
   65 ISUM = 0
   70 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, IIDX, IHAS, DDUM, ISEL, ILEN)) 900, 72, 900
   72 IF (IHAS) 900, 80, 74
   74 IIDX = 1
      IOP = IOPCIF(0)
      IF (ICORMF(IOP, IST, IIDX, IV, DDUM, ISEL, ILEN)) 900, 76, 900
   76 ISUM = ISUM + IV
      GO TO 70
   80 IF (ISUM - 30) 900, 82, 900
   82 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, ISEL, ILEN)) 900, 84, 900
   84 IOP = IOPCLF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, ISEL, ILEN)) 900, 86, 900
   86 WRITE (6, 100) ISUM
  100 FORMAT (I6)
      STOP
  900 STOP 1
      END
