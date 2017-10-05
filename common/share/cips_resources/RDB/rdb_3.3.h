#ifndef __rdb3_3_h
#define __rdb3_3_h

/* RDB File format description.
   Copyright (C) 1989, 1990, 1991, 1992, 1993 METEO-FRANCE.

This file is part of SYNERGIE.  */

/* attention : c'est la version situee sous 
client/srclib/magics5.4/src/include qui fait foi dans cvs */


#define VRAI  1
#define FAUX  0

/* quelques valeurs */
#define RDB_SOL      1   /* val de RDB_JTYP */
#define RDB_ALTI     5   /* val de RDB_JTYP */

#define RDB_PNORM    0   /* val de RDB_CPMER */
#define RDB_PEXT     1   /* val de RDB_CPMER */

#define TOUS_MESSAGES 2147483647
 
#define OCTET              8
/* Ajout Paulais D le 28/02/2006 */
#ifndef __DIAPASON
/* valeurs possibles de RDB_JCT */
#define ERS1URA      9 
#define SYNOP       11
#define METAR       12
#define SYNOR       14
#define BUOY        21
#define SHIP        22
#define BATHY       23 
#define TESAC       24 
#define WAVEOB      25 
#define SATGEO      26 
#define SPECI       27 
#define SYNOPMOBIL  28 
#define RADOMEH     29 
#define RADOME6M    30 
#define RADOME1M    31 
#define SPEMET      32   /* BD 3.6b.6 */
#define TEMP        35
#define PILOT       36
#define TEMPSHIP    37
#define TEMPDROP    38	/* SLG 420a3 */
#define TEMPMOBIL   39	/* SLG 420a3 */
#define PILOTSHIP   40 /* SLG 420b2 */
#define PILOTMOBIL  41 /* SLG 420b2 */
#define BUOYOMM     50  /* SLG 420b1 */
#define ERS1UWI    122 
#define QSCT       123 
#define ASCATAL    124  /* SLG 420b1 */
#define EUROPROFIL 139 /* FD Europrofil 4.2 ajout apres D.Paulais choix = 139, 147 etant deja pris */
#define AMDAR      140
#define AIREP      141
#define ACARS      142  /* les ACAR de la table alti */
#define SATOB      143 
#define ACAR       144  /* les ACAR de la bdm */
#define GEOWIND    145 /* JBV Geowind */
#define PROFILER   146 /* FD Profiler 4.2 ajout apres JBV Geowind choix = 146*/
#define ENVISATRA  147 /* DP ENVISAT-RA 4.2 */
#define JASON      148 /* DP JASON 4.2*/
/* Claude,2007-05-15 */
#define WMO_BATHY   181
#define WMO_TESAC   182
#define ARGO_PROFIL 183
#define ARGO_FLOAT  184
#define ARGO_BATHY  185
#define ARGO_TESAC  186
#define ARGO_MOORING 187
#define ARGO_CTD    188
#define ARGO_TRAJ   189
#define ARGO_BUOY   190
#define ARGO_THERMO 191

#endif

#define TABLEQ      77  /* autres donnees de la table Q */
#define TABLEH     149  /* autres donnees de la table H */

#define RDB_EST      1   /* inverse de la bdm */
#define RDB_MES      0   /* pour des raisons de compatibilite ascendante */

#define RDB_AUTO     1   /* inverse de la bdm */
#define RDB_MANU     0   /* pour des raisons de compatibilite ascendante */

#define RDB_N_PARAM  140	 /* Nb params (SLG passage de 98 a 120 V420a3) */
 /* penser a modifier aussi BDMDATA_MAX_RDB dans bdmdata_.h */

#define RDB_RAF3      1  /* rafale NO 2 des SYNOR */
#define RDB_RAF3_TPS  2  /* suite */

#define RDB_F_TYP     3	 /* parametre specifiant le type de flag. 
                            Pas de flag : 0 */

#define RDB_JTYP      4  /* OBS TYPE */

#define RDB_VG        7	 /* vertical gust:rafale verticale */
#define RDB_IW        8	 /* vitesse de vent mesuree/estimee */
#define RDB_TMIN10    9	 /* temperature dans le sol */

#define RDB_JCT      10	 /* CODE TYPE (ITYP) */
#define RDB_LAT      11	 /* Latitude avec 2 digits */
#define RDB_LON      12	 /* Longitude avec 2 digits */
#define RDB_INDIC    13	 /* Indicatif de la station <==0*/
#define RDB_HH       14	 /* Heure de l'observation */
#define RDB_MN       15	 /* Minutes reelles*/
#define RDB_AA       16	 /* annee */
#define RDB_MM       17	 /* mois */
#define RDB_JJ       18	 /* jour */
#define RDB_HH_R     19	 /* heure reelle */

#define RDB_F_Z      20	 /* flag pour l'altitude ou la pression */
#define RDB_F_T      21	 /* flag pour la temperature */
#define RDB_F_TD     22	 /* flag pour la temperature de rosee */
#define RDB_F_VENT   23	 /* flag pour le vent */
#define RDB_F_TMER   24	 /* flag pour la temperature de la mer */

#define RDB_TN12     25  /* TMIN sur les 12 dernieres heures */
#define RDB_TN24     26  /* TMIN sur les 24 dernieres heures */
#define RDB_TX12     27  /* TMAX sur les 12 dernieres heures */
#define RDB_TX24     28  /* TMAX sur les 24 dernieres heures */
#define RDB_TYPESTA  29  /* MANUELLE/AUTO */
#define RDB_MBW2     30  /* amelioration/aggravation SPECI */
#define RDB_TURBUL   31	 /* turbulence avions*/
#define RDB_PMER     32	 /* ppp : pression 3 DIGIT 1/10 Hpa <==0*/
#define RDB_P        32	 /* ppp : pression 3 DIGIT 1/10 Hpa <==0*/
#define RDB_DD       33	 /* Wind direction (rose de 360dg) <==-1*/
#define RDB_FF       34	 /* force du vent (m/s) <==0 */
#define RDB_T        35	 /* Temperature abri (1/10Dg) <==100000 */
#define RDB_TD       36	 /* Temperature de rosee (1/10Dg) <==100000 */
#define RDB_COD_TEND 37	 /* a : code tendance <==10 */
#define RDB_TEND     38	 /* pp : tendance (1/10Hpa) <==100000 */
#define RDB_TMER     39	 /* Temperature mer (1/10Dg) <==100000 */
#define RDB_VISI     40	 /* vv : visibilite (code) <==100000*/
#define RDB_WW       41	 /* temps present (code) <==100000 */
#define RDB_W1W2     42	 /* w : temps passe (code) <==100000*/
#define RDB_N        43	 /* nebul total (code) <==0 */
/*#define RDB_CMEL     43*/  /* Calypso,JC,2007-04-25 */
#define RDB_NBAS     44	 /* nh : nebul nuage bas (code) <==0 */
#define RDB_CL       45	 /* code nuage bas (code <==0 */
#define RDB_BBAS     46	 /* h : hauteur nuage bas (code) <==0*/
#define RDB_CM       47	 /* code nuage moyen (code) <==0 */
#define RDB_CH       48	 /* code nuage eleve (code) <==0*/
#define RDB_RAF1     49  /* vit raf ds les 10 mn avant l'obs <== 0*/
#define RDB_RAF2     50  /*raf ds les 10 mn avant l'heure RDB_RAF2_TPS > 0*/
#define RDB_RAF2_TPS 51  /* ou la periode RDB_RAF2_TPS <0 , 99 = periode
                            correspondant a W1W2*/
#define RDB_HT_NEIGE 52
#define RDB_FR_NEIGE 53
#define RDB_RR1      54
#define RDB_RR3      55
#define RDB_RR6      56
#define RDB_RR12     57
#define RDB_RR24     58
#define RDB_CPMER    59  /* complement PMER */
#define RDB_IDENTH   60	 /* code haut, indicatif avion ou bateau <==0 */
#define RDB_IDENTB   61	 /* code bas, indicatif avion ou bateau  <==0 */
#define RDB_WPV      62  /* code periode mer du vent <==100000 */
#define RDB_WHV      63  /* code hauteur mer du vent <==100000 */
#define RDB_WD1      64  /* code direction houle1    <==100000 */
#define RDB_WP1      65  /* code periode houle1      <==100000 */ 
#define RDB_WH1      66  /* code hauteur houle1      <==100000 */ 
#define RDB_WD2      67  /* code direction houle2    <==100000 */
#define RDB_WP2      68  /* code periode houle2      <==100000 */
#define RDB_WH2      69  /* code hauteur houle2      <==100000 */
#define RDB_DS       70	 /* direction bateau <==100000 */
#define RDB_VS       71	 /* vitesse bateau <==100000 */

#define RDB_QNH      72  /* code METAR */
#define RDB_TSIG     73  /* code METAR, par ex CAVOK */
#define RDB_VVMINI   74  /* code METAR, visi mini */
#define RDB_VVMAXI   75  /* code METAR, visi maxi */
#define RDB_VVVERT   76  /* code METAR, visi verticale */
#define RDB_WW1      77  /* code METAR, temps present 1 */
#define RDB_WW2      78  /* code METAR, temps present 2 */
#define RDB_WW3      79  /* code METAR, temps present 3 */
#define RDB_N1       80  /* code METAR, nebul 1 */
#define RDB_N1TYPE   81  /* code METAR, TYPE NUAGES 1 */
#define RDB_N1H      82  /* code METAR, HAUTEUR NUAGES 1 */
#define RDB_N2       83  /* code METAR, nebul 2 */
#define RDB_N2TYPE   84  /* code METAR, TYPE NUAGES 2 */
#define RDB_N2H      85  /* code METAR, HAUTEUR NUAGES 2 */
#define RDB_N3       86  /* code METAR, nebul 3 */
#define RDB_N3TYPE   87  /* code METAR, TYPE NUAGES 3 */
#define RDB_N3H      88  /* code METAR, HAUTEUR NUAGES 3 */
#define RDB_N4       89  /* code METAR, nebul 4 */
#define RDB_N4TYPE   90  /* code METAR, TYPE NUAGES 4 */
#define RDB_N4H      91  /* code METAR, HAUTEUR NUAGES 4 */

#define RDB_MOD      92  /* code ERS1URA, module vent */
#define RDB_MOD_SD   93  /* code ERS1URA, ecart type (standard deviation) */
#define RDB_H1S3     94  /* code ERS1URA, module hauteur moyenne des vagues */
#define RDB_H1S3_SD  95  /* code ERS1URA, ecart type (standard deviation) */
#define RDB_GEOP     96  /* Hauteur Geopotentielle si stn_alt > 850hPa...*/ 
#define RDB_RRPER    97  

/* Ajout D.Paulais version 4.2 */

#define RDB_N1HC    98   /* caracteristique de la hauteur */
#define RDB_N2HC    99   /* caracteristique de la hauteur */ 
#define RDB_N3HC    100  /* caracteristique de la hauteur */ 
#define RDB_N4HC    101  /* caracteristique de la hauteur */  
#define RDB_E_SOL   102  /* Etat du sol */
#define RDB_RAY_G01 103  /* Rayonnement global integre sur 1 heure */
#define RDB_V1_HAUT 104  /* Hauteur de mesure du vent (1 mesure) */
#define RDB_V1_DD   105  /* direction du vent (1 mesure) */
#define RDB_V1_FF   106  /* force du  du vent (1 mesure) */
#define RDB_V2_HAUT 107  /* Hauteur de mesure du vent (2 mesure) */
#define RDB_V2_DD   108  /* direction du vent (2 mesure) */
#define RDB_V2_FF   109  /* force du  du vent (2 mesure) */

/* Ajout F.Duret version 4.2 */
#define RDB_VENT_VV 110  /* vitesse verticale du vent (mesure des profilers) */

/* Parametres oceano (Calypso) */
#define RDB_O_TMER     111	/* temperature de l'eau */
#define RDB_O_DEPH     112	/* profondeur */
#define RDB_O_PSAL     113	/* salinite */
#define RDB_O_PRES     114	/* pression */
#define RDB_O_DOXY     115	/* densite oxygene */
#define RDB_O_TOXY     116
#define RDB_O_CNDC     117
#define RDB_O_ATMP     118
#define RDB_O_DRYT     119
#define RDB_O_TEM2     120
#define RDB_O_SCDT     121
#define RDB_O_SCSP     122
#define RDB_O_SSPS     123
#define RDB_O_HCDI     124
#define RDB_O_HCSP     125
#define RDB_O_RELH     126
#define RDB_O_SSTP     127
#define RDB_O_ATMS     128
#define RDB_O_ATPT     129
#define RDB_O_SWHT     130
#define RDB_O_SWPR     131
#define RDB_O_WSPD     132	/* force du courant */
#define RDB_O_WDIR     133	/* direction du courant */
#define RDB_O_CMEL     134
#define RDB_O_TEND     135

/* valeurs manquantes */

#define RDB_M_RAF3      0
#define RDB_M_RAF3_TPS -99

#define RDB_M_VG       0	 /* vertical gust:rafale verticale */
#define RDB_M_IW       RDB_MES	 /* vitesse de vent mesuree/estimee */
#define RDB_M_TMIN10   100000    /* temperature ds le sol */

#define RDB_M_INDIC    0	 /* Indicatif de la station <==0*/
#define RDB_M_HH       0	 /* Heure de l'observation */
#define RDB_M_MN       0	 /* Minutes */
#define RDB_M_AA       0	 /* annee */
#define RDB_M_MM       0	 /* mois */
#define RDB_M_JJ       0	 /* jour */

#define RDB_F_M       255	 /* flag absent */

#define RDB_M_TN12   100000        /* TMIN sur les 12 dernieres heures */
#define RDB_M_TN24   100000        /* TMIN sur les 24 dernieres heures */
#define RDB_M_TX12   100000        /* TMAX sur les 12 dernieres heures */
#define RDB_M_TX24   100000        /* TMAX sur les 24 dernieres heures */

#define RDB_M_TYPESTA  RDB_MANU  /* MANUELLE/AUTO */
#define RDB_M_MBW2     -1        /* amelioration/aggravation SPECI */
#define RDB_M_TURBUL   -1	 /* turbulence avions */
#define RDB_M_PMER     -1	 /* ppp : pression 3 DIGIT 1/10 Hpa <==0*/
#define RDB_M_P        -1	 /* ppp : pression 3 DIGIT 1/10 Hpa <==0*/
#define RDB_M_DD       -1	 /* Wind direction (rose de 360dg) <==-1*/
#define RDB_M_FF       	0        /* force du vent (m/s) necessairement a 0 */
#define RDB_M_T        100000	 /* Temperature abri (1/10Dg) <==100000 */
#define RDB_M_TD       100000	 /* Temperature de rosee (1/10Dg) <==100000 */
#define RDB_M_COD_TEND 10	 /* a : code tendance <==10 */
#define RDB_M_TEND     100000	 /* pp : tendance (1/10Hpa) <==100000 */
#define RDB_M_TMER     100000	 /* Temperature mer (1/10Dg) <==100000 */
#define RDB_M_VISI     100000	 /* vv : visibilite (code) <==100000*/
#define RDB_M_WW       100000	 /* temps present (code) <==100000 */
#define RDB_M_W1W2     100000	 /* w : temps passe (code) <==100000*/
#define RDB_M_N        -1	 /* nebul total (code) <==0 */
#define RDB_M_NBAS     -1	 /* nh : nebul nuage bas (code) <==0 */
#define RDB_M_CL       -1	 /* code nuage bas (code <==0 */
#define RDB_M_BBAS     -1	 /* h : hauteur nuage bas (code) <==0*/
#define RDB_M_CM       -1	 /* code nuage moyen (code) <==0 */
#define RDB_M_CH       -1	 /* code nuage eleve (code) <==0*/

#define RDB_M_RAF1      0  /* necessairement a 0 (si < 0 : en dixiemes) */
#define RDB_M_RAF2      0  /* necessairement a 0 (si < 0 : en dixiemes) */
#define RDB_M_RAF2_TPS -99 /* ou la periode RDB_RAF2_TPS <0 , 99 = periode
                            correspondant a W1W2*/
 
#define RDB_M_HT_NEIGE -1
#define RDB_M_FR_NEIGE -1
#define RDB_M_RR1      -1
#define RDB_M_RR3      -1
#define RDB_M_RR6      -1
#define RDB_M_RR12     -1
#define RDB_M_RR24     -1
#define RDB_M_RRPER    -1

#define RDB_M_CPMER    0  /* complement PMER */
#define RDB_M_IDENTH   0	 /* code haut, indicatif avion ou bateau <==0 */
#define RDB_M_IDENTB   0	 /* code bas, indicatif avion ou bateau  <==0 */

#define RDB_M_WPV      0  /* code periode mer du vent <==100000 */
#define RDB_M_WHV      0  /* code hauteur mer du vent <==100000 */
#define RDB_M_WD1      0  /* code direction houle1    <==100000 */
#define RDB_M_WP1      0  /* code periode houle1      <==100000 */
#define RDB_M_WH1      0  /* code hauteur houle1      <==100000 */
#define RDB_M_WD2      0  /* code direction houle2    <==100000 */
#define RDB_M_WP2      0  /* code periode houle2      <==100000 */
#define RDB_M_WH2      0  /* code hauteur houle2      <==100000 */

#define RDB_M_DS       0	 /* direction bateau <==100000 */
#define RDB_M_VS       0	 /* vitesse bateau <==100000 */

#define RDB_M_QNH    -1  /* code METAR */
#define RDB_M_TSIG   -1  /* code METAR, par ex CAVOK */
#define RDB_M_VVMINI -1  /* code METAR, visi mini */
#define RDB_M_VVMAXI -1  /* code METAR, visi maxi */
#define RDB_M_VVVERT -1  /* code METAR, visi verticale */
#define RDB_M_WW1    -1  /* code METAR, temps present 1 */
#define RDB_M_WW2    -1  /* code METAR, temps present 2 */
#define RDB_M_WW3    -1  /* code METAR, temps present 3 */
#define RDB_M_N1     -1  /* code METAR, nebul 1 */
#define RDB_M_N1TYPE -1  /* code METAR, TYPE NUAGES 1 */
#define RDB_M_N1H    -1  /* code METAR, HAUTEUR NUAGES 1 */
#define RDB_M_N2     -1  /* code METAR, nebul 2 */
#define RDB_M_N2TYPE -1  /* code METAR, TYPE NUAGES 2 */
#define RDB_M_N2H    -1  /* code METAR, HAUTEUR NUAGES 2 */
#define RDB_M_N3     -1  /* code METAR, nebul 3 */
#define RDB_M_N3TYPE -1  /* code METAR, TYPE NUAGES 3 */
#define RDB_M_N3H    -1  /* code METAR, HAUTEUR NUAGES 3 */
#define RDB_M_N4     -1  /* code METAR, nebul 4 */
#define RDB_M_N4TYPE -1  /* code METAR, TYPE NUAGES 4 */
#define RDB_M_N4H    -1  /* code METAR, HAUTEUR NUAGES 4 */


#define RDB_M_MOD    -1  /* code ERS1URA, module vent */
#define RDB_M_MOD_SD -1  /* code ERS1URA, ecart type (standard deviation) */
#define RDB_M_H1S3   -1  /* code ERS1URA, module hauteur moyenne des vagues */
#define RDB_M_H1S3_SD -1 /* code ERS1URA, ecart type (standard deviation) */
#define RDB_M_GEOP    0

/* Ajout D.Paulais version 4.2 */

#define RDB_M_N1HC    -1   /* caracteristique de la hauteur */
#define RDB_M_N2HC    -1   /* caracteristique de la hauteur */ 
#define RDB_M_N3HC    -1  /* caracteristique de la hauteur */ 
#define RDB_M_N4HC    -1  /* caracteristique de la hauteur */  
#define RDB_M_E_SOL   -1  /* Etat du sol */
#define RDB_M_RAY_G01 -1  /* Rayonnement global integre sur 1 heure */
#define RDB_M_V1_HAUT -1  /* Hauteur de mesure du vent (1 mesure) */
#define RDB_M_V1_DD   -1  /* direction du vent (1 mesure) */
#define RDB_M_V1_FF   -1  /* force du  du vent (1 mesure) */
#define RDB_M_V2_HAUT -1  /* Hauteur de mesure du vent (2 mesure) */
#define RDB_M_V2_DD   -1  /* direction du vent (2 mesure) */
#define RDB_M_V2_FF   -1  /* force du  du vent (2 mesure) */

/* Ajout F.Duret version 4.2 */
#define RDB_M_VENT_VV 100000  /* vitesse verticale du vent (mesure des profilers) */

#define RDB_M_DEPH    -1 /* Calypso,Claude,2007-02-08 */
#define RDB_M_PSAL    -1 /* Calypso,Claude,2007-02-08 */
#define RDB_M_PRES    -1 /* Calypso,Claude,2007-02-08 */
#define RDB_M_CMEL    -1 /* Calypso,JC,2007-04-25 */
#define RDB_M_DOXY    -1
#define RDB_M_TOXY    -1
#define RDB_M_CNDC    -1
#define RDB_M_ATMP    -1
#define RDB_M_DRYT    -1
#define RDB_M_TEM2    -1
#define RDB_M_SCDT    -1
#define RDB_M_SCSP    -1
#define RDB_M_SSPS    -1
#define RDB_M_HCDI    -1
#define RDB_M_HCSP    -1
#define RDB_M_RELH    -1
#define RDB_M_SSTP    100000
#define RDB_M_ATMS    -1
#define RDB_M_ATPT    100000
#define RDB_M_SWHT    0
#define RDB_M_SWPR    0
#define RDB_M_WSPD    0
#define RDB_M_WDIR    -1
#endif
/* End Of File */
