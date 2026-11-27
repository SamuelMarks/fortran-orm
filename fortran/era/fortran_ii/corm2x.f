C @file corm2x.f
C @brief Extended 1958 IBM FORTRAN II ORM abstractions: transactions,
C packed A4 Hollerith marshaling, DOUBLE PRECISION binds/columns,
C scalar aggregate queries, 1D/2D scientific array persistence, A1
C character utilities, and /CORMCM/ diagnostic functions.
C
C Uses strict 1958 FORTRAN II syntax only: fixed-form columns 1-72,
C <= 6-char uppercase identifiers without underscores, SUBROUTINE,
C FUNCTION, CALL, COMMON, RETURN, DIMENSION, and arithmetic IF.

C @brief Begins a database transaction and updates /CORMCM/.
C @param IDB Active 1-based database slot handle.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2TXBG(IDB, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 6
      NHND = IDB
      IIDX = 0
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Commits the active database transaction on IDB.
C @param IDB Active 1-based database slot handle.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2TXCM(IDB, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 7
      NHND = IDB
      IIDX = 0
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Rolls back the active database transaction on IDB.
C @param IDB Active 1-based database slot handle.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2TXRB(IDB, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 8
      NHND = IDB
      IIDX = 0
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Queries the last inserted rowid on IDB.
C @param IDB Active 1-based database slot handle.
C @param IRWID Receives last inserted 32-bit row identifier.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2RWID(IDB, IRWID, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 21
      NHND = IDB
      IIDX = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IRWID, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Binds a DOUBLE PRECISION parameter at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter position.
C @param DVAL Double-precision value to bind.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2BIND(ISTMT, IIDX, DVAL, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DVAL, DTMP
      DIMENSION IDUM(1)
      IDUM(1) = 0
      IOP = 12
      NHND = ISTMT
      IVAL = 0
      DTMP = DVAL
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DTMP, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Reads a DOUBLE PRECISION column at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based result column position.
C @param DVAL Receives double-precision column value.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2COLD(ISTMT, IIDX, DVAL, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DVAL
      DIMENSION IDUM(1)
      IDUM(1) = 0
      IOP = 17
      NHND = ISTMT
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Opens a database connection from a packed A4 Hollerith buffer.
C @param IHURL Packed A4 Hollerith integer array containing URL.
C @param ILEN Byte count of URL in IHURL.
C @param IDB Receives 1-based database slot handle.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2OPA4(IHURL, ILEN, IDB, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IHURL(1)
      DDUM = 0.0D0
      IOP = 2
      IIDX = 0
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, IDB, IIDX, IVAL, DDUM, IHURL, NLEN, IERR)
      LASTEC = IERR
      IF (IERR) 10, 20, 10
   20 LASTDB = IDB
   10 RETURN
      END

C @brief Executes DDL or DML SQL from a packed A4 Hollerith buffer.
C @param IDB Active 1-based database slot handle.
C @param IHSQL Packed A4 Hollerith SQL integer array.
C @param ILEN Byte count of SQL in IHSQL.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2EXA4(IDB, IHSQL, ILEN, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IHSQL(1)
      DDUM = 0.0D0
      IOP = 5
      NHND = IDB
      IIDX = 0
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IHSQL, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Prepares a SQL statement from a packed A4 Hollerith buffer.
C @param IDB Active 1-based database slot handle.
C @param IHSQL Packed A4 Hollerith SQL integer array.
C @param ILEN Byte count of SQL in IHSQL.
C @param ISTMT Receives 1-based prepared statement slot handle.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2PRA4(IDB, IHSQL, ILEN, ISTMT, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IHSQL(1)
      DDUM = 0.0D0
      IOP = 10
      NHND = IDB
      IIDX = 0
      ISTMT = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, ISTMT, DDUM, IHSQL, NLEN, IERR)
      LASTEC = IERR
      IF (IERR) 10, 20, 10
   20 LASTST = ISTMT
   10 RETURN
      END

C @brief Binds a packed A4 Hollerith string at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter index.
C @param IHBUF Packed A4 Hollerith integer array.
C @param ILEN Byte count in IHBUF.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2BNA4(ISTMT, IIDX, IHBUF, ILEN, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IHBUF(1)
      DDUM = 0.0D0
      IOP = 14
      NHND = ISTMT
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IHBUF, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Reads a text column into a packed A4 Hollerith integer buffer.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based column index.
C @param IHBUF Destination packed A4 integer array.
C @param ICAP Element capacity of IHBUF in 4-byte words.
C @param ILEN Receives trimmed string byte length.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2CLA4(ISTMT, IIDX, IHBUF, ICAP, ILEN, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DDUM
      DIMENSION IHBUF(1)
      DDUM = 0.0D0
      IOP = 19
      NHND = ISTMT
      NCAP = ICAP
      CALL CORM66(IOP, NHND, IIDX, NCAP, DDUM, IHBUF, ILEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Packs unpacked A1 ASCII codes IA1(1..NA1) into 4-byte A4 words.
C @param IA1 Source unpacked A1 ASCII integer array (codes 32..126).
C @param NA1 Number of active characters in IA1.
C @param IA4 Destination packed A4 integer word array.
C @param NWDS Number of 4-byte integer words to populate in IA4.
      SUBROUTINE F2PKA4(IA1, NA1, IA4, NWDS)
      DIMENSION IA1(1), IA4(1), IB(4)
      IF (NWDS) 90, 90, 10
   10 DO 40 IW = 1, NWDS
      DO 30 J = 1, 4
      IDX = (IW - 1) * 4 + J
      IF (IDX - NA1) 15, 15, 20
   15 IB(J) = IA1(IDX)
      GO TO 30
   20 IB(J) = 32
   30 CONTINUE
      IA4(IW) = IB(1) + 256 * (IB(2) + 256 * (IB(3) + 256 * IB(4)))
   40 CONTINUE
   90 RETURN
      END

C @brief Evaluates a 1-row, 1-column INTEGER scalar query from A1 SQL.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 ASCII SELECT SQL array.
C @param ILEN Character count in ISQL.
C @param IDEF Default value returned if query yields zero rows.
C @param IOUT Receives scalar integer result.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2SCAL(IDB, ISQL, ILEN, IDEF, IOUT, IERR)
      DIMENSION ISQL(1)
      IOUT = IDEF
      CALL F2PREP(IDB, ISQL, ILEN, IST, IERR)
      IF (IERR) 90, 10, 90
   10 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 30, 15, 30
   15 IF (IHAS) 30, 30, 20
   20 CALL F2COLI(IST, 1, IOUT, IERR)
   30 CALL F2FINL(IST, IFNL)
      IF (IERR) 90, 40, 90
   40 IERR = IFNL
   90 RETURN
      END

C @brief Evaluates a 1-row, 1-column DOUBLE PRECISION scalar query.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 ASCII SELECT SQL array.
C @param ILEN Character count in ISQL.
C @param DDEF Default value returned if query yields zero rows.
C @param DOUT Receives scalar double-precision result.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2SCLD(IDB, ISQL, ILEN, DDEF, DOUT, IERR)
      DOUBLE PRECISION DDEF, DOUT
      DIMENSION ISQL(1)
      DOUT = DDEF
      CALL F2PREP(IDB, ISQL, ILEN, IST, IERR)
      IF (IERR) 90, 10, 90
   10 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 30, 15, 30
   15 IF (IHAS) 30, 30, 20
   20 CALL F2COLD(IST, 1, DOUT, IERR)
   30 CALL F2FINL(IST, IFNL)
      IF (IERR) 90, 40, 90
   40 IERR = IFNL
   90 RETURN
      END

C @brief Batch-inserts a 1D INTEGER array IVEC(1..N) inside a tx.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 single-parameter INSERT SQL.
C @param ILEN Character count in ISQL.
C @param IVEC Source 1D integer vector.
C @param N Number of elements to insert.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2VECI(IDB, ISQL, ILEN, IVEC, N, IERR)
      DIMENSION ISQL(1), IVEC(1)
      IF (N) 5, 5, 10
    5 IERR = 0
      RETURN
   10 CALL F2TXBG(IDB, IERR)
      IF (IERR) 90, 15, 90
   15 DO 40 K = 1, N
      CALL F2PREP(IDB, ISQL, ILEN, IST, IERR)
      IF (IERR) 60, 20, 60
   20 CALL F2BINI(IST, 1, IVEC(K), IERR)
      IF (IERR) 25, 22, 25
   22 CALL F2STEP(IST, IHAS, IERR)
   25 CALL F2FINL(IST, IFNL)
      IF (IERR) 60, 30, 60
   30 IF (IFNL) 55, 40, 55
   40 CONTINUE
      CALL F2TXCM(IDB, IERR)
      RETURN
   55 IERR = IFNL
   60 CALL F2TXRB(IDB, IRBC)
      IERR = IERR + 0 * IRBC
   90 RETURN
      END

C @brief Hydrates column 1 of A1 SELECT SQL into 1D INTEGER array IVEC.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in ISQL.
C @param IVEC Destination 1D integer vector.
C @param ICAP Element capacity of IVEC.
C @param NOUT Receives number of hydrated elements.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2QRYI(IDB, ISQL, ILEN, IVEC, ICAP, NOUT, IERR)
      DIMENSION ISQL(1), IVEC(1)
      NOUT = 0
      CALL F2PREP(IDB, ISQL, ILEN, IST, IERR)
      IF (IERR) 90, 10, 90
   10 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 50, 15, 50
   15 IF (IHAS) 50, 50, 20
   20 IF (NOUT - ICAP) 25, 45, 45
   25 NOUT = NOUT + 1
      CALL F2COLI(IST, 1, IVEC(NOUT), IERR)
      IF (IERR) 50, 10, 50
   45 IERR = 34
   50 CALL F2FINL(IST, IFNL)
      IF (IERR) 90, 60, 90
   60 IERR = IFNL
   90 RETURN
      END

C @brief Batch-inserts a 1D DOUBLE PRECISION array DVEC(1..N) in a tx.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 single-parameter INSERT SQL.
C @param ILEN Character count in ISQL.
C @param DVEC Source 1D double-precision vector.
C @param N Number of elements to insert.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2VECD(IDB, ISQL, ILEN, DVEC, N, IERR)
      DOUBLE PRECISION DVEC(1)
      DIMENSION ISQL(1)
      IF (N) 5, 5, 10
    5 IERR = 0
      RETURN
   10 CALL F2TXBG(IDB, IERR)
      IF (IERR) 90, 15, 90
   15 DO 40 K = 1, N
      CALL F2PREP(IDB, ISQL, ILEN, IST, IERR)
      IF (IERR) 60, 20, 60
   20 CALL F2BIND(IST, 1, DVEC(K), IERR)
      IF (IERR) 25, 22, 25
   22 CALL F2STEP(IST, IHAS, IERR)
   25 CALL F2FINL(IST, IFNL)
      IF (IERR) 60, 30, 60
   30 IF (IFNL) 55, 40, 55
   40 CONTINUE
      CALL F2TXCM(IDB, IERR)
      RETURN
   55 IERR = IFNL
   60 CALL F2TXRB(IDB, IRBC)
      IERR = IERR + 0 * IRBC
   90 RETURN
      END

C @brief Hydrates column 1 of A1 SELECT SQL into DOUBLE PRECISION DVEC.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in ISQL.
C @param DVEC Destination 1D double-precision vector.
C @param ICAP Element capacity of DVEC.
C @param NOUT Receives number of hydrated elements.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2QRYD(IDB, ISQL, ILEN, DVEC, ICAP, NOUT, IERR)
      DOUBLE PRECISION DVEC(1)
      DIMENSION ISQL(1)
      NOUT = 0
      CALL F2PREP(IDB, ISQL, ILEN, IST, IERR)
      IF (IERR) 90, 10, 90
   10 CALL F2STEP(IST, IHAS, IERR)
      IF (IERR) 50, 15, 50
   15 IF (IHAS) 50, 50, 20
   20 IF (NOUT - ICAP) 25, 45, 45
   25 NOUT = NOUT + 1
      CALL F2COLD(IST, 1, DVEC(NOUT), IERR)
      IF (IERR) 50, 10, 50
   45 IERR = 34
   50 CALL F2FINL(IST, IFNL)
      IF (IERR) 90, 60, 90
   60 IERR = IFNL
   90 RETURN
      END

C @brief Batch-inserts a 2D column-major DOUBLE PRECISION matrix.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 parameterized INSERT SQL.
C @param ILEN Character count in ISQL.
C @param DMAT Column-major DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param NROWS Number of active rows to insert.
C @param NCOLS Number of columns in DMAT.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2MATI(IDB, ISQL, ILEN, DMAT, LDROWS, NROWS, NCOLS,
     1 IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      DIMENSION ISQL(1)
      IMODE = 1
      IHOLMD = 1
      NOUT = 0
      CALL CORMMD(IMODE, IDB, IHOLMD, ISQL, ILEN, DMAT, LDROWS, NROWS,
     1 NCOLS, NOUT, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Hydrates A1 SELECT SQL into a 2D column-major matrix DMAT.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in ISQL.
C @param DMAT Destination DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param MAXROW Maximum rows to hydrate.
C @param NCOLS Number of numeric columns to extract.
C @param NOUT Receives hydrated row count.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2MATQ(IDB, ISQL, ILEN, DMAT, LDROWS, MAXROW, NCOLS,
     1 NOUT, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      DIMENSION ISQL(1)
      IMODE = 2
      IHOLMD = 1
      CALL CORMMD(IMODE, IDB, IHOLMD, ISQL, ILEN, DMAT, LDROWS, MAXROW,
     1 NCOLS, NOUT, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Copies an unpacked A1 ASCII array with blank padding (code 32).
C @param ISRC Source A1 integer array.
C @param NSRC Number of source characters.
C @param IDST Destination A1 integer array.
C @param NDST Total capacity of IDST.
      SUBROUTINE F2A1CP(ISRC, NSRC, IDST, NDST)
      DIMENSION ISRC(1), IDST(1)
      IF (NDST) 90, 90, 10
   10 DO 30 K = 1, NDST
      IF (K - NSRC) 15, 15, 20
   15 IDST(K) = ISRC(K)
      GO TO 30
   20 IDST(K) = 32
   30 CONTINUE
   90 RETURN
      END

C @brief Compares two unpacked A1 ASCII arrays of length N.
C @param IA Left unpacked A1 integer array.
C @param IB Right unpacked A1 integer array.
C @param N Number of characters to compare.
C @return 1 when equal across 1..N, 0 when different.
      INTEGER FUNCTION IF2AEQ(IA, IB, N)
      DIMENSION IA(1), IB(1)
      IF2AEQ = 1
      IF (N) 90, 90, 10
   10 DO 30 K = 1, N
      IF (IA(K) - IB(K)) 20, 30, 20
   20 IF2AEQ = 0
      RETURN
   30 CONTINUE
   90 RETURN
      END

C @brief Returns 1 if /CORMCM/ LASTEC equals 0, else 0.
C @param IDUM Dummy argument required by 1958 FORTRAN II syntax.
C @return 1 when last FORTRAN II ORM operation succeeded, 0 otherwise.
      INTEGER FUNCTION IF2OK(IDUM)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      IF (LASTEC + 0 * IDUM) 10, 20, 10
   10 IF2OK = 0
      RETURN
   20 IF2OK = 1
      RETURN
      END
