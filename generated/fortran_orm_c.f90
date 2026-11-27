!> @file fortran_orm_c.f90
!> @module fortran_orm_c
!> @brief Auto-generated Fortran 2003+ (ISO_C_BINDING) bindings for fortran_orm.
MODULE fortran_orm_c
  USE, INTRINSIC :: ISO_C_BINDING
  IMPLICIT NONE

  ! Maximum decimal digits in fortran_orm_decimal_t.
  INTEGER(C_INT64_T), PARAMETER :: fortran_orm_decimal_max_digits = 38_C_INT64_T

  ! Initial slot capacity for integer-indexed legacy handles.
  INTEGER(C_INT64_T), PARAMETER :: fortran_orm_legacy_init_slots = 64_C_INT64_T

  ! Semantic version string of the fortran-orm library.
  CHARACTER(LEN=*), PARAMETER :: fortran_orm_version_str = "0.1.0"

  ! @brief Unified error status enumeration returned by every function in
  ! fortran-orm (`FORTRAN_ORM_OK == 0`).
  ENUM, BIND(C)
    ! @brief Operation succeeded (`C_ORM_OK`).
    ENUMERATOR :: fortran_orm_ok = 0_C_INT
    ! @brief Out-of-memory allocation failure (`C_ORM_ERROR_MEMORY`).
    ENUMERATOR :: fortran_orm_error_memory = 1_C_INT
    ! @brief Database connection failure (`C_ORM_ERROR_CONNECTION`).
    ENUMERATOR :: fortran_orm_error_connection = 2_C_INT
    ! @brief SQL syntax or execution error (`C_ORM_ERROR_SQL`).
    ENUMERATOR :: fortran_orm_error_sql = 3_C_INT
    ! @brief Statement parameter bind failure (`C_ORM_ERROR_BIND`).
    ENUMERATOR :: fortran_orm_error_bind = 4_C_INT
    ! @brief Prepared statement step failure (`C_ORM_ERROR_STEP`).
    ENUMERATOR :: fortran_orm_error_step = 5_C_INT
    ! @brief Column or parameter type mismatch (`C_ORM_ERROR_TYPE_MISMATCH`).
    ENUMERATOR :: fortran_orm_error_type_mismatch = 6_C_INT
    ! @brief Requested row or key not found (`C_ORM_ERROR_NOT_FOUND`).
    ENUMERATOR :: fortran_orm_error_not_found = 7_C_INT
    ! @brief Feature not implemented by driver (`C_ORM_ERROR_NOT_IMPLEMENTED`).
    ENUMERATOR :: fortran_orm_error_not_implemented = 8_C_INT
    ! @brief Unclassified driver error (`C_ORM_ERROR_UNKNOWN`).
    ENUMERATOR :: fortran_orm_error_unknown = 9_C_INT
    ! @brief Cached record TTL expired (`C_ORM_ERROR_EXPIRED`).
    ENUMERATOR :: fortran_orm_error_expired = 10_C_INT
    ! @brief Domain or argument validation error (`C_ORM_ERROR_VALIDATION`).
    ENUMERATOR :: fortran_orm_error_validation = 11_C_INT
    ! @brief Maximum recursion depth exceeded (`C_ORM_ERROR_RECURSION`).
    ENUMERATOR :: fortran_orm_error_recursion = 12_C_INT
    ! @brief Mutation attempted on read-only view (`C_ORM_ERROR_READ_ONLY`).
    ENUMERATOR :: fortran_orm_error_read_only = 13_C_INT
    ! @brief Unexpected NULL pointer argument (`C_ORM_ERROR_NULL_POINTER`).
    ENUMERATOR :: fortran_orm_error_null_pointer = 14_C_INT
    ! @brief File or OS CSPRNG I/O error (`C_ORM_ERROR_IO`).
    ENUMERATOR :: fortran_orm_error_io = 15_C_INT
    ! @brief SQL, JSON, or schema parse failure (`C_ORM_ERROR_PARSE`).
    ENUMERATOR :: fortran_orm_error_parse = 16_C_INT
    ! @brief Arithmetic or buffer size overflow (`C_ORM_ERROR_OVERFLOW`).
    ENUMERATOR :: fortran_orm_error_overflow = 17_C_INT
    ! @brief Cyclic graph dependency detected (`C_ORM_ERROR_CYCLE`).
    ENUMERATOR :: fortran_orm_error_cycle = 18_C_INT
    ! @brief Database lock contention / busy (`C_ORM_ERROR_BUSY`).
    ENUMERATOR :: fortran_orm_error_busy = 19_C_INT
    ! @brief Cryptographic operation failed (`C_ORM_ERROR_CRYPTO`).
    ENUMERATOR :: fortran_orm_error_crypto = 20_C_INT
    ! @brief Unique/FK/check constraint violation (`C_ORM_ERROR_CONSTRAINT`).
    ENUMERATOR :: fortran_orm_error_constraint = 21_C_INT
    ! @brief Dynamic driver client load failure (`C_ORM_ERROR_DRIVER_LOAD`).
    ENUMERATOR :: fortran_orm_error_driver_load = 22_C_INT
    ! @brief ODBC / Db2 CLI diagnostic error (`C_ORM_ERROR_ODBC_DIAG`).
    ENUMERATOR :: fortran_orm_error_odbc_diag = 23_C_INT
    ! @brief Pool or login timeout expired (`C_ORM_ERROR_TIMEOUT`).
    ENUMERATOR :: fortran_orm_error_timeout = 24_C_INT
    ! @brief Transaction deadlock detected (`C_ORM_ERROR_DEADLOCK`).
    ENUMERATOR :: fortran_orm_error_deadlock = 25_C_INT
    ! @brief Disallowed string/binary truncation (`C_ORM_ERROR_TRUNCATION`).
    ENUMERATOR :: fortran_orm_error_truncation = 26_C_INT
    ! @brief Invalid decimal string or BCD nybble
    ! (`C_ORM_ERROR_DECIMAL_SYNTAX`).
    ENUMERATOR :: fortran_orm_error_decimal_syntax = 27_C_INT
    ! @brief Decimal overflow or divide-by-zero
    ! (`C_ORM_ERROR_DECIMAL_OVERFLOW`).
    ENUMERATOR :: fortran_orm_error_decimal_overflow = 28_C_INT
    ! @brief Inexact rounding under exact mode (`C_ORM_ERROR_DECIMAL_INEXACT`).
    ENUMERATOR :: fortran_orm_error_decimal_inexact = 29_C_INT
    ! @brief Invalid UTF-8/UTF-16/EBCDIC sequence (`C_ORM_ERROR_CODEPAGE`).
    ENUMERATOR :: fortran_orm_error_codepage = 30_C_INT
    ! @brief Reserved Copybook syntax code (`C_ORM_ERROR_COPYBOOK_SYNTAX`).
    ENUMERATOR :: fortran_orm_error_copybook_syntax = 31_C_INT
    ! @brief Null, closed, or corrupted Fortran FFI handle or slot ID.
    ENUMERATOR :: fortran_orm_error_invalid_handle = 32_C_INT
    ! @brief Legacy integer handle slot table capacity exhausted.
    ENUMERATOR :: fortran_orm_error_handle_table_full = 33_C_INT
    ! @brief Caller array/matrix capacity smaller than result count.
    ENUMERATOR :: fortran_orm_error_buffer_too_small = 34_C_INT
    ! @brief 1-based parameter, column, or row index out of valid bounds.
    ENUMERATOR :: fortran_orm_error_invalid_index = 35_C_INT
    ! @brief Unrecognized FORTRAN I / legacy dispatcher opcode.
    ENUMERATOR :: fortran_orm_error_invalid_opcode = 36_C_INT
    ! @brief Invalid Fortran 2018 CFI_cdesc_t array rank.
    ENUMERATOR :: fortran_orm_error_descriptor_rank = 37_C_INT
    ! @brief Unsupported Fortran 2018 CFI_cdesc_t element type.
    ENUMERATOR :: fortran_orm_error_descriptor_type = 38_C_INT
  END ENUM

  ! @brief Target SQL dialect for AST compilation and DDL generation.
  ENUM, BIND(C)
    ! @brief SQLite (`?` placeholders, `LIMIT`/`OFFSET`, `ON CONFLICT`).
    ENUMERATOR :: fortran_orm_dialect_sqlite = 0_C_INT
    ! @brief PostgreSQL (`$1..$N` placeholders, `RETURNING`).
    ENUMERATOR :: fortran_orm_dialect_postgres = 1_C_INT
    ! @brief MySQL / MariaDB (`?` placeholders, `ON DUPLICATE KEY`).
    ENUMERATOR :: fortran_orm_dialect_mysql = 2_C_INT
    ! @brief IBM Db2 (`FETCH FIRST`, `MERGE INTO`, `FINAL TABLE`, `WITH UR`).
    ENUMERATOR :: fortran_orm_dialect_db2 = 3_C_INT
    ! @brief Generic ANSI/ISO ODBC 3.52 (`OFFSET ... FETCH NEXT`).
    ENUMERATOR :: fortran_orm_dialect_odbc = 4_C_INT
  END ENUM

  ! @brief Column and dynamic variant value types aligned with `c_orm_type_t`.
  ENUM, BIND(C)
    ! @brief 32-bit signed integer (`INTEGER*4` / `C_INT32_T`).
    ENUMERATOR :: fortran_orm_col_int32 = 0_C_INT
    ! @brief 64-bit signed integer (`INTEGER*8` / `C_INT64_T`).
    ENUMERATOR :: fortran_orm_col_int64 = 1_C_INT
    ! @brief 32-bit IEEE float (`REAL*4` / `C_FLOAT`).
    ENUMERATOR :: fortran_orm_col_float32 = 2_C_INT
    ! @brief 64-bit IEEE double (`DOUBLE PRECISION` / `REAL*8` / `C_DOUBLE`).
    ENUMERATOR :: fortran_orm_col_float64 = 3_C_INT
    ! @brief Boolean flag (`LOGICAL` / `0` or `1`).
    ENUMERATOR :: fortran_orm_col_bool = 4_C_INT
    ! @brief NUL-terminated or blank-padded UTF-8/ASCII text string.
    ENUMERATOR :: fortran_orm_col_string = 5_C_INT
    ! @brief Raw binary byte buffer (`BLOB`).
    ENUMERATOR :: fortran_orm_col_blob = 6_C_INT
    ! @brief SQL `DATE` (`YYYY-MM-DD`).
    ENUMERATOR :: fortran_orm_col_date = 7_C_INT
    ! @brief SQL `TIMESTAMP` (`YYYY-MM-DD HH:MM:SS`).
    ENUMERATOR :: fortran_orm_col_timestamp = 8_C_INT
    ! @brief Exact 38-digit fixed-point decimal (`fortran_orm_decimal_t`).
    ENUMERATOR :: fortran_orm_col_decimal = 15_C_INT
    ! @brief Fixed-width space-padded character (`CHAR(N)`).
    ENUMERATOR :: fortran_orm_col_char_fixed = 17_C_INT
    ! @brief Unknown or SQL `NULL` variant value.
    ENUMERATOR :: fortran_orm_col_null = 23_C_INT
  END ENUM

  ! @brief Rounding modes for exact 38-digit decimal arithmetic and rescaling.
  ENUM, BIND(C)
    ! @brief Truncate toward zero.
    ENUMERATOR :: fortran_orm_round_truncate = 0_C_INT
    ! @brief Round half away from zero.
    ENUMERATOR :: fortran_orm_round_half_up = 1_C_INT
    ! @brief Round half to nearest even digit (banker's rounding).
    ENUMERATOR :: fortran_orm_round_half_even = 2_C_INT
    ! @brief Return `FORTRAN_ORM_ERROR_DECIMAL_INEXACT` if non-zero lost.
    ENUMERATOR :: fortran_orm_round_error_if_inexact = 3_C_INT
  END ENUM

  ! @brief Character codepages for mainframe EBCDIC <-> UTF-8/ASCII transcoding.
  ENUM, BIND(C)
    ! @brief UTF-8 (CCSID 1208).
    ENUMERATOR :: fortran_orm_cp_utf8 = 0_C_INT
    ! @brief 7-bit ASCII / ISO-8859-1 (CCSID 367/819).
    ENUMERATOR :: fortran_orm_cp_ascii = 1_C_INT
    ! @brief US/Canada z/OS & Db2 EBCDIC (CCSID 37).
    ENUMERATOR :: fortran_orm_cp_ibm037 = 2_C_INT
    ! @brief z/OS USS C/Fortran EBCDIC (CCSID 1047).
    ENUMERATOR :: fortran_orm_cp_ibm1047 = 3_C_INT
    ! @brief International EBCDIC (CCSID 500).
    ENUMERATOR :: fortran_orm_cp_ibm500 = 4_C_INT
    ! @brief US/Canada Euro EBCDIC with U+20AC at 0x9F (CCSID 1140).
    ENUMERATOR :: fortran_orm_cp_ibm1140 = 5_C_INT
  END ENUM

  ! @brief Transaction and statement isolation levels (Db2 & ODBC 3.52).
  ENUM, BIND(C)
    ! @brief Uncommitted Read (`WITH UR` / `READ UNCOMMITTED`).
    ENUMERATOR :: fortran_orm_iso_ur = 0_C_INT
    ! @brief Cursor Stability (`WITH CS` / `READ COMMITTED`).
    ENUMERATOR :: fortran_orm_iso_cs = 1_C_INT
    ! @brief Read Stability (`WITH RS` / `REPEATABLE READ`).
    ENUMERATOR :: fortran_orm_iso_rs = 2_C_INT
    ! @brief Repeatable Read (`WITH RR` / `SERIALIZABLE`).
    ENUMERATOR :: fortran_orm_iso_rr = 3_C_INT
  END ENUM

  ! @brief Relationship association kinds for runtime struct metadata.
  ENUM, BIND(C)
    ! @brief One-to-one child association.
    ENUMERATOR :: fortran_orm_rel_one_to_one = 0_C_INT
    ! @brief Belongs-to parent association.
    ENUMERATOR :: fortran_orm_rel_belongs_to = 1_C_INT
    ! @brief One-to-many child collection.
    ENUMERATOR :: fortran_orm_rel_one_to_many = 2_C_INT
    ! @brief Many-to-many association via join table.
    ENUMERATOR :: fortran_orm_rel_many_to_many = 3_C_INT
  END ENUM

  ! @brief Operation codes for the 1957 FORTRAN (I) external function `ICORMF`
  ! and pre-CHARACTER legacy integer-handle dispatchers.
  ENUM, BIND(C)
    ! @brief Connect using unpacked A1 INTEGER character-code array.
    ENUMERATOR :: fortran_orm_op_open_a1 = 1_C_INT
    ! @brief Connect using packed A4 Hollerith INTEGER buffer.
    ENUMERATOR :: fortran_orm_op_open_a4 = 2_C_INT
    ! @brief Disconnect integer DB handle slot.
    ENUMERATOR :: fortran_orm_op_close = 3_C_INT
    ! @brief Execute raw SQL from unpacked A1 INTEGER array.
    ENUMERATOR :: fortran_orm_op_exec_a1 = 4_C_INT
    ! @brief Execute raw SQL from packed A4 Hollerith buffer.
    ENUMERATOR :: fortran_orm_op_exec_a4 = 5_C_INT
    ! @brief Begin transaction on DB slot.
    ENUMERATOR :: fortran_orm_op_tx_begin = 6_C_INT
    ! @brief Commit transaction on DB slot.
    ENUMERATOR :: fortran_orm_op_tx_commit = 7_C_INT
    ! @brief Rollback transaction on DB slot.
    ENUMERATOR :: fortran_orm_op_tx_rollback = 8_C_INT
    ! @brief Prepare statement from unpacked A1 SQL array.
    ENUMERATOR :: fortran_orm_op_prep_a1 = 9_C_INT
    ! @brief Prepare statement from packed A4 Hollerith SQL buffer.
    ENUMERATOR :: fortran_orm_op_prep_a4 = 10_C_INT
    ! @brief Bind 32-bit INTEGER parameter (`1`-based index).
    ENUMERATOR :: fortran_orm_op_bind_i32 = 11_C_INT
    ! @brief Bind DOUBLE PRECISION parameter (`1`-based index).
    ENUMERATOR :: fortran_orm_op_bind_f64 = 12_C_INT
    ! @brief Bind unpacked A1 string parameter (`1`-based index).
    ENUMERATOR :: fortran_orm_op_bind_a1 = 13_C_INT
    ! @brief Bind packed A4 Hollerith string parameter (`1`-based index).
    ENUMERATOR :: fortran_orm_op_bind_a4 = 14_C_INT
    ! @brief Step prepared statement (`IVAL` receives `1` for row, `0` EOF).
    ENUMERATOR :: fortran_orm_op_step = 15_C_INT
    ! @brief Read 32-bit INTEGER column (`1`-based index) into `IVAL`.
    ENUMERATOR :: fortran_orm_op_col_i32 = 16_C_INT
    ! @brief Read DOUBLE PRECISION column (`1`-based index) into `DVAL`.
    ENUMERATOR :: fortran_orm_op_col_f64 = 17_C_INT
    ! @brief Read text column (`1`-based index) into unpacked A1 `IBUF`.
    ENUMERATOR :: fortran_orm_op_col_a1 = 18_C_INT
    ! @brief Read text column (`1`-based index) into packed A4 `IBUF`.
    ENUMERATOR :: fortran_orm_op_col_a4 = 19_C_INT
    ! @brief Finalize and release integer statement slot.
    ENUMERATOR :: fortran_orm_op_finalize = 20_C_INT
    ! @brief Retrieve last inserted row ID into `IVAL`.
    ENUMERATOR :: fortran_orm_op_last_rowid = 21_C_INT
  END ENUM

  ! @brief Exact 38-digit base-10 fixed-point decimal POD structure (`BIND(C)`
  ! layout: 44 bytes, natural 4-byte alignment).
  TYPE, BIND(C) :: fortran_orm_decimal
    ! @brief `0` for non-negative, `1` for negative (`0` is always `0`).
    INTEGER(C_INT8_T) :: sign
    ! @brief Active precision in digits (`1..38`).
    INTEGER(C_INT8_T) :: precision
    ! @brief Fractional digits after radix point (`0..38`).
    INTEGER(C_INT8_T) :: scale
    ! @brief Unpacked base-10 digits (`0..9`), least-significant at index `0`.
    INTEGER(C_INT8_T), DIMENSION(38) :: digits
    ! @brief Explicit reserved padding bytes (`0`) for 44-byte ABI alignment.
    INTEGER(C_INT8_T), DIMENSION(3) :: reserved
  END TYPE fortran_orm_decimal

  ! @brief Connection pool & session telemetry snapshot (`BIND(C)` POD layout).
  TYPE, BIND(C) :: fortran_orm_pool_stats
    ! @brief Number of currently leased connections.
    INTEGER(C_INT64_T) :: active_connections
    ! @brief Number of currently idle connections in pool.
    INTEGER(C_INT64_T) :: idle_connections
    ! @brief Cumulative count of pool exhaustion events.
    INTEGER(C_INT64_T) :: exhaustion_count
    ! @brief Moving average acquisition wait time in milliseconds.
    REAL(C_DOUBLE) :: average_wait_time_ms
    ! @brief Cumulative count of queries exceeding slow-query threshold.
    INTEGER(C_INT64_T) :: slow_queries_logged
  END TYPE fortran_orm_pool_stats

  ! @brief Fixed-capacity C-interoperable POD record for OAuth2 tokens (`BIND(C)`
  ! compatible without nested heap pointers).
  TYPE, BIND(C) :: fortran_orm_oauth2_token_pod
    ! @brief NUL-terminated / blank-compatible bearer access token.
    CHARACTER(KIND=C_CHAR), DIMENSION(256) :: access_token
    ! @brief NUL-terminated refresh token.
    CHARACTER(KIND=C_CHAR), DIMENSION(256) :: refresh_token
    ! @brief NUL-terminated token type (e.g. `"Bearer"`).
    CHARACTER(KIND=C_CHAR), DIMENSION(64) :: token_type
    ! @brief Lifetime in seconds.
    INTEGER(C_INT32_T) :: expires_in
    ! @brief Explicit alignment padding before 64-bit timestamp.
    INTEGER(C_INT32_T) :: reserved_pad
    ! @brief Creation UNIX timestamp in seconds.
    INTEGER(C_INT64_T) :: created_at
    ! @brief Associated user identifier.
    CHARACTER(KIND=C_CHAR), DIMENSION(128) :: user_id
    ! @brief Space-delimited scope list.
    CHARACTER(KIND=C_CHAR), DIMENSION(256) :: scopes
  END TYPE fortran_orm_oauth2_token_pod

  INTERFACE
    ! @brief Copies the canonical symbolic name of `err` into a blank-padded
    ! Fortran character buffer (or NUL-free fixed buffer).
    ! @param[in] err Error code to format.
    ! @param[out] out_buf Destination character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed character length of the symbolic name.
    ! @return `FORTRAN_ORM_OK` on success, `FORTRAN_ORM_ERROR_NULL_POINTER` if
    ! `out_buf` or `out_len` is NULL, or `FORTRAN_ORM_ERROR_TRUNCATION` if
    ! `buf_cap` is smaller than the name length.
    FUNCTION fortran_orm_error_name(err, out_buf, buf_cap, out_len) BIND(C, NAME="fortran_orm_error_name") RESULT( &
      &cdd_ret_)
      IMPORT :: C_INT32_T, C_CHAR
      IMPLICIT NONE
      INTEGER(C_INT32_T), VALUE :: err
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_error_name

    ! @brief Writes the library semantic version into a blank-padded Fortran
    ! buffer.
    ! @param[out] out_buf Destination character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed length of the version string.
    ! @return `FORTRAN_ORM_OK` on success, or error code on NULL/truncation.
    FUNCTION fortran_orm_version(out_buf, buf_cap, out_len) BIND(C, NAME="fortran_orm_version") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_version

    ! @brief Converts an unpacked `A1` `INTEGER*4` character-code array (`1` ASCII
    ! codepoint per integer element) into a blank-padded character buffer.
    ! @param[in] a1_codes Input array of `count` 32-bit ASCII character codes.
    ! @param[in] count Number of elements in `a1_codes`.
    ! @param[out] out_buf Destination character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed string length.
    ! @return `FORTRAN_ORM_OK` on success, or error code on NULL/truncation.
    FUNCTION fortran_orm_a1_to_str(a1_codes, count, out_buf, buf_cap, out_len) BIND(C, NAME="fortran_orm_a1_to_str")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: a1_codes
      INTEGER(C_INT32_T), VALUE :: count
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_a1_to_str

    ! @brief Encodes a character buffer of length `str_len` into an unpacked `A1`
    ! `INTEGER*4` array (`1` ASCII codepoint per element, space-padded to `cap`).
    ! @param[in] str Source character buffer.
    ! @param[in] str_len Length of `str` in bytes.
    ! @param[out] out_a1 Destination `INTEGER*4` array of capacity `cap`.
    ! @param[in] cap Number of `INTEGER*4` slots in `out_a1`.
    ! @param[out] out_len Receives trimmed character length.
    ! @return `FORTRAN_ORM_OK` on success, or error code on NULL/truncation.
    FUNCTION fortran_orm_str_to_a1(str, str_len, out_a1, cap, out_len) BIND(C, NAME="fortran_orm_str_to_a1") RESULT( &
      &cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: str
      INTEGER(C_INT32_T), VALUE :: str_len
      TYPE(C_PTR), VALUE :: out_a1
      INTEGER(C_INT32_T), VALUE :: cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_str_to_a1

    ! @brief Connects to any supported `c-orm` backend (`sqlite://`, `memory://`,
    ! `postgres://`, `mysql://`, `db2://`, `odbc://`) from a Fortran string slice.
    ! @param[in] url Connection URL buffer (trailing spaces are trimmed).
    ! @param[in] url_len Byte length of `url`.
    ! @param[out] out_db Receives allocated database handle.
    ! @return `FORTRAN_ORM_OK` on success, or driver/memory error code.
    FUNCTION fortran_orm_connect(url, url_len, out_db) BIND(C, NAME="fortran_orm_connect") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: url
      INTEGER(C_INT32_T), VALUE :: url_len
      TYPE(C_PTR), INTENT(OUT) :: out_db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_connect

    ! @brief Connects to any supported `c-orm` backend from a NUL-terminated C
    ! string (`CHARACTER(KIND=C_CHAR)`).
    ! @param[in] url_cstr NUL-terminated connection URL.
    ! @param[out] out_db Receives allocated database handle.
    ! @return `FORTRAN_ORM_OK` on success, or driver/memory error code.
    FUNCTION fortran_orm_connect_cstr(url_cstr, out_db) BIND(C, NAME="fortran_orm_connect_cstr") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_PTR, C_INT32_T
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: url_cstr
      TYPE(C_PTR), INTENT(OUT) :: out_db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_connect_cstr

    ! @brief Closes and frees a database connection handle.
    ! @param[in,out] db Database handle to close.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
    FUNCTION fortran_orm_disconnect(db) BIND(C, NAME="fortran_orm_disconnect") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_disconnect

    ! @brief Executes a non-query DDL or DML SQL statement string slice.
    ! @param[in] db Active database handle.
    ! @param[in] sql SQL text buffer (trailing spaces trimmed).
    ! @param[in] sql_len Byte length of `sql`.
    ! @return `FORTRAN_ORM_OK` on success, or SQL error code.
    FUNCTION fortran_orm_exec_sql(db, sql, sql_len) BIND(C, NAME="fortran_orm_exec_sql") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_exec_sql

    ! @brief Executes a NUL-terminated DDL or DML SQL C string.
    ! @param[in] db Active database handle.
    ! @param[in] sql_cstr NUL-terminated SQL text.
    ! @return `FORTRAN_ORM_OK` on success, or SQL error code.
    FUNCTION fortran_orm_exec_cstr(db, sql_cstr) BIND(C, NAME="fortran_orm_exec_cstr") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: sql_cstr
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_exec_cstr

    ! @brief Copies the last driver error message into a blank-padded buffer.
    ! @param[in] db Active database handle.
    ! @param[out] out_buf Destination character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed message length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_last_error(db, out_buf, buf_cap, out_len) BIND(C, NAME="fortran_orm_last_error") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_last_error

    ! @brief Copies the last contextual diagnostic trace into a blank-padded
    ! buffer.
    ! @param[in] db Active database handle.
    ! @param[out] out_buf Destination character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed trace length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_last_trace(db, out_buf, buf_cap, out_len) BIND(C, NAME="fortran_orm_last_trace") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_last_trace

    ! @brief Retrieves the 64-bit row ID generated by the most recent `INSERT`.
    ! @param[in] db Active database handle.
    ! @param[out] out_rowid Receives 64-bit row ID.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_last_insert_rowid(db, out_rowid) BIND(C, NAME="fortran_orm_last_insert_rowid") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT64_T, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT64_T), INTENT(OUT) :: out_rowid
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_last_insert_rowid

    ! @brief Enables or disables the per-connection prepared-statement LRU cache.
    ! @param[in] db Active database handle.
    ! @param[in] capacity Maximum cached statements (`0` disables caching).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_enable_stmt_cache(db, capacity) BIND(C, NAME="fortran_orm_enable_stmt_cache") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T), VALUE :: capacity
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_enable_stmt_cache

    ! @brief Configures the session UTC offset and optional IANA timezone name.
    ! @param[in] db Active database handle.
    ! @param[in] offset_minutes Offset from UTC in minutes.
    ! @param[in] tz_name Optional timezone name buffer (may be empty).
    ! @param[in] tz_len Byte length of `tz_name`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_set_timezone(db, offset_minutes, tz_name, tz_len) BIND(C, NAME="fortran_orm_set_timezone")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T), VALUE :: offset_minutes
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: tz_name
      INTEGER(C_INT32_T), VALUE :: tz_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_set_timezone

    ! @brief Sets the slow-query threshold in milliseconds (`0` disables logging).
    ! @param[in] db Active database handle.
    ! @param[in] threshold_ms Slow-query threshold in milliseconds.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_set_slow_query_ms(db, threshold_ms) BIND(C, NAME="fortran_orm_set_slow_query_ms") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T), VALUE :: threshold_ms
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_set_slow_query_ms

    ! @brief Retrieves telemetry counters from a single database connection.
    ! @param[in] db Active database handle.
    ! @param[out] out_stats Receives connection telemetry snapshot.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_db_telemetry(db, out_stats) BIND(C, NAME="fortran_orm_db_telemetry") RESULT(cdd_ret_)
      IMPORT :: C_PTR, fortran_orm_pool_stats, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(fortran_orm_pool_stats), INTENT(OUT) :: out_stats
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_db_telemetry

    ! @brief Escapes a string literal against SQL injection using driver rules.
    ! @param[in] db Active database handle.
    ! @param[in] src Source string buffer (trailing spaces trimmed).
    ! @param[in] src_len Byte length of `src`.
    ! @param[out] out_buf Destination blank-padded character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives escaped string length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_escape_string(db, src, src_len, out_buf, buf_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_escape_string") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: src
      INTEGER(C_INT32_T), VALUE :: src_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_escape_string

    ! @brief Initializes a bounded thread-safe database connection pool.
    ! @param[in] url Connection URL buffer.
    ! @param[in] url_len Byte length of `url`.
    ! @param[in] min_conns Pre-warmed minimum connections (`>= 0`).
    ! @param[in] max_conns Maximum concurrent connections (`>= 1`).
    ! @param[in] timeout_ms Acquisition wait timeout in milliseconds.
    ! @param[out] out_pool Receives initialized pool handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_pool_init(url, url_len, min_conns, max_conns, timeout_ms, out_pool) BIND(C,  &
      &NAME="fortran_orm_pool_init") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: url
      INTEGER(C_INT32_T), VALUE :: url_len
      INTEGER(C_INT32_T), VALUE :: min_conns
      INTEGER(C_INT32_T), VALUE :: max_conns
      INTEGER(C_INT32_T), VALUE :: timeout_ms
      TYPE(C_PTR), INTENT(OUT) :: out_pool
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_pool_init

    ! @brief Leases an active database connection from `pool`.
    ! @param[in] pool Connection pool handle.
    ! @param[out] out_db Receives leased database handle (release with
    ! `fortran_orm_pool_release`).
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_TIMEOUT`.
    FUNCTION fortran_orm_pool_acquire(pool, out_db) BIND(C, NAME="fortran_orm_pool_acquire") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: pool
      TYPE(C_PTR), INTENT(OUT) :: out_db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_pool_acquire

    ! @brief Returns a leased connection back to `pool` and invalidates `db`
    ! wrapper.
    ! @param[in] pool Connection pool handle.
    ! @param[in,out] db Leased database handle wrapper to release.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_pool_release(pool, db) BIND(C, NAME="fortran_orm_pool_release") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: pool
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_pool_release

    ! @brief Snapshots live telemetry metrics from `pool`.
    ! @param[in] pool Connection pool handle.
    ! @param[out] out_stats Receives telemetry counters.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_pool_telemetry(pool, out_stats) BIND(C, NAME="fortran_orm_pool_telemetry") RESULT(cdd_ret_)
      IMPORT :: C_PTR, fortran_orm_pool_stats, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: pool
      TYPE(fortran_orm_pool_stats), INTENT(OUT) :: out_stats
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_pool_telemetry

    ! @brief Destroys `pool` and closes all idle connections.
    ! @param[in,out] pool Connection pool handle to destroy.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_pool_destroy(pool) BIND(C, NAME="fortran_orm_pool_destroy") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: pool
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_pool_destroy

    ! @brief Initializes a horizontal shard router for `num_shards` nodes.
    ! @param[in] num_shards Number of shard slots (`>= 1`).
    ! @param[out] out_shard Receives initialized shard manager handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_shard_init(num_shards, out_shard) BIND(C, NAME="fortran_orm_shard_init") RESULT(cdd_ret_)
      IMPORT :: C_INT32_T, C_PTR
      IMPLICIT NONE
      INTEGER(C_INT32_T), VALUE :: num_shards
      TYPE(C_PTR), INTENT(OUT) :: out_shard
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_shard_init

    ! @brief Binds `db` to 1-based shard slot `shard_idx` (`1..num_shards`).
    ! @param[in] shard Shard manager handle.
    ! @param[in] shard_idx 1-based shard index (`1..num_shards`).
    ! @param[in] db Connected database handle for this shard.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_shard_add_node(shard, shard_idx, db) BIND(C, NAME="fortran_orm_shard_add_node") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: shard
      INTEGER(C_INT32_T), VALUE :: shard_idx
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_shard_add_node

    ! @brief Routes `routing_key` via deterministic hash to a 1-based shard index.
    ! @param[in] shard Shard manager handle.
    ! @param[in] routing_key Routing key buffer (trailing spaces trimmed).
    ! @param[in] key_len Byte length of `routing_key`.
    ! @param[out] out_shard_idx Receives 1-based selected shard index.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_shard_route(shard, routing_key, key_len, out_shard_idx) BIND(C,  &
      &NAME="fortran_orm_shard_route") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: shard
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: routing_key
      INTEGER(C_INT32_T), VALUE :: key_len
      INTEGER(C_INT32_T), INTENT(OUT) :: out_shard_idx
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_shard_route

    ! @brief Frees a shard manager handle (does not close attached `db` nodes).
    ! @param[in,out] shard Shard manager handle to free.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_shard_free(shard) BIND(C, NAME="fortran_orm_shard_free") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: shard
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_shard_free

    ! @brief Begins an explicit database transaction on `db`.
    ! @param[in] db Active database handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_tx_begin(db) BIND(C, NAME="fortran_orm_tx_begin") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_tx_begin

    ! @brief Commits the active database transaction on `db`.
    ! @param[in] db Active database handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_tx_commit(db) BIND(C, NAME="fortran_orm_tx_commit") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_tx_commit

    ! @brief Rolls back the active database transaction on `db`.
    ! @param[in] db Active database handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_tx_rollback(db) BIND(C, NAME="fortran_orm_tx_rollback") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_tx_rollback

    ! @brief Creates a named transaction savepoint.
    ! @param[in] db Active database handle.
    ! @param[in] name Savepoint identifier buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `name`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_tx_savepoint(db, name, name_len) BIND(C, NAME="fortran_orm_tx_savepoint") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: name
      INTEGER(C_INT32_T), VALUE :: name_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_tx_savepoint

    ! @brief Releases a named transaction savepoint.
    ! @param[in] db Active database handle.
    ! @param[in] name Savepoint identifier buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `name`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_tx_release_sp(db, name, name_len) BIND(C, NAME="fortran_orm_tx_release_sp") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: name
      INTEGER(C_INT32_T), VALUE :: name_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_tx_release_sp

    ! @brief Rolls back to a named transaction savepoint.
    ! @param[in] db Active database handle.
    ! @param[in] name Savepoint identifier buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `name`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_tx_rollback_sp(db, name, name_len) BIND(C, NAME="fortran_orm_tx_rollback_sp") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: name
      INTEGER(C_INT32_T), VALUE :: name_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_tx_rollback_sp

    ! @brief Prepares a parameterized SQL statement (`?` or `$1..$N`).
    ! @param[in] db Active database handle.
    ! @param[in] sql SQL statement buffer (trailing spaces trimmed).
    ! @param[in] sql_len Byte length of `sql`.
    ! @param[out] out_stmt Receives prepared statement handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_prepare(db, sql, sql_len, out_stmt) BIND(C, NAME="fortran_orm_stmt_prepare") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), INTENT(OUT) :: out_stmt
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_prepare

    ! @brief Prepares or recycles a statement from `db`'s LRU statement cache.
    ! @param[in] db Active database handle.
    ! @param[in] sql SQL statement buffer (trailing spaces trimmed).
    ! @param[in] sql_len Byte length of `sql`.
    ! @param[out] out_stmt Receives cached statement handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_prepare_cached(db, sql, sql_len, out_stmt) BIND(C,  &
      &NAME="fortran_orm_stmt_prepare_cached") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), INTENT(OUT) :: out_stmt
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_prepare_cached

    ! @brief Binds a 32-bit signed integer to 1-based parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] val 32-bit integer value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_i32(stmt, param_idx, val) BIND(C, NAME="fortran_orm_stmt_bind_i32") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      INTEGER(C_INT32_T), VALUE :: val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_i32

    ! @brief Binds a 64-bit signed integer to 1-based parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] val 64-bit integer value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_i64(stmt, param_idx, val) BIND(C, NAME="fortran_orm_stmt_bind_i64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_INT64_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      INTEGER(C_INT64_T), VALUE :: val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_i64

    ! @brief Binds a 32-bit IEEE float (`REAL*4`) to 1-based parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] val 32-bit floating-point value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_f32(stmt, param_idx, val) BIND(C, NAME="fortran_orm_stmt_bind_f32") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_FLOAT
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      REAL(C_FLOAT), VALUE :: val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_f32

    ! @brief Binds a 64-bit IEEE double (`REAL*8` / `DOUBLE PRECISION`) to 1-based
    ! parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] val 64-bit floating-point value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_f64(stmt, param_idx, val) BIND(C, NAME="fortran_orm_stmt_bind_f64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_DOUBLE
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      REAL(C_DOUBLE), VALUE :: val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_f64

    ! @brief Binds a boolean/logical flag (`0` false, non-zero true) to 1-based
    ! parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] flag Logical value (`0` or non-zero).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_logical(stmt, param_idx, flag) BIND(C, NAME="fortran_orm_stmt_bind_logical")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      INTEGER(C_INT32_T), VALUE :: flag
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_logical

    ! @brief Binds a blank-trimmed Fortran string slice to 1-based parameter
    ! `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] val Source character buffer (trailing ASCII spaces trimmed).
    ! @param[in] val_len Byte length of `val`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_str(stmt, param_idx, val, val_len) BIND(C, NAME="fortran_orm_stmt_bind_str")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: val
      INTEGER(C_INT32_T), VALUE :: val_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_str

    ! @brief Binds an untrimmed fixed-length string slice (preserving trailing
    ! spaces) to 1-based parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] val Source character buffer.
    ! @param[in] val_len Exact byte length to preserve.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_str_raw(stmt, param_idx, val, val_len) BIND(C,  &
      &NAME="fortran_orm_stmt_bind_str_raw") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: val
      INTEGER(C_INT32_T), VALUE :: val_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_str_raw

    ! @brief Binds raw binary bytes (`BLOB`) to 1-based parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] data Binary byte buffer.
    ! @param[in] data_len Byte count to bind.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_blob(stmt, param_idx, data_, data_len) BIND(C, NAME="fortran_orm_stmt_bind_blob")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      TYPE(C_PTR), VALUE :: data_
      INTEGER(C_INT32_T), VALUE :: data_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_blob

    ! @brief Binds an exact 38-digit decimal value to 1-based parameter
    ! `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @param[in] dec Exact decimal structure.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_decimal(stmt, param_idx, dec) BIND(C, NAME="fortran_orm_stmt_bind_decimal") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, fortran_orm_decimal
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      TYPE(fortran_orm_decimal), INTENT(IN) :: dec
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_decimal

    ! @brief Binds SQL `NULL` to 1-based parameter `param_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] param_idx 1-based parameter position (`>= 1`).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_bind_null(stmt, param_idx) BIND(C, NAME="fortran_orm_stmt_bind_null") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: param_idx
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_bind_null

    ! @brief Advances execution of `stmt` by one row.
    ! @param[in] stmt Prepared statement handle.
    ! @param[out] out_has_row Receives `1` if a row is available, `0` if complete.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_step(stmt, out_has_row) BIND(C, NAME="fortran_orm_stmt_step") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), INTENT(OUT) :: out_has_row
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_step

    ! @brief Resets `stmt` for re-execution with new parameter bindings.
    ! @param[in] stmt Prepared statement handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_reset(stmt) BIND(C, NAME="fortran_orm_stmt_reset") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_reset

    ! @brief Finalizes (or returns to LRU cache) and frees `stmt`.
    ! @param[in,out] stmt Prepared statement handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_finalize(stmt) BIND(C, NAME="fortran_orm_stmt_finalize") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_finalize

    ! @brief Queries the number of result columns on `stmt`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[out] out_count Receives result column count.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_count(stmt, out_count) BIND(C, NAME="fortran_orm_stmt_col_count") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), INTENT(OUT) :: out_count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_count

    ! @brief Copies the 1-based result column name (`1..col_count`) into `out_buf`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_buf Destination blank-padded character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed column name length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_name(stmt, col_idx, out_buf, buf_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_stmt_col_name") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_name

    ! @brief Checks whether 1-based result column `col_idx` is SQL `NULL`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_is_null Receives `1` if `NULL`, `0` otherwise.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_is_null(stmt, col_idx, out_is_null) BIND(C, NAME="fortran_orm_stmt_col_is_null")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      INTEGER(C_INT32_T), INTENT(OUT) :: out_is_null
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_is_null

    ! @brief Reads a 32-bit signed integer from 1-based result column `col_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_val Receives 32-bit integer value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_i32(stmt, col_idx, out_val) BIND(C, NAME="fortran_orm_stmt_col_i32") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      INTEGER(C_INT32_T), INTENT(OUT) :: out_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_i32

    ! @brief Reads a 64-bit signed integer from 1-based result column `col_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_val Receives 64-bit integer value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_i64(stmt, col_idx, out_val) BIND(C, NAME="fortran_orm_stmt_col_i64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_INT64_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      INTEGER(C_INT64_T), INTENT(OUT) :: out_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_i64

    ! @brief Reads a 32-bit IEEE float (`REAL*4`) from 1-based column `col_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_val Receives 32-bit float value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_f32(stmt, col_idx, out_val) BIND(C, NAME="fortran_orm_stmt_col_f32") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_FLOAT
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      REAL(C_FLOAT), INTENT(OUT) :: out_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_f32

    ! @brief Reads a 64-bit IEEE double (`REAL*8`) from 1-based column `col_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_val Receives 64-bit double value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_f64(stmt, col_idx, out_val) BIND(C, NAME="fortran_orm_stmt_col_f64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_DOUBLE
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      REAL(C_DOUBLE), INTENT(OUT) :: out_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_f64

    ! @brief Reads a logical flag (`0` / `1`) from 1-based column `col_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_flag Receives `0` for zero, `1` for non-zero.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_logical(stmt, col_idx, out_flag) BIND(C, NAME="fortran_orm_stmt_col_logical")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      INTEGER(C_INT32_T), INTENT(OUT) :: out_flag
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_logical

    ! @brief Reads a text string from 1-based column `col_idx` into blank-padded
    ! `out_buf`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_buf Destination blank-padded character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives actual string byte length.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_TRUNCATION`.
    FUNCTION fortran_orm_stmt_col_str(stmt, col_idx, out_buf, buf_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_stmt_col_str") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_str

    ! @brief Reads raw binary `BLOB` bytes from 1-based column `col_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_buf Destination byte buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives actual blob byte length.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_TRUNCATION`.
    FUNCTION fortran_orm_stmt_col_blob(stmt, col_idx, out_buf, buf_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_stmt_col_blob") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      TYPE(C_PTR), VALUE :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_blob

    ! @brief Reads an exact 38-digit decimal value from 1-based column `col_idx`.
    ! @param[in] stmt Prepared statement handle.
    ! @param[in] col_idx 1-based column index (`>= 1`).
    ! @param[out] out_dec Receives exact decimal value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_stmt_col_decimal(stmt, col_idx, out_dec) BIND(C, NAME="fortran_orm_stmt_col_decimal") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, fortran_orm_decimal
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_dec
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_stmt_col_decimal

    ! @brief Batch-inserts a contiguous 1D `INTEGER*4` vector using a single-param
    ! `INSERT` statement (`?`) inside a savepoint/transaction.
    ! @param[in] db Active database handle.
    ! @param[in] insert_sql Parameterized SQL (e.g. `INSERT INTO v VALUES (?)`).
    ! @param[in] sql_len Byte length of `insert_sql`.
    ! @param[in] vec Contiguous 32-bit integer array.
    ! @param[in] count Number of elements in `vec`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_insert_vec_i32(db, insert_sql, sql_len, vec, count) BIND(C,  &
      &NAME="fortran_orm_insert_vec_i32") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: insert_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: vec
      INTEGER(C_INT32_T), VALUE :: count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_insert_vec_i32

    ! @brief Batch-inserts a contiguous 1D `INTEGER*8` vector.
    ! @param[in] db Active database handle.
    ! @param[in] insert_sql Parameterized SQL (`INSERT INTO v VALUES (?)`).
    ! @param[in] sql_len Byte length of `insert_sql`.
    ! @param[in] vec Contiguous 64-bit integer array.
    ! @param[in] count Number of elements in `vec`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_insert_vec_i64(db, insert_sql, sql_len, vec, count) BIND(C,  &
      &NAME="fortran_orm_insert_vec_i64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: insert_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: vec
      INTEGER(C_INT32_T), VALUE :: count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_insert_vec_i64

    ! @brief Batch-inserts a contiguous 1D `DOUBLE PRECISION` (`REAL*8`) vector.
    ! @param[in] db Active database handle.
    ! @param[in] insert_sql Parameterized SQL (`INSERT INTO v VALUES (?)`).
    ! @param[in] sql_len Byte length of `insert_sql`.
    ! @param[in] vec Contiguous `double` array.
    ! @param[in] count Number of elements in `vec`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_insert_vec_f64(db, insert_sql, sql_len, vec, count) BIND(C,  &
      &NAME="fortran_orm_insert_vec_f64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: insert_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: vec
      INTEGER(C_INT32_T), VALUE :: count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_insert_vec_f64

    ! @brief Executes `select_sql` and hydrates column 1 into a 1D `INTEGER*4`
    ! vector.
    ! @param[in] db Active database handle.
    ! @param[in] select_sql `SELECT` query buffer.
    ! @param[in] sql_len Byte length of `select_sql`.
    ! @param[out] out_vec Destination 32-bit integer array.
    ! @param[in] cap_elems Maximum element capacity of `out_vec`.
    ! @param[out] out_count Receives number of elements hydrated.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
    FUNCTION fortran_orm_query_vec_i32(db, select_sql, sql_len, out_vec, cap_elems, out_count) BIND(C,  &
      &NAME="fortran_orm_query_vec_i32") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: select_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: out_vec
      INTEGER(C_INT32_T), VALUE :: cap_elems
      INTEGER(C_INT32_T), INTENT(OUT) :: out_count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_query_vec_i32

    ! @brief Executes `select_sql` and hydrates column 1 into a 1D `INTEGER*8`
    ! vector.
    ! @param[in] db Active database handle.
    ! @param[in] select_sql `SELECT` query buffer.
    ! @param[in] sql_len Byte length of `select_sql`.
    ! @param[out] out_vec Destination 64-bit integer array.
    ! @param[in] cap_elems Maximum element capacity of `out_vec`.
    ! @param[out] out_count Receives number of elements hydrated.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
    FUNCTION fortran_orm_query_vec_i64(db, select_sql, sql_len, out_vec, cap_elems, out_count) BIND(C,  &
      &NAME="fortran_orm_query_vec_i64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: select_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: out_vec
      INTEGER(C_INT32_T), VALUE :: cap_elems
      INTEGER(C_INT32_T), INTENT(OUT) :: out_count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_query_vec_i64

    ! @brief Executes `select_sql` and hydrates column 1 into a 1D `REAL*8` vector.
    ! @param[in] db Active database handle.
    ! @param[in] select_sql `SELECT` query buffer.
    ! @param[in] sql_len Byte length of `select_sql`.
    ! @param[out] out_vec Destination `double` array.
    ! @param[in] cap_elems Maximum element capacity of `out_vec`.
    ! @param[out] out_count Receives number of elements hydrated.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
    FUNCTION fortran_orm_query_vec_f64(db, select_sql, sql_len, out_vec, cap_elems, out_count) BIND(C,  &
      &NAME="fortran_orm_query_vec_f64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: select_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: out_vec
      INTEGER(C_INT32_T), VALUE :: cap_elems
      INTEGER(C_INT32_T), INTENT(OUT) :: out_count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_query_vec_f64

    ! @brief Batch-persists a Fortran column-major 2D `DOUBLE PRECISION` matrix
    ! `A(ld_rows, n_cols)` (`element(r, c) = matrix[c * ld_rows + r]` for `0`-based
    ! `r < n_rows, c < n_cols`) using a parameterized `INSERT` with `n_cols` `?`
    ! placeholders.
    ! @param[in] db Active database handle.
    ! @param[in] insert_sql Parameterized SQL with `n_cols` placeholders.
    ! @param[in] sql_len Byte length of `insert_sql`.
    ! @param[in] matrix_col_major Column-major `double` buffer.
    ! @param[in] ld_rows Leading dimension (`>= n_rows`) of the Fortran array.
    ! @param[in] n_rows Number of active rows to insert.
    ! @param[in] n_cols Number of active columns (`>= 1`).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_insert_matrix_f64(db, insert_sql, sql_len, matrix_col_major, ld_rows, n_rows, n_cols) BIND(C, &
      &NAME="fortran_orm_insert_matrix_f64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: insert_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: matrix_col_major
      INTEGER(C_INT32_T), VALUE :: ld_rows
      INTEGER(C_INT32_T), VALUE :: n_rows
      INTEGER(C_INT32_T), VALUE :: n_cols
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_insert_matrix_f64

    ! @brief Hydrates a multi-column numeric SQL `SELECT` directly into a Fortran
    ! column-major 2D `DOUBLE PRECISION` matrix `A(ld_rows, n_cols)` without
    ! transpose copies.
    ! @param[in] db Active database handle.
    ! @param[in] select_sql `SELECT` query returning at least `n_cols` columns.
    ! @param[in] sql_len Byte length of `select_sql`.
    ! @param[out] out_matrix Column-major `double` buffer (`ld_rows * n_cols`).
    ! @param[in] ld_rows Leading dimension (`>= max_rows`) of `out_matrix`.
    ! @param[in] max_rows Maximum rows to write (`<= ld_rows`).
    ! @param[in] n_cols Number of numeric columns to extract (`>= 1`).
    ! @param[out] out_rows Receives number of rows hydrated.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
    FUNCTION fortran_orm_query_matrix_f64(db, select_sql, sql_len, out_matrix, ld_rows, max_rows, n_cols, out_rows)  &
      &BIND(C, NAME="fortran_orm_query_matrix_f64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: select_sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), VALUE :: out_matrix
      INTEGER(C_INT32_T), VALUE :: ld_rows
      INTEGER(C_INT32_T), VALUE :: max_rows
      INTEGER(C_INT32_T), VALUE :: n_cols
      INTEGER(C_INT32_T), INTENT(OUT) :: out_rows
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_query_matrix_f64

    ! @brief Creates a dynamic `c_orm_table_meta_t` builder for a Fortran
    ! `TYPE, BIND(C)` derived type of byte size `struct_size`.
    ! @param[in] table_name SQL table identifier buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `table_name`.
    ! @param[in] struct_size Total byte size of the `BIND(C)` Fortran struct.
    ! @param[out] out_schema Receives allocated runtime schema handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_schema_create(table_name, name_len, struct_size, out_schema) BIND(C,  &
      &NAME="fortran_orm_schema_create") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: table_name
      INTEGER(C_INT32_T), VALUE :: name_len
      INTEGER(C_INT32_T), VALUE :: struct_size
      TYPE(C_PTR), INTENT(OUT) :: out_schema
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_schema_create

    ! @brief Appends a mapped column descriptor to `schema`.
    ! For `FORTRAN_ORM_COL_CHAR_FIXED`, the field in the Fortran `BIND(C)` struct
    ! is a fixed `char[fixed_len]` buffer (blank-padded or NUL-terminated) rather
    ! than a `char *` heap pointer.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] col_name Column identifier buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `col_name`.
    ! @param[in] col_type Column data type enum.
    ! @param[in] byte_offset 0-based byte offset within the `BIND(C)` struct.
    ! @param[in] fixed_len Fixed byte width for `CHAR_FIXED` (`0` otherwise).
    ! @param[in] is_pk Non-zero if primary key column.
    ! @param[in] is_nullable Non-zero if column permits SQL `NULL`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_schema_add_col(schema, col_name, name_len, col_type, byte_offset, fixed_len, is_pk,  &
      &is_nullable) BIND(C, NAME="fortran_orm_schema_add_col") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: schema
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col_name
      INTEGER(C_INT32_T), VALUE :: name_len
      INTEGER(C_INT32_T), VALUE :: col_type
      INTEGER(C_INT32_T), VALUE :: byte_offset
      INTEGER(C_INT32_T), VALUE :: fixed_len
      INTEGER(C_INT32_T), VALUE :: is_pk
      INTEGER(C_INT32_T), VALUE :: is_nullable
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_schema_add_col

    ! @brief Registers a foreign-key relationship metadata descriptor on `schema`.
    ! @param[in,out] schema Parent runtime schema handle.
    ! @param[in] field_name Relation name buffer.
    ! @param[in] field_len Byte length of `field_name`.
    ! @param[in] rel_kind Relationship kind enum.
    ! @param[in] target_schema Target table runtime schema handle.
    ! @param[in] fk_col Foreign key column name buffer.
    ! @param[in] fk_len Byte length of `fk_col`.
    ! @param[in] local_col Local key column name buffer.
    ! @param[in] local_len Byte length of `local_col`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_schema_add_relation(schema, field_name, field_len, rel_kind, target_schema, fk_col, fk_len,  &
      &local_col, local_len) BIND(C, NAME="fortran_orm_schema_add_relation") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: schema
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: field_name
      INTEGER(C_INT32_T), VALUE :: field_len
      INTEGER(C_INT32_T), VALUE :: rel_kind
      TYPE(C_PTR), VALUE :: target_schema
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: fk_col
      INTEGER(C_INT32_T), VALUE :: fk_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: local_col
      INTEGER(C_INT32_T), VALUE :: local_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_schema_add_relation

    ! @brief Finalizes SQL query templates on `schema` and emits `CREATE TABLE IF
    ! NOT EXISTS` DDL into `out_ddl`.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[out] out_ddl Destination blank-padded DDL buffer.
    ! @param[in] ddl_cap Capacity of `out_ddl` in bytes.
    ! @param[out] out_len Receives trimmed DDL length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_schema_build_ddl(schema, out_ddl, ddl_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_schema_build_ddl") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: schema
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_ddl
      INTEGER(C_INT32_T), VALUE :: ddl_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_schema_build_ddl

    ! @brief Creates the SQL table defined by `schema` on `db`.
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_crud_create_table(db, schema) BIND(C, NAME="fortran_orm_crud_create_table") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_create_table

    ! @brief Inserts a single `BIND(C)` Fortran struct instance (`C_LOC(rec)`).
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] in_record Pointer to `BIND(C)` Fortran struct (`TYPE(C_PTR)`).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_crud_insert(db, schema, in_record) BIND(C, NAME="fortran_orm_crud_insert") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      TYPE(C_PTR), VALUE :: in_record
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_insert

    ! @brief Dialect-aware atomic `UPSERT` (`ON CONFLICT` / `MERGE INTO`) of a
    ! `BIND(C)` Fortran struct instance.
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] in_record Pointer to `BIND(C)` Fortran struct.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_crud_upsert(db, schema, in_record) BIND(C, NAME="fortran_orm_crud_upsert") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      TYPE(C_PTR), VALUE :: in_record
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_upsert

    ! @brief Updates an existing row matching the primary key in `in_record`.
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] in_record Pointer to `BIND(C)` Fortran struct.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_crud_update(db, schema, in_record) BIND(C, NAME="fortran_orm_crud_update") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      TYPE(C_PTR), VALUE :: in_record
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_update

    ! @brief Performs an optimistic-locked `UPDATE` checking and incrementing
    ! integer `version_col` (returns `FORTRAN_ORM_ERROR_NOT_FOUND` on conflict).
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] version_col Version column name buffer.
    ! @param[in] col_len Byte length of `version_col`.
    ! @param[in] in_record Pointer to `BIND(C)` Fortran struct.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
    FUNCTION fortran_orm_crud_update_optimistic(db, schema, version_col, col_len, in_record) BIND(C,  &
      &NAME="fortran_orm_crud_update_optimistic") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: version_col
      INTEGER(C_INT32_T), VALUE :: col_len
      TYPE(C_PTR), VALUE :: in_record
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_update_optimistic

    ! @brief Finds and hydrates a single `BIND(C)` Fortran struct by 32-bit PK.
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] id_val 32-bit primary key value.
    ! @param[out] out_record Pointer to pre-allocated `BIND(C)` Fortran struct.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
    FUNCTION fortran_orm_crud_find_i32(db, schema, id_val, out_record) BIND(C, NAME="fortran_orm_crud_find_i32")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      INTEGER(C_INT32_T), VALUE :: id_val
      TYPE(C_PTR), VALUE :: out_record
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_find_i32

    ! @brief Finds a single `BIND(C)` Fortran struct with pessimistic `FOR UPDATE`
    ! row locking.
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] id_val 32-bit primary key value.
    ! @param[out] out_record Pointer to pre-allocated `BIND(C)` Fortran struct.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
    FUNCTION fortran_orm_crud_find_for_update_i32(db, schema, id_val, out_record) BIND(C,  &
      &NAME="fortran_orm_crud_find_for_update_i32") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      INTEGER(C_INT32_T), VALUE :: id_val
      TYPE(C_PTR), VALUE :: out_record
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_find_for_update_i32

    ! @brief Checks whether a row with 32-bit primary key `id_val` exists.
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] id_val 32-bit primary key value.
    ! @param[out] out_exists Receives `1` if present, `0` otherwise.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_crud_exists_i32(db, schema, id_val, out_exists) BIND(C, NAME="fortran_orm_crud_exists_i32")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      INTEGER(C_INT32_T), VALUE :: id_val
      INTEGER(C_INT32_T), INTENT(OUT) :: out_exists
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_exists_i32

    ! @brief Deletes a row by 32-bit primary key `id_val`.
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[in] id_val 32-bit primary key value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_crud_delete_i32(db, schema, id_val) BIND(C, NAME="fortran_orm_crud_delete_i32") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      INTEGER(C_INT32_T), VALUE :: id_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_delete_i32

    ! @brief Hydrates all rows of `schema` into a contiguous Fortran array of
    ! `BIND(C)` structs (`max_records * struct_size` bytes).
    ! @param[in] db Active database handle.
    ! @param[in,out] schema Runtime schema handle.
    ! @param[out] out_array Contiguous array of `BIND(C)` structs.
    ! @param[in] max_records Capacity of `out_array` in records.
    ! @param[out] out_count Receives number of records hydrated.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL`.
    FUNCTION fortran_orm_crud_find_all(db, schema, out_array, max_records, out_count) BIND(C,  &
      &NAME="fortran_orm_crud_find_all") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: schema
      TYPE(C_PTR), VALUE :: out_array
      INTEGER(C_INT32_T), VALUE :: max_records
      INTEGER(C_INT32_T), INTENT(OUT) :: out_count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_crud_find_all

    ! @brief Frees a runtime schema handle and all owned column/query strings.
    ! @param[in,out] schema Runtime schema handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_schema_free(schema) BIND(C, NAME="fortran_orm_schema_free") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: schema
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_schema_free

    ! @brief Executes arbitrary `SELECT` SQL and hydrates all rows into a dynamic
    ! `cdd_c_abstract_struct_array_t` result-set handle.
    ! @param[in] db Active database handle.
    ! @param[in] sql `SELECT` SQL buffer (trailing spaces trimmed).
    ! @param[in] sql_len Byte length of `sql`.
    ! @param[out] out_rs Receives dynamic result-set handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_query_abstract(db, sql, sql_len, out_rs) BIND(C, NAME="fortran_orm_query_abstract") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: sql
      INTEGER(C_INT32_T), VALUE :: sql_len
      TYPE(C_PTR), INTENT(OUT) :: out_rs
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_query_abstract

    ! @brief Queries total number of rows in dynamic result set `rs`.
    ! @param[in] rs Result-set handle.
    ! @param[out] out_rows Receives row count.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_row_count(rs, out_rows) BIND(C, NAME="fortran_orm_rs_row_count") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T), INTENT(OUT) :: out_rows
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_row_count

    ! @brief Queries column count of 1-based row `row_idx` (`1..row_count`).
    ! @param[in] rs Result-set handle.
    ! @param[in] row_idx 1-based row index.
    ! @param[out] out_cols Receives column count.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_col_count(rs, row_idx, out_cols) BIND(C, NAME="fortran_orm_rs_col_count") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T), VALUE :: row_idx
      INTEGER(C_INT32_T), INTENT(OUT) :: out_cols
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_col_count

    ! @brief Copies the name of 1-based `(row_idx, col_idx)` into `out_buf`.
    ! @param[in] rs Result-set handle.
    ! @param[in] row_idx 1-based row index.
    ! @param[in] col_idx 1-based column index.
    ! @param[out] out_buf Destination blank-padded character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed column name length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_col_name(rs, row_idx, col_idx, out_buf, buf_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_rs_col_name") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T), VALUE :: row_idx
      INTEGER(C_INT32_T), VALUE :: col_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_col_name

    ! @brief Checks whether column `col_name` on 1-based `row_idx` is `NULL`.
    ! @param[in] rs Result-set handle.
    ! @param[in] row_idx 1-based row index.
    ! @param[in] col_name Column name buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `col_name`.
    ! @param[out] out_is_null Receives `1` if `NULL`, `0` otherwise.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_is_null(rs, row_idx, col_name, name_len, out_is_null) BIND(C,  &
      &NAME="fortran_orm_rs_is_null") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T), VALUE :: row_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col_name
      INTEGER(C_INT32_T), VALUE :: name_len
      INTEGER(C_INT32_T), INTENT(OUT) :: out_is_null
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_is_null

    ! @brief Reads a 64-bit integer by column name from 1-based `row_idx`.
    ! @param[in] rs Result-set handle.
    ! @param[in] row_idx 1-based row index.
    ! @param[in] col_name Column name buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `col_name`.
    ! @param[out] out_val Receives 64-bit integer value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_get_i64(rs, row_idx, col_name, name_len, out_val) BIND(C, NAME="fortran_orm_rs_get_i64")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR, C_INT64_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T), VALUE :: row_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col_name
      INTEGER(C_INT32_T), VALUE :: name_len
      INTEGER(C_INT64_T), INTENT(OUT) :: out_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_get_i64

    ! @brief Reads a `DOUBLE PRECISION` value by column name from 1-based
    ! `row_idx`.
    ! @param[in] rs Result-set handle.
    ! @param[in] row_idx 1-based row index.
    ! @param[in] col_name Column name buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `col_name`.
    ! @param[out] out_val Receives `double` value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_get_f64(rs, row_idx, col_name, name_len, out_val) BIND(C, NAME="fortran_orm_rs_get_f64")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR, C_DOUBLE
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T), VALUE :: row_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col_name
      INTEGER(C_INT32_T), VALUE :: name_len
      REAL(C_DOUBLE), INTENT(OUT) :: out_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_get_f64

    ! @brief Reads a blank-padded string by column name from 1-based `row_idx`.
    ! @param[in] rs Result-set handle.
    ! @param[in] row_idx 1-based row index.
    ! @param[in] col_name Column name buffer (trailing spaces trimmed).
    ! @param[in] name_len Byte length of `col_name`.
    ! @param[out] out_buf Destination blank-padded character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed string length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_get_str(rs, row_idx, col_name, name_len, out_buf, buf_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_rs_get_str") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T), VALUE :: row_idx
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col_name
      INTEGER(C_INT32_T), VALUE :: name_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_get_str

    ! @brief Serializes dynamic result set `rs` into a JSON array string.
    ! @param[in] rs Result-set handle.
    ! @param[out] out_json Destination blank-padded character buffer.
    ! @param[in] json_cap Capacity of `out_json` in bytes.
    ! @param[out] out_len Receives JSON byte length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_to_json(rs, out_json, json_cap, out_len) BIND(C, NAME="fortran_orm_rs_to_json") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_json
      INTEGER(C_INT32_T), VALUE :: json_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_to_json

    ! @brief Frees a dynamic result-set handle.
    ! @param[in,out] rs Result-set handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_rs_free(rs) BIND(C, NAME="fortran_orm_rs_free") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: rs
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_rs_free

    ! @brief Creates a `SELECT <columns> FROM <table>` arena-backed AST builder.
    ! @param[in] table Table identifier buffer (trailing spaces trimmed).
    ! @param[in] table_len Byte length of `table`.
    ! @param[in] columns Comma-separated projection buffer (e.g. `"*"`).
    ! @param[in] cols_len Byte length of `columns`.
    ! @param[out] out_ast Receives allocated AST query handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_select(table, table_len, columns, cols_len, out_ast) BIND(C,  &
      &NAME="fortran_orm_ast_select") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: table
      INTEGER(C_INT32_T), VALUE :: table_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: columns
      INTEGER(C_INT32_T), VALUE :: cols_len
      TYPE(C_PTR), INTENT(OUT) :: out_ast
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_select

    ! @brief Creates an `INSERT INTO <table>` arena-backed AST builder.
    ! @param[in] table Table identifier buffer.
    ! @param[in] table_len Byte length of `table`.
    ! @param[out] out_ast Receives allocated AST query handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_insert(table, table_len, out_ast) BIND(C, NAME="fortran_orm_ast_insert") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: table
      INTEGER(C_INT32_T), VALUE :: table_len
      TYPE(C_PTR), INTENT(OUT) :: out_ast
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_insert

    ! @brief Creates an `UPDATE <table>` arena-backed AST builder.
    ! @param[in] table Table identifier buffer.
    ! @param[in] table_len Byte length of `table`.
    ! @param[out] out_ast Receives allocated AST query handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_update(table, table_len, out_ast) BIND(C, NAME="fortran_orm_ast_update") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: table
      INTEGER(C_INT32_T), VALUE :: table_len
      TYPE(C_PTR), INTENT(OUT) :: out_ast
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_update

    ! @brief Creates a `DELETE FROM <table>` arena-backed AST builder.
    ! @param[in] table Table identifier buffer.
    ! @param[in] table_len Byte length of `table`.
    ! @param[out] out_ast Receives allocated AST query handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_delete(table, table_len, out_ast) BIND(C, NAME="fortran_orm_ast_delete") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: table
      INTEGER(C_INT32_T), VALUE :: table_len
      TYPE(C_PTR), INTENT(OUT) :: out_ast
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_delete

    ! @brief Enables `SELECT DISTINCT` on `ast`.
    ! @param[in,out] ast AST handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_distinct(ast) BIND(C, NAME="fortran_orm_ast_distinct") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_distinct

    ! @brief Appends an integer comparison `WHERE` / `AND` predicate (`=`, `!=`,
    ! `<`, `>`).
    ! @param[in,out] ast AST handle.
    ! @param[in] col Column name buffer.
    ! @param[in] col_len Byte length of `col`.
    ! @param[in] op_str Operator (`"="`, `"!="`, `"<"`, `">"`).
    ! @param[in] op_len Byte length of `op_str`.
    ! @param[in] val 64-bit integer value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_where_i64(ast, col, col_len, op_str, op_len, val) BIND(C,  &
      &NAME="fortran_orm_ast_where_i64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T, C_INT64_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col
      INTEGER(C_INT32_T), VALUE :: col_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: op_str
      INTEGER(C_INT32_T), VALUE :: op_len
      INTEGER(C_INT64_T), VALUE :: val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_where_i64

    ! @brief Appends a string comparison `WHERE` / `AND` predicate (`=`, `!=`,
    ! `LIKE`).
    ! @param[in,out] ast AST handle.
    ! @param[in] col Column name buffer.
    ! @param[in] col_len Byte length of `col`.
    ! @param[in] op_str Operator (`"="`, `"!="`, `"LIKE"`).
    ! @param[in] op_len Byte length of `op_str`.
    ! @param[in] val String literal buffer.
    ! @param[in] val_len Byte length of `val`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_where_str(ast, col, col_len, op_str, op_len, val, val_len) BIND(C,  &
      &NAME="fortran_orm_ast_where_str") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col
      INTEGER(C_INT32_T), VALUE :: col_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: op_str
      INTEGER(C_INT32_T), VALUE :: op_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: val
      INTEGER(C_INT32_T), VALUE :: val_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_where_str

    ! @brief Appends a `JOIN` clause (`INNER`, `LEFT`, `RIGHT`) to `ast`.
    ! @param[in,out] ast AST handle.
    ! @param[in] join_type Join type (`"INNER"`, `"LEFT"`, `"RIGHT"`).
    ! @param[in] type_len Byte length of `join_type`.
    ! @param[in] table Joined table name buffer.
    ! @param[in] table_len Byte length of `table`.
    ! @param[in] on_sql Raw `ON` condition expression (e.g. `"a.id = b.a_id"`).
    ! @param[in] on_len Byte length of `on_sql`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_join(ast, join_type, type_len, table, table_len, on_sql, on_len) BIND(C,  &
      &NAME="fortran_orm_ast_join") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: join_type
      INTEGER(C_INT32_T), VALUE :: type_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: table
      INTEGER(C_INT32_T), VALUE :: table_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: on_sql
      INTEGER(C_INT32_T), VALUE :: on_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_join

    ! @brief Appends `GROUP BY` and optional `HAVING` expression to `ast`.
    ! @param[in,out] ast AST handle.
    ! @param[in] group_cols Comma-separated `GROUP BY` column list.
    ! @param[in] group_len Byte length of `group_cols`.
    ! @param[in] having_sql Optional `HAVING` raw expression (`0` length to skip).
    ! @param[in] having_len Byte length of `having_sql`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_group_having(ast, group_cols, group_len, having_sql, having_len) BIND(C,  &
      &NAME="fortran_orm_ast_group_having") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: group_cols
      INTEGER(C_INT32_T), VALUE :: group_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: having_sql
      INTEGER(C_INT32_T), VALUE :: having_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_group_having

    ! @brief Appends `ORDER BY`, `LIMIT`, and `OFFSET` clauses to `ast`.
    ! @param[in,out] ast AST handle.
    ! @param[in] order_col Sort column (`0` length to skip `ORDER BY`).
    ! @param[in] col_len Byte length of `order_col`.
    ! @param[in] descending Non-zero for `DESC`, `0` for `ASC`.
    ! @param[in] limit_rows Maximum rows (`0` to skip `LIMIT`).
    ! @param[in] offset_rows Initial rows to skip (`0` to skip `OFFSET`).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_order_limit(ast, order_col, col_len, descending, limit_rows, offset_rows) BIND(C,  &
      &NAME="fortran_orm_ast_order_limit") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: order_col
      INTEGER(C_INT32_T), VALUE :: col_len
      INTEGER(C_INT32_T), VALUE :: descending
      INTEGER(C_INT32_T), VALUE :: limit_rows
      INTEGER(C_INT32_T), VALUE :: offset_rows
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_order_limit

    ! @brief Appends a column assignment (`INSERT` / `UPDATE`) with a 64-bit
    ! integer value.
    ! @param[in,out] ast AST handle.
    ! @param[in] col Column name buffer.
    ! @param[in] col_len Byte length of `col`.
    ! @param[in] val 64-bit integer value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_set_i64(ast, col, col_len, val) BIND(C, NAME="fortran_orm_ast_set_i64") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T, C_INT64_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col
      INTEGER(C_INT32_T), VALUE :: col_len
      INTEGER(C_INT64_T), VALUE :: val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_set_i64

    ! @brief Appends a column assignment (`INSERT` / `UPDATE`) with a string value.
    ! @param[in,out] ast AST handle.
    ! @param[in] col Column name buffer.
    ! @param[in] col_len Byte length of `col`.
    ! @param[in] val String value buffer.
    ! @param[in] val_len Byte length of `val`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_set_str(ast, col, col_len, val, val_len) BIND(C, NAME="fortran_orm_ast_set_str") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: col
      INTEGER(C_INT32_T), VALUE :: col_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: val
      INTEGER(C_INT32_T), VALUE :: val_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_set_str

    ! @brief Appends `RETURNING` projection and/or Db2 isolation lock clause (`1`
    ! UR, `2` CS, `3` RS, `4` RR, `5` FOR FETCH ONLY).
    ! @param[in,out] ast AST handle.
    ! @param[in] returning_cols Returning columns (`0` length to skip).
    ! @param[in] ret_len Byte length of `returning_cols`.
    ! @param[in] db2_lock_mode Db2 lock mode (`0` none, `1..5`).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_returning_lock(ast, returning_cols, ret_len, db2_lock_mode) BIND(C,  &
      &NAME="fortran_orm_ast_returning_lock") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: returning_cols
      INTEGER(C_INT32_T), VALUE :: ret_len
      INTEGER(C_INT32_T), VALUE :: db2_lock_mode
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_returning_lock

    ! @brief Renders `ast` into parameterized SQL for `dialect`.
    ! @param[in] ast AST handle.
    ! @param[in] dialect Target SQL dialect enum.
    ! @param[out] out_sql Destination blank-padded SQL character buffer.
    ! @param[in] sql_cap Capacity of `out_sql` in bytes.
    ! @param[out] out_len Receives trimmed SQL byte length.
    ! @param[out] out_param_count Receives number of extracted bind parameters.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_to_sql(ast, dialect, out_sql, sql_cap, out_len, out_param_count) BIND(C,  &
      &NAME="fortran_orm_ast_to_sql") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      INTEGER(C_INT32_T), VALUE :: dialect
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_sql
      INTEGER(C_INT32_T), VALUE :: sql_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T), INTENT(OUT) :: out_param_count
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_to_sql

    ! @brief Compiles and executes a non-query (`INSERT` / `UPDATE` / `DELETE`)
    ! AST directly against `db`.
    ! @param[in] db Active database handle.
    ! @param[in] ast AST handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_exec(db, ast) BIND(C, NAME="fortran_orm_ast_exec") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: ast
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_exec

    ! @brief Compiles and executes a `SELECT` AST against `db`, hydrating results
    ! into a dynamic `fortran_orm_rs_t` handle.
    ! @param[in] db Active database handle.
    ! @param[in] ast AST handle.
    ! @param[out] out_rs Receives hydrated dynamic result-set handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_query_rs(db, ast, out_rs) BIND(C, NAME="fortran_orm_ast_query_rs") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(C_PTR), VALUE :: ast
      TYPE(C_PTR), INTENT(OUT) :: out_rs
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_query_rs

    ! @brief Frees an arena-backed AST builder handle.
    ! @param[in,out] ast AST handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ast_free(ast) BIND(C, NAME="fortran_orm_ast_free") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: ast
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ast_free

    ! @brief Initializes a schema migration runner scanning `dir_path`.
    ! @param[in] db Active database handle.
    ! @param[in] dir_path Filesystem directory containing `.sql` migrations.
    ! @param[in] dir_len Byte length of `dir_path`.
    ! @param[out] out_mig Receives migration runner handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_mig_init(db, dir_path, dir_len, out_mig) BIND(C, NAME="fortran_orm_mig_init") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: dir_path
      INTEGER(C_INT32_T), VALUE :: dir_len
      TYPE(C_PTR), INTENT(OUT) :: out_mig
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_mig_init

    ! @brief Applies pending `-- UP` SQL migrations.
    ! @param[in] mig Migration runner handle.
    ! @param[in] dry_run Non-zero to validate without mutating database.
    ! @param[out] out_total_applied Receives total count of applied migrations.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_mig_up(mig, dry_run, out_total_applied) BIND(C, NAME="fortran_orm_mig_up") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: mig
      INTEGER(C_INT32_T), VALUE :: dry_run
      INTEGER(C_INT32_T), INTENT(OUT) :: out_total_applied
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_mig_up

    ! @brief Rolls back the last `steps` applied migrations (`-- DOWN`).
    ! @param[in] mig Migration runner handle.
    ! @param[in] steps Number of migrations to revert (`0` reverts all).
    ! @param[in] dry_run Non-zero to validate without mutating database.
    ! @param[out] out_remaining Receives remaining applied migration count.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_mig_down(mig, steps, dry_run, out_remaining) BIND(C, NAME="fortran_orm_mig_down") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: mig
      INTEGER(C_INT32_T), VALUE :: steps
      INTEGER(C_INT32_T), VALUE :: dry_run
      INTEGER(C_INT32_T), INTENT(OUT) :: out_remaining
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_mig_down

    ! @brief Copies the latest applied migration version string into `out_ver`.
    ! @param[in] mig Migration runner handle.
    ! @param[out] out_ver Destination blank-padded character buffer.
    ! @param[in] ver_cap Capacity of `out_ver` in bytes.
    ! @param[out] out_len Receives version string length (`0` if none applied).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_mig_version(mig, out_ver, ver_cap, out_len) BIND(C, NAME="fortran_orm_mig_version") RESULT( &
      &cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: mig
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_ver
      INTEGER(C_INT32_T), VALUE :: ver_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_mig_version

    ! @brief Frees a migration runner handle.
    ! @param[in,out] mig Migration runner handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_mig_free(mig) BIND(C, NAME="fortran_orm_mig_free") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: mig
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_mig_free

    ! @brief Parses a base-10 numeric string slice into an exact 38-digit decimal.
    ! @param[in] str Decimal text buffer (leading/trailing spaces trimmed).
    ! @param[in] str_len Byte length of `str`.
    ! @param[out] out_dec Receives parsed `fortran_orm_decimal_t`.
    ! @return `FORTRAN_ORM_OK` on success, or decimal syntax/overflow error.
    FUNCTION fortran_orm_dec_from_str(str, str_len, out_dec) BIND(C, NAME="fortran_orm_dec_from_str") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, fortran_orm_decimal
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: str
      INTEGER(C_INT32_T), VALUE :: str_len
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_dec
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_from_str

    ! @brief Formats `dec` into a canonical base-10 string in blank-padded
    ! `out_buf`.
    ! @param[in] dec Source decimal value.
    ! @param[out] out_buf Destination blank-padded character buffer.
    ! @param[in] buf_cap Capacity of `out_buf` in bytes.
    ! @param[out] out_len Receives trimmed string length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_dec_to_str(dec, out_buf, buf_cap, out_len) BIND(C, NAME="fortran_orm_dec_to_str") RESULT( &
      &cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: dec
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
      INTEGER(C_INT32_T), VALUE :: buf_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_to_str

    ! @brief Converts a 64-bit signed integer into a scale-0 decimal.
    ! @param[in] val 64-bit integer value.
    ! @param[out] out_dec Receives decimal value.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_dec_from_i64(val, out_dec) BIND(C, NAME="fortran_orm_dec_from_i64") RESULT(cdd_ret_)
      IMPORT :: C_INT64_T, fortran_orm_decimal, C_INT32_T
      IMPLICIT NONE
      INTEGER(C_INT64_T), VALUE :: val
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_dec
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_from_i64

    ! @brief Converts `dec` to a 64-bit signed integer using `round_mode`.
    ! @param[in] dec Source decimal value.
    ! @param[in] round_mode Rounding mode enum.
    ! @param[out] out_val Receives rounded 64-bit integer.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_dec_to_i64(dec, round_mode, out_val) BIND(C, NAME="fortran_orm_dec_to_i64") RESULT(cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_INT32_T, C_INT64_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: dec
      INTEGER(C_INT32_T), VALUE :: round_mode
      INTEGER(C_INT64_T), INTENT(OUT) :: out_val
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_to_i64

    ! @brief Computes exact fixed-point sum `a + b`.
    ! @param[in] a Left addend.
    ! @param[in] b Right addend.
    ! @param[out] out_res Receives sum.
    ! @return `FORTRAN_ORM_OK` on success, or overflow error.
    FUNCTION fortran_orm_dec_add(a, b, out_res) BIND(C, NAME="fortran_orm_dec_add") RESULT(cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_INT32_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: a
      TYPE(fortran_orm_decimal), INTENT(IN) :: b
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_res
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_add

    ! @brief Computes exact fixed-point difference `a - b`.
    ! @param[in] a Minuend.
    ! @param[in] b Subtrahend.
    ! @param[out] out_res Receives difference.
    ! @return `FORTRAN_ORM_OK` on success, or overflow error.
    FUNCTION fortran_orm_dec_sub(a, b, out_res) BIND(C, NAME="fortran_orm_dec_sub") RESULT(cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_INT32_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: a
      TYPE(fortran_orm_decimal), INTENT(IN) :: b
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_res
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_sub

    ! @brief Computes fixed-point product `a * b` bounded to `max_scale`.
    ! @param[in] a Multiplicand.
    ! @param[in] b Multiplier.
    ! @param[in] max_scale Maximum fractional scale (`0..38`).
    ! @param[in] round_mode Rounding mode when reducing scale.
    ! @param[out] out_res Receives product.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_dec_mul(a, b, max_scale, round_mode, out_res) BIND(C, NAME="fortran_orm_dec_mul") RESULT( &
      &cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_INT32_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: a
      TYPE(fortran_orm_decimal), INTENT(IN) :: b
      INTEGER(C_INT32_T), VALUE :: max_scale
      INTEGER(C_INT32_T), VALUE :: round_mode
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_res
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_mul

    ! @brief Computes fixed-point quotient `a / b` at `result_scale`.
    ! @param[in] a Dividend.
    ! @param[in] b Divisor.
    ! @param[in] result_scale Desired fractional scale (`0..38`).
    ! @param[in] round_mode Remainder rounding mode.
    ! @param[out] out_res Receives quotient.
    ! @return `FORTRAN_ORM_OK` on success, or divide-by-zero / overflow error.
    FUNCTION fortran_orm_dec_div(a, b, result_scale, round_mode, out_res) BIND(C, NAME="fortran_orm_dec_div") RESULT( &
      &cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_INT32_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: a
      TYPE(fortran_orm_decimal), INTENT(IN) :: b
      INTEGER(C_INT32_T), VALUE :: result_scale
      INTEGER(C_INT32_T), VALUE :: round_mode
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_res
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_div

    ! @brief Numerically compares two decimals (`-1`, `0`, `+1`).
    ! @param[in] a Left decimal.
    ! @param[in] b Right decimal.
    ! @param[out] out_cmp Receives `-1` (`a < b`), `0` (`a == b`), or `1` (`a >
    ! b`).
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_dec_cmp(a, b, out_cmp) BIND(C, NAME="fortran_orm_dec_cmp") RESULT(cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_INT32_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: a
      TYPE(fortran_orm_decimal), INTENT(IN) :: b
      INTEGER(C_INT32_T), INTENT(OUT) :: out_cmp
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_cmp

    ! @brief Rescales `dec` to `(target_precision, target_scale)` under
    ! `round_mode`.
    ! @param[in] dec Source decimal.
    ! @param[in] target_precision Maximum allowed digits (`1..38`).
    ! @param[in] target_scale Target fractional digits (`0..target_precision`).
    ! @param[in] round_mode Rounding mode enum.
    ! @param[out] out_dec Receives rescaled decimal.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_dec_rescale(dec, target_precision, target_scale, round_mode, out_dec) BIND(C,  &
      &NAME="fortran_orm_dec_rescale") RESULT(cdd_ret_)
      IMPORT :: fortran_orm_decimal, C_INT32_T
      IMPLICIT NONE
      TYPE(fortran_orm_decimal), INTENT(IN) :: dec
      INTEGER(C_INT32_T), VALUE :: target_precision
      INTEGER(C_INT32_T), VALUE :: target_scale
      INTEGER(C_INT32_T), VALUE :: round_mode
      TYPE(fortran_orm_decimal), INTENT(OUT) :: out_dec
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_dec_rescale

    ! @brief Transcodes single-byte mainframe EBCDIC bytes into blank-padded UTF-8.
    ! @param[in] codepage Source EBCDIC codepage enum.
    ! @param[in] ebcdic_bytes Source EBCDIC byte buffer.
    ! @param[in] byte_len Number of source bytes.
    ! @param[out] out_utf8 Destination blank-padded UTF-8 character buffer.
    ! @param[in] out_cap Capacity of `out_utf8` in bytes.
    ! @param[out] out_len Receives decoded UTF-8 byte count.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_ebcdic_to_utf8(codepage, ebcdic_bytes, byte_len, out_utf8, out_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_ebcdic_to_utf8") RESULT(cdd_ret_)
      IMPORT :: C_INT32_T, C_PTR, C_CHAR
      IMPLICIT NONE
      INTEGER(C_INT32_T), VALUE :: codepage
      TYPE(C_PTR), VALUE :: ebcdic_bytes
      INTEGER(C_INT32_T), VALUE :: byte_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_utf8
      INTEGER(C_INT32_T), VALUE :: out_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_ebcdic_to_utf8

    ! @brief Transcodes UTF-8 text into single-byte mainframe EBCDIC bytes.
    ! @param[in] codepage Target EBCDIC codepage enum.
    ! @param[in] utf8_str Source UTF-8 character buffer.
    ! @param[in] str_len Byte length of `utf8_str`.
    ! @param[out] out_ebcdic Destination EBCDIC byte buffer.
    ! @param[in] out_cap Capacity of `out_ebcdic` in bytes.
    ! @param[out] out_len Receives encoded EBCDIC byte count.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_utf8_to_ebcdic(codepage, utf8_str, str_len, out_ebcdic, out_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_utf8_to_ebcdic") RESULT(cdd_ret_)
      IMPORT :: C_INT32_T, C_CHAR, C_PTR
      IMPLICIT NONE
      INTEGER(C_INT32_T), VALUE :: codepage
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: utf8_str
      INTEGER(C_INT32_T), VALUE :: str_len
      TYPE(C_PTR), VALUE :: out_ebcdic
      INTEGER(C_INT32_T), VALUE :: out_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_utf8_to_ebcdic

    ! @brief Transcodes UTF-8 text into UTF-16 code units (`GRAPHIC` / `SQLWCHAR`).
    ! @param[in] utf8_str Source UTF-8 character buffer.
    ! @param[in] str_len Byte length of `utf8_str`.
    ! @param[in] big_endian Non-zero for big-endian z/OS `GRAPHIC` byte order.
    ! @param[out] out_u16 Destination 16-bit code unit array.
    ! @param[in] u16_cap Capacity of `out_u16` in 16-bit units (`>= units + 1`).
    ! @param[out] out_units Receives written 16-bit unit count.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_utf8_to_utf16(utf8_str, str_len, big_endian, out_u16, u16_cap, out_units) BIND(C,  &
      &NAME="fortran_orm_utf8_to_utf16") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T, C_PTR
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: utf8_str
      INTEGER(C_INT32_T), VALUE :: str_len
      INTEGER(C_INT32_T), VALUE :: big_endian
      TYPE(C_PTR), VALUE :: out_u16
      INTEGER(C_INT32_T), VALUE :: u16_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_units
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_utf8_to_utf16

    ! @brief Transcodes UTF-16 code units into blank-padded UTF-8 text.
    ! @param[in] u16_units Source 16-bit UTF-16 code unit array.
    ! @param[in] unit_count Number of 16-bit units to decode.
    ! @param[in] big_endian Non-zero if `u16_units` are big-endian.
    ! @param[out] out_utf8 Destination blank-padded UTF-8 character buffer.
    ! @param[in] out_cap Capacity of `out_utf8` in bytes.
    ! @param[out] out_len Receives decoded UTF-8 byte length.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_utf16_to_utf8(u16_units, unit_count, big_endian, out_utf8, out_cap, out_len) BIND(C,  &
      &NAME="fortran_orm_utf16_to_utf8") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T, C_CHAR
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: u16_units
      INTEGER(C_INT32_T), VALUE :: unit_count
      INTEGER(C_INT32_T), VALUE :: big_endian
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_utf8
      INTEGER(C_INT32_T), VALUE :: out_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_utf16_to_utf8

    ! @brief Retrieves the 5-character ANSI `SQLSTATE` recorded on an ODBC/Db2
    ! connection.
    ! @param[in] db Active ODBC/Db2 database handle.
    ! @param[out] out_state Destination blank-padded buffer (`>= 5` bytes).
    ! @param[in] state_cap Capacity of `out_state` in bytes.
    ! @param[out] out_len Receives length (`5`).
    ! @return `FORTRAN_ORM_OK` on success, or validation error if not ODBC/Db2.
    FUNCTION fortran_orm_odbc_sqlstate(db, out_state, state_cap, out_len) BIND(C, NAME="fortran_orm_odbc_sqlstate")  &
      &RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_state
      INTEGER(C_INT32_T), VALUE :: state_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_odbc_sqlstate

    ! @brief Configures transaction isolation level (`UR`, `CS`, `RS`, `RR`) on an
    ! ODBC or IBM Db2 connection.
    ! @param[in] db Active ODBC/Db2 database handle.
    ! @param[in] iso_level Isolation level enum.
    ! @return `FORTRAN_ORM_OK` on success, or diagnostic/validation error.
    FUNCTION fortran_orm_set_isolation(db, iso_level) BIND(C, NAME="fortran_orm_set_isolation") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T), VALUE :: iso_level
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_set_isolation

    ! @brief Configures IBM Db2 Workload Manager (WLM) client registers and active
    ! `CURRENT SCHEMA`.
    ! @param[in] db Active Db2 connection handle.
    ! @param[in] userid Client user ID (`0` length to skip).
    ! @param[in] userid_len Byte length of `userid`.
    ! @param[in] applname Client application name (`0` length to skip).
    ! @param[in] appl_len Byte length of `applname`.
    ! @param[in] schema Target Db2 `CURRENT SCHEMA` (`0` length to skip).
    ! @param[in] schema_len Byte length of `schema`.
    ! @return `FORTRAN_ORM_OK` on success, or diagnostic/validation error.
    FUNCTION fortran_orm_db2_configure(db, userid, userid_len, applname, appl_len, schema, schema_len) BIND(C,  &
      &NAME="fortran_orm_db2_configure") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: userid
      INTEGER(C_INT32_T), VALUE :: userid_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: applname
      INTEGER(C_INT32_T), VALUE :: appl_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: schema
      INTEGER(C_INT32_T), VALUE :: schema_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_db2_configure

    ! @brief Generates a RFC 4122 random UUID v4 (`36` ASCII chars) into
    ! blank-padded `out_uuid`.
    ! @param[out] out_uuid Destination character buffer (`>= 36` bytes).
    ! @param[in] uuid_cap Capacity of `out_uuid` in bytes.
    ! @param[out] out_len Receives `36`.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_uuid_v4(out_uuid, uuid_cap, out_len) BIND(C, NAME="fortran_orm_uuid_v4") RESULT(cdd_ret_)
      IMPORT :: C_CHAR, C_INT32_T
      IMPLICIT NONE
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_uuid
      INTEGER(C_INT32_T), VALUE :: uuid_cap
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_uuid_v4

    ! @brief Creates the standard `c-orm` OAuth2 tables (`users`, `tokens`,
    ! `clients`, `auth_codes`) on `db`.
    ! @param[in] db Active database handle.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_oauth2_init_tables(db) BIND(C, NAME="fortran_orm_oauth2_init_tables") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_oauth2_init_tables

    ! @brief Persists an OAuth2 token POD structure into `db`.
    ! @param[in] db Active database handle.
    ! @param[in] token_pod Populated OAuth2 token POD struct.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_oauth2_save_token(db, token_pod) BIND(C, NAME="fortran_orm_oauth2_save_token") RESULT(cdd_ret_)
      IMPORT :: C_PTR, fortran_orm_oauth2_token_pod, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      TYPE(fortran_orm_oauth2_token_pod), INTENT(IN) :: token_pod
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_oauth2_save_token

    ! @brief Retrieves an OAuth2 token POD structure by `access_token`.
    ! @param[in] db Active database handle.
    ! @param[in] access_token Access token string buffer (trailing spaces trimmed).
    ! @param[in] token_len Byte length of `access_token`.
    ! @param[out] out_pod Receives hydrated OAuth2 token POD struct.
    ! @return `FORTRAN_ORM_OK` on success, or `FORTRAN_ORM_ERROR_NOT_FOUND`.
    FUNCTION fortran_orm_oauth2_get_token(db, access_token, token_len, out_pod) BIND(C,  &
      &NAME="fortran_orm_oauth2_get_token") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T, fortran_orm_oauth2_token_pod
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: access_token
      INTEGER(C_INT32_T), VALUE :: token_len
      TYPE(fortran_orm_oauth2_token_pod), INTENT(OUT) :: out_pod
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_oauth2_get_token

    ! @brief Revokes an OAuth2 token by `access_token` and validates scope subsets.
    ! @param[in] db Active database handle (may be NULL if `revoke_flag == 0`).
    ! @param[in] access_token Access token to revoke when `revoke_flag != 0`.
    ! @param[in] token_len Byte length of `access_token`.
    ! @param[in] revoke_flag Non-zero to delete token from `db`.
    ! @param[in] granted_scopes Space-delimited granted scopes.
    ! @param[in] granted_len Byte length of `granted_scopes`.
    ! @param[in] req_scopes Space-delimited requested scopes.
    ! @param[in] req_len Byte length of `req_scopes`.
    ! @param[out] out_scope_valid Receives `1` if `req_scopes` is a subset.
    ! @return `FORTRAN_ORM_OK` on success, or error code.
    FUNCTION fortran_orm_oauth2_revoke_or_check(db, access_token, token_len, revoke_flag, granted_scopes, granted_len, &
      &req_scopes, req_len, out_scope_valid) BIND(C, NAME="fortran_orm_oauth2_revoke_or_check") RESULT(cdd_ret_)
      IMPORT :: C_PTR, C_CHAR, C_INT32_T
      IMPLICIT NONE
      TYPE(C_PTR), VALUE :: db
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: access_token
      INTEGER(C_INT32_T), VALUE :: token_len
      INTEGER(C_INT32_T), VALUE :: revoke_flag
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: granted_scopes
      INTEGER(C_INT32_T), VALUE :: granted_len
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: req_scopes
      INTEGER(C_INT32_T), VALUE :: req_len
      INTEGER(C_INT32_T), INTENT(OUT) :: out_scope_valid
      INTEGER(C_INT32_T) :: cdd_ret_
    END FUNCTION fortran_orm_oauth2_revoke_or_check

  END INTERFACE

CONTAINS

  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_str_to_a1.
  !> @param[in] str Argument 1.
  !> @param[in] str_len Argument 2.
  !> @param[in] out_a1 Argument 3.
  !> @param[in] cap Argument 4.
  !> @param[out] out_len Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_str_to_a1_str(str, str_len, out_a1, cap, out_len) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: str
    INTEGER(C_INT32_T), VALUE :: str_len
    TYPE(C_PTR), VALUE :: out_a1
    INTEGER(C_INT32_T), VALUE :: cap
    INTEGER(C_INT32_T), INTENT(OUT) :: out_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_str_to_a1(TRIM(str) // C_NULL_CHAR, str_len, out_a1, cap, out_len)
  END FUNCTION fortran_orm_str_to_a1_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_connect.
  !> @param[in] url Argument 1.
  !> @param[in] url_len Argument 2.
  !> @param[out] out_db Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_connect_str(url, url_len, out_db) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: url
    INTEGER(C_INT32_T), VALUE :: url_len
    TYPE(C_PTR), INTENT(OUT) :: out_db
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_connect(TRIM(url) // C_NULL_CHAR, url_len, out_db)
  END FUNCTION fortran_orm_connect_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_connect_cstr.
  !> @param[in] url_cstr Argument 1.
  !> @param[out] out_db Argument 2.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_connect_cstr_str(url_cstr, out_db) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: url_cstr
    TYPE(C_PTR), INTENT(OUT) :: out_db
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_connect_cstr(TRIM(url_cstr) // C_NULL_CHAR, out_db)
  END FUNCTION fortran_orm_connect_cstr_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_exec_sql.
  !> @param[in] db Argument 1.
  !> @param[in] sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_exec_sql_str(db, sql, sql_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_exec_sql(db, TRIM(sql) // C_NULL_CHAR, sql_len)
  END FUNCTION fortran_orm_exec_sql_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_exec_cstr.
  !> @param[in] db Argument 1.
  !> @param[in] sql_cstr Argument 2.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_exec_cstr_str(db, sql_cstr) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql_cstr
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_exec_cstr(db, TRIM(sql_cstr) // C_NULL_CHAR)
  END FUNCTION fortran_orm_exec_cstr_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_set_timezone.
  !> @param[in] db Argument 1.
  !> @param[in] offset_minutes Argument 2.
  !> @param[in] tz_name Argument 3.
  !> @param[in] tz_len Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_set_timezone_str(db, offset_minutes, tz_name, tz_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    INTEGER(C_INT32_T), VALUE :: offset_minutes
    CHARACTER(LEN=*), INTENT(IN) :: tz_name
    INTEGER(C_INT32_T), VALUE :: tz_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_set_timezone(db, offset_minutes, TRIM(tz_name) // C_NULL_CHAR, tz_len)
  END FUNCTION fortran_orm_set_timezone_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_escape_string.
  !> @param[in] db Argument 1.
  !> @param[in] src Argument 2.
  !> @param[in] src_len Argument 3.
  !> @param[out] out_buf Argument 4.
  !> @param[in] buf_cap Argument 5.
  !> @param[out] out_len Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_escape_string_str(db, src, src_len, out_buf, buf_cap, out_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: src
    INTEGER(C_INT32_T), VALUE :: src_len
    CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
    INTEGER(C_INT32_T), VALUE :: buf_cap
    INTEGER(C_INT32_T), INTENT(OUT) :: out_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_escape_string(db, TRIM(src) // C_NULL_CHAR, src_len, out_buf, buf_cap, out_len)
  END FUNCTION fortran_orm_escape_string_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_pool_init.
  !> @param[in] url Argument 1.
  !> @param[in] url_len Argument 2.
  !> @param[in] min_conns Argument 3.
  !> @param[in] max_conns Argument 4.
  !> @param[in] timeout_ms Argument 5.
  !> @param[out] out_pool Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_pool_init_str(url, url_len, min_conns, max_conns, timeout_ms, out_pool) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: url
    INTEGER(C_INT32_T), VALUE :: url_len
    INTEGER(C_INT32_T), VALUE :: min_conns
    INTEGER(C_INT32_T), VALUE :: max_conns
    INTEGER(C_INT32_T), VALUE :: timeout_ms
    TYPE(C_PTR), INTENT(OUT) :: out_pool
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_pool_init(TRIM(url) // C_NULL_CHAR, url_len, min_conns, max_conns, timeout_ms, out_pool)
  END FUNCTION fortran_orm_pool_init_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_shard_route.
  !> @param[in] shard Argument 1.
  !> @param[in] routing_key Argument 2.
  !> @param[in] key_len Argument 3.
  !> @param[out] out_shard_idx Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_shard_route_str(shard, routing_key, key_len, out_shard_idx) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: shard
    CHARACTER(LEN=*), INTENT(IN) :: routing_key
    INTEGER(C_INT32_T), VALUE :: key_len
    INTEGER(C_INT32_T), INTENT(OUT) :: out_shard_idx
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_shard_route(shard, TRIM(routing_key) // C_NULL_CHAR, key_len, out_shard_idx)
  END FUNCTION fortran_orm_shard_route_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_tx_savepoint.
  !> @param[in] db Argument 1.
  !> @param[in] name Argument 2.
  !> @param[in] name_len Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_tx_savepoint_str(db, name, name_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(C_INT32_T), VALUE :: name_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_tx_savepoint(db, TRIM(name) // C_NULL_CHAR, name_len)
  END FUNCTION fortran_orm_tx_savepoint_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_tx_release_sp.
  !> @param[in] db Argument 1.
  !> @param[in] name Argument 2.
  !> @param[in] name_len Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_tx_release_sp_str(db, name, name_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(C_INT32_T), VALUE :: name_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_tx_release_sp(db, TRIM(name) // C_NULL_CHAR, name_len)
  END FUNCTION fortran_orm_tx_release_sp_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_tx_rollback_sp.
  !> @param[in] db Argument 1.
  !> @param[in] name Argument 2.
  !> @param[in] name_len Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_tx_rollback_sp_str(db, name, name_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: name
    INTEGER(C_INT32_T), VALUE :: name_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_tx_rollback_sp(db, TRIM(name) // C_NULL_CHAR, name_len)
  END FUNCTION fortran_orm_tx_rollback_sp_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_stmt_prepare.
  !> @param[in] db Argument 1.
  !> @param[in] sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[out] out_stmt Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_stmt_prepare_str(db, sql, sql_len, out_stmt) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), INTENT(OUT) :: out_stmt
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_stmt_prepare(db, TRIM(sql) // C_NULL_CHAR, sql_len, out_stmt)
  END FUNCTION fortran_orm_stmt_prepare_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_stmt_prepare_cached.
  !> @param[in] db Argument 1.
  !> @param[in] sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[out] out_stmt Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_stmt_prepare_cached_str(db, sql, sql_len, out_stmt) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), INTENT(OUT) :: out_stmt
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_stmt_prepare_cached(db, TRIM(sql) // C_NULL_CHAR, sql_len, out_stmt)
  END FUNCTION fortran_orm_stmt_prepare_cached_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_stmt_bind_str.
  !> @param[in] stmt Argument 1.
  !> @param[in] param_idx Argument 2.
  !> @param[in] val Argument 3.
  !> @param[in] val_len Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_stmt_bind_str_str(stmt, param_idx, val, val_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: stmt
    INTEGER(C_INT32_T), VALUE :: param_idx
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER(C_INT32_T), VALUE :: val_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_stmt_bind_str(stmt, param_idx, TRIM(val) // C_NULL_CHAR, val_len)
  END FUNCTION fortran_orm_stmt_bind_str_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_stmt_bind_str_raw.
  !> @param[in] stmt Argument 1.
  !> @param[in] param_idx Argument 2.
  !> @param[in] val Argument 3.
  !> @param[in] val_len Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_stmt_bind_str_raw_str(stmt, param_idx, val, val_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: stmt
    INTEGER(C_INT32_T), VALUE :: param_idx
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER(C_INT32_T), VALUE :: val_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_stmt_bind_str_raw(stmt, param_idx, TRIM(val) // C_NULL_CHAR, val_len)
  END FUNCTION fortran_orm_stmt_bind_str_raw_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_insert_vec_i32.
  !> @param[in] db Argument 1.
  !> @param[in] insert_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] vec Argument 4.
  !> @param[in] count Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_insert_vec_i32_str(db, insert_sql, sql_len, vec, count) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: insert_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: vec
    INTEGER(C_INT32_T), VALUE :: count
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_insert_vec_i32(db, TRIM(insert_sql) // C_NULL_CHAR, sql_len, vec, count)
  END FUNCTION fortran_orm_insert_vec_i32_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_insert_vec_i64.
  !> @param[in] db Argument 1.
  !> @param[in] insert_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] vec Argument 4.
  !> @param[in] count Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_insert_vec_i64_str(db, insert_sql, sql_len, vec, count) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: insert_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: vec
    INTEGER(C_INT32_T), VALUE :: count
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_insert_vec_i64(db, TRIM(insert_sql) // C_NULL_CHAR, sql_len, vec, count)
  END FUNCTION fortran_orm_insert_vec_i64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_insert_vec_f64.
  !> @param[in] db Argument 1.
  !> @param[in] insert_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] vec Argument 4.
  !> @param[in] count Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_insert_vec_f64_str(db, insert_sql, sql_len, vec, count) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: insert_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: vec
    INTEGER(C_INT32_T), VALUE :: count
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_insert_vec_f64(db, TRIM(insert_sql) // C_NULL_CHAR, sql_len, vec, count)
  END FUNCTION fortran_orm_insert_vec_f64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_query_vec_i32.
  !> @param[in] db Argument 1.
  !> @param[in] select_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] out_vec Argument 4.
  !> @param[in] cap_elems Argument 5.
  !> @param[out] out_count Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_query_vec_i32_str(db, select_sql, sql_len, out_vec, cap_elems, out_count) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: select_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: out_vec
    INTEGER(C_INT32_T), VALUE :: cap_elems
    INTEGER(C_INT32_T), INTENT(OUT) :: out_count
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_query_vec_i32(db, TRIM(select_sql) // C_NULL_CHAR, sql_len, out_vec, cap_elems, out_count)
  END FUNCTION fortran_orm_query_vec_i32_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_query_vec_i64.
  !> @param[in] db Argument 1.
  !> @param[in] select_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] out_vec Argument 4.
  !> @param[in] cap_elems Argument 5.
  !> @param[out] out_count Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_query_vec_i64_str(db, select_sql, sql_len, out_vec, cap_elems, out_count) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: select_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: out_vec
    INTEGER(C_INT32_T), VALUE :: cap_elems
    INTEGER(C_INT32_T), INTENT(OUT) :: out_count
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_query_vec_i64(db, TRIM(select_sql) // C_NULL_CHAR, sql_len, out_vec, cap_elems, out_count)
  END FUNCTION fortran_orm_query_vec_i64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_query_vec_f64.
  !> @param[in] db Argument 1.
  !> @param[in] select_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] out_vec Argument 4.
  !> @param[in] cap_elems Argument 5.
  !> @param[out] out_count Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_query_vec_f64_str(db, select_sql, sql_len, out_vec, cap_elems, out_count) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: select_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: out_vec
    INTEGER(C_INT32_T), VALUE :: cap_elems
    INTEGER(C_INT32_T), INTENT(OUT) :: out_count
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_query_vec_f64(db, TRIM(select_sql) // C_NULL_CHAR, sql_len, out_vec, cap_elems, out_count)
  END FUNCTION fortran_orm_query_vec_f64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_insert_matrix_f64.
  !> @param[in] db Argument 1.
  !> @param[in] insert_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] matrix_col_major Argument 4.
  !> @param[in] ld_rows Argument 5.
  !> @param[in] n_rows Argument 6.
  !> @param[in] n_cols Argument 7.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_insert_matrix_f64_str(db, insert_sql, sql_len, matrix_col_major, ld_rows, n_rows, n_cols)  &
      &RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: insert_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: matrix_col_major
    INTEGER(C_INT32_T), VALUE :: ld_rows
    INTEGER(C_INT32_T), VALUE :: n_rows
    INTEGER(C_INT32_T), VALUE :: n_cols
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_insert_matrix_f64(db, TRIM(insert_sql) // C_NULL_CHAR, sql_len, matrix_col_major, ld_rows,  &
      &n_rows, n_cols)
  END FUNCTION fortran_orm_insert_matrix_f64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_query_matrix_f64.
  !> @param[in] db Argument 1.
  !> @param[in] select_sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[in] out_matrix Argument 4.
  !> @param[in] ld_rows Argument 5.
  !> @param[in] max_rows Argument 6.
  !> @param[in] n_cols Argument 7.
  !> @param[out] out_rows Argument 8.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_query_matrix_f64_str(db, select_sql, sql_len, out_matrix, ld_rows, max_rows, n_cols, out_rows)  &
      &RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: select_sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), VALUE :: out_matrix
    INTEGER(C_INT32_T), VALUE :: ld_rows
    INTEGER(C_INT32_T), VALUE :: max_rows
    INTEGER(C_INT32_T), VALUE :: n_cols
    INTEGER(C_INT32_T), INTENT(OUT) :: out_rows
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_query_matrix_f64(db, TRIM(select_sql) // C_NULL_CHAR, sql_len, out_matrix, ld_rows,  &
      &max_rows, n_cols, out_rows)
  END FUNCTION fortran_orm_query_matrix_f64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_schema_create.
  !> @param[in] table_name Argument 1.
  !> @param[in] name_len Argument 2.
  !> @param[in] struct_size Argument 3.
  !> @param[out] out_schema Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_schema_create_str(table_name, name_len, struct_size, out_schema) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(C_INT32_T), VALUE :: name_len
    INTEGER(C_INT32_T), VALUE :: struct_size
    TYPE(C_PTR), INTENT(OUT) :: out_schema
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_schema_create(TRIM(table_name) // C_NULL_CHAR, name_len, struct_size, out_schema)
  END FUNCTION fortran_orm_schema_create_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_schema_add_col.
  !> @param[inout] schema Argument 1.
  !> @param[in] col_name Argument 2.
  !> @param[in] name_len Argument 3.
  !> @param[in] col_type Argument 4.
  !> @param[in] byte_offset Argument 5.
  !> @param[in] fixed_len Argument 6.
  !> @param[in] is_pk Argument 7.
  !> @param[in] is_nullable Argument 8.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_schema_add_col_str(schema, col_name, name_len, col_type, byte_offset, fixed_len, is_pk,  &
      &is_nullable) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: schema
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    INTEGER(C_INT32_T), VALUE :: name_len
    INTEGER(C_INT32_T), VALUE :: col_type
    INTEGER(C_INT32_T), VALUE :: byte_offset
    INTEGER(C_INT32_T), VALUE :: fixed_len
    INTEGER(C_INT32_T), VALUE :: is_pk
    INTEGER(C_INT32_T), VALUE :: is_nullable
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_schema_add_col(schema, TRIM(col_name) // C_NULL_CHAR, name_len, col_type, byte_offset,  &
      &fixed_len, is_pk, is_nullable)
  END FUNCTION fortran_orm_schema_add_col_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_schema_add_relation.
  !> @param[inout] schema Argument 1.
  !> @param[in] field_name Argument 2.
  !> @param[in] field_len Argument 3.
  !> @param[in] rel_kind Argument 4.
  !> @param[in] target_schema Argument 5.
  !> @param[in] fk_col Argument 6.
  !> @param[in] fk_len Argument 7.
  !> @param[in] local_col Argument 8.
  !> @param[in] local_len Argument 9.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_schema_add_relation_str(schema, field_name, field_len, rel_kind, target_schema, fk_col, fk_len, &
      &local_col, local_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: schema
    CHARACTER(LEN=*), INTENT(IN) :: field_name
    INTEGER(C_INT32_T), VALUE :: field_len
    INTEGER(C_INT32_T), VALUE :: rel_kind
    TYPE(C_PTR), VALUE :: target_schema
    CHARACTER(LEN=*), INTENT(IN) :: fk_col
    INTEGER(C_INT32_T), VALUE :: fk_len
    CHARACTER(LEN=*), INTENT(IN) :: local_col
    INTEGER(C_INT32_T), VALUE :: local_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_schema_add_relation(schema, TRIM(field_name) // C_NULL_CHAR, field_len, rel_kind,  &
      &target_schema, TRIM(fk_col) // C_NULL_CHAR, fk_len, TRIM(local_col) // C_NULL_CHAR, local_len)
  END FUNCTION fortran_orm_schema_add_relation_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_crud_update_optimistic.
  !> @param[in] db Argument 1.
  !> @param[inout] schema Argument 2.
  !> @param[in] version_col Argument 3.
  !> @param[in] col_len Argument 4.
  !> @param[in] in_record Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_crud_update_optimistic_str(db, schema, version_col, col_len, in_record) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    TYPE(C_PTR), VALUE :: schema
    CHARACTER(LEN=*), INTENT(IN) :: version_col
    INTEGER(C_INT32_T), VALUE :: col_len
    TYPE(C_PTR), VALUE :: in_record
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_crud_update_optimistic(db, schema, TRIM(version_col) // C_NULL_CHAR, col_len, in_record)
  END FUNCTION fortran_orm_crud_update_optimistic_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_query_abstract.
  !> @param[in] db Argument 1.
  !> @param[in] sql Argument 2.
  !> @param[in] sql_len Argument 3.
  !> @param[out] out_rs Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_query_abstract_str(db, sql, sql_len, out_rs) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT32_T), VALUE :: sql_len
    TYPE(C_PTR), INTENT(OUT) :: out_rs
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_query_abstract(db, TRIM(sql) // C_NULL_CHAR, sql_len, out_rs)
  END FUNCTION fortran_orm_query_abstract_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_rs_is_null.
  !> @param[in] rs Argument 1.
  !> @param[in] row_idx Argument 2.
  !> @param[in] col_name Argument 3.
  !> @param[in] name_len Argument 4.
  !> @param[out] out_is_null Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_rs_is_null_str(rs, row_idx, col_name, name_len, out_is_null) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: rs
    INTEGER(C_INT32_T), VALUE :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    INTEGER(C_INT32_T), VALUE :: name_len
    INTEGER(C_INT32_T), INTENT(OUT) :: out_is_null
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_rs_is_null(rs, row_idx, TRIM(col_name) // C_NULL_CHAR, name_len, out_is_null)
  END FUNCTION fortran_orm_rs_is_null_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_rs_get_i64.
  !> @param[in] rs Argument 1.
  !> @param[in] row_idx Argument 2.
  !> @param[in] col_name Argument 3.
  !> @param[in] name_len Argument 4.
  !> @param[out] out_val Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_rs_get_i64_str(rs, row_idx, col_name, name_len, out_val) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: rs
    INTEGER(C_INT32_T), VALUE :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    INTEGER(C_INT32_T), VALUE :: name_len
    INTEGER(C_INT64_T), INTENT(OUT) :: out_val
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_rs_get_i64(rs, row_idx, TRIM(col_name) // C_NULL_CHAR, name_len, out_val)
  END FUNCTION fortran_orm_rs_get_i64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_rs_get_f64.
  !> @param[in] rs Argument 1.
  !> @param[in] row_idx Argument 2.
  !> @param[in] col_name Argument 3.
  !> @param[in] name_len Argument 4.
  !> @param[out] out_val Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_rs_get_f64_str(rs, row_idx, col_name, name_len, out_val) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: rs
    INTEGER(C_INT32_T), VALUE :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    INTEGER(C_INT32_T), VALUE :: name_len
    REAL(C_DOUBLE), INTENT(OUT) :: out_val
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_rs_get_f64(rs, row_idx, TRIM(col_name) // C_NULL_CHAR, name_len, out_val)
  END FUNCTION fortran_orm_rs_get_f64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_rs_get_str.
  !> @param[in] rs Argument 1.
  !> @param[in] row_idx Argument 2.
  !> @param[in] col_name Argument 3.
  !> @param[in] name_len Argument 4.
  !> @param[out] out_buf Argument 5.
  !> @param[in] buf_cap Argument 6.
  !> @param[out] out_len Argument 7.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_rs_get_str_str(rs, row_idx, col_name, name_len, out_buf, buf_cap, out_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: rs
    INTEGER(C_INT32_T), VALUE :: row_idx
    CHARACTER(LEN=*), INTENT(IN) :: col_name
    INTEGER(C_INT32_T), VALUE :: name_len
    CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(OUT) :: out_buf
    INTEGER(C_INT32_T), VALUE :: buf_cap
    INTEGER(C_INT32_T), INTENT(OUT) :: out_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_rs_get_str(rs, row_idx, TRIM(col_name) // C_NULL_CHAR, name_len, out_buf, buf_cap, out_len)
  END FUNCTION fortran_orm_rs_get_str_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_select.
  !> @param[in] table Argument 1.
  !> @param[in] table_len Argument 2.
  !> @param[in] columns Argument 3.
  !> @param[in] cols_len Argument 4.
  !> @param[out] out_ast Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_select_str(table, table_len, columns, cols_len, out_ast) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: table
    INTEGER(C_INT32_T), VALUE :: table_len
    CHARACTER(LEN=*), INTENT(IN) :: columns
    INTEGER(C_INT32_T), VALUE :: cols_len
    TYPE(C_PTR), INTENT(OUT) :: out_ast
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_select(TRIM(table) // C_NULL_CHAR, table_len, TRIM(columns) // C_NULL_CHAR, cols_len,  &
      &out_ast)
  END FUNCTION fortran_orm_ast_select_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_insert.
  !> @param[in] table Argument 1.
  !> @param[in] table_len Argument 2.
  !> @param[out] out_ast Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_insert_str(table, table_len, out_ast) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: table
    INTEGER(C_INT32_T), VALUE :: table_len
    TYPE(C_PTR), INTENT(OUT) :: out_ast
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_insert(TRIM(table) // C_NULL_CHAR, table_len, out_ast)
  END FUNCTION fortran_orm_ast_insert_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_update.
  !> @param[in] table Argument 1.
  !> @param[in] table_len Argument 2.
  !> @param[out] out_ast Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_update_str(table, table_len, out_ast) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: table
    INTEGER(C_INT32_T), VALUE :: table_len
    TYPE(C_PTR), INTENT(OUT) :: out_ast
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_update(TRIM(table) // C_NULL_CHAR, table_len, out_ast)
  END FUNCTION fortran_orm_ast_update_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_delete.
  !> @param[in] table Argument 1.
  !> @param[in] table_len Argument 2.
  !> @param[out] out_ast Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_delete_str(table, table_len, out_ast) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: table
    INTEGER(C_INT32_T), VALUE :: table_len
    TYPE(C_PTR), INTENT(OUT) :: out_ast
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_delete(TRIM(table) // C_NULL_CHAR, table_len, out_ast)
  END FUNCTION fortran_orm_ast_delete_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_where_i64.
  !> @param[inout] ast Argument 1.
  !> @param[in] col Argument 2.
  !> @param[in] col_len Argument 3.
  !> @param[in] op_str Argument 4.
  !> @param[in] op_len Argument 5.
  !> @param[in] val Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_where_i64_str(ast, col, col_len, op_str, op_len, val) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: col
    INTEGER(C_INT32_T), VALUE :: col_len
    CHARACTER(LEN=*), INTENT(IN) :: op_str
    INTEGER(C_INT32_T), VALUE :: op_len
    INTEGER(C_INT64_T), VALUE :: val
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_where_i64(ast, TRIM(col) // C_NULL_CHAR, col_len, TRIM(op_str) // C_NULL_CHAR, op_len,  &
      &val)
  END FUNCTION fortran_orm_ast_where_i64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_where_str.
  !> @param[inout] ast Argument 1.
  !> @param[in] col Argument 2.
  !> @param[in] col_len Argument 3.
  !> @param[in] op_str Argument 4.
  !> @param[in] op_len Argument 5.
  !> @param[in] val Argument 6.
  !> @param[in] val_len Argument 7.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_where_str_str(ast, col, col_len, op_str, op_len, val, val_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: col
    INTEGER(C_INT32_T), VALUE :: col_len
    CHARACTER(LEN=*), INTENT(IN) :: op_str
    INTEGER(C_INT32_T), VALUE :: op_len
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER(C_INT32_T), VALUE :: val_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_where_str(ast, TRIM(col) // C_NULL_CHAR, col_len, TRIM(op_str) // C_NULL_CHAR, op_len,  &
      &TRIM(val) // C_NULL_CHAR, val_len)
  END FUNCTION fortran_orm_ast_where_str_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_join.
  !> @param[inout] ast Argument 1.
  !> @param[in] join_type Argument 2.
  !> @param[in] type_len Argument 3.
  !> @param[in] table Argument 4.
  !> @param[in] table_len Argument 5.
  !> @param[in] on_sql Argument 6.
  !> @param[in] on_len Argument 7.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_join_str(ast, join_type, type_len, table, table_len, on_sql, on_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: join_type
    INTEGER(C_INT32_T), VALUE :: type_len
    CHARACTER(LEN=*), INTENT(IN) :: table
    INTEGER(C_INT32_T), VALUE :: table_len
    CHARACTER(LEN=*), INTENT(IN) :: on_sql
    INTEGER(C_INT32_T), VALUE :: on_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_join(ast, TRIM(join_type) // C_NULL_CHAR, type_len, TRIM(table) // C_NULL_CHAR,  &
      &table_len, TRIM(on_sql) // C_NULL_CHAR, on_len)
  END FUNCTION fortran_orm_ast_join_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_group_having.
  !> @param[inout] ast Argument 1.
  !> @param[in] group_cols Argument 2.
  !> @param[in] group_len Argument 3.
  !> @param[in] having_sql Argument 4.
  !> @param[in] having_len Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_group_having_str(ast, group_cols, group_len, having_sql, having_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: group_cols
    INTEGER(C_INT32_T), VALUE :: group_len
    CHARACTER(LEN=*), INTENT(IN) :: having_sql
    INTEGER(C_INT32_T), VALUE :: having_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_group_having(ast, TRIM(group_cols) // C_NULL_CHAR, group_len, TRIM(having_sql) //  &
      &C_NULL_CHAR, having_len)
  END FUNCTION fortran_orm_ast_group_having_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_order_limit.
  !> @param[inout] ast Argument 1.
  !> @param[in] order_col Argument 2.
  !> @param[in] col_len Argument 3.
  !> @param[in] descending Argument 4.
  !> @param[in] limit_rows Argument 5.
  !> @param[in] offset_rows Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_order_limit_str(ast, order_col, col_len, descending, limit_rows, offset_rows) RESULT( &
      &cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: order_col
    INTEGER(C_INT32_T), VALUE :: col_len
    INTEGER(C_INT32_T), VALUE :: descending
    INTEGER(C_INT32_T), VALUE :: limit_rows
    INTEGER(C_INT32_T), VALUE :: offset_rows
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_order_limit(ast, TRIM(order_col) // C_NULL_CHAR, col_len, descending, limit_rows,  &
      &offset_rows)
  END FUNCTION fortran_orm_ast_order_limit_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_set_i64.
  !> @param[inout] ast Argument 1.
  !> @param[in] col Argument 2.
  !> @param[in] col_len Argument 3.
  !> @param[in] val Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_set_i64_str(ast, col, col_len, val) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: col
    INTEGER(C_INT32_T), VALUE :: col_len
    INTEGER(C_INT64_T), VALUE :: val
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_set_i64(ast, TRIM(col) // C_NULL_CHAR, col_len, val)
  END FUNCTION fortran_orm_ast_set_i64_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_set_str.
  !> @param[inout] ast Argument 1.
  !> @param[in] col Argument 2.
  !> @param[in] col_len Argument 3.
  !> @param[in] val Argument 4.
  !> @param[in] val_len Argument 5.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_set_str_str(ast, col, col_len, val, val_len) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: col
    INTEGER(C_INT32_T), VALUE :: col_len
    CHARACTER(LEN=*), INTENT(IN) :: val
    INTEGER(C_INT32_T), VALUE :: val_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_set_str(ast, TRIM(col) // C_NULL_CHAR, col_len, TRIM(val) // C_NULL_CHAR, val_len)
  END FUNCTION fortran_orm_ast_set_str_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_ast_returning_lock.
  !> @param[inout] ast Argument 1.
  !> @param[in] returning_cols Argument 2.
  !> @param[in] ret_len Argument 3.
  !> @param[in] db2_lock_mode Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_ast_returning_lock_str(ast, returning_cols, ret_len, db2_lock_mode) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: ast
    CHARACTER(LEN=*), INTENT(IN) :: returning_cols
    INTEGER(C_INT32_T), VALUE :: ret_len
    INTEGER(C_INT32_T), VALUE :: db2_lock_mode
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_ast_returning_lock(ast, TRIM(returning_cols) // C_NULL_CHAR, ret_len, db2_lock_mode)
  END FUNCTION fortran_orm_ast_returning_lock_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_mig_init.
  !> @param[in] db Argument 1.
  !> @param[in] dir_path Argument 2.
  !> @param[in] dir_len Argument 3.
  !> @param[out] out_mig Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_mig_init_str(db, dir_path, dir_len, out_mig) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: dir_path
    INTEGER(C_INT32_T), VALUE :: dir_len
    TYPE(C_PTR), INTENT(OUT) :: out_mig
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_mig_init(db, TRIM(dir_path) // C_NULL_CHAR, dir_len, out_mig)
  END FUNCTION fortran_orm_mig_init_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_dec_from_str.
  !> @param[in] str Argument 1.
  !> @param[in] str_len Argument 2.
  !> @param[out] out_dec Argument 3.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_dec_from_str_str(str, str_len, out_dec) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: str
    INTEGER(C_INT32_T), VALUE :: str_len
    TYPE(fortran_orm_decimal), INTENT(OUT) :: out_dec
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_dec_from_str(TRIM(str) // C_NULL_CHAR, str_len, out_dec)
  END FUNCTION fortran_orm_dec_from_str_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_utf8_to_ebcdic.
  !> @param[in] codepage Argument 1.
  !> @param[in] utf8_str Argument 2.
  !> @param[in] str_len Argument 3.
  !> @param[in] out_ebcdic Argument 4.
  !> @param[in] out_cap Argument 5.
  !> @param[out] out_len Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_utf8_to_ebcdic_str(codepage, utf8_str, str_len, out_ebcdic, out_cap, out_len) RESULT(cdd_ret_)
    INTEGER(C_INT32_T), VALUE :: codepage
    CHARACTER(LEN=*), INTENT(IN) :: utf8_str
    INTEGER(C_INT32_T), VALUE :: str_len
    TYPE(C_PTR), VALUE :: out_ebcdic
    INTEGER(C_INT32_T), VALUE :: out_cap
    INTEGER(C_INT32_T), INTENT(OUT) :: out_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_utf8_to_ebcdic(codepage, TRIM(utf8_str) // C_NULL_CHAR, str_len, out_ebcdic, out_cap,  &
      &out_len)
  END FUNCTION fortran_orm_utf8_to_ebcdic_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_utf8_to_utf16.
  !> @param[in] utf8_str Argument 1.
  !> @param[in] str_len Argument 2.
  !> @param[in] big_endian Argument 3.
  !> @param[in] out_u16 Argument 4.
  !> @param[in] u16_cap Argument 5.
  !> @param[out] out_units Argument 6.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_utf8_to_utf16_str(utf8_str, str_len, big_endian, out_u16, u16_cap, out_units) RESULT(cdd_ret_)
    CHARACTER(LEN=*), INTENT(IN) :: utf8_str
    INTEGER(C_INT32_T), VALUE :: str_len
    INTEGER(C_INT32_T), VALUE :: big_endian
    TYPE(C_PTR), VALUE :: out_u16
    INTEGER(C_INT32_T), VALUE :: u16_cap
    INTEGER(C_INT32_T), INTENT(OUT) :: out_units
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_utf8_to_utf16(TRIM(utf8_str) // C_NULL_CHAR, str_len, big_endian, out_u16, u16_cap,  &
      &out_units)
  END FUNCTION fortran_orm_utf8_to_utf16_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_db2_configure.
  !> @param[in] db Argument 1.
  !> @param[in] userid Argument 2.
  !> @param[in] userid_len Argument 3.
  !> @param[in] applname Argument 4.
  !> @param[in] appl_len Argument 5.
  !> @param[in] schema Argument 6.
  !> @param[in] schema_len Argument 7.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_db2_configure_str(db, userid, userid_len, applname, appl_len, schema, schema_len) RESULT( &
      &cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: userid
    INTEGER(C_INT32_T), VALUE :: userid_len
    CHARACTER(LEN=*), INTENT(IN) :: applname
    INTEGER(C_INT32_T), VALUE :: appl_len
    CHARACTER(LEN=*), INTENT(IN) :: schema
    INTEGER(C_INT32_T), VALUE :: schema_len
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_db2_configure(db, TRIM(userid) // C_NULL_CHAR, userid_len, TRIM(applname) // C_NULL_CHAR,  &
      &appl_len, TRIM(schema) // C_NULL_CHAR, schema_len)
  END FUNCTION fortran_orm_db2_configure_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_oauth2_get_token.
  !> @param[in] db Argument 1.
  !> @param[in] access_token Argument 2.
  !> @param[in] token_len Argument 3.
  !> @param[out] out_pod Argument 4.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_oauth2_get_token_str(db, access_token, token_len, out_pod) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: access_token
    INTEGER(C_INT32_T), VALUE :: token_len
    TYPE(fortran_orm_oauth2_token_pod), INTENT(OUT) :: out_pod
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_oauth2_get_token(db, TRIM(access_token) // C_NULL_CHAR, token_len, out_pod)
  END FUNCTION fortran_orm_oauth2_get_token_str
  !> @brief Fortran CHARACTER convenience wrapper for fortran_orm_oauth2_revoke_or_check.
  !> @param[in] db Argument 1.
  !> @param[in] access_token Argument 2.
  !> @param[in] token_len Argument 3.
  !> @param[in] revoke_flag Argument 4.
  !> @param[in] granted_scopes Argument 5.
  !> @param[in] granted_len Argument 6.
  !> @param[in] req_scopes Argument 7.
  !> @param[in] req_len Argument 8.
  !> @param[out] out_scope_valid Argument 9.
  !> @return Wrapped C call result.
  FUNCTION fortran_orm_oauth2_revoke_or_check_str(db, access_token, token_len, revoke_flag, granted_scopes,  &
      &granted_len, req_scopes, req_len, out_scope_valid) RESULT(cdd_ret_)
    TYPE(C_PTR), VALUE :: db
    CHARACTER(LEN=*), INTENT(IN) :: access_token
    INTEGER(C_INT32_T), VALUE :: token_len
    INTEGER(C_INT32_T), VALUE :: revoke_flag
    CHARACTER(LEN=*), INTENT(IN) :: granted_scopes
    INTEGER(C_INT32_T), VALUE :: granted_len
    CHARACTER(LEN=*), INTENT(IN) :: req_scopes
    INTEGER(C_INT32_T), VALUE :: req_len
    INTEGER(C_INT32_T), INTENT(OUT) :: out_scope_valid
    INTEGER(C_INT32_T) :: cdd_ret_
    cdd_ret_ = fortran_orm_oauth2_revoke_or_check(db, TRIM(access_token) // C_NULL_CHAR, token_len, revoke_flag, TRIM( &
      &granted_scopes) // C_NULL_CHAR, granted_len, TRIM(req_scopes) // C_NULL_CHAR, req_len, out_scope_valid)
  END FUNCTION fortran_orm_oauth2_revoke_or_check_str
END MODULE fortran_orm_c
