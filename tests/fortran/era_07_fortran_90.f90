!> @file era_07_fortran_90.f90
!> @brief End-to-end ISO/IEC 1539:1991 Fortran 90 ORM verification suite
!> covering `fortran_orm_f90` and `fortran_orm_f90_orm` (`corm_query_f90_t`,
!> `corm_kv_f90_t`, `corm_ts_f90_t`, savepoints, generic vectors, and scalars).
PROGRAM era_07_fortran_90
  USE fortran_orm_f90_orm
  IMPLICIT NONE

  TYPE(corm_db_f90) :: db, bad_db
  TYPE(corm_stmt_f90) :: stmt
  TYPE(corm_ast_f90) :: ast
  TYPE(corm_query_f90_t) :: q
  TYPE(corm_kv_f90_t) :: kv, bad_kv
  TYPE(corm_ts_f90_t) :: ts, bad_ts
  DOUBLE PRECISION, ALLOCATABLE, DIMENSION(:, :) :: m_in, m_out
  INTEGER, DIMENSION(3) :: vi_in, vi_out
  DOUBLE PRECISION, DIMENSION(3) :: vd_in, vd_out
  CHARACTER(LEN=64) :: str_val, kv_val
  CHARACTER(LEN=256) :: sql_rendered
  INTEGER :: rc, iv, slen, nrows, rowid, lstep
  DOUBLE PRECISION :: dv, lt_sim, lval, peak_v
  LOGICAL :: has_row, is_null, bflag, exists_f, found_f

  bad_db%slot = 0
  CALL corm_f90_open(":memory:", db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_exec(db, &
       "CREATE TABLE f90_items(id INT, score REAL, tag TEXT, active INT)", rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_tx_begin(db)
  CALL corm_f90_tx_rollback(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_tx_begin(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_savepoint(db, "sp_f90", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_rollback_sp(db, "sp_f90", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_release_sp(db, "sp_f90", rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_prepare(db, "INSERT INTO f90_items VALUES(?,?,?,?)", stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind(stmt, 1, 90, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind(stmt, 2, 99.5D0, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind(stmt, 3, "ISO1991", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind_logical(stmt, 4, .TRUE., rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_reset(stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_bind(stmt, 1, 91, rc)
  CALL corm_f90_bind_null(stmt, 2, rc)
  CALL corm_f90_bind_null(stmt, 3, rc)
  CALL corm_f90_bind_logical(stmt, 4, .FALSE., rc)
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_finalize(stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_tx_commit(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_last_rowid(db, rowid, rc)
  IF (rc /= CORM_F90_OK .OR. rowid < 2) STOP 1

  CALL corm_f90_prepare(db, &
       "SELECT id, score, tag, active FROM f90_items ORDER BY id", stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. has_row) STOP 1
  CALL corm_f90_col(stmt, 1, iv, rc)
  IF (rc /= CORM_F90_OK .OR. iv /= 90) STOP 1
  CALL corm_f90_col(stmt, 2, dv, rc)
  IF (rc /= CORM_F90_OK .OR. ABS(dv - 99.5D0) > 1.0D-9) STOP 1
  CALL corm_f90_col(stmt, 3, str_val, slen, rc)
  IF (rc /= CORM_F90_OK .OR. str_val(1:slen) /= "ISO1991") STOP 1
  CALL corm_f90_col_logical(stmt, 4, bflag, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. bflag) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. has_row) STOP 1
  CALL corm_f90_col_is_null(stmt, 2, is_null, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. is_null) STOP 1
  CALL corm_f90_col_logical(stmt, 4, bflag, rc)
  IF (rc /= CORM_F90_OK .OR. bflag) STOP 1
  CALL corm_f90_finalize(stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! Scalars, count, exists, delete (+ validation & error paths)
  CALL corm_f90_scalar_i32(bad_db, "SELECT 1", -1, iv, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_scalar_i32(db, "SELECT score FROM f90_items WHERE id=91", &
                           777, iv, rc)
  IF (rc /= CORM_F90_OK .OR. iv /= 777) STOP 1
  CALL corm_f90_scalar_i32(db, "SELECT id FROM f90_items WHERE id=90", &
                           0, iv, rc)
  IF (rc /= CORM_F90_OK .OR. iv /= 90) STOP 1

  CALL corm_f90_scalar_f64(bad_db, "SELECT 1.0", 0.0D0, dv, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_scalar_f64(db, "SELECT score FROM f90_items WHERE id=91", &
                           2.5D0, dv, rc)
  IF (rc /= CORM_F90_OK .OR. ABS(dv - 2.5D0) > 1.0D-9) STOP 1
  CALL corm_f90_scalar_f64(db, "SELECT score FROM f90_items WHERE id=90", &
                           0.0D0, dv, rc)
  IF (rc /= CORM_F90_OK .OR. ABS(dv - 99.5D0) > 1.0D-9) STOP 1

  CALL corm_f90_scalar_str(bad_db, "SELECT 'A'", "DEF", str_val, slen, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_scalar_str(db, "SELECT tag FROM f90_items WHERE id=91", &
                           "FALLBACK", str_val, slen, rc)
  IF (rc /= CORM_F90_OK .OR. str_val(1:slen) /= "FALLBACK") STOP 1
  CALL corm_f90_scalar_str(db, "SELECT tag FROM f90_items WHERE id=90", &
                           "NONE", str_val, slen, rc)
  IF (rc /= CORM_F90_OK .OR. str_val(1:slen) /= "ISO1991") STOP 1

  CALL corm_f90_count(db, "   ", nrows, ierr=rc)
  IF (rc /= CORM_F90_ERR_VAL) STOP 1
  CALL corm_f90_count(db, "f90_items", nrows, ierr=rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 2) STOP 1
  CALL corm_f90_count(db, "f90_items", nrows, "id = 90", rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 1) STOP 1

  CALL corm_f90_exists_i32(db, " ", "id", 90, exists_f, rc)
  IF (rc /= CORM_F90_ERR_VAL) STOP 1
  CALL corm_f90_exists_i32(bad_db, "f90_items", "id", 90, exists_f, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_exists_i32(db, "f90_items", "id", 90, exists_f, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. exists_f) STOP 1

  CALL corm_f90_delete_i32(db, " ", "id", 91, rc)
  IF (rc /= CORM_F90_ERR_VAL) STOP 1
  CALL corm_f90_delete_i32(bad_db, "f90_items", "id", 91, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_delete_i32(db, "f90_items", "id", 91, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! Fluent Query Builder corm_query_f90_t
  CALL corm_f90_exec(db, "CREATE TABLE f90_dept(id INT, dname TEXT)", rc)
  CALL corm_f90_exec(db, "INSERT INTO f90_dept VALUES(90, 'O''NEILL')", rc)
  CALL corm_f90_q_init(q, "f90_items i")
  CALL corm_f90_q_init(q, "f90_items i", "i.id, d.dname")
  CALL corm_f90_q_distinct(q)
  CALL corm_f90_q_join(q, "INNER", "f90_dept d", "i.id = d.id")
  CALL corm_f90_q_join(q, "INNER", "f90_dept d2", "i.id = d2.id")
  CALL corm_f90_q_where_i32(q, "i.id", ">=", 90)
  CALL corm_f90_q_where_str(q, "d.dname", "=", "O'NEILL")
  CALL corm_f90_q_where_str(q, "d.dname", "<>", "")
  CALL corm_f90_q_group_by(q, "i.id, d.dname", "COUNT(*) >= 1")
  CALL corm_f90_q_order_by(q, "i.id", .FALSE.)
  CALL corm_f90_q_order_by(q, "i.id", .TRUE.)
  CALL corm_f90_q_limit_offset(q, 5, 0)
  CALL corm_f90_q_limit_offset(q, 5, 1)
  CALL corm_f90_q_render(q, sql_rendered, slen)
  IF (INDEX(sql_rendered(1:slen), "SELECT DISTINCT") == 0) STOP 1
  CALL corm_f90_q_limit_offset(q, 5, 0)
  CALL corm_f90_q_prepare(db, q, stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_step(stmt, has_row, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. has_row) STOP 1
  CALL corm_f90_finalize(stmt, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  ! Generic 1D vectors (`INTEGER` & `DOUBLE PRECISION`) + 2D matrix
  CALL corm_f90_exec(db, "CREATE TABLE f90_vi(v INT)", rc)
  CALL corm_f90_exec(db, "CREATE TABLE f90_vd(v REAL)", rc)
  vi_in = (/ 10, 20, 30 /)
  vd_in = (/ 1.5D0, 2.5D0, 3.5D0 /)
  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vi VALUES(?)", vi_in(1:0), rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(bad_db, "INSERT INTO f90_vi VALUES(?)", vi_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "BAD SQL", vi_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vi VALUES(?,?)", vi_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vi VALUES(NULL)", vi_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vi VALUES(?)", vi_in, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_vec(bad_db, "SELECT v FROM f90_vi", vi_out, nrows, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_query_vec(db, "SELECT v FROM f90_vi", vi_out(1:2), nrows, rc)
  IF (rc /= CORM_F90_ERR_BUF) STOP 1
  CALL corm_f90_query_vec(db, "SELECT v FROM f90_vi", vi_out, nrows, rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 3 .OR. vi_out(3) /= 30) STOP 1

  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vd VALUES(?)", vd_in(1:0), rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(bad_db, "INSERT INTO f90_vd VALUES(?)", vd_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "BAD SQL", vd_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vd VALUES(?,?)", vd_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vd VALUES(NULL)", vd_in, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_insert_vec(db, "INSERT INTO f90_vd VALUES(?)", vd_in, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_vec(bad_db, "SELECT v FROM f90_vd", vd_out, nrows, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_query_vec(db, "SELECT v FROM f90_vd", vd_out(1:2), nrows, rc)
  IF (rc /= CORM_F90_ERR_BUF) STOP 1
  CALL corm_f90_query_vec(db, "SELECT v FROM f90_vd", vd_out, nrows, rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 3) STOP 1

  CALL corm_f90_exec(db, "CREATE TABLE f90_mat(c1 REAL, c2 REAL)", rc)
  ALLOCATE(m_in(3, 2), m_out(3, 2))
  m_in(:, 1) = (/ 1.0D0, 2.0D0, 3.0D0 /)
  m_in(:, 2) = (/ 4.0D0, 5.0D0, 6.0D0 /)
  CALL corm_f90_insert_matrix(db, "INSERT INTO f90_mat VALUES(?,?)", m_in, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_query_matrix(db, "SELECT c1, c2 FROM f90_mat", m_out, nrows, rc)
  IF (rc /= CORM_F90_OK .OR. nrows /= 3) STOP 1
  IF (ABS(m_out(3, 2) - 6.0D0) > 1.0D-9) STOP 1
  DEALLOCATE(m_in, m_out)

  ! Persistent Key-Value Store corm_kv_f90_t
  CALL corm_f90_kv_init(db, " ", kv, rc)
  IF (rc /= CORM_F90_ERR_VAL) STOP 1
  CALL corm_f90_kv_init(db, "f90_cfg", kv, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  bad_kv%db = bad_db
  bad_kv%table_name = "f90_cfg"
  CALL corm_f90_kv_put(bad_kv, "k", "v", rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_kv_get(bad_kv, "k", kv_val, slen, found_f, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_kv_delete(bad_kv, "k", rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_kv_put(kv, "solver", "RK4", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_kv_get(kv, "solver", kv_val, slen, found_f, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. found_f .OR. kv_val(1:slen) /= "RK4") STOP 1
  CALL corm_f90_kv_delete(kv, "solver", rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_kv_get(kv, "solver", kv_val, slen, found_f, rc)
  IF (rc /= CORM_F90_OK .OR. found_f) STOP 1

  ! Time-Series Ledger corm_ts_f90_t
  CALL corm_f90_ts_init(db, " ", ts, rc)
  IF (rc /= CORM_F90_ERR_VAL) STOP 1
  CALL corm_f90_ts_init(db, "f90_ts", ts, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  bad_ts%db = bad_db
  bad_ts%table_name = "f90_ts"
  CALL corm_f90_ts_append(bad_ts, 1, 0.1D0, 1.0D0, "S1", rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_ts_latest(bad_ts, lstep, lt_sim, lval, found_f, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_ts_prune_after(bad_ts, 1, rc)
  IF (rc == CORM_F90_OK) STOP 1
  CALL corm_f90_ts_append(ts, 1, 0.1D0, 12.5D0, "GROWTH", rc)
  CALL corm_f90_ts_append(ts, 2, 0.2D0, 28.0D0, "PEAK", rc)
  CALL corm_f90_ts_append(ts, 3, 0.3D0, 19.0D0, "SPEC", rc)
  CALL corm_f90_ts_max_val(ts, peak_v, rc)
  IF (rc /= CORM_F90_OK .OR. ABS(peak_v - 28.0D0) > 1.0D-9) STOP 1
  CALL corm_f90_ts_prune_after(ts, 2, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_ts_latest(ts, lstep, lt_sim, lval, found_f, rc)
  IF (rc /= CORM_F90_OK .OR. .NOT. found_f .OR. lstep /= 2) STOP 1
  IF (ABS(lt_sim - 0.2D0) > 1.0D-9 .OR. ABS(lval - 28.0D0) > 1.0D-9) STOP 1

  CALL corm_f90_ast_select("f90_mat", 10, ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  CALL corm_f90_ast_to_sql(ast, CORM_F90_DIALECT_DB2, sql_rendered, slen, rc)
  IF (rc /= CORM_F90_OK .OR. slen <= 0) STOP 1
  CALL corm_f90_ast_free(ast, rc)
  IF (rc /= CORM_F90_OK) STOP 1

  CALL corm_f90_close(db, rc)
  IF (rc /= CORM_F90_OK) STOP 1
  PRINT '(A)', "PASS: Fortran 90"
END PROGRAM era_07_fortran_90
