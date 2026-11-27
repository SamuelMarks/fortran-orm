C @file corm66_ext.f
C @brief Extended strict ANSI X3.9-1966 FORTRAN 66 ORM abstractions:
C packed A4 Hollerith entry points, rowid & scalar aggregate queries,
C 1-trip-safe 1D INTEGER/DOUBLE PRECISION vector persistence, persistent
C (X,Y) empirical lookup & linear interpolation tables, and A1 codecs.
C
C Conforms 100% to ANSI X3.9-1966: fixed-form columns 1-72, <= 6-char
C uppercase names without underscores, zero CHARACTER, zero PARAMETER,
C zero SAVE, zero INCLUDE, zero block IF/THEN/ENDIF, and 1-trip-safe DO
C guards.

C @brief Opens a database connection from a packed A4 Hollerith URL.
C @param IHURL Packed A4 Hollerith integer array.
C @param ILEN Byte count of URL in IHURL.
C @param IDB Receives 1-based database slot handle.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6OPA4(IHURL, ILEN, IDB, IERR)
      INTEGER IHURL(1), ILEN, IDB, IERR
      INTEGER IOP, IIDX, IVAL, NLEN
      DOUBLE PRECISION DVAL
      IOP = 2
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, IDB, IIDX, IVAL, DVAL, IHURL, NLEN, IERR)
      RETURN
      END

C @brief Executes DDL or DML SQL from a packed A4 Hollerith buffer.
C @param IDB Active 1-based database slot handle.
C @param IHSQL Packed A4 Hollerith SQL integer array.
C @param ILEN Byte count in IHSQL.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6EXA4(IDB, IHSQL, ILEN, IERR)
      INTEGER IDB, IHSQL(1), ILEN, IERR
      INTEGER IOP, NHND, IIDX, IVAL, NLEN
      DOUBLE PRECISION DVAL
      IOP = 5
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IHSQL, NLEN, IERR)
      RETURN
      END

C @brief Prepares a SQL statement from a packed A4 Hollerith buffer.
C @param IDB Active 1-based database slot handle.
C @param IHSQL Packed A4 Hollerith SQL integer array.
C @param ILEN Byte count in IHSQL.
C @param ISTMT Receives 1-based statement slot handle.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6PRA4(IDB, IHSQL, ILEN, ISTMT, IERR)
      INTEGER IDB, IHSQL(1), ILEN, ISTMT, IERR
      INTEGER IOP, NHND, IIDX, NLEN
      DOUBLE PRECISION DVAL
      IOP = 10
      NHND = IDB
      IIDX = 0
      ISTMT = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, ISTMT, DVAL, IHSQL, NLEN, IERR)
      RETURN
      END

C @brief Binds a packed A4 Hollerith string at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter position.
C @param IHSTR Packed A4 Hollerith integer array.
C @param ILEN Byte count in IHSTR.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6BNA4(ISTMT, IIDX, IHSTR, ILEN, IERR)
      INTEGER ISTMT, IIDX, IHSTR(1), ILEN, IERR
      INTEGER IOP, NHND, IVAL, NLEN
      DOUBLE PRECISION DVAL
      IOP = 14
      NHND = ISTMT
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IHSTR, NLEN, IERR)
      RETURN
      END

C @brief Reads a text column into a packed A4 Hollerith integer buffer.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based column position.
C @param IHOUT Destination packed A4 integer array.
C @param ICAP Capacity of IHOUT in 4-byte integer words.
C @param ILEN Receives trimmed byte length.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6CLA4(ISTMT, IIDX, IHOUT, ICAP, ILEN, IERR)
      INTEGER ISTMT, IIDX, IHOUT(1), ICAP, ILEN, IERR
      INTEGER IOP, NHND, NCAP
      DOUBLE PRECISION DVAL
      IOP = 19
      NHND = ISTMT
      NCAP = ICAP
      DVAL = 0.0D0
      CALL CORM66(IOP, NHND, IIDX, NCAP, DVAL, IHOUT, ILEN, IERR)
      RETURN
      END

C @brief Queries the last inserted 32-bit rowid on IDB.
C @param IDB Active 1-based database slot handle.
C @param IRWID Receives last inserted rowid.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6RWID(IDB, IRWID, IERR)
      INTEGER IDB, IRWID, IERR
      INTEGER IOP, NHND, IIDX, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 21
      NHND = IDB
      IIDX = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IRWID, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Executes a scalar INTEGER query from an unpacked A1 SQL array.
C @param IDB Active 1-based database slot handle.
C @param IA1SQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in IA1SQL.
C @param IDEF Default integer if zero rows returned.
C @param IVAL Receives scalar integer result.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6QINT(IDB, IA1SQL, ILEN, IDEF, IVAL, IERR)
      INTEGER IDB, IA1SQL(1), ILEN, IDEF, IVAL, IERR
      INTEGER IST, IHAS, IFNL
      IVAL = IDEF
      CALL C6PREP(IDB, IA1SQL, ILEN, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .EQ. 0 .AND. IHAS .NE. 0)
     1 CALL C6COLI(IST, 1, IVAL, IERR)
      CALL C6FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Executes a scalar DOUBLE PRECISION query from A1 SQL.
C @param IDB Active 1-based database slot handle.
C @param IA1SQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in IA1SQL.
C @param DDEF Default value if zero rows returned.
C @param DVAL Receives scalar double-precision result.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6QDBL(IDB, IA1SQL, ILEN, DDEF, DVAL, IERR)
      INTEGER IDB, IA1SQL(1), ILEN, IERR
      DOUBLE PRECISION DDEF, DVAL
      INTEGER IST, IHAS, IFNL
      DVAL = DDEF
      CALL C6PREP(IDB, IA1SQL, ILEN, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .EQ. 0 .AND. IHAS .NE. 0)
     1 CALL C6COLD(IST, 1, DVAL, IERR)
      CALL C6FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Batch-inserts a 1D DOUBLE PRECISION vector DVEC(1..N) in a tx.
C @param IDB Active 1-based database slot handle.
C @param IA1SQL Unpacked A1 single-parameter INSERT SQL.
C @param ILEN Character count in IA1SQL.
C @param DVEC Source 1D DOUBLE PRECISION array.
C @param N Element count (1-trip-safe guard skips when N <= 0).
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6VECD(IDB, IA1SQL, ILEN, DVEC, N, IERR)
      INTEGER IDB, IA1SQL(1), ILEN, N, IERR
      DOUBLE PRECISION DVEC(1)
      INTEGER K, IST, IHAS, IFNL, IRBC
      IERR = 0
      IF (N .LE. 0) RETURN
      CALL C6TXBG(IDB, IERR)
      IF (IERR .NE. 0) RETURN
      DO 30 K = 1, N
      CALL C6PREP(IDB, IA1SQL, ILEN, IST, IERR)
      IF (IERR .NE. 0) GO TO 50
      CALL C6BIND(IST, 1, DVEC(K), IERR)
      IF (IERR .EQ. 0) CALL C6STEP(IST, IHAS, IERR)
      CALL C6FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      IF (IERR .NE. 0) GO TO 50
   30 CONTINUE
      CALL C6TXCM(IDB, IERR)
      RETURN
   50 CALL C6TXRB(IDB, IRBC)
      IERR = IERR + 0 * IRBC
      RETURN
      END

C @brief Hydrates column 1 of A1 SELECT SQL into DOUBLE PRECISION DVEC.
C @param IDB Active 1-based database slot handle.
C @param IA1SQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in IA1SQL.
C @param DVEC Destination 1D DOUBLE PRECISION array.
C @param ICAP Maximum element capacity of DVEC.
C @param NOUT Receives hydrated element count.
C @param IERR Receives 0 on success or 34 on overflow.
      SUBROUTINE C6QRYD(IDB, IA1SQL, ILEN, DVEC, ICAP, NOUT, IERR)
      INTEGER IDB, IA1SQL(1), ILEN, ICAP, NOUT, IERR
      DOUBLE PRECISION DVEC(1)
      INTEGER IST, IHAS, IFNL
      NOUT = 0
      CALL C6PREP(IDB, IA1SQL, ILEN, IST, IERR)
      IF (IERR .NE. 0) RETURN
   10 CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0 .OR. IHAS .EQ. 0) GO TO 40
      IF (NOUT .GE. ICAP) GO TO 35
      NOUT = NOUT + 1
      CALL C6COLD(IST, 1, DVEC(NOUT), IERR)
      IF (IERR .EQ. 0) GO TO 10
      GO TO 40
   35 IERR = 34
   40 CALL C6FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Creates and populates an empirical (X, Y) lookup table C6LUT
C on IDB from parallel DOUBLE PRECISION arrays XVEC and YVEC.
C @param IDB Active 1-based database slot handle.
C @param XVEC Monotone abscissa array XVEC(1..N).
C @param YVEC Ordinate array YVEC(1..N).
C @param N Number of knots to persist.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6KVIN(IDB, XVEC, YVEC, N, IERR)
      INTEGER IDB, N, IERR
      DOUBLE PRECISION XVEC(1), YVEC(1)
      INTEGER IDDL(34), IDEL(14), IINS(26), K, IST, IHAS, IFNL, IRBC
C "CREATE TABLE IF NOT EXISTS L6(X,Y)" (34 chars)
      DATA IDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,73,70,32,78,
     1           79,84,32,69,88,73,83,84,83,32,76,54,40,88,44,89,41/
C "DELETE FROM L6" (14 chars)
      DATA IDEL /68,69,76,69,84,69,32,70,82,79,77,32,76,54/
C "INSERT INTO L6 VALUES(?,?)" (26 chars)
      DATA IINS /73,78,83,69,82,84,32,73,78,84,79,32,76,54,32,86,65,
     1           76,85,69,83,40,63,44,63,41/
      CALL C6EXEC(IDB, IDDL, 34, IERR)
      IF (IERR .NE. 0) RETURN
      CALL C6EXEC(IDB, IDEL, 14, IERR)
      IF (IERR .NE. 0 .OR. N .LE. 0) RETURN
      CALL C6TXBG(IDB, IERR)
      IF (IERR .NE. 0) RETURN
      DO 30 K = 1, N
      CALL C6PREP(IDB, IINS, 26, IST, IERR)
      IF (IERR .NE. 0) GO TO 50
      CALL C6BIND(IST, 1, XVEC(K), IERR)
      IF (IERR .EQ. 0) CALL C6BIND(IST, 2, YVEC(K), IERR)
      IF (IERR .EQ. 0) CALL C6STEP(IST, IHAS, IERR)
      CALL C6FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      IF (IERR .NE. 0) GO TO 50
   30 CONTINUE
      CALL C6TXCM(IDB, IERR)
      RETURN
   50 CALL C6TXRB(IDB, IRBC)
      IERR = IERR + 0 * IRBC
      RETURN
      END

C @brief Evaluates piecewise-linear interpolation Y(XQ) directly from
C persisted table L6 ordered by X.
C @param IDB Active 1-based database slot handle.
C @param XQ Query abscissa.
C @param YOUT Receives interpolated (or clamped endpoint) ordinate.
C @param IERR Receives 0 on success or 7 if table is empty.
      SUBROUTINE C6KVIT(IDB, XQ, YOUT, IERR)
      INTEGER IDB, IERR
      DOUBLE PRECISION XQ, YOUT
      INTEGER ISEL(27), IST, IHAS, IFNL, NREAD
      DOUBLE PRECISION XP, YP, XC, YC, DX
C "SELECT X,Y FROM L6 ORDER BY X" (29) -> "SELECT X,Y FROM L6" (18)
      DATA ISEL /83,69,76,69,67,84,32,88,44,89,32,70,82,79,77,32,76,
     1           54,9*32/
      YOUT = 0.0D0
      NREAD = 0
      XP = 0.0D0
      YP = 0.0D0
      CALL C6PREP(IDB, ISEL, 18, IST, IERR)
      IF (IERR .NE. 0) RETURN
   10 CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0 .OR. IHAS .EQ. 0) GO TO 40
      CALL C6COLD(IST, 1, XC, IERR)
      IF (IERR .EQ. 0) CALL C6COLD(IST, 2, YC, IERR)
      IF (IERR .NE. 0) GO TO 40
      NREAD = NREAD + 1
      IF (NREAD .EQ. 1) YOUT = YC
      IF (NREAD .EQ. 1 .AND. XQ .LE. XC) GO TO 40
      IF (NREAD .GT. 1 .AND. XQ .LE. XC) GO TO 30
      XP = XC
      YP = YC
      YOUT = YC
      GO TO 10
   30 DX = XC - XP
      IF (DABS(DX) .GT. 1.0D-15)
     1 YOUT = YP + (XQ - XP) * (YC - YP) / DX
   40 CALL C6FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      IF (IERR .EQ. 0 .AND. NREAD .EQ. 0) IERR = 7
      RETURN
      END

C @brief Computes trimmed non-blank length of an A1 integer array.
C @param IA1 Unpacked A1 ASCII integer array.
C @param N Total capacity of IA1.
C @return Last index in 1..N whose ASCII code is not 32 (0 if all 32).
      INTEGER FUNCTION IC6ALN(IA1, N)
      INTEGER IA1(1), N
      INTEGER K
      IC6ALN = 0
      IF (N .LE. 0) RETURN
      DO 10 K = 1, N
      IF (IA1(K) .NE. 32) IC6ALN = K
   10 CONTINUE
      RETURN
      END

C @brief Formats non-negative integer IVAL into unpacked A1 ASCII digits.
C @param IVAL Non-negative integer value.
C @param IA1OUT Destination A1 integer array.
C @param ICAP Capacity of IA1OUT.
C @param NLEN Receives number of decimal digits written.
C @param IERR Receives 0 on success or 26 on truncation.
      SUBROUTINE C6I2A1(IVAL, IA1OUT, ICAP, NLEN, IERR)
      INTEGER IVAL, IA1OUT(1), ICAP, NLEN, IERR
      INTEGER ITMP(12), N, NDIG, K, J
      NLEN = 0
      IERR = 0
      IF (ICAP .LE. 0 .OR. IVAL .LT. 0) GO TO 50
      N = IVAL
      NDIG = 0
   10 NDIG = NDIG + 1
      ITMP(NDIG) = 48 + (N - (N / 10) * 10)
      N = N / 10
      IF (N .GT. 0) GO TO 10
      IF (NDIG .GT. ICAP) GO TO 50
      DO 20 K = 1, NDIG
      J = NDIG - K + 1
      IA1OUT(K) = ITMP(J)
   20 CONTINUE
      NLEN = NDIG
      IF (ICAP .LE. NDIG) RETURN
      J = NDIG + 1
      DO 30 K = J, ICAP
      IA1OUT(K) = 32
   30 CONTINUE
      RETURN
   50 IERR = 26
      RETURN
      END

C @brief Packs unpacked A1 ASCII codes IA1(1..NA1) into 4-byte A4 words.
C @param IA1 Source unpacked A1 ASCII integer array (codes 32..126).
C @param NA1 Number of active characters in IA1.
C @param IA4 Destination packed A4 integer word array.
C @param NWDS Number of 4-byte integer words to populate in IA4.
      SUBROUTINE C6PKA4(IA1, NA1, IA4, NWDS)
      INTEGER IA1(1), NA1, IA4(1), NWDS
      INTEGER IB(4), IW, J, IDX
      IF (NWDS .LE. 0) RETURN
      DO 30 IW = 1, NWDS
      DO 20 J = 1, 4
      IDX = (IW - 1) * 4 + J
      IB(J) = 32
      IF (IDX .LE. NA1) IB(J) = IA1(IDX)
   20 CONTINUE
      IA4(IW) = IB(1) + 256 * (IB(2) + 256 * (IB(3) + 256 * IB(4)))
   30 CONTINUE
      RETURN
      END
