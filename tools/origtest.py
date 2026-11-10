#!/usr/bin/env python3
"""origtest.py -- MASTER:/ORIG/MAKEFILE on the P-System (tools/mkmaster.py: build/MASTER.BLK):
from the shell, make -f master:/orig/makefile mounts each source disk of UCSD Pascal II.0
(MOUNT: emulator 2.14; the OS's on #5, then UCSD-C again) and compiles its programs with PC
into MASTER:/ORIG/CODE; then again: every one up to date.  Each code file must be the one the
host's PC makes of the same sources (UCSD-Pascal-compiler-written-in-C's build/pc and
tools/compare.py: what the code file defines, but for the bytes the compiler never sets).

  origtest.py [DISK ...]      (DISK: U132A ...; default all of them)

Disks: #4 BIGGY (mkbiggy.py), #5 UCSD-C, #9 MASTER, #10 the source disks in turn, #11
TOOLS, #12 PASCAL-C (its build/PASCAL-C.BLK: ../ucsd-pascal-compiler-written-in-c or
$PASCALC), #13 SOURCE; all in one folder, the run's own (MOUNT looks there).  The source
disks: UCSD-Pascal-Volumes' BLK_format ($VOLUMES).  Uses PSYS_MODE (native or z80)."""
import os, re, shutil, subprocess, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from psys import ensure_setup, BUILD, shell_script, shell_transcript
from mkmaster import ORIG, BLK
PASCALC = os.environ.get('PASCALC', os.path.join(os.path.dirname(ROOT), 'ucsd-pascal-compiler-written-in-c'))
sys.path.insert(0, os.path.join(PASCALC, 'tools'))
os.environ.setdefault('UCSDC', ROOT)
os.environ.setdefault('VOLUMES', os.path.dirname(BLK))
from compare import regions, differences, put


def host(image, src, fill):
    """the host's PC on the disk's files (and BIGGY's SYSTEM.LIBRARY): the code file"""
    d = tempfile.mkdtemp(prefix='orighost_')
    v = ucsdvol.Volume(os.path.join(BLK, image + '.BLK'))
    for e in v.entries:
        put(d, e[3], v.read(e[3])[0])
    if not os.path.exists(os.path.join(d, 'SYSTEM.LIBRARY')):
        put(d, 'SYSTEM.LIBRARY', ucsdvol.Volume(os.path.join(BUILD, 'BIGGY.BLK')).read('SYSTEM.LIBRARY')[0])
    subprocess.run([os.path.join(PASCALC, 'build', 'pc'), src + '.TEXT', 'OUT.CODE'], cwd=d, capture_output=True,
                   env=dict(os.environ, PCFILL=str(fill)), timeout=600)
    p = os.path.join(d, 'OUT.CODE')
    got = open(p, 'rb').read() if os.path.exists(p) else None
    shutil.rmtree(d, True)
    return got


def main(args):
    ensure_setup()
    disks = [o for o in ORIG if not args or o[0] in args]
    mode = os.environ.get('PSYS_MODE', 'native')
    d = tempfile.mkdtemp(prefix='origtest_')
    for v in ('UCSD-C', 'TOOLS', 'MASTER', 'SOURCE'):
        shutil.copy(os.path.join(BUILD, v + '.BLK'), d)
    shutil.copy(os.path.join(PASCALC, 'build', 'PASCAL-C.BLK'), d)
    for key, image, unit, progs, what in ORIG:
        shutil.copy(os.path.join(BLK, image + '.BLK'), d)
    data = os.path.join(d, 'data')
    os.makedirs(data)
    for f in os.listdir(os.path.join(BUILD, 'data')):
        shutil.copy(os.path.join(BUILD, 'data', f), data)
    shutil.copy(os.path.join(BUILD, 'BIGGY.BLK'), os.path.join(data, 'Big_Disk.BLK'))
    goal = ' '.join(k for k, i, u, p, w in disks) if args else ''
    cmd = ('make -f master:/orig/makefile ' + goal).strip()
    L = ['WAIT "Command:"', 'TYPE "S"', 'WAIT "shell> "', 'TYPE "%s\\r"' % cmd, 'WAIT "> MAKE -f MASTER:/ORIG/%s"' % disks[-1][0],
         'WAIT "shell> "', 'TYPE "%s\\r"' % cmd, 'WAIT "> MAKE -f MASTER:/ORIG/%s"' % disks[-1][0], 'WAIT "shell> "',
         'TYPE "mount\\r"', 'WAIT "shell> "', 'TYPE "bye\\r"', 'WAIT "Command:"']
    sp = os.path.join(d, 'orig.script')
    open(sp, 'w').write(shell_script('\n'.join(L) + '\n'))
    # (the PC's clock, as a user has it: without it a new file gets the system's 1979 date, older than
    # sources dated since)
    env = dict(os.environ, VERIFY_HOSTCLOCK='2026-11-07T12:00:00', VERIFY_UNIT10=os.path.join(d, disks[0][1] + '.BLK'), VERIFY_UNIT11=os.path.join(d, 'TOOLS.BLK'),
               VERIFY_UNIT12=os.path.join(d, 'PASCAL-C.BLK'), VERIFY_UNIT13=os.path.join(d, 'SOURCE.BLK'))
    # (the work directory is d: #5's and #9's copies there, beside the other images)
    r = subprocess.run([os.path.join(BUILD, 'run_verify'), data, os.path.join(d, 'UCSD-C.BLK'), os.path.join(d, 'MASTER.BLK'),
                        sp, mode, d, '', '7200'], capture_output=True, text=True, env=env)
    tp = os.path.join(d, 'transcript.txt')
    tr = shell_transcript(open(tp, encoding='latin1').read()).replace('\r', '\n') if os.path.exists(tp) else ''
    tr = re.sub(r'\n+', '\n', tr)
    i = tr.find('shell> ' + cmd, tr.find('shell> ' + cmd) + 10)
    first, second = tr[:i], tr[i:]
    master = ucsdvol.Volume(os.path.join(d, 'VERIFY_COMPASM.BLK')).sub('ORIG').sub('CODE')
    checks = [('the script completed', 'VERIFY SCRIPT COMPLETED' in r.stdout),
              ('no recipe failed', '@: stopped' not in tr and 'make: ***' not in tr)]
    for key, image, unit, progs, what in disks:
        for src, code in progs:
            got = master.read(code)[0] if master.find(code) else None
            ref, ref2 = host(image, src, 0), host(image, src, 0xEE)
            ok = got is not None and ref is not None and len(got) == len(ref)
            if ok:
                inside = set(j for a, b in regions(ref) for j in range(a, b)) | set(range(256, 336))
                unset = [j for j in range(len(ref)) if ref2 is not None and j < len(ref2) and ref[j] != ref2[j] and j in inside]
                diffs = differences(got, ref, unset)
                ok = not diffs
            checks.append(('%s: %s (%s), the host\'s PC\'s%s' % (key, code, src, '' if got else ': NOT MADE'), ok))
    checks.append(('again: every one up to date (no PC run)', '> PC ' not in second
                   and second.count("Nothing to be done for 'all'") == len(disks)))
    m = tr[tr.rfind('shell> mount'):]
    checks.append(('#5 has UCSD-C again, the prefix on it', re.search(r'#5 +UCSD-C', m) is not None and 'UCSD-C:> mount' in open(tp, encoding='latin1').read()))
    bad = [n for n, g in checks if not g]
    if bad:
        print(tr[-4000:])
    for n, g in checks:
        print('%-5s %s' % ('ok' if g else 'FAIL', n))
    print('orig test (%s): %s   (work: %s)' % (mode, 'FAILED' if bad else 'PASSED', d))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
