/**
 * @file fortran_orm_export.h
 * @brief Symbol visibility, NO_DISCARD attributes, and portable fixed-width
 * integer typedefs for the ISO C89 fortran-orm FFI library.
 */

#ifndef FORTRAN_ORM_EXPORT_H
/** @brief Header guard for fortran_orm_export.h. */
#define FORTRAN_ORM_EXPORT_H

/* clang-format off */
#include <stddef.h>
#if defined(_MSC_VER) && _MSC_VER < 1600
typedef signed __int8 fortran_orm_i8_t;
typedef unsigned __int8 fortran_orm_u8_t;
typedef signed __int16 fortran_orm_i16_t;
typedef unsigned __int16 fortran_orm_u16_t;
typedef signed __int32 fortran_orm_i32_t;
typedef unsigned __int32 fortran_orm_u32_t;
typedef signed __int64 fortran_orm_i64_t;
typedef unsigned __int64 fortran_orm_u64_t;
#else
#include <stdint.h>
/** @brief Signed 8-bit integer matching Fortran INTEGER(C_INT8_T). */
typedef int8_t fortran_orm_i8_t;
/** @brief Unsigned 8-bit integer matching raw byte buffers. */
typedef uint8_t fortran_orm_u8_t;
/** @brief Signed 16-bit integer matching Fortran INTEGER*2 / C_INT16_T. */
typedef int16_t fortran_orm_i16_t;
/** @brief Unsigned 16-bit integer matching UTF-16 code units. */
typedef uint16_t fortran_orm_u16_t;
/** @brief Signed 32-bit integer matching Fortran INTEGER*4 / C_INT32_T. */
typedef int32_t fortran_orm_i32_t;
/** @brief Unsigned 32-bit integer for capacities and counts. */
typedef uint32_t fortran_orm_u32_t;
/** @brief Signed 64-bit integer matching Fortran INTEGER*8 / C_INT64_T. */
typedef int64_t fortran_orm_i64_t;
/** @brief Unsigned 64-bit integer. */
typedef uint64_t fortran_orm_u64_t;
#endif
/* clang-format on */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
 * @brief Hidden trailing character-length argument type used by FORTRAN
 * 77/90/95 compilers (`size_t` on GFortran >= 8 and Flang; `int` on f2c /
 * legacy G77).
 */
#if defined(FORTRAN_ORM_CHARLEN_INT)
typedef int fortran_charlen_t;
#else
typedef size_t fortran_charlen_t;
#endif

/**
 * @brief Shared library symbol export/import visibility macro.
 */
#ifndef FORTRAN_ORM_EXPORT
#if defined(_WIN32) || defined(__CYGWIN__)
#if defined(FORTRAN_ORM_SHARED)
#if defined(fortran_orm_c_EXPORTS)
#define FORTRAN_ORM_EXPORT __declspec(dllexport)
#else
#define FORTRAN_ORM_EXPORT __declspec(dllimport)
#endif
#else
#define FORTRAN_ORM_EXPORT
#endif
#elif defined(__GNUC__) && __GNUC__ >= 4
#define FORTRAN_ORM_EXPORT __attribute__((visibility("default")))
#else
#define FORTRAN_ORM_EXPORT
#endif
#endif

/**
 * @brief Mandatory return-value inspection attribute enforcing error-enum
 * percolation at compile time.
 */
#ifndef FORTRAN_ORM_NO_DISCARD
#if !defined(__CPPCHECK__) && defined(__STDC_VERSION__) &&                     \
    __STDC_VERSION__ >= 202311L
#define FORTRAN_ORM_NO_DISCARD [[nodiscard]]
#elif defined(__GNUC__) || defined(__clang__)
#define FORTRAN_ORM_NO_DISCARD __attribute__((warn_unused_result))
#elif defined(_MSC_VER) && _MSC_VER >= 1700
#define FORTRAN_ORM_NO_DISCARD _Check_return_
#else
#define FORTRAN_ORM_NO_DISCARD
#endif
#endif

/** @brief Semantic version string of the fortran-orm library. */
#define FORTRAN_ORM_VERSION_STR "0.1.0"

/** @brief Maximum decimal digits in fortran_orm_decimal_t (ANSI/ODBC max). */
#define FORTRAN_ORM_DECIMAL_MAX_DIGITS 38

/** @brief Initial slot capacity for integer-indexed legacy handles. */
#define FORTRAN_ORM_LEGACY_INIT_SLOTS 64

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* FORTRAN_ORM_EXPORT_H */
