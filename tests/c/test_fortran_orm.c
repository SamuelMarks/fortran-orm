/**
 * @file test_fortran_orm.c
 * @brief Master ISO C89 unit, ABI-parity, legacy symbol, CFI descriptor, and
 * deterministic OOM fault-injection test runner for fortran-orm.
 */

/* clang-format off */
#ifndef C_ORM_TEST_ALLOCATOR
/** @brief Enable c-orm custom allocator hooks for deterministic OOM testing. */
#define C_ORM_TEST_ALLOCATOR 1
#endif
#include "fortran_orm_internal.h"
#include "greatest.h"
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#if defined(_WIN32)
#include <direct.h>
#define rmdir _rmdir
#else
#include <sys/stat.h>
#include <unistd.h>
#endif
/* clang-format on */

/** @brief Countdown for deterministic OOM fault injection (`0` = disabled). */
static int g_oom_countdown = 0;

/**
 * @brief Fault-injecting `malloc` callback for deterministic OOM sweeps.
 *
 * @param[in] sz Allocation size in bytes.
 * @param[out] out_ptr Receives allocated block or `NULL` on injected OOM.
 * @return `C_ORM_OK` or `C_ORM_ERROR_MEMORY`.
 */
static c_orm_error_t test_oom_malloc(size_t sz, void **out_ptr) {
  if (g_oom_countdown > 0) {
    g_oom_countdown--;
    if (g_oom_countdown == 0) {
      if (out_ptr) {
        *out_ptr = NULL;
      }
      return C_ORM_ERROR_MEMORY;
    }
  }
  return c_orm_default_malloc(sz, out_ptr);
}

/**
 * @brief Fault-injecting `realloc` callback for deterministic OOM sweeps.
 *
 * @param[in] ptr Existing allocation pointer.
 * @param[in] sz Requested new size in bytes.
 * @param[out] out_ptr Receives reallocated block or `NULL` on injected OOM.
 * @return `C_ORM_OK` or `C_ORM_ERROR_MEMORY`.
 */
static c_orm_error_t test_oom_realloc(void *ptr, size_t sz, void **out_ptr) {
  if (g_oom_countdown > 0) {
    g_oom_countdown--;
    if (g_oom_countdown == 0) {
      if (out_ptr) {
        *out_ptr = NULL;
      }
      return C_ORM_ERROR_MEMORY;
    }
  }
  return c_orm_default_realloc(ptr, sz, out_ptr);
}

/**
 * @brief Standard `free` callback paired with fault-injecting allocators.
 *
 * @param[in] ptr Heap block to free.
 * @return `C_ORM_OK`.
 */
static c_orm_error_t test_oom_free(void *ptr) {
  return c_orm_default_free(ptr);
}

/**
 * @brief Configures or resets the deterministic OOM countdown allocator.
 *
 * @param[in] fail_at 1-based allocation index to fail, or `0` to reset.
 * @return `FORTRAN_ORM_OK` on success.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t set_oom_at(int fail_at) {
  g_oom_countdown = fail_at;
  if (fail_at > 0) {
    return fortran_orm_from_c(
        c_orm_set_allocators(test_oom_malloc, test_oom_realloc, test_oom_free));
  }
  return fortran_orm_from_c(c_orm_reset_allocators());
}

/* clang-format off */
#include "test_str_db_pool_tx.h"
#include "test_stmt_matrix_crud.h"
#include "test_query_ext.h"
#include "test_legacy_f77_cfi_oom.h"
/* clang-format on */

/**
 * @brief Registers all C89 unit and OOM suites.
 */
SUITE(fortran_orm_suite) {
  RUN_TEST(test_str_and_abi);
  RUN_TEST(test_db_pool_shard_and_tx);
  RUN_TEST(test_stmt_all_types);
  RUN_TEST(test_matrix_and_crud);
  RUN_TEST(test_abstract_rs_and_ast);
  RUN_TEST(test_extensions_all);
  RUN_TEST(test_legacy_bridge_all);
  RUN_TEST(test_f77_and_cfi_bridges);
  RUN_TEST(test_oom_fault_injection_sweep);
}

GREATEST_MAIN_DEFS();

/**
 * @brief CTest entry point running `fortran_orm_suite`.
 *
 * @param[in] argc Command-line argument count.
 * @param[in] argv Command-line argument vector.
 * @return `0` when all assertions pass, non-zero otherwise.
 */
int main(int argc, char **argv) {
  GREATEST_MAIN_BEGIN();
  RUN_SUITE(fortran_orm_suite);
  GREATEST_MAIN_END();
}
