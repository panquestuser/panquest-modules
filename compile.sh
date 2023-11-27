#!/bin/bash
#
#
#

KERNEL_SOURCE="$PWD/QTS_Kernel_5.1.0.20230808/GPL_QTS/src/linux-5.10/"
KSRC="$KERNEL_SOURCE"
KHOME="$PWD"

CROSS_COMPILE="$KHOME/QTS_Kernel_5.1.0.20230808/toolkit/x86_64-QNAP-linux-gnu/cross-tools/bin/x86_64-QNAP-linux-gnu-"
CFLAGS="-I$KHOME/QTS_Kernel_5.1.0.20230808/toolkit/x86_64-QNAP-linux-gnu/fs/include"
LDFLAGS="-I$KHOME/QTS_Kernel_5.1.0.20230808/toolkit/x86_64-QNAP-linux-gnu/fs/lib"
RANLIB="$KHOME/QTS_Kernel_5.1.0.20230808/toolkit/x86_64-QNAP-linux-gnu/cross-tools/bin/x86_64-QNAP-linux-gnu-gcc-ranlib"
LD="$KHOME/QTS_Kernel_5.1.0.20230808/toolkit/x86_64-QNAP-linux-gnu/cross-tools/bin/x86_64-QNAP-linux-gnu-ld.bfd"
CC="$KHOME/QTS_Kernel_5.1.0.20230808/toolkit/x86_64-QNAP-linux-gnu/cross-tools/bin/x86_64-QNAP-linux-gnu-gcc"
LD_LIBRARY_PATH="$KHOME/QTS_Kernel_5.1.0.20230808/toolkit/x86_64-QNAP-linux-gnu/fs/lib"
KSRC="$KHOME/QTS_Kernel_5.1.0.20230808/GPL_QTS/src/linux-5.10"
ARCH=x86_64

### URLS ###
KERNEL_SOURCE1="https://altushost-swe.dl.sourceforge.net/project/qosgpl/QNAP%20NAS%20GPL%20Source/QTS%205.1.0/QTS_Kernel_5.1.0.20230808.tar.gz.0"
KERNEL_SOURCE2="https://altushost-swe.dl.sourceforge.net/project/qosgpl/QNAP%20NAS%20GPL%20Source/QTS%205.1.0/QTS_Kernel_5.1.0.20230808.tar.gz.1"
TOOLKIT="https://master.dl.sourceforge.net/project/qosgpl/QNAP%20NAS%20Tool%20Chains/Cross%20Toolchain%20SDK%20%28x86%29%2020180115.tgz"

if [ ! -d "$KERNEL_SOURCE" ] && [ ! -d "$CFLAGS" ]; then

    wget --quiet "$KERNEL_SOURCE1" -O downloads/KERNEL_SOURCE.tar.gz
    wget --quiet "$KERNEL_SOURCE2" -O downloads/KERNEL_SOURCE2.tar.gz
    wget --quiet "$TOOLKIT" -O downloads/TOOLKIT.tar.gz
    ls -l downloads/*
    echo "Extracting files "
    mkdir -p QTS_Kernel_5.1.0.20230808
    cat downloads/KERNEL_SOURCE2.tar.gz >>downloads/KERNEL_SOURCE.tar.gz
    tar xfz downloads/KERNEL_SOURCE.tar.gz -C QTS_Kernel_5.1.0.20230808 GPL_QTS/src/linux-5.10
    tar xfz downloads/TOOLKIT.tar.gz -C QTS_Kernel_5.1.0.20230808
    cp -f $KERNEL_SOURCE/QNAP/x86_64.cfg $KERNEL_SOURCE/.config
    ls -ltr $KERNEL_SOURCE

else

    echo "Compilation environment OK ! Setting compilation environment parameters"

fi

echo "In $PWD and starting compilation..."
echo "Folders : $(ls -ltr)"
cd src
#find . -exec touch {} \;
#find $KERNEL_SOURCE -exec touch {} \;
PARMS="$(cat defines.panquest | xargs)"
#PARMS+="$(cat $KERNEL_SOURCE/.config | xargs)"
echo "PARMS: $PARMS"
make -j$(nproc) -C $KSRC M=$(pwd) ${PARMS} modules
cd ../

find . -name "*.ko" -exec strip --strip-debug {} \;
mkdir -p compiled-modules
find src -name "*.ko" -exec cp {} compiled-modules/ \;

echo "Clearing compilation sources"
find src -name "*.ko" -exec rm -f {} \;
find src -name "*.o" -exec rm -f {} \;
find src -name "*.cmd" -exec rm -f {} \;
find src -name "*.mod.c" -exec rm -f {} \;
find src -name "*.mod" -exec rm -f {} \;
find src -name "modules.order" -exec rm -f {} \;
find src -name "Module.symvers" -exec rm -f {} \;

VERSION=$(cat VERSION | awk '{print $2}')

cd compiled-modules
tar cvfz ../modules.tar.gz *.ko
sha256sum="$(sha256sum ../modules.tar.gz | awk '{print $1}')"
echo $VERSION >> ../modules.chksum
echo "SHA256SUM $sha256sum" >>../modules.chksum
cd ../
tar tvfz modules.tar.gz
echo "Compiled $(tar tvfz modules.tar.gz | grep ko | wc -l) modules"
cat modules.chksum
echo "Copying modules.tar.gz and modules.chksum to release folder"
mkdir /opt/output/
cp -f modules.tar.gz /opt/output/
cp -f modules.chksum /opt/output/
echo "Compilation done !"
ls -l /opt/output/
