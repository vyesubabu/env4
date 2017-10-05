program score_vs_anal

!
!!   This program computes the rmse of a field vs its own analysis
!
!

  implicit none

! variables externes avec leur intent
!  integer, intent(in) :: nlines
!  character(len=14), intent(in) :: infile

!! pour getarg
  !external getarg  
  character*80    argv(50),anal_file, ech_file, NPoints
  integer*4       argc
  integer :: N_output_files,nargs
  integer :: unit_in, unit_in_ech, unit_out

  character(len=15) :: out_f
  character(len=14),dimension (1) :: output_filenames

  real :: lat,lon,value
  integer :: level, ech
  integer*8 :: date, date_e
  real :: lat_e,lon_e,value_e
  integer :: level_e, ech_e

  real :: minvalue, maxvalue, avgval
  real :: sqe,mse,rmsd 
  integer :: count_p,i

  output_filenames=(/"SCORE_RMS.out"/) 
  N_output_files=1

  nargs=iargc()
  do argc=1,nargs
     call getarg(argc,argv(argc))
     if (nargs == 3) then 
        anal_file=argv(1)
        ech_file=argv(2)
        NPoints=argv(3)
     endif 
     write(6,'(" Argument ",I2," is ",A)') argc, argv(argc)
  enddo
 

!!! OPEN ALL FILES
do i=1,N_output_files
   unit_out=20+i
   out_f=output_filenames(i)
   open(unit_out,file=out_f)
   write(*,*) "File ",out_f," opened in unit ",unit_out
enddo

unit_in=10
open(unit_in,file=anal_file)

unit_in_ech=11
open(unit_in_ech,file=ech_file)

! Initialise the counters
!line_counter=0

minvalue=99999999.
maxvalue=-99999999.
avgval=0.
count_p=0

!!! Dealing with END OF FILE: When the EOF location is not known, one needs to specify END or ERR in the read statement
!100    read(unit,'(4X,F11.5,7X,F11.5)',ERR=111)  can be accepted by g95; for pgf90 use END=111 strictly

100    read(unit_in,*,END=111) lat, lon, level, date, ech, value
200    read(unit_in_ech,*,END=112) lat_e, lon_e, level_e, date_e, ech_e, value_e
 if (( lat == -90.0 ) .OR. ( lat == 90.0 )) then
   if ( lon == 0.0 ) then
     sqe = (value_e - value)**2.0
     avgval = avgval + sqe       
     count_p = count_p + 1
     write(21,*) lat, lon, level, date, ech_e, sqrt(sqe)
   else
     !write(*,*) "Not Duplicating polar points!! Computing only for lon=0°"
   endif
 else
  
   sqe = (value_e - value)**2.0
   avgval = avgval + sqe       
   count_p = count_p + 1

   write(21,*) lat, lon, level, date, ech_e, sqrt(sqe)
       
 endif
 

goto 100 !!! END OF LINE LOOP
111  close(unit_in)
112  close(unit_in_ech)

 write(*,*) "Number of gridpoints =", NPoints
 write(*,*) "Number of points used for computation =", count_p
 mse = avgval/count_p
 rmsd = sqrt(mse)

 write(21,*) "Total mean RMSD =", rmsd
 write(*,*) "Total mean RMSD =", rmsd

do i=1,N_output_files
   unit_out=20+i
   close(unit_out)
enddo

end program score_vs_anal
