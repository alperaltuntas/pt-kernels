!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-24 12:23:01 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module POP_KindsMod
!BOP
! !MODULE: POP_KindsMod
! !DESCRIPTION:
!  This module defines default numerical data types for all common data
!  types like integer, character, logical, real4 and real8.
! !USERDOC:
!  Users should not need to adjust anything in this module.  If various
!  character strings like long paths to files exceed the default
!  character length, the default value may be increased.
! !REFDOC:
!  This module is supplied to provide consistent data representation
!  across machine architectures.  It is meant to replace the old
!  Fortran double precision and real *X declarations that were
!  implementation-specific.
!  Users should not need to adjust anything in this module.  If various
!  character strings like long paths to files exceed the default
!  character length, the default value may be increased.
! !REVISION HISTORY:
!  SVN:$Id: POP_KindsMod.F90 76178 2016-01-12 04:50:32Z mlevy@ucar.edu $
! !USES:
!  uses no other modules
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

!
!
!
!


     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !DEFINED PARAMETERS:
   ! Note: we want POP_CharLength to be 256 and POP_CharLengthLong to be 512
   !       but this is a quick work-around because some of variables containing
   !       the name of restart files, history files, and other output files are
   !       set to POP_CharLength. A later update should change these to the
   !       newly introduced POP_CharLengthLong and then reset POP_CharLength
   !       to its original 256 value. (MNL; 10 Aug 2015)


   integer, parameter, public ::                   &
      POP_CharLength     = 384                    ,&
      POP_CharLengthLong = 512                    ,&
      POP_Logical        = kind(.true.)           ,&
      POP_i4             = selected_int_kind(6)   ,&
      POP_i8             = selected_int_kind(13)  ,&
      POP_r4             = selected_real_kind(6)  ,&
      POP_r8             = selected_real_kind(13) ,&
      POP_r16            = selected_real_kind(26)
   ! Note: we need to hard-code these sizes for NAG compiler; no sizeof()
   !       intrinsic is present, and the kind number != size (as it is for
   !       intel, pgi, and gnu compilers)


!EOP
!BOC
!EOC
!***********************************************************************


 end module POP_KindsMod
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
