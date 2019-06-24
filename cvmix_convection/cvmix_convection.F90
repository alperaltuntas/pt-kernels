!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-23 18:42:32 
!KGEN version : 0.8.1 
  


module cvmix_convection
!BOP
!\newpage
! !MODULE: cvmix_convection
! !AUTHOR:
!  Michael N. Levy, NCAR (mlevy@ucar.edu)
! !DESCRIPTION:
!  This module contains routines to initialize the derived types needed for
!  specifying mixing coefficients to parameterize vertical convective mixing,
!  and to set the viscosity and diffusivity in gravitationally unstable
!  portions of the water column.
!\!\!  References:\!  * Brunt-Vaisala?
!\!\
! !USES:

!
!
    USE cvmix_kinds_and_types, ONLY: cvmix_r8, cvmix_zero, cvmix_one, cvmix_data_type 
!EOP
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
    USE cvmix_kinds_and_types, ONLY: kr_cvmix_kinds_and_types_cvmix_data_type 
    USE cvmix_kinds_and_types, ONLY: kv_cvmix_kinds_and_types_cvmix_data_type 
    USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_tolerance, kgen_minvalue, kgen_verboselevel, CHECK_IDENTICAL, &
    &CHECK_IN_TOL, CHECK_OUT_TOL 


    IMPLICIT NONE 
    PRIVATE 
    SAVE 
!BOP
! !PUBLIC MEMBER FUNCTIONS:


! !PUBLIC TYPES:
  ! cvmix_conv_params_type contains the necessary parameters for convective
  ! mixing.


  type, public :: cvmix_conv_params_type
    private
      ! Convective diff
      ! diffusivity coefficient used in convective regime
      real(cvmix_r8) :: convect_diff ! units: m^2/s
      ! viscosity coefficient used in convective regime

      real(cvmix_r8) :: convect_visc ! units: m^2/s
      logical        :: lBruntVaisala
      ! Threshold for squared buoyancy frequency needed to trigger
      ! Brunt-Vaisala parameterization

      real(cvmix_r8) :: BVsqr_convect ! units: s^-2
      ! Only apply below the boundary layer?

      logical :: lnoOBL
      ! Flag for what to do with old values of CVmix_vars%[MTS]diff

      integer :: handle_old_vals
  end type cvmix_conv_params_type
!EOP


  PUBLIC cvmix_coeffs_conv_wrap 
#ifdef _MPI 
  include "mpif.h" 
#endif 
    
  PUBLIC kr_cvmix_kinds_and_types_cvmix_data_type 
  PUBLIC kr_cvmix_convection_cvmix_conv_params_type 
  PUBLIC kv_cvmix_kinds_and_types_cvmix_data_type 
  PUBLIC kv_cvmix_convection_cvmix_conv_params_type 

contains
!BOP
! !IROUTINE: cvmix_init_conv
! !INTERFACE:


!BOP
! !IROUTINE: cvmix_coeffs_conv_wrap
! !INTERFACE:


SUBROUTINE cvmix_coeffs_conv_wrap(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, cvmix_vars) 
! !DESCRIPTION:
!  Computes vertical diffusion coefficients for convective mixing.
!\!\
! !USES:
!  Only those used by entire module.
! !INPUT PARAMETERS:
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE kgen_utils_mod, ONLY: kgen_perturb_real 
    USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_init_verify, kgen_tolerance, kgen_minvalue, kgen_verboselevel, &
    &CHECK_IDENTICAL, CHECK_IN_TOL, CHECK_OUT_TOL 


! !INPUT/OUTPUT PARAMETERS:

    TYPE(cvmix_data_type), INTENT(INOUT) :: cvmix_vars 
!EOP
!BOC
!-----------------------------------------------------------------------
!  local variables
!-----------------------------------------------------------------------


!
!

    REAL(KIND=cvmix_r8), dimension(cvmix_vars%max_nlev+1) :: new_mdiff, new_tdiff 
    TYPE(cvmix_conv_params_type), pointer :: cvmix_conv_params_in 
    INTEGER :: nlev, max_nlev 
    REAL(KIND=cvmix_r8) :: convect_mdiff, convect_tdiff 
    LOGICAL :: lnoobl 
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
    REAL(KIND=cvmix_r8), dimension(cvmix_vars%max_nlev+1) :: kgenref_new_mdiff 
    REAL(KIND=cvmix_r8), dimension(cvmix_vars%max_nlev+1) :: kgenref_new_tdiff 
      
    !parent block preprocessing 
      
#ifdef _MPI 
    call mpi_comm_rank(mpi_comm_world, kgen_mpirank, kgen_ierr) 
#else 
    kgen_mpirank = 0 
#endif 
      
      
    !local input variables 
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) new_mdiff 
        CALL kgen_array_sumcheck("new_mdiff", kgen_array_sum, DBLE(SUM(new_mdiff, mask=(new_mdiff .eq. new_mdiff))), .TRUE.) 
    END IF   
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) new_tdiff 
        CALL kgen_array_sumcheck("new_tdiff", kgen_array_sum, DBLE(SUM(new_tdiff, mask=(new_tdiff .eq. new_tdiff))), .TRUE.) 
    END IF   
    CALL kr_kgen_cvmix_coeffs_conv_wrap_subp2(cvmix_conv_params_in, kgen_unit, "cvmix_conv_params_in", .FALSE.) 
    READ (UNIT = kgen_unit) nlev 
    READ (UNIT = kgen_unit) max_nlev 
    READ (UNIT = kgen_unit) convect_mdiff 
    READ (UNIT = kgen_unit) convect_tdiff 
    READ (UNIT = kgen_unit) lnoobl 
      
    !extern output variables 
      
    !local output variables 
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) kgenref_new_mdiff 
        CALL kgen_array_sumcheck("kgenref_new_mdiff", kgen_array_sum, DBLE(SUM(kgenref_new_mdiff, mask=(kgenref_new_mdiff .eq. &
        &kgenref_new_mdiff))), .TRUE.) 
    END IF   
    READ (UNIT = kgen_unit) kgen_istrue 
    IF (kgen_istrue) THEN 
        READ (UNIT = kgen_unit) kgen_array_sum 
        READ (UNIT = kgen_unit) kgenref_new_tdiff 
        CALL kgen_array_sumcheck("kgenref_new_tdiff", kgen_array_sum, DBLE(SUM(kgenref_new_tdiff, mask=(kgenref_new_tdiff .eq. &
        &kgenref_new_tdiff))), .TRUE.) 
    END IF   


!$kgen begin_callsite cvmix_coeffs_conv_low

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
    call cvmix_coeffs_conv_low(new_Mdiff, new_Tdiff,                              &
                           CVmix_vars%SqrBuoyancyFreq_iface,                  &
                           CVmix_vars%WaterDensity_cntr,                      &
                           CVmix_vars%AdiabWaterDensity_cntr,                 &
                           nlev, max_nlev, nint(CVMix_vars%kOBL_depth)+1,     &
                           lnoOBL, convect_mdiff, convect_tdiff,              &
                           CVmix_conv_params_in%lBruntVaisala,                &
                           CVmix_conv_params_in%BVsqr_convect,                &
                           CVmix_conv_params_in%convect_diff,                 &
                           CVmix_conv_params_in%convect_visc)
    IF (kgen_mainstage) THEN 
          
        !verify init 
        CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=1) 
        CALL kgen_init_check(check_status, rank=kgen_mpirank) 
          
        !extern verify variables 
          
        !local verify variables 
        CALL kv_kgen_cvmix_coeffs_conv_wrap_subp0("new_mdiff", check_status, new_mdiff, kgenref_new_mdiff) 
        CALL kv_kgen_cvmix_coeffs_conv_wrap_subp0("new_tdiff", check_status, new_tdiff, kgenref_new_tdiff) 
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
    call cvmix_coeffs_conv_low(new_Mdiff, new_Tdiff,                              &
                           CVmix_vars%SqrBuoyancyFreq_iface,                  &
                           CVmix_vars%WaterDensity_cntr,                      &
                           CVmix_vars%AdiabWaterDensity_cntr,                 &
                           nlev, max_nlev, nint(CVMix_vars%kOBL_depth)+1,     &
                           lnoOBL, convect_mdiff, convect_tdiff,              &
                           CVmix_conv_params_in%lBruntVaisala,                &
                           CVmix_conv_params_in%BVsqr_convect,                &
                           CVmix_conv_params_in%convect_diff,                 &
                           CVmix_conv_params_in%convect_visc)
        END DO   
        CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
        kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
#ifdef _MPI 
        CALL mpi_allreduce(kgen_measure, gkgen_measure, 1, mpi_real8, mpi_max, mpi_comm_world, kgen_ierr) 
        kgen_measure = gkgen_measure 
#endif 
        IF (check_status%rank==0) THEN 
            WRITE (*, *) "cvmix_coeffs_conv_low : Time per call (usec): ", kgen_measure 
        END IF   
    END IF   
    IF (kgen_warmupstage) THEN 
    END IF   
    IF (kgen_evalstage) THEN 
    END IF   
!$kgen end_callsite cvmix_coeffs_conv_low
!EOC
      
    CONTAINS 
      


    !read state subroutine for kr_kgen_cvmix_coeffs_conv_wrap_subp2 
    SUBROUTINE kr_kgen_cvmix_coeffs_conv_wrap_subp2(var, kgen_unit, printname, printvar) 
        TYPE(cvmix_conv_params_type), INTENT(INOUT), POINTER :: var 
        INTEGER, INTENT(IN) :: kgen_unit 
        CHARACTER(LEN=*), INTENT(IN) :: printname 
        LOGICAL, INTENT(IN), OPTIONAL :: printvar 
        LOGICAL :: kgen_istrue 
        REAL(KIND=8) :: kgen_array_sum 
          
        READ (UNIT = kgen_unit) kgen_istrue 
        IF (kgen_istrue) THEN 
            IF (ASSOCIATED( var )) THEN 
                NULLIFY (var) 
            END IF   
            ALLOCATE (var) 
            IF (PRESENT( printvar ) .AND. printvar) THEN 
                CALL kr_cvmix_convection_cvmix_conv_params_type(var, kgen_unit, printname, .TRUE.) 
            ELSE 
                CALL kr_cvmix_convection_cvmix_conv_params_type(var, kgen_unit, printname, .FALSE.) 
            END IF   
        END IF   
    END SUBROUTINE kr_kgen_cvmix_coeffs_conv_wrap_subp2 
      
    !verify state subroutine for kv_kgen_cvmix_coeffs_conv_wrap_subp0 
    RECURSIVE SUBROUTINE kv_kgen_cvmix_coeffs_conv_wrap_subp0(varname, check_status, var, kgenref_var) 
        CHARACTER(LEN=*), INTENT(IN) :: varname 
        TYPE(check_t), INTENT(INOUT) :: check_status 
        REAL(KIND=cvmix_r8), INTENT(IN), DIMENSION(:) :: var, kgenref_var 
        INTEGER :: check_result 
        LOGICAL :: is_print = .FALSE. 
          
        INTEGER :: idx1 
        INTEGER :: n 
        real(KIND=cvmix_r8) :: nrmsdiff, rmsdiff 
        real(KIND=cvmix_r8), ALLOCATABLE :: buf1(:), buf2(:) 
          
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
          
    END SUBROUTINE kv_kgen_cvmix_coeffs_conv_wrap_subp0 
      
END SUBROUTINE cvmix_coeffs_conv_wrap 
!BOP
! !IROUTINE: cvmix_coeffs_conv_low
! !INTERFACE:


  subroutine cvmix_coeffs_conv_low(Mdiff_out, Tdiff_out, Nsqr, dens, dens_lwr,&
                                   nlev, max_nlev, OBL_ind,                   &
                                   lnoOBL, convect_mdiff, convect_tdiff,      &
                                   lBruntVaisala, BVsqr_convect, convect_diff, convect_visc)
! !DESCRIPTION:
!  Computes vertical diffusion coefficients for convective mixing.
!\!\
! !USES:
!  Only those used by entire module.
! !INPUT PARAMETERS:


    integer,                               intent(in) :: nlev, max_nlev
    integer,                               intent(in) :: OBL_ind
    ! max_nlev+1
    real(cvmix_r8), dimension(max_nlev+1), intent(in) :: Nsqr
    ! max_nlev
    real(cvmix_r8), dimension(max_nlev),   intent(in) :: dens, dens_lwr
    ! retrieved from CVmix_conv_params

    logical, intent(in)        :: lnoOBL, lBruntVaisala
    real(cvmix_r8), intent(in) :: convect_mdiff, convect_tdiff
    real(cvmix_r8), intent(in) :: BVsqr_convect
    real(cvmix_r8), intent(in) :: &
      convect_diff,      &! diffusivity to parameterize convection
      convect_visc        ! viscosity to parameterize convection
! !INPUT/OUTPUT PARAMETERS:
    ! nlev+1

    real(cvmix_r8), dimension(max_nlev+1), intent(inout) :: Mdiff_out,        &
                                                            Tdiff_out
!EOP
!BOC
!-----------------------------------------------------------------------
!  local variables
!-----------------------------------------------------------------------


!
!
    integer        :: kw
    real(cvmix_r8) :: wgt
!-----------------------------------------------------------------------
!  enhance the vertical mixing coefficients if gravitationally unstable
!-----------------------------------------------------------------------

!
!
    if (lBruntVaisala) then
      ! Brunt-Vaisala mixing based on buoyancy
      ! Based on parameter BVsqr_convect
      ! diffusivity = convect_diff * wgt
      ! viscosity   = convect_visc * wgt
      ! For BVsqr_convect < 0:
      ! wgt = 0 for N^2 > 0
      ! wgt = 1 for N^2 < BVsqr_convect
      ! wgt = [1 - (1-N^2/BVsqr_convect)^2]^3 otherwise
      ! If BVsqr_convect >= 0:
      ! wgt = 0 for N^2 > 0
      ! wgt = 1 for N^2 <= 0
      ! Compute wgt


      if (BVsqr_convect.lt.0) then
        do kw=1, nlev
          wgt = cvmix_zero
          if (Nsqr(kw).le.0) then
            if (Nsqr(kw).gt.BVsqr_convect) then
              wgt = cvmix_one - Nsqr(kw) / BVsqr_convect
              wgt = (cvmix_one - wgt**2)**3
            else
              wgt = cvmix_one
            end if
          end if
          Mdiff_out(kw) = wgt*convect_visc
          Tdiff_out(kw) = wgt*convect_diff
        end do
      else ! BVsqr_convect >= 0 => step function
        do kw=1,nlev
          if ((Nsqr(kw).le.0).and.((kw.ge.OBL_ind).or.(.not.lnoOBL))) then
            Mdiff_out(kw) = convect_visc
            Tdiff_out(kw) = convect_diff
          else
            Mdiff_out(kw) = cvmix_zero
            Tdiff_out(kw) = cvmix_zero
          end if
        end do
      end if
      Mdiff_out(nlev+1) = cvmix_zero
      Tdiff_out(nlev+1) = cvmix_zero
    else
      ! Default convection mixing based on density
      do kw=1,nlev-1
        if (dens(kw).gt.dens_lwr(kw)) then
          if (convect_visc.eq.cvmix_zero) then
            ! convection only affects tracers
            Mdiff_out(kw+1) = Mdiff_out(kw)
          else
            Mdiff_out(kw+1) = convect_mdiff
          end if
          Tdiff_out(kw+1) = convect_tdiff
        end if
      end do
    end if
!EOC


  end subroutine cvmix_coeffs_conv_low
!BOP
! !IROUTINE: cvmix_put_conv_int
! !INTERFACE:


!BOP
! !IROUTINE: cvmix_put_conv_real
! !INTERFACE:


!BOP
! !IROUTINE: cvmix_put_conv_logical
! !INTERFACE:


!BOP
! !IROUTINE: cvmix_get_conv_real
! !INTERFACE:


  !read state subroutine for kr_cvmix_convection_cvmix_conv_params_type 
  RECURSIVE SUBROUTINE kr_cvmix_convection_cvmix_conv_params_type(var, kgen_unit, printname, printvar) 
      TYPE(cvmix_conv_params_type), INTENT(INOUT) :: var 
      INTEGER, INTENT(IN) :: kgen_unit 
      CHARACTER(LEN=*), INTENT(IN) :: printname 
      LOGICAL, INTENT(IN), OPTIONAL :: printvar 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
        
      READ (UNIT = kgen_unit) var%convect_diff 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%convect_diff = ", var%convect_diff 
      END IF   
        
      READ (UNIT = kgen_unit) var%convect_visc 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%convect_visc = ", var%convect_visc 
      END IF   
        
      READ (UNIT = kgen_unit) var%lbruntvaisala 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%lbruntvaisala = ", var%lbruntvaisala 
      END IF   
        
      READ (UNIT = kgen_unit) var%bvsqr_convect 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%bvsqr_convect = ", var%bvsqr_convect 
      END IF   
        
      READ (UNIT = kgen_unit) var%lnoobl 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%lnoobl = ", var%lnoobl 
      END IF   
        
      READ (UNIT = kgen_unit) var%handle_old_vals 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%handle_old_vals = ", var%handle_old_vals 
      END IF   
        
  END SUBROUTINE kr_cvmix_convection_cvmix_conv_params_type 
    
  !verify state subroutine for kv_cvmix_convection_cvmix_conv_params_type 
  RECURSIVE SUBROUTINE kv_cvmix_convection_cvmix_conv_params_type(varname, check_status, var, kgenref_var) 
      CHARACTER(LEN=*), INTENT(IN) :: varname 
      TYPE(check_t), INTENT(INOUT) :: check_status 
      TYPE(cvmix_conv_params_type), INTENT(IN) :: var, kgenref_var 
      TYPE(check_t) :: dtype_check_status, comp_check_status 
      INTEGER :: check_result 
      LOGICAL :: is_print = .FALSE. 
        
      real(KIND=cvmix_r8) :: diff_convect_diff 
      real(KIND=cvmix_r8) :: diff_convect_visc 
      logical :: diff_lbruntvaisala 
      real(KIND=cvmix_r8) :: diff_bvsqr_convect 
      logical :: diff_lnoobl 
      integer :: diff_handle_old_vals 
        
      check_status%numTotal = check_status%numTotal + 1 
        
      CALL kgen_init_check(dtype_check_status, rank=check_status%rank) 
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%convect_diff == kgenref_var%convect_diff) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%convect_diff is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_convect_diff = ABS(var%convect_diff - kgenref_var%convect_diff) 
          IF (diff_convect_diff <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%convect_diff is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%convect_diff is NOT IDENTICAL(out of tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_OUT_TOL 
          END IF   
      END IF   
      IF (check_result == CHECK_IDENTICAL) THEN 
          CONTINUE 
      ELSE IF (check_result == CHECK_OUT_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_convect_diff 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_convect_diff 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%convect_visc == kgenref_var%convect_visc) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%convect_visc is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_convect_visc = ABS(var%convect_visc - kgenref_var%convect_visc) 
          IF (diff_convect_visc <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%convect_visc is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%convect_visc is NOT IDENTICAL(out of tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_OUT_TOL 
          END IF   
      END IF   
      IF (check_result == CHECK_IDENTICAL) THEN 
          CONTINUE 
      ELSE IF (check_result == CHECK_OUT_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_convect_visc 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_convect_visc 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%lbruntvaisala .EQV. kgenref_var%lbruntvaisala) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%lbruntvaisala is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
          IF (kgen_verboseLevel > 1) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%lbruntvaisala is NOT IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_OUT_TOL 
      END IF   
      IF (check_result == CHECK_IDENTICAL) THEN 
          CONTINUE 
      ELSE IF (check_result == CHECK_OUT_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "NOT IMPLEMENTED YET" 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "NOT IMPLEMENTED YET" 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%bvsqr_convect == kgenref_var%bvsqr_convect) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%bvsqr_convect is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_bvsqr_convect = ABS(var%bvsqr_convect - kgenref_var%bvsqr_convect) 
          IF (diff_bvsqr_convect <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%bvsqr_convect is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%bvsqr_convect is NOT IDENTICAL(out of tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_OUT_TOL 
          END IF   
      END IF   
      IF (check_result == CHECK_IDENTICAL) THEN 
          CONTINUE 
      ELSE IF (check_result == CHECK_OUT_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_bvsqr_convect 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_bvsqr_convect 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%lnoobl .EQV. kgenref_var%lnoobl) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%lnoobl is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
          IF (kgen_verboseLevel > 1) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%lnoobl is NOT IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_OUT_TOL 
      END IF   
      IF (check_result == CHECK_IDENTICAL) THEN 
          CONTINUE 
      ELSE IF (check_result == CHECK_OUT_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "NOT IMPLEMENTED YET" 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "NOT IMPLEMENTED YET" 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%handle_old_vals == kgenref_var%handle_old_vals) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%handle_old_vals is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_handle_old_vals = ABS(var%handle_old_vals - kgenref_var%handle_old_vals) 
          IF (diff_handle_old_vals <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%handle_old_vals is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%handle_old_vals is NOT IDENTICAL(out of tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_OUT_TOL 
          END IF   
      END IF   
      IF (check_result == CHECK_IDENTICAL) THEN 
          CONTINUE 
      ELSE IF (check_result == CHECK_OUT_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_handle_old_vals 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_handle_old_vals 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      IF (dtype_check_status%numTotal == dtype_check_status%numIdentical) THEN 
          check_status%numIdentical = check_status%numIdentical + 1 
      ELSE IF (dtype_check_status%numOutTol > 0) THEN 
          check_status%numOutTol = check_status%numOutTol + 1 
      ELSE IF (dtype_check_status%numInTol > 0) THEN 
          check_status%numInTol = check_status%numInTol + 1 
      END IF   
  END SUBROUTINE kv_cvmix_convection_cvmix_conv_params_type 
    
end module cvmix_convection
