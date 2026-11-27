C @file fortran66_chemical_kinetics.f
C @brief ANSI X3.9-1966 FORTRAN 66 Arrhenius chemical kinetics example.
C
C Strictly adheres to ANSI X3.9-1966: fixed-form columns 1-72, <= 6-char
C uppercase identifiers, zero CHARACTER types, zero PARAMETER statements,
C zero SAVE/INCLUDE statements, and zero block IF/THEN/ENDIF constructs.
C Persists catalyst metadata (with rollback of a thermal runaway batch)
C and a 4x3 Arrhenius rate-constant curve matrix.
      INTEGER IURL(8), IDDL(23), IINS(29), ISEL(21), IDEL(15)
      INTEGER IMDDL(23), IMINS(29), IMSEL(21)
      INTEGER ICT1(4), ICT2(4), IOUT(8)
      INTEGER IDB, IST, IERR, IHAS, ICID, ILEN, NOUT, K
      DOUBLE PRECISION DEA, KININ(4, 3), KINOUT(4, 3)
      DOUBLE PRECISION DA0, DTK, DK, ARRH66
      DATA IURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE CAT(I,E,N)" (23 chars)
      DATA IDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,67,65,84,40,
     1           73,44,69,44,78,41/
C "INSERT INTO CAT VALUES(?,?,?)" (29 chars)
      DATA IINS /73,78,83,69,82,84,32,73,78,84,79,32,67,65,84,32,86,
     1           65,76,85,69,83,40,63,44,63,44,63,41/
C "SELECT I,E,N FROM CAT" (21 chars)
      DATA ISEL /83,69,76,69,67,84,32,73,44,69,44,78,32,70,82,79,77,
     1           32,67,65,84/
C "DELETE FROM CAT" (15 chars)
      DATA IDEL /68,69,76,69,84,69,32,70,82,79,77,32,67,65,84/
C "CREATE TABLE KIN(T,K,C)" (23 chars)
      DATA IMDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,75,73,78,40,
     1            84,44,75,44,67,41/
C "INSERT INTO KIN VALUES(?,?,?)" (29 chars)
      DATA IMINS /73,78,83,69,82,84,32,73,78,84,79,32,75,73,78,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,41/
C "SELECT T,K,C FROM KIN" (21 chars)
      DATA IMSEL /83,69,76,69,67,84,32,84,44,75,44,67,32,70,82,79,77,
     1            32,75,73,78/
C "PTAL" and "ZSM5" catalyst codes
      DATA ICT1 /80, 84, 65, 76/
      DATA ICT2 /90, 83, 77, 53/
      IDB = 0
      CALL C6OPEN(IURL, 8, IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXEC(IDB, IDDL, 23, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6TXBG(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6PREP(IDB, IINS, 29, IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINI(IST, 1, 10, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BIND(IST, 2, 48500.0D0, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINA(IST, 3, ICT1, 4, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6FINL(IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6PREP(IDB, IINS, 29, IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINI(IST, 1, 20, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BIND(IST, 2, 62000.0D0, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6BINA(IST, 3, ICT2, 4, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6FINL(IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6TXCM(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
C Roll back an aborted catalyst purge
      CALL C6TXBG(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXEC(IDB, IDEL, 15, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6TXRB(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6PREP(IDB, ISEL, 21, IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6STEP(IST, IHAS, IERR)
      IF (IERR .NE. 0 .OR. IHAS .NE. 1) STOP 1
      CALL C6COLI(IST, 1, ICID, IERR)
      IF (IERR .NE. 0 .OR. ICID .NE. 10) STOP 1
      CALL C6COLD(IST, 2, DEA, IERR)
      IF (IERR .NE. 0 .OR. DABS(DEA - 48500.0D0) .GT. 1.0D-6) STOP 1
      CALL C6COLA(IST, 3, IOUT, 8, ILEN, IERR)
      IF (IERR .NE. 0 .OR. ILEN .NE. 4) STOP 1
      CALL C6FINL(IST, IERR)
      IF (IERR .NE. 0) STOP 1
      CALL C6EXEC(IDB, IMDDL, 23, IERR)
      IF (IERR .NE. 0) STOP 1
      DA0 = 1.25D7
      DO 10 K = 1, 4
        DTK = 350.0D0 + DBLE(K - 1) * 25.0D0
        DK = ARRH66(DA0, DEA, DTK)
        KININ(K, 1) = DTK
        KININ(K, 2) = DK
        KININ(K, 3) = DEXP(-DK * 120.0D0)
        KINOUT(K, 1) = 0.0D0
        KINOUT(K, 2) = 0.0D0
        KINOUT(K, 3) = 0.0D0
   10 CONTINUE
      CALL C6MATI(IDB, IMINS, 29, KININ, 4, 4, 3, IERR)
      IF (IERR .NE. 0) STOP 1
      NOUT = 0
      CALL C6MATQ(IDB, IMSEL, 21, KINOUT, 4, 4, 3, NOUT, IERR)
      IF (IERR .NE. 0 .OR. NOUT .NE. 4) STOP 1
      IF (KINOUT(4, 2) .LE. KINOUT(1, 2)) STOP 1
      IF (DABS(KINOUT(4, 2) - KININ(4, 2)) .GT. 1.0D-12) STOP 1
      CALL C6CLOS(IDB, IERR)
      IF (IERR .NE. 0) STOP 1
      WRITE (6, 100) KINOUT(4, 1), KINOUT(4, 2)
  100 FORMAT (F8.1, E14.6)
      STOP
      END

C @brief Evaluates first-order Arrhenius rate constant A * exp(-Ea/RT).
C @param DA Pre-exponential frequency factor (1/s).
C @param DEA Molar activation energy (J/mol).
C @param DTK Absolute temperature (K).
C @return First-order rate constant k(T) in 1/s.
      DOUBLE PRECISION FUNCTION ARRH66(DA, DEA, DTK)
      DOUBLE PRECISION DA, DEA, DTK, DRGAS
      DRGAS = 8.314462618D0
      ARRH66 = DA * DEXP(-DEA / (DRGAS * DTK))
      RETURN
      END
