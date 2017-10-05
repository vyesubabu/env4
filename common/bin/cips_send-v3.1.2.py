#!/usr/bin/python

# Name: cips_send.py
# Property: Meteo France International (M.F.I.)
# Author: S. BENCHIMOL
# Release: 3.1.0b1
# Status: Beta (Development)
# Creation Date: 2009/07/29
# v3.1.2 :Modification Date: 2013/11/20 by RM : 
#		- for mode=transmet-header:
#		  Add ProcessID as unique identifier at sending time
#		- remove '-r 3' from ncftpput
# v3.1.1 :Modification Date: 2013/11/12 by RM : Set CIPS_O & CIPS_S 
#	  machines explicitly (not vcips..)
# v3.1.0 :Modification Date: 2013/10/15 by RM : redial in NCFTPPUT
##

"""
Description: Universal tool for sending data to/from CIPS
"""

global _debug, _verbose
_debug = 0
_verbose = 1
_donothing = 0
_log = 1

import gettext, datetime, os
from string import upper, replace
#############################################################################
#                                                                           #
#                        Config options                                     #
#                                                                           #
#                                                                           #
#############################################################################

#[CIPS]
### RM update 
CIPSSTANDBY = "cipsstandby"
CIPSOPER    = "cipsoper"
CIPS_HOSTS = [CIPSSTANDBY, CIPSOPER]
CIPS_LOGIN = "cips_in"
CIPS_PASSW = "cips_in"

#[Transmet]
# known in DNS TRSJAN.nc.bmkg.local
TRANSMET    = "TRSJAN"
TRANSMET_HOSTS = [TRANSMET]
TRANSMET_LOGIN = "cnmjanz"
TRANSMET_PASSW = "Cnmjanz1234"
TRANSMET_PATH  = "./"

#[Local]
LOG_FILE = "/cm/shared/apps/CIPS/logs/cips_send/cips_send.log"
FTP_COMMAND="/common/softwares/ncftp-3.2.5/bin/ncftpput"
#FTP_ARGS = "-S .tmp -r 3"
FTP_ARGS = "-S .tmp "
#WGRIB_COMMAND=os.path.expanduser('~')+"/cips/bin/wgrib"
WGRIB_COMMAND="wgrib"
GRIBDUMP_COMMAND="grib_dump"
    
#############################################################################
#                                                                           #
#                        XML and config Constants                           #
#                                                                           #
#############################################################################
DATE_FORMAT = 'YYYYMMDDHHmmSS'
# Possibles values for mode
MODE_TRANSMET   = "transmet-header"
MODE_REGION     = "region"
MODE_CIPS       = "cips"
MODE_CIPS_DEBUG = "cips_debug"

# Possible values for database
CST_MODDB               = "moddb"
CST_IMGDB               = "imgdb"
CST_PRDDB               = "prddb"
CST_OBSDB               = "obsdb"
CST_FCTDB               = "fctdb"

# Transmet headers
TRANSMET_HEADER  = "TTAAII"
TRANSMET_HEADERS = {}
TRANSMET_HEADERS[CST_MODDB] = "ZCMO00"
TRANSMET_HEADERS[CST_IMGDB] = "ZCIM00"
TRANSMET_HEADERS[CST_PRDDB] = "ZCPR00"
TRANSMET_HEADERS[CST_FCTDB] = "ZCFC00"

# Transmet center
TRANSMET_CENTERS = {}
TRANSMET_CENTERS[CST_MODDB] = "CIPS"
TRANSMET_CENTERS[CST_IMGDB] = "CIPS"
TRANSMET_CENTERS[CST_PRDDB] = "CIPS"
TRANSMET_CENTERS[CST_FCTDB] = "CIPS"

FAMILY_MODEL = 'ATM'
FAMILY_SAT   = 'SAT'
FAMILY_OBS   = 'OBS'

#SAT_KALPANA_SPACE74E_CC_CIPS_FMT_JPG1400

# T1 Headers
############
HEADERS_T1 = {}
HEADERS_T1[FAMILY_MODEL] = 'Y'
#HEADERS_T1[FAMILY_MODEL]['GFSUS'] = 'Y'
#HEADERS_T1[FAMILY_MODEL]['ARPTR'] = 'H'
#HEADERS_T1[FAMILY_MODEL]['GFSHQ'] = 'Y'
HEADERS_T1[FAMILY_SAT] = 'E'
HEADERS_T1[FAMILY_OBS] = 'Z'

# T2 Headers
############
HEADERS_T2 = {}
HEADERS_T2[FAMILY_MODEL] = {}
HEADERS_T2[FAMILY_MODEL]['FORECASTERS'] = 'F'
HEADERS_T2[FAMILY_MODEL]['AVIATION']    = 'Y'
HEADERS_T2[FAMILY_MODEL]['FULL']        = 'X'
HEADERS_T2[FAMILY_SAT] = {
                    'IR':    'I',
                    'COULDCLASS': 'K',
                    'OLR':   'L',
                    'NVS':   'N',
                    'CC':    'O',
                    'QPME':  'Q',
                    'SST':   'S',
                    'UTH':   'U',
                    'VS':    'V',
                    'WV':    'W',
                   }
HEADERS_T2['Z'] = {
                    # PWS Image
                    'PWSI':  'I', 
                    # XML MFY
                    'XMLGZ': 'X',
                    # Grid-based verif
                    'VERIF': 'G',
                    # Obs-based data
                    'OBS':   'O',
                    # CIPS Direct
                    'CIPS':  'C',
                    # PWS Video
                    'PWSV':  'V',
                  }


# A1 Headers
############
HEADERS_A1 = {}
HEADERS_A1[FAMILY_MODEL] = {}
HEADERS_A1[FAMILY_MODEL]['Y'] = {}
#HEADERS_A1[FAMILY_MODEL]['Y']['INDIA']    = 'M'
HEADERS_A1[FAMILY_MODEL]['Y']['INDIAS']   = 'M'
HEADERS_A1[FAMILY_MODEL]['Y']['INDIAL']   = 'O'
HEADERS_A1[FAMILY_MODEL]['Y']['INDIAXL']  = 'P'
HEADERS_A1[FAMILY_MODEL]['Y']['INDIAM']   = 'Q'
HEADERS_A1[FAMILY_MODEL]['Y']['WRFIND']   = 'W'
HEADERS_A1[FAMILY_SAT] = {
                     'GLOBE':    'S',
                     'SPACE74E': 'S',
                     'SPACE93E': 'S',
                     'INDIA':    'I',
                     'INDIAL':   'I',
                     'INDIAS':   'I',
                     }

HEADERS_A1['Z'] = {}
HEADERS_A1['Z']['X'] = {
                     'INDIA':    'N',
                     'INDIAS':   'N',
                     'NATIONAL': 'N',
                     'REGIONAL': 'R'
                    }


# A2 Headers
############
HEADERS_A2 = {}
HEADERS_A2[FAMILY_SAT] = {
                     'GLOBE':    'G',
                     'SPACE74E': 'G',
                     'SPACE93E': 'G',
                     'INDIA':    'N',
                     'INDIAL':   'L',
                     'INDIAS':   'S',
                     }

HEADERS_A2['Z'] = {}
HEADERS_A2['Z']['X'] = {
                    'OBS':  'O'
                    }


# Enter CCCC Headers
#######################
HEADERS_CCCC = {
          'HQ': 'DEMS'
          }

# C1 Headers
############
# FIXIT ? By default, if somebody use cips_send, it's CIPS output
HEADERS_C1 = 'Q'

# C2 Headers 
#############
HEADERS_C2 = {}
HEADERS_C2[FAMILY_MODEL] = {
                     'ARPTR': 'A',  # Arpege Tropics - MF
                     'ARP':   'B',  # Arpege - MF
                     'ECMWF': 'E',  # IFS - ECMWF
                     'GFSUS': 'G',  # GFSUS - NCEP
                     'GFSNC': 'I',  # GFSNC - NCMWRF
                     'JMA':   'J',  # JMA
                     'GFSHQ': 'H',  # GFSHQ - IMD
                     'UKMET': 'U',  # UKMet
                     'WRFHQ': 'W',  # WRFHQ - IMD
                     }
HEADERS_C2[FAMILY_SAT] = {
                     'KALPANA1': 'K',  # Kalpana products
                     'INSAT3A':  'I',  # Insat products
                     'METEOSAT': 'M'   # Meteosat products
                     }
HEADERS_C2[FAMILY_OBS] = {
                     'HQ': 'E'
                      }

# C3 Headers 
#############
REGION_FULL   = 'full'
REGION_INTER  = 'inter'
REGION_LOW    = 'low'
REGION_SYN    = 'synergie'
REGION_CIPS   = 'cips'

HEADERS_C3 = {
              REGION_FULL: 'F',   # Region with full bandwith
              REGION_INTER:'I',   # Region with inter bandwidth
              REGION_LOW:  'L',   # Region with low bandwidth
              REGION_SYN:  'S',   # Only to Synergie HQ
              REGION_CIPS: 'Y',   # Only to CIPS HQ
              }

# C4 Headers 
#############
HEADERS_VERSION = '1.0'
HEADERS_C4 = {
              '1.0':'A'
              }


#############################################################################
#                                                                           #
#                        Generic functions                                  #
#                                                                           #
#############################################################################



"""
Read a grib file and return some informations
"""
def readGribFile(file):
  from tempfile import mkstemp

  gribInfos = {'date':None,'fcstRange':None}
  
  fcstRanges = {}
  dates = {}

  # Read with wgrib
  #################
  (fd, TEMP_FILE) = mkstemp()
  cmd = WGRIB_COMMAND+" "+file+" > " + TEMP_FILE
  launchSubProcess(cmd)
  
  try:
    f = open(TEMP_FILE,'r')
    for line in f:
      #54:269518:d=10020400:RH:kpds5=52:kpds6=4:kpds7=0:TR=10:P1=0:P2=6:TimeU=1:0C isotherm:6hr fcst:NAve=0
      (record, unknow, date, param, paramCode, levelCode, levelValue, levelType, fcstP1, fcstP2, timeUnit, level, fcstRange, unknow) = line.split(":")

      currentCentury = datetime.date.today().strftime("%Y")[:2]
      dates[currentCentury+date.split('=')[1]] = True
      #fcstRanges[str(fcstP1.split('=')[1])+str(fcstP2.split('=')[1])] = True

  finally:
    os.remove(TEMP_FILE)
  
  # Read fcstRanges with grib_dump (ECMWF)
  ############### 
  (fd, TEMP_FILE) = mkstemp()
  cmd = GRIBDUMP_COMMAND +" "+file+" | grep stepRange | sort -n | uniq> " + TEMP_FILE
  launchSubProcess(cmd)

  try:
    f = open(TEMP_FILE,'r')
    for line in f:
      #  stepRange = 12;
      range = line.split("=")[1].split(';')[0].strip()

      if (len(range) == 1):
        range = "0"+range

      # Might have multiples ranges
      # 102-108 --> 108
      range = range.split('-')[-1]
      #range = str("%.2d" % int(range[-2:]))

      fcstRanges[range] = True
  finally:
    os.remove(TEMP_FILE)

  gribInfos['date'] = dates.keys()
  gribInfos['fcstRange'] = fcstRanges.keys()

  return gribInfos
  

#############################################################################
#                                                                           #
#                        Headers functions                                  #
# To generate Transmet headers according to Data Type                       #
#                                                                           #
#############################################################################
"""
Generate Transmet Headers according
to datatype and headers declaration

Check also file consistency:
  - is it really a grib file ?
  - which grib code ? etc

Datatype example : ATM_ARPTR_INDIAL1500_SET_FORECASTERS_FR_00

@input string  file
@input string  datatype
@input string  region
"""
def generateTransmetHeaders(file, datatype, region=None):
  header = {'T1':None,'T2':None,
            'A1':None,'A2':None,
            'ii':None,
            'C1':None,'C2':None,'C3':None,'C4':None,
            'date':None}
    
  debug(_("Generating Transmet Header for datareference: %s")%(datatype))
  
  # Recognize datatype it and build header
  ########################
  debug(_("BEGIN Parsing data reference"))

  parts = datatype.split('_')
  datatypeParts = {'region':region}
  family = parts[0]
  
  if (family == FAMILY_MODEL):
    datatypeParts['family'] = family
    try:
      # ex: ATM_PGFSNC_INDIA0500_SET_FORECASTERS_FMT_GRIB1_FR_00-66
      datatypeParts['model']  = parts[1]
      datatypeParts['grid']   = parts[2]
      datatypeParts['subset'] = parts[4]
      datatypeParts['minExpectedFcstRange'] = parts[8]
      datatypeParts['maxExpectedFcstRange'] = parts[8]

      """
      try:
        r = parts[6].split('-')
        if (len(r) == 2):
          if (int(r[0]) < int(r[1])):
            debug(_("Expected forecast ranges : %s to %s")%(r[0],r[1]))
            datatypeParts['minExpectedFcstRange'] = int(r[0])
            datatypeParts['maxExpectedFcstRange'] = int(r[1])
          else:
            raise Exception()
        elif (int(r[0]) != None):
          debug(_("Expected forecast range : %s")%(r[0]))
          datatypeParts['minExpectedFcstRange'] = int(r[0])
          datatypeParts['maxExpectedFcstRange'] = int(r[0])
      except:
        error(_("Unable to parse forecast range"))
        raise Exception()
      """
      
    except:
      error(_("Datatype not recognized: %s")%(datatype))
      sys.exit(1)

  elif (family == FAMILY_SAT):
    datatypeParts['family'] = family
    try:
      # ex: SAT_KALPANA1_VHRR_IR/VS/WV_SPACE74E_FMT_HDF5_RES_FULL_20100413083000
      datatypeParts['sat']     = parts[1]
      datatypeParts['domain']  = parts[4]
      datatypeParts['product'] = parts[3]
      datatypeParts['format']  = parts[6]
      datatypeParts['date']    = parts[9]
      print datatypeParts
      
    except:
      error(_("Datatype not recognized: %s")%(datatype))
      sys.exit(1)
  

  elif (family == FAMILY_OBS):
    datatypeParts['family'] = family
    try:
      #ex:     OBS_METAR-SYNOP-SYNOPMOBIL_DEPTH_24_INDIAS_FROM_HQ_FMT_XMLGZ
      datatypeParts['type']  = parts[1]
      datatypeParts['depth'] = parts[3]
      datatypeParts['domain'] = parts[4]
      datatypeParts['source'] = parts[6]
      datatypeParts['format'] = parts[8]
    except:
      error(_("Datatype not recognized: %s")%(datatype))
      sys.exit(1)
  
  else:
    error(_("Datatype %s unknown")%(datatype))
    sys.exit(1)
  debug(_("END   Parsing data reference"))
  


  # Read file for more information
  ################################
  if (family == FAMILY_MODEL):
    debug(_("BEGIN Parsing grib file"))
    gribInfos = readGribFile(file)
    
    if (gribInfos['date'] == []):
      error(_("%s family, but not recognized as grib file: %s")%(family, file))
      sys.exit(0)
    else:
      gribInfos['date'] = gribInfos['date'][0] + "0000"
      debug(_("Grib file recognized, run of %s")%(gribInfos['date']))
      
    if (len(gribInfos['fcstRange']) > 1):
      info(_("Several forecast range found in grib file: %s")%(gribInfos['fcstRange']))
      range = gribInfos['fcstRange'][0]
      info(_("Using default ii = %s")%(range))
      #FIXIT
      gribInfos['fcstRange'] = range
    else:
      #FIXIT
      gribInfos['fcstRange'] = gribInfos['fcstRange'][0]

    if ((int(gribInfos['fcstRange']) < datatypeParts['minExpectedFcstRange']) or \
       (int(gribInfos['fcstRange']) > datatypeParts['maxExpectedFcstRange'])):
      error(_("Fcst range is out of range ... continuing"))
      
    datatypeParts['fcstRange'] = gribInfos['fcstRange']
    header['date'] = gribInfos['date']
    debug(_("END   Parsing grib file"))

  elif (family == FAMILY_SAT):
    header['date'] = datatypeParts['date']
    #tiffInfos = readTiffFile(file)
    pass
  
  
  # Construct header from datatype variables
  ################################
  debug(_("BEGIN Generating header"))
  try:
    debug(_("Decoding T1 ..."))
    header['T1'] = _getT1Header(datatypeParts)
    debug(_("T1 = %s")%(header['T1']))
    
    debug(_("Decoding T2 ..."))
    header['T2'] = _getT2Header(datatypeParts)
    debug(_("T2 = %s")%(header['T2']))
    
    debug(_("Decoding A1 ..."))
    header['A1'] = _getA1Header(datatypeParts)
    debug(_("A1 = %s")%(header['A1']))
    
    debug(_("Decoding A2 ..."))
    header['A2'] = _getA2Header(datatypeParts)
    debug(_("A2 = %s")%(header['A2']))
    
    debug(_("Decoding ii ..."))
    header['ii'] = _getiiHeader(datatypeParts)
    debug(_("ii = %s")%(header['ii']))
    

    if (family == FAMILY_OBS):
      # Decode entire CCCC
      debug(_("Decoding CCCC ..."))
      CCCC = _getCCCCHeader(datatypeParts)
      header['C1'] = CCCC[0]
      header['C2'] = CCCC[1]
      header['C3'] = CCCC[2]
      header['C4'] = CCCC[3]
      debug(_("CCCC = %s")%(CCCC))
    else:
      debug(_("Decoding C1 ..."))
      header['C1'] = _getC1Header(datatypeParts)
      debug(_("C1 = %s")%(header['C1']))
      
      debug(_("Decoding C2 ..."))
      header['C2'] = _getC2Header(datatypeParts)
      debug(_("C2 = %s")%(header['C2']))
      
      debug(_("Decoding C3 ..."))
      header['C3'] = _getC3Header(datatypeParts)
      debug(_("C3 = %s")%(header['C3']))
      
      debug(_("Decoding C4 ..."))
      header['C4'] = _getC4Header(datatypeParts)
      debug(_("C4 = %s")%(header['C4']))
      
  except Exception, e:
    error(_("Data reference error: %s")%(str(e)))
    sys.exit(1)

  h = str(header['T1'])+str(header['T2'])+str(header['A1'])+str(header['A2'])+str(header['ii'])
  c = str(header['C1'])+str(header['C2'])+str(header['C3'])+str(header['C4'])
  d = header['date']

  info(_("Generated Transmet header : %s %s")%(h,c))
  
  debug(_("END  Generating header"))
  
  return [h, c, d]
  
  
def _getT1Header(datatypeParts):
  T1 = None
  family = datatypeParts['family']
  
  if (family == FAMILY_MODEL):
    T1 = HEADERS_T1[FAMILY_MODEL]
    """
    model = datatypeParts['model']
    try:
      T1 = HEADERS_T1[FAMILY_MODEL][model]
    except:
      raise Exception(_("Model %s not recognized, expected: %s")%(model, str(HEADERS_T1[FAMILY_MODEL].keys())) )
    """
  
  elif (family == FAMILY_SAT):
    T1 = HEADERS_T1[FAMILY_SAT]

  elif (family == FAMILY_OBS):
    T1 = HEADERS_T1[FAMILY_OBS]
  
  return T1


def _getT2Header(datatypeParts):
  T2 = None
  family = datatypeParts['family']
  
  if (family == FAMILY_MODEL):
    subset = datatypeParts['subset']
    try:
      T2 = HEADERS_T2[FAMILY_MODEL][subset]
    except:
      raise Exception(_("Subset %s not recognized, expected: %s")%(subset,str(HEADERS_T2[FAMILY_MODEL].keys())))
  
  elif (family == FAMILY_SAT):
    application = datatypeParts['product']
    try:
      T2 = HEADERS_T2[FAMILY_SAT][application]
    except:
      raise Exception(_("%s not recognized, expected: %s")%(application, str(HEADERS_T2[FAMILI_SAT].keys())))
    

  elif (family == FAMILY_OBS):
    T1 = _getT1Header(datatypeParts)
    format = datatypeParts['format']
    T2 = HEADERS_T2[T1][format]
  return T2
    
    
def _getA1Header(datatypeParts):
  A1 = None

  family = datatypeParts['family']
  
  if (family == FAMILY_MODEL):
    T1 = _getT1Header(datatypeParts)
    if (T1 == 'Y'):
      grid = datatypeParts['grid']

      # Flexibility on grid name (eg INDIAXL0500 = INDIAXL)
      import re
      stripGrid = re.sub("[^a-zA-Z]","",grid)
      try:
        A1 = HEADERS_A1[FAMILY_MODEL]['Y'][stripGrid]
      except:
        raise Exception(_("Grid %s (%s) not recognized, expected: %s")%(grid, stripGrid,str(HEADERS_A1[FAMILY_MODEL]['Y'].keys())))      
    
    elif (T1 == 'H'):
      A1 = "_FIXME_"
      
  elif (family == FAMILY_SAT):
    domain = datatypeParts['domain']
    try:
      A1 = HEADERS_A1[FAMILY_SAT][domain]
    except:
      raise Exception(_("%s no recognized, expected: %s")%(domain, str(HEADERS_A1[FAMILY_SAT].keys())))



  elif (family == FAMILY_OBS):
    T1 = _getT1Header(datatypeParts)
    domain = datatypeParts['domain']
    try:
      A1 = HEADERS_A1[T1][_getT2Header(datatypeParts)][domain]
    except:
      raise Exception(_("%s no recognized, expected: %s")%(domain, str(HEADERS_A1[T1][_getT2Header(datatypeParts)].keys() )))

  return A1


def _getA2Header(datatypeParts):
  A2 = None
  family = datatypeParts['family']
  
  if (family == FAMILY_MODEL):
    fcstRange = int(datatypeParts['fcstRange'])
    if (_getT1Header(datatypeParts) == 'Y'):
      if (fcstRange >= 0 and fcstRange <= 99):
        A2 = 'R'
      elif (fcstRange >= 100 and fcstRange <= 199):
        A2 = 'S'
      else:
        A2 = "_FIXME_"
      
    if (_getT1Header(datatypeParts) == 'H'):
      A2 =  "_FIXME_"

  if (family == FAMILY_SAT):
    domain = datatypeParts['domain']
    try:
      A2 = HEADERS_A2[FAMILY_SAT][domain]
    except:
      raise Exception(_("%s no recognized, expected: %s")%(domain, str(HEADERS_A2[FAMILY_SAT].keys())))

  if (family == FAMILY_OBS):
    T1 = _getT1Header(datatypeParts)
    T2 = _getT2Header(datatypeParts)

    A2 = HEADERS_A2[T1][T2][family]

  return A2


def _getiiHeader(datatypeParts):
  ii = None
  
  family = datatypeParts['family']
  if (family == FAMILY_MODEL):
    range = datatypeParts['fcstRange']
    ii = str("%.2d" % int(range[-2:]))
    
  elif (family == FAMILY_SAT):
    date = datatypeParts['date']
    format = datatypeParts['format']
    
    if ( not (len(date) == len(DATE_FORMAT)) and (date.isdigit()) ):
      raise Exception(_("Date %s not recognized")%(date))
      
    # ii is minutes of date
    #######################
    ii = date[-4:-2]
    
    # Regarding format, we might add some units
    ############################################
    if (format in ('TIFFMF')):
      ii = ii[0] + '0'
    elif (format in ('GEOTIFF')):
      ii = ii[0] + '1'
    elif (format in ('JPG','JPEG')):
      ii = ii[0] + '2'
    elif (format in ('HDF')):
      ii = ii[0] + '3'
    

  elif (family == FAMILY_OBS):
    depth = datatypeParts['depth']
    ii = depth


  return str(ii)

def _getC1Header(datatypeParts):
  return HEADERS_C1


def _getC2Header(datatypeParts):
  C2 = None
  family = datatypeParts['family']
  if (family == FAMILY_MODEL):
    model = datatypeParts['model']

    # Flexibility on model name (eg PARPTR = ARP)
    for (key, value) in HEADERS_C2[FAMILY_MODEL].items():
      if (model.find(key) != -1):
        C2 = value

    if (C2 == None):
      raise Exception(_("Model %s not recognized, expected: %s")%(model,str(HEADERS_C2[FAMILY_MODEL].keys())))

    """
    try:
      C2 = HEADERS_C2[family][model]
    except:
      raise Exception(_("Model %s not recognized, expected: %s")%(model, str(HEADERS_C2[family][model].keys())))
    """
  
  elif (family == FAMILY_SAT):
    product = datatypeParts['sat']
    try:
      C2 = HEADERS_C2[family][product]
    except:
      raise Exception(_("Satellite %s not recognized, expected: %s")%(product, str(HEADERS_C2[family].keys())))
  
  return C2


def _getC3Header(datatypeParts):
  C3 = None
  try:
    C3 = HEADERS_C3[datatypeParts['region']]
  except:
    raise Exception(_("Region %s not recognized")%(datatypeParts['region']))
  
  return C3

 
def _getC4Header(datatypeParts):
  C4 = HEADERS_C4[HEADERS_VERSION]
  return C4
  
  
def _getCCCCHeader(datatypeParts):
  CCCC = None
  family = datatypeParts['family']
  if (family == FAMILY_OBS):
    source = datatypeParts['source']
    CCCC = HEADERS_CCCC[source]

  return CCCC
  
  
  

#############################################################################
#                                                                           #
#                        Functions to rename and send files                 #
#                                                                           #
#############################################################################
"""
Make symbolic link for a file with correct PrdDB syntax:
  YYYYMMDD.key1.key2.key3.originalFileName

@input  file      Original filename
@input  keys      [key1, key2, key3]
@input  date      Date for PrdDB
@output fileName   PrdDB filename
"""
def generatePrdDBFilename(file, keys, date=None):
  filename = os.path.basename(file)
  todayDate = datetime.date.today().strftime("%Y%m%d")

  if (not date):
    date = todayDate
  
  keyPrefix = str(date)+"."+keys['key1']+"."+keys['key2']+"."+keys['key3']+"."+filename

  return keyPrefix
  
  
  
"""
Using strict GTS filenaming convention (see attII15rev.pdf)

Make symbolic link for a file with correct Transmet header:
  T_CIMOWR_C_LFPW_20090729000000_[orginialFileName].bin

Where
  T         Transmet
  CIPSPRD   Header to identify the product we are sending
  C_LMFI    Indicate origin center (here local MFI CIPS)

@input  header      TTAAii header
@input  center      CCCC center
@input  freeformat  Freeformat stuff
@input  date        Date of validity
@output fileName    Transmet filename
"""
def generateTransmetFilename(header, center, freeformat, date=None):
  # Get date as YYYYMMDDHHmmSS
  if (not date):
    todayDate = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    date = todayDate
  
  # Get filename without any "."
  freeformat = replace(freeformat, ".", "_")

  # Add ProcessId to filename
  pid = str(os.getpid())
  
  # Rename for Transmet 
  fileName = "T_"+header+"_C_"+center+"_"+date+"_"+freeformat+"_"+pid+".bin"
  
  return fileName
  




"""
Send a file to Transmet with a specific filename

@input file                Real file path
@input transmetFilename    Remote filename
@output returnCode         -1 if error has occured
"""
def sendWithTransmet(file, transmetFilename):
  global _donothing
  
  info(_("Sending %s (%s) through Transmet")%(file, transmetFilename))

  # Make symbolic link
  if (not file == transmetFilename):
    makeSymbolicLink(file, transmetFilename)
  
  # Send file
  returnCode = 0
  for host in TRANSMET_HOSTS:
    cmd = FTP_COMMAND+" "+FTP_ARGS+" -u "+TRANSMET_LOGIN+" -p "+TRANSMET_PASSW+" "+host+" "+TRANSMET_PATH+" "+transmetFilename

    if (_log):
       #cmd = cmd + " 2>&1 | tee -a " + LOG_FILE
      cmd = cmd + " &> /tmp/cips_send.$$ ; sendcode=$? ; "
      cmd = cmd + "cat /tmp/cips_send.$$ >> " + LOG_FILE
      cmd = cmd + " ; cat /tmp/cips_send.$$ ; rm /tmp/cips_send.$$ ; exit $sendcode" 
  
    print "DEBUG: " + cmd
    if (_donothing):
      ret = 0
    else:
      ret = launchSubProcess(cmd)
    
    if ( ret != 0):
      returnCode = 1
          
  # Remove symbolic link
  if (not file == transmetFilename):
    removeSymbolicLink(transmetFilename)
  
  return returnCode


"""
Send a file to CIPS with a specific filename

@input file                Real file path
@input transmetFilename    Remote filename
@output returnCode         -1 if error has occured
"""
def sendToCIPS(database, file, cipsFilename):
  info(_("Sending %s (%s) through CIPS")%(file, cipsFilename))

  # Make symbolic link
  if (not file == cipsFilename):
    makeSymbolicLink(file, cipsFilename)
  
  # Send file
  returnCode = 0
  for host in CIPS_HOSTS:
    info(_("Sending %s (%s) to CIPS Host %s")%(file, cipsFilename,host))
    cmd = FTP_COMMAND+" "+FTP_ARGS+" -u "+CIPS_LOGIN+" -p "+CIPS_PASSW+" "+host+" "+database+" "+cipsFilename

    ret = launchSubProcess(cmd)
    if ( ret != 0):
      returnCode = 1
          
  # Remove symbolic link
  if (not file == cipsFilename):
    removeSymbolicLink(cipsFilename)
  
  return returnCode



"""
Append PID and HOSTNAME to filename
to avoid same filenames

@input  file      Original filename
@output fileName  Unique filename
"""
def uniqueFileName(file):
  import socket, posix
  hostname = socket.gethostname()
  pid = posix.getpid()
  
  fileName = str(file)+"."+str(pid)+"."+str(hostname)
  
  return fileName
  

#############################################################################
#                                                                           #
#                        Main program                                       #
#                                                                           #
#############################################################################
def usage():
  print ""
  print "Usage : cips_send.py [OPTIONS]"
  print "Unified tool for sending data to/from CIPS"
  print ""
  print "   -f, --files FILES         Files to send"
  print "   -m, --mode MODE           Force mode:"
  print "                               * transmet-header      to any through Transmet"
  print "                               * region               to region through Transmet"
  print "                               * cips                 to CIPS only through Transmet"
  print "                               * cips_debug           for sending directly (debug only)"
  print ""
  print "   --verbose             Show verbose information"
  print "   --debug"
  print ""   
  print "Options for mode transmet-header:"
  print "Send to any through Transmet"
  print "   --header TTAAii       Header specify for Transmet"
  print "   --center CCCC         Center"
  print ""
  print "Options for mode region:"
  print "Send to region through Transmet"
  print "   --dataref DATAREF    Datareference of files to send, i.e:"
  print "   Examples:"
  print "       ATM_PARPTR_INDIAXL1500_SET_FORECASTERS_FMT_GRIB_FR_00"
  print "       SAT_KALPANA1_PRD_CC_SPACE74E_FMT_JPG_RES_1400_20100428080000"
  print ""
  print "   --bandwidth REGION        Bandwith capacity"
  print "                             Could be full,inter,low"
  print ""
  print "Options for mode CIPS:"
  print "Send to CIPS only through Transmet"
  print "   --database DB         Database to send the files:"
  print "                             Could be: moddb, imgdb, prddb, fctdb"
  print "   PrdDB with specific keys:"
  print "       --date YYYYMMDD           Specify date (optional)"
  print "       --key1 KEY1               Specify Key1"
  print "       --key2 KEY2               Specify Key2"
  print "       --key3 KEY3               Specify Key3"
  print ""  

def getDate():
  import os
  from time import strftime
  return strftime("%Y-%m-%d %H:%M:%S") + " (" + str(os.getpid()) + ") "

def error(err, exception=None):
  global _debug, _log

  print getDate() + _("Error  : ") + str(err)

  if (_log):
    fdLog = open(LOG_FILE, 'a+')
    fdLog.write(getDate() + _("Info   : ") + str(err)+"\n")
    fdLog.close()

  if (_debug and exception):
    raise exception
 
def debug(err):
  global _debug
  
  if (_debug):
    print getDate() + _("Debug  : ") + str(err)
  
def info(err):
  global _debug, _verbose, _log
  
  if (_debug or _verbose):
    print getDate() + _("Info   : ") + str(err)

    if (_log):
      fdLog = open(LOG_FILE, 'a+')
      fdLog.write(getDate() + _("Info   : ") + str(err)+"\n")
      fdLog.close()


def makeSymbolicLink(file, newfile):
  debug(_("Linking %s to %s")%(file, newfile))
  try:
    os.symlink(file, newfile)
  except Exception, err:
    error(_("Linking file : %s")%(str(err)))

def removeSymbolicLink(file):
  info(_("Removing link %s")%(file))
  try:
    os.remove(file)
  except:
    pass
  

def launchSubProcess(command):
  """ Launch external command
  """
  #from subprocess import Popen, STDOUT, PIPE
  #return Popen(command, stderr=STDOUT, stdout=PIPE) 
  global _log

  import os

  debug( (_("Launching: %s ")%(command)))
  return os.system(command)



#####################################################
#
# Main
#
#####################################################
def main(files, mode, args):
  returnCode = 0

  ##########################
  # Mode Transmet
  ##########################
  if (mode == upper(MODE_TRANSMET)):
    for file in files:
      info(_("Sending %s to Transmet")%(file))

      # Header from command line
      #################
      transmetHeader = args['header']
      transmetCenter = args['center']
      # Use current date
      date = None 

      # Specific freeformat for PrdDB
      ###############################
      if ( args.has_key('database') and (args['database'] == (CST_PRDDB)) ):
        freeformatFile = generatePrdDBFilename(file, args['prddb'], args['prddb']['date'])
      else:
        freeformatFile = file

      # Final transmet name
      #####################
      transmetFilename = generateTransmetFilename(transmetHeader, transmetCenter, freeformatFile, date)
      
      # Send to transmet
      ##################
      returnCode = sendWithTransmet(file, transmetFilename)


  ##########################
  # Mode Region
  ##########################
  elif (mode == upper(MODE_REGION)):
    for file in files:
      info(_("Sending %s to region through Transmet")%(file))
      
      #TODO: explode files in several forecast ranges if needed ??
      
      # Generate header
      #################
      [transmetHeader, transmetCenter, date] = generateTransmetHeaders(file, args['datatype'], args['region'])
      
      # Specific freeformat for PrdDB
      ###############################
      if (not datatype): #FIXIT
        freeformatFile = generatePrdDBFilename(file, args['prddb'])
      else:
        freeformatFile = file

      # Final transmet name
      #####################
      transmetFilename = generateTransmetFilename(transmetHeader, transmetCenter, file, date)
      
      # Send to transmet
      ##################
      returnCode = sendWithTransmet(file, transmetFilename)


  ##########################
  # Mode CIPS (only to CIPS through Transmet)
  ##########################
  elif (mode == upper(MODE_CIPS)):
    for file in files:
      info(_("Sending %s to CIPS only through Transmet")%(file))

      # Generate header
      #################
      if args['database'] in (TRANSMET_HEADERS.keys()):
        # In this case we send directly to CIPS through Transmet
        # Use "generic" headers
        ########################
        transmetHeader = TRANSMET_HEADERS[args['database']]
        transmetCentre = TRANSMET_CENTERS[args['database']]
      else:
        error(_("Database %s unknown")%(args['database']))
        sys.exit(1)
      
      # Specific freeformat for PrdDB
      ###############################
      if (args['database'] in (CST_PRDDB)):
        freeformatFile = generatePrdDBFilename(file, args['prddb'], args['prddb']['date'])
      else:
        freeformatFile = file
      
      # Final transmet name
      #####################
      transmetFileName = generateTransmetFilename(transmetHeader, transmetCentre, freeformatFile)
      
      # Send to transmet
      ##################
      returnCode = sendWithTransmet(file, transmetFileName)


  ##########################
  # Mode CIPS DEBUG (directly to CIPS)
  ##########################
  elif (mode == upper(MODE_CIPS_DEBUG)):
    for file in files:
      info(_("Sending %s to CIPS directly")%(file))
      
      # Specific freeformat for PrdDB
      ###############################
      if (args['database'] in (CST_PRDDB)):
        fileName = generatePrdDBFilename(file, args['prddb'], args['prddb']['date'])
      else:
        fileName = file
        
      # Send to CIPS
      ##############
      returnCode = sendToCIPS(database, file, fileName)
      
  else:
    error(_("Mode not recognized: %s")%(mode))
    returnCode = 1

  # Return error code if ftp transfert failure
  ##############################
  sys.exit(returnCode)




if __name__ == "__main__":
  import sys, getopt

  files      = ""
  mode       = ""
  
  datatype   = ""
  region     = ""
  header     = ""
  center     = ""
  
  database   = ""
  
  date = ""
  key1 = ""
  key2 = ""
  key3 = ""

  if (_log):
    if (not os.path.exists(os.path.dirname(LOG_FILE))):
      _log = 0


  gettext.install("cips_cal")
  
  try:
    opts, args = getopt.gnu_getopt(sys.argv[1:], "f:m:dr:db:v", 
          ["files=", "mode=", "debug", "verbose", "info",\
           "dataref=", "region=", "bandwidth=", "header=", "center=",
           "database=", "key1=","key2=","key3=","date="])
           
  except getopt.GetoptError, err:
    error(err)
    usage()
    sys.exit(1)
  
  # Parse arguments
  #################
  logArgs = ''
  for opt, arg in opts:
    logArgs = logArgs + "%s: %s | "%(opt, arg)

    if opt in ("-f", "--files"):
      files = [arg]
      if (args):
        files = files + args
    elif opt in ("-m", "--mode"):
      mode = arg
      
    elif opt in ("-v", "--verbose"):
      _verbose = 1
    elif opt in ("--info"):
      _donothing = 1
    elif opt in ("--debug"):
      _verbose = 1               
      _debug = 1
      
    elif opt in ("-dr", "--dataref"):
      datatype = arg
    elif opt in ("-r", "--region", "--bandwidth"):
      region = arg
    elif opt in ("--header"):
      header = arg
    elif opt in ("--center"):
      center = arg
         
    elif opt in ("-db", "--database"):
      database = arg
    elif opt in ("--date"):
      date = arg
    elif opt in ("--key1"):
      key1 = arg
    elif opt in ("--key2"):
      key2 = arg
    elif opt in ("--key3"):
      key3 = arg
      

  # Check arguments validity
  ##########################
  if (not files):
    error(_("--files argument required"))
    usage()
    sys.exit(1)
    
  if (not mode):
    error(_("--mode argument required"))
    usage()
    sys.exit(1)

  if (upper(mode) == upper(MODE_TRANSMET)):
    if (not header):
      error(_("--header argument required"))
      sys.exit(1)

    if (not center):
      error(_("--center argument required"))
      sys.exit(1)
    

  if (upper(mode) == upper(MODE_REGION)):
    if (not datatype):
      error(_("--dataref argument required"))
      sys.exit(1)
    if (not region):
      family = datatype.split('_')[0]
      if (family == FAMILY_OBS):
        pass
      else:
        error(_("--bandwidth argument required"))
        sys.exit(1)
      
  elif (upper(mode) in (upper(MODE_CIPS), upper(MODE_CIPS_DEBUG)) ):
    if (not database):
      error(_("--database argument required"))
      sys.exit(1)
      
  if (upper(database) == upper(CST_PRDDB) ):
    if (not key1):
      error(_("--key1 argument required for database PrdDB"))
      sys.exit(1)
    if (not key2):
      error(_("--key2 argument required for database PrdDB"))
      sys.exit(1)
    if (not key3):
      error(_("--key3 argument required for database PrdDB"))
      sys.exit(1)
       

  # Init log if needed
  ####################
  if (_log):
    # Get user informations
    import os,pwd
    uid = os.getuid()
    username = pwd.getpwuid(uid)[0]
    # Get host informations
    import socket
    (host, null, ip) = socket.gethostbyaddr(socket.gethostname())
    # Fill log file
    info(_("=== Start sending | %s user: %s (%s) | host: %s (%s) ")%(logArgs, username, uid, host, ip))


  # Launch main
  ##########################
  main(files, upper(mode), \
    {'datatype':datatype, 'region':region, \
     'header': header, 'center': center,
     'database':database,
     'prddb':{'date':date,'key1':key1,'key2':key2,'key3':key3}
     })



