#!/bin/bash
# setup.sh -- unpack the P-System emulator and disk images and build the Linux
# runner (run_verify) from the emulator's own verify/run_verify.cpp.
#
# The emulator comes from the zip in the repository root, or -- when ENGINE_DIR
# is set -- from a checkout of https://github.com/Bio-Printer/UCSD-Pascal_Windows_Emulator:
#     ENGINE_DIR=/path/to/UCSD-Pascal_Windows_Emulator tools/setup.sh
# Calls through function pointers are compiled to CSP 138 (CALLI) by default,
# which needs emulator version 1.91 or later; the v1.88 zip has no CALLI, so
# with it use  tc -z  (TINYC_Z80CALLS=1 for the tools).
set -e
cd "$(dirname "$0")/.."
ZIP=UCSD-Pascal---P-Machine_work-v1.88.zip
PM=build/pm/UCSD-Pascal---P-Machine_work
if [ -n "$ENGINE_DIR" ]; then
    PM="$ENGINE_DIR"
    [ -f "$PM/UCSDPascal/PSystemEngine.cpp" ] || { echo "ENGINE_DIR: no UCSDPascal/PSystemEngine.cpp in $PM"; exit 1; }
    ZIP=/dev/null
fi
mkdir -p build
if [ -z "$ENGINE_DIR" ] && { [ ! -f $PM/UCSDPascal/PSystemEngine.cpp ] || [ $ZIP -nt $PM/UCSDPascal/PSystemEngine.cpp ]; }; then
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
    # an old image holds a scratch file M that fills the volume
    if python3 tools/ucsdvol.py ls build/data/Big_Disk.BLK | grep -q "^  M  "; then
        python3 tools/ucsdvol.py rm build/data/Big_Disk.BLK M
    fi
fi
# P-Code mode boots natively and never executes pascal.bin (the Z80 loader);
# LoadFiles only needs the file to exist.
# pascal.bin (the Z80 loader) is needed only in Z80 mode; P-Code mode boots natively
if [ -f pascal.bin ]; then cp pascal.bin build/data/pascal.bin
else [ -f build/data/pascal.bin ] || head -c 4096 /dev/zero > build/data/pascal.bin; fi
if [ ! -x build/run_verify ] || [ -n "$(find $PM/UCSDPascal $PM/verify -maxdepth 1 \( -name '*.inc' -o -name '*.cpp' -o -name '*.h' \) -newer build/run_verify 2>/dev/null | head -1)" ]; then
    g++ -std=c++17 -O2 -w -I $PM/verify/linux-shim -I $PM/UCSDPascal \
        -o build/run_verify $PM/verify/run_verify.cpp \
        $PM/UCSDPascal/PSystemEngine.cpp $PM/UCSDPascal/z80.cpp -lpthread
fi
echo "setup OK"
