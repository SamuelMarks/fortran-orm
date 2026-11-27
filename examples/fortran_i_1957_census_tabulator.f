C @file fortran_i_1957_census_tabulator.f
C @brief 1957 IBM 704 FORTRAN (I) municipal census & tax-roll tabulator.
C
C Demonstrates pure 1957 IBM 704 FORTRAN (I) programming: statement
C functions ending in F, unpacked A1 ASCII integer arrays, three-way
C arithmetic IF statements, transactional commit and rollback of a
C mis-punched card batch, and last-inserted rowid verification via
C ICORMF without SUBROUTINE, CALL, COMMON, DATA, LOGICAL, or CHARACTER.
      DIMENSION IURL(8), IDDL(21), IINS(27), IDEL(15), ISEL(19)
      DIMENSION DDUM(2)
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
      ITAXF(IPOP) = IPOP * 3 + 50
      DDUM(1) = 0.0
      DDUM(2) = 0.0
C ":memory:" (8 chars)
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
C "CREATE TABLE CEN(W,T)" (21 chars)
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
      IDDL(14) = 67
      IDDL(15) = 69
      IDDL(16) = 78
      IDDL(17) = 40
      IDDL(18) = 87
      IDDL(19) = 44
      IDDL(20) = 84
      IDDL(21) = 41
      ILEN = 21
      IOP = IOPEXF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)) 900, 15, 900
   15 ILEN = 0
      IOP = IOPBGF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)) 900, 20, 900
C "INSERT INTO CEN VALUES(?,?)" (27 chars)
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
      IINS(13) = 67
      IINS(14) = 69
      IINS(15) = 78
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
      IINS(27) = 41
      DO 40 K = 1, 4
      ILEN = 27
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, IINS, ILEN)) 900, 24, 900
   24 IIDX = 1
      IVAL = K
      IOP = IOPBIF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 28, 900
   28 IIDX = 2
      IPOP = K * 100
      IVAL = ITAXF(IPOP)
      IOP = IOPBIF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 32, 900
   32 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, IIDX, IHAS, DDUM, IINS, ILEN)) 900, 36, 900
   36 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 40, 900
   40 CONTINUE
      ILEN = 0
      IOP = IOPRWF(0)
      IF (ICORMF(IOP, IDB, IIDX, IROW, DDUM, IINS, ILEN)) 900, 42, 900
   42 IF (IROW - 4) 900, 44, 900
   44 IOP = IOPCMF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 46, 900
C Begin a second transaction and roll back an accidental DELETE card
   46 IOP = IOPBGF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 48, 900
C "DELETE FROM CEN" (15 chars)
   48 IDEL(1) = 68
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
      IDEL(13) = 67
      IDEL(14) = 69
      IDEL(15) = 78
      ILEN = 15
      IOP = IOPEXF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDEL, ILEN)) 900, 50, 900
   50 ILEN = 0
      IOP = IOPRBF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDEL, ILEN)) 900, 52, 900
C "SELECT W,T FROM CEN" (19 chars)
   52 ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 87
      ISEL(9) = 44
      ISEL(10) = 84
      ISEL(11) = 32
      ISEL(12) = 70
      ISEL(13) = 82
      ISEL(14) = 79
      ISEL(15) = 77
      ISEL(16) = 32
      ISEL(17) = 67
      ISEL(18) = 69
      ISEL(19) = 78
      ILEN = 19
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, ISEL, ILEN)) 900, 54, 900
   54 IWSUM = 0
      ISUM = 0
   56 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, IIDX, IHAS, DDUM, ISEL, ILEN)) 900, 58, 900
   58 IF (IHAS) 900, 70, 60
   60 IIDX = 1
      IOP = IOPCIF(0)
      IF (ICORMF(IOP, IST, IIDX, IW, DDUM, ISEL, ILEN)) 900, 62, 900
   62 IIDX = 2
      IOP = IOPCIF(0)
      IF (ICORMF(IOP, IST, IIDX, IT, DDUM, ISEL, ILEN)) 900, 64, 900
   64 IWSUM = IWSUM + IW
      ISUM = ISUM + IT
      GO TO 56
   70 IF (IWSUM - 10) 900, 72, 900
   72 IF (ISUM - 3200) 900, 74, 900
   74 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, ISEL, ILEN)) 900, 76, 900
   76 IOP = IOPCLF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, ISEL, ILEN)) 900, 80, 900
   80 WRITE (6, 100) IWSUM, ISUM
  100 FORMAT (2I6)
      STOP
  900 STOP 1
      END
