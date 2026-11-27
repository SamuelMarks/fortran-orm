C @file corm66_lib.f
C @brief Strict ANSI X3.9-1966 FORTRAN 66 ORM subroutine library.
C
C Conforms 100% to ANSI X3.9-1966: fixed-form columns 1-72, uppercase
C 6-character names, zero CHARACTER types, zero PARAMETER statements,
C zero block IF/THEN/ENDIF, and 1-trip-safe DO loop guards.

C @brief Opens a database connection from an unpacked A1 URL array.
C @param IA1URL Unpacked A1 ASCII integer array.
C @param ILEN Character count in IA1URL.
C @param IDB Receives 1-based database handle slot.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6OPEN(IA1URL, ILEN, IDB, IERR)
      INTEGER IA1URL(1), ILEN, IDB, IERR
      INTEGER IOP, IIDX, IVAL, NLEN
      DOUBLE PRECISION DVAL
      IOP = 1
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, IDB, IIDX, IVAL, DVAL, IA1URL, NLEN, IERR)
      RETURN
      END

C @brief Closes an ANSI FORTRAN 66 database connection slot.
C @param IDB 1-based database slot (cleared to 0 on success).
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6CLOS(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IOP, IIDX, IVAL, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 3
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, IDB, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Executes DDL or DML SQL from an unpacked A1 integer array.
C @param IDB Active 1-based database handle slot.
C @param IA1SQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Character count in IA1SQL.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6EXEC(IDB, IA1SQL, ILEN, IERR)
      INTEGER IDB, IA1SQL(1), ILEN, IERR
      INTEGER IOP, NHND, IIDX, IVAL, NLEN
      DOUBLE PRECISION DVAL
      IOP = 4
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IA1SQL, NLEN, IERR)
      RETURN
      END

C @brief Begins a database transaction on IDB.
C @param IDB Active 1-based database handle slot.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6TXBG(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IOP, NHND, IIDX, IVAL, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 6
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Commits a database transaction on IDB.
C @param IDB Active 1-based database handle slot.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6TXCM(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IOP, NHND, IIDX, IVAL, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 7
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Rolls back a database transaction on IDB.
C @param IDB Active 1-based database handle slot.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6TXRB(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IOP, NHND, IIDX, IVAL, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 8
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Prepares a parameterized SQL statement from an A1 array.
C @param IDB Active 1-based database handle slot.
C @param IA1SQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Character count in IA1SQL.
C @param ISTMT Receives 1-based statement handle slot.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6PREP(IDB, IA1SQL, ILEN, ISTMT, IERR)
      INTEGER IDB, IA1SQL(1), ILEN, ISTMT, IERR
      INTEGER IOP, NHND, IIDX, NLEN
      DOUBLE PRECISION DVAL
      IOP = 9
      NHND = IDB
      IIDX = 0
      ISTMT = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, ISTMT, DVAL, IA1SQL, NLEN, IERR)
      RETURN
      END

C @brief Binds an INTEGER parameter at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter position.
C @param IVAL Integer value to bind.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6BINI(ISTMT, IIDX, IVAL, IERR)
      INTEGER ISTMT, IIDX, IVAL, IERR
      INTEGER IOP, NHND, NVAL, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 11
      NHND = ISTMT
      NVAL = IVAL
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, NVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Binds a DOUBLE PRECISION parameter at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter position.
C @param DVAL Double-precision value to bind.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6BIND(ISTMT, IIDX, DVAL, IERR)
      INTEGER ISTMT, IIDX, IERR
      DOUBLE PRECISION DVAL, DTMP
      INTEGER IOP, NHND, IVAL, IDUM(1), NLEN
      IOP = 12
      NHND = ISTMT
      IVAL = 0
      DTMP = DVAL
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DTMP, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Binds an unpacked A1 string parameter at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter position.
C @param IA1STR Unpacked A1 ASCII integer array.
C @param ILEN Character count in IA1STR.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6BINA(ISTMT, IIDX, IA1STR, ILEN, IERR)
      INTEGER ISTMT, IIDX, IA1STR(1), ILEN, IERR
      INTEGER IOP, NHND, IVAL, NLEN
      DOUBLE PRECISION DVAL
      IOP = 13
      NHND = ISTMT
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IA1STR, NLEN, IERR)
      RETURN
      END

C @brief Steps a prepared statement by one row.
C @param ISTMT Prepared statement slot handle.
C @param IHASR Receives 1 when a row is available, 0 when done.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6STEP(ISTMT, IHASR, IERR)
      INTEGER ISTMT, IHASR, IERR
      INTEGER IOP, NHND, IIDX, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 15
      NHND = ISTMT
      IIDX = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IHASR, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Reads an INTEGER column at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based column index.
C @param IVAL Receives integer value.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6COLI(ISTMT, IIDX, IVAL, IERR)
      INTEGER ISTMT, IIDX, IVAL, IERR
      INTEGER IOP, NHND, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 16
      NHND = ISTMT
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Reads a DOUBLE PRECISION column at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based column index.
C @param DVAL Receives double-precision value.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6COLD(ISTMT, IIDX, DVAL, IERR)
      INTEGER ISTMT, IIDX, IERR
      DOUBLE PRECISION DVAL
      INTEGER IOP, NHND, IVAL, IDUM(1), NLEN
      IOP = 17
      NHND = ISTMT
      IVAL = 0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Reads a text column at IIDX into an unpacked A1 integer array.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based column index.
C @param IA1OUT Destination A1 integer array.
C @param ICAP Capacity of IA1OUT in elements.
C @param ILEN Receives trimmed character length.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6COLA(ISTMT, IIDX, IA1OUT, ICAP, ILEN, IERR)
      INTEGER ISTMT, IIDX, IA1OUT(1), ICAP, ILEN, IERR
      INTEGER IOP, NHND, NCAP
      DOUBLE PRECISION DVAL
      IOP = 18
      NHND = ISTMT
      NCAP = ICAP
      DVAL = 0.0D0
      CALL CORM66(IOP, NHND, IIDX, NCAP, DVAL, IA1OUT, ILEN, IERR)
      RETURN
      END

C @brief Finalizes and releases a prepared statement slot.
C @param ISTMT Prepared statement slot handle (cleared to 0).
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6FINL(ISTMT, IERR)
      INTEGER ISTMT, IERR
      INTEGER IOP, IIDX, IVAL, IDUM(1), NLEN
      DOUBLE PRECISION DVAL
      IOP = 20
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOP, ISTMT, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      RETURN
      END

C @brief Batch-inserts a 2D column-major DOUBLE PRECISION matrix.
C @param IDB Active 1-based database slot handle.
C @param IA1SQL Unpacked A1 ASCII INSERT SQL array.
C @param ILEN Character count in IA1SQL.
C @param DMAT Column-major DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param NROWS Number of rows to insert.
C @param NCOLS Number of columns in DMAT.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6MATI(IDB, IA1SQL, ILEN, DMAT, LDROWS, NROWS, NCOLS,
     1 IERR)
      INTEGER IDB, IA1SQL(1), ILEN, LDROWS, NROWS, NCOLS, IERR
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      INTEGER IMODE, IHOLMD, NOUT
      IMODE = 1
      IHOLMD = 1
      NOUT = 0
      CALL CORMMD(IMODE, IDB, IHOLMD, IA1SQL, ILEN, DMAT, LDROWS,
     1 NROWS, NCOLS, NOUT, IERR)
      RETURN
      END

C @brief Hydrates a SQL SELECT into a 2D column-major matrix DMAT.
C @param IDB Active 1-based database slot handle.
C @param IA1SQL Unpacked A1 ASCII SELECT SQL array.
C @param ILEN Character count in IA1SQL.
C @param DMAT Destination DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param MAXROW Maximum rows to read.
C @param NCOLS Number of columns to read.
C @param NOUT Receives hydrated row count.
C @param IERR Receives 0 on success or error code.
      SUBROUTINE C6MATQ(IDB, IA1SQL, ILEN, DMAT, LDROWS, MAXROW, NCOLS,
     1 NOUT, IERR)
      INTEGER IDB, IA1SQL(1), ILEN, LDROWS, MAXROW, NCOLS, NOUT, IERR
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      INTEGER IMODE, IHOLMD
      IMODE = 2
      IHOLMD = 1
      CALL CORMMD(IMODE, IDB, IHOLMD, IA1SQL, ILEN, DMAT, LDROWS,
     1 MAXROW, NCOLS, NOUT, IERR)
      RETURN
      END
