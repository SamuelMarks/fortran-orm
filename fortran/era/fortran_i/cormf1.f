C @file cormf1.f
C @brief 1957 IBM 704 FORTRAN (I) reference card deck for fortran-orm.
C
C In 1957 IBM 704 FORTRAN (I), SUBROUTINE, FUNCTION, CALL, COMMON,
C DATA, LOGICAL, and CHARACTER did not yet exist. Programs invoked
C external library functions on the master system tape directly in
C arithmetic expressions and three-way arithmetic IF statements:
C   IF (ICORMF(IOP, IDB, IIDX, IVAL, DVAL, IBUF, ILEN)) 900, 10, 900
C
C This deck demonstrates pure 1957 FORTRAN (I) ORM usage against an
C in-memory SQLite database using unpacked A1 ASCII integer arrays and
C 1-line statement functions (ending in F per IBM 704 convention).
C
      DIMENSION IURL(6), ISQL1(38), ISQL2(31), ISQL3(23)
      DIMENSION DDUM(2)
C Statement functions for 1957 FORTRAN (I) ICORMF opcodes
      IOPOPF(IDUM) = 1 + 0 * IDUM
      IOPCLF(IDUM) = 3 + 0 * IDUM
      IOPEXF(IDUM) = 4 + 0 * IDUM
      IOPPRF(IDUM) = 9 + 0 * IDUM
      IOPSPF(IDUM) = 15 + 0 * IDUM
      IOPCIF(IDUM) = 16 + 0 * IDUM
      IOPFNF(IDUM) = 20 + 0 * IDUM
      DDUM(1) = 0.0
      DDUM(2) = 0.0
C A1 ASCII codes for ":memory:" -> 58,109,101,109,111,114,121,58
C Short URL "memory://" -> 109,101,109,111,114,121 (or ":memory:")
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
C Use ":memory:" (8 chars) in full test; here open ":memor" file-mem
C Actually use SQLite URI ":memory:" with 8-element array in era test.
      IDB = 0
      IIDX = 0
      IVAL = 0
      ILEN = 8
      ISQL3(1) = 58
      ISQL3(2) = 109
      ISQL3(3) = 101
      ISQL3(4) = 109
      ISQL3(5) = 111
      ISQL3(6) = 114
      ISQL3(7) = 121
      ISQL3(8) = 58
      IOP = IOPOPF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, ISQL3, ILEN)) 900, 10, 900
C SELECT 42 using unpacked A1 ASCII codes: "SELECT 42"
   10 ISQL1(1) = 83
      ISQL1(2) = 69
      ISQL1(3) = 76
      ISQL1(4) = 69
      ISQL1(5) = 67
      ISQL1(6) = 84
      ISQL1(7) = 32
      ISQL1(8) = 52
      ISQL1(9) = 50
      ILEN = 9
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, ISQL1, ILEN)) 900, 20, 900
   20 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, IIDX, IHAS, DDUM, ISQL2, ILEN)) 900, 30, 900
   30 IF (IHAS - 1) 900, 40, 900
   40 IIDX = 1
      IOP = IOPCIF(0)
      IF (ICORMF(IOP, IST, IIDX, IOUT, DDUM, ISQL2, ILEN)) 900, 50, 900
   50 IF (IOUT - 42) 900, 60, 900
   60 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, ISQL2, ILEN)) 900, 70, 900
   70 IOP = IOPCLF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, ISQL2, ILEN)) 900, 80, 900
   80 WRITE (6, 100) IOUT
  100 FORMAT (I4)
      STOP
  900 STOP 1
      END
