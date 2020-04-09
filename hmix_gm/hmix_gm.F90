!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-22 12:03:11 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


      module hmix_gm
!BOP
! !MODULE: hmix_gm
! !DESCRIPTION:
!  This module contains routines for computing horizontal mixing
!  using the Gent-McWilliams eddy transport parameterization
!  and isopycnal diffusion.
! !REVISION HISTORY:
!  SVN:$Id$
! !USES:


          USE kinds_mod 
          USE blocks 
          USE time_management 
          USE hmix_gm_submeso_share 

          USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
          USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
          USE kgen_utils_mod, ONLY: kgen_init_verify
          USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_verboselevel, kgen_tolerance, kgen_minvalue, CHECK_IDENTICAL, &
          &CHECK_IN_TOL, CHECK_OUT_TOL 


          IMPLICIT NONE 
          PRIVATE 
          SAVE 
! !PUBLIC MEMBER FUNCTIONS:


          PUBLIC hdifft_gm 
!EOP
!BOC
!-----------------------------------------------------------------------
!     variables to save from one call to next
!-----------------------------------------------------------------------

!
!

      integer (int_kind), parameter :: &
         ktp = 1, kbt = 2     ! refer to the top and bottom halves of a
                              !  grid cell, respectively


      real (r8), dimension(:,:,:,:,:,:), allocatable :: &
         SF_SLX, SF_SLY       ! components of the merged streamfunction


                              !  this time step?

                                  !  thickness diffusion coefficients result in 
                                  !  cancellation of some tensor elements
                                  !  instead of model dependent N^2
!-----------------------------------------------------------------------
!     KAPPA_LATERAL and KAPPA_VERTICAL are 2D and 3D arrays, respectively,
!     containing the spatial variations of the isopycnal (KAPPA_ISOP)
!     and thickness (KAPPA_THIC) diffusion coefficients. Except in kappa_type_eg,
!     KAPPA_LATERAL has the actual diffusion coefficient values in cm^2/s,
!     whereas KAPPA_VERTICAL is unitless. So, the total coefficients are
!     constructed using
!      KAPPA_ISOP or KAPPA_THIC (:,:,:,k,bid) ~ KAPPA_LATERAL(:,:,bid)
!                                             * KAPPA_VERTICAL(:,:,k,bid)
!     When kappa_type_eg, KAPPA_VERTICAL contains the isopycnal diffusivity
!     coefficients in cm^2/s and KAPPA_LATERAL is not used!
!-----------------------------------------------------------------------

!
!
!
!

      REAL(KIND=r8), dimension(:,:,:,:,:), allocatable :: kappa_thic 
                            !  for top and bottom half of a grid cell
                            !  for top and bottom half of a grid cell
                            !  for top and bottom half of a grid cell


                            !  e.g. normalized buoyancy frequency dependent 
                            !  profiles at the tracer grid points
                            !  ( = N^2 / N_ref^2 ) OR a time-independent
                            !  user-specified function

!-----------------------------------------------------------------------
!     GM specific options
!     kappa_freq = how often spatial variations of the diffusion 
!                  coefficients are computed. Same frequency is 
!                  used for both coefficients.
!     slope_control = tanh function (Danabasoglu and McWilliams 1995) or
!                     DM95 with replacement function to tanh or
!                     slope clipping or
!                     method of Gerdes et al (1991)
!     diag_gm_bolus = .true. for diagnostic bolus velocity computation.
!-----------------------------------------------------------------------

!
!
!


!-----------------------------------------------------------------------
!     if use_const_ah_bkg_srfbl = .true., then the specified constant
!     value of ah_bkg_srfbl is used as the "maximum" background horizontal 
!     diffusivity within the surface boundary layer. Otherwise,
!     KAPPA_ISOP is utilized as this "maximum".
!-----------------------------------------------------------------------

!
!
  
                               
                                !  surface boundary layer

!-----------------------------------------------------------------------
!     the following set of variables are used in Eden and Greatbatch 
!     (2008) KAPPA formulation. They are in the input namelist.
!-----------------------------------------------------------------------

!
!

                           !  time scale (unitless)
!-----------------------------------------------------------------------
!     transition layer type variables
!----------------------------------------------------------------------- 

!
!

      type tlt_info
        real (r8), dimension(nx_block,ny_block,max_blocks_clinic) :: &
           DIABATIC_DEPTH,  &   ! depth of the diabatic region at the
                                !  surface, i.e. mean mixed or boundary layer
                                !  depth
           THICKNESS,       &   ! transition layer thickness
           INTERIOR_DEPTH       ! depth at which the interior, adiabatic
                                !  surface, i.e. mean mixed or boundary layer
                                !  depth
                                !  region starts, i.e.
                                !   = TLT%DIABATIC_DEPTH + TLT%THICKNESS
        integer (int_kind), &
              dimension(nx_block,ny_block,max_blocks_clinic) :: &
           K_LEVEL,  &          ! k level at or below which the interior,
                                !  adiabatic region starts
           ZTW                  ! designates if the interior region
                                !  adiabatic region starts
                                !  starts below depth zt or zw.
                                !  ( = 1 for zt, = 2 for zw )
      end type tlt_info

      type (tlt_info) :: &
         TLT                    ! transition layer thickness related fields 
!-----------------------------------------------------------------------
!     tavg ids for tavg diagnostics related to diffusivities and
!     isopycnal velocities. Zonal and meridional refer here to logical 
!     space only.
!-----------------------------------------------------------------------

!
!

!-----------------------------------------------------------------------
!  timers
!-----------------------------------------------------------------------

!
!

!EOC
!***********************************************************************
      PUBLIC kr_externs_in_hmix_gm 
      PUBLIC kr_externs_out_hmix_gm 
#ifdef _MPI 
      include "mpif.h" 
#endif 
        
      PUBLIC kv_externs_hmix_gm 
      REAL(KIND=r8), dimension(:,:,:,:,:,:), allocatable :: kgenref_sf_slx, kgenref_sf_sly 
      PUBLIC kr_hmix_gm_tlt_info 
      PUBLIC kv_hmix_gm_tlt_info 


      contains
!***********************************************************************
!BOP
! !IROUTINE: init_gm
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: hdifft_gm
! !INTERFACE:


      SUBROUTINE hdifft_gm(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, this_block) 
! !DESCRIPTION:
!  Gent-McWilliams eddy transport parameterization
!  and isopycnal diffusion.
!  This routine must be called successively with k = 1,2,3,...
! !REVISION HISTORY:
!  same as module
! !INPUT PARAMETERS:
          USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
          USE kgen_utils_mod, ONLY: kgen_perturb_real 

!
!


                               !   at mixing time level

                               !   at mixing time level


          TYPE(block), INTENT(INOUT) :: this_block 
! !OUTPUT PARAMETERS:


!EOP
!BOC
!-----------------------------------------------------------------------
!     local variables
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!     initialize various quantities
!-----------------------------------------------------------------------
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
            
          !parent block preprocessing 
            
#ifdef _MPI 
          call mpi_comm_rank(mpi_comm_world, kgen_mpirank, kgen_ierr) 
#else 
          kgen_mpirank = 0 
#endif 
            
            
          !local input variables 
            
          !extern output variables 
          CALL kr_externs_out_hmix_gm(kgen_unit) 
            
          !local output variables 

!
!


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
          call merged_streamfunction ( this_block )
          IF (kgen_mainstage) THEN 
                
              !verify init 
              CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=1) 
              CALL kgen_init_check(check_status, rank=kgen_mpirank) 
                
              !extern verify variables 
              CALL kv_externs_hmix_gm(check_status) 
                
              !local verify variables 
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
          call merged_streamfunction ( this_block )
              END DO   
              CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
              kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
#ifdef _MPI 
              CALL mpi_allreduce(kgen_measure, gkgen_measure, 1, mpi_real8, mpi_max, mpi_comm_world, kgen_ierr) 
              kgen_measure = gkgen_measure 
#endif 
              IF (check_status%rank==0) THEN 
                  WRITE (*, *) "merged_streamfunction : Time per call (usec): ", kgen_measure 
              END IF   
          END IF   
          IF (kgen_warmupstage) THEN 
          END IF   
          IF (kgen_evalstage) THEN 
          END IF   


!-----------------------------------------------------------------------
!     calculate effective vertical diffusion coefficient
!     NOTE: it is assumed that VDC has been set before this
!           in vmix_coeffs or something similar.
!     Dz(VDC * Dz(T)) where D is derivative rather than difference
!     VDC = (Az(dz*Ax(KAPPA*HYX*SLX**2)) + Az(dz*Ay(KAPPA*HXY*SLY**2)))*
!           dzw/TAREA
!-----------------------------------------------------------------------
      

!
!
!

      

!-----------------------------------------------------------------------
!     check if some horizontal diffusion needs to be added to the
!     bottom half of the bottom cell
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!     combine isopycnal and horizontal diffusion coefficients
!-----------------------------------------------------------------------

!
!


      

!-----------------------------------------------------------------------
!     start loop over tracers
!-----------------------------------------------------------------------
      

!
!


!-----------------------------------------------------------------------
!     diagnostic computation of the bolus velocities 
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!     update remaining bottom-face fields to top-face fields for next
!     pass
!-----------------------------------------------------------------------


!
!

      

!-----------------------------------------------------------------------
!     compute isopycnal diffusion cfl diagnostics if required
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!     accumulate time average if necessary; testing is internal to
!       accumulate_tavg_field
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!EOC


      END SUBROUTINE hdifft_gm 
!***********************************************************************
!BOP
! !IROUTINE: kappa_lon_lat_vmhs 
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: kappa_eg
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: kappa_lon_lat_hdgr 
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: kappa_lon_lat_dradius 
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: buoyancy_frequency_dependent_profile 
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: transition_layer 
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: merged_streamfunction 
! !INTERFACE:


      subroutine merged_streamfunction ( this_block )
! !DESCRIPTION:
!  Construct a merged streamfunction that has the appropriate
!  behavior in the surface diabatic region, transition layer, and
!  adiabatic interior
! !REVISION HISTORY:
!  same as module
! !INPUT PARAMETERS:

!


      type (block), intent(in) :: &
         this_block          ! block info for this sub block
!EOP
!BOC
!-----------------------------------------------------------------------
!     local variables
!-----------------------------------------------------------------------

!
!

      integer (int_kind) :: &
         k, kk,     &        ! loop indices
         bid                 ! local block address for this sub block
 
      real (r8), dimension(nx_block,ny_block,2) :: &
         WORK1, WORK2, WORK3, WORK4   ! work arrays

      real (r8), dimension(nx_block,ny_block) :: &
         WORK2_NEXT, WORK4_NEXT       ! WORK2 or WORK4 at next level

      real (r8), dimension(nx_block,ny_block) :: &
         WORK5, WORK6, WORK7          ! more work arrays

      logical (log_kind), dimension(nx_block,ny_block) :: &
         LMASK               ! flag

      real (r8), dimension(2) :: &
         reference_depth              ! zt or zw
!-----------------------------------------------------------------------
!     initialize various quantities
!-----------------------------------------------------------------------

!
!

      bid = this_block%local_id

      SF_SLX(:,:,:,:,:,bid) = c0
      SF_SLY(:,:,:,:,:,bid) = c0

      WORK1 = c0
      WORK2 = c0
      WORK3 = c0
      WORK4 = c0
      WORK5 = c0
      WORK6 = c0
      WORK7 = c0
      WORK2_NEXT = c0
      WORK4_NEXT = c0
!-----------------------------------------------------------------------
!     compute the interior streamfunction and its first derivative at the
!     INTERIOR_DEPTH level. WORK1 and WORK2 contain the streamfunction
!     and its first derivative, respectively, for the zonal component
!     for the east and west sides of a grid cell. WORK3 and WORK4 are
!     the corresponding fields for the meridional component for the
!     north and south sides of a grid cell. Note that these definitions
!     include a "dz". Also, the first derivative computations assume 
!     that the streamfunctions are located in the middle of the top or
!     bottom half of a grid cell, hence a factor of two in WORK2 and
!     WORK4 calculations. 
!-----------------------------------------------------------------------

!
!

      do k=1,km-1

        do kk=1,2

          LMASK = TLT%K_LEVEL(:,:,bid) == k  .and.            &
                  TLT%K_LEVEL(:,:,bid) < KMT(:,:,bid)  .and.  &
                  TLT%ZTW(:,:,bid) == 1

          where ( LMASK ) 

            WORK1(:,:,kk) =  KAPPA_THIC(:,:,kbt,k,bid)  &
                           * SLX(:,:,kk,kbt,k,bid) * dz(k)
            WORK2(:,:,kk) = c2 * dzwr(k) * ( WORK1(:,:,kk)            &
              - KAPPA_THIC(:,:,ktp,k+1,bid) * SLX(:,:,kk,ktp,k+1,bid) &
                                            * dz(k+1) )

            WORK2_NEXT = c2 * ( &
              KAPPA_THIC(:,:,ktp,k+1,bid) * SLX(:,:,kk,ktp,k+1,bid) - &
              KAPPA_THIC(:,:,kbt,k+1,bid) * SLX(:,:,kk,kbt,k+1,bid) )

            WORK3(:,:,kk) =  KAPPA_THIC(:,:,kbt,k,bid)  &
                           * SLY(:,:,kk,kbt,k,bid) * dz(k)
            WORK4(:,:,kk) = c2 * dzwr(k) * ( WORK3(:,:,kk)            &
              - KAPPA_THIC(:,:,ktp,k+1,bid) * SLY(:,:,kk,ktp,k+1,bid) &
                                            * dz(k+1) )

            WORK4_NEXT = c2 * ( &
              KAPPA_THIC(:,:,ktp,k+1,bid) * SLY(:,:,kk,ktp,k+1,bid) - &
              KAPPA_THIC(:,:,kbt,k+1,bid) * SLY(:,:,kk,kbt,k+1,bid) )

          endwhere

          where ( LMASK .and. abs(WORK2_NEXT) < abs(WORK2(:,:,kk)) ) &
            WORK2(:,:,kk) = WORK2_NEXT

          where ( LMASK .and. abs(WORK4_NEXT) < abs(WORK4(:,:,kk)) ) &
            WORK4(:,:,kk) = WORK4_NEXT

          LMASK = TLT%K_LEVEL(:,:,bid) == k  .and.           &
                  TLT%K_LEVEL(:,:,bid) < KMT(:,:,bid)  .and. &
                  TLT%ZTW(:,:,bid) == 2

          where ( LMASK )

            WORK1(:,:,kk) =  KAPPA_THIC(:,:,ktp,k+1,bid)     & 
                           * SLX(:,:,kk,ktp,k+1,bid)
            WORK2(:,:,kk) =  c2 * ( WORK1(:,:,kk)                 &
                           - ( KAPPA_THIC(:,:,kbt,k+1,bid)        &
                              * SLX(:,:,kk,kbt,k+1,bid) ) )
            WORK1(:,:,kk) = WORK1(:,:,kk) * dz(k+1)

            WORK3(:,:,kk) =  KAPPA_THIC(:,:,ktp,k+1,bid)     &
                           * SLY(:,:,kk,ktp,k+1,bid)
            WORK4(:,:,kk) =  c2 * ( WORK3(:,:,kk)                 &
                           - ( KAPPA_THIC(:,:,kbt,k+1,bid)        &
                              * SLY(:,:,kk,kbt,k+1,bid) ) )
            WORK3(:,:,kk) = WORK3(:,:,kk) * dz(k+1)

          endwhere

          LMASK = LMASK .and. TLT%K_LEVEL(:,:,bid) + 1 < KMT(:,:,bid)

          if (k.lt.km-1) then ! added to avoid out of bounds access
            where ( LMASK )

              WORK2_NEXT = c2 * dzwr(k+1) * ( &
                KAPPA_THIC(:,:,kbt,k+1,bid) * SLX(:,:,kk,kbt,k+1,bid) * dz(k+1) - &
                KAPPA_THIC(:,:,ktp,k+2,bid) * SLX(:,:,kk,ktp,k+2,bid) * dz(k+2))

              WORK4_NEXT = c2 * dzwr(k+1) * ( &
                KAPPA_THIC(:,:,kbt,k+1,bid) * SLY(:,:,kk,kbt,k+1,bid) * dz(k+1) - &
                KAPPA_THIC(:,:,ktp,k+2,bid) * SLY(:,:,kk,ktp,k+2,bid) * dz(k+2))

            endwhere
          end if

          where ( LMASK .and. abs(WORK2_NEXT) < abs(WORK2(:,:,kk)) ) &
            WORK2(:,:,kk) = WORK2_NEXT

          where ( LMASK .and. abs(WORK4_NEXT) < abs(WORK4(:,:,kk)) ) &
            WORK4(:,:,kk) = WORK4_NEXT

        enddo

      enddo
!-----------------------------------------------------------------------
!     compute the depth independent interpolation factors used in the 
!     linear and quadratic interpolations within the diabatic and 
!     transition regions, respectively.
!-----------------------------------------------------------------------

!
!

      WORK5 = c0
      where (KMT(:,:,bid) /= 0)
        WORK5(:,:) = c1 / ( c2 * TLT%DIABATIC_DEPTH(:,:,bid) &
                   + TLT%THICKNESS(:,:,bid) )
      endwhere

      WORK6 = c0
      where ((KMT(:,:,bid) /= 0) .AND. (TLT%THICKNESS(:,:,bid) > eps))
        WORK6(:,:) = WORK5(:,:) / TLT%THICKNESS(:,:,bid)
      endwhere
!-----------------------------------------------------------------------
!     start of interpolation to construct the merged streamfunction
!-----------------------------------------------------------------------

!
!

      do k=1,km

        reference_depth(ktp) = zt(k) - p25 * dz(k)
        reference_depth(kbt) = zt(k) + p25 * dz(k)

        do kk=ktp,kbt
!-----------------------------------------------------------------------
!     diabatic region: use linear interpolation (in streamfunction) 
!-----------------------------------------------------------------------

!
!

          where ( reference_depth(kk) <= TLT%DIABATIC_DEPTH(:,:,bid)  &
                  .and.  k <= KMT(:,:,bid) ) 

            SF_SLX(:,:,1,kk,k,bid) = reference_depth(kk) * WORK5  &
                  * ( c2 * WORK1(:,:,1) + TLT%THICKNESS(:,:,bid)  &
                     * WORK2(:,:,1) )

            SF_SLX(:,:,2,kk,k,bid) = reference_depth(kk) * WORK5  &
                  * ( c2 * WORK1(:,:,2) + TLT%THICKNESS(:,:,bid)  &
                     * WORK2(:,:,2) )

            SF_SLY(:,:,1,kk,k,bid) = reference_depth(kk) * WORK5  &
                  * ( c2 * WORK3(:,:,1) + TLT%THICKNESS(:,:,bid)  &
                     * WORK4(:,:,1) )

            SF_SLY(:,:,2,kk,k,bid) = reference_depth(kk) * WORK5  &
                  * ( c2 * WORK3(:,:,2) + TLT%THICKNESS(:,:,bid)  &
                     * WORK4(:,:,2) )

          endwhere
!-----------------------------------------------------------------------
!     transition layer: use quadratic interpolation (in streamfunction) 
!-----------------------------------------------------------------------

!
!

          where ( reference_depth(kk) > TLT%DIABATIC_DEPTH(:,:,bid)   &
            .and.  reference_depth(kk) <= TLT%INTERIOR_DEPTH(:,:,bid) &
            .and.  k <= KMT(:,:,bid) )

            WORK7 = (TLT%DIABATIC_DEPTH(:,:,bid)  &
                     - reference_depth(kk))**2

            SF_SLX(:,:,1,kk,k,bid) = - WORK7 * WORK6            &
                * ( WORK1(:,:,1) + TLT%INTERIOR_DEPTH(:,:,bid)  &
                   * WORK2(:,:,1) )                             &
               + reference_depth(kk) * WORK5                    &
                * ( c2 * WORK1(:,:,1) + TLT%THICKNESS(:,:,bid)  &
                   * WORK2(:,:,1) )

            SF_SLX(:,:,2,kk,k,bid) = - WORK7 * WORK6            &
                * ( WORK1(:,:,2) + TLT%INTERIOR_DEPTH(:,:,bid)  &
                   * WORK2(:,:,2) )                             &
               + reference_depth(kk) * WORK5                    &
                * ( c2 * WORK1(:,:,2) + TLT%THICKNESS(:,:,bid)  &
                   * WORK2(:,:,2) )

            SF_SLY(:,:,1,kk,k,bid) = - WORK7 * WORK6            &
                * ( WORK3(:,:,1) + TLT%INTERIOR_DEPTH(:,:,bid)  &
                   * WORK4(:,:,1) )                             &
               + reference_depth(kk) * WORK5                    &
                * ( c2 * WORK3(:,:,1) + TLT%THICKNESS(:,:,bid)  &
                   * WORK4(:,:,1) )

            SF_SLY(:,:,2,kk,k,bid) = - WORK7 * WORK6            &
                * ( WORK3(:,:,2) + TLT%INTERIOR_DEPTH(:,:,bid)  &
                   * WORK4(:,:,2) )                             &
               + reference_depth(kk) * WORK5                    &
                * ( c2 * WORK3(:,:,2) + TLT%THICKNESS(:,:,bid)  &
                   * WORK4(:,:,2) )

          endwhere
!-----------------------------------------------------------------------
!     interior, adiabatic region: no interpolation is needed. note that
!     "dzw" is introduced here, too, for consistency. 
!-----------------------------------------------------------------------

!
!

          where ( reference_depth(kk) > TLT%INTERIOR_DEPTH(:,:,bid)  & 
                  .and.  k <= KMT(:,:,bid) )

            SF_SLX(:,:,1,kk,k,bid) =  KAPPA_THIC(:,:,kk,k,bid)  &
                              * SLX(:,:,1,kk,k,bid) * dz(k)

            SF_SLX(:,:,2,kk,k,bid) =  KAPPA_THIC(:,:,kk,k,bid)  &
                              * SLX(:,:,2,kk,k,bid) * dz(k)

            SF_SLY(:,:,1,kk,k,bid) =  KAPPA_THIC(:,:,kk,k,bid)  &
                              * SLY(:,:,1,kk,k,bid) * dz(k)

            SF_SLY(:,:,2,kk,k,bid) =  KAPPA_THIC(:,:,kk,k,bid)  &
                              * SLY(:,:,2,kk,k,bid) * dz(k)

          endwhere

        enddo  ! end of kk-loop

      enddo    ! end of k-loop
!-----------------------------------------------------------------------
!EOC


      end subroutine merged_streamfunction
!***********************************************************************
!BOP
! !IROUTINE: apply_vertical_profile_to_isop_hor_diff 
! !INTERFACE:


!***********************************************************************
!***********************************************************************
!BOP
! !IROUTINE: calc_ri_n2
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: calc_sigma
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: kappa_steer
! !INTERFACE:


      !read state subroutine for kr_externs_in_hmix_gm 
      SUBROUTINE kr_externs_in_hmix_gm(kgen_unit) 
          INTEGER, INTENT(IN) :: kgen_unit 
          LOGICAL :: kgen_istrue 
          REAL(KIND=8) :: kgen_array_sum 
            
          CALL kr_hmix_gm_real__r8_dim6(sf_sly, kgen_unit, "sf_sly", .FALSE.) 
          CALL kr_hmix_gm_real__r8_dim6(sf_slx, kgen_unit, "sf_slx", .FALSE.) 
          CALL kr_hmix_gm_real__r8_dim5(kappa_thic, kgen_unit, "kappa_thic", .FALSE.) 
          CALL kr_hmix_gm_tlt_info(tlt, kgen_unit, "tlt", .FALSE.) 
      END SUBROUTINE kr_externs_in_hmix_gm 
        
      !read state subroutine for kr_externs_out_hmix_gm 
      SUBROUTINE kr_externs_out_hmix_gm(kgen_unit) 
          INTEGER, INTENT(IN) :: kgen_unit 
            
          LOGICAL :: kgen_istrue 
          REAL(KIND=8) :: kgen_array_sum 
          CALL kr_hmix_gm_real__r8_dim6(kgenref_sf_sly, kgen_unit, "kgenref_sf_sly", .FALSE.) 
          CALL kr_hmix_gm_real__r8_dim6(kgenref_sf_slx, kgen_unit, "kgenref_sf_slx", .FALSE.) 
      END SUBROUTINE kr_externs_out_hmix_gm 
        
      !verify state subroutine for kv_externs_hmix_gm 
      SUBROUTINE kv_externs_hmix_gm(check_status) 
          TYPE(check_t), INTENT(INOUT) :: check_status 
            
          CALL kv_hmix_gm_real__r8_dim6("sf_sly", check_status, sf_sly, kgenref_sf_sly) 
          CALL kv_hmix_gm_real__r8_dim6("sf_slx", check_status, sf_slx, kgenref_sf_slx) 
      END SUBROUTINE kv_externs_hmix_gm 
        
      !read state subroutine for kr_hmix_gm_real__r8_dim6 
      SUBROUTINE kr_hmix_gm_real__r8_dim6(var, kgen_unit, printname, printvar) 
          REAL(KIND=r8), INTENT(INOUT), ALLOCATABLE, DIMENSION(:,:,:,:,:,:) :: var 
          INTEGER, INTENT(IN) :: kgen_unit 
          CHARACTER(LEN=*), INTENT(IN) :: printname 
          LOGICAL, INTENT(IN), OPTIONAL :: printvar 
          LOGICAL :: kgen_istrue 
          REAL(KIND=8) :: kgen_array_sum 
          INTEGER :: idx1, idx2, idx3, idx4, idx5, idx6 
          INTEGER, DIMENSION(2,6) :: kgen_bound 
            
          READ (UNIT = kgen_unit) kgen_istrue 
          IF (kgen_istrue) THEN 
              IF (ALLOCATED( var )) THEN 
                  DEALLOCATE (var) 
              END IF   
              READ (UNIT = kgen_unit) kgen_array_sum 
              READ (UNIT = kgen_unit) kgen_bound(1, 1) 
              READ (UNIT = kgen_unit) kgen_bound(2, 1) 
              READ (UNIT = kgen_unit) kgen_bound(1, 2) 
              READ (UNIT = kgen_unit) kgen_bound(2, 2) 
              READ (UNIT = kgen_unit) kgen_bound(1, 3) 
              READ (UNIT = kgen_unit) kgen_bound(2, 3) 
              READ (UNIT = kgen_unit) kgen_bound(1, 4) 
              READ (UNIT = kgen_unit) kgen_bound(2, 4) 
              READ (UNIT = kgen_unit) kgen_bound(1, 5) 
              READ (UNIT = kgen_unit) kgen_bound(2, 5) 
              READ (UNIT = kgen_unit) kgen_bound(1, 6) 
              READ (UNIT = kgen_unit) kgen_bound(2, 6) 
              ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1), kgen_bound(1,2):kgen_bound(2,2), kgen_bound(1,3):kgen_bound(2,3), &
              &kgen_bound(1,4):kgen_bound(2,4), kgen_bound(1,5):kgen_bound(2,5), kgen_bound(1,6):kgen_bound(2,6))) 
              READ (UNIT = kgen_unit) var 
              CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
              IF (PRESENT( printvar ) .AND. printvar) THEN 
                  WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
              END IF   
          END IF   
      END SUBROUTINE kr_hmix_gm_real__r8_dim6 
        
      !read state subroutine for kr_hmix_gm_real__r8_dim5 
      SUBROUTINE kr_hmix_gm_real__r8_dim5(var, kgen_unit, printname, printvar) 
          REAL(KIND=r8), INTENT(INOUT), ALLOCATABLE, DIMENSION(:,:,:,:,:) :: var 
          INTEGER, INTENT(IN) :: kgen_unit 
          CHARACTER(LEN=*), INTENT(IN) :: printname 
          LOGICAL, INTENT(IN), OPTIONAL :: printvar 
          LOGICAL :: kgen_istrue 
          REAL(KIND=8) :: kgen_array_sum 
          INTEGER :: idx1, idx2, idx3, idx4, idx5 
          INTEGER, DIMENSION(2,5) :: kgen_bound 
            
          READ (UNIT = kgen_unit) kgen_istrue 
          IF (kgen_istrue) THEN 
              IF (ALLOCATED( var )) THEN 
                  DEALLOCATE (var) 
              END IF   
              READ (UNIT = kgen_unit) kgen_array_sum 
              READ (UNIT = kgen_unit) kgen_bound(1, 1) 
              READ (UNIT = kgen_unit) kgen_bound(2, 1) 
              READ (UNIT = kgen_unit) kgen_bound(1, 2) 
              READ (UNIT = kgen_unit) kgen_bound(2, 2) 
              READ (UNIT = kgen_unit) kgen_bound(1, 3) 
              READ (UNIT = kgen_unit) kgen_bound(2, 3) 
              READ (UNIT = kgen_unit) kgen_bound(1, 4) 
              READ (UNIT = kgen_unit) kgen_bound(2, 4) 
              READ (UNIT = kgen_unit) kgen_bound(1, 5) 
              READ (UNIT = kgen_unit) kgen_bound(2, 5) 
              ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1), kgen_bound(1,2):kgen_bound(2,2), kgen_bound(1,3):kgen_bound(2,3), &
              &kgen_bound(1,4):kgen_bound(2,4), kgen_bound(1,5):kgen_bound(2,5))) 
              READ (UNIT = kgen_unit) var 
              CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
              IF (PRESENT( printvar ) .AND. printvar) THEN 
                  WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
              END IF   
          END IF   
      END SUBROUTINE kr_hmix_gm_real__r8_dim5 
        
      !read state subroutine for kr_hmix_gm_tlt_info 
      RECURSIVE SUBROUTINE kr_hmix_gm_tlt_info(var, kgen_unit, printname, printvar) 
          TYPE(tlt_info), INTENT(INOUT) :: var 
          INTEGER, INTENT(IN) :: kgen_unit 
          CHARACTER(LEN=*), INTENT(IN) :: printname 
          LOGICAL, INTENT(IN), OPTIONAL :: printvar 
          LOGICAL :: kgen_istrue 
          REAL(KIND=8) :: kgen_array_sum 
            
          READ (UNIT = kgen_unit) kgen_istrue 
          IF (kgen_istrue) THEN 
              READ (UNIT = kgen_unit) kgen_array_sum 
              READ (UNIT = kgen_unit) var%diabatic_depth 
              CALL kgen_array_sumcheck(printname // "%diabatic_depth", kgen_array_sum, DBLE(SUM(var%diabatic_depth, &
              &mask=(var%diabatic_depth .eq. var%diabatic_depth))), .TRUE.) 
              IF (PRESENT( printvar ) .AND. printvar) THEN 
                  WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // "%diabatic_depth)) = ", DBLE(SUM(var%diabatic_depth, &
                  &mask=(var%diabatic_depth .eq. var%diabatic_depth))) 
              END IF   
          END IF   
          READ (UNIT = kgen_unit) kgen_istrue 
          IF (kgen_istrue) THEN 
              READ (UNIT = kgen_unit) kgen_array_sum 
              READ (UNIT = kgen_unit) var%thickness 
              CALL kgen_array_sumcheck(printname // "%thickness", kgen_array_sum, DBLE(SUM(var%thickness, mask=(var%thickness &
              &.eq. var%thickness))), .TRUE.) 
              IF (PRESENT( printvar ) .AND. printvar) THEN 
                  WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // "%thickness)) = ", DBLE(SUM(var%thickness, &
                  &mask=(var%thickness .eq. var%thickness))) 
              END IF   
          END IF   
          READ (UNIT = kgen_unit) kgen_istrue 
          IF (kgen_istrue) THEN 
              READ (UNIT = kgen_unit) kgen_array_sum 
              READ (UNIT = kgen_unit) var%interior_depth 
              CALL kgen_array_sumcheck(printname // "%interior_depth", kgen_array_sum, DBLE(SUM(var%interior_depth, &
              &mask=(var%interior_depth .eq. var%interior_depth))), .TRUE.) 
              IF (PRESENT( printvar ) .AND. printvar) THEN 
                  WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // "%interior_depth)) = ", DBLE(SUM(var%interior_depth, &
                  &mask=(var%interior_depth .eq. var%interior_depth))) 
              END IF   
          END IF   
            
          READ (UNIT = kgen_unit) kgen_istrue 
          IF (kgen_istrue) THEN 
              READ (UNIT = kgen_unit) kgen_array_sum 
              READ (UNIT = kgen_unit) var%k_level 
              CALL kgen_array_sumcheck(printname // "%k_level", kgen_array_sum, DBLE(SUM(var%k_level, mask=(var%k_level .eq. &
              &var%k_level))), .TRUE.) 
              IF (PRESENT( printvar ) .AND. printvar) THEN 
                  WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // "%k_level)) = ", DBLE(SUM(var%k_level, mask=(var%k_level &
                  &.eq. var%k_level))) 
              END IF   
          END IF   
          READ (UNIT = kgen_unit) kgen_istrue 
          IF (kgen_istrue) THEN 
              READ (UNIT = kgen_unit) kgen_array_sum 
              READ (UNIT = kgen_unit) var%ztw 
              CALL kgen_array_sumcheck(printname // "%ztw", kgen_array_sum, DBLE(SUM(var%ztw, mask=(var%ztw .eq. var%ztw))), &
              &.TRUE.) 
              IF (PRESENT( printvar ) .AND. printvar) THEN 
                  WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // "%ztw)) = ", DBLE(SUM(var%ztw, mask=(var%ztw .eq. &
                  &var%ztw))) 
              END IF   
          END IF   
            
      END SUBROUTINE kr_hmix_gm_tlt_info 
        
      !verify state subroutine for kv_hmix_gm_real__r8_dim6 
      RECURSIVE SUBROUTINE kv_hmix_gm_real__r8_dim6(varname, check_status, var, kgenref_var) 
          CHARACTER(LEN=*), INTENT(IN) :: varname 
          TYPE(check_t), INTENT(INOUT) :: check_status 
          REAL(KIND=r8), allocatable, INTENT(IN), DIMENSION(:,:,:,:,:,:) :: var, kgenref_var 
          INTEGER :: check_result 
          LOGICAL :: is_print = .FALSE. 
            
          INTEGER :: idx1, idx2, idx3, idx4, idx5, idx6 
          INTEGER :: n 
          real(KIND=r8) :: nrmsdiff, rmsdiff 
          real(KIND=r8), ALLOCATABLE :: buf1(:,:,:,:,:,:), buf2(:,:,:,:,:,:) 
            
          IF (ALLOCATED(var)) THEN 
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
                  ALLOCATE &
                  &(buf1(SIZE(var,dim=1),SIZE(var,dim=2),SIZE(var,dim=3),SIZE(var,dim=4),SIZE(var,dim=5),SIZE(var,dim=6))) 
                  ALLOCATE &
                  &(buf2(SIZE(var,dim=1),SIZE(var,dim=2),SIZE(var,dim=3),SIZE(var,dim=4),SIZE(var,dim=5),SIZE(var,dim=6))) 
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
                
          END IF   
      END SUBROUTINE kv_hmix_gm_real__r8_dim6 
        
      !verify state subroutine for kv_hmix_gm_tlt_info 
      RECURSIVE SUBROUTINE kv_hmix_gm_tlt_info(varname, check_status, var, kgenref_var) 
          CHARACTER(LEN=*), INTENT(IN) :: varname 
          TYPE(check_t), INTENT(INOUT) :: check_status 
          TYPE(tlt_info), INTENT(IN) :: var, kgenref_var 
          TYPE(check_t) :: dtype_check_status, comp_check_status 
          INTEGER :: check_result 
          LOGICAL :: is_print = .FALSE. 
            
          INTEGER :: n_diabatic_depth 
          real(KIND=r8) :: nrmsdiff_diabatic_depth, rmsdiff_diabatic_depth 
          real(KIND=r8), ALLOCATABLE :: buf1_diabatic_depth(:,:,:), buf2_diabatic_depth(:,:,:) 
          INTEGER :: n_thickness 
          real(KIND=r8) :: nrmsdiff_thickness, rmsdiff_thickness 
          real(KIND=r8), ALLOCATABLE :: buf1_thickness(:,:,:), buf2_thickness(:,:,:) 
          INTEGER :: n_interior_depth 
          real(KIND=r8) :: nrmsdiff_interior_depth, rmsdiff_interior_depth 
          real(KIND=r8), ALLOCATABLE :: buf1_interior_depth(:,:,:), buf2_interior_depth(:,:,:) 
          INTEGER :: n_k_level 
          integer(KIND=int_kind) :: nrmsdiff_k_level, rmsdiff_k_level 
          integer(KIND=int_kind), ALLOCATABLE :: buf1_k_level(:,:,:), buf2_k_level(:,:,:) 
          INTEGER :: n_ztw 
          integer(KIND=int_kind) :: nrmsdiff_ztw, rmsdiff_ztw 
          integer(KIND=int_kind), ALLOCATABLE :: buf1_ztw(:,:,:), buf2_ztw(:,:,:) 
            
          check_status%numTotal = check_status%numTotal + 1 
            
          CALL kgen_init_check(dtype_check_status, rank=check_status%rank) 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%diabatic_depth == kgenref_var%diabatic_depth)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%diabatic_depth is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_diabatic_depth(SIZE(var%diabatic_depth,dim=1),SIZE(var%diabatic_depth,dim=2),&
                                            SIZE(var%diabatic_depth,dim=3)))
              ALLOCATE (buf2_diabatic_depth(SIZE(var%diabatic_depth,dim=1),SIZE(var%diabatic_depth,dim=2),&
                                            SIZE(var%diabatic_depth,dim=3)))
              n_diabatic_depth = COUNT(var%diabatic_depth /= kgenref_var%diabatic_depth) 
              WHERE ( ABS(kgenref_var%diabatic_depth) > kgen_minvalue ) 
                  buf1_diabatic_depth = ((var%diabatic_depth-kgenref_var%diabatic_depth)/kgenref_var%diabatic_depth)**2 
                  buf2_diabatic_depth = (var%diabatic_depth-kgenref_var%diabatic_depth)**2 
              ELSEWHERE 
                  buf1_diabatic_depth = (var%diabatic_depth-kgenref_var%diabatic_depth)**2 
                  buf2_diabatic_depth = buf1_diabatic_depth 
              END WHERE   
              nrmsdiff_diabatic_depth = SQRT(SUM(buf1_diabatic_depth)/REAL(n_diabatic_depth)) 
              rmsdiff_diabatic_depth = SQRT(SUM(buf2_diabatic_depth)/REAL(n_diabatic_depth)) 
              IF (rmsdiff_diabatic_depth > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%diabatic_depth is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%diabatic_depth is NOT IDENTICAL(within tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_IN_TOL 
              END IF   
          END IF   
          IF (check_result == CHECK_IDENTICAL) THEN 
              CONTINUE 
          ELSE IF (check_result == CHECK_OUT_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%diabatic_depth /= kgenref_var%diabatic_depth), " of ", size( var%diabatic_depth ), &
                      &" elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%diabatic_depth)/real(size(var%diabatic_depth)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%diabatic_depth)/real(size(kgenref_var%diabatic_depth)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_diabatic_depth 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_diabatic_depth 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%diabatic_depth /= kgenref_var%diabatic_depth), " of ", size( var%diabatic_depth ), &
                      &" elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%diabatic_depth)/real(size(var%diabatic_depth)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%diabatic_depth)/real(size(kgenref_var%diabatic_depth)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_diabatic_depth 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_diabatic_depth 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%thickness == kgenref_var%thickness)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%thickness is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_thickness(SIZE(var%thickness,dim=1),SIZE(var%thickness,dim=2),SIZE(var%thickness,dim=3))) 
              ALLOCATE (buf2_thickness(SIZE(var%thickness,dim=1),SIZE(var%thickness,dim=2),SIZE(var%thickness,dim=3))) 
              n_thickness = COUNT(var%thickness /= kgenref_var%thickness) 
              WHERE ( ABS(kgenref_var%thickness) > kgen_minvalue ) 
                  buf1_thickness = ((var%thickness-kgenref_var%thickness)/kgenref_var%thickness)**2 
                  buf2_thickness = (var%thickness-kgenref_var%thickness)**2 
              ELSEWHERE 
                  buf1_thickness = (var%thickness-kgenref_var%thickness)**2 
                  buf2_thickness = buf1_thickness 
              END WHERE   
              nrmsdiff_thickness = SQRT(SUM(buf1_thickness)/REAL(n_thickness)) 
              rmsdiff_thickness = SQRT(SUM(buf2_thickness)/REAL(n_thickness)) 
              IF (rmsdiff_thickness > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%thickness is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%thickness is NOT IDENTICAL(within tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_IN_TOL 
              END IF   
          END IF   
          IF (check_result == CHECK_IDENTICAL) THEN 
              CONTINUE 
          ELSE IF (check_result == CHECK_OUT_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%thickness /= kgenref_var%thickness), " of ", size( var%thickness ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%thickness)/real(size(var%thickness)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%thickness)/real(size(kgenref_var%thickness)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_thickness 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_thickness 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%thickness /= kgenref_var%thickness), " of ", size( var%thickness ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%thickness)/real(size(var%thickness)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%thickness)/real(size(kgenref_var%thickness)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_thickness 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_thickness 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%interior_depth == kgenref_var%interior_depth)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%interior_depth is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_interior_depth(SIZE(var%interior_depth,dim=1),SIZE(var%interior_depth,dim=2),&
                                            SIZE(var%interior_depth,dim=3)))
              ALLOCATE (buf2_interior_depth(SIZE(var%interior_depth,dim=1),SIZE(var%interior_depth,dim=2),&
                                            SIZE(var%interior_depth,dim=3)))
              n_interior_depth = COUNT(var%interior_depth /= kgenref_var%interior_depth) 
              WHERE ( ABS(kgenref_var%interior_depth) > kgen_minvalue ) 
                  buf1_interior_depth = ((var%interior_depth-kgenref_var%interior_depth)/kgenref_var%interior_depth)**2 
                  buf2_interior_depth = (var%interior_depth-kgenref_var%interior_depth)**2 
              ELSEWHERE 
                  buf1_interior_depth = (var%interior_depth-kgenref_var%interior_depth)**2 
                  buf2_interior_depth = buf1_interior_depth 
              END WHERE   
              nrmsdiff_interior_depth = SQRT(SUM(buf1_interior_depth)/REAL(n_interior_depth)) 
              rmsdiff_interior_depth = SQRT(SUM(buf2_interior_depth)/REAL(n_interior_depth)) 
              IF (rmsdiff_interior_depth > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%interior_depth is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%interior_depth is NOT IDENTICAL(within tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_IN_TOL 
              END IF   
          END IF   
          IF (check_result == CHECK_IDENTICAL) THEN 
              CONTINUE 
          ELSE IF (check_result == CHECK_OUT_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%interior_depth /= kgenref_var%interior_depth), " of ", size( var%interior_depth ), &
                      &" elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%interior_depth)/real(size(var%interior_depth)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%interior_depth)/real(size(kgenref_var%interior_depth)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_interior_depth 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_interior_depth 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%interior_depth /= kgenref_var%interior_depth), " of ", size( var%interior_depth ), &
                      &" elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%interior_depth)/real(size(var%interior_depth)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%interior_depth)/real(size(kgenref_var%interior_depth)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_interior_depth 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_interior_depth 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%k_level == kgenref_var%k_level)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%k_level is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_k_level(SIZE(var%k_level,dim=1),SIZE(var%k_level,dim=2),SIZE(var%k_level,dim=3))) 
              ALLOCATE (buf2_k_level(SIZE(var%k_level,dim=1),SIZE(var%k_level,dim=2),SIZE(var%k_level,dim=3))) 
              n_k_level = COUNT(var%k_level /= kgenref_var%k_level) 
              WHERE ( ABS(kgenref_var%k_level) > kgen_minvalue ) 
                  buf1_k_level = ((var%k_level-kgenref_var%k_level)/kgenref_var%k_level)**2 
                  buf2_k_level = (var%k_level-kgenref_var%k_level)**2 
              ELSEWHERE 
                  buf1_k_level = (var%k_level-kgenref_var%k_level)**2 
                  buf2_k_level = buf1_k_level 
              END WHERE   
              nrmsdiff_k_level = SQRT(SUM(buf1_k_level)/REAL(n_k_level)) 
              rmsdiff_k_level = SQRT(SUM(buf2_k_level)/REAL(n_k_level)) 
              IF (rmsdiff_k_level > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%k_level is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%k_level is NOT IDENTICAL(within tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_IN_TOL 
              END IF   
          END IF   
          IF (check_result == CHECK_IDENTICAL) THEN 
              CONTINUE 
          ELSE IF (check_result == CHECK_OUT_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%k_level /= kgenref_var%k_level), " of ", size( var%k_level ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%k_level)/real(size(var%k_level)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%k_level)/real(size(kgenref_var%k_level)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_k_level 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_k_level 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%k_level /= kgenref_var%k_level), " of ", size( var%k_level ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%k_level)/real(size(var%k_level)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%k_level)/real(size(kgenref_var%k_level)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_k_level 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_k_level 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%ztw == kgenref_var%ztw)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%ztw is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_ztw(SIZE(var%ztw,dim=1),SIZE(var%ztw,dim=2),SIZE(var%ztw,dim=3))) 
              ALLOCATE (buf2_ztw(SIZE(var%ztw,dim=1),SIZE(var%ztw,dim=2),SIZE(var%ztw,dim=3))) 
              n_ztw = COUNT(var%ztw /= kgenref_var%ztw) 
              WHERE ( ABS(kgenref_var%ztw) > kgen_minvalue ) 
                  buf1_ztw = ((var%ztw-kgenref_var%ztw)/kgenref_var%ztw)**2 
                  buf2_ztw = (var%ztw-kgenref_var%ztw)**2 
              ELSEWHERE 
                  buf1_ztw = (var%ztw-kgenref_var%ztw)**2 
                  buf2_ztw = buf1_ztw 
              END WHERE   
              nrmsdiff_ztw = SQRT(SUM(buf1_ztw)/REAL(n_ztw)) 
              rmsdiff_ztw = SQRT(SUM(buf2_ztw)/REAL(n_ztw)) 
              IF (rmsdiff_ztw > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%ztw is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%ztw is NOT IDENTICAL(within tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_IN_TOL 
              END IF   
          END IF   
          IF (check_result == CHECK_IDENTICAL) THEN 
              CONTINUE 
          ELSE IF (check_result == CHECK_OUT_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%ztw /= kgenref_var%ztw), " of ", size( var%ztw ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%ztw)/real(size(var%ztw)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%ztw)/real(size(kgenref_var%ztw)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_ztw 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_ztw 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%ztw /= kgenref_var%ztw), " of ", size( var%ztw ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%ztw)/real(size(var%ztw)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%ztw)/real(size(kgenref_var%ztw)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_ztw 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_ztw 
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
      END SUBROUTINE kv_hmix_gm_tlt_info 
        
      end module hmix_gm
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
