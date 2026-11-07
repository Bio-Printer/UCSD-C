#!/usr/bin/env python3
"""voltest.py -- test the volumes (build/TINY-C.BLK, TCEXTRA.BLK, TCTESTS.BLK,
made by mkvolume.py) on the P-System: TINY-C: on unit #5, an empty SPARE: on
#9, TCEXTRA: on #10, TCTESTS: on #11.

TOOLS: (MAKE) on #12.  From the shell:

  make -f tiny-c:/src/lib/makefile   -> TINY-C:/LIB/TCLIB2.OBJ (-Z -C each module, joined
           in two parts), CMPCODE: IDENTICAL to TINY-C:/LIB/TCLIB.OBJ
  make -f tiny-c:/src/cc/makefile    -> TINY-C:CC2.CODE, CMPCODE: IDENTICAL to TINY-C:CC.CODE;
           make again: up to date
  make -B -f tcextra:makefile        every demo (compiler and headers from TINY-C:), then
           QUEENS runs
  make -B -f tctests:makefile        every test program, then LONGS runs

Prints the result, the least "N bytes free" CC printed (at the end of a
pass), and the least free memory the emulator tracked (SP - NP at every
P-code instruction: the true worst case, emulator 1.97 or later).  PSYS_MODE
picks the mode, as for the other tools: native (default; P-Code mode with
the Z80 interpreter's memory reclaimed) or z80 (Z80 mode, normal layout:
the least memory of all).
"""
import os, sys, re, shutil, subprocess, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from psys import ensure_setup, BUILD, shell_script, shell_transcript

# the first line LONGS prints (tests/longs.expect)
LONGS1 = open(os.path.join(ROOT, 'tests', 'longs.expect')).readline().strip()


def prefix(v):
    return ['TYPE "F"', 'WAIT "Filer:"', 'TYPE "P"', 'WAIT "Prefix"', 'TYPE "%s\\r"' % v,
            'WAIT "Filer:"', 'TYPE "Q"', 'WAIT "Command:"']


def tinyc(prog, cmd, waits):
    return (['TYPE "X"', 'WAIT "Execute what file?"', 'TYPE "%s\\r"' % prog,
             'WAIT "Compile what file?"', 'TYPE "%s\\r"' % cmd] +
            ['WAIT "%s"' % w for w in waits] + ['WAIT "Done."', 'WAIT "Command:"'])


def cmpcode(a, b):
    return ['TYPE "X"', 'WAIT "Execute what file?"', 'TYPE "TCEXTRA:CMPCODE\\r"',
            'WAIT "First file?"', 'TYPE "%s\\r"' % a, 'WAIT "Second file?"', 'TYPE "%s\\r"' % b,
            'WAIT "IDENTICAL"', 'WAIT "Command:"']


def shell(cmd, waits):
    return ['TYPE "%s\\r"' % cmd] + ['WAIT "%s"' % w for w in waits] + ['WAIT "shell> "']


def script():
    L = ['WAIT "Command:"'] + prefix('SPARE:') + ['TYPE "S"', 'WAIT "shell> "']
    L += shell('make -f tiny-c:/src/lib/makefile', ['> CC -O TINY-C:/OBJ/ -Z -C TINY-C:/SRC/LIB/ASSERT.C',
                                                    '> CC -O TINY-C:/OBJ/ -Z -C TINY-C:/SRC/LIB/TCRT.C',
                                                    'Joining TINY-C:/LIB/TCLIB2.OBJ'])
    L += shell('make -f tiny-c:/src/cc/makefile', ['> CC -O TINY-C:/OBJ/ -C TINY-C:/SRC/CC/MAIN.C', '> CC @#4:MAKE1R1',
                                                   '> -L TINY-C:CC2=', 'Done.'])
    L += shell('make -f tiny-c:/src/cc/makefile', ["'TINY-C:CC2.CODE' is up to date"])
    L += shell('make -B -f tcextra:makefile', ['> CC -Z TCEXTRA:BOXES', '> CC -Z TCEXTRA:CMPCODE', '> CC -Z TCEXTRA:SHELL'])
    L += shell('tcextra:queens', ['92'])
    L += shell('make -B -f tctests:makefile', ['> CC -Z TCTESTS:CONTROL', '> CC -Z TCTESTS:STRUCTS', '> CC -Z TCTESTS:SYSCOM'])
    L += shell('tctests:longs', [LONGS1])
    L += ['TYPE "bye\\r"', 'WAIT "Command:"']
    L += cmpcode('TINY-C:/LIB/TCLIB.OBJ', 'TINY-C:/LIB/TCLIB2.OBJ')
    L += cmpcode('TINY-C:CC.CODE', 'TINY-C:CC2.CODE')
    return '\n'.join(L) + '\n'


def main():
    ensure_setup()
    d = tempfile.mkdtemp(prefix='voltest_')
    for v in ('TINY-C', 'TCEXTRA', 'TCTESTS', 'TOOLS'):
        shutil.copy(os.path.join(ROOT, 'build', v + '.BLK'), d)
    ucsdvol.main(['new', os.path.join(d, 'SPARE.BLK'), 'SPARE', '400'])
    data = os.path.join(d, 'data')                  # BIGGY as mkbiggy.py made it is the boot disk (its shell runs MAKE's batch)
    os.makedirs(data)
    for f in os.listdir(os.path.join(BUILD, 'data')):
        shutil.copy(os.path.join(BUILD, 'data', f), data)
    shutil.copy(os.path.join(BUILD, 'BIGGY.BLK'), os.path.join(data, 'Big_Disk.BLK'))
    sp = os.path.join(d, 'voltest.script')
    open(sp, 'w').write(shell_script(script()))
    mode = os.environ.get('PSYS_MODE', 'native')
    env = dict(os.environ, VERIFY_UNIT10=os.path.join(d, 'TCEXTRA.BLK'),
               VERIFY_UNIT11=os.path.join(d, 'TCTESTS.BLK'), VERIFY_UNIT12=os.path.join(d, 'TOOLS.BLK'), VERIFY_LOWWATER='1')
    if mode == 'native':
        env['VERIFY_RECLAIM'] = '1'
    r = subprocess.run([os.path.join(BUILD, 'run_verify'), data,
                        os.path.join(d, 'TINY-C.BLK'), os.path.join(d, 'SPARE.BLK'), sp, mode,
                        os.path.join(d, 'out'), '', '600' if mode == 'native' else '1800'], capture_output=True, text=True, env=env)
    ok = 'VERIFY SCRIPT COMPLETED' in r.stdout
    tr = shell_transcript(open(os.path.join(d, 'out', 'transcript.txt'), encoding='latin1').read())
    least, where, cmd, step = None, '', '', ''
    for l in tr.split('\n'):
        if l.startswith('> '):
            cmd = l[2:].strip()
        elif l.startswith('Linking'):
            step = 'Linking'
        # X.C  n bytes free  Compiling  n bytes free  Generating code  n bytes free; a link's  n bytes free
        if 'bytes free' in l and step != 'Linking':
            step = 'Preprocessing'
        for m in re.finditer(r'(Compiling|Generating)|(\d+) bytes free', l):
            if m.group(1):
                step = m.group(1)
            elif least is None or int(m.group(2)) < least:
                least, where = int(m.group(2)), '%s, %s' % (cmd, step)
        if 'bytes free' in l:
            step = ''
    glued = re.findall(r'(?:free|/s) +(?:> |Done).*', tr)   # a pass's last line runs into the next one
    if glued:
        print('not on a line of its own: %s' % glued[0])
        ok = False
    print([l for l in r.stdout.split('\n') if 'VERIFY' in l][-1:])
    print('least memory: %s bytes free (%s; the least "N bytes free" CC printed)' % (least, where))
    lw = [l for l in r.stdout.split('\n') if l.startswith('least free memory')]
    if lw:                              # the emulator's tracking (engine 1.97): the true worst case
        print('tracked ' + lw[0])
    print('volume test: %s   (work: %s)' % ('PASSED' if ok else 'FAILED', d))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
