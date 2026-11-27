!> @file fortran_orm_f2008_ckpt_sub.f90
!> @module fortran_orm_f2008_ckpt
!> @brief Second ISO Fortran 2008 SUBMODULE implementing `DO CONCURRENT`
!> column standardization and multi-step scientific checkpoint/restore.
SUBMODULE (fortran_orm_f2008) fortran_orm_f2008_ckpt
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_PTR, C_NULL_PTR, C_ASSOCIATED, &
                                          C_INT32_T
  USE fortran_orm_c, ONLY : fortran_orm_stmt_prepare, &
                            fortran_orm_stmt_bind_i32, &
                            fortran_orm_stmt_bind_f64, &
                            fortran_orm_stmt_step, &
                            fortran_orm_stmt_col_f64, &
                            fortran_orm_stmt_finalize
  IMPLICIT NONE

CONTAINS

  !> @brief Formats a positive column index into `"c<idx>"`.
  !> @param[in] idx Column number (`1..8`).
  !> @return Two-character column identifier.
  PURE FUNCTION col_tag_f08(idx) RESULT(tag)
    INTEGER(INT32), INTENT(IN) :: idx
    CHARACTER(LEN=2) :: tag
    tag(1:1) = "c"
    tag(2:2) = ACHAR(IACHAR("0") + idx)
  END FUNCTION col_tag_f08

  !> @brief Standardizes each column of `mat` to zero mean & unit variance.
  MODULE PROCEDURE corm_f2008_zscore_cols
    BLOCK
      INTEGER(INT32) :: nr, nc, r, c
      REAL(REAL64) :: mu, var_acc, sigma
      nr = INT(SIZE(mat, 1), INT32)
      nc = INT(SIZE(mat, 2), INT32)
      IF (nr <= 1_INT32 .OR. nc <= 0_INT32) RETURN
      DO c = 1_INT32, nc
        mu = SUM(mat(:, c)) / REAL(nr, REAL64)
        var_acc = SUM((mat(:, c) - mu) ** 2) / REAL(nr, REAL64)
        sigma = SQRT(var_acc)
        IF (sigma > 1.0E-14_REAL64) THEN
          DO CONCURRENT (r = 1_INT32:nr)
            mat(r, c) = (mat(r, c) - mu) / sigma
          END DO
        END IF
      END DO
    END BLOCK
  END PROCEDURE corm_f2008_zscore_cols

  !> @brief Creates `<prefix>_meta` and `<prefix>_data` checkpoint tables.
  MODULE PROCEDURE corm_f2008_ckpt_init
    BLOCK
      CHARACTER(LEN=256) :: meta_ddl, data_ddl, cols_ddl
      INTEGER(INT32) :: lp, c
      lp = INT(LEN_TRIM(prefix), INT32)
      IF (lp <= 0_INT32 .OR. lp > 32_INT32 .OR. &
          n_cols < 1_INT32 .OR. n_cols > 8_INT32) THEN
        ckpt%initialized = .FALSE.
        rc = FORTRAN_ORM_ERROR_VALIDATION
        RETURN
      END IF
      ckpt%prefix = prefix(1:lp)
      ckpt%n_cols = n_cols
      meta_ddl = "CREATE TABLE IF NOT EXISTS " // TRIM(ckpt%prefix) // &
                 "_meta(step_no INT PRIMARY KEY, sim_time REAL, l2_norm REAL)"
      rc = db%exec(TRIM(meta_ddl))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      cols_ddl = "step_no REAL, row_no REAL"
      DO c = 1_INT32, n_cols
        cols_ddl = TRIM(cols_ddl) // ", " // col_tag_f08(c) // " REAL"
      END DO
      data_ddl = "CREATE TABLE IF NOT EXISTS " // TRIM(ckpt%prefix) // &
                 "_data(" // TRIM(cols_ddl) // ")"
      rc = db%exec(TRIM(data_ddl))
      ckpt%initialized = (rc == FORTRAN_ORM_OK)
    END BLOCK
  END PROCEDURE corm_f2008_ckpt_init

  !> @brief Checkpoints `mat` and its `L2` norm at `step_no` inside a savepoint.
  MODULE PROCEDURE corm_f2008_ckpt_save
    BLOCK
      TYPE(C_PTR) :: mstmt_ptr, dstmt_ptr
      REAL(REAL64), ALLOCATABLE, DIMENSION(:, :) :: packed
      CHARACTER(LEN=256) :: del_sql, meta_sql, data_sql, qmarks
      INTEGER(C_INT32_T) :: ihas
      INTEGER(INT32) :: nr, nc, r, c, sp_rc
      out_l2 = 0.0_REAL64
      nr = INT(SIZE(mat, 1), INT32)
      nc = INT(SIZE(mat, 2), INT32)
      IF (.NOT. ckpt%initialized .OR. nr <= 0_INT32 .OR. &
          nc /= ckpt%n_cols) THEN
        rc = FORTRAN_ORM_ERROR_VALIDATION
        RETURN
      END IF
      out_l2 = SQRT(SUM(mat ** 2))
      rc = db%savepoint("f08_ckpt")
      IF (rc /= FORTRAN_ORM_OK) RETURN
      mstmt_ptr = C_NULL_PTR
      dstmt_ptr = C_NULL_PTR
      ihas = 0_C_INT32_T

      del_sql = "DELETE FROM " // TRIM(ckpt%prefix) // &
                "_data WHERE step_no = ?"
      rc = fortran_orm_stmt_prepare(db%ptr, TRIM(del_sql), &
                                    INT(LEN_TRIM(del_sql), C_INT32_T), &
                                    dstmt_ptr)
      IF (rc == FORTRAN_ORM_OK) THEN
        rc = fortran_orm_stmt_bind_f64(dstmt_ptr, 1_C_INT32_T, &
                                       REAL(step_no, REAL64))
      END IF
      IF (rc == FORTRAN_ORM_OK) THEN
        rc = fortran_orm_stmt_step(dstmt_ptr, ihas)
      END IF
      IF (C_ASSOCIATED(dstmt_ptr)) THEN
        sp_rc = fortran_orm_stmt_finalize(dstmt_ptr)
      END IF

      IF (rc == FORTRAN_ORM_OK) THEN
        meta_sql = "INSERT OR REPLACE INTO " // TRIM(ckpt%prefix) // &
                   "_meta VALUES(?,?,?)"
        rc = fortran_orm_stmt_prepare(db%ptr, TRIM(meta_sql), &
                                      INT(LEN_TRIM(meta_sql), C_INT32_T), &
                                      mstmt_ptr)
        IF (rc == FORTRAN_ORM_OK) THEN
          rc = fortran_orm_stmt_bind_i32(mstmt_ptr, 1_C_INT32_T, step_no)
        END IF
        IF (rc == FORTRAN_ORM_OK) THEN
          rc = fortran_orm_stmt_bind_f64(mstmt_ptr, 2_C_INT32_T, sim_time)
        END IF
        IF (rc == FORTRAN_ORM_OK) THEN
          rc = fortran_orm_stmt_bind_f64(mstmt_ptr, 3_C_INT32_T, out_l2)
        END IF
        IF (rc == FORTRAN_ORM_OK) THEN
          rc = fortran_orm_stmt_step(mstmt_ptr, ihas)
        END IF
        IF (C_ASSOCIATED(mstmt_ptr)) THEN
          sp_rc = fortran_orm_stmt_finalize(mstmt_ptr)
        END IF
      END IF

      IF (rc == FORTRAN_ORM_OK) THEN
        ALLOCATE(packed(nr, nc + 2_INT32))
        DO CONCURRENT (r = 1_INT32:nr)
          packed(r, 1) = REAL(step_no, REAL64)
          packed(r, 2) = REAL(r, REAL64)
        END DO
        DO CONCURRENT (c = 1_INT32:nc, r = 1_INT32:nr)
          packed(r, c + 2_INT32) = mat(r, c)
        END DO
        qmarks = "?,?"
        DO c = 1_INT32, nc
          qmarks = TRIM(qmarks) // ",?"
        END DO
        data_sql = "INSERT INTO " // TRIM(ckpt%prefix) // &
                   "_data VALUES(" // TRIM(qmarks) // ")"
        rc = corm_f2008_insert_matrix_f64(db, TRIM(data_sql), packed)
        DEALLOCATE(packed)
      END IF

      IF (rc == FORTRAN_ORM_OK) THEN
        rc = db%release_sp("f08_ckpt")
      ELSE
        sp_rc = db%rollback_sp("f08_ckpt")
        sp_rc = db%release_sp("f08_ckpt")
      END IF
    END BLOCK
  END PROCEDURE corm_f2008_ckpt_save

  !> @brief Restores checkpoint `step_no` into CONTIGUOUS `out_mat`.
  MODULE PROCEDURE corm_f2008_ckpt_load
    BLOCK
      TYPE(C_PTR) :: mstmt_ptr
      CHARACTER(LEN=256) :: meta_sql, sel_cols, data_sql
      CHARACTER(LEN=24) :: step_buf
      INTEGER(C_INT32_T) :: ihas
      INTEGER(INT32) :: nc, c, close_rc
      out_sim_time = 0.0_REAL64
      out_rows = 0_INT32
      out_mat = 0.0_REAL64
      nc = INT(SIZE(out_mat, 2), INT32)
      IF (.NOT. ckpt%initialized .OR. nc /= ckpt%n_cols) THEN
        rc = FORTRAN_ORM_ERROR_VALIDATION
        RETURN
      END IF
      mstmt_ptr = C_NULL_PTR
      ihas = 0_C_INT32_T
      meta_sql = "SELECT sim_time FROM " // TRIM(ckpt%prefix) // &
                 "_meta WHERE step_no = ?"
      rc = fortran_orm_stmt_prepare(db%ptr, TRIM(meta_sql), &
                                    INT(LEN_TRIM(meta_sql), C_INT32_T), &
                                    mstmt_ptr)
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = fortran_orm_stmt_bind_i32(mstmt_ptr, 1_C_INT32_T, step_no)
      IF (rc == FORTRAN_ORM_OK) THEN
        rc = fortran_orm_stmt_step(mstmt_ptr, ihas)
      END IF
      IF (rc == FORTRAN_ORM_OK .AND. ihas == 0_C_INT32_T) THEN
        close_rc = fortran_orm_stmt_finalize(mstmt_ptr)
        rc = FORTRAN_ORM_ERROR_NOT_FOUND
        RETURN
      END IF
      IF (rc == FORTRAN_ORM_OK) THEN
        rc = fortran_orm_stmt_col_f64(mstmt_ptr, 1_C_INT32_T, out_sim_time)
      END IF
      close_rc = fortran_orm_stmt_finalize(mstmt_ptr)
      IF (rc /= FORTRAN_ORM_OK) RETURN

      WRITE (step_buf, '(I12)') step_no
      sel_cols = col_tag_f08(1_INT32)
      DO c = 2_INT32, nc
        sel_cols = TRIM(sel_cols) // ", " // col_tag_f08(c)
      END DO
      data_sql = "SELECT " // TRIM(sel_cols) // " FROM " // &
                 TRIM(ckpt%prefix) // "_data WHERE CAST(step_no AS INT) = " // &
                 TRIM(ADJUSTL(step_buf)) // " ORDER BY row_no ASC"
      rc = corm_f2008_query_matrix_f64(db, TRIM(data_sql), out_mat, out_rows)
    END BLOCK
  END PROCEDURE corm_f2008_ckpt_load

END SUBMODULE fortran_orm_f2008_ckpt
