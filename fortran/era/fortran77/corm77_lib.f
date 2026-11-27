C @file corm77_lib.f
C @brief Strict ANSI X3.9-1978 FORTRAN 77 CHARACTER*(*) ORM library.
C
C Conforms strictly to ANSI X3.9-1978: fixed-form columns 1-72,
C <= 6-character uppercase names without underscores, CHARACTER*(*)
C dummy arguments, block IF/THEN/ELSE/END IF, and zero Fortran 90+
C keywords.

C @brief Opens a database connection from a CHARACTER*(*) URL.
C @param URL Connection URL string (trailing spaces trimmed).
C @param IDB Receives 1-based database handle slot.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7OPEN(URL, IDB, IERR)
      CHARACTER*(*) URL
      INTEGER IDB, IERR
      CALL CF77OP(URL, IDB, IERR)
      RETURN
      END

C @brief Closes a FORTRAN 77 database connection handle.
C @param IDB 1-based database slot (cleared to 0 on success).
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7CLOS(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IMODE
      IMODE = 1
      CALL CF77CL(IMODE, IDB, IERR)
      RETURN
      END

C @brief Executes DDL or DML SQL on IDB.
C @param IDB Active 1-based database slot.
C @param SQL SQL statement text.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7EXEC(IDB, SQL, IERR)
      INTEGER IDB, IERR
      CHARACTER*(*) SQL
      INTEGER IMODE, IOUT
      IMODE = 1
      IOUT = 0
      CALL CF77EX(IMODE, IDB, SQL, IOUT, IERR)
      RETURN
      END

C @brief Queries the last inserted row ID on IDB.
C @param IDB Active 1-based database slot.
C @param IROWID Receives last inserted integer row ID.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7ROW(IDB, IROWID, IERR)
      INTEGER IDB, IROWID, IERR
      INTEGER IMODE
      IMODE = 8
      CALL CF77EX(IMODE, IDB, ' ', IROWID, IERR)
      RETURN
      END

C @brief Begins a transaction on IDB.
C @param IDB Active 1-based database slot.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7TXBG(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IMODE, IOUT
      IMODE = 2
      IOUT = 0
      CALL CF77EX(IMODE, IDB, ' ', IOUT, IERR)
      RETURN
      END

C @brief Commits the active transaction on IDB.
C @param IDB Active 1-based database slot.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7TXCM(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IMODE, IOUT
      IMODE = 3
      IOUT = 0
      CALL CF77EX(IMODE, IDB, ' ', IOUT, IERR)
      RETURN
      END

C @brief Rolls back the active transaction on IDB.
C @param IDB Active 1-based database slot.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7TXRB(IDB, IERR)
      INTEGER IDB, IERR
      INTEGER IMODE, IOUT
      IMODE = 4
      IOUT = 0
      CALL CF77EX(IMODE, IDB, ' ', IOUT, IERR)
      RETURN
      END

C @brief Creates a named savepoint on IDB.
C @param IDB Active 1-based database slot.
C @param SPNAME Savepoint identifier.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7SVPT(IDB, SPNAME, IERR)
      INTEGER IDB, IERR
      CHARACTER*(*) SPNAME
      INTEGER IMODE, IOUT
      IMODE = 5
      IOUT = 0
      CALL CF77EX(IMODE, IDB, SPNAME, IOUT, IERR)
      RETURN
      END

C @brief Rolls back to a named savepoint on IDB.
C @param IDB Active 1-based database slot.
C @param SPNAME Savepoint identifier.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7RBSP(IDB, SPNAME, IERR)
      INTEGER IDB, IERR
      CHARACTER*(*) SPNAME
      INTEGER IMODE, IOUT
      IMODE = 6
      IOUT = 0
      CALL CF77EX(IMODE, IDB, SPNAME, IOUT, IERR)
      RETURN
      END

C @brief Releases a named savepoint on IDB.
C @param IDB Active 1-based database slot.
C @param SPNAME Savepoint identifier.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7RLSP(IDB, SPNAME, IERR)
      INTEGER IDB, IERR
      CHARACTER*(*) SPNAME
      INTEGER IMODE, IOUT
      IMODE = 7
      IOUT = 0
      CALL CF77EX(IMODE, IDB, SPNAME, IOUT, IERR)
      RETURN
      END

C @brief Prepares a parameterized SQL statement on IDB.
C @param IDB Active 1-based database slot.
C @param SQL Parameterized SQL string.
C @param ISTMT Receives 1-based statement slot.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7PREP(IDB, SQL, ISTMT, IERR)
      INTEGER IDB, ISTMT, IERR
      CHARACTER*(*) SQL
      INTEGER IMODE, IIDX, ILEN
      DOUBLE PRECISION DVAL
      IMODE = 1
      IIDX = 0
      ISTMT = 0
      DVAL = 0.0D0
      ILEN = 0
      CALL CF77ST(IMODE, IDB, IIDX, ISTMT, DVAL, SQL, ILEN, IERR)
      RETURN
      END

C @brief Binds a 32-bit INTEGER value at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based parameter index.
C @param IVAL Integer value to bind.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7BINI(ISTMT, IIDX, IVAL, IERR)
      INTEGER ISTMT, IIDX, IVAL, IERR
      INTEGER IMODE, NVAL, ILEN
      DOUBLE PRECISION DVAL
      CHARACTER*1 CDUM
      IMODE = 2
      NVAL = IVAL
      DVAL = 0.0D0
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, NVAL, DVAL, CDUM, ILEN, IERR)
      RETURN
      END

C @brief Binds a DOUBLE PRECISION value at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based parameter index.
C @param DVAL Double-precision value to bind.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7BIND(ISTMT, IIDX, DVAL, IERR)
      INTEGER ISTMT, IIDX, IERR
      DOUBLE PRECISION DVAL, DTMP
      INTEGER IMODE, IVAL, ILEN
      CHARACTER*1 CDUM
      IMODE = 3
      IVAL = 0
      DTMP = DVAL
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, IVAL, DTMP, CDUM, ILEN, IERR)
      RETURN
      END

C @brief Binds a CHARACTER*(*) string at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based parameter index.
C @param CVAL Character value (trailing spaces trimmed).
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7BINC(ISTMT, IIDX, CVAL, IERR)
      INTEGER ISTMT, IIDX, IERR
      CHARACTER*(*) CVAL
      INTEGER IMODE, IVAL, ILEN
      DOUBLE PRECISION DVAL
      IMODE = 4
      IVAL = 0
      DVAL = 0.0D0
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, IVAL, DVAL, CVAL, ILEN, IERR)
      RETURN
      END

C @brief Binds SQL NULL at 1-based parameter IIDX.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based parameter index.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7BINN(ISTMT, IIDX, IERR)
      INTEGER ISTMT, IIDX, IERR
      INTEGER IMODE, IVAL, ILEN
      DOUBLE PRECISION DVAL
      CHARACTER*1 CDUM
      IMODE = 5
      IVAL = 0
      DVAL = 0.0D0
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, IVAL, DVAL, CDUM, ILEN, IERR)
      RETURN
      END

C @brief Advances ISTMT by one row, setting LROW = .TRUE. when ready.
C @param ISTMT Prepared statement slot.
C @param LROW Receives .TRUE. if row available, .FALSE. on completion.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7STEP(ISTMT, LROW, IERR)
      INTEGER ISTMT, IERR
      LOGICAL LROW
      INTEGER IMODE, IIDX, IHAS, ILEN
      DOUBLE PRECISION DVAL
      CHARACTER*1 CDUM
      IMODE = 6
      IIDX = 0
      IHAS = 0
      DVAL = 0.0D0
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, IHAS, DVAL, CDUM, ILEN, IERR)
      IF (IERR .EQ. 0 .AND. IHAS .NE. 0) THEN
        LROW = .TRUE.
      ELSE
        LROW = .FALSE.
      END IF
      RETURN
      END

C @brief Resets ISTMT for re-execution with new bindings.
C @param ISTMT Prepared statement slot.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7RSET(ISTMT, IERR)
      INTEGER ISTMT, IERR
      INTEGER IMODE, IIDX, IVAL, ILEN
      DOUBLE PRECISION DVAL
      CHARACTER*1 CDUM
      IMODE = 7
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, IVAL, DVAL, CDUM, ILEN, IERR)
      RETURN
      END

C @brief Reads an INTEGER value from 1-based column IIDX.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based column index.
C @param IVAL Receives integer column value.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7COLI(ISTMT, IIDX, IVAL, IERR)
      INTEGER ISTMT, IIDX, IVAL, IERR
      INTEGER IMODE, ILEN
      DOUBLE PRECISION DVAL
      CHARACTER*1 CDUM
      IMODE = 8
      DVAL = 0.0D0
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, IVAL, DVAL, CDUM, ILEN, IERR)
      RETURN
      END

C @brief Reads a DOUBLE PRECISION value from 1-based column IIDX.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based column index.
C @param DVAL Receives double-precision column value.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7COLD(ISTMT, IIDX, DVAL, IERR)
      INTEGER ISTMT, IIDX, IERR
      DOUBLE PRECISION DVAL
      INTEGER IMODE, IVAL, ILEN
      CHARACTER*1 CDUM
      IMODE = 9
      IVAL = 0
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, IVAL, DVAL, CDUM, ILEN, IERR)
      RETURN
      END

C @brief Reads a CHARACTER*(*) string from 1-based column IIDX.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based column index.
C @param COUT Destination blank-padded character variable.
C @param ILEN Receives trimmed character length.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7COLC(ISTMT, IIDX, COUT, ILEN, IERR)
      INTEGER ISTMT, IIDX, ILEN, IERR
      CHARACTER*(*) COUT
      INTEGER IMODE, IVAL
      DOUBLE PRECISION DVAL
      IMODE = 10
      IVAL = 0
      DVAL = 0.0D0
      CALL CF77ST(IMODE, ISTMT, IIDX, IVAL, DVAL, COUT, ILEN, IERR)
      RETURN
      END

C @brief Checks whether 1-based column IIDX is SQL NULL.
C @param ISTMT Prepared statement slot.
C @param IIDX 1-based column index.
C @param LNULL Receives .TRUE. if SQL NULL, .FALSE. otherwise.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7COLN(ISTMT, IIDX, LNULL, IERR)
      INTEGER ISTMT, IIDX, IERR
      LOGICAL LNULL
      INTEGER IMODE, INUL, ILEN
      DOUBLE PRECISION DVAL
      CHARACTER*1 CDUM
      IMODE = 11
      INUL = 0
      DVAL = 0.0D0
      CDUM = ' '
      ILEN = 0
      CALL CF77ST(IMODE, ISTMT, IIDX, INUL, DVAL, CDUM, ILEN, IERR)
      IF (IERR .EQ. 0 .AND. INUL .NE. 0) THEN
        LNULL = .TRUE.
      ELSE
        LNULL = .FALSE.
      END IF
      RETURN
      END

C @brief Finalizes and releases statement slot ISTMT.
C @param ISTMT Prepared statement slot (cleared to 0).
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7FINL(ISTMT, IERR)
      INTEGER ISTMT, IERR
      INTEGER IMODE
      IMODE = 2
      CALL CF77CL(IMODE, ISTMT, IERR)
      RETURN
      END

C @brief Batch-inserts a 2D column-major DOUBLE PRECISION matrix.
C @param IDB Active 1-based database slot.
C @param SQL Parameterized INSERT SQL string.
C @param DMAT Column-major DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param NROWS Number of active rows to insert.
C @param NCOLS Number of columns in DMAT.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7MATI(IDB, SQL, DMAT, LDROWS, NROWS, NCOLS, IERR)
      INTEGER IDB, LDROWS, NROWS, NCOLS, IERR
      CHARACTER*(*) SQL
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      INTEGER IMODE, NOUT
      IMODE = 1
      NOUT = 0
      CALL CF77MX(IMODE, IDB, SQL, DMAT, LDROWS, NROWS, NCOLS, NOUT,
     1 IERR)
      RETURN
      END

C @brief Hydrates a SQL SELECT directly into column-major matrix DMAT.
C @param IDB Active 1-based database slot.
C @param SQL SELECT SQL string.
C @param DMAT Destination DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param MAXROW Maximum rows to hydrate.
C @param NCOLS Number of numeric columns to read.
C @param NOUT Receives hydrated row count.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7MATQ(IDB, SQL, DMAT, LDROWS, MAXROW, NCOLS, NOUT,
     1 IERR)
      INTEGER IDB, LDROWS, MAXROW, NCOLS, NOUT, IERR
      CHARACTER*(*) SQL
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      INTEGER IMODE
      IMODE = 2
      CALL CF77MX(IMODE, IDB, SQL, DMAT, LDROWS, MAXROW, NCOLS, NOUT,
     1 IERR)
      RETURN
      END

C @brief Creates a SELECT * FROM <TBL> AST builder with optional LIMIT.
C @param TBL Table name string.
C @param NLIMIT Row limit (0 for unlimited).
C @param IAST Receives 1-based AST builder slot.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7ASTS(TBL, NLIMIT, IAST, IERR)
      CHARACTER*(*) TBL
      INTEGER NLIMIT, IAST, IERR
      INTEGER IMODE, IDUM, LDUM, NCOL
      DOUBLE PRECISION DDUM(1)
      IMODE = 3
      IDUM = 0
      LDUM = 1
      NCOL = 1
      DDUM(1) = 0.0D0
      CALL CF77MX(IMODE, IDUM, TBL, DDUM, LDUM, NLIMIT, NCOL, IAST,
     1 IERR)
      RETURN
      END

C @brief Renders AST slot IAST into dialect-specific SQL text.
C @param IAST 1-based AST builder slot.
C @param IDIAL Target SQL dialect (0=SQLite,1=PG,2=MySQL,3=Db2,4=ODBC).
C @param OUTSQL Destination blank-padded SQL buffer.
C @param ILEN Receives rendered SQL byte length.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7ASTR(IAST, IDIAL, OUTSQL, ILEN, IERR)
      INTEGER IAST, IDIAL, ILEN, IERR
      CHARACTER*(*) OUTSQL
      INTEGER IMODE, LDUM, NROW
      DOUBLE PRECISION DDUM(1)
      IMODE = 4
      LDUM = 1
      NROW = 0
      DDUM(1) = 0.0D0
      CALL CF77MX(IMODE, IAST, OUTSQL, DDUM, LDUM, NROW, IDIAL, ILEN,
     1 IERR)
      RETURN
      END

C @brief Frees AST builder slot IAST.
C @param IAST 1-based AST builder slot (cleared to 0).
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7ASTF(IAST, IERR)
      INTEGER IAST, IERR
      INTEGER IMODE
      IMODE = 4
      CALL CF77CL(IMODE, IAST, IERR)
      RETURN
      END
