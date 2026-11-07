#!/usr/bin/env python3
"""pasmtest.py -- PASM, the P-code assembler (pasm/, tools/pasm.py, tools/mkpasm.py):

  the host            tools/pasm.py assembles pasm/ (PASM itself), the examples and
                      pasm/test/errs.pasm (its errors, on their lines); the disk
                      build/U016.1_PCODE_ASSEM.BLK (mkpasm.py) holds what it makes now
  the P-System        with U016.1 on #5 and TOOLS on #11, from the shell: HELLO and PTEST
                      print what they should; PASM PASM P2. makes P2 the same bytes as the
                      host's PASM.CODE (PASM assembles itself); PASM ERRS reports the
                      host's errors on the same lines and makes no code file; TOUCH
                      PASMGEN.TEXT, then MAKE -f U016.1:MAKEFILE: PASM rebuilds itself and
                      the examples (each the host's bytes), and a second MAKE does nothing

Uses PSYS_MODE (native or z80).  Needs build/run_verify from emulator 2.13 (a clock the script
sets: TOUCH and MAKE)."""
import os, re, shutil, subprocess, sys, tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from psys import ensure_setup, BUILD, shell_script, shell_transcript
import ucsdvol
import pasm
from mkpasm import IMAGE, PASMDIR, assemble

PTEST = ['PTEST', '120', '-1234', 'two?', '3', '5050', '4660']


def errors(src):
    a = pasm.Asm(src, PASMDIR)
    a.assemble()
    return [(int(m.group(1)), m.group(2)) for m in (re.match(r'\S+ (\d+): (.*)', e) for e in a.errors) if m]


def main():
    ensure_setup()
    mode = os.environ.get('PSYS_MODE', 'native')
    host = {n: assemble(os.path.join(PASMDIR, *p)) for n, p in
            (('PASM.CODE', ('pasm.pasm',)), ('HELLO.CODE', ('test', 'hello.pasm')), ('PTEST.CODE', ('test', 'ptest.pasm')))}
    errsrc = os.path.join(PASMDIR, 'test', 'errs.pasm')
    herr = errors(errsrc)
    img = os.path.join(BUILD, IMAGE + '.BLK')
    disk = ucsdvol.Volume(img)
    d = tempfile.mkdtemp(prefix='pasmtest_')
    work = os.path.join(d, IMAGE + '.BLK')
    shutil.copy(img, work)
    v = ucsdvol.Volume(work)
    v.write('ERRS.TEXT', ucsdvol.text_to_ucsd(open(errsrc).read()), 3)
    v.save()
    spare = os.path.join(d, 'SPARE.BLK')
    ucsdvol.main(['new', spare, 'SPARE', '200'])
    data = os.path.join(d, 'data')
    os.makedirs(data)
    for f in os.listdir(os.path.join(BUILD, 'data')):
        shutil.copy(os.path.join(BUILD, 'data', f), data)
    shutil.copy(os.path.join(BUILD, 'BIGGY.BLK'), os.path.join(data, 'Big_Disk.BLK'))
    cmds = ['cd u016.1:', 'hello', 'ptest', 'pasm pasm p2.', 'pasm errs', 'touch pasmgen.text',
            'make -f u016.1:makefile', 'make -f u016.1:makefile']
    L = ['WAIT "Command:"', 'TYPE "S"', 'WAIT "shell> "']
    for c in cmds:
        L += ['TYPE "%s\\r"' % c, 'WAIT "shell> "']
    L += ['TYPE "bye\\r"', 'WAIT "Command:"']
    sp = os.path.join(d, 'pasm.script')
    open(sp, 'w').write(shell_script('\n'.join(L) + '\n'))
    out = os.path.join(d, 'out')
    env = dict(os.environ, VERIFY_HOSTCLOCK='2026-11-07T12:00:00', VERIFY_UNIT11=os.path.join(BUILD, 'TOOLS.BLK'))
    r = subprocess.run([os.path.join(BUILD, 'run_verify'), data, work, spare, sp, mode, out, '', '1800'],
                       capture_output=True, text=True, env=env)
    tp = os.path.join(out, 'transcript.txt')
    tr = shell_transcript(open(tp, encoding='latin1').read()).replace('\r', '\n') if os.path.exists(tp) else ''
    tr = re.sub(r'\n+', '\n', tr)

    def part(c):
        i = tr.find('shell> %s\n' % c)
        j = tr.find('shell> ', i + 7)
        return tr[i:j] if i >= 0 else ''
    after = ucsdvol.Volume(os.path.join(out, 'VERIFY_SOURCE.BLK'))
    got = {n: after.read(n)[0] if after.find(n) else None for n in ('P2', 'PASM.CODE', 'HELLO.CODE', 'PTEST.CODE', 'ERRS.CODE')}
    perr = [(int(m.group(1)), m.group(2)) for m in re.finditer(r'errs\.TEXT (\d+): (.*)', part('pasm errs'), re.I)]
    i = tr.find('shell> make -f u016.1:makefile')
    make1 = tr[i:tr.find('shell> make -f u016.1:makefile', i + 10)]
    make2 = tr[tr.find('shell> make -f u016.1:makefile', i + 10):]
    checks = [
        ('the script completed', 'VERIFY SCRIPT COMPLETED' in r.stdout),
        ('the disk holds what the host makes now (mkpasm.py)',
         all(disk.find(n) and disk.read(n)[0] == host[n] for n in host)),
        ('the host: errs.pasm\'s errors on their lines', [l for l, m in herr] == [6, 7, 8, 12, 14, 15, 17]),
        ('HELLO', 'Hello from P-code!' in part('hello')),
        ('PTEST', part('ptest').split('\n')[1:1 + len(PTEST)] == PTEST),
        ('PASM PASM P2.: the host\'s PASM.CODE', got['P2'] == host['PASM.CODE']),
        ('PASM ERRS: the same lines (%s)' % ' '.join(str(l) for l, m in perr), [l for l, m in perr] == [l for l, m in herr]),
        ('PASM ERRS: exit status 1, no code file', '7 error(s): no code file' in part('pasm errs')
         and '[exit status 1]' in part('pasm errs') and got['ERRS.CODE'] is None),
        ('MAKE: PASM rebuilt by itself, then the examples',
         all('> U016.1:PASM %s' % n in make1 for n in ('PASM', 'HELLO', 'PTEST')) and 'make: ***' not in make1),
        ('MAKE: each code file the host\'s bytes', all(got[n] == host[n] for n in host)),
        ('MAKE again: nothing to be done', 'PASM' not in make2.replace('make -f u016.1:makefile', '')),
    ]
    bad = [n for n, g in checks if not g]
    if bad:
        print(tr[-4000:])
    for n, g in checks:
        print('%-5s %s' % ('ok' if g else 'FAIL', n))
    print('pasm test (%s): %s   (work: %s)' % (mode, 'FAILED' if bad else 'PASSED', d))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
