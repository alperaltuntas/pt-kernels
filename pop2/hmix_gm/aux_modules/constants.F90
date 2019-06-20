!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-20 15:47:47 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module constants
!BOP
! !MODULE: constants
! !DESCRIPTION:
!  This module defines a variety of physical and numerical constants
!  used throughout the Parallel Ocean Program.
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
! !PUBLIC MEMBER FUNCTIONS:


! !DEFINED PARAMETERS:
   ! numbers


   real (r8), parameter, public :: &
      c0     =    0.0_r8   ,&
      c1     =    1.0_r8   ,&
      c2     =    2.0_r8   ,&
      c3     =    3.0_r8   ,&
      c4     =    4.0_r8   ,&
      c5     =    5.0_r8   ,&
      c8     =    8.0_r8   ,&
      c10    =   10.0_r8   ,&
      c16    =   16.0_r8   ,&
      c1000  = 1000.0_r8   ,&
      c10000 =10000.0_r8   ,&
      c1p5   =    1.5_r8   ,&
      p33    = c1/c3       ,&
      p5     = 0.500_r8    ,&
      p25    = 0.250_r8    ,&
      p125   = 0.125_r8    ,&
      p001   = 0.001_r8    ,&
      eps    = 1.0e-10_r8  ,&
      eps2   = 1.0e-20_r8  ,&
      bignum = 1.0e+30_r8


   !*** location of fields for staggered grids


   !*** field type attribute - necessary for handling
   !*** changes of direction across tripole boundary


   !  common formats for formatted output


  ! common model doi url for all tavg outputs

  !---------------------------------------------------------------------
  !     Gas exchange/piston velocity parameter
  !---------------------------------------------------------------------


!  !PUBLIC DATA MEMBERS:


   ! physical constants
   ! note that most internal ocean constants are in cgs units
   !  while atmosphere and surface flux constants are sometimes
   !  in MKS units
   ! these constants are defined in an init routine to allow
   !  CSM shared constants to over-ride


   !  conversion factors


!EOP
!BOC
!EOC
!***********************************************************************


!***********************************************************************
!BOP
! !IROUTINE: init_constants
! !INTERFACE:


!***********************************************************************


 end module constants
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
