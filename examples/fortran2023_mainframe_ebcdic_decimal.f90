!> @file fortran2023_mainframe_ebcdic_decimal.f90
!> @brief ISO Fortran 2023 mainframe EBCDIC transcoding, exact 38-digit decimal
!> banking settlement, horizontal shard routing, and OAuth2 token example.
PROGRAM fortran2023_mainframe_ebcdic_decimal
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_PTR, C_NULL_PTR, C_NULL_CHAR, &
                                          C_INT8_T, C_INT32_T, C_INT64_T, &
                                          C_CHAR, C_LOC
  USE fortran_orm
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: shard_db1, shard_db2
  TYPE(orm_stmt_t) :: stmt
  TYPE(C_PTR) :: shard_mgr
  TYPE(fortran_orm_decimal) :: principal, rate, interest, closing_bal, db_bal
  TYPE(fortran_orm_oauth2_token_pod) :: tok_in, tok_out
  INTEGER(C_INT8_T), DIMENSION(32), TARGET :: ebcdic_wire
  CHARACTER(LEN=32, KIND=C_CHAR) :: utf8_acct, bal_buf
  CHARACTER(LEN=*), PARAMETER :: ACCT_CODE = "Z_OS_LEDGER_037"
  CHARACTER(LEN=*), PARAMETER :: BEARER_TOK = "f23_settlement_tok_01"
  LOGICAL :: has_row
  INTEGER(C_INT32_T) :: rc, ebcdic_len, utf8_len, bal_len, route_idx
  INTEGER(C_INT32_T) :: scope_ok, k

  ! 1. Round-trip account identifier through z/OS CCSID 037 EBCDIC
  ebcdic_wire = 0_C_INT8_T
  rc = fortran_orm_utf8_to_ebcdic_str(FORTRAN_ORM_CP_IBM037, ACCT_CODE, &
       INT(LEN(ACCT_CODE), C_INT32_T), C_LOC(ebcdic_wire(1)), &
       32_C_INT32_T, ebcdic_len)
  IF (rc /= FORTRAN_ORM_OK .OR. ebcdic_len /= INT(LEN(ACCT_CODE), C_INT32_T)) &
    ERROR STOP 1

  utf8_acct = " "
  rc = fortran_orm_ebcdic_to_utf8(FORTRAN_ORM_CP_IBM037, &
       C_LOC(ebcdic_wire(1)), ebcdic_len, utf8_acct, 32_C_INT32_T, utf8_len)
  IF (rc /= FORTRAN_ORM_OK .OR. utf8_acct(1:utf8_len) /= ACCT_CODE) &
    ERROR STOP 1

  ! 2. Exact 38-digit fixed-point decimal interest settlement (banker's round)
  rc = fortran_orm_dec_from_str_str("125000000000000.00", 18_C_INT32_T, &
                                    principal)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_from_str_str("0.0425", 6_C_INT32_T, rate)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_mul(principal, rate, 2_C_INT32_T, &
                           FORTRAN_ORM_ROUND_HALF_EVEN, interest)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_dec_add(principal, interest, closing_bal)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 3. Deterministic 2-node horizontal shard router via F_C_STRING connections
  rc = corm_f2023_open(shard_db1, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_open(shard_db2, ":memory:")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_exec(shard_db1, &
       "CREATE TABLE settlements(acct TEXT, closing_dec TEXT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_exec(shard_db2, &
       "CREATE TABLE settlements(acct TEXT, closing_dec TEXT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  shard_mgr = C_NULL_PTR
  rc = fortran_orm_shard_init(2_C_INT32_T, shard_mgr)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_shard_add_node(shard_mgr, 1_C_INT32_T, shard_db1%ptr)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_shard_add_node(shard_mgr, 2_C_INT32_T, shard_db2%ptr)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_shard_route(shard_mgr, utf8_acct, utf8_len, route_idx)
  IF (rc /= FORTRAN_ORM_OK .OR. (route_idx /= 1_C_INT32_T .AND. &
      route_idx /= 2_C_INT32_T)) ERROR STOP 1

  IF (route_idx == 1_C_INT32_T) THEN
    rc = stmt%prepare(shard_db1, "INSERT INTO settlements VALUES(?,?)")
  ELSE
    rc = stmt%prepare(shard_db2, "INSERT INTO settlements VALUES(?,?)")
  END IF
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%bind_str(1_C_INT32_T, utf8_acct(1:utf8_len))
  IF (rc == FORTRAN_ORM_OK) rc = fortran_orm_stmt_bind_decimal(stmt%ptr, &
       2_C_INT32_T, closing_bal)
  IF (rc == FORTRAN_ORM_OK) rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  IF (route_idx == 1_C_INT32_T) THEN
    rc = stmt%prepare(shard_db1, "SELECT closing_dec FROM settlements")
  ELSE
    rc = stmt%prepare(shard_db2, "SELECT closing_dec FROM settlements")
  END IF
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = stmt%step(has_row)
  IF (rc /= FORTRAN_ORM_OK .OR. .NOT. has_row) ERROR STOP 1
  rc = fortran_orm_stmt_col_decimal(stmt%ptr, 1_C_INT32_T, db_bal)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  bal_buf = " "
  rc = fortran_orm_dec_to_str(db_bal, bal_buf, 32_C_INT32_T, bal_len)
  IF (rc /= FORTRAN_ORM_OK .OR. &
      bal_buf(1:bal_len) /= "130312500000000.00") ERROR STOP 1
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  ! 4. OAuth2 service token persistence & scope subset verification
  rc = fortran_orm_oauth2_init_tables(shard_db1%ptr)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  tok_in%access_token = C_NULL_CHAR
  tok_in%refresh_token = C_NULL_CHAR
  tok_in%token_type = C_NULL_CHAR
  tok_in%user_id = C_NULL_CHAR
  tok_in%scopes = C_NULL_CHAR
  DO k = 1_C_INT32_T, INT(LEN(BEARER_TOK), C_INT32_T)
    tok_in%access_token(k) = BEARER_TOK(k:k)
  END DO
  DO k = 1_C_INT32_T, 6_C_INT32_T
    tok_in%token_type(k) = "Bearer"(k:k)
  END DO
  DO k = 1_C_INT32_T, 8_C_INT32_T
    tok_in%user_id(k) = "u_zos_01"(k:k)
  END DO
  DO k = 1_C_INT32_T, 18_C_INT32_T
    tok_in%scopes(k) = "ledger:read settle"(k:k)
  END DO
  tok_in%expires_in = 3600_C_INT32_T
  tok_in%reserved_pad = 0_C_INT32_T
  tok_in%created_at = 4102444800_C_INT64_T

  rc = fortran_orm_oauth2_save_token(shard_db1%ptr, tok_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = fortran_orm_oauth2_get_token_str(shard_db1%ptr, BEARER_TOK, &
       INT(LEN(BEARER_TOK), C_INT32_T), tok_out)
  IF (rc /= FORTRAN_ORM_OK .OR. tok_out%expires_in /= 3600_C_INT32_T) &
    ERROR STOP 1
  rc = fortran_orm_oauth2_revoke_or_check_str(shard_db1%ptr, BEARER_TOK, &
       INT(LEN(BEARER_TOK), C_INT32_T), 1_C_INT32_T, "ledger:read settle", &
       18_C_INT32_T, "settle", 6_C_INT32_T, scope_ok)
  IF (rc /= FORTRAN_ORM_OK .OR. scope_ok /= 1_C_INT32_T) ERROR STOP 1

  rc = fortran_orm_shard_free(shard_mgr)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = shard_db1%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = shard_db2%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A,I1,2A)', "Shard ", route_idx, ": ", bal_buf(1:bal_len)
END PROGRAM fortran2023_mainframe_ebcdic_decimal
