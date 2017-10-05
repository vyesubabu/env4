!#include"fonctions_new.F90"
!#include"fonctions.F90"
program compute_thetaw
!!! 
!!   This program computes the value of THETAW from two RH and T text file
!
! To compile :
! . ./ENV64bits.intel.arns 
! $F90 compute_THETAW_GFSUS.F90 -o compute_THETAW_GFSUS.exe
!
!  USE CONSTANTES, ONLY: RDAM

!  implicit none
  
  REAL,PARAMETER :: SST=30.0, PS=1000.0
  REAL,PARAMETER :: PTOP=100.0, KEV0=273.15
  REAL,PARAMETER :: RO=1.3, G=9.81
  REAL,PARAMETER :: DETENTE=8.5E-3                 ! K / m
  REAL,PARAMETER :: TOLERANCE=0.01

  real :: ZP, ZH, ZT, ZT1, ZQS, ZQV, ZRH
  real :: ZP0, ZH0, ZT0, ZQS0, ZQV0, ZK
  real :: ZPTOP, ZPS, i
  real :: ZTHES, ZTHES0
  real :: ZTHES1, ZPSIP
  real :: ZTHETAW
  real :: ZLAT,ZLON

  integer :: ZECH,ZFR
  integer*8 :: ZDATE
  integer :: linecounter, unit_in, unit_in2

  character*12 :: ZSID
!! pour getarg
  external getarg  
  character*80    argv(50),inputfileT,inputfileRH
  integer*4       argc

  LOGICAL :: LLPRINT

  nargs=iargc()
  do argc=1,nargs
     call getarg(argc,argv(argc))
     inputfileT=argv(1)
     inputfileRH=argv(2)
  enddo

linecounter=0
LLPRINT=.TRUE.
LLPRINT=.FALSE.

unit_in=10
unit_in2=11
open(unit_in,file=inputfileT)
open(unit_in2,file=inputfileRH)

!write(*,*) inputfileT,inputfileRH
100    read(unit_in,*,END=111)  ZLAT,ZLON,ZP,ZDATE,ZFR,ZT
       read(unit_in2,*,END=112)  ZLAT,ZLON,ZP,ZDATE,ZFR,ZRH

linecounter=linecounter+1

!! The pressure must be given in Pa
ZP=ZP*100.0

!! The Temperature must be given in Kelvin
ZT=ZT

!! The relative humidity must be between in [0,1]
ZRH=ZRH/100.0

if (linecounter > 0) then 
        !! Because RH=e/es ~ qv/qs, we have:
        if (ZT >= 0.0 ) then

!! Relative Humidity (RH): With respect to water, it is the ratio (expressed as a percentage) of the actual mixing ratio (w) to the saturation mixing ratio (ws) with respect to water at the same temperature and pressure. RH = w / ws (to have %, we need to multiply by 100)

! Here ZQV is the mixing ratio.
            ZQV = ZRH * fth_qs(ZT,ZP)

!! ZTHETAW is then :

            ZK =  RD / RCPD
            ZTHETAW = fth_thetaw(ZP,ZT,ZQV)

            if (LLPRINT) then
                write(*,*) "ZLAT=", ZLAT
                write(*,*) "ZLON=", ZLON
                write(*,*) "ZDATE=", ZDATE
                write(*,*) "ZECH=", ZECH
                write(*,*) "ZP=", ZP
                write(*,*) "ZRH=", ZRH
                write(*,*) "ZT=", ZT
                write(*,*) "ZQV=", ZQV
                write(*,*) "ZTHETAW=", ZTHETAW
                write(*,*) " "
            end if
        end if
end if

write(*,674) ZLAT,ZLON,ZP/100.0,ZDATE,ZTHETAW
674 FORMAT (3(F12.5),I16,F10.5)  ! Test

goto 100 !!! END OF LINE LOOP

111  close(unit_in)
112  close(unit_in2)
!    close(unit_out)


end program compute_thetaw
