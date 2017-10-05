program test_arg
character(80) :: buffer
narg = iargc ()
print *, "no. of args = ", narg
do i = 1, narg
    call getarg (i, buffer)
    print *, buffer
end do
end program test_arg
