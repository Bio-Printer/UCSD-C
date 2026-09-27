#!/usr/bin/env python3
"""modes.py prog.c -- compile with the host Tiny-C, run in Z80 mode and in
P-Code mode (no memory reclaim) and compare the console output."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from tcrun import run_c

def main(src):
    res = {}
    for mode in ('z80', 'native'):
        os.environ['PSYS_MODE'] = mode
        os.environ['VERIFY_RECLAIM'] = '0'
        ok, out, ps, info = run_c(src, timeout=60)
        res[mode] = (ok, out.replace('\n\n', '\n').strip())
        print('%-6s %s' % (mode, res[mode][1] if ok else 'DID NOT FINISH: ' + info.strip().split('\n')[-1][:100]))
    print('SAME' if res['z80'] == res['native'] else 'DIFFERENT')

if __name__ == '__main__':
    main(sys.argv[1])
