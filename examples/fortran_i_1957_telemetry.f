C @file fortran_i_1957_telemetry.f
C @brief 1957 IBM 704 FORTRAN (I) wind-tunnel telemetry logger example.
C
C Uses pure 1957 FORTRAN (I) statement functions, unpacked A1 ASCII
C integer arrays, and three-way arithmetic IF statements to log five
C Mach-number telemetry integers into SQLite via ICORMF and compute
C their persisted average.
      DIMENSION IURL(8), IDDL(22), IINS(24), ISEL(16), DDUM(2)
      IOPOPF(IDUM) = 1 + 0 * IDUM
      IOPCLF(IDUM) = 3 + 0 * IDUM
      IOPEXF(IDUM) = 4 + 0 * IDUM
      IOPPRF(IDUM) = 9 + 0 * IDUM
      IOPBIF(IDUM) = 11 + 0 * IDUM
      IOPSPF(IDUM) = 15 + 0 * IDUM
      IOPCIF(IDUM) = 16 + 0 * IDUM
      IOPFNF(IDUM) = 20 + 0 * IDUM
      DDUM(1) = 0.0
      DDUM(2) = 0.0
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
      IDDL(14) = 87
      IDDL(15) = 84
      IDDL(16) = 40
      IDDL(17) = 77
      IDDL(18) = 32
      IDDL(19) = 73
      IDDL(20) = 78
      IDDL(21) = 84
      IDDL(22) = 41
      ILEN = 22
      IOP = IOPEXF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, IDDL, ILEN)) 900, 20, 900
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
      IINS(13) = 87
      IINS(14) = 84
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
      DO 40 K = 1, 5
      ILEN = 24
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, IINS, ILEN)) 900, 25, 900
   25 IIDX = 1
      IVAL = K * 100
      IOP = IOPBIF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 30, 900
   30 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, IIDX, IHAS, DDUM, IINS, ILEN)) 900, 35, 900
   35 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, IINS, ILEN)) 900, 40, 900
   40 CONTINUE
      ISEL(1) = 83
      ISEL(2) = 69
      ISEL(3) = 76
      ISEL(4) = 69
      ISEL(5) = 67
      ISEL(6) = 84
      ISEL(7) = 32
      ISEL(8) = 77
      ISEL(9) = 32
      ISEL(10) = 70
      ISEL(11) = 82
      ISEL(12) = 79
      ISEL(13) = 77
      ISEL(14) = 32
      ISEL(15) = 87
      ISEL(16) = 84
      ILEN = 16
      IOP = IOPPRF(0)
      IF (ICORMF(IOP, IDB, IIDX, IST, DDUM, ISEL, ILEN)) 900, 45, 900
   45 ISUM = 0
   50 IOP = IOPSPF(0)
      IF (ICORMF(IOP, IST, IIDX, IHAS, DDUM, ISEL, ILEN)) 900, 52, 900
   52 IF (IHAS) 900, 60, 54
   54 IIDX = 1
      IOP = IOPCIF(0)
      IF (ICORMF(IOP, IST, IIDX, IM, DDUM, ISEL, ILEN)) 900, 56, 900
   56 ISUM = ISUM + IM
      GO TO 50
   60 IAVG = ISUM / 5
      IF (IAVG - 300) 900, 65, 900
   65 IOP = IOPFNF(0)
      IF (ICORMF(IOP, IST, IIDX, IVAL, DDUM, ISEL, ILEN)) 900, 70, 900
   70 IOP = IOPCLF(0)
      IF (ICORMF(IOP, IDB, IIDX, IVAL, DDUM, ISEL, ILEN)) 900, 75, 900
   75 WRITE (6, 100) IAVG
  100 FORMAT (I6)
      STOP
  900 STOP 1
      END
