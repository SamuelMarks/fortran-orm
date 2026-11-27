C @file fortran_ii_1958_naca_airfoil_polar.f
C @brief 1958 IBM FORTRAN II NACA 2412 wind-tunnel lift/drag polar,
C Prandtl induced-drag decomposition, and L/D glide-ratio catalog.
C
C Showcases extended FORTRAN II ORM abstractions from corm2x.f:
C F2OPA4, F2EXA4, F2VECD, F2QRYD, F2MATI, F2MATQ, F2SCLD, F2SCAL,
C /CORMCM/, and IF2OK using strict 1958 syntax (SUBROUTINE, FUNCTION,
C COMMON, arithmetic IF, zero LOGICAL/DATA/CHARACTER/PARAMETER).

C @brief Computes NACA 2412 lift CL and parabolic drag CD at angle ALFA.
C @param ALFA Angle of attack in degrees.
C @param AR Wing aspect ratio.
C @param EOSW Oswald span efficiency factor.
C @param CD0 Zero-lift parasite drag coefficient.
C @param CLOUT Receives section lift coefficient CL.
C @param CDOUT Receives total wing drag coefficient CD.
      SUBROUTINE PLR58(ALFA, AR, EOSW, CD0, CLOUT, CDOUT)
      DOUBLE PRECISION ALFA, AR, EOSW, CD0, CLOUT, CDOUT
      DOUBLE PRECISION PI, AL0, D2R, KFAC
      PI = 3.141592653589793D0
      AL0 = -2.0D0
      D2R = PI / 180.0D0
      CLOUT = 2.0D0 * PI * (AR / (AR + 2.0D0)) * (ALFA - AL0) * D2R
      KFAC = 1.0D0 / (PI * AR * EOSW)
      CDOUT = CD0 + KFAC * CLOUT * CLOUT
      RETURN
      END

C @brief Populates unpacked A1 SQL buffers for airfoil polar persistence.
C @param IMINS Receives "INSERT INTO PL VALUES(?,?,?)" (28 chars).
C @param IMSEL Receives "SELECT A,L,D FROM PL" (20 chars).
C @param IMMAX Receives "SELECT MAX(L/D) FROM PL" (23 chars).
      SUBROUTINE SQL58P(IMINS, IMSEL, IMMAX)
      DIMENSION IMINS(28), IMSEL(20), IMMAX(23)
C "INSERT INTO PL VALUES(?,?,?)"
      IMINS(1) = 73
      IMINS(2) = 78
      IMINS(3) = 83
      IMINS(4) = 69
      IMINS(5) = 82
      IMINS(6) = 84
      IMINS(7) = 32
      IMINS(8) = 73
      IMINS(9) = 78
      IMINS(10) = 84
      IMINS(11) = 79
      IMINS(12) = 32
      IMINS(13) = 80
      IMINS(14) = 76
      IMINS(15) = 32
      IMINS(16) = 86
      IMINS(17) = 65
      IMINS(18) = 76
      IMINS(19) = 85
      IMINS(20) = 69
      IMINS(21) = 83
      IMINS(22) = 40
      IMINS(23) = 63
      IMINS(24) = 44
      IMINS(25) = 63
      IMINS(26) = 44
      IMINS(27) = 63
      IMINS(28) = 41
C "SELECT A,L,D FROM PL"
      IMSEL(1) = 83
      IMSEL(2) = 69
      IMSEL(3) = 76
      IMSEL(4) = 69
      IMSEL(5) = 67
      IMSEL(6) = 84
      IMSEL(7) = 32
      IMSEL(8) = 65
      IMSEL(9) = 44
      IMSEL(10) = 76
      IMSEL(11) = 44
      IMSEL(12) = 68
      IMSEL(13) = 32
      IMSEL(14) = 70
      IMSEL(15) = 82
      IMSEL(16) = 79
      IMSEL(17) = 77
      IMSEL(18) = 32
      IMSEL(19) = 80
      IMSEL(20) = 76
C "SELECT MAX(L/D) FROM PL"
      IMMAX(1) = 83
      IMMAX(2) = 69
      IMMAX(3) = 76
      IMMAX(4) = 69
      IMMAX(5) = 67
      IMMAX(6) = 84
      IMMAX(7) = 32
      IMMAX(8) = 77
      IMMAX(9) = 65
      IMMAX(10) = 88
      IMMAX(11) = 40
      IMMAX(12) = 76
      IMMAX(13) = 47
      IMMAX(14) = 68
      IMMAX(15) = 41
      IMMAX(16) = 32
      IMMAX(17) = 70
      IMMAX(18) = 82
      IMMAX(19) = 79
      IMMAX(20) = 77
      IMMAX(21) = 32
      IMMAX(22) = 80
      IMMAX(23) = 76
      RETURN
      END

C @brief Main 1958 FORTRAN II NACA 2412 wind-tunnel polar program.
      COMMON /CORMCM/ LASTEC, LASTDB, LASTST
      DOUBLE PRECISION ALVEC(7), AQRY(7), PMAT(8, 3), POUT(8, 3)
      DOUBLE PRECISION AR, EOSW, CD0, CL, CD, LDMAX, BESTLD, DERR
      DIMENSION IHURL(2), IHDDL(6), IHVDDL(5), IVINS(24), IVSEL(16)
      DIMENSION IAURL(8), IADDL(22), IAVDDL(18)
      DIMENSION IMINS(28), IMSEL(20), IMMAX(23), ICNTQ(23)
      IAURL(1) = 58
      IAURL(2) = 109
      IAURL(3) = 101
      IAURL(4) = 109
      IAURL(5) = 111
      IAURL(6) = 114
      IAURL(7) = 121
      IAURL(8) = 58
      CALL F2PKA4(IAURL, 8, IHURL, 2)
      CALL F2OPA4(IHURL, 8, IDB, IERR)
      IF (IERR) 900, 10, 900
   10 IF (IF2OK(0) - 1) 900, 12, 900
   12 IF (LASTDB - IDB) 900, 15, 900
C Create tables via packed A4 Hollerith: "CREATE TABLE PL(A,L,D)" (22)
   15 IADDL(1) = 67
      IADDL(2) = 82
      IADDL(3) = 69
      IADDL(4) = 65
      IADDL(5) = 84
      IADDL(6) = 69
      IADDL(7) = 32
      IADDL(8) = 84
      IADDL(9) = 65
      IADDL(10) = 66
      IADDL(11) = 76
      IADDL(12) = 69
      IADDL(13) = 32
      IADDL(14) = 80
      IADDL(15) = 76
      IADDL(16) = 40
      IADDL(17) = 65
      IADDL(18) = 44
      IADDL(19) = 76
      IADDL(20) = 44
      IADDL(21) = 68
      IADDL(22) = 41
      CALL F2PKA4(IADDL, 22, IHDDL, 6)
      CALL F2EXA4(IDB, IHDDL, 22, IERR)
      IF (IERR) 900, 18, 900
   18 DO 19 J = 1, 13
      IAVDDL(J) = IADDL(J)
   19 CONTINUE
      IAVDDL(14) = 65
      IAVDDL(15) = 86
      IAVDDL(16) = 40
      IAVDDL(17) = 88
      IAVDDL(18) = 41
      CALL F2PKA4(IAVDDL, 18, IHVDDL, 5)
      CALL F2EXA4(IDB, IHVDDL, 18, IERR)
      IF (IERR) 900, 20, 900
C Persist 7 angle-of-attack setpoints (-2..+10 deg) with F2VECD / F2QRYD
   20 DO 25 K = 1, 7
      ALVEC(K) = -2.0D0 + 2.0D0 * DBLE(K - 1)
   25 CONTINUE
      CALL SQL58P(IMINS, IMSEL, IMMAX)
      DO 26 J = 1, 12
      IVINS(J) = IMINS(J)
   26 CONTINUE
      IVINS(13) = 65
      IVINS(14) = 86
      DO 27 J = 15, 23
      IVINS(J) = IMINS(J)
   27 CONTINUE
      IVINS(24) = 41
      DO 28 J = 1, 7
      IVSEL(J) = IMSEL(J)
   28 CONTINUE
      IVSEL(8) = 88
      DO 29 J = 9, 14
      IVSEL(J) = IMSEL(J + 4)
   29 CONTINUE
      IVSEL(15) = 65
      IVSEL(16) = 86
      CALL F2VECD(IDB, IVINS, 24, ALVEC, 7, IERR)
      IF (IERR) 900, 30, 900
   30 CALL F2QRYD(IDB, IVSEL, 16, AQRY, 7, NA, IERR)
      IF (IERR) 900, 32, 900
   32 IF (NA - 7) 900, 35, 900
C Evaluate NACA 2412 polar across hydrated angles & persist 2D matrix
   35 AR = 7.5D0
      EOSW = 0.84D0
      CD0 = 0.021D0
      BESTLD = 0.0D0
      DO 45 K = 1, 7
      CALL PLR58(AQRY(K), AR, EOSW, CD0, CL, CD)
      PMAT(K, 1) = AQRY(K)
      PMAT(K, 2) = CL
      PMAT(K, 3) = CD
      IF (CL / CD - BESTLD) 45, 45, 42
   42 BESTLD = CL / CD
   45 CONTINUE
      PMAT(8, 1) = 0.0D0
      PMAT(8, 2) = 0.0D0
      PMAT(8, 3) = 0.0D0
      CALL F2MATI(IDB, IMINS, 28, PMAT, 8, 7, 3, IERR)
      IF (IERR) 900, 50, 900
   50 CALL F2MATQ(IDB, IMSEL, 20, POUT, 8, 8, 3, NROWS, IERR)
      IF (IERR) 900, 52, 900
   52 IF (NROWS - 7) 900, 55, 900
C Verify SQL scalar MAX(L/D) via F2SCLD matches Fortran BESTLD
   55 CALL F2SCLD(IDB, IMMAX, 23, 0.0D0, LDMAX, IERR)
      IF (IERR) 900, 58, 900
   58 DERR = LDMAX - BESTLD
      IF (DERR * DERR - 1.0D-16) 60, 60, 900
   60 IF (LDMAX - 15.0D0) 900, 900, 62
C Verify row count via F2SCAL: "SELECT COUNT(*) FROM PL" (23? use 21)
C "SELECT COUNT(A) FROM PL" -> 23? Let's use F2SCAL on IMSEL (first A=-2)
   62 ICNTQ(1) = 83
      ICNTQ(2) = 69
      ICNTQ(3) = 76
      ICNTQ(4) = 69
      ICNTQ(5) = 67
      ICNTQ(6) = 84
      ICNTQ(7) = 32
      ICNTQ(8) = 67
      ICNTQ(9) = 79
      ICNTQ(10) = 85
      ICNTQ(11) = 78
      ICNTQ(12) = 84
      ICNTQ(13) = 40
      ICNTQ(14) = 42
      ICNTQ(15) = 41
      ICNTQ(16) = 32
      ICNTQ(17) = 70
      ICNTQ(18) = 82
      ICNTQ(19) = 79
      ICNTQ(20) = 77
      ICNTQ(21) = 32
      ICNTQ(22) = 80
      ICNTQ(23) = 76
      CALL F2SCAL(IDB, ICNTQ, 23, 0, IA0, IERR)
      IF (IERR) 900, 64, 900
   64 IF (IA0 - 7 + 0 * LASTST + 0 * LASTEC) 900, 66, 900
   66 DERR = POUT(7, 2) - PMAT(7, 2)
      IF (DERR * DERR - 1.0D-18) 70, 70, 900
   70 CALL F2CLOS(IDB, IERR)
      IF (IERR) 900, 75, 900
   75 WRITE (6, 100) NROWS, LDMAX
  100 FORMAT (I6, F12.4)
      STOP
  900 STOP 1
      END
