#!/bin/bash
# setup.sh -- unpack the P-System emulator and disk images from the zips in
# the repository root into build/, and build the Linux runner (run_verify).
set -e
cd "$(dirname "$0")/.."
mkdir -p build
if [ ! -f build/pm/UCSDPascal/PSystemEngine.cpp ]; then
    mkdir -p build/pm && (cd build/pm && unzip -q -o ../../UCSD-Pascal---P-Machine_work.zip)
fi
if [ ! -f build/img/Big_Disk.BLK ]; then
    mkdir -p build/img && (cd build/img && unzip -q -o ../../Usefull_System_Disk_Images.zip)
fi
if [ ! -d build/linux-harness ]; then (cd build && unzip -q -o ../linux-harness.zip); fi
mkdir -p build/data
cp --update=none build/img/Big_Disk.BLK build/data/Big_Disk.BLK
# P-Code mode boots natively and never executes pascal.bin (the Z80 loader);
# LoadFiles only needs the file to exist.
[ -f build/data/pascal.bin ] || head -c 4096 /dev/zero > build/data/pascal.bin
if [ ! -x build/run_verify ] || [ build/pm/UCSDPascal/PSystemEngine.cpp -nt build/run_verify ]; then
    g++ -std=c++17 -O2 -w -I tools/runner/linux-shim -I build/pm/UCSDPascal \
        -o build/run_verify tools/runner/run_verify.cpp \
        build/pm/UCSDPascal/PSystemEngine.cpp build/pm/UCSDPascal/z80.cpp -lpthread
fi
echo "setup OK"
