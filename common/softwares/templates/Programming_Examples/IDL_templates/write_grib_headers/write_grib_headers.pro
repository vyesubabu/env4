PRO write_grib_headers
COMMON Share1,tval,outpath,inpath,vlat,vlon,datetime

;Error Handling
!Error_State.code=0
Catch,Error
IF (Error NE 0) THEN BEGIN
    help,/last_message,output=traceback
    errarr=['Error Caught',traceback]
    ok = Dialog_Message(errarr,/INFORMATION)
    close,/all
    return
ENDIF

  ;Checking input arguments
  args = command_line_args()
  ele = N_ELEMENTS(args)

  IF (ele LT 3) THEN BEGIN
     print,'Sorry! Invalid Arguments....'
     print,'Usages :'
     print,'idl -rt=.sav_file -args output_path input_path bin_path'
     return
  ENDIF
  
  ;Geting user arguments inputs
  outpath =args[0]  
  inpath =args[1]     
  bpath =args[2] 
  
  IF (ele EQ 4) THEN $
    datetime=args[3] $
  ELSE print,'WARNING: Year and Month will be set as SYSTEM data.....!'  
  
 
 ;Count input file 
 CD,inpath
 files = file_search('*.ascii', /FOLD_CASE,/FULLY_QUALIFY_PATH,COUNT=nfiles)
 print,'No. of file : ',nfiles

;Check no. of files
IF (nfiles LT 1) THEN BEGIN
  print,'Sorry! Either no input file or invalid input path.....'
  return
 ENDIF

;Check read/write permision of output path
finfo = FILE_INFO(outpath,/NOEXPAND_PATH)
 IF NOT (finfo.Write) THEN BEGIN
      message,'Err! No writing permisions in output path'
      return
  ENDIF
 
 ;Create template file for all ASCII files
 FOR j=0,nfiles-1 DO BEGIN 
 
 SKIP_FILE:
   
 infile=files[1]
 
 ;Check input file size
 finfo = FILE_INFO(infile,/NOEXPAND_PATH)
 IF finfo.Size LE 0 THEN BEGIN
      print,'Err! File size is zero : ',infile
      j=j+1
      goto, SKIP_FILE
 ENDIF 
   
    ;Open the data file
    nrows = File_Lines(infile)  
    data = fltarr(5,nrows)
    OpenR, lun, infile, /Get_Lun
    ReadF, lun, data
    Free_Lun, lun
   
    ; Get vectors you are interested in.
    vlat = Reform(data[0,*])
    vlon = Reform(data[1,*])
    tval = Reform(data[4,*])       
          
    ;Get the input file name
    ofile=FILE_BASENAME(infile,'.ascii',/fold_case)+'.tmp'
   
    ;get level
    ld=STRPOS(ofile, '.')
    lh=STRPOS(ofile, 'H',/REVERSE_SEARCH)
    lvl=LONG(STRMID(ofile,ld+1,lh-ld-1))
     
    ;get hrs
    dt=STRPOS(ofile, '.',/REVERSE_SEARCH)
    substr=STRMID(ofile,0,dt)
    ndt=STRPOS(substr,'.',/REVERSE_SEARCH)
    gmt_time=LONG(STRMID(substr,ndt+1,STRLEN(substr)-ndt))
    print,'level: ',lvl,' time: ',gmt_time
    
    ;Write data tampelete
    WriteGrbTemplt,ofile,lvl,gmt_time
    cmd = bpath+'/write_grib '+ofile+' '+outpath+'/'+FILE_BASENAME(infile,'.ascii',/fold_case)+'.'
    spawn,cmd
    

 
ENDFOR

END

 
;Procedure for formating grib template
PRO WriteGrbTemplt,ofile,level,gmt_time
COMMON Share1,tval,outpath,inpath,vlat,vlon,datetime
;Error Handling
!Error_State.code=0
Catch,Error
IF (Error NE 0) THEN BEGIN
    help,/last_message,output=traceback
    errarr=['Error Caught',traceback]
    ok = Dialog_Message(errarr,/INFORMATION)
    close,/all
    return
ENDIF

    ;Extract Year and Month from input arguments
    IF NOT KEYWORD_SET(datetime) THEN BEGIN
      ;Get current date and year
      jdays=SYSTIME(/JULIAN)
      CALDAT,jdays,mm,dd,yr,hh,mn
      mn=00
      yy=STRMID(STRTRIM(yr,2),2,2)
    ENDIF ELSE BEGIN
    
      ; Only YY/MM are needed for the file
      yy=STRMID(STRTRIM(datetime,2),2,2)
      mm=STRMID(STRTRIM(datetime,2),4,2)
    
    ENDELSE
    
    ;Hours as per input file
    hh=gmt_time
    
    
    ;Write data into ascii template file
    CD,inpath
    OPENW,1,ofile

    printf,1,'# Informations to identify the grib'
    printf,1,'centre:7'
    printf,1,'generatingProcessIdentifier:96'

    printf,1,''

    printf,1,'# Date time'
    printf,1,'yearOfCentury:',STRTRIM(yy,2)
    printf,1,'month:',STRTRIM(mm,2)
    printf,1,'day:',STRTRIM(dd,2)
    printf,1,'hour:',STRTRIM(hh,2)
    printf,1,'minute:',STRTRIM(mn,2)
    printf,1,'P1:',STRTRIM(gmt_time,2)
    printf,1,'P2:0';,STRTRIM(gmt_time,2)
    printf,1,''

    latmin=min(vlat)
    latmax=max(vlat)
    lonmin=min(vlon)
    lonmax=max(vlon)
       
    printf,1,'# Grid-related informations'
    getGribLat,latmax,outlat
    printf,1,'latitudeOfFirstGridPoint:'+strtrim(outlat,2) ;50000
    getGribLon,lonmin,outlon
    printf,1,'longitudeOfFirstGridPoint:'+strtrim(outlon,2) ;050000
    printf,1,'resolutionAndComponentFlags:128'
    getGribLat,latmin,outlat
    printf,1,'latitudeOfLastGridPoint:'+strtrim(outlat,2) ;-01000
    getGribLon,lonmax,outlon
    printf,1,'longitudeOfLastGridPoint:'+strtrim(outlon,2) ;110000
    printf,1,'iDirectionIncrement:0250'
    printf,1,'jDirectionIncrement:0250'
    printf,1,'Ni:241'
    printf,1,'Nj:241'

    printf,1,''

    printf,1,'# Set type of value'
    printf,1,'indicatorOfParameter:14'

    printf,1,''

    printf,1,'# Set level'
    printf,1,'level:',STRTRIM(level,2)
    printf,1,'indicatorOfTypeOfLevel:100'

    printf,1,''

    printf,1,'# Standards headers'
    printf,1,'editionNumber:1'
    printf,1,'table2Version:2'
    printf,1,'gridDefinition:3'
    printf,1,'section1Flags:128'
    printf,1,'unitOfTimeRange:4'
    printf,1,'timeRangeIndicator:4'
    printf,1,'numberIncludedInAverage:0'
    printf,1,'numberMissingFromAveragesOrAccumulations:0'
    printf,1,'centuryOfReferenceTimeOfData:21'
    printf,1,'subCentre:0'
    printf,1,'decimalScaleFactor:1'
    printf,1,'numberOfVerticalCoordinateValues:0'
    printf,1,'pvlLocation:255'
    printf,1,'dataRepresentationType:0'
    printf,1,'scanningMode:0'
    printf,1,'bitsPerValue:10'
    printf,1,'sphericalHarmonics:0'
    printf,1,'complexPacking:0'
    printf,1,'integerPointValues:0'
    printf,1,'additionalFlagPresent:0'

    printf,1,''
    i=0L
    print,'nol',N_ELEMENTS(vlat)
    
WHILE (i LT N_ELEMENTS(vlat))  DO BEGIN

      if vlat[i] LT 0 AND vlat[i] GT -10 THEN $
        lat='-0'+STRTRIM(ABS(LONG(vlat[i])),2)+'000' $
      else if vlat[i] LE -10 THEN lat='-'+STRTRIM(ABS(LONG(vlat[i])),2)+'000' $
      else if vlat[i] EQ 0 THEN lat='0'+STRTRIM(ABS(LONG(vlat[i])),2)+'000' $ 
      else if vlat[i] LT 10 THEN lat='0'+STRTRIM(ABS(LONG(vlat[i])),2)+'000' $
      else if vlat[i] GE 10 THEN lat=STRTRIM(ABS(LONG(vlat[i])),2)+'000' 
      
      if  vlon[i] LT 0 AND vlon[i] GT -9 THEN lon='-00'+STRTRIM(ABS(LONG(vlon[i])),2)+'00' $
      else if vlon[i] LE -10 AND vlon[i] GT -99 THEN lon='-0'+STRTRIM(ABS(LONG(vlon[i])),2)+'00' $
      else if vlon[i] LE -100 THEN lon='-'+STRTRIM(LONG(ABS(vlon[i])),2)+'000' $
      else if vlon[i] LE 1 AND vlon[i] GE 0 THEN lon='00000'+STRTRIM(LONG(vlon[i]),2) $
      else if vlon[i] GE 10 AND vlon[i] LE 99 THEN lon='0'+STRTRIM(LONG(vlon[i]),2)+'000' $
      else if vlon[i] GE 100 THEN lon=STRTRIM(LONG(vlon[i]),2)+'000'
      
      printf,1,'value:',lat,':',lon,':',strtrim(tval[i],2)    
      i=i+1
      
ENDWHILE

CLOSE,1


END

;Get lat string as per grib template
PRO getGribLat,inlat,outlat
    
    if inlat LT 0 AND inlat GT -9. THEN $
    outlat='-0'+STRTRIM(ABS(LONG(inlat)),2)+'000' $
    else if inlat LE -10  THEN outlat='-'+STRTRIM(ABS(LONG(inlat)),2)+'000' $ 
    else if inlat EQ 0 THEN  outlat='0'+STRTRIM(ABS(LONG(inlat)),2)+'000' $ 
    else if inlat LT 10 THEN outlat='0'+STRTRIM(ABS(LONG(inlat)),2)+'000' $
    else if inlat GE 10 THEN outlat=STRTRIM(ABS(LONG(inlat)),2)+'000' 
return    
END    

;Get lon string as per grib template
PRO getGribLon,inlon,outlon

   if  inlon LT 0 AND inlon GT -9 THEN outlon='-00'+STRTRIM(ABS(LONG(inlon)),2)+'00' $
   else if inlon LE -10 AND inlon GT -99 THEN outlon='-0'+STRTRIM(ABS(LONG(inlon)),2)+'00' $
   else if inlon LE -100 THEN outlon='-'+STRTRIM(LONG(ABS(inlon)),2)+'000' $
   else if inlon LE 1 AND inlon GE 0 THEN outlon='00000'+STRTRIM(LONG(inlon),2) $
   else if inlon GE 10 AND inlon LE 99 THEN outlon='0'+STRTRIM(LONG(inlon),2)+'000' $
   else if inlon GE 100 THEN outlon=STRTRIM(LONG(inlon),2)+'000'
      
return
END
