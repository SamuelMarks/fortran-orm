/**
 * @file fortran_orm_ext.c
 * @brief Schema migrations, exact 38-digit decimal arithmetic, EBCDIC and
 * UTF-16 GRAPHIC transcoders, IBM Db2/ODBC session helpers, UUID v4, and
 * OAuth2 token persistence bridges.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#include <string.h>
/* clang-format on */

/**
 * @brief Validates a `fortran_orm_mig_t` handle.
 *
 * @param[in] mig Candidate migration handle.
 * @return `FORTRAN_ORM_OK` or `FORTRAN_ORM_ERROR_INVALID_HANDLE`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
check_mig(const fortran_orm_mig_t *mig) {
  if (!mig || mig->magic != FORTRAN_ORM_MAGIC_MIG) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_init(fortran_orm_db_t *db, const char *dir_path,
                     fortran_orm_u32_t dir_len, fortran_orm_mig_t **out_mig) {
  char *c_dir = NULL;
  fortran_orm_mig_t *wrap = NULL;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  rc = fortran_orm_check_db(db);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_mig) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_mig = NULL;

  rc = fortran_orm_slice_to_cstr(dir_path, dir_len, 1, &c_dir);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_system_calloc(1u, sizeof(*wrap), (void **)&wrap);
  if (crc != C_ORM_OK) {
    fortran_orm_error_t f1 = fortran_orm_from_c(c_orm_system_free(c_dir));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), f1);
  }
  crc = c_orm_migration_init_table(db->db);
  if (crc != C_ORM_OK) {
    fortran_orm_error_t f1 = fortran_orm_from_c(c_orm_system_free(c_dir));
    fortran_orm_error_t f2 = fortran_orm_from_c(c_orm_system_free(wrap));
    return fortran_orm_keep_err(fortran_orm_from_c(crc),
                                fortran_orm_keep_err(f1, f2));
  }

  wrap->magic = FORTRAN_ORM_MAGIC_MIG;
  wrap->db = db->db;
  wrap->dir_path = c_dir;
  *out_mig = wrap;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_up(fortran_orm_mig_t *mig, fortran_orm_i32_t dry_run,
                   fortran_orm_u32_t *out_total_applied) {
  c_orm_migration_options_t opts;
  c_orm_migration_t *applied = NULL;
  size_t count = 0u;
  c_orm_error_t crc;
  fortran_orm_error_t chk = check_mig(mig);
  fortran_orm_error_t frc;

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_total_applied) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  memset(&opts, 0, sizeof(opts));
  opts.dry_run = dry_run ? 1 : 0;

  crc = c_orm_migrate_up(mig->db, mig->dir_path, &opts);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  crc = c_orm_migration_get_applied(mig->db, &applied, &count);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_total_applied = (fortran_orm_u32_t)count;
  frc = fortran_orm_from_c(c_orm_migration_free_array(applied, count));
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_down(fortran_orm_mig_t *mig, fortran_orm_u32_t steps,
                     fortran_orm_i32_t dry_run,
                     fortran_orm_u32_t *out_remaining) {
  c_orm_migration_options_t opts;
  c_orm_migration_t *applied = NULL;
  size_t count = 0u;
  c_orm_error_t crc;
  fortran_orm_error_t chk = check_mig(mig);
  fortran_orm_error_t frc;

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if (!out_remaining) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  memset(&opts, 0, sizeof(opts));
  opts.dry_run = dry_run ? 1 : 0;

  crc = c_orm_migrate_down(mig->db, mig->dir_path, (size_t)steps, &opts);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  crc = c_orm_migration_get_applied(mig->db, &applied, &count);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_remaining = (fortran_orm_u32_t)count;
  frc = fortran_orm_from_c(c_orm_migration_free_array(applied, count));
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_version(fortran_orm_mig_t *mig, char *out_ver,
                        fortran_orm_u32_t ver_cap, fortran_orm_u32_t *out_len) {
  c_orm_migration_t *applied = NULL;
  size_t count = 0u;
  const char *ver_str = "";
  c_orm_error_t crc;
  fortran_orm_error_t rc = check_mig(mig);
  fortran_orm_error_t frc;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_migration_get_applied(mig->db, &applied, &count);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  if (count > 0u) {
    ver_str = applied[count - 1u].version;
  }
  rc = fortran_orm_cstr_to_fbuf(ver_str, out_ver, ver_cap, out_len);
  frc = fortran_orm_from_c(c_orm_migration_free_array(applied, count));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_mig_free(fortran_orm_mig_t *mig) {
  char *dir;
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;
  fortran_orm_error_t chk = check_mig(mig);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  dir = mig->dir_path;
  mig->magic = 0u;
  mig->db = NULL;
  mig->dir_path = NULL;
  f1 = fortran_orm_from_c(c_orm_system_free(dir));
  f2 = fortran_orm_from_c(c_orm_system_free(mig));
  return fortran_orm_keep_err(f1, f2);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_from_str(const char *str, fortran_orm_u32_t str_len,
                         fortran_orm_decimal_t *out_dec) {
  char *c_str = NULL;
  const char *lead;
  c_orm_decimal_t c_dec;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_dec) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_slice_to_cstr(str, str_len, 1, &c_str);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  lead = c_str;
  while (*lead == ' ') {
    lead++;
  }
  crc = c_orm_decimal_from_str(lead, &c_dec);
  frc = fortran_orm_from_c(c_orm_system_free(c_str));
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }
  rc = fortran_orm_dec_from_c(&c_dec, out_dec);
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_to_str(const fortran_orm_decimal_t *dec, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len) {
  c_orm_decimal_t c_dec;
  char tmp[64];
  size_t written = 0u;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_dec_to_c(dec, &c_dec);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  tmp[0] = '\0';
  crc = c_orm_decimal_to_str(&c_dec, tmp, sizeof(tmp), &written);
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_cstr_to_fbuf(tmp, out_buf, buf_cap, out_len));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_from_i64(fortran_orm_i64_t val,
                         fortran_orm_decimal_t *out_dec) {
  c_orm_decimal_t c_dec;
  c_orm_error_t crc;

  if (!out_dec) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_decimal_from_int64((int64_t)val, &c_dec);
  return fortran_orm_keep_err(fortran_orm_from_c(crc),
                              fortran_orm_dec_from_c(&c_dec, out_dec));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_to_i64(const fortran_orm_decimal_t *dec,
                       fortran_orm_round_mode_t round_mode,
                       fortran_orm_i64_t *out_val) {
  c_orm_decimal_t c_dec;
  c_orm_int64_t v = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_dec_to_c(dec, &c_dec);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_val) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_decimal_to_int64(&c_dec, (c_orm_round_mode_t)round_mode, &v);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  *out_val = (fortran_orm_i64_t)v;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_add(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b,
                    fortran_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  if (!out_res) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_dec_to_c(a, &ca);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_dec_to_c(b, &cb);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_add(&ca, &cb, &cr);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return fortran_orm_dec_from_c(&cr, out_res);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_sub(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b,
                    fortran_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  if (!out_res) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_dec_to_c(a, &ca);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_dec_to_c(b, &cb);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_sub(&ca, &cb, &cr);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return fortran_orm_dec_from_c(&cr, out_res);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_mul(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b, fortran_orm_u32_t max_scale,
                    fortran_orm_round_mode_t round_mode,
                    fortran_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  if (!out_res) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (max_scale > FORTRAN_ORM_DECIMAL_MAX_DIGITS) {
    return FORTRAN_ORM_ERROR_DECIMAL_OVERFLOW;
  }
  rc = fortran_orm_dec_to_c(a, &ca);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_dec_to_c(b, &cb);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_mul(&ca, &cb, (unsigned char)max_scale,
                          (c_orm_round_mode_t)round_mode, &cr);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return fortran_orm_dec_from_c(&cr, out_res);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_div(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b,
                    fortran_orm_u32_t result_scale,
                    fortran_orm_round_mode_t round_mode,
                    fortran_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  if (!out_res) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (result_scale > FORTRAN_ORM_DECIMAL_MAX_DIGITS) {
    return FORTRAN_ORM_ERROR_DECIMAL_OVERFLOW;
  }
  rc = fortran_orm_dec_to_c(a, &ca);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_dec_to_c(b, &cb);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_div(&ca, &cb, (unsigned char)result_scale,
                          (c_orm_round_mode_t)round_mode, &cr);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return fortran_orm_dec_from_c(&cr, out_res);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_cmp(const fortran_orm_decimal_t *a,
                    const fortran_orm_decimal_t *b,
                    fortran_orm_i32_t *out_cmp) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  int cmp = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  if (!out_cmp) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_dec_to_c(a, &ca);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_dec_to_c(b, &cb);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_cmp(&ca, &cb, &cmp);
  *out_cmp = (fortran_orm_i32_t)cmp;
  return fortran_orm_from_c(crc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_rescale(const fortran_orm_decimal_t *dec,
                        fortran_orm_u32_t target_precision,
                        fortran_orm_u32_t target_scale,
                        fortran_orm_round_mode_t round_mode,
                        fortran_orm_decimal_t *out_dec) {
  c_orm_decimal_t c_in;
  c_orm_decimal_t c_out;
  c_orm_error_t crc;
  fortran_orm_error_t rc;

  if (!out_dec) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (target_precision == 0u ||
      target_precision > FORTRAN_ORM_DECIMAL_MAX_DIGITS ||
      target_scale > target_precision) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  rc = fortran_orm_dec_to_c(dec, &c_in);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_rescale(&c_in, (unsigned char)target_precision,
                              (unsigned char)target_scale,
                              (c_orm_round_mode_t)round_mode, &c_out);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  return fortran_orm_dec_from_c(&c_out, out_dec);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_ebcdic_to_utf8(fortran_orm_codepage_t codepage,
                           const fortran_orm_u8_t *ebcdic_bytes,
                           fortran_orm_u32_t byte_len, char *out_utf8,
                           fortran_orm_u32_t out_cap,
                           fortran_orm_u32_t *out_len) {
  char *tmp = NULL;
  size_t tmp_cap;
  size_t written = 0u;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_len || (byte_len > 0u && !ebcdic_bytes) ||
      (out_cap > 0u && !out_utf8)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  tmp_cap = ((size_t)byte_len * 3u) + 2u;
  crc = c_orm_system_malloc(tmp_cap, (void **)&tmp);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  crc = c_orm_ebcdic_to_utf8((c_orm_codepage_t)codepage, ebcdic_bytes,
                             (size_t)byte_len, tmp, tmp_cap, &written);
  if (crc != C_ORM_OK) {
    frc = fortran_orm_from_c(c_orm_system_free(tmp));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }
  rc = fortran_orm_cstr_to_fbuf(tmp, out_utf8, out_cap, out_len);
  frc = fortran_orm_from_c(c_orm_system_free(tmp));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_utf8_to_ebcdic(fortran_orm_codepage_t codepage,
                           const char *utf8_str, fortran_orm_u32_t str_len,
                           fortran_orm_u8_t *out_ebcdic,
                           fortran_orm_u32_t out_cap,
                           fortran_orm_u32_t *out_len) {
  char *c_str = NULL;
  size_t written = 0u;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_len || (out_cap > 0u && !out_ebcdic)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_slice_to_cstr(utf8_str, str_len, 1, &c_str);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_utf8_to_ebcdic((c_orm_codepage_t)codepage, c_str, strlen(c_str),
                             out_ebcdic, (size_t)out_cap, &written);
  frc = fortran_orm_from_c(c_orm_system_free(c_str));
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }
  *out_len = (fortran_orm_u32_t)written;
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_utf8_to_utf16(const char *utf8_str, fortran_orm_u32_t str_len,
                          fortran_orm_i32_t big_endian,
                          fortran_orm_u16_t *out_u16, fortran_orm_u32_t u16_cap,
                          fortran_orm_u32_t *out_units) {
  char *c_str = NULL;
  size_t units = 0u;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_units || (u16_cap > 0u && !out_u16)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_slice_to_cstr(utf8_str, str_len, 1, &c_str);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_utf8_to_utf16(c_str, strlen(c_str), big_endian ? 1 : 0, out_u16,
                            (size_t)u16_cap, &units);
  frc = fortran_orm_from_c(c_orm_system_free(c_str));
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }
  *out_units = (fortran_orm_u32_t)units;
  return frc;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_utf16_to_utf8(const fortran_orm_u16_t *u16_units,
                          fortran_orm_u32_t unit_count,
                          fortran_orm_i32_t big_endian, char *out_utf8,
                          fortran_orm_u32_t out_cap,
                          fortran_orm_u32_t *out_len) {
  char *tmp = NULL;
  size_t tmp_cap;
  size_t bytes = 0u;
  c_orm_error_t crc;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_len || (unit_count > 0u && !u16_units) ||
      (out_cap > 0u && !out_utf8)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  tmp_cap = ((size_t)unit_count * 4u) + 2u;
  crc = c_orm_system_malloc(tmp_cap, (void **)&tmp);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  crc = c_orm_utf16_to_utf8(u16_units, (size_t)unit_count, big_endian ? 1 : 0,
                            tmp, tmp_cap, &bytes);
  if (crc != C_ORM_OK) {
    frc = fortran_orm_from_c(c_orm_system_free(tmp));
    return fortran_orm_keep_err(fortran_orm_from_c(crc), frc);
  }
  rc = fortran_orm_cstr_to_fbuf(tmp, out_utf8, out_cap, out_len);
  frc = fortran_orm_from_c(c_orm_system_free(tmp));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_odbc_sqlstate(fortran_orm_db_t *db, char *out_state,
                          fortran_orm_u32_t state_cap,
                          fortran_orm_u32_t *out_len) {
  char state6[6];
  c_orm_error_t crc;
  fortran_orm_error_t chk = fortran_orm_check_db(db);

  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  state6[0] = '\0';
  crc = c_orm_odbc_get_sqlstate(db->db, state6);
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_cstr_to_fbuf(state6, out_state, state_cap, out_len));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_set_isolation(fortran_orm_db_t *db,
                          fortran_orm_isolation_t iso_level) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  if ((int)iso_level < 0 || (int)iso_level > (int)FORTRAN_ORM_ISO_RR) {
    return FORTRAN_ORM_ERROR_VALIDATION;
  }
  return fortran_orm_from_c(
      c_orm_db2_set_isolation(db->db, (c_orm_db2_isolation_t)iso_level));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_db2_configure(fortran_orm_db_t *db, const char *userid,
                          fortran_orm_u32_t userid_len, const char *applname,
                          fortran_orm_u32_t appl_len, const char *schema,
                          fortran_orm_u32_t schema_len) {
  char *c_uid = NULL;
  char *c_app = NULL;
  char *c_sch = NULL;
  c_orm_error_t crc = C_ORM_OK;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t f1 = FORTRAN_ORM_OK;
  fortran_orm_error_t f2 = FORTRAN_ORM_OK;
  fortran_orm_error_t f3 = FORTRAN_ORM_OK;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (userid_len > 0u) {
    rc = fortran_orm_slice_to_cstr(userid, userid_len, 1, &c_uid);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
  }
  if (appl_len > 0u) {
    rc = fortran_orm_slice_to_cstr(applname, appl_len, 1, &c_app);
    if (rc != FORTRAN_ORM_OK) {
      if (c_uid) {
        f1 = fortran_orm_from_c(c_orm_system_free(c_uid));
      }
      return fortran_orm_keep_err(rc, f1);
    }
  }
  if (schema_len > 0u) {
    rc = fortran_orm_slice_to_cstr(schema, schema_len, 1, &c_sch);
    if (rc != FORTRAN_ORM_OK) {
      if (c_app) {
        f1 = fortran_orm_from_c(c_orm_system_free(c_app));
      }
      if (c_uid) {
        f2 = fortran_orm_from_c(c_orm_system_free(c_uid));
      }
      return fortran_orm_keep_err(rc, fortran_orm_keep_err(f1, f2));
    }
  }

  if (c_uid || c_app) {
    crc = c_orm_db2_set_client_info(db->db, c_uid, NULL, c_app, NULL);
  }
  if (crc == C_ORM_OK && c_sch && c_sch[0] != '\0') {
    crc = c_orm_db2_set_current_schema(db->db, c_sch);
  }
  if (c_sch) {
    f1 = fortran_orm_from_c(c_orm_system_free(c_sch));
  }
  if (c_app) {
    f2 = fortran_orm_from_c(c_orm_system_free(c_app));
  }
  if (c_uid) {
    f3 = fortran_orm_from_c(c_orm_system_free(c_uid));
  }
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_keep_err(f1, fortran_orm_keep_err(f2, f3)));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_uuid_v4(char *out_uuid, fortran_orm_u32_t uuid_cap,
                    fortran_orm_u32_t *out_len) {
  char buf37[37];
  c_orm_error_t crc;

  if (!out_len || (uuid_cap > 0u && !out_uuid)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  buf37[0] = '\0';
  crc = c_orm_uuid_v4(buf37);
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_cstr_to_fbuf(buf37, out_uuid, uuid_cap, out_len));
}

/**
 * @brief Copies bounded string content from a fixed POD char array (trimmed of
 * trailing spaces if non-NUL-terminated) into a NUL-terminated stack buffer.
 *
 * @param[in] src Fixed POD character field.
 * @param[in] cap Capacity of `src`.
 * @param[out] dst Stack buffer of capacity `cap + 1`.
 * @return `FORTRAN_ORM_OK`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
pod_field_to_cstr(const char *src, size_t cap, char *dst) {
  size_t len = 0u;
  while (len < cap && src[len] != '\0') {
    len++;
  }
  if (len == cap) {
    while (len > 0u && src[len - 1u] == ' ') {
      len--;
    }
  }
  if (len > 0u) {
    memcpy(dst, src, len);
  }
  dst[len] = '\0';
  return FORTRAN_ORM_OK;
}

/**
 * @brief Copies a NUL-terminated C string into a fixed POD char array with
 * trailing NUL fill.
 *
 * @param[in] src Source C string (may be NULL).
 * @param[out] dst Fixed POD char array.
 * @param[in] cap Capacity of `dst` in bytes.
 * @return `FORTRAN_ORM_OK`.
 */
static FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
cstr_to_pod_field(const char *src, char *dst, size_t cap) {
  const char *s = src ? src : "";
  size_t len = strlen(s);
  if (len >= cap) {
    len = cap - 1u;
  }
  memset(dst, 0, cap);
  if (len > 0u) {
    memcpy(dst, s, len);
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_init_tables(fortran_orm_db_t *db) {
  fortran_orm_error_t chk = fortran_orm_check_db(db);
  if (chk != FORTRAN_ORM_OK) {
    return chk;
  }
  return fortran_orm_from_c(c_orm_oauth2_create_tables(db->db));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_save_token(fortran_orm_db_t *db,
                              const fortran_orm_oauth2_token_pod_t *token_pod) {
  char acc[257];
  char ref[257];
  char typ[65];
  char uid[129];
  char scp[257];
  c_orm_oauth2_token_t tok;
  fortran_orm_error_t rc = fortran_orm_check_db(db);

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!token_pod) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  rc = pod_field_to_cstr(token_pod->access_token,
                         sizeof(token_pod->access_token), acc);
  rc = fortran_orm_keep_err(
      rc, pod_field_to_cstr(token_pod->refresh_token,
                            sizeof(token_pod->refresh_token), ref));
  rc = fortran_orm_keep_err(rc, pod_field_to_cstr(token_pod->token_type,
                                                  sizeof(token_pod->token_type),
                                                  typ));
  rc = fortran_orm_keep_err(
      rc,
      pod_field_to_cstr(token_pod->user_id, sizeof(token_pod->user_id), uid));
  rc = fortran_orm_keep_err(
      rc, pod_field_to_cstr(token_pod->scopes, sizeof(token_pod->scopes), scp));

  tok.access_token = acc;
  tok.refresh_token = ref;
  tok.token_type = typ;
  tok.expires_in = token_pod->expires_in;
  tok.created_at = token_pod->created_at;
  tok.user_id = uid;
  tok.scopes = scp;

  return fortran_orm_keep_err(
      rc, fortran_orm_from_c(c_orm_oauth2_save_token(db->db, &tok)));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_get_token(fortran_orm_db_t *db, const char *access_token,
                             fortran_orm_u32_t token_len,
                             fortran_orm_oauth2_token_pod_t *out_pod) {
  char *c_tok = NULL;
  c_orm_oauth2_token_t tok;
  c_orm_error_t crc;
  fortran_orm_error_t rc = fortran_orm_check_db(db);
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;

  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  if (!out_pod) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  memset(&tok, 0, sizeof(tok));
  memset(out_pod, 0, sizeof(*out_pod));

  rc = fortran_orm_slice_to_cstr(access_token, token_len, 1, &c_tok);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  crc = c_orm_oauth2_get_token(db->db, c_tok, &tok);
  f1 = fortran_orm_from_c(c_orm_system_free(c_tok));
  if (crc != C_ORM_OK) {
    return fortran_orm_keep_err(fortran_orm_from_c(crc), f1);
  }

  rc = cstr_to_pod_field(tok.access_token, out_pod->access_token,
                         sizeof(out_pod->access_token));
  rc = fortran_orm_keep_err(
      rc, cstr_to_pod_field(tok.refresh_token, out_pod->refresh_token,
                            sizeof(out_pod->refresh_token)));
  rc = fortran_orm_keep_err(rc, cstr_to_pod_field(tok.token_type,
                                                  out_pod->token_type,
                                                  sizeof(out_pod->token_type)));
  rc = fortran_orm_keep_err(rc, cstr_to_pod_field(tok.user_id, out_pod->user_id,
                                                  sizeof(out_pod->user_id)));
  rc = fortran_orm_keep_err(rc, cstr_to_pod_field(tok.scopes, out_pod->scopes,
                                                  sizeof(out_pod->scopes)));
  out_pod->expires_in = tok.expires_in;
  out_pod->created_at = tok.created_at;

  f2 = fortran_orm_from_c(c_orm_free_columns(&c_orm_token_meta, &tok));
  return fortran_orm_keep_err(rc, fortran_orm_keep_err(f1, f2));
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_oauth2_revoke_or_check(
    fortran_orm_db_t *db, const char *access_token, fortran_orm_u32_t token_len,
    fortran_orm_i32_t revoke_flag, const char *granted_scopes,
    fortran_orm_u32_t granted_len, const char *req_scopes,
    fortran_orm_u32_t req_len, fortran_orm_i32_t *out_scope_valid) {
  char *c_gran = NULL;
  char *c_req = NULL;
  int valid = 0;
  c_orm_error_t crc;
  fortran_orm_error_t rc = FORTRAN_ORM_OK;
  fortran_orm_error_t f1;
  fortran_orm_error_t f2;

  if (!out_scope_valid) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  if (revoke_flag) {
    char *c_tok = NULL;
    fortran_orm_error_t ft;
    rc = fortran_orm_check_db(db);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    rc = fortran_orm_slice_to_cstr(access_token, token_len, 1, &c_tok);
    if (rc != FORTRAN_ORM_OK) {
      return rc;
    }
    crc = c_orm_oauth2_revoke_token(db->db, c_tok);
    ft = fortran_orm_from_c(c_orm_system_free(c_tok));
    if (crc != C_ORM_OK) {
      return fortran_orm_keep_err(fortran_orm_from_c(crc), ft);
    }
    rc = ft;
  }

  f1 = fortran_orm_slice_to_cstr(granted_scopes, granted_len, 1, &c_gran);
  if (f1 != FORTRAN_ORM_OK) {
    return fortran_orm_keep_err(rc, f1);
  }
  f2 = fortran_orm_slice_to_cstr(req_scopes, req_len, 1, &c_req);
  if (f2 != FORTRAN_ORM_OK) {
    fortran_orm_error_t fg = fortran_orm_from_c(c_orm_system_free(c_gran));
    return fortran_orm_keep_err(rc, fortran_orm_keep_err(f2, fg));
  }
  crc = c_orm_oauth2_validate_scope(c_gran, c_req, &valid);
  *out_scope_valid = (fortran_orm_i32_t)valid;
  f1 = fortran_orm_from_c(c_orm_system_free(c_req));
  f2 = fortran_orm_from_c(c_orm_system_free(c_gran));
  return fortran_orm_keep_err(
      fortran_orm_from_c(crc),
      fortran_orm_keep_err(rc, fortran_orm_keep_err(f1, f2)));
}
