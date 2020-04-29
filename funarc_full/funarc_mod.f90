module funarc_mod
  implicit none
  integer, parameter :: ITERS = 10

contains

subroutine funarc_wrapper()
  real(kind=10) :: s1
!$kgen callsite funarc_call
  s1 = funarc()
!$kgen end callsite
end subroutine funarc_wrapper

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
