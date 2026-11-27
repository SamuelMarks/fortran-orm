C @file corm4x.f
C @brief Extended 1962 IBM FORTRAN IV ORM abstractions: prepared
C statements with LOGICAL status, LOGICAL-to-integer SQL marshaling,
C unpacked A1 & packed A4 text persistence, scalar DOUBLE PRECISION
C aggregates, 1D vector batching, and 2D matrix Frobenius norm/scaling.
C
C Conforms strictly to 1962 FORTRAN IV: fixed-form columns 1-72,
C <= 6-char uppercase identifiers without underscores, explicit INTEGER,
C DOUBLE PRECISION, and LOGICAL types, single-line logical IF, and zero
C CHARACTER/PARAMETER/IMPLICIT/THEN/ENDIF keywords.

C @brief Opens a database from an unpacked A1 ASCII integer array.
C @param IA1URL Unpacked A1 ASCII URL array.
C @param ILEN Character count in IA1URL.
C @param IDB Receives 1-based database slot ID.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4OA1(IA1URL, ILEN, IDB, LOK)
      INTEGER IA1URL(1), ILEN, IDB
      LOGICAL LOK
      INTEGER IOP, IIDX, IVAL, NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 1
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, IDB, IIDX, IVAL, DVAL, IA1URL, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Executes DDL or DML SQL from an unpacked A1 ASCII array.
C @param IDB Active 1-based database slot ID.
C @param IA1SQL Unpacked A1 ASCII SQL array.
C @param ILEN Character count in IA1SQL.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4EXA1(IDB, IA1SQL, ILEN, LOK)
      INTEGER IDB, IA1SQL(1), ILEN
      LOGICAL LOK
      INTEGER IOP, NHND, IIDX, IVAL, NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 4
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IA1SQL, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Prepares a parameterized SQL statement from an A1 array.
C @param IDB Active 1-based database slot ID.
C @param IA1SQL Unpacked A1 ASCII SQL array.
C @param ILEN Character count in IA1SQL.
C @param ISTMT Receives 1-based statement slot ID.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4PREP(IDB, IA1SQL, ILEN, ISTMT, LOK)
      INTEGER IDB, IA1SQL(1), ILEN, ISTMT
      LOGICAL LOK
      INTEGER IOP, NHND, IIDX, NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 9
      NHND = IDB
      IIDX = 0
      ISTMT = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, ISTMT, DVAL, IA1SQL, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Binds a 32-bit INTEGER value at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based parameter position.
C @param IVAL Integer value to bind.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4BINI(ISTMT, IIDX, IVAL, LOK)
      INTEGER ISTMT, IIDX, IVAL
      LOGICAL LOK
      INTEGER IOP, NHND, NVAL, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 11
      NHND = ISTMT
      NVAL = IVAL
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, NVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Binds a DOUBLE PRECISION value at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based parameter position.
C @param DVAL Double-precision value to bind.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4BIND(ISTMT, IIDX, DVAL, LOK)
      INTEGER ISTMT, IIDX
      DOUBLE PRECISION DVAL, DTMP
      LOGICAL LOK
      INTEGER IOP, NHND, IVAL, IDUM(1), NLEN, IERR
      IOP = 12
      NHND = ISTMT
      IVAL = 0
      DTMP = DVAL
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DTMP, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Binds a FORTRAN IV LOGICAL flag (.TRUE.=1, .FALSE.=0) at IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based parameter position.
C @param LFLAG Logical flag value to bind.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4BINL(ISTMT, IIDX, LFLAG, LOK)
      INTEGER ISTMT, IIDX
      LOGICAL LFLAG, LOK
      INTEGER IFLAG
      IFLAG = 0
      IF (LFLAG) IFLAG = 1
      CALL F4BINI(ISTMT, IIDX, IFLAG, LOK)
      RETURN
      END

C @brief Binds an unpacked A1 character array at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based parameter position.
C @param IA1STR Unpacked A1 ASCII integer array.
C @param ILEN Character count in IA1STR.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4BINA(ISTMT, IIDX, IA1STR, ILEN, LOK)
      INTEGER ISTMT, IIDX, IA1STR(1), ILEN
      LOGICAL LOK
      INTEGER IOP, NHND, IVAL, NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 13
      NHND = ISTMT
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IA1STR, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Advances prepared statement ISTMT by one row.
C @param ISTMT Prepared statement slot ID.
C @param LROW Receives .TRUE. when a row is ready, .FALSE. on EOF/err.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4STEP(ISTMT, LROW, LOK)
      INTEGER ISTMT
      LOGICAL LROW, LOK
      INTEGER IOP, NHND, IIDX, IHAS, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 15
      NHND = ISTMT
      IIDX = 0
      IHAS = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IHAS, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      LROW = (IERR .EQ. 0 .AND. IHAS .NE. 0)
      RETURN
      END

C @brief Reads a 32-bit INTEGER from 1-based column IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based column position.
C @param IVAL Receives integer column value.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4COLI(ISTMT, IIDX, IVAL, LOK)
      INTEGER ISTMT, IIDX, IVAL
      LOGICAL LOK
      INTEGER IOP, NHND, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 16
      NHND = ISTMT
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Reads a DOUBLE PRECISION value from 1-based column IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based column position.
C @param DVAL Receives double-precision column value.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4COLD(ISTMT, IIDX, DVAL, LOK)
      INTEGER ISTMT, IIDX
      DOUBLE PRECISION DVAL
      LOGICAL LOK
      INTEGER IOP, NHND, IVAL, IDUM(1), NLEN, IERR
      IOP = 17
      NHND = ISTMT
      IVAL = 0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Reads a FORTRAN IV LOGICAL flag from 1-based column IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based column position.
C @param LFLAG Receives .TRUE. when column != 0, else .FALSE.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4COLL(ISTMT, IIDX, LFLAG, LOK)
      INTEGER ISTMT, IIDX
      LOGICAL LFLAG, LOK
      INTEGER IVAL
      IVAL = 0
      CALL F4COLI(ISTMT, IIDX, IVAL, LOK)
      LFLAG = (LOK .AND. IVAL .NE. 0)
      RETURN
      END

C @brief Reads an unpacked A1 text column from 1-based column IIDX.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based column position.
C @param IA1OUT Destination A1 integer array.
C @param ICAP Element capacity of IA1OUT.
C @param ILEN Receives trimmed character length.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4COLA(ISTMT, IIDX, IA1OUT, ICAP, ILEN, LOK)
      INTEGER ISTMT, IIDX, IA1OUT(1), ICAP, ILEN
      LOGICAL LOK
      INTEGER IOP, NHND, NCAP, IERR
      DOUBLE PRECISION DVAL
      IOP = 18
      NHND = ISTMT
      NCAP = ICAP
      DVAL = 0.0D0
      CALL CORM66(IOP, NHND, IIDX, NCAP, DVAL, IA1OUT, ILEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Finalizes and releases statement slot ISTMT.
C @param ISTMT Prepared statement slot ID (cleared to 0).
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4FINL(ISTMT, LOK)
      INTEGER ISTMT
      LOGICAL LOK
      INTEGER IOP, IIDX, IVAL, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      IOP = 20
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, ISTMT, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Batch-inserts a 1D DOUBLE PRECISION vector DVEC(1..N) in a tx.
C @param IDB Active 1-based database slot ID.
C @param IA1SQL Unpacked A1 single-parameter INSERT SQL.
C @param ILEN Character count in IA1SQL.
C @param DVEC Source 1D double-precision vector.
C @param N Number of elements to insert.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4VECD(IDB, IA1SQL, ILEN, DVEC, N, LOK)
      INTEGER IDB, IA1SQL(1), ILEN, N
      DOUBLE PRECISION DVEC(1)
      LOGICAL LOK
      INTEGER K, IST
      LOGICAL LROW, LFNL, LRBC
      LOK = .TRUE.
      IF (N .LE. 0) RETURN
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) RETURN
      DO 30 K = 1, N
      CALL F4PREP(IDB, IA1SQL, ILEN, IST, LOK)
      IF (.NOT. LOK) GO TO 50
      CALL F4BIND(IST, 1, DVEC(K), LOK)
      IF (LOK) CALL F4STEP(IST, LROW, LOK)
      CALL F4FINL(IST, LFNL)
      LOK = (LOK .AND. LFNL .AND. (.NOT. LROW .OR. LROW))
      IF (.NOT. LOK) GO TO 50
   30 CONTINUE
      CALL F4TXCM(IDB, LOK)
      RETURN
   50 CALL F4TXRB(IDB, LRBC)
      LOK = (.FALSE. .AND. LRBC)
      RETURN
      END

C @brief Hydrates column 1 of A1 SELECT SQL into DOUBLE PRECISION DVEC.
C @param IDB Active 1-based database slot ID.
C @param IA1SQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in IA1SQL.
C @param DVEC Destination 1D double-precision vector.
C @param ICAP Element capacity of DVEC.
C @param NOUT Receives hydrated element count.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4QRYD(IDB, IA1SQL, ILEN, DVEC, ICAP, NOUT, LOK)
      INTEGER IDB, IA1SQL(1), ILEN, ICAP, NOUT
      DOUBLE PRECISION DVEC(1)
      LOGICAL LOK
      INTEGER IST
      LOGICAL LROW, LFNL
      NOUT = 0
      CALL F4PREP(IDB, IA1SQL, ILEN, IST, LOK)
      IF (.NOT. LOK) RETURN
   10 CALL F4STEP(IST, LROW, LOK)
      IF (.NOT. LOK .OR. .NOT. LROW) GO TO 40
      IF (NOUT .GE. ICAP) GO TO 35
      NOUT = NOUT + 1
      CALL F4COLD(IST, 1, DVEC(NOUT), LOK)
      IF (LOK) GO TO 10
      GO TO 40
   35 LOK = .FALSE.
   40 CALL F4FINL(IST, LFNL)
      LOK = (LOK .AND. LFNL)
      RETURN
      END

C @brief Scales active submatrix DMAT(1:NROWS, 1:NCOLS) by DGAIN and
C persists it via F4MATI.
C @param IDB Active 1-based database slot ID.
C @param IA1SQL Unpacked A1 parameterized INSERT SQL.
C @param ILEN Character count in IA1SQL.
C @param DMAT Column-major DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param NROWS Number of active rows.
C @param NCOLS Number of active columns.
C @param DGAIN Multiplicative scale factor applied in-place before save.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4MSCL(IDB, IA1SQL, ILEN, DMAT, LDROWS, NROWS, NCOLS,
     1 DGAIN, LOK)
      INTEGER IDB, IA1SQL(1), ILEN, LDROWS, NROWS, NCOLS
      DOUBLE PRECISION DMAT(LDROWS, NCOLS), DGAIN
      LOGICAL LOK
      INTEGER I, J
      IF (NROWS .LE. 0 .OR. NCOLS .LE. 0) GO TO 25
      DO 20 J = 1, NCOLS
      DO 10 I = 1, NROWS
      DMAT(I, J) = DMAT(I, J) * DGAIN
   10 CONTINUE
   20 CONTINUE
   25 CALL F4MATI(IDB, IA1SQL, ILEN, DMAT, LDROWS, NROWS, NCOLS, LOK)
      RETURN
      END

C @brief Evaluates a scalar DOUBLE PRECISION SQL query in FORTRAN IV.
C @param IDB Active 1-based database slot ID.
C @param IA1SQL Unpacked A1 SELECT SQL returning 1 numeric column.
C @param ILEN Character count in IA1SQL.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
C @return Hydrated DOUBLE PRECISION scalar (0.0D0 when empty or error).
      DOUBLE PRECISION FUNCTION DF4SUM(IDB, IA1SQL, ILEN, LOK)
      INTEGER IDB, IA1SQL(1), ILEN
      LOGICAL LOK
      INTEGER IST
      LOGICAL LROW, LFNL
      DF4SUM = 0.0D0
      CALL F4PREP(IDB, IA1SQL, ILEN, IST, LOK)
      IF (.NOT. LOK) RETURN
      CALL F4STEP(IST, LROW, LOK)
      IF (LOK .AND. LROW) CALL F4COLD(IST, 1, DF4SUM, LOK)
      CALL F4FINL(IST, LFNL)
      LOK = (LOK .AND. LFNL)
      RETURN
      END

C @brief Computes Frobenius norm of active submatrix DMAT(1:NROWS,1:NC).
C @param DMAT Column-major DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param NROWS Number of active rows.
C @param NCOLS Number of active columns.
C @return Euclidean Frobenius norm DSQRT(SUM(DMAT(I,J)**2)).
      DOUBLE PRECISION FUNCTION DF4NRM(DMAT, LDROWS, NROWS, NCOLS)
      INTEGER LDROWS, NROWS, NCOLS
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      DOUBLE PRECISION DSQ
      INTEGER I, J
      DSQ = 0.0D0
      IF (NROWS .LE. 0 .OR. NCOLS .LE. 0) GO TO 30
      DO 20 J = 1, NCOLS
      DO 10 I = 1, NROWS
      DSQ = DSQ + DMAT(I, J) * DMAT(I, J)
   10 CONTINUE
   20 CONTINUE
   30 DF4NRM = DSQRT(DSQ)
      RETURN
      END

C @brief Checks whether FORTRAN IV DB slot IDB is live via ICORMB.
C @param IDB Candidate 1-based database slot ID.
C @return .TRUE. when IDB refers to an open legacy DB slot.
      LOGICAL FUNCTION LF4LIV(IDB)
      INTEGER IDB
      INTEGER ISTAT, IMASK, IWORD, IRC, ICORMB
      ISTAT = 0
      IMASK = 2
      IWORD = 0
      IRC = ICORMB(ISTAT, IDB, IMASK, IWORD)
      LF4LIV = (IRC .EQ. 0 .AND. IWORD .EQ. 2)
      RETURN
      END
