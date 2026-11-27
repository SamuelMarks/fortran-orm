C @file era_04_fortran_iv.f
C @brief End-to-end 1962 IBM FORTRAN IV ORM, LOGICAL marshaling, scalar
C aggregate, 1D vector, and 2D matrix Frobenius norm/scaling test suite.
      EXTERNAL CORMBD
      INTEGER IHURL(8), IHDDL(20), IHINS(26), IHSEL(18)
      INTEGER IAURL(8), IADDL(22), IAINS(30), IASEL(22)
      INTEGER IVDDL(18), IVINS(24), IVSEL(16), IBAD(7)
      INTEGER ISUMQ(19), ITAG(4), IOUT(8)
      INTEGER IDB, IDBA, IST, NOUT, ILEN, IV
      DOUBLE PRECISION DMAT(4, 2), DOUT(4, 2), DERR, DNRM, DSUM
      DOUBLE PRECISION DVEC(3), DQRY(3), DV, DF4NRM, DF4SUM
      LOGICAL LOK, LROW, LFLG, LF4LIV
      DATA IHURL /58, 109, 101, 109, 111, 114, 121, 58/
      DATA IHDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,77,52,40,
     1            65,44,66,41/
      DATA IHINS /73,78,83,69,82,84,32,73,78,84,79,32,77,52,32,86,
     1            65,76,85,69,83,40,63,44,63,41/
      DATA IHSEL /83,69,76,69,67,84,32,65,44,66,32,70,82,79,77,32,
     1            77,52/
      DATA IAURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE R4(I,D,L,S)" -> "CREATE TABLE R4(I,D,L,S)" (24)?
C Use "CREATE TABLE R(I,D,L,S)" (23) -> IADDL(23)! Wait: use 22:
C "CREATE TABLE R(I,D,L)" + S -> "CREATE TABLE R4(I,D,L)" (22) & S!
C Let's size IADDL: "CREATE TABLE R(K,D,L,S)" is 23 chars -> use R(I,D,L)
      DATA IADDL /67,82,69,65,84,69,32,84,65,66,76,69,32,82,40,73,
     1            44,68,44,76,44,83/
      DATA IAINS /73,78,83,69,82,84,32,73,78,84,79,32,82,32,86,65,
     1            76,85,69,83,40,63,44,63,44,63,44,63,41,32/
      DATA IASEL /83,69,76,69,67,84,32,73,44,68,44,76,44,83,32,70,
     1            82,79,77,32,82,32/
      DATA IVDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,86,52,40,
     1            88,41/
      DATA IVINS /73,78,83,69,82,84,32,73,78,84,79,32,86,52,32,86,
     1            65,76,85,69,83,40,63,41/
      DATA IVSEL /83,69,76,69,67,84,32,88,32,70,82,79,77,32,86,52/
      DATA ISUMQ /83,69,76,69,67,84,32,83,85,77,40,88,41,32,70,82,
     1            79,77,32/
      DATA IBAD /66, 65, 68, 32, 83, 81, 76/
      DATA ITAG /70, 73, 86, 52/
C 1. Packed A4 Hollerith + 2D matrix + F4MSCL + DF4NRM + LF4LIV
      IF (LF4LIV(0)) STOP 1
      IDB = 0
      CALL F4OPEN(IHURL, 8, IDB, LOK)
      IF (.NOT. LOK .OR. .NOT. LF4LIV(IDB)) STOP 1
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
      IF (DF4NRM(DMAT, 4, 0, 2) .GT. 1.0D-12) STOP 1
      DNRM = DF4NRM(DMAT, 4, 3, 2)
      IF (DNRM .LT. 37.0D0) STOP 1
      CALL F4MSCL(IDB, IHINS, 26, DMAT, 4, 0, 2, 2.0D0, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4MSCL(IDB, IHINS, 26, DMAT, 4, 3, 2, 2.0D0, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXCM(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXRB(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4MATQ(IDB, IHSEL, 18, DOUT, 4, 4, 2, NOUT, LOK)
      IF (.NOT. LOK .OR. NOUT .NE. 3) STOP 1
      DERR = DABS(DOUT(3, 2) - 60.0D0) + DABS(DOUT(2, 1) - 5.0D0)
      IF (DERR .GT. 1.0D-9) STOP 1
      CALL F4CLOS(IDB, LOK)
      IF (.NOT. LOK) STOP 1
C 2. Unpacked A1 prepared statements, LOGICAL bind/col, vectors & DF4SUM
      IDBA = 0
      CALL F4OA1(IAURL, 8, IDBA, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4EXA1(IDBA, IVDDL, 18, LOK)
      IF (.NOT. LOK) STOP 1
      DVEC(1) = 2.0D0
      DVEC(2) = 4.0D0
      DVEC(3) = 6.0D0
      CALL F4VECD(IDBA, IVINS, 24, DVEC, 0, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4VECD(0, IVINS, 24, DVEC, 3, LOK)
      IF (LOK) STOP 1
      CALL F4VECD(IDBA, IBAD, 7, DVEC, 3, LOK)
      IF (LOK) STOP 1
      CALL F4VECD(IDBA, IVINS, 24, DVEC, 3, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4QRYD(0, IVSEL, 16, DQRY, 3, NOUT, LOK)
      IF (LOK) STOP 1
      CALL F4QRYD(IDBA, IVSEL, 16, DQRY, 2, NOUT, LOK)
      IF (LOK) STOP 1
      CALL F4QRYD(IDBA, IVSEL, 16, DQRY, 3, NOUT, LOK)
      IF (.NOT. LOK .OR. NOUT .NE. 3) STOP 1
      IF (DABS(DQRY(3) - 6.0D0) .GT. 1.0D-9) STOP 1
      DSUM = DF4SUM(0, IVSEL, 16, LOK)
      IF (LOK .OR. DABS(DSUM) .GT. 1.0D-12) STOP 1
      DSUM = DF4SUM(IDBA, IVSEL, 16, LOK)
      IF (.NOT. LOK .OR. DABS(DSUM - 2.0D0) .GT. 1.0D-9) STOP 1
C Create table "CREATE TABLE R(I,D,L,S)" using 23-char buffer via IAINS
      IAINS(1) = 67
      IAINS(2) = 82
      IAINS(3) = 69
      IAINS(4) = 65
      IAINS(5) = 84
      IAINS(6) = 69
      IAINS(7) = 32
      IAINS(8) = 84
      IAINS(9) = 65
      IAINS(10) = 66
      IAINS(11) = 76
      IAINS(12) = 69
      IAINS(13) = 32
      IAINS(14) = 82
      IAINS(15) = 40
      IAINS(16) = 73
      IAINS(17) = 44
      IAINS(18) = 68
      IAINS(19) = 44
      IAINS(20) = 76
      IAINS(21) = 44
      IAINS(22) = 83
      IAINS(23) = 41
      CALL F4EXA1(IDBA, IAINS, 23, LOK)
      IF (.NOT. LOK) STOP 1
C Restore "INSERT INTO R VALUES(?,?,?,?)" (29 chars)
      IAINS(1) = 73
      IAINS(2) = 78
      IAINS(3) = 83
      IAINS(4) = 69
      IAINS(5) = 82
      IAINS(6) = 84
      IAINS(7) = 32
      IAINS(8) = 73
      IAINS(9) = 78
      IAINS(10) = 84
      IAINS(11) = 79
      IAINS(12) = 32
      IAINS(13) = 82
      IAINS(14) = 32
      IAINS(15) = 86
      IAINS(16) = 65
      IAINS(17) = 76
      IAINS(18) = 85
      IAINS(19) = 69
      IAINS(20) = 83
      IAINS(21) = 40
      IAINS(22) = 63
      IAINS(23) = 44
      CALL F4PREP(IDBA, IAINS, 29, IST, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BINI(IST, 1, 1962, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BIND(IST, 2, 9.81D0, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BINL(IST, 3, .FALSE., LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BINL(IST, 3, .TRUE., LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BINA(IST, 4, ITAG, 4, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4STEP(IST, LROW, LOK)
      IF (.NOT. LOK .OR. LROW) STOP 1
      CALL F4FINL(IST, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4PREP(IDBA, IASEL, 21, IST, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4STEP(IST, LROW, LOK)
      IF (.NOT. LOK .OR. .NOT. LROW) STOP 1
      CALL F4COLI(IST, 1, IV, LOK)
      IF (.NOT. LOK .OR. IV .NE. 1962) STOP 1
      CALL F4COLD(IST, 2, DV, LOK)
      IF (.NOT. LOK .OR. DABS(DV - 9.81D0) .GT. 1.0D-9) STOP 1
      CALL F4COLL(IST, 3, LFLG, LOK)
      IF (.NOT. LOK .OR. .NOT. LFLG) STOP 1
      CALL F4COLA(IST, 4, IOUT, 8, ILEN, LOK)
      IF (.NOT. LOK .OR. ILEN .NE. 4 .OR. IOUT(1) .NE. 70) STOP 1
      CALL F4FINL(IST, LOK)
      IF (.NOT. LOK) STOP 1
      IASEL(8) = 83
      CALL F4QRYD(IDBA, IASEL, 21, DQRY, 3, NOUT, LOK)
      IF (LOK) STOP 1
      CALL F4CLOS(IDBA, LOK)
      IF (.NOT. LOK .OR. IADDL(1) * ISUMQ(1) .LE. 0) STOP 1
      WRITE (6, 100) NOUT
  100 FORMAT (I6)
      STOP
      END
