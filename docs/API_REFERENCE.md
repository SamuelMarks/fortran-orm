# API Reference

## 1. ISO C89 FFI Umbrella (`include/fortran_orm_ffi.h`)

All public C89 symbols are exported in `libfortran_orm` (`generated/fortran_orm_c.f90` via `cdd-c`) and return `fortran_orm_error_t` (`FORTRAN_ORM_NO_DISCARD`):

- **Version & Codecs**: `fortran_orm_error_name`, `fortran_orm_version`, `fortran_orm_a1_to_str`, `fortran_orm_str_to_a1`
- **Connections & Session**: `fortran_orm_connect`, `fortran_orm_connect_cstr`, `fortran_orm_disconnect`, `fortran_orm_exec_sql`, `fortran_orm_exec_cstr`, `fortran_orm_last_error`, `fortran_orm_last_trace`, `fortran_orm_last_insert_rowid`, `fortran_orm_enable_stmt_cache`, `fortran_orm_set_timezone`, `fortran_orm_set_slow_query_ms`, `fortran_orm_db_telemetry`, `fortran_orm_escape_string`
- **Pool & Shards**: `fortran_orm_pool_init`, `fortran_orm_pool_acquire`, `fortran_orm_pool_release`, `fortran_orm_pool_telemetry`, `fortran_orm_pool_destroy`, `fortran_orm_shard_init`, `fortran_orm_shard_add_node`, `fortran_orm_shard_route`, `fortran_orm_shard_free`
- **Transactions**: `fortran_orm_tx_begin`, `fortran_orm_tx_commit`, `fortran_orm_tx_rollback`, `fortran_orm_tx_savepoint`, `fortran_orm_tx_release_sp`, `fortran_orm_tx_rollback_sp`
- **Prepared Statements (1-Based)**: `fortran_orm_stmt_prepare`, `fortran_orm_stmt_prepare_cached`, `fortran_orm_stmt_bind_{i32,i64,f32,f64,logical,str,str_raw,blob,decimal,null}`, `fortran_orm_stmt_step`, `fortran_orm_stmt_reset`, `fortran_orm_stmt_finalize`, `fortran_orm_stmt_col_{count,name,is_null,i32,i64,f32,f64,logical,str,blob,decimal}`
- **Vectors & 2D Matrices**: `fortran_orm_insert_vec_{i32,i64,f64}`, `fortran_orm_query_vec_{i32,i64,f64}`, `fortran_orm_insert_matrix_f64`, `fortran_orm_query_matrix_f64`
- **Runtime `BIND(C)` CRUD**: `fortran_orm_schema_{create,add_col,add_relation,build_ddl,free}`, `fortran_orm_crud_{create_table,insert,upsert,update,update_optimistic,find_i32,find_for_update_i32,exists_i32,delete_i32,find_all}`
- **Abstract Rows & AST**: `fortran_orm_query_abstract`, `fortran_orm_rs_{row_count,col_count,col_name,is_null,get_i64,get_f64,get_str,to_json,free}`, `fortran_orm_ast_{select,insert,update,delete,distinct,where_i64,where_str,join,group_having,order_limit,set_i64,set_str,returning_lock,to_sql,exec,query_rs,free}`
- **Enterprise Extensions**: `fortran_orm_mig_{init,up,down,version,free}`, `fortran_orm_dec_{from_str,to_str,from_i64,to_i64,add,sub,mul,div,cmp,rescale}`, `fortran_orm_ebcdic_to_utf8`, `fortran_orm_utf8_to_ebcdic`, `fortran_orm_utf8_to_utf16`, `fortran_orm_utf16_to_utf8`, `fortran_orm_odbc_sqlstate`, `fortran_orm_set_isolation`, `fortran_orm_db2_configure`, `fortran_orm_uuid_v4`, `fortran_orm_oauth2_{init_tables,save_token,get_token,revoke_or_check}`

## 2. Fortran 2018/2023 CFI Descriptors (`src/fortran_orm_cfi.c`)

- `fortran_orm_cfi_connect(url_desc, out_db)`
- `fortran_orm_cfi_exec(db, sql_desc)`
- `fortran_orm_cfi_col_str(stmt, col_idx, out_desc, out_len)`
- `fortran_orm_cfi_insert_numeric(db, sql_desc, arr_desc)`
- `fortran_orm_cfi_query_numeric(db, sql_desc, out_arr_desc, out_rows)`

## 3. High-Level Fortran Era Abstractions (`fortran/`)

- **FORTRAN I–66 (`fortran/era/fortran_i..fortran66/`)**:
  - `ICORMF` (1957 FORTRAN I integer dispatcher), `F2OPEN..F2MATQ` & `F2OPA4..IF2OK` (`cormf2.f`, `corm2x.f`), `F3OPEN..F3MATQ` & `IF3BIT`/`IF3ALL` (`cormf3.f`, `corm3x.f`), `F4OPEN..DF4NRM` & `LF4LIV` (`cormf4.f`, `corm4x.f`), `C6OPEN..C6I2A1` (`corm66_lib.f`, `corm66_ext.f`).
- **FORTRAN 77 (`fortran/era/fortran77/corm77_{lib,orm}.f`)**:
  - `F7OPEN..F7MATQ`, scalar queries (`F7QINT`, `F7QDBL`, `F7QCHR`), repositories (`F7CNT`, `F7EXST`, `F7DELI`), Key-Value store (`F7KVCR`, `F7KVPT`, `F7KVGT`), savepoint-guarded vectors (`F7VECD`, `F7QRYD`), and AST renderer (`F7ASAL`).
- **Fortran 90 & 95 (`fortran_orm_f90_orm`, `fortran_orm_f95_orm`)**:
  - Fluent query builder `corm_query_f90_t`, Key-Value store `corm_kv_f90_t`, time-series ledger `corm_ts_f90_t`, generic `corm_f90_insert_vec`/`corm_f90_query_vec`; `PURE`/`ELEMENTAL` kernels, `FORALL` affine/masked matrices, and 2D mesh checkpoint handle `corm_grid2d_f95`.
- **Fortran 2003 (`fortran_orm_f2003`, `fortran_orm_f2003_ext`)**:
  - RAII OOP `orm_db_t`, `orm_stmt_t` (generic `bind`/`col`), `orm_pool_t`, `orm_rs_t`, `orm_ast_t`, `orm_schema_t`, `orm_tx_guard_t`, `orm_decimal_t`, `orm_migration_t`, `orm_shard_router_t`, `orm_oauth2_store_t`, `ABSTRACT` `orm_model_base_t`, and EBCDIC/UTF-16/A1 codecs.
- **Fortran 2008 (`fortran_orm_f2008` + `SUBMODULE`s)**:
  - Generic `CONTIGUOUS` `corm_f2008_insert_vec`/`corm_f2008_query_vec` (`INT32`, `INT64`, `REAL64`), padded submatrices, `DO CONCURRENT` `corm_f2008_zscore_cols`, and `orm_checkpoint_f2008_t`.
- **Fortran 2018 & 2023 (`fortran_orm_f2018`, `fortran_orm_f2023`, `fortran_orm`)**:
  - `SELECT RANK` Rank 0..3 volumetric tensor persistence (`corm_f2018_save_tensor_f64`, `corm_f2018_load_tensor_f64`), `F_C_STRING` connection/exec, 38-digit decimal canonical string suite (`corm_f2023_dec_{add,sub,mul,div,cmp,rescale}_str`), `orm_dataframe_f2023_t`, and `orm_session_f2023_t`.
