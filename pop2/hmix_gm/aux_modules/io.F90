!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-20 15:47:47 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module io
!BOP
! !MODULE: io
! !DESCRIPTION:
!  This module provides a generic parallel input/output interface
!  for writing arrays.
! !REVISION HISTORY:
!  SVN:$Id$
! !USES:

!
!


     USE blocks 
     USE constants 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

     IMPLICIT NONE 
     PUBLIC 
           ! module directly
     SAVE 
! !PUBLIC MEMBER FUNCTIONS:


!EOP
!BOC
!EOC
!***********************************************************************


!***********************************************************************
!BOP
! !IROUTINE: data_set
! !INTERFACE:


!***********************************************************************


 end module io
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
