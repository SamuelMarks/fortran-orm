C @file fortran_iv_1962_ac_power_loadflow.f
C @brief 1962 IBM 7094 5-bus AC transmission admittance & linearized DC
C power-flow contingency scaling audit using FORTRAN IV ORM extensions.
C
C Exercises EXTERNAL CORMBD, F4OPEN, F4EXEC, F4TXBG, F4TXCM, F4MSCL,
C F4MATQ, DF4NRM, DF4SUM, and LF4LIV in strict 1962 FORTRAN IV.

C @brief Solves 4x4 active-bus phase angles THETA(2..5) (bus 1 slack)
C via 25-sweep Gauss-Seidel relaxation on susceptance matrix BMAT.
C @param BMAT 5x5 nodal susceptance matrix (per-unit).
C @param PINJ Net active power injection per bus (per-unit, 100 MVA).
C @param THETA Receives bus voltage phase angles in radians.
      SUBROUTINE DCLF4(BMAT, PINJ, THETA)
      DOUBLE PRECISION BMAT(5, 5), PINJ(5), THETA(5)
      DOUBLE PRECISION RHS
      INTEGER ITER, I, J
      DO 10 I = 1, 5
      THETA(I) = 0.0D0
   10 CONTINUE
      DO 40 ITER = 1, 30
      DO 30 I = 2, 5
      RHS = PINJ(I)
      DO 20 J = 1, 5
      IF (J .NE. I) RHS = RHS - BMAT(I, J) * THETA(J)
   20 CONTINUE
      THETA(I) = RHS / BMAT(I, I)
   30 CONTINUE
   40 CONTINUE
      RETURN
      END

C @brief Populates 6 transmission-line branch flows into BRMAT(6, 3):
C col 1 = from_bus, col 2 = to_bus, col 3 = per-unit active flow P_ij.
C @param XLINE Reactance x_ij of each of the 6 transmission lines.
C @param IFROM Sending-end bus index (1..5).
C @param ITO Receiving-end bus index (1..5).
C @param THETA Solved bus angles in radians.
C @param BRMAT Destination (8, 3) padded column-major matrix.
      SUBROUTINE FLW62(XLINE, IFROM, ITO, THETA, BRMAT)
      DOUBLE PRECISION XLINE(6), THETA(5), BRMAT(8, 3)
      INTEGER IFROM(6), ITO(6), K
      DO 20 K = 1, 6
      BRMAT(K, 1) = DBLE(IFROM(K))
      BRMAT(K, 2) = DBLE(ITO(K))
      BRMAT(K, 3) = (THETA(IFROM(K)) - THETA(ITO(K))) / XLINE(K)
   20 CONTINUE
      BRMAT(7, 1) = 0.0D0
      BRMAT(8, 1) = 0.0D0
      BRMAT(7, 2) = 0.0D0
      BRMAT(8, 2) = 0.0D0
      BRMAT(7, 3) = 0.0D0
      BRMAT(8, 3) = 0.0D0
      RETURN
      END

C @brief Main 1962 FORTRAN IV AC grid load-flow scaling program.
      EXTERNAL CORMBD
      INTEGER IHURL(8), IHDDL(22), IHINS(28), IHSEL(20), ISUMQ(22)
      INTEGER IFROM(6), ITO(6), IDB, NOUT, I, J, K
      DOUBLE PRECISION BMAT(5, 5), PINJ(5), THETA(5), XLINE(6)
      DOUBLE PRECISION BRMAT(8, 3), QMAT(8, 3), NRM1, NRM2, PMAX
      DOUBLE PRECISION DF4NRM, DF4SUM
      LOGICAL LOK, LF4LIV
      DATA IHURL /58, 109, 101, 109, 111, 114, 121, 58/
      DATA IHDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,76,70,40,
     1            70,44,84,44,80,41/
      DATA IHINS /73,78,83,69,82,84,32,73,78,84,79,32,76,70,32,86,
     1            65,76,85,69,83,40,63,44,63,44,63,41/
      DATA IHSEL /83,69,76,69,67,84,32,70,44,84,44,80,32,70,82,79,
     1            77,32,76,70/
C "SELECT MAX(ABS(P))..." -> "SELECT MAX(P) FROM LF " (21 chars)
      DATA ISUMQ /83,69,76,69,67,84,32,77,65,88,40,80,41,32,70,82,
     1            79,77,32,76,70,32/
      DATA IFROM /1, 1, 2, 2, 3, 4/
      DATA ITO   /2, 3, 3, 4, 5, 5/
      DATA XLINE /0.08D0, 0.12D0, 0.10D0, 0.15D0, 0.10D0, 0.06D0/
      DATA PINJ  /0.0D0, 1.40D0, -0.85D0, -0.95D0, -1.10D0/
C Assemble 5x5 nodal susceptance matrix B from branch reactances
      DO 15 J = 1, 5
      DO 12 I = 1, 5
      BMAT(I, J) = 0.0D0
   12 CONTINUE
   15 CONTINUE
      DO 25 K = 1, 6
      I = IFROM(K)
      J = ITO(K)
      BMAT(I, I) = BMAT(I, I) + 1.0D0 / XLINE(K)
      BMAT(J, J) = BMAT(J, J) + 1.0D0 / XLINE(K)
      BMAT(I, J) = BMAT(I, J) - 1.0D0 / XLINE(K)
      BMAT(J, I) = BMAT(J, I) - 1.0D0 / XLINE(K)
   25 CONTINUE
      CALL DCLF4(BMAT, PINJ, THETA)
      CALL FLW62(XLINE, IFROM, ITO, THETA, BRMAT)
      NRM1 = DF4NRM(BRMAT, 8, 6, 3)
      IF (NRM1 .LE. 1.0D0) STOP 1
C Open DB, scale per-unit matrix to 100 MVA base via F4MSCL, & query
      IDB = 0
      CALL F4OPEN(IHURL, 8, IDB, LOK)
      IF (.NOT. LOK .OR. .NOT. LF4LIV(IDB)) STOP 1
      CALL F4EXEC(IDB, IHDDL, 22, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXBG(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4MSCL(IDB, IHINS, 28, BRMAT, 8, 6, 3, 100.0D0, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4TXCM(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      CALL F4MATQ(IDB, IHSEL, 20, QMAT, 8, 8, 3, NOUT, LOK)
      IF (.NOT. LOK .OR. NOUT .NE. 6) STOP 1
      NRM2 = DF4NRM(QMAT, 8, 6, 3)
      IF (DABS(NRM2 - 100.0D0 * NRM1) .GT. 1.0D-7) STOP 1
      PMAX = DF4SUM(IDB, ISUMQ, 21, LOK)
      IF (.NOT. LOK .OR. PMAX .LE. 50.0D0) STOP 1
      CALL F4CLOS(IDB, LOK)
      IF (.NOT. LOK) STOP 1
      WRITE (6, 100) NOUT, PMAX, NRM2
  100 FORMAT (I6, 2F12.3)
      STOP
      END
