!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-20 15:47:47 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module domain_size
!BOP
! !MODULE: domain_size
! !DESCRIPTION:
!  This module contains parameters for the global model domain size
!  decomposition block size.  It is used by the domain and block
!  modules for decomposing the model domain across processors.
! !REVISION HISTORY:
!  SVN:$Id$
! !USES:

!
!


     USE kinds_mod 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !DEFINED PARAMETERS:


   integer (int_kind), parameter, public ::  &  ! model size parameters
      nx_global =  320 ,&! extent of horizontal axis in i direction
      ny_global =  384 ,&! extent of horizontal axis in j direction
      km = 60          ,&! number of vertical levels
      nt = 3            ! total number of tracers

   integer (int_kind), parameter, public :: &
      block_size_x = 27, &! size of block in 1st horizontal dimension
      block_size_y = 32   ! size of block in 2nd horizontal dimension
   !*** The model will inform the user of the correct
   !*** values for theparameters below.  A value higher than
   !*** necessary will not cause the code to fail, but will
   !*** allocate more memory than is necessary.  A value that
   !*** is too low will cause the code to exit.  
   !*** A good initial guess is found using
   !*** max=(nx_global/block_size_x)*(ny_global/block_size_y)/
   !***         num_procs

 
   integer (int_kind), parameter, public :: &
      max_blocks_clinic = 1,  &! max number of blocks per processor
      max_blocks_tropic = 1    !   in each distribution
!EOP
!BOC
!EOC
!***********************************************************************


 end module domain_size
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
