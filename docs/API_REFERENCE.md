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
