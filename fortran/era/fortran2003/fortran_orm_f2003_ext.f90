!> @file fortran_orm_f2003_ext.f90
!> @module fortran_orm_f2003_ext
!> @brief Advanced ISO/IEC 1539-1:2004 Fortran 2003 OOP abstractions:
!> - `orm_tx_guard_t`: RAII scoped transaction & savepoint rollback guard
!> - `orm_decimal_t`: OOP 38-digit fixed-point decimal value class
!> - `orm_migration_t`: RAII versioned `-- UP` / `-- DOWN` migration runner
!> - `orm_shard_router_t`: RAII deterministic horizontal shard router
!> - `orm_oauth2_store_t`: OOP OAuth2 bearer-token & scope repository
!> - `orm_model_base_t`: `ABSTRACT` polymorphic ActiveRecord base class
!> - Enterprise EBCDIC, UTF-16 `GRAPHIC`, and unpacked `A1` codecs
MODULE fortran_orm_f2003_ext
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_c
  USE fortran_orm_f2003
  IMPLICIT NONE
  PRIVATE

  !> @type orm_tx_guard_t
  !> @brief RAII transaction / savepoint guard that automatically rolls back
  !> on scope exit unless `%commit()` was called.
  TYPE, PUBLIC :: orm_tx_guard_t
    TYPE(C_PTR) :: db_ptr = C_NULL_PTR
    CHARACTER(LEN=64) :: sp_name = ""
    INTEGER(C_INT32_T) :: sp_len = 0_C_INT32_T
    LOGICAL :: active = .FALSE.
    LOGICAL :: use_savepoint = .FALSE.
  CONTAINS
    PROCEDURE :: begin => tx_guard_begin
    PROCEDURE :: begin_sp => tx_guard_begin_sp
    PROCEDURE :: commit => tx_guard_commit
    PROCEDURE :: rollback => tx_guard_rollback
    FINAL :: tx_guard_finalize_raii
  END TYPE orm_tx_guard_t

  !> @type orm_decimal_t
  !> @brief OOP 38-digit base-10 fixed-point decimal wrapper class.
  TYPE, PUBLIC :: orm_decimal_t
    TYPE(fortran_orm_decimal) :: pod
  CONTAINS
    PROCEDURE :: from_str => dec_from_str_m
    PROCEDURE :: to_str => dec_to_str_m
    PROCEDURE :: from_i64 => dec_from_i64_m
    PROCEDURE :: to_i64 => dec_to_i64_m
    PROCEDURE :: add => dec_add_m
    PROCEDURE :: sub => dec_sub_m
    PROCEDURE :: mul => dec_mul_m
    PROCEDURE :: div => dec_div_m
    PROCEDURE :: cmp => dec_cmp_m
    PROCEDURE :: rescale => dec_rescale_m
    PROCEDURE :: is_negative => dec_is_negative_m
  END TYPE orm_decimal_t

  !> @type orm_migration_t
  !> @brief RAII Fortran 2003 `-- UP` / `-- DOWN` SQL schema migration runner.
  TYPE, PUBLIC :: orm_migration_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: init => mig_init_m
    PROCEDURE :: up => mig_up_m
    PROCEDURE :: down => mig_down_m
    PROCEDURE :: version => mig_version_m
    PROCEDURE :: free => mig_free_m
    FINAL :: mig_finalize_raii
  END TYPE orm_migration_t

  !> @type orm_shard_router_t
  !> @brief RAII Fortran 2003 deterministic horizontal shard router.
  TYPE, PUBLIC :: orm_shard_router_t
    TYPE(C_PTR) :: ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: init => shard_init_m
    PROCEDURE :: add_node => shard_add_node_m
    PROCEDURE :: route => shard_route_m
    PROCEDURE :: free => shard_free_m
    FINAL :: shard_finalize_raii
  END TYPE orm_shard_router_t

  !> @type orm_oauth2_store_t
  !> @brief OOP Fortran 2003 OAuth2 token persistence & scope validator.
  TYPE, PUBLIC :: orm_oauth2_store_t
    TYPE(C_PTR) :: db_ptr = C_NULL_PTR
  CONTAINS
    PROCEDURE :: init_tables => oauth2_init_m
    PROCEDURE :: save => oauth2_save_m
    PROCEDURE :: fetch => oauth2_fetch_m
    PROCEDURE :: check_scopes => oauth2_check_m
    PROCEDURE :: revoke => oauth2_revoke_m
  END TYPE orm_oauth2_store_t

  !> @type orm_model_base_t
  !> @brief Abstract polymorphic Fortran 2003 ActiveRecord base class.
  TYPE, ABSTRACT, PUBLIC :: orm_model_base_t
    INTEGER(C_INT32_T) :: pk_id = 0_C_INT32_T
  CONTAINS
    PROCEDURE(model_configure_schema_if), DEFERRED :: configure_schema
    PROCEDURE(model_save_if), DEFERRED :: save
    PROCEDURE(model_load_if), DEFERRED :: load_by_id
  END TYPE orm_model_base_t

  ABSTRACT INTERFACE
    !> @brief Deferred schema registration hook on polymorphic ORM models.
    !> @param[in] self Polymorphic model instance.
    !> @param[inout] schema Runtime reflection schema to populate.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION model_configure_schema_if(self, schema) RESULT(rc)
      IMPORT :: orm_model_base_t, orm_schema_t, C_INT
      IMPLICIT NONE
      CLASS(orm_model_base_t), INTENT(IN) :: self
      CLASS(orm_schema_t), INTENT(INOUT) :: schema
      INTEGER(C_INT) :: rc
    END FUNCTION model_configure_schema_if

    !> @brief Deferred persistence hook saving `self` via `schema` onto `db`.
    !> @param[inout] self Polymorphic model instance.
    !> @param[in] db Active database connection.
    !> @param[inout] schema Configured runtime reflection schema.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION model_save_if(self, db, schema) RESULT(rc)
      IMPORT :: orm_model_base_t, orm_db_t, orm_schema_t, C_INT
      IMPLICIT NONE
      CLASS(orm_model_base_t), INTENT(INOUT) :: self
      CLASS(orm_db_t), INTENT(IN) :: db
      CLASS(orm_schema_t), INTENT(INOUT) :: schema
      INTEGER(C_INT) :: rc
    END FUNCTION model_save_if

    !> @brief Deferred hydration hook loading `id_val` into `self`.
    !> @param[inout] self Polymorphic model instance.
    !> @param[in] db Active database connection.
    !> @param[inout] schema Configured runtime reflection schema.
    !> @param[in] id_val 32-bit primary key value.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION model_load_if(self, db, schema, id_val) RESULT(rc)
      IMPORT :: orm_model_base_t, orm_db_t, orm_schema_t, C_INT, C_INT32_T
      IMPLICIT NONE
      CLASS(orm_model_base_t), INTENT(INOUT) :: self
      CLASS(orm_db_t), INTENT(IN) :: db
      CLASS(orm_schema_t), INTENT(INOUT) :: schema
      INTEGER(C_INT32_T), INTENT(IN) :: id_val
      INTEGER(C_INT) :: rc
    END FUNCTION model_load_if
  END INTERFACE

  PUBLIC :: corm_f2003_utf8_to_ebcdic, corm_f2003_ebcdic_to_utf8
  PUBLIC :: corm_f2003_utf8_to_utf16, corm_f2003_utf16_to_utf8
  PUBLIC :: corm_f2003_str_to_a1, corm_f2003_a1_to_str

CONTAINS

  !> @brief Copies a Fortran string into a NUL-terminated `C_CHAR` POD field.
  !> @param[out] field Fixed-length `C_CHAR` array.
  !> @param[in] src Source Fortran string.
  SUBROUTINE copy_to_cchar_arr(field, src)
    CHARACTER(KIND=C_CHAR), DIMENSION(:), INTENT(OUT) :: field
    CHARACTER(LEN=*), INTENT(IN) :: src
    INTEGER :: cap, n, k
    cap = SIZE(field, 1)
    field = C_NULL_CHAR
    n = MIN(LEN_TRIM(src), MAX(cap - 1, 0))
    DO k = 1, n
      field(k) = src(k:k)
    END DO
  END SUBROUTINE copy_to_cchar_arr

  !> @brief Extracts an allocatable Fortran string from a `C_CHAR` POD field.
  !> @param[in] field Fixed-length `C_CHAR` array.
  !> @param[out] out_str Extracted trimmed Fortran string.
  SUBROUTINE extract_cchar_arr(field, out_str)
    CHARACTER(KIND=C_CHAR), DIMENSION(:), INTENT(IN) :: field
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    CHARACTER(LEN=256) :: tmp
    INTEGER :: cap, k, n
    cap = MIN(SIZE(field, 1), 256)
    tmp = " "
    n = 0
    DO k = 1, cap
      IF (field(k) == C_NULL_CHAR) EXIT
      n = k
      tmp(k:k) = field(k)
    END DO
    out_str = ""
    IF (n > 0) THEN
      out_str = TRIM(tmp(1:n))
    END IF
  END SUBROUTINE extract_cchar_arr

  !> @brief Starts a scoped RAII transaction on `db`.
  !> @param[inout] self Transaction guard instance.
  !> @param[in] db Active database connection.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION tx_guard_begin(self, db) RESULT(rc)
    CLASS(orm_tx_guard_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (self%active) prev_rc = self%rollback()
    self%db_ptr = db%ptr
    self%use_savepoint = .FALSE.
    self%sp_len = 0_C_INT32_T
    rc = fortran_orm_tx_begin(self%db_ptr)
    self%active = (rc == FORTRAN_ORM_OK)
  END FUNCTION tx_guard_begin

  !> @brief Starts a scoped RAII savepoint `sp_name` on `db`.
  !> @param[inout] self Transaction guard instance.
  !> @param[in] db Active database connection.
  !> @param[in] sp_name Savepoint identifier (`<= 64` chars).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION tx_guard_begin_sp(self, db, sp_name) RESULT(rc)
    CLASS(orm_tx_guard_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sp_name
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (self%active) prev_rc = self%rollback()
    self%db_ptr = db%ptr
    self%sp_name = sp_name
    self%sp_len = INT(MIN(LEN_TRIM(sp_name), 64), C_INT32_T)
    self%use_savepoint = .TRUE.
    rc = fortran_orm_tx_savepoint(self%db_ptr, self%sp_name, self%sp_len)
    self%active = (rc == FORTRAN_ORM_OK)
  END FUNCTION tx_guard_begin_sp

  !> @brief Commits (or releases savepoint) and disarms RAII rollback.
  !> @param[inout] self Transaction guard instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION tx_guard_commit(self) RESULT(rc)
    CLASS(orm_tx_guard_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (.NOT. self%active) THEN
      rc = FORTRAN_ORM_OK
      RETURN
    END IF
    IF (self%use_savepoint) THEN
      rc = fortran_orm_tx_release_sp(self%db_ptr, self%sp_name, self%sp_len)
    ELSE
      rc = fortran_orm_tx_commit(self%db_ptr)
    END IF
    self%active = .FALSE.
    self%db_ptr = C_NULL_PTR
  END FUNCTION tx_guard_commit

  !> @brief Explicitly rolls back (or reverts savepoint) on `self`.
  !> @param[inout] self Transaction guard instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION tx_guard_rollback(self) RESULT(rc)
    CLASS(orm_tx_guard_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: rel_rc
    IF (.NOT. self%active) THEN
      rc = FORTRAN_ORM_OK
      RETURN
    END IF
    IF (self%use_savepoint) THEN
      rc = fortran_orm_tx_rollback_sp(self%db_ptr, self%sp_name, self%sp_len)
      rel_rc = fortran_orm_tx_release_sp(self%db_ptr, self%sp_name, self%sp_len)
      IF (rc == FORTRAN_ORM_OK) rc = rel_rc
    ELSE
      rc = fortran_orm_tx_rollback(self%db_ptr)
    END IF
    self%active = .FALSE.
    self%db_ptr = C_NULL_PTR
  END FUNCTION tx_guard_rollback

  !> @brief RAII FINAL destructor rolling back uncommitted `orm_tx_guard_t`.
  !> @param[inout] self Transaction guard instance leaving scope.
  SUBROUTINE tx_guard_finalize_raii(self)
    TYPE(orm_tx_guard_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (self%active .AND. C_ASSOCIATED(self%db_ptr)) THEN
      rc = self%rollback()
    END IF
  END SUBROUTINE tx_guard_finalize_raii

  !> @brief Parses base-10 string `str` into `self`.
  !> @param[inout] self Decimal object.
  !> @param[in] str Base-10 decimal literal.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_from_str_m(self, str) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(INOUT) :: self
    CHARACTER(LEN=*), INTENT(IN) :: str
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_from_str(str, INT(LEN(str), C_INT32_T), self%pod)
  END FUNCTION dec_from_str_m

  !> @brief Formats `self` into canonical base-10 string `out_str`.
  !> @param[in] self Decimal object.
  !> @param[out] out_str Allocatable base-10 string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_to_str_m(self, out_str) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=64, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_str = ""
    rc = fortran_orm_dec_to_str(self%pod, buf, 64_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    END IF
  END FUNCTION dec_to_str_m

  !> @brief Initializes `self` from 64-bit integer `val`.
  !> @param[inout] self Decimal object.
  !> @param[in] val 64-bit signed integer.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_from_i64_m(self, val) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(INOUT) :: self
    INTEGER(C_INT64_T), INTENT(IN) :: val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_from_i64(val, self%pod)
  END FUNCTION dec_from_i64_m

  !> @brief Converts `self` to a 64-bit integer under `round_mode`.
  !> @param[in] self Decimal object.
  !> @param[in] round_mode Rounding mode (`FORTRAN_ORM_ROUND_*`).
  !> @param[out] out_val Receives rounded 64-bit integer.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_to_i64_m(self, round_mode, out_val) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self
    INTEGER(C_INT), INTENT(IN) :: round_mode
    INTEGER(C_INT64_T), INTENT(OUT) :: out_val
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_to_i64(self%pod, round_mode, out_val)
  END FUNCTION dec_to_i64_m

  !> @brief Computes `out_res = self + rhs`.
  !> @param[in] self Left addend.
  !> @param[in] rhs Right addend.
  !> @param[out] out_res Exact sum.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_add_m(self, rhs, out_res) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self, rhs
    TYPE(orm_decimal_t), INTENT(OUT) :: out_res
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_add(self%pod, rhs%pod, out_res%pod)
  END FUNCTION dec_add_m

  !> @brief Computes `out_res = self - rhs`.
  !> @param[in] self Minuend.
  !> @param[in] rhs Subtrahend.
  !> @param[out] out_res Exact difference.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_sub_m(self, rhs, out_res) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self, rhs
    TYPE(orm_decimal_t), INTENT(OUT) :: out_res
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_sub(self%pod, rhs%pod, out_res%pod)
  END FUNCTION dec_sub_m

  !> @brief Computes `out_res = self * rhs` bounded to `max_scale`.
  !> @param[in] self Multiplicand.
  !> @param[in] rhs Multiplier.
  !> @param[in] max_scale Maximum fractional digits (`0..38`).
  !> @param[in] round_mode Rounding mode.
  !> @param[out] out_res Product decimal.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_mul_m(self, rhs, max_scale, round_mode, out_res) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self, rhs
    INTEGER(C_INT32_T), INTENT(IN) :: max_scale
    INTEGER(C_INT), INTENT(IN) :: round_mode
    TYPE(orm_decimal_t), INTENT(OUT) :: out_res
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_mul(self%pod, rhs%pod, max_scale, round_mode, &
                             out_res%pod)
  END FUNCTION dec_mul_m

  !> @brief Computes `out_res = self / rhs` at `result_scale`.
  !> @param[in] self Dividend.
  !> @param[in] rhs Divisor.
  !> @param[in] result_scale Fractional digits (`0..38`).
  !> @param[in] round_mode Remainder rounding mode.
  !> @param[out] out_res Quotient decimal.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_div_m(self, rhs, result_scale, round_mode, out_res) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self, rhs
    INTEGER(C_INT32_T), INTENT(IN) :: result_scale
    INTEGER(C_INT), INTENT(IN) :: round_mode
    TYPE(orm_decimal_t), INTENT(OUT) :: out_res
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_div(self%pod, rhs%pod, result_scale, round_mode, &
                             out_res%pod)
  END FUNCTION dec_div_m

  !> @brief Compares `self` against `rhs` (`-1`, `0`, `+1`).
  !> @param[in] self Left decimal.
  !> @param[in] rhs Right decimal.
  !> @param[out] cmp_out Receives `-1`, `0`, or `+1`.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_cmp_m(self, rhs, cmp_out) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self, rhs
    INTEGER(C_INT32_T), INTENT(OUT) :: cmp_out
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_cmp(self%pod, rhs%pod, cmp_out)
  END FUNCTION dec_cmp_m

  !> @brief Rescales `self` to `(prec, scale)` under `round_mode`.
  !> @param[in] self Source decimal.
  !> @param[in] prec Maximum precision (`1..38`).
  !> @param[in] scale Target fractional digits (`0..prec`).
  !> @param[in] round_mode Rounding mode.
  !> @param[out] out_res Rescaled decimal.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION dec_rescale_m(self, prec, scale, round_mode, out_res) RESULT(rc)
    CLASS(orm_decimal_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: prec, scale
    INTEGER(C_INT), INTENT(IN) :: round_mode
    TYPE(orm_decimal_t), INTENT(OUT) :: out_res
    INTEGER(C_INT) :: rc
    rc = fortran_orm_dec_rescale(self%pod, prec, scale, round_mode, &
                                 out_res%pod)
  END FUNCTION dec_rescale_m

  !> @brief Returns `.TRUE.` when `self` has negative sign (`sign /= 0`).
  !> @param[in] self Decimal object.
  !> @return `.TRUE.` if strictly negative.
  PURE FUNCTION dec_is_negative_m(self) RESULT(neg)
    CLASS(orm_decimal_t), INTENT(IN) :: self
    LOGICAL :: neg
    neg = (self%pod%sign /= 0_C_INT8_T)
  END FUNCTION dec_is_negative_m

  !> @brief Initializes migration runner `self` scanning `dir_path`.
  !> @param[inout] self Migration runner instance.
  !> @param[in] db Active database connection.
  !> @param[in] dir_path Directory containing `.sql` migrations.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION mig_init_m(self, db, dir_path) RESULT(rc)
    CLASS(orm_migration_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: dir_path
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) prev_rc = self%free()
    rc = fortran_orm_mig_init(db%ptr, dir_path, &
                              INT(LEN(dir_path), C_INT32_T), self%ptr)
  END FUNCTION mig_init_m

  !> @brief Applies pending `-- UP` migrations on `self`.
  !> @param[in] self Migration runner instance.
  !> @param[in] dry_run `.TRUE.` for dry-run verification without mutation.
  !> @param[out] total_applied Total count of applied migrations.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION mig_up_m(self, dry_run, total_applied) RESULT(rc)
    CLASS(orm_migration_t), INTENT(IN) :: self
    LOGICAL, INTENT(IN) :: dry_run
    INTEGER(C_INT32_T), INTENT(OUT) :: total_applied
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: idry
    idry = MERGE(1_C_INT32_T, 0_C_INT32_T, dry_run)
    rc = fortran_orm_mig_up(self%ptr, idry, total_applied)
  END FUNCTION mig_up_m

  !> @brief Reverts the last `steps` applied `-- DOWN` migrations.
  !> @param[in] self Migration runner instance.
  !> @param[in] steps Number of migrations to revert (`0` for all).
  !> @param[in] dry_run `.TRUE.` for dry-run verification.
  !> @param[out] remaining Remaining applied migration count.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION mig_down_m(self, steps, dry_run, remaining) RESULT(rc)
    CLASS(orm_migration_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: steps
    LOGICAL, INTENT(IN) :: dry_run
    INTEGER(C_INT32_T), INTENT(OUT) :: remaining
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: idry
    idry = MERGE(1_C_INT32_T, 0_C_INT32_T, dry_run)
    rc = fortran_orm_mig_down(self%ptr, steps, idry, remaining)
  END FUNCTION mig_down_m

  !> @brief Queries latest applied migration version string on `self`.
  !> @param[in] self Migration runner instance.
  !> @param[out] ver_out Allocatable version string (`""` if none).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION mig_version_m(self, ver_out) RESULT(rc)
    CLASS(orm_migration_t), INTENT(IN) :: self
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: ver_out
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=128, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    ver_out = ""
    rc = fortran_orm_mig_version(self%ptr, buf, 128_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      ver_out = buf(1:out_n)
    END IF
  END FUNCTION mig_version_m

  !> @brief Frees migration runner `self`.
  !> @param[inout] self Migration runner instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION mig_free_m(self) RESULT(rc)
    CLASS(orm_migration_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_mig_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION mig_free_m

  !> @brief RAII FINAL destructor for `orm_migration_t`.
  !> @param[inout] self Migration runner instance leaving scope.
  SUBROUTINE mig_finalize_raii(self)
    TYPE(orm_migration_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_mig_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE mig_finalize_raii

  !> @brief Initializes shard router `self` for `num_shards` nodes.
  !> @param[inout] self Shard router instance.
  !> @param[in] num_shards Total shard count (`>= 1`).
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION shard_init_m(self, num_shards) RESULT(rc)
    CLASS(orm_shard_router_t), INTENT(INOUT) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: num_shards
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    IF (C_ASSOCIATED(self%ptr)) prev_rc = self%free()
    rc = fortran_orm_shard_init(num_shards, self%ptr)
  END FUNCTION shard_init_m

  !> @brief Binds `db` to 1-based `shard_idx` on `self`.
  !> @param[in] self Shard router instance.
  !> @param[in] shard_idx 1-based shard slot (`1..num_shards`).
  !> @param[in] db Connected database node.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION shard_add_node_m(self, shard_idx, db) RESULT(rc)
    CLASS(orm_shard_router_t), INTENT(IN) :: self
    INTEGER(C_INT32_T), INTENT(IN) :: shard_idx
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT) :: rc
    rc = fortran_orm_shard_add_node(self%ptr, shard_idx, db%ptr)
  END FUNCTION shard_add_node_m

  !> @brief Deterministically hashes `routing_key` to a 1-based shard index.
  !> @param[in] self Shard router instance.
  !> @param[in] routing_key Partition routing key string.
  !> @param[out] shard_idx Receives 1-based target shard index.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION shard_route_m(self, routing_key, shard_idx) RESULT(rc)
    CLASS(orm_shard_router_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: routing_key
    INTEGER(C_INT32_T), INTENT(OUT) :: shard_idx
    INTEGER(C_INT) :: rc
    rc = fortran_orm_shard_route(self%ptr, routing_key, &
                                 INT(LEN(routing_key), C_INT32_T), shard_idx)
  END FUNCTION shard_route_m

  !> @brief Frees shard router `self` without closing attached DB nodes.
  !> @param[inout] self Shard router instance.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION shard_free_m(self) RESULT(rc)
    CLASS(orm_shard_router_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    rc = FORTRAN_ORM_OK
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_shard_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END FUNCTION shard_free_m

  !> @brief RAII FINAL destructor for `orm_shard_router_t`.
  !> @param[inout] self Shard router instance leaving scope.
  SUBROUTINE shard_finalize_raii(self)
    TYPE(orm_shard_router_t), INTENT(INOUT) :: self
    INTEGER(C_INT) :: rc
    IF (C_ASSOCIATED(self%ptr)) THEN
      rc = fortran_orm_shard_free(self%ptr)
      self%ptr = C_NULL_PTR
    END IF
  END SUBROUTINE shard_finalize_raii

  !> @brief Initializes standard OAuth2 persistence tables on `db`.
  !> @param[inout] self OAuth2 store instance.
  !> @param[in] db Active database connection.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION oauth2_init_m(self, db) RESULT(rc)
    CLASS(orm_oauth2_store_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    INTEGER(C_INT) :: rc
    self%db_ptr = db%ptr
    rc = fortran_orm_oauth2_init_tables(self%db_ptr)
  END FUNCTION oauth2_init_m

  !> @brief Persists an OAuth2 bearer token from native Fortran strings.
  !> @param[in] self OAuth2 store instance.
  !> @param[in] access_tok Bearer access token.
  !> @param[in] refresh_tok Refresh token.
  !> @param[in] user_id Principal user identifier.
  !> @param[in] scopes Space-delimited granted scopes.
  !> @param[in] expires_in Lifetime in seconds.
  !> @param[in] created_at Creation UNIX timestamp.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION oauth2_save_m(self, access_tok, refresh_tok, user_id, scopes, &
                         expires_in, created_at) RESULT(rc)
    CLASS(orm_oauth2_store_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: access_tok, refresh_tok, user_id, scopes
    INTEGER(C_INT32_T), INTENT(IN) :: expires_in
    INTEGER(C_INT64_T), INTENT(IN) :: created_at
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_oauth2_token_pod) :: pod
    CALL copy_to_cchar_arr(pod%access_token, access_tok)
    CALL copy_to_cchar_arr(pod%refresh_token, refresh_tok)
    CALL copy_to_cchar_arr(pod%token_type, "Bearer")
    CALL copy_to_cchar_arr(pod%user_id, user_id)
    CALL copy_to_cchar_arr(pod%scopes, scopes)
    pod%expires_in = expires_in
    pod%reserved_pad = 0_C_INT32_T
    pod%created_at = created_at
    rc = fortran_orm_oauth2_save_token(self%db_ptr, pod)
  END FUNCTION oauth2_save_m

  !> @brief Retrieves user ID, scopes, and expiry for `access_tok`.
  !> @param[in] self OAuth2 store instance.
  !> @param[in] access_tok Bearer access token.
  !> @param[out] user_id Allocatable user ID string.
  !> @param[out] scopes Allocatable space-delimited scope string.
  !> @param[out] expires_in Lifetime in seconds.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION oauth2_fetch_m(self, access_tok, user_id, scopes, expires_in) &
      RESULT(rc)
    CLASS(orm_oauth2_store_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: access_tok
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: user_id, scopes
    INTEGER(C_INT32_T), INTENT(OUT) :: expires_in
    INTEGER(C_INT) :: rc
    TYPE(fortran_orm_oauth2_token_pod) :: pod
    expires_in = 0_C_INT32_T
    rc = fortran_orm_oauth2_get_token(self%db_ptr, access_tok, &
                                      INT(LEN(access_tok), C_INT32_T), pod)
    IF (rc == FORTRAN_ORM_OK) THEN
      CALL extract_cchar_arr(pod%user_id, user_id)
      CALL extract_cchar_arr(pod%scopes, scopes)
      expires_in = pod%expires_in
    ELSE
      user_id = ""
      scopes = ""
    END IF
  END FUNCTION oauth2_fetch_m

  !> @brief Verifies whether `req_scopes` is a subset of `granted_scopes`.
  !> @param[in] self OAuth2 store instance.
  !> @param[in] granted_scopes Space-delimited granted scopes.
  !> @param[in] req_scopes Space-delimited required scopes.
  !> @param[out] is_valid Receives `.TRUE.` if subset check passes.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION oauth2_check_m(self, granted_scopes, req_scopes, is_valid) &
      RESULT(rc)
    CLASS(orm_oauth2_store_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: granted_scopes, req_scopes
    LOGICAL, INTENT(OUT) :: is_valid
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: iok
    iok = 0_C_INT32_T
    rc = fortran_orm_oauth2_revoke_or_check( &
         self%db_ptr, " ", 0_C_INT32_T, 0_C_INT32_T, granted_scopes, &
         INT(LEN(granted_scopes), C_INT32_T), req_scopes, &
         INT(LEN(req_scopes), C_INT32_T), iok)
    is_valid = (rc == FORTRAN_ORM_OK .AND. iok /= 0_C_INT32_T)
  END FUNCTION oauth2_check_m

  !> @brief Revokes (deletes) `access_tok` from `self`.
  !> @param[in] self OAuth2 store instance.
  !> @param[in] access_tok Bearer access token to revoke.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION oauth2_revoke_m(self, access_tok) RESULT(rc)
    CLASS(orm_oauth2_store_t), INTENT(IN) :: self
    CHARACTER(LEN=*), INTENT(IN) :: access_tok
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: iok
    iok = 0_C_INT32_T
    rc = fortran_orm_oauth2_revoke_or_check( &
         self%db_ptr, access_tok, INT(LEN(access_tok), C_INT32_T), &
         1_C_INT32_T, " ", 0_C_INT32_T, " ", 0_C_INT32_T, iok)
  END FUNCTION oauth2_revoke_m

  !> @brief Transcodes UTF-8 string `src` into mainframe EBCDIC bytes.
  !> @param[in] codepage EBCDIC codepage (`FORTRAN_ORM_CP_*`).
  !> @param[in] src UTF-8 string slice.
  !> @param[out] out_bytes Destination `C_INT8_T` byte array.
  !> @param[out] out_len Number of encoded EBCDIC bytes.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_utf8_to_ebcdic(codepage, src, out_bytes, out_len) &
      RESULT(rc)
    INTEGER(C_INT), INTENT(IN) :: codepage
    CHARACTER(LEN=*), INTENT(IN) :: src
    INTEGER(C_INT8_T), DIMENSION(:), TARGET, INTENT(OUT) :: out_bytes
    INTEGER(C_INT32_T), INTENT(OUT) :: out_len
    INTEGER(C_INT) :: rc
    out_bytes = 0_C_INT8_T
    rc = fortran_orm_utf8_to_ebcdic(codepage, src, &
                                    INT(LEN(src), C_INT32_T), &
                                    C_LOC(out_bytes(1)), &
                                    INT(SIZE(out_bytes, 1), C_INT32_T), &
                                    out_len)
  END FUNCTION corm_f2003_utf8_to_ebcdic

  !> @brief Transcodes EBCDIC bytes into an allocatable UTF-8 Fortran string.
  !> @param[in] codepage EBCDIC codepage (`FORTRAN_ORM_CP_*`).
  !> @param[in] ebcdic_bytes Source `C_INT8_T` byte array.
  !> @param[in] byte_len Number of active bytes in `ebcdic_bytes`.
  !> @param[out] out_str Decoded allocatable UTF-8 string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_ebcdic_to_utf8(codepage, ebcdic_bytes, byte_len, &
                                     out_str) RESULT(rc)
    INTEGER(C_INT), INTENT(IN) :: codepage
    INTEGER(C_INT8_T), DIMENSION(:), TARGET, INTENT(IN) :: ebcdic_bytes
    INTEGER(C_INT32_T), INTENT(IN) :: byte_len
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_str = ""
    rc = fortran_orm_ebcdic_to_utf8(codepage, C_LOC(ebcdic_bytes(1)), &
                                    byte_len, buf, 512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    END IF
  END FUNCTION corm_f2003_ebcdic_to_utf8

  !> @brief Transcodes UTF-8 string `src` into 16-bit UTF-16 `GRAPHIC` units.
  !> @param[in] src UTF-8 string slice.
  !> @param[in] big_endian `.TRUE.` for z/OS big-endian `GRAPHIC`.
  !> @param[out] out_u16 Destination `C_INT16_T` code-unit array.
  !> @param[out] out_units Number of written 16-bit code units.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_utf8_to_utf16(src, big_endian, out_u16, out_units) &
      RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: src
    LOGICAL, INTENT(IN) :: big_endian
    INTEGER(C_INT16_T), DIMENSION(:), TARGET, INTENT(OUT) :: out_u16
    INTEGER(C_INT32_T), INTENT(OUT) :: out_units
    INTEGER(C_INT) :: rc
    INTEGER(C_INT32_T) :: ibe
    ibe = MERGE(1_C_INT32_T, 0_C_INT32_T, big_endian)
    out_u16 = 0_C_INT16_T
    rc = fortran_orm_utf8_to_utf16(src, INT(LEN(src), C_INT32_T), ibe, &
                                   C_LOC(out_u16(1)), &
                                   INT(SIZE(out_u16, 1), C_INT32_T), out_units)
  END FUNCTION corm_f2003_utf8_to_utf16

  !> @brief Transcodes UTF-16 `GRAPHIC` units into an allocatable UTF-8 string.
  !> @param[in] u16_units Source `C_INT16_T` code-unit array.
  !> @param[in] unit_count Number of 16-bit code units to decode.
  !> @param[in] big_endian `.TRUE.` if `u16_units` are big-endian.
  !> @param[out] out_str Decoded allocatable UTF-8 string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_utf16_to_utf8(u16_units, unit_count, big_endian, &
                                    out_str) RESULT(rc)
    INTEGER(C_INT16_T), DIMENSION(:), TARGET, INTENT(IN) :: u16_units
    INTEGER(C_INT32_T), INTENT(IN) :: unit_count
    LOGICAL, INTENT(IN) :: big_endian
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: ibe, out_n
    ibe = MERGE(1_C_INT32_T, 0_C_INT32_T, big_endian)
    out_n = 0_C_INT32_T
    out_str = ""
    rc = fortran_orm_utf16_to_utf8(C_LOC(u16_units(1)), unit_count, ibe, &
                                   buf, 512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    END IF
  END FUNCTION corm_f2003_utf16_to_utf8

  !> @brief Encodes a Fortran string into an unpacked `A1` `C_INT32_T` array.
  !> @param[in] src Source Fortran string.
  !> @param[out] out_a1 Destination `C_INT32_T` ASCII code array.
  !> @param[out] out_len Trimmed character count.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_str_to_a1(src, out_a1, out_len) RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: src
    INTEGER(C_INT32_T), DIMENSION(:), TARGET, INTENT(OUT) :: out_a1
    INTEGER(C_INT32_T), INTENT(OUT) :: out_len
    INTEGER(C_INT) :: rc
    out_a1 = 32_C_INT32_T
    rc = fortran_orm_str_to_a1(src, INT(LEN(src), C_INT32_T), &
                               C_LOC(out_a1(1)), &
                               INT(SIZE(out_a1, 1), C_INT32_T), out_len)
  END FUNCTION corm_f2003_str_to_a1

  !> @brief Decodes an unpacked `A1` `C_INT32_T` array into an allocatable str.
  !> @param[in] a1_codes Source `C_INT32_T` ASCII code array.
  !> @param[in] count Number of elements to decode.
  !> @param[out] out_str Trimmed allocatable Fortran string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2003_a1_to_str(a1_codes, count, out_str) RESULT(rc)
    INTEGER(C_INT32_T), DIMENSION(:), TARGET, INTENT(IN) :: a1_codes
    INTEGER(C_INT32_T), INTENT(IN) :: count
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: buf
    INTEGER(C_INT32_T) :: out_n
    out_n = 0_C_INT32_T
    out_str = ""
    rc = fortran_orm_a1_to_str(C_LOC(a1_codes(1)), count, buf, &
                               512_C_INT32_T, out_n)
    IF (rc == FORTRAN_ORM_OK .AND. out_n > 0_C_INT32_T) THEN
      out_str = buf(1:out_n)
    END IF
  END FUNCTION corm_f2003_a1_to_str

END MODULE fortran_orm_f2003_ext
