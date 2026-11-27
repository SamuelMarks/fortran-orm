!> @file fortran_orm_f2023.f90
!> @module fortran_orm_f2023
!> @brief ISO/IEC 1539-1:2023 Fortran 2023 ORM module.
!>
!> Showcases authentic Fortran 2023 `ISO_C_BINDING` enhancements (`F_C_STRING`
!> intrinsic with `ASIS` blank-preservation control), full 38-digit base-10
!> canonical decimal string arithmetic, OOP scientific columnar DataFrames
!> (`orm_dataframe_f2023_t`), and nested Unit-of-Work sessions
!> (`orm_session_f2023_t`).
MODULE fortran_orm_f2023
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_INT, C_INT32_T, F_C_STRING
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, INT64, REAL64
  USE fortran_orm_c, ONLY : fortran_orm_connect_cstr, fortran_orm_exec_cstr, &
                            fortran_orm_decimal, fortran_orm_pool_stats, &
                            fortran_orm_dec_from_str, fortran_orm_dec_to_str, &
                            fortran_orm_dec_add, fortran_orm_dec_sub, &
                            fortran_orm_dec_mul, fortran_orm_dec_div, &
                            fortran_orm_dec_cmp, fortran_orm_dec_rescale, &
                            FORTRAN_ORM_ERROR_VALIDATION, &
                            FORTRAN_ORM_ROUND_HALF_EVEN
  USE fortran_orm_f2003, ONLY : orm_db_t, orm_stmt_t, orm_ast_t, orm_rs_t, &
                                orm_pool_t, orm_schema_t, FORTRAN_ORM_OK, &
                                corm_f2003_uuid_v4, corm_f2003_version
  USE fortran_orm_f2018, ONLY : corm_f2018_insert_any_rank, &
                                corm_f2018_query_any_rank
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE

  PUBLIC :: INT32, INT64, REAL64, FORTRAN_ORM_OK, FORTRAN_ORM_ERROR_VALIDATION
  PUBLIC :: FORTRAN_ORM_ROUND_HALF_EVEN
  PUBLIC :: orm_db_t, orm_stmt_t, orm_ast_t, orm_rs_t, orm_pool_t, orm_schema_t
  PUBLIC :: fortran_orm_decimal, fortran_orm_pool_stats
  PUBLIC :: corm_f2023_open, corm_f2023_exec
  PUBLIC :: corm_f2023_dec_add_str, corm_f2023_dec_sub_str
  PUBLIC :: corm_f2023_dec_mul_str, corm_f2023_dec_div_str
  PUBLIC :: corm_f2023_dec_cmp_str, corm_f2023_dec_rescale_str
  PUBLIC :: corm_f2018_insert_any_rank, corm_f2018_query_any_rank
  PUBLIC :: corm_f2003_uuid_v4, corm_f2003_version

  !> @type orm_dataframe_f2023_t
  !> @brief Column-major Fortran 2023 scientific DataFrame backed by SQL & JSON.
  TYPE, PUBLIC :: orm_dataframe_f2023_t
    INTEGER(INT32) :: n_rows = 0_INT32
    INTEGER(INT32) :: n_cols = 0_INT32
    CHARACTER(LEN=32), ALLOCATABLE, DIMENSION(:) :: col_names
    REAL(REAL64), ALLOCATABLE, DIMENSION(:, :) :: data
  CONTAINS
    PROCEDURE :: init => df_init_m
    PROCEDURE :: set_col_name => df_set_col_name_m
    PROCEDURE :: get_col_name => df_get_col_name_m
    PROCEDURE :: set_col => df_set_col_m
    PROCEDURE :: get_col => df_get_col_m
    PROCEDURE :: col_mean => df_col_mean_m
    PROCEDURE :: col_variance => df_col_variance_m
    PROCEDURE :: col_min_max => df_col_min_max_m
    PROCEDURE :: filter_gt => df_filter_gt_m
    PROCEDURE :: save_sql => df_save_sql_m
    PROCEDURE :: load_sql => df_load_sql_m
    PROCEDURE :: to_json_sql => df_to_json_sql_m
    PROCEDURE :: free => df_free_m
  END TYPE orm_dataframe_f2023_t

  !> @type orm_session_f2023_t
  !> @brief Fortran 2023 Unit-of-Work database session with nested savepoints.
  TYPE, PUBLIC :: orm_session_f2023_t
    TYPE(orm_db_t) :: db
    INTEGER(INT32) :: tx_depth = 0_INT32
    INTEGER(INT32) :: exec_count = 0_INT32
  CONTAINS
    PROCEDURE :: open => sess_open_m
    PROCEDURE :: exec => sess_exec_m
    PROCEDURE :: begin_uow => sess_begin_uow_m
    PROCEDURE :: commit_uow => sess_commit_uow_m
    PROCEDURE :: rollback_uow => sess_rollback_uow_m
    PROCEDURE :: telemetry => sess_telemetry_m
    PROCEDURE :: close => sess_close_m
  END TYPE orm_session_f2023_t

CONTAINS

  !> @brief Formats `dec` into an allocatable canonical base-10 string.
  !> @param[in] dec Decimal POD value.
  !> @param[out] out_str Allocatable formatted decimal string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_pod_to_alloc(dec, out_str) RESULT(rc)
    TYPE(fortran_orm_decimal), INTENT(IN) :: dec
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=64) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_str = ""
    rc = fortran_orm_dec_to_str(dec, buf, 64_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    END IF
  END FUNCTION dec_pod_to_alloc

  !> @brief Connects `db` using the Fortran 2023 `F_C_STRING` intrinsic.
  !> @param[inout] db RAII database connection object.
  !> @param[in] url Connection URL string.
  !> @param[in] asis Optional flag preserving trailing blanks when `.TRUE.`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_open(db, url, asis) RESULT(rc)
    CLASS(orm_db_t), INTENT(INOUT) :: db
    CHARACTER(LEN=*), INTENT(IN) :: url
    LOGICAL, INTENT(IN), OPTIONAL :: asis
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    LOGICAL :: keep_blanks
    keep_blanks = .FALSE.
    IF (PRESENT(asis)) keep_blanks = asis
    prev_rc = db%close()
    rc = fortran_orm_connect_cstr(F_C_STRING(url, ASIS=keep_blanks), db%ptr)
  END FUNCTION corm_f2023_open

  !> @brief Executes SQL on `db` using Fortran 2023 `F_C_STRING`.
  !> @param[in] db Active RAII database connection object.
  !> @param[in] sql SQL DDL or DML text.
  !> @param[in] asis Optional flag preserving trailing blanks when `.TRUE.`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_exec(db, sql, asis) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    LOGICAL, INTENT(IN), OPTIONAL :: asis
    INTEGER(C_INT) :: rc
    LOGICAL :: keep_blanks
    keep_blanks = .FALSE.
    IF (PRESENT(asis)) keep_blanks = asis
    rc = fortran_orm_exec_cstr(db%ptr, F_C_STRING(sql, ASIS=keep_blanks))
  END FUNCTION corm_f2023_exec

  !> @brief Exact 38-digit base-10 decimal addition returning allocatable text.
  !> @param[in] lhs_str Left base-10 decimal string.
  !> @param[in] rhs_str Right base-10 decimal string.
  !> @param[out] sum_str Allocatable canonical decimal sum string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_dec_add_str(lhs_str, rhs_str, sum_str) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: lhs_str, rhs_str
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: sum_str
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_decimal) :: da, db, ds
    sum_str = ""
    rc = fortran_orm_dec_from_str(lhs_str, INT(LEN(lhs_str), C_INT32_T), da)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_from_str(rhs_str, INT(LEN(rhs_str), C_INT32_T), db)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_add(da, db, ds)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = dec_pod_to_alloc(ds, sum_str)
  END FUNCTION corm_f2023_dec_add_str

  !> @brief Exact 38-digit base-10 decimal subtraction (`lhs_str - rhs_str`).
  !> @param[in] lhs_str Minuend decimal string.
  !> @param[in] rhs_str Subtrahend decimal string.
  !> @param[out] diff_str Allocatable canonical difference string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_dec_sub_str(lhs_str, rhs_str, diff_str) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: lhs_str, rhs_str
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: diff_str
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_decimal) :: da, db, dd
    diff_str = ""
    rc = fortran_orm_dec_from_str(lhs_str, INT(LEN(lhs_str), C_INT32_T), da)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_from_str(rhs_str, INT(LEN(rhs_str), C_INT32_T), db)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_sub(da, db, dd)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = dec_pod_to_alloc(dd, diff_str)
  END FUNCTION corm_f2023_dec_sub_str

  !> @brief Exact 38-digit decimal multiplication (`lhs_str * rhs_str`).
  !> @param[in] lhs_str Multiplicand decimal string.
  !> @param[in] rhs_str Multiplier decimal string.
  !> @param[in] max_scale Maximum fractional scale (`0..38`).
  !> @param[in] round_mode Rounding mode (`FORTRAN_ORM_ROUND_*`).
  !> @param[out] prod_str Allocatable canonical product string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_dec_mul_str(lhs_str, rhs_str, max_scale, round_mode, &
                                  prod_str) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: lhs_str, rhs_str
    INTEGER(INT32), INTENT(IN) :: max_scale
    INTEGER(C_INT), INTENT(IN) :: round_mode
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: prod_str
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_decimal) :: da, db, dp
    prod_str = ""
    rc = fortran_orm_dec_from_str(lhs_str, INT(LEN(lhs_str), C_INT32_T), da)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_from_str(rhs_str, INT(LEN(rhs_str), C_INT32_T), db)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_mul(da, db, max_scale, round_mode, dp)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = dec_pod_to_alloc(dp, prod_str)
  END FUNCTION corm_f2023_dec_mul_str

  !> @brief Exact 38-digit decimal division (`lhs_str / rhs_str`).
  !> @param[in] lhs_str Dividend decimal string.
  !> @param[in] rhs_str Divisor decimal string.
  !> @param[in] res_scale Target fractional scale (`0..38`).
  !> @param[in] round_mode Remainder rounding mode.
  !> @param[out] quot_str Allocatable canonical quotient string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_dec_div_str(lhs_str, rhs_str, res_scale, round_mode, &
                                  quot_str) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: lhs_str, rhs_str
    INTEGER(INT32), INTENT(IN) :: res_scale
    INTEGER(C_INT), INTENT(IN) :: round_mode
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: quot_str
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_decimal) :: da, db, dq
    quot_str = ""
    rc = fortran_orm_dec_from_str(lhs_str, INT(LEN(lhs_str), C_INT32_T), da)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_from_str(rhs_str, INT(LEN(rhs_str), C_INT32_T), db)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_div(da, db, res_scale, round_mode, dq)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = dec_pod_to_alloc(dq, quot_str)
  END FUNCTION corm_f2023_dec_div_str

  !> @brief Numerically compares two base-10 decimal strings (`-1`, `0`, `+1`).
  !> @param[in] lhs_str Left decimal string.
  !> @param[in] rhs_str Right decimal string.
  !> @param[out] cmp_out Receives `-1`, `0`, or `+1`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_dec_cmp_str(lhs_str, rhs_str, cmp_out) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: lhs_str, rhs_str
    INTEGER(INT32), INTENT(OUT) :: cmp_out
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_decimal) :: da, db
    cmp_out = 0_INT32
    rc = fortran_orm_dec_from_str(lhs_str, INT(LEN(lhs_str), C_INT32_T), da)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_from_str(rhs_str, INT(LEN(rhs_str), C_INT32_T), db)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_cmp(da, db, cmp_out)
  END FUNCTION corm_f2023_dec_cmp_str

  !> @brief Rescales `src_str` to `(prec, scale)` under `round_mode`.
  !> @param[in] src_str Input decimal string.
  !> @param[in] prec Maximum precision (`1..38`).
  !> @param[in] scale Target fractional scale (`0..prec`).
  !> @param[in] round_mode Rounding mode.
  !> @param[out] out_str Allocatable rescaled canonical string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2023_dec_rescale_str(src_str, prec, scale, round_mode, &
                                      out_str) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: src_str
    INTEGER(INT32), INTENT(IN) :: prec, scale
    INTEGER(C_INT), INTENT(IN) :: round_mode
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_decimal) :: da, dr
    out_str = ""
    rc = fortran_orm_dec_from_str(src_str, INT(LEN(src_str), C_INT32_T), da)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = fortran_orm_dec_rescale(da, prec, scale, round_mode, dr)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = dec_pod_to_alloc(dr, out_str)
  END FUNCTION corm_f2023_dec_rescale_str

  !> @brief Allocates and initializes a `(n_rows, n_cols)` DataFrame.
  !> @param[inout] self DataFrame object.
  !> @param[in] n_rows Row count (`>= 1`).
  !> @param[in] n_cols Column count (`1..16`).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_init_m(self, n_rows, n_cols) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(INOUT) :: self
    INTEGER(INT32), INTENT(IN) :: n_rows, n_cols
    INTEGER(C_INT) :: rc
    INTEGER(INT32) :: c, frc
    IF (n_rows < 1_INT32 .OR. n_cols < 1_INT32 .OR. n_cols > 16_INT32) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    frc = self%free()
    self%n_rows = n_rows
    self%n_cols = n_cols
    ALLOCATE(self%col_names(n_cols))
    ALLOCATE(self%data(n_rows, n_cols))
    self%data = 0.0_REAL64
    DO c = 1_INT32, n_cols
      WRITE (self%col_names(c), '("col_",I0)') c
    END DO
    rc = FORTRAN_ORM_OK
  END FUNCTION df_init_m

  !> @brief Assigns SQL column identifier `name_str` to 1-based `col_idx`.
  !> @param[inout] self DataFrame object.
  !> @param[in] col_idx 1-based column index.
  !> @param[in] name_str Non-empty SQL column identifier.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_set_col_name_m(self, col_idx, name_str) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(INOUT) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    CHARACTER(LEN=*), INTENT(IN) :: name_str
    INTEGER(C_INT) :: rc
    IF (.NOT. ALLOCATED(self%col_names) .OR. col_idx < 1_INT32 .OR. &
        col_idx > self%n_cols .OR. LEN_TRIM(name_str) == 0) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    self%col_names(col_idx) = TRIM(name_str)
    rc = FORTRAN_ORM_OK
  END FUNCTION df_set_col_name_m

  !> @brief Retrieves the trimmed name of 1-based `col_idx`.
  !> @param[in] self DataFrame object.
  !> @param[in] col_idx 1-based column index.
  !> @param[out] name_out Allocatable column name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_get_col_name_m(self, col_idx, name_out) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: name_out
    INTEGER(C_INT) :: rc
    IF (.NOT. ALLOCATED(self%col_names) .OR. col_idx < 1_INT32 .OR. &
        col_idx > self%n_cols) THEN
      name_out = ""
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    name_out = TRIM(self%col_names(col_idx))
    rc = FORTRAN_ORM_OK
  END FUNCTION df_get_col_name_m

  !> @brief Copies 1D vector `values` into 1-based column `col_idx`.
  !> @param[inout] self DataFrame object.
  !> @param[in] col_idx 1-based column index.
  !> @param[in] values Vector of length `self%n_rows`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_set_col_m(self, col_idx, values) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(INOUT) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    REAL(REAL64), DIMENSION(:), INTENT(IN) :: values
    INTEGER(C_INT) :: rc
    IF (.NOT. ALLOCATED(self%data) .OR. col_idx < 1_INT32 .OR. &
        col_idx > self%n_cols .OR. SIZE(values, 1) /= self%n_rows) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    self%data(:, col_idx) = values
    rc = FORTRAN_ORM_OK
  END FUNCTION df_set_col_m

  !> @brief Extracts 1-based column `col_idx` into `out_values`.
  !> @param[in] self DataFrame object.
  !> @param[in] col_idx 1-based column index.
  !> @param[out] out_values Destination vector of length `self%n_rows`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_get_col_m(self, col_idx, out_values) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    REAL(REAL64), DIMENSION(:), INTENT(OUT) :: out_values
    INTEGER(C_INT) :: rc
    out_values = 0.0_REAL64
    IF (.NOT. ALLOCATED(self%data) .OR. col_idx < 1_INT32 .OR. &
        col_idx > self%n_cols .OR. SIZE(out_values, 1) /= self%n_rows) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    out_values = self%data(:, col_idx)
    rc = FORTRAN_ORM_OK
  END FUNCTION df_get_col_m

  !> @brief Computes arithmetic mean of 1-based column `col_idx`.
  !> @param[in] self DataFrame object.
  !> @param[in] col_idx 1-based column index.
  !> @param[out] mean_out Receives arithmetic mean.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_col_mean_m(self, col_idx, mean_out) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    REAL(REAL64), INTENT(OUT) :: mean_out
    INTEGER(C_INT) :: rc
    mean_out = 0.0_REAL64
    IF (.NOT. ALLOCATED(self%data) .OR. col_idx < 1_INT32 .OR. &
        col_idx > self%n_cols) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    mean_out = SUM(self%data(:, col_idx)) / REAL(self%n_rows, REAL64)
    rc = FORTRAN_ORM_OK
  END FUNCTION df_col_mean_m

  !> @brief Computes unbiased sample variance of 1-based column `col_idx`.
  !> @param[in] self DataFrame object.
  !> @param[in] col_idx 1-based column index.
  !> @param[out] var_out Receives sample variance (`0.0` if `n_rows == 1`).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_col_variance_m(self, col_idx, var_out) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    REAL(REAL64), INTENT(OUT) :: var_out
    INTEGER(C_INT) :: rc
    REAL(REAL64) :: mu
    var_out = 0.0_REAL64
    rc = self%col_mean(col_idx, mu)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    IF (self%n_rows > 1_INT32) THEN
      var_out = SUM((self%data(:, col_idx) - mu) ** 2) / &
                REAL(self%n_rows - 1_INT32, REAL64)
    END IF
  END FUNCTION df_col_variance_m

  !> @brief Computes minimum and maximum of 1-based column `col_idx`.
  !> @param[in] self DataFrame object.
  !> @param[in] col_idx 1-based column index.
  !> @param[out] min_out Receives column minimum.
  !> @param[out] max_out Receives column maximum.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_col_min_max_m(self, col_idx, min_out, max_out) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    REAL(REAL64), INTENT(OUT) :: min_out, max_out
    INTEGER(C_INT) :: rc
    min_out = 0.0_REAL64
    max_out = 0.0_REAL64
    IF (.NOT. ALLOCATED(self%data) .OR. col_idx < 1_INT32 .OR. &
        col_idx > self%n_cols) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    min_out = MINVAL(self%data(:, col_idx))
    max_out = MAXVAL(self%data(:, col_idx))
    rc = FORTRAN_ORM_OK
  END FUNCTION df_col_min_max_m

  !> @brief Filters rows where column `col_idx > threshold` into `out_df`.
  !> @param[in] self Source DataFrame object.
  !> @param[in] col_idx 1-based predicate column index.
  !> @param[in] threshold Strict lower bound.
  !> @param[out] out_df Filtered DataFrame object.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_filter_gt_m(self, col_idx, threshold, out_df) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    INTEGER(INT32), INTENT(IN) :: col_idx
    REAL(REAL64), INTENT(IN) :: threshold
    TYPE(orm_dataframe_f2023_t), INTENT(OUT) :: out_df
    INTEGER(C_INT) :: rc
    INTEGER(INT32) :: r, k, hit_count
    IF (.NOT. ALLOCATED(self%data) .OR. col_idx < 1_INT32 .OR. &
        col_idx > self%n_cols) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    hit_count = COUNT(self%data(:, col_idx) > threshold)
    IF (hit_count <= 0_INT32) THEN
      rc = FORTRAN_ORM_OK
      RETURN
    END IF
    rc = out_df%init(hit_count, self%n_cols)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    out_df%col_names = self%col_names
    k = 0_INT32
    DO r = 1_INT32, self%n_rows
      IF (self%data(r, col_idx) > threshold) THEN
        k = k + 1_INT32
        out_df%data(k, :) = self%data(r, :)
      END IF
    END DO
  END FUNCTION df_filter_gt_m

  !> @brief Creates/replaces SQL table `table_name` and persists `self`.
  !> @param[in] self DataFrame object.
  !> @param[in] db Active database connection.
  !> @param[in] table_name Target SQL table name.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_save_sql_m(self, db, table_name) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512) :: drop_sql, create_sql, ins_sql, cols_ddl, qmarks
    INTEGER(INT32) :: c
    IF (.NOT. ALLOCATED(self%data) .OR. LEN_TRIM(table_name) == 0) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    drop_sql = "DROP TABLE IF EXISTS " // TRIM(table_name)
    rc = corm_f2023_exec(db, TRIM(drop_sql))
    IF (rc /= FORTRAN_ORM_OK) RETURN
    cols_ddl = TRIM(self%col_names(1)) // " REAL NOT NULL"
    qmarks = "?"
    DO c = 2_INT32, self%n_cols
      cols_ddl = TRIM(cols_ddl) // ", " // TRIM(self%col_names(c)) // &
                 " REAL NOT NULL"
      qmarks = TRIM(qmarks) // ",?"
    END DO
    create_sql = "CREATE TABLE " // TRIM(table_name) // "(" // &
                 TRIM(cols_ddl) // ")"
    rc = corm_f2023_exec(db, TRIM(create_sql))
    IF (rc /= FORTRAN_ORM_OK) RETURN
    ins_sql = "INSERT INTO " // TRIM(table_name) // " VALUES(" // &
              TRIM(qmarks) // ")"
    rc = corm_f2018_insert_any_rank(db, TRIM(ins_sql), self%data)
  END FUNCTION df_save_sql_m

  !> @brief Initializes `self` and hydrates `(n_rows, SIZE(col_names))` from SQL.
  !> @param[inout] self DataFrame object.
  !> @param[in] db Active database connection.
  !> @param[in] table_name Source SQL table name.
  !> @param[in] n_rows Expected row capacity (`>= 1`).
  !> @param[in] col_names Array of SQL column names to select.
  !> @param[out] out_rows Actual number of rows hydrated.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_load_sql_m(self, db, table_name, n_rows, col_names, out_rows) &
      RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(INT32), INTENT(IN) :: n_rows
    CHARACTER(LEN=*), DIMENSION(:), INTENT(IN) :: col_names
    INTEGER(INT32), INTENT(OUT) :: out_rows
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512) :: sel_cols, sel_sql
    INTEGER(INT32) :: nc, c
    out_rows = 0_INT32
    nc = INT(SIZE(col_names, 1), INT32)
    IF (LEN_TRIM(table_name) == 0 .OR. nc < 1_INT32) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    rc = self%init(n_rows, nc)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    sel_cols = TRIM(col_names(1))
    rc = self%set_col_name(1_INT32, col_names(1))
    IF (rc /= FORTRAN_ORM_OK) RETURN
    DO c = 2_INT32, nc
      rc = self%set_col_name(c, col_names(c))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      sel_cols = TRIM(sel_cols) // ", " // TRIM(col_names(c))
    END DO
    sel_sql = "SELECT " // TRIM(sel_cols) // " FROM " // TRIM(table_name)
    rc = corm_f2018_query_any_rank(db, TRIM(sel_sql), self%data, out_rows)
  END FUNCTION df_load_sql_m

  !> @brief Exports persisted SQL table `table_name` of `self` to JSON text.
  !> @param[in] self DataFrame object.
  !> @param[in] db Active database connection.
  !> @param[in] table_name Persisted SQL table name.
  !> @param[out] json_out Allocatable JSON array string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION df_to_json_sql_m(self, db, table_name, json_out) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(IN) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: json_out
    INTEGER(C_INT) :: rc
    TYPE(orm_rs_t) :: rs
    CHARACTER(LEN=512) :: sel_cols, sel_sql
    INTEGER(INT32) :: c, frc
    json_out = ""
    IF (.NOT. ALLOCATED(self%col_names) .OR. LEN_TRIM(table_name) == 0) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    sel_cols = TRIM(self%col_names(1))
    DO c = 2_INT32, self%n_cols
      sel_cols = TRIM(sel_cols) // ", " // TRIM(self%col_names(c))
    END DO
    sel_sql = "SELECT " // TRIM(sel_cols) // " FROM " // TRIM(table_name)
    rc = rs%query(db, TRIM(sel_sql))
    IF (rc == FORTRAN_ORM_OK) rc = rs%to_json(json_out)
    frc = rs%free()
  END FUNCTION df_to_json_sql_m

  !> @brief Deallocates internal storage of `self`.
  !> @param[inout] self DataFrame object.
  !> @return `FORTRAN_ORM_OK`.
  FUNCTION df_free_m(self) RESULT(rc)
    CLASS(orm_dataframe_f2023_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (ALLOCATED(self%col_names)) DEALLOCATE(self%col_names)
    IF (ALLOCATED(self%data)) DEALLOCATE(self%data)
    self%n_rows = 0_INT32
    self%n_cols = 0_INT32
    rc = FORTRAN_ORM_OK
  END FUNCTION df_free_m

  !> @brief Opens Unit-of-Work session `self` with LRU statement cache.
  !> @param[inout] self Session object.
  !> @param[in] url Connection URL string.
  !> @param[in] cache_cap Statement cache capacity (`>= 0`).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION sess_open_m(self, url, cache_cap) RESULT(rc)
    CLASS(orm_session_f2023_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: url
    INTEGER(INT32), INTENT(IN) :: cache_cap
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    prev_rc = self%close()
    rc = corm_f2023_open(self%db, url)
    IF (rc == FORTRAN_ORM_OK .AND. cache_cap > 0_INT32) THEN
      rc = self%db%enable_cache(cache_cap)
    END IF
    self%tx_depth = 0_INT32
    self%exec_count = 0_INT32
  END FUNCTION sess_open_m

  !> @brief Executes SQL via `F_C_STRING` and increments session counter.
  !> @param[inout] self Session object.
  !> @param[in] sql SQL DDL or DML statement.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION sess_exec_m(self, sql) RESULT(rc)
    CLASS(orm_session_f2023_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT) :: rc
    rc = corm_f2023_exec(self%db, sql)
    IF (rc == FORTRAN_ORM_OK) self%exec_count = self%exec_count + 1_INT32
  END FUNCTION sess_exec_m

  !> @brief Enters a top-level transaction or nested savepoint `sp_name`.
  !> @param[inout] self Session object.
  !> @param[in] sp_name Savepoint name used when `tx_depth >= 1`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION sess_begin_uow_m(self, sp_name) RESULT(rc)
    CLASS(orm_session_f2023_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER(C_INT) :: rc
    IF (self%tx_depth == 0_INT32) THEN
      rc = self%db%tx_begin()
    ELSE
      rc = self%db%savepoint(sp_name)
    END IF
    IF (rc == FORTRAN_ORM_OK) self%tx_depth = self%tx_depth + 1_INT32
  END FUNCTION sess_begin_uow_m

  !> @brief Commits top-level Unit-of-Work or releases nested savepoint `sp_name`.
  !> @param[inout] self Session object.
  !> @param[in] sp_name Savepoint name used when `tx_depth >= 2`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION sess_commit_uow_m(self, sp_name) RESULT(rc)
    CLASS(orm_session_f2023_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER(C_INT) :: rc
    IF (self%tx_depth <= 0_INT32) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    IF (self%tx_depth == 1_INT32) THEN
      rc = self%db%tx_commit()
    ELSE
      rc = self%db%release_sp(sp_name)
    END IF
    IF (rc == FORTRAN_ORM_OK) self%tx_depth = self%tx_depth - 1_INT32
  END FUNCTION sess_commit_uow_m

  !> @brief Rolls back top-level Unit-of-Work or nested savepoint `sp_name`.
  !> @param[inout] self Session object.
  !> @param[in] sp_name Savepoint name used when `tx_depth >= 2`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION sess_rollback_uow_m(self, sp_name) RESULT(rc)
    CLASS(orm_session_f2023_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: rel_rc
    IF (self%tx_depth <= 0_INT32) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    IF (self%tx_depth == 1_INT32) THEN
      rc = self%db%tx_rollback()
    ELSE
      rc = self%db%rollback_sp(sp_name)
      rel_rc = self%db%release_sp(sp_name)
      IF (rc == FORTRAN_ORM_OK) rc = rel_rc
    END IF
    self%tx_depth = self%tx_depth - 1_INT32
  END FUNCTION sess_rollback_uow_m

  !> @brief Snapshots connection telemetry counters on `self`.
  !> @param[in] self Session object.
  !> @param[out] stats Telemetry POD snapshot.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION sess_telemetry_m(self, stats) RESULT(rc)
    CLASS(orm_session_f2023_t), INTENT(IN) :: self
    TYPE(fortran_orm_pool_stats), INTENT(OUT) :: stats
    INTEGER(C_INT) :: rc
    rc = self%db%telemetry(stats)
  END FUNCTION sess_telemetry_m

  !> @brief Rolls back any uncommitted work and closes `self`.
  !> @param[inout] self Session object.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION sess_close_m(self) RESULT(rc)
    CLASS(orm_session_f2023_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: rb_rc
    IF (self%tx_depth > 0_INT32 .AND. self%db%is_open()) THEN
      rb_rc = self%db%tx_rollback()
    END IF
    self%tx_depth = 0_INT32
    rc = self%db%close()
  END FUNCTION sess_close_m

END MODULE fortran_orm_f2023
