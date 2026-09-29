#!/usr/bin/env python3
"""mkbiggy.py -- volumes/BIGGY.zip: the emulator's boot volume BIGGY:
(data/Big_Disk.BLK in the P-Machine zip) with Tiny-C installed: TINYC.CODE,
TCLIB.OBJ, TCMSGS.TEXT and the headers (NAME.H).  Tiny-C looks for headers,
TCLIB.OBJ and TCMSGS.TEXT on the boot volume (*) when they are not on the
prefix volume, so programs on any volume compile with X *TINYC.
The 12-byte doubles (CSP 100..137) are in the emulator itself (build it
from UCSD-Pascal---P-Machine_work-v1.88.zip); nothing on the disk is needed
for them."""
import os, sys, zipfile, shutil
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from psys import ensure_setup
from tcrun import build_lib, INC
from buildtc import build

def main():
    ensure_setup()
    src = os.path.join(ROOT, 'build', 'pm', 'UCSD-Pascal---P-Machine_work', 'data', 'Big_Disk.BLK')
    out = os.path.join(ROOT, 'build', 'BIGGY.BLK')
    shutil.copy(src, out)
    v = ucsdvol.Volume(out)
    code, log = build()
    v.write('TINYC.CODE', open(code, 'rb').read(), 2)
    v.write('TCLIB.OBJ', open(build_lib(), 'rb').read(), 5)
    v.write('TCMSGS.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(INC, 'tcmsgs.txt')).read()), 3)
    for f in sorted(os.listdir(INC)):
        if f.endswith('.h'):
            v.write(f.upper(), ucsdvol.text_to_ucsd(open(os.path.join(INC, f)).read()), 3)
    v.save()
    v = ucsdvol.Volume(out)
    lines = ['BIGGY:  %d files  (the boot volume, with Tiny-C added)' % len(v.entries), '']
    for first, last, kind, name, lastbyte, date in v.entries:
        lines.append('  %-15s %6d' % (name, last - first))
    open(os.path.join(ROOT, 'volumes', 'BIGGY.txt'), 'w').write('\n'.join(lines) + '\n')
    with zipfile.ZipFile(os.path.join(ROOT, 'volumes', 'BIGGY.zip'), 'w', zipfile.ZIP_DEFLATED) as z:
        z.write(out, 'Big_Disk.BLK')
    print('volumes/BIGGY.zip: %d files' % len(v.entries))

if __name__ == '__main__':
    main()
