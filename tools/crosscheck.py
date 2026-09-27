#!/usr/bin/env python3
"""crosscheck.py [tests...] -- compile each test with the host Tiny-C and
with the Tiny-C running on the P-System; the code files must be identical."""
import os, sys, subprocess
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from selfhost import compile_on_psystem
from tcrun import compile_c

def main(names):
    tests = os.path.join(ROOT, 'tests')
    names = names or sorted(f[:-2] for f in os.listdir(tests) if f.endswith('.c'))
    bad = 0
    for n in names:
        src = os.path.join(tests, n + '.c')
        up = n.upper()[:10]
        ok, tr, ps, info = compile_on_psystem([(up + '.TEXT', src)], up, timeout=300)
        try:
            pcode = ps.get(up + '.CODE')
        except SystemExit:
            print('FAIL  %-10s P-System compile failed: %s' % (n, tr[tr.find('Compiling'):][-300:].replace('\n', ' | ')))
            bad += 1
            continue
        base, hpath = compile_c(src, ps.dir)
        hcode = open(hpath, 'rb').read()
        if pcode == hcode:
            print('SAME  %-10s %d bytes' % (n, len(pcode)))
        else:
            bad += 1
            diffs = [i for i in range(min(len(pcode), len(hcode))) if pcode[i] != hcode[i]]
            print('DIFF  %-10s host %d, P-System %d bytes, first difference at %s' % (n, len(hcode), len(pcode), diffs[:1]))
    print('%d of %d identical' % (len(names) - bad, len(names)))
    return 1 if bad else 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
