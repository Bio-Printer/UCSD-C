#!/bin/bash
# setup.sh -- unpack the P-System emulator and disk images and build the Linux
# runner (run_verify) from the emulator's own verify/run_verify.cpp.
#
# The emulator comes from a checkout of
# https://github.com/Bio-Printer/UCSD-Pascal_Windows_Emulator beside this repository
# (UCSD-Pascal_Windows_Emulator, any letter case, or its Download ZIP's -main folder),
# or from ENGINE_DIR:
#     ENGINE_DIR=/path/to/UCSD-Pascal_Windows_Emulator tools/setup.sh
set -e
cd "$(dirname "$0")/.."
if [ -z "$ENGINE_DIR" ]; then
    for d in ../UCSD-Pascal_Windows_Emulator ../ucsd-pascal_windows_emulator ../UCSD-Pascal_Windows_Emulator-main \
             ../bio-printer/ucsd-pascal_windows_emulator; do
        [ -f "$d/UCSDPascal/PSystemEngine.cpp" ] && { ENGINE_DIR=$d; break; }
    done
fi
PM="$ENGINE_DIR"
[ -n "$PM" ] && [ -f "$PM/UCSDPascal/PSystemEngine.cpp" ] || {
    echo "setup: no emulator -- clone https://github.com/Bio-Printer/UCSD-Pascal_Windows_Emulator beside this"
    echo "repository, or set ENGINE_DIR=/path/to/it"; exit 1; }
mkdir -p build
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
