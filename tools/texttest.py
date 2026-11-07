#!/usr/bin/env python3
"""texttest.py -- ECHO, HEAD, TAIL, SORT, UNIQ, TR, CUT and TEE (ports/NAME/NAME.c, TOOLS:NAME.CODE) from
the shell on the P-System, each command's output against the host's coreutils given the same text
(LC_ALL=C): the options of each, several files and their headers, wild cards (L*.TEXT), the standard
input from <FILE and from a pipe, SORT's keys (-k -t -n -b -d -f -r -s -u, -o FILE, -c) and a file
sorted through several temporary runs and merges (-S), TEE into new files and with -a, TR's
classes, ranges, escapes and repeats, CUT's lists, fields, --complement and --output-delimiter.
Then the errors: a bad option, a missing file, a wild card that matches nothing, SORT -c on
lines out of order (status 1), TAIL -f, TEE's FILE on the disk where >FILE is being written (the
P-System gives that one the free area; >FILE[*] leaves room, and is still a text file).
The data is on #9 (the prefix), each command's output goes to #5:On.TEXT.

Uses the mode of PSYS_MODE (native or z80) like the other tools."""
import os, sys, re, subprocess, tempfile, random
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from psys import PSystem
import ucsdvol
from tcrun import compile_c
from difftest import make_text

TOOLS = ['echo', 'head', 'tail', 'sort', 'uniq', 'tr', 'cut', 'tee']

rnd = random.Random(7)
WORDS = ['apple', 'Banana', 'cherry', 'date', 'Elder', 'fig', 'grape', 'hazel', 'Iris', 'juniper', 'kiwi', 'Lemon']
L1 = ['the quick brown fox', 'The Quick Brown Fox', '  leading blanks here', '\tstarts with a tab',
      'zebra 10 last', 'apple 2 first', 'apple 10 second', 'Apple 1 third', 'mango-lassi: drink!',
      '', 'numbers 123 and 45', 'x', 'aa  bb   cc', 'end of the line   ', 'b2 a1', 'b10 a2',
      '#include <stdio.h>', 'MiXeD CaSe line', 'apple 2 first', 'tab\tin\tthe middle', 'q', 'banana 3',
      'cherry 007 pie', 'Zulu', 'yankee  9']
L2 = ['one', 'two', 'three', 'four', 'five']
N = ['10', '9', '-3', '  42', '3.14', '3.140', '-0', '0', '007', 'abc', '', '-12.5', '1e3', '100 apples',
     '2.5', '-2.50', '.5', '-.5', '99999999999999999999', '5']
F = ['root:0:0:/root', 'daemon:1:1:/usr/sbin', 'bin:2:2:/bin', 'sys:3:3:/dev', 'no colon here',
     'games:5:60:/usr/games', 'man:6:12:/var/cache/man', 'a::b:', ':lead', 'trail:']
D = ['alpha', 'alpha', 'Alpha', 'beta', 'beta', 'beta', 'gamma', 'x 1 same', 'y 1 same', 'z 2 same',
     'aa1', 'aa2', 'ab3', 'delta', 'delta', 'epsilon']
T = ['a\tb\tc', 'one\ttwo', 'no tabs', '\tempty first', 'x\t\ty']
B = ['%s %d %s' % (rnd.choice(WORDS), rnd.randint(-500, 500), rnd.choice(WORDS).lower()) for i in range(1200)]
FILES = {'L1.TEXT': L1, 'L2.TEXT': L2, 'N.TEXT': N, 'F.TEXT': F, 'D.TEXT': D, 'T.TEXT': T, 'B.TEXT': B, 'E.TEXT': []}

# (P-System command, host command or None for the same); a host command is a string, split at blanks,
# or a list of argv lists (the stages of a pipe; a stage's first word "<FILE" is its input)
GROUPS = [
    [   # echo, head, tail
        ('echo hello world', None),
        ('echo -n no new line', None),
        ('echo -e tab\\there', None),
        ('echo -e oct\\0101\\x41\\x4a!', None),
        ('echo -e stop\\cnever', None),
        ('echo -E raw\\tbackslash', None),
        ('echo -x is a word', None),
        ('echo', None),
        ('head L1.TEXT', None),
        ('head -n 3 L1.TEXT', None),
        ('head -3 L1.TEXT', None),
        ('head -n -20 L1.TEXT', None),
        ('head -c 50 L1.TEXT', None),
        ('head -c -400 L1.TEXT', None),
        ('head L1.TEXT L2.TEXT', None),
        ('head -q -n 2 L1.TEXT L2.TEXT', None),
        ('head -v -n1 L2.TEXT', None),
        ('head -n 2 L*.TEXT', 'head -n 2 L1.TEXT L2.TEXT'),
        ('cat L1.TEXT | head -n 4', None),
        ('head -n 2 <L1.TEXT', None),
        ('head -n -3 <L2.TEXT', None),
        ('head E.TEXT', None),
        ('tail L1.TEXT', None),
        ('tail -n 3 L1.TEXT', None),
        ('tail -3 L1.TEXT', None),
        ('tail -n +20 L1.TEXT', None),
        ('tail -c 40 L1.TEXT', None),
        ('tail -c +500 L1.TEXT', None),
        ('tail L1.TEXT L2.TEXT', None),
        ('tail -q -n 1 L*.TEXT', 'tail -q -n 1 L1.TEXT L2.TEXT'),
        ('cat L1.TEXT | tail -n 2', None),
        ('tail -n 0 L1.TEXT', None),
        ('tail -n 2 E.TEXT', None),
        ('tail -n 2 <L2.TEXT', None),
    ],
    [   # sort
        ('sort L1.TEXT', None),
        ('sort -r L1.TEXT', None),
        ('sort -f L1.TEXT', None),
        ('sort -u L1.TEXT', None),
        ('sort -fu L1.TEXT', None),
        ('sort -b L1.TEXT', None),
        ('sort -d L1.TEXT', None),
        ('sort -i L1.TEXT', None),
        ('sort -n N.TEXT', None),
        ('sort -rn N.TEXT', None),
        ('sort -nu N.TEXT', None),
        ('sort -t: -k3n F.TEXT', None),
        ('sort -t: -k2,2 -k1,1r F.TEXT', None),
        ('sort -t: -k4 F.TEXT', None),
        ('sort -k2 L1.TEXT', None),
        ('sort -k2,2 -s L1.TEXT', None),
        ('sort -k1.2,1.3 L1.TEXT', None),
        ('sort -k2b,2 L1.TEXT', None),
        ('sort -k2n -k1 L1.TEXT', None),
        ('sort -k2,2n -k3r L1.TEXT', None),
        ('sort -k1.3b L1.TEXT', None),
        ('sort -t\\040 -k2 L1.TEXT', [['sort', '-t', ' ', '-k2', 'L1.TEXT']]),
        ('sort L1.TEXT L2.TEXT', None),
        ('sort L*.TEXT', 'sort L1.TEXT L2.TEXT'),
        ('cat L1.TEXT | sort -r', None),
        ('sort <N.TEXT', None),
        ('sort -o S.TEXT L1.TEXT', None),
        ('cat S.TEXT', None),
        ('sort -o L2.TEXT L2.TEXT', None),
        ('cat L2.TEXT', None),
        ('sort E.TEXT', None),
        ('sort B.TEXT', None),
        ('sort -S 6000 B.TEXT', 'sort B.TEXT'),
        ('sort -S 6000 -u -k1,1 B.TEXT', 'sort -u -k1,1 B.TEXT'),
        ('sort -S 6000 -k2n -r B.TEXT', 'sort -k2n -r B.TEXT'),
        ('sort -S 6000 -o S.TEXT B.TEXT', 'sort -o S.TEXT B.TEXT'),
        ('sort -S 5000 -T SPARE: -r B.TEXT', 'sort -r B.TEXT'),
        ('cat S.TEXT', None),
    ],
    [   # uniq, tr, cut, tee
        ('uniq D.TEXT', None),
        ('uniq -c D.TEXT', None),
        ('uniq -d D.TEXT', None),
        ('uniq -D D.TEXT', None),
        ('uniq -u D.TEXT', None),
        ('uniq -i D.TEXT', None),
        ('uniq -ci D.TEXT', None),
        ('uniq -f 1 D.TEXT', None),
        ('uniq -s 2 D.TEXT', None),
        ('uniq -w 2 D.TEXT', None),
        ('uniq -f1 -s1 -c D.TEXT', None),
        ('sort L1.TEXT | uniq -c', None),
        ('uniq <D.TEXT', None),
        ('uniq D.TEXT U.TEXT', None),
        ('cat U.TEXT', None),
        ('tr a-z A-Z <L1.TEXT', None),
        ('tr -d aeiou <L1.TEXT', None),
        ('tr -s \\040 <L1.TEXT', [['<L1.TEXT', 'tr', '-s', ' ']]),
        ('tr [:lower:] [:upper:] <L1.TEXT', None),
        ('tr -cs [:alnum:] \\n <L1.TEXT', None),
        ('tr -d [:digit:] <N.TEXT', None),
        ('tr abc x <L1.TEXT', None),
        ('tr -t abc xy <L1.TEXT', None),
        ('tr a-e [x*] <L1.TEXT', None),
        ('tr e [x*3]Y <L1.TEXT', None),
        ('tr -s a-z <L1.TEXT', None),
        ('tr -ds aeiou a-z <L1.TEXT', None),
        ('tr \\t _ <L1.TEXT', None),
        ('tr -c a-z\\n . <L1.TEXT', None),
        ('tr [:space:] _ <L1.TEXT', None),
        ('tr a-zA-Z n-za-mN-ZA-M <L1.TEXT', None),
        ('cat L1.TEXT | tr -d [:punct:]', None),
        ('cut -c1-5 L1.TEXT', None),
        ('cut -c3- L1.TEXT', None),
        ('cut -c-4,8,10-12 L1.TEXT', None),
        ('cut -b2 L1.TEXT', None),
        ('cut -d: -f1,3 F.TEXT', None),
        ('cut -d: -f2- F.TEXT', None),
        ('cut -d: -f3 -s F.TEXT', None),
        ('cut -d: -f1 --complement F.TEXT', None),
        ('cut -d: -f1,3 --output-delimiter=+ F.TEXT', None),
        ('cut -c1-2,5-6 --output-delimiter=+ L2.TEXT', None),
        ('cut -f2 T.TEXT', None),
        ('cut -f1,3 -s T.TEXT', None),
        ('cut -d\\040 -f2 L1.TEXT', [['cut', '-d', ' ', '-f2', 'L1.TEXT']]),
        ('cut -c2-3 L*.TEXT', 'cut -c2-3 L1.TEXT L2.TEXT'),
        ('cut -c1 <L2.TEXT', None),
        ('cat L2.TEXT | tee T1.TEXT', None),
        ('cat T1.TEXT', None),
        ('cat L2.TEXT | tee -a T1.TEXT T2.TEXT', None),
        ('cat T1.TEXT', None),
        ('cat T2.TEXT', None),
        ('echo hi | tee', None),
    ],
]

# errors: (command, what the transcript must say after it)
ERRORS = [
    ('head -x L1.TEXT', "head: invalid option -- 'x'"),
    ('head NOSUCH.TEXT', 'head: NOSUCH.TEXT: cannot open it'),
    ('tail ZZ*', 'tail: ZZ*: no file matches'),
    ('tail -f L1.TEXT', 'tail: -f: not possible here'),
    ('sort -k0 L1.TEXT', 'sort: field number is zero'),
    ('sort -c L1.TEXT', 'sort: L1.TEXT:2: disorder: The Quick Brown Fox'),
    ('uniq NOSUCH.TEXT', 'uniq: NOSUCH.TEXT: cannot open it'),
    ('tr a', "tr: missing operand after a"),
    ('cut -c L1.TEXT', 'cut: invalid field value or range'),
    ('cut L1.TEXT', 'cut: you must specify a list'),
    ('tee -z', "tee: invalid option -- 'z'"),
    ('tee Z.TEXT <L2.TEXT >Y.TEXT', 'tee: Z.TEXT: cannot write it (no room on its disk, or a new file'),
    ('tee Z.TEXT <L2.TEXT >Y.TEXT[*]', '[exit status 0]'),
    ('cat Y.TEXT', 'four'),
]


def put_files(d):
    for n, ls in FILES.items():
        open(os.path.join(d, n), 'w', encoding='latin1').write(''.join(l + '\n' for l in ls))


def hostrun(d, cmd, host):
    if host is None:
        host = cmd
    if isinstance(host, str):
        host = [s.split() for s in host.split(' | ')]
    data = b''
    env = dict(os.environ, LC_ALL='C')
    for st in host:
        if st and st[0].startswith('<'):
            data = open(os.path.join(d, st[0][1:]), 'rb').read()
            st = st[1:]
        elif any(w.startswith('<') for w in st):
            w = [w for w in st if w.startswith('<')][0]
            data = open(os.path.join(d, w[1:]), 'rb').read()
            st = [x for x in st if x != w]
        if st[0] == 'echo':
            st = ['/bin/echo'] + st[1:]
        data = subprocess.run(st, input=data, capture_output=True, cwd=d, env=env).stdout
    return data.decode('latin1')


def norm(s):
    s = s.replace('\r', '')
    if s and not s.endswith('\n'):
        s += '\n'
    return '' if s == '\n' else s


def session(cmds, z, extra=()):
    ps = PSystem()
    for t in TOOLS + ['cat']:
        base, code = compile_c(os.path.join(ROOT, 'ports', t, t + '.c'), ps.dir, True)  # -z, as on TOOLS:
        ps.put(base + '.CODE', open(code, 'rb').read())
    base, code = compile_c(os.path.join(ROOT, 'examples', 'shell.c'), ps.dir, z)
    ps.put(base + '.CODE', open(code, 'rb').read())
    v = ucsdvol.Volume(ps.spare)        # the data on #9, the prefix; the outputs on #5 (a disk
    for n, ls in FILES.items():         # with a new file being written has no room for another)
        v.write(n, make_text(ls), 3)
    v.save()
    script = ['WAIT "Command:"', 'TYPE "X"', 'WAIT "Execute what file?"', 'TYPE "#5:SHELL\\r"', 'WAIT "shell> "',
              'TYPE "cd #9\\r"', 'WAIT "shell> "']
    for i, c in enumerate(cmds):
        line = '%s >#5:O%d.TEXT' % (c, i)
        assert len(line) <= 80, line
        script += ['TYPE "%s\\r"' % line.replace('\\', '\\\\'), 'WAIT "shell> "']
    for c in extra:
        script += ['TYPE "%s\\r"' % c.replace('\\', '\\\\'), 'WAIT "shell> "']
    script += ['TYPE "bye\\r"', 'WAIT "Command:"']
    ok, tr, info = ps.run_script('\n'.join(script) + '\n', 6000)
    tr = tr.replace('\r', '\n')
    img = ucsdvol.Volume(os.path.join(ps.out, 'VERIFY_SOURCE.BLK'))
    outs = []
    for i in range(len(cmds)):
        n = 'O%d.TEXT' % i
        outs.append(ucsdvol.ucsd_to_text(img.read(n)[0]) if img.find(n) else None)
    sp = ucsdvol.Volume(ps.spare)
    left = [e[3] for v in (img, sp) for e in v.entries if e[3].startswith('SORTTMP')]
    return ok, outs, tr, left


def main():
    z = os.environ.get('PSYS_MODE') == 'z80'
    want = sys.argv[1:]                 # tool names: only their commands
    checks = []
    for g, group in enumerate(GROUPS):
        if want:
            group = [c for c in group if c[0].split()[0] in want or (c[0].startswith('cat ') and
                     any(w in c[0].split('|')[-1] for w in want))]
            if not group:
                continue
        d = tempfile.mkdtemp(prefix='texttest_')
        put_files(d)
        exp = [norm(hostrun(d, c, h)) for c, h in group]
        extra = [c for c, msg in ERRORS] if g == len(GROUPS) - 1 and not want else []
        ok, outs, tr, left = session([c for c, h in group], z, extra)
        checks.append(('session %d (%d commands) completed' % (g + 1, len(group)), ok))
        for (c, h), e, o in zip(group, exp, outs):
            got = norm(o) if o is not None else None
            good = got == e
            if not good:
                print('--- %s\n got:  %r\n want: %r' % (c, got, e))
            checks.append((c, good))
        if any('-S 6000' in c for c, h in group):
            checks.append(("sort's temporary files removed", left == []))
        if extra:
            for c, msg in ERRORS:
                i = tr.find('shell> ' + c + '\n')
                part = tr[i:tr.find('shell> ', i + 7)] if i >= 0 else ''
                good = msg in part
                if not good:
                    print('--- %s\n got: %r\n want: %r' % (c, part, msg))
                checks.append(('error: ' + c, good))
            i = tr.find('shell> sort -c L1.TEXT\n')
            checks.append(('sort -c: status 1', '[exit status 1]' in tr[i:tr.find('shell> ', i + 7)]))
    bad = [n for n, g in checks if not g]
    for n, g in checks:
        print('%-5s %s' % ('ok' if g else 'FAIL', n))
    print('text tools test (%s): %s' % ('z80' if z else 'native', 'FAILED' if bad else 'PASSED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
