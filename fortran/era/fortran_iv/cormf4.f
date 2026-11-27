C @file cormf4.f
C @brief 1962 IBM FORTRAN IV subroutine & BLOCK DATA ORM library.
C
C Uses authentic 1962 FORTRAN IV features: explicit INTEGER, DOUBLE
C PRECISION, and LOGICAL declarations, logical IF (.EQ., .AND.),
C packed A4 Hollerith integer buffers, BLOCK DATA, and 2D column-major
C DOUBLE PRECISION scientific matrix persistence.

C @brief Initializes FORTRAN IV opcode constants in /CORMF4/ COMMON.
      BLOCK DATA CORMBD
      INTEGER IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      COMMON /CORMF4/ IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      DATA IOPOP4, IOPCL4, IOPEX4 /1, 3, 4/
      DATA IOPBG4, IOPCM4, IOPRB4 /6, 7, 8/
      END

C @brief Opens a database connection using a packed A4 Hollerith URL.
C @param IHURL Packed A4 Hollerith integer array containing URL.
C @param ILEN Character byte count in IHURL.
C @param IDB Receives 1-based database slot ID.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4OPEN(IHURL, ILEN, IDB, LOK)
      INTEGER IHURL(1), ILEN, IDB
      LOGICAL LOK
      INTEGER IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      COMMON /CORMF4/ IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      INTEGER IIDX, IVAL, NLEN, IERR
      DOUBLE PRECISION DVAL
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOPOP4, IDB, IIDX, IVAL, DVAL, IHURL, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Executes packed A4 Hollerith DDL or DML SQL on IDB.
C @param IDB Active 1-based database slot ID.
C @param IHSQL Packed A4 Hollerith SQL integer array.
C @param ILEN Character byte count in IHSQL.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4EXEC(IDB, IHSQL, ILEN, LOK)
      INTEGER IDB, IHSQL(1), ILEN
      LOGICAL LOK
      INTEGER IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      COMMON /CORMF4/ IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      INTEGER NHND, IIDX, IVAL, NLEN, IERR
      DOUBLE PRECISION DVAL
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      NLEN = ILEN
      CALL CORM66(IOPEX4, NHND, IIDX, IVAL, DVAL, IHSQL, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Begins an explicit database transaction on IDB.
C @param IDB Active 1-based database slot ID.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4TXBG(IDB, LOK)
      INTEGER IDB
      LOGICAL LOK
      INTEGER IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      COMMON /CORMF4/ IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      INTEGER NHND, IIDX, IVAL, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOPBG4, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Commits the active database transaction on IDB.
C @param IDB Active 1-based database slot ID.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4TXCM(IDB, LOK)
      INTEGER IDB
      LOGICAL LOK
      INTEGER IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      COMMON /CORMF4/ IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      INTEGER NHND, IIDX, IVAL, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOPCM4, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Rolls back the active database transaction on IDB.
C @param IDB Active 1-based database slot ID.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4TXRB(IDB, LOK)
      INTEGER IDB
      LOGICAL LOK
      INTEGER IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      COMMON /CORMF4/ IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      INTEGER NHND, IIDX, IVAL, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      NHND = IDB
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOPRB4, NHND, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Inserts a column-major 2D DOUBLE PRECISION matrix into IDB.
C @param IDB Active 1-based database slot ID.
C @param IHSQL Packed A4 Hollerith parameterized INSERT SQL.
C @param ILEN Character byte count in IHSQL.
C @param DMAT Column-major DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param NROWS Number of active rows to insert.
C @param NCOLS Number of columns in DMAT.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4MATI(IDB, IHSQL, ILEN, DMAT, LDROWS, NROWS, NCOLS,
     1 LOK)
      INTEGER IDB, IHSQL(1), ILEN, LDROWS, NROWS, NCOLS
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      LOGICAL LOK
      INTEGER IMODE, IHOLMD, NOUT, IERR
      IMODE = 1
      IHOLMD = 1
      NOUT = 0
      CALL CORMMD(IMODE, IDB, IHOLMD, IHSQL, ILEN, DMAT, LDROWS, NROWS,
     1 NCOLS, NOUT, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Queries SQL directly into a column-major 2D matrix DMAT.
C @param IDB Active 1-based database slot ID.
C @param IHSQL Packed A4 Hollerith SELECT SQL.
C @param ILEN Character byte count in IHSQL.
C @param DMAT Destination DOUBLE PRECISION matrix DMAT(LDROWS, NCOLS).
C @param LDROWS Leading dimension of DMAT.
C @param MAXROW Maximum rows to hydrate.
C @param NCOLS Number of numeric columns to read.
C @param NOUT Receives number of hydrated rows.
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4MATQ(IDB, IHSQL, ILEN, DMAT, LDROWS, MAXROW, NCOLS,
     1 NOUT, LOK)
      INTEGER IDB, IHSQL(1), ILEN, LDROWS, MAXROW, NCOLS, NOUT
      DOUBLE PRECISION DMAT(LDROWS, NCOLS)
      LOGICAL LOK
      INTEGER IMODE, IHOLMD, IERR
      IMODE = 2
      IHOLMD = 1
      CALL CORMMD(IMODE, IDB, IHOLMD, IHSQL, ILEN, DMAT, LDROWS,
     1 MAXROW, NCOLS, NOUT, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END

C @brief Closes database handle IDB.
C @param IDB Database slot handle (cleared to 0 on success).
C @param LOK Receives .TRUE. on success, .FALSE. on failure.
      SUBROUTINE F4CLOS(IDB, LOK)
      INTEGER IDB
      LOGICAL LOK
      INTEGER IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      COMMON /CORMF4/ IOPOP4, IOPCL4, IOPEX4, IOPBG4, IOPCM4, IOPRB4
      INTEGER IIDX, IVAL, IDUM(1), NLEN, IERR
      DOUBLE PRECISION DVAL
      IIDX = 0
      IVAL = 0
      DVAL = 0.0D0
      IDUM(1) = 0
      NLEN = 0
      CALL CORM66(IOPCL4, IDB, IIDX, IVAL, DVAL, IDUM, NLEN, IERR)
      LOK = (IERR .EQ. 0)
      RETURN
      END
