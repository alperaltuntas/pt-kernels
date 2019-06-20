!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-20 15:47:47 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module hmix_gm_submeso_share 
!BOP
! !MODULE: hmix_gm_submeso_share 
! !DESCRIPTION:
!  This module contains routines for computing tracer and density differences for
!  use in the hmix_gm and mix_submeso routines. In addition, isopycnal slopes are
!  computed if necessary.
! !REVISION HISTORY:
!  SVN:$Id: hmix_gm_submeso_share.F90
! !USES:


     USE kinds_mod 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !PUBLIC MEMBER FUNCTIONS:


!-----------------------------------------------------------------------
!  variables to save from one call to next
!-----------------------------------------------------------------------

!
!

   real (r8), dimension(:,:,:,:,:,:), allocatable, public :: &
      SLX, SLY                ! slope of isopycnal sfcs in x,y-direction
!***********************************************************************
   PUBLIC kr_externs_in_hmix_gm_submeso_share 


!***********************************************************************
! !IROUTINE: init_meso_mixing
! !INTERFACE:
     
   CONTAINS 
     


!-----------------------------------------------------------------------
! !IROUTINE: tracer_diffs_and_isopyc_slopes
! !INTERFACE:


!***********************************************************************
!


   !read state subroutine for kr_externs_in_hmix_gm_submeso_share 
   SUBROUTINE kr_externs_in_hmix_gm_submeso_share(kgen_unit) 
       INTEGER, INTENT(IN) :: kgen_unit 
       LOGICAL :: kgen_istrue 
       REAL(KIND=8) :: kgen_array_sum 
         
       CALL kr_hmix_gm_submeso_share_real__r8_dim6(slx, kgen_unit, "slx", .FALSE.) 
       CALL kr_hmix_gm_submeso_share_real__r8_dim6(sly, kgen_unit, "sly", .FALSE.) 
   END SUBROUTINE kr_externs_in_hmix_gm_submeso_share 
     
   !read state subroutine for kr_hmix_gm_submeso_share_real__r8_dim6 
   SUBROUTINE kr_hmix_gm_submeso_share_real__r8_dim6(var, kgen_unit, printname, printvar) 
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
   END SUBROUTINE kr_hmix_gm_submeso_share_real__r8_dim6 
     
 end module hmix_gm_submeso_share
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
