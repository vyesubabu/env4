#!/bin/bash
#
# This script provides compilation of WRF cores
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Nov, 09  2011     #
#                                                                             #
#   VERSION :								      #
#	* v1.6: 20120315						      # 
#		-	Add netcdf 3.6.3 & 4.0 
#		-	Add $NETCDFVERSION to directory of build
#		-	Add $CONFIGURE_OPTS instead of $COMPILE(R)_OPTS
#		-	Add explicit logging of ./configure line
#	* v1.5: 20120307						      # 
#		-	Add call_tree(), CALL_TREE toggle
#	* v1.4: 20120214						      # 
#		-	Move COMPILENVFILE to find_compile_opts()
#	* v1.3: 20120213						      # 
#		-	Add COMPILENVDIR to specify an environment for each 
#			step to be compiled
#		-	Add functions numbers (16 functions)
#	* v1.2: 20120209						      # 
#		-	Activate AUTOBUGFIX on to fetch the latest tar of
#			bugfixes. Should in time gather all the bugfixes of
#			a given version
#		-	netcdf compile : add -Df2cFortran in CPPFLAGS !
#		-	check_tools : create $TOOLSDIR
#		-	Add main WRF steps: WPS, WRF, UPP
#		-	Add all necessary steps (OMPI, Tools, etc...)
#		-	Switch to WRFTARGET as root			      #
#	* v1.1: 20120206						      # 
#		-	Add openMPI library version			      #
#	* v1.0								      # 
#		-	Split ARW & NMM, specify optimisation level,          #
#			type of parallelisation, compiler		      #
#		-	Nesting assumed to be option 1 (basic)		      #
#									      #
#   Evols:
#		- autodetect version from tar file name
#		- generate module file (wrf/$core/$compiler/$openmpi) on the fly
#		- Prepare PGI arch files to match (-DpgiFortran eg.)
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#    compile_core.sh ARW SMDM 3 gcc44 no_debug openmpi154
#
#  compile_core.sh core PARALLEL OPTIM COMPILER DEBUG OPENMPI
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

## Main Variables Declaration
NETCDFVERSION_LIST="3.6.3 4.0 4.1.1"
WRFVERSION=V3.3.1
UPPVERSION=V1.0
WRFPROPER=/share/scratch/REMI/WRF_PROPER
SHAREDIR=/share/apps
MODULESDIR=$SHAREDIR/modules/modulefiles
WRFTARGET=$SHAREDIR/WRF

COMPILENVDIR=/share/common/share/environment/compilation

AUTOBUGFIX="ON"

CALL_TREE="ON"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#			FUNCTIONS
# 
## F0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
call_tree() {
  functionname=$1
  CALL_TREE_DIR=/tmp
  CALL_TREE_FILE=`basename $0`".$$.calltree"
  if [ "$CALL_TREE" == "ON" ];then
	echo "#~~~~~~~~~~~~~~~~~~~~~~ $functionname ~~~~~~#" >> $CALL_TREE_DIR/$CALL_TREE_FILE
  fi
}

## F1
check_tools() {

  call_tree $FUNCNAME

  [[ -d $TOOLSDIR ]] || mkdir -p $TOOLSDIR
  
  opt=$1
  
  ## check TOOLSDIR
  LIBFILES="libjasper.a libpng.a libz.a libnetcdf.a"
  declare -a ARRAYLIB=($LIBFILES)
  NLIB=${#ARRAYLIB[*]}
  
  counter=0
  
  for f in $LIBFILES ; do
  	if [ -f $TOOLSDIR/lib/$f ]; then
  		echo "$f exists"
  		let counter=counter+1
  	else
  		## step : jasper, libpng, netcdf-4.1.1 or zlib
  		step=`basename $f .a|sed "s:^lib::g"`
  		if [ "$step" == "z" ]; then
  			step="zlib"
  		elif [ "$step" == "png" ]; then
			step="libpng"
  		elif [ "$step" == "netcdf" ]; then
			#step="netcdf-4.1.1"
			#step="netcdf-3.6.3"
			step="netcdf-$NETCDFVERSION"
  		fi
  
  		echo "WRF Tools incomplete : missing $f in $TOOLSDIR/lib"

  		if [ "$opt" == "and_compile" ]; then
  			## Compile each & every tool
  			mycompile $step $compiler
  		fi
  	
  	fi
  done
  	
  if [ $counter -eq $NLIB ]; then
  	CHECKTOOLS="OK"
  else
  	CHECKTOOLS="NOK"
  	echo "Missing a tool in $TOOLSDIR. Check amongs $LIBFILES"
  
  	if [ "$opt" == "and_exit" ]; then
  		exit 1
  	fi
  fi

}

## F2
check_and_load_module() {

  call_tree $FUNCNAME

	mod=$1

	if [ -f $MODULESDIR/$mod ]; then
		. /etc/profile.d/modules.sh
		echo "Loading module $mod"
		module load $mod
		echo "module load $mod" >> /tmp/MODULES.$0.$$
	else
		echo "MODULE $mod unknown. " ; 
		exit 1;
	fi
}

## F3
find_compressor() {

  call_tree $FUNCNAME

	file=$1
	ext=`echo ${file##*.}`
	case $ext in
		bz2) DECOMPRESS="tar xvfj ";;
		gz) DECOMPRESS="tar xvfz ";;
		tgz) DECOMPRESS="tar xvfz ";;
		zip) DECOMPRESS="unzip ";;
		*) echo "Unknown extension $ext on file $file ! Cannot decompress" ; exit 1;;
	esac
}

## F4
find_compile_opts() {

  call_tree $FUNCNAME

	stepversion=$1

	DEFAULT_COMPILENVFILE=ENV.GCC44
	## does NOT include the prefix (which comes in the compilation sequence)
	case $stepversion in 
		netcdf-3.6.3)	
				CONFIGURE_OPTS="" ; 
			#	COMPILENVFILE=ENV.NETCDF
				;;
		netcdf-4.1.1|netcdf-4.0)	
				#CONFIGURE_OPTS="--disable-netcdf-4" ; 
				CONFIGURE_OPTS="--enable-separate-fortran" ; 
			#	COMPILENVFILE=ENV.NETCDF
				;;
		openmpi154) 
				CONFIGURE_OPTS="--with-openib --with-sge "
				;;
		WPSV3.3.1|WRFV3.3.1|UPPV1.0) 
				CONFIGURE_OPTS=""
			#	COMPILENVFILE=ENV.NETCDF
				;;
		*) 
			echo "" 
			echo "Unknown step $stepversion ... compile options not figured out!" 
			echo "Forcing compile environment file to default : $DEFAULT_COMPILENVFILE"
			COMPILENVFILE=$DEFAULT_COMPILENVFILE
			sleep 2 ;;
	esac

	if [ -z "$COMPILENVFILE" ]; then
		COMPILENVFILE=$DEFAULT_COMPILENVFILE
	fi

	## Loading env file
#	echo "Loading compilation environment from $COMPILENVFILE"
	if [ -z "$CC" ]; then
		echo "Loading 	. $COMPILENVDIR/$COMPILENVFILE"
		. $COMPILENVDIR/$COMPILENVFILE
	else
		echo "CC=$CC already set. Not changing it with $COMPILENVFILE"
	fi

	env | sort -n |grep "^[FC]"
	
	echo "This is ENV for $stepversion. Continue?"
	#	read answer

}

## F5
find_and_run_compilation_sequence() {

  call_tree $FUNCNAME

	stepversion=$1

        ## COMPILE  SEQUENCE
        case $stepversion in
                jasper)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$TOOLSDIR ;
                        echo "Running make install for $stepversion in $PWD"
                        echo " ./configure $CONFIGURE_OPTS --prefix=$PREFIX"
		        sleep 2
                  	./configure $CONFIGURE_OPTS --prefix=$PREFIX
			make
			make install &> $PWD/makeinstall.log ;;
                openmpi154)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$OPENMPIDIR ;
		        echo "Running ./configure $CONFIGURE_OPTS --prefix=$PREFIX in $PWD"
			sleep 2
		        ./configure $CONFIGURE_OPTS --prefix=$PREFIX

                        echo "Running make -j 4 install in $PWD"
                        sleep 2
                        make -j 4 install &> $PWD/make.log;
                        make install &> $PWD/makeinstall.log ;;

                netcdf-4.1.1 | netcdf-4.0 | netcdf-3.6.3)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$TOOLSDIR ;
                        echo "Running make install for $stepversion in $PWD"
			#export CPPFLAGS="$CPPFLAGS -Df2cFortran"
			#export CPPFLAGS="$CPPFLAGS -DgFortran"
			#export FFLAGS="$FFLAGS -DUNDERSCORE -fno-second-underscore"
			#export FFLAGS="$FFLAGS -fno-second-underscore"

                  	./configure $CONFIGURE_OPTS --prefix=$PREFIX 
		        echo "Running ./configure $CONFIGURE_OPTS --prefix=$PREFIX in $PWD"
			sleep 2
			make check
			make install  &> $PWD/makeinstall.log ;;
                libpng)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$TOOLSDIR ;
                        echo "Running make install for $stepversion in $PWD"
                  	./configure $CONFIGURE_OPTS --prefix=$PREFIX
		        echo "Running ./configure $CONFIGURE_OPTS --prefix=$PREFIX in $PWD"
			sleep 2
			make check
			make install &> $PWD/makeinstall.log ;;
                zlib)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$TOOLSDIR ;
                        echo "Running make install for $stepversion in $PWD"
                  	./configure $CONFIGURE_OPTS --prefix=$PREFIX
		        echo "Running ./configure $CONFIGURE_OPTS --prefix=$PREFIX in $PWD"
			sleep 2
			make test
			make install &> $PWD/makeinstall.log ;;
               UPPV1.0)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$UPPDIR ;

			cd $UPPDIR
                        echo "Running make install for $stepversion in $PWD"
                  	./configure $CONFIGURE_OPTS --prefix=$PREFIX
		        echo "Running ./configure $CONFIGURE_OPTS --prefix=$PREFIX in $PWD"
			sleep 2

			#./clean -a
			./compile ;;

                WPSV3.3.1)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$WPSDIR ;
			echo "Importing MFI architecture defaults file $WRFPROPER/CONFIG/mfi.arch.WPS.defaults !"
			cat $WRFPROPER/CONFIG/mfi.arch.WPS.defaults > $WPSDIR/arch/configure.mfi.defaults
			cat $WPSDIR/arch/configure.defaults >> $WPSDIR/arch/configure.mfi.defaults
			mv $WPSDIR/arch/configure.mfi.defaults $WPSDIR/arch/configure.defaults

			cd $WPSDIR
                        echo "Running make install for $stepversion in $PWD"
                  	./configure $CONFIGURE_OPTS --prefix=$PREFIX
		        echo "Running ./configure $CONFIGURE_OPTS --prefix=$PREFIX in $PWD"
			sleep 2

			## Add the proper links to the libraries / includes
			CLIBS="#-#L$TOOLSDIR/lib -lnetcdff -lnetcdf -ljasper -lpng -lpng12 -lz"
			CINC="#-#I$TOOLSDIR/include"
			cat configure.wps | sed -e "s:COMPRESSION_LIBS        =:&	$CLIBS:g" -e "s:COMPRESSION_INC		=:&	$CINC:g" -e "s:#-#:-:g" > tmp.wps
			mv configure.wps configure.wps.ori ; mv tmp.wps configure.wps	

			#./clean -a
			./compile ;;
                WRFV3.3.1)
			#~~
			find_compile_opts $stepversion
		
			PREFIX=$WRFDIR ;

			echo "Importing MFI architecture defaults file $WRFPROPER/CONFIG/mfi.arch.WRF.defaults!"
			cat $WRFPROPER/CONFIG/configure_new.defaults.WRF.mfi > $WRFDIR/arch/configure_new.mfi.defaults
			
			if [ ! -f $WRFDIR/arch/configure_new.defaults.ori ]; then
				cp $WRFDIR/arch/configure_new.defaults $WRFDIR/arch/configure_new.defaults.ori
			fi
			mv $WRFDIR/arch/configure_new.mfi.defaults $WRFDIR/arch/configure_new.defaults
			
			## Override MFI-SPECIFIC
			#echo "Overriding MFI-SPECIFIC config"
			#sleep 5
			#cp -f $WRFDIR/arch/configure_new.defaults.ori $WRFDIR/arch/configure_new.defaults

			cd $WRFDIR
                        echo "Running make install for $stepversion in $PWD"
			#./clean -a
                  	./configure $CONFIGURE_OPTS --prefix=$PREFIX
		        echo "Running ./configure $CONFIGURE_OPTS --prefix=$PREFIX in $PWD"
			sleep 2
                  	#./configure 

			if [ "$AUTOBUGFIX" == "ON" ]; then
				latest_bugfix=`ls -rt $WRFPROPER/CONFIG/bugfixes_${WRFVERSION}* |tail -1`
				cd $WRFDIR 
				tar xvfz $latest_bugfix
			fi

                        echo "Running compilation of process $process for $core in version $stepversion in $PWD"
			sleep 2
			./compile -j 8 $process ;;
                *)
                        echo "Unknown stepversion $stepversion to make..."
                        exit 1;;
        esac
}

## F6

  call_tree $FUNCNAME

decompress_and_compile() {
	
	##eg openmpi154 ; WPSV3.3.1 ; UPPV1.0
	stepversion=$1
	file=$2
	compiler=$3

	echo "in decompress_and_compile, compiling $stepversion using $file and $compiler"

	case $stepversion in 
		jasper|libpng|netcdf-3.6.3|netcdf-4.0|netcdf-4.1.1|zlib|openmpi154)
			TMPDIR=/tmp/$stepversion.$$ ;;
		UPPV1.0)	
			# Note that UPP.tgz package contains "UPPV1.0" subdir ; it must be extracted in $WRFMAINDIR  
			TMPDIR=$WRFMAINDIR ;;
		WPSV3.3.1)	
			# Note that WPS.tgz package contains "WPS" subdir ; it must be extracted in $WRFMAINDIR  
			TMPDIR=$WRFMAINDIR ;;
		WRFV3.3.1)	
			# Note that WRF.tgz package contains "WRFV3" subdir ; it must be extracted in $WRFMAINDIR  
			TMPDIR=$WRFMAINDIR ;;
		*)	
			echo "Unknown extraction dir $TMPDIR for $stepversion!" ; exit 1;;
	esac
	[[ -d $TMPDIR ]] || mkdir -p $TMPDIR ; cd $TMPDIR
	echo "Working in $PWD"
	sleep 2
	$DECOMPRESS $file

	is_compilerstring=`echo $compiler | grep "/"`
	if [ -z "$is_compilerstring" ]; then
		## Compiler is not a string with /, trying to fetch module from it
		case $compiler in 
			gcc44) 
				COMPILER_MODULE="gcc/gcc44" ;;
			*) 
				echo "Compiler $compiler unknown .. pls check" ; exit 1 ;;
		esac
	else
		## Compiler is a string with /: assuming it is the module string!
		COMPILER_MODULE=$compiler
	fi

	#~~
	check_and_load_module $COMPILER_MODULE

	
	cd $TMPDIR
	cd `ls -1d *`

	## RUN COMPILATION SEQUENCE
	#~~
	find_and_run_compilation_sequence $stepversion

}


## F7
find_step_tar() {

  call_tree $FUNCNAME

	step=$1
	dir=$2
	echo "Grepping for $step in $dir"
	versionfile=`ls $dir/* | grep "$step" | grep -i "[(bz2)|(gz)|(zip)]"`
	if [ ! -z "$versionfile" ]; then
		echo "Found file $versionfile for $step"
		NFILES=`echo $versionfile | awk ' BEGIN {FS=" "}; {print NF}'`
		if [ $NFILES -ne 1 ]; then
			echo "Found too many files: "
			echo $versionfile
			echo "Please pick one:"
			read answer
			versionfile=$answer
		fi
	else
		echo "Did not find a file for $step in $dir. Please check"
		exit 1
	fi
		
}

## F8
compile_lib() {

  call_tree $FUNCNAME

	step=$1
	compiler=$2
	
	find_step_tar $step $WRFPROPER/SRC

        if [ -f $versionfile ]; then

                find_compressor $versionfile

                decompress_and_compile $step $versionfile $compiler

        else
                echo "File $versionfile not found for step $step !"
                exit 1
        fi
}

## F9
compile_openmpi() {

  call_tree $FUNCNAME

	step=openmpi
	## 3 digits version (eg 154)
	version=$1
	stepversion=${step}$version
	compiler=$2
	versiondots=`echo $version | sed "s:.:&.:g"`

        find_step_tar $step $WRFPROPER/SRC

	if [ -f $versionfile ]; then

		find_compressor $versionfile

		decompress_and_compile $stepversion $versionfile $compiler

	else
		echo "File $versionfile not found for step $step !"
		exit 1
	fi

}

## F10
compile_upp() {

  call_tree $FUNCNAME

	step=UPP
	## upp version (V1.0)
	version=$1
	stepversion=${step}$version
	compiler_string=$2
	echo "Compiling $step in version $version with compiler_string $compiler_string"
	echo "Using Stepversion=$stepversion"

	#~~
        find_step_tar $stepversion $WRFPROPER/SRC

	if [ -f $versionfile ]; then

		#~~
		find_compressor $versionfile

		#~~
		decompress_and_compile $stepversion $versionfile $compiler_string

	else
		echo "File $versionfile not found for step $step !"
		exit 1
	fi
}


## F11
compile_wrf() {

  call_tree $FUNCNAME

	step=WRF
	## wrf-like version (V3.3.1)
	version=$1
	stepversion=${step}$version
	compiler_string=$2
	echo "Compiling $step in version $version with compiler_string $compiler_string"
	echo "Using Stepversion=$stepversion"

	#~~
        find_step_tar $stepversion $WRFPROPER/SRC

	if [ -f $versionfile ]; then

		#~~
		find_compressor $versionfile

		#~~
		decompress_and_compile $stepversion $versionfile $compiler_string

	else
		echo "File $versionfile not found for step $step !"
		exit 1
	fi
}

## F12
compile_wps() {

  call_tree $FUNCNAME

	step=WPS
	## wrf-like version (V3.3.1)
	version=$1
	stepversion=${step}$version
	compiler_string=$2
	echo "Compiling $step in version $version with compiler_string $compiler_string"
	echo "Using Stepversion=$stepversion"

	#~~
        find_step_tar $stepversion $WRFPROPER/SRC

	if [ -f $versionfile ]; then

		#~~
		find_compressor $versionfile

		#~~
		decompress_and_compile $stepversion $versionfile $compiler_string

	else
		echo "File $versionfile not found for step $step !"
		exit 1
	fi
}

## F13
mycompile() {

  call_tree $FUNCNAME

	step=$1
	step_opt1=$2
	step_opt2=$3

	case $step in 
		jasper|libpng|netcdf-4.1.1|netcdf-4.0|netcdf-3.6.3|zlib)
			
			compiler=$step_opt1;

			#~~
			compile_lib $step $compiler ;; 
		openmpi)
			ompi_version=`echo $step_opt1| cut -c8-`; 
			compiler=$step_opt2; 

			#~~
			compile_openmpi $ompi_version $compiler ;;
		upp)
			upp_version=$step_opt1 
			compiler_string=$step_opt2 

			#~~
			compile_upp $upp_version $compiler_string;;
		wps)
			wps_version=$step_opt1 
			compiler_string=$step_opt2 

			#~~
			compile_wps $wps_version $compiler_string;;
		wrf)
			wrf_version=$step_opt1 
			compiler_string=$step_opt2 

			#~~
			compile_wrf $wrf_version $compiler_string;;


		*) echo "Unknown step to compile as $step... exit" ; exit 1 ;;
	esac
}

## F14
check_wps() {

  call_tree $FUNCNAME


	opt=$1

	echo "Checking WPSDIR = $WPSDIR for WRF Version $WRFVERSION"
	WPSBINARIES="geogrid.exe ungrib.exe metgrid.exe"
	NBINARIES=`echo $WPSBINARIES|awk ' BEGIN {FS=" "}; {print NF}'`

	missing=0
	for f in $WPSBINARIES; do
		if [ -f $WPSDIR/$f ]; then
			echo "$WPSDIR/$f exists"
		else
			echo "Missing $WPSDIR/$f"
			let missing=missing+1
		fi
	done
	
	## If all binaries are missing, we recompile
	if [ $missing -eq $NBINARIES ]; then
		echo "All binaries missing! Recompiling!"

  		if [ "$opt" == "and_exit" ]; then
  			echo "Still not present after compilation. Exiting."
			exit 1
		fi

  		if [ "$opt" == "and_compile" ]; then
			#~~
			mycompile wps $WRFVERSION  wrf/$core/$compiler/$openmpi/${compiler}-$openmpi
			WPSCOMPILED="CHECK"
  		fi

	elif [ $missing -ne 0 ]; then
		echo "Missing at least one binary file in $WPSDIR but others founds ... please check manually"
		exit 1
	else
		echo "All binaries for WPS found. Proceeding."
		WPSCOMPILED="YES"
	fi
}

## F15
check_wrf() {

  call_tree $FUNCNAME


	opt=$1

	echo "Checking WRFDIR = $WRFDIR for WRF Version $WRFVERSION"
	WRFBINARIES="real.exe wrf.exe"
	NBINARIES=`echo $WRFBINARIES|awk ' BEGIN {FS=" "}; {print NF}'`

	missing=0
	for f in $WRFBINARIES; do
		if [ -f $WRFDIR/$f ]; then
			echo "$WRFDIR/$f exists"
		else
			echo "Missing $WRFDIR/$f"
			let missing=missing+1
		fi
	done
	
	## If all binaries are missing, we either compile or exit 
	if [ $missing -eq $NBINARIES ]; then
		echo "All binaries missing! Recompiling!"

  		if [ "$opt" == "and_exit" ]; then
  			echo "Still not present after compilation. Exiting."
			exit 1
		fi

  		if [ "$opt" == "and_compile" ]; then
			case $core in 
				ARW) process="em_real" ;;
				NMM) process="nmm_real" ;;
				*) echo "core undefined. Aborting" ; exit 1 ;;
			esac

			#~~
			mycompile wrf $WRFVERSION  wrf/$core/$compiler/$openmpi/${compiler}-$openmpi
			WRFCOMPILED="CHECK"
  		fi

	elif [ $missing -ne 0 ]; then
		echo "Missing at least one binary file in $WRFDIR but others founds ... please check manually"
		exit 1
	else
		echo "All binaries for WRF found. Proceeding."
		WRFCOMPILED="YES"
	fi
}

## F16
check_upp() {

  call_tree $FUNCNAME


	opt=$1

	echo "Checking UPPDIR = $UPPDIR for UPP Version $UPPVERSION"
	UPPBINARIES="copygb.exe unipost.exe"
	NBINARIES=`echo $UPPBINARIES|awk ' BEGIN {FS=" "}; {print NF}'`

	missing=0
	for f in $UPPBINARIES; do
		if [ -f $UPPDIR/bin/$f ]; then
			echo "$UPPDIR/bin/$f exists"
		else
			echo "Missing $UPPDIR/bin/$f"
			let missing=missing+1
		fi
	done
	
	## If all binaries are missing, we either compile or exit 
	if [ $missing -eq $NBINARIES ]; then
		echo "All binaries missing! Recompiling!"

  		if [ "$opt" == "and_exit" ]; then
  			echo "Still not present after compilation. Exiting."
			exit 1
		fi

  		if [ "$opt" == "and_compile" ]; then

			#~~
			mycompile upp $UPPVERSION  wrf/$core/$compiler/$openmpi/${compiler}-$openmpi
			UPPCOMPILED="CHECK"
  		fi

	elif [ $missing -ne 0 ]; then
		echo "Missing at least one binary file in $UPPDIR but others founds ... please check manually"
		exit 1
	else
		echo "All binaries for UPP found. Proceeding."
		UPPCOMPILED="YES"
	fi
}


#~~~~~~~~~~~~~~~~~~~END OF FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

################################################################################
## 			MAIN  PROGRAM
if [ -z "$*" ]; then
	echo "No arguments passed. Usage is :"
	echo "compile_core.sh core PARALLEL OPTIM COMPILER DEBUG_LEVEL OPENMPI"
	echo ""
	
	echo "Compiling which core? ARW or NMM?"
	read core

	echo "Compiling with which parallelisation? SM, DM or SMDM?"
	read parallel

	echo "Compiling with which optimisation? 0, 2 or 3?"
	read optim

	echo "Compiling with which compiler? gcc44, pgf, intel, amd? (gcc44 default)"
	read compiler
	if [ -z "$compiler" ]; then
		compiler=gcc44
	fi
	echo "Compiling with debug level? no_debug, debug, dbg_profiling? (no_debug default)"
	read debuglevel
	if [ -z "$debuglevel" ]; then
		debuglevel="no_debug"
	fi
	echo "Compiling with which openmpi library? openmpi154, openmpi143(openmpi 1.5.4 default)"
	read openmpi
	if [ -z "$openmpi" ]; then
		openmpi="openmpi154"
	fi
	echo "Compiling with which netcdf version? $NETCDFVERSION_LIST (4.1.1 default)"
	read NETCDFVERSION
	if [ -z "$NETCDFVERSION" ]; then
		NETCDFVERSION="4.1.1"
	fi
else 
	core=$1
	parallel=$2
	optim=$3
	compiler=$4
	debuglevel=$5
	openmpi=$6
	NETCDFVERSION=$7
fi

echo "CORE=$core"
echo "Parallel option=$parallel"
echo "Optimisation level=$optim"
echo "Compiler=$compiler"
echo "Debug level=$debuglevel"
echo "OpenMPI Library=$openmpi"
echo "NetCDF Version=$NETCDFVERSION"
debugstring="$debuglevel"
sleep 2

## Sub-Variables declaration	
MODULE=wrf/$core/$compiler/$openmpi/${compiler}-${openmpi}-netcdf-${NETCDFVERSION}

WRFMAINDIR=$WRFTARGET/WRF_${WRFVERSION}.netcdf-$NETCDFVERSION.$compiler.$core
OPENMPIDIR=$SHAREDIR/$openmpi-$compiler
TOOLSDIR=$WRFMAINDIR/tools
WPSDIR=$WRFMAINDIR/WPS
WRFDIR=$WRFMAINDIR/WRFV3
UPPDIR=$WRFMAINDIR/UPPV1.0

echo "Compiling to $WRFMAINDIR .. ok?"
#read answer ; if [ "$answer" != "y" ]; then echo "Aborting." ; exit 1; fi

WRFCONFIG=$WRFPROPER/CONFIG/configure.wrf
WRFFILE=$WRFPROPER/SRC/WRF${WRFVERSION}.TAR.gz

configfile=configure.wrf.$core.$parallel.$compiler.Opt${optim}.${debugstring}.$openmpi

############################### CHECK OPENMPIDIR ############################################

if [ -f $OPENMPIDIR/bin/mpicc ]; then
	echo "OPENMPIDIR ok : $OPENMPIDIR/bin/mpicc = " `ls -lrt $OPENMPIDIR/bin/mpicc` 
else
	#~~
	mycompile openmpi $openmpi $compiler
fi

############################### CHECK TOOLSDIR ############################################

#~~
check_tools and_compile

if [ "$CHECKTOOLS" == "NOK" ] ; then
	check_tools and_exit
elif [ "$CHECKTOOLS" == "OK" ] ; then
	echo "NOMINAL CONDITIONS IN $TOOLSDIR"
else
	echo "What is the value of CHECKTOOLS? CHECKTOOLS=$CHECKTOOLS"
	exit 1
fi

##################### CHECK wrf/$core/$compiler/$openmpi/$core-$openmpi ##################

## Pending... ???  Think to generate it "on the fly"

############################### CHECK WPSDIR ############################################

## Do a first check to see if compilation is needed
check_wrf and_compile

## Do a second check to see if compilation worked
if [ "$WRFCOMPILED" == "CHECK" ]; then
	check_wrf and_exit
fi

############################### CHECK WPSDIR ############################################
#
#	NOTE : WRF must be compiled first as it is used by WPS
#
## Do a first check to see if compilation is needed
check_wps and_compile

## Do a second check to see if compilation worked
if [ "$WPSCOMPILED" == "CHECK" ]; then
	check_wps and_exit
fi


############################### CHECK UPPDIR ############################################
## Do a first check to see if compilation is needed
check_upp and_compile

## Do a second check to see if compilation worked
if [ "$UPPCOMPILED" == "CHECK" ]; then
	check_upp and_exit
fi


exit 1

############################################################################################
# NOTHING BELOW HERE
##
if [ -d $WRFMAINDIR ]; then
	cd $WRFMAINDIR
	cd WRF
else
	echo "$WRFMAINDIR doesnt exist... creating it & untaring version $WRFVERSION from $WRFPROPER/SRC"
	tar xvfz $WRFFILE
	if [ -d WRFV3 ]; then
		mkdir $WRFMAINDIR
		mv WRFV3 $WRFMAINDIR/WRF
		cd $WRFMAINDIR/WRF
	else
		echo "WRFV3 not found inside $WRFFILE"
		exit 1
	fi
fi

if [ ! -f $WRFCONFIG/$configfile ]; then
	echo "$WRFCONFIG/$configfile missing ! Please check!"
	exit 1
else
	cp $WRFCONFIG/$configfile $WRFMAINDIR
fi


#--------init ENV-----------
check_and_load_module $MODULE

case $core in 
	ARW) process="em_real" ;;
	NMM) process="nmm_real" ;;
	*) echo "core undefined. Aborting" ; exit 1 ;;
esac

logfile=$process.$core.$parallel.$compiler.Opt${optim}.$debugstring.$openmpi.log.$$

echo "Make compilation on all available cores? [Y/N]"
read answer 
if [ -z "$answer" ] || [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
	#NCORES=`cat /proc/cpuinfo |grep "cpu cores"|awk '{print $4}'|sort -u`
	NCORES=`grep ^processor /proc/cpuinfo | wc -l`
	COMPILE_OPT=" -j $NCORES "
else
	COMPILE_OPT=" "
fi

echo "Time compilation? [Y/N]"
read answer 
if [ -z "$answer" ] || [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
	COMPILE_PREFIX="time "
else
	COMPILE_PREFIX=""
fi

echo "Clean before compilation? [Y/N]"
read answer 
if [ -z "$answer" ] || [ "$answer" == "Y" ] || [ "$answer" == "y" ]; then
	CLEAN="./clean -a"
else
	CLEAN="echo 'Keeping previously compiled objects'"
fi

set -x 


if  [ -f $configfile ]; then
	echo "Config file exists. Proceeding with compilation"
	$CLEAN
	cp $configfile configure.wrf
	$COMPILE_PREFIX ./compile $COMPILE_OPT $process &> $logfile
else
	echo "Config file $configfile missing in $WRFMAINDIR ... Please review"
fi
