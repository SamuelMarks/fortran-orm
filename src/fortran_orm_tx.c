/**
 * @file fortran_orm_tx.c
 * @brief Explicit database transactions and nested savepoint bridges.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
/* clang-format on */

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_begin(fortran_orm_db_t *db) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(c_orm_transaction_begin(db->db));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_commit(fortran_orm_db_t *db) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(c_orm_transaction_commit(db->db));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_rollback(fortran_orm_db_t *db) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(c_orm_transaction_rollback(db->db));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_savepoint(fortran_orm_db_t *db, const char *name,
                         fortran_orm_u32_t name_len) {
  char *c_name = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_slice_to_cstr(name, name_len, 1, &c_name);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_from_c(c_orm_savepoint_create(db->db, c_name));
  frc = fortran_orm_from_c(c_orm_system_free(c_name));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_release_sp(fortran_orm_db_t *db, const char *name,
                          fortran_orm_u32_t name_len) {
  char *c_name = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_slice_to_cstr(name, name_len, 1, &c_name);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_from_c(c_orm_savepoint_release(db->db, c_name));
  frc = fortran_orm_from_c(c_orm_system_free(c_name));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_tx_rollback_sp(fortran_orm_db_t *db, const char *name,
                           fortran_orm_u32_t name_len) {
  char *c_name = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_slice_to_cstr(name, name_len, 1, &c_name);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_from_c(c_orm_savepoint_rollback(db->db, c_name));
  frc = fortran_orm_from_c(c_orm_system_free(c_name));
  return fortran_orm_keep_err(rc, frc);
}
