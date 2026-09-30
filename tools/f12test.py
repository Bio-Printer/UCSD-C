#!/usr/bin/env python3
"""f12test.py -- run repro/float12/f12test.c (CSP 100..137, 8-byte floating
point) on the P-System in P-Code mode and compare with f12test.expect."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from tcrun import run_c
from runtests import normalize

d = os.path.join(ROOT, 'repro', 'float12')
os.environ.setdefault('PSYS_MODE', 'native')
ok, out, ps, info = run_c(os.path.join(d, 'f12test.c'), timeout=60)
for ext in ('.i', '.ir', '.obj'):
    p = os.path.join(d, 'f12test' + ext)
    if os.path.exists(p):
        os.remove(p)
got = normalize(out).split('\n')
exp = open(os.path.join(d, 'f12test.expect')).read().split('\n')
bad = 0
for i, (a, b) in enumerate(zip(got, exp)):
    if a != b:
        bad += 1
        print('BAD %2d got %-28r want %r' % (i, a, b))
print('%d checks, %d bad%s' % (len(exp) - 1, bad, '' if ok else ' (run did not complete)'))
if not ok:
    print(info[-400:])
sys.exit(1 if bad or not ok else 0)
