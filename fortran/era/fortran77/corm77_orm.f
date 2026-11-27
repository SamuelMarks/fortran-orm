C @file corm77_orm.f
C @brief High-level strict ANSI X3.9-1978 FORTRAN 77 ORM abstractions:
C scalar queries with SQL NULL defaults, table row count & existence &
C delete-by-key repositories, persistent CHARACTER*(*) Key-Value store,
C savepoint-guarded 1D INTEGER/DOUBLE PRECISION vector batching, and
C 5-dialect AST SQL rendering.
C
C Conforms strictly to ANSI X3.9-1978: fixed-form columns 1-72,
C <= 6-character uppercase names without underscores, CHARACTER*(*)
C dummy arguments, block IF/THEN/ELSE/END IF, and zero Fortran 90+
C keywords.

C @brief Executes a scalar INTEGER query with SQL NULL default fallback.
C @param IDB Active 1-based database slot.
C @param SQL SELECT SQL returning 1 integer column.
C @param IDEF Default value returned on empty set or SQL NULL.
C @param IVAL Receives scalar integer result.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7QINT(IDB, SQL, IDEF, IVAL, IERR)
      INTEGER IDB, IDEF, IVAL, IERR
      CHARACTER*(*) SQL
      INTEGER IST, IFNL
      LOGICAL LROW, LNUL
      IVAL = IDEF
      CALL F7PREP(IDB, SQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7STEP(IST, LROW, IERR)
      IF (IERR .EQ. 0 .AND. LROW) THEN
        CALL F7COLN(IST, 1, LNUL, IERR)
        IF (IERR .EQ. 0 .AND. .NOT. LNUL) THEN
          CALL F7COLI(IST, 1, IVAL, IERR)
        END IF
      END IF
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Executes a scalar DOUBLE PRECISION query with NULL fallback.
C @param IDB Active 1-based database slot.
C @param SQL SELECT SQL returning 1 real/float column.
C @param DDEF Default value returned on empty set or SQL NULL.
C @param DVAL Receives scalar double-precision result.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7QDBL(IDB, SQL, DDEF, DVAL, IERR)
      INTEGER IDB, IERR
      CHARACTER*(*) SQL
      DOUBLE PRECISION DDEF, DVAL
      INTEGER IST, IFNL
      LOGICAL LROW, LNUL
      DVAL = DDEF
      CALL F7PREP(IDB, SQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7STEP(IST, LROW, IERR)
      IF (IERR .EQ. 0 .AND. LROW) THEN
        CALL F7COLN(IST, 1, LNUL, IERR)
        IF (IERR .EQ. 0 .AND. .NOT. LNUL) THEN
          CALL F7COLD(IST, 1, DVAL, IERR)
        END IF
      END IF
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Executes a scalar CHARACTER*(*) query with SQL NULL fallback.
C @param IDB Active 1-based database slot.
C @param SQL SELECT SQL returning 1 text column.
C @param CDEF Default character string used on empty set or SQL NULL.
C @param COUT Destination blank-padded character variable.
C @param ILEN Receives trimmed character length.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7QCHR(IDB, SQL, CDEF, COUT, ILEN, IERR)
      INTEGER IDB, ILEN, IERR
      CHARACTER*(*) SQL, CDEF, COUT
      INTEGER IST, IFNL, LF7TRM
      LOGICAL LROW, LNUL
      COUT = CDEF
      ILEN = LF7TRM(CDEF)
      CALL F7PREP(IDB, SQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7STEP(IST, LROW, IERR)
      IF (IERR .EQ. 0 .AND. LROW) THEN
        CALL F7COLN(IST, 1, LNUL, IERR)
        IF (IERR .EQ. 0 .AND. .NOT. LNUL) THEN
          CALL F7COLC(IST, 1, COUT, ILEN, IERR)
        END IF
      END IF
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Computes trimmed length of a FORTRAN 77 CHARACTER*(*) string.
C @param STR Input blank-padded character string.
C @return Index of last non-space character (0 if all spaces).
      INTEGER FUNCTION LF7TRM(STR)
      CHARACTER*(*) STR
      INTEGER K, N
      N = LEN(STR)
      LF7TRM = 0
      DO 10 K = 1, N
        IF (STR(K:K) .NE. ' ') LF7TRM = K
   10 CONTINUE
      RETURN
      END

C @brief Counts total rows in SQL table TBL on IDB.
C @param IDB Active 1-based database slot.
C @param TBL Table identifier (<= 64 chars).
C @param NROWS Receives total row count.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7CNT(IDB, TBL, NROWS, IERR)
      INTEGER IDB, NROWS, IERR
      CHARACTER*(*) TBL
      CHARACTER*128 CSQL
      INTEGER LT, LF7TRM
      NROWS = 0
      LT = LF7TRM(TBL)
      IF (LT .LE. 0 .OR. LT .GT. 64) THEN
        IERR = 11
        RETURN
      END IF
      CSQL = 'SELECT COUNT(*) FROM ' // TBL(1:LT)
      CALL F7QINT(IDB, CSQL, 0, NROWS, IERR)
      RETURN
      END

C @brief Checks whether a row with integer key IDVAL exists in TBL.
C @param IDB Active 1-based database slot.
C @param TBL Table identifier.
C @param IDCOL Integer primary-key column name.
C @param IDVAL 32-bit key value to probe.
C @param LEXST Receives .TRUE. when row exists, .FALSE. otherwise.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7EXST(IDB, TBL, IDCOL, IDVAL, LEXST, IERR)
      INTEGER IDB, IDVAL, IERR
      CHARACTER*(*) TBL, IDCOL
      LOGICAL LEXST
      CHARACTER*160 CSQL
      INTEGER LT, LC, IST, IFNL, LF7TRM
      LOGICAL LROW
      LEXST = .FALSE.
      LT = LF7TRM(TBL)
      LC = LF7TRM(IDCOL)
      IF (LT .LE. 0 .OR. LC .LE. 0 .OR. LT + LC .GT. 96) THEN
        IERR = 11
        RETURN
      END IF
      CSQL = 'SELECT 1 FROM ' // TBL(1:LT) // ' WHERE ' //
     1       IDCOL(1:LC) // ' = ?'
      CALL F7PREP(IDB, CSQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7BINI(IST, 1, IDVAL, IERR)
      IF (IERR .EQ. 0) CALL F7STEP(IST, LROW, IERR)
      IF (IERR .EQ. 0) LEXST = LROW
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Deletes rows matching integer key IDVAL in TBL.
C @param IDB Active 1-based database slot.
C @param TBL Table identifier.
C @param IDCOL Integer key column name.
C @param IDVAL 32-bit key value to delete.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7DELI(IDB, TBL, IDCOL, IDVAL, IERR)
      INTEGER IDB, IDVAL, IERR
      CHARACTER*(*) TBL, IDCOL
      CHARACTER*160 CSQL
      INTEGER LT, LC, IST, IFNL, LF7TRM
      LOGICAL LROW
      LT = LF7TRM(TBL)
      LC = LF7TRM(IDCOL)
      IF (LT .LE. 0 .OR. LC .LE. 0 .OR. LT + LC .GT. 96) THEN
        IERR = 11
        RETURN
      END IF
      CSQL = 'DELETE FROM ' // TBL(1:LT) // ' WHERE ' //
     1       IDCOL(1:LC) // ' = ?'
      CALL F7PREP(IDB, CSQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7BINI(IST, 1, IDVAL, IERR)
      IF (IERR .EQ. 0) CALL F7STEP(IST, LROW, IERR)
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0 .AND. (.NOT. LROW .OR. LROW)) IERR = IFNL
      RETURN
      END

C @brief Creates a persistent CHARACTER*(*) Key-Value store table TBL.
C @param IDB Active 1-based database slot.
C @param TBL Key-value table identifier.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7KVCR(IDB, TBL, IERR)
      INTEGER IDB, IERR
      CHARACTER*(*) TBL
      CHARACTER*160 CSQL
      INTEGER LT, LF7TRM
      LT = LF7TRM(TBL)
      IF (LT .LE. 0 .OR. LT .GT. 64) THEN
        IERR = 11
        RETURN
      END IF
      CSQL = 'CREATE TABLE IF NOT EXISTS ' // TBL(1:LT) //
     1       '(K TEXT PRIMARY KEY, V TEXT)'
      CALL F7EXEC(IDB, CSQL, IERR)
      RETURN
      END

C @brief Upserts (replaces) a key-value pair in FORTRAN 77 KV table TBL.
C @param IDB Active 1-based database slot.
C @param TBL Key-value table identifier.
C @param CKEY Key string.
C @param CVAL Value string.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7KVPT(IDB, TBL, CKEY, CVAL, IERR)
      INTEGER IDB, IERR
      CHARACTER*(*) TBL, CKEY, CVAL
      CHARACTER*160 CSQL
      INTEGER LT, IST, IFNL, LF7TRM
      LOGICAL LROW
      LT = LF7TRM(TBL)
      IF (LT .LE. 0 .OR. LT .GT. 64) THEN
        IERR = 11
        RETURN
      END IF
      CSQL = 'INSERT OR REPLACE INTO ' // TBL(1:LT) // ' VALUES(?,?)'
      CALL F7PREP(IDB, CSQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7BINC(IST, 1, CKEY, IERR)
      IF (IERR .EQ. 0) CALL F7BINC(IST, 2, CVAL, IERR)
      IF (IERR .EQ. 0) CALL F7STEP(IST, LROW, IERR)
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0 .AND. (.NOT. LROW .OR. LROW)) IERR = IFNL
      RETURN
      END

C @brief Fetches a value by key from FORTRAN 77 KV table TBL.
C @param IDB Active 1-based database slot.
C @param TBL Key-value table identifier.
C @param CKEY Key string to look up.
C @param COUT Destination value buffer.
C @param ILEN Receives trimmed value length (0 when not found).
C @param LFOUND Receives .TRUE. if key was present, .FALSE. otherwise.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7KVGT(IDB, TBL, CKEY, COUT, ILEN, LFOUND, IERR)
      INTEGER IDB, ILEN, IERR
      CHARACTER*(*) TBL, CKEY, COUT
      LOGICAL LFOUND
      CHARACTER*160 CSQL
      INTEGER LT, IST, IFNL, LF7TRM
      LOGICAL LROW
      COUT = ' '
      ILEN = 0
      LFOUND = .FALSE.
      LT = LF7TRM(TBL)
      IF (LT .LE. 0 .OR. LT .GT. 64) THEN
        IERR = 11
        RETURN
      END IF
      CSQL = 'SELECT V FROM ' // TBL(1:LT) // ' WHERE K = ?'
      CALL F7PREP(IDB, CSQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7BINC(IST, 1, CKEY, IERR)
      IF (IERR .EQ. 0) CALL F7STEP(IST, LROW, IERR)
      IF (IERR .EQ. 0 .AND. LROW) THEN
        LFOUND = .TRUE.
        CALL F7COLC(IST, 1, COUT, ILEN, IERR)
      END IF
      CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Savepoint-guarded batch insert of 1D DOUBLE PRECISION DVEC.
C @param IDB Active 1-based database slot.
C @param SQL Single-parameter INSERT SQL string.
C @param DVEC Source DOUBLE PRECISION array DVEC(1..N).
C @param N Number of elements to insert.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7VECD(IDB, SQL, DVEC, N, IERR)
      INTEGER IDB, N, IERR
      CHARACTER*(*) SQL
      DOUBLE PRECISION DVEC(*)
      INTEGER IST, K, IFNL, ISPR
      LOGICAL LROW
      IERR = 0
      IF (N .LE. 0) RETURN
      CALL F7SVPT(IDB, 'F7VECD_SP', IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7PREP(IDB, SQL, IST, IERR)
      IF (IERR .NE. 0) THEN
        CALL F7RBSP(IDB, 'F7VECD_SP', ISPR)
        CALL F7RLSP(IDB, 'F7VECD_SP', ISPR)
        RETURN
      END IF
      DO 20 K = 1, N
        CALL F7BIND(IST, 1, DVEC(K), IERR)
        IF (IERR .EQ. 0) CALL F7STEP(IST, LROW, IERR)
        IF (IERR .EQ. 0) CALL F7RSET(IST, IERR)
        IF (IERR .NE. 0 .AND. (.NOT. LROW .OR. LROW)) GO TO 30
   20 CONTINUE
   30 CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      IF (IERR .EQ. 0) THEN
        CALL F7RLSP(IDB, 'F7VECD_SP', IERR)
      ELSE
        CALL F7RBSP(IDB, 'F7VECD_SP', ISPR)
        CALL F7RLSP(IDB, 'F7VECD_SP', ISPR)
      END IF
      RETURN
      END

C @brief Hydrates column 1 of SELECT SQL into DOUBLE PRECISION DVEC.
C @param IDB Active 1-based database slot.
C @param SQL SELECT SQL string.
C @param DVEC Destination DOUBLE PRECISION array DVEC(1..ICAP).
C @param ICAP Maximum element capacity of DVEC.
C @param NOUT Receives hydrated element count.
C @param IERR Receives CORMOK (0) or CBUFER (34) on overflow.
      SUBROUTINE F7QRYD(IDB, SQL, DVEC, ICAP, NOUT, IERR)
      INTEGER IDB, ICAP, NOUT, IERR
      CHARACTER*(*) SQL
      DOUBLE PRECISION DVEC(*)
      INTEGER IST, IFNL
      LOGICAL LROW
      NOUT = 0
      CALL F7PREP(IDB, SQL, IST, IERR)
      IF (IERR .NE. 0) RETURN
   10 CALL F7STEP(IST, LROW, IERR)
      IF (IERR .EQ. 0 .AND. LROW) THEN
        IF (NOUT .GE. ICAP) THEN
          IERR = 34
          GO TO 30
        END IF
        NOUT = NOUT + 1
        CALL F7COLD(IST, 1, DVEC(NOUT), IERR)
        IF (IERR .EQ. 0) GO TO 10
      END IF
   30 CALL F7FINL(IST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END

C @brief Renders a SELECT * FROM <TBL> AST in one call for IDIAL.
C @param TBL Table name string.
C @param NLIMIT Row limit (0 for unlimited).
C @param IDIAL Target SQL dialect (0=SQLite,1=PG,2=MySQL,3=Db2,4=ODBC).
C @param OUTSQL Destination blank-padded SQL buffer.
C @param ILEN Receives rendered SQL length.
C @param IERR Receives CORMOK (0) or error code.
      SUBROUTINE F7ASAL(TBL, NLIMIT, IDIAL, OUTSQL, ILEN, IERR)
      CHARACTER*(*) TBL, OUTSQL
      INTEGER NLIMIT, IDIAL, ILEN, IERR
      INTEGER IAST, IFNL, LF7TRM
      ILEN = 0
      OUTSQL = ' '
      IF (LF7TRM(TBL) .LE. 0) THEN
        IERR = 11
        RETURN
      END IF
      CALL F7ASTS(TBL, NLIMIT, IAST, IERR)
      IF (IERR .NE. 0) RETURN
      CALL F7ASTR(IAST, IDIAL, OUTSQL, ILEN, IERR)
      CALL F7ASTF(IAST, IFNL)
      IF (IERR .EQ. 0) IERR = IFNL
      RETURN
      END
