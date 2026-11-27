# Memory Ownership & RAII Lifecycle

## 1. Unified Allocator Discipline

Every internal heap allocation in `fortran-orm` routes through `c-orm`'s `c_orm_system_malloc` / `c_orm_system_calloc` / `c_orm_system_realloc` / `c_orm_system_free` hooks. In test builds (`C_ORM_TEST_ALLOCATOR=1`), `c_orm_set_allocators` injects deterministic allocation failures at step $k = 1 \dots N$, verifying zero memory leaks or dangling handles on every failure branch.

## 2. Handle Magic Tagging & Double-Free Protection

Every concrete C89 handle struct (`fortran_orm_db`, `fortran_orm_stmt`, `fortran_orm_pool`, `fortran_orm_ast`, `fortran_orm_rs`, `fortran_orm_mig`, `fortran_orm_schema`, `fortran_orm_shard`) begins with a distinct 32-bit magic tag (`FORTRAN_ORM_MAGIC_*`). Destructors zero the magic tag before freeing memory, turning accidental use-after-close calls into clean `FORTRAN_ORM_ERROR_INVALID_HANDLE` returns.

## 3. Fortran 2003–2023 `FINAL` RAII Destructors

In `fortran_orm_f2003` (and re-exported through `fortran_orm_f2008`, `fortran_orm_f2018`, `fortran_orm_f2023`, and `fortran_orm`), every wrapper type (`orm_db_t`, `orm_stmt_t`, `orm_pool_t`, `orm_ast_t`, `orm_rs_t`, `orm_schema_t`) defines a `FINAL` subroutine that automatically closes/frees any associated `TYPE(C_PTR)` when a local object leaves scope. Connections leased from an `orm_pool_t` track `from_pool = .TRUE.` so scope exit never disconnects a pooled raw handle prematurely.
