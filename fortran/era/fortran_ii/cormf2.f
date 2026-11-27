C @file cormf2.f
C @brief 1958 IBM FORTRAN II subroutine & COMMON library for fortran-orm.
C
C Uses strict 1958 FORTRAN II features only: fixed-form columns 1-72,
C uppercase 6-character identifiers, SUBROUTINE, CALL, COMMON, RETURN,
C DIMENSION, implicit I-N integer typing, and arithmetic IF.

C @brief Opens a database from an unpacked A1 integer character array.
C @param IURL Unpacked A1 ASCII integer array.
C @param ILEN Number of characters in IURL.
C @param IDB Receives 1-based database slot handle.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2OPEN(IURL, ILEN, IDB, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IURL(1), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 1
      IIDX = 0
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, IDB, IIDX, IVAL, DDUM, IURL, NLEN, IERR)
      LASTEC = IERR
      IF (IERR) 10, 20, 10
   20 LASTDB = IDB
   10 RETURN
      END

C @brief Executes DDL or DML SQL from an unpacked A1 integer array.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Number of characters in ISQL.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2EXEC(IDB, ISQL, ILEN, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION ISQL(1), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 4
      NHND = IDB
      IIDX = 0
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, ISQL, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Prepares a parameterized SQL statement from an A1 array.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Number of characters in ISQL.
C @param ISTMT Receives 1-based prepared statement slot handle.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2PREP(IDB, ISQL, ILEN, ISTMT, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION ISQL(1), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 9
      NHND = IDB
      IIDX = 0
      ISTMT = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, ISTMT, DDUM, ISQL, NLEN, IERR)
      LASTEC = IERR
      IF (IERR) 10, 20, 10
   20 LASTST = ISTMT
   10 RETURN
      END

C @brief Binds a 32-bit integer parameter at 1-based index IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter position.
C @param IVAL Integer value to bind.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2BINI(ISTMT, IIDX, IVAL, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IDUM(1), DDUM(2)
      IDUM(1) = 0
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 11
      NHND = ISTMT
      NVAL = IVAL
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, NVAL, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Binds an unpacked A1 character array parameter at IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based parameter position.
C @param IBUF Unpacked A1 ASCII integer array.
C @param ILEN Number of characters in IBUF.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2BINA(ISTMT, IIDX, IBUF, ILEN, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IBUF(1), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 13
      NHND = ISTMT
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IBUF, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Steps a prepared statement by one row.
C @param ISTMT Prepared statement slot handle.
C @param IHASR Receives 1 if a row is ready, 0 on completion.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2STEP(ISTMT, IHASR, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IDUM(1), DDUM(2)
      IDUM(1) = 0
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 15
      NHND = ISTMT
      IIDX = 0
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IHASR, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Reads a 32-bit integer from 1-based result column IIDX.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based result column index.
C @param IVAL Receives integer column value.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2COLI(ISTMT, IIDX, IVAL, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IDUM(1), DDUM(2)
      IDUM(1) = 0
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 16
      NHND = ISTMT
      NLEN = 0
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Reads a text column into an unpacked A1 integer array.
C @param ISTMT Prepared statement slot handle.
C @param IIDX 1-based result column index.
C @param IBUF Destination unpacked A1 integer array.
C @param ICAP Element capacity of IBUF.
C @param ILEN Receives trimmed character length.
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2COLA(ISTMT, IIDX, IBUF, ICAP, ILEN, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IBUF(1), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 18
      NHND = ISTMT
      NCAP = ICAP
      CALL CORM66(IOP, NHND, IIDX, NCAP, DDUM, IBUF, ILEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Finalizes and releases a prepared statement slot.
C @param ISTMT Statement slot handle (cleared to 0 on success).
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2FINL(ISTMT, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IDUM(1), DDUM(2)
      IDUM(1) = 0
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 20
      IIDX = 0
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, ISTMT, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END

C @brief Closes and releases a database connection slot.
C @param IDB Database slot handle (cleared to 0 on success).
C @param IERR Receives 0 on success or error status code.
      SUBROUTINE F2CLOS(IDB, IERR)
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DIMENSION IDUM(1), DDUM(2)
      IDUM(1) = 0
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 3
      IIDX = 0
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, IDB, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      LASTEC = IERR
      RETURN
      END
