#!/usr/bin/perl
#
# This script parses a .def extracted from SMS to get the whole tasklist.
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Feb, 05  2014     #
#                                                                             #
#   VERSION :								      #
#	* v1.0.0 : 20140205						      # 
#		- Init from YG's script					      #
#									      #
#   TODO  :a							  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


$noeud="";
$tache=0;

while (<STDIN>){
  if (/^\s*suite\s+(\S+)/){
     $noeud="/$1";
     print "\n" if ($tache);
     $tache=0;
  }elsif(/^\s*family\s+(\S+)/){
     $noeud="$noeud/$1";
     #print "famille -> $noeud\n";
     print "\n" if ($tache);
     $tache=0;
  }elsif(/^\s*endfamily/){
     $noeud=~s/(.*)\/([^\/]+)$/\1/;
     #print "fin -> $noeud\n";
     print "\n" if ($tache);
     $tache=0;
  }elsif(/^\s*task\s+(\S+)/){
     print "\n" if ($tache);
     print "$noeud/$1;";
     $tache=1
  }elsif(/^\s*trigger\s+(.+)/){
     if ($tache){
        $t=$1;
    $t=~s/int__r_/bull_r_/g;
    $t=~s/int__//g;
    $t=~s/oper__//g;
        print "trigger $t;";
     }
  }elsif(/^\s*time\s+(.+)/){
     if ($tache){
        print "time $1;";
     }
  }
  
}
