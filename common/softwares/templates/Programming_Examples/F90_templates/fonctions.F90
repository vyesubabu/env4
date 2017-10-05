MODULE CONSTANTES
! --------------------------------------------------------------
! //// Constantes physiques.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Auteur/author:   2006-01, J.M. Piriou d'après ARPEGE.
! Modifications:
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
SAVE
!
!-------------------------------------------------
! Nombre d'itérations de la boucle de Newton.
!-------------------------------------------------
!
INTEGER, PARAMETER :: NBITER=2
!      -----------------------------------------------------------------
!
!*       1.    DEFINE FUNDAMENTAL CONSTANTS.
!              -----------------------------
!
REAL, PARAMETER :: RPI=3.14159265358979 ! pi.
REAL, PARAMETER :: RCLUM=299792458. ! célérité de la lumière.
REAL, PARAMETER :: RHPLA=6.6260755E-34 ! cte de Planck.
REAL, PARAMETER :: RKBOL=1.380658E-23 ! cte de Bolzman.
REAL, PARAMETER :: RNAVO=6.0221367E+23 ! nombre d'Avogadro.
!
!     ------------------------------------------------------------------
!
!*       2.    DEFINE ASTRONOMICAL CONSTANTS.
!              ------------------------------
!
REAL, PARAMETER :: RDAY=86400. ! jour solaire.
REAL, PARAMETER :: REA=149597870000. ! demi-grand axe de rév. terrestre.
REAL, PARAMETER :: RSIYEA=365.25*RDAY*2.*RPI/6.283076 ! année sidérale.
REAL, PARAMETER :: RSIDAY=RDAY/(1.0+RDAY/RSIYEA) ! jour sidéral.
REAL, PARAMETER :: ROMEGA=2.*RPI/RSIDAY ! vitesse angulaire terrestre.
!
! ------------------------------------------------------------------
!
! *       3.    DEFINE GEOIDE.
! --------------
!
REAL, PARAMETER :: RG=9.80665 ! accélération de la pesanteur.
REAL, PARAMETER :: RA=6371229. ! rayon terrestre.
!
! ------------------------------------------------------------------
!
! *       4.    DEFINE RADIATION CONSTANTS.
! ---------------------------
!
!REAL, parameter :: rsigma=2. * rpi**5 * rkbol**4 /(15.* rclum**2 * rhpla**3) ! cte de Stefan-Bolzman.
REAL, PARAMETER :: RSIGMA=5.670509E-08
REAL, PARAMETER :: RI0=1370. ! cte solaire.
!
! ------------------------------------------------------------------
!
! *       5.    DEFINE THERMODYNAMIC CONSTANTS, GAS PHASE.
! ------------------------------------------
!
REAL, PARAMETER :: R=RNAVO*RKBOL ! cte des gaz parfaits.
REAL, PARAMETER :: RMD=28.9644
REAL, PARAMETER :: RMV=18.0153
REAL, PARAMETER :: RMO3=47.9942
REAL, PARAMETER :: RD=1000.*R/RMD ! cte spécifique de l'air sec.
REAL, PARAMETER :: RV=1000.*R/RMV ! cte spécifique de la vapeur d'eau.
REAL, PARAMETER :: RCPD=3.5*RD ! chaleur massique de l'air sec.
REAL, PARAMETER :: RCVD=RCPD-RD
REAL, PARAMETER :: RCPV=4. *RV ! chaleur massique de la vapeur d'eau.
REAL, PARAMETER :: RCVV=RCPV-RV
REAL, PARAMETER :: RKAPPA=RD/RCPD
REAL, PARAMETER :: RETV=RV/RD-1.0
!
REAL, PARAMETER :: RALPW =  .6022274788E+02
REAL, PARAMETER :: RBETW =  .6822400210E+04
REAL, PARAMETER :: RGAMW =  .5139266694E+01
!
REAL, PARAMETER :: RALPS =  .3262117981E+02
REAL, PARAMETER :: RBETS =  .6295421339E+04
REAL, PARAMETER :: RGAMS =  .5631331575E+00
!
REAL, PARAMETER :: RALPD = -.2760156808E+02
REAL, PARAMETER :: RBETD = -.5269788712E+03
REAL, PARAMETER :: RGAMD = -.4576133537E+01
! ------------------------------------------------------------------
!
! *       6.    DEFINE THERMODYNAMIC CONSTANTS, LIQUID PHASE.
! ---------------------------------------------
!
REAL, PARAMETER :: RCW=4218. ! chaleur massique de l'eau liquide.
!
! ------------------------------------------------------------------
!
! *       7.    DEFINE THERMODYNAMIC CONSTANTS, SOLID PHASE.
! --------------------------------------------
!
REAL, PARAMETER :: RCS=2106. ! chaleur massique de la glace.
!
! ------------------------------------------------------------------
!
! *       8.    DEFINE THERMODYNAMIC CONSTANTS, TRANSITION OF PHASE.
! ----------------------------------------------------
!
REAL, PARAMETER :: RTT=273.16 ! point triple de l'eau.
REAL, PARAMETER :: RDT=11.82
REAL, PARAMETER :: RLVTT=2.5008E+6 ! chaleur latente eau vapeur > eau liquide.
REAL, PARAMETER :: RLSTT=2.8345E+6 ! chaleur latente eau vapeur > eau glace.
REAL, PARAMETER :: RLVZER=RLVTT+RTT*(RCW-RCPV) ! chaleur latente de fusion à 0°K!
REAL, PARAMETER :: RLSZER=RLSTT+RTT*(RCS-RCPV) ! chaleur latente de sublimation à 0°K!
REAL, PARAMETER :: RLMLT=RLSTT-RLVTT ! chaleur latente eau liquide > eau glace.
REAL, PARAMETER :: RATM=100000. ! pression standard.
!
! ------------------------------------------------------------------
!
! *       9.    SATURATED VAPOUR PRESSURE.
! --------------------------
!
REAL, PARAMETER :: RESTT=611.14
!
!-------------------------------------------------
! Constante de Joule.
!-------------------------------------------------
!
REAL, PARAMETER :: RJOULE=4.184
!
END
SUBROUTINE FTH_CIN_CAPE(LDVERBOSE,KLEV,PT,PQV,PP,PRETAINED,PENTR,PCIN,PCAPE,KLC,KLFC &
  & ,KLNB,plc,plfc,plnb,KCLOUD,PMC,PTHETAE_TOP,PPREC)
! --------------------------------------------------------------
! //// *fth_cin_cape* Compute CIN, CAPE, and vertical location of clouds.
! --------------------------------------------------------------
! Subject:
! Method:
!  Ascents will be computed starting from each level of the input profile.
!  The parcel is raised from its level of origin LO to the level of condensation LC,
!  then to its level of free convection LFC (the parcel becomes buoyant),
!  then to the level of neutral buoyancy LNB, where the the parcel becomes unbuoyant.
! Externals:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
!    2008-12-22, J.M. Piriou: output of real data for pressure levels of LC, LFC and LNB.
! --------------------------------------------------------------
! In input:
! ----------
!  LOGICAL: ldverbose: debugging mode only: prints on standard output, if .true.; should be .false., usually.
!  INTEGER: klev: number of levels.
!  REAL: pt: temperature (K).
!  REAL: pqv: specific humidity (no dim).
!  REAL: pp: pressure (Pa).
! WARNING: pressure values are supposed to icrease from pp(1) to pp(klev).
!  REAL pretained: fraction of the condensates which is retained, i.e. which does not precipitate.
!       if pretained=1. ==> reversible moist ascent.
!                      it is assumed that all the parcel's condensed
!                      water is retained, thus liquid and ice sustents reduce the buoyancy.
!        if pretained=0. ==> "irreversible" (pseudo-adiabatic) moist ascent.
!                       liquid and ice sustents precipitate
!                       instantaneously and thus do not affect the buoyancy.
!       pretained can be used with values between 0. and 1..
!  REAL pentr: vertical entrainment coefficient
!       (in m**-1, useful range: between 0. (no entrainment) and 3.E-03 m**-1).
!
! In output:
! -----------
!  REAL: pcin (J/kg): CIN, Convection INhibition,
!         massic energy to raise the parcel from
!         LO to LC then to LFC (see above).
!         Only negative terms are cumulated.
!  REAL: pcape (J/kg): CAPE, Convection Available Potential Energy,
!         massic energy  provided by the raise of the parcel
!         from LFC to LNB (see above).
!         Only positive terms are cumulated.
!  INTEGER: klc(jlev) LC of the parcel raised from jlev (level number).
!  INTEGER: klfc(jlev) LFC of the parcel raised from jlev (level number).
!  INTEGER: klnb(jlev) LNB of the parcel raised from jlev (level number).
!  REAL   : plc(jlev) LC of the parcel raised from jlev (pressure level in Pa).
!  REAL   : plfc(jlev) LFC of the parcel raised from jlev (pressure level in Pa).
!  REAL   : plnb(jlev) LNB of the parcel raised from jlev (pressure level in Pa).
!  INTEGER: kcloud: 1 if convective cloud at this level,
!          2 if "close to saturation" cloud at this level,
!          0 if no cloud at this level.
!          If both convective and "near saturation" are present, the output is 1.
!  REAL: pmc (kg/m2/s): convective mass flux profile, for a parcel starting from the lowest level.
!  REAL: pthetae_top (K): array receiving the potential temperature of the parcel raised up to the LNB.
!  REAL: pprec (kg/m2): precipitations cumulated over all ascents.
! --------------------------------------------------------------
!
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY: RG,RTT
IMPLICIT NONE
!
INTEGER :: IPOS
INTEGER :: JLEV
INTEGER :: JLEV1
INTEGER :: KLEV
INTEGER :: KCLOUD(KLEV)
INTEGER :: KLC(KLEV), KLFC(KLEV), KLNB(KLEV)
INTEGER :: ILEVX
!
LOGICAL :: LDVERBOSE
LOGICAL :: LLSAT
LOGICAL :: LLBUOY
!
REAL :: plc(KLEV), plfc(KLEV), plnb(KLEV)
REAL :: PPREC
REAL :: ZDLOG
REAL :: ZPREC
REAL :: ZPRESS
REAL :: ZQS
REAL :: ZQV
REAL :: ZQV1,ZQV2
REAL :: ZRT
REAL :: ZT,PRETAINED,ZADD
REAL :: ZT1,ZT2,ZQL,ZQI,ZQC,fth_tv,fth_thetav,fth_thetavl,fth_thetal,fth_tvl
REAL :: ZBUOY,zdz
REAL :: ZBUOY_PREC
REAL :: PCAPE(KLEV)
REAL :: ZCAPE(KLEV)
REAL :: PCIN(KLEV)
REAL :: PP(KLEV)
REAL :: PQV(KLEV)
REAL :: PT(KLEV)
REAL :: PTHETAE_TOP(KLEV)
REAL :: PENTR,PMC(KLEV)
REAL :: fth_qs,fth_r_hum,fth_t_evol_ad_hum,fth_theta,fth_t_evol_ad_seche
REAL :: ZCAPEX,zsat,zsat_prec,zpress_prec,fth_pinterpole
!
!-------------------------------------------------
! Default initializations.
!-------------------------------------------------
!
!-------------------------------------------------
! Initialize to zero.
!-------------------------------------------------
!
!
!-------------------------------------------------
! pcin: CIN: <= 0.: vertical integral from surf. to current level
!            of the buoyancy force, where <= 0.
!-------------------------------------------------
!
PCIN=0.0
!
!-------------------------------------------------
! pcape: CAPE: >= 0.: vertical integral from surf. to current level
!            of the buoyancy force, where >= 0.
!-------------------------------------------------
!
PCAPE=0.0
!
!-------------------------------------------------
! zcape: vertical integral from surf. to current level
!        of the buoyancy force, everywhere!
!-------------------------------------------------
!
ZCAPE=0.0
!
!-------------------------------------------------
! Mass flux.
!-------------------------------------------------
!
PMC=0.0
!
!-------------------------------------------------
! Integer levels.
!-------------------------------------------------
!
KLC=0 ; KLFC=0 ; KLNB=0
plc=0.0 ; plfc=0.0 ; plnb=0.0
KCLOUD=0
PTHETAE_TOP=0.0
PPREC=0.0
!
!-------------------------------------------------
! Loop over origin of ascents.
! This loop can be done indifferently upwards or downwards.
!-------------------------------------------------
!
DO JLEV1=KLEV,1,-1
  !
  ! -------------------------------------------------
  ! ipos:
  ! 0 if parcel between LO and LC.
  ! 1 if parcel between LC and LFC.
  ! 2 if parcel between LFC and LNB.
  ! 3 if parcel between LNB and top of profile.
  ! -------------------------------------------------
  !
  IPOS=0
  !
  ! -------------------------------------------------
  ! Diagnostic: kcloud=2 if close to saturation.
  ! -------------------------------------------------
  !
  IF(PQV(JLEV1)/FTH_QS(PT(JLEV1),PP(JLEV1)) > 0.9) THEN
    !
    ! -------------------------------------------------
    ! "Near saturation" cloud.
    ! -------------------------------------------------
    !
    KCLOUD(JLEV1)=2
  ENDIF
  !
  ! -------------------------------------------------
  ! For each LO, one will raise the parcel up to the top.
  ! -------------------------------------------------
  !
  ZT=PT(JLEV1)
  ZQV=PQV(JLEV1)
  ZPREC=0.0
  ZQL=0.0
  ZQI=0.0
  DO JLEV=JLEV1,2,-1
    !
    ! -------------------------------------------------
    ! Saturation specific humidity.
    ! -------------------------------------------------
    !
    ZQS=FTH_QS(ZT,PP(JLEV))
    !
    ! -------------------------------------------------
    ! Pressure and saturation.
    ! -------------------------------------------------
    !
    ZPRESS=PP(JLEV)
    zsat=ZQV - 0.99*ZQS
    LLSAT=zsat > 0. ! true if saturated parcel.
    !
    ! -------------------------------------------------
    ! The parcel buoyancy is computed from the ratio
    ! between density of the parcel (which is a mixture of dry air, water vapour zqv
    ! and condensates zqc) and density of the environmental air.
    ! Note that zqc is zql+zqi and thus will be 0. if pretained=0.,
    ! i.e. if liquid and ice sustents are supposed to precipitate instantaneously.
    ! -------------------------------------------------
    !
    ZQC=ZQL+ZQI
    ZBUOY=(FTH_TVL(ZT,ZQV,ZQC)/FTH_TV(PT(JLEV),PQV(JLEV))-1.0)*FTH_R_HUM(PQV(JLEV))*PT(JLEV)
    LLBUOY=ZBUOY >= 0.0 ! true if buoyant parcel.
    !
    ! -------------------------------------------------
    ! CIN and CAPE integrals.
    ! -------------------------------------------------
    !
    IF(JLEV < JLEV1) THEN
      ZDLOG=LOG(PP(JLEV+1)/PP(JLEV))
      ZRT=0.5*(ZBUOY+ZBUOY_PREC)*ZDLOG
      ! zrt=0.5*(zbuoy+zbuoy_prec)*(pp(jlev+1)-pp(jlev))/(0.5*(pp(jlev)+pp(jlev+1)))
      IF(ZRT > 0.0) THEN
        !
        ! -------------------------------------------------
        ! Cumulate CAPE if positive contribution.
        ! -------------------------------------------------
        !
        PCAPE(JLEV1)=PCAPE(JLEV1)+ZRT
      ELSE
        !
        ! -------------------------------------------------
        ! Cumulate CIN if negative contribution and below LFC.
        ! -------------------------------------------------
        !
        IF(IPOS <= 1) PCIN(JLEV1)=PCIN(JLEV1)+ZRT
      ENDIF
      ZCAPE(JLEV1)=ZCAPE(JLEV1)+ZRT
    ELSE
      zsat_prec=zsat
      ZBUOY_PREC=ZBUOY
      zpress_prec=zpress
    ENDIF
    IF(JLEV1 == KLEV) THEN
      !
      ! -------------------------------------------------
      ! Mass flux profile.
      ! -------------------------------------------------
      !
      PMC(JLEV)=PP(JLEV)/FTH_R_HUM(PQV(JLEV))/PT(JLEV)*SQRT(MAX(0.0,2.0*ZCAPE(JLEV1))) ! kg/m2/s.
    ENDIF
    IF(LDVERBOSE .AND. JLEV1 == KLEV) THEN
      !
      ! -------------------------------------------------
      ! Saturation and CAPE profiles.
      ! -------------------------------------------------
      !
      WRITE(77,FMT='(2i3,5(a,g9.3),a,i3,2(a,l3),3(a,g9.3))') &
        & JLEV1,JLEV,' qvn=',ZQV,' qsn=',ZQS,' thetan=',FTH_THETA(PP(JLEV),ZT)-RTT &
        & ,' theta=',FTH_THETA(PP(JLEV),PT(JLEV))-RTT,' pp=',PP(JLEV)/100. &
        &,' ipos=',IPOS,' sat=',LLSAT,' buoy=',LLBUOY &
        &,' pcin=',PCIN(JLEV1),' pcape=',PCAPE(JLEV1) &
        &,' psum=',ZCAPE(JLEV1)
      !
      ! -------------------------------------------------
      ! Theta, thetaV and thetaVL profiles.
      ! -------------------------------------------------
      !
      WRITE(78,FMT='(1(a,i2.2),5(a,g10.4),2(a,l3),9(a,g10.4))') &
        & 'niv=',JLEV,' theta = ',FTH_THETA(PP(JLEV),ZT),' thetaV = ',FTH_THETAV(PP(JLEV),ZT,ZQV) &
        & ,' thetaVL = ',FTH_THETAVL(PP(JLEV),ZT,ZQV,ZQC)
      !
      ! -------------------------------------------------
      ! Theta, thetaV and thetaVL profiles.
      ! -------------------------------------------------
      !
      WRITE(79,FMT='(9g12.5)') FTH_THETA(PP(JLEV),ZT),-PP(JLEV)/100.
      WRITE(80,FMT='(9g12.5)') FTH_THETAV(PP(JLEV),ZT,ZQV),-PP(JLEV)/100.
      WRITE(81,FMT='(9g12.5)') FTH_THETAL(PP(JLEV),ZT,ZQV,ZQC),-PP(JLEV)/100.
      WRITE(82,FMT='(9g12.5)') FTH_THETAVL(PP(JLEV),ZT,ZQV,ZQC),-PP(JLEV)/100.
      !
      ! -------------------------------------------------
      ! qv and qc=ql+qi profiles.
      ! -------------------------------------------------
      !
      WRITE(83,FMT='(9g12.5)') ZQV,-PP(JLEV)/100.
      WRITE(84,FMT='(9g12.5)') ZQC,-PP(JLEV)/100.
      WRITE(85,FMT='(9g12.5)') PMC(JLEV),-PP(JLEV)/100.
      !
      ! -------------------------------------------------
      ! Buoyancy profile in K.
      ! -------------------------------------------------
      !
      WRITE(86,FMT='(9g12.5)') ZT-PT(JLEV),-PP(JLEV)/100.
    ENDIF
    !
    ! -------------------------------------------------
    ! Check-up transitions between LC, LFC and LNB.
    ! -------------------------------------------------
    !
    IF(LLSAT) THEN  
      !
      ! -------------------------------------------------
      ! Saturated parcel.
      ! -------------------------------------------------
      !
      IF(LLBUOY) THEN
        !
        ! -------------------------------------------------
        ! Buoyant parcel.
        ! -------------------------------------------------
        !
        IF(IPOS == 0) THEN
          !
          ! -------------------------------------------------
          ! While raising to LC, one has found both LC and LFC!...
          ! -------------------------------------------------
          !
          IPOS=2
          KLC(JLEV1)=JLEV
          plc(JLEV1)=fth_pinterpole(zsat,zsat_prec,zpress,zpress_prec)
          KLFC(JLEV1)=JLEV
          plfc(JLEV1)=fth_pinterpole(zbuoy,zbuoy_prec,zpress,zpress_prec)
        ELSEIF(IPOS == 1) THEN
          !
          ! -------------------------------------------------
          ! While raising to LFC, one has found LFC.
          ! -------------------------------------------------
          !
          IPOS=2
          KLFC(JLEV1)=JLEV
          plfc(JLEV1)=fth_pinterpole(zbuoy,zbuoy_prec,zpress,zpress_prec)
        ELSEIF(IPOS == 2) THEN
          !
          ! -------------------------------------------------
          ! While raising to LNB, one has to go on raising.
          ! -------------------------------------------------
          !
        ELSEIF(IPOS == 3) THEN
        ELSE
          PRINT*,'fth_cin_cape/ERROR: unexpected ipos!...',IPOS
          STOP 'call abort'
        ENDIF
      ELSE
        !
        ! -------------------------------------------------
        ! Unbuoyant parcel.
        ! -------------------------------------------------
        !
        IF(IPOS == 0) THEN
          !
          ! -------------------------------------------------
          ! While raising to LC, one has found LC.
          ! -------------------------------------------------
          !
          IPOS=1
          KLC(JLEV1)=JLEV
          plc(JLEV1)=fth_pinterpole(zsat,zsat_prec,zpress,zpress_prec)
        ELSEIF(IPOS == 1) THEN
          !
          ! -------------------------------------------------
          ! While raising to LFC, one has to go on raising.
          ! -------------------------------------------------
          !
        ELSEIF(IPOS == 2) THEN
          !
          ! -------------------------------------------------
          ! While raising to LNB, one has found LNB.
          ! Raising from jlev1 can be stopped here.
          ! -------------------------------------------------
          !
          IPOS=3
          KLNB(JLEV1)=JLEV
          plnb(JLEV1)=fth_pinterpole(zbuoy,zbuoy_prec,zpress,zpress_prec)
        ELSEIF(IPOS == 3) THEN
        ELSE
          PRINT*,'fth_cin_cape/ERROR: unexpected ipos!...',IPOS
          STOP 'call abort'
        ENDIF
      ENDIF
    ELSE
      !
      ! -------------------------------------------------
      ! Unsaturated parcel.
      ! -------------------------------------------------
      !
      IF(LLBUOY) THEN
        !
        ! -------------------------------------------------
        ! Buoyant parcel.
        ! -------------------------------------------------
        !
        IF(IPOS == 0) THEN
          !
          ! -------------------------------------------------
          ! While raising to LC, one has to go on raising.
          ! -------------------------------------------------
          !
        ELSEIF(IPOS == 1) THEN
          !
          ! -------------------------------------------------
          ! The parcel is unsaturated and buoyant, above LC.
          ! Thus another LC point exists above.
          ! One restarts the search for LC.
          ! -------------------------------------------------
          !
          IPOS=0
        ELSEIF(IPOS == 2) THEN
          !
          ! -------------------------------------------------
          ! Go on raising to LNB (ipos=2).
          ! -------------------------------------------------
          !
        ELSEIF(IPOS == 3) THEN
        ELSE
          PRINT*,'fth_cin_cape/ERROR: unexpected ipos!...',IPOS
          STOP 'call abort'
        ENDIF
      ELSE
        !
        ! -------------------------------------------------
        ! Unbuoyant parcel.
        ! -------------------------------------------------
        !
        IF(IPOS == 0) THEN
          !
          ! -------------------------------------------------
          ! Go on raising to LC (ipos=0).
          ! -------------------------------------------------
          !
        ELSEIF(IPOS == 1) THEN
          !
          ! -------------------------------------------------
          ! Go on raising to LFC (ipos=1).
          ! -------------------------------------------------
          !
        ELSEIF(IPOS == 2) THEN
          !
          ! -------------------------------------------------
          ! While raising to LNB, one has found LNB.
          ! Raising from jlev1 can be stopped here.
          ! -------------------------------------------------
          !
          IPOS=3
          KLNB(JLEV1)=JLEV
          plnb(JLEV1)=fth_pinterpole(zbuoy,zbuoy_prec,zpress,zpress_prec)
        ELSEIF(IPOS == 3) THEN
        ELSE
          PRINT*,'fth_cin_cape/ERROR: unexpected ipos!...'
          STOP 'call abort'
        ENDIF
      ENDIF
    ENDIF
    IF(LLSAT) THEN
      !
      ! -------------------------------------------------
      ! If the parcel is oversaturated, this oversaturation is removed.
      ! This is done through an isobaric transformation from (zt,zqv) to (zt1,zqv1).
      ! -------------------------------------------------
      !
      CALL FTH_EVOL_AD_HUM_ISOBARE(ZT,ZQV,PP(JLEV),ZT1,ZQV1)
      ZADD=PRETAINED*(ZQV-ZQV1)
      IF(ZT1 >= RTT) THEN
        ZQL=ZQL+ZADD
      ELSE
        ZQI=ZQI+ZADD
      ENDIF
      !
      ! -------------------------------------------------
      ! Moist adiabatic ascent.
      ! Transformation from (zt1,zqv1) to (zt2,zqv2).
      ! -------------------------------------------------
      !
      ZT2=FTH_T_EVOL_AD_HUM(ZT1,PP(JLEV),PP(JLEV-1))
      ZQV2=FTH_QS(ZT2,PP(JLEV-1))
      IF(ZQV1 > ZQV2) THEN
        ZADD=PRETAINED*(ZQV1-ZQV2)
        IF(ZT2 >= RTT) THEN
          ZQL=ZQL+ZADD
        ELSE
          ZQI=ZQI+ZADD
        ENDIF
      ENDIF
      !
      ! -------------------------------------------------
      ! Cumulate precipitations from ascent started at jlev1.
      ! -------------------------------------------------
      !
      ZPREC=ZPREC+MAX(0.0,(ZQV-ZQV2))*(PP(JLEV)-PP(JLEV-1))/RG
      !
      ! -------------------------------------------------
      ! Update parcel state.
      ! -------------------------------------------------
      !
      ZT=ZT2
      ZQV=ZQV2
    ELSE
      !
      ! -------------------------------------------------
      ! Dry adiabatic ascent.
      ! -------------------------------------------------
      !
      ZT=FTH_T_EVOL_AD_SECHE(ZT,ZQV,PP(JLEV),PP(JLEV-1))
    ENDIF
    !
    ! -------------------------------------------------
    ! Entrainment: relax towards the environment.
    ! -------------------------------------------------
    !
    zdz=(PP(JLEV)-PP(JLEV-1))/(0.5*(PP(JLEV)+PP(JLEV-1)))*fth_r_hum(0.5*(PQV(JLEV)+(PQV(JLEV-1)))) &
    & * 0.5*(PT(JLEV)+(PT(JLEV-1)))/RG
    IF(ZT > PT(JLEV-1)) THEN
      ZT=MAX(PT(JLEV-1),ZT+PENTR*zdz*(PT(JLEV-1)-ZT))
    ELSE
      ZT=MIN(PT(JLEV-1),ZT+PENTR*zdz*(PT(JLEV-1)-ZT))
    ENDIF
    IF(ZQV > PQV(JLEV-1)) THEN
      ZQV=MAX(PQV(JLEV-1),ZQV+PENTR*zdz*(PQV(JLEV-1)-ZQV))
    ELSE
      ZQV=MIN(PQV(JLEV-1),ZQV+PENTR*zdz*(PQV(JLEV-1)-ZQV))
    ENDIF
    !
    !-------------------------------------------------
    ! Store values from previous level (just below).
    !-------------------------------------------------
    !
    zsat_prec=zsat
    ZBUOY_PREC=ZBUOY
    zpress_prec=zpress
  ENDDO
  IF(LDVERBOSE .AND. JLEV1 == KLEV) PRINT*,'Final ql=',ZQL,', final qi=',ZQI
  !
  ! -------------------------------------------------
  ! If CAPE is 0, CIN is put also to 0, in order
  ! not to saturate the graphics with very negative CINs
  ! where no convection is to be expected anyway.
  ! -------------------------------------------------
  !
  ! if(pcape(jlev1) == 0.0) pcin(jlev1) = 0.0
  !
  ! -------------------------------------------------
  ! If some CAPE is present, and CIN is not too large, all levels from LC to LNB are cloudy ones.
  ! -------------------------------------------------
  !
  IF(PCAPE(JLEV1) > 0. .AND. ABS(PCIN(JLEV1)) < 100.) THEN
    IF(KLC(JLEV1) == 0 .OR. KLNB(JLEV1) == 0) THEN
      !
      ! -------------------------------------------------
      ! Buoyancy in dry air. No cloud.
      ! -------------------------------------------------
      !
    ELSE
      !
      ! -------------------------------------------------
      ! Usual case, for which buoyancy appeared
      ! at LFC, i.e. AFTER saturation.
      ! -------------------------------------------------
      !
      IF(LDVERBOSE) PRINT*,'Parcel raised from level ',JLEV1,': LNB at ',KLNB(JLEV1),', LC at ',KLC(JLEV1)
      IF(LDVERBOSE) PRINT*,'CIN (jlev1=',JLEV1,')=',PCIN(JLEV1)
      PPREC=PPREC+ZPREC
    ENDIF
  ENDIF
  !
  ! -------------------------------------------------
  ! Compute potential temperature at LNB.
  ! -------------------------------------------------
  !
  IF(IPOS == 3) THEN
    PTHETAE_TOP(JLEV1)=FTH_THETA(ZPRESS,ZT)
  ELSE
    PTHETAE_TOP(JLEV1)=FTH_THETA(PP(JLEV1),PT(JLEV1))
  ENDIF
ENDDO
!
!-------------------------------------------------
! Compute convective levels and write in kcloud:
! Firstly, diagnose which initial level has the highest (CIN+CAPE).
! Secondly, put kcloud=1 from LC to LNB of this ascent.
!-------------------------------------------------
!
!
!-------------------------------------------------
! Diagnose which initial level has the highest (CIN+CAPE).
!-------------------------------------------------
!
ZCAPEX=0.
ILEVX=0
DO JLEV=1,KLEV
  IF(PCAPE(JLEV)+PCIN(JLEV) > ZCAPEX) THEN
    ZCAPEX=PCAPE(JLEV)+PCIN(JLEV)
    ILEVX=JLEV
  ENDIF
ENDDO
!
!-------------------------------------------------
! Put kcloud=1 from LC to LNB of this ascent.
!-------------------------------------------------
!
IF(ILEVX /= 0) THEN
  IF(KLC(ILEVX) == 0) THEN
    !
    !-------------------------------------------------
    ! No condensation was found ==> no cloud.
    !-------------------------------------------------
    !
    KCLOUD=0
  ELSEIF(KLNB(ILEVX) == 0) THEN
    !
    !-------------------------------------------------
    ! No LNB found ==> cloud from LC to the top of the atmosphere.
    !-------------------------------------------------
    !
    DO JLEV=KLC(ILEVX),1,-1
      KCLOUD(JLEV)=1
    ENDDO
  ELSE
    DO JLEV=KLC(ILEVX),KLNB(ILEVX),-1
      KCLOUD(JLEV)=1
    ENDDO
  ENDIF
ENDIF
END
FUNCTION FTH_HCLA(KLEV,PTHETAV,PZ)
! --------------------------------------------------------------
! //// *fth_hcla* Hauteur de la couche limite atmosphérique.
! --------------------------------------------------------------
! Subject:
!
! Explicit arguments:
!
! Implicit arguments:
!
! Method:
!  Inspirée de Ayotte 1996, Bound. Layer Meteor., vol 79, 131-175, equ (9) page 141.
!  Afin de rendre le diagnostic plus robuste aux couches minces
!  cette équation a été intégrée sur la verticale, avec fluctuations linéaires
!  de couche à couche, cf doc. interne Piriou et Geleyn 2002
!  "Diagnostics de hauteur de couche limite".
!
! Externals:
!
! Auteur/author:   2002-03, J.M. Piriou.
!
! Modifications:
! --------------------------------------------------------------
! Input:
!  klev: nombre de niveaux du profil de thetav.
!  pthetav: profil vertical de thetav (K).
!  pz: profil vertical de l'élévation (m).
!      ATTENTION: pz doit croître de klev à 1.
!      pz doit être une élévation au dessus de la surface,
!      i.e. ne doit pas être une altitude. pz(klev) peut être
!      nul ou non, i.e. les tableaux d'entrée
!      peuvent contenir ou non la surface.
! Output:
!  fth_hcla: hauteur de la couche limite atmosphérique (m).
! --------------------------------------------------------------
!
!-------------------------------------------------
! Types implicites.
!-------------------------------------------------
!
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
INTEGER KLEV,JLEV
REAL PTHETAV(KLEV), PZ(KLEV)
REAL ZTHETAV(KLEV+1), ZZ(KLEV+1)
REAL fth_hcla,ZKHI0,ZKHI1,ZINT,ZTHETAV_PRIME(KLEV+1),ZEPS
REAL ZBIG,ZDELTA,ZARG1,ZARG2,ZPSI,ZTHETAV_PRIME_2,ZBIN
INTEGER ILEV
LOGICAL LLDEBUG
!
!-------------------------------------------------
! Si les tableaux d'entrée ne contiennent pas la surface, on l'y ajoute.
!-------------------------------------------------
!
IF(PZ(KLEV) /= 0.0) THEN
  !
  ! -------------------------------------------------
  ! Il faut ajouter la surface.
  ! -------------------------------------------------
  !
  ILEV=KLEV+1
  DO JLEV=1,KLEV
    ZZ(JLEV)=PZ(JLEV)
    ZTHETAV(JLEV)=PTHETAV(JLEV)
  ENDDO
  ZZ(KLEV+1)=0.0
  ZTHETAV(KLEV+1)=PTHETAV(KLEV)
ELSE
  !
  ! -------------------------------------------------
  ! La surface est déjà présente. Rien à ajouter.
  ! -------------------------------------------------
  !
  ILEV=KLEV
  DO JLEV=1,KLEV
    ZZ(JLEV)=PZ(JLEV)
    ZTHETAV(JLEV)=PTHETAV(JLEV)
  ENDDO
ENDIF
ZKHI0=0.25
ZKHI1=ZKHI0/4.
ZEPS=0.001
ZBIG=30.
!
!-------------------------------------------------
! Intégrale ascendante.
!-------------------------------------------------
!
fth_hcla=0.0
ZINT=0.0
ZTHETAV_PRIME(ILEV)=0.0
LLDEBUG=.FALSE.
IF(LLDEBUG) THEN
  WRITE(*,FMT='(3a)') '  niveau       |   z           |  thetav       |  ' &
  &,'  zpsi       |   zdelta      |   zarg2       |  ' &
  &,' fth_hcla        |               |'
ENDIF
DO JLEV=ILEV-1,1,-1
  !
  ! -------------------------------------------------
  ! Intégrale de thetav.
  ! -------------------------------------------------
  !
  ZINT=ZINT+(ZZ(JLEV)-ZZ(JLEV+1))*0.5*(ZTHETAV(JLEV)+ZTHETAV(JLEV+1))
  !
  ! -------------------------------------------------
  ! thetav': différence entre thetav du niveau courant
  ! et la moyenne de thetav entre la surface et le niveau courant.
  ! -------------------------------------------------
  !
  ZTHETAV_PRIME(JLEV)=ZTHETAV(JLEV)-ZINT/ZZ(JLEV)
  !
  ! -------------------------------------------------
  ! Ecart de thetav' du niveau précédent au courant.
  ! -------------------------------------------------
  !
  ZDELTA=ZTHETAV_PRIME(JLEV)-ZTHETAV_PRIME(JLEV+1)
  !
  ! -------------------------------------------------
  ! Sécurité en division: zdelta va servir au dénominateur.
  ! On le borne pour éviter la division par zéro, en conservant son signe.
  ! -------------------------------------------------
  !
  ZBIN=MAX(0.0,SIGN(1.0,ABS(ZDELTA)-ZEPS))
  ZDELTA=ZBIN*ZDELTA+(1.0-ZBIN)*ZEPS*SIGN(1.0,ZDELTA)
  ZTHETAV_PRIME_2=ZTHETAV_PRIME(JLEV+1)+ZDELTA
  !
  ! -------------------------------------------------
  ! Sécurité en débordement de l'exponentielle: on utilise
  ! la fonction log(cosh) pour les arguments inférieurs à zbig,
  ! et son asymptote au-delà.
  ! -------------------------------------------------
  !
  ZARG2=(ZTHETAV_PRIME_2-ZKHI0)/ZKHI1
  ZARG1=(ZTHETAV_PRIME(JLEV+1)-ZKHI0)/ZKHI1
  ZPSI=0.5*(1.0-ZKHI1/ZDELTA &
    & *(MAX(LOG(COSH(MIN(ABS(ZARG2),ZBIG))),ABS(ZARG2)-LOG(2.0)) &
    & -MAX(LOG(COSH(MIN(ABS(ZARG1),ZBIG))),ABS(ZARG1)-LOG(2.0))))
  !
  ! -------------------------------------------------
  ! Intégrale de dz, avec pour poids zpsi.
  ! -------------------------------------------------
  !
  fth_hcla=fth_hcla+(ZZ(JLEV)-ZZ(JLEV+1))*ZPSI
  !
  ! -------------------------------------------------
  ! Impressions.
  ! -------------------------------------------------
  !
  IF(LLDEBUG) WRITE(*,FMT='(i16,9g12.5)') JLEV,ZZ(JLEV),ZTHETAV(JLEV),ZPSI,ZDELTA,ZARG2,fth_hcla
ENDDO
END
FUNCTION FTH_CP(PQV,PQL,PQI)
! --------------------------------------------------------------
! //// *fth_cp* Chaleur massique de l'air humide.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
! pqv  humidité spécifique vapeur (sans dimension).
! pql  humidité spécifique liquide (sans dimension).
! pqi  humidité spécifique glace (sans dimension).
! En sortie: chaleur massique de l'air humide (J/kg/K).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RCW
USE CONSTANTES, ONLY : RCS
IMPLICIT NONE
REAL :: PQV
REAL :: PQL
REAL :: PQI
REAL fth_cp
fth_cp=RCPD*(1.0-PQV-PQL-PQI)+RCPV*PQV+RCW*PQL+RCS*PQI
END
FUNCTION fth_e(PQ,PP)
! --------------------------------------------------------------
! //// *fth_e* Tension de vapeur en fonction de l'humidité spécifique et de la pression.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree: pq humidité spécifique (sans dimension).
! pp pression en Pa.
! En sortie: fth_e en Pa.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RV
!
IMPLICIT NONE
REAL :: PP
REAL :: PQ
REAL fth_e
fth_e=PP*PQ/((1.0-PQ)*RD/RV+PQ)
END
FUNCTION FTH_ES(PT)
! --------------------------------------------------------------
! //// *fth_es* Fonction fth_es(T) par rapport à l'eau ou la glace.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.F. Geleyn.
! Modifications:
! --------------------------------------------------------------
! En entree: température en K.
! En sortie: fth_es en Pa.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RALPD
USE CONSTANTES, ONLY : RALPW
USE CONSTANTES, ONLY : RBETD
USE CONSTANTES, ONLY : RBETW
USE CONSTANTES, ONLY : RGAMD
USE CONSTANTES, ONLY : RGAMW
USE CONSTANTES, ONLY : RTT
IMPLICIT NONE
REAL :: PT
REAL fth_es
fth_es=EXP( &
  & (RALPW+RALPD*MAX(0.0,SIGN(1.0,RTT-PT))) &
  & -(RBETW+RBETD*MAX(0.0,SIGN(1.0,RTT-PT)))/PT &
  & -(RGAMW+RGAMD*MAX(0.0,SIGN(1.0,RTT-PT)))*LOG(PT))
IF(fth_es == 0.) THEN
  !
  ! -------------------------------------------------
  ! Cas d'underflow.
  ! -------------------------------------------------
  !
  WRITE(*,FMT=*) 'fth_es/ATTENTION: underflow!... PT=',PT
  WRITE(*,FMT=*)
ENDIF
END
FUNCTION FTH_ES_FRANCOISE(PT)
! --------------------------------------------------------------
! //// *fth_es_francoise* Fonction fth_es(T) par rapport à l'eau ou la glace.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2004-07, Françoise Guichard
! Modifications:
! --------------------------------------------------------------
! En entree: température en K.
! En sortie: fth_es en Pa.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PT
REAL :: fth_es_francoise,WA,WB,WC
WA   = 6.11E+2
WB   = 17.269
WC   = 35.86
fth_es_francoise=WA * EXP(WB * (PT-273.16)/(PT-WC ) )
END
FUNCTION FTH_ESS(PT)
! --------------------------------------------------------------
! //// *fth_ess* Fonction fth_es(T) par rapport à la glace.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.F. Geleyn.
! Modifications:
! --------------------------------------------------------------
! En entree: température en K.
! En sortie: fth_es en Pa.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RALPS
USE CONSTANTES, ONLY : RBETS
USE CONSTANTES, ONLY : RGAMS
IMPLICIT NONE
REAL :: PT
REAL fth_ess
fth_ess=EXP(RALPS-RBETS/PT-RGAMS*LOG(PT))
END
FUNCTION FTH_ESW(PT)
! --------------------------------------------------------------
! //// *fth_esw* Fonction fth_es(T) par rapport à l'eau.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.F. Geleyn.
! Modifications:
! --------------------------------------------------------------
! En entree: température en K.
! En sortie: fth_es en Pa.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RALPW
USE CONSTANTES, ONLY : RBETW
USE CONSTANTES, ONLY : RGAMW
IMPLICIT NONE
REAL :: PT,fth_esw
fth_esw=EXP(RALPW-RBETW/PT-RGAMW*LOG(PT))
END
SUBROUTINE FTH_EVOL_AD_HUM_ISOBARE(PT0,PQV0,PP0,PT,PQV)
! --------------------------------------------------------------
! //// *fth_evol_ad_hum_isobare* Calcul de l'état final d'une condensation isobare.
! --------------------------------------------------------------
! Sujet:
! On passe d'un état (T0,qv0,p0) avec qv0 > fth_qs(T0,p0)
! à un état (T,qv,p0), en vérifiant cp*dt+L*dq=0, et qv=fth_qs(T,p0), et à pression constante.
! Arguments explicites:
! Arguments implicites:
! Methode:
!  On résout en T
!       f(T)=cp*(T-T0)+L*(q-q0)=0
!  avec la contrainte q=fth_qs(T,p0),
!  On résout par la méthode de Newton, en itérant
!  T --> T-f(T)/f'(T), avec pour point de départ T0.
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt0: température de départ (K).
!  pqv0: humidité spécifique de départ (kg/kg).
!  pp0: pression de départ et d'arrivée (Pa).
! En sortie:
!  pt: température d'arrivée (K).
!  pqv: humidité spécifique d'arrivée (kg/kg).
!       Elle est égale à fth_qs(pt,pp0).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RTT
IMPLICIT NONE
INTEGER :: JIT
REAL :: PP0
REAL :: PQV
REAL :: PQV0
REAL :: PT
REAL :: PT0
REAL :: ZCP
REAL :: ZGLACE
REAL :: ZL
REAL :: ZQI
REAL :: ZQL
REAL :: ZT_DEPART,fth_qs,fth_folh,fth_cp,fth_fderqs,fth_fderfolh
!
PT=PT0
PQV=FTH_QS(PT,PP0)
ZQL=0.0
ZQI=0.0
DO JIT=1,10
  ZT_DEPART=PT
  !
  ! -------------------------------------------------
  ! Chaleur latente.
  ! -------------------------------------------------
  !
  ZGLACE=MAX(0.0,SIGN(1.0,RTT-PT))
  ZL=FTH_FOLH(PT,ZGLACE)
  !
  ! -------------------------------------------------
  ! Itération de Newton.
  ! -------------------------------------------------
  !
  ZCP=FTH_CP(PQV,ZQL,ZQI)
  PT=PT-(ZCP*(PT-PT0)+ZL*(PQV-PQV0)) &
    & /(ZCP+(RCPV-RCPD+ZL)*fth_fderqs(PT,PP0)+PQV*fth_fderfolh(ZGLACE))
  !
  ! -------------------------------------------------
  ! Vapeur saturante.
  ! -------------------------------------------------
  !
  PQV=FTH_QS(PT,PP0)
  !
  ! -------------------------------------------------
  ! On sort de la boucle de Newton
  ! si on a la solution à epsilon près.
  ! -------------------------------------------------
  !
  IF(ABS(PT-ZT_DEPART) < 0.01) EXIT
  ZT_DEPART=PT
ENDDO
END
SUBROUTINE FTH_EVAPO_ISOBARE(PT0,PQV0,PQC0,PP,PT,PQV,PQC)
! --------------------------------------------------------------
! //// *fth_evapo_isobare* Calcul de l'état final d'une évaporation isobare.
! --------------------------------------------------------------
! Sujet:
!
! On passe d'un état (T0,qv0,qc0,p) avec qv0 < fth_qs(T0,p)
! à un état (T,qv,qc,p), en vérifiant cp*dt+L*dq=0, et qv=fth_qs(T,p), et à pression constante.
! On va évaporer à concurrence
!   - d'atteindre le qv saturant.
!   - d'épuiser qc0.
!
! Arguments explicites:
! Arguments implicites:
!
! Auteur/author:   2004-05, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt0: température de départ (K).
!  pqv0: quantité spécifique vapeur d'eau de départ (kg/kg).
!  pqc0: quantité spécifique d'eau condensée (liquide + glace) de départ (kg/kg).
!  pp: pression de départ et d'arrivée (Pa).
! En sortie:
!  pt: température d'arrivée (K).
!  pqv: quantité spécifique vapeur d'eau d'arrivée (kg/kg).
!  pqc: quantité spécifique d'eau condensée (liquide + glace) d'arrivée (kg/kg).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RTT
IMPLICIT NONE
REAL :: PP
REAL :: PQV
REAL :: PQV0
REAL :: PQC
REAL :: PQC0
REAL :: PT
REAL :: PT0
REAL :: ZCP
REAL :: ZGLACE
REAL :: ZL
REAL :: fth_qs,fth_folh,fth_cp,ZQS,ZT1,ZQV1
!
ZQS=FTH_QS(PT0,PP)
IF(PQV0 < ZQS) THEN
  !
  ! -------------------------------------------------
  ! L'humidité spécifique vapeur est soussaturante.
  ! -------------------------------------------------
  !
  IF(PQC0 < 0.0) THEN
    WRITE(*,FMT=*)
    WRITE(*,FMT=*) 'fth_evapo_isobare/ERREUR: l''eau condensée est négative en entrée!...'
    WRITE(*,FMT=*) PQC0
    STOP 'call abort'
  ENDIF
  IF(PT0 > RTT) THEN
    ZGLACE=0.0
    ZL=FTH_FOLH(PT0,ZGLACE)
    ZCP=FTH_CP(PQV0,PQC0,0.0)
  ELSE
    ZGLACE=1.0
    ZL=FTH_FOLH(PT0,ZGLACE)
    ZCP=FTH_CP(PQV0,0.0,PQC0)
  ENDIF
  !
  ! -------------------------------------------------
  ! On évapore d'un coup une quantité de condensat égale à pqc0.
  ! On arrive à un état (T1,qv1,qc1=0).
  ! -------------------------------------------------
  !
  ZQV1=PQV0+PQC0
  ZT1=PT0-ZL/ZCP*PQC0
  !
  ! -------------------------------------------------
  ! Si après cette opération on est sursaturé, on revient
  ! à la valeur fth_hr=1.
  ! -------------------------------------------------
  !
  ZQS=FTH_QS(ZT1,PP)
  IF(ZQV1 > ZQS) THEN
    !
    ! -------------------------------------------------
    ! On est sursaturé. Retour à la valeur fth_hr=1.
    ! -------------------------------------------------
    !
    CALL FTH_EVOL_AD_HUM_ISOBARE(ZT1,ZQV1,PP,PT,PQV)
    PQC=ZQV1-PQV
  ELSE
    PT=ZT1
    PQV=ZQV1
    PQC=0.0
  ENDIF
ELSE
  !
  ! -------------------------------------------------
  ! L'humidité spécifique vapeur est saturée ou sursaturée.
  ! On ne fait rien ici, car la présente routine est dévolue
  ! à l'évaporation seule.
  ! -------------------------------------------------
  !
  PT=PT0
  PQV=PQV0
  PQC=PQC0
ENDIF
END
FUNCTION fth_fderqs(PT,PP)
! --------------------------------------------------------------
! //// *fth_fderqs* Fonction dérivée partielle par rapport à la température de l'humidité spécifique saturante.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:  2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree: pt température en K.
! pp pression en Pa.
! En sortie: humidité spécifique saturante (sans dimension).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RETV
USE CONSTANTES, ONLY : RV
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL :: ZES
REAL :: ZRAPP,fth_fderqs,fth_es,fth_fodles
!
ZES=FTH_ES(PT)
ZRAPP=RV/RD*PP/ZES
fth_fderqs=ZRAPP/(ZRAPP-RETV)**2*fth_fodles(PT)
END
FUNCTION fth_fodles(PT)
! --------------------------------------------------------------
! //// *fth_fodles* Fonction d(ln(fth_es(T)))/dT.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.F. Geleyn.
! Modifications:
! --------------------------------------------------------------
! En entree: température en K.
! En sortie: fth_es en Pa.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RBETD
USE CONSTANTES, ONLY : RBETW
USE CONSTANTES, ONLY : RGAMD
USE CONSTANTES, ONLY : RGAMW
USE CONSTANTES, ONLY : RTT
IMPLICIT NONE
REAL :: PT
REAL :: ZGLACE,fth_fodles
!
!
! FONCTION DERIVEE DU LOGARITHME NEPERIEN DE LA PRECEDENTE (FOEW) .
! INPUT : pt = TEMPERATURE
! PDELARG = 0 SI EAU (QUELQUE SOIT pt)
! 1 SI GLACE (QUELQUE SOIT pt).
ZGLACE=MAX(0.0,SIGN(1.0,RTT-PT))
fth_fodles = ( &
  & ( RBETW+ZGLACE*RBETD ) &
  & - ( RGAMW+ZGLACE*RGAMD ) * PT ) &
  & / ( PT*PT )
END
FUNCTION FTH_FOLH(PT,PDELARG)
! --------------------------------------------------------------
! //// *fth_folh* Fonction chaleur latente vapeur/eau ou vapeur/glace.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-09, J.F. Geleyn.
! Modifications:
!         2004-04, J.M. Piriou: formule heuristique.
! --------------------------------------------------------------
! FONCTION CHALEUR LATENTE .
! Entrée: pt = TEMPERATURE
! PDELARG = 0 SI EAU (QUELQUE SOIT pt)
! 1 SI GLACE (QUELQUE SOIT pt).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES
IMPLICIT NONE
REAL :: PDELARG
REAL :: PT
REAL fth_folh
!
!
!-------------------------------------------------
! L complet heuristique (eau liquide/glace).
!-------------------------------------------------
!
fth_folh= PDELARG          *(RLSTT-(PT-RTT)*(RCS-RCPV)) &
  &     +(1.0-PDELARG) *(RLVTT-(PT-RTT)*(RCW-RCPV))
!
!-------------------------------------------------
! L complet à la ARPEGE (eau liquide/glace).
!-------------------------------------------------
!
!fth_folh=rv*((rbetw+pdelarg*rbetd)-(rgamw+pdelarg*rgamd)*pt)
!
!-------------------------------------------------
! L Bolton (i.e. L vapeur/eau liquide).
!-------------------------------------------------
!
!fth_folh=(2.501-0.00237*(pt-rtt))*1.e6
!
!-------------------------------------------------
! L constant.
!-------------------------------------------------
!
!fth_folh=2.5e6
!
END
FUNCTION fth_fderfolh(PDELARG)
! --------------------------------------------------------------
! //// *fth_fderfolh* Fonction dérivée partielle par rapport à la température de la fonction chaleur latente vapeur/eau ou vapeur/glace.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
!     On calcule cette dérivée en faisant explicitement
!     le calcul d'un taux de variation.
!     Pourquoi faire cela pour arriver à une constante?
!     Simplement pour être SUR que la dérivée obtenue ici
!     soit consistante avec la fonction fth_folh,
!     fournie ailleurs dans ce même source.
!     Ainsi une modification du calcul de fth_folh
!     sera répercutée de facto ici.
! Externes:
! Auteur/author:  2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! FONCTION CHALEUR LATENTE .
! Entrée:
! PDELARG = 0 SI EAU (QUELQUE SOIT pt)
! 1 SI GLACE (QUELQUE SOIT pt).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RTT
IMPLICIT NONE
REAL :: PDELARG
REAL :: fth_fderfolh
REAL :: fth_folh
REAL :: ZDELTAT
!
ZDELTAT=10.
fth_fderfolh=(FTH_FOLH(RTT+ZDELTAT,PDELARG)-FTH_FOLH(RTT,PDELARG))/ZDELTAT
!
END
FUNCTION FTH_HR(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_hr* Fonction humidité relative.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-10, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_hr (sans dimension).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PQV
REAL :: PT,fth_hr,fth_e,fth_es
!
fth_hr=fth_e(MAX(0.0,PQV),PP)/FTH_ES(PT)
END
SUBROUTINE FTH_POINT_CONDENS(PT0,PQV0,PP0,PTCOND,PPCOND)
! --------------------------------------------------------------
! //// *fth_point_condens* Calcul du point de condensation d'une particule donnée par (T0, qv0, p0).
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
!  On résout en p
!       fth_qs(T,p)=qv0
!       avec T=T0*(p0/p)**(R/cp)
!  On résout par la méthode de Newton, en itérant
!  p --> p-f(p)/f'(p), avec pour point de départ p0.
! Externes:
! Auteur/author:   2000-10, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt0: température de départ (K).
!  pqv0: humidité spécifique de départ (Pa).
!  pp0: pression de départ (Pa).
! En sortie:
!  ptcond température du point de condensation (K).
!  ppcond pression du point de condensation (Pa).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
INTEGER :: JIT
REAL :: PP0
REAL :: PPCOND
REAL :: PQV0
REAL :: PT0
REAL :: PTCOND
REAL :: ZDERI,ZPCOND2
REAL :: ZDP
REAL :: ZFONC
REAL :: ZPPREC
REAL :: ZQV
REAL :: ZTPLUS,fth_qs,fth_t_evol_ad_seche
!
PTCOND=PT0
PPCOND=PP0
ZDP=5.
ZQV=0.0
DO JIT=1,10
  ZPPREC=PPCOND
  ZFONC=FTH_QS(PTCOND,PPCOND) ! valeur en p.
  ZTPLUS=FTH_T_EVOL_AD_SECHE(PTCOND,ZQV,PPCOND,PPCOND+ZDP) ! T(p+dp).
  ZDERI=(FTH_QS(ZTPLUS,PPCOND+ZDP)-ZFONC)/ZDP ! dérivée [fth_qs(T(p+dp),p+dp)-fth_qs(T,p)]/dp.
  ZPCOND2=PPCOND-(ZFONC-PQV0)/ZDERI
  IF(ZPCOND2 > 0.) THEN
    !
    ! -------------------------------------------------
    ! L'algorithme fournit une valeur de pression plausible.
    ! On la prend pour ébauche de Newton suivante.
    ! Dans les autres cas on laisse la valeur de pression stationner.
    ! -------------------------------------------------
    !
    PPCOND=ZPCOND2
  ENDIF
  PTCOND=FTH_T_EVOL_AD_SECHE(PTCOND,ZQV,ZPPREC,PPCOND)
  IF(ABS(PPCOND-ZPPREC) < 50.) EXIT
ENDDO
END
FUNCTION FTH_QS(PT,PP)
! --------------------------------------------------------------
! //// *fth_qs* humidité spécifique saturante en fonction de T et p.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree: pt température en K.
! pp pression en Pa.
! En sortie: humidité spécifique saturante (sans dimension).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL :: ZES,fth_qs,fth_es,fth_qv
!
ZES=FTH_ES(PT)
fth_qs=FTH_QV(ZES,PP)
END
FUNCTION FTH_QS_FRANCOISE(PT,PP)
! --------------------------------------------------------------
! //// *fth_qs_francoise* humidité spécifique saturante en fonction de T et p.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2004-07, Françoise Guichard.
! Modifications:
! --------------------------------------------------------------
! En entree: pt température en K.
! pp pression en Pa.
! En sortie: humidité spécifique saturante (sans dimension).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL :: ZES,fth_qs_francoise,fth_es_francoise,VEPS
!
ZES=FTH_ES_FRANCOISE(PT)
VEPS = .62198
fth_qs_francoise=VEPS * ZES / (PP + (VEPS-1.)*ZES )
END
FUNCTION FTH_QV(PE,PP)
! --------------------------------------------------------------
! //// *fth_qv* qv en fonction de la tension de vapeur et de la pression.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2003-07, J.M. Piriou, d'après ARPEGE.
! Modifications:
! --------------------------------------------------------------
! En entree: pe tension de vapeur en Pa.
! pp pression en Pa.
! En sortie: q (sans dimension).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RETV
IMPLICIT NONE
REAL :: PE
REAL :: PP,fth_qv,ZESP
!
ZESP=PE/PP
fth_qv = ZESP / ( 1.0+RETV*MAX(0.0,(1.0-ZESP)) )
!
END
FUNCTION FTH_R_HUM(PQV)
! --------------------------------------------------------------
! //// *fth_r_hum* Constante spécifique de l'air humide.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-10, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
! pqv  humidité spécifique vapeur (sans dimension).
! En sortie: constante spécifique de l'air humide (J/kg/K).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RV
IMPLICIT NONE
REAL :: PQV,fth_r_hum
!
fth_r_hum=RD+(RV-RD)*PQV
END
FUNCTION FTH_DELTA_H_AD_HUM(PP,PT,PP0,PT0,PGLACE,PLOG)
! --------------------------------------------------------------
! //// *fth_delta_h_ad_hum* Calcul de la fonction delat(h) dont on cherche le zéro
! pour calculer les évolutions pseudo-adiabatiques humides.
! Appelé par fth_t_evol_ad_hum.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2003-07, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt: température (K).
!  pglace: 1 si phase glace, 0 si phase liquide.
!  plog: constante à soustraire.
! En sortie:
!  delta(h) (J/kg).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP,PT,PP0,PT0,PGLACE,PLOG
REAL :: fth_delta_h_ad_hum,fth_qs,fth_r_hum,ZQV,ZL,ZCP,ZRDLOG,fth_folh,ZQL,ZQI,fth_cp,ZQV0
!
!-------------------------------------------------
! Humidité saturante.
!-------------------------------------------------
!
ZQV=FTH_QS(PT,PP)
ZQV0=FTH_QS(PT0,PP0)
!
!-------------------------------------------------
! Chaleur latente.
!-------------------------------------------------
!
! Calcul où l'on considère que toute la chaleur latente libérée
! est récupérée par la vapeur d'eau pour se réchauffer.
!
ZL=FTH_FOLH(PT,PGLACE)
!
! Calcul où l'on considère qu'une part seulement de la chaleur latente libérée
! est récupérée par la vapeur d'eau pour se réchauffer:
! le reste reste dans l'eau liquide ou glace.
! Ce calcul fournit des CAPE plus réalistes,
! mais n'est pas conservatif d'une énergie totale
! qui ne prendrait pas en compte l'énergie interne des particules
! d'eau et de glace.
!
!zratio=0.92 ; zl=zratio*fth_folh(pt,pglace) ; zl0=zratio*fth_folh(pt0,pglace)
!
!
!-------------------------------------------------
! Cp et dlog.
!-------------------------------------------------
!
ZQL=0.
ZQI=0.
ZCP=FTH_CP(ZQV,ZQL,ZQI)
ZRDLOG=FTH_R_HUM(ZQV)*PLOG
fth_delta_h_ad_hum=ZCP*(PT-PT0)+ZL*(ZQV-ZQV0)-PT*ZRDLOG
END
FUNCTION FTH_T_EVOL_AD_SECHE(PT0,PQV0,PP0,PP)
! --------------------------------------------------------------
! //// *fth_t_evol_ad_seche* Calcul de l'état final d'une évolution adiabatique sèche.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt0: température de départ (K).
!  pqv0: humidité spécifique de départ (et d'arrivée, puisqu'aucune condensation ici) (kg/kg).
!        l'humidité spécifique sert simplement à calculer R et cp.
!  pp0: pression de départ (Pa).
!  pp: pression d'arrivée (Pa).
! En sortie:
!  fth_t_evol_ad_seche: température d'arrivée (K).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PP0
REAL :: PQV0
REAL :: PT0
REAL :: ZQI
REAL :: ZQL,fth_t_evol_ad_seche,fth_r_hum,fth_cp
!
ZQL=0.0
ZQI=0.0
fth_t_evol_ad_seche=PT0*(PP/PP0)**(FTH_R_HUM(PQV0)/FTH_CP(PQV0,ZQL,ZQI))
END
FUNCTION FTH_TD(PE)
! --------------------------------------------------------------
! //// *fth_td* Calcul de Td en fonction de la tension de vapeur.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   96-04, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree: pe tension de vapeur en Pa.
! En sortie: fth_td en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
INTEGER :: JIT
REAL :: PE
REAL :: ZDERI
REAL :: ZDT
REAL :: ZES
REAL :: ZT
REAL :: ZTPREC,fth_es,fth_td
!
ZT=280.
!
! On itère une boucle de Newton
! pour annuler la fonction fth_es(t)-e.
!
ZDT=0.1
DO JIT=1,10
  ZES=FTH_ES(ZT)
  ZDERI=(FTH_ES(ZT+ZDT)-ZES)/ZDT
  ZTPREC=ZT
  ZT=ZT-(ZES-PE)/ZDERI
  IF(ABS(ZT-ZTPREC) < 0.01) EXIT
ENDDO
fth_td=ZT
END
FUNCTION FTH_THETA(PP,PT)
! --------------------------------------------------------------
! //// *fth_theta* Fonction température potentielle.
! --------------------------------------------------------------
! Sujet:
!  On ramène une particule donnée par (p,T) au niveau standard via une adiabatique sèche.
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   98-01, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt température en K.
!  pp pression en Pa.
! En sortie:
!  fth_theta en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RD
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL fth_theta
!
fth_theta=PT*(RATM/PP)**(RD/RCPD)
END
FUNCTION FTH_THETAP(PP,PT)
! --------------------------------------------------------------
! //// *fth_thetap* Fonction theta': température potentielle pseudo-adiabatique.
! --------------------------------------------------------------
! Sujet:
!  On ramène une particule donnée par (p,T) au niveau standard via une pseudo-adiabatique humide.
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2003-07, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt température en K.
!  pp pression en Pa.
! En sortie:
!  fth_thetap en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL fth_thetap,fth_t_evol_ad_hum
!
!
!-------------------------------------------------
! On va du point courant au niveau p standard
! via une theta'w (évolution adiabatique humide irréversible).
!-------------------------------------------------
!
fth_thetap=FTH_T_EVOL_AD_HUM(PT,PP,RATM)
END
FUNCTION fth_t(PP,PTHETA)
! --------------------------------------------------------------
! //// *fth_t* Inversion en T de la température potentielle.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2001-01, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  ptheta potential temperature in K.
!  pp pressure in Pa.
! En sortie:
!  fth_t in K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RD
IMPLICIT NONE
REAL :: PP
REAL :: PTHETA
REAL fth_t
!
fth_t=PTHETA*(PP/RATM)**(RD/RCPD)
END
FUNCTION FTH_THETAD(PP,PQV)
! --------------------------------------------------------------
! //// *fth_thetad* Fonction température de rosée potentielle.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_thetad en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RD
IMPLICIT NONE
REAL :: PP
REAL :: PQV,fth_thetad,fth_e,fth_td
!
fth_thetad=FTH_TD(fth_e(PQV,PP))*(RATM/PP)**(RD/RCPD)
END
FUNCTION FTH_THETAW(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_thetaw* Température du thermomètre mouillé ramenée adiabatiquement au niveau standard.
! ATTENTION: il ne faut pas la confondre avec la theta'w, qui est elle ramenée au niveau
! standard via une pseudo-adiabatique humide.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2003-07, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_thetaw en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RD
IMPLICIT NONE
REAL :: PP,PT,PQV
REAL :: fth_thetaw,fth_tw
!
fth_thetaw=FTH_TW(PP,PT,PQV)*(RATM/PP)**(RD/RCPD)
END
FUNCTION fth_thetae(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_thetae* Fonction température potentielle équivalente (calcul discret précis).
! --------------------------------------------------------------
! Sujet:
! Le thetae d'une particule est la température qu'elle aurait
! si on la montait selon une adiabatique sèche jusqu'en son point
! de condensation, puis selon une adiabatique humide jusqu'à
! épuiser son humidité spécifique, puis on la redescendait
! selon une adiabatique sèche jusqu'au niveau de pression standard (ratm dans le code).
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-10, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_thetae en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
INTEGER :: IETAPES
INTEGER :: JETAPES
REAL :: PP
REAL :: PQV
REAL :: PT
REAL :: ZETAPE
REAL :: ZP
REAL :: ZPLIM
REAL :: ZPPREC
REAL :: ZQV
REAL :: ZQV1
REAL :: ZQVPREC
REAL :: ZT
REAL :: ZT1
REAL :: ZTPREC,fth_thetae,fth_qs,fth_t_evol_ad_hum,fth_t_evol_ad_seche,fth_theta
!
LOGICAL LLSAT
!
!-------------------------------------------------
! Ascendance jusqu'à épuisement de l'humidité spécifique,
! ce qu'on suppose arriver au niveau p=zplim
!-------------------------------------------------
!
LLSAT=PQV >= FTH_QS(PT,PP)
IF(LLSAT) THEN
  !
  ! -------------------------------------------------
  ! La particule est sursaturée dès le départ.
  ! On élimine cette sursaturation.
  ! -------------------------------------------------
  !
  CALL FTH_EVOL_AD_HUM_ISOBARE(PT,PQV,PP,ZT,ZQV)
ELSE
  ZT=PT
  ZQV=PQV
ENDIF
ZPLIM=10000. ! pression d'arrêt d'ascendance (Pa).
ZETAPE=1000. ! pas de pression pour la discrétisation verticale (Pa).
IETAPES=NINT(ABS(PP-ZPLIM)/ZETAPE)+1
ZPPREC=PP
ZTPREC=ZT
ZQVPREC=ZQV
DO JETAPES=1,IETAPES
  ZP=PP+(ZPLIM-PP)*REAL(JETAPES)/REAL(IETAPES)
  IF(LLSAT) THEN
    !
    ! -------------------------------------------------
    ! Particule saturée. Ascendance adiabatique humide.
    ! -------------------------------------------------
    !
    ZT=FTH_T_EVOL_AD_HUM(ZTPREC,ZPPREC,ZP)
    ZQV=FTH_QS(ZT,ZP)
  ELSE
    !
    ! -------------------------------------------------
    ! Particule insaturée. Ascendance adiabatique sèche.
    ! -------------------------------------------------
    !
    ZT=FTH_T_EVOL_AD_SECHE(ZTPREC,ZQVPREC,ZPPREC,ZP)
    IF(ZQVPREC > FTH_QS(ZT,ZP)) THEN
      !
      ! -------------------------------------------------
      ! On atteint le point de condensation.
      ! On élimine cette sursaturation.
      ! -------------------------------------------------
      !
      CALL FTH_EVOL_AD_HUM_ISOBARE(ZT,ZQVPREC,ZP,ZT1,ZQV1)
      LLSAT=.TRUE.
      ZT=ZT1
      ZQV=ZQV1
    ELSE
      !
      ! -------------------------------------------------
      ! On n'atteint pas le point de condensation.
      ! qv est reconduit égal à lui-même.
      ! -------------------------------------------------
      !
      ZQV=ZQVPREC
    ENDIF
  ENDIF
  !
  ! -------------------------------------------------
  ! Le niveau courant devient le précédent.
  ! -------------------------------------------------
  !
  ZTPREC=ZT
  ZQVPREC=ZQV
  ZPPREC=ZP
ENDDO
!
!-------------------------------------------------
! thetae n'est autre que le theta de la particule
! parvenue au sommet.
!-------------------------------------------------
!
fth_thetae=FTH_THETA(ZPPREC,ZT)
END
FUNCTION FTH_THETAE_BOLTON(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_thetae_bolton* Fonction température potentielle équivalente (calcul direct approché).
! --------------------------------------------------------------
! Sujet:
! Le thetae d'une particule est la température qu'elle aurait
! si on la montait selon une adiabatique sèche jusqu'en son point
! de condensation, puis selon une adiabatique humide jusqu'à
! épuiser son humidité spécifique, puis on la redescendait
! selon une adiabatique sèche jusqu'au niveau de pression standard.
! Arguments explicites:
! Arguments implicites:
! Methode: David Bolton, MWR 1980.
! La formule se veut rapide à calculer, et donc
! fait des hypothèses, telle une dépendance affine de L en T
! sur toute la plage de températures, etc...
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_thetae_bolton en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
IMPLICIT NONE
REAL :: PP
REAL :: PQV
REAL :: PT
REAL :: ZE
REAL :: ZR
REAL :: ZTCOND,fth_thetae_bolton,fth_e
!
ZE=fth_e(MAX(0.0,PQV),PP)
ZR=PQV/(1.0-PQV)*1000. ! r en g/kg.
IF(ZE /= 0.0) THEN
  ZTCOND=2840./(3.5*LOG(PT)-LOG(ZE/100.)-4.805)+55. ! equ. (21) de Bolton 1980.
  ! zhr=ze/fth_es(pt) ; ztcond=1.0/(1.0/(pt-55.)-log(zhr)/2840.)+55. ! equ. (22) de Bolton 1980.
ELSE
  ZTCOND=PT
ENDIF
fth_thetae_bolton=PT*(RATM/PP)**(0.2854*(1.0-0.28E-3*ZR)) &
  &*EXP((3.376/ZTCOND-0.00254)*ZR*(1+0.81E-3*ZR)) ! equ. (43) de Bolton 1980.
END
FUNCTION fth_thetaes(PP,PT)
! --------------------------------------------------------------
! //// *fth_thetaes* Fonction température potentielle équivalente de saturation (calcul discret précis).
! --------------------------------------------------------------
! Sujet:
! Le thetae d'une particule est la température qu'elle aurait
! si elle était saturée au départ (qv=fth_qs(T,p)),
! si on la montait selon une adiabatique sèche jusqu'en son point
! de condensation, puis selon une adiabatique humide jusqu'à
! épuiser son humidité spécifique, puis on la redescendait
! selon une adiabatique sèche jusqu'au niveau de pression standard (ratm dans le code).
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-10, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
! En sortie:
!  fth_thetaes en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL :: fth_thetaes,fth_thetae,fth_qs
!
fth_thetaes=fth_thetae(PP,PT,FTH_QS(PT,PP))
END
FUNCTION FTH_THETAES_BOLTON(PP,PT)
! --------------------------------------------------------------
! //// *fth_thetaes_bolton* Fonction température potentielle équivalente de saturation (calcul direct approché).
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
! En sortie:
!  fth_thetaes_bolton en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PT,fth_thetae_bolton,fth_qs,fth_THETAES_BOLTON
fth_THETAES_BOLTON=FTH_THETAE_BOLTON(PP,PT,FTH_QS(PT,PP))
END
FUNCTION FTH_THETAPW(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_thetapw* Fonction theta'w.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2002-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique (kg/kg).
! En sortie:
!  fth_thetapw en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY: RATM
IMPLICIT NONE
REAL :: PP,PT,PQV,fth_thetapw,ZT_COND,ZP_COND,fth_t_evol_ad_hum
!
!-------------------------------------------------
! On recherche le point de condensation issu du point courant.
!-------------------------------------------------
!
CALL FTH_POINT_CONDENS(PT,PQV,PP,ZT_COND,ZP_COND)
!
!-------------------------------------------------
! On va du point de condensation au niveau p standard
! via une theta'w (évolution adiabatique humide irréversible).
!-------------------------------------------------
!
fth_thetapw=FTH_T_EVOL_AD_HUM(ZT_COND,ZP_COND,RATM)
END
FUNCTION FTH_THETAPW_ARP(PP,PT,PQV,PQL,PQI)
! --------------------------------------------------------------
! //// *fth_thetapw_arp* theta'w.
! --------------------------------------------------------------
! Sujet:
! CALCUL DE LA TEMPERATURE POTENTIELLE PSEUDO-ADIABATIQUE
! DU THERMOMETRE MOUILLE.
! Arguments explicites:
! Arguments implicites:
!
! Methode.
! --------
!
! CETTE ROUTINE N'A QU'UNE DIMENSION POUR SES VARIABLES D'ENTREE
! AFIN D'ETRE LA PLUS GENERALE POSSIBLE (UTILISATION SUR LES NIVEAUX
! DU MODELE COMME DU POST-PROCESSING, PAR EXEMPLE). TOUT ETAT DE
! L'AIR REALISTE EST ADMIS EN ENTREE ET L'ALGORITHME PREND EN COMPTE
! AUTOMATIQUEMENT UNE POSSIBLE TRANSITION DE PHASE LIQUIDE/GLACE.
! TROIS EQUATIONS IMPLICITES SONT RESOLUES PAR METHODE DE NEWTON:
! - RECHERCHE DU POINT DE SATURATION D'ENTROPIE EGALE PAR
! TRANSFORMATION REVERSIBLE ;
! - RECHERCHE DU POINT DE TEMPERATURE EGALE A CELLE DU POINT
! TRIPLE LE LONG DE L'ADIABATIQUE SATUREE IRREVERSIBLE ;
! - RECHERCHE DU POINT DE PRESSION EGALE A LA REFERENCE
! ATMOSPHERIQUE LE LONG D'UNE AUTRE (PARFOIS LA MEME) ADIABATIQUE
! IRREVERSIBLE.
! REMARQUES :
! - POUR LA PREMIERE ETAPE LA FORME SYMETRIQUE DE L'ENTROPIE
! HUMIDE PROPOSEE PAR P. MARQUET EST UTILISEE AFIN DE PERMETTRE UN
! MELANGE DE PHASES LIQUIDE ET GLACE DANS L'ETAT DE L'AIR ;
! - POUR LES DEUX DERNIERES ETAPES, PLUTOT QUE DE NEGLIGER
! COMME DE COUTUME LE TERME CONTENANT LE CP DU CONDENSAT, L'AUTEUR
! DE LA ROUTINE EN A DERIVE UNE APPROXIMATION QUASI-EXACTE ET PLUTOT
! BON MARCHE ;
! - POUR CES DEUX MEMES ETAPES, LES EBAUCHES DES BOUCLES DE
! NEWTON SONT OBTENUES PAR EXTRAPOLATION D'UNE LINEARISATION LOCALE
! APPROCHEE DES EQUATIONS ADIABATIQUE SATUREES.
!
! THIS ROUTINE HAS ONLY ONE DIMENSIONAL INPUT/OUTPUT ARRAYS IN
! ORDER TO BE THE MOST GENERAL POSSIBLE (USE ON MODEL OR ON POST-
! PROCESSING LEVELS, FOR EXAMPLE). ALL POSSIBLE REALISTIC INPUT
! STATES ARE ALLOWED AND THE ALGORITHM AUTOMATICALLY TAKES INTO
! ACCOUNT THE POTENTIAL LIQUID/ICE WATER TRANSITION.
! THREE IMPLICIT EQUATIONS ARE SOLVED BY NEWTON METHODS :
! - SEARCH OF THE SATURATION POINT OF EQUAL ENTROPY UNDER A
! REVERSIBLE TRANSFORM ;
! - SEARCH OF THE POINT OF TEMPERATURE EQUAL TO THAT OF THE
! TRIPLE POINT ALONG THE IRREVERSIBLE MOIST ADIABAT ;
! - SEARCH OF THE POINT OF REFERENCE ATMOSPHERIC PRESSURE
! ALONG ANOTHER (SOMETIMES IDENTICAL) IRREVERSIBLE MOIST ADIABAT.
! REMARKS :
! - FOR THE FIRST STEP THE SYMETRIC FORM OF THE MOIST ENTROPY
! PROPOSED BY P. MARQUET IS USED IN ORDER TO ALLOW A MIX OF LIQUID
! AND ICE WATER IN THE ATMOSPHERIC STATE ;
! - FOR THE TWO LAST STEPS, RATHER THAN THE USUAL NEGLECTION
! OF THE TERM MULTIPLIED BY CP OF THE CONDENSATE, THE ROUTINE'S
! AUTHOR DERIVED A QUASI EXACT AND NOT TOO EXPENSIVE ANALYTICAL
! APPROXIMATION FOR IT ;
! - FOR THE SAME STEPS, THE GUESSES OF THE NEWTON LOOP ARE
! OBTAINED BY VERTICAL EXTRAPOLATION OF A LINEAR LOCAL APPROXIMATION
! OF THE MOIST ADIABATS.
!
! Auteur/author: 92-09, J.F. Geleyn.
!
! Modifications.
! --------------
! 96-04, J. Calvo: Introduced a minimun in RH instead of a mini-
! mun in PQV. Added a security threshold in the
! calculation of the triple  point pressure
! first guess.
! --------------------------------------------------------------
! En entree:
! En sortie:
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RCS
USE CONSTANTES, ONLY : RCW
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RESTT
USE CONSTANTES, ONLY : RKAPPA
USE CONSTANTES, ONLY : RTT
USE CONSTANTES, ONLY : RV, NBITER
IMPLICIT NONE
INTEGER :: JIT
REAL :: ZCPLNTT
REAL :: ZCWS
REAL :: ZDELTA
REAL :: ZDF
REAL :: ZDLEW
REAL :: ZDLSTT
REAL :: ZE
REAL :: ZEPSP
REAL :: ZEPSRH
REAL :: ZEW
REAL :: ZF
REAL :: ZKAPPA
REAL :: ZKDI
REAL :: ZKDW
REAL :: ZKNI
REAL :: ZKNW
REAL :: ZLH
REAL :: ZLHZ
REAL :: ZLHZI
REAL :: ZLHZW
REAL :: ZLSTC
REAL :: ZLSTT
REAL :: ZLSTTI
REAL :: ZLSTTW
REAL :: ZPRS
REAL :: ZQI
REAL :: ZQL
REAL :: ZQV
REAL :: ZQVSAT
REAL :: ZRDSV
REAL :: ZRI
REAL :: ZRL
REAL :: ZRS
REAL :: ZRV
REAL :: ZTIN
REAL :: ZTMAX
REAL :: ZTMIN,fth_folh,fth_qs,fth_es,fth_fodles,fth_thetapw_arp
!
REAL PP,PT,PQV,PQL,PQI
REAL ZRT,ZCPT,ZRRT,ZS1,ZCONS,ZTITER,ZDEL,ZS2,ZFUNCT,ZPITER
!
! *
! ------------------------------------------------------------------
! I - CALCUL DES CONSTANTES DERIVEES DE CELLES ISSUES DE YOMCST ET
! CONSTANTES DE SECURITE.
!
! COMPUTATION OF CONSTANTS DERIVED FROM THOSE CONTAINED IN
! YOMCST AND SECURITY CONSTANTS.
!
ZRDSV=RD/RV
ZLSTTW= fth_folh (RTT,0.0)/RTT+RCW*RV/( fth_folh (RTT,0.0)/RTT)
ZLSTTI= fth_folh (RTT,1.0)/RTT+RCS*RV/( fth_folh (RTT,1.0)/RTT)
ZLHZW= fth_folh (0.0,0.0)
ZLHZI= fth_folh (0.0,1.0)
ZKNW=RESTT* fth_folh (RTT,0.0)/(RV*RTT)
ZKNI=RESTT* fth_folh (RTT,1.0)/(RV*RTT)
ZKDW=RKAPPA*RESTT*( fth_folh (RTT,0.0)/(RV*RTT))**2
ZKDI=RKAPPA*RESTT*( fth_folh (RTT,1.0)/(RV*RTT))**2
ZCPLNTT=RCPD*LOG(RTT)
!
ZEPSP=10.
ZEPSRH=0.001
ZTMIN=155.
ZTMAX=355.
!
!
! *
! ------------------------------------------------------------------
! II - CALCUL DE LA TEMPERATURE DE SATURATION (EN GENERAL MAIS PAS
! FORCEMENT TEMPERATURE DU POINT DE CONDENSATION). LE RAPPORT DE
! MELANGE TOTAL ET LA TEMPERATURE POTENTIELLE HUMIDE -REVERSIBLE-
! SONT GARDES CONSTANTS DURANT L'OPERATION.
!
! COMPUTATION OF THE SATURATION TEMPERATURE (IN GENERAL BUT NOT
! SYSTEMATICALLY LIFTING CONDENSATION TEMPERATURE). THE TOTAL MIXING
! RATIO AND THE MOIST -REVERSIBLE- POTENTIAL TEMPERATURE ARE KEPT
! CONSTANT DURING THE PROCESS.
!
! - TEMPORAIRES .
!
! ZRT        : RAPPORT DE MELANGE TOTAL DE L'EAU.
! : TOTAL WATER MIXING RATIO.
! ZCPT       : PARTIE "CP" DU "KAPPA" IMPLICITE DE LA TEMP. CONSERVEE.
! : "CP" PART OF THE IMPLICIT "KAPPA" OF THE CONSERVED TEMP..
! ZRRT       : PARTIE "R" DU "KAPPA" IMPLICITE DE LA TEMP. CONSERVEE.
! : "R" PART OF THE IMPLICIT "KAPPA" OF THE CONSERVED TEMP..
! ZS1        : EXPRESSION DE L'ENTROPIE ASSOCIE A LA TEMP. CONSERVEE.
! : ENTROPY'S EXPRESSION LINKED TO THE CONSERVED TEMPERATURE.
! ZCONS      : CONSTANTE AUXILIAIRE POUR LA BOUCLE DE NEWTON.
! : AUXILIARY CONSTANT FOR THE NEWTON LOOP.
! ZTITER     : EBAUCHE POUR LA SOLUTION DE LA BOUCLE DE NEWTON EN TEMP..
! : FIRST GUESS FOR THE SOLUTION OF THE NEWTON LOOP ON TEMP..
! ZQVSAT     :
! : SATURATED SPECIFIC HUMIDITY
!
! CALCULS PRELIMINAIRES.
! PRELIMINARY COMPUTATIONS.
!
!
! SECURITES.
! SECURITIES.
!
! QVSAT CALCULATION DEPENING ON THE SNOW OPTION.
!
ZDELTA=MAX(0.0,SIGN(1.0,RTT-PT))
!
ZQL=MAX(0.0,PQL)
ZQI=MAX(0.0,PQI)
ZTIN=MAX(ZTMIN,MIN(ZTMAX,PT))
ZPRS=MAX(ZEPSP,PP)
ZQVSAT=FTH_QS(ZTIN,ZPRS)
ZQV=MAX(ZEPSRH*ZQVSAT,PQV)
!
ZRV=ZQV/(1.0-ZQV-ZQL-ZQI)
ZRL=ZQL/(1.0-ZQV-ZQL-ZQI)
ZRI=ZQI/(1.0-ZQV-ZQL-ZQI)
ZRT=ZRV+ZRL+ZRI
ZCPT=RCPD+RCPV*ZRT
ZRRT=RD+RV*ZRT
ZE=(ZRV*ZPRS)/(ZRV+ZRDSV)
ZS1=ZCPT*LOG(ZTIN)-RD*LOG(ZPRS-ZE)-RV*ZRT &
  & *LOG(ZE)-( fth_folh (ZTIN,0.0)*ZRL+ fth_folh (ZTIN,1.0)*ZRI)/ZTIN
ZCONS=ZS1+RD*LOG(ZRDSV/ZRT)
ZTITER=ZTIN
!
! BOUCLE DE NEWTON.
! NEWTON LOOP.
!
DO JIT=1,NBITER
  !
  ! CALCULS DEPENDANT DE L'OPTION NEIGE.
  ! SNOW OPTION DEPENDENT CALCULATIONS.
  !
  ZDELTA=MAX(0.0,SIGN(1.0,RTT-ZTITER))
  !
  ZEW= fth_es (ZTITER)
  ZDLEW= fth_fodles (ZTITER)
  ZF=ZCONS+ZRRT*LOG(ZEW)-ZCPT*LOG(ZTITER)
  ZDF=ZRRT*ZDLEW-ZCPT/ZTITER
  ZTITER=ZTITER-ZF/ZDF
ENDDO
!
! *
! ------------------------------------------------------------------
! III - CALCUL DE LA PRESSION CORRESPONDANT AU POINT TRIPLE LE LONG
! DE L'ADIABATIQUE SATUREE IRREVERSIBLE PASSANT PAR LE POINT CALCULE
! PRECEDEMMENT. DANS LE CAS "LNEIGE=.T." LA TEMPERATURE DU POINT EN
! QUESTION DETERMINE LE CHOIX DES PARAMETRES LIES A "L" ET "CP".
!
! COMPUTATION OF PRESSURE CORRESPONDING TO THE TRIPLE POINT ON
! THE IRREVERSIBLE SATURATED ADIABAT PASSING THROUGH THE PREVIOUSLY
! OBTAINED POINT. IN THE "LNEIGE=.T." CASE THE LATTER'S TEMPERATURE
! DETERMINES THE CHOICE OF THE PARAMETERS LINKED TO "L" AND "CP".
!
!
! - TEMPORAIRES .
!
! ZDEL       : "MEMOIRE" DE LA VALEUR ZDELTA (EAU 0 / GLACE 1).
! : "MEMORY" OF THE ZDELTA (WATER 0 / ICE 1) VALUE.
! ZFUNCT     : EXPRESSION UTILISEE DANS LA BOUCLE DE NEWTON.
! : FUNCTIONAL EXPRESSION USED IN THE NEWTON LOOP.
! ZS2        : EXPRESSION DE LA PSEUDO ENTROPIE DE L'AD. IRREVERSIBLE.
! : PSEUDO ENTROPY'S EXPRESSION FOR THE IRREVERSIBLE AD..
! ZPITER     : EBAUCHE POUR LA SOLUTION DE LA BOUCLE DE NEWTON EN PRES..
! : FIRST GUESS FOR THE SOLUTION OF THE NEWTON LOOP ON PRES..
!
! CALCULS PRELIMINAIRES.
! PRELIMINARY COMPUTATIONS.
!
!
! CALCULS DEPENDANT DE L'OPTION NEIGE.
! SNOW OPTION DEPENDENT CALCULATIONS.
!
ZDELTA=MAX(0.0,SIGN(1.0,RTT-ZTITER))
!
ZDEL=ZDELTA
ZEW= fth_es (ZTITER)
ZLSTT=ZLSTTW+ZDELTA*(ZLSTTI-ZLSTTW)
ZCWS=RCW+ZDELTA*(RCS-RCW)
ZLSTC= fth_folh (ZTITER,ZDELTA)/ZTITER+ZCWS*RV &
  & /( fth_folh (ZTITER,ZDELTA)/ZTITER)
ZFUNCT=ZRDSV*RESTT*ZLSTT
ZS2=ZS1+ZRT*(ZLSTC+RV*LOG(ZEW)-RCPV &
  & *LOG(ZTITER))
ZCONS=ZS2-ZCPLNTT
ZKAPPA=RKAPPA*(1.0+ZRT* fth_folh (ZTITER,ZDELTA)/(RD &
  & *ZTITER))/(1.0+RKAPPA*ZRT &
  & * fth_folh (ZTITER,ZDELTA)**2/(RD*RV*ZTITER**2))
ZPITER=(ZRDSV*ZEW/ZRT)*(RTT/ZTITER)**(1.0/ZKAPPA) &
  & -RESTT
ZPITER=MAX(ZPITER,ZEPSP)
!
! BOUCLE DE NEWTON (UNE ITERATION DE PLUS POUR P QUE POUR T).
! NEWTON LOOP (ONE MORE ITERATION FOR P THAN FOR T).
!
DO JIT=1,NBITER+1
  ZF=ZCONS+RD*LOG(ZPITER)-ZFUNCT/ZPITER
  ZDF=(RD*ZPITER+ZFUNCT)/ZPITER**2
  ZPITER=ZPITER-ZF/ZDF
ENDDO
!
! RETOUR A LA PRESSION REELLE.
! RETURN TO THE REAL PRESSURE.
!
ZPITER=ZPITER+RESTT
!
! *
! ------------------------------------------------------------------
! IV - CALCUL DE LA TEMPERATURE CORRESPONDANT A P STANDARD LE LONG
! DE L'ADIABATIQUE SATUREE IRREVERSIBLE PASSANT PAR LE POINT CALCULE
! PRECEDEMMENT. DANS LE CAS "LNEIGE=.T." LA PRESSION DU POINT EN
! QUESTION DETERMINE LE CHOIX DES PARAMETRES LIES A "L" ET "CP".
!
! COMPUTATION OF THE TEMPERATURE CORRESPONDING TO THE STD. P ON
! THE IRREVERSIBLE SATURATED ADIABAT PASSING THROUGH THE PREVIOUSLY
! OBTAINED POINT. IN THE "LNEIGE=.T." CASE THE LATTER'S PRESSURE
! DETERMINES THE CHOICE OF THE PARAMETERS LINKED TO "L" AND "CP".
!
! CALCULS PRELIMINAIRES.
! PRELIMINARY COMPUTATIONS.
!
!
! CALCULS DEPENDANT DE L'OPTION NEIGE.
! SNOW OPTION DEPENDENT CALCULATIONS.
!
ZDELTA=MAX(0.0,SIGN(1.0,ZPITER-RATM))
!
ZDLSTT=(ZDELTA-ZDEL)*(ZLSTTI-ZLSTTW)
ZDEL=ZDELTA
ZS2=ZS2+ZDLSTT*ZRDSV*RESTT/(ZPITER-RESTT)
ZKAPPA=RKAPPA*(1.0+(ZKNW+ZDELTA*(ZKNI-ZKNW))/ZPITER)/(1.0 &
  & +(ZKDW+ZDELTA*(ZKDI-ZKDW))/ZPITER)
ZTITER=RTT*(RATM/ZPITER)**ZKAPPA
!
! BOUCLE DE NEWTON.
! NEWTON LOOP.
!
DO JIT=1,NBITER
  ZEW= FTH_ES(ZTITER)
  ZCWS=RCW+ZDEL*(RCS-RCW)
  ZLHZ=ZLHZW+ZDEL*(ZLHZI-ZLHZW)
  ZLH= fth_folh (ZTITER,ZDEL)
  ZLSTC=ZLH/ZTITER+ZCWS*RV/(ZLH/ZTITER)
  ZRS=ZRDSV*ZEW/(RATM-ZEW)
  ZF=ZS2-RCPD*LOG(ZTITER)+RD*LOG(RATM-ZEW)-ZRS*ZLSTC
  ZDF=-RCPD/ZTITER-ZRS*((RATM/(RATM-ZEW))*ZLSTC*ZLH/(RV &
    &   *ZTITER**2)+ZCWS*RV*ZLHZ/ZLH**2+(RCPV-ZCWS) &
    &   /ZTITER)
  ZTITER=ZTITER-ZF/ZDF
ENDDO
!
! STOCKAGE DU RESULTAT.
! RESULT'S STORAGE.
!
fth_thetapw_arp=ZTITER
END
FUNCTION FTH_THETAV(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_thetav* Fonction température virtuelle potentielle.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_thetav en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RD
IMPLICIT NONE
REAL :: PP
REAL :: PQV
REAL :: PT
REAL :: fth_thetav,fth_tv
!
fth_thetav=FTH_TV(PT,PQV)*(RATM/PP)**(RD/RCPD)
END
FUNCTION FTH_THETAL(PP,PT,PQV,PQC)
! --------------------------------------------------------------
! //// *fth_thetal* Fonction température potentielle avec prise en compte de la flottabilité des condensats.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
!  Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press, 200 Madison Avenue, New York.
!  thetal calculé ici est celui associé à une transformation adiabatique humide réversible.
!  Si pqc est non nul, il est donc plus consistant d'avoir pqv=qsat.
! Externes:
! Auteur/author:   2001-07, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
!  pqc humidité spécifique de la somme de tous les condensats ayant atteint leur vitesse limite (qliq+qice+qrain+...) (sans dimension).
! En sortie:
!  fth_thetal en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RV
USE CONSTANTES, ONLY : RTT
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL :: PQV
REAL :: PQC
REAL :: fth_thetal,fth_folh
REAL :: ZRT,ZRL,ZKAPPA,ZGAMMA,ZGLACE,ZLV,ZMULT1,ZMULT2,ZMULT3
!
!-------------------------------------------------
! zrt: rapport de mélange total: vapeur + liq + glace + pluie + ...
!-------------------------------------------------
!
ZRT=(PQV+PQC)/(1.0-PQV-PQC)
!
!-------------------------------------------------
! zrl: rapport de mélange des condensats.
!-------------------------------------------------
!
ZRL=PQC/(1.0-PQV-PQC)
!
!-------------------------------------------------
! Kappa equ. (4.5.16) p122 Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press.
!-------------------------------------------------
!
ZKAPPA=(RD+ZRT*RV)/(RCPD+ZRT*RCPV)
!
!-------------------------------------------------
! Gamma equ. (4.5.16) p122 Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press.
!-------------------------------------------------
!
ZGAMMA=ZRT*RV/(RCPD+ZRT*RCPV)
!
!-------------------------------------------------
! zlv: chaleur latente.
!-------------------------------------------------
!
ZGLACE=MAX(0.0,SIGN(1.0,RTT-PT))
ZLV=FTH_FOLH(PT,ZGLACE)
!
!-------------------------------------------------
! thetal equ. (4.5.15) p121 Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press.
!-------------------------------------------------
!
ZMULT1=(1.0-ZRL/(RD/RV+ZRT))**ZKAPPA
IF(ZRL < ZRT) THEN
  ZMULT2=(1.0-ZRL/ZRT)**(-ZGAMMA)
ELSE
  ZMULT2=1.0
ENDIF
ZMULT3=EXP(-ZLV*ZRL/((RCPD+ZRT*RCPV)*PT))
fth_thetal=PT*(RATM/PP)**ZKAPPA &
  & *ZMULT1*ZMULT2*ZMULT3
END
FUNCTION FTH_THETAVL(PP,PT,PQV,PQC)
! --------------------------------------------------------------
! //// *fth_thetavl* Fonction température virtuelle potentielle avec prise en compte du poids des condensats.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2004-06, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
!  pqc humidité spécifique de la somme de tous les condensats ayant atteint leur vitesse limite (qliq+qice+qrain+...) (sans dimension).
! En sortie:
!  fth_thetavl en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL :: PQV
REAL :: PQC
REAL :: fth_thetavl,fth_tvl,fth_theta
fth_thetavl=FTH_THETA(PP,FTH_TVL(PT,PQV,PQC))
END
FUNCTION FTH_THETAVL_EMANUEL(PP,PT,PQV,PQC)
! --------------------------------------------------------------
! //// *fth_thetavl_emanuel* Fonction température virtuelle potentielle avec prise en compte de la chaleur latente potentielle des condensats.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
!  Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press, 200 Madison Avenue, New York.
!  Thetavl_emanuel calculé ici est celui associé à une transformation adiabatique humide réversible.
!  Si pqc est non nul, il est donc plus consistant d'avoir pqv=qsat.
! Externes:
! Auteur/author:   2001-07, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
!  pqc humidité spécifique de la somme de tous les condensats ayant atteint leur vitesse limite (qliq+qice+qrain+...) (sans dimension).
! En sortie:
!  fth_thetavl_emanuel en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RATM
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RV
USE CONSTANTES, ONLY : RTT
IMPLICIT NONE
REAL :: PP
REAL :: PT
REAL :: PQV
REAL :: PQC
REAL :: fth_thetavl_emanuel,fth_tv,fth_folh
REAL :: ZRT,ZRL,ZKAPPA,ZGAMMA,ZGLACE,ZLV,ZMULT1,ZMULT2,ZMULT3,ZMULT4
!
!-------------------------------------------------
! zrt: rapport de mélange total: vapeur + liq + glace + pluie + ...
!-------------------------------------------------
!
ZRT=(PQV+PQC)/(1.0-PQV-PQC)
!
!-------------------------------------------------
! zrl: rapport de mélange des condensats.
!-------------------------------------------------
!
ZRL=PQC/(1.0-PQV-PQC)
!
!-------------------------------------------------
! Kappa equ. (4.5.16) p122 Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press.
!-------------------------------------------------
!
ZKAPPA=(RD+ZRT*RV)/(RCPD+ZRT*RCPV)
!
!-------------------------------------------------
! Gamma equ. (4.5.16) p122 Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press.
!-------------------------------------------------
!
ZGAMMA=ZRT*RV/(RCPD+ZRT*RCPV)
!
!-------------------------------------------------
! zlv: chaleur latente.
!-------------------------------------------------
!
ZGLACE=MAX(0.0,SIGN(1.0,RTT-PT))
ZLV=FTH_FOLH(PT,ZGLACE)
!
!-------------------------------------------------
! Thetavl equ. (4.5.18) p122 Kerry A. Emanuel, "Atmospheric Convection", 1994 Oxford University Press.
!-------------------------------------------------
!
ZMULT1=(1.0-ZRL/(1.0+ZRT))
ZMULT2=(1.0-ZRL/(RD/RV+ZRT))**(ZKAPPA-1.0)
IF(ZRL < ZRT) THEN
  ZMULT3=(1.0-ZRL/ZRT)**(-ZGAMMA)
ELSE
  ZMULT3=1.0
ENDIF
ZMULT4=EXP(-ZLV*ZRL/((RCPD+ZRT*RCPV)*PT))
fth_thetavl_emanuel=FTH_TV(PT,PQV)*(RATM/PP)**ZKAPPA &
  & *ZMULT1*ZMULT2*ZMULT3*ZMULT4
END
FUNCTION FTH_TV(PT,PQV)
! --------------------------------------------------------------
! //// *fth_tv* Fonction température virtuelle, aussi appelée température de densité.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_tv en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RV
IMPLICIT NONE
REAL :: PQV
REAL :: PT,fth_tv
!
!-------------------------------------------------
! Expression de Tv.
!-------------------------------------------------
!
fth_tv=PT*(1.0+(RV/RD-1.0)*PQV)
END
FUNCTION FTH_TW(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_tw* TEMPERATURE PSEUDO-ADIABATIQUE DU THERMOMETRE MOUILLE (point "bleu").
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2000-10, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_tw (K).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PQV
REAL :: PT
REAL :: ZPCOND
REAL :: ZTCOND,fth_tw,fth_t_evol_ad_hum
!
!
!-------------------------------------------------
! On cherche le point de condensation.
!-------------------------------------------------
!
CALL FTH_POINT_CONDENS(PT,PQV,PP,ZTCOND,ZPCOND)
!
!-------------------------------------------------
! On revient au niveau courant
! selon une adiabatique humide.
!-------------------------------------------------
!
fth_tw=FTH_T_EVOL_AD_HUM(ZTCOND,ZPCOND,PP)
END
FUNCTION FTH_QW(PP,PT,PQV)
! --------------------------------------------------------------
! //// *fth_qw* HUMIDITE SPECIFIQUE PSEUDO-ADIABATIQUE DU THERMOMETRE MOUILLE (point "bleu").
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2004-10, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp pression en Pa.
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
! En sortie:
!  fth_qw (K).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
REAL :: PP
REAL :: PQV
REAL :: PT
REAL :: fth_tw,fth_qw,fth_qs
!
!-------------------------------------------------
! On cherche le point bleu.
!-------------------------------------------------
!
fth_qw=fth_qs(fth_tw(pp,pt,pqv),pp)
END
FUNCTION FTH_TW_ARP(PP,PT,PQV,PQL,PQI)
! --------------------------------------------------------------
! //// *fth_tw_arp* TEMPERATURE PSEUDO-ADIABATIQUE DU THERMOMETRE MOUILLE (point "bleu").
! --------------------------------------------------------------
! Sujet:
! CALCUL DE LA TEMPERATURE PSEUDO-ADIABATIQUE DU THERMOMETRE MOUILLE.
! Arguments explicites:
! Arguments implicites:
!
! Methode.
! --------
!
! CETTE ROUTINE N'A QU'UNE DIMENSION POUR SES VARIABLES D'ENTREE
! AFIN D'ETRE LA PLUS GENERALE POSSIBLE (UTILISATION SUR LES NIVEAUX
! DU MODELE COMME DU POST-PROCESSING, PAR EXEMPLE). TOUT ETAT DE
! L'AIR REALISTE EST ADMIS EN ENTREE ET L'ALGORITHME PREND EN COMPTE
! AUTOMATIQUEMENT UNE POSSIBLE TRANSITION DE PHASE LIQUIDE/GLACE.
! TROIS EQUATIONS IMPLICITES SONT RESOLUES PAR METHODE DE NEWTON:
! - RECHERCHE DU POINT DE SATURATION D'ENTROPIE EGALE PAR
! TRANSFORMATION REVERSIBLE ;
! - RECHERCHE DU POINT DE TEMPERATURE EGALE A CELLE DU POINT
! TRIPLE LE LONG DE L'ADIABATIQUE SATUREE IRREVERSIBLE ;
! - RECHERCHE DU POINT DE PRESSION EGALE A LA REFERENCE
! ATMOSPHERIQUE LE LONG D'UNE AUTRE (PARFOIS LA MEME) ADIABATIQUE
! IRREVERSIBLE.
! REMARQUES :
! - POUR LA PREMIERE ETAPE LA FORME SYMETRIQUE DE L'ENTROPIE
! HUMIDE PROPOSEE PAR P. MARQUET EST UTILISEE AFIN DE PERMETTRE UN
! MELANGE DE PHASES LIQUIDE ET GLACE DANS L'ETAT DE L'AIR ;
! - POUR LES DEUX DERNIERES ETAPES, PLUTOT QUE DE NEGLIGER
! COMME DE COUTUME LE TERME CONTENANT LE CP DU CONDENSAT, L'AUTEUR
! DE LA ROUTINE EN A DERIVE UNE APPROXIMATION QUASI-EXACTE ET PLUTOT
! BON MARCHE ;
! - POUR CES DEUX MEMES ETAPES, LES EBAUCHES DES BOUCLES DE
! NEWTON SONT OBTENUES PAR EXTRAPOLATION D'UNE LINEARISATION LOCALE
! APPROCHEE DES EQUATIONS ADIABATIQUE SATUREES.
!
! THIS ROUTINE HAS ONLY ONE DIMENSIONAL INPUT/OUTPUT ARRAYS IN
! ORDER TO BE THE MOST GENERAL POSSIBLE (USE ON MODEL OR ON POST-
! PROCESSING LEVELS, FOR EXAMPLE). ALL POSSIBLE REALISTIC INPUT
! STATES ARE ALLOWED AND THE ALGORITHM AUTOMATICALLY TAKES INTO
! ACCOUNT THE POTENTIAL LIQUID/ICE WATER TRANSITION.
! THREE IMPLICIT EQUATIONS ARE SOLVED BY NEWTON METHODS :
! - SEARCH OF THE SATURATION POINT OF EQUAL ENTROPY UNDER A
! REVERSIBLE TRANSFORM ;
! - SEARCH OF THE POINT OF TEMPERATURE EQUAL TO THAT OF THE
! TRIPLE POINT ALONG THE IRREVERSIBLE MOIST ADIABAT ;
! - SEARCH OF THE POINT OF REFERENCE ATMOSPHERIC PRESSURE
! ALONG ANOTHER (SOMETIMES IDENTICAL) IRREVERSIBLE MOIST ADIABAT.
! REMARKS :
! - FOR THE FIRST STEP THE SYMETRIC FORM OF THE MOIST ENTROPY
! PROPOSED BY P. MARQUET IS USED IN ORDER TO ALLOW A MIX OF LIQUID
! AND ICE WATER IN THE ATMOSPHERIC STATE ;
! - FOR THE TWO LAST STEPS, RATHER THAN THE USUAL NEGLECTION
! OF THE TERM MULTIPLIED BY CP OF THE CONDENSATE, THE ROUTINE'S
! AUTHOR DERIVED A QUASI EXACT AND NOT TOO EXPENSIVE ANALYTICAL
! APPROXIMATION FOR IT ;
! - FOR THE SAME STEPS, THE GUESSES OF THE NEWTON LOOP ARE
! OBTAINED BY VERTICAL EXTRAPOLATION OF A LINEAR LOCAL APPROXIMATION
! OF THE MOIST ADIABATS.
!
! Auteur/author: 92-09, J.F. Geleyn.
!
! Modifications.
! --------------
! 96-04, J. Calvo: Introduced a minimun in RH instead of a mini-
! mun in PQV. Added a security threshold in the
! calculation of the triple  point pressure
! first guess.
! --------------------------------------------------------------
! En entree:
! En sortie:
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RCS
USE CONSTANTES, ONLY : RCW
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RESTT
USE CONSTANTES, ONLY : RKAPPA
USE CONSTANTES, ONLY : RTT
USE CONSTANTES, ONLY : RV,NBITER
IMPLICIT NONE
INTEGER :: JIT
REAL :: ZCPLNTT
REAL :: ZCWS
REAL :: ZDELTA
REAL :: ZDF
REAL :: ZDLEW
REAL :: ZDLSTT
REAL :: ZE
REAL :: ZEPSP
REAL :: ZEPSRH
REAL :: ZEW
REAL :: ZF
REAL :: ZKAPPA
REAL :: ZKDI
REAL :: ZKDW
REAL :: ZKNI
REAL :: ZKNW
REAL :: ZLH
REAL :: ZLHZ
REAL :: ZLHZI
REAL :: ZLHZW
REAL :: ZLSTC
REAL :: ZLSTT
REAL :: ZLSTTI
REAL :: ZLSTTW
REAL :: ZPRS
REAL :: ZQI
REAL :: ZQL
REAL :: ZQV
REAL :: ZQVSAT
REAL :: ZRDSV
REAL :: ZRI
REAL :: ZRL
REAL :: ZRS
REAL :: ZRV
REAL :: ZTIN
REAL :: ZTMAX
REAL :: ZTMIN,fth_tw_arp
!
REAL PP,PT,PQV,PQL,PQI,fth_folh,fth_qs,fth_es,fth_fodles
REAL ZRT,ZCPT,ZRRT,ZS1,ZCONS,ZTITER,ZDEL,ZS2,ZFUNCT,ZPITER
!
! *
! ------------------------------------------------------------------
! I - CALCUL DES CONSTANTES DERIVEES DE CELLES ISSUES DE YOMCST ET
! CONSTANTES DE SECURITE.
!
! COMPUTATION OF CONSTANTS DERIVED FROM THOSE CONTAINED IN
! YOMCST AND SECURITY CONSTANTS.
!
ZRDSV=RD/RV
ZLSTTW= fth_folh (RTT,0.0)/RTT+RCW*RV/( fth_folh (RTT,0.0)/RTT)
ZLSTTI= fth_folh (RTT,1.0)/RTT+RCS*RV/( fth_folh (RTT,1.0)/RTT)
ZLHZW= fth_folh (0.0,0.0)
ZLHZI= fth_folh (0.0,1.0)
ZKNW=RESTT* fth_folh (RTT,0.0)/(RV*RTT)
ZKNI=RESTT* fth_folh (RTT,1.0)/(RV*RTT)
ZKDW=RKAPPA*RESTT*( fth_folh (RTT,0.0)/(RV*RTT))**2
ZKDI=RKAPPA*RESTT*( fth_folh (RTT,1.0)/(RV*RTT))**2
ZCPLNTT=RCPD*LOG(RTT)
!
ZEPSP=10.
ZEPSRH=0.001
ZTMIN=155.
ZTMAX=355.
!
!
! *
! ------------------------------------------------------------------
! II - CALCUL DE LA TEMPERATURE DE SATURATION (EN GENERAL MAIS PAS
! FORCEMENT TEMPERATURE DU POINT DE CONDENSATION). LE RAPPORT DE
! MELANGE TOTAL ET LA TEMPERATURE POTENTIELLE HUMIDE -REVERSIBLE-
! SONT GARDES CONSTANTS DURANT L'OPERATION.
!
! COMPUTATION OF THE SATURATION TEMPERATURE (IN GENERAL BUT NOT
! SYSTEMATICALLY LIFTING CONDENSATION TEMPERATURE). THE TOTAL MIXING
! RATIO AND THE MOIST -REVERSIBLE- POTENTIAL TEMPERATURE ARE KEPT
! CONSTANT DURING THE PROCESS.
!
! - TEMPORAIRES .
!
! ZRT        : RAPPORT DE MELANGE TOTAL DE L'EAU.
! : TOTAL WATER MIXING RATIO.
! ZCPT       : PARTIE "CP" DU "KAPPA" IMPLICITE DE LA TEMP. CONSERVEE.
! : "CP" PART OF THE IMPLICIT "KAPPA" OF THE CONSERVED TEMP..
! ZRRT       : PARTIE "R" DU "KAPPA" IMPLICITE DE LA TEMP. CONSERVEE.
! : "R" PART OF THE IMPLICIT "KAPPA" OF THE CONSERVED TEMP..
! ZS1        : EXPRESSION DE L'ENTROPIE ASSOCIE A LA TEMP. CONSERVEE.
! : ENTROPY'S EXPRESSION LINKED TO THE CONSERVED TEMPERATURE.
! ZCONS      : CONSTANTE AUXILIAIRE POUR LA BOUCLE DE NEWTON.
! : AUXILIARY CONSTANT FOR THE NEWTON LOOP.
! ZTITER     : EBAUCHE POUR LA SOLUTION DE LA BOUCLE DE NEWTON EN TEMP..
! : FIRST GUESS FOR THE SOLUTION OF THE NEWTON LOOP ON TEMP..
! ZQVSAT     :
! : SATURATED SPECIFIC HUMIDITY
!
! CALCULS PRELIMINAIRES.
! PRELIMINARY COMPUTATIONS.
!
!
! SECURITES.
! SECURITIES.
!
! QVSAT CALCULATION DEPENING ON THE SNOW OPTION.
!
ZDELTA=MAX(0.0,SIGN(1.0,RTT-PT))
!
ZQL=MAX(0.0,PQL)
ZQI=MAX(0.0,PQI)
ZTIN=MAX(ZTMIN,MIN(ZTMAX,PT))
ZPRS=MAX(ZEPSP,PP)
ZQVSAT=FTH_QS(ZTIN,ZPRS)
ZQV=MAX(ZEPSRH*ZQVSAT,PQV)
!
ZRV=ZQV/(1.0-ZQV-ZQL-ZQI)
ZRL=ZQL/(1.0-ZQV-ZQL-ZQI)
ZRI=ZQI/(1.0-ZQV-ZQL-ZQI)
ZRT=ZRV+ZRL+ZRI
ZCPT=RCPD+RCPV*ZRT
ZRRT=RD+RV*ZRT
ZE=(ZRV*ZPRS)/(ZRV+ZRDSV)
ZS1=ZCPT*LOG(ZTIN)-RD*LOG(ZPRS-ZE)-RV*ZRT &
  & *LOG(ZE)-( fth_folh (ZTIN,0.0)*ZRL+ fth_folh (ZTIN,1.0)*ZRI)/ZTIN
ZCONS=ZS1+RD*LOG(ZRDSV/ZRT)
ZTITER=ZTIN
!
! BOUCLE DE NEWTON.
! NEWTON LOOP.
!
DO JIT=1,NBITER
  !
  ! CALCULS DEPENDANT DE L'OPTION NEIGE.
  ! SNOW OPTION DEPENDENT CALCULATIONS.
  !
  ZDELTA=MAX(0.0,SIGN(1.0,RTT-ZTITER))
  !
  ZEW= fth_es (ZTITER)
  ZDLEW= fth_fodles (ZTITER)
  ZF=ZCONS+ZRRT*LOG(ZEW)-ZCPT*LOG(ZTITER)
  ZDF=ZRRT*ZDLEW-ZCPT/ZTITER
  ZTITER=ZTITER-ZF/ZDF
ENDDO
!
! *
! ------------------------------------------------------------------
! III - CALCUL DE LA PRESSION CORRESPONDANT AU POINT TRIPLE LE LONG
! DE L'ADIABATIQUE SATUREE IRREVERSIBLE PASSANT PAR LE POINT CALCULE
! PRECEDEMMENT. DANS LE CAS "LNEIGE=.T." LA TEMPERATURE DU POINT EN
! QUESTION DETERMINE LE CHOIX DES PARAMETRES LIES A "L" ET "CP".
!
! COMPUTATION OF PRESSURE CORRESPONDING TO THE TRIPLE POINT ON
! THE IRREVERSIBLE SATURATED ADIABAT PASSING THROUGH THE PREVIOUSLY
! OBTAINED POINT. IN THE "LNEIGE=.T." CASE THE LATTER'S TEMPERATURE
! DETERMINES THE CHOICE OF THE PARAMETERS LINKED TO "L" AND "CP".
!
! - TEMPORAIRES .
!
! ZDEL       : "MEMOIRE" DE LA VALEUR ZDELTA (EAU 0 / GLACE 1).
! : "MEMORY" OF THE ZDELTA (WATER 0 / ICE 1) VALUE.
! ZFUNCT     : EXPRESSION UTILISEE DANS LA BOUCLE DE NEWTON.
! : FUNCTIONAL EXPRESSION USED IN THE NEWTON LOOP.
! ZS2        : EXPRESSION DE LA PSEUDO ENTROPIE DE L'AD. IRREVERSIBLE.
! : PSEUDO ENTROPY'S EXPRESSION FOR THE IRREVERSIBLE AD..
! ZPITER     : EBAUCHE POUR LA SOLUTION DE LA BOUCLE DE NEWTON EN PRES..
! : FIRST GUESS FOR THE SOLUTION OF THE NEWTON LOOP ON PRES..
!
! CALCULS PRELIMINAIRES.
! PRELIMINARY COMPUTATIONS.
!
!
! CALCULS DEPENDANT DE L'OPTION NEIGE.
! SNOW OPTION DEPENDENT CALCULATIONS.
!
ZDELTA=MAX(0.0,SIGN(1.0,RTT-ZTITER))
!
ZDEL=ZDELTA
ZEW= fth_es (ZTITER)
ZLSTT=ZLSTTW+ZDELTA*(ZLSTTI-ZLSTTW)
ZCWS=RCW+ZDELTA*(RCS-RCW)
ZLSTC= fth_folh (ZTITER,ZDELTA)/ZTITER+ZCWS*RV &
  & /( fth_folh (ZTITER,ZDELTA)/ZTITER)
ZFUNCT=ZRDSV*RESTT*ZLSTT
ZS2=ZS1+ZRT*(ZLSTC+RV*LOG(ZEW)-RCPV &
  & *LOG(ZTITER))
ZCONS=ZS2-ZCPLNTT
ZKAPPA=RKAPPA*(1.0+ZRT* fth_folh (ZTITER,ZDELTA)/(RD &
  & *ZTITER))/(1.0+RKAPPA*ZRT &
  & * fth_folh (ZTITER,ZDELTA)**2/(RD*RV*ZTITER**2))
ZPITER=(ZRDSV*ZEW/ZRT)*(RTT/ZTITER)**(1.0/ZKAPPA) &
  & -RESTT
ZPITER=MAX(ZPITER,ZEPSP)
!
! BOUCLE DE NEWTON (UNE ITERATION DE PLUS POUR P QUE POUR T).
! NEWTON LOOP (ONE MORE ITERATION FOR P THAN FOR T).
!
DO JIT=1,NBITER+1
  ZF=ZCONS+RD*LOG(ZPITER)-ZFUNCT/ZPITER
  ZDF=(RD*ZPITER+ZFUNCT)/ZPITER**2
  ZPITER=ZPITER-ZF/ZDF
ENDDO
!
! RETOUR A LA PRESSION REELLE.
! RETURN TO THE REAL PRESSURE.
!
ZPITER=ZPITER+RESTT
!
! *
! ------------------------------------------------------------------
! IV - CALCUL DE LA TEMPERATURE CORRESPONDANT A P STANDARD LE LONG
! DE L'ADIABATIQUE SATUREE IRREVERSIBLE PASSANT PAR LE POINT CALCULE
! PRECEDEMMENT. DANS LE CAS "LNEIGE=.T." LA PRESSION DU POINT EN
! QUESTION DETERMINE LE CHOIX DES PARAMETRES LIES A "L" ET "CP".
!
! COMPUTATION OF THE TEMPERATURE CORRESPONDING TO THE STD. P ON
! THE IRREVERSIBLE SATURATED ADIABAT PASSING THROUGH THE PREVIOUSLY
! OBTAINED POINT. IN THE "LNEIGE=.T." CASE THE LATTER'S PRESSURE
! DETERMINES THE CHOICE OF THE PARAMETERS LINKED TO "L" AND "CP".
!
! CALCULS PRELIMINAIRES.
! PRELIMINARY COMPUTATIONS.
!
!
! CALCULS DEPENDANT DE L'OPTION NEIGE.
! SNOW OPTION DEPENDENT CALCULATIONS.
!
ZDELTA=MAX(0.0,SIGN(1.0,ZPITER-PP))
!
ZDLSTT=(ZDELTA-ZDEL)*(ZLSTTI-ZLSTTW)
ZDEL=ZDELTA
ZS2=ZS2+ZDLSTT*ZRDSV*RESTT/(ZPITER-RESTT)
ZKAPPA=RKAPPA*(1.0+(ZKNW+ZDELTA*(ZKNI-ZKNW))/ZPITER)/(1.0 &
  & +(ZKDW+ZDELTA*(ZKDI-ZKDW))/ZPITER)
ZTITER=RTT*(PP/ZPITER)**ZKAPPA
!
! BOUCLE DE NEWTON.
! NEWTON LOOP.
!
DO JIT=1,NBITER
  ZEW= FTH_ES(ZTITER)
  ZCWS=RCW+ZDEL*(RCS-RCW)
  ZLHZ=ZLHZW+ZDEL*(ZLHZI-ZLHZW)
  ZLH= fth_folh (ZTITER,ZDEL)
  ZLSTC=ZLH/ZTITER+ZCWS*RV/(ZLH/ZTITER)
  ZRS=ZRDSV*ZEW/(PP-ZEW)
  ZF=ZS2-RCPD*LOG(ZTITER)+RD*LOG(PP-ZEW)-ZRS*ZLSTC
  ZDF=-RCPD/ZTITER-ZRS*((PP/(PP-ZEW))*ZLSTC*ZLH/(RV &
    &   *ZTITER**2)+ZCWS*RV*ZLHZ/ZLH**2+(RCPV-ZCWS) &
    &   /ZTITER)
  ZTITER=ZTITER-ZF/ZDF
ENDDO
!
! STOCKAGE DU RESULTAT.
! RESULT'S STORAGE.
!
fth_tw_arp=ZTITER
END
FUNCTION FTH_TVL(PT,PQV,PQC)
! --------------------------------------------------------------
! //// *fth_tvl* Fonction température de densité: température virtuelle plus effets de flottabilité des condensats.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur:   2001-07, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pt température en K.
!  pqv humidité spécifique de la vapeur d'eau (sans dimension).
!  pqc humidité spécifique de la somme de tous les condensats ayant atteint leur vitesse limite (qliq+qice+qrain+...) (sans dimension).
! En sortie:
!  fth_tvl en K.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RV
IMPLICIT NONE
REAL :: PQV,PQC
REAL :: PT,fth_tvl
!
!-------------------------------------------------
! Expression de tvl.
!-------------------------------------------------
!
fth_tvl=PT*(1.0+(RV/RD-1.0)*PQV-PQC)
END
FUNCTION FTH_T_EVOL_AD_HUM(PT0,PP0,PP1)
! --------------------------------------------------------------
! //// *fth_t_evol_ad_hum* Calcul de l'état final d'une évolution pseudo-adiabatique humide.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
!  On résout en T
!       f(T)=cp*(T-T0)+L*(q-q0)+phi1-phi0=0
!  soit f(T)=cp*(T-T0)+L*(q-q0)-R*T*log(p1/p0)=0
!  avec la contrainte q=fth_qs(T,p1), et sachant que q0=fth_qs(T0,p0).
!  On résout par la méthode de Newton, en itérant
!  T --> T-f(T)/f'(T), avec pour point de départ T0.
! Externes:
! Auteur/author:   2000-09, J.M. Piriou.
! Modifications:
!     2010-02-04, J.M. Piriou. Suppression du calcul adiabatique au-dessus de l'altitude 150hPa.
! --------------------------------------------------------------
! En entree:
!  pt0: température de départ (K).
!  pp0: pression de départ (Pa).
!  pp1: pression d'arrivée (Pa).
! En sortie:
!  température d'arrivée (K).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RCPD
USE CONSTANTES, ONLY : RCPV
USE CONSTANTES, ONLY : RD
USE CONSTANTES, ONLY : RTT
USE CONSTANTES, ONLY : RV
IMPLICIT NONE
INTEGER :: IETAPES,ITRAC,JTRAC
INTEGER :: JETAPES
INTEGER :: JIT,ITERMAX,iul
LOGICAL :: LLFIN_ADIAB
REAL :: PP1
REAL :: PP0
REAL :: PT0
REAL :: ZGLACE
REAL :: ZETAPE
REAL :: ZLOG
REAL :: ZP_ARRIVEE
REAL :: ZP_DEPART
REAL :: ZT
REAL :: ZT_DEPART,fth_t_evol_ad_hum
REAL :: ZT_PREC
REAL :: ZDERI,ZF0,ZF1,fth_delta_h_ad_hum,ZTDERI,ZXT
REAL :: ZQS,fth_t_evol_ad_seche,zfrac
CHARACTER(LEN=200) CLFIC
ZT=PT0
!
!-------------------------------------------------
! L'écart de pression à effectuer doit être
! cassé en suffisamment d'étapes pour que le calcul
! discret soit suffisamment précis.
!-------------------------------------------------
!
ZETAPE=1000. ! pas de pression pour la discrétisation verticale (Pa).
IETAPES=NINT(ABS(PP1-PP0)/ZETAPE)+1
DO JETAPES=1,IETAPES
  ZP_DEPART=PP0+(PP1-PP0)*REAL(JETAPES-1)/REAL(IETAPES)
  ZP_ARRIVEE=PP0+(PP1-PP0)*REAL(JETAPES)/REAL(IETAPES)
  ZT_DEPART=ZT
  ZLOG=LOG(ZP_ARRIVEE/ZP_DEPART)
  !
  ! -------------------------------------------------
  ! Chaleur latente.
  ! -------------------------------------------------
  !
  ZGLACE=MAX(0.0,SIGN(1.0,RTT-ZT_DEPART))
  IF(.false.) THEN
    !
    ! -------------------------------------------------
    ! Mode mise au point.
    ! On écrit sur fichier la courbe fonction de T
    ! dont on cherche ici le zéro.
    ! -------------------------------------------------
    !
    write(clfic,fmt='(a,i2.2,a)') 'fonctionnelle.',jetapes,'.tmp.dta'
    iul=40 ; open(iul,file=clfic,form='formatted')
    write(iul,fmt=*) 'ZT_DEPART=',ZT_DEPART
    write(iul,fmt=*) 'ZP_DEPART=',ZP_DEPART
    write(iul,fmt=*) 'ZP_ARRIVEE=',ZP_ARRIVEE
    write(iul,fmt=*) ' '
    ITRAC=130
    DO JTRAC=1,ITRAC
      ZFRAC=REAL(JTRAC-1)/REAL(ITRAC-1)
      ZXT=1. *(1.-ZFRAC)     + 400.  *ZFRAC
      ZF0=FTH_DELTA_H_AD_HUM(ZP_ARRIVEE,ZXT,ZP_DEPART,ZT_DEPART,ZGLACE,ZLOG)
      WRITE(iul,*) ZXT,ZF0
    ENDDO
    close(iul)
  ENDIF
  ITERMAX=15
  DO JIT=1,ITERMAX
    !
    ! -------------------------------------------------
    ! Itération de Newton. On résout fth_delta_h_ad_hum = 0.
    ! -------------------------------------------------
    !
    ZF0=FTH_DELTA_H_AD_HUM(ZP_ARRIVEE,ZT,ZP_DEPART,ZT_DEPART,ZGLACE,ZLOG)
    ZTDERI=ZT+0.1
    ZF1=FTH_DELTA_H_AD_HUM(ZP_ARRIVEE,ZTDERI,ZP_DEPART,ZT_DEPART,ZGLACE,ZLOG)
    ZDERI=(ZF1-ZF0)/(ZTDERI-ZT)
    ! write(*,fmt='(a,/,80g13.5)') 'Debug: jetapes,zp_depart,zp_arrivee,jit,zt,zf0,zf1,zderi = ',jetapes,zp_depart,zp_arrivee,jit,zt,zf0,zf1,zderi
    !
    ! -------------------------------------------------
    ! La fonction dont on cherche le zéro est convexe.
    ! Elle est donc a priori favorable à une recherche de zéro
    ! par la méthode de Newton.
    ! Elle comporte un seul zéro. Sa dérivée est positive au lieu du zéro.
    ! Cependant sa dérivée peut être négative, pour les valeurs faibles
    ! de T. Donc si l'ébauche est trop froide, l'algorithme ne converge pas.
    ! Donc ci-dessous, si la dérivée est négative on force une ébauche
    ! plus grande.
    ! -------------------------------------------------
    !
    ZT_PREC=ZT
    IF(ZDERI <= 0.) THEN
      write(*,fmt=*) 'FTH_T_EVOL_AD_HUM: dérivée négative'
      write(*,fmt=*) '  zt=',zt
      write(*,fmt=*) '  ZT_DEPART=',ZT_DEPART
      write(*,fmt=*) '  ZP_DEPART=',ZP_DEPART
      write(*,fmt=*) '  ZP_ARRIVEE=',ZP_ARRIVEE
      ZT=400.
    ELSE
      ZT=ZT-ZF0/ZDERI
    ENDIF
    IF(ZT < 100. .OR. ZT > 400.) THEN
      ZT=400.
    ENDIF
    !
    ! -------------------------------------------------
    ! On sort de la boucle de Newton
    ! si on a la solution à epsilon près.
    ! -------------------------------------------------
    !
    IF(ABS(ZT-ZT_PREC) < 0.01) EXIT
    !IF(JIT == ITERMAX) THEN
    !  WRITE(*,FMT=*) 'fth_t_evol_ad_hum/ATTENTION: non convergence de l''algorithme de Newton après ',ITERMAX,' itérations'
    !  WRITE(*,FMT=*) '  pt0,PP0,PP1=',PT0,PP0,PP1
    !  WRITE(*,FMT=*) '  fth_t_evol_ad_hum=',ZT
    !ENDIF
  ENDDO
ENDDO
fth_t_evol_ad_hum=ZT
END
FUNCTION FTH_TPHIG(PP,PT,CDMETHODE)
! --------------------------------------------------------------
! //// *fth_tphig* Calcul de la coordonnée X dans un T-Phi-gramme.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2004-03, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp: pression de départ (Pa).
!  pt: température de départ (K).
!  cdmethode: méthode utilisée pour bâtir le T-Phi-gramme.
! En sortie:
!  température d'arrivée (K).
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY: RTT,RATM
IMPLICIT NONE
REAL :: PP,PT
REAL :: fth_tphig,fth_theta,fth_thetapw,fth_qs
CHARACTER*(*) CDMETHODE
IF(TRIM(CDMETHODE) == 'AS') THEN
  !
  ! -------------------------------------------------
  ! Adiabatique sèche.
  ! Le T-Phi-gramme consiste à ramener adiabatiquement au niveau 1000hPa.
  ! Dans un tel T-Phi-gramme une ascendance adiabatique sèche (theta)
  ! est verticale.
  ! -------------------------------------------------
  !
  fth_tphig=FTH_THETA(PP,PT)
ELSEIF(TRIM(CDMETHODE) == 'PAH') THEN
  !
  ! -------------------------------------------------
  ! Pseudo-adiabatique humide.
  ! Le T-Phi-gramme consiste à ramener au niveau 1000hPa
  ! selon une pseudo-adiabatique humide.
  ! Dans un tel T-Phi-gramme une ascendance pseudo-adiabatique humide (theta'w)
  ! est verticale.
  ! -------------------------------------------------
  !
  fth_tphig=FTH_THETAPW(PP,PT,FTH_QS(PT,PP))
ELSEIF(TRIM(CDMETHODE) == 'E761') THEN
  !
  ! -------------------------------------------------
  ! Le T-Phi-gramme consiste à ramener au niveau 1000hPa
  ! selon la relation entre T et p de l'émagramme
  ! oblique à 45°, dit "Emagramme 761".
  ! Sur cet émagramme particulier on a
  ! y = 764.4 - 254.8 * log10(p), avec y en mm, p en hPa.
  ! x = 2.91 * T + 764.4 - 254.8 * log10(p), avec x en mm, T en °C, p en hPa.
  ! Ici on ne cherche pas à spécifier x et y, mais seulement à ramener
  ! au niveau standard avec la même relation entre T et p que cet émagramme.
  ! Donc, connaissant T et p en entrée, on déduit y.
  ! Connaissant y, on ramène à y=0 à x constant.
  ! On en déduit le nouveau T.
  ! On résout donc en fth_tphig:
  ! 2.91 * (pt-rtt)    + 764.4 - 254.8 * log10(pp/100.)
  ! = 2.91 * (fth_tphig-rtt) + 764.4 - 254.8 * log10(1000.)
  ! dont la solution est
  ! fth_tphig = pt + 254.8 * log10(100000./pp)/2.91
  ! -------------------------------------------------
  !
  fth_tphig=PT+254.8*LOG(RATM/PP)/LOG(10.)/2.91
ELSE
  WRITE(*,FMT=*) 'fth_tphig/ERREUR: méthode inconnue!...'
  WRITE(*,FMT=*) TRIM(CDMETHODE)
  STOP 'call abort'
ENDIF
END
SUBROUTINE FTH_CIN_CAPE_SIMPL(KLEV,PT,PQV,PP,PCIN,PCAPE,KLEVX)
! --------------------------------------------------------------
! //// *fth_cin_cape_simpl* Version simplifiée de calculs de CAPE et CIN.
! --------------------------------------------------------------
! Subject:
! Method:
! Externals:
! Auteur/author:   2004-05, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! In input:
! ----------
!  INTEGER: klev: number of levels.
!  REAL: pt: temperature (K).
!  REAL: pqv: specific humidity (no dim).
!  REAL: pp: pressure (Pa).
! WARNING: pressure values are supposed to icrease from pp(1) to pp(klev).
!
! In output:
! -----------
!  REAL: pcin (J/kg): CIN de la particule ayant la CAPE maxi.
!  REAL: pcape (J/kg): CAPE maxi de ce profil.
!  INTEGER: klevx: niveau de la particule présentant cette CAPE maxi.
! --------------------------------------------------------------
!
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
!
!-------------------------------------------------
! Arguments.
!-------------------------------------------------
!
INTEGER :: KLEV
REAL :: PT(KLEV)
REAL :: PQV(KLEV)
REAL :: PP(KLEV)
REAL :: PCIN
REAL :: PCAPE
INTEGER :: KLEVX
logical :: llverbose
!
!-------------------------------------------------
! Variables locales.
!-------------------------------------------------
!
REAL :: ZRETAINED,ZENTR,ZCAPE(KLEV),ZCIN(KLEV)

INTEGER :: ILC(KLEV)
INTEGER :: ILFC(KLEV)
INTEGER :: ILNB(KLEV)

REAL :: ZLC(KLEV)
REAL :: ZLFC(KLEV)
REAL :: ZLNB(KLEV)

INTEGER :: ICLOUD(KLEV),JLEV
REAL :: ZMC(KLEV)
REAL :: ZTHETAE_TOP(KLEV)
REAL :: ZPREC
!
!-------------------------------------------------
! Calcul complet de CIN et CAPE.
!-------------------------------------------------
!
ZRETAINED=0.
ZENTR=1.e-4
CALL FTH_CIN_CAPE(.false.,KLEV,PT,PQV,PP,ZRETAINED,ZENTR,ZCIN,ZCAPE,ILC,ILFC &
  & ,ILNB,ZLC,ZLFC,ZLNB,ICLOUD,ZMC,ZTHETAE_TOP,ZPREC)
!
!-------------------------------------------------
! Calcul de la CAPE maxi, et CIN de ce niveau de CAPE maxi.
!-------------------------------------------------
!
PCAPE=0.
PCIN=0.
KLEVX=KLEV
DO JLEV=1,KLEV
  IF(ZCAPE(JLEV) > PCAPE) THEN
    PCAPE=ZCAPE(JLEV)
    PCIN=ZCIN(JLEV)
    KLEVX=JLEV
  ENDIF
ENDDO
!
!-------------------------------------------------
! Diagnostics sur output standard.
!-------------------------------------------------
!
llverbose=.true.
if(llverbose) then
  write(*,fmt=*) 'FTH_CIN_CAPE_SIMPL:'
  write(*,fmt=*) '  Ascendance avec un entraînement de ',zentr,' m^-1.'
  write(*,fmt=*) '  CAPE maxi=',PCAPE,' CIN=',PCIN
  write(*,fmt=*) '  Niveau de départ de la particule de CAPE maxi: ',klevx,', p=',pp(klevx)/100.,' hPa.'
  write(*,fmt=*) '  Niveau de neutralité de cette particule: ',ilnb(klevx),', p=',zlnb(klevx)/100.,' hPa.'
  write(*,fmt=*) '  '
endif
END
SUBROUTINE FTH_AJUSTEMENT(PP,PT0,PQV0,PQC0,PT1,PQV1,PQC1)
! --------------------------------------------------------------
! //// *fth_ajustement* mise en cohérence de (p,T,qv,qc).
! --------------------------------------------------------------
! Subject:
!
! Ajustement thermodynamique:
!    - En entrée (T,qv,qc) peut être tel que qv > qsat.
!      On va alors condenser la vapeur d'eau jusqu'à atteindre fth_hr=1.
!      qv se trouve donc diminué et qc augmenté de la même quantité.
!      T se trouve augmenté.
!      En sortie on a qv1=qsat(T1,p).
!    - En entrée (T,qv,qc) peut être tel que qv < qsat.
!      En ce cas si qc > 0, on va évaporer qc.
!      On évapore qc sous deux conditions:
!      1. que qv résultant ne dépasse pas qs(T,p).
!      2. on ne peut évaporer plus que la valeur de qc!...
!      En sortie on a
!        - soit qv1=qsat(T1,p) et alors qc1 peut être > 0.
!        - soit qv1<qsat(T1,p) et alors qc1=0.
! Method:
! Externals:
! Auteur/author:   2004-05, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! In input:
! ----------
!  REAL: pp: pressure (Pa).
!  REAL: pt0: temperature (K).
!  REAL: pqv0: water vapour specific humidity (no dim).
!  REAL: pqc0: condensated water (liquid + solid) specific humidity (no dim).
!
! In output:
! -----------
!  REAL: pt1: temperature (K).
!  REAL: pqv1: water vapour specific humidity (no dim).
!  REAL: pqc1: condensated water (liquid + solid) specific humidity (no dim).
! --------------------------------------------------------------
!
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
!
!-------------------------------------------------
! Arguments.
!-------------------------------------------------
!
REAL, intent(in) :: PP,PT0,PQV0,PQC0
REAL, intent(out) :: PT1,PQV1,PQC1
!
!-------------------------------------------------
! Local.
!-------------------------------------------------
!
REAL :: ZQS,fth_qs
!
!-------------------------------------------------
! Tests de cohérence.
!-------------------------------------------------
!
if(pqc0 < 0.) then
  write(*,fmt=*) 
  write(*,fmt=*) 'fth_ajustement/ATTENTION: eau condensée < 0.!...'
  write(*,fmt=*) 'pp,pt0,pqv0,pqc0=',pp,pt0,pqv0,pqc0
endif
if(pqv0 < 0.) then
  write(*,fmt=*) 
  write(*,fmt=*) 'fth_ajustement/ATTENTION: eau vapeur < 0.!...'
  write(*,fmt=*) 'pp,pt0,pqv0,pqc0=',pp,pt0,pqv0,pqc0
endif
!
!-------------------------------------------------
! Calculs.
!-------------------------------------------------
!
ZQS=FTH_QS(PT0,PP)
IF(PQV0 > ZQS) THEN
  !
  ! -------------------------------------------------
  ! Cas sursaturé.
  ! Condensation isobare.
  ! -------------------------------------------------
  !
  CALL FTH_EVOL_AD_HUM_ISOBARE(PT0,PQV0,PP,PT1,PQV1)
  PQC1=PQC0+PQV0-PQV1
ELSE
  !
  ! -------------------------------------------------
  ! Cas soussaturé.
  ! Evaporation isobare.
  ! -------------------------------------------------
  !
  CALL FTH_EVAPO_ISOBARE(PT0,PQV0,PQC0,PP,PT1,PQV1,PQC1)
ENDIF
END
FUNCTION fth_thetae_bolton_inv(pp,pthetae,pqv)
! --------------------------------------------------------------
! //// *fth_thetae_bolton_inv* Inversion en T de la fonction thetae.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2004-12, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  pp: pression de départ (Pa).
!  pthetae: thetae de départ (K).
!  pqv: humidité spécifique vapeur d'eau.
! En sortie:
!  température associée T (K), telle que thetae(pp,T,pqv)=pthetae.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
USE CONSTANTES, ONLY : RLVTT
USE CONSTANTES, ONLY : RCPD
IMPLICIT NONE
!
!-------------------------------------------------
! Arguments.
!-------------------------------------------------
!
REAL, intent(in) :: PP,pthetae,pqv
REAL :: fth_thetae_bolton_inv
!
!-------------------------------------------------
! Locaux.
!-------------------------------------------------
!
REAL :: FTH_THETAE_BOLTON,zf,zdt,zfprime,zincrement,zt,fth_t
INTEGER :: jit
!
!-------------------------------------------------
! Boucle de Newton pour résoudre en T thetae(pp,T,pqv)=pthetae.
!-------------------------------------------------
!
!
! Ebauche de T: inverse de theta, moins L/cp fois pqv.
!
zt=fth_t(pp,pthetae)-rlvtt/rcpd*pqv
!
! Boucle.
!
do jit=1,10
  !
  !-------------------------------------------------
  ! Valeur de la fonction.
  !-------------------------------------------------
  !
  zf=FTH_THETAE_BOLTON(pp,zt,pqv)-pthetae
  zdt=0.02
  zfprime=(FTH_THETAE_BOLTON(pp,zt+zdt,pqv)-pthetae-zf)/zdt
  zincrement=-zf/zfprime
  zt=zt+zincrement
  !
  ! -------------------------------------------------
  ! On sort de la boucle de Newton
  ! si on a la solution à epsilon près.
  ! -------------------------------------------------
  !
  if(abs(zincrement) < 0.01) exit
enddo
!
!-------------------------------------------------
! On affecte le résultat dans la fonction de sortie.
!-------------------------------------------------
!
fth_thetae_bolton_inv=zt
END
FUNCTION fth_pinterpole(pycou,pyprec,ppcou,ppprec)
! --------------------------------------------------------------
! //// *fth_pinterpole* Calcul de l'altitude-pression à laquelle une fonction affine s'annule.
! --------------------------------------------------------------
! Sujet:
! Arguments explicites:
! Arguments implicites:
! Methode:
! Externes:
! Auteur/author:   2008-12, J.M. Piriou.
! Modifications:
! --------------------------------------------------------------
! En entree:
!  (ppcou, pycou) et (ppprec,pyprec) sont les deux points par lesquels la fonction affine passe.
! En sortie:
!  fth_pinterpole est la valeur de p pour laquelle la fonction affine s'annule.
! --------------------------------------------------------------
!USE PARKIND1, ONLY : JPIM, JPRB
IMPLICIT NONE
!
!-------------------------------------------------
! Arguments.
!-------------------------------------------------
!
REAL, intent(in) :: pycou,pyprec,ppcou,ppprec
REAL :: fth_pinterpole
!
!-------------------------------------------------
! Variables locales.
!-------------------------------------------------
!
REAL :: zecart
!
!-------------------------------------------------
! Si le dénominateur (zecart) s'annule, c'est que la routine
! a été appelée dans un cas non soluble.
! En ce cas on ne génère pas de message d'erreur,
! on protège simplement la division
! en divisant par 1.
!-------------------------------------------------
!
zecart=pyprec-pycou
if(zecart == 0.0) zecart=1.0
fth_pinterpole=(ppcou*pyprec-ppprec*pycou)/zecart
if(fth_pinterpole < min(ppprec,ppcou)) fth_pinterpole=min(ppprec,ppcou)
if(fth_pinterpole > max(ppprec,ppcou)) fth_pinterpole=max(ppprec,ppcou)
end
