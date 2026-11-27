C @file fortran_iv_1962_apollo_guidance_burn.f
C @brief 1962 IBM FORTRAN IV translunar midcourse Tsiolkovsky delta-v
C burn planner and RCS propellant ullage LOGICAL interlock ledger.
C
C Showcases extended FORTRAN IV ORM abstractions from corm4x.f:
C F4OA1, F4EXA1, F4PREP, F4BINI, F4BIND, F4BINL, F4BINA, F4STEP, F4COLI,
C F4COLD, F4COLL, F4COLA, F4FINL, F4VECD, F4QRYD, DF4SUM, and LF4LIV.

C @brief Evaluates Tsiolkovsky propellant burn DMKG and LOGICAL ullage
C go/no-go gate LGO for a Service Propulsion System maneuver.
C @param M0KG Initial spacecraft wet mass in kg.
C @param DVMS Desired velocity increment delta-v in m/s.
C @param ISPS Specific impulse Isp in seconds.
C @param ULLG Settling acceleration in m/s^2 from RCS ullage thrusters.
C @param DMKG Receives required propellant mass in kg.
C @param LGO Receives .TRUE. when ullage settled & propellant <= budget.
      SUBROUTINE BURN62(M0KG, DVMS, ISPS, ULLG, DMKG, LGO)
      DOUBLE PRECISION M0KG, DVMS, ISPS, ULLG, DMKG
      LOGICAL LGO
      DOUBLE PRECISION G0, VE, MRAT
      G0 = 9.80665D0
      VE = ISPS * G0
      MRAT = DEXP(-DVMS / VE)
      DMKG = M0KG * (1.0D0 - MRAT)
      LGO = (ULLG .GE. 0.05D0 .AND. DMKG .LE. 450.0D0)
      RETURN
      END

C @brief Main 1962 FORTRAN IV translunar midcourse guidance program.
      EXTERNAL CORMBD
      INTEGER IAURL(8), IADDL(23), IAINS(29), IASEL(21)
      INTEGER IVDDL(18), IVINS(24), IVSEL(16), ISUMQ(19)
      INTEGER ITAG(4), IOUT(8), IDB, IST, K, NOUT, ILEN, JID, NGO
      DOUBLE PRECISION DVSET(5), DVQRY(5), ULLG(5), M0KG, ISPS
      DOUBLE PRECISION DMKG, DMSUM, DVSUM, DERR, DF4SUM
      LOGICAL LOK, LROW, LGO, LGORD, LF4LIV
      DATA IAURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE BN(K,P,G,T)" -> 24? Use "CREATE TABLE B(K,P,G,T)" (23)
      DATA IADDL /67,82,69,65,84,69,32,84,65,66,76,69,32,66,40,75,
     1            44,80,44,71,44,84,41/
C "INSERT INTO B VALUES(?,?,?,?)" (29 chars)
      DATA IAINS /73,78,83,69,82,84,32,73,78,84,79,32,66,32,86,65,
     1            76,85,69,83,40,63,44,63,44,63,44,63,41/
C "SELECT K,P,G,T FROM B" (21 chars)
      DATA IASEL /83,69,76,69,67,84,32,75,44,80,44,71,44,84,32,70,
     1            82,79,77,32,66/
C "CREATE TABLE DV(X)" (18), "INSERT INTO DV VALUES(?)" (24)
      DATA IVDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,68,86,40,
     1            88,41/
      DATA IVINS /73,78,83,69,82,84,32,73,78,84,79,32,68,86,32,86,
     1            65,76,85,69,83,40,63,41/
      DATA IVSEL /83,69,76,69,67,84,32,88,32,70,82,79,77,32,68,86/
C "SELECT SUM(P) FROM B" -> 20? "SELECT SUM(X) FROM DV" (21)?
C Use "SELECT SUM(P) FROM B" -> 20 chars -> ISUMQ(20)! Wait: ISUMQ(19):
C "SELECT SUM(X) FROM " -> let's size ISUMQ: "SELECT SUM(P) FROM B" = 20
      DATA ISUMQ /83,69,76,69,67,84,32,83,85,77,40,80,41,32,70,82,
     1            79,77,32/
      DATA DVSET /12.5D0, 28.0D0, 4.2D0, 62.0D0, 18.4D0/
      DATA ULLG /0.08D0, 0.09D0, 0.01D0, 0.11D0, 0.07D0/
      DATA ITAG /77, 67, 67, 49/
      IDB = 0
      CALL F4OA1(IAURL, 8, IDB, LOK)
      IF (.NOT. LOK .OR. .NOT. LF4LIV(IDB)) STOP 1
      CALL F4EXA1(IDB, IVDDL, 18, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4EXA1(IDB, IADDL, 23, LOK)
      IF (.NOT. LOK) STOP 1
C Batch-persist planned midcourse delta-v vector via F4VECD & F4QRYD
      CALL F4VECD(IDB, IVINS, 24, DVSET, 5, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4QRYD(IDB, IVSEL, 16, DVQRY, 5, NOUT, LOK)
      IF (.NOT. LOK .OR. NOUT .NE. 5) STOP 1
C Compute Tsiolkovsky propellant & LOGICAL ullage gates for 5 burns
      M0KG = 28500.0D0
      ISPS = 314.0D0
      DMSUM = 0.0D0
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      DO 30 K = 1, 5
      ITAG(4) = 48 + K
      CALL BURN62(M0KG, DVQRY(K), ISPS, ULLG(K), DMKG, LGO)
      DMSUM = DMSUM + DMKG
      IF (LGO) M0KG = M0KG - DMKG
      CALL F4PREP(IDB, IAINS, 29, IST, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BINI(IST, 1, K, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BIND(IST, 2, DMKG, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BINL(IST, 3, LGO, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4BINA(IST, 4, ITAG, 4, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4STEP(IST, LROW, LOK)
      IF (.NOT. LOK .OR. LROW) STOP 1
      CALL F4FINL(IST, LOK)
      IF (.NOT. LOK) STOP 1
   30 CONTINUE
      CALL F4TXCM(IDB, LOK)
      IF (.NOT. LOK) STOP 1
C Audit persisted maneuvers using F4COLI, F4COLD, F4COLL, F4COLA
      CALL F4PREP(IDB, IASEL, 21, IST, LOK)
      IF (.NOT. LOK) STOP 1
      NGO = 0
      DVSUM = 0.0D0
   40 CALL F4STEP(IST, LROW, LOK)
      IF (.NOT. LOK) STOP 1
      IF (.NOT. LROW) GO TO 60
      CALL F4COLI(IST, 1, JID, LOK)
      IF (.NOT. LOK .OR. JID .LT. 1) STOP 1
      CALL F4COLD(IST, 2, DMKG, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4COLL(IST, 3, LGORD, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4COLA(IST, 4, IOUT, 8, ILEN, LOK)
      IF (.NOT. LOK .OR. ILEN .NE. 4 .OR. IOUT(1) .NE. 77) STOP 1
      DVSUM = DVSUM + DMKG
      IF (LGORD) NGO = NGO + 1
      GO TO 40
   60 CALL F4FINL(IST, LOK)
      IF (.NOT. LOK) STOP 1
C Verify DF4SUM on "SELECT SUM(P) FROM B" (20 chars stored in IASEL)
      DO 65 K = 1, 19
      IASEL(K) = ISUMQ(K)
   65 CONTINUE
      IASEL(20) = 66
      DERR = DABS(DF4SUM(IDB, IASEL, 20, LOK) - DMSUM)
      IF (.NOT. LOK .OR. DERR .GT. 1.0D-7) STOP 1
C Burn 3 had ullage 0.01 < 0.05 (NO-GO) and Burn 4 had DMKG > 450 (NO-GO)
C -> exactly 3 GO burns (Burns 1, 2, 5)!
      IF (NGO .NE. 3 .OR. DABS(DVSUM - DMSUM) .GT. 1.0D-7) STOP 1
      CALL F4CLOS(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      WRITE (6, 100) NGO, DMSUM, M0KG
  100 FORMAT (I6, 2F12.3)
      STOP
      END
