!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-24 12:23:00 
!KGEN version : 0.8.1 
  
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


 module POP_SolversMod
!BOP
! !MODULE: POP_SolversMod
! !DESCRIPTION:
!  This module contains routines and operators for solving the elliptic
!  system for surface pressure in the barotropic mode.
! !REVISION HISTORY:
!  SVN:$Id: $
! !USES:

!
!


     USE pop_kindsmod 
     USE pop_iounitsmod 
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 

     IMPLICIT NONE 
     PRIVATE 
     SAVE 
! !PUBLIC MEMBER FUNCTIONS:


! !PUBLIC DATA MEMBERS:
!-----------------------------------------------------------------------
!  other operator and preconditioning weights for barotropic operator
!-----------------------------------------------------------------------


!
!


!-----------------------------------------------------------------------
!  EVP preconditioner influence matrix and block coefficient matrix,
!  Saved in EVP sub-block format. Dimension switched:
!  (X,Y,block_ID) ==> (subblock_X, subblock_Y, subblock_ID, block_ID) 
!-----------------------------------------------------------------------

!
!

   real (POP_r8), dimension (:,:,:,:), allocatable, public :: & 
      EvpRinv               ! EVP influence matrix

   real (POP_r8), dimension (:,:,:,:), allocatable, public :: & 
      EvpCenterWgt,        &! reshape coefficients into blocks 
      InvEvpCenterWgt,     &! save inverse for computational efficiency
      EvpNeWgt,            &! 
      InvEvpNeWgt          

   integer (POP_i4),dimension(:,:,:),allocatable :: &
      landIndx              ! index of land EVP blocks 
!EOP
!BOC
   !*** preconditioning operator coefficients (ninept operator)


   real (POP_r8), dimension (:,:,:), allocatable :: & 
      precondCenter,              &
      precondNorth, precondSouth, &
      precondEast,  precondWest,  &
      precondNE,    precondSE,    &
      precondNW,    precondSW
!-----------------------------------------------------------------------
!  supported solvers and preconditioners
!-----------------------------------------------------------------------

!
!


   character (POP_charLength) :: &
      preconditionerChoice

   character (4), parameter :: &
      precondChoiceFile = 'file'
   character (3), parameter :: &
      precondChoiceEvp = 'evp' 

!-----------------------------------------------------------------------
!  scalar convergence-related variables
!-----------------------------------------------------------------------

!
!


   !*** convergence diagnostics


   integer(POP_i4), parameter  :: &
      EvpXbs  = 8,        &! EVP block size along longitude
      EvpYbs  = 8          ! EVP block size along latitude


   integer (POP_i4) :: &
      EvpXnb,          &    ! sub block number along longitude
      EvpYnb                ! sub block number along latitude

   integer (POP_i4),dimension(:),allocatable :: &
      EvpXbidx,          &  ! index of sub blocks start point 
      EvpYbidx              ! along longtitude and latitude
!EOC
!***********************************************************************
   PUBLIC kr_externs_in_pop_solversmod 
   PUBLIC kr_externs_out_pop_solversmod 
   PUBLIC pcsi 
#ifdef _MPI 
   include "mpif.h" 
#endif 
     


 contains
!***********************************************************************
!BOP
! !SUBROUTINE: POP_SolversPrep
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: POP_SolversRun
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: POP_SolversInit
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: POP_SolversDiagonal
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: POP_SolversGetDiagnostics
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: pcg
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: PCSI
! !INTERFACE:


 SUBROUTINE pcsi(kgen_unit, kgen_measure, kgen_isverified, kgen_filepath, x) 
! !DESCRIPTION:
!  This routine implements the Preconditioned Classical Stiefel Iteration 
!  (PCSI)  solver for solving the linear system $Ax=b$.
!  It uses the two extreme eigenvalues of $A$ instead of the norm of
!  residual. Thus, PCSI eliminates global reductions in each iteration.
!  The eigenvalues are estimated by routine PcsiLanczos.
!  PCSI supports all kinds of preconditioners supported by PCG/ChronGear, 
!  including diagonal and EVP preconditioning.
!  References:
!     Stiefel, E. L. (1958). Kernel polynomial in linear algebra and their
!        numerical applications, in: Further contributions to the 
!        determination of eigenvalues. NBS Applied Math. Ser., 49, 1-22.
!     Hu, Y., Huang, X., Wang, X., Fu, H., Xu, S., Ruan, H., Xue, W. and Yang, G. (2013). 
!        A scalable barotropic mode solver for the parallel ocean program. 
!        In Euro-Par 2013  Parallel Processing (pp. 739-750) Springer Berlin Heidelberg.
! !REVISION HISTORY:
!  this routine implemented by Yong Hu et al., Tsinghua University
! !INPUT PARAMETERS:
     USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
     USE kgen_utils_mod, ONLY: kgen_perturb_real 
     USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_init_verify, kgen_tolerance, kgen_minvalue, kgen_verboselevel, &
     &CHECK_IDENTICAL, CHECK_IN_TOL, CHECK_OUT_TOL 

!
!


! !INPUT/OUTPUT PARAMETERS:


     REAL(KIND=pop_r8), dimension(:,:,:), INTENT(INOUT) :: x 
                         ! on output, solution of the linear system
! !OUTPUT PARAMETERS:


!EOP
!BOC
!-----------------------------------------------------------------------
!  local variables
!-----------------------------------------------------------------------

!
!

     INTEGER(KIND=pop_i4) :: iblock 


   
     REAL(KIND=pop_r8), dimension(size(x,dim=1),size(x,dim=2),                                                                   &
     &                  size(x,dim=3)) :: r, work1 
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
     REAL(KIND=pop_r8), dimension(size(x,dim=1),size(x,dim=2),size(x,dim=3)) :: kgenref_work1 
       
     !parent block preprocessing 
       
#ifdef _MPI 
     call mpi_comm_rank(mpi_comm_world, kgen_mpirank, kgen_ierr) 
#else 
     kgen_mpirank = 0 
#endif 
       
       
     !local input variables 
     READ (UNIT = kgen_unit) iblock 
     READ (UNIT = kgen_unit) kgen_istrue 
     IF (kgen_istrue) THEN 
         READ (UNIT = kgen_unit) kgen_array_sum 
         READ (UNIT = kgen_unit) work1 
         CALL kgen_array_sumcheck("work1", kgen_array_sum, DBLE(SUM(work1, mask=(work1 .eq. work1))), .TRUE.) 
     END IF   
     READ (UNIT = kgen_unit) kgen_istrue 
     IF (kgen_istrue) THEN 
         READ (UNIT = kgen_unit) kgen_array_sum 
         READ (UNIT = kgen_unit) r 
         CALL kgen_array_sumcheck("r", kgen_array_sum, DBLE(SUM(r, mask=(r .eq. r))), .TRUE.) 
     END IF   
       
     !extern output variables 
     CALL kr_externs_out_pop_solversmod(kgen_unit) 
       
     !local output variables 
     READ (UNIT = kgen_unit) kgen_istrue 
     IF (kgen_istrue) THEN 
         READ (UNIT = kgen_unit) kgen_array_sum 
         READ (UNIT = kgen_unit) kgenref_work1 
         CALL kgen_array_sumcheck("kgenref_work1", kgen_array_sum, DBLE(SUM(kgenref_work1, mask=(kgenref_work1 .eq. &
         &kgenref_work1))), .TRUE.) 
     END IF   


!-----------------------------------------------------------------------
!  step 1 : compute iteration parameters by eigenvalues
!  $\alpha =\frac{2}{\mu -\nu}$, $ \beta = \frac{\mu +\nu}{\mu -\nu}$,
!  $\gamma = \frac{\beta}{\alpha}$, $\omega_0 =\frac{ 2}{\gamma}$
!-----------------------------------------------------------------------


!
!
    
!-----------------------------------------------------------------------
! step 2 : compute initial residual and initialize X
! $\textbf{r}_0 = \textbf{b}-\textbf{B}\textbf{x}_0$; 
! $\textbf{x}_1 =\textbf{x}_0 -\gamma^{-1}\textbf{M}^{-1}\textbf{r}_0$; 
! $\textbf{r}_1 =\textbf{b} -\textbf{B}\textbf{x}_1$; 
!-----------------------------------------------------------------------
    
!
!
    
    !$OMP PARALLEL DO PRIVATE(iblock,i,j)

   !$OMP END PARALLEL DO


    !$OMP PARALLEL DO PRIVATE(iblock,i,j)
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
            call preconditioner(work1,R,iblock)
            IF (kgen_mainstage) THEN 
                  
                !verify init 
                CALL kgen_init_verify(tolerance=1.D-14, minvalue=1.D-14, verboseLevel=1) 
                CALL kgen_init_check(check_status, rank=kgen_mpirank) 
                  
                !extern verify variables 
                  
                !local verify variables 
                CALL kv_pcsi_real__pop_r8_dim3("work1", check_status, work1, kgenref_work1) 
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
                  
#ifdef _MPI 
                call mpi_barrier(mpi_comm_world, kgen_ierr) 
#endif 
                  
                CALL SYSTEM_CLOCK(kgen_start_clock, kgen_rate_clock) 
                DO kgen_intvar = 1, KGEN_MAXITER 
            call preconditioner(work1,R,iblock)
                END DO   
                CALL SYSTEM_CLOCK(kgen_stop_clock, kgen_rate_clock) 
                kgen_measure = 1.0D6*(kgen_stop_clock - kgen_start_clock)/DBLE(kgen_rate_clock*KGEN_MAXITER) 
#ifdef _MPI 
                CALL mpi_allreduce(kgen_measure, gkgen_measure, 1, mpi_real8, mpi_max, mpi_comm_world, kgen_ierr) 
                kgen_measure = gkgen_measure 
#endif 
                IF (check_status%rank==0) THEN 
                    WRITE (*, *) "preconditioner : Time per call (usec): ", kgen_measure 
                END IF   
            END IF   
            IF (kgen_warmupstage) THEN 
            END IF   
            IF (kgen_evalstage) THEN 
            END IF   


   !$OMP END PARALLEL DO


    


    !$OMP PARALLEL DO PRIVATE(iblock,i,j)


    !$OMP END PARALLEL DO
    
    
    

    
    !-----------------------------------------------------------------------
    !  iterate
    !-----------------------------------------------------------------------
    
    !
    !
    


    
!-----------------------------------------------------------------------
!EOC
              
            CONTAINS 
              


            !verify state subroutine for kv_pcsi_real__pop_r8_dim3 
            RECURSIVE SUBROUTINE kv_pcsi_real__pop_r8_dim3(varname, check_status, var, kgenref_var) 
                CHARACTER(LEN=*), INTENT(IN) :: varname 
                TYPE(check_t), INTENT(INOUT) :: check_status 
                REAL(KIND=pop_r8), INTENT(IN), DIMENSION(:,:,:) :: var, kgenref_var 
                INTEGER :: check_result 
                LOGICAL :: is_print = .FALSE. 
                  
                INTEGER :: idx1, idx2, idx3 
                INTEGER :: n 
                real(KIND=pop_r8) :: nrmsdiff, rmsdiff 
                real(KIND=pop_r8), ALLOCATABLE :: buf1(:,:,:), buf2(:,:,:) 
                  
                check_status%numTotal = check_status%numTotal + 1 
                  
                IF (ALL(var == kgenref_var)) THEN 
                    check_status%numIdentical = check_status%numIdentical + 1 
                    IF (kgen_verboseLevel > 1) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) trim(adjustl(varname)), " is IDENTICAL." 
                        END IF   
                    END IF   
                    check_result = CHECK_IDENTICAL 
                ELSE 
                    ALLOCATE (buf1(SIZE(var,dim=1),SIZE(var,dim=2),SIZE(var,dim=3))) 
                    ALLOCATE (buf2(SIZE(var,dim=1),SIZE(var,dim=2),SIZE(var,dim=3))) 
                    n = SIZE(var) 
                    WHERE ( ABS(kgenref_var) > kgen_minvalue ) 
                        buf1 = ((var-kgenref_var)/kgenref_var)**2 
                        buf2 = (var-kgenref_var)**2 
                    ELSEWHERE 
                        buf1 = (var-kgenref_var)**2 
                        buf2 = buf1 
                    END WHERE   
                    nrmsdiff = SQRT(SUM(buf1)/DBLE(n)) 
                    rmsdiff = SQRT(SUM(buf2)/DBLE(n)) 
                    IF (rmsdiff > kgen_tolerance) THEN 
                        check_status%numOutTol = check_status%numOutTol + 1 
                        IF (kgen_verboseLevel > 0) THEN 
                            IF (check_status%rank == 0) THEN 
                                WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(out of tolerance)." 
                            END IF   
                        END IF   
                        check_result = CHECK_OUT_TOL 
                    ELSE 
                        check_status%numInTol = check_status%numInTol + 1 
                        IF (kgen_verboseLevel > 1) THEN 
                            IF (check_status%rank == 0) THEN 
                                WRITE (*, *) trim(adjustl(varname)), " is NOT IDENTICAL(within tolerance)." 
                            END IF   
                        END IF   
                        check_result = CHECK_IN_TOL 
                    END IF   
                END IF   
                IF (check_result == CHECK_IDENTICAL) THEN 
                    IF (kgen_verboseLevel > 2) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                            WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                            WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                            WRITE (*, *) "RMS of difference is ", 0 
                            WRITE (*, *) "Normalized RMS of difference is ", 0 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                ELSE IF (check_result == CHECK_OUT_TOL) THEN 
                    IF (kgen_verboseLevel > 0) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                            WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                            WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                            WRITE (*, *) "RMS of difference is ", rmsdiff 
                            WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                ELSE IF (check_result == CHECK_IN_TOL) THEN 
                    IF (kgen_verboseLevel > 1) THEN 
                        IF (check_status%rank == 0) THEN 
                            WRITE (*, *) count( var /= kgenref_var), " of ", size( var ), " elements are different." 
                            WRITE (*, *) "Average - kernel ", sum(var)/real(size(var)) 
                            WRITE (*, *) "Average - reference ", sum(kgenref_var)/real(size(kgenref_var)) 
                            WRITE (*, *) "RMS of difference is ", rmsdiff 
                            WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff 
                            WRITE (*, *) "" 
                        END IF   
                    END IF   
                END IF   
                  
            END SUBROUTINE kv_pcsi_real__pop_r8_dim3 
              
 END SUBROUTINE pcsi 
!***********************************************************************
!BOP
! !IROUTINE: ChronGear
! !INTERFACE:


!***********************************************************************
!BOP
! !IROUTINE: preconditioner
! !INTERFACE:


 subroutine preconditioner(PX,X,bid)
! !DESCRIPTION:
!  This function applies a precomputed preconditioner as a nine-point
!  stencil operator.
! !REVISION HISTORY:
!  add EVP preconditioning interface by Yong Hu et al., Tsinghua University
! !INPUT PARAMETERS:

!


   real (POP_r8), dimension(:,:,:), intent(in) :: & 
      X                     ! array to be operated on 

   integer (POP_i4), intent(in) :: &
      bid                    ! local block address for this block
! !OUTPUT PARAMETERS:


   real (POP_r8), dimension(:,:,:), intent(out) :: &
      PX                  ! nine point operator result
!EOP
!BOC
!-----------------------------------------------------------------------
!  local variables
!-----------------------------------------------------------------------

!
!
   real (POP_r8), dimension(EvpXbs+2,EvpYbs+2,EvpXnb*EvpYnb):: &
      f               ! reshaped X

   integer (POP_i4) :: &
      i,j,js,je,is,ie,lm,ln,l,ib               ! dummy counters
!-----------------------------------------------------------------------


   PX(:,:,bid) = 0.0_POP_r8
   if (trim(preconditionerChoice) == precondChoiceFile) then
       do j=2,size(X,dim=2)-1
       do i=2,size(X,dim=1)-1
          PX(i,j,bid) = precondNE    (i,j,bid)*X(i+1,j+1,bid) + &
                        precondNW    (i,j,bid)*X(i-1,j+1,bid) + &
                        precondSE    (i,j,bid)*X(i+1,j-1,bid) + &
                        precondSW    (i,j,bid)*X(i-1,j-1,bid) + &
                        precondNorth (i,j,bid)*X(i  ,j+1,bid) + &
                        precondSouth (i,j,bid)*X(i  ,j-1,bid) + &
                        precondEast  (i,j,bid)*X(i+1,j  ,bid) + &
                        precondWest  (i,j,bid)*X(i-1,j  ,bid) + &
                        precondCenter(i,j,bid)*X(i  ,j  ,bid)
       end do
       end do
!-----------------------------------------------------------------------
!  EVP preconditioning 
!-----------------------------------------------------------------------
!
!

   else if (trim(preconditionerChoice) == precondChoiceEvp) then
       f = 0.0_POP_r8 
       do j = 1, EvpYnb
         js = EvpYbidx(j)
         je = EvpYbidx(j+1) +1
         lm = (je-js) +1
         do i = 1, EvpXnb
           is = EvpXbidx(i) 
           ie = EvpXbidx(i+1) +1
           ln = (ie-is) +1
           l  = ln + lm -5
           ib = (j-1)*EvpXnb+i
           f(2:ln-1,2:lm-1,ib) = X(is+1:ie-1,js+1:je-1,bid)
           if (landIndx(i,j,bid) == 1 ) then 
             ! diagonal preconditioning for blocks containing land potins

             PX(is+1:ie-1,js+1:je-1,bid) = & 
             f(2:ln-1,2:lm-1,ib)*InvEvpCenterWgt(2:ln-1,2:lm-1,ib,bid)

           else if (landIndx(i,j,bid) == 0 ) then 
             ! EVP solver on sub-blocks

             call ExplicitEvp(EvpCenterWgt(1:ln,1:lm,ib,bid),&
                  EvpNeWgt(1:ln,1:lm,ib,bid),InvEvpNeWgt(1:ln,1:lm,ib,bid),&
                  EvpRinv(1:l,1:l,ib,bid),PX(is+1:ie-1,js+1:je-1,bid),f(1:ln,1:lm,ib),ln,lm)

           else 
             write(POP_stdout,'(a35,3I5.3)') 'EVP Error: unpreconditioned block ',&
                                             i,j,landIndx(i,j,bid)
           endif 

         end do 
       end do 
  endif 
!-----------------------------------------------------------------------
!EOC


 end subroutine preconditioner
!***********************************************************************
!BOP
! !IROUTINE: btropOperator
! !INTERFACE:


  


  subroutine ExplicitEvp(cc,ne,ine,rinv,tu,f,n,m)
! !DESCRIPTION:
!  This routine implements the EVP method to explicitly solve 
!  a nine point elliptic equation on sub blocks.
!  Four coefficients related to north, south, east and west are 
!  small compared with the rest five coefficients, thus ignored 
!  here to reduce computation
!  References:
!     Roache, P. J. (1995). Elliptic marching methods and domain 
!        decomposition (Vol.5). CRC press.
! !REVISION HISTORY:
!  this routine implemented by Yong Hu, et al., Tsinghua University
 ! !INPUT PARAMETERS:
!
!
 
   integer(POP_i4),intent(in) :: n,m                    !sub-block size [n,m]
   real(POP_r8),dimension(n,m),intent(in) :: cc,&! center weight
                                             ne,&! northeast weight
                                             ine ! inverse of ne
   real(POP_r8),dimension(n,m),intent(in) :: f   ! residual 
   real(POP_r8),dimension(n+m-5,n+m-5),intent(in) :: rinv
                                                 ! preconditioning matrx
 ! !OUTPUT PARAMETERS:

   real(POP_r8),dimension(n-2,m-2),intent(inout) :: tu ! solution
   !LOCAL VARIABLES
 
 
   integer(POP_i4) :: i,j,k       ! local counters
   integer(POP_i4) :: nm          ! length of initial and final error
   real(POP_r8),dimension(n,m) :: y ! temporary array
   real(POP_r8),dimension(n+m-5) :: r !final error vector
 
   nm = n+m-5
   y(:,:) = 0.0_POP_r8
   y(2:n-1,2:m-1) = tu(:,:) 
   ! marching from intial error vectors (west and south)
   
   do j = 2, m-1
     do i = 2, n-1
         y(i+1,j+1)  = (f(i,j)- cc(i,j)     * y(i,j )     & 
                -  ne(i,j-1)   * y(i+1,j-1)  &
                -  ne(i-1,j)   * y(i-1,j+1)  & 
                -  ne(i-1,j-1) * y(i-1,j-1) ) *ine(i,j) 
     end do
   end do
   ! get final error vectors (east and north)
 
   r(1:n-2) = y(3:n,m)
   r(n-1:n+m-5) = y(n,m-1:3:-1) 
   !compute intial error 
 
   do j = 1,m-2
       do k = 1,nm
         y(2,m-j)  = y(2,m-j) + rinv(k,j)*r(k)
       end do 
   end do 
   do i = 1,n-3
       do k = 1,nm
         y(i+2,2)  = y(i+2,2) + rinv(k,m-2+i)*r(k)
       end do 
   end do 
   !marching again based on the adjusted intial vector
 
 
   do j = 2, m-2
     do i = 2, n-2
         y(i+1,j+1)  = (f(i,j)- cc(i,j)     * y(i,j )     & 
                -  ne(i,j-1)   * y(i+1,j-1)  &
                -  ne(i-1,j)   * y(i-1,j+1)  & 
                -  ne(i-1,j-1) * y(i-1,j-1) ) *ine(i,j) 
       end do
   end do
   !copy results 

   tu(1:n-2,1:m-2) = y(2:n-1,2:m-1) 
 
  end subroutine 
 !***********************************************************************
 


  !read state subroutine for kr_externs_in_pop_solversmod 
  SUBROUTINE kr_externs_in_pop_solversmod(kgen_unit) 
      INTEGER, INTENT(IN) :: kgen_unit 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
        
      CALL kr_pop_solversmod_real__pop_r8_dim4(evprinv, kgen_unit, "evprinv", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim4(invevpcenterwgt, kgen_unit, "invevpcenterwgt", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim4(invevpnewgt, kgen_unit, "invevpnewgt", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim4(evpnewgt, kgen_unit, "evpnewgt", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim4(evpcenterwgt, kgen_unit, "evpcenterwgt", .FALSE.) 
      CALL kr_pop_solversmod_integer__pop_i4_dim3(landindx, kgen_unit, "landindx", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondsw, kgen_unit, "precondsw", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondeast, kgen_unit, "precondeast", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondwest, kgen_unit, "precondwest", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondne, kgen_unit, "precondne", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondse, kgen_unit, "precondse", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondnorth, kgen_unit, "precondnorth", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondcenter, kgen_unit, "precondcenter", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondsouth, kgen_unit, "precondsouth", .FALSE.) 
      CALL kr_pop_solversmod_real__pop_r8_dim3(precondnw, kgen_unit, "precondnw", .FALSE.) 
      READ (UNIT = kgen_unit) preconditionerchoice 
      READ (UNIT = kgen_unit) evpxnb 
      READ (UNIT = kgen_unit) evpynb 
      CALL kr_pop_solversmod_integer__pop_i4_dim1(evpybidx, kgen_unit, "evpybidx", .FALSE.) 
      CALL kr_pop_solversmod_integer__pop_i4_dim1(evpxbidx, kgen_unit, "evpxbidx", .FALSE.) 
  END SUBROUTINE kr_externs_in_pop_solversmod 
    
  !read state subroutine for kr_externs_out_pop_solversmod 
  SUBROUTINE kr_externs_out_pop_solversmod(kgen_unit) 
      INTEGER, INTENT(IN) :: kgen_unit 
        
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
  END SUBROUTINE kr_externs_out_pop_solversmod 
    
  !read state subroutine for kr_pop_solversmod_real__pop_r8_dim4 
  SUBROUTINE kr_pop_solversmod_real__pop_r8_dim4(var, kgen_unit, printname, printvar) 
      REAL(KIND=pop_r8), INTENT(INOUT), ALLOCATABLE, DIMENSION(:,:,:,:) :: var 
      INTEGER, INTENT(IN) :: kgen_unit 
      CHARACTER(LEN=*), INTENT(IN) :: printname 
      LOGICAL, INTENT(IN), OPTIONAL :: printvar 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
      INTEGER :: idx1, idx2, idx3, idx4 
      INTEGER, DIMENSION(2,4) :: kgen_bound 
        
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
          ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1), kgen_bound(1,2):kgen_bound(2,2), kgen_bound(1,3):kgen_bound(2,3), &
          &kgen_bound(1,4):kgen_bound(2,4))) 
          READ (UNIT = kgen_unit) var 
          CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
          IF (PRESENT( printvar ) .AND. printvar) THEN 
              WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
          END IF   
      END IF   
  END SUBROUTINE kr_pop_solversmod_real__pop_r8_dim4 
    
  !read state subroutine for kr_pop_solversmod_integer__pop_i4_dim3 
  SUBROUTINE kr_pop_solversmod_integer__pop_i4_dim3(var, kgen_unit, printname, printvar) 
      INTEGER(KIND=pop_i4), INTENT(INOUT), ALLOCATABLE, DIMENSION(:,:,:) :: var 
      INTEGER, INTENT(IN) :: kgen_unit 
      CHARACTER(LEN=*), INTENT(IN) :: printname 
      LOGICAL, INTENT(IN), OPTIONAL :: printvar 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
      INTEGER :: idx1, idx2, idx3 
      INTEGER, DIMENSION(2,3) :: kgen_bound 
        
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
          ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1), kgen_bound(1,2):kgen_bound(2,2), kgen_bound(1,3):kgen_bound(2,3))) 
          READ (UNIT = kgen_unit) var 
          CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
          IF (PRESENT( printvar ) .AND. printvar) THEN 
              WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
          END IF   
      END IF   
  END SUBROUTINE kr_pop_solversmod_integer__pop_i4_dim3 
    
  !read state subroutine for kr_pop_solversmod_real__pop_r8_dim3 
  SUBROUTINE kr_pop_solversmod_real__pop_r8_dim3(var, kgen_unit, printname, printvar) 
      REAL(KIND=pop_r8), INTENT(INOUT), ALLOCATABLE, DIMENSION(:,:,:) :: var 
      INTEGER, INTENT(IN) :: kgen_unit 
      CHARACTER(LEN=*), INTENT(IN) :: printname 
      LOGICAL, INTENT(IN), OPTIONAL :: printvar 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
      INTEGER :: idx1, idx2, idx3 
      INTEGER, DIMENSION(2,3) :: kgen_bound 
        
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
          ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1), kgen_bound(1,2):kgen_bound(2,2), kgen_bound(1,3):kgen_bound(2,3))) 
          READ (UNIT = kgen_unit) var 
          CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
          IF (PRESENT( printvar ) .AND. printvar) THEN 
              WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
          END IF   
      END IF   
  END SUBROUTINE kr_pop_solversmod_real__pop_r8_dim3 
    
  !read state subroutine for kr_pop_solversmod_integer__pop_i4_dim1 
  SUBROUTINE kr_pop_solversmod_integer__pop_i4_dim1(var, kgen_unit, printname, printvar) 
      INTEGER(KIND=pop_i4), INTENT(INOUT), ALLOCATABLE, DIMENSION(:) :: var 
      INTEGER, INTENT(IN) :: kgen_unit 
      CHARACTER(LEN=*), INTENT(IN) :: printname 
      LOGICAL, INTENT(IN), OPTIONAL :: printvar 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
      INTEGER :: idx1 
      INTEGER, DIMENSION(2,1) :: kgen_bound 
        
      READ (UNIT = kgen_unit) kgen_istrue 
      IF (kgen_istrue) THEN 
          IF (ALLOCATED( var )) THEN 
              DEALLOCATE (var) 
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
  END SUBROUTINE kr_pop_solversmod_integer__pop_i4_dim1 
    
 end module POP_SolversMod
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
