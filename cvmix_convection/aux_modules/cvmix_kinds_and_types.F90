!KGEN-generated Fortran source file 
  
!Generated at : 2019-06-23 18:42:32 
!KGEN version : 0.8.1 
  
!BOI
! !TITLE: In-code documentation for CVMix
! !AUTHORS: Many contributors from GFDL, LANL, and NCAR
! !AFFILIATION: GFDL, LANL, and NCAR
! !DATE: \today
!EOI


module cvmix_kinds_and_types
!BOP
! !MODULE:  cvmix_kinds_and_types
! !AUTHOR:
!  Michael Levy, NCAR (mlevy@ucar.edu)
! !DESCRIPTION:
!  This module contains the declarations for all required vertical mixing
!  data types. It also contains several global parameters used by the cvmix
!  package, such as kind numbers and string lengths.
!  \!  \
! !USES:
!  uses no other modules
!EOP
    USE kgen_utils_mod, ONLY: kgen_dp, kgen_array_sumcheck 
    USE tprof_mod, ONLY: tstart, tstop, tnull, tprnt 
    USE kgen_utils_mod, ONLY: check_t, kgen_init_check, kgen_tolerance, kgen_minvalue, kgen_verboselevel, CHECK_IDENTICAL, &
    &CHECK_IN_TOL, CHECK_OUT_TOL 

!
!

    IMPLICIT NONE 
    PRIVATE 
    SAVE 
!BOP
! !DEFINED PARAMETERS:
  ! Kind Types:
  ! The cvmix package uses double precision for floating point computations.


  integer, parameter, public :: cvmix_r8       = selected_real_kind(15, 307), &
                                cvmix_log_kind = kind(.true.),                &
                                cvmix_strlen   = 256
  ! Parameters to allow CVMix to store integers instead of strings

  ! Global parameters:
  ! The constant 1 is used repeatedly in PP and double-diff mixing.
  ! The value for pi is needed for Bryan-Lewis mixing.

  real(cvmix_r8), parameter, public :: cvmix_zero = real(0,cvmix_r8),         &
                                       cvmix_one  = real(1,cvmix_r8)
! !PUBLIC TYPES:
  ! cvmix_data_type contains variables for time-dependent and column-specific
  ! mixing. Time-independent physical parameters should be stored in
  ! cvmix_global_params_type and *-mixing specific parameters should be
  ! stored in cvmix_*_params_type (found in the cvmix_* module).


  type, public :: cvmix_data_type
    integer        :: nlev = -1      ! Number of active levels in column
    integer        :: max_nlev = -1  ! Number of levels in column
                                     ! Setting defaults to -1 might be F95...
    ! Scalar quantities
    ! -----------------
    ! distance from sea level to ocean bottom (positive => below sea level)

    real(cvmix_r8) :: OceanDepth
                    ! units: m
    ! distance from sea level to OBL bottom (positive => below sea level)
    real(cvmix_r8) :: BoundaryLayerDepth
                    ! units: m
    ! sea surface height (positive => above sea level)
    real(cvmix_r8) :: SeaSurfaceHeight
                    ! units: m
    ! turbulent friction velocity at surface
    real(cvmix_r8) :: SurfaceFriction
                    ! units: m/s
    ! buoyancy forcing at surface
    real(cvmix_r8) :: SurfaceBuoyancyForcing
                    ! units: m^2 s^-3
    ! latitude of column
    real(cvmix_r8) :: lat
                    ! units: degrees
    ! longitude of column
    real(cvmix_r8) :: lon
                    ! units: degrees
    ! Coriolis parameter
    real(cvmix_r8) :: Coriolis
                    ! units: s^-1
    ! Index of cell containing OBL (fraction > .5 => below cell center)
    real(cvmix_r8) :: kOBL_depth
                    ! units: unitless
    ! QL, 150610
    ! Langmuir mixing induced enhancement factor to turbulent velocity scale
    real(cvmix_r8) :: LangmuirEnhancementFactor
                    ! units: unitless
    ! Surface Stokes drift magnitude
    real(cvmix_r8) :: SurfaceStokesDrift
                    ! units: m/s
    ! A time-invariant coefficient needed for Simmons, et al. tidal mixing
    real(cvmix_r8) :: SimmonsCoeff
    ! Values on interfaces (dimsize = nlev+1)
    ! --------------------
    ! height of interfaces in column (positive up => most are negative)

    real(cvmix_r8), dimension(:), pointer :: zw_iface => NULL()
                                           ! units: m
    ! distance between neighboring cell centers (first value is top of ocean to
    ! middle of first cell, last value is middle of last cell to ocean bottom

    real(cvmix_r8), dimension(:), pointer :: dzw                   => NULL()
                                           ! units: m
    ! diffusivity coefficients at interfaces
    ! different coefficients for momentum (Mdiff), temperature (Tdiff), and
    ! salinity / non-temp tracers (Sdiff)

    real(cvmix_r8), dimension(:), pointer :: Mdiff_iface => NULL()
    real(cvmix_r8), dimension(:), pointer :: Tdiff_iface => NULL()
    real(cvmix_r8), dimension(:), pointer :: Sdiff_iface => NULL()
                                           ! units: m^2/s
    ! shear Richardson number at column interfaces

    real(cvmix_r8), dimension(:), pointer :: ShearRichardson_iface => NULL()
                                           ! units: unitless
    ! For tidal mixing, we need the squared buoyancy frequency and vertical
    ! deposition function

    real(cvmix_r8), dimension(:), pointer :: SqrBuoyancyFreq_iface => NULL()
                                           ! units: s^-2
    real(cvmix_r8), dimension(:), pointer :: VertDep_iface => NULL()
                                           ! units: unitless
    ! A time-dependent coefficient needed for Schmittner 2014

    real(cvmix_r8), dimension(:), pointer   :: SchmittnerCoeff => NULL()
    ! A time-invariant coefficient needed in Schmittner tidal mixing

    real(cvmix_r8), dimension(:), pointer   :: SchmittnerSouthernOcean => NULL()
    ! Another time-invariant coefficient needed in Schmittner tidal mixing

    real(cvmix_r8), dimension(:,:), pointer :: exp_hab_zetar => NULL()
    ! For KPP, need to store non-local transport term


    real(cvmix_r8), dimension(:), pointer :: kpp_Tnonlocal_iface => NULL()
    real(cvmix_r8), dimension(:), pointer :: kpp_Snonlocal_iface => NULL()
                                           ! units: unitless (see note below)
    ! Note that kpp_transport_iface is the value of K_x*gamma_x/flux_x: in
    ! other words, the user must multiply this value by either the freshwater
    ! flux or the penetrative shortwave heat flux to come the values in Eqs.
    ! (7.128) and (7.129) of the CVMix manual.
    ! Currently only provide nonlocal term for temperature tracer and salinity
    ! (non-temperature) tracers. Eventually may add support for momentum terms
    ! (would be 2D for x- and y-, respectively) but current implementation
    ! assumes momentum term is 0 everywhere.
    ! Values at tracer points (dimsize = nlev)
    ! -----------------------
    ! height of cell centers in column (positive up => most are negative)

    real(cvmix_r8), dimension(:), pointer :: zt_cntr => NULL()
                                           ! units: m
    ! level thicknesses (positive semi-definite)

    real(cvmix_r8), dimension(:), pointer :: dzt => NULL()
                                           ! units: m
    ! Two density values are stored: the actual density of water at a given
    ! level and the the density of water after adiabatic displacement to the
    ! level below where the water actually is

    real(cvmix_r8), dimension(:), pointer :: WaterDensity_cntr      => NULL()
    real(cvmix_r8), dimension(:), pointer :: AdiabWaterDensity_cntr => NULL()
                                           ! units: kg m^-3
    ! bulk Richardson number

    real(cvmix_r8), dimension(:), pointer :: BulkRichardson_cntr => NULL()
                                           ! units: unitless
    ! For double diffusion mixing, we need to calculate the stratification
    ! parameter R_rho. Since the denominator of this ratio may be zero, we
    ! store the numerator and denominator separately and make sure the
    ! denominator is non-zero before performing the division.

    real(cvmix_r8), dimension(:), pointer :: strat_param_num   => NULL()
    real(cvmix_r8), dimension(:), pointer :: strat_param_denom => NULL()
                                           ! units: unitless
    ! For KPP we need velocity (in both x direction and y direction)

    real(cvmix_r8), dimension(:), pointer :: Vx_cntr => NULL()
    real(cvmix_r8), dimension(:), pointer :: Vy_cntr => NULL()
                                           ! units: m/s
  end type cvmix_data_type
  ! cvmix_global_params_type contains global parameters used by multiple
  ! mixing methods.


!EOP
  PUBLIC kr_cvmix_kinds_and_types_cvmix_data_type 
  PUBLIC kv_cvmix_kinds_and_types_cvmix_data_type 
    
  CONTAINS 
    


  !read state subroutine for kr_cvmix_kinds_and_types_cvmix_data_type 
  RECURSIVE SUBROUTINE kr_cvmix_kinds_and_types_cvmix_data_type(var, kgen_unit, printname, printvar) 
      TYPE(cvmix_data_type), INTENT(INOUT) :: var 
      INTEGER, INTENT(IN) :: kgen_unit 
      CHARACTER(LEN=*), INTENT(IN) :: printname 
      LOGICAL, INTENT(IN), OPTIONAL :: printvar 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
        
      READ (UNIT = kgen_unit) var%nlev 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%nlev = ", var%nlev 
      END IF   
        
      READ (UNIT = kgen_unit) var%max_nlev 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%max_nlev = ", var%max_nlev 
      END IF   
        
      READ (UNIT = kgen_unit) var%oceandepth 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%oceandepth = ", var%oceandepth 
      END IF   
        
      READ (UNIT = kgen_unit) var%boundarylayerdepth 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%boundarylayerdepth = ", var%boundarylayerdepth 
      END IF   
        
      READ (UNIT = kgen_unit) var%seasurfaceheight 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%seasurfaceheight = ", var%seasurfaceheight 
      END IF   
        
      READ (UNIT = kgen_unit) var%surfacefriction 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%surfacefriction = ", var%surfacefriction 
      END IF   
        
      READ (UNIT = kgen_unit) var%surfacebuoyancyforcing 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%surfacebuoyancyforcing = ", var%surfacebuoyancyforcing 
      END IF   
        
      READ (UNIT = kgen_unit) var%lat 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%lat = ", var%lat 
      END IF   
        
      READ (UNIT = kgen_unit) var%lon 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%lon = ", var%lon 
      END IF   
        
      READ (UNIT = kgen_unit) var%coriolis 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%coriolis = ", var%coriolis 
      END IF   
        
      READ (UNIT = kgen_unit) var%kobl_depth 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%kobl_depth = ", var%kobl_depth 
      END IF   
        
      READ (UNIT = kgen_unit) var%langmuirenhancementfactor 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%langmuirenhancementfactor = ", var%langmuirenhancementfactor 
      END IF   
        
      READ (UNIT = kgen_unit) var%surfacestokesdrift 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%surfacestokesdrift = ", var%surfacestokesdrift 
      END IF   
        
      READ (UNIT = kgen_unit) var%simmonscoeff 
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          WRITE (*, *) "KGEN DEBUG: " // printname // "%simmonscoeff = ", var%simmonscoeff 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%zw_iface, kgen_unit, printname // "%zw_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%zw_iface, kgen_unit, printname // "%zw_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%dzw, kgen_unit, printname // "%dzw", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%dzw, kgen_unit, printname // "%dzw", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%mdiff_iface, kgen_unit, printname // "%mdiff_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%mdiff_iface, kgen_unit, printname // "%mdiff_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%tdiff_iface, kgen_unit, printname // "%tdiff_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%tdiff_iface, kgen_unit, printname // "%tdiff_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%sdiff_iface, kgen_unit, printname // "%sdiff_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%sdiff_iface, kgen_unit, printname // "%sdiff_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%shearrichardson_iface, kgen_unit, printname // &
          &"%shearrichardson_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%shearrichardson_iface, kgen_unit, printname // &
          &"%shearrichardson_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%sqrbuoyancyfreq_iface, kgen_unit, printname // &
          &"%sqrbuoyancyfreq_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%sqrbuoyancyfreq_iface, kgen_unit, printname // &
          &"%sqrbuoyancyfreq_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%vertdep_iface, kgen_unit, printname // "%vertdep_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%vertdep_iface, kgen_unit, printname // "%vertdep_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%schmittnercoeff, kgen_unit, printname // "%schmittnercoeff", &
          &.TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%schmittnercoeff, kgen_unit, printname // "%schmittnercoeff", &
          &.FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%schmittnersouthernocean, kgen_unit, printname // &
          &"%schmittnersouthernocean", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%schmittnersouthernocean, kgen_unit, printname // &
          &"%schmittnersouthernocean", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim2_ptr(var%exp_hab_zetar, kgen_unit, printname // "%exp_hab_zetar", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim2_ptr(var%exp_hab_zetar, kgen_unit, printname // "%exp_hab_zetar", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%kpp_tnonlocal_iface, kgen_unit, printname // &
          &"%kpp_tnonlocal_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%kpp_tnonlocal_iface, kgen_unit, printname // &
          &"%kpp_tnonlocal_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%kpp_snonlocal_iface, kgen_unit, printname // &
          &"%kpp_snonlocal_iface", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%kpp_snonlocal_iface, kgen_unit, printname // &
          &"%kpp_snonlocal_iface", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%zt_cntr, kgen_unit, printname // "%zt_cntr", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%zt_cntr, kgen_unit, printname // "%zt_cntr", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%dzt, kgen_unit, printname // "%dzt", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%dzt, kgen_unit, printname // "%dzt", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%waterdensity_cntr, kgen_unit, printname // "%waterdensity_cntr", &
          &.TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%waterdensity_cntr, kgen_unit, printname // "%waterdensity_cntr", &
          &.FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%adiabwaterdensity_cntr, kgen_unit, printname // &
          &"%adiabwaterdensity_cntr", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%adiabwaterdensity_cntr, kgen_unit, printname // &
          &"%adiabwaterdensity_cntr", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%bulkrichardson_cntr, kgen_unit, printname // &
          &"%bulkrichardson_cntr", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%bulkrichardson_cntr, kgen_unit, printname // &
          &"%bulkrichardson_cntr", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%strat_param_num, kgen_unit, printname // "%strat_param_num", &
          &.TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%strat_param_num, kgen_unit, printname // "%strat_param_num", &
          &.FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%strat_param_denom, kgen_unit, printname // "%strat_param_denom", &
          &.TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%strat_param_denom, kgen_unit, printname // "%strat_param_denom", &
          &.FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%vx_cntr, kgen_unit, printname // "%vx_cntr", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%vx_cntr, kgen_unit, printname // "%vx_cntr", .FALSE.) 
      END IF   
        
      IF (PRESENT( printvar ) .AND. printvar) THEN 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%vy_cntr, kgen_unit, printname // "%vy_cntr", .TRUE.) 
      ELSE 
          CALL kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var%vy_cntr, kgen_unit, printname // "%vy_cntr", .FALSE.) 
      END IF   
        
  END SUBROUTINE kr_cvmix_kinds_and_types_cvmix_data_type 
    
  !write state subroutine for kr_cvmix_data_type_real__cvmix_r8_dim1_ptr 
  SUBROUTINE kr_cvmix_data_type_real__cvmix_r8_dim1_ptr(var, kgen_unit, printname, printvar) 
      REAL(KIND=cvmix_r8), INTENT(INOUT), POINTER, DIMENSION(:) :: var 
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
        
  END SUBROUTINE kr_cvmix_data_type_real__cvmix_r8_dim1_ptr 
    
  !write state subroutine for kr_cvmix_data_type_real__cvmix_r8_dim2_ptr 
  SUBROUTINE kr_cvmix_data_type_real__cvmix_r8_dim2_ptr(var, kgen_unit, printname, printvar) 
      REAL(KIND=cvmix_r8), INTENT(INOUT), POINTER, DIMENSION(:,:) :: var 
      INTEGER, INTENT(IN) :: kgen_unit 
      CHARACTER(LEN=*), INTENT(IN) :: printname 
      LOGICAL, INTENT(IN), OPTIONAL :: printvar 
      LOGICAL :: kgen_istrue 
      REAL(KIND=8) :: kgen_array_sum 
      INTEGER :: idx1, idx2 
      INTEGER, DIMENSION(2,2) :: kgen_bound 
        
      READ (UNIT = kgen_unit) kgen_istrue 
      IF (kgen_istrue) THEN 
          IF (ASSOCIATED( var )) THEN 
              NULLIFY (var) 
          END IF   
          READ (UNIT = kgen_unit) kgen_array_sum 
          READ (UNIT = kgen_unit) kgen_bound(1, 1) 
          READ (UNIT = kgen_unit) kgen_bound(2, 1) 
          READ (UNIT = kgen_unit) kgen_bound(1, 2) 
          READ (UNIT = kgen_unit) kgen_bound(2, 2) 
          ALLOCATE (var(kgen_bound(1,1):kgen_bound(2,1), kgen_bound(1,2):kgen_bound(2,2))) 
          READ (UNIT = kgen_unit) var 
          CALL kgen_array_sumcheck(printname, kgen_array_sum, DBLE(SUM(var, mask=(var .eq. var))), .TRUE.) 
          IF (PRESENT( printvar ) .AND. printvar) THEN 
              WRITE (*, *) "KGEN DEBUG: DBLE(SUM(" // printname // ")) = ", DBLE(SUM(var, mask=(var .eq. var))) 
          END IF   
      END IF   
        
  END SUBROUTINE kr_cvmix_data_type_real__cvmix_r8_dim2_ptr 
    
  !verify state subroutine for kv_cvmix_kinds_and_types_cvmix_data_type 
  RECURSIVE SUBROUTINE kv_cvmix_kinds_and_types_cvmix_data_type(varname, check_status, var, kgenref_var) 
      CHARACTER(LEN=*), INTENT(IN) :: varname 
      TYPE(check_t), INTENT(INOUT) :: check_status 
      TYPE(cvmix_data_type), INTENT(IN) :: var, kgenref_var 
      TYPE(check_t) :: dtype_check_status, comp_check_status 
      INTEGER :: check_result 
      LOGICAL :: is_print = .FALSE. 
        
      integer :: diff_nlev 
      integer :: diff_max_nlev 
      real(KIND=cvmix_r8) :: diff_oceandepth 
      real(KIND=cvmix_r8) :: diff_boundarylayerdepth 
      real(KIND=cvmix_r8) :: diff_seasurfaceheight 
      real(KIND=cvmix_r8) :: diff_surfacefriction 
      real(KIND=cvmix_r8) :: diff_surfacebuoyancyforcing 
      real(KIND=cvmix_r8) :: diff_lat 
      real(KIND=cvmix_r8) :: diff_lon 
      real(KIND=cvmix_r8) :: diff_coriolis 
      real(KIND=cvmix_r8) :: diff_kobl_depth 
      real(KIND=cvmix_r8) :: diff_langmuirenhancementfactor 
      real(KIND=cvmix_r8) :: diff_surfacestokesdrift 
      real(KIND=cvmix_r8) :: diff_simmonscoeff 
      INTEGER :: n_zw_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_zw_iface, rmsdiff_zw_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_zw_iface(:), buf2_zw_iface(:) 
      INTEGER :: n_dzw 
      real(KIND=cvmix_r8) :: nrmsdiff_dzw, rmsdiff_dzw 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_dzw(:), buf2_dzw(:) 
      INTEGER :: n_mdiff_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_mdiff_iface, rmsdiff_mdiff_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_mdiff_iface(:), buf2_mdiff_iface(:) 
      INTEGER :: n_tdiff_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_tdiff_iface, rmsdiff_tdiff_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_tdiff_iface(:), buf2_tdiff_iface(:) 
      INTEGER :: n_sdiff_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_sdiff_iface, rmsdiff_sdiff_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_sdiff_iface(:), buf2_sdiff_iface(:) 
      INTEGER :: n_shearrichardson_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_shearrichardson_iface, rmsdiff_shearrichardson_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_shearrichardson_iface(:), buf2_shearrichardson_iface(:) 
      INTEGER :: n_sqrbuoyancyfreq_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_sqrbuoyancyfreq_iface, rmsdiff_sqrbuoyancyfreq_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_sqrbuoyancyfreq_iface(:), buf2_sqrbuoyancyfreq_iface(:) 
      INTEGER :: n_vertdep_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_vertdep_iface, rmsdiff_vertdep_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_vertdep_iface(:), buf2_vertdep_iface(:) 
      INTEGER :: n_schmittnercoeff 
      real(KIND=cvmix_r8) :: nrmsdiff_schmittnercoeff, rmsdiff_schmittnercoeff 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_schmittnercoeff(:), buf2_schmittnercoeff(:) 
      INTEGER :: n_schmittnersouthernocean 
      real(KIND=cvmix_r8) :: nrmsdiff_schmittnersouthernocean, rmsdiff_schmittnersouthernocean 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_schmittnersouthernocean(:), buf2_schmittnersouthernocean(:) 
      INTEGER :: n_exp_hab_zetar 
      real(KIND=cvmix_r8) :: nrmsdiff_exp_hab_zetar, rmsdiff_exp_hab_zetar 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_exp_hab_zetar(:,:), buf2_exp_hab_zetar(:,:) 
      INTEGER :: n_kpp_tnonlocal_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_kpp_tnonlocal_iface, rmsdiff_kpp_tnonlocal_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_kpp_tnonlocal_iface(:), buf2_kpp_tnonlocal_iface(:) 
      INTEGER :: n_kpp_snonlocal_iface 
      real(KIND=cvmix_r8) :: nrmsdiff_kpp_snonlocal_iface, rmsdiff_kpp_snonlocal_iface 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_kpp_snonlocal_iface(:), buf2_kpp_snonlocal_iface(:) 
      INTEGER :: n_zt_cntr 
      real(KIND=cvmix_r8) :: nrmsdiff_zt_cntr, rmsdiff_zt_cntr 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_zt_cntr(:), buf2_zt_cntr(:) 
      INTEGER :: n_dzt 
      real(KIND=cvmix_r8) :: nrmsdiff_dzt, rmsdiff_dzt 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_dzt(:), buf2_dzt(:) 
      INTEGER :: n_waterdensity_cntr 
      real(KIND=cvmix_r8) :: nrmsdiff_waterdensity_cntr, rmsdiff_waterdensity_cntr 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_waterdensity_cntr(:), buf2_waterdensity_cntr(:) 
      INTEGER :: n_adiabwaterdensity_cntr 
      real(KIND=cvmix_r8) :: nrmsdiff_adiabwaterdensity_cntr, rmsdiff_adiabwaterdensity_cntr 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_adiabwaterdensity_cntr(:), buf2_adiabwaterdensity_cntr(:) 
      INTEGER :: n_bulkrichardson_cntr 
      real(KIND=cvmix_r8) :: nrmsdiff_bulkrichardson_cntr, rmsdiff_bulkrichardson_cntr 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_bulkrichardson_cntr(:), buf2_bulkrichardson_cntr(:) 
      INTEGER :: n_strat_param_num 
      real(KIND=cvmix_r8) :: nrmsdiff_strat_param_num, rmsdiff_strat_param_num 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_strat_param_num(:), buf2_strat_param_num(:) 
      INTEGER :: n_strat_param_denom 
      real(KIND=cvmix_r8) :: nrmsdiff_strat_param_denom, rmsdiff_strat_param_denom 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_strat_param_denom(:), buf2_strat_param_denom(:) 
      INTEGER :: n_vx_cntr 
      real(KIND=cvmix_r8) :: nrmsdiff_vx_cntr, rmsdiff_vx_cntr 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_vx_cntr(:), buf2_vx_cntr(:) 
      INTEGER :: n_vy_cntr 
      real(KIND=cvmix_r8) :: nrmsdiff_vy_cntr, rmsdiff_vy_cntr 
      real(KIND=cvmix_r8), ALLOCATABLE :: buf1_vy_cntr(:), buf2_vy_cntr(:) 
        
      check_status%numTotal = check_status%numTotal + 1 
        
      CALL kgen_init_check(dtype_check_status, rank=check_status%rank) 
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%nlev == kgenref_var%nlev) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%nlev is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_nlev = ABS(var%nlev - kgenref_var%nlev) 
          IF (diff_nlev <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%nlev is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%nlev is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_nlev 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_nlev 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%max_nlev == kgenref_var%max_nlev) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%max_nlev is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_max_nlev = ABS(var%max_nlev - kgenref_var%max_nlev) 
          IF (diff_max_nlev <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%max_nlev is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%max_nlev is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_max_nlev 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_max_nlev 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%oceandepth == kgenref_var%oceandepth) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%oceandepth is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_oceandepth = ABS(var%oceandepth - kgenref_var%oceandepth) 
          IF (diff_oceandepth <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%oceandepth is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%oceandepth is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_oceandepth 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_oceandepth 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%boundarylayerdepth == kgenref_var%boundarylayerdepth) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%boundarylayerdepth is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_boundarylayerdepth = ABS(var%boundarylayerdepth - kgenref_var%boundarylayerdepth) 
          IF (diff_boundarylayerdepth <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%boundarylayerdepth is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%boundarylayerdepth is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_boundarylayerdepth 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_boundarylayerdepth 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%seasurfaceheight == kgenref_var%seasurfaceheight) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%seasurfaceheight is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_seasurfaceheight = ABS(var%seasurfaceheight - kgenref_var%seasurfaceheight) 
          IF (diff_seasurfaceheight <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%seasurfaceheight is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%seasurfaceheight is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_seasurfaceheight 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_seasurfaceheight 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%surfacefriction == kgenref_var%surfacefriction) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%surfacefriction is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_surfacefriction = ABS(var%surfacefriction - kgenref_var%surfacefriction) 
          IF (diff_surfacefriction <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%surfacefriction is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%surfacefriction is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_surfacefriction 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_surfacefriction 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%surfacebuoyancyforcing == kgenref_var%surfacebuoyancyforcing) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%surfacebuoyancyforcing is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_surfacebuoyancyforcing = ABS(var%surfacebuoyancyforcing - kgenref_var%surfacebuoyancyforcing) 
          IF (diff_surfacebuoyancyforcing <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%surfacebuoyancyforcing is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%surfacebuoyancyforcing is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_surfacebuoyancyforcing 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_surfacebuoyancyforcing 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%lat == kgenref_var%lat) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%lat is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_lat = ABS(var%lat - kgenref_var%lat) 
          IF (diff_lat <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%lat is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%lat is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_lat 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_lat 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%lon == kgenref_var%lon) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%lon is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_lon = ABS(var%lon - kgenref_var%lon) 
          IF (diff_lon <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%lon is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%lon is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_lon 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_lon 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%coriolis == kgenref_var%coriolis) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%coriolis is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_coriolis = ABS(var%coriolis - kgenref_var%coriolis) 
          IF (diff_coriolis <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%coriolis is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%coriolis is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_coriolis 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_coriolis 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%kobl_depth == kgenref_var%kobl_depth) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%kobl_depth is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_kobl_depth = ABS(var%kobl_depth - kgenref_var%kobl_depth) 
          IF (diff_kobl_depth <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%kobl_depth is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%kobl_depth is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_kobl_depth 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_kobl_depth 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%langmuirenhancementfactor == kgenref_var%langmuirenhancementfactor) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%langmuirenhancementfactor is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_langmuirenhancementfactor = ABS(var%langmuirenhancementfactor - kgenref_var%langmuirenhancementfactor) 
          IF (diff_langmuirenhancementfactor <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%langmuirenhancementfactor is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%langmuirenhancementfactor is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_langmuirenhancementfactor 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_langmuirenhancementfactor 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%surfacestokesdrift == kgenref_var%surfacestokesdrift) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%surfacestokesdrift is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_surfacestokesdrift = ABS(var%surfacestokesdrift - kgenref_var%surfacestokesdrift) 
          IF (diff_surfacestokesdrift <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%surfacestokesdrift is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%surfacestokesdrift is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_surfacestokesdrift 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_surfacestokesdrift 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
      IF (var%simmonscoeff == kgenref_var%simmonscoeff) THEN 
          dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank == 0) THEN 
                  WRITE (*, *) trim(adjustl(varname)), "%simmonscoeff is IDENTICAL." 
              END IF   
          END IF   
          check_result = CHECK_IDENTICAL 
      ELSE 
          diff_simmonscoeff = ABS(var%simmonscoeff - kgenref_var%simmonscoeff) 
          IF (diff_simmonscoeff <= kgen_tolerance) THEN 
              dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%simmonscoeff is NOT IDENTICAL(within tolerance)." 
                  END IF   
              END IF   
              check_result = CHECK_IN_TOL 
          ELSE 
              dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
              IF (kgen_verboseLevel > 1) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%simmonscoeff is NOT IDENTICAL(out of tolerance)." 
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
                  WRITE (*, *) "Difference is ", diff_simmonscoeff 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      ELSE IF (check_result == CHECK_IN_TOL) THEN 
          IF (kgen_verboseLevel > 2) THEN 
              IF (check_status%rank ==0) THEN 
                  WRITE (*, *) "Difference is ", diff_simmonscoeff 
                  WRITE (*, *) "" 
              END IF   
          END IF   
      END IF   
        
      IF (ASSOCIATED(var%zw_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%zw_iface == kgenref_var%zw_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%zw_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_zw_iface(SIZE(var%zw_iface,dim=1))) 
              ALLOCATE (buf2_zw_iface(SIZE(var%zw_iface,dim=1))) 
              n_zw_iface = COUNT(var%zw_iface /= kgenref_var%zw_iface) 
              WHERE ( ABS(kgenref_var%zw_iface) > kgen_minvalue ) 
                  buf1_zw_iface = ((var%zw_iface-kgenref_var%zw_iface)/kgenref_var%zw_iface)**2 
                  buf2_zw_iface = (var%zw_iface-kgenref_var%zw_iface)**2 
              ELSEWHERE 
                  buf1_zw_iface = (var%zw_iface-kgenref_var%zw_iface)**2 
                  buf2_zw_iface = buf1_zw_iface 
              END WHERE   
              nrmsdiff_zw_iface = SQRT(SUM(buf1_zw_iface)/REAL(n_zw_iface)) 
              rmsdiff_zw_iface = SQRT(SUM(buf2_zw_iface)/REAL(n_zw_iface)) 
              IF (rmsdiff_zw_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%zw_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%zw_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%zw_iface /= kgenref_var%zw_iface), " of ", size( var%zw_iface ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%zw_iface)/real(size(var%zw_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%zw_iface)/real(size(kgenref_var%zw_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_zw_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_zw_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%zw_iface /= kgenref_var%zw_iface), " of ", size( var%zw_iface ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%zw_iface)/real(size(var%zw_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%zw_iface)/real(size(kgenref_var%zw_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_zw_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_zw_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%dzw)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%dzw == kgenref_var%dzw)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%dzw is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_dzw(SIZE(var%dzw,dim=1))) 
              ALLOCATE (buf2_dzw(SIZE(var%dzw,dim=1))) 
              n_dzw = COUNT(var%dzw /= kgenref_var%dzw) 
              WHERE ( ABS(kgenref_var%dzw) > kgen_minvalue ) 
                  buf1_dzw = ((var%dzw-kgenref_var%dzw)/kgenref_var%dzw)**2 
                  buf2_dzw = (var%dzw-kgenref_var%dzw)**2 
              ELSEWHERE 
                  buf1_dzw = (var%dzw-kgenref_var%dzw)**2 
                  buf2_dzw = buf1_dzw 
              END WHERE   
              nrmsdiff_dzw = SQRT(SUM(buf1_dzw)/REAL(n_dzw)) 
              rmsdiff_dzw = SQRT(SUM(buf2_dzw)/REAL(n_dzw)) 
              IF (rmsdiff_dzw > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%dzw is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%dzw is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%dzw /= kgenref_var%dzw), " of ", size( var%dzw ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%dzw)/real(size(var%dzw)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%dzw)/real(size(kgenref_var%dzw)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_dzw 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_dzw 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%dzw /= kgenref_var%dzw), " of ", size( var%dzw ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%dzw)/real(size(var%dzw)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%dzw)/real(size(kgenref_var%dzw)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_dzw 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_dzw 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%mdiff_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%mdiff_iface == kgenref_var%mdiff_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%mdiff_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_mdiff_iface(SIZE(var%mdiff_iface,dim=1))) 
              ALLOCATE (buf2_mdiff_iface(SIZE(var%mdiff_iface,dim=1))) 
              n_mdiff_iface = COUNT(var%mdiff_iface /= kgenref_var%mdiff_iface) 
              WHERE ( ABS(kgenref_var%mdiff_iface) > kgen_minvalue ) 
                  buf1_mdiff_iface = ((var%mdiff_iface-kgenref_var%mdiff_iface)/kgenref_var%mdiff_iface)**2 
                  buf2_mdiff_iface = (var%mdiff_iface-kgenref_var%mdiff_iface)**2 
              ELSEWHERE 
                  buf1_mdiff_iface = (var%mdiff_iface-kgenref_var%mdiff_iface)**2 
                  buf2_mdiff_iface = buf1_mdiff_iface 
              END WHERE   
              nrmsdiff_mdiff_iface = SQRT(SUM(buf1_mdiff_iface)/REAL(n_mdiff_iface)) 
              rmsdiff_mdiff_iface = SQRT(SUM(buf2_mdiff_iface)/REAL(n_mdiff_iface)) 
              IF (rmsdiff_mdiff_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%mdiff_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%mdiff_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%mdiff_iface /= kgenref_var%mdiff_iface), " of ", size( var%mdiff_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%mdiff_iface)/real(size(var%mdiff_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%mdiff_iface)/real(size(kgenref_var%mdiff_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_mdiff_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_mdiff_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%mdiff_iface /= kgenref_var%mdiff_iface), " of ", size( var%mdiff_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%mdiff_iface)/real(size(var%mdiff_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%mdiff_iface)/real(size(kgenref_var%mdiff_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_mdiff_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_mdiff_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%tdiff_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%tdiff_iface == kgenref_var%tdiff_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%tdiff_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_tdiff_iface(SIZE(var%tdiff_iface,dim=1))) 
              ALLOCATE (buf2_tdiff_iface(SIZE(var%tdiff_iface,dim=1))) 
              n_tdiff_iface = COUNT(var%tdiff_iface /= kgenref_var%tdiff_iface) 
              WHERE ( ABS(kgenref_var%tdiff_iface) > kgen_minvalue ) 
                  buf1_tdiff_iface = ((var%tdiff_iface-kgenref_var%tdiff_iface)/kgenref_var%tdiff_iface)**2 
                  buf2_tdiff_iface = (var%tdiff_iface-kgenref_var%tdiff_iface)**2 
              ELSEWHERE 
                  buf1_tdiff_iface = (var%tdiff_iface-kgenref_var%tdiff_iface)**2 
                  buf2_tdiff_iface = buf1_tdiff_iface 
              END WHERE   
              nrmsdiff_tdiff_iface = SQRT(SUM(buf1_tdiff_iface)/REAL(n_tdiff_iface)) 
              rmsdiff_tdiff_iface = SQRT(SUM(buf2_tdiff_iface)/REAL(n_tdiff_iface)) 
              IF (rmsdiff_tdiff_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%tdiff_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%tdiff_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%tdiff_iface /= kgenref_var%tdiff_iface), " of ", size( var%tdiff_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%tdiff_iface)/real(size(var%tdiff_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%tdiff_iface)/real(size(kgenref_var%tdiff_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_tdiff_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_tdiff_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%tdiff_iface /= kgenref_var%tdiff_iface), " of ", size( var%tdiff_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%tdiff_iface)/real(size(var%tdiff_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%tdiff_iface)/real(size(kgenref_var%tdiff_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_tdiff_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_tdiff_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%sdiff_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%sdiff_iface == kgenref_var%sdiff_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%sdiff_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_sdiff_iface(SIZE(var%sdiff_iface,dim=1))) 
              ALLOCATE (buf2_sdiff_iface(SIZE(var%sdiff_iface,dim=1))) 
              n_sdiff_iface = COUNT(var%sdiff_iface /= kgenref_var%sdiff_iface) 
              WHERE ( ABS(kgenref_var%sdiff_iface) > kgen_minvalue ) 
                  buf1_sdiff_iface = ((var%sdiff_iface-kgenref_var%sdiff_iface)/kgenref_var%sdiff_iface)**2 
                  buf2_sdiff_iface = (var%sdiff_iface-kgenref_var%sdiff_iface)**2 
              ELSEWHERE 
                  buf1_sdiff_iface = (var%sdiff_iface-kgenref_var%sdiff_iface)**2 
                  buf2_sdiff_iface = buf1_sdiff_iface 
              END WHERE   
              nrmsdiff_sdiff_iface = SQRT(SUM(buf1_sdiff_iface)/REAL(n_sdiff_iface)) 
              rmsdiff_sdiff_iface = SQRT(SUM(buf2_sdiff_iface)/REAL(n_sdiff_iface)) 
              IF (rmsdiff_sdiff_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%sdiff_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%sdiff_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%sdiff_iface /= kgenref_var%sdiff_iface), " of ", size( var%sdiff_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%sdiff_iface)/real(size(var%sdiff_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%sdiff_iface)/real(size(kgenref_var%sdiff_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_sdiff_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_sdiff_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%sdiff_iface /= kgenref_var%sdiff_iface), " of ", size( var%sdiff_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%sdiff_iface)/real(size(var%sdiff_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%sdiff_iface)/real(size(kgenref_var%sdiff_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_sdiff_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_sdiff_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%shearrichardson_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%shearrichardson_iface == kgenref_var%shearrichardson_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%shearrichardson_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_shearrichardson_iface(SIZE(var%shearrichardson_iface,dim=1))) 
              ALLOCATE (buf2_shearrichardson_iface(SIZE(var%shearrichardson_iface,dim=1))) 
              n_shearrichardson_iface = COUNT(var%shearrichardson_iface /= kgenref_var%shearrichardson_iface) 
              WHERE ( ABS(kgenref_var%shearrichardson_iface) > kgen_minvalue ) 
                  buf1_shearrichardson_iface = &
                  &((var%shearrichardson_iface-kgenref_var%shearrichardson_iface)/kgenref_var%shearrichardson_iface)**2 
                  buf2_shearrichardson_iface = (var%shearrichardson_iface-kgenref_var%shearrichardson_iface)**2 
              ELSEWHERE 
                  buf1_shearrichardson_iface = (var%shearrichardson_iface-kgenref_var%shearrichardson_iface)**2 
                  buf2_shearrichardson_iface = buf1_shearrichardson_iface 
              END WHERE   
              nrmsdiff_shearrichardson_iface = SQRT(SUM(buf1_shearrichardson_iface)/REAL(n_shearrichardson_iface)) 
              rmsdiff_shearrichardson_iface = SQRT(SUM(buf2_shearrichardson_iface)/REAL(n_shearrichardson_iface)) 
              IF (rmsdiff_shearrichardson_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%shearrichardson_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%shearrichardson_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%shearrichardson_iface /= kgenref_var%shearrichardson_iface), " of ", size( &
                      &var%shearrichardson_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%shearrichardson_iface)/real(size(var%shearrichardson_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%shearrichardson_iface)/real(size(kgenref_var%shearrichardson_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_shearrichardson_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_shearrichardson_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%shearrichardson_iface /= kgenref_var%shearrichardson_iface), " of ", size( &
                      &var%shearrichardson_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%shearrichardson_iface)/real(size(var%shearrichardson_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%shearrichardson_iface)/real(size(kgenref_var%shearrichardson_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_shearrichardson_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_shearrichardson_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%sqrbuoyancyfreq_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%sqrbuoyancyfreq_iface == kgenref_var%sqrbuoyancyfreq_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%sqrbuoyancyfreq_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_sqrbuoyancyfreq_iface(SIZE(var%sqrbuoyancyfreq_iface,dim=1))) 
              ALLOCATE (buf2_sqrbuoyancyfreq_iface(SIZE(var%sqrbuoyancyfreq_iface,dim=1))) 
              n_sqrbuoyancyfreq_iface = COUNT(var%sqrbuoyancyfreq_iface /= kgenref_var%sqrbuoyancyfreq_iface) 
              WHERE ( ABS(kgenref_var%sqrbuoyancyfreq_iface) > kgen_minvalue ) 
                  buf1_sqrbuoyancyfreq_iface = &
                  &((var%sqrbuoyancyfreq_iface-kgenref_var%sqrbuoyancyfreq_iface)/kgenref_var%sqrbuoyancyfreq_iface)**2 
                  buf2_sqrbuoyancyfreq_iface = (var%sqrbuoyancyfreq_iface-kgenref_var%sqrbuoyancyfreq_iface)**2 
              ELSEWHERE 
                  buf1_sqrbuoyancyfreq_iface = (var%sqrbuoyancyfreq_iface-kgenref_var%sqrbuoyancyfreq_iface)**2 
                  buf2_sqrbuoyancyfreq_iface = buf1_sqrbuoyancyfreq_iface 
              END WHERE   
              nrmsdiff_sqrbuoyancyfreq_iface = SQRT(SUM(buf1_sqrbuoyancyfreq_iface)/REAL(n_sqrbuoyancyfreq_iface)) 
              rmsdiff_sqrbuoyancyfreq_iface = SQRT(SUM(buf2_sqrbuoyancyfreq_iface)/REAL(n_sqrbuoyancyfreq_iface)) 
              IF (rmsdiff_sqrbuoyancyfreq_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%sqrbuoyancyfreq_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%sqrbuoyancyfreq_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%sqrbuoyancyfreq_iface /= kgenref_var%sqrbuoyancyfreq_iface), " of ", size( &
                      &var%sqrbuoyancyfreq_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%sqrbuoyancyfreq_iface)/real(size(var%sqrbuoyancyfreq_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%sqrbuoyancyfreq_iface)/real(size(kgenref_var%sqrbuoyancyfreq_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_sqrbuoyancyfreq_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_sqrbuoyancyfreq_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%sqrbuoyancyfreq_iface /= kgenref_var%sqrbuoyancyfreq_iface), " of ", size( &
                      &var%sqrbuoyancyfreq_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%sqrbuoyancyfreq_iface)/real(size(var%sqrbuoyancyfreq_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%sqrbuoyancyfreq_iface)/real(size(kgenref_var%sqrbuoyancyfreq_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_sqrbuoyancyfreq_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_sqrbuoyancyfreq_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%vertdep_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%vertdep_iface == kgenref_var%vertdep_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%vertdep_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_vertdep_iface(SIZE(var%vertdep_iface,dim=1))) 
              ALLOCATE (buf2_vertdep_iface(SIZE(var%vertdep_iface,dim=1))) 
              n_vertdep_iface = COUNT(var%vertdep_iface /= kgenref_var%vertdep_iface) 
              WHERE ( ABS(kgenref_var%vertdep_iface) > kgen_minvalue ) 
                  buf1_vertdep_iface = ((var%vertdep_iface-kgenref_var%vertdep_iface)/kgenref_var%vertdep_iface)**2 
                  buf2_vertdep_iface = (var%vertdep_iface-kgenref_var%vertdep_iface)**2 
              ELSEWHERE 
                  buf1_vertdep_iface = (var%vertdep_iface-kgenref_var%vertdep_iface)**2 
                  buf2_vertdep_iface = buf1_vertdep_iface 
              END WHERE   
              nrmsdiff_vertdep_iface = SQRT(SUM(buf1_vertdep_iface)/REAL(n_vertdep_iface)) 
              rmsdiff_vertdep_iface = SQRT(SUM(buf2_vertdep_iface)/REAL(n_vertdep_iface)) 
              IF (rmsdiff_vertdep_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%vertdep_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%vertdep_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%vertdep_iface /= kgenref_var%vertdep_iface), " of ", size( var%vertdep_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%vertdep_iface)/real(size(var%vertdep_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%vertdep_iface)/real(size(kgenref_var%vertdep_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_vertdep_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_vertdep_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%vertdep_iface /= kgenref_var%vertdep_iface), " of ", size( var%vertdep_iface ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%vertdep_iface)/real(size(var%vertdep_iface)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%vertdep_iface)/real(size(kgenref_var%vertdep_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_vertdep_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_vertdep_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%schmittnercoeff)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%schmittnercoeff == kgenref_var%schmittnercoeff)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%schmittnercoeff is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_schmittnercoeff(SIZE(var%schmittnercoeff,dim=1))) 
              ALLOCATE (buf2_schmittnercoeff(SIZE(var%schmittnercoeff,dim=1))) 
              n_schmittnercoeff = COUNT(var%schmittnercoeff /= kgenref_var%schmittnercoeff) 
              WHERE ( ABS(kgenref_var%schmittnercoeff) > kgen_minvalue ) 
                  buf1_schmittnercoeff = ((var%schmittnercoeff-kgenref_var%schmittnercoeff)/kgenref_var%schmittnercoeff)**2 
                  buf2_schmittnercoeff = (var%schmittnercoeff-kgenref_var%schmittnercoeff)**2 
              ELSEWHERE 
                  buf1_schmittnercoeff = (var%schmittnercoeff-kgenref_var%schmittnercoeff)**2 
                  buf2_schmittnercoeff = buf1_schmittnercoeff 
              END WHERE   
              nrmsdiff_schmittnercoeff = SQRT(SUM(buf1_schmittnercoeff)/REAL(n_schmittnercoeff)) 
              rmsdiff_schmittnercoeff = SQRT(SUM(buf2_schmittnercoeff)/REAL(n_schmittnercoeff)) 
              IF (rmsdiff_schmittnercoeff > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%schmittnercoeff is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%schmittnercoeff is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%schmittnercoeff /= kgenref_var%schmittnercoeff), " of ", size( var%schmittnercoeff &
                      &), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%schmittnercoeff)/real(size(var%schmittnercoeff)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%schmittnercoeff)/real(size(kgenref_var%schmittnercoeff)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_schmittnercoeff 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_schmittnercoeff 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%schmittnercoeff /= kgenref_var%schmittnercoeff), " of ", size( var%schmittnercoeff &
                      &), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%schmittnercoeff)/real(size(var%schmittnercoeff)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%schmittnercoeff)/real(size(kgenref_var%schmittnercoeff)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_schmittnercoeff 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_schmittnercoeff 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%schmittnersouthernocean)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%schmittnersouthernocean == kgenref_var%schmittnersouthernocean)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%schmittnersouthernocean is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_schmittnersouthernocean(SIZE(var%schmittnersouthernocean,dim=1))) 
              ALLOCATE (buf2_schmittnersouthernocean(SIZE(var%schmittnersouthernocean,dim=1))) 
              n_schmittnersouthernocean = COUNT(var%schmittnersouthernocean /= kgenref_var%schmittnersouthernocean) 
              WHERE ( ABS(kgenref_var%schmittnersouthernocean) > kgen_minvalue ) 
                  buf1_schmittnersouthernocean = &
                  &((var%schmittnersouthernocean-kgenref_var%schmittnersouthernocean)/kgenref_var%schmittnersouthernocean)**2 
                  buf2_schmittnersouthernocean = (var%schmittnersouthernocean-kgenref_var%schmittnersouthernocean)**2 
              ELSEWHERE 
                  buf1_schmittnersouthernocean = (var%schmittnersouthernocean-kgenref_var%schmittnersouthernocean)**2 
                  buf2_schmittnersouthernocean = buf1_schmittnersouthernocean 
              END WHERE   
              nrmsdiff_schmittnersouthernocean = SQRT(SUM(buf1_schmittnersouthernocean)/REAL(n_schmittnersouthernocean)) 
              rmsdiff_schmittnersouthernocean = SQRT(SUM(buf2_schmittnersouthernocean)/REAL(n_schmittnersouthernocean)) 
              IF (rmsdiff_schmittnersouthernocean > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%schmittnersouthernocean is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%schmittnersouthernocean is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%schmittnersouthernocean /= kgenref_var%schmittnersouthernocean), " of ", size( &
                      &var%schmittnersouthernocean ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%schmittnersouthernocean)/real(size(var%schmittnersouthernocean)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%schmittnersouthernocean)/real(size(kgenref_var%schmittnersouthernocean)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_schmittnersouthernocean 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_schmittnersouthernocean 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%schmittnersouthernocean /= kgenref_var%schmittnersouthernocean), " of ", size( &
                      &var%schmittnersouthernocean ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%schmittnersouthernocean)/real(size(var%schmittnersouthernocean)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%schmittnersouthernocean)/real(size(kgenref_var%schmittnersouthernocean)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_schmittnersouthernocean 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_schmittnersouthernocean 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%exp_hab_zetar)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%exp_hab_zetar == kgenref_var%exp_hab_zetar)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%exp_hab_zetar is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_exp_hab_zetar(SIZE(var%exp_hab_zetar,dim=1),SIZE(var%exp_hab_zetar,dim=2))) 
              ALLOCATE (buf2_exp_hab_zetar(SIZE(var%exp_hab_zetar,dim=1),SIZE(var%exp_hab_zetar,dim=2))) 
              n_exp_hab_zetar = COUNT(var%exp_hab_zetar /= kgenref_var%exp_hab_zetar) 
              WHERE ( ABS(kgenref_var%exp_hab_zetar) > kgen_minvalue ) 
                  buf1_exp_hab_zetar = ((var%exp_hab_zetar-kgenref_var%exp_hab_zetar)/kgenref_var%exp_hab_zetar)**2 
                  buf2_exp_hab_zetar = (var%exp_hab_zetar-kgenref_var%exp_hab_zetar)**2 
              ELSEWHERE 
                  buf1_exp_hab_zetar = (var%exp_hab_zetar-kgenref_var%exp_hab_zetar)**2 
                  buf2_exp_hab_zetar = buf1_exp_hab_zetar 
              END WHERE   
              nrmsdiff_exp_hab_zetar = SQRT(SUM(buf1_exp_hab_zetar)/REAL(n_exp_hab_zetar)) 
              rmsdiff_exp_hab_zetar = SQRT(SUM(buf2_exp_hab_zetar)/REAL(n_exp_hab_zetar)) 
              IF (rmsdiff_exp_hab_zetar > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%exp_hab_zetar is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%exp_hab_zetar is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%exp_hab_zetar /= kgenref_var%exp_hab_zetar), " of ", size( var%exp_hab_zetar ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%exp_hab_zetar)/real(size(var%exp_hab_zetar)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%exp_hab_zetar)/real(size(kgenref_var%exp_hab_zetar)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_exp_hab_zetar 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_exp_hab_zetar 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%exp_hab_zetar /= kgenref_var%exp_hab_zetar), " of ", size( var%exp_hab_zetar ), " &
                      &elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%exp_hab_zetar)/real(size(var%exp_hab_zetar)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%exp_hab_zetar)/real(size(kgenref_var%exp_hab_zetar)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_exp_hab_zetar 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_exp_hab_zetar 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%kpp_tnonlocal_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%kpp_tnonlocal_iface == kgenref_var%kpp_tnonlocal_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%kpp_tnonlocal_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_kpp_tnonlocal_iface(SIZE(var%kpp_tnonlocal_iface,dim=1))) 
              ALLOCATE (buf2_kpp_tnonlocal_iface(SIZE(var%kpp_tnonlocal_iface,dim=1))) 
              n_kpp_tnonlocal_iface = COUNT(var%kpp_tnonlocal_iface /= kgenref_var%kpp_tnonlocal_iface) 
              WHERE ( ABS(kgenref_var%kpp_tnonlocal_iface) > kgen_minvalue ) 
                  buf1_kpp_tnonlocal_iface = &
                  &((var%kpp_tnonlocal_iface-kgenref_var%kpp_tnonlocal_iface)/kgenref_var%kpp_tnonlocal_iface)**2 
                  buf2_kpp_tnonlocal_iface = (var%kpp_tnonlocal_iface-kgenref_var%kpp_tnonlocal_iface)**2 
              ELSEWHERE 
                  buf1_kpp_tnonlocal_iface = (var%kpp_tnonlocal_iface-kgenref_var%kpp_tnonlocal_iface)**2 
                  buf2_kpp_tnonlocal_iface = buf1_kpp_tnonlocal_iface 
              END WHERE   
              nrmsdiff_kpp_tnonlocal_iface = SQRT(SUM(buf1_kpp_tnonlocal_iface)/REAL(n_kpp_tnonlocal_iface)) 
              rmsdiff_kpp_tnonlocal_iface = SQRT(SUM(buf2_kpp_tnonlocal_iface)/REAL(n_kpp_tnonlocal_iface)) 
              IF (rmsdiff_kpp_tnonlocal_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%kpp_tnonlocal_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%kpp_tnonlocal_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%kpp_tnonlocal_iface /= kgenref_var%kpp_tnonlocal_iface), " of ", size( &
                      &var%kpp_tnonlocal_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%kpp_tnonlocal_iface)/real(size(var%kpp_tnonlocal_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%kpp_tnonlocal_iface)/real(size(kgenref_var%kpp_tnonlocal_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_kpp_tnonlocal_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_kpp_tnonlocal_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%kpp_tnonlocal_iface /= kgenref_var%kpp_tnonlocal_iface), " of ", size( &
                      &var%kpp_tnonlocal_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%kpp_tnonlocal_iface)/real(size(var%kpp_tnonlocal_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%kpp_tnonlocal_iface)/real(size(kgenref_var%kpp_tnonlocal_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_kpp_tnonlocal_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_kpp_tnonlocal_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%kpp_snonlocal_iface)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%kpp_snonlocal_iface == kgenref_var%kpp_snonlocal_iface)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%kpp_snonlocal_iface is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_kpp_snonlocal_iface(SIZE(var%kpp_snonlocal_iface,dim=1))) 
              ALLOCATE (buf2_kpp_snonlocal_iface(SIZE(var%kpp_snonlocal_iface,dim=1))) 
              n_kpp_snonlocal_iface = COUNT(var%kpp_snonlocal_iface /= kgenref_var%kpp_snonlocal_iface) 
              WHERE ( ABS(kgenref_var%kpp_snonlocal_iface) > kgen_minvalue ) 
                  buf1_kpp_snonlocal_iface = &
                  &((var%kpp_snonlocal_iface-kgenref_var%kpp_snonlocal_iface)/kgenref_var%kpp_snonlocal_iface)**2 
                  buf2_kpp_snonlocal_iface = (var%kpp_snonlocal_iface-kgenref_var%kpp_snonlocal_iface)**2 
              ELSEWHERE 
                  buf1_kpp_snonlocal_iface = (var%kpp_snonlocal_iface-kgenref_var%kpp_snonlocal_iface)**2 
                  buf2_kpp_snonlocal_iface = buf1_kpp_snonlocal_iface 
              END WHERE   
              nrmsdiff_kpp_snonlocal_iface = SQRT(SUM(buf1_kpp_snonlocal_iface)/REAL(n_kpp_snonlocal_iface)) 
              rmsdiff_kpp_snonlocal_iface = SQRT(SUM(buf2_kpp_snonlocal_iface)/REAL(n_kpp_snonlocal_iface)) 
              IF (rmsdiff_kpp_snonlocal_iface > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%kpp_snonlocal_iface is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%kpp_snonlocal_iface is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%kpp_snonlocal_iface /= kgenref_var%kpp_snonlocal_iface), " of ", size( &
                      &var%kpp_snonlocal_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%kpp_snonlocal_iface)/real(size(var%kpp_snonlocal_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%kpp_snonlocal_iface)/real(size(kgenref_var%kpp_snonlocal_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_kpp_snonlocal_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_kpp_snonlocal_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%kpp_snonlocal_iface /= kgenref_var%kpp_snonlocal_iface), " of ", size( &
                      &var%kpp_snonlocal_iface ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%kpp_snonlocal_iface)/real(size(var%kpp_snonlocal_iface)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%kpp_snonlocal_iface)/real(size(kgenref_var%kpp_snonlocal_iface)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_kpp_snonlocal_iface 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_kpp_snonlocal_iface 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%zt_cntr)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%zt_cntr == kgenref_var%zt_cntr)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%zt_cntr is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_zt_cntr(SIZE(var%zt_cntr,dim=1))) 
              ALLOCATE (buf2_zt_cntr(SIZE(var%zt_cntr,dim=1))) 
              n_zt_cntr = COUNT(var%zt_cntr /= kgenref_var%zt_cntr) 
              WHERE ( ABS(kgenref_var%zt_cntr) > kgen_minvalue ) 
                  buf1_zt_cntr = ((var%zt_cntr-kgenref_var%zt_cntr)/kgenref_var%zt_cntr)**2 
                  buf2_zt_cntr = (var%zt_cntr-kgenref_var%zt_cntr)**2 
              ELSEWHERE 
                  buf1_zt_cntr = (var%zt_cntr-kgenref_var%zt_cntr)**2 
                  buf2_zt_cntr = buf1_zt_cntr 
              END WHERE   
              nrmsdiff_zt_cntr = SQRT(SUM(buf1_zt_cntr)/REAL(n_zt_cntr)) 
              rmsdiff_zt_cntr = SQRT(SUM(buf2_zt_cntr)/REAL(n_zt_cntr)) 
              IF (rmsdiff_zt_cntr > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%zt_cntr is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%zt_cntr is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%zt_cntr /= kgenref_var%zt_cntr), " of ", size( var%zt_cntr ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%zt_cntr)/real(size(var%zt_cntr)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%zt_cntr)/real(size(kgenref_var%zt_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_zt_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_zt_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%zt_cntr /= kgenref_var%zt_cntr), " of ", size( var%zt_cntr ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%zt_cntr)/real(size(var%zt_cntr)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%zt_cntr)/real(size(kgenref_var%zt_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_zt_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_zt_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%dzt)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%dzt == kgenref_var%dzt)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%dzt is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_dzt(SIZE(var%dzt,dim=1))) 
              ALLOCATE (buf2_dzt(SIZE(var%dzt,dim=1))) 
              n_dzt = COUNT(var%dzt /= kgenref_var%dzt) 
              WHERE ( ABS(kgenref_var%dzt) > kgen_minvalue ) 
                  buf1_dzt = ((var%dzt-kgenref_var%dzt)/kgenref_var%dzt)**2 
                  buf2_dzt = (var%dzt-kgenref_var%dzt)**2 
              ELSEWHERE 
                  buf1_dzt = (var%dzt-kgenref_var%dzt)**2 
                  buf2_dzt = buf1_dzt 
              END WHERE   
              nrmsdiff_dzt = SQRT(SUM(buf1_dzt)/REAL(n_dzt)) 
              rmsdiff_dzt = SQRT(SUM(buf2_dzt)/REAL(n_dzt)) 
              IF (rmsdiff_dzt > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%dzt is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%dzt is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%dzt /= kgenref_var%dzt), " of ", size( var%dzt ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%dzt)/real(size(var%dzt)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%dzt)/real(size(kgenref_var%dzt)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_dzt 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_dzt 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%dzt /= kgenref_var%dzt), " of ", size( var%dzt ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%dzt)/real(size(var%dzt)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%dzt)/real(size(kgenref_var%dzt)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_dzt 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_dzt 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%waterdensity_cntr)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%waterdensity_cntr == kgenref_var%waterdensity_cntr)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%waterdensity_cntr is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_waterdensity_cntr(SIZE(var%waterdensity_cntr,dim=1))) 
              ALLOCATE (buf2_waterdensity_cntr(SIZE(var%waterdensity_cntr,dim=1))) 
              n_waterdensity_cntr = COUNT(var%waterdensity_cntr /= kgenref_var%waterdensity_cntr) 
              WHERE ( ABS(kgenref_var%waterdensity_cntr) > kgen_minvalue ) 
                  buf1_waterdensity_cntr = &
                  &((var%waterdensity_cntr-kgenref_var%waterdensity_cntr)/kgenref_var%waterdensity_cntr)**2 
                  buf2_waterdensity_cntr = (var%waterdensity_cntr-kgenref_var%waterdensity_cntr)**2 
              ELSEWHERE 
                  buf1_waterdensity_cntr = (var%waterdensity_cntr-kgenref_var%waterdensity_cntr)**2 
                  buf2_waterdensity_cntr = buf1_waterdensity_cntr 
              END WHERE   
              nrmsdiff_waterdensity_cntr = SQRT(SUM(buf1_waterdensity_cntr)/REAL(n_waterdensity_cntr)) 
              rmsdiff_waterdensity_cntr = SQRT(SUM(buf2_waterdensity_cntr)/REAL(n_waterdensity_cntr)) 
              IF (rmsdiff_waterdensity_cntr > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%waterdensity_cntr is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%waterdensity_cntr is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%waterdensity_cntr /= kgenref_var%waterdensity_cntr), " of ", size( &
                      &var%waterdensity_cntr ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%waterdensity_cntr)/real(size(var%waterdensity_cntr)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%waterdensity_cntr)/real(size(kgenref_var%waterdensity_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_waterdensity_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_waterdensity_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%waterdensity_cntr /= kgenref_var%waterdensity_cntr), " of ", size( &
                      &var%waterdensity_cntr ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%waterdensity_cntr)/real(size(var%waterdensity_cntr)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%waterdensity_cntr)/real(size(kgenref_var%waterdensity_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_waterdensity_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_waterdensity_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%adiabwaterdensity_cntr)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%adiabwaterdensity_cntr == kgenref_var%adiabwaterdensity_cntr)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%adiabwaterdensity_cntr is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_adiabwaterdensity_cntr(SIZE(var%adiabwaterdensity_cntr,dim=1))) 
              ALLOCATE (buf2_adiabwaterdensity_cntr(SIZE(var%adiabwaterdensity_cntr,dim=1))) 
              n_adiabwaterdensity_cntr = COUNT(var%adiabwaterdensity_cntr /= kgenref_var%adiabwaterdensity_cntr) 
              WHERE ( ABS(kgenref_var%adiabwaterdensity_cntr) > kgen_minvalue ) 
                  buf1_adiabwaterdensity_cntr = &
                  &((var%adiabwaterdensity_cntr-kgenref_var%adiabwaterdensity_cntr)/kgenref_var%adiabwaterdensity_cntr)**2 
                  buf2_adiabwaterdensity_cntr = (var%adiabwaterdensity_cntr-kgenref_var%adiabwaterdensity_cntr)**2 
              ELSEWHERE 
                  buf1_adiabwaterdensity_cntr = (var%adiabwaterdensity_cntr-kgenref_var%adiabwaterdensity_cntr)**2 
                  buf2_adiabwaterdensity_cntr = buf1_adiabwaterdensity_cntr 
              END WHERE   
              nrmsdiff_adiabwaterdensity_cntr = SQRT(SUM(buf1_adiabwaterdensity_cntr)/REAL(n_adiabwaterdensity_cntr)) 
              rmsdiff_adiabwaterdensity_cntr = SQRT(SUM(buf2_adiabwaterdensity_cntr)/REAL(n_adiabwaterdensity_cntr)) 
              IF (rmsdiff_adiabwaterdensity_cntr > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%adiabwaterdensity_cntr is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%adiabwaterdensity_cntr is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%adiabwaterdensity_cntr /= kgenref_var%adiabwaterdensity_cntr), " of ", size( &
                      &var%adiabwaterdensity_cntr ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%adiabwaterdensity_cntr)/real(size(var%adiabwaterdensity_cntr)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%adiabwaterdensity_cntr)/real(size(kgenref_var%adiabwaterdensity_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_adiabwaterdensity_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_adiabwaterdensity_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%adiabwaterdensity_cntr /= kgenref_var%adiabwaterdensity_cntr), " of ", size( &
                      &var%adiabwaterdensity_cntr ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%adiabwaterdensity_cntr)/real(size(var%adiabwaterdensity_cntr)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%adiabwaterdensity_cntr)/real(size(kgenref_var%adiabwaterdensity_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_adiabwaterdensity_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_adiabwaterdensity_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%bulkrichardson_cntr)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%bulkrichardson_cntr == kgenref_var%bulkrichardson_cntr)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%bulkrichardson_cntr is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_bulkrichardson_cntr(SIZE(var%bulkrichardson_cntr,dim=1))) 
              ALLOCATE (buf2_bulkrichardson_cntr(SIZE(var%bulkrichardson_cntr,dim=1))) 
              n_bulkrichardson_cntr = COUNT(var%bulkrichardson_cntr /= kgenref_var%bulkrichardson_cntr) 
              WHERE ( ABS(kgenref_var%bulkrichardson_cntr) > kgen_minvalue ) 
                  buf1_bulkrichardson_cntr = &
                  &((var%bulkrichardson_cntr-kgenref_var%bulkrichardson_cntr)/kgenref_var%bulkrichardson_cntr)**2 
                  buf2_bulkrichardson_cntr = (var%bulkrichardson_cntr-kgenref_var%bulkrichardson_cntr)**2 
              ELSEWHERE 
                  buf1_bulkrichardson_cntr = (var%bulkrichardson_cntr-kgenref_var%bulkrichardson_cntr)**2 
                  buf2_bulkrichardson_cntr = buf1_bulkrichardson_cntr 
              END WHERE   
              nrmsdiff_bulkrichardson_cntr = SQRT(SUM(buf1_bulkrichardson_cntr)/REAL(n_bulkrichardson_cntr)) 
              rmsdiff_bulkrichardson_cntr = SQRT(SUM(buf2_bulkrichardson_cntr)/REAL(n_bulkrichardson_cntr)) 
              IF (rmsdiff_bulkrichardson_cntr > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%bulkrichardson_cntr is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%bulkrichardson_cntr is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%bulkrichardson_cntr /= kgenref_var%bulkrichardson_cntr), " of ", size( &
                      &var%bulkrichardson_cntr ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%bulkrichardson_cntr)/real(size(var%bulkrichardson_cntr)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%bulkrichardson_cntr)/real(size(kgenref_var%bulkrichardson_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_bulkrichardson_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_bulkrichardson_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%bulkrichardson_cntr /= kgenref_var%bulkrichardson_cntr), " of ", size( &
                      &var%bulkrichardson_cntr ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%bulkrichardson_cntr)/real(size(var%bulkrichardson_cntr)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%bulkrichardson_cntr)/real(size(kgenref_var%bulkrichardson_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_bulkrichardson_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_bulkrichardson_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%strat_param_num)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%strat_param_num == kgenref_var%strat_param_num)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%strat_param_num is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_strat_param_num(SIZE(var%strat_param_num,dim=1))) 
              ALLOCATE (buf2_strat_param_num(SIZE(var%strat_param_num,dim=1))) 
              n_strat_param_num = COUNT(var%strat_param_num /= kgenref_var%strat_param_num) 
              WHERE ( ABS(kgenref_var%strat_param_num) > kgen_minvalue ) 
                  buf1_strat_param_num = ((var%strat_param_num-kgenref_var%strat_param_num)/kgenref_var%strat_param_num)**2 
                  buf2_strat_param_num = (var%strat_param_num-kgenref_var%strat_param_num)**2 
              ELSEWHERE 
                  buf1_strat_param_num = (var%strat_param_num-kgenref_var%strat_param_num)**2 
                  buf2_strat_param_num = buf1_strat_param_num 
              END WHERE   
              nrmsdiff_strat_param_num = SQRT(SUM(buf1_strat_param_num)/REAL(n_strat_param_num)) 
              rmsdiff_strat_param_num = SQRT(SUM(buf2_strat_param_num)/REAL(n_strat_param_num)) 
              IF (rmsdiff_strat_param_num > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%strat_param_num is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%strat_param_num is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%strat_param_num /= kgenref_var%strat_param_num), " of ", size( var%strat_param_num &
                      &), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%strat_param_num)/real(size(var%strat_param_num)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%strat_param_num)/real(size(kgenref_var%strat_param_num)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_strat_param_num 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_strat_param_num 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%strat_param_num /= kgenref_var%strat_param_num), " of ", size( var%strat_param_num &
                      &), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%strat_param_num)/real(size(var%strat_param_num)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%strat_param_num)/real(size(kgenref_var%strat_param_num)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_strat_param_num 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_strat_param_num 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%strat_param_denom)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%strat_param_denom == kgenref_var%strat_param_denom)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%strat_param_denom is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_strat_param_denom(SIZE(var%strat_param_denom,dim=1))) 
              ALLOCATE (buf2_strat_param_denom(SIZE(var%strat_param_denom,dim=1))) 
              n_strat_param_denom = COUNT(var%strat_param_denom /= kgenref_var%strat_param_denom) 
              WHERE ( ABS(kgenref_var%strat_param_denom) > kgen_minvalue ) 
                  buf1_strat_param_denom = &
                  &((var%strat_param_denom-kgenref_var%strat_param_denom)/kgenref_var%strat_param_denom)**2 
                  buf2_strat_param_denom = (var%strat_param_denom-kgenref_var%strat_param_denom)**2 
              ELSEWHERE 
                  buf1_strat_param_denom = (var%strat_param_denom-kgenref_var%strat_param_denom)**2 
                  buf2_strat_param_denom = buf1_strat_param_denom 
              END WHERE   
              nrmsdiff_strat_param_denom = SQRT(SUM(buf1_strat_param_denom)/REAL(n_strat_param_denom)) 
              rmsdiff_strat_param_denom = SQRT(SUM(buf2_strat_param_denom)/REAL(n_strat_param_denom)) 
              IF (rmsdiff_strat_param_denom > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%strat_param_denom is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%strat_param_denom is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%strat_param_denom /= kgenref_var%strat_param_denom), " of ", size( &
                      &var%strat_param_denom ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%strat_param_denom)/real(size(var%strat_param_denom)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%strat_param_denom)/real(size(kgenref_var%strat_param_denom)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_strat_param_denom 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_strat_param_denom 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%strat_param_denom /= kgenref_var%strat_param_denom), " of ", size( &
                      &var%strat_param_denom ), " elements are different." 
                      WRITE (*, *) "Average - kernel ", sum(var%strat_param_denom)/real(size(var%strat_param_denom)) 
                      WRITE (*, *) "Average - reference ", &
                      &sum(kgenref_var%strat_param_denom)/real(size(kgenref_var%strat_param_denom)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_strat_param_denom 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_strat_param_denom 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%vx_cntr)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%vx_cntr == kgenref_var%vx_cntr)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%vx_cntr is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_vx_cntr(SIZE(var%vx_cntr,dim=1))) 
              ALLOCATE (buf2_vx_cntr(SIZE(var%vx_cntr,dim=1))) 
              n_vx_cntr = COUNT(var%vx_cntr /= kgenref_var%vx_cntr) 
              WHERE ( ABS(kgenref_var%vx_cntr) > kgen_minvalue ) 
                  buf1_vx_cntr = ((var%vx_cntr-kgenref_var%vx_cntr)/kgenref_var%vx_cntr)**2 
                  buf2_vx_cntr = (var%vx_cntr-kgenref_var%vx_cntr)**2 
              ELSEWHERE 
                  buf1_vx_cntr = (var%vx_cntr-kgenref_var%vx_cntr)**2 
                  buf2_vx_cntr = buf1_vx_cntr 
              END WHERE   
              nrmsdiff_vx_cntr = SQRT(SUM(buf1_vx_cntr)/REAL(n_vx_cntr)) 
              rmsdiff_vx_cntr = SQRT(SUM(buf2_vx_cntr)/REAL(n_vx_cntr)) 
              IF (rmsdiff_vx_cntr > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%vx_cntr is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%vx_cntr is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%vx_cntr /= kgenref_var%vx_cntr), " of ", size( var%vx_cntr ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%vx_cntr)/real(size(var%vx_cntr)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%vx_cntr)/real(size(kgenref_var%vx_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_vx_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_vx_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%vx_cntr /= kgenref_var%vx_cntr), " of ", size( var%vx_cntr ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%vx_cntr)/real(size(var%vx_cntr)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%vx_cntr)/real(size(kgenref_var%vx_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_vx_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_vx_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          END IF   
            
      END IF   
      IF (ASSOCIATED(var%vy_cntr)) THEN 
          dtype_check_status%numTotal = dtype_check_status%numTotal + 1 
          IF (ALL(var%vy_cntr == kgenref_var%vy_cntr)) THEN 
              dtype_check_status%numIdentical = dtype_check_status%numIdentical + 1 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank == 0) THEN 
                      WRITE (*, *) trim(adjustl(varname)), "%vy_cntr is IDENTICAL." 
                  END IF   
              END IF   
              check_result = CHECK_IDENTICAL 
          ELSE 
              ALLOCATE (buf1_vy_cntr(SIZE(var%vy_cntr,dim=1))) 
              ALLOCATE (buf2_vy_cntr(SIZE(var%vy_cntr,dim=1))) 
              n_vy_cntr = COUNT(var%vy_cntr /= kgenref_var%vy_cntr) 
              WHERE ( ABS(kgenref_var%vy_cntr) > kgen_minvalue ) 
                  buf1_vy_cntr = ((var%vy_cntr-kgenref_var%vy_cntr)/kgenref_var%vy_cntr)**2 
                  buf2_vy_cntr = (var%vy_cntr-kgenref_var%vy_cntr)**2 
              ELSEWHERE 
                  buf1_vy_cntr = (var%vy_cntr-kgenref_var%vy_cntr)**2 
                  buf2_vy_cntr = buf1_vy_cntr 
              END WHERE   
              nrmsdiff_vy_cntr = SQRT(SUM(buf1_vy_cntr)/REAL(n_vy_cntr)) 
              rmsdiff_vy_cntr = SQRT(SUM(buf2_vy_cntr)/REAL(n_vy_cntr)) 
              IF (rmsdiff_vy_cntr > kgen_tolerance) THEN 
                  dtype_check_status%numOutTol = dtype_check_status%numOutTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%vy_cntr is NOT IDENTICAL(out of tolerance)." 
                      END IF   
                  END IF   
                  check_result = CHECK_OUT_TOL 
              ELSE 
                  dtype_check_status%numInTol = dtype_check_status%numInTol + 1 
                  IF (kgen_verboseLevel > 1) THEN 
                      IF (check_status%rank == 0) THEN 
                          WRITE (*, *) trim(adjustl(varname)), "%vy_cntr is NOT IDENTICAL(within tolerance)." 
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
                      WRITE (*, *) count( var%vy_cntr /= kgenref_var%vy_cntr), " of ", size( var%vy_cntr ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%vy_cntr)/real(size(var%vy_cntr)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%vy_cntr)/real(size(kgenref_var%vy_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_vy_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_vy_cntr 
                      WRITE (*, *) "" 
                  END IF   
              END IF   
          ELSE IF (check_result == CHECK_IN_TOL) THEN 
              IF (kgen_verboseLevel > 2) THEN 
                  IF (check_status%rank ==0) THEN 
                      WRITE (*, *) count( var%vy_cntr /= kgenref_var%vy_cntr), " of ", size( var%vy_cntr ), " elements are &
                      &different." 
                      WRITE (*, *) "Average - kernel ", sum(var%vy_cntr)/real(size(var%vy_cntr)) 
                      WRITE (*, *) "Average - reference ", sum(kgenref_var%vy_cntr)/real(size(kgenref_var%vy_cntr)) 
                      WRITE (*, *) "RMS of difference is ", rmsdiff_vy_cntr 
                      WRITE (*, *) "Normalized RMS of difference is ", nrmsdiff_vy_cntr 
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
  END SUBROUTINE kv_cvmix_kinds_and_types_cvmix_data_type 
    
end module cvmix_kinds_and_types
