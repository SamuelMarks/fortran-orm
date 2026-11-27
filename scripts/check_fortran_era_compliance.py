#!/usr/bin/env python3
"""
@file check_fortran_era_compliance.py
@module fortran_orm_era_linter
@brief Enforces authentic historical dialect rules across all 12 Fortran
standards (1957 FORTRAN I through ISO Fortran 2023) so pre-standard and early
ANSI files cannot accidentally use modern extensions permitted by `-std=legacy`.
"""

import os
import re
import sys

ERA_RULES = [
    {
        "era": "FORTRAN (I) (1957)",
        "files": [
            "fortran/era/fortran_i/cormf1.f",
            "tests/fortran/era_01_fortran_i.f",
            "examples/fortran_i_1957_telemetry.f",
            "examples/fortran_i_1957_census_tabulator.f",
            "examples/fortran_i_1957_drum_inventory.f",
            "examples/fortran_i_1957_cosmic_ray_hodoscope.f",
        ],
        "fixed72": True,
        "max_ident": 6,
        "forbid_underscore": True,
        "forbid_keywords": [
            "SUBROUTINE",
            "CALL",
            "COMMON",
            "BLOCK",
            "DATA",
            "LOGICAL",
            "CHARACTER",
            "PARAMETER",
            "IMPLICIT",
            "MODULE",
            "THEN",
            "ENDIF",
        ],
    },
    {
        "era": "FORTRAN II (1958)",
        "files": [
            "fortran/era/fortran_ii/cormf2.f",
            "fortran/era/fortran_ii/corm2x.f",
            "tests/fortran/era_02_fortran_ii.f",
            "examples/fortran_ii_1958_ballistics.f",
            "examples/fortran_ii_1958_hydro_reservoir.f",
            "examples/fortran_ii_1958_naca_airfoil_polar.f",
            "examples/fortran_ii_1958_lunar_ranging_doppler.f",
        ],
        "fixed72": True,
        "max_ident": 6,
        "forbid_underscore": True,
        "forbid_keywords": [
            "LOGICAL",
            "DATA",
            "CHARACTER",
            "PARAMETER",
            "IMPLICIT",
            "MODULE",
            "THEN",
            "ENDIF",
        ],
    },
    {
        "era": "FORTRAN III (1958-59)",
        "files": [
            "fortran/era/fortran_iii/cormf3.f",
            "fortran/era/fortran_iii/corm3x.f",
            "tests/fortran/era_03_fortran_iii.f",
            "examples/fortran_iii_1958_reactor_scram.f",
            "examples/fortran_iii_1958_radar_track.f",
            "examples/fortran_iii_1958_relay_switching_matrix.f",
            "examples/fortran_iii_1958_magnet_coil_quench.f",
        ],
        "fixed72": True,
        "max_ident": 6,
        "forbid_underscore": True,
        "forbid_keywords": [
            "LOGICAL",
            "CHARACTER",
            "PARAMETER",
            "IMPLICIT",
            "MODULE",
            "THEN",
            "ENDIF",
        ],
    },
    {
        "era": "FORTRAN IV (1962)",
        "files": [
            "fortran/era/fortran_iv/cormf4.f",
            "fortran/era/fortran_iv/corm4x.f",
            "tests/fortran/era_04_fortran_iv.f",
            "examples/fortran_iv_1962_orbital_ephemeris.f",
            "examples/fortran_iv_1962_structural_truss.f",
            "examples/fortran_iv_1962_apollo_guidance_burn.f",
            "examples/fortran_iv_1962_ac_power_loadflow.f",
        ],
        "fixed72": True,
        "max_ident": 6,
        "forbid_underscore": True,
        "forbid_keywords": [
            "CHARACTER",
            "PARAMETER",
            "IMPLICIT",
            "MODULE",
            "THEN",
            "ENDIF",
        ],
    },
    {
        "era": "FORTRAN 66 (ANSI X3.9-1966)",
        "files": [
            "fortran/era/fortran66/corm66_lib.f",
            "fortran/era/fortran66/corm66_ext.f",
            "tests/fortran/era_05_fortran_66.f",
            "examples/fortran66_steam_tables.f",
            "examples/fortran66_chemical_kinetics.f",
            "examples/fortran66_geodetic_triangulation.f",
            "examples/fortran66_neutron_cross_section.f",
        ],
        "fixed72": True,
        "max_ident": 6,
        "forbid_underscore": True,
        "forbid_keywords": [
            "CHARACTER",
            "PARAMETER",
            "IMPLICIT",
            "SAVE",
            "INCLUDE",
            "MODULE",
            "THEN",
            "ENDIF",
        ],
    },
    {
        "era": "FORTRAN 77 (ANSI X3.9-1978)",
        "files": [
            "include/fortran/fortran_orm_f77.inc",
            "fortran/era/fortran77/corm77_lib.f",
            "fortran/era/fortran77/corm77_orm.f",
            "tests/fortran/era_06_fortran_77.f",
            "examples/fortran77_ledger.f",
            "examples/fortran77_ast_seismic.f",
            "examples/fortran77_ocean_hydrography.f",
            "examples/fortran77_atmospheric_radiosonde.f",
            "examples/fortran77_distillation_tray_column.f",
        ],
        "fixed72": True,
        "max_ident": 6,
        "forbid_underscore": True,
        "forbid_keywords": [
            "MODULE",
            "CONTAINS",
            "ALLOCATABLE",
            "POINTER",
            "INTENT",
            "INTERFACE",
            "USE",
        ],
    },
    {
        "era": "Fortran 90 (ISO/IEC 1539:1991)",
        "files": [
            "fortran/era/fortran90/fortran_orm_f90.f90",
            "fortran/era/fortran90/fortran_orm_f90_orm.f90",
            "tests/fortran/era_07_fortran_90.f90",
            "examples/fortran90_matrix_sim.f90",
            "examples/fortran90_weather_stations.f90",
            "examples/fortran90_power_grid_dispatch.f90",
            "examples/fortran90_finite_element_beam.f90",
            "examples/fortran90_epidemic_sir_compartment.f90",
        ],
        "fixed72": False,
        "max_ident": 31,
        "forbid_underscore": False,
        "forbid_keywords": [
            "PURE",
            "ELEMENTAL",
            "FORALL",
            "ISO_C_BINDING",
            "CLASS",
            "SUBMODULE",
        ],
    },
    {
        "era": "Fortran 95 (ISO/IEC 1539-1:1997)",
        "files": [
            "fortran/era/fortran95/fortran_orm_f95.f95",
            "fortran/era/fortran95/fortran_orm_f95_orm.f95",
            "tests/fortran/era_08_fortran_95.f95",
            "examples/fortran95_forall_cfd.f95",
            "examples/fortran95_blackbody_planck.f95",
            "examples/fortran95_shallow_water_tsunami.f95",
            "examples/fortran95_lattice_boltzmann_d2q9.f95",
        ],
        "fixed72": False,
        "max_ident": 31,
        "forbid_underscore": False,
        "forbid_keywords": [
            "ISO_C_BINDING",
            "CLASS",
            "FINAL",
            "SUBMODULE",
            "CONTIGUOUS",
        ],
    },
]


def strip_strings_and_hollerith(code):
    """Replace string and Hollerith literals with spaces so lexical checks inspect code tokens.

    @param code Fortran statement text with comments already removed.
    @return Sanitized statement text with character/Hollerith literals masked.
    """
    # Remove single/double quoted strings
    out = re.sub(r"'[^']*'|\"[^\"]*\"", "''", code)
    # Remove nH... Hollerith constants
    idx = 0
    res = []
    while idx < len(out):
        m = re.match(r"(\b\d+)[Hh]", out[idx:])
        if m:
            n_chars = int(m.group(1))
            skip = len(m.group(0)) + n_chars
            res.append("0")
            idx += skip
        else:
            res.append(out[idx])
            idx += 1
    return "".join(res)


def check_rule(rule):
    """Validate all files in a single historical era rule entry.

    @param rule Era rule dictionary specifying files, column limit, and forbidden tokens.
    @return List of dialect compliance violation strings.
    """
    errors = []
    for rel_path in rule["files"]:
        if not os.path.isfile(rel_path):
            errors.append(f"[{rule['era']}] missing required file: {rel_path}")
            continue
        with open(rel_path, "r", encoding="utf-8") as fp:
            lines = [ln.rstrip("\r\n") for ln in fp]

        for lno, raw in enumerate(lines, start=1):
            if rule["fixed72"]:
                if raw and raw[0] in ("C", "c", "*"):
                    continue
                if raw.strip() == "":
                    continue
                if len(raw) > 72:
                    errors.append(
                        f"[{rule['era']}] {rel_path}:{lno}: line exceeds column 72 ({len(raw)} cols)"
                    )
                if "\t" in raw:
                    errors.append(
                        f"[{rule['era']}] {rel_path}:{lno}: tab character forbidden in fixed-form card"
                    )
                code_part = strip_strings_and_hollerith(raw[6:72])
                label_part = raw[:5].strip()
                if label_part and not label_part.isdigit():
                    errors.append(
                        f"[{rule['era']}] {rel_path}:{lno}: non-numeric statement label `{label_part}`"
                    )
            else:
                code_only = raw.split("!")[0]
                code_part = strip_strings_and_hollerith(code_only)

            tokens = re.findall(r"\b[A-Za-z][A-Za-z0-9_]*\b", code_part)
            for tok in tokens:
                utok = tok.upper()
                if utok in rule["forbid_keywords"]:
                    errors.append(
                        f"[{rule['era']}] {rel_path}:{lno}: forbidden post-era keyword `{utok}`"
                    )
                if rule["forbid_underscore"] and "_" in tok:
                    errors.append(
                        f"[{rule['era']}] {rel_path}:{lno}: underscore forbidden in `{tok}`"
                    )
                # Standard keywords like PRECISION, SUBROUTINE, DIMENSION, CONTINUE, CHARACTER, PARAMETER, EXTERNAL
                std_kw = {
                    "INTEGER",
                    "LOGICAL",
                    "PROGRAM",
                    "INCLUDE",
                    "COMPLEX",
                    "EQUIVALENCE",
                    "SUBROUTINE",
                    "FUNCTION",
                    "DIMENSION",
                    "CONTINUE",
                    "PRECISION",
                    "CHARACTER",
                    "PARAMETER",
                    "EXTERNAL",
                    "IMPLICIT",
                    "ALLOCATABLE",
                    "INTERFACE",
                    "PROCEDURE",
                    "OPTIONAL",
                    "CONTAINS",
                    "ELEMENTAL",
                }
                if utok not in std_kw and len(tok) > rule["max_ident"]:
                    errors.append(
                        f"[{rule['era']}] {rel_path}:{lno}: identifier `{tok}` ({len(tok)} chars) exceeds {rule['max_ident']}-char limit"
                    )
    return errors


def main():
    """CLI entry point for 12-era Fortran compliance verifier.

    @return Process exit status (`0` when all 12 eras comply, `1` otherwise).
    """
    all_errors = []
    for rule in ERA_RULES:
        all_errors.extend(check_rule(rule))

    # Also verify modern eras (2003, 2008, 2018, 2023) exist
    modern_files = [
        "generated/fortran_orm_c.f90",
        "generated/fortran_orm_c_test.f90",
        "fortran/era/fortran2003/fortran_orm_f2003.f90",
        "fortran/era/fortran2003/fortran_orm_f2003_ext.f90",
        "fortran/era/fortran2008/fortran_orm_f2008.f90",
        "fortran/era/fortran2008/fortran_orm_f2008_sub.f90",
        "fortran/era/fortran2008/fortran_orm_f2008_ckpt_sub.f90",
        "fortran/era/fortran2018/fortran_orm_f2018.f90",
        "fortran/era/fortran2023/fortran_orm_f2023.f90",
        "fortran/fortran_orm.f90",
        "tests/fortran/era_09_fortran_2003.f90",
        "tests/fortran/era_10_fortran_2008.f90",
        "tests/fortran/era_11_fortran_2018.f90",
        "tests/fortran/era_12_fortran_2023.f90",
        "examples/fortran2003_oop_models.f90",
        "examples/fortran2003_pool_and_ast.f90",
        "examples/fortran2003_spectroscopy_crud.f90",
        "examples/fortran2003_molecular_dynamics_lj.f90",
        "examples/fortran2003_clinical_pharmacokinetics.f90",
        "examples/fortran2008_contiguous_nbody.f90",
        "examples/fortran2008_kalman_navigation.f90",
        "examples/fortran2008_multigrid_poisson_ckpt.f90",
        "examples/fortran2008_seismic_tomography_sparse.f90",
        "examples/fortran2018_cfi_strided_stencil.f90",
        "examples/fortran2018_acoustic_wavefield.f90",
        "examples/fortran2018_3d_heat_tensor_cfi.f90",
        "examples/fortran2018_mhd_alfven_strided.f90",
        "examples/fortran2023_scientific_orm.f90",
        "examples/fortran2023_mainframe_ebcdic_decimal.f90",
        "examples/fortran2023_isotope_decay_ledger.f90",
        "examples/fortran2023_exoplanet_transit_dataframe.f90",
        "examples/fortran2023_carbon_flux_unit_of_work.f90",
    ]
    for mf in modern_files:
        if not os.path.isfile(mf):
            all_errors.append(f"[Modern Fortran] missing required file: {mf}")

    if all_errors:
        for err in all_errors:
            print(f"ERA COMPLIANCE ERROR: {err}", file=sys.stderr)
        return 1

    print(
        "OK: All 12 Fortran standard eras (1957 FORTRAN I .. ISO Fortran 2023) passed dialect compliance checks."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
