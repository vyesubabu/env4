function build_modulefile() {

    TEMPLATE=$MODULESDIR/template

    mkdir -p $MODULESDIR/$util/
    
    cat $TEMPLATE | sed -e "s:__UTIL__:$util:g" -e "s:__UTILVERSION__:$version:g" -e "s:__UTILVERSIONDIR__:$UTILVERSIONDIR:g" -e "s:__NEEDED_MODULES__:${NEEDED_MODULES}:g" > $MODULESDIR/$util/$version

    echo ""
    echo ""
    echo " module file is now in $MODULESDIR/$util/$version"
    echo ""
    echo ""

}


function select_commands() {

PACKAGE=$1
case $PACKAGE in

    "zlib-1.2.11")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        NEEDED_MODULES=""
        UTILVERSIONDIR=${APPDIR}/$util/$version
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR}"
        MAKE_CMD="make"
        MAKEINSTALL_CMD="make install"
    ;;
        "szip-2.1.1")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load gcc/4.8.4"
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR}"
        MAKE_CMD="make; make check"
        MAKEINSTALL_CMD="make install"
    ;;
        "hdf5-1.10.2")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4\n module load szip/2.1.1\n module load zlib/1.2.11"
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} --enable-fortran --enable-cxx --with-szlib=$APPDIR/szip/2.1.1"
        MAKE_CMD="make "
        MAKEINSTALL_CMD="make install ; make check-install"
    ;;
        "curl-7.59.0")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4"
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} "
        MAKE_CMD="make "
        MAKEINSTALL_CMD="make install "
    ;;

        "netcdf-c-4.6.1")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 3` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4\nmodule load hdf5/1.10.2\nmodule load szip/2.1.1\nmodule load zlib/1.2.11\nmodule load curl/7.59.0"
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR}  --with-zlib=$APPDIR/szip/1.2.11 --with-szlib=$APPDIR/szip/2.1.1"
        MAKE_CMD="make "
        MAKEINSTALL_CMD="make check install"
        export CPPFLAGS="-I${APPDIR}/curl/7.59.0/include -I${APPDIR}/hdf5/1.10.2/include -I${APPDIR}/szip/2.1.1/include -I${APPDIR}/zlib/1.2.11/include"
        export LDFLAGS="-L${APPDIR}/curl/7.59.0/lib -L${APPDIR}/hdf5/1.10.2/lib -L${APPDIR}/szip/2.1.1/lib -L${APPDIR}/zlib/1.2.11/lib"
    ;;

        "cdo-1.9.3")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4\nmodule load hdf5/1.10.2\nmodule load szip/2.1.1\nmodule load zlib/1.2.11\nmodule load curl/7.59.0"
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR}  --with-netcdf=$APPDIR/netcdf/4.6.1 --with-szlib=$APPDIR/szip/2.1.1 --with-curl=$APPDIR/curl/7.59.0"
        MAKE_CMD="make "
        MAKEINSTALL_CMD="make install"
#        export CPPFLAGS="-I${APPDIR}/curl/7.59.0/include -I${APPDIR}/hdf5/1.10.2/include -I${APPDIR}/szip/2.1.1/include -I${APPDIR}/zlib/1.2.11/include"
#        export LDFLAGS="-L${APPDIR}/curl/7.59.0/lib -L${APPDIR}/hdf5/1.10.2/lib -L${APPDIR}/szip/2.1.1/lib -L${APPDIR}/zlib/1.2.11/lib"
    ;;
        "yasm-git")
        PATH2SRC=$SRCDIR/GIT/yasm
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4"
        PRECONFIGURE="./autogen.sh"
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} "
        MAKE_CMD="make "
        MAKE_TEST=""
        MAKEINSTALL_CMD="make install"
        ;;

        "lame-3.100")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4\nmodule load yasm/git"
        PRECONFIGURE=""
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} --enable-mp3x "
        MAKE_CMD="make "
        MAKE_TEST=""
        MAKEINSTALL_CMD="make install"
        ;;

        "ffmpeg-git")
        PATH2SRC=$SRCDIR/GIT/ffmpeg
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4\nmodule load yasm/git\nmodule load lame/3.100"
        PRECONFIGURE=""
        #CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} --enable-libmp3lame --enable-shared --disable-mmx --arch=x86_64 --extra-ldflags=-L/cm/shared/client_config/v4.0/apps/lame/3.100/lib --extra-cflags=-I/cm/shared/client_config/v4.0/apps/lame/3.100/include"
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} --enable-libmp3lame --enable-shared --extra-ldflags=-L/cm/shared/client_config/v4.0/apps/lame/3.100/lib --extra-cflags=-I/cm/shared/client_config/v4.0/apps/lame/3.100/include"
        MAKE_CMD="make "
        MAKE_TEST=""
        MAKEINSTALL_CMD="make install"
    ;;
        "gdal-2.3.0")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4"
        PRECONFIGURE=""
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} "
        MAKE_CMD="make "
        MAKE_TEST=""
        MAKEINSTALL_CMD="make install"

    ;;

        "jasper-1.900.1")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4"
        PRECONFIGURE=""
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} --enable-shared "
        MAKE_CMD="make "
        MAKE_TEST=""
        MAKEINSTALL_CMD="make install"

    ;;
        "libpng-1.6.34")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4\nmodule load zlib/1.2.11\n"
        PRECONFIGURE=""
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR} "
        MAKE_CMD="make "
        MAKE_TEST="make check"
        MAKEINSTALL_CMD="make install"
        export CPPFLAGS="-I${APPDIR}/zlib/1.2.11/include"
        export LDFLAGS="-L${APPDIR}/zlib/1.2.11/lib"
        export LD_LIBRARY_PATH="${APPDIR}/zlib/1.2.11/lib:$LD_LIBRARY_PATH"

    ;;

        "eccodes-2.7.3-Source")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4"
        module load jasper/1.900.1
        module load libpng/1.6.34
        #echo "LDLIB=$LD_LIBRARY_PATH"
        #sleep 2
        [[ -d $PATH2SRC/build ]] || mkdir $PATH2SRC/build 
        PRECONFIGURE="cd $PATH2SRC/build "
        ## NOK
        CONFIGURE_CMD="cmake ../ -DCMAKE_INSTALL_PREFIX=$UTILVERSIONDIR -DENABLE_NETCDF=ON \
            -DHDF5_LIBRARIES=$APPDIR/hdf5/1.10.2/lib -DHDF5_INCLUDE_DIRS=$APPDIR/hdf5/1.10.2/include \        
            -DJPEG_LIBRARIES=$APPDIR/jasper/1.900.1/lib \
            -DJASPER_LIBRARIES=$APPDIR/jasper/1.900.1/lib -DJASPER_INCLUDE_DIR=$APPDIR/jasper/1.900.1/include \
            -DNETCDF_PATH=$APPDIR/netcdf/4.6.1 -DENABLE_ECCODES_THREADS=ON -DENABLE_JPG=ON \
            -DENABLE_PNG=ON -DPNG_LIBRARIES=$APPDIR/libpng/1.6.34/lib -DPNG_INCLUDE_DIR=$APPDIR/libpng/1.6.34/include "
        CONFIGURE_CMD="cmake ../ -DCMAKE_INSTALL_PREFIX=$UTILVERSIONDIR -DENABLE_NETCDF=ON \
                        -DNETCDF_PATH=$APPDIR/netcdf/4.6.1 -DENABLE_ECCODES_THREADS=ON -DENABLE_JPG=ON \
                        -DENABLE_PNG=ON"
        MAKE_CMD="make "
        MAKE_TEST="ctest "
        MAKEINSTALL_CMD="make install"
    ;;
        "grib_api-1.12.3")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4"
 #       PRECONFIGURE="./autogen.sh"
        PRECONFIGURE=""
        CONFIGURE_CMD="./configure --prefix=${UTILVERSIONDIR}  --with-jasper=$APPDIR/jasper/1.900.1"
        MAKE_CMD="make "
        MAKE_TEST=""
        MAKEINSTALL_CMD="make install"
        ;;

        "grib_api-1.26.1-Source")
        PATH2SRC=$SRCDIR/$PACKAGE
        util=`echo $PACKAGE | cut -d "-" -f 1` 
        version=`echo $PACKAGE | cut -d "-" -f 2` 
        UTILVERSIONDIR=${APPDIR}/$util/$version
        NEEDED_MODULES="module load taskcenter/v4.0\nmodule load gcc/4.8.4"
        #module load jasper/1.900.1
        #module load libpng/1.6.34
        #echo "LDLIB=$LD_LIBRARY_PATH"
        #sleep 2
        #[[ -d $PATH2SRC/build ]] || mkdir $PATH2SRC/build 
        rm -rf $PATH2SRC/build ; mkdir $PATH2SRC/build

        PRECONFIGURE="cd $PATH2SRC/build "
        ## OK
        CONFIGURE_CMD="ccmake $PATH2SRC -DCMAKE_INSTALL_PREFIX=$UTILVERSIONDIR \
            -DHDF5_LIBRARIES=$APPDIR/hdf5/1.10.2/lib -DHDF5_INCLUDE_DIRS=$APPDIR/hdf5/1.10.2/include\
            -DJPEG_LIBRARIES=$APPDIR/jasper/1.900.1/lib \
            -DJASPER_LIBRARIES=$APPDIR/jasper/1.900.1/lib -DJASPER_INCLUDE_DIR=$APPDIR/jasper/1.900.1/include \
            -DNETCDF_PATH=$APPDIR/netcdf/4.6.1 -DENABLE_ECCODES_THREADS=ON -DENABLE_JPG=OFF"
        MAKE_CMD="make "
        MAKE_TEST="ctest "
        MAKEINSTALL_CMD="make install"
    ;;




    *)
        echo "Unknown package $PACKAGE"
        exit 1
    ;;
esac
}

MAIN_CLIENT_CONFIG=/cm/shared/client_config/v4.0
APPDIR=$MAIN_CLIENT_CONFIG/apps
MODULESDIR=$MAIN_CLIENT_CONFIG/modulefiles
SRCDIR=/root/SRC/env4.0/

## Please create this module:   taskcenter/v4.0
#  in order to generate the environment properly

module load gcc/4.8.4
module load taskcenter/v4.0

## NB
#
#  CDO : requires netcdf, hdf5, jpeg, png, grib, curl
#  Should have : 
#which cdo
#/usr/bin/cdo
#cdo -V
#Climate Data Operators version 1.7.0 (http://mpimet.mpg.de/cdo)
#Compiler: gcc -g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wall -pedantic -fPIC -fopenmp
#version: gcc (Ubuntu 5.3.1-9ubuntu2) 5.3.1 20160220
#Features: DATA PTHREADS OpenMP4 HDF5 NC4/HDF5/threadsafe OPeNDAP SZ Z UDUNITS2 PROJ.4 MAGICS CURL FFTW3 SSE2
#Libraries: HDF5/1.8.16 proj/4.92 curl/7.47.0
#Filetypes: srv ext ieg grb grb2 nc nc2 nc4 nc4c
#CDI library version : 1.7.0
#GRIB_API library version : 1.14.4
#netCDF library version : 4.4.0 of Mar 29 2016 11:41:40 $
#HDF5 library version : 1.8.16
#SERVICE library version : 1.4.0
#EXTRA library version : 1.4.0
#IEG library version : 1.4.0
#FILE library version : 1.8.2




#  ECCODES : requires netcdf, hdf5, libpng, jasper, curl, 
#  NETCDF : requires hdf5,curl
#  HDF5 :   requires szlib, zlib
#  FFMPEG :   requires yasm, lame
#  GRIB_API : requires jasper
PACKAGES2BUILD="szip-2.1.1    "
PACKAGES2BUILD="zlib-1.2.11    "
PACKAGES2BUILD="hdf5-1.10.2    "
PACKAGES2BUILD="curl-7.59.0 "
PACKAGES2BUILD="netcdf-c-4.6.1  "
PACKAGES2BUILD="cdo-1.9.3  "
PACKAGES2BUILD="jasper-1.900.1 "
PACKAGES2BUILD="libpng-1.6.34 "
PACKAGES2BUILD="eccodes-2.7.3-Source  "
PACKAGES2BUILD="yasm-git  "
PACKAGES2BUILD="lame-3.100 "
PACKAGES2BUILD="ffmpeg-git  "
PACKAGES2BUILD="gdal-2.3.0"

PACKAGES2BUILD="grib_api-1.12.3"
PACKAGES2BUILD="grib_api-1.26.1-Source"




P2B=$PACKAGES2BUILD


for pack in $P2B; do
    
    set -x
    #~~
    select_commands $pack

    cd $PATH2SRC

    set -e
    $PRECONFIGURE

    $CONFIGURE_CMD

    $MAKE_CMD
    
    $MAKE_TEST

    $MAKEINSTALL_CMD
    
    set +e
    echo ""
    echo "finished installing $pack in $APPDIR"
    sleep 2


    #~~
    build_modulefile

done
