C @file fortran_iii_1958_radar_track.f
C @brief 1958-59 IBM 704/709 FORTRAN III SAGE radar track gate example.
C
C Exercises the portable FORTRAN III boolean status-word interface
C (F3OPEN, F3EXEC, F3MASK, F3CLOS) across all three bitmask selectors
C (1 = status OK, 2 = handle live, 3 = combined status + handle mask)
C while logging range-azimuth radar intercepts.
      DIMENSION IURL(8), IDDL(23), ITR1(32), ITR2(32), IUPD(30)
      DATA IURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE TRK(B,R,A)" (23 chars)
      DATA IDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,84,82,75,40,
     1           66,44,82,44,65,41/
C "INSERT INTO TRK VALUES(1,180,45)" (32 chars)
      DATA ITR1 /73,78,83,69,82,84,32,73,78,84,79,32,84,82,75,32,86,
     1           65,76,85,69,83,40,49,44,49,56,48,44,52,53,41/
C "INSERT INTO TRK VALUES(2,240,90)" (32 chars)
      DATA ITR2 /73,78,83,69,82,84,32,73,78,84,79,32,84,82,75,32,86,
     1           65,76,85,69,83,40,50,44,50,52,48,44,57,48,41/
C "UPDATE TRK SET R=225 WHERE B=2" (30 chars)
      DATA IUPD /85,80,68,65,84,69,32,84,82,75,32,83,69,84,32,82,61,
     1           50,50,53,32,87,72,69,82,69,32,66,61,50/
      IDB = 0
      CALL F3OPEN(IURL, 8, IDB, IWORD)
      IF (IWORD - 3) 900, 10, 900
   10 IF (KMSK3(0, IDB) - 6) 900, 15, 900
   15 IF (KMSK3(9, IDB) - 4) 900, 20, 900
   20 CALL TRKEX(IDB, IDDL, 23, IW)
      IF (IW - 3) 900, 25, 900
   25 CALL TRKEX(IDB, ITR1, 32, IW)
      IF (IW - 3) 900, 30, 900
   30 CALL TRKEX(IDB, ITR2, 32, IW)
      IF (IW - 3) 900, 35, 900
   35 CALL TRKEX(IDB, IUPD, 30, IW)
      IF (IW - 3) 900, 40, 900
   40 CALL F3CLOS(IDB, IWORD)
      IF (IWORD - 1) 900, 45, 900
   45 IF (KMSK3(0, IDB) - 2) 900, 50, 900
   50 WRITE (6, 100) IW, IWORD
  100 FORMAT (2I4)
      STOP
  900 STOP 1
      END

C @brief Executes one radar SQL command and checks live handle bit 2.
C @param IDB Active 1-based database slot handle.
C @param ISQL Unpacked A1 ASCII SQL integer array.
C @param ILEN Character count in ISQL.
C @param IW Receives F3EXEC status word (3 when OK and handle live).
      SUBROUTINE TRKEX(IDB, ISQL, ILEN, IW)
      DIMENSION ISQL(1)
      CALL F3EXEC(IDB, ISQL, ILEN, IW)
      CALL F3MASK(0, IDB, 2, ILIVE)
      IF (ILIVE - 2) 10, 20, 10
   10 IW = 0
   20 RETURN
      END

C @brief Sums FORTRAN III boolean bitmasks 1, 2, and 3 via F3MASK.
C @param ISTAT Candidate error code to test against bit 0.
C @param IDB Candidate database handle to test against bit 1.
C @return Sum of masked words for IMASK = 1, 2, and 3.
      FUNCTION KMSK3(ISTAT, IDB)
      CALL F3MASK(ISTAT, IDB, 1, IB1)
      CALL F3MASK(ISTAT, IDB, 2, IB2)
      CALL F3MASK(ISTAT, IDB, 3, IB3)
      KMSK3 = IB1 + IB2 + IB3
      RETURN
      END
