C @file era_04_fortran_iv.f
C @brief End-to-end 1962 IBM FORTRAN IV ORM & 2D matrix test suite.
C
C Uses FORTRAN IV LOGICAL IF, DOUBLE PRECISION 2D matrices, BLOCK DATA
C CORMBD, and DATA-initialized integer character arrays.
      EXTERNAL CORMBD
      INTEGER IHURL(8), IHDDL(20), IHINS(26), IHSEL(18)
      INTEGER IDB, NOUT
      DOUBLE PRECISION DMAT(4, 2), DOUT(4, 2), DERR
      LOGICAL LOK
      DATA IHURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE M4(A,B)" (20 chars)
      DATA IHDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,77,52,40,
     1            65,44,66,41/
C "INSERT INTO M4 VALUES(?,?)" (26 chars)
      DATA IHINS /73,78,83,69,82,84,32,73,78,84,79,32,77,52,32,86,
     1            65,76,85,69,83,40,63,44,63,41/
C "SELECT A,B FROM M4" (18 chars)
      DATA IHSEL /83,69,76,69,67,84,32,65,44,66,32,70,82,79,77,32,
     1            77,52/
      IDB = 0
      CALL F4OPEN(IHURL, 8, IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4EXEC(IDB, IHDDL, 20, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      DMAT(1, 1) = 1.5D0
      DMAT(2, 1) = 2.5D0
      DMAT(3, 1) = 3.5D0
      DMAT(4, 1) = 0.0D0
      DMAT(1, 2) = 10.0D0
      DMAT(2, 2) = 20.0D0
      DMAT(3, 2) = 30.0D0
      DMAT(4, 2) = 0.0D0
      CALL F4MATI(IDB, IHINS, 26, DMAT, 4, 3, 2, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXCM(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXRB(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      DOUT(1, 1) = 0.0D0
      DOUT(3, 2) = 0.0D0
      CALL F4MATQ(IDB, IHSEL, 18, DOUT, 4, 4, 2, NOUT, LOK)
      IF (.NOT. LOK) STOP 1
      IF (NOUT .NE. 3) STOP 1
      DERR = DABS(DOUT(3, 2) - 30.0D0) + DABS(DOUT(2, 1) - 2.5D0)
      IF (DERR .GT. 1.0D-9) STOP 1
      CALL F4CLOS(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      WRITE (6, 100) NOUT
  100 FORMAT (I6)
      STOP
      END
