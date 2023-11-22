#!/bin/bash
#
#
#

### URLS ###
URLS="https://altushost-swe.dl.sourceforge.net/project/qosgpl/QNAP%20NAS%20GPL%20Source/QTS%205.1.0/QTS_Kernel_5.1.0.20230808.tar.gz.0 "
URLS+="https://altushost-swe.dl.sourceforge.net/project/qosgpl/QNAP%20NAS%20GPL%20Source/QTS%205.1.0/QTS_Kernel_5.1.0.20230808.tar.gz.1 "
URLS+="https://master.dl.sourceforge.net/project/qosgpl/QNAP%20NAS%20Tool%20Chains/Cross%20Toolchain%20SDK%20%28x86%29%2020180115.tgz "


if [ ! -d "QTS_Kernel_5.1.0.20230808/GPL_QTS" ] && [ ! -d "QTS_Kernel_5.1.0.20230808/x86_64-QNAP-linux-gnu" ] ; then

for url in $URLS
do
file="$(echo $url | awk -F\/ '{print $NF}')"
echo "Downloading $url file $file"
[ ! -f downloads/${file} ] && curl --progress-bar --insecure -iL "$url" -o downloads/${file} || echo "File ${file} already downloaded"
done

echo "Extracting files "

mv downloads/QTS_Kernel_5.1.0.20230808.tar.gz.0 downloads/QTS_Kernel_5.1.0.20230808.tar.gz
cat downloads/QTS_Kernel_5.1.0.20230808.tar.gz.1 >> downloads/QTS_Kernel_5.1.0.20230808.tar.gz
rm downloads/QTS_Kernel_5.1.0.20230808.tar.gz.1

tar xfz downloads/QTS_Kernel_5.1.0.20230808.tar.gz -C QTS_Kernel_5.1.0.20230808 GPL_QTS/src/linux-5.10
tar xfz "downloads/Cross%20Toolchain%20SDK%20%28x86%29%2020180115.tgz" -C QTS_Kernel_5.1.0.20230808

else

echo "Compilation environment OK ! Setting compilation environment parameters"

fi



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

echo "Compiling..."
cd src
find . -exec touch {} \;
#find $KERNEL_SOURCE -exec touch {} \;
PARMS="`cat defines.panquest | xargs`"
echo "PARMS: $PARMS"
make -j`nproc` KSRC=$KSRC -C $KSRC M=`pwd` "${PARMS}" modules
cd ../

find . -name "*.ko" -exec strip --strip-debug {} \;
mkdir -p compiled-modules ; find src -name "*.ko" -exec cp {} compiled-modules/ \;

echo "Clearing compilation sources"
find src -name "*.ko" -exec rm -f {} \;
find src -name "*.o" -exec rm -f {} \;
find src -name "*.cmd" -exec rm -f {} \;
find src -name "*.mod.c" -exec rm -f {} \;
find src -name "*.mod" -exec rm -f {} \;
find src -name "modules.order" -exec rm -f {} \;
find src -name "Module.symvers" -exec rm -f {} \;

