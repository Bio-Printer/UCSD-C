#!/usr/bin/env python3
"""mkvolume.py -- build TinyC_Volume.zip: a UCSD volume TINYC: holding the
Tiny-C compiler (TINYC.CODE), its headers (NAME.H.TEXT), the message file
(TCMSGS.TEXT), the test programs and README.TEXT.

Use it as unit #5 (or any unit), set the prefix to it (F(iler P(refix),
then X(ecute TINYC and answer "Compile what file?" with e.g. SIEVE.
"""
import os, sys, zipfile, subprocess
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from tcrun import compile_c, INC

README = """TINY-C for UCSD Pascal II.0

  X(ecute TINYC            then answer: Compile what file? NAME
  (reads NAME.TEXT from the prefix volume, writes NAME.CODE)
  X(ecute NAME             runs the program

Headers: STDIO.H STDLIB.H STRING.H CTYPE.H MATH.H CONIO.H IO.H FCNTL.H
STDARG.H STDDEF.H LIMITS.H FLOAT.H ASSERT.H, and TCRT.H (runtime helpers,
added to every program automatically).  TCMSGS.TEXT holds the compiler's
messages.  Temporary files: TCTEMP.TEXT, TCTEMP.IR, TCTEMP.OBJ.

Test programs: DEMO (compiles on the P-System today), SIEVE HANOI QUEENS STRUCTS CONTROL FUNCPTR LONGS FLOATS
FCOMPARE STRINGS.  Set the prefix to this volume first (F(iler, P(refix).

Current limit: the compile pass has little memory left, so programs that
include STDIO.H do not yet compile ON the P-System (they compile with the
host build of Tiny-C, and the code runs here).
"""


def main():
    out = os.path.join(ROOT, 'build', 'TINYC.BLK')
    ucsdvol.main(['new', out, 'TINYC', '4000'])
    v = ucsdvol.Volume(out)
    base, code = compile_c(os.path.join(ROOT, 'tinyc', 'tc.c'), os.path.join(ROOT, 'build'))
    v.write('TINYC.CODE', open(code, 'rb').read(), 2)
    for f in sorted(os.listdir(INC)):
        if f.endswith('.h'):
            v.write(f.upper() + '.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(INC, f)).read()), 3)
    v.write('TCMSGS.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(INC, 'tcmsgs.txt')).read()), 3)
    tests = os.path.join(ROOT, 'tests')
    for f in sorted(os.listdir(tests)):
        if f.endswith('.c'):
            v.write(f[:-2].upper()[:10] + '.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(tests, f)).read()), 3)
    v.write('README.TEXT', ucsdvol.text_to_ucsd(README), 3)
    v.save()
    z = os.path.join(ROOT, 'TinyC_Volume.zip')
    with zipfile.ZipFile(z, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.write(out, 'TINYC.BLK')
    print('wrote', z, os.path.getsize(z), 'bytes')


if __name__ == '__main__':
    main()
