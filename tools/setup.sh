#!/bin/bash
# setup.sh -- unpack the P-System emulator and disk images from the zips in
# the repository root into build/, and build the Linux runner (run_verify)
# from the emulator's own verify/run_verify.cpp.
set -e
cd "$(dirname "$0")/.."
ZIP=UCSD-Pascal---P-Machine_work-v1.88.zip
PM=build/pm/UCSD-Pascal---P-Machine_work
mkdir -p build
if [ ! -f $PM/UCSDPascal/PSystemEngine.cpp ] || [ $ZIP -nt $PM/UCSDPascal/PSystemEngine.cpp ]; then
    rm -rf build/pm build/run_verify
    mkdir -p build/pm && (cd build/pm && unzip -q -o ../../$ZIP)
    touch $PM/UCSDPascal/PSystemEngine.cpp
fi
if [ ! -f build/img/Big_Disk.BLK ]; then
    mkdir -p build/img && (cd build/img && unzip -q -o ../../Usefull_System_Disk_Images.zip)
fi
mkdir -p build/data
if [ ! -f build/data/Big_Disk.BLK ]; then
    cp build/img/Big_Disk.BLK build/data/Big_Disk.BLK
    # the image still holds a scratch file M that fills the volume
    python3 tools/ucsdvol.py rm build/data/Big_Disk.BLK M
fi
# P-Code mode boots natively and never executes pascal.bin (the Z80 loader);
# LoadFiles only needs the file to exist.
# pascal.bin (the Z80 loader) is needed only in Z80 mode; P-Code mode boots natively
if [ -f pascal.bin ]; then cp pascal.bin build/data/pascal.bin
else [ -f build/data/pascal.bin ] || head -c 4096 /dev/zero > build/data/pascal.bin; fi
if [ ! -x build/run_verify ] || [ $PM/UCSDPascal/PSystemEngine.cpp -nt build/run_verify ]; then
    g++ -std=c++17 -O2 -w -I $PM/verify/linux-shim -I $PM/UCSDPascal \
        -o build/run_verify $PM/verify/run_verify.cpp \
        $PM/UCSDPascal/PSystemEngine.cpp $PM/UCSDPascal/z80.cpp -lpthread
fi
echo "setup OK"
