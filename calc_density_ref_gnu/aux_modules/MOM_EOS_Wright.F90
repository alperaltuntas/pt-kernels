!KGEN-generated Fortran source file 
  
!Generated at : 2019-10-22 18:38:07 
!KGEN version : 0.8.1 
  
!> The equation of state using the Wright 1997 expressions


module MOM_EOS_Wright
! This file is part of MOM6. See LICENSE.md for the license.
!***********************************************************************
!*  The subroutines in this file implement the equation of state for   *
!*  sea water using the formulae given by  Wright, 1997, J. Atmos.     *
!*  Ocean. Tech., 14, 735-740.  Coded by R. Hallberg, 7/00.            *
!***********************************************************************


    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

    IMPLICIT NONE 
!/// \brief Compile-time memory settings
!/// \details This include file determines the compile-time memory settings.
!/// There are several variants of this file and only one should be in the search path for compilation.
!/// \file MOM_memory.h
!/// The number of thickness grid points in the i-direction of the global domain.
!/// The number of thickness grid points in the j-direction of the global domain.
!/// The number of layers in the vertical direction.
!/// The number of processors in the i-direction.
!/// The number of processors in the j-direction.
!/// The maximum permitted number (each) of restart variables, time derivatives, etc.
!/// This is mostly used for the size of pointer arrays, so it should be set generously.
!/// The number of memory halo cells on each side of the computational domain in the i-direction.
!/// The number of memory halo cells on each side of the computational domain in the j-direction.
!/// If SYMMETRIC_MEMORY_() is defined, the velocity point data domain includes every face of the thickness points.
!/// In other words, some arrays are larger than others, depending on where they are on the staggered grid.
!/// If STATIC_MEMORY_ is defined, the principle variables have sizes that are statically determined at compile time.
!/// Otherwise the sizes are not determined until run time.
!//! \brief Memory macros
!//! \details This is a header file to define macros for static and dynamic memory allocation.
!//! Define STATIC_MEMORY_ in MOM_memory.h for static memory allocation.
!//! Otherwise dynamic memory allocation will be assumed.
!//!
!//! For explanation of symmetric and non-symmetric memory modes see \ref Horizontal_indexing.
!//! \file MOM_memory_macros.h
!/// Deallocates array x when using dynamic memory mode. Does nothing in static memory mode.
!/// Allocates array x when using dynamic memory mode. Does nothing in static memory mode.
!/// Attaches the ALLOCATABLE attribute to an array in dynamic memory mode. Does nothing in static memory mode.
!/// Attaches the POINTER attribute to an array in dynamic memory mode. Does nothing in static memory mode.
!/// Nullify a pointer in dynamic memory mode. Does nothing in static memory mode.
!/// Expands to : in dynamic memory mode, or is the i-shape of a tile in static memory mode.
!/// Use for heap (,allocatable or ,pointer) variables at h- or v- points.
!/// Expands to : in dynamic memory mode, or is the j-shape of a tile in static memory mode.
!/// Use for heap (,allocatable or ,pointer) variables at h- or u- points.
!/// Expands to : in dynamic memory mode, or to NIMEMB_ in static memory mode.
!/// Use for heap (,allocatable or ,pointer) variables at h- or v- points.
!/// Expands to : in dynamic memory mode, or to NJMEMB_ in static memory mode.
!/// Use for heap (,allocatable or ,pointer) variables at h- or u- points.
!/// Expands to : or 0: in dynamic memory mode, or is the staggered i-shape of a tile in static memory mode.
!/// Use for heap (,allocatable or ,pointer) variables at q- or u- points.
!/// Expands to : or 0: in dynamic memory mode, or is the staggered j-shape of a tile in static memory mode.
!/// Use for heap (,allocatable or ,pointer) variables at q- or v- points.
!/// Expands to 0: in dynamic memory mode, or is the staggered i-shape of a tile in static memory mode.
!/// Use for always-symmetric heap (,allocatable or ,pointer) variables at q- or u- points.
!/// Expands to 0: in dynamic memory mode, or is the staggered j-shape of a tile in static memory mode.
!/// Use for always-symmetric heap (,allocatable or ,pointer) variables at q- or v- points.
!/// Expands to : in dynamic memory mode or is to the number of layers in static memory mode.
!/// Use for heap (,allocatable or ,pointer) layer variables.
!/// Expands to 0: in dynamic memory mode or to 0:NONSENSE_NK in static memory mode.
!/// Use for heap (,allocatable or ,pointer) interface variables.
!/// Expands to : in dynamic memory mode or to NONSENSE_NK+1 in static memory mode.
!/// Use for heap (,allocatable or ,pointer) interface variables.
!/// Expands to : or 1. UNKNOWN PURPOSE!
!/// Expands to : or 2. UNKNOWN PURPOSE!
!/// Expands to : or 3. UNKNOWN PURPOSE!
!/// \todo Explain or remove :, : and :
!/// The i-shape of a dummy argument staggered at h- or v-points.
!/// The j-shape of a dummy argument staggered at h- or u-points.
!/// The k-shape of a layer dummy argument.
!/// The k-shape of an interface dummy argument.
!/// The i-shape of a dummy argument staggered at q- or u-points.
!/// The j-shape of a dummy argument staggered at q- or v-points.
!/// The i-shape of a symmetric dummy argument staggered at q- or u-points.
!/// The j-shape of a symmetric dummy argument staggered at q- or v-points.
!/// The i-shape of a dynamic dummy argument staggered at h- or v-points.
!/// The i-shape of a dynamic dummy argument staggered at q- or u-points.
!/// The j-shape of a dynamic dummy argument staggered at h- or u-points.
!/// The j-shape of a dynamic dummy argument staggered at q- or v-points.


!


!


!


!


! A note on unit descriptions in comments: MOM6 uses units that can be rescaled for dimensional
! consistency testing. These are noted in comments with units like Z, H, L, and T, along with
! their mks counterparts with notation like "a velocity [Z T-1 ~> m s-1]".  If the units
! vary with the Boussinesq approximation, the Boussinesq variant is given first.
!> Compute the in situ density of sea water (in [kg m-3]), or its anomaly with respect to
!! a reference density, from salinity (in psu), potential temperature (in deg C), and pressure [Pa],
!! using the expressions from Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.


!> Compute the in situ specific volume of sea water (in [m3 kg-1]), or an anomaly with respect
!! to a reference specific volume, from salinity (in psu), potential temperature (in deg C), and
!! pressure [Pa], using the expressions from Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.


!> For a given thermodynamic state, return the derivatives of density with temperature and salinity


!> For a given thermodynamic state, return the second derivatives of density with various combinations
!! of temperature, salinity, and pressure


!>@{ Parameters in the Wright equation of state
!real :: a0, a1, a2, b0, b1, b2, b3, b4, b5, c0, c1, c2, c3, c4, c5
!    One of the two following blocks of values should be commented out.
!  Following are the values for the full range formula.
!real, parameter :: a0 = 7.133718e-4, a1 = 2.724670e-7, a2 = -1.646582e-7
!real, parameter :: b0 = 5.613770e8,  b1 = 3.600337e6,  b2 = -3.727194e4
!real, parameter :: b3 = 1.660557e2,  b4 = 6.844158e5,  b5 = -8.389457e3
!real, parameter :: c0 = 1.609893e5,  c1 = 8.427815e2,  c2 = -6.931554
!real, parameter :: c3 = 3.869318e-2, c4 = -1.664201e2, c5 = -2.765195
! Following are the values for the reduced range formula.

!


real, parameter :: a0 = 7.057924e-4, a1 = 3.480336e-7, a2 = -1.112733e-7 ! a0/a1 ~= 2028 ; a0/a2 ~= -6343
real, parameter :: b0 = 5.790749e8,  b1 = 3.516535e6,  b2 = -4.002714e4  ! b0/b1 ~= 165  ; b0/b4 ~= 974
real, parameter :: b3 = 2.084372e2,  b4 = 5.944068e5,  b5 = -9.643486e3
real, parameter :: c0 = 1.704853e5,  c1 = 7.904722e2,  c2 = -7.984422    ! c0/c1 ~= 216  ; c0/c4 ~= -740
real, parameter :: c3 = 5.140652e-2, c4 = -2.302158e2, c5 = -3.079464
!!@}
PUBLIC calculate_density_array_wright 
#ifdef _MPI 
include "mpif.h" 
#endif 
  

contains
!> This subroutine computes the in situ density of sea water (rho in
!! [kg m-3]) from salinity (S [PSU]), potential temperature
!! (T [degC]), and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.


!> This subroutine computes the in situ density of sea water (rho in
!! [kg m-3]) from salinity (S [PSU]), potential temperature
!! (T [degC]), and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.

SUBROUTINE calculate_density_array_wright(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, t, s, pressure, rho, start, &
&npts, rho_ref) 
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE kgen_utils_mod, ONLY: kgen_perturb_real 
    USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_init_verify, kgen_tolerance, kgen_minvalue, kgen_verboselevel, &
    &CHECK_IDENTICAL, CHECK_IN_TOL, CHECK_OUT_TOL 
    REAL, dimension(:), INTENT(INOUT) :: t 
    REAL, dimension(:), INTENT(INOUT) :: s 
    REAL, dimension(:), INTENT(INOUT) :: pressure 
    REAL, dimension(:), INTENT(INOUT) :: rho 
    INTEGER, INTENT(INOUT) :: start 
    INTEGER, INTENT(INOUT) :: npts 
    REAL, INTENT(INOUT) :: rho_ref 
    INTEGER, INTENT(IN) :: kgen_unit 
    REAL(KIND=kgen_dp), INTENT(OUT) :: kgen_measure 
    LOGICAL, INTENT(OUT) :: kgen_isverified 
    CHARACTER(LEN=*), INTENT(IN) :: kgen_filepath 
    LOGICAL :: kgen_istrue 
    REAL(KIND=8) :: kgen_array_sum 
    INTEGER :: kgen_intvar, kgen_ierr 
    INTEGER :: kgen_mpirank, kgen_openmptid, kgen_kernelinvoke 
    LOGICAL :: kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    COMMON / state / kgen_mpirank, kgen_openmptid, kgen_kernelinvoke, kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    INTEGER, PARAMETER :: KGEN_MAXITER = 1 
      
    TYPE(check_t) :: check_status 
    INTEGER*8 :: kgen_start_clock, kgen_stop_clock, kgen_rate_clock 
    REAL(KIND=kgen_dp) :: gkgen_measure 
    REAL, dimension(:), allocatable :: kgenref_rho 
      
    !parent block preprocessing 
      
#ifdef _MPI 
    call mpi_comm_rank(mpi_comm_world, kgen_mpirank, kgen_ierr) 
#else 
    kgen_mpirank = 0 
#endif 
      
      
    !local input variables 
      
    !extern output variables 
      
    !local output variables 
    CALL kr_kgen_calculate_density_array_wright_subp0(kgenref_rho, kgen_unit, "kgenref_rho", .FALSE.) 

    IF (kgen_evalstage) THEN 
    END IF   
    IF (kgen_warmupstage) THEN 
    END IF   
    IF (kgen_mainstage) THEN 
    END IF   
      
    !Uncomment following call statement to turn on perturbation experiment. 
    !Adjust perturbation value and/or kind parameter if required. 
    !CALL kgen_perturb_real( your_variable, 1.0E-15_8 ) 
      
      
    !call to kgen kernel 
    call calculate_density_array_wright_ref(T, S, pressure, rho, start, npts, rho_ref)
    IF (kgen_mainstage) THEN 
          
        !verify init 
        CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=1) 
        CALL kgen_init_check(check_status, rank=kgen_mpirank) 
          
        !extern verify variables 
          
        !local verify variables 
        CALL kv_kgen_calculate_density_array_wright_subp0("rho", check_status, rho, kgenref_rho) 
        IF (check_status%rank == 0) THEN 
            WRITE (*, *) "" 
        END IF   
        IF (kgen_verboseLevel > 0) THEN 
            IF (check_status%rank == 0) THEN 
                WRITE (*, *) "Number of output variables: ", check_status%numTotal 
                WRITE (*, *) "Number of identical variables: ", check_status%numIdentical 
                WRITE (*, *) "Number of non-identical variables within tolerance: ", check_status%numInTol 
                WRITE (*, *) "Number of non-identical variables out of tolerance: ", check_status%numOutTol 
                WRITE (*, *) "Tolerance: ", kgen_tolerance 
            END IF   
        END IF   
        IF (check_status%rank == 0) THEN 
            WRITE (*, *) "" 
        END IF   
        IF (check_status%numOutTol > 0) THEN 
            IF (check_status%rank == 0) THEN 
                WRITE (*, *) "Verification FAILED with" // TRIM(ADJUSTL(kgen_filepath)) 
            END IF   
            check_status%Passed = .FALSE. 
            kgen_isverified = .FALSE. 
        ELSE 
            IF (check_status%rank == 0) THEN 
                WRITE (*, *) "Verification PASSED with " // TRIM(ADJUSTL(kgen_filepath)) 
            END IF   
            check_status%Passed = .TRUE. 
            kgen_isverified = .TRUE. 
        END IF   
        IF (check_status%rank == 0) THEN 
            WRITE (*, *) "" 
        END IF   
          
#ifdef _MPI 
        call mpi_barrier(mpi_comm_world, kgen_ierr) 
#endif 
          
        CALL SYSTEM_CLOCK(kgen_start_clock, kgen_rate_clock) 
        DO kgen_intvar = 1, KGEN_MAXITER 
    call calculate_density_array_wright_ref(T, S, pressure, rho, start, npts, rho_ref)
        END DO   
        CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
        kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
#ifdef _MPI 
        CALL mpi_allreduce(kgen_measure, gkgen_measure, 1, mpi_real8, mpi_max, mpi_comm_world, kgen_ierr) 
        kgen_measure = gkgen_measure 
#endif 
        IF (check_status%rank==0) THEN 
            WRITE (*, *) "calculate_density_array_wright_ref : Time per call (usec): ", kgen_measure 
        END IF   
    END IF   
    IF (kgen_warmupstage) THEN 
    END IF   
    IF (kgen_evalstage) THEN 
    END IF   
      
    CONTAINS 
      

    !read state subroutine for kr_kgen_calculate_density_array_wright_subp0 
    SUBROUTINE kr_kgen_calculate_density_array_wright_subp0(var, kgen_unit, printname, printvar) 
        REAL, INTENT(INOUT), ALLOCATABLE, DIMENSION(:) :: var 
        INTEGER, INTENT(IN) :: kgen_unit 
        CHARACTER(LEN=*), INTENT(IN) :: printname 
        LOGICAL, INTENT(IN), OPTIONAL :: printvar 
        LOGICAL :: kgen_istrue 
        REAL(KIND=8) :: kgen_array_sum 
        INTEGER :: idx1 
        INTEGER, DIMENSION(2,1) :: kgen_bound 
          
        READ (UNIT = kgen_unit) kgen_istrue 
        IF (kgen_istrue) THEN 
            IF (ALLOCATED( var )) THEN 
                DEALLOCATE (var) 
            END IF   
            READ (UNIT = kgen_unit) kgen_array_sum 
            READ (UNIT = kgen_unit) kgen_bound(1, 1) 
            READ (UNIT = kgen_unit) kgen_bound(2, 1) 
            ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1))) 
            READ (UNIT = kgen_unit) var 
            CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
            IF (PRESENT( printvar ) .AND. printvar) THEN 
                WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
            END IF   
        END IF   
    END SUBROUTINE kr_kgen_calculate_density_array_wright_subp0 
      
    !verify state subroutine for kv_kgen_calculate_density_array_wright_subp0 
    RECURSIVE SUBROUTINE kv_kgen_calculate_density_array_wright_subp0(varname, check_status, var, kgenref_var) 
        CHARACTER(LEN=*), INTENT(IN) :: varname 
        TYPE(check_t), INTENT(INOUT) :: check_status 
        REAL, INTENT(IN), DIMENSION(:) :: var, kgenref_var 
        INTEGER :: check_result 
        LOGICAL :: is_print = .FALSE. 
          
        INTEGER :: idx1 
        INTEGER :: n 
        real :: nrmsdiff, rmsdiff 
        real, ALLOCATABLE :: buf1(:), buf2(:) 
          
        check_status%numTotal = check_status%numTotal + 1 
          
        IF (ALL(var == kgenref_var)) THEN 
            check_status%numIdentical = check_status%numIdentical + 1 
            IF (kgen_verboseLevel > 1) THEN 
                IF (check_status%rank == 0) THEN 
                    WRITE (*, *) trim(adjustl(varname)), " is IDENTICAL." 
                END IF   
            END IF   
            check_result = CHECK_IDENTICAL 
        ELSE 
            ALLOCATE (buf1(SIZE(var,dim=1))) 
            ALLOCATE (buf2(SIZE(var,dim=1))) 
            n = SIZE(var) 
            WHERE ( ABS(kgenref_var) > kgen_minvalue ) 
                buf1 = ((var-kgenref_var)/kgenref_var)**2 
                buf2 = (var-kgenref_var)**2 
            ELSEWHERE 
                buf1 = (var-kgenref_var)**2 
                buf2 = buf1 
            END WHERE   
            nrmsdiff = SQRT(SUM(buf1)/DBLE(n)) 
            rmsdiff = SQRT(SUM(buf2)/DBLE(n)) 
            IF (rmsdiff > kgen_tolerance) THEN 
                check_status%numOutTol = check_status%numOutTol + 1 
                IF (kgen_verboseLevel > 0) THEN 
                    IF (check_status%rank == 0) THEN 
                        WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(out of tolerance)." 
                    END IF   
                END IF   
                check_result = CHECK_OUT_TOL 
            ELSE 
                check_status%numInTol = check_status%numInTol + 1 
                IF (kgen_verboseLevel > 1) THEN 
                    IF (check_status%rank == 0) THEN 
                        WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(within tolerance)." 
                    END IF   
                END IF   
                check_result = CHECK_IN_TOL 
            END IF   
        END IF   
        IF (check_result == CHECK_IDENTICAL) THEN 
            IF (kgen_verboseLevel > 2) THEN 
                IF (check_status%rank == 0) THEN 
                    WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                    WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                    WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                    WRITE (*, *) "RMS of difference is ", 0 
                    WRITE (*, *) "Normalized RMS of difference is ", 0 
                    WRITE (*, *) "" 
                END IF   
            END IF   
        ELSE IF (check_result == CHECK_OUT_TOL) THEN 
            IF (kgen_verboseLevel > 0) THEN 
                IF (check_status%rank == 0) THEN 
                    WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                    WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                    WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                    WRITE (*, *) "RMS of difference is ", rmsdiff 
                    WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff 
                    WRITE (*, *) "" 
                END IF   
            END IF   
        ELSE IF (check_result == CHECK_IN_TOL) THEN 
            IF (kgen_verboseLevel > 1) THEN 
                IF (check_status%rank == 0) THEN 
                    WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                    WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                    WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                    WRITE (*, *) "RMS of difference is ", rmsdiff 
                    WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff 
                    WRITE (*, *) "" 
                END IF   
            END IF   
        END IF   
          
    END SUBROUTINE kv_kgen_calculate_density_array_wright_subp0 
      
END SUBROUTINE calculate_density_array_wright 
!> This subroutine computes the in situ density of sea water (rho in
!! [kg m-3]) from salinity (S [PSU]), potential temperature
!! (T [degC]), and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.

subroutine calculate_density_array_wright_ref(T, S, pressure, rho, start, npts, rho_ref)
  real, dimension(:), intent(in)  :: T        !< potential temperature relative to the surface [degC].
  real, dimension(:), intent(in)  :: S        !< salinity [PSU].
  real, dimension(:), intent(in)  :: pressure !< pressure [Pa].
  real, dimension(:), intent(out) :: rho      !< in situ density [kg m-3].
  integer,            intent(in)  :: start    !< the starting point in the arrays.
  integer,            intent(in)  :: npts     !< the number of values to calculate.
  real,               intent(in)  :: rho_ref  !< A reference density [kg m-3].
  ! Original coded by R. Hallberg, 7/00, anomaly coded in 3/18.
  ! Local variables

  real :: al0, p0, lambda
  real :: al_TS, p_TSp, lam_TS, pa_000
  integer :: j

  pa_000 = (b0*(1.0 - a0*rho_ref) - rho_ref*c0)
  do j=start,start+npts-1
    al_TS = a1*T(j) +a2*S(j)
    al0 = a0 + al_TS
    p_TSp = pressure(j) + (b4*S(j) + T(j) * (b1 + (T(j)*(b2 + b3*T(j)) + b5*S(j))))
    lam_TS = c4*S(j) + T(j) * (c1 + (T(j)*(c2 + c3*T(j)) + c5*S(j)))
    ! The following two expressions are mathematically equivalent.
    ! rho(j) = (b0 + p0_TSp) / ((c0 + lam_TS) + al0*(b0 + p0_TSp)) - rho_ref

    rho(j) = (pa_000 + (p_TSp - rho_ref*(p_TSp*al0 + (b0*al_TS + lam_TS)))) / &
             ( (c0 + lam_TS) + al0*(b0 + p_TSp) )
  enddo

end subroutine calculate_density_array_wright_ref
!> This subroutine computes the in situ density of sea water (rho in
!! [kg m-3]) from salinity (S [PSU]), potential temperature
!! (T [degC]), and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.


!> This subroutine computes the in situ specific volume of sea water (specvol in
!! [m3 kg-1]) from salinity (S [PSU]), potential temperature (T [degC])
!! and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.
!! If spv_ref is present, specvol is an anomaly from spv_ref.


!> This subroutine computes the in situ specific volume of sea water (specvol in
!! [m3 kg-1]) from salinity (S [PSU]), potential temperature (T [degC])
!! and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.
!! If spv_ref is present, specvol is an anomaly from spv_ref.


!> For a given thermodynamic state, return the thermal/haline expansion coefficients


!> The scalar version of calculate_density_derivs which promotes scalar inputs to a 1-element array and then
!! demotes the output back to a scalar


!> Second derivatives of density with respect to temperature, salinity, and pressure


!> Second derivatives of density with respect to temperature, salinity, and pressure for scalar inputs. Inputs
!! promoted to 1-element array and output demoted to scalar


!> For a given thermodynamic state, return the partial derivatives of specific volume
!! with temperature and salinity


!> This subroutine computes the in situ density of sea water (rho in
!! [kg m-3]) and the compressibility (drho/dp = C_sound^-2)
!! (drho_dp [s2 m-2]) from salinity (sal in psu), potential
!! temperature (T [degC]), and pressure [Pa].  It uses the expressions
!! from Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.
!! Coded by R. Hallberg, 1/01


!> This subroutine calculates analytical and nearly-analytical integrals of
!! pressure anomalies across layers, which are required for calculating the
!! finite-volume form pressure accelerations in a Boussinesq model.


!>   This subroutine calculates analytical and nearly-analytical integrals in
!! pressure across layers of geopotential anomalies, which are required for
!! calculating the finite-volume form pressure accelerations in a non-Boussinesq
!! model.  There are essentially no free assumptions, apart from the use of
!! Bode's rule to do the horizontal integrals, and from a truncation in the
!! series for log(1-eps/1+eps) that assumes that |eps| < 0.34.


end module MOM_EOS_Wright