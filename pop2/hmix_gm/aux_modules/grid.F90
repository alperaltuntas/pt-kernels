!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-22 12:03:12 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module grid
!BOP
! !MODULE: grid
! !DESCRIPTION:
!  This module contains grid info and routines for setting up the
!  POP grid quantities.
! !REVISION HISTORY:
!  SVN:$Id$
! !USES:

!
!


     USE pop_kindsmod 

     USE domain_size 
     USE io 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !PUBLIC MEMBER FUNCTIONS:


! !PUBLIC DATA MEMBERS:


   ! Default values used if l1Ddyn and lidentical_columns = .true.


                                                    ! (if lmin_Coriolis = .true.)

                       ! for use in computing KMT internally

                       ! for use in performing work distribution
!-----------------------------------------------------------------------
!  grid information for all local blocks
!  the local blocks are by default in baroclinic distribution
!-----------------------------------------------------------------------
   !*** dimension(1:km)

!
!


     REAL(KIND=pop_r8), dimension(km), public :: dz, zt 
   !*** dimension(0:km)


     REAL(KIND=pop_r8), dimension(0:km), public :: dzwr 
                         !   and its reciprocal
   !*** geometric 2d arrays


   !*** 3d depth fields for partial bottom cells


   !*** 2d landmasks


     INTEGER(KIND=pop_i4), dimension(nx_block,ny_block,max_blocks_clinic), public, target :: kmt 


                       ! allocated and computed in advection module


!-----------------------------------------------------------------------
!     define types used with region masks and marginal seas balancing
!-----------------------------------------------------------------------

!
!
 


!#################### temporary kludge for overflows ####################

!########################################################################
!EOP
!BOC
!-----------------------------------------------------------------------
!  module private data
!-----------------------------------------------------------------------
   !*** geometric scalars

!
!


                            ! in global-sized array
!-----------------------------------------------------------------------
!     area-weighted averaging coefficients
!     AT{0,S,W,SW} = {central,s,w,sw} coefficients for area-weighted
!       averaging of four U points surrounding a T point
!     AU{0,N,E,NE} = {central,n,e,ne} coefficients for area-weighted
!       averaging of four T points surrounding a U point
!-----------------------------------------------------------------------

!
!

!-----------------------------------------------------------------------
!  variables which are shared between init_grid1,init_grid2
!-----------------------------------------------------------------------

!
!

!EOC
!***********************************************************************
     PUBLIC kr_externs_in_grid 


!***********************************************************************
!BOP
! !IROUTINE: init_grid1
! !INTERFACE:
       
     CONTAINS 
       


!***********************************************************************
!BOP
! !IROUTINE: init_grid2
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: horiz_grid_internal
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: read_horiz_grid
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: vert_grid_internal
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: compute_dz
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: read_vert_grid
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: topography_bathymetry
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: topography_internal
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: read_topography
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: read_bottom_cell
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: remove_isolated_points
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: remove_points
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: smooth_topography
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: landmasks
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: area_masks
! !INTERFACE:


!***********************************************************************


!***********************************************************************
!BOP
! !IROUTINE: calc_tpoints
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: fill_points
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: ugrid_to_tgrid
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: tgrid_to_ugrid
! !INTERFACE:


!***********************************************************************


     !read state subroutine for kr_externs_in_grid 
     SUBROUTINE kr_externs_in_grid(kgen_unit) 
         INTEGER, INTENT(IN) :: kgen_unit 
         LOGICAL :: kgen_istrue 
         REAL(KIND=8) :: kgen_array_sum 
           
         READ (UNIT = kgen_unit) kgen_istrue 
         IF (kgen_istrue) THEN 
             READ (UNIT = kgen_unit) kgen_array_sum 
             READ (UNIT = kgen_unit) zt 
             CALL kgen_array_sumcheck("zt", kgen_array_sum, DBLE(SUM(zt, mask=(zt .eq. zt))), .TRUE.) 
         END IF   
         READ (UNIT = kgen_unit) kgen_istrue 
         IF (kgen_istrue) THEN 
             READ (UNIT = kgen_unit) kgen_array_sum 
             READ (UNIT = kgen_unit) dz 
             CALL kgen_array_sumcheck("dz", kgen_array_sum, DBLE(SUM(dz, mask=(dz .eq. dz))), .TRUE.) 
         END IF   
         READ (UNIT = kgen_unit) kgen_istrue 
         IF (kgen_istrue) THEN 
             READ (UNIT = kgen_unit) kgen_array_sum 
             READ (UNIT = kgen_unit) dzwr 
             CALL kgen_array_sumcheck("dzwr", kgen_array_sum, DBLE(SUM(dzwr, mask=(dzwr .eq. dzwr))), .TRUE.) 
         END IF   
         READ (UNIT = kgen_unit) kgen_istrue 
         IF (kgen_istrue) THEN 
             READ (UNIT = kgen_unit) kgen_array_sum 
             READ (UNIT = kgen_unit) kmt 
             CALL kgen_array_sumcheck("kmt", kgen_array_sum, DBLE(SUM(kmt, mask=(kmt .eq. kmt))), .TRUE.) 
         END IF   
     END SUBROUTINE kr_externs_in_grid 
       
 end module grid
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

