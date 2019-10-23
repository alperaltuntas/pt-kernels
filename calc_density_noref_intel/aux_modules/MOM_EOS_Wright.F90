!KGEN-generated Fortran source file 
  
!Generated at : 2019-10-22 21:08:52 
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
    USE target_subroutine_mod, ONLY: calculate_density_array_wright_noref

    IMPLICIT NONE 
    PUBLIC calculate_density_array_wright 
#ifdef _MPI 
include "mpif.h" 
#endif 
  

contains
!> This subroutine computes the in situ density of sea water (rho in
!! [kg m-3]) from salinity (S [PSU]), potential temperature
!! (T [degC]), and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.

SUBROUTINE calculate_density_array_wright(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, t, s, pressure, rho, start, &
&npts) 
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
    call calculate_density_array_wright_noref(T, S, pressure, rho, start, npts)
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
    call calculate_density_array_wright_noref(T, S, pressure, rho, start, npts)
        END DO   
        CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
        kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
#ifdef _MPI 
        CALL mpi_allreduce(kgen_measure, gkgen_measure, 1, mpi_real8, mpi_max, mpi_comm_world, kgen_ierr) 
        kgen_measure = gkgen_measure 
#endif 
        IF (check_status%rank==0) THEN 
            WRITE (*, *) "calculate_density_array_wright_noref : Time per call (usec): ", kgen_measure 
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

end module MOM_EOS_Wright
