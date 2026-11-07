#!/usr/bin/env python3
"""mastertest.py -- MASTER:MAKEFILE on the P-System (tools/mkmaster.py): from the shell,
make -f master:makefile rebuilds everything -- Tiny-C's compiler, library and tools, the demos
and tests, SYS-C:SYSTEM.C, PASCALC:PC.CODE, BC and B2 (their volumes' makefiles, each volume
mounted by MOUNT first) and the original programs (origtest.py's part); then again: nothing
to be done anywhere (no CC, BC, B2 or PC runs).  The parts' results are what their own tests
check (alltest, voltest, UCSD-BASIC's voltest and voltest2, origtest); here: the run, every
part in turn, nothing stopped, and the second run.

Disks, all in the run's folder (MOUNT looks there): #4 BIGGY, #5 TINY-C, #9 MASTER, #10 the
source disks, #11 TOOLS, #12 TCEXTRA, TCTESTS, SYS-C and PASCAL-C in turn, #13 BASIC, BASIC2
and SOURCE.  The volumes: build/ (mkvolume.py, mkmaster.py), UCSD-SYSTEM-C's build/SYS-C.BLK
($SYSTEMC), UCSD-Pascal-compiler-written-in-C's build/PASCAL-C.BLK ($PASCALC), UCSD-BASIC's
build/BASIC.BLK and BASIC2.BLK ($BASIC), UCSD-Pascal-Volumes' source disks ($VOLUMES).  About
9 minutes in P-Code mode with the Harvard layout."""
import os, re, shutil, subprocess, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from psys import ensure_setup, BUILD, shell_script, shell_transcript
from mkmaster import ORIG, BLK
SIB = os.path.dirname(ROOT)
SYSTEMC = os.environ.get('SYSTEMC', os.path.join(SIB, 'ucsd-system-c'))
PASCALC = os.environ.get('PASCALC', os.path.join(SIB, 'ucsd-pascal-compiler-written-in-c'))
BASIC = os.environ.get('BASIC', os.path.join(SIB, 'ucsd-basic'))

PARTS = ['> MAKE -f TINY-C:/SRC/CC/MAKEFILE', '> MAKE -f TINY-C:/SRC/LIB/MAKEFILE', '> MAKE -f TOOLS:/SRC/MAKEFILE',
         '> MOUNT #12 TCEXTRA', '> MAKE -f TCEXTRA:MAKEFILE', '> MOUNT #12 TCTESTS', '> MAKE -f TCTESTS:MAKEFILE',
         '> MOUNT #12 SYS-C', '> MAKE -f SYS-C:MAKEFILE', '> MOUNT #12 PASCAL-C', '> MAKE -f PASCALC:/SRC/MAKEFILE',
         '> MOUNT #13 BASIC', '> MAKE -f BASIC:MAKEFILE', '> MAKE -f BASIC:/TEST/MAKEFILE', '> MOUNT #13 BASIC2',
         '> MAKE -f BASIC2:MAKEFILE', '> MAKE -f BASIC2:/TEST/MAKEFILE', '> MAKE -f MASTER:/ORIG/MAKEFILE',
         '> MAKE -f MASTER:/ORIG/U134', '> MOUNT #5 TINY-C']


def main():
    ensure_setup()
    mode = os.environ.get('PSYS_MODE', 'native')
    d = tempfile.mkdtemp(prefix='mastertest_')
    for v in ('TOOLS', 'MASTER', 'SOURCE', 'TCEXTRA', 'TCTESTS'):
        shutil.copy(os.path.join(BUILD, v + '.BLK'), d)
    shutil.copy(os.path.join(BUILD, 'TINY-C.BLK'), os.path.join(d, 'TINYC0.BLK'))
    os.symlink('VERIFY_SOURCE.BLK', os.path.join(d, 'TINY-C.BLK'))   # (#5's image: MOUNT #5 TINY-C brings it back)
    shutil.copy(os.path.join(SYSTEMC, 'build', 'SYS-C.BLK'), d)
    shutil.copy(os.path.join(PASCALC, 'build', 'PASCAL-C.BLK'), d)
    for b in ('BASIC', 'BASIC2'):
        shutil.copy(os.path.join(BASIC, 'build', b + '.BLK'), d)
    for key, image, unit, progs, what in ORIG:
        shutil.copy(os.path.join(BLK, image + '.BLK'), d)
    data = os.path.join(d, 'data')
    os.makedirs(data)
    for f in os.listdir(os.path.join(BUILD, 'data')):
        shutil.copy(os.path.join(BUILD, 'data', f), data)
    shutil.copy(os.path.join(BUILD, 'BIGGY.BLK'), os.path.join(data, 'Big_Disk.BLK'))
    cmd = 'make -f master:makefile'
    L = ['WAIT "Command:"', 'TYPE "S"', 'WAIT "shell> "', 'TYPE "%s\\r"' % cmd] + ['WAIT "%s"' % p for p in PARTS] + \
        ['WAIT "shell> "', 'TYPE "%s\\r"' % cmd, 'WAIT "> MOUNT #5 TINY-C"', 'WAIT "shell> "', 'TYPE "bye\\r"', 'WAIT "Command:"']
    sp = os.path.join(d, 'master.script')
    open(sp, 'w').write(shell_script('\n'.join(L) + '\n'))
    # (P-Code mode with the Harvard layout and the Z80 interpreter's memory reclaimed, as UCSD-BASIC's
    # tests run: BC's own build needs that memory -- Options > Harvard Mode in the emulator)
    env = dict(os.environ, VERIFY_HARVARD='1', VERIFY_RECLAIM='1', VERIFY_HOSTCLOCK='2026-11-07T12:00:00', VERIFY_UNIT10=os.path.join(d, ORIG[0][1] + '.BLK'),
               VERIFY_UNIT11=os.path.join(d, 'TOOLS.BLK'), VERIFY_UNIT12=os.path.join(d, 'TCEXTRA.BLK'),
               VERIFY_UNIT13=os.path.join(d, 'BASIC.BLK'))
    r = subprocess.run([os.path.join(BUILD, 'run_verify'), data, os.path.join(d, 'TINYC0.BLK'), os.path.join(d, 'MASTER.BLK'),
                        sp, mode, d, '', '7200'], capture_output=True, text=True, env=env)
    tp = os.path.join(d, 'transcript.txt')
    tr = shell_transcript(open(tp, encoding='latin1').read()).replace('\r', '\n') if os.path.exists(tp) else ''
    tr = re.sub(r'\n+', '\n', tr)
    i = tr.find('shell> ' + cmd, tr.find('shell> ' + cmd) + 10)
    first, second = tr[:i], tr[i:]
    pos = [first.find(p) for p in PARTS]
    progs = re.findall(r'> (?:-?)(CC|BC|B2|PC) ', second)
    checks = [('the script completed', 'VERIFY SCRIPT COMPLETED' in r.stdout),
              ('every part in turn', -1 not in pos and pos == sorted(pos)),
              ('nothing stopped', '@: stopped' not in tr and 'make: ***' not in tr and 'no such image' not in tr),
              ('compilers ran the first time (CC, BC, B2, PC)', all('> %s ' % c in first for c in ('CC', 'BC', 'B2', 'PC'))),
              ('again: nothing compiled (%d runs of %s)' % (len(progs), ' '.join(sorted(set(progs))) or 'none'), not progs and i > 0)]
    bad = [n for n, g in checks if not g]
    if bad:
        print(tr[-5000:])
    lw = [l for l in r.stdout.split('\n') if 'VERIFY' in l]
    print(lw[-1:] if lw else r.stdout[-500:])
    for n, g in checks:
        print('%-5s %s' % ('ok' if g else 'FAIL', n))
    print('master test (%s): %s   (work: %s)' % (mode, 'FAILED' if bad else 'PASSED', d))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
