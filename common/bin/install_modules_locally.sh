MODULES_SRCDIR=/ecfshared/v4.0/SRC/modules-tcl-1.923
LOCALDIR=/ecflocal/v4.0/apps/EnvironmentModules/1.923/

TMPDIR=/tmp/modules.install.$$

[[ -d $LOCALDIR ]] || mkdir -p $LOCALDIR
[[ -d $TMPDIR ]] || mkdir -p $TMPDIR


cp -r $MODULES_SRCDIR/* $TMPDIR

cd $TMPDIR
make clean
./configure --prefix=$LOCALDIR

make 
make install
echo $?

##Linking 
cd /etc/profile.d
ln -sf $LOCALDIR/init/profile*sh .

## Add the ecfshared module
cp -f $MODULES_SRCDIR/ecfshared.module $LOCALDIR/modulefiles/ecfshared


module avail
