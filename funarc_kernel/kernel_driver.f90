    !KGEN-generated Fortran source file 
      
    !Generated at : 2020-04-29 13:46:47 
    !KGEN version : 0.8.1 
      
    PROGRAM kernel_driver 
        USE kgen_utils_mod, ONLY: kgen_get_newunit, kgen_error_stop, kgen_dp, kgen_array_sumcheck, kgen_rankthreadinvoke 
        USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
        USE funarc_mod, ONLY: funarc_wrapper 
          
        IMPLICIT NONE 
          
        LOGICAL :: kgen_isverified 
        INTEGER :: kgen_ierr_list, kgen_unit_list 
        INTEGER :: kgen_ierr, kgen_unit, kgen_case_count, kgen_count_verified 
        CHARACTER(LEN=1024) :: kgen_filepath 
        REAL(KIND=kgen_dp) :: kgen_measure, kgen_total_time, kgen_min_time, kgen_max_time 
        REAL(KIND=8) :: kgen_array_sum 
        INTEGER :: kgen_mpirank, kgen_openmptid, kgen_kernelinvoke 
        INTEGER :: myrank, mpisize 
        LOGICAL :: kgen_evalstage, kgen_warmupstage, kgen_mainstage 
        COMMON / state / kgen_mpirank, kgen_openmptid, kgen_kernelinvoke, kgen_evalstage, kgen_warmupstage, kgen_mainstage 
          
        myrank = 0 
        mpisize = 1 
        kgen_total_time = 0.0_kgen_dp 
        kgen_min_time = HUGE(0.0_kgen_dp) 
        kgen_max_time = 0.0_kgen_dp 
        kgen_case_count = 0 
        kgen_count_verified = 0 
          
        kgen_unit_list = kgen_get_newunit() 
        OPEN (UNIT=kgen_unit_list, FILE="kgen_statefile.lst", STATUS="OLD", IOSTAT=kgen_ierr_list) 
        IF (kgen_ierr_list .NE. 0) THEN 
            CALL SYSTEM("ls -1 funarc_call.*.*.* > kgen_statefile.lst") 
            CALL SLEEP(1) 
            kgen_unit_list = kgen_get_newunit() 
            OPEN (UNIT=kgen_unit_list, FILE="kgen_statefile.lst", STATUS="OLD", IOSTAT=kgen_ierr_list) 
        END IF   
        IF (kgen_ierr_list .NE. 0) THEN 
            IF (myrank == 0) THEN 
                WRITE (*, *) "" 
                WRITE (*, *) "ERROR: ""kgen_statefile.lst"" is not found in current directory." 
            END IF   
            STOP 
        END IF   
        DO WHILE ( kgen_ierr_list .EQ. 0 ) 
            READ (UNIT = kgen_unit_list, FMT="(A)", IOSTAT=kgen_ierr_list) kgen_filepath 
            IF (kgen_ierr_list .EQ. 0) THEN 
                kgen_unit = kgen_get_newunit() 
                CALL kgen_rankthreadinvoke(TRIM(ADJUSTL(kgen_filepath)), kgen_mpirank, kgen_openmptid, kgen_kernelinvoke) 
                OPEN (UNIT=kgen_unit, FILE=TRIM(ADJUSTL(kgen_filepath)), STATUS="OLD", ACCESS="STREAM", FORM="UNFORMATTED", &
                &ACTION="READ", CONVERT="BIG_ENDIAN", IOSTAT=kgen_ierr) 
                IF (kgen_ierr == 0) THEN 
                    IF (myrank == 0) THEN 
                        WRITE (*, *) "" 
                        WRITE (*, *) "***************** Verification against '" // trim(adjustl(kgen_filepath)) // "' &
                        &*****************" 
                    END IF   
                    kgen_evalstage = .TRUE. 
                    kgen_warmupstage = .FALSE. 
                    kgen_mainstage = .FALSE. 
                      
                      
                    !driver read in arguments 
                      
                    !extern input variables 
                      
                    !callsite part 
                    CALL funarc_wrapper(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath) 
                    REWIND (UNIT=kgen_unit) 
                    kgen_evalstage = .FALSE. 
                    kgen_warmupstage = .TRUE. 
                    kgen_mainstage = .FALSE. 
                      
                      
                    !driver read in arguments 
                      
                    !extern input variables 
                      
                    !callsite part 
                    CALL funarc_wrapper(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath) 
                    REWIND (UNIT=kgen_unit) 
                    kgen_evalstage = .FALSE. 
                    kgen_warmupstage = .FALSE. 
                    kgen_mainstage = .TRUE. 
                    kgen_case_count = kgen_case_count + 1 
                    kgen_isverified = .FALSE. 
                      
                      
                    !driver read in arguments 
                      
                    !extern input variables 
                      
                    !callsite part 
                    CALL funarc_wrapper(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath) 
                    kgen_total_time = kgen_total_time + kgen_measure 
                    kgen_min_time = MIN( kgen_min_time, kgen_measure ) 
                    kgen_max_time = MAX( kgen_max_time, kgen_measure ) 
                    IF (kgen_isverified) THEN 
                        kgen_count_verified = kgen_count_verified + 1 
                    END IF   
                END IF   
                CLOSE (UNIT=kgen_unit) 
            END IF   
        END DO   
          
        CLOSE (UNIT=kgen_unit_list) 
          
        IF (myrank == 0) THEN 
            WRITE (*, *) "" 
            WRITE (*, "(A)") "****************************************************" 
            WRITE (*, "(4X,A)") "kernel execution summary: funarc_call" 
            WRITE (*, "(A)") "****************************************************" 
            IF (kgen_case_count == 0) THEN 
                WRITE (*, *) "No data file is verified." 
            ELSE 
                WRITE (*, "(4X, A36, A1, I6)") "Total number of verification cases   ", ":", kgen_case_count 
                WRITE (*, "(4X, A36, A1, I6)") "Number of verification-passed cases ", ":", kgen_count_verified 
                WRITE (*, *) "" 
                IF (kgen_case_count == kgen_count_verified) THEN 
                    WRITE (*, "(4X,A)") "kernel: funarc_call: PASSED verification" 
                ELSE 
                    WRITE (*, "(4X,A)") "kernel: funarc_call: FAILED verification" 
                END IF   
                WRITE (*, *) "" 
                WRITE (*, "(4X,A19,I3)") "number of processes: ", mpisize 
                WRITE (*, *) "" 
                WRITE (*, "(4X, A, E10.3)") "Average call time (usec): ", kgen_total_time / DBLE(kgen_case_count) 
                WRITE (*, "(4X, A, E10.3)") "Minimum call time (usec): ", kgen_min_time 
                WRITE (*, "(4X, A, E10.3)") "Maximum call time (usec): ", kgen_max_time 
            END IF   
            WRITE (*, "(A)") "****************************************************" 
        END IF   
    END PROGRAM   
    BLOCK DATA KGEN 
        INTEGER :: kgen_mpirank = 0, kgen_openmptid = 0, kgen_kernelinvoke = 0 
        LOGICAL :: kgen_evalstage = .TRUE., kgen_warmupstage = .FALSE., kgen_mainstage = .FALSE. 
        COMMON / state / kgen_mpirank, kgen_openmptid, kgen_kernelinvoke, kgen_evalstage, kgen_warmupstage, kgen_mainstage 
    END BLOCK DATA KGEN 