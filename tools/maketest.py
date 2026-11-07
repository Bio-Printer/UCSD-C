#!/usr/bin/env python3
"""maketest.py -- MAKE, TOUCH and DATE (ports/make, ports/touch, ports/date) and files' times
of day, from the shell on BIGGY as mkbiggy.py made it (SYSTEM.C, or SYSTEM.PASCAL with
--pascal: both write a file's time when they close it, OS source revision 1.16), with the
emulator's clock standing at times the script sets (run_verify VERIFY_HOSTCLOCK and CLOCK,
emulator 2.13):

  make                 A.OUT and B.OUT from A.TEXT and B.TEXT (a pattern rule), then
                       ALL.OUT from them: the recipes run by the shell after MAKE ends
  make                 nothing to be done
  touch A.TEXT (later), make
                       only A.OUT and ALL.OUT again; DIR shows the times
  make -q, -n          1 and the commands; then make, make -q: 0
  make fail            a - recipe that fails does not stop the next
  make nosuch          no rule: status 2
  date, date +FMT, date -r, touch -d, -t, -r
  with CC (TINY-C: on unit 9): a program of two modules made; one touched, only it
                       compiled again and the program linked; then up to date
Each file's time is read off the disk image: it must be the clock's at that step.
Uses the mode of PSYS_MODE (native or z80) like the other tools."""
import os, sys, re, shutil, subprocess, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from psys import ensure_setup, BUILD, shell_transcript
from tcrun import compile_c
from difftest import make_text

MAKEFILE = r"""# MAKE's test (tools/maketest.py)
OBJS = A.OUT B.OUT
SRCS := $(OBJS:.OUT=.TEXT)

all : ALL.OUT

ALL.OUT : $(OBJS)
	CAT $^ >ALL.OUT

%.OUT : %.TEXT
	CAT $< >$@

show :
	@ECHO srcs $(SRCS) objs $(patsubst %.OUT,%,$(OBJS)) n $(words $(OBJS))

fail :
	-CAT NOSUCH.TEXT
	ECHO after the failure

.PHONY : all show fail
"""

T0 = '2026-11-07T10:00:00'


def secs(t):
    h, m, s = t[11:].split(':')
    return int(h) * 3600 + int(m) * 60 + int(s) + 1


CCMAKE = r"""# a program of two modules: the built-in %.OBJ rule (CC -C), then the link
HELLO.CODE : MAIN.OBJ UTIL.OBJ
	CC -L $(basename $@)=$(subst $(space),$(comma),$(basename $^))
"""
MAIN_C = ['#include <stdio.h>', 'int twice(int x);', '', 'int main(void)', '{', '    printf("hello %d\\n", twice(21));', '    return 0;', '}']
UTIL_C = ['int twice(int x)', '{', '    return 2 * x;', '}']


def cc_part(data, mode, d):
    """MAKE with CC (TINY-C: on unit 9): two modules compiled and linked; one touched: only it
    compiled again, and the link"""
    work = os.path.join(d, 'CC.BLK')
    ucsdvol.main(['new', work, 'WORK', '800'])
    w = ucsdvol.Volume(work)
    for t in ('make', 'touch'):
        base, code = compile_c(os.path.join(ROOT, 'ports', t, t + '.c'), d, True)
        w.write(base + '.CODE', open(code, 'rb').read(), 2)
    w.write('MAKEFILE.TEXT', make_text(CCMAKE.split('\n')), 3)
    w.write('MAIN.C', make_text(MAIN_C), 3)
    w.write('UTIL.C', make_text(UTIL_C), 3)
    w.save()
    tinyc = os.path.join(d, 'TINY-C.BLK')
    shutil.copy(os.path.join(BUILD, 'TINY-C.BLK'), tinyc)
    L = ['WAIT "Command:"', 'TYPE "S"', 'WAIT "> "', 'TYPE "cd #5\\r"', 'WAIT "> "', 'TYPE "make\\r"', 'WAIT "> "',
         'WAIT "> CC -L HELLO=MAIN,UTIL"', 'WAIT "> "', 'TYPE "hello\\r"', 'WAIT "> "',
         'CLOCK "2026-11-07T11:00:00"', 'TYPE "touch UTIL.C\\r"', 'WAIT "> "', 'TYPE "make\\r"', 'WAIT "> "',
         'WAIT "> CC -L HELLO=MAIN,UTIL"', 'WAIT "> "', 'TYPE "make\\r"', 'WAIT "> "', 'TYPE "bye\\r"', 'WAIT "Command:"']
    sp = os.path.join(d, 'cc.script')
    open(sp, 'w').write('\n'.join(L) + '\n')
    env = dict(os.environ, VERIFY_HOSTCLOCK='2026-11-07T10:30:00')
    r = subprocess.run([os.path.join(BUILD, 'run_verify'), data, work, tinyc, sp, mode, os.path.join(d, 'ccout'), '', '3000'],
                       capture_output=True, text=True, env=env)
    tp = os.path.join(d, 'ccout', 'transcript.txt')
    tr = shell_transcript(open(tp, encoding='latin1').read()).replace('\r', '\n') if os.path.exists(tp) else ''
    tr = re.sub(r'\n+', '\n', tr)
    runs = tr.split('> make\n')
    first = runs[1] if len(runs) > 1 else ''
    second = runs[2] if len(runs) > 2 else ''
    third = runs[3] if len(runs) > 3 else ''
    if 'VERIFY SCRIPT COMPLETED' not in r.stdout:
        print(tr[-3000:])
    return [
        ('cc: the script completed', 'VERIFY SCRIPT COMPLETED' in r.stdout),
        ('cc: make: CC -C MAIN, CC -C UTIL, the link', first.find('> CC -C MAIN') >= 0 and
         first.find('> CC -C MAIN') < first.find('> CC -C UTIL') < first.find('> CC -L HELLO=MAIN,UTIL')),
        ('cc: HELLO runs', 'hello 42' in tr),
        ('cc: UTIL.C touched: only UTIL compiled, and the link', '> CC -C UTIL' in second and '> CC -C MAIN' not in second
         and '> CC -L HELLO=MAIN,UTIL' in second),
        ('cc: then up to date', "'HELLO.CODE' is up to date" in third),
    ]


def main(a):
    ensure_setup()
    pascal = '--pascal' in a
    mode = os.environ.get('PSYS_MODE', 'native')
    d = tempfile.mkdtemp(prefix='maketest_')
    data = os.path.join(d, 'data')
    os.makedirs(data)
    for f in os.listdir(os.path.join(BUILD, 'data')):
        shutil.copy(os.path.join(BUILD, 'data', f), data)
    shutil.copy(os.path.join(BUILD, 'BIGGY.BLK'), os.path.join(data, 'Big_Disk.BLK'))
    if pascal:                          # without SYSTEM.C the boot takes SYSTEM.PASCAL
        b = ucsdvol.Volume(os.path.join(data, 'Big_Disk.BLK'))
        b.remove('SYSTEM.C')
        b.save()
    work = os.path.join(d, 'WORK.BLK')
    ucsdvol.main(['new', work, 'WORK', '800'])
    w = ucsdvol.Volume(work)
    for t in ('make', 'cat', 'echo', 'touch', 'date'):
        base, code = compile_c(os.path.join(ROOT, 'ports', t, t + '.c'), d, True)
        w.write(base + '.CODE', open(code, 'rb').read(), 2)
    w.write('MAKEFILE.TEXT', make_text(MAKEFILE.split('\n')), 3)
    w.write('A.TEXT', make_text(['alpha 1', 'alpha 2']), 3)
    w.write('B.TEXT', make_text(['beta']), 3)
    w.save()
    spare = os.path.join(d, 'SPARE.BLK')
    ucsdvol.main(['new', spare, 'SPARE', '100'])
    steps = []                          # (clock, command)
    steps.append((None, 'cd #5'))
    steps.append((None, 'make'))
    steps.append((None, 'make'))
    steps.append(('2026-11-07T10:05:00', 'touch A.TEXT'))
    steps.append((None, 'make -q'))
    steps.append((None, 'make -n'))
    steps.append(('2026-11-07T10:06:30', 'make'))
    steps.append((None, 'make -q'))
    steps.append((None, 'dir *.OUT'))
    steps.append((None, 'make show'))
    steps.append((None, 'make fail'))
    steps.append((None, 'make nosuch'))
    steps.append(('2026-11-08T23:59:58', 'date'))
    steps.append((None, 'date +%F_%T_%a_%j'))
    steps.append((None, 'date -r ALL.OUT'))
    steps.append((None, 'touch -d 2026-01-02T03:04:05 B.TEXT'))
    steps.append((None, 'touch -t 202512312359.59 X.TEXT'))
    steps.append((None, 'touch -r B.TEXT Y.TEXT'))
    L = ['WAIT "Command:"', 'TYPE "S"', 'WAIT "> "']
    for clock, c in steps:
        if clock:
            L.append('CLOCK "%s"' % clock)
        L += ['TYPE "%s\\r"' % c, 'WAIT "> "']
    L += ['TYPE "bye\\r"', 'WAIT "Command:"']
    sp = os.path.join(d, 'make.script')
    open(sp, 'w').write('\n'.join(L) + '\n')
    env = dict(os.environ, VERIFY_HOSTCLOCK=T0)
    r = subprocess.run([os.path.join(BUILD, 'run_verify'), data, work, spare, sp, mode, os.path.join(d, 'out'), '', '3000'],
                       capture_output=True, text=True, env=env)
    tp = os.path.join(d, 'out', 'transcript.txt')
    tr = shell_transcript(open(tp, encoding='latin1').read()).replace('\r', '\n') if os.path.exists(tp) else ''
    tr = re.sub(r'\n+', '\n', tr)
    v = ucsdvol.Volume(os.path.join(d, 'out', 'VERIFY_SOURCE.BLK'))

    def stamp(n):
        if not v.find(n):
            return None
        date, s = v.stamp(n)
        return '%02d-%02d-%02d %s' % ((date >> 9) & 127, date & 15, (date >> 4) & 31,
                                      '%02d:%02d:%02d' % ((s - 1) // 3600, (s - 1) // 60 % 60, (s - 1) % 60) if s else 'none')

    def part(cmd, k=0):
        """the transcript after the k-th "> cmd" (to the next prompt line typed by the script)"""
        i = -1
        for _ in range(k + 1):
            i = tr.find('> ' + cmd + '\n', i + 1)
            if i < 0:
                return ''
        j = i + len(cmd) + 3
        nxt = [tr.find('> ' + c2 + '\n', j) for c, c2 in steps if tr.find('> ' + c2 + '\n', j) > 0]
        return tr[j:min(nxt) if nxt else len(tr)]

    m1 = part('make', 0)
    m2 = part('make', 1)
    m3 = part('make', 2)
    checks = [
        ('the script completed', 'VERIFY SCRIPT COMPLETED' in r.stdout),
        ('make: A.OUT, B.OUT, then ALL.OUT', m1.find('> CAT A.TEXT >A.OUT') < m1.find('> CAT B.TEXT >B.OUT') < m1.find('> CAT A.OUT B.OUT >ALL.OUT')
         and m1.find('> CAT A.TEXT >A.OUT') >= 0),
        ('ALL.OUT (a data file, A.OUT then B.OUT, whole blocks): A.TEXT and B.TEXT', v.find('ALL.OUT') is not None
         and v.read('ALL.OUT')[0].startswith(b'alpha 1\nalpha 2\n') and v.read('ALL.OUT')[0][512:517] == b'beta\n'),
        ('make again: nothing to be done', "Nothing to be done for 'all'" in m2 and 'CAT' not in m2),
        ('touch A.TEXT: make -q says 1', '[exit status 1]' in part('make -q', 0)),
        ('make -n: the two commands, nothing run', 'CAT A.TEXT >A.OUT' in part('make -n') and 'CAT B.TEXT' not in part('make -n')
         and 'CAT A.OUT B.OUT >ALL.OUT' in part('make -n') and '> CAT' not in part('make -n')),
        ('make: A.OUT and ALL.OUT again, not B.OUT', '> CAT A.TEXT >A.OUT' in m3 and '> CAT A.OUT B.OUT >ALL.OUT' in m3 and 'B.TEXT' not in m3),
        ('make -q after: 0', '[exit status 0]' in part('make -q', 1)),
        ('times: B.OUT 10:00:00, A.OUT and ALL.OUT 10:06:30', stamp('B.OUT') == '26-11-07 10:00:00' and stamp('A.OUT') == '26-11-07 10:06:30'
         and stamp('ALL.OUT') == '26-11-07 10:06:30'),
        ('DIR shows the times', re.search(r'ALL\.OUT +\d+   7-Nov-26 10:06:30  Data', part('dir *.OUT')) is not None
         and re.search(r'B\.OUT +\d+   7-Nov-26 10:00:00  Data', part('dir *.OUT')) is not None),
        ('functions: $(OBJS:.OUT=.TEXT), patsubst, words; @ taken off', 'srcs A.TEXT B.TEXT objs A B n 2' in part('make show')),
        ('a - recipe that fails does not stop the next', 'after the failure' in part('make fail') and 'stopped' not in part('make fail')),
        ('no rule: said, status 2', "No rule to make target 'nosuch'" in part('make nosuch') and '[exit status 2]' in part('make nosuch')),
        ('date: the clock (past midnight)', 'Sun Nov  8 23:59:58 2026' in part('date')),
        ('date +%F_%T_%a_%j', '2026-11-08_23:59:58_Sun_312' in part('date +%F_%T_%a_%j')),
        ('date -r ALL.OUT', 'Sat Nov  7 10:06:30 2026' in part('date -r ALL.OUT')),
        ('touch -d: B.TEXT 2026-01-02 03:04:05', stamp('B.TEXT') == '26-01-02 03:04:05'),
        ('touch -t: X.TEXT made, 2025-12-31 23:59:59', stamp('X.TEXT') == '25-12-31 23:59:59'),
        ('touch -r B.TEXT Y.TEXT', stamp('Y.TEXT') == '26-01-02 03:04:05'),
    ]
    checks += cc_part(data, mode, d)
    bad = [n for n, g in checks if not g]
    if bad:
        print(tr[-6000:])
    for n, g in checks:
        print('%-5s %s' % ('ok' if g else 'FAIL', n))
    print('make test (%s, %s): %s   (work: %s)' % (mode, 'SYSTEM.PASCAL' if pascal else 'SYSTEM.C', 'FAILED' if bad else 'PASSED', d))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
