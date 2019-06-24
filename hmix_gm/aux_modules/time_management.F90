!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-22 12:03:12 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module time_management
!BOP
! !MODULE: time_management
! !DESCRIPTION:
!  This module contains a large number of routines for calendar, time
!  flags and other functions related to model time.
! !REVISION HISTORY:
!  SVN:$Id$
! !USES:


!
!

     USE domain_size 
     USE grid 
     USE io 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

     IMPLICIT NONE 
     PUBLIC 
     SAVE 
! !PUBLIC MEMBER FUNCTIONS:


! !PUBLIC DATA TYPES:


! !PUBLIC DATA MEMBERS:
!-----------------------------------------------------------------------
!  variables for run control
!-----------------------------------------------------------------------


!
!


                          !   OR date (yyyymmdd) at which model stops

                               !  half timesteps must exactly "fit"


                            !   selected to enforce strict pop2 alignment with coupling intervals.
                            !   Not true when using avg or avgbb, because the number of steps per
                            !   interval is non-uniform.


 
                              !  is close enough to seconds_in_year

!-----------------------------------------------------------------------
!     quantities related to date
!-----------------------------------------------------------------------

!
!


 


                                !      and initial start date
                                !                   this segment of run
                                !                   of this run
                                !       and initial start date
                                !                     this segment of run
                                !      and initial start date
                                !      this segment of run
 

        !   J  F  M    A  M  J   J  A  S     O  N  D

                               !         if leap years are allowed
 


 
 
   !*** for forcing calendar


!-----------------------------------------------------------------------
!  parameters for time frequency and start options
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!  user defined time flags
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!  time-step related constants and variables
!-----------------------------------------------------------------------

!
!


                          !   input; may be different from restart value

!-----------------------------------------------------------------------
!  time-centering and mixing variables
!-----------------------------------------------------------------------

!
!


                          !  back_to_back option to keep time boundaries
                          !  selecting the timestep size in such
                          !  a way as to force the end of the day
                          !  (or interval) to coincide with the end of 
                          !  a timestep


                             ! coriolis and  surface-pressure gradient
                             ! are not time centered
!----------------------------------------------------------------------
!  Robert Filter variables
!----------------------------------------------------------------------

!
!

                                                 ! Unstable. Use as sanity check only.


!-----------------------------------------------------------------------
!  variables documenting avgfit progression
!-----------------------------------------------------------------------

!
!


!-----------------------------------------------------------------------
!  variables to control output
!-----------------------------------------------------------------------

!
!

!EOP
!BOC
!-----------------------------------------------------------------------
!  a few private variables used only internally
!-----------------------------------------------------------------------

!
!


!EOC
!***********************************************************************


!***********************************************************************
!BOP
! !IROUTINE: init_time1
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: test_timestep
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: init_time2
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: time_manager
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: reset_switches
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: set_switches
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: init_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: access_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: set_num_time_flags
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: get_time_flag_id
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: search_time_flags
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: document_time_flags
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: document_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: override_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: reset_time_flags
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: reset_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: check_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: check_time_flag_int
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: eval_time_flags
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: eval_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: error_check_time_flag
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: time_to_do
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: time_to_start
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: model_date
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: get_tday
! !INTERFACE:
 


!***********************************************************************
!BOP
! !IROUTINE: ymd_hms
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: hms
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: reduce_months
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: reduce_seconds
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: leap_adjust
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: date2ymd
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: ymd2date
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: eday2ymd
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: ymd2eday
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: date2eday
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: eday2date
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: prior_days
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: time_stamp
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: ccsm_date_stamp
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: is_near
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: is_leapyear
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: valid_date
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: valid_ymd_hms()
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: write_time_manager_options
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: int_to_char
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: ccsm_char_date_and_time
! !INTERFACE:


!***********************************************************************
 

 end module time_management
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
