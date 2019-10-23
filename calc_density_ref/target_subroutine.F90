!> This module contains only the target subroutine, i.e., the subroutine called by the 
!! callsite of this kernel.

module target_subroutine_mod
  implicit none

!>@{ Parameters in the Wright equation of state
!real :: a0, a1, a2, b0, b1, b2, b3, b4, b5, c0, c1, c2, c3, c4, c5
!    One of the two following blocks of values should be commented out.
!  Following are the values for the full range formula.
!real, parameter :: a0 = 7.133718e-4, a1 = 2.724670e-7, a2 = -1.646582e-7
!real, parameter :: b0 = 5.613770e8,  b1 = 3.600337e6,  b2 = -3.727194e4
!real, parameter :: b3 = 1.660557e2,  b4 = 6.844158e5,  b5 = -8.389457e3
!real, parameter :: c0 = 1.609893e5,  c1 = 8.427815e2,  c2 = -6.931554
!real, parameter :: c3 = 3.869318e-2, c4 = -1.664201e2, c5 = -2.765195
! Following are the values for the reduced range formula.
real, parameter :: a0 = 7.057924e-4, a1 = 3.480336e-7, a2 = -1.112733e-7 ! a0/a1 ~= 2028 ; a0/a2 ~= -6343
real, parameter :: b0 = 5.790749e8,  b1 = 3.516535e6,  b2 = -4.002714e4  ! b0/b1 ~= 165  ; b0/b4 ~= 974
real, parameter :: b3 = 2.084372e2,  b4 = 5.944068e5,  b5 = -9.643486e3
real, parameter :: c0 = 1.704853e5,  c1 = 7.904722e2,  c2 = -7.984422    ! c0/c1 ~= 216  ; c0/c4 ~= -740
real, parameter :: c3 = 5.140652e-2, c4 = -2.302158e2, c5 = -3.079464
!!@}
  
contains

!> This subroutine computes the in situ density of sea water (rho in
!! [kg m-3]) from salinity (S [PSU]), potential temperature
!! (T [degC]), and pressure [Pa].  It uses the expression from
!! Wright, 1997, J. Atmos. Ocean. Tech., 14, 735-740.
subroutine calculate_density_array_wright_ref(T, S, pressure, rho, start, npts, rho_ref)
  real, dimension(:), intent(in)  :: T        !< potential temperature relative to the surface [degC].
  real, dimension(:), intent(in)  :: S        !< salinity [PSU].
  real, dimension(:), intent(in)  :: pressure !< pressure [Pa].
  real, dimension(:), intent(out) :: rho      !< in situ density [kg m-3].
  integer,            intent(in)  :: start    !< the starting point in the arrays.
  integer,            intent(in)  :: npts     !< the number of values to calculate.
  real,               intent(in)  :: rho_ref  !< A reference density [kg m-3].
  ! Original coded by R. Hallberg, 7/00, anomaly coded in 3/18.
  ! Local variables

  real :: al0, p0, lambda
  real :: al_TS, p_TSp, lam_TS, pa_000
  integer :: j

  pa_000 = (b0*(1.0 - a0*rho_ref) - rho_ref*c0)
  do j=start,start+npts-1
    al_TS = a1*T(j) +a2*S(j)
    al0 = a0 + al_TS
    p_TSp = pressure(j) + (b4*S(j) + T(j) * (b1 + (T(j)*(b2 + b3*T(j)) + b5*S(j))))
    lam_TS = c4*S(j) + T(j) * (c1 + (T(j)*(c2 + c3*T(j)) + c5*S(j)))
    ! The following two expressions are mathematically equivalent.
    ! rho(j) = (b0 + p0_TSp) / ((c0 + lam_TS) + al0*(b0 + p0_TSp)) - rho_ref

    rho(j) = (pa_000 + (p_TSp - rho_ref*(p_TSp*al0 + (b0*al_TS + lam_TS)))) / &
             ( (c0 + lam_TS) + al0*(b0 + p_TSp) )
  enddo

end subroutine calculate_density_array_wright_ref

end module target_subroutine_mod
