/**
 * @file fortran_orm_types.h
 * @brief Strongly-typed opaque handle declarations, SQL dialect/type/rounding
 * enumerations, and ABI-fixed POD structures for ISO_C_BINDING
 * interoperability.
 */

#ifndef FORTRAN_ORM_TYPES_H
/** @brief Header guard for fortran_orm_types.h. */
#define FORTRAN_ORM_TYPES_H

/* clang-format off */
#include "fortran_orm_error.h"
/* clang-format on */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/** @brief Opaque database connection handle (`fortran_orm_db_t`). */
typedef struct fortran_orm_db fortran_orm_db_t;

/** @brief Opaque prepared statement handle (`fortran_orm_stmt_t`). */
typedef struct fortran_orm_stmt fortran_orm_stmt_t;

/** @brief Opaque thread-safe connection pool handle (`fortran_orm_pool_t`). */
typedef struct fortran_orm_pool fortran_orm_pool_t;

/** @brief Opaque arena-backed SQL AST builder handle (`fortran_orm_ast_t`). */
typedef struct fortran_orm_ast fortran_orm_ast_t;

/** @brief Opaque dynamic abstract result-set handle (`fortran_orm_rs_t`). */
typedef struct fortran_orm_rs fortran_orm_rs_t;

/** @brief Opaque schema migration runner handle (`fortran_orm_mig_t`). */
typedef struct fortran_orm_mig fortran_orm_mig_t;

/** @brief Opaque runtime struct reflection schema (`fortran_orm_schema_t`). */
typedef struct fortran_orm_schema fortran_orm_schema_t;

/** @brief Opaque horizontal shard manager handle (`fortran_orm_shard_t`). */
typedef struct fortran_orm_shard fortran_orm_shard_t;

/**
 * @brief Target SQL dialect for AST compilation and DDL generation.
 */
typedef enum fortran_orm_dialect {
  /** @brief SQLite (`?` placeholders, `LIMIT`/`OFFSET`, `ON CONFLICT`). */
  FORTRAN_ORM_DIALECT_SQLITE = 0,
  /** @brief PostgreSQL (`$1..$N` placeholders, `RETURNING`). */
  FORTRAN_ORM_DIALECT_POSTGRES = 1,
  /** @brief MySQL / MariaDB (`?` placeholders, `ON DUPLICATE KEY`). */
  FORTRAN_ORM_DIALECT_MYSQL = 2,
  /** @brief IBM Db2 (`FETCH FIRST`, `MERGE INTO`, `FINAL TABLE`, `WITH UR`). */
  FORTRAN_ORM_DIALECT_DB2 = 3,
  /** @brief Generic ANSI/ISO ODBC 3.52 (`OFFSET ... FETCH NEXT`). */
  FORTRAN_ORM_DIALECT_ODBC = 4
} fortran_orm_dialect_t;

/**
 * @brief Column and dynamic variant value types aligned with `c_orm_type_t`.
 */
typedef enum fortran_orm_col_type {
  /** @brief 32-bit signed integer (`INTEGER*4` / `C_INT32_T`). */
  FORTRAN_ORM_COL_INT32 = 0,
  /** @brief 64-bit signed integer (`INTEGER*8` / `C_INT64_T`). */
  FORTRAN_ORM_COL_INT64 = 1,
  /** @brief 32-bit IEEE float (`REAL*4` / `C_FLOAT`). */
  FORTRAN_ORM_COL_FLOAT32 = 2,
  /** @brief 64-bit IEEE double (`DOUBLE PRECISION` / `REAL*8` / `C_DOUBLE`). */
  FORTRAN_ORM_COL_FLOAT64 = 3,
  /** @brief Boolean flag (`LOGICAL` / `0` or `1`). */
  FORTRAN_ORM_COL_BOOL = 4,
  /** @brief NUL-terminated or blank-padded UTF-8/ASCII text string. */
  FORTRAN_ORM_COL_STRING = 5,
  /** @brief Raw binary byte buffer (`BLOB`). */
  FORTRAN_ORM_COL_BLOB = 6,
  /** @brief SQL `DATE` (`YYYY-MM-DD`). */
  FORTRAN_ORM_COL_DATE = 7,
  /** @brief SQL `TIMESTAMP` (`YYYY-MM-DD HH:MM:SS`). */
  FORTRAN_ORM_COL_TIMESTAMP = 8,
  /** @brief Exact 38-digit fixed-point decimal (`fortran_orm_decimal_t`). */
  FORTRAN_ORM_COL_DECIMAL = 15,
  /** @brief Fixed-width space-padded character (`CHAR(N)`). */
  FORTRAN_ORM_COL_CHAR_FIXED = 17,
  /** @brief Unknown or SQL `NULL` variant value. */
  FORTRAN_ORM_COL_NULL = 23
} fortran_orm_col_type_t;

/**
 * @brief Rounding modes for exact 38-digit decimal arithmetic and rescaling.
 */
typedef enum fortran_orm_round_mode {
  /** @brief Truncate toward zero. */
  FORTRAN_ORM_ROUND_TRUNCATE = 0,
  /** @brief Round half away from zero. */
  FORTRAN_ORM_ROUND_HALF_UP = 1,
  /** @brief Round half to nearest even digit (banker's rounding). */
  FORTRAN_ORM_ROUND_HALF_EVEN = 2,
  /** @brief Return `FORTRAN_ORM_ERROR_DECIMAL_INEXACT` if non-zero lost. */
  FORTRAN_ORM_ROUND_ERROR_IF_INEXACT = 3
} fortran_orm_round_mode_t;

/**
 * @brief Character codepages for mainframe EBCDIC <-> UTF-8/ASCII transcoding.
 */
typedef enum fortran_orm_codepage {
  /** @brief UTF-8 (CCSID 1208). */
  FORTRAN_ORM_CP_UTF8 = 0,
  /** @brief 7-bit ASCII / ISO-8859-1 (CCSID 367/819). */
  FORTRAN_ORM_CP_ASCII = 1,
  /** @brief US/Canada z/OS & Db2 EBCDIC (CCSID 37). */
  FORTRAN_ORM_CP_IBM037 = 2,
  /** @brief z/OS USS C/Fortran EBCDIC (CCSID 1047). */
  FORTRAN_ORM_CP_IBM1047 = 3,
  /** @brief International EBCDIC (CCSID 500). */
  FORTRAN_ORM_CP_IBM500 = 4,
  /** @brief US/Canada Euro EBCDIC with U+20AC at 0x9F (CCSID 1140). */
  FORTRAN_ORM_CP_IBM1140 = 5
} fortran_orm_codepage_t;

/**
 * @brief Transaction and statement isolation levels (Db2 & ODBC 3.52).
 */
typedef enum fortran_orm_isolation {
  /** @brief Uncommitted Read (`WITH UR` / `READ UNCOMMITTED`). */
  FORTRAN_ORM_ISO_UR = 0,
  /** @brief Cursor Stability (`WITH CS` / `READ COMMITTED`). */
  FORTRAN_ORM_ISO_CS = 1,
  /** @brief Read Stability (`WITH RS` / `REPEATABLE READ`). */
  FORTRAN_ORM_ISO_RS = 2,
  /** @brief Repeatable Read (`WITH RR` / `SERIALIZABLE`). */
  FORTRAN_ORM_ISO_RR = 3
} fortran_orm_isolation_t;

/**
 * @brief Relationship association kinds for runtime struct metadata.
 */
typedef enum fortran_orm_relation_kind {
  /** @brief One-to-one child association. */
  FORTRAN_ORM_REL_ONE_TO_ONE = 0,
  /** @brief Belongs-to parent association. */
  FORTRAN_ORM_REL_BELONGS_TO = 1,
  /** @brief One-to-many child collection. */
  FORTRAN_ORM_REL_ONE_TO_MANY = 2,
  /** @brief Many-to-many association via join table. */
  FORTRAN_ORM_REL_MANY_TO_MANY = 3
} fortran_orm_relation_kind_t;

/**
 * @brief Operation codes for the 1957 FORTRAN (I) external function `ICORMF`
 * and pre-CHARACTER legacy integer-handle dispatchers.
 */
typedef enum fortran_orm_legacy_op {
  /** @brief Connect using unpacked A1 INTEGER character-code array. */
  FORTRAN_ORM_OP_OPEN_A1 = 1,
  /** @brief Connect using packed A4 Hollerith INTEGER buffer. */
  FORTRAN_ORM_OP_OPEN_A4 = 2,
  /** @brief Disconnect integer DB handle slot. */
  FORTRAN_ORM_OP_CLOSE = 3,
  /** @brief Execute raw SQL from unpacked A1 INTEGER array. */
  FORTRAN_ORM_OP_EXEC_A1 = 4,
  /** @brief Execute raw SQL from packed A4 Hollerith buffer. */
  FORTRAN_ORM_OP_EXEC_A4 = 5,
  /** @brief Begin transaction on DB slot. */
  FORTRAN_ORM_OP_TX_BEGIN = 6,
  /** @brief Commit transaction on DB slot. */
  FORTRAN_ORM_OP_TX_COMMIT = 7,
  /** @brief Rollback transaction on DB slot. */
  FORTRAN_ORM_OP_TX_ROLLBACK = 8,
  /** @brief Prepare statement from unpacked A1 SQL array. */
  FORTRAN_ORM_OP_PREP_A1 = 9,
  /** @brief Prepare statement from packed A4 Hollerith SQL buffer. */
  FORTRAN_ORM_OP_PREP_A4 = 10,
  /** @brief Bind 32-bit INTEGER parameter (`1`-based index). */
  FORTRAN_ORM_OP_BIND_I32 = 11,
  /** @brief Bind DOUBLE PRECISION parameter (`1`-based index). */
  FORTRAN_ORM_OP_BIND_F64 = 12,
  /** @brief Bind unpacked A1 string parameter (`1`-based index). */
  FORTRAN_ORM_OP_BIND_A1 = 13,
  /** @brief Bind packed A4 Hollerith string parameter (`1`-based index). */
  FORTRAN_ORM_OP_BIND_A4 = 14,
  /** @brief Step prepared statement (`IVAL` receives `1` for row, `0` EOF). */
  FORTRAN_ORM_OP_STEP = 15,
  /** @brief Read 32-bit INTEGER column (`1`-based index) into `IVAL`. */
  FORTRAN_ORM_OP_COL_I32 = 16,
  /** @brief Read DOUBLE PRECISION column (`1`-based index) into `DVAL`. */
  FORTRAN_ORM_OP_COL_F64 = 17,
  /** @brief Read text column (`1`-based index) into unpacked A1 `IBUF`. */
  FORTRAN_ORM_OP_COL_A1 = 18,
  /** @brief Read text column (`1`-based index) into packed A4 `IBUF`. */
  FORTRAN_ORM_OP_COL_A4 = 19,
  /** @brief Finalize and release integer statement slot. */
  FORTRAN_ORM_OP_FINALIZE = 20,
  /** @brief Retrieve last inserted row ID into `IVAL`. */
  FORTRAN_ORM_OP_LAST_ROWID = 21
} fortran_orm_legacy_op_t;

/**
 * @brief Exact 38-digit base-10 fixed-point decimal POD structure (`BIND(C)`
 * layout: 44 bytes, natural 4-byte alignment).
 */
typedef struct fortran_orm_decimal {
  /** @brief `0` for non-negative, `1` for negative (`0` is always `0`). */
  fortran_orm_u8_t sign;
  /** @brief Active precision in digits (`1..38`). */
  fortran_orm_u8_t precision;
  /** @brief Fractional digits after radix point (`0..38`). */
  fortran_orm_u8_t scale;
  /** @brief Unpacked base-10 digits (`0..9`), least-significant at index `0`.
   */
  fortran_orm_u8_t digits[FORTRAN_ORM_DECIMAL_MAX_DIGITS];
  /** @brief Explicit reserved padding bytes (`0`) for 44-byte ABI alignment. */
  fortran_orm_u8_t reserved[3];
} fortran_orm_decimal_t;

/**
 * @brief Connection pool & session telemetry snapshot (`BIND(C)` POD layout).
 */
typedef struct fortran_orm_pool_stats {
  /** @brief Number of currently leased connections. */
  fortran_orm_i64_t active_connections;
  /** @brief Number of currently idle connections in pool. */
  fortran_orm_i64_t idle_connections;
  /** @brief Cumulative count of pool exhaustion events. */
  fortran_orm_i64_t exhaustion_count;
  /** @brief Moving average acquisition wait time in milliseconds. */
  double average_wait_time_ms;
  /** @brief Cumulative count of queries exceeding slow-query threshold. */
  fortran_orm_i64_t slow_queries_logged;
} fortran_orm_pool_stats_t;

/**
 * @brief Fixed-capacity C-interoperable POD record for OAuth2 tokens (`BIND(C)`
 * compatible without nested heap pointers).
 */
typedef struct fortran_orm_oauth2_token_pod {
  /** @brief NUL-terminated / blank-compatible bearer access token. */
  char access_token[256];
  /** @brief NUL-terminated refresh token. */
  char refresh_token[256];
  /** @brief NUL-terminated token type (e.g. `"Bearer"`). */
  char token_type[64];
  /** @brief Lifetime in seconds. */
  fortran_orm_i32_t expires_in;
  /** @brief Explicit alignment padding before 64-bit timestamp. */
  fortran_orm_i32_t reserved_pad;
  /** @brief Creation UNIX timestamp in seconds. */
  fortran_orm_i64_t created_at;
  /** @brief Associated user identifier. */
  char user_id[128];
  /** @brief Space-delimited scope list. */
  char scopes[256];
} fortran_orm_oauth2_token_pod_t;

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* FORTRAN_ORM_TYPES_H */
