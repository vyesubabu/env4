#!/usr/bin/perl

$numArgs = @ARGV;
if ($numArgs eq 0 )
{die "Need rdb filename as parameter. Exiting";} 



#-----stations file path/name -------#
my $FILE_STATIONS="stations.txt";
#------------------------------------#



my $FILE_RDB=$ARGV[0];

#-------BEHAVIOR if station doesn't exist -------------#

my $MISSING_IGNORE=1;    # 1 : skip observation if we can't find ELEVATION in station file.
			# 0 : fill ELEVATION with default value if we can't find ELEVATION in station file.
my $DEFAULT_ELEV=9999; 

#------------------------------------------------------#
 
open FILE, "<", $FILE_STATIONS or die "Error opening $FILE_STATIONS:$!\n" ;

%HashpMap = ();

while (<FILE>)
 { 
  s/#.*//;            
  next if /^(\s)*$/;  
  chomp;
  my @arr = split(/ /,$_);
  $HashpMap{$arr[0]} = $arr[3];
 }


open FILE, "<", $FILE_RDB or die "Error opening $FILE_RDB:$!\n" ;

while (<FILE>)
 { 
  s/#.*//;            
  next if /^(\s)*$/;  
  chomp;
  my @obs = split(/ /,$_);

my $STN_ID = sprintf("%05d", $obs[13]); #--- for stationID over 5 digits, filling with 00..

my $LAT=$obs[11]/100.0;
my $LON=$obs[12]/100.0;
my $PMER=$obs[32];
my $YY=$obs[16]+2000;
my $MM="0".$obs[17];
my $DD=$obs[18];
my $HH=$obs[14];
my $min=$obs[15];
my $RR6=$obs[56];
my $MSGTYPE="ADPSFC";
my $GRIBCODE=140;
my $ELEVATION=$HashpMap{$STN_ID};
 
if ($ELEVATION == "") 
	{
	print STDERR "Missing station ID:$STN_ID\n";
	if ($MISSING_IGNORE eq 1)
	{next;}
	else
	{$ELEVATION=$DEFAULT_ELEV;} 
	}
	
my $LEVEL=6;
if ($RR6 ne -1)
{$RR6 = $RR6 / 100.0}
my $HEIGHT=0;
my $OBSVALUE=$RR6;


my $OUT= sprintf("%6s %s %4d%02i%02i_%02i%02i00 %10.2f %10.2f %4i %2i %9i %6i %10.3f",$MSGTYPE,$STN_ID,$YY,$MM,$DD,$HH,$min,$LAT,$LON,$ELEVATION,$GRIBCODE,$LEVEL,$HEIGHT,$OBSVALUE);

$OUT=~ s/\t/ /g;
$OUT=~ s/\s+/ /g;

print "$OUT\n";



}

exit 0;





