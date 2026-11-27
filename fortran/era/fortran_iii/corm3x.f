C @file corm3x.f
C @brief Extended 1958-59 IBM FORTRAN III boolean status-word ORM
C abstractions: transactions, prepared statements, guarded short-circuit
C execution pipelines, bitmask combinators, and 1D/2D array persistence.
C
C Uses strict 1958-59 FORTRAN III syntax: fixed-form columns 1-72,
C <= 6-char uppercase identifiers without underscores, zero LOGICAL,
C zero CHARACTER, zero PARAMETER, and portable ICORMB boolean masks.

C @brief Begins a transaction on IDB and returns boolean status word.
C @param IDB Active 1-based database slot ID.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3TXBG(IDB, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
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
      I3STAT = IERR
      I3DB = IDB
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Commits the active transaction on IDB and updates boolean word.
C @param IDB Active 1-based database slot ID.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3TXCM(IDB, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
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
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Rolls back the active transaction on IDB and updates mask.
C @param IDB Active 1-based database slot ID.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3TXRB(IDB, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
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
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Guarded SQL execution: runs ISQL only if IWORD equals 3.
C @param IDB Active 1-based database slot ID.
C @param ISQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Character count in ISQL.
C @param IWORD Input/output boolean pipeline word (short-circuits != 3).
      SUBROUTINE F3GEX(IDB, ISQL, ILEN, IWORD)
      DIMENSION ISQL(1)
      IF (IWORD - 3) 10, 20, 10
   10 IWORD = 0
      RETURN
   20 CALL F3EXEC(IDB, ISQL, ILEN, IWORD)
      RETURN
      END

C @brief Prepares an A1 SQL statement and returns boolean status word.
C @param IDB Active 1-based database slot ID.
C @param ISQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Character count in ISQL.
C @param ISTMT Receives 1-based prepared statement slot ID.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3PREP(IDB, ISQL, ILEN, ISTMT, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DDUM
      DIMENSION ISQL(1)
      DDUM = 0.0D0
      IOP = 9
      NHND = IDB
      IIDX = 0
      ISTMT = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, ISTMT, DDUM, ISQL, NLEN, IERR)
      I3STAT = IERR
      I3DB = IDB
      I3STMT = ISTMT
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Binds an INTEGER parameter and updates boolean status word.
C @param IDB Active 1-based database slot ID for mask evaluation.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based parameter position.
C @param IVAL Integer value to bind.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3BINI(IDB, ISTMT, IIDX, IVAL, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 11
      NHND = ISTMT
      NVAL = IVAL
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, NVAL, DDUM, IDUM, NLEN, IERR)
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Binds a DOUBLE PRECISION parameter and updates boolean word.
C @param IDB Active 1-based database slot ID for mask evaluation.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based parameter position.
C @param DVAL Double-precision value to bind.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3BIND(IDB, ISTMT, IIDX, DVAL, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DVAL, DTMP
      DIMENSION IDUM(1)
      IDUM(1) = 0
      IOP = 12
      NHND = ISTMT
      IVAL = 0
      DTMP = DVAL
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DTMP, IDUM, NLEN, IERR)
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Steps a prepared statement and updates boolean status word.
C @param IDB Active 1-based database slot ID for mask evaluation.
C @param ISTMT Prepared statement slot ID.
C @param IHASR Receives 1 when row ready, 0 on completion.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3STEP(IDB, ISTMT, IHASR, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 15
      NHND = ISTMT
      IIDX = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IHASR, DDUM, IDUM, NLEN, IERR)
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Reads an INTEGER column and updates boolean status word.
C @param IDB Active 1-based database slot ID for mask evaluation.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based column index.
C @param IVAL Receives integer column value.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3COLI(IDB, ISTMT, IIDX, IVAL, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 16
      NHND = ISTMT
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Reads a DOUBLE PRECISION column and updates boolean word.
C @param IDB Active 1-based database slot ID for mask evaluation.
C @param ISTMT Prepared statement slot ID.
C @param IIDX 1-based column index.
C @param DVAL Receives double-precision column value.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3COLD(IDB, ISTMT, IIDX, DVAL, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DVAL
      DIMENSION IDUM(1)
      IDUM(1) = 0
      IOP = 17
      NHND = ISTMT
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Finalizes a statement handle and updates boolean status word.
C @param IDB Active 1-based database slot ID for mask evaluation.
C @param ISTMT Prepared statement slot ID (cleared to 0).
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3FINL(IDB, ISTMT, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DDUM
      DIMENSION IDUM(1)
      IDUM(1) = 0
      DDUM = 0.0D0
      IOP = 20
      IIDX = 0
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, ISTMT, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      I3STAT = IERR
      I3STMT = ISTMT
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Persists a 2D column-major DOUBLE PRECISION matrix in F3.
C @param IDB Active 1-based database slot ID.
C @param ISQL Unpacked A1 parameterized INSERT SQL.
C @param ILEN Character count in ISQL.
C @param DMAT Column-major DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param NROWS Number of active rows to insert.
C @param NCOLS Number of columns in DMAT.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3MATI(IDB, ISQL, ILEN, DMAT, LDROWS, NROWS, NCOLS,
     1 IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      DIMENSION ISQL(1)
      IMODE = 1
      IHOLMD = 1
      NOUT = 0
      CALL CORMMD(IMODE, IDB, IHOLMD, ISQL, ILEN, DMAT, LDROWS, NROWS,
     1 NCOLS, NOUT, IERR)
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Hydrates A1 SELECT SQL into 2D column-major matrix DMAT in F3.
C @param IDB Active 1-based database slot ID.
C @param ISQL Unpacked A1 SELECT SQL array.
C @param ILEN Character count in ISQL.
C @param DMAT Destination DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param MAXROW Maximum rows to hydrate.
C @param NCOLS Number of columns to extract.
C @param NOUT Receives hydrated row count.
C @param IWORD Receives boolean status word (3 when OK and DB live).
      SUBROUTINE F3MATQ(IDB, ISQL, ILEN, DMAT, LDROWS, MAXROW, NCOLS,
     1 NOUT, IWORD)
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      DIMENSION ISQL(1)
      IMODE = 2
      IHOLMD = 1
      CALL CORMMD(IMODE, IDB, IHOLMD, ISQL, ILEN, DMAT, LDROWS, MAXROW,
     1 NCOLS, NOUT, IERR)
      I3STAT = IERR
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 I3WORD = IWORD
      RETURN
      END

C @brief Portable FORTRAN III bit extractor on 2-bit status word IWORD.
C @param IWORD Boolean status word (0..3).
C @param IBIT Bit selector (1 for OK bit, 2 for DB-live bit).
C @return 1 if requested bit is set in IWORD, else 0.
      INTEGER FUNCTION IF3BIT(IWORD, IBIT)
      IF (IBIT - 1) 10, 20, 30
   10 IF3BIT = 0
      RETURN
   20 IF3BIT = IWORD - (IWORD / 2) * 2
      RETURN
   30 IF (IBIT - 2) 10, 40, 10
   40 IF3BIT = (IWORD / 2) - ((IWORD / 2) / 2) * 2
      RETURN
      END

C @brief Portable FORTRAN III conjunction across two 2-bit status words.
C @param IWA First boolean status word (0..3).
C @param IWB Second boolean status word (0..3).
C @return Bitwise AND of low two bits of IWA and IWB.
      INTEGER FUNCTION IF3ALL(IWA, IWB)
      IB0 = IF3BIT(IWA, 1) * IF3BIT(IWB, 1)
      IB1 = IF3BIT(IWA, 2) * IF3BIT(IWB, 2)
      IF3ALL = IB0 + 2 * IB1
      RETURN
      END
