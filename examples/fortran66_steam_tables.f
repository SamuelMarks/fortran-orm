C @file fortran66_steam_tables.f
C @brief ANSI X3.9-1966 FORTRAN 66 ASME saturated steam table example.
C
C Strictly adheres to ANSI X3.9-1966: fixed-form columns 1-72, <= 6-char
C uppercase identifiers, zero CHARACTER types, zero PARAMETER statements,
C and zero block IF/THEN/ENDIF constructs. Persists phase metadata and a
C 4x3 saturation curve matrix, then interpolates enthalpy at 150 C.
      INTEGER IURL(8), IDDL(23), IINS(29), ISEL(21)
      INTEGER IMDDL(23), IMINS(29), IMSEL(21)
      INTEGER IPH1(6), IPH2(5), IOUT(8)
      INTEGER IDB, IST, IERR, IHAS, IPKPA, ILEN, NOUT, K
      DOUBLE PRECISION DHG, STMIN(4, 3), STMOUT(4, 3), H150, DTERP6
      DATA IURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE PHS(P,H,N)" (23 chars)
      DATA IDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,80,72,83,40,
     1           80,44,72,44,78,41/
C "INSERT INTO PHS VALUES(?,?,?)" (29 chars)
      DATA IINS /73,78,83,69,82,84,32,73,78,84,79,32,80,72,83,32,86,
     1           65,76,85,69,83,40,63,44,63,44,63,41/
C "SELECT P,H,N FROM PHS" (21 chars)
      DATA ISEL /83,69,76,69,67,84,32,80,44,72,44,78,32,70,82,79,77,
     1           32,80,72,83/
C "CREATE TABLE STM(T,P,H)" (23 chars)
      DATA IMDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,83,84,77,40,
     1            84,44,80,44,72,41/
C "INSERT INTO STM VALUES(?,?,?)" (29 chars)
      DATA IMINS /73,78,83,69,82,84,32,73,78,84,79,32,83,84,77,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,41/
C "SELECT T,P,H FROM STM" (21 chars)
      DATA IMSEL /83,69,76,69,67,84,32,84,44,80,44,72,32,70,82,79,77,
     1            32,83,84,77/
C "LIQUID" and "VAPOR"
      DATA IPH1 /76, 73, 81, 85, 73, 68/
      DATA IPH2 /86, 65, 80, 79, 82/
      IDB = 0
      CALL C6OPEN(IURL, 8, IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXEC(IDB, IDDL, 23, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6TXBG(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6PREP(IDB, IINS, 29, IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINI(IST, 1, 101, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BIND(IST, 2, 419.06D0, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINA(IST, 3, IPH1, 6, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6FINL(IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6PREP(IDB, IINS, 29, IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINI(IST, 1, 101, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BIND(IST, 2, 2675.6D0, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINA(IST, 3, IPH2, 5, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6FINL(IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6TXCM(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6PREP(IDB, ISEL, 21, IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0 .OR. IHAS .NE. 1) STOP 1
      CALL C6COLI(IST, 1, IPKPA, IERR)
      IF (IERR .NE. 0 .OR. IPKPA .NE. 101) STOP 1
      CALL C6COLD(IST, 2, DHG, IERR)
      IF (IERR .NE. 0 .OR. DABS(DHG - 419.06D0) .GT. 1.0D-6) STOP 1
      CALL C6COLA(IST, 3, IOUT, 8, ILEN, IERR)
      IF (IERR .NE. 0 .OR. ILEN .NE. 6) STOP 1
      CALL C6FINL(IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXEC(IDB, IMDDL, 23, IERR)
      IF (IERR .NE. 0) STOP 1
      STMIN(1, 1) = 100.0D0
      STMIN(2, 1) = 120.0D0
      STMIN(3, 1) = 160.0D0
      STMIN(4, 1) = 200.0D0
      STMIN(1, 2) = 101.325D0
      STMIN(2, 2) = 198.67D0
      STMIN(3, 2) = 618.23D0
      STMIN(4, 2) = 1554.9D0
      STMIN(1, 3) = 2675.6D0
      STMIN(2, 3) = 2706.0D0
      STMIN(3, 3) = 2758.1D0
      STMIN(4, 3) = 2792.0D0
      DO 10 K = 1, 4
        STMOUT(K, 1) = 0.0D0
        STMOUT(K, 2) = 0.0D0
        STMOUT(K, 3) = 0.0D0
   10 CONTINUE
      CALL C6MATI(IDB, IMINS, 29, STMIN, 4, 4, 3, IERR)
      IF (IERR .NE. 0) STOP 1
      NOUT = 0
      CALL C6MATQ(IDB, IMSEL, 21, STMOUT, 4, 4, 3, NOUT, IERR)
      IF (IERR .NE. 0 .OR. NOUT .NE. 4) STOP 1
      H150 = DTERP6(STMOUT(2, 1), STMOUT(2, 3), STMOUT(3, 1),
     1              STMOUT(3, 3), 150.0D0)
      IF (DABS(H150 - 2745.075D0) .GT. 1.0D-6) STOP 1
      CALL C6CLOS(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      WRITE (6, 100) H150
  100 FORMAT (F10.3)
      STOP
      END

C @brief Linearly interpolates a thermodynamic property at XQ.
C @param X0 Lower state point abscissa.
C @param Y0 Lower state point property value.
C @param X1 Upper state point abscissa.
C @param Y1 Upper state point property value.
C @param XQ Query abscissa between X0 and X1.
C @return Interpolated property value Y(XQ).
      DOUBLE PRECISION FUNCTION DTERP6(X0, Y0, X1, Y1, XQ)
      DOUBLE PRECISION X0, Y0, X1, Y1, XQ
      DTERP6 = Y0 + (XQ - X0) * (Y1 - Y0) / (X1 - X0)
      RETURN
      END
