!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-22 12:03:11 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module blocks
!BOP
! !MODULE: blocks
! !DESCRIPTION: 
!  This module contains data types and tools for decomposing a global
!  horizontal domain into a set of blocks.  It contains a data type 
!  for describing each block and contains routines for creating and 
!  querying the block decomposition for a global domain.
! !REVISION HISTORY:
!  SVN:$Id$
! !USES:

!
!
!

     USE kinds_mod 
     USE domain_size, ONLY: block_size_x, block_size_y 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
     USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_tolerance, kgen_minvalue, kgen_verboselevel, CHECK_IDENTICAL, &
     &CHECK_IN_TOL, CHECK_OUT_TOL 

     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !PUBLIC TYPES:


   type, public :: block   ! block data type
      integer (int_kind) :: &
         block_id          ,&! global block number
         local_id          ,&! local address of block in current distrib
         ib, ie, jb, je    ,&! begin,end indices for physical domain
         iblock, jblock      ! cartesian i,j position for bloc

      integer (int_kind), dimension(:), pointer :: &
         i_glob, j_glob     ! global domain location for each point
   end type
! !PUBLIC MEMBER FUNCTIONS:


! !DEFINED PARAMETERS:


   integer (int_kind), parameter, public :: &
      nghost = 2       ! number of ghost cells around each block

   integer (int_kind), parameter, public :: &! size of block domain in
      nx_block = block_size_x + 2*nghost,   &!  x,y dir including ghost
      ny_block = block_size_y + 2*nghost     !  cells 
! !PUBLIC DATA MEMBERS:


!EOP
!BOC
!-----------------------------------------------------------------------
!  module private data
!-----------------------------------------------------------------------

!
!


!EOC
!***********************************************************************
   PUBLIC kr_blocks_block 
   PUBLIC kv_blocks_block 


!***********************************************************************
!BOP
! !IROUTINE: create_blocks
! !INTERFACE:
     
   CONTAINS 
     


!***********************************************************************
!BOP
! !IROUTINE: get_block
! !INTERFACE:


!**********************************************************************
!BOP
! !IROUTINE: get_block_parameter
! !INTERFACE:


!**********************************************************************
!BOP
! !IROUTINE: destroy_blocks
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: get_block_ids_from_coords
! !INTERFACE:


!***********************************************************************


   !read state subroutine for kr_blocks_block 
   RECURSIVE SUBROUTINE kr_blocks_block(var, kgen_unit, printname, printvar) 
       TYPE(block), INTENT(INOUT) :: var 
       INTEGER, INTENT(IN) :: kgen_unit 
       CHARACTER(LEN=*), INTENT(IN) :: printname 
       LOGICAL, INTENT(IN), OPTIONAL :: printvar 
       LOGICAL :: kgen_istrue 
       REAL(KIND=8) :: kgen_array_sum 
         
       READ (UNIT = kgen_unit) var%block_id 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%block_id = ", var%block_id 
       END IF   
       READ (UNIT = kgen_unit) var%local_id 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%local_id = ", var%local_id 
       END IF   
       READ (UNIT = kgen_unit) var%ib 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%ib = ", var%ib 
       END IF   
       READ (UNIT = kgen_unit) var%ie 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%ie = ", var%ie 
       END IF   
       READ (UNIT = kgen_unit) var%jb 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%jb = ", var%jb 
       END IF   
       READ (UNIT = kgen_unit) var%je 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%je = ", var%je 
       END IF   
       READ (UNIT = kgen_unit) var%iblock 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%iblock = ", var%iblock 
       END IF   
       READ (UNIT = kgen_unit) var%jblock 
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           WRITE (*, *) "KGEN DEBUG: " // printname // "%jblock = ", var%jblock 
       END IF   
         
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           CALL kr_block_integer__int_kind_dim1_ptr(var%i_glob, kgen_unit, printname // "%i_glob", .TRUE.) 
       ELSE 
           CALL kr_block_integer__int_kind_dim1_ptr(var%i_glob, kgen_unit, printname // "%i_glob", .FALSE.) 
       END IF   
       IF (PRESENT( printvar ) .AND. printvar) THEN 
           CALL kr_block_integer__int_kind_dim1_ptr(var%j_glob, kgen_unit, printname // "%j_glob", .TRUE.) 
       ELSE 
           CALL kr_block_integer__int_kind_dim1_ptr(var%j_glob, kgen_unit, printname // "%j_glob", .FALSE.) 
       END IF   
         
   END SUBROUTINE kr_blocks_block 
     
   !write state subroutine for kr_block_integer__int_kind_dim1_ptr 
   SUBROUTINE kr_block_integer__int_kind_dim1_ptr(var, kgen_unit, printname, printvar) 
       INTEGER(KIND=int_kind), INTENT(INOUT), POINTER, DIMENSION(:) :: var 
       INTEGER, INTENT(IN) :: kgen_unit 
       CHARACTER(LEN=*), INTENT(IN) :: printname 
       LOGICAL, INTENT(IN), OPTIONAL :: printvar 
       LOGICAL :: kgen_istrue 
       REAL(KIND=8) :: kgen_array_sum 
       INTEGER :: idx1 
       INTEGER, DIMENSION(2,1) :: kgen_bound 
         
       READ (UNIT = kgen_unit) kgen_istrue 
       IF (kgen_istrue) THEN 
           IF (ASSOCIATED( var )) THEN 
               NULLIFY (var) 
           END IF   
           READ (UNIT = kgen_unit) kgen_array_sum 
           READ (UNIT = kgen_unit) kgen_bound(1, 1) 
           READ (UNIT = kgen_unit) kgen_bound(2, 1) 
           ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1))) 
           READ (UNIT = kgen_unit) var 
           CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
           IF (PRESENT( printvar ) .AND. printvar) THEN 
               WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
           END IF   
       END IF   
         
   END SUBROUTINE kr_block_integer__int_kind_dim1_ptr 
     
   !verify state subroutine for kv_blocks_block 
   RECURSIVE SUBROUTINE kv_blocks_block(varname, check_status, var, kgenref_var) 
       CHARACTER(LEN=*), INTENT(IN) :: varname 
       TYPE(check_t), INTENT(INOUT) :: check_status 
       TYPE(block), INTENT(IN) :: var, kgenref_var 
       TYPE(check_t) :: dtype_check_status, comp_check_status 
       INTEGER :: check_result 
       LOGICAL :: is_print = .FALSE. 
         
       integer(KIND=int_kind) :: diff_block_id 
       integer(KIND=int_kind) :: diff_local_id 
       integer(KIND=int_kind) :: diff_ib 
       integer(KIND=int_kind) :: diff_ie 
       integer(KIND=int_kind) :: diff_jb 
       integer(KIND=int_kind) :: diff_je 
       integer(KIND=int_kind) :: diff_iblock 
       integer(KIND=int_kind) :: diff_jblock 
       INTEGER :: n_i_glob 
       integer(KIND=int_kind) :: nrmsdiff_i_glob, rmsdiff_i_glob 
       integer(KIND=int_kind), ALLOCATABLE :: buf1_i_glob(:), buf2_i_glob(:) 
       INTEGER :: n_j_glob 
       integer(KIND=int_kind) :: nrmsdiff_j_glob, rmsdiff_j_glob 
       integer(KIND=int_kind), ALLOCATABLE :: buf1_j_glob(:), buf2_j_glob(:) 
         
       check_status%numTotal = check_status%numTotal + 1 
         
       CALL kgen_init_check(dtype_check_status, rank=check_status%rank) 
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%block_id == kgenref_var%block_id) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%block_id is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_block_id = ABS(var%block_id - kgenref_var%block_id) 
           IF (diff_block_id <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%block_id is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%block_id is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_block_id 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_block_id 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%local_id == kgenref_var%local_id) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%local_id is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_local_id = ABS(var%local_id - kgenref_var%local_id) 
           IF (diff_local_id <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%local_id is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%local_id is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_local_id 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_local_id 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%ib == kgenref_var%ib) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%ib is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_ib = ABS(var%ib - kgenref_var%ib) 
           IF (diff_ib <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%ib is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%ib is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_ib 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_ib 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%ie == kgenref_var%ie) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%ie is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_ie = ABS(var%ie - kgenref_var%ie) 
           IF (diff_ie <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%ie is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%ie is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_ie 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_ie 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%jb == kgenref_var%jb) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%jb is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_jb = ABS(var%jb - kgenref_var%jb) 
           IF (diff_jb <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%jb is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%jb is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_jb 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_jb 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%je == kgenref_var%je) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%je is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_je = ABS(var%je - kgenref_var%je) 
           IF (diff_je <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%je is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%je is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_je 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_je 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%iblock == kgenref_var%iblock) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%iblock is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_iblock = ABS(var%iblock - kgenref_var%iblock) 
           IF (diff_iblock <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%iblock is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%iblock is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_iblock 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_iblock 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
       dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
       IF (var%jblock == kgenref_var%jblock) THEN 
           dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank == 0) THEN 
                   WRITE (*, *) trim(adjustl(varname)), "%jblock is IDENTICAL." 
               END IF   
           END IF   
           check_result = CHECK_IDENTICAL 
       ELSE 
           diff_jblock = ABS(var%jblock - kgenref_var%jblock) 
           IF (diff_jblock <= kgen_tolerance) THEN 
               dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%jblock is NOT IDENTICAL(within tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_IN_TOL 
           ELSE 
               dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
               IF (kgen_verboseLevel > 1) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%jblock is NOT IDENTICAL(out of tolerance)." 
                   END IF   
               END IF   
               check_result = CHECK_OUT_TOL 
           END IF   
       END IF   
       IF (check_result == CHECK_IDENTICAL) THEN 
           CONTINUE 
       ELSE IF (check_result == CHECK_OUT_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_jblock 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       ELSE IF (check_result == CHECK_IN_TOL) THEN 
           IF (kgen_verboseLevel > 2) THEN 
               IF (check_status%rank ==0) THEN 
                   WRITE (*, *) "Difference is ", diff_jblock 
                   WRITE (*, *) "" 
               END IF   
           END IF   
       END IF   
         
       IF (ASSOCIATED(var%i_glob)) THEN 
           dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
           IF (ALL(var%i_glob == kgenref_var%i_glob)) THEN 
               dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
               IF (kgen_verboseLevel > 2) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%i_glob is IDENTICAL." 
                   END IF   
               END IF   
               check_result = CHECK_IDENTICAL 
           ELSE 
               ALLOCATE (buf1_i_glob(SIZE(var%i_glob,dim=1))) 
               ALLOCATE (buf2_i_glob(SIZE(var%i_glob,dim=1))) 
               n_i_glob = COUNT(var%i_glob /= kgenref_var%i_glob) 
               WHERE ( ABS(kgenref_var%i_glob) > kgen_minvalue ) 
                   buf1_i_glob = ((var%i_glob-kgenref_var%i_glob)/kgenref_var%i_glob)**2 
                   buf2_i_glob = (var%i_glob-kgenref_var%i_glob)**2 
               ELSEWHERE 
                   buf1_i_glob = (var%i_glob-kgenref_var%i_glob)**2 
                   buf2_i_glob = buf1_i_glob 
               END WHERE   
               nrmsdiff_i_glob = SQRT(SUM(buf1_i_glob)/REAL(n_i_glob)) 
               rmsdiff_i_glob = SQRT(SUM(buf2_i_glob)/REAL(n_i_glob)) 
               IF (rmsdiff_i_glob > kgen_tolerance) THEN 
                   dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                   IF (kgen_verboseLevel > 1) THEN 
                       IF (check_status%rank == 0) THEN 
                           WRITE (*, *) trim(adjustl(varname)), "%i_glob is NOT IDENTICAL(out of tolerance)." 
                       END IF   
                   END IF   
                   check_result = CHECK_OUT_TOL 
               ELSE 
                   dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                   IF (kgen_verboseLevel > 1) THEN 
                       IF (check_status%rank == 0) THEN 
                           WRITE (*, *) trim(adjustl(varname)), "%i_glob is NOT IDENTICAL(within tolerance)." 
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
                       WRITE (*, *) count( var%i_glob /= kgenref_var%i_glob), " of ", size( var%i_glob ), " elements are &
                       &different." 
                       WRITE (*, *) "Average - kernel ", sum(var%i_glob)/real(size(var%i_glob)) 
                       WRITE (*, *) "Average - reference ", sum(kgenref_var%i_glob)/real(size(kgenref_var%i_glob)) 
                       WRITE (*, *) "RMS of difference is ", rmsdiff_i_glob 
                       WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_i_glob 
                       WRITE (*, *) "" 
                   END IF   
               END IF   
           ELSE IF (check_result == CHECK_IN_TOL) THEN 
               IF (kgen_verboseLevel > 2) THEN 
                   IF (check_status%rank ==0) THEN 
                       WRITE (*, *) count( var%i_glob /= kgenref_var%i_glob), " of ", size( var%i_glob ), " elements are &
                       &different." 
                       WRITE (*, *) "Average - kernel ", sum(var%i_glob)/real(size(var%i_glob)) 
                       WRITE (*, *) "Average - reference ", sum(kgenref_var%i_glob)/real(size(kgenref_var%i_glob)) 
                       WRITE (*, *) "RMS of difference is ", rmsdiff_i_glob 
                       WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_i_glob 
                       WRITE (*, *) "" 
                   END IF   
               END IF   
           END IF   
       END IF   
       IF (ASSOCIATED(var%j_glob)) THEN 
           dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
           IF (ALL(var%j_glob == kgenref_var%j_glob)) THEN 
               dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
               IF (kgen_verboseLevel > 2) THEN 
                   IF (check_status%rank == 0) THEN 
                       WRITE (*, *) trim(adjustl(varname)), "%j_glob is IDENTICAL." 
                   END IF   
               END IF   
               check_result = CHECK_IDENTICAL 
           ELSE 
               ALLOCATE (buf1_j_glob(SIZE(var%j_glob,dim=1))) 
               ALLOCATE (buf2_j_glob(SIZE(var%j_glob,dim=1))) 
               n_j_glob = COUNT(var%j_glob /= kgenref_var%j_glob) 
               WHERE ( ABS(kgenref_var%j_glob) > kgen_minvalue ) 
                   buf1_j_glob = ((var%j_glob-kgenref_var%j_glob)/kgenref_var%j_glob)**2 
                   buf2_j_glob = (var%j_glob-kgenref_var%j_glob)**2 
               ELSEWHERE 
                   buf1_j_glob = (var%j_glob-kgenref_var%j_glob)**2 
                   buf2_j_glob = buf1_j_glob 
               END WHERE   
               nrmsdiff_j_glob = SQRT(SUM(buf1_j_glob)/REAL(n_j_glob)) 
               rmsdiff_j_glob = SQRT(SUM(buf2_j_glob)/REAL(n_j_glob)) 
               IF (rmsdiff_j_glob > kgen_tolerance) THEN 
                   dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                   IF (kgen_verboseLevel > 1) THEN 
                       IF (check_status%rank == 0) THEN 
                           WRITE (*, *) trim(adjustl(varname)), "%j_glob is NOT IDENTICAL(out of tolerance)." 
                       END IF   
                   END IF   
                   check_result = CHECK_OUT_TOL 
               ELSE 
                   dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                   IF (kgen_verboseLevel > 1) THEN 
                       IF (check_status%rank == 0) THEN 
                           WRITE (*, *) trim(adjustl(varname)), "%j_glob is NOT IDENTICAL(within tolerance)." 
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
                       WRITE (*, *) count( var%j_glob /= kgenref_var%j_glob), " of ", size( var%j_glob ), " elements are &
                       &different." 
                       WRITE (*, *) "Average - kernel ", sum(var%j_glob)/real(size(var%j_glob)) 
                       WRITE (*, *) "Average - reference ", sum(kgenref_var%j_glob)/real(size(kgenref_var%j_glob)) 
                       WRITE (*, *) "RMS of difference is ", rmsdiff_j_glob 
                       WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_j_glob 
                       WRITE (*, *) "" 
                   END IF   
               END IF   
           ELSE IF (check_result == CHECK_IN_TOL) THEN 
               IF (kgen_verboseLevel > 2) THEN 
                   IF (check_status%rank ==0) THEN 
                       WRITE (*, *) count( var%j_glob /= kgenref_var%j_glob), " of ", size( var%j_glob ), " elements are &
                       &different." 
                       WRITE (*, *) "Average - kernel ", sum(var%j_glob)/real(size(var%j_glob)) 
                       WRITE (*, *) "Average - reference ", sum(kgenref_var%j_glob)/real(size(kgenref_var%j_glob)) 
                       WRITE (*, *) "RMS of difference is ", rmsdiff_j_glob 
                       WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_j_glob 
                       WRITE (*, *) "" 
                   END IF   
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
   END SUBROUTINE kv_blocks_block 
     
 end module blocks
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
