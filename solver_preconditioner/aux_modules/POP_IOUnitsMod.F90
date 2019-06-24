!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-24 12:23:01 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module POP_IOUnitsMod
!BOP
! !MODULE:  POP_IOUnitsMod
! !DESCRIPTION:
!  This module contains an I/O unit manager for tracking, assigning
!  and reserving I/O unit numbers.
!  There are three reserved I/O units set as parameters in this
!  module.  The default units for standard input (stdin), standard
!  output (stdout) and standard error (stderr).  These are currently
!  set as units 5,6,6, respectively as that is the most commonly
!  used among vendors. However, the user may change these if those
!  default units are conflicting with other models or if the
!  vendor is using different values.
!  The maximum number of I/O units per node is currently set by
!  the parameter POP\_IOMaxUnits.
! !REFDOC:
! !REVISION HISTORY:
!  SVN:$Id: POP_IOUnitsMod.F90 90652 2019-02-26 21:07:52Z mvertens $
!  2006-08-21: Phil Jones
!     added wrapper for system flush routine
!  2006-08-15: Phil Jones
!     fixed problem in case construct for duplicate unit numbers
!     stripped DOS line feed-CR stuff
!  2006-07-05: Phil Jones
!     added new IO unit manager to follow new naming conventions
!         and check to see if unit assigned by another component
!         if POP is being called as subroutine in a coupled context
! !USES:

!
!
!
!
!
!


     USE pop_kindsmod 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !PUBLIC MEMBER FUNCTIONS:


! !PUBLIC DATA MEMBERS:


     INTEGER(KIND=pop_i4), public :: pop_stdout =   6 
   ! common formats for writing to stdout, stderr


   ! instance control

!EOP
!BOC
!-----------------------------------------------------------------------
!  private io unit manager variables
!-----------------------------------------------------------------------

!
!


!EOC
!***********************************************************************
     PUBLIC kr_externs_in_pop_iounitsmod 


!***********************************************************************
!BOP
! !IROUTINE: POP_IOUnitsGet
! !INTERFACE:
       
     CONTAINS 
       


!***********************************************************************
!BOP
! !IROUTINE: POP_IOUnitsRelease
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: POP_IOUnitsReserve
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: POP_IOUnitsRedirect
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: POP_IOUnitsFlush
! !INTERFACE:


!***********************************************************************


     !read state subroutine for kr_externs_in_pop_iounitsmod 
     SUBROUTINE kr_externs_in_pop_iounitsmod(kgen_unit) 
         INTEGER, INTENT(IN) :: kgen_unit 
         LOGICAL :: kgen_istrue 
         REAL(KIND=8) :: kgen_array_sum 
           
         READ (UNIT = kgen_unit) pop_stdout 
     END SUBROUTINE kr_externs_in_pop_iounitsmod 
       
 end module POP_IOUnitsMod
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
