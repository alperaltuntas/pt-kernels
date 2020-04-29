!KGEN-generated Fortran source file 
  
!Generated at : 2020-04-29 13:46:47 
!KGEN version : 0.8.1 
  


module funarc_mod
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
    IMPLICIT NONE 
  integer, parameter :: ITERS = 10
  PUBLIC funarc_wrapper 

contains

SUBROUTINE funarc_wrapper(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath) 
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE kgen_utils_mod, ONLY: kgen_perturb_real 
    USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_init_verify, kgen_tolerance, kgen_minvalue, kgen_verboselevel, &
    &CHECK_IDENTICAL, CHECK_IN_TOL, CHECK_OUT_TOL 
    REAL(KIND=10) :: s1 
!$kgen callsite funarc_call
    INTEGER, INTENT(IN) :: kgen_unit 
    REAL(KIND=kgen_dp), INTENT(OUT) :: kgen_measure 
    LOGICAL, INTENT(OUT) :: kgen_isverified 
    CHARACTER(LEN=*), INTENT(IN) :: kgen_filepath 
    LOGICAL :: kgen_istrue 
    REAL(KIND=8) :: kgen_array_sum 
    INTEGER :: kgen_intvar, kgen_ierr 
    INTEGER :: kgen_mpirank, kgen_openmptid, kgen_kernelinvoke 
    LOGICAL :: kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    COMMON / state / kgen_mpirank, kgen_openmptid, kgen_kernelinvoke, kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    INTEGER, PARAMETER :: KGEN_MAXITER = 1 
      
    TYPE(check_t) :: check_status 
    INTEGER*8 :: kgen_start_clock, kgen_stop_clock, kgen_rate_clock 
    REAL(KIND=kgen_dp) :: gkgen_measure 
    REAL(KIND=10) :: kgenref_s1 
      
    !parent block preprocessing 
    kgen_mpirank = 0 
      
    !local input variables 
    READ (UNIT = kgen_unit) s1 
      
    !extern output variables 
      
    !local output variables 
    READ (UNIT = kgen_unit) kgenref_s1 
    IF (kgen_evalstage) THEN 
    END IF   
    IF (kgen_warmupstage) THEN 
    END IF   
    IF (kgen_mainstage) THEN 
    END IF   
      
    !Uncomment following call statement to turn on perturbation experiment. 
    !Adjust perturbation value and/or kind parameter if required. 
    !CALL kgen_perturb_real( your_variable, 1.0E-15_8 ) 
      
      
    !call to kgen kernel 
  s1 = funarc()
  IF (kgen_mainstage) THEN 
        
      !verify init 
      CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=1) 
      CALL kgen_init_check(check_status, rank=kgen_mpirank) 
        
      !extern verify variables 
        
      !local verify variables 
      CALL kv_funarc_wrapper_real__10("s1", check_status, s1, kgenref_s1) 
      IF (check_status%rank == 0) THEN 
          WRITE (*, *) "" 
      END IF   
      IF (kgen_verboseLevel > 0) THEN 
          IF (check_status%rank == 0) THEN 
              WRITE (*, *) "Number of output variables: ", check_status%numTotal 
              WRITE (*, *) "Number of identical variables: ", check_status%numIdentical 
              WRITE (*, *) "Number of non-identical variables within tolerance: ", check_status%numInTol 
              WRITE (*, *) "Number of non-identical variables out of tolerance: ", check_status%numOutTol 
              WRITE (*, *) "Tolerance: ", kgen_tolerance 
          END IF   
      END IF   
      IF (check_status%rank == 0) THEN 
          WRITE (*, *) "" 
      END IF   
      IF (check_status%numOutTol > 0) THEN 
          IF (check_status%rank == 0) THEN 
              WRITE (*, *) "Verification FAILED with" // TRIM(ADJUSTL(kgen_filepath)) 
          END IF   
          check_status%Passed = .FALSE. 
          kgen_isverified = .FALSE. 
      ELSE 
          IF (check_status%rank == 0) THEN 
              WRITE (*, *) "Verification PASSED with " // TRIM(ADJUSTL(kgen_filepath)) 
          END IF   
          check_status%Passed = .TRUE. 
          kgen_isverified = .TRUE. 
      END IF   
      IF (check_status%rank == 0) THEN 
          WRITE (*, *) "" 
      END IF   
      CALL SYSTEM_CLOCK(kgen_start_clock, kgen_rate_clock) 
      DO kgen_intvar = 1, KGEN_MAXITER 
  s1 = funarc()
      END DO   
      CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
      kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
      IF (check_status%rank==0) THEN 
          WRITE (*, *) "funarc_call : Time per call (usec): ", kgen_measure 
      END IF   
  END IF   
  IF (kgen_warmupstage) THEN 
  END IF   
  IF (kgen_evalstage) THEN 
  END IF   
!$kgen end callsite
    
  CONTAINS 
    
  !verify state subroutine for kv_funarc_wrapper_real__10 
  RECURSIVE SUBROUTINE kv_funarc_wrapper_real__10(varname, check_status, var, kgenref_var) 
      CHARACTER(LEN=*), INTENT(IN) :: varname 
      TYPE(check_t), INTENT(INOUT) :: check_status 
      REAL(KIND=10), INTENT(IN) :: var, kgenref_var 
      INTEGER :: check_result 
      LOGICAL :: is_print = .FALSE. 
        
      real(KIND=10) :: diff 
        
      check_status%numTotal = check_status%numTotal + 1 
        
      IF (var == kgenref_var) THEN 
          check_status%numIdentical = check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 1) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), " is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff = ABS(var - kgenref_var) 
          IF (diff <= kgen_tolerance) THEN 
              check_status%numInTol = check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              check_status%numOutTol = check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 0) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(out of tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_OUT_TOL 
          END IF   
      END IF   
      IF (check_result == CHECK_IDENTICAL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) "Difference is ", 0 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_OUT_TOL) THEN 
          IF (kgen_verboseLevel > 0) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) "Difference is ", diff 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 1) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) "Difference is ", diff 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
  END SUBROUTINE kv_funarc_wrapper_real__10 
    
END SUBROUTINE funarc_wrapper 

function funarc() result(s1)

  real(kind=8) :: diff
  integer :: l

  integer :: i, j, k, n
  real(kind=10) :: h, t1, t2, dppi
  real(kind=10) :: s1

  n = 1000000

  print *, "begin"
  do l=1,ITERS
    t1 = -1.0
    dppi = acos(t1)
    s1 = 0.0;
    t1 = 0.0
    h = dppi / n

    do i=1,n
      t2 = fun(i*h) 
      s1 = s1 + sqrt (h*h + (t2 - t1)*(t2 - t1))
      t1 = t2
    enddo
  enddo

  print *, "s1: ", s1

end function funarc

function fun(x) result(t1)
  real(kind=10), intent(in) :: x
  !local
  integer       :: k, n
  real(kind=10)  :: t1, d1

  n=5
  d1 = 1.0

  t1 = x
  do k=1,n
    d1 = 2.0 * d1
    t1 = t1 + sin (d1 * x) / d1
  end do

end function fun

end module funarc_mod