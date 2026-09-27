#!/usr/bin/env python3
"""runtests.py -- Tiny-C validation: compile each tests/*.c with the host
Tiny-C, run it on the P-System and compare with tests/<name>.expect.

  runtests.py [name ...]      run all tests, or the named ones
  runtests.py --gcc name ...  (re)create name.expect from a gcc build
                              (only for programs whose output does not
                              depend on int being 16 bits)
"""
import os, sys, subprocess, re
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from tcrun import run_c

TESTS = os.path.join(ROOT, 'tests')


def normalize(out):
    # the console turns each CR into CR LF; the transcript shows both
    out = out.replace('\n\n', '\n')
    return '\n'.join(l.rstrip() for l in out.strip('\n').split('\n')) + '\n'


def gcc_expect(name):
    src = os.path.join(TESTS, name + '.c')
    exe = os.path.join(ROOT, 'build', 'gcc_' + name)
    subprocess.check_call(['gcc', '-w', '-o', exe, src, '-lm'])
    out = subprocess.run([exe], capture_output=True, text=True, input='').stdout
    open(os.path.join(TESTS, name + '.expect'), 'w').write(normalize(out))
    print('wrote', name + '.expect')


def main(a):
    if a and a[0] == '--gcc':
        for n in a[1:]:
            gcc_expect(n)
        return 0
    names = a or sorted(f[:-2] for f in os.listdir(TESTS) if f.endswith('.c'))
    failed = 0
    for n in names:
        exp_path = os.path.join(TESTS, n + '.expect')
        keys_path = os.path.join(TESTS, n + '.keys')
        keys = open(keys_path, newline='').read() if os.path.exists(keys_path) else ''
        try:
            ok, out, ps, info = run_c(os.path.join(TESTS, n + '.c'), keys)
        except SystemExit as e:
            print('FAIL  %-12s %s' % (n, str(e).strip().split('\n')[-1]))
            failed += 1
            continue
        out = normalize(out)
        exp = open(exp_path).read() if os.path.exists(exp_path) else None
        if ok and out == exp:
            print('PASS  %s' % n)
        else:
            failed += 1
            print('FAIL  %s%s' % (n, '' if ok else ' (run did not complete)'))
            if exp is None:
                print('  no .expect file; output was:')
            else:
                import difflib
                for l in difflib.unified_diff(exp.split('\n'), out.split('\n'), 'expected', 'got', lineterm='', n=1):
                    print('  ' + l)
                continue
            print('  ' + out.replace('\n', '\n  '))
    print('%d of %d tests passed' % (len(names) - failed, len(names)))
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
