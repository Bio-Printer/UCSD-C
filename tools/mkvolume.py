#!/usr/bin/env python3
"""mkvolume.py -- build TinyC_Volume.zip: TINY-C.BLK, the UCSD volume TINY-C: holding the
Tiny-C compiler (TINYC.CODE, built from its modules), its headers
(NAME.H.TEXT), the library (TCLIB.OBJ), the message file (TCMSGS.TEXT),
the test programs, the compiler's own sources and README.TEXT.

Use it as unit #5 (or any unit), set the prefix to it (F(iler P(refix),
then X(ecute TINYC and answer "Compile what file?" with e.g. SIEVE.
"""
import os, sys, zipfile, subprocess
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from tcrun import build_lib, compile_c, INC
from buildtc import build, MODULES

README = """TINY-C for UCSD Pascal II.0

  X(ecute TINYC            then answer "Compile what file?" with
      NAME                 compile NAME.TEXT, link with TCLIB.OBJ -> NAME.CODE
      /C NAME              compile only -> NAME.OBJ
      /L OUT=A,B,...       link A.OBJ, B.OBJ, ... and TCLIB.OBJ -> OUT.CODE
  X(ecute NAME             runs the program

TCLIB.OBJ is the precompiled C library (only what a program uses is
linked in).  Headers: STDIO.H STDLIB.H STRING.H CTYPE.H MATH.H CONIO.H IO.H FCNTL.H
STDARG.H STDDEF.H LIMITS.H FLOAT.H ASSERT.H.  TCRT.H documents the
runtime helpers the compiler calls (they are in TCLIB.OBJ).  TCMSGS.TEXT
holds the compiler's messages.  Temporary files: TCTEMP.TEXT, TCTEMP.IR.

Set the prefix to this volume first (F(iler, P(refix TINY-C:).

Demo and test programs (NAME.TEXT; compile with X TINYC, answer NAME):
  CALC      a calculator: recursive descent, longs
  GUESS     guess the number: rand, scanf
  BOXES     conio.h: clrscr, gotoxy, getch
  FILEIO    stdio text files, io.h/fcntl.h binary files
  HANOI     towers of Hanoi          QUEENS   eight queens
  SIEVE     primes                   STRINGS  string.h, sprintf, sscanf
  STRUCTS   structs, unions, lists   FUNCPTR  function pointers, qsort
  LONGS     32-bit longs             FLOATS   reals and math.h
  CONTROL   switch, goto, loops
  CMPCODE   compares two code files (checks a rebuilt compiler)

Files: 58 of the directory's 77 entries are used.  A compile adds
NAME.OBJ and NAME.CODE (and TCTEMP.TEXT, TCTEMP.IR once); rebuilding the
compiler needs 15 (12 .OBJ files, TINYC2.CODE, the two temporaries).
Remove the .OBJ and .CODE files you no longer need.

The compiler's own sources are here too (%s,
TC.H PARSE.H).  To rebuild the compiler on the P-System, compile each
module separately, then link them (there is no TC.TEXT: the whole
compiler as one file does not fit in memory):
  X(ecute TINYC   /C MAIN        (and the same for every module)
  X(ecute TINYC   /L TINYC2=%s
TINYC2.CODE comes out identical to TINYC.CODE (apart from its name):
  X(ecute CMPCODE   TINYC.CODE  TINYC2.CODE   -> IDENTICAL

The library's sources are here as well (%s,
LIBINT.H).  Each compiles on the P-System with /C to exactly the
host's object.  TCLIB.OBJ is those objects one after another.  TINYC
links TCLIB.OBJ automatically when it finds it (here or *TCLIB.OBJ),
so to link with rebuilt modules instead, rename TCLIB.OBJ and list
them:  /L PROG=PROG,TCRT,STDIO,STDLIB,STRING,CTYPE,MATH,FLTFMT,...
""" % (' '.join(m.upper() for m in MODULES), ','.join(m.upper() for m in MODULES),
       ' '.join(f[:-2].upper() for f in sorted(os.listdir(os.path.join(ROOT, 'tinyc', 'lib'))) if f.endswith('.c')))


# tests left off the volume (the directory holds 77 files): in tests/ still
SKIP_TESTS = ('demo', 'fcompare')


def main():
    out = os.path.join(ROOT, 'build', 'TINY-C.BLK')
    ucsdvol.main(['new', out, 'TINY-C', '4000'])
    v = ucsdvol.Volume(out)
    code, log = build()
    v.write('TINYC.CODE', open(code, 'rb').read(), 2)
    for f in sorted(os.listdir(INC)):
        if f.endswith('.h'):
            v.write(f.upper() + '.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(INC, f)).read()), 3)
    v.write('TCLIB.OBJ', open(build_lib(), 'rb').read(), 5)
    v.write('TCMSGS.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(INC, 'tcmsgs.txt')).read()), 3)
    tests = os.path.join(ROOT, 'tests')
    for f in sorted(os.listdir(tests)):
        if f.endswith('.c') and f[:-2] not in SKIP_TESTS:
            v.write(f[:-2].upper()[:10] + '.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(tests, f)).read()), 3)
    src = os.path.join(ROOT, 'tinyc')
    for m in MODULES:
        v.write(m.upper() + '.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(src, m + '.c')).read()), 3)
    for h in ('tc.h', 'parse.h'):
        v.write(h.upper() + '.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(src, h)).read()), 3)
    lib = os.path.join(src, 'lib')
    for f in sorted(os.listdir(lib)):
        if f.endswith('.c') or f.endswith('.h'):
            n = f[:-2].upper() + ('.TEXT' if f.endswith('.c') else '.H.TEXT')
            v.write(n, ucsdvol.text_to_ucsd(open(os.path.join(lib, f)).read()), 3)
    v.write('README.TEXT', ucsdvol.text_to_ucsd(README), 3)
    # CMPCODE compares code files: checks a rebuilt compiler
    tmp = os.path.join(ROOT, 'build', 'volume_tmp')
    os.makedirs(tmp, exist_ok=True)
    v.write('CMPCODE.TEXT', ucsdvol.text_to_ucsd(open(os.path.join(ROOT, 'verify', 'cmpcode.c')).read()), 3)
    for path in (os.path.join(ROOT, 'verify', 'cmpcode.c'),):
        base, code = compile_c(path, tmp)
        v.write(base + '.CODE', open(code, 'rb').read(), 2)
    for d, n in ((os.path.join(ROOT, 'verify'), 'cmpcode'),):
        for ext in ('.i', '.ir', '.obj'):                  # compile_c's temporaries
            if os.path.exists(os.path.join(d, n + ext)):
                os.remove(os.path.join(d, n + ext))
    v.save()
    nfiles = len(ucsdvol.Volume(out).entries)
    print(nfiles, 'files on TINY-C:')
    if nfiles > 58:     # 77 in a directory: room for a self-compile (15) and a program
        raise SystemExit('too many files for a self-compile on the volume')
    z = os.path.join(ROOT, 'TinyC_Volume.zip')
    with zipfile.ZipFile(z, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.write(out, 'TINY-C.BLK')
    print('wrote', z, os.path.getsize(z), 'bytes')


if __name__ == '__main__':
    main()
