/**
 * @file fortran_orm_str.c
 * @brief Error formatting, handle checks, blank-padded Fortran CHARACTER
 * marshaling, and FORTRAN I–66 A1/A4 Hollerith string codecs.
 */

/* clang-format off */
#include "fortran_orm_internal.h"
#include <string.h>
/* clang-format on */

/** @brief Canonical symbolic names indexed by `fortran_orm_error_t`. */
static const char *const k_error_names[] = {
    "FORTRAN_ORM_OK",
    "FORTRAN_ORM_ERROR_MEMORY",
    "FORTRAN_ORM_ERROR_CONNECTION",
    "FORTRAN_ORM_ERROR_SQL",
    "FORTRAN_ORM_ERROR_BIND",
    "FORTRAN_ORM_ERROR_STEP",
    "FORTRAN_ORM_ERROR_TYPE_MISMATCH",
    "FORTRAN_ORM_ERROR_NOT_FOUND",
    "FORTRAN_ORM_ERROR_NOT_IMPLEMENTED",
    "FORTRAN_ORM_ERROR_UNKNOWN",
    "FORTRAN_ORM_ERROR_EXPIRED",
    "FORTRAN_ORM_ERROR_VALIDATION",
    "FORTRAN_ORM_ERROR_RECURSION",
    "FORTRAN_ORM_ERROR_READ_ONLY",
    "FORTRAN_ORM_ERROR_NULL_POINTER",
    "FORTRAN_ORM_ERROR_IO",
    "FORTRAN_ORM_ERROR_PARSE",
    "FORTRAN_ORM_ERROR_OVERFLOW",
    "FORTRAN_ORM_ERROR_CYCLE",
    "FORTRAN_ORM_ERROR_BUSY",
    "FORTRAN_ORM_ERROR_CRYPTO",
    "FORTRAN_ORM_ERROR_CONSTRAINT",
    "FORTRAN_ORM_ERROR_DRIVER_LOAD",
    "FORTRAN_ORM_ERROR_ODBC_DIAG",
    "FORTRAN_ORM_ERROR_TIMEOUT",
    "FORTRAN_ORM_ERROR_DEADLOCK",
    "FORTRAN_ORM_ERROR_TRUNCATION",
    "FORTRAN_ORM_ERROR_DECIMAL_SYNTAX",
    "FORTRAN_ORM_ERROR_DECIMAL_OVERFLOW",
    "FORTRAN_ORM_ERROR_DECIMAL_INEXACT",
    "FORTRAN_ORM_ERROR_CODEPAGE",
    "FORTRAN_ORM_ERROR_COPYBOOK_SYNTAX",
    "FORTRAN_ORM_ERROR_INVALID_HANDLE",
    "FORTRAN_ORM_ERROR_HANDLE_TABLE_FULL",
    "FORTRAN_ORM_ERROR_BUFFER_TOO_SMALL",
    "FORTRAN_ORM_ERROR_INVALID_INDEX",
    "FORTRAN_ORM_ERROR_INVALID_OPCODE",
    "FORTRAN_ORM_ERROR_DESCRIPTOR_RANK",
    "FORTRAN_ORM_ERROR_DESCRIPTOR_TYPE"};

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t fortran_orm_keep_err(
    fortran_orm_error_t primary, fortran_orm_error_t secondary) {
  return (primary != FORTRAN_ORM_OK) ? primary : secondary;
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_from_c(c_orm_error_t rc) {
  return (fortran_orm_error_t)((int)rc);
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_check_db(const fortran_orm_db_t *db) {
  if (!db || db->magic != FORTRAN_ORM_MAGIC_DB || !db->db) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_check_stmt(const fortran_orm_stmt_t *stmt) {
  if (!stmt || stmt->magic != FORTRAN_ORM_MAGIC_STMT || !stmt->query ||
      !stmt->db) {
    return FORTRAN_ORM_ERROR_INVALID_HANDLE;
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t fortran_orm_slice_to_cstr(
    const char *buf, fortran_orm_u32_t len, int trim_right, char **out_cstr) {
  fortran_orm_u32_t eff_len = len;
  char *dst = NULL;
  c_orm_error_t crc;

  if (!out_cstr) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_cstr = NULL;
  if (len > 0 && !buf) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  if (buf) {
    fortran_orm_u32_t k;
    for (k = 0; k < eff_len; k++) {
      if (buf[k] == '\0') {
        eff_len = k;
        break;
      }
    }
    if (trim_right) {
      while (eff_len > 0 && buf[eff_len - 1] == ' ') {
        eff_len--;
      }
    }
  }

  crc = c_orm_system_malloc((size_t)eff_len + 1u, (void **)&dst);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  if (eff_len > 0) {
    memcpy(dst, buf, (size_t)eff_len);
  }
  dst[eff_len] = '\0';
  *out_cstr = dst;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t fortran_orm_cstr_to_fbuf(
    const char *cstr, char *out_buf, fortran_orm_u32_t buf_cap,
    fortran_orm_u32_t *out_len) {
  const char *src = cstr ? cstr : "";
  size_t slen = strlen(src);
  size_t ncopy;

  if (!out_len || (buf_cap > 0 && !out_buf)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }

  *out_len = (fortran_orm_u32_t)slen;
  ncopy = (slen < (size_t)buf_cap) ? slen : (size_t)buf_cap;
  if (ncopy > 0) {
    memcpy(out_buf, src, ncopy);
  }
  if ((size_t)buf_cap > ncopy) {
    memset(out_buf + ncopy, ' ', (size_t)buf_cap - ncopy);
  }
  if (slen > (size_t)buf_cap) {
    return FORTRAN_ORM_ERROR_TRUNCATION;
  }
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_a1_to_cstr(const fortran_orm_i32_t *a1_codes,
                       fortran_orm_u32_t count, char **out_cstr) {
  fortran_orm_u32_t eff = count;
  fortran_orm_u32_t i;
  char *dst = NULL;
  c_orm_error_t crc;

  if (!out_cstr || (count > 0 && !a1_codes)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  *out_cstr = NULL;

  for (i = 0; i < eff; i++) {
    if (a1_codes[i] == 0) {
      eff = i;
      break;
    }
  }
  while (eff > 0 && (a1_codes[eff - 1] & 0xFF) == (int)' ') {
    eff--;
  }

  crc = c_orm_system_malloc((size_t)eff + 1u, (void **)&dst);
  if (crc != C_ORM_OK) {
    return fortran_orm_from_c(crc);
  }
  for (i = 0; i < eff; i++) {
    dst[i] = (char)(a1_codes[i] & 0xFF);
  }
  dst[eff] = '\0';
  *out_cstr = dst;
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_a4_to_cstr(const fortran_orm_i32_t *a4_words,
                       fortran_orm_u32_t byte_len, char **out_cstr) {
  if (!out_cstr || (byte_len > 0 && !a4_words)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  return fortran_orm_slice_to_cstr((const char *)a4_words, byte_len, 1,
                                   out_cstr);
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_cstr_to_a4(const char *cstr, fortran_orm_i32_t *out_words,
                       fortran_orm_u32_t byte_cap, fortran_orm_u32_t *out_len) {
  if (!out_len || (byte_cap > 0 && !out_words)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  return fortran_orm_cstr_to_fbuf(cstr, (char *)out_words, byte_cap, out_len);
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_to_c(const fortran_orm_decimal_t *src, c_orm_decimal_t *dst) {
  if (!src || !dst) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  memset(dst, 0, sizeof(*dst));
  dst->sign = src->sign;
  dst->precision = src->precision;
  dst->scale = src->scale;
  memcpy(dst->digits, src->digits, FORTRAN_ORM_DECIMAL_MAX_DIGITS);
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_dec_from_c(const c_orm_decimal_t *src, fortran_orm_decimal_t *dst) {
  if (!src || !dst) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  memset(dst, 0, sizeof(*dst));
  dst->sign = src->sign;
  dst->precision = src->precision;
  dst->scale = src->scale;
  memcpy(dst->digits, src->digits, FORTRAN_ORM_DECIMAL_MAX_DIGITS);
  return FORTRAN_ORM_OK;
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_error_name(fortran_orm_error_t err, char *out_buf,
                       fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len) {
  size_t count = sizeof(k_error_names) / sizeof(k_error_names[0]);
  const char *name = "FORTRAN_ORM_ERROR_UNRECOGNIZED";
  if ((int)err >= 0 && (size_t)err < count) {
    name = k_error_names[(size_t)err];
  }
  return fortran_orm_cstr_to_fbuf(name, out_buf, buf_cap, out_len);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_version(char *out_buf, fortran_orm_u32_t buf_cap,
                    fortran_orm_u32_t *out_len) {
  return fortran_orm_cstr_to_fbuf(FORTRAN_ORM_VERSION_STR, out_buf, buf_cap,
                                  out_len);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_a1_to_str(const fortran_orm_i32_t *a1_codes,
                      fortran_orm_u32_t count, char *out_buf,
                      fortran_orm_u32_t buf_cap, fortran_orm_u32_t *out_len) {
  char *tmp = NULL;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  rc = fortran_orm_a1_to_cstr(a1_codes, count, &tmp);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  rc = fortran_orm_cstr_to_fbuf(tmp, out_buf, buf_cap, out_len);
  frc = fortran_orm_from_c(c_orm_system_free(tmp));
  return fortran_orm_keep_err(rc, frc);
}

FORTRAN_ORM_EXPORT FORTRAN_ORM_NO_DISCARD fortran_orm_error_t
fortran_orm_str_to_a1(const char *str, fortran_orm_u32_t str_len,
                      fortran_orm_i32_t *out_a1, fortran_orm_u32_t cap,
                      fortran_orm_u32_t *out_len) {
  char *tmp = NULL;
  size_t slen;
  size_t ncopy;
  size_t i;
  fortran_orm_error_t rc;
  fortran_orm_error_t frc;

  if (!out_len || (cap > 0 && !out_a1)) {
    return FORTRAN_ORM_ERROR_NULL_POINTER;
  }
  rc = fortran_orm_slice_to_cstr(str, str_len, 1, &tmp);
  if (rc != FORTRAN_ORM_OK) {
    return rc;
  }
  slen = strlen(tmp);
  *out_len = (fortran_orm_u32_t)slen;
  ncopy = (slen < (size_t)cap) ? slen : (size_t)cap;
  for (i = 0; i < ncopy; i++) {
    out_a1[i] = (fortran_orm_i32_t)((unsigned char)tmp[i]);
  }
  for (i = ncopy; i < (size_t)cap; i++) {
    out_a1[i] = (fortran_orm_i32_t)' ';
  }
  frc = fortran_orm_from_c(c_orm_system_free(tmp));
  if (slen > (size_t)cap) {
    return fortran_orm_keep_err(FORTRAN_ORM_ERROR_TRUNCATION, frc);
  }
  return frc;
}
