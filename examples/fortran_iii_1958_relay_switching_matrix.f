C @file fortran_iii_1958_relay_switching_matrix.f
C @brief 1958-59 IBM FORTRAN III Crossbar No. 5 telephone trunk-relay
C switching matrix and Erlangs B grade-of-service word-mask auditor.
C
C Showcases extended FORTRAN III boolean status-word ORM abstractions
C from corm3x.f: F3GEX, F3TXBG, F3TXCM, F3PREP, F3BINI, F3BIND, F3STEP,
C F3COLI, F3COLD, F3FINL, IF3BIT, IF3ALL, and /CORM3C/ without LOGICAL,
C CHARACTER, PARAMETER, or block IF.

C @brief Computes Erlang-B blocking probability BPROB for NTRK trunks
C under offered traffic load AERL Erlangs via exact recurrence.
C @param NTRK Number of parallel crossbar trunks (>= 1).
C @param AERL Offered traffic intensity in Erlangs.
C @param BPROB Receives grade-of-service blocking fraction (0..1).
      SUBROUTINE ERLB3(NTRK, AERL, BPROB)
      DOUBLE PRECISION AERL, BPROB, BPREV, ANUM
      BPREV = 1.0D0
      DO 20 K = 1, NTRK
      ANUM = AERL * BPREV
      BPREV = ANUM / (DBLE(K) + ANUM)
   20 CONTINUE
      BPROB = BPREV
      RETURN
      END

C @brief Evaluates 2-bit relay trunk health mask (bit 0: idle trunk
C available, bit 1: blocking < 2% grade-of-service threshold).
C @param NIDLE Number of idle trunks on frame.
C @param BPROB Erlang-B blocking probability.
C @return 2-bit word (3 when healthy & non-congested).
      INTEGER FUNCTION IRLYM(NIDLE, BPROB)
      DOUBLE PRECISION BPROB
      IB0 = 0
      IB1 = 0
      IF (NIDLE) 10, 10, 5
    5 IB0 = 1
   10 IF (BPROB - 0.02D0) 15, 15, 20
   15 IB1 = 1
   20 IRLYM = IB0 + 2 * IB1
      RETURN
      END

C @brief Main 1958-59 FORTRAN III crossbar relay switching program.
      COMMON /CORM3C/ I3STAT, I3WORD, I3DB, I3STMT
      DOUBLE PRECISION AERL(6), BPROB, BOUT, BSUM
      DIMENSION IURL(8), IDDL(24), IINS(30), ISEL(22)
      DIMENSION NTRK(6), NIDLE(6)
      DATA IURL /58, 109, 101, 109, 111, 114, 121, 58/
C "CREATE TABLE SW(F,M,N,B)" (24 chars)
      DATA IDDL /67,82,69,65,84,69,32,84,65,66,76,69,32,83,87,40,
     1           70,44,77,44,78,44,66,41/
C "INSERT INTO SW VALUES(?,?,?,?)" (30 chars)
      DATA IINS /73,78,83,69,82,84,32,73,78,84,79,32,83,87,32,86,
     1           65,76,85,69,83,40,63,44,63,44,63,44,63,41/
C "SELECT F,M,N,B FROM SW" (22 chars)
      DATA ISEL /83,69,76,69,67,84,32,70,44,77,44,78,44,66,32,70,
     1           82,79,77,32,83,87/
      DATA NTRK /12, 16, 8, 20, 10, 24/
      DATA NIDLE /4, 5, 0, 7, 2, 9/
      DATA AERL /5.5D0, 8.2D0, 7.5D0, 11.0D0, 6.8D0, 13.5D0/
      CALL F3OPEN(IURL, 8, IDB, IW)
      IF (IW - 3) 900, 10, 900
C Guarded schema creation via F3GEX short-circuit pipeline
   10 CALL F3GEX(IDB, IDDL, 24, IW)
      IF (IF3BIT(IW, 1) * IF3BIT(IW, 2) - 1) 900, 15, 900
   15 CALL F3TXBG(IDB, IW)
      IF (IW - 3) 900, 20, 900
   20 DO 45 K = 1, 6
      CALL ERLB3(NTRK(K), AERL(K), BPROB)
      IMSK = IRLYM(NIDLE(K), BPROB)
      CALL F3PREP(IDB, IINS, 30, IST, IWP)
      CALL F3BINI(IDB, IST, 1, K, IWB1)
      CALL F3BINI(IDB, IST, 2, IMSK, IWB2)
      CALL F3BINI(IDB, IST, 3, NTRK(K), IWB3)
      CALL F3BIND(IDB, IST, 4, BPROB, IWB4)
      IW = IF3ALL(IW, IF3ALL(IWP, IF3ALL(IWB1, IWB2)))
      IW = IF3ALL(IW, IF3ALL(IWB3, IWB4))
      CALL F3STEP(IDB, IST, IHAS, IWS)
      CALL F3FINL(IDB, IST, IWF)
      IW = IF3ALL(IW, IF3ALL(IWS, IWF))
      IF (IW - 3 + 0 * IHAS) 900, 45, 900
   45 CONTINUE
      CALL F3TXCM(IDB, IW)
      IF (IW - 3) 900, 50, 900
C Audit persisted crossbar frames and count grade-of-service passes
   50 CALL F3PREP(IDB, ISEL, 22, IST, IW)
      IF (IW - 3) 900, 52, 900
   52 NTOT = 0
      NPASS = 0
      BSUM = 0.0D0
   55 CALL F3STEP(IDB, IST, IHAS, IW)
      IF (IW - 3) 900, 56, 900
   56 IF (IHAS) 900, 70, 58
   58 CALL F3COLI(IDB, IST, 1, JFRM, IW1)
      CALL F3COLI(IDB, IST, 2, JMSK, IW2)
      CALL F3COLI(IDB, IST, 3, JTRK, IW3)
      CALL F3COLD(IDB, IST, 4, BOUT, IW4)
      IW = IF3ALL(IF3ALL(IW1, IW2), IF3ALL(IW3, IW4))
      IF (IW - 3) 900, 60, 900
   60 NTOT = NTOT + 1
      IF (JFRM - NTOT + 0 * JTRK) 900, 62, 900
   62 BSUM = BSUM + BOUT
      IF (IF3BIT(JMSK, 1) * IF3BIT(JMSK, 2) - 1) 55, 64, 55
   64 NPASS = NPASS + 1
      GO TO 55
   70 CALL F3FINL(IDB, IST, IW)
      IF (IW - 3) 900, 72, 900
   72 CALL F3CLOS(IDB, IW)
      IF (IW - 1) 900, 74, 900
   74 IF (NTOT - 6 + 0 * I3STAT + 0 * I3WORD + 0 * I3DB + 0 * I3STMT)
     1 900, 76, 900
   76 IF (NPASS - 4) 900, 78, 900
   78 IF (BSUM - 0.10D0) 900, 900, 80
   80 WRITE (6, 100) NTOT, NPASS, BSUM
  100 FORMAT (2I6, F12.6)
      STOP
  900 STOP 1
      END
