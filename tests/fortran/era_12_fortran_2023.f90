!> @file era_12_fortran_2023.f90
!> @brief End-to-end ISO/IEC 1539-1:2023 Fortran 2023 `F_C_STRING`, umbrella
!> module, 38-digit decimal suite, `orm_dataframe_f2023_t`, and
!> `orm_session_f2023_t` Unit-of-Work verification suite.
PROGRAM era_12_fortran_2023
  USE fortran_orm
  IMPLICIT NONE (TYPE, EXTERNAL)

  TYPE(orm_db_t) :: db
  TYPE(orm_dataframe_f2023_t) :: df, df_loaded, df_filt, df_one
  TYPE(orm_session_f2023_t) :: sess
  TYPE(fortran_orm_pool_stats) :: stats
  REAL(REAL64), DIMENSION(2, 2) :: g_in, g_out
  REAL(REAL64), DIMENSION(4) :: col_t, col_flux, col_tmp
  CHARACTER(LEN=16), DIMENSION(2) :: load_cols
  CHARACTER(LEN=:), ALLOCATABLE :: dec_str, uuid_val, cname, json_out
  REAL(REAL64) :: mu, s2, mn, mx
  INTEGER(INT32) :: rc, nrows, cmp_v

  ! 1. `F_C_STRING` connection & execution + assumed-rank mesh round-trip
  rc = corm_f2023_open(db, ":memory:   ", ASIS=.FALSE.)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_exec(db, "CREATE TABLE f23_mesh(u REAL, v REAL)   ", &
                       ASIS=.FALSE.)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  g_in = RESHAPE([1.5_REAL64, 2.5_REAL64, 3.5_REAL64, 4.5_REAL64], [2, 2])
  rc = corm_f2018_insert_any_rank(db, "INSERT INTO f23_mesh VALUES(?,?)", g_in)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  g_out = 0.0_REAL64
  rc = corm_f2018_query_any_rank(db, "SELECT u, v FROM f23_mesh", g_out, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 2_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(g_in - g_out)) > 1.0E-12_REAL64) ERROR STOP 1

  ! 2. Full 38-digit decimal canonical string suite (`add`, `sub`, `mul`, `div`, `cmp`, `rescale`)
  rc = corm_f2023_dec_add_str("bad", "0.875", dec_str)
  IF (rc == FORTRAN_ORM_OK .OR. dec_str /= "") ERROR STOP 1
  rc = corm_f2023_dec_add_str("1.0", "bad", dec_str)
  IF (rc == FORTRAN_ORM_OK .OR. dec_str /= "") ERROR STOP 1
  rc = corm_f2023_dec_add_str("99999999999999999999999999999999999999", &
                              "5", dec_str)
  IF (rc == FORTRAN_ORM_OK .OR. dec_str /= "") ERROR STOP 1
  rc = corm_f2023_dec_add_str("123456789012345678901234567890.125", &
                              "0.875", dec_str)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  IF (dec_str /= "123456789012345678901234567891.000") ERROR STOP 1

  rc = corm_f2023_dec_sub_str("bad", "1.0", dec_str)
  IF (rc == FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_sub_str("100.500", "0.250", dec_str)
  IF (rc /= FORTRAN_ORM_OK .OR. dec_str /= "100.250") ERROR STOP 1

  rc = corm_f2023_dec_mul_str("bad", "2.0", 4_INT32, &
                              FORTRAN_ORM_ROUND_HALF_EVEN, dec_str)
  IF (rc == FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_mul_str("12.25", "4.00", 4_INT32, &
                              FORTRAN_ORM_ROUND_HALF_EVEN, dec_str)
  IF (rc /= FORTRAN_ORM_OK .OR. dec_str /= "49.0000") ERROR STOP 1

  rc = corm_f2023_dec_div_str("1.0", "0", 4_INT32, &
                              FORTRAN_ORM_ROUND_HALF_EVEN, dec_str)
  IF (rc == FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_div_str("10.0", "4.0", 3_INT32, &
                              FORTRAN_ORM_ROUND_HALF_EVEN, dec_str)
  IF (rc /= FORTRAN_ORM_OK .OR. dec_str /= "2.500") ERROR STOP 1

  rc = corm_f2023_dec_cmp_str("bad", "1.0", cmp_v)
  IF (rc == FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_cmp_str("2.500", "2.5", cmp_v)
  IF (rc /= FORTRAN_ORM_OK .OR. cmp_v /= 0_INT32) ERROR STOP 1

  rc = corm_f2023_dec_rescale_str("bad", 10_INT32, 2_INT32, &
                                  FORTRAN_ORM_ROUND_HALF_EVEN, dec_str)
  IF (rc == FORTRAN_ORM_OK) ERROR STOP 1
  rc = corm_f2023_dec_rescale_str("3.14159", 10_INT32, 2_INT32, &
                                  FORTRAN_ORM_ROUND_HALF_EVEN, dec_str)
  IF (rc /= FORTRAN_ORM_OK .OR. dec_str /= "3.14") ERROR STOP 1

  ! 3. `orm_dataframe_f2023_t` scientific DataFrame + stats + filter + SQL/JSON
  rc = df%init(0_INT32, 2_INT32)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%set_col_name(1_INT32, "bad")
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%get_col_name(1_INT32, cname)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1

  rc = df%init(4_INT32, 2_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df%set_col_name(1_INT32, "bjd_day")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df%set_col_name(2_INT32, "norm_flux")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df%get_col_name(2_INT32, cname)
  IF (rc /= FORTRAN_ORM_OK .OR. cname /= "norm_flux") ERROR STOP 1

  col_t = [1.0_REAL64, 2.0_REAL64, 3.0_REAL64, 4.0_REAL64]
  col_flux = [10.0_REAL64, 20.0_REAL64, 30.0_REAL64, 40.0_REAL64]
  rc = df%set_col(1_INT32, col_t)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df%set_col(2_INT32, col_flux)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df%get_col(2_INT32, col_tmp)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  IF (MAXVAL(ABS(col_tmp - col_flux)) > 1.0E-12_REAL64) ERROR STOP 1

  rc = df%col_mean(2_INT32, mu)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(mu - 25.0_REAL64) > 1.0E-12_REAL64) THEN
    ERROR STOP 1
  END IF
  rc = df%col_variance(2_INT32, s2)
  IF (rc /= FORTRAN_ORM_OK .OR. &
      ABS(s2 - 500.0_REAL64 / 3.0_REAL64) > 1.0E-10_REAL64) ERROR STOP 1
  rc = df%col_min_max(2_INT32, mn, mx)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(mn - 10.0_REAL64) > 1.0E-12_REAL64 .OR. &
      ABS(mx - 40.0_REAL64) > 1.0E-12_REAL64) ERROR STOP 1

  rc = df_one%init(1_INT32, 1_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df_one%col_variance(1_INT32, s2)
  IF (rc /= FORTRAN_ORM_OK .OR. ABS(s2) > 1.0E-12_REAL64) ERROR STOP 1
  rc = df_one%free()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = df%filter_gt(2_INT32, 22.0_REAL64, df_filt)
  IF (rc /= FORTRAN_ORM_OK .OR. df_filt%n_rows /= 2_INT32) ERROR STOP 1
  rc = df%filter_gt(2_INT32, 999.0_REAL64, df_one)
  IF (rc /= FORTRAN_ORM_OK .OR. df_one%n_rows /= 0_INT32) ERROR STOP 1

  rc = df%save_sql(db, "transit_df23")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  load_cols(1) = "bjd_day"
  load_cols(2) = "norm_flux"
  rc = df_loaded%load_sql(db, "transit_df23", 4_INT32, load_cols, nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 4_INT32) ERROR STOP 1
  IF (MAXVAL(ABS(df_loaded%data - df%data)) > 1.0E-12_REAL64) ERROR STOP 1

  rc = df%to_json_sql(db, "transit_df23", json_out)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_out, "norm_flux") == 0) ERROR STOP 1
  rc = df%set_col(99_INT32, col_tmp)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%get_col(99_INT32, col_tmp)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%col_mean(99_INT32, mu)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%col_min_max(99_INT32, mn, mx)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%filter_gt(99_INT32, 0.0_REAL64, df_filt)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%save_sql(db, " ")
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df_loaded%load_sql(db, " ", 4_INT32, load_cols, nrows)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = df%to_json_sql(db, " ", json_out)
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1

  ! 4. `orm_session_f2023_t` Unit-of-Work nested savepoints & telemetry
  rc = sess%open(":memory:", 4_INT32)
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%commit_uow("none")
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1
  rc = sess%rollback_uow("none")
  IF (rc /= FORTRAN_ORM_ERROR_VALIDATION) ERROR STOP 1

  rc = sess%exec("CREATE TABLE uow23(v INT)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%begin_uow("root")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%exec("INSERT INTO uow23 VALUES(1)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%begin_uow("sp_inner")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%exec("INSERT INTO uow23 VALUES(2)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%rollback_uow("sp_inner")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%begin_uow("sp_keep")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%exec("INSERT INTO uow23 VALUES(3)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%commit_uow("sp_keep")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%commit_uow("root")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = sess%begin_uow("aborted_tx")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%exec("INSERT INTO uow23 VALUES(99)")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%rollback_uow("aborted_tx")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%begin_uow("unclosed_tx")
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = sess%telemetry(stats)
  IF (rc /= FORTRAN_ORM_OK .OR. sess%exec_count < 4_INT32) ERROR STOP 1
  rc = sess%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1

  rc = corm_f2003_uuid_v4(uuid_val)
  IF (rc /= FORTRAN_ORM_OK .OR. LEN(uuid_val) /= 36) ERROR STOP 1

  rc = df_filt%free()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df_loaded%free()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = df%free()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) ERROR STOP 1
  PRINT '(A)', "PASS: Fortran 2023"
END PROGRAM era_12_fortran_2023
