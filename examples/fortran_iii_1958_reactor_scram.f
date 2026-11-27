C @file fortran_iii_1958_reactor_scram.f
C @brief 1958-59 IBM 704/709 FORTRAN III reactor interlock audit example.
C
C Uses the portable FORTRAN III boolean status-word subset (F3OPEN,
C F3EXEC, F3MASK, F3CLOS backed by ICORMB) to audit control-rod bank
C insertions and verify bitmasked live/closed handle states without
C hardware-specific IBM 704 S-column symbolic machine cards.
      DIMENSION IURL(8), IDDL(22), IRD1(30), IRD2(28)
      DATA IURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE RODS(B,P)" (22 chars)
      DATA IDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,82,79,68,83,
     1           40,66,44,80,41/
C "INSERT INTO RODS VALUES(1,100)" (30 chars)
      DATA IRD1 /73,78,83,69,82,84,32,73,78,84,79,32,82,79,68,83,32,
     1           86,65,76,85,69,83,40,49,44,49,48,48,41/
C "INSERT INTO RODS VALUES(2,0)" (28 chars)
      DATA IRD2 /73,78,83,69,82,84,32,73,78,84,79,32,82,79,68,83,32,
     1           86,65,76,85,69,83,40,50,44,48,41/
      IDB = 0
      CALL F3OPEN(IURL, 8, IDB, IWORD)
      IF (IWORD - 3) 900, 10, 900
   10 CALL EXCMSK(IDB, IDDL, 22, IOK)
      IF (IOK - 5) 900, 20, 900
   20 CALL EXCMSK(IDB, IRD1, 30, IOK)
      IF (IOK - 5) 900, 30, 900
   30 CALL EXCMSK(IDB, IRD2, 28, IOK)
      IF (IOK - 5) 900, 40, 900
   40 CALL F3CLOS(IDB, IWORD)
      IF (IWORD - 1) 900, 50, 900
   50 CALL F3MASK(0, IDB, 2, ILIVE)
      IF (ILIVE) 900, 60, 900
   60 WRITE (6, 100) IOK, IWORD
  100 FORMAT (2I4)
      STOP
  900 STOP 1
      END

C @brief Executes A1 SQL and evaluates FORTRAN III status/handle masks.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Character count in ISQL.
C @param IOK Receives combined boolean word sum (5 when OK and live).
      SUBROUTINE EXCMSK(IDB, ISQL, ILEN, IOK)
      DIMENSION ISQL(1)
      CALL F3EXEC(IDB, ISQL, ILEN, IW3)
      CALL F3MASK(0, IDB, 2, IW2)
      IOK = IW3 + IW2
      RETURN
      END
