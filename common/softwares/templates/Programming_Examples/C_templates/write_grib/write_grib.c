/*___________________________________________________________________________________________*/
/* AUTHOR   : AZZOPARDI Jean-Christophe                                                      */
/* PURPOSE  : Create GRIB1 file from input data instructions                                 */
/* CREATION : 20090920                                                                       */
/* USAGE    : $0 <input_directives_file> <output_grib_file>                                  */
/* HISTORY  :                                                                                */
/* DATE		DEV	COMMENT                                                              */
/* 20090920	JCA	Creation of the file                                                 */
/* 20091120	JKT	Creation of the outout file name                                     */
/* 20100430     JKT     Adopting any grid resolution and inverting Ni & Nj as per CIPS       */
/*___________________________________________________________________________________________*/



/*______________________________________________________________[ INCLUDES ]_________________*/



#include <grib_api.h>



/*______________________________________________________________[ COMPILATION DIRECTIVES ]___*/



#define FIELD_SEPARATOR	':'
int CharPosReverse(char [], char);



/*______________________________________________________________[ EOP ]______________________*/



int main(int argc,const char *argv[])
{
	/* vars */
	char		*szRow		= NULL;
	char		*sPtrKey	= NULL;
	char		*sPtrValue	= NULL;
	char		*sPtrTmp	= NULL;
	const void	*pBuffer	= NULL;
	size_t		iBufferSize	= 0;
	grib_handle	*hGrib		= NULL;
	FILE		*fInputData	= NULL;
	FILE		*fOutputGrib	= NULL;
	long		longTmp		= 0;
	long		Ni		= 0;
	long		Nj		= 0;
  double    FirstPointLat = 0., FirstPointLon = 0.;
  double    LastPointLat = 0.,  LastPointLon = 0.;
  double    iDirectionIncrement = 0., jDirectionIncrement = 0.;
  double    diffLat = 0., diffLon = 0.;
  float     incrLat = 0., incrLon = 0.;
  double    maxLat = 0., maxLon = 0.;
  double    minLat = 0., minLon = .0;
	size_t		iNbValues	= 0;
	size_t		iValuesCounter	= 0;
	size_t		iIndex	= 0;
	double		*dValueArray	= NULL;

	/* check parameters */
	if(argc != 3)
	{
		fprintf(stderr,"usage: %s in.cfg out.grib1\n",argv[0]);
		exit(1);
	}

	/* open grib handle */
	if ((hGrib = grib_handle_new_from_samples(NULL,"GRIB1")) == NULL)
	{
		fprintf(stderr,"error : Cannot create grib handle\n");
		exit(1);
	}

	/* open input data file */
	if ((fInputData = fopen(argv[1],"r")) == NULL)
	{
		perror(argv[1]);
		exit(1);
	}

	/* loop data file */
	szRow = (char *)malloc(1482);                               // By JKT increase buffer 1024 to 1482
	while (fgets(szRow,1482*sizeof(char),fInputData) != NULL)
	{
		/* jump comments and empty rows */
		if ((szRow[0] == '#') || (szRow[0] == '\n')){continue;}

		/* split key and value */
		sPtrKey = &szRow[0];
		if ((sPtrValue = strchr(sPtrKey,FIELD_SEPARATOR)) == NULL)
		{
			/* remove return at end of row */
			if ((sPtrTmp = strchr(sPtrKey,'\n')) != NULL)
			{
				*sPtrTmp = '\0';
			}

			fprintf(stderr,"warning: missing value for key '%s' in file '%s'\n",sPtrKey,argv[1]);
			continue;
		}
		*sPtrValue++ = '\0';

		/* remove return at end of row */
		if ((sPtrTmp = strchr(sPtrValue,'\n')) != NULL)
		{
			*sPtrTmp = '\0';
		}

		/* missing value (case key:)*/
		if (*sPtrValue == '\0')
		{
			fprintf(stderr,"warning: missing value for key '%s' in file '%s'\n",sPtrKey,argv[1]);
			continue;
		}

		/* set value depending of the data type */
		if (strcmp(sPtrKey,"value") == 0)
		{
			/* compute the number of value from Ni and Nj */
			if (iNbValues == 0)
			{
				if ((Ni != 0) && (Nj != 0))
				{
					iNbValues = (Ni) * (Nj);
				}

				/* if iNbValues is found, allocate array and keep values */
				if (iNbValues != 0) 
				{
					if ((dValueArray = (double*)calloc(iNbValues,sizeof(double))) == NULL)
					{
						fprintf(stderr,"error : failed to allocate value array (%d bytes)\n",iNbValues*sizeof(double));
						exit(1);
					}
				}
			}

      /* compute values to make convertion between
        lat/lon and dValueArray index */
      if ( (diffLat == 0) && (diffLon == 0) ) {
        if (FirstPointLat < LastPointLat) {
          diffLat = LastPointLat - FirstPointLat;
          maxLat = LastPointLat;
          minLat = FirstPointLat;
        } else {
          diffLat = FirstPointLat - LastPointLat ;
          maxLat = FirstPointLat;
          minLat = LastPointLat;
        }

        if (FirstPointLon < LastPointLon) {
          diffLon = LastPointLon - FirstPointLon;
          maxLon = LastPointLon;
          minLon = FirstPointLon;
        } else {
          diffLon = FirstPointLon - LastPointLon ;
          maxLon = FirstPointLon;
          minLon = LastPointLon;
        }

        fprintf(stdout, "info: minLat=%f\t minLon=%f\n", minLat, minLon);
        fprintf(stdout, "info: maxLat=%f\t maxLon=%f\n", maxLat, maxLon);
        fprintf(stdout, "info: diffLat=%f\t diffLon=%f\n", diffLat, diffLon);
	fprintf(stdout, "info: iDI=%.2f\t",iDirectionIncrement);
	fprintf(stdout, "info: jDI=%.2f\n",jDirectionIncrement);

      }
      if ( (incrLat == 0) && (incrLon ==0) ) {
        incrLat = ((diffLat) / iDirectionIncrement) + 1.;

        //if (incrLat != Ni) {** Change by JKT for inverting the grid
	if (incrLat != (double) Nj) {
          fprintf(stderr, "error: latitude increment not correct ( %.2f found, expected %d )\n", incrLat, Nj);
          exit(1);
        }
        
        incrLon = ((diffLon) / jDirectionIncrement) + 1.;      //Change by JKT for inverting the grid
        //incrLon = diffLon / jDirectionIncrement;
        //if (incrLon != Nj) { ** Change by JKT for inverting the grid
 	if (incrLon != (double) Ni) {
          fprintf(stderr, "error: longitude increment not correct ( %.2f found, expected %d )\n", incrLon, Ni);
          exit(1);
        }

        fprintf(stdout, "info: incrLat=%.2f\t incrLon=%.2f\n", incrLat, incrLon);
      }

			if (iValuesCounter < iNbValues)
			{
        /* split lat/lon/value */
        char *sPtrLon = NULL, *sPtrLat = NULL, *sPtrVal = NULL;

        if ((sPtrTmp = strchr(sPtrValue,FIELD_SEPARATOR)) != NULL) {
          sPtrLat = sPtrValue;
          *sPtrTmp = '\0';
          sPtrTmp++;
        } else {
          fprintf(stderr, "error: incorrect lat:lon:value %s\n", sPtrValue);
          continue;
        }

        if ((sPtrVal = strchr(sPtrTmp,FIELD_SEPARATOR)) != NULL) {
          sPtrLon = sPtrTmp;
          *sPtrVal = '\0';
          sPtrVal++;
        } else {
          fprintf(stderr, "error: incorrect lat:lon:value %s\n", sPtrValue);
          continue;
        }

        if ( (atol(sPtrLat) > maxLat) || (atol(sPtrLat) < minLat) ) {
          fprintf(stderr, "error: latitude %d is out of the grid ( %d <--> %d )\n", atol(sPtrLat), minLat, maxLat);
          continue;
        }
        if ( (atol(sPtrLon) > maxLon) || (atol(sPtrLon) < minLon) ) {
          fprintf(stderr, "error: longitude %d is out of the grid ( %d <--> %d )\n", atol(sPtrLon), minLon, maxLon);
          continue;
        }

        /* compute array index for such value */
        long indexLat = NULL, indexLon = NULL;
        indexLat = (atol(sPtrLat) - minLat) * incrLat / diffLat;
        indexLon = (atol(sPtrLon) - minLon) * incrLon / diffLon;

        iIndex = indexLat * incrLon + indexLon;
        
        //fprintf(stdout, "lat : %s\t lon: %s\t val : %s\n", sPtrLat, sPtrLon, sPtrVal);
        //fprintf(stdout, "indexLat : %d\t indexLon: %d\t index: %d\n", indexLat, indexLon, iIndex);

				dValueArray[iIndex] = atof(sPtrVal);

				iValuesCounter++;

				/* all values found, set the array in grib file */
				if (iValuesCounter == iNbValues)
				{
          fprintf(stdout, "\ninfo: all values read\n");
					GRIB_CHECK(grib_set_double_array(hGrib,"values",dValueArray,iNbValues),0);
          fprintf(stdout, "values write\n");
					//free(dValueArray);
				}
			}
			else
			{
				//fprintf(stderr,"warning : value '%s' will not be used. Values array is full\n",sPtrValue);
			}	
		}
		else if	((strcmp(sPtrKey,"editionNumber") == 0)
		||	 (strcmp(sPtrKey,"table2Version") == 0)
		||	 (strcmp(sPtrKey,"centre") == 0)
		||	 (strcmp(sPtrKey,"generatingProcessIdentifier") == 0)
		||	 (strcmp(sPtrKey,"gridDefinition") == 0)
		||	 (strcmp(sPtrKey,"section1Flags") == 0)
		||	 (strcmp(sPtrKey,"indicatorOfParameter") == 0)
		||	 (strcmp(sPtrKey,"indicatorOfTypeOfLevel") == 0)
		||	 (strcmp(sPtrKey,"level") == 0)
		||	 (strcmp(sPtrKey,"yearOfCentury") == 0)
		||	 (strcmp(sPtrKey,"month") == 0)
		||	 (strcmp(sPtrKey,"day") == 0)
		||	 (strcmp(sPtrKey,"hour") == 0)
		||	 (strcmp(sPtrKey,"minute") == 0)
		||	 (strcmp(sPtrKey,"unitOfTimeRange") == 0)
		||	 (strcmp(sPtrKey,"P1") == 0)
		||	 (strcmp(sPtrKey,"P2") == 0)
		||	 (strcmp(sPtrKey,"timeRangeIndicator") == 0)
		||	 (strcmp(sPtrKey,"numberIncludedInAverage") == 0)
		||	 (strcmp(sPtrKey,"numberMissingFromAveragesOrAccumulations") == 0)
		||	 (strcmp(sPtrKey,"centuryOfReferenceTimeOfData") == 0)
		||	 (strcmp(sPtrKey,"subCentre") == 0)
		||	 (strcmp(sPtrKey,"decimalScaleFactor") == 0)
		||	 (strcmp(sPtrKey,"numberOfVerticalCoordinateValues") == 0)
		||	 (strcmp(sPtrKey,"pvlLocation") == 0)
		||	 (strcmp(sPtrKey,"dataRepresentationType") == 0)
		//||	 (strcmp(sPtrKey,"latitudeOfFirstGridPoint") == 0)
		//||	 (strcmp(sPtrKey,"longitudeOfFirstGridPoint") == 0)
		||	 (strcmp(sPtrKey,"resolutionAndComponentFlags") == 0)
		//||	 (strcmp(sPtrKey,"latitudeOfLastGridPoint") == 0)
		//||	 (strcmp(sPtrKey,"longitudeOfLastGridPoint") == 0)
		//||	 (strcmp(sPtrKey,"iDirectionIncrement") == 0)
		//||	 (strcmp(sPtrKey,"jDirectionIncrement") == 0)
		||	 (strcmp(sPtrKey,"scanningMode") == 0)
		||	 (strcmp(sPtrKey,"bitsPerValue") == 0)
		||	 (strcmp(sPtrKey,"sphericalHarmonics") == 0)
		||	 (strcmp(sPtrKey,"complexPacking") == 0)
		||	 (strcmp(sPtrKey,"integerPointValues") == 0)
		||	 (strcmp(sPtrKey,"additionalFlagPresent") == 0))
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);
		}
		else if (strcmp(sPtrKey,"Ni") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store Ni for further use (size) */
			Ni = longTmp;

		}
		else if (strcmp(sPtrKey,"Nj") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store Nj for further use (size) */
			Nj = longTmp;
		}
		else if (strcmp(sPtrKey,"latitudeOfFirstGridPoint") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store for further use (size) */
			FirstPointLat = longTmp;
		}
    else if (strcmp(sPtrKey,"longitudeOfFirstGridPoint") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store for further use (size) */
			FirstPointLon = longTmp;
		}
    else if (strcmp(sPtrKey,"latitudeOfLastGridPoint") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store for further use (size) */
			LastPointLat = longTmp;
		}
    else if (strcmp(sPtrKey,"longitudeOfLastGridPoint") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store for further use (size) */
			LastPointLon = longTmp;
		}
    else if (strcmp(sPtrKey,"iDirectionIncrement") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store for further use (size) */
			 iDirectionIncrement= longTmp;
		}
    else if (strcmp(sPtrKey,"jDirectionIncrement") == 0)
		{
			/* set value */
			longTmp = atol(sPtrValue);
			GRIB_CHECK(grib_set_long(hGrib,sPtrKey,longTmp),0);			

			/* store for further use (size) */
			 jDirectionIncrement= longTmp;
		}
	}
	free(szRow);

	/* check */
	if (iValuesCounter != iNbValues)
	{
		fprintf(stderr,"warning: number of values found '%d' is not equal as the number expected '%d'\n",iValuesCounter,iNbValues);
		free(dValueArray);
	}

	/* close input data file */
	fclose(fInputData);

	/*>>========JK TOMAR for output file name creation============<<*/

	char infile[strlen(argv[1])+1];
	char outfile[strlen(argv[2])+50];
	char *outpath;

	strcpy(infile,argv[1]);

	int sindex=CharPosReverse(infile,'/');
	int eindex=CharPosReverse(infile,'.');
//	printf("in file ....\n");
	int i=sindex-1,j=0;
	for(;i<eindex-1;i++,j++)
	{
		outfile[j] = infile[i];
	}
	outfile[j]='\0';
	strcat(outfile,"grib1");
	outpath=argv[2];
	strcat(outpath,outfile);
	printf("grib file : %s\n",outpath);
	

	/*>>================================================<<*/

	/* open output grib file */
	if ((fOutputGrib = fopen(outpath,"w")) == NULL)
	{
		perror(outpath);
		exit(1);
	}

	/* write grib file */
	GRIB_CHECK(grib_get_message(hGrib,&pBuffer,&iBufferSize),0);
	if(fwrite(pBuffer,1,iBufferSize,fOutputGrib) != iBufferSize)
	{
		perror(argv[2]);
		exit(1);
	}

	/* close output grib file */
	if(fclose(fOutputGrib))
	{
		perror(argv[2]);
		exit(1);
	}

	return 0;
}

/*************************************************
*
* Search given Char in Given String from Last
*
***************************************************/

int CharPosReverse(char str[], char ch)
{

int i=0,k=0,pos;
int val=(int)ch;

for(i=strlen(str)-1;i>1;i--,k++)
{
	if(str[i]==val)
	{	
		pos=strlen(str)-k;	
        	break;
	}
	else
		pos=-1;
}	
return pos;
}
