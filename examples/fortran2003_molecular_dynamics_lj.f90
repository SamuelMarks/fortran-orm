!> @file fortran2003_molecular_dynamics_lj.f90
!> @brief ISO/IEC 1539-1:2004 Fortran 2003 Velocity-Verlet Lennard-Jones 12-6
!> noble-gas nanocluster dynamics with polymorphic `orm_model_base_t` & RAII.
!>
!> Showcases `fortran_orm_f2003` and `fortran_orm_f2003_ext`: concrete
!> ActiveRecord `lj_atom_model_t` extending `ABSTRACT` `orm_model_base_t`,
!> `orm_tx_guard_t` RAII rollback of unphysical high-dt blowup steps, generic
!> `stmt%bind`/`stmt%col`, `orm_ast_t`, and `orm_rs_t` JSON export.
MODULE md_lj_f2003_mod
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  USE fortran_orm_f2003_ext
  IMPLICIT NONE
  PRIVATE

  !> @type lj_atom_pod_t
  !> @brief Interoperable C struct backing `lj_atom_model_t` (56 bytes).
  TYPE, BIND(C), PUBLIC :: lj_atom_pod_t
    INTEGER(C_INT32_T) :: id
    INTEGER(C_INT32_T) :: atomic_z
    REAL(C_DOUBLE) :: rx
    REAL(C_DOUBLE) :: ry
    REAL(C_DOUBLE) :: rz
    REAL(C_DOUBLE) :: vx
    REAL(C_DOUBLE) :: vy
    REAL(C_DOUBLE) :: vz
  END TYPE lj_atom_pod_t

  !> @type lj_atom_model_t
  !> @brief Polymorphic Argon atom ActiveRecord extending `orm_model_base_t`.
  TYPE, EXTENDS(orm_model_base_t), PUBLIC :: lj_atom_model_t
    INTEGER(C_INT32_T) :: atomic_z = 18_C_INT32_T
    REAL(C_DOUBLE) :: r(3) = 0.0_C_DOUBLE
    REAL(C_DOUBLE) :: v(3) = 0.0_C_DOUBLE
  CONTAINS
    PROCEDURE :: configure_schema => atom_configure_schema
    PROCEDURE :: save => atom_save
    PROCEDURE :: load_by_id => atom_load_by_id
  END TYPE lj_atom_model_t

  PUBLIC :: lj_forces_and_pe, velocity_verlet_step, kinetic_energy

CONTAINS

  !> @brief Registers runtime BIND(C) reflection columns for `lj_atom_model_t`.
  !> @param[in] self Atom model instance.
  !> @param[inout] schema Reflection schema descriptor.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION atom_configure_schema(self, schema) RESULT(rc)
    CLASS(lj_atom_model_t), INTENT(IN) :: self
    CLASS(orm_schema_t), INTENT(INOUT) :: schema
    INTEGER(C_INT) :: rc
    IF (self%pk_id < -1_C_INT32_T) THEN
      rc = FORTRAN_ORM_ERROR_VALIDATION
      RETURN
    END IF
    rc = schema%create("lj_atoms", 56_C_INT32_T)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("id", FORTRAN_ORM_COL_INT32, 0_C_INT32_T, &
                        0_C_INT32_T, .TRUE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("atomic_z", FORTRAN_ORM_COL_INT32, 4_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("rx", FORTRAN_ORM_COL_FLOAT64, 8_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("ry", FORTRAN_ORM_COL_FLOAT64, 16_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("rz", FORTRAN_ORM_COL_FLOAT64, 24_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("vx", FORTRAN_ORM_COL_FLOAT64, 32_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("vy", FORTRAN_ORM_COL_FLOAT64, 40_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
    IF (rc /= FORTRAN_ORM_OK) RETURN
    rc = schema%add_col("vz", FORTRAN_ORM_COL_FLOAT64, 48_C_INT32_T, &
                        0_C_INT32_T, .FALSE., .FALSE.)
  END FUNCTION atom_configure_schema

  !> @brief Saves `self` via dialect-aware `UPSERT` onto `db`.
  !> @param[inout] self Atom model instance.
  !> @param[in] db Active database connection.
  !> @param[inout] schema Configured reflection schema.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION atom_save(self, db, schema) RESULT(rc)
    CLASS(lj_atom_model_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CLASS(orm_schema_t), INTENT(INOUT) :: schema
    INTEGER(C_INT) :: rc
    TYPE(lj_atom_pod_t), TARGET :: pod
    pod%id = self%pk_id
    pod%atomic_z = self%atomic_z
    pod%rx = self%r(1)
    pod%ry = self%r(2)
    pod%rz = self%r(3)
    pod%vx = self%v(1)
    pod%vy = self%v(2)
    pod%vz = self%v(3)
    rc = schema%upsert_ptr(db, C_LOC(pod))
  END FUNCTION atom_save

  !> @brief Hydrates atom `id_val` from `db` into `self`.
  !> @param[inout] self Atom model instance.
  !> @param[in] db Active database connection.
  !> @param[inout] schema Configured reflection schema.
  !> @param[in] id_val 32-bit atom primary key.
  !> @return Unified `fortran_orm_error_t` status code.
  FUNCTION atom_load_by_id(self, db, schema, id_val) RESULT(rc)
    CLASS(lj_atom_model_t), INTENT(INOUT) :: self
    CLASS(orm_db_t), INTENT(IN) :: db
    CLASS(orm_schema_t), INTENT(INOUT) :: schema
    INTEGER(C_INT32_T), INTENT(IN) :: id_val
    INTEGER(C_INT) :: rc
    TYPE(lj_atom_pod_t), TARGET :: pod
    rc = schema%find_i32_ptr(db, id_val, C_LOC(pod))
    IF (rc == FORTRAN_ORM_OK) THEN
      self%pk_id = pod%id
      self%atomic_z = pod%atomic_z
      self%r = (/ pod%rx, pod%ry, pod%rz /)
      self%v = (/ pod%vx, pod%vy, pod%vz /)
    END IF
  END FUNCTION atom_load_by_id

  !> @brief Computes reduced-unit Lennard-Jones 12-6 pairwise forces & PE.
  !> @param[in] pos `(3, natoms)` atomic coordinates.
  !> @param[out] acc `(3, natoms)` accelerations (`m = 1` reduced units).
  !> @param[out] pe_tot Pairwise potential energy `4 * (r^-12 - r^-6)`.
  SUBROUTINE lj_forces_and_pe(pos, acc, pe_tot)
    REAL(C_DOUBLE), DIMENSION(:, :), INTENT(IN) :: pos
    REAL(C_DOUBLE), DIMENSION(:, :), INTENT(OUT) :: acc
    REAL(C_DOUBLE), INTENT(OUT) :: pe_tot
    REAL(C_DOUBLE) :: dr(3), r2, inv_r2, inv_r6, f_mag
    INTEGER :: n, i, j

    n = SIZE(pos, 2)
    acc = 0.0_C_DOUBLE
    pe_tot = 0.0_C_DOUBLE
    DO i = 1, n - 1
      DO j = i + 1, n
        dr = pos(:, i) - pos(:, j)
        r2 = SUM(dr * dr)
        inv_r2 = 1.0_C_DOUBLE / r2
        inv_r6 = inv_r2 * inv_r2 * inv_r2
        pe_tot = pe_tot + 4.0_C_DOUBLE * inv_r6 * (inv_r6 - 1.0_C_DOUBLE)
        f_mag = 24.0_C_DOUBLE * inv_r2 * inv_r6 * &
                (2.0_C_DOUBLE * inv_r6 - 1.0_C_DOUBLE)
        acc(:, i) = acc(:, i) + f_mag * dr
        acc(:, j) = acc(:, j) - f_mag * dr
      END DO
    END DO
  END SUBROUTINE lj_forces_and_pe

  !> @brief Symplectic Velocity-Verlet step advancing `pos` and `vel`.
  !> @param[inout] pos `(3, natoms)` coordinates.
  !> @param[inout] vel `(3, natoms)` velocities.
  !> @param[inout] acc `(3, natoms)` accelerations.
  !> @param[in] dt Reduced time step.
  !> @param[out] pe_tot Updated potential energy.
  SUBROUTINE velocity_verlet_step(pos, vel, acc, dt, pe_tot)
    REAL(C_DOUBLE), DIMENSION(:, :), INTENT(INOUT) :: pos, vel, acc
    REAL(C_DOUBLE), INTENT(IN) :: dt
    REAL(C_DOUBLE), INTENT(OUT) :: pe_tot
    REAL(C_DOUBLE), DIMENSION(3, SIZE(pos, 2)) :: acc_new

    pos = pos + vel * dt + 0.5_C_DOUBLE * acc * dt * dt
    CALL lj_forces_and_pe(pos, acc_new, pe_tot)
    vel = vel + 0.5_C_DOUBLE * (acc + acc_new) * dt
    acc = acc_new
  END SUBROUTINE velocity_verlet_step

  !> @brief Computes reduced total kinetic energy `0.5 * SUM(vel^2)`.
  !> @param[in] vel `(3, natoms)` velocity array.
  !> @return Total kinetic energy.
  PURE FUNCTION kinetic_energy(vel) RESULT(ke_tot)
    REAL(C_DOUBLE), DIMENSION(:, :), INTENT(IN) :: vel
    REAL(C_DOUBLE) :: ke_tot
    ke_tot = 0.5_C_DOUBLE * SUM(vel * vel)
  END FUNCTION kinetic_energy

END MODULE md_lj_f2003_mod

!> @brief Main Fortran 2003 Lennard-Jones nanocluster MD ORM program.
PROGRAM fortran2003_md_lj
  USE, INTRINSIC :: ISO_C_BINDING
  USE fortran_orm_f2003
  USE fortran_orm_f2003_ext
  USE md_lj_f2003_mod
  IMPLICIT NONE

  INTEGER, PARAMETER :: NATOMS = 4
  TYPE(orm_db_t) :: db
  TYPE(orm_schema_t) :: atom_schema
  TYPE(orm_stmt_t) :: stmt
  TYPE(orm_rs_t) :: rs
  TYPE(orm_tx_guard_t) :: tx_guard, zero_guard
  TYPE(lj_atom_model_t), DIMENSION(NATOMS) :: atoms
  TYPE(lj_atom_model_t) :: probe_atom
  REAL(C_DOUBLE), DIMENSION(3, NATOMS) :: pos, vel, acc
  CHARACTER(LEN=:), ALLOCATABLE :: json_out
  REAL(C_DOUBLE) :: dt, pe0, ke0, e0, pe, ke, e_final, drift
  INTEGER(C_INT) :: rc
  INTEGER(C_INT32_T) :: step_k, nrows
  LOGICAL :: has_row

  ! Regular Argon_4 tetrahedron near equilibrium spacing r ~ 1.15 sigma
  pos(:, 1) = (/  0.00_C_DOUBLE,  0.00_C_DOUBLE,  0.00_C_DOUBLE /)
  pos(:, 2) = (/  1.16_C_DOUBLE,  0.00_C_DOUBLE,  0.00_C_DOUBLE /)
  pos(:, 3) = (/  0.58_C_DOUBLE,  1.00_C_DOUBLE,  0.00_C_DOUBLE /)
  pos(:, 4) = (/  0.58_C_DOUBLE,  0.33_C_DOUBLE,  0.95_C_DOUBLE /)
  vel = 0.0_C_DOUBLE
  vel(1, 1) =  0.08_C_DOUBLE
  vel(1, 2) = -0.08_C_DOUBLE

  CALL lj_forces_and_pe(pos, acc, pe0)
  ke0 = kinetic_energy(vel)
  e0 = pe0 + ke0

  rc = db%open(":memory:")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = atoms(1)%configure_schema(atom_schema)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = atom_schema%create_table(db)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = db%exec("CREATE TABLE md_thermo(step_no INT, pe REAL, ke REAL, etot REAL)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  ! Symplectic integration + thermo logging via generic `stmt%bind`
  dt = 0.0005_C_DOUBLE
  rc = stmt%prepare(db, "INSERT INTO md_thermo VALUES(?,?,?,?)")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  DO step_k = 1_C_INT32_T, 100_C_INT32_T
    CALL velocity_verlet_step(pos, vel, acc, dt, pe)
    IF (MOD(step_k, 20_C_INT32_T) == 0_C_INT32_T) THEN
      ke = kinetic_energy(vel)
      rc = stmt%bind(1_C_INT32_T, step_k)
      rc = stmt%bind(2_C_INT32_T, pe)
      rc = stmt%bind(3_C_INT32_T, ke)
      rc = stmt%bind(4_C_INT32_T, pe + ke)
      rc = stmt%step(has_row)
      rc = stmt%reset()
      IF (rc /= FORTRAN_ORM_OK) STOP 1
    END IF
  END DO
  rc = stmt%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1

  e_final = pe + kinetic_energy(vel)
  drift = ABS(e_final - e0)
  IF (drift > 1.0D-5) STOP 1

  ! Persist final Argon_4 cluster via polymorphic `atoms(i)%save` inside guard
  CALL commit_cluster_state(db, atom_schema, tx_guard, atoms, pos, vel)

  ! Simulate unstable step inside `abort_unstable_step` and let RAII roll back!
  CALL abort_unstable_step(db, tx_guard, zero_guard)

  rc = probe_atom%load_by_id(db, atom_schema, 4_C_INT32_T)
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  IF (MAXVAL(ABS(probe_atom%r - pos(:, 4))) > 1.0D-12) STOP 1

  rc = rs%query(db, "SELECT step_no, etot FROM md_thermo ORDER BY step_no")
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  rc = rs%row_count(nrows)
  IF (rc /= FORTRAN_ORM_OK .OR. nrows /= 5_C_INT32_T) STOP 1
  rc = rs%to_json(json_out)
  IF (rc /= FORTRAN_ORM_OK .OR. INDEX(json_out, "etot") == 0) STOP 1

  rc = rs%free()
  rc = atom_schema%free()
  rc = db%close()
  IF (rc /= FORTRAN_ORM_OK) STOP 1
  PRINT '(A,E12.4,F12.6)', "MD LJ F2003 OK: drift=", drift, e_final

CONTAINS

  !> @brief Commits all `NATOMS` polymorphic models inside an `orm_tx_guard_t`.
  !> @param[inout] db_h Active database connection.
  !> @param[inout] sch Reflection schema.
  !> @param[inout] guard_h RAII transaction guard.
  !> @param[inout] models Array of atom ActiveRecords.
  !> @param[in] r_arr Final `(3, NATOMS)` coordinates.
  !> @param[in] v_arr Final `(3, NATOMS)` velocities.
  SUBROUTINE commit_cluster_state(db_h, sch, guard_h, models, r_arr, v_arr)
    TYPE(orm_db_t), INTENT(INOUT) :: db_h
    TYPE(orm_schema_t), INTENT(INOUT) :: sch
    TYPE(orm_tx_guard_t), INTENT(INOUT) :: guard_h
    TYPE(lj_atom_model_t), DIMENSION(:), INTENT(INOUT) :: models
    REAL(C_DOUBLE), DIMENSION(:, :), INTENT(IN) :: r_arr, v_arr
    INTEGER(C_INT) :: grc
    INTEGER(C_INT32_T) :: k

    grc = guard_h%begin(db_h)
    IF (grc /= FORTRAN_ORM_OK) STOP 1
    DO k = 1_C_INT32_T, INT(SIZE(models, 1), C_INT32_T)
      models(k)%pk_id = k
      models(k)%r = r_arr(:, k)
      models(k)%v = v_arr(:, k)
      grc = models(k)%save(db_h, sch)
      IF (grc /= FORTRAN_ORM_OK) STOP 1
    END DO
    grc = guard_h%commit()
    IF (grc /= FORTRAN_ORM_OK) STOP 1
  END SUBROUTINE commit_cluster_state

  !> @brief Inserts a divergent blowup thermo row and resets `guard_h` without
  !> `%commit()`, proving `orm_tx_guard_t`'s `FINAL` destructor rolls back.
  !> @param[inout] db_h Active database connection.
  !> @param[inout] guard_h Active RAII transaction guard.
  !> @param[in] empty_guard Default-initialized guard triggering `FINAL`.
  SUBROUTINE abort_unstable_step(db_h, guard_h, empty_guard)
    TYPE(orm_db_t), INTENT(INOUT) :: db_h
    TYPE(orm_tx_guard_t), INTENT(INOUT) :: guard_h
    TYPE(orm_tx_guard_t), INTENT(IN) :: empty_guard
    INTEGER(C_INT) :: grc
    grc = guard_h%begin(db_h)
    IF (grc /= FORTRAN_ORM_OK) STOP 1
    grc = db_h%exec("INSERT INTO md_thermo VALUES(999, 1.0E9, 1.0E9, 2.0E9)")
    IF (grc /= FORTRAN_ORM_OK) STOP 1
    guard_h = empty_guard
  END SUBROUTINE abort_unstable_step

END PROGRAM fortran2003_md_lj
