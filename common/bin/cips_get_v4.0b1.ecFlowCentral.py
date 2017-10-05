#!/usr/bin/python
# Translation of <param> to --paramAlias, only for ModDB
# Name: cips_cal.py
# Property: Meteo France International (M.F.I.)
# Author: S. BENCHIMOL / R. MONTROTY
# Release: 3.3b1
# Status: Beta3 (Development)
# Creation Date: 2009/06/11
# Modification Date: 
# 2014/04/26 : Timeout 600s on wget
# 2014/10/20 : RM ; add TASKCENTER_STATUS review
# 2014/10/24 : MSP ; add TASKCENTER_STATUS try / catch 
# 2015/10/15 : Option for sending raw files
# 2015/10/20 : 3.3b1 ; RM, LRFDB compatibility (duplicate all PrdDB classes)
# 2015/10/29 : 3.3b1 ; RM, Bring to CNMTBI


"""
Description: Universal CIPS Access Layer
"""

#############################################################################
#                                                                           #
#                        Config options                                     #
#                                                                           #
#                                                                           #
#############################################################################
## RM tmp mod while cipsstandby is down...
#CIPSSTANDBY = "cipsoper"
#CIPSOPER    = "vcipsoper"

## Version RCC Botswana for CNMGAS
CIPSSTANDBY = "192.168.200.23"
CIPSOPER    = "192.168.200.22"

CONFIG_REMOTEURL = 0
CONFIG_SOCKETPIPE = 2
CONFIG_REMOTESSH = 4
CONFIG_CONSOLE = 5

# Set up config regarding hostname
#####################
# Par default (dev) : wget
# CIpsInteg : socketpipe sur cipsstandby
# CIPSProc : socketpipe sur cipsoper
# CIPSOper : socketpipe sur cipsoper
# CIPSStandy : sockepipe sur cipsstandby

import socket
host = socket.gethostbyaddr(socket.gethostname())[0]

if   (host == "cipsinteg"):
  CIPS_REMOTE_IP = CIPSSTANDBY
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE
elif (host == "cipsproc1"):
  CIPS_REMOTE_IP = CIPSOPER
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE
elif (host == "cipsproc2"):
  CIPS_REMOTE_IP = CIPSOPER
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE
elif (host == "cipsproc3"):
  CIPS_REMOTE_IP = CIPSOPER
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE  
  
elif (host == "cipsoper"):
  CIPS_REMOTE_IP = CIPSOPER
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE
elif (host == "cipsstandby"):
  CIPS_REMOTE_IP = CIPSSTANDBY
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE  
else:
  CIPS_REMOTE_IP = CIPSSTANDBY
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_REMOTEURL    


## Override from TASKCENTER_STATUS if available
import os

## Muchtar fix 20141024 in case of developer user 
#  (no TASKCENTER_STATUS available in environment)
try:
  taskcenter_status = os.environ["TASKCENTER_STATUS"]
except KeyError:
  taskcenter_status = 'DEFAULT'

if (taskcenter_status == "OPER"):
  print "Task running in OPER environment. Feeding from CIPSOPER"
  CIPS_REMOTE_IP = CIPSOPER
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_REMOTEURL
elif (taskcenter_status == "INTEGRATION"):
  print "Task running in INTEGRATION environment. Feeding from CIPSSSTANDBY"
  CIPS_REMOTE_IP = CIPSSTANDBY
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_REMOTEURL
else:
  print "No proper TASKCENTER_STATUS environment found. Feeding from CIPSSTANDBY"
  CIPS_REMOTE_IP = CIPSSTANDBY
  CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
  CONFIG_MODE_GETDATA = CONFIG_REMOTEURL





CIPS_REMOTE_LOGIN = "cips"
CIPS_REMOTE_WEB = "http://"+CIPS_REMOTE_IP+"/cips"
CIPS_REMOTE_WEBSERVICES = CIPS_REMOTE_WEB + "/cal"
CIPS_REMOTE_WEBTIMEOUT = 3000
CIPS_SOCKETPIPE = "/bin/socketpipe"
CIPS_PHP = "./cipsenv php.local.sh"
CIPS_REMOTE_PHPPATH = " /home/cips/www/cal"
CIPS_REMOTE_PHPSCRIPT = CIPS_PHP + CIPS_REMOTE_PHPPATH

#[ModDB]
MODDB_GETCAPABILITES_FILE = "get_moddb.php"
MODDB_GETDATA_PHP = "moddb_access.php"
MODDB_GETDATA_SCRIPT = "./cipsenv moddb_access.sh"
MODDB_OUTFILE_PATH = "%2fscratch_nfs%2ftmp%2f" # Muchtar

#[ImgDB]
IMGDB_GETCAPABILITES_FILE = "get_imgdb.php"
IMGDB_GETDATA_PHP = "imgdb_access.php"
IMGDB_GETDATA_SCRIPT = "./cipsenv imgdb_access.sh"

#[ObsDB]
OBSDB_GETCAPABILITES_FILE = "get_obsdb.php"
OBSDB_GETDATA_PHP = "obsdb_access.php"
OBSDB_GETDATA_SCRIPT = "./cipsenv obsdb_access.sh"

#[PrdDB]
PRDDB_GETCAPABILITES_FILE = "get_prddb.php"
PRDDB_GETDATA_PHP = "prddb_access.php"
PRDDB_GETDATA_SCRIPT = "./cipsenv prddb_access.sh"

#[LrfDB]
LRFDB_GETCAPABILITES_FILE = "get_lrfdb.php"
LRFDB_GETDATA_PHP = "lrfdb_access.php"
LRFDB_GETDATA_SCRIPT = "./cipsenv lrfdb_access.sh"

#[FctDB]
FCTDB_GETCAPABILITES_FILE = "get_fctdb.php"
FCTDB_GETDATA_PHP = "fctdb_access.php"
FCTDB_GETDATA_SCRIPT = "./cipsenv fctdb_access.sh"

#[CIPS_CAL]
OUTPUT_CHAR = "-"

# Default config
CONFIG_MODE_OUTPUT = CONFIG_CONSOLE
VAR_AVAIL = 0


#############################################################################
#                                                                           #
#                        XML and config Constants                           #
#                                                                           #
#############################################################################

## To read XML input file
XMLTAG_REQUEST          = "request"
XMLTAG_DATABASE         = "database"
XMLTAG_REQUEST_TYPE     = "type"
XMLTAG_REQUEST_NAME     = "name"
XMLTAG_USER             = "user"
XMLTAG_FORMAT           = "format"
XMLTAG_VARIABLES        = "variables"
XMLTAG_OUTFILE          = "outFile" # Muchtar # new variable to handle outFile

XMLTAG_DATE             = "date"
XMLTAG_DATERUN          = "dateRun"
XMLTAG_DATEBEGIN        = "dateBegin"
XMLTAG_DATEEND          = "dateEnd"
XMLTAG_DATERUNBEGIN     = "dateRunBegin"
XMLTAG_DATERUNEND       = "dateRunEnd"
XMLTAG_DATEREF          = "dateRef"
XMLTAG_TIMEDEPTH        = "timeDepth"

XMLTAG_PERIOD_BEGIN     = "begin"
XMLTAG_PERIOD_END       = "end"
XMLTAG_PERIOD_STEP      = "step"

XMLTAG_GRID             = "grid"
XMLTAG_SUBGRID          = "subGrid"
XMLTAG_RESOLUTION       = "resolution"
XMLTAG_PREVIEWAREA      = "previewArea"
XMLTAG_MODEL            = "model"
XMLTAG_PARAM            = "param"
XMLTAG_PARAMALIAS       = "paramAlias"
XMLTAG_RANGE            = "range"
XMLTAG_LEVEL            = "level"
XMLTAG_PREVIEWLEGEND    = "previewLegend" # Muchtar # new variable to handle previewLegend

XMLTAG_TIMESTAMP        = "timeStamp"
XMLTAG_PRODUCT          = "product"
XMLTAG_DOMAIN           = "domain"
XMLTAG_PARAM            = "param"
XMLTAG_SUBDOMAIN        = "subDomain"
XMLTAG_PREVIEWAREA      = "previewArea"

XMLTAG_MINLAT           = "minLat" # Muchtar # <minLat>-30000</minLat>
XMLTAG_MAXLAT           = "maxLat" # Muchtar # <maxLat>30000</maxLat>
XMLTAG_MINLON           = "minLon" # Muchtar # <minLon>60000</minLon>
XMLTAG_MAXLON           = "maxLon" # Muchtar # <maxLon>150000</maxLon>
ARG_MINLAT              = -90000 # Muchta
ARG_MAXLAT              = 90000 # Muchtar
ARG_MINLON              = -180000 # Muchtar
ARG_MAXLON              = 180000 # Muchtar
LATLON_OR_DOMAIN        = 1 # Muchtar, 0 if argument has latlon, 1 if not

XMLTAG_OBSTYPE          = "obsType"
XMLTAG_STATION          = "station"

XMLTAG_KEY1             = "key1"
XMLTAG_KEY2             = "key2"
XMLTAG_KEY3             = "key3"
XMLTAG_FILTER           = "filter"

# LrfDB
XMLTAG_LRFMODEL         = "model"
XMLTAG_LRFTYPE          = "type"
XMLTAG_LRFSUBTYPE       = "subtype"

XMLTAG_FCTTYPE          = "fctType"

# Possible values for XMLTAG_DATABASE
CST_MODDB               = "moddb"
CST_IMGDB               = "imgdb"
CST_PRDDB               = "prddb"
CST_OBSDB               = "obsdb"
CST_FCTDB               = "fctdb"
CST_LRFDB               = "lrfdb"

# Possible values for XMLTAG_REQUEST_TYPE
CST_GETCAPABILITIES     = "getCapabilities"
CST_GETDATA             = "getData"
# Possible values for XMLTAG_REQUEST_NAME
CST_LISTRUN             = "listRun"
CST_LISTMODEL           = "listModel"
CST_LISTGRID            = "listGrid"
CST_LISTRANGE           = "listRange"
CST_LISTLEVEL           = "listLevel"
CST_LISTPARAM           = "listParam"
CST_LISTAREA            = "listArea"

CST_LISTKEY1            = "listKey1"
CST_LISTKEY2            = "listKey2"
CST_LISTKEY3            = "listKey3"

## for LrfDB 
CST_LISTLRFMODEL        = "list_dates"
CST_LISTLRFTYPE         = "list_folders"
CST_LISTLRFSUBTYPE      = "list_files"

CST_LISTPROD            = "listProd"
CST_LISTDOMAIN          = "listDomain"
CST_LISTSUBGRID         = "listSubGrid"
CST_LISTPREVIEWAREA     = "listPreviewArea"
CST_LISTTIMESTAMP       = "listTimeStamp"

CST_LISTOBSTYPE         = "listObsType"
CST_LISTSTATION         = "listStation"

CST_LISTFCTTYPE         = "listFctType"



## To read the configuration file
CONFTAG_CIPS                    = "CIPS"
CONFTAG_CIPS_REMOTE_IP          = "CIPS_REMOTE_IP"
CONFTAG_CIPS_REMOTE_LOGIN       = "CIPS_REMOTE_LOGIN"
CONFTAG_CIPS_REMOTE_WEB         = "CIPS_REMOTE_WEB"
CONFTAG_CIPS_REMOTE_WEBSERVICES = "CIPS_REMOTE_WEBSERVICES"
CONFTAG_CIPS_REMOTE_WEBTIMEOUT  = "CIPS_REMOTE_WEBTIMEOUT"
CONFTAG_CIPS_LOCAL_SOCKETPIPE   = "LOCAL_SOCKETPIPE"
CONFTAG_CIPS_PHP                = "CIPS_PHP"
CONFTAG_CIPS_REMOTE_PHPSCRIPT   = "CIPS_REMOTE_PHPSCRIPT"
CONFTAG_CAL                     = "CAL"
CONFTAG_CAL_MODE_GETCAPABILITES = "CONFIG_MODE_GETCAPABILITIES"
CONFTAG_CAL_MODE_GETDATA        = "CONFIG_MODE_GETDATA"
CONFTAG_CAL_MODE_OUTPUT         = "CONFIG_MODE_OUTPUT"


global _debug, _verbose
_debug = 0
_verbose = 0

import urllib2, socket, os
import gettext, sys
import copy, types
from string import upper
import datetime
from tempfile import mkstemp

# For Python 2.5
try:
  import xml.etree.ElementTree as ET
except:
# For Python 2.3
  import elementtree.ElementTree as ET


def XMLTreeCaseInsentitiveFind(xmlTree, myTag):
  for child in xmlTree:
    if (upper(child.tag) == upper(myTag) ):
      return child  
      
def XMLTreeCaseInsentitiveFindAll(xmlTree, myTag):
  for child in xmlTree:
    print child.tag
    if (upper(child.tag) == upper(myTag) ):
      yield child 


def ParseStringToDate(string):
  try:
    #TODO: Check regexp
    year    = int(string[0:4])
    month   = int(string[4:6])
    day     = int(string[6:8])

    # Optional
    hour    = int(string[8:10])
    minute  = int(string[10:12])
    second  = int(string[12:14])
    
    return datetime.datetime(year, month, day, hour, minute, second)
  except:
    raise Exception(_("Unable to parse %s as a date")%(string))
    
    
def ParseStringToTimedelta(string):
  #TODO: Check regexp
  #TODO: Check regexp
  year    = int(string[0:4])
  month   = int(string[4:6])
  day     = int(string[6:8])

  # Optional
  hour    = int(string[8:10])
  minute  = int(string[10:12])
  second  = int(string[12:14])
  
  return datetime.timedelta( days=int(day), seconds = int(second), minutes = int(minute), hours = int(hour) )
  


"""
This class handles special date keywords
and convert them in format YYYYMMDDHHmmSS

There is three category of keywords:
  - Simple keyword
      __NOW__
      __TODAY__
      __YESTERDAY__
      __CURRENT_HOUR__
      __CURRENT_QUARTERHOUR__
      __CURRENT_HALFHOUR__
  
  - Timedelta keyword, ex __3_HOURS__
      __*_SECONDS__
      __*_MINUTES__
      __*_HOURS__
      __*_DAYS__

  - Composed keyword, ex __3_DAYS_AGO__
      __*_SECONDS_AGO__
      __*_MINUTES_AGO__
      __*_HOURS_AGO__
      __*_DAYS_AGO__


Simple keyword could be in any xml tag:
  <dateBegin>__TODAY__</dateBegin>

Timedelta and composed keyword could be only in <*Period> tag:
  <dateRunPeriod>
    <begin>__2_DAYS_AGO__</begin>
    <end>__CURRENT_HOUR__</end>
    <step>__12_HOURS__</step>
  </dateRunPeriod>

The <dateRun> list generation is done with Request._parseVariablePeriod()

"""
## 
XMLKEYWORD_LATEST = "__LATEST__"
class DateKeyword:
  def __init__(self):
    self.year     = "0000"
    self.month    = "00"
    self.day      = "00"
    self.hour     = "00"
    self.minute   = "00"
    self.second   = "00"
    
    self.keywords = {
      "NOW":                  self.NOW,
      "TODAY":                self.TODAY,
      "YESTERDAY":            self.YESTERDAY,
      "CURRENT_HOUR":         self.CURRENT_HOUR,
      "CURRENT_HALFHOUR":     self.CURRENT_HALFHOUR,
      "CURRENT_QUARTERHOUR":  self.CURRENT_QUARTERHOUR,
      "CURRENT_MINUTE":       self.CURRENT_MINUTE,
    }
    
    self.units = {
      "HOURS":        self.HOURS,
      "MINUTES":      self.MINUTES, 
      "SECOND":       self.SECONDS,
      "DAYS":         self.DAYS,
    }
    self.past  = [ "AGO" ]
  
  
  def match(self, keyword):
    #TODO: Check regular expression
    if (not keyword):
      return False

    if ( (keyword[:2] == "__") and (keyword[-2:] == "__") ):
      return True
    else:
      return False


  """
  Execute a get capabilities to get __LATEST__ value
  @in    string  tag
  @out   string  Date as string YYYYMMDDHHmmSS
  """
  def getLASTValue(self, tag, variablesTree):
    (fd, TEMP_FILE) = mkstemp()
    
    if (tag == XMLTAG_DATERUN.lower() ):
      myRequest = ModDBlistLatestRun(None)
      
      myRequest.mandatoryVariables[XMLTAG_REQUEST] = "listLatestRun"
      myRequest.mandatoryVariables[XMLTAG_FORMAT]  = "raw"
      
      try:
        for myTag in [XMLTAG_MODEL, XMLTAG_GRID]:
          myRequest.mandatoryVariables[myTag] = variablesTree.find(myTag).text
      except:
        error(_("Mandatory variable not found: %s")%(myTag))

      myRequest.generateCommand()
      myRequest.executeCommand(TEMP_FILE)
      try:
        try:

          r = ""
          f = open(TEMP_FILE,"r")
          for line in f:
            r += line
          
          if (r.strip()):
            return r.strip()
          else:
            raise Exception
          
        except Exception, e:
          #raise Exception(_("Keyword cannot be resolved : %s \t --> \t %s")%(XMLKEYWORD_LATEST, tag))
          error(_("Keyword cannot be resolved : %s \t --> \t %s")%(XMLKEYWORD_LATEST, tag))
          error(_("Unable to find latest dateRun for %s %s, exiting ...")%(myRequest.mandatoryVariables[XMLTAG_MODEL], \
                                                                           myRequest.mandatoryVariables[XMLTAG_GRID]), e)
        else:
          pass

      finally:
        f.close()
        os.remove(TEMP_FILE)
      
      
    elif (tag == XMLTAG_TIMESTAMP.lower() ):
      myRequest = ImgDBlistLatestTimestamp(None)
      
      myRequest.mandatoryVariables[XMLTAG_REQUEST] = "listLatestTimestamp"
      myRequest.mandatoryVariables[XMLTAG_FORMAT]  = "raw"
      
      try:
        for myTag in [XMLTAG_PRODUCT, XMLTAG_DOMAIN, XMLTAG_PARAM]:
          myRequest.mandatoryVariables[myTag] = variablesTree.find(myTag).text
      except:
        error(_("Mandatory variable not found: %s")%(myTag))


      myRequest.generateCommand()
      myRequest.executeCommand(TEMP_FILE)

      try:
        try:

          r = ""
          f = open(TEMP_FILE,"r")
          for line in f:
            r += line
          
          if (r.strip()):
            return r.strip()
          else:
            raise Exception
          
        except:
          error(_("Keyword cannot be resolved : %s \t --> \t %s")%(XMLKEYWORD_LATEST, tag))
        else:
          pass

      finally:
        f.close()
        os.remove(TEMP_FILE)
       

    #TODO:
    #elif (tag == XMLTAG_TIMESTAMP):
    
    else:
      raise(_("%s keyword for tag %s is not allowed")%(XMLKEYWORD_LATEST, tag) )
      #sys.exit(1)
      

  """
  Return date as string
  @in    string  Keyword
  @out   string  Date as string YYYYMMDDHHmmSS
  """
  def getValue(self, keyword, end=False, ):
    self.value = ""
  
    keyword = keyword[2:-2]
    t = keyword.split("_")

    ## Single keyword (eg. __NOW__, __CURRENT_HOUR__ )
    ###################
    if ( len(t) == 1 ):
      if (t[0] in self.keywords.keys() ):
        return self.keywords[t[0]](end)
    elif ( len(t) == 2 and t[0] == "CURRENT" ):
      t = t[0]+"_"+t[1]
      if (t in self.keywords.keys() ):
        return self.keywords[t](end)
        
    ## Time delta (eg. __15_MINUTES__)
    ###################
    elif ( ( len(t) == 2 ) and ( t[0] != "CURRENT" ) ):
      if ( t[1] in self.units.keys() ):
        return self.units[t[1]](t[0], end)

    ## Past (eg. __15_MINUTES_AGO__)
    ###################
    elif ( len(t) == 3):
      if ( t[1] in self.units.keys() ):
        # Get the timedelta
        timedeltaString = self.units[t[1]](t[0])
        timedelta = self._getTimeDeltaFromString()
        
        # Compute difference
        today = self.getDateNow()
        self.date = today - timedelta
        
        # Set hour/minute/second
        if (end):
          hour   = "23"
          minute = "59"
          second = "59"
        else:
          hour   = "00"
          minute = "00"
          second = "00"
          
        if (t[1] == "HOURS"):
          self.date = self.date.replace(minute=int(minute),second=int(second))
        elif (t[1] == "MINUTES"):
          self.date = self.date.replace(second=int(second) )
        elif (t[1] == "DAYS"):
          self.date = self.date.replace(minute=int(minute),second=int(second),hour=int(hour))
        
        return self._getDateStringFromDate()

  

  def _generateDate(self):
    self.date = datetime.date(  int(self.year), int(self.month),  int(self.day),
                                int(self.hour), int(self.minute), int(self.second) )

  def _getDateStringFromDate(self):
    return self.date.strftime("%Y%m%d%H%M%S")

  def _getDateStringFromString(self):
    return str(self.year)+str(self.month)+str(self.day)+ \
           str(self.hour)+str(self.minute)+str(self.second)
    
  def _getTimeDeltaFromString(self):
    return datetime.timedelta(days=int(self.day), 
                              minutes=int(self.minute), hours=int(self.hour) )
    
    
  def getDateNow(self):
    return datetime.datetime.utcnow()
  
  
  
  
  def NOW(self, end):
    self.date = self.getDateNow()
    return self._getDateStringFromDate()
  
  def TODAY(self, end):
    if (end):
      second = 59
      minute = 59
      hour   = 23
    else:
      second = 0
      minute = 0
      hour   = 0
      
    date = self.getDateNow()
    self.date = date.replace(microsecond=0,second=second,minute=minute,hour=hour)
    
    return self._getDateStringFromDate()
    
    
  def YESTERDAY(self, end):
    if (end):
      second = 59
      minute = 59
      hour   = 23
    else:
      second = 0
      minute = 0
      hour   = 0
      
    today = self.getDateNow()
    self.date = today - datetime.timedelta(days=1)
    self.date = self.date.replace(microsecond=0,second=second,minute=minute,hour=hour)

    return self._getDateStringFromDate()





  def CURRENT_HOUR(self, end):
    if (end):
      second = 00
      minute = 00
    else:
      second = 0
      minute = 0
      
    date = self.getDateNow()
    self.date = date.replace(microsecond=0,second=second,minute=minute)
    return self._getDateStringFromDate()
    
  def CURRENT_HALFHOUR(self, end):
    if (end):
      second = 59
    else:
      second = 0
      
    date = self.getDateNow()
    self.date = date.replace(microsecond=0, second=second, minute=( (date.minute/30)*30 ) )
    return self._getDateStringFromDate()
    
  def CURRENT_QUARTERHOUR(self, end):
    if (end):
      second = 0
    else:
      second = 0
      
    date = self.getDateNow()
    self.date = date.replace(microsecond=0,second=second,minute=( (date.minute/15)*15 ) )
    return self._getDateStringFromDate()
  
  def CURRENT_MINUTE(self, end):
    if (end):
      second = 0
    else:
      second = 0
      
    date = self.getDateNow()
    self.date = date.replace(microsecond=0,second=second)
    return self._getDateStringFromDate()



  def DAYS(self, nb, end=False):
    self.year     = "0000"
    self.month    = "00"
    self.day      = str(nb)
    self.hour     = "00"
    self.minute   = "00"
    self.second   = "00"
    
    return self._getDateStringFromString()
    
  def HOURS(self, nb, end=False):
    self.year     = "0000"
    self.month    = "00"
    self.day      = "00"
    self.hour     = str(nb)
    self.minute   = "00"
    self.second   = "00"
    
    return self._getDateStringFromString()
    
  def MINUTES(self, nb, end=False):
    self.year     = "0000"
    self.month    = "00"
    self.day      = "00"
    self.hour     = "00"
    self.minute   = str(nb)
    self.second   = "00"
    
    return self._getDateStringFromString()
    
  def SECONDS(self, nb, end=False):
    self.year     = "0000"
    self.month    = "00"
    self.day      = "00"
    self.hour     = "00"
    self.minute   = "00"
    self.second   = str(nb)
    
    return self._getDateStringFromString()
    
    
    
    
    
    
    
    
    
#############################################################################
#                                                                           #
#                        Generic classes                                    #
#                                                                           #
# Provide facilities for:
#     * Request                  : a generic request
#     * GetCapabilites(Request)  : a generic getCapabilities request
#     * GetData(Request)         : a generic getData request
#############################################################################

"""
Define a generic request for both getData and getCapabilities actions
"""
class Request:
  outputMode = CONFIG_MODE_OUTPUT
  outputFile = None
  
  def __init__(self, xmlTree):
    self.xmlTree = xmlTree
    self.mandatoryVariables = {}
    self.optionalVariables = {}
    self.multipleCommands = []
    self.multipleOutputFiles = []
    self.additionalVariables = {}


  """
  Execute the request
  
  @in inputFile     Filename of the xml request file
  @in outputFile    Filename or suffix for outputFile(s) (optional)
  @in plugins       Plugins name to execute after extraction
  """
  def execute(self, inputFile, outputFile, plugins):
    # Parse variables
    ##################
    debug(_("BEGIN Parse input file %s")%(inputFile))
    try:
      self.parseVariables()
    except Exception, err:
      error(_("Error while reading request file"), err)
      sys.exit(1)
      
    debug(_("END   Parse input file %s")%(inputFile))
    
    # Generate command(s)
    ##################
    debug(_("BEGIN Generate command"))
    try:
      self.generateCommand()
    except Exception, err:
      error(_("Error while generating command : %s")%(str(err)), err)
      sys.exit(1)
      
    debug(_("END   Generate command"))
    
    # Execute command(s)
    ##################
    debug(_("BEGIN Execute command"))
    try:
      self.executeCommand(outputFile)
    except Exception, err:
      error(_("Error while executing command : %s")%(str(err)), err)
      sys.exit(1)
      
    debug(_("END   Execute command"))

    # Execute optional plugins
    ##################
    if (plugins):
      debug(_("BEGIN Execute plugin"))
      try:
        runPlugins(plugins, outputFile)
      except Exception, err:
        error (_("Error while running plugins : %s")%(str(err)))
        sys.exit(1)
        
      debug(_("END   Execute plugin"))





  """
  Parse variables from xmlTree and generate dictionary,
  like self.mandatoryVariables[varTAG] = value
  
  @input  mandatoryTAG  List of expected mandatory XML TAG
  @input  optionalTAG   List of expected optional XML TAG
  @output self.mandatoryVariables
  @output self.optionalVariables
  """
  def parseVariables(self, mandatoryTAG, optionalTAG):
    
    variablesTree = self.xmlTree.find(XMLTAG_VARIABLES)
    
    # Convert all key words (ie. __NOW___ -> 20090801155400)
    #############
    try:
      self._parseVariableKeywords(variablesTree)
    except Exception, msg:
      error(_("Error while parsing keyword") )
      sys.exit(2)

    # Parse mandatory variables
    ##############   
    for varTAG in mandatoryTAG:
      try:
        self._parseVariables(variablesTree, varTAG, self.mandatoryVariables)
      except Exception, msg:
        error( (_("No mandatory variable %s ")%(str(msg)) ) )
        sys.exit(2)

    # Muchtar: function to check the default, between latlon and domain, keep latlon as default
    # But, if the latlon available as an argument, forget about the domain
    cnt_var_found = 0
    for varTAG in optionalTAG:
      try:
        var_found = variablesTree.find(varTAG.lower())
        if var_found != None:
          if varTAG == 'domain':
            cnt_var_found -= 1
          else:
            cnt_var_found += 1
      except Exception, msg:
        info(_("Something error %s ")%(str(msg)) )

    if (cnt_var_found == 3) or (LATLON_OR_DOMAIN == 0): # 3 means, there are domain and latlon
      optionalTAG.remove('domain')
    
    # Parse optional variables
    ##############
    for varTAG in optionalTAG:
      try:
        self._parseVariables(variablesTree, varTAG, self.optionalVariables)
      except Exception, msg:
        info( (_("No optional variable %s ")%(str(msg)) ) )

    # Add information for logging facilities
    ##############
    try:
      #self.mandatoryVariables['user'] = os.getlogin()
      self.mandatoryVariables['user'] = os.getenv("USER")
    except:
      pass
    try:
      # Add (wis) username possibly stored in the xml file
      self.mandatoryVariables['user'] += "-"+str(self.xmlTree.find(XMLTAG_USER).text)
    except:
      pass

  
  """
  Convert all keywords with current timestamp
  using DateKeyword class
  
  @in   variableTree              The ElementTree object of all variables
  @out  self.mandatoryVariables   Fulfilled with variables
  @out  self.optionalVariables    Fulfilled with variables
  """
  def _parseVariableKeywords(self, variablesTree):
    dateKeyword = DateKeyword()

    if (not variablesTree):
      return
    
    # For each xml variable text
    for elemTree in variablesTree.getiterator():

      # Check if it matches dateKeyword
      if ( dateKeyword.match(elemTree.text) ):

        # And then replace keyword with value
        if (elemTree.text == XMLKEYWORD_LATEST):
          info(_("Keywords detected for %s \t : %s  --> launching get capabilities")%(elemTree.tag, elemTree.text) )
          newText = dateKeyword.getLASTValue(elemTree.tag, variablesTree)

          #info(_("Keyword detected for  %s \t :   %s \t --> \t %s")%(elemTree.tag, elemTree.text, newText))
          elemTree.text = newText
        else:
          if (elemTree.tag == "end"):
            newText = dateKeyword.getValue(elemTree.text, True) 
          else:
            newText = dateKeyword.getValue(elemTree.text)

          if (newText == None):
            error(_("Unable to parse keyword  for  <%s> \t :   %s \t")%(elemTree.tag, elemTree.text))
            raise Exception(_("Unable to parse keyword"))

          info(_("Keyword detected for  <%s> \t :   %s \t --> \t %s")%(elemTree.tag, elemTree.text, newText))
          elemTree.text = newText

  
  """
  When parsing a variables, several case appears :
    - Single option
      <varTAG>option</varTAG>
      
    - Explicit list of options
      <varTAGList>
        <varTAG>option1</varTAG>
        <varTAG>option2</varTAG>
        ...
      </varTAGList>
      
    - Implicit list of options, which need a getCapabilities call
      <varTAGPeriod>
        <begin>__1_DAY_AGO__</begin>
        <end>__NOW__</end>
        <limit>3</limit>
      </varTAGPeriod>
      
  @in     variableTree              The ElementTree object of all variables
  @in     xmlTAG                    The list of tag to parse
  @out    variablesList             The list of variables parsed
  """
  def _parseVariables(self, variablesTree, varTAG, variablesList):
    try:
      self._parseVariableSingle(variablesTree, varTAG, variablesList)
    except AttributeError:
      
      debug(_("No variable %s found, trying %s ")%(varTAG, varTAG+"List" ) )
      try:
        self._parseVariableList(variablesTree, varTAG, variablesList)
      except AttributeError:
        
        debug(_("No variable %s found, trying %s ")%(varTAG+"List", varTAG+"Period" ) )
        try:
          self._parseVariablePeriod(variablesTree, varTAG, variablesList)
        except AttributeError:
          
          debug(_("No variable %s found, no %s at all ! ")%(varTAG+"Period", varTAG ) )
          raise Exception(varTAG)

    debug(_("Variable found: %s \t %s")%(varTAG, variablesList[varTAG]))


  
  """
  Parse a single variable
  Example : <model>GFS</model>
  """
  def _parseVariableSingle(self, variablesTree, varTAG, variablesList):
    global VAR_AVAIL
    variablesList[varTAG] = variablesTree.find(varTAG.lower()).text # Muchtar
    if varTAG == 'outFile': # Muchtar
      #info(_("--- %s | %s ---")%(varTAG.lower(), variablesList[varTAG].replace("/", "%2f"))) # Muchtar
      variablesList[varTAG] = variablesList[varTAG].replace("/", "%2f") # Muchtar
      
  """
  Parse a list of variables
  Example:
    <modelList>
      <model>GFS</model>
      <model>WRF</model>
    </modelList>
  """
  def _parseVariableList(self, variablesTree, varTAG, variablesList):
    varList = variablesTree.find( (varTAG+"List").lower() )

    if ( len( varList.findall(varTAG.lower()) ) >= 1 ):
      variablesList[varTAG] = []
      
    for var in varList.findall(varTAG.lower()):
      variablesList[varTAG] = variablesList[varTAG] + [var.text]

    if (not variablesList[varTAG]):
      raise Exception(varTAG)
      
  """
  Parse a period and generate dates
  
  Example:
    <modelPeriod>
      <begin>20090101000000</begin>   The 2009/01/01 at 00h UTC
        <end>20090101020000</end>     The 2009/01/01 at 02h UTC
       <step>00000000003000</step>    Step of 30minutes
    </modelPeriod>
    
  ---> Will generate
    20090101000000
    20090101003000
    20090101010000
    20090101013000
    20090101020000
    
  """
  def _parseVariablePeriod(self, variablesTree, varTAG, variablesList):   
    varPeriod = variablesTree.find( (varTAG+"Period").lower() )

    begin = varPeriod.find(XMLTAG_PERIOD_BEGIN.lower()).text
    end   = varPeriod.find(XMLTAG_PERIOD_END.lower()).text
    step  = varPeriod.find(XMLTAG_PERIOD_STEP.lower()).text
    
    # Generate timestamp list
    ##############
    debug(_("Generate dates for %s from %s to %s (step %s)")%(varTAG, begin, end, step))

    try:
      dateBegin = ParseStringToDate(begin)
      dateEnd   = ParseStringToDate(end)
      timedelta = ParseStringToTimedelta(step)
      
      variablesList[varTAG] = []
    except Exception, err:
      error(str(err))
      sys.exit(2)
  
    date = dateBegin
    while (date <= dateEnd): 
      variablesList[varTAG].append(date.strftime("%Y%m%d%H%M%S"))
      date = date + timedelta


  """
  Generate command line regarding the request mode
  """
  def generateCommand(self):
    if (self.mode == CONFIG_REMOTEURL):
      self._generateRemoteURL()
      self._encapsulateCommandWithWget()
    elif (self.mode == CONFIG_REMOTESSH):
      self._generateScriptCommand()
      self.command = self.command + " --mode ssh"
      self._encapsulateCommandWithSSH()
    elif (self.mode == CONFIG_SOCKETPIPE):
      self._generateScriptCommand()
      self.command = self.command + " --mode socketpipe"
      self._encapsulateCommandWithSocketPipe()
    else:
      error(_("Mode not implemented : %s")%(self.mode))

  """
  Muchtar: Add some additional variables, special for boundary
  """
  def addVars(self, variables):
    #info(_("--- addVars %s ---")%(variables))
    self.additionalVariables = variables
    #info(_("--- addVars %s ---")%(self.additionalVariables))

  """
  URL-like : key=value&key=value&...
  """ 
  def _generateRemoteURL(self):
    #info(_("--- GENERATE REMOTE URL ---"))
    urlArgs = ""
    for key, value in self.mandatoryVariables.iteritems():

      if type(value).__name__ == 'list':
        v = ''
        for i in value:
          v = v + i + "-"
        value = v[:-1]
        
      urlArgs = urlArgs + "&"+str(key)+"="+str(value)
                  
      
    for key, value in self.optionalVariables.iteritems():
      if type(value).__name__ == 'list':
        v = ''
        for i in value:
          v = v + i + "-"
        value = v[:-1]
        
      urlArgs = urlArgs + "&"+str(key)+"="+str(value) 

    if(len(self.additionalVariables) > 0):
        #info(_("--- additional vars: %s ---") % (self.additionalVariables))
        for key, value in self.additionalVariables.iteritems():
          urlArgs = urlArgs + "&" + str(key) + "=" + str(value)
    #else:
    #    info(_("--- no additional vars ---"))
      
    self.remoteURL = self.remoteURL + urlArgs
    self.command   = self.command +" "+ self.remoteURL
    #info(_("--- additional vars: %s ---") % (self.remoteURL))
        
  """
  Script-like : --key1 value1 --key2 value2 
  """    
  def _generateScriptCommand(self):
    for key, value in self.mandatoryVariables.iteritems():

      if type(value).__name__ == 'list':
        v = ''
        for i in value:
          v = v + i + "-"
        value = v[:-1]
        
      self.command = self.command + " --"+str(key)+" "+str(value)
      
    for key, value in self.optionalVariables.iteritems():
      if type(value).__name__ == 'list':
        v = ''
        for i in value:
          v = v + i + "-"
        value = v[:-1]
        
      self.command = self.command + " --"+str(key)+" "+str(value)     
      
   
   
   
   
  def _encapsulateCommandWithSSH(self):
    self.command = ("ssh %s@%s %s")%(CIPS_REMOTE_LOGIN, CIPS_REMOTE_IP, self.command)
    
  def _encapsulateCommandWithSocketPipe(self):
    self.command = ("socketpipe -b -l { ssh %s@%s } -r { %s } -o { cat }")%(CIPS_REMOTE_LOGIN, CIPS_REMOTE_IP, self.command)

  def _encapsulateCommandWithWget(self):
    self.command = ("wget --timeout=600 \"%s\"")%(self.remoteURL)
    

  """
  The point is:
    - the user specified argument
        --output myoutput.ext
    - there is the need for multiple output files,
      all outputs cannot be concatenated (eg. images files)
      
  We'll generate files like
      myoutput0001.ext
      myoutput0002.ext
      myoutput0003.ext
  """
  def _generateUserMultipleOutputFile(self, templateOutputFile, index, maxIndex):
    import string
    
    if (maxIndex != 1):
      t = string.split(templateOutputFile, '.')
      number = "%04d" % (index)
      return templateOutputFile[:-len(t[-1])] + number + "." + t[-1]
    else:
      return templateOutputFile
    
    
    
  def _checkOutputFile(self):
    outputFile = None
    if (self.outputFile):
      outputFile = self.outputFile
    if (outputFile):
      try:
        import os
        if (os.path.isfile(outputFile)):
          os.remove(outputFile)
        f = open(outputFile, "w")
        f.close()
      except Exception, err:
        raise Exception( _("Outputfile %s not valid: %s")%(outputFile, str(err)) )
      
      try:
        os.remove(outputFile)
      except Exception, err:
        pass


  """
  Execute command regarding request mode
  """
  def executeCommand(self, outputFile=None, append=False):
    if (outputFile != None):
      self.outputFile = outputFile
    
    # Check if we need to create a new file
    # or if we append data to that file
    if (not append):
      self._checkOutputFile()

    if (self.mode == CONFIG_REMOTEURL):
      self._executeRemoteURL()
    elif (self.mode == CONFIG_REMOTESSH):
      self._executeRemoteSSH()
    elif (self.mode == CONFIG_SOCKETPIPE):
      self._executeSocketPipe()
    else:
      error(_("Mode not implemented : %s")%(self.mode))
 
  """
  Execute a remote ssh command
  """  
  def _executeRemoteSSH(self):
    #subProcess = launchSubProcess(self.command, self.outputFile)
    if (self.outputFile == OUTPUT_CHAR):
      # Redirect to standard output
      self.command = self.command
    elif (not self.outputFile):
      # Redirect to standard output
      self.command = self.command
    else:
      self.command = self.command + " >> " + self.outputFile

    subProcess = launchSubProcess(self.command)
        
 
  """
  Execute a remote socket pipe
  """  
  def _executeSocketPipe(self):
    #subProcess = launchSubProcess(self.command, self.outputFile)
    if (self.outputFile == OUTPUT_CHAR):
      # Redirect to standard output
      self.command = self.command
    elif (not self.outputFile):
      # Redirect to standard output
      self.command = self.command
    else:
      self.command = self.command + " >> " + self.outputFile
    subProcess = launchSubProcess(self.command)

 
  """
  Get data from a remote URL
  """    
  def _executeRemoteURL(self):    
    cmd = self.command
    if (not _verbose):
      cmd += " --quiet"
    else:
      #cmd += " -nv"
      cmd += " --quiet" # quand meme :)

    if (self.outputFile == OUTPUT_CHAR):
      # Redirect to standard output
      cmd += " -O -"
    elif (not self.outputFile):
      # Redirect to standard output
      cmd += " -O -"
    else:
      cmd += " -O - >> "+self.outputFile

    launchSubProcess(cmd)


    
"""
Define a generic getCapabilities request
"""
class GetCapabilites(Request):
  
  def __init__(self, xmlTree):
    self.mode = CONFIG_MODE_GETCAPABILITIES

    Request.__init__(self, xmlTree)

  def parseVariables(self, mandatoryTAG, optionalTAG):
    try:
      self.mandatoryVariables[XMLTAG_REQUEST] = self.xmlTree.find(XMLTAG_REQUEST_NAME).text
    except Exception, err:
        error( (_("No mandatory variable %s: "), XMLTAG_REQUEST, str(err) ) )
        sys.exit(2)
      
    try:
      format = self.xmlTree.find(XMLTAG_FORMAT).text
      self.optionalVariables["output"] = format
    except:
      pass
    
    Request.parseVariables(self, mandatoryTAG, optionalTAG)


"""
Define a generic getData request
""" 
class GetData(Request):

  def __init__(self, xmlTree):
    self.mode = CONFIG_MODE_GETDATA
    Request.__init__(self, xmlTree)  

"""
Define a generic ModDB request
"""    
class ModDBRequest(Request):
  def __init__(self, xmlTree):
    Request.__init__(self, xmlTree)

#############################################################################
#                                                                           #
#                        ModDB classes                                      #
#                                                                           #
# Providing facilities for:
#     * ModDBGetCapabilites      : a generic getCapabilities request on ModDB
#     * ModDBlistRun             : a listRun get capabilities
#     * ModDBlistModel           : a listModel get capabilities
#     *
#############################################################################

"""
Define a getData request on ModDB
"""
class ModDBGetData(GetData):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + MODDB_GETDATA_PHP + "?"
    self.command   = MODDB_GETDATA_SCRIPT
    
    GetData.__init__(self, xmlTree)
    
  def parseVariables(self):    
    try:
      format = self.xmlTree.find(XMLTAG_FORMAT).text
      self.optionalVariables[XMLTAG_FORMAT] = format
    except:
      self.optionalVariables[XMLTAG_FORMAT] = "grib"
    
    mandatoryVariables = [XMLTAG_DATERUN, XMLTAG_GRID, XMLTAG_MODEL,
                          XMLTAG_PARAM, XMLTAG_RANGE, XMLTAG_LEVEL]
    optionalVariables = [XMLTAG_SUBGRID, XMLTAG_PREVIEWAREA, XMLTAG_RESOLUTION, 
                          XMLTAG_OUTFILE, XMLTAG_PREVIEWLEGEND] # Muchtar
  
    GetData.parseVariables(self, mandatoryVariables, optionalVariables)

    # Translation of <param> to --paramAlias, only for ModDB
    self.mandatoryVariables[XMLTAG_PARAMALIAS] = self.mandatoryVariables[XMLTAG_PARAM]
    del self.mandatoryVariables[XMLTAG_PARAM]



  def generateCommand(self):
    """
    Cas particuliers:
      * On demande une preview !
      
      * On demande plusieurs dateRun
      * On demande plusieurs model
      * On demande plusieurs grid
      
      --> Il faut faire plusieurs appels a l'extracteur ModDB
    """    
    myMandatoryVariables = copy.deepcopy(self.mandatoryVariables)
    self.originalCommand   = copy.deepcopy(self.command)
    self.originalRemoteURL = copy.deepcopy(self.remoteURL)
    
    if ( type(myMandatoryVariables[XMLTAG_DATERUN]) != types.ListType ):
      myMandatoryVariables[XMLTAG_DATERUN] = [myMandatoryVariables[XMLTAG_DATERUN]]
    if ( type(myMandatoryVariables[XMLTAG_MODEL]) != types.ListType ):
      myMandatoryVariables[XMLTAG_MODEL] = [myMandatoryVariables[XMLTAG_MODEL]]
    if ( type(myMandatoryVariables[XMLTAG_GRID]) != types.ListType ):
      myMandatoryVariables[XMLTAG_GRID] = [myMandatoryVariables[XMLTAG_GRID]]


    for dateRun in myMandatoryVariables[XMLTAG_DATERUN]:
      self.mandatoryVariables[XMLTAG_DATERUN] = dateRun
      
      for model in myMandatoryVariables[XMLTAG_MODEL]:
        self.mandatoryVariables[XMLTAG_MODEL] = model
        
        for grid in myMandatoryVariables[XMLTAG_GRID]:
          self.mandatoryVariables[XMLTAG_GRID] = grid
          
          # There is much more command to generate
          # if preview format is set
          if (self.optionalVariables[XMLTAG_FORMAT] != "png"):
            self._generateCommandForBinaryFormat(dateRun, model, grid)
          else:
            self._generateCommandForPreviewFormat(dateRun, model, grid)


          # Put command prefix again
          self.command   = self.originalCommand
          self.remoteURL = self.originalRemoteURL


   
  def _generateCommandForBinaryFormat(self, dateRun, model, grid):         
    info(_("Generate command for %s : %s on %s")%(dateRun, model, grid) )
    
    # Generate command
    GetData.generateCommand(self)
    
    # Generate default filename for binary data
    date = dateRun[:8]
    run  = dateRun[8:10]
    self.multipleOutputFiles.append(model+"."+grid+"."+date+".Run"+run+"."+self.optionalVariables[XMLTAG_FORMAT])

    # Add it to the list
    self.multipleCommands.append(self.command)
          

  """
  If preview format is requested, then
  one command is needed for each association of
    dateRun / model / grid / range / param / level
    
  TODO: go get the full list of range / param / level ...
  """
  def _generateCommandForPreviewFormat(self, dateRun, model, grid):
    myMandatoryVariables = copy.deepcopy(self.mandatoryVariables)
    

    print self.mandatoryVariables

    if ( myMandatoryVariables[XMLTAG_RANGE] == "ALL" ):
      myMandatoryVariables[XMLTAG_RANGE] = self._generateRangeList(model, grid, dateRun[:8], dateRun[8:10])
    if ( myMandatoryVariables[XMLTAG_PARAMALIAS] == "ALL" ):
      myMandatoryVariables[XMLTAG_PARAMALIAS] = self._generateParamList(model, grid, dateRun[:8], dateRun[8:10])
    if ( myMandatoryVariables[XMLTAG_LEVEL] == "ALL" ):
      myMandatoryVariables[XMLTAG_LEVEL] = self._generateLevelList(model, grid, dateRun[:8], dateRun[8:10])

    # We can only generate preview for explicit 
    # range / param / level association
    if ( type(myMandatoryVariables[XMLTAG_RANGE]) != types.ListType ):
      myMandatoryVariables[XMLTAG_RANGE] = [myMandatoryVariables[XMLTAG_RANGE]]
    if ( type(myMandatoryVariables[XMLTAG_PARAMALIAS]) != types.ListType ):
      myMandatoryVariables[XMLTAG_PARAMALIAS] = [myMandatoryVariables[XMLTAG_PARAMALIAS]]
    if ( type(myMandatoryVariables[XMLTAG_LEVEL]) != types.ListType ):
      myMandatoryVariables[XMLTAG_LEVEL] = [myMandatoryVariables[XMLTAG_LEVEL]]    
      

    for range in myMandatoryVariables[XMLTAG_RANGE]:
      self.mandatoryVariables[XMLTAG_RANGE] = range
      
      for param in myMandatoryVariables[XMLTAG_PARAMALIAS]:
        self.mandatoryVariables[XMLTAG_PARAMALIAS] = param
        
        for level in myMandatoryVariables[XMLTAG_LEVEL]:
          self.mandatoryVariables[XMLTAG_LEVEL] = level
          
          info(_("Generate command for %s : %s  %s  %s  %s  %s")%(dateRun, model, grid, range, param, level) )

          #if ( (range == "ALL") or (param == "ALL") or (level == "ALL") ):
          #  error(_("ALL is not allowed.\nPlease specify explicit range, parameter and level for multiple preview outputs"))
          #  sys.exit(1)
            
          # Generate command
          GetData.generateCommand(self)
          
          # Generate default filename for preview
          filename = self._generateFilename(model, grid, dateRun[:8], dateRun[8:10], range, param, level, self.optionalVariables[XMLTAG_FORMAT])
          self.multipleOutputFiles.append(filename)

          # Add it to the list
          self.multipleCommands.append(self.command)
          
          # Put original back
          self.command   = self.originalCommand
          self.remoteURL = self.originalRemoteURL

    # Put original back
    self.mandatoryVariables = myMandatoryVariables

 
  """
  Use ModDBlistRange() to obtains range
  """
  def _generateRangeList(self, model, grid, date, run):
    (fd, TEMP_FILE) = mkstemp()

    myRequest = ModDBlistRange(None)
    myRequest.mandatoryVariables[XMLTAG_REQUEST] = "listRange"
    myRequest.mandatoryVariables[XMLTAG_FORMAT]  = "raw"
    
    myRequest.mandatoryVariables[XMLTAG_MODEL]    = model
    myRequest.mandatoryVariables[XMLTAG_GRID]     = grid
    myRequest.mandatoryVariables[XMLTAG_DATERUN]  = date+run
    
    try:
      myRequest.generateCommand()
      myRequest.executeCommand(TEMP_FILE)
      r = ""
      f = open(TEMP_FILE,"r")
      
      for line in f:
        return line.split()

    except:
      raise Exception(_("Unable to launch get capabilities for <range>ALL</range>"))
  
  """
  Use ModDBlistParam() to obtains param
  """
  def _generateParamList(self, model, grid, date, run):
    (fd, TEMP_FILE) = mkstemp()

    myRequest = ModDBlistParam(None)
    myRequest.mandatoryVariables[XMLTAG_REQUEST] = "listRange"
    myRequest.mandatoryVariables[XMLTAG_FORMAT]  = "raw"
    
    myRequest.mandatoryVariables[XMLTAG_MODEL]    = model
    myRequest.mandatoryVariables[XMLTAG_GRID]     = grid
    myRequest.mandatoryVariables[XMLTAG_DATERUN]  = date+run
    
    try:
      myRequest.generateCommand()
      myRequest.executeCommand(TEMP_FILE)
      r = ""
      f = open(TEMP_FILE,"r")
      
      for line in f:
        return line.split()

    except:
      raise Exception(_("Unable to launch get capabilities for <param>ALL</param>"))
  
  """
  Use ModDBlistLevel() to obtains level
  """
  def _generateLevelList(self, model, grid, date, run):
    (fd, TEMP_FILE) = mkstemp()

    myRequest = ModDBlistLevel(None)
    myRequest.mandatoryVariables[XMLTAG_REQUEST] = "listLevel"
    myRequest.mandatoryVariables[XMLTAG_FORMAT]  = "raw"
    
    myRequest.mandatoryVariables[XMLTAG_MODEL]    = model
    myRequest.mandatoryVariables[XMLTAG_GRID]     = grid
    myRequest.mandatoryVariables[XMLTAG_DATERUN]  = date+run
    
    try:
      myRequest.generateCommand()
      myRequest.executeCommand(TEMP_FILE)
      r = ""
      f = open(TEMP_FILE,"r")
      
      t = []
      for line in f:
        l = line.strip()
        p = l.split(",")
        t.append(p[1] + p[2])
        #return line.split()

      return t
      
    except:
      raise Exception(_("Unable to launch get capabilities for <level>ALL</level>"))
  
  
  
 
 
  def _generateFilename(self, model, grid, date, run, range, param, level, format):
     return model+"."+grid+"."+date+".Run"+run+"."+range+"."+param+"."+level+"."+format
   
   
   
      
  def executeCommand(self, outputFile):
    self.outputFile = outputFile
    self._checkOutputFile()
    
    # We might need several calls
    ##################
    append = False
    nbCommand = 1
    for command  in self.multipleCommands:
      defaultOutputFile = self.multipleOutputFiles[self.multipleCommands.index(command)]

      # Handle filenaming issues
      ##################
      if (outputFile):

        if (self.optionalVariables[XMLTAG_FORMAT] == "png"):
          # Outputfile is specified and format is preview
          #    -> We generate userfilename.[digit].png
          ##################
          currentOutputFile = self._generateUserMultipleOutputFile(outputFile, nbCommand, len(self.multipleCommands))
          nbCommand = nbCommand + 1  
        else:
          # Outputfile is specified and format is not preview
          #    -> We put all binary data in user's file
          ##################
          currentOutputFile = outputFile
          append = True
          
      else:
        # Else, use default good looking filename
        ##################
        currentOutputFile = defaultOutputFile

      # Execute each command with appropriate outputFile
      ##################
      self.command = command
      GetData.executeCommand(self, currentOutputFile, append)



"""
Define a generic getCapabilities request on ModDB
"""  
class ModDBGetCapabilites(GetCapabilites):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + MODDB_GETCAPABILITES_FILE + "?"
    self.command = CIPS_PHP + CIPS_REMOTE_PHPPATH + "/" + MODDB_GETCAPABILITES_FILE

    GetCapabilites.__init__(self, xmlTree)

class ModDBlistModel(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATERUNBEGIN, XMLTAG_DATERUNEND]
    optionalVariables = [XMLTAG_DATERUN, XMLTAG_GRID]
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ModDBlistGrid(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATERUNBEGIN, XMLTAG_DATERUNEND]
    optionalVariables = [XMLTAG_DATERUN, XMLTAG_MODEL]
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
 
class ModDBlistRun(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATERUNBEGIN, XMLTAG_DATERUNEND,
                          XMLTAG_GRID, XMLTAG_MODEL]
    optionalVariables = []
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ModDBlistLatestRun(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
    
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_GRID, XMLTAG_MODEL]
    optionalVariables = []
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
    
class ModDBlistRange(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATERUN, XMLTAG_MODEL, XMLTAG_GRID]
    optionalVariables = [XMLTAG_PARAM, XMLTAG_LEVEL]
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ModDBlistLevel(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATERUN, XMLTAG_MODEL, XMLTAG_GRID]
    optionalVariables = [XMLTAG_PARAM, XMLTAG_RANGE]
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ModDBlistParam(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATERUN, XMLTAG_MODEL, XMLTAG_GRID]
    optionalVariables = [XMLTAG_LEVEL, XMLTAG_RANGE]
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ModDBlistArea(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = []
    optionalVariables = []
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ModDBListSubGrid(ModDBGetCapabilites):
  def __init__(self, xmlTree):
    ModDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = []
    optionalVariables = []
    
    ModDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
 

 #############################################################################
#                                                                           #
#                        ImgDB classes                                      #
#                                                                           #
# Providing facilities for:
#     * ImgDBGetCapabilites      : a generic getCapabilities request on ImgDB
#     *
#     * ImgDBGetData
#############################################################################
"""
Define a getData request on ImgDB
"""
class ImgDBGetData(GetData):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + IMGDB_GETDATA_PHP + "?"
    self.command   = IMGDB_GETDATA_SCRIPT
    
    GetData.__init__(self, xmlTree)
    
  def parseVariables(self):    
    try:
      format = self.xmlTree.find(XMLTAG_FORMAT).text
      self.optionalVariables[XMLTAG_FORMAT] = format
    except:
      self.optionalVariables[XMLTAG_FORMAT] = "tiff"
  
    mandatoryVariables = [XMLTAG_TIMESTAMP, XMLTAG_PRODUCT, XMLTAG_DOMAIN,
                          XMLTAG_PARAM]
    optionalVariables = [XMLTAG_SUBDOMAIN, XMLTAG_PREVIEWAREA]
  
    GetData.parseVariables(self, mandatoryVariables, optionalVariables)




  def generateCommand(self):
    """
    Cas particuliers:
      * On demande plusieurs timeStamp
      * On demande plusieurs product
      * On demande plusieurs domain
      * On demande plusieurs param
      
      --> Il faut faire plusieurs appels a l'extracteur ImgDB
      --> On doit generer un fichier pour chaque image
    """
    import copy, types
    
    myMandatoryVariables = copy.deepcopy(self.mandatoryVariables)
    myCommand = copy.deepcopy(self.command)
    myRemoteURL = copy.deepcopy(self.remoteURL)
        
    for id in [XMLTAG_TIMESTAMP, XMLTAG_PRODUCT, XMLTAG_DOMAIN, XMLTAG_PARAM]:
      if ( type(myMandatoryVariables[id]) != types.ListType ):
       myMandatoryVariables[id] = [myMandatoryVariables[id]]

    for timeStamp in myMandatoryVariables[XMLTAG_TIMESTAMP]:
      self.mandatoryVariables[XMLTAG_TIMESTAMP] = timeStamp
      
      for product in myMandatoryVariables[XMLTAG_PRODUCT]:
        self.mandatoryVariables[XMLTAG_PRODUCT] = product
        
        for domain in myMandatoryVariables[XMLTAG_DOMAIN]:
          self.mandatoryVariables[XMLTAG_DOMAIN] = domain
          
          for param in myMandatoryVariables[XMLTAG_PARAM]:
            self.mandatoryVariables[XMLTAG_PARAM] = param
          
            # Test if data is present before generating the command
            #################################
            # FIX / TODO, how ?
            
            
            # Generate and execute download command
            #################################
            info(_("Generate command for %s : %s - %s - %s")%(timeStamp, product, domain, param) )
            
            # Generate command
            GetData.generateCommand(self)
            
            # Generate default filename
            self.multipleOutputFiles.append(str(product)+"."+str(domain)+"."+str(param)+"."+str(timeStamp)+"."+str(self.optionalVariables[XMLTAG_FORMAT]))

            # Add it to the list
            self.multipleCommands.append(self.command)

            # Put command prefix again
            self.command   = myCommand
            self.remoteURL = myRemoteURL



  def executeCommand(self, userOutputFile):
    # We might need several calls
    ##################  
    nbCommand = 1
    for command  in self.multipleCommands:
      defaultOutputFile = self.multipleOutputFiles[self.multipleCommands.index(command)]

      # Handle filenaming issues
      ##################
      if (outputFile):
        # If the user specified an outputfile, use it with digits suffix
        ##################
        currentOutputFile = self._generateUserMultipleOutputFile(outputFile, nbCommand, len(self.multipleCommands))
        nbCommand = nbCommand + 1  
      else:
        # Else, use default good looking filename
        ##################
        currentOutputFile = defaultOutputFile

      # Execute each command with appropriate outputFile
      ##################
      self.command = command
      GetData.executeCommand(self, currentOutputFile)

      # Temporary FIX: delete file if size is null
      ###################
      try:
        size = os.path.getsize(currentOutputFile)
        if not (size > 0):
          info(_("No data available for %s")%(currentOutputFile) )
          os.remove(currentOutputFile)
      except:
        pass
      
      

"""
Define a generic getCapabilities request on ImgDB
"""  
class ImgDBGetCapabilites(GetCapabilites):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + IMGDB_GETCAPABILITES_FILE + "?"
    self.command = CIPS_PHP + CIPS_REMOTE_PHPPATH + "/" + IMGDB_GETCAPABILITES_FILE

    GetCapabilites.__init__(self, xmlTree)


class ImgDBlistProd(ImgDBGetCapabilites):
  def __init__(self, xmlTree):
    ImgDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = [XMLTAG_DOMAIN, XMLTAG_PARAM]
    
    ImgDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
    

class ImgDBlistDomain(ImgDBGetCapabilites):
  def __init__(self, xmlTree):
    ImgDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = [XMLTAG_PRODUCT, XMLTAG_PARAM]
    
    ImgDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)


class ImgDBlistParam(ImgDBGetCapabilites):
  def __init__(self, xmlTree):
    ImgDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = [XMLTAG_DOMAIN, XMLTAG_PRODUCT]
    
    ImgDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)


class ImgDBlistTimeStamp(ImgDBGetCapabilites):
  def __init__(self, xmlTree):
    ImgDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND, XMLTAG_DOMAIN, XMLTAG_PRODUCT, XMLTAG_PARAM]
    optionalVariables = []
    
    ImgDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ImgDBlistLatestTimestamp(ImgDBGetCapabilites):
  def __init__(self, xmlTree):
    ImgDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_PRODUCT, XMLTAG_DOMAIN, XMLTAG_PARAM]
    optionalVariables = []
    
    ImgDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)



#############################################################################
#                                                                           #
#                        ObsDB classes                                      #
#                                                                           #
# Providing facilities for:
#     * ObsDBGetCapabilites      : a generic getCapabilities request on ObsDB
#     *
#     * ObsDBGetData
#############################################################################
"""
Define a getData request on ObsDB
"""
class ObsDBGetData(GetData):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + OBSDB_GETDATA_PHP + "?"
    self.command   = OBSDB_GETDATA_SCRIPT
    
    GetData.__init__(self, xmlTree)
    
  def parseVariables(self):    
    try:
      format = self.xmlTree.find(XMLTAG_FORMAT).text
      self.optionalVariables["format"] = format

    except:
      pass
    
    mandatoryVariables = [XMLTAG_DATEREF, XMLTAG_TIMEDEPTH, XMLTAG_OBSTYPE]

    optionalVariables = [XMLTAG_DOMAIN, XMLTAG_PREVIEWAREA, XMLTAG_STATION,
                         XMLTAG_LEVEL, XMLTAG_PARAM, 
                         XMLTAG_MINLAT, XMLTAG_MAXLAT, XMLTAG_MINLON, XMLTAG_MAXLON] # Muchtar
  
    GetData.parseVariables(self, mandatoryVariables, optionalVariables)


  def generateCommand(self):
    """
    Cas particuliers:
      * On demande une preview !
      
      --> Il faut faire plusieurs appels a l'extracteur ObsDB
    """ 
    myMandatoryVariables = copy.deepcopy(self.mandatoryVariables)
    self.originalCommand   = copy.deepcopy(self.command)
    self.originalRemoteURL = copy.deepcopy(self.remoteURL)

    #info(_("--- Generate command ---")) # Muchtar
    #info(_("--- minLat %s ---") % (ARG_MINLAT))
    #info(_("--- maxLat %s ---") % (ARG_MAXLAT))
    #info(_("--- minLon %s ---") % (ARG_MINLON))
    #info(_("--- maxLon %s ---") % (ARG_MAXLON))
    latlonVariables = dict(zip(['minLat','maxLat','minLon','maxLon'],[ARG_MINLAT,ARG_MAXLAT,ARG_MINLON,ARG_MAXLON]))
    info(_("--- new vars: %s ---") % (latlonVariables))
    
    if ( type(myMandatoryVariables[XMLTAG_OBSTYPE]) != types.ListType ):
      myMandatoryVariables[XMLTAG_OBSTYPE] = [myMandatoryVariables[XMLTAG_OBSTYPE]]


    for obsType in myMandatoryVariables[XMLTAG_OBSTYPE]:
      self.mandatoryVariables[XMLTAG_OBSTYPE] = obsType
      
      dateRef    = self.mandatoryVariables[XMLTAG_DATEREF]
      timeDepth  = self.mandatoryVariables[XMLTAG_TIMEDEPTH]
            
      info(_("Generate command for %s : %s -- last %s")%(obsType, dateRef, timeDepth) )
      
      # Generate command
      if LATLON_OR_DOMAIN == 0: # Muchtar
        GetData.addVars(self, latlonVariables) # Muchtar
      GetData.generateCommand(self)
      
      # Generate default filename
      filename = self._generateFilename(obsType, dateRef, timeDepth, self.optionalVariables[XMLTAG_FORMAT])
      self.multipleOutputFiles.append(filename)

      # Add it to the list
      self.multipleCommands.append(self.command)
      GetData.generateCommand(self)
    
      # Put command prefix again
      self.command   = self.originalCommand
      self.remoteURL = self.originalRemoteURL



 
  def _generateFilename(self, obsType, dateRef, timeDepth, format):
     return obsType+"."+dateRef+"."+timeDepth+"."+format
   


  def executeCommand(self, outputFile):
    self.outputFile = outputFile
    self._checkOutputFile()
    
    # We might need several calls
    ##################
    append = False
    nbCommand = 1
    for command  in self.multipleCommands:
      defaultOutputFile = self.multipleOutputFiles[self.multipleCommands.index(command)]

      # Handle filenaming issues
      ##################
      if (outputFile):

        if (self.optionalVariables[XMLTAG_FORMAT] == "png"):
          # Outputfile is specified and format is preview
          #    -> We generate userfilename.[digit].png
          ##################
          currentOutputFile = self._generateUserMultipleOutputFile(outputFile, nbCommand, len(self.multipleCommands))
          nbCommand = nbCommand + 1  
        else:
          # Outputfile is specified and format is not preview
          #    -> We put all binary data in user's file
          ##################
          currentOutputFile = outputFile
          append = True
          
      else:
        # Else, use default good looking filename
        ##################
        currentOutputFile = defaultOutputFile

      # Execute each command with appropriate outputFile
      ##################
      self.command = command
      GetData.executeCommand(self, currentOutputFile, append)



"""
Define a generic getCapabilities request on ObsDB
"""  
class ObsDBGetCapabilites(GetCapabilites):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + OBSDB_GETCAPABILITES_FILE + "?"
    self.command = CIPS_PHP + CIPS_REMOTE_PHPPATH + "/" + OBSDB_GETCAPABILITES_FILE

    GetCapabilites.__init__(self, xmlTree)


class ObsDBlistObsType(ObsDBGetCapabilites):
  def __init__(self, xmlTree):
    ObsDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEREF]
    optionalVariables = [XMLTAG_DOMAIN, XMLTAG_TIMEDEPTH, XMLTAG_DATEBEGIN]
    
    ObsDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)


class ObsDBlistStation(ObsDBGetCapabilites):
  def __init__(self, xmlTree):
    ObsDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_OBSTYPE, XMLTAG_TIMEDEPTH, XMLTAG_DATEREF]
    optionalVariables = [XMLTAG_DOMAIN]
    
    ObsDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class ObsDBlistDomain(ObsDBGetCapabilites):
  def __init__(self, xmlTree):
    ObsDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = []
    optionalVariables = []
    
    ObsDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)




#############################################################################
#                                                                           #
#                        PrdDB classes                                      #
#                                                                           #
# Providing facilities for:
#     * PrdDBGetCapabilites      : a generic getCapabilities request on PrdDB
#     *
#     * PrdDBGetData
#############################################################################
"""
Define a getData request on PrdDB
"""
class PrdDBGetData(GetData):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + PRDDB_GETDATA_PHP + "?"
    self.command   = PRDDB_GETDATA_SCRIPT
    
    GetData.__init__(self, xmlTree)
    
  def parseVariables(self):    
    try:
      format = self.xmlTree.find(XMLTAG_FORMAT).text
      self.optionalVariables["format"] = format
    except:
      pass
    
    mandatoryVariables = [XMLTAG_DATE, XMLTAG_KEY1, XMLTAG_KEY2, XMLTAG_KEY3]
    optionalVariables = [XMLTAG_FILTER, XMLTAG_OUTFILE]
  
    GetData.parseVariables(self, mandatoryVariables, optionalVariables)


  def generateCommand(self):
    """
    Cas particuliers:
      * TODO: On demande plusieur fichiers
    """       
    
    key1 = self.mandatoryVariables[XMLTAG_KEY1]
    key2 = self.mandatoryVariables[XMLTAG_KEY2]
    key3 = self.mandatoryVariables[XMLTAG_KEY3]
    
    info(_("Generate command for : %s \t %s \t %s")%(key1, key2, key3) )

    # Generate command
    GetData.generateCommand(self)
          
    # Generate default filename
    filename = self._generateFilename(key1, key2, key3, self.optionalVariables[XMLTAG_FORMAT])
    self.multipleOutputFiles.append(filename)

    # Add it to the list
    self.multipleCommands.append(self.command)


  def _generateFilename(self, key1, key2, key3, format):
     return key1+"."+key2+"."+key3+"."+format
   


  def executeCommand(self, outputFile):
    self.outputFile = outputFile
    self._checkOutputFile()
    
    # We might need several calls
    ##################
    append = False
    nbCommand = 1
    for command  in self.multipleCommands:
      defaultOutputFile = self.multipleOutputFiles[self.multipleCommands.index(command)]

      # Handle filenaming issues
      ##################
      if (outputFile):

        if (self.optionalVariables[XMLTAG_FORMAT] == "png"):
          # Outputfile is specified and format is preview
          #    -> We generate userfilename.[digit].png
          ##################
          currentOutputFile = self._generateUserMultipleOutputFile(outputFile, nbCommand, len(self.multipleCommands))
          nbCommand = nbCommand + 1  
        else:
          # Outputfile is specified and format is not preview
          #    -> We put all binary data in user's file
          ##################
          currentOutputFile = outputFile
          append = True
          
      else:
        # Else, use default good looking filename
        ##################
        currentOutputFile = defaultOutputFile

      # Execute each command with appropriate outputFile
      ##################
      self.command = command
      GetData.executeCommand(self, currentOutputFile, append)



"""
Define a generic getCapabilities request on PrdDB
"""  
class PrdDBGetCapabilites(GetCapabilites):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + PRDDB_GETCAPABILITES_FILE + "?"
    self.command = CIPS_PHP + CIPS_REMOTE_PHPPATH + "/" + PRDDB_GETCAPABILITES_FILE

    GetCapabilites.__init__(self, xmlTree)


class PrdDBlistKey1(PrdDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = []
    
    PrdDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class PrdDBlistKey2(PrdDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = [XMLTAG_KEY1]
    
    PrdDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class PrdDBlistKey3(PrdDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = [XMLTAG_KEY1, XMLTAG_KEY2]
    
    PrdDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class PrdDBlistProd(PrdDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEEND, XMLTAG_DATEBEGIN, XMLTAG_KEY1, XMLTAG_KEY2, XMLTAG_KEY3]
    optionalVariables = []
    
    PrdDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)


#############################################################################
#                                                                           #
#                        LrfDB classes                                      #
#                                                                           #
# Providing facilities for:
#     * LrfDBGetCapabilites      : a generic getCapabilities request on LrfDB
#     *
#     * LrfDBGetData
#############################################################################
"""
Define a getData request on LrfDB
"""
class LrfDBGetData(GetData):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + LRFDB_GETDATA_PHP + "?"
    self.command   = LRFDB_GETDATA_SCRIPT
    
    GetData.__init__(self, xmlTree)
    
  def parseVariables(self):    
    try:
      format = self.xmlTree.find(XMLTAG_FORMAT).text
      self.optionalVariables["format"] = format
    except:
      pass
    
    mandatoryVariables = [XMLTAG_DATE, XMLTAG_LRFMODEL, XMLTAG_LRFTYPE, XMLTAG_LRFSUBTYPE]
    optionalVariables = [XMLTAG_FILTER, XMLTAG_OUTFILE]
  
    GetData.parseVariables(self, mandatoryVariables, optionalVariables)


  def generateCommand(self):
    """
    Cas particuliers:
      * TODO: On demande plusieur fichiers
    """       
    
    key1 = self.mandatoryVariables[XMLTAG_LRFMODEL]
    key2 = self.mandatoryVariables[XMLTAG_LRFTYPE]
    key3 = self.mandatoryVariables[XMLTAG_LRFSUBTYPE]
    
    info(_("Generate command for : %s \t %s \t %s")%(key1, key2, key3) )

    # Generate command
    GetData.generateCommand(self)
          
    # Generate default filename
    filename = self._generateFilename(key1, key2, key3, self.optionalVariables[XMLTAG_FORMAT])
    self.multipleOutputFiles.append(filename)

    # Add it to the list
    self.multipleCommands.append(self.command)


  def _generateFilename(self, key1, key2, key3, format):
     return key1+"."+key2+"."+key3+"."+format
   


  def executeCommand(self, outputFile):
    self.outputFile = outputFile
    self._checkOutputFile()
    
    # We might need several calls
    ##################
    append = False
    nbCommand = 1
    for command  in self.multipleCommands:
      defaultOutputFile = self.multipleOutputFiles[self.multipleCommands.index(command)]

      # Handle filenaming issues
      ##################
      if (outputFile):

        if (self.optionalVariables[XMLTAG_FORMAT] == "png"):
          # Outputfile is specified and format is preview
          #    -> We generate userfilename.[digit].png
          ##################
          currentOutputFile = self._generateUserMultipleOutputFile(outputFile, nbCommand, len(self.multipleCommands))
          nbCommand = nbCommand + 1  
        else:
          # Outputfile is specified and format is not preview
          #    -> We put all binary data in user's file
          ##################
          currentOutputFile = outputFile
          append = True
          
      else:
        # Else, use default good looking filename
        ##################
        currentOutputFile = defaultOutputFile

      # Execute each command with appropriate outputFile
      ##################
      self.command = command
      GetData.executeCommand(self, currentOutputFile, append)



"""
Define a generic getCapabilities request on LrfDB
"""  
class LrfDBGetCapabilites(GetCapabilites):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + LRFDB_GETCAPABILITES_FILE + "?"
    self.command = CIPS_PHP + CIPS_REMOTE_PHPPATH + "/" + LRFDB_GETCAPABILITES_FILE

    GetCapabilites.__init__(self, xmlTree)


class LrfDBlistKey1(LrfDBGetCapabilites):
  def __init__(self, xmlTree):
    LrfDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = []
    
    LrfDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class LrfDBlistKey2(LrfDBGetCapabilites):
  def __init__(self, xmlTree):
    LrfDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = [XMLTAG_LRFMODEL]
    
    LrfDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class LrfDBlistKey3(LrfDBGetCapabilites):
  def __init__(self, xmlTree):
    LrfDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEBEGIN, XMLTAG_DATEEND]
    optionalVariables = [XMLTAG_LRFMODEL, XMLTAG_LRFTYPE]
    
    LrfDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)

class LrfDBlistProd(LrfDBGetCapabilites):
  def __init__(self, xmlTree):
    LrfDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_DATEEND, XMLTAG_DATEBEGIN, XMLTAG_LRFMODEL, XMLTAG_LRFTYPE, XMLTAG_LRFSUBTYPE]
    optionalVariables = []
    
    LrfDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)




#############################################################################
#                                                                           #
#                        FctDB classes                                      #
#                                                                           #
# Providing facilities for:
#     * FctDBGetCapabilites      : a generic getCapabilities request on FctDB
#     *
#     * FctDBGetData
#############################################################################
"""
Define a getData request on FctDB
"""
class FctDBGetData(GetData):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + FCTDB_GETDATA_PHP + "?"
    self.command   = FCTDB_GETDATA_SCRIPT
    
    GetData.__init__(self, xmlTree)
    
  def parseVariables(self):    
    try:
      format = self.xmlTree.find(XMLTAG_FORMAT).text
      self.optionalVariables["format"] = format
    except:
      pass
    
    mandatoryVariables = [XMLTAG_FCTTYPE, XMLTAG_DATERUN]
    optionalVariables = [XMLTAG_RANGE, XMLTAG_DOMAIN, XMLTAG_PARAM]
  
    GetData.parseVariables(self, mandatoryVariables, optionalVariables)

  def generateCommand(self):
    """
    Cas particuliers:
      * TODO: On demande plusieur fichiers
    """       
    
    fctType = self.mandatoryVariables[XMLTAG_FCTTYPE]
    dateRun = self.mandatoryVariables[XMLTAG_DATERUN]
    
    info(_("Generate command for : %s \t %s")%(fctType, dateRun) )

    # Generate command
    GetData.generateCommand(self)
          
    # Generate default filename
    filename = self._generateFilename(fctType, dateRun, self.optionalVariables[XMLTAG_FORMAT])
    self.outputFile = filename

  def _generateFilename(self, fctType, dateRun, format):
     return fctType+"."+dateRun+"."+format
   
"""
Define a generic getCapabilities request on FctDB
"""  
class FctDBGetCapabilites(GetCapabilites):
  def __init__(self, xmlTree):
    self.remoteURL = CIPS_REMOTE_WEBSERVICES + "/" + FCTDB_GETCAPABILITES_FILE + "?"
    self.command = CIPS_PHP + CIPS_REMOTE_PHPPATH + "/" + FCTDB_GETCAPABILITES_FILE

    GetCapabilites.__init__(self, xmlTree)

class FctDBlistFctTypes(FctDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = []
    optionalVariables = []
    
    FctDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
    
class FctDBlistRun(FctDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_FCTTYPE]
    optionalVariables = [XMLTAG_DATERUNBEGIN, XMLTAG_DATERUNEND]
    
    FctDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
     
class FctDBlistLatestRun(FctDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_FCTTYPE]
    optionalVariables = [XMLTAG_DATERUNBEGIN, XMLTAG_DATERUNEND]
    
    FctDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
 
class FctDBlistRange(FctDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_FCTTYPE, XMLTAG_DATERUN]
    optionalVariables = []
    
    FctDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
 
class FctDBlistParam(FctDBGetCapabilites):
  def __init__(self, xmlTree):
    PrdDBGetCapabilites.__init__(self, xmlTree)
       
  def parseVariables(self):
    mandatoryVariables = [XMLTAG_FCTTYPE, XMLTAG_DATERUN]
    optionalVariables = []
    
    FctDBGetCapabilites.parseVariables(self, mandatoryVariables, optionalVariables)
    
#############################################################################
#                                                                           #
#                        Plugins                                            #
#                                                                           #
# Exemple de plugin :
#   --plugin 'tar xvf'
# Executera
#   tar xvf outputFile
# 
# On suppose donc qu'un plugin a le comportement suivant:
#   - prend en arguement le fichier de donnee
#   - cree ses propres fichiers ou ecrit sur la sortie standard
# 
############################################################################# 
def runPlugins(pluginName, outputFile):
  # 1. Look for plugin into plugin directory
  # 2. Run it
  command = pluginName + " " + outputFile

  launchSubProcess(command)
  
  # 3. Delete temporary file (useful for tar xvf at least ...)
  launchSubProcess("rm "+outputFile)


#############################################################################
#                                                                           #
#                        Config file                                        #
#                                                                           #
#############################################################################
from UserDict import UserDict 
class KeyInsensitiveDict(UserDict):
    """ User defined Dictionary
    
    Allow upper or lower character when calling instance
    """
    def __init__(self, dict={}):
        UserDict.__init__(self, dict)
    
    
    def __getitem__(self, key):
        key = key.upper()
        return self.data[key]

    def __setitem__(self, key, item):
        key = key.upper()
        UserDict.__setitem__(self, key, item)
        
    def update(self, dict):
        """Copy (key,value) pairs from 'dict'."""
        for k,v in dict.items():
            self[k.upper()] = v


import ConfigParser
class ConfigReader(ConfigParser.SafeConfigParser):
    """ Provide config file reading facilities """
    _configFile = None
    _config = None

    
    def __init__(self):
        ConfigParser.SafeConfigParser.__init__(self)
        self._config = KeyInsensitiveDict()

        
    def parse(self, dataFile):
        """ Parse config file
        
        @return Double dictionary [section][option]
        """
        self._configFile = dataFile
        
        l = self.read(dataFile)

        if self.sections() == []:
            raise IOError(dataFile)
       
        self.readConfig()
        return self._config

    
    def readConfig(self):
        """ Read the configuration file and build a dictionnary """
        for section in self.sections():
            self._config[section.upper()] = KeyInsensitiveDict({})
            for option in self.items(section):
                self._config[section][option[0].upper()] = option[1]
     
    def getParam(self, section, param):
      try:
        return self._config[section][param]
      except:
        return ""
                
    def setGlobals(self):
      global CONFTAG_CIPS, CONFTAG_CIPS_REMOTE_IP, CONFTAG_CIPS_REMOTE_LOGIN, \
              CONFTAG_CIPS_REMOTE_WEB, CONFTAG_CIPS_REMOTE_WEBSERVICES, \
              CONFTAG_CIPS_SOCKETPIPE, CONFTAG_CIPS_PHP, \
              CONFTAG_CIPS_REMOTE_PHPSCRIPT, CONFTAG_CIPS_REMOTE_WEBTIMEOUT
              
      global CIPS_REMOTE_IP, CIPS_REMOTE_LOGIN, CIPS_REMOTE_WEB, \
              CIPS_REMOTE_WEBSERVICES, CIPS_SOCKETPIPE, CIPS_PHP, \
              CIPS_REMOTE_PHPSCRIPT, CIPS_REMOTE_WEBTIMEOUT

      global CONFIG_MODE_GETCAPABILITIES, CONFIG_MODE_GETDATA
      global CONFIG_REMOTEURL, CONFIG_SOCKETPIPE, CONFIG_REMOTESSH
      
      try:
        CIPS_REMOTE_IP          = self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_REMOTE_IP)
        CIPS_REMOTE_LOGIN       = self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_REMOTE_LOGIN)
        CIPS_REMOTE_WEB         = self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_REMOTE_WEB)
        CIPS_REMOTE_WEBSERVICES = self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_REMOTE_WEBSERVICES)
        CIPS_REMOTE_WEBTIMEOUT  = int(self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_REMOTE_WEBTIMEOUT))
        CIPS_SOCKETPIPE         = self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_LOCAL_SOCKETPIPE)
        CIPS_PHP                = self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_PHP)
        CIPS_REMOTE_PHPSCRIPT   = self.getParam(CONFTAG_CIPS,CONFTAG_CIPS_REMOTE_PHPSCRIPT)
        
        mod_getCapa = self.getParam(CONFTAG_CAL,CONFTAG_CAL_MODE_GETCAPABILITES)
        if   (mod_getCapa == "CONFIG_REMOTEURL"):
          CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
        elif (mod_getCapa == "CONFIG_REMOTESSH"):
          CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTESSH
        elif (mod_getCapa == "CONFIG_SOCKETPIPE"):
          CONFIG_MODE_GETCAPABILITIES = CONFIG_SOCKETPIPE
          
        mod_getData = self.getParam(CONFTAG_CAL,CONFTAG_CAL_MODE_GETDATA)
        if   (mod_getData == "CONFIG_REMOTEURL"):
          CONFIG_MODE_GETDATA = CONFIG_REMOTEURL
        elif (mod_getData == "CONFIG_REMOTESSH"):
          CONFIG_MODE_GETDATA = CONFIG_REMOTESSH
        elif (mod_getData == "CONFIG_SOCKETPIPE"):
          CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE
          
        
      except Exception, msg:
        error(str(msg))


#############################################################################
#                                                                           #
#                        Main program                                       #
#                                                                           #
#############################################################################
def usage():
  print ""
  print "Usage : cips_cal.sh [OPTIONS]"
  print "Unified CIPS Access Layer client for get capabilities and get data actions"
  print ""
  print "   -i, --input FILE          Input file describing the request at specified xml format"
  print "   -o, --output FILE         Output file. Standard filename if not specified"
  print "                             Use - for standard output"
  print "                             Put specific folder if you want, e.g: /PATH/TO/FOLDER/FILENAME" # Muchtar
  print ""
  print "   -p, --plugin PLUGIN_NAME  Specify plugin as data post-processor"
  print ""
  print "   --host HOST               Force using speficic CIPS server"
  print "   --mode MODE               Force mode: url, socketpipe"
  print ""
  print "   -v, --verbose             Show verbose information"
  print "   -d, --debug"
  print ""
  print "   --minLat NUMBER           minimum latitude for boundary, NUMBER from -90000 to 90000" # Muchtar
  print "   --maxLat NUMBER           maximum latitude for boundary, NUMBER from -90000 to 90000" # Muchtar
  print "   --minLon NUMBER           minimum longitude for boundary, NUMBER from -180000 to 180000" # Muchtar
  print "   --maxLon NUMBER           maximum longitude for boundary, NUMBER from -180000 to 180000" # Muchtar
  print ""

def error(err, exception=None):
  print _("Error  : ") + str(err)

  if (_debug):
    import traceback
    traceback.print_exc()
    print ""

  if (exception):
    raise Exception(str(err))
  
def debug(err):
  global _debug
  
  if (_debug):
    print _("Debug  : ") + str(err)
  
def info(err):
  global _debug, _verbose
  
  if (_debug or _verbose):
    print _("Info   : ") + str(err)

def launchSubProcess(command):
  """ Launch external command
  """
  #from subprocess import Popen, STDOUT, PIPE
  #return Popen(command, stderr=STDOUT, stdout=PIPE) 
  
  import os
  
  info( (_("Launching: %s ")%(command)))

  os.system(command)
    
    
def main(inputFile, outputFile, plugins):
  xmlTree = None
  
  # Load configuration file
  ##################
  """
  config = ConfigReader()
  config.parse(CONFIG_FILE)
  config.setGlobals()
  """
  
  # Clean outputFile
  ##################
  """
  if (outputFile):
    try:
      import os
      if (os.path.isfile(outputFile)):
        os.remove(outputFile)
      f = open(outputFile, "w")
      f.close()
    except Exception, err:
      error( _("Outputfile %s not valid: %s")%(outputFile, str(err)) )
      sys.exit(1)
  """
  
  # Check XML file
  ##################
  try:
    xmlTree = ET.parse(inputFile);
    
    # Because we want to be case-insensitive,
    # convert all tags in lower-case
    for elem in xmlTree.getiterator():
      elem.tag = (elem.tag).lower()

  except Exception, err:
    error( ( _("XML file %s in not valid: %s")%(inputFile, str(err)) ))
    sys.exit(1)
    
  
  # Determine which type of request
  ##################
  myDatabase = xmlTree.find(XMLTAG_DATABASE).text
  database = upper(myDatabase)
  myRequestType = xmlTree.find(XMLTAG_REQUEST_TYPE).text
  requestType = upper(myRequestType)
  
  if (database not in [upper(CST_MODDB),upper(CST_IMGDB),upper(CST_OBSDB),upper(CST_PRDDB),upper(CST_FCTDB),upper(CST_LRFDB)]):
    error(_("Database %s is not correct")%(myDatabase))
    sys.exit(1)
    
  if (requestType not in [upper(CST_GETCAPABILITIES), upper(CST_GETDATA)]):
    error(_("Request type %s is not correct")%(myRequestType))
    sys.exit(1)
    
    
  # Instance correct request object
  ##################
  #try:
  request = instanceRequest(database, requestType, xmlTree)
  #except:
  #  pass
  
  # Execute the request
  ##################
  try:
    request.execute(inputFile, outputFile, plugins)
  except:
    pass
  
  
    
def instanceRequest(database, requestType, xmlTree=None):
  request = None
  
  try:
    myRequestName = xmlTree.find(XMLTAG_REQUEST_NAME).text
    requestName = upper(myRequestName)
  except:
    pass
    
  if (database == upper(CST_MODDB) ):
    if (requestType == upper(CST_GETCAPABILITIES) ):
      if (requestName == upper(CST_LISTRUN) ):
        request = ModDBlistRun(xmlTree)  
      elif (requestName == upper(CST_LISTMODEL) ):
        request = ModDBlistModel(xmlTree) 
      elif (requestName == upper(CST_LISTGRID) ):
        request = ModDBlistGrid(xmlTree) 
      elif (requestName == upper(CST_LISTLEVEL) ):
        request = ModDBlistLevel(xmlTree)
      elif (requestName == upper(CST_LISTPARAM) ):
        request = ModDBlistParam(xmlTree)
      elif (requestName == upper(CST_LISTAREA) ):
        request = ModDBlistArea(xmlTree)
      elif (requestName == upper(CST_LISTSUBGRID) ):
        request = ModDBListSubGrid(xmlTree)
      elif (requestName == upper(CST_LISTRANGE) ):
        request = ModDBlistRange(xmlTree)
      else:
        error(_("Request name %s is not correct for database %s")%(myRequestName,database))
        sys.exit(1)

    if (requestType == upper(CST_GETDATA) ):
      request = ModDBGetData(xmlTree)
   
   
  elif (database == upper(CST_PRDDB) ):
    if (requestType == upper(CST_GETCAPABILITIES) ):
      if (requestName == upper(CST_LISTKEY1) ):
        request = PrdDBlistKey1(xmlTree)
      elif (requestName == upper(CST_LISTKEY2) ):
        request = PrdDBlistKey2(xmlTree)
      elif (requestName == upper(CST_LISTKEY3) ):
        request = PrdDBlistKey3(xmlTree)
      elif (requestName == upper(CST_LISTPROD) ):
        request = PrdDBlistProd(xmlTree)
      else:
        error(_("Request name %s is not correct for database %s")%(myRequestName,database))
        sys.exit(1)

  elif (database == upper(CST_LRFDB) ):
    if (requestType == upper(CST_GETCAPABILITIES) ):
      if (requestName == upper(CST_LISTLRFMODEL) ):
        request = LrfDBlistKey1(xmlTree)
      elif (requestName == upper(CST_LISTLRFTYPE) ):
        request = LrfDBlistKey2(xmlTree)
      elif (requestName == upper(CST_LISTLRFSUBTYPE) ):
        request = LrfDBlistKey3(xmlTree)
      elif (requestName == upper(CST_LISTPROD) ):
        request = LrfDBlistProd(xmlTree)
      else:
        error(_("Request name %s is not correct for database %s")%(myRequestName,database))
        sys.exit(1)       
    elif (requestType == upper(CST_GETDATA) ):
      request = LrfDBGetData(xmlTree)
  
  
  elif (database == upper(CST_IMGDB) ):
    if (requestType == upper(CST_GETCAPABILITIES) ):
      if (requestName == upper(CST_LISTPROD) ):
        request = ImgDBlistProd(xmlTree)
      elif (requestName == upper(CST_LISTDOMAIN) ):
        request = ImgDBlistDomain(xmlTree)
      elif (requestName == upper(CST_LISTPARAM) ):
        request = ImgDBlistParam(xmlTree)
      elif (requestName == upper(CST_LISTTIMESTAMP) ):
        request = ImgDBlistTimeStamp(xmlTree)
      else:
        error(_("Request name %s is not correct for database %s")%(myRequestName,database))
        sys.exit(1)
        
    elif (requestType == upper(CST_GETDATA) ):
      request = ImgDBGetData(xmlTree)


  elif (database == upper(CST_OBSDB) ):
    if (requestType == upper(CST_GETCAPABILITIES) ):
      if (requestName == upper(CST_LISTOBSTYPE) ):
        request = ObsDBlistObsType(xmlTree)
      elif (requestName == upper(CST_LISTSTATION) ):
        request = ObsDBlistStation(xmlTree)
      elif (requestName == upper(CST_LISTTIMESTAMP) ):
        request = ObsDBlistTimeStamp(xmlTree)
      elif (requestName == upper(CST_LISTPARAM) ):
        request = ObsDBlistParam(xmlTree)
      elif (requestName == upper(CST_LISTDOMAIN) ):
        request = ObsDBlistDomain(xmlTree)
      else:
        error(_("Request name %s is not correct for database %s")%(myRequestName,database))
        sys.exit(1)
        
    elif (requestType == upper(CST_GETDATA) ):
      request = ObsDBGetData(xmlTree)      


  elif (database == upper(CST_FCTDB) ):
    if (requestType == upper(CST_GETCAPABILITIES) ):
      if (requestName == upper(CST_LISTFCTTYPE) ):
        request = FctDBlistFctTypes(xmlTree)
      elif (requestName == upper(CST_LISTRUN) ):
        request = FctDBlistRun(xmlTree)
      elif (requestName == upper(CST_LISTRANGE) ):
        request = FctDBlistRange(xmlTree)
      elif (requestName == upper(CST_LISTPARAM) ):
        request = FctDBlistParam(xmlTree)
      else:
        error(_("Request name %s is not correct for database %s")%(myRequestName,database))
        sys.exit(1)
        
    elif (requestType == upper(CST_GETDATA) ):
      request = FctDBGetData(xmlTree)   
      
      
  return request
    


if __name__ == "__main__":
  import sys, getopt

  inputFile  = ""
  outputFile = ""
  plugins    = ""
  
  gettext.install("cips_cal")
  
  try:
    #opts, args = getopt.getopt(sys.argv[1:], "i:o:p:dv", ["input=", "output=", "plugin=", "debug", "verbose","host=","mode="])
    opts, args = getopt.getopt(sys.argv[1:], "i:o:p:dv", ["input=", "output=", "plugin=", "debug", "verbose","host=","mode=", "minLat=", "maxLat=", "minLon=", "maxLon="])
  except getopt.GetoptError, err:
    error(err)
    usage()
    sys.exit(2)

  for opt, arg in opts:
    if opt in ("-i", "--input"):
      inputFile = arg
    elif opt in ("-o", "--output"):
      outputFile = arg
    elif opt in ("-p", "--plugin"):
      plugins = arg
    elif opt in ("-v", "--verbose"):
      _verbose = 1
    elif opt in ("-d", "--debug"):
      _verbose = 1               
      _debug = 1
    elif opt in ("--host"):
      CIPS_REMOTE_IP = arg
      CIPS_REMOTE_WEB = "http://"+CIPS_REMOTE_IP+"/cips"
      CIPS_REMOTE_WEBSERVICES = CIPS_REMOTE_WEB + "/cal"
    elif opt in ("--mode"):
      if (arg == "url"):
        CONFIG_MODE_GETCAPABILITIES = CONFIG_REMOTEURL
        CONFIG_MODE_GETDATA = CONFIG_REMOTEURL    
      elif (arg == "socketpipe"):
        CONFIG_MODE_GETCAPABILITIES = CONFIG_SOCKETPIPE
        CONFIG_MODE_GETDATA = CONFIG_SOCKETPIPE  
    elif opt in ("--minLat"):
        ARG_MINLAT = arg
        LATLON_OR_DOMAIN = 0
        info(_("using --minLat %s") % (ARG_MINLAT))
    elif opt in ("--maxLat"):
        ARG_MAXLAT = arg
        LATLON_OR_DOMAIN = 0
        info(_("using --maxLat %s") % (ARG_MAXLAT))
    elif opt in ("--minLon"):
        ARG_MINLON = arg
        LATLON_OR_DOMAIN = 0
        info(_("using --minLon %s") % (ARG_MINLON))
    elif opt in ("--maxLon"):
        ARG_MAXLON = arg
        LATLON_OR_DOMAIN = 0
        info(_("using --maxLon %s") % (ARG_MAXLON))


  if (not inputFile):
    error(_("--input argument required"));
    usage()                     
    sys.exit()
  else:
    main(inputFile, outputFile, plugins)
