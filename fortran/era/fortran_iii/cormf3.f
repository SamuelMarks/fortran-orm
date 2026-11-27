C @file cormf3.f
C @brief 1958-59 IBM FORTRAN III portable boolean-word ORM wrappers.
C
C IBM 704/709 FORTRAN III introduced inline symbolic machine code (S in
C column 1, non-portable) and word-level boolean masking. This library
C implements the portable FORTRAN III subset using ICORMB to evaluate
C boolean status/handle bitmasks without hardware-specific S cards.

C @brief Opens a database in FORTRAN III using unpacked A1 URL array.
C @param IURL Unpacked A1 ASCII integer array.
C @param ILEN Length of IURL.
C @param IDB Receives 1-based database slot ID.
C @param IWORD Receives boolean status word (bit 0=OK, bit 1=DB live).
      SUBROUTINE F3OPEN(IURL, ILEN, IDB, IWORD)
      DIMENSION IURL(1), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 1
      IIDX = 0
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, IDB, IIDX, IVAL, DDUM, IURL, NLEN, IERR)
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 RETURN
      END

C @brief Executes unpacked A1 SQL and returns FORTRAN III boolean mask.
C @param IDB Active 1-based database slot ID.
C @param ISQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Length of ISQL.
C @param IWORD Receives boolean status word (3 when OK and DB active).
      SUBROUTINE F3EXEC(IDB, ISQL, ILEN, IWORD)
      DIMENSION ISQL(1), DDUM(2)
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 4
      NHND = IDB
      IIDX = 0
      IVAL = 0
      NLEN = ILEN
      CALL CORM66(IOP, NHND, IIDX, IVAL, DDUM, ISQL, NLEN, IERR)
      IMASK = 3
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 RETURN
      END

C @brief Evaluates a custom FORTRAN III boolean bitmask via ICORMB.
C @param ISTAT Last integer error status code.
C @param IDB Database slot handle to inspect.
C @param IMASK Bitwise filter mask (1=status OK, 2=handle live, 3=both).
C @param IWORD Receives masked boolean integer word.
      SUBROUTINE F3MASK(ISTAT, IDB, IMASK, IWORD)
      IRC = ICORMB(ISTAT, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 RETURN
      END

C @brief Closes a FORTRAN III database handle and updates boolean word.
C @param IDB Database slot handle (cleared to 0 on success).
C @param IWORD Receives 1 if close succeeded and slot is now 0, else 0.
      SUBROUTINE F3CLOS(IDB, IWORD)
      DIMENSION IDUM(1), DDUM(2)
      IDUM(1) = 0
      DDUM(1) = 0.0
      DDUM(2) = 0.0
      IOP = 3
      IIDX = 0
      IVAL = 0
      NLEN = 0
      CALL CORM66(IOP, IDB, IIDX, IVAL, DDUM, IDUM, NLEN, IERR)
      IMASK = 1
      IRC = ICORMB(IERR, IDB, IMASK, IWORD)
      IF (IRC) 10, 20, 10
   10 IWORD = 0
   20 RETURN
      END
