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
from tcrun import compile_c, build_lib, INC

README = """TINY-C for UCSD Pascal II.0

  X(ecute TINYC            then answer "Compile what file?" with
      NAME                 compile NAME.TEXT, link with TCLIB.OBJ -> NAME.CODE
      /C NAME              compile only -> NAME.OBJ
      /L OUT=A,B,...       link A.OBJ, B.OBJ, ... and TCLIB.OBJ -> OUT.CODE
  X(ecute NAME             runs the program

TCLIB.OBJ is the precompiled C library (only what a program uses is
linked in).  Headers: STDIO.H STDLIB.H STRING.H CTYPE.H MATH.H CONIO.H IO.H FCNTL.H
STDARG.H STDDEF.H LIMITS.H FLOAT.H ASSERT.H, and TCRT.H (runtime helpers,
added to every program automatically).  TCMSGS.TEXT holds the compiler's
messages.  Temporary files: TCTEMP.TEXT, TCTEMP.IR.

Test programs: DEMO (compiles on the P-System today), SIEVE HANOI QUEENS STRUCTS CONTROL FUNCPTR LONGS FLOATS
FCOMPARE STRINGS.  Set the prefix to this volume first (F(iler, P(refix).

Current limit: memory is tight in the compile pass; a program that
includes several of the larger headers (e.g. STRUCTS) may still run out.
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
    v.write('TCLIB.OBJ', open(build_lib(), 'rb').read(), 5)
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
