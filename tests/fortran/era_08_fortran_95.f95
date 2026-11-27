!> @file era_08_fortran_95.f95
!> @brief End-to-end ISO/IEC 1539-1:1997 Fortran 95 ORM verification suite
!> covering `fortran_orm_f95` and `fortran_orm_f95_orm` (`PURE`/`ELEMENTAL`
!> kernels, `FORALL` scaled/affine/masked matrices, statements, savepoints,
!> ASTs, and `corm_grid2d_f95` structured mesh checkpointing).
PROGRAM era_08_fortran_95
  USE fortran_orm_f95_orm
  IMPLICIT NONE

  TYPE(corm_db_f95) :: db, bad_db
  TYPE(corm_stmt_f95) :: stmt
  TYPE(corm_ast_f95) :: ast
  TYPE(corm_grid2d_f95) :: g_in, g_out, g_unalloc
  DOUBLE PRECISION, DIMENSION(3, 2) :: src_mat, dst_mat
  LOGICAL, DIMENSION(3, 2) :: vmask
  INTEGER, DIMENSION(3) :: statuses
  LOGICAL, DIMENSION(3) :: ok_flags
  CHARACTER(LEN=32) :: tag_out
  CHARACTER(LEN=128) :: ast_sql
  DOUBLE PRECISION :: dv, clamped
  LOGICAL :: has_row
  INTEGER :: rc, nrows, i, iv, slen

  IF (corm_f95_db_is_open(db)) STOP 1
  IF (corm_f95_stmt_is_open(stmt)) STOP 1
  IF (corm_f95_ast_is_open(ast)) STOP 1
  IF (.NOT. corm_f95_is_err(11)) STOP 1

  clamped = corm_f95_clamp_val(-5.0D0, 0.0D0, 10.0D0)
  IF (ABS(clamped) > 1.0D-12) STOP 1

  CALL corm_f95_open(":memory:", db, statuses(1))
  IF (.NOT. corm_f95_db_is_open(db)) STOP 1

  ! Transactions & savepoints
  CALL corm_f95_tx_begin(db, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_savepoint(db, "sp95", rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_rollback_sp(db, "sp95", rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_release_sp(db, "sp95", rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_tx_rollback(db, rc)
  IF (corm_f95_is_err(rc)) STOP 1

  ! Generic prepared statements in Fortran 95
  CALL corm_f95_exec(db, "CREATE TABLE f95_obs(k INT, x REAL, nm TEXT)", rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_tx_begin(db, rc)
  CALL corm_f95_prepare(db, "INSERT INTO f95_obs VALUES(?,?,?)", stmt, rc)
  IF (corm_f95_is_err(rc) .OR. .NOT. corm_f95_stmt_is_open(stmt)) STOP 1
  CALL corm_f95_bind(stmt, 1, 95, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_bind(stmt, 2, 6.5D0, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_bind(stmt, 3, "ISO1997", rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_step(stmt, has_row, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_reset(stmt, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_finalize(stmt, rc)
  IF (corm_f95_is_err(rc) .OR. corm_f95_stmt_is_open(stmt)) STOP 1
  CALL corm_f95_tx_commit(db, rc)
  IF (corm_f95_is_err(rc)) STOP 1

  CALL corm_f95_prepare(db, "SELECT k, x, nm FROM f95_obs", stmt, rc)
  CALL corm_f95_step(stmt, has_row, rc)
  IF (corm_f95_is_err(rc) .OR. .NOT. has_row) STOP 1
  CALL corm_f95_col(stmt, 1, iv, rc)
  IF (corm_f95_is_err(rc) .OR. iv /= 95) STOP 1
  CALL corm_f95_col(stmt, 2, dv, rc)
  IF (corm_f95_is_err(rc) .OR. ABS(dv - 6.5D0) > 1.0D-9) STOP 1
  CALL corm_f95_col(stmt, 3, tag_out, slen, rc)
  IF (corm_f95_is_err(rc) .OR. tag_out(1:slen) /= "ISO1997") STOP 1
  CALL corm_f95_finalize(stmt, rc)

  ! FORALL scaled, affine, and masked matrices
  CALL corm_f95_exec(db, "CREATE TABLE f95_grid(u REAL, v REAL)", statuses(2))
  CALL corm_f95_query_matrix(db, "SELECT u, v FROM f95_grid", dst_mat, nrows, rc)
  IF (.NOT. corm_f95_is_ok(rc) .OR. nrows /= 0) STOP 1

  FORALL (i = 1:3)
    src_mat(i, 1) = DBLE(i)
    src_mat(i, 2) = DBLE(i * 10)
  END FORALL

  CALL corm_f95_insert_scaled_matrix(db, "INSERT INTO f95_grid VALUES(?,?)", &
                                     src_mat, 2.5D0, statuses(3))
  ok_flags = corm_f95_is_ok(statuses)
  IF (.NOT. ALL(ok_flags)) STOP 1
  CALL corm_f95_query_matrix(db, "SELECT u, v FROM f95_grid", dst_mat, nrows, rc)
  IF (.NOT. corm_f95_is_ok(rc) .OR. nrows /= 3) STOP 1
  IF (ABS(dst_mat(3, 2) - 75.0D0) > 1.0D-9) STOP 1

  CALL corm_f95_exec(db, "CREATE TABLE f95_aff(u REAL, v REAL)", rc)
  CALL corm_f95_insert_affine_matrix(db, "INSERT INTO f95_aff VALUES(?,?)", &
                                     src_mat, 2.0D0, 1.0D0, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_query_matrix(db, "SELECT u, v FROM f95_aff", dst_mat, nrows, rc)
  IF (corm_f95_is_err(rc) .OR. ABS(dst_mat(3, 2) - 61.0D0) > 1.0D-9) STOP 1

  CALL corm_f95_exec(db, "CREATE TABLE f95_msk(u REAL, v REAL)", rc)
  vmask = .TRUE.
  vmask(2, 2) = .FALSE.
  CALL corm_f95_insert_masked_matrix(db, "INSERT INTO f95_msk VALUES(?,?)", &
                                     src_mat, vmask, -999.0D0, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  CALL corm_f95_query_matrix(db, "SELECT u, v FROM f95_msk", dst_mat, nrows, rc)
  IF (corm_f95_is_err(rc) .OR. ABS(dst_mat(2, 2) + 999.0D0) > 1.0D-9) STOP 1

  ! Structured 2D mesh checkpointing (`corm_grid2d_f95`)
  CALL corm_f95_grid_save(db, "mesh95", g_unalloc, rc)
  IF (rc /= 11) STOP 1
  CALL corm_f95_grid_load(db, "mesh95", g_unalloc, rc)
  IF (rc /= 11) STOP 1
  CALL corm_f95_grid_alloc(g_in, 2, 2, 0.5D0, 0.5D0)
  CALL corm_f95_grid_alloc(g_in, 2, 3, 0.5D0, 0.25D0)
  g_in%cells(:, 1) = (/ 1.0D0, 2.0D0 /)
  g_in%cells(:, 2) = (/ 3.0D0, 4.0D0 /)
  g_in%cells(:, 3) = (/ 5.0D0, 6.0D0 /)
  CALL corm_f95_grid_save(bad_db, "mesh95", g_in, rc)
  IF (corm_f95_is_ok(rc)) STOP 1
  CALL corm_f95_grid_save(db, "mesh95", g_in, rc)
  IF (corm_f95_is_err(rc)) STOP 1

  CALL corm_f95_grid_alloc(g_out, 2, 2, 0.5D0, 0.25D0)
  CALL corm_f95_grid_load(db, "mesh95", g_out, rc)
  IF (corm_f95_is_ok(rc)) STOP 1
  CALL corm_f95_exec(db, "CREATE TABLE empty95(ix REAL, iy REAL, u REAL)", rc)
  CALL corm_f95_grid_load(db, "empty95", g_out, rc)
  IF (rc /= 7) STOP 1
  CALL corm_f95_grid_alloc(g_out, 2, 3, 0.5D0, 0.25D0)
  CALL corm_f95_grid_load(db, "mesh95", g_out, rc)
  IF (corm_f95_is_err(rc)) STOP 1
  IF (MAXVAL(ABS(g_out%cells - g_in%cells)) > 1.0D-12) STOP 1
  CALL corm_f95_grid_free(g_in)
  CALL corm_f95_grid_free(g_out)

  ! AST rendering in Fortran 95
  CALL corm_f95_ast_select("f95_grid", 4, ast, rc)
  IF (corm_f95_is_err(rc) .OR. .NOT. corm_f95_ast_is_open(ast)) STOP 1
  CALL corm_f95_ast_to_sql(ast, CORM_F95_DIALECT_POSTGRES, ast_sql, slen, rc)
  IF (corm_f95_is_err(rc) .OR. slen <= 0) STOP 1
  CALL corm_f95_ast_free(ast, rc)
  IF (corm_f95_is_err(rc) .OR. corm_f95_ast_is_open(ast)) STOP 1

  CALL corm_f95_close(db, rc)
  IF (.NOT. corm_f95_is_ok(rc) .OR. corm_f95_db_is_open(db)) STOP 1
  PRINT '(A)', "PASS: Fortran 95"
END PROGRAM era_08_fortran_95
