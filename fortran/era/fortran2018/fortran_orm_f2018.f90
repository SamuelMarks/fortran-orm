!> @file fortran_orm_f2018.f90
!> @module fortran_orm_f2018
!> @brief ISO/IEC 1539-1:2018 Fortran 2018 Enhanced C Interoperability
!> (`CFI_cdesc_t` / TS 29113) & `SELECT RANK` volumetric tensor ORM module.
!>
!> Uses Fortran 2018 `IMPLICIT NONE (TYPE, EXTERNAL)`, direct `CHARACTER(LEN=*)`
!> `BIND(C)` descriptor arguments (zero `C_NULL_CHAR` copies), assumed-rank
!> `TYPE(*), DIMENSION(..)` `BIND(C)` interfaces supporting arbitrary strided
!> non-contiguous Fortran array slices (`A(1:10:2, :)`), and `SELECT RANK`
!> persistence for Rank-0 scalars, Rank-1 vectors, Rank-2 matrices, and
!> Rank-3 `(nx, ny, nz)` 3D PDE bricks.
MODULE fortran_orm_f2018
  USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_PTR, C_INT, C_INT32_T, C_CHAR
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY : INT32, REAL64
  USE fortran_orm_c, ONLY : FORTRAN_ORM_ERROR_DESCRIPTOR_RANK, &
                            FORTRAN_ORM_ERROR_VALIDATION
  USE fortran_orm_f2003, ONLY : orm_db_t, orm_stmt_t, FORTRAN_ORM_OK
  IMPLICIT NONE (TYPE, EXTERNAL)
  PRIVATE

  PUBLIC :: FORTRAN_ORM_OK, FORTRAN_ORM_ERROR_DESCRIPTOR_RANK
  PUBLIC :: FORTRAN_ORM_ERROR_VALIDATION
  PUBLIC :: orm_db_t, orm_stmt_t
  PUBLIC :: fortran_orm_cfi_connect, fortran_orm_cfi_exec
  PUBLIC :: fortran_orm_cfi_col_str
  PUBLIC :: fortran_orm_cfi_insert_numeric, fortran_orm_cfi_query_numeric
  PUBLIC :: corm_f2018_open, corm_f2018_exec
  PUBLIC :: corm_f2018_insert_any_rank, corm_f2018_query_any_rank
  PUBLIC :: corm_f2018_rank_of, corm_f2018_is_contig
  PUBLIC :: corm_f2018_col_str_alloc
  PUBLIC :: corm_f2018_save_tensor_f64, corm_f2018_load_tensor_f64

  INTERFACE
    !> @brief Direct Fortran 2018 CHARACTER(LEN=*) CFI descriptor connect.
    !> @param[in] url_desc Native Fortran string passed via CFI_cdesc_t.
    !> @param[out] out_db Allocated database C_PTR handle.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_connect(url_desc, out_db) &
        BIND(C, NAME="fortran_orm_cfi_connect") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: url_desc
      TYPE(C_PTR), INTENT(OUT) :: out_db
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_connect

    !> @brief Direct Fortran 2018 CHARACTER(LEN=*) CFI descriptor SQL exec.
    !> @param[in] db Active database C_PTR handle.
    !> @param[in] sql_desc Native Fortran SQL string passed via CFI_cdesc_t.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_exec(db, sql_desc) &
        BIND(C, NAME="fortran_orm_cfi_exec") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: db
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: sql_desc
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_exec

    !> @brief Direct Fortran 2018 CHARACTER(LEN=*) CFI descriptor column reader.
    !> @param[in] stmt Active prepared statement C_PTR handle.
    !> @param[in] col_idx 1-based column index.
    !> @param[out] out_desc Destination CHARACTER(LEN=*) CFI descriptor.
    !> @param[out] out_len Trimmed string length.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_col_str(stmt, col_idx, out_desc, out_len) &
        BIND(C, NAME="fortran_orm_cfi_col_str") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_INT32_T, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: stmt
      INTEGER(C_INT32_T), VALUE :: col_idx
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(OUT) :: out_desc
      INTEGER(C_INT32_T), INTENT(OUT) :: out_len
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_col_str

    !> @brief Direct Fortran 2018 assumed-rank & assumed-type numeric insert
    !> supporting rank-1 vectors and rank-2 strided matrix slices.
    !> @param[in] db Active database C_PTR handle.
    !> @param[in] sql_desc Parameterized INSERT SQL string descriptor.
    !> @param[in] arr_desc Assumed-rank `DIMENSION(..)` array or slice.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_insert_numeric(db, sql_desc, arr_desc) &
        BIND(C, NAME="fortran_orm_cfi_insert_numeric") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: db
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: sql_desc
      TYPE(*), DIMENSION(..), INTENT(IN) :: arr_desc
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_insert_numeric

    !> @brief Direct Fortran 2018 assumed-rank & assumed-type numeric query
    !> hydrating rank-1 vectors or rank-2 strided matrix slices.
    !> @param[in] db Active database C_PTR handle.
    !> @param[in] sql_desc SELECT SQL string descriptor.
    !> @param[inout] out_arr_desc Assumed-rank destination array or slice.
    !> @param[out] out_rows Number of rows hydrated.
    !> @return Unified `fortran_orm_error_t` status code.
    FUNCTION fortran_orm_cfi_query_numeric(db, sql_desc, out_arr_desc, &
                                           out_rows) &
        BIND(C, NAME="fortran_orm_cfi_query_numeric") RESULT(rc)
      IMPORT :: C_PTR, C_INT, C_INT32_T, C_CHAR
      IMPLICIT NONE (TYPE, EXTERNAL)
      TYPE(C_PTR), VALUE :: db
      CHARACTER(LEN=*, KIND=C_CHAR), INTENT(IN) :: sql_desc
      TYPE(*), DIMENSION(..), INTENT(INOUT) :: out_arr_desc
      INTEGER(C_INT32_T), INTENT(OUT) :: out_rows
      INTEGER(C_INT) :: rc
    END FUNCTION fortran_orm_cfi_query_numeric
  END INTERFACE

CONTAINS

  !> @brief Formats positive column index `idx` into `"c<idx>"`.
  !> @param[in] idx 1-based column number (`1..99`).
  !> @return Trimmed column tag string.
  PURE FUNCTION f18_col_tag(idx) RESULT(tag)
    INTEGER(INT32), INTENT(IN) :: idx
    CHARACTER(LEN=4) :: tag
    WRITE (tag, '("c",I0)') idx
  END FUNCTION f18_col_tag

  !> @brief Builds `CREATE TABLE` and `INSERT INTO` SQL for `n_cols` columns.
  !> @param[in] table_name Target SQL table identifier.
  !> @param[in] n_cols Number of REAL64 columns (`1..16`).
  !> @param[out] ddl_sql Receives `CREATE TABLE` DDL string.
  !> @param[out] ins_sql Receives parameterized `INSERT` SQL string.
  !> @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_VALIDATION`.
  FUNCTION f18_build_table_sql(table_name, n_cols, ddl_sql, ins_sql) &
      RESULT(rc)
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    INTEGER(INT32), INTENT(IN) :: n_cols
    CHARACTER(LEN=512), INTENT(OUT) :: ddl_sql, ins_sql
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=256) :: col_defs, qmarks
    INTEGER(INT32) :: c, lt
    ddl_sql = ""
    ins_sql = ""
    lt = INT(LEN_TRIM(table_name), INT32)
    IF (lt <= 0_INT32 .OR. lt > 48_INT32 .OR. &
        n_cols < 1_INT32 .OR. n_cols > 16_INT32) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    col_defs = TRIM(f18_col_tag(1_INT32)) // " REAL NOT NULL"
    qmarks = "?"
    DO c = 2_INT32, n_cols
      col_defs = TRIM(col_defs) // ", " // TRIM(f18_col_tag(c)) // &
                 " REAL NOT NULL"
      qmarks = TRIM(qmarks) // ",?"
    END DO
    ddl_sql = "CREATE TABLE IF NOT EXISTS " // TRIM(table_name) // &
              "(" // TRIM(col_defs) // ")"
    ins_sql = "INSERT INTO " // TRIM(table_name) // &
              " VALUES(" // TRIM(qmarks) // ")"
    rc = FORTRAN_ORM_OK
  END FUNCTION f18_build_table_sql

  !> @brief Opens `db` directly via Fortran 2018 CFI `CHARACTER(LEN=*)`.
  !> @param[inout] db Database RAII object.
  !> @param[in] url Connection URL string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_open(db, url) RESULT(rc)
    CLASS(orm_db_t), INTENT(INOUT) :: db
    CHARACTER(LEN=*), INTENT(IN) :: url
    INTEGER(C_INT) :: rc
    INTEGER(C_INT) :: prev_rc
    prev_rc = db%close()
    rc = fortran_orm_cfi_connect(url, db%ptr)
  END FUNCTION corm_f2018_open

  !> @brief Executes SQL directly via Fortran 2018 CFI `CHARACTER(LEN=*)`.
  !> @param[in] db Active database RAII object.
  !> @param[in] sql SQL text.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_exec(db, sql) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    INTEGER(C_INT) :: rc
    rc = fortran_orm_cfi_exec(db%ptr, sql)
  END FUNCTION corm_f2018_exec

  !> @brief Inserts any rank-1 or rank-2 INT32/REAL64 array or strided slice.
  !> @param[in] db Active database RAII object.
  !> @param[in] sql Parameterized INSERT SQL.
  !> @param[in] arr Assumed-rank INT32 or REAL64 array/slice.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_insert_any_rank(db, sql, arr) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    TYPE(*), DIMENSION(..), INTENT(IN) :: arr
    INTEGER(C_INT) :: rc
    rc = fortran_orm_cfi_insert_numeric(db%ptr, sql, arr)
  END FUNCTION corm_f2018_insert_any_rank

  !> @brief Hydrates any rank-1 or rank-2 INT32/REAL64 array or strided slice.
  !> @param[in] db Active database RAII object.
  !> @param[in] sql SELECT SQL query.
  !> @param[inout] arr Assumed-rank destination INT32 or REAL64 array/slice.
  !> @param[out] out_rows Number of hydrated rows.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_query_any_rank(db, sql, arr, out_rows) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: sql
    TYPE(*), DIMENSION(..), INTENT(INOUT) :: arr
    INTEGER(INT32), INTENT(OUT) :: out_rows
    INTEGER(C_INT) :: rc
    rc = fortran_orm_cfi_query_numeric(db%ptr, sql, arr, out_rows)
  END FUNCTION corm_f2018_query_any_rank

  !> @brief Returns the runtime rank (`0..15`) of any assumed-rank object.
  !> @param[in] arr Assumed-type, assumed-rank Fortran variable or slice.
  !> @return Rank integer (`0` for scalar).
  PURE FUNCTION corm_f2018_rank_of(arr) RESULT(rnk)
    TYPE(*), DIMENSION(..), INTENT(IN) :: arr
    INTEGER(INT32) :: rnk
    rnk = INT(RANK(arr), INT32)
  END FUNCTION corm_f2018_rank_of

  !> @brief Inspects memory contiguity of assumed-rank REAL64 `arr` (`0..3`).
  !> @param[in] arr Assumed-rank REAL64 scalar, array, or strided slice.
  !> @return `.TRUE.` if rank `0` or contiguous rank `1..3`, else `.FALSE.`.
  PURE FUNCTION corm_f2018_is_contig(arr) RESULT(flag)
    REAL(REAL64), DIMENSION(..), INTENT(IN) :: arr
    LOGICAL :: flag
    SELECT RANK (arr)
    RANK (0)
      flag = .TRUE.
    RANK (1)
      flag = IS_CONTIGUOUS(arr)
    RANK (2)
      flag = IS_CONTIGUOUS(arr)
    RANK (3)
      flag = IS_CONTIGUOUS(arr)
    RANK DEFAULT
      flag = .FALSE.
    END SELECT
  END FUNCTION corm_f2018_is_contig

  !> @brief Reads a text column from `stmt` via TS 29113 CFI into `out_str`.
  !> @param[in] stmt Active prepared statement object.
  !> @param[in] col_idx 1-based column position.
  !> @param[out] out_str Deferred-length allocatable string.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_col_str_alloc(stmt, col_idx, out_str) RESULT(rc)
    CLASS(orm_stmt_t), INTENT(IN) :: stmt
    INTEGER(INT32), INTENT(IN) :: col_idx
    CHARACTER(LEN=:), ALLOCATABLE, INTENT(OUT) :: out_str
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512, KIND=C_CHAR) :: scratch
    INTEGER(INT32) :: slen
    slen = 0_INT32
    rc = fortran_orm_cfi_col_str(stmt%ptr, col_idx, scratch, slen)
    IF (rc == FORTRAN_ORM_OK .AND. slen > 0_INT32) THEN
      out_str = scratch(1:slen)
    ELSE
      out_str = ""
    END IF
  END FUNCTION corm_f2018_col_str_alloc

  !> @brief Persists a Rank-0, Rank-1, Rank-2, or Rank-3 REAL64 tensor (or
  !> strided slice!) into `table_name` using Fortran 2018 `SELECT RANK`.
  !> @param[in] db Active database connection.
  !> @param[in] table_name Destination SQL table name.
  !> @param[in] arr Assumed-rank REAL64 scalar, vector, matrix, or 3D brick.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_save_tensor_f64(db, table_name, arr) RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    REAL(REAL64), DIMENSION(..), INTENT(IN) :: arr
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512) :: ddl_sql, ins_sql, clr_sql
    REAL(REAL64), DIMENSION(1) :: sbuf
    INTEGER(INT32) :: ny, nz, kz, sp_rc

    SELECT RANK (arr)
    RANK (0)
      rc = f18_build_table_sql(table_name, 1_INT32, ddl_sql, ins_sql)
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = corm_f2018_exec(db, TRIM(ddl_sql))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      clr_sql = "DELETE FROM " // TRIM(table_name)
      rc = corm_f2018_exec(db, TRIM(clr_sql))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      sbuf(1) = arr
      rc = fortran_orm_cfi_insert_numeric(db%ptr, TRIM(ins_sql), sbuf)

    RANK (1)
      rc = f18_build_table_sql(table_name, 1_INT32, ddl_sql, ins_sql)
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = corm_f2018_exec(db, TRIM(ddl_sql))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      clr_sql = "DELETE FROM " // TRIM(table_name)
      rc = corm_f2018_exec(db, TRIM(clr_sql))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = fortran_orm_cfi_insert_numeric(db%ptr, TRIM(ins_sql), arr)

    RANK (2)
      ny = INT(SIZE(arr, 2), INT32)
      rc = f18_build_table_sql(table_name, ny, ddl_sql, ins_sql)
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = corm_f2018_exec(db, TRIM(ddl_sql))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      clr_sql = "DELETE FROM " // TRIM(table_name)
      rc = corm_f2018_exec(db, TRIM(clr_sql))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = fortran_orm_cfi_insert_numeric(db%ptr, TRIM(ins_sql), arr)

    RANK (3)
      ny = INT(SIZE(arr, 2), INT32)
      nz = INT(SIZE(arr, 3), INT32)
      rc = f18_build_table_sql(table_name, ny, ddl_sql, ins_sql)
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = corm_f2018_exec(db, TRIM(ddl_sql))
      IF (rc /= FORTRAN_ORM_OK) RETURN
      rc = db%savepoint("f18_r3")
      IF (rc /= FORTRAN_ORM_OK) RETURN
      clr_sql = "DELETE FROM " // TRIM(table_name)
      rc = corm_f2018_exec(db, TRIM(clr_sql))
      DO kz = 1_INT32, nz
        IF (rc /= FORTRAN_ORM_OK) EXIT
        rc = fortran_orm_cfi_insert_numeric(db%ptr, TRIM(ins_sql), &
                                            arr(:, :, kz))
      END DO
      IF (rc == FORTRAN_ORM_OK) THEN
        rc = db%release_sp("f18_r3")
      ELSE
        sp_rc = db%rollback_sp("f18_r3")
        sp_rc = db%release_sp("f18_r3")
      END IF

    RANK DEFAULT
      rc = FORTRAN_ORM_ERROR_DESCRIPTOR_RANK
    END SELECT
  END FUNCTION corm_f2018_save_tensor_f64

  !> @brief Hydrates a Rank-0, Rank-1, Rank-2, or Rank-3 REAL64 tensor (or
  !> strided slice!) from `table_name` using Fortran 2018 `SELECT RANK`.
  !> @param[in] db Active database connection.
  !> @param[in] table_name Source SQL table name.
  !> @param[inout] arr Assumed-rank REAL64 scalar, vector, matrix, or 3D brick.
  !> @param[out] out_items Total number of rows hydrated across slabs.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION corm_f2018_load_tensor_f64(db, table_name, arr, out_items) &
      RESULT(rc)
    CLASS(orm_db_t), INTENT(IN) :: db
    CHARACTER(LEN=*), INTENT(IN) :: table_name
    REAL(REAL64), DIMENSION(..), INTENT(INOUT) :: arr
    INTEGER(INT32), INTENT(OUT) :: out_items
    INTEGER(C_INT) :: rc
    CHARACTER(LEN=512) :: sel_sql
    REAL(REAL64), DIMENSION(1) :: sbuf
    INTEGER(INT32) :: nx, nz, kz, slab_rows, off_rows

    out_items = 0_INT32
    IF (LEN_TRIM(table_name) == 0) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF

    SELECT RANK (arr)
    RANK (0)
      sbuf(1) = 0.0_REAL64
      sel_sql = "SELECT * FROM " // TRIM(table_name) // " LIMIT 1"
      rc = fortran_orm_cfi_query_numeric(db%ptr, TRIM(sel_sql), sbuf, &
                                         out_items)
      IF (rc == FORTRAN_ORM_OK .AND. out_items > 0_INT32) arr = sbuf(1)

    RANK (1)
      sel_sql = "SELECT * FROM " // TRIM(table_name)
      rc = fortran_orm_cfi_query_numeric(db%ptr, TRIM(sel_sql), arr, &
                                         out_items)

    RANK (2)
      sel_sql = "SELECT * FROM " // TRIM(table_name)
      rc = fortran_orm_cfi_query_numeric(db%ptr, TRIM(sel_sql), arr, &
                                         out_items)

    RANK (3)
      nx = INT(SIZE(arr, 1), INT32)
      nz = INT(SIZE(arr, 3), INT32)
      rc = FORTRAN_ORM_OK
      DO kz = 1_INT32, nz
        off_rows = (kz - 1_INT32) * nx
        WRITE (sel_sql, '("SELECT * FROM ",A," LIMIT ",I0," OFFSET ",I0)') &
          TRIM(table_name), nx, off_rows
        slab_rows = 0_INT32
        rc = fortran_orm_cfi_query_numeric(db%ptr, TRIM(sel_sql), &
                                           arr(:, :, kz), slab_rows)
        IF (rc /= FORTRAN_ORM_OK) EXIT
        out_items = out_items + slab_rows
      END DO

    RANK DEFAULT
      rc = FORTRAN_ORM_ERROR_DESCRIPTOR_RANK
    END SELECT
  END FUNCTION corm_f2018_load_tensor_f64

END MODULE fortran_orm_f2018
