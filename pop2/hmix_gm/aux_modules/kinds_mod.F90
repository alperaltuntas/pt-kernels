!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-20 15:47:47 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module kinds_mod
!BOP
! !MODULE: kinds_mod
! !DESCRIPTION:
!  This module defines default numerical data types for all common data
!  types like integer, character, logical, real4 and real8.
! !REVISION HISTORY:
!  SVN:$Id$
! !USES:
!  uses no other modules
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

!
!


     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !DEFINED PARAMETERS:
   ! Note: we want char_len to be 256 and char_len_long to be 512 but this is
   !       a quick work-around because some of variables containing the name of
   !       restart files, history files, and other output files are set to
   !       char_len. A later update should change these to char_len_long and
   !       then reset char_len to its original 256 value. (MNL; 10 Aug 2015)


   integer, parameter, public ::               &
      char_len       = 384                    ,&
      char_len_long  = 512                    ,&
      log_kind       = kind(.true.)           ,&
      int_kind       = kind(1)                ,&
      i4             = selected_int_kind(6)   ,&
      i8             = selected_int_kind(13)  ,&
      r4             = selected_real_kind(6)  ,&
      r8             = selected_real_kind(13)

!EOP
!BOC
!EOC
!***********************************************************************


 end module kinds_mod
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
