# Scientific Column-Major Vectors & 2D Matrices

## Memory Layout (`A(ld_rows, n_cols)`)

Fortran stores 2D arrays in **column-major** order (`A(1,1), A(2,1), ..., A(ld_rows, 1), A(1,2), ...`), whereas SQL rows are tuple-oriented `(col_1, col_2, ..., col_M)`.

Rather than forcing Fortran callers to allocate a transposed `n_cols x n_rows` copy, `src/fortran_orm_matrix.c` indexes directly into the caller's column-major buffer using the leading dimension `ld_rows`:

$$\text{offset}(r, c) = c \times \text{ld\_rows} + r \quad (0 \le r < n_{\text{rows}},\; 0 \le c < n_{\text{cols}})$$

This supports sub-matrix persistence (`n_rows <= ld_rows`) across FORTRAN IV (`F4MATI`/`F4MATQ`), FORTRAN 66 (`C6MATI`/`C6MATQ`), FORTRAN 77 (`F7MATI`/`F7MATQ`), Fortran 90/95, and Fortran 2008 (`CONTIGUOUS`).

## Strided Slices via Fortran 2018/2023 `CFI_cdesc_t`

In Fortran 2018 and Fortran 2023 (`fortran_orm_f2018`), `fortran_orm_cfi_insert_numeric` and `fortran_orm_cfi_query_numeric` inspect `arr_desc->dim[d].sm` (signed byte stride per dimension) inside `<ISO_Fortran_binding.h>`'s `CFI_cdesc_t` descriptor:

$$\text{addr}(r, c) = \text{base\_addr} + r \cdot \text{sm}_0 + c \cdot \text{sm}_1$$

Non-contiguous array sections such as `grid(1:100:2, :)` are persisted and hydrated in-place with zero temporary array copies.
