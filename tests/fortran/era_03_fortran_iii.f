C @file era_03_fortran_iii.f
C @brief End-to-end 1958-59 IBM FORTRAN III boolean-mask ORM test suite.
C
C Exercises F3OPEN, F3EXEC, F3MASK, and F3CLOS verifying portable
C ICORMB boolean word bitmasks across live and closed database handles.
      DIMENSION IURL(8), ISQL(22)
      IURL(1) = 58
      IURL(2) = 109
      IURL(3) = 101
      IURL(4) = 109
      IURL(5) = 111
      IURL(6) = 114
      IURL(7) = 121
      IURL(8) = 58
      IDB = 0
      CALL F3OPEN(IURL, 8, IDB, IWORD)
      IF (IWORD - 3) 900, 10, 900
C "CREATE TABLE T3(X INT)" (22 chars)
   10 ISQL(1) = 67
      ISQL(2) = 82
      ISQL(3) = 69
      ISQL(4) = 65
      ISQL(5) = 84
      ISQL(6) = 69
      ISQL(7) = 32
      ISQL(8) = 84
      ISQL(9) = 65
      ISQL(10) = 66
      ISQL(11) = 76
      ISQL(12) = 69
      ISQL(13) = 32
      ISQL(14) = 84
      ISQL(15) = 51
      ISQL(16) = 40
      ISQL(17) = 88
      ISQL(18) = 32
      ISQL(19) = 73
      ISQL(20) = 78
      ISQL(21) = 84
      ISQL(22) = 41
      CALL F3EXEC(IDB, ISQL, 22, IWORD)
      IF (IWORD - 3) 900, 20, 900
   20 CALL F3MASK(0, IDB, 2, IWORD)
      IF (IWORD - 2) 900, 30, 900
   30 CALL F3CLOS(IDB, IWORD)
      IF (IWORD - 1) 900, 40, 900
   40 WRITE (6, 100) IWORD
  100 FORMAT (I6)
      STOP
  900 STOP 1
      END
