#!/usr/bin/env python3
"""tcrun.py -- compile a C program with the host Tiny-C and run it on the P-System.

  tcrun.py prog.c [input-keys]      prints the program's console output

The host compiler is built into build/tc from tinyc/tc.c if needed.
"""
import os, sys, subprocess, shutil
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from psys import PSystem, esc

TC = os.path.join(ROOT, 'build', 'tc')
INC = os.path.join(ROOT, 'tinyc', 'include')


def build_tc():
    srcs = [os.path.join(ROOT, 'tinyc', f) for f in os.listdir(os.path.join(ROOT, 'tinyc')) if f.endswith(('.c', '.h'))]
    if not os.path.exists(TC) or any(os.path.getmtime(s) > os.path.getmtime(TC) for s in srcs):
        os.makedirs(os.path.dirname(TC), exist_ok=True)
        subprocess.check_call(['gcc', '-O1', '-w', '-o', TC, os.path.join(ROOT, 'tinyc', 'tc.c')])


def compile_c(src, outdir):
    build_tc()
    base = os.path.splitext(os.path.basename(src))[0].upper()[:10]
    out = os.path.join(outdir, base + '.CODE')
    r = subprocess.run([TC, '-I', INC, src, '-o', out], capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit('compile failed:\n' + r.stdout + r.stderr)
    return base, out


def run_c(src, keys='', extra_files=(), timeout=300):
    ps = PSystem()
    base, code = compile_c(src, ps.dir)
    ps.put(base + '.CODE', open(code, 'rb').read())
    for name, data in extra_files:
        ps.put(name, data)
    script = ['WAIT "Command:"', 'TYPE "X"', 'WAIT "Execute what file?"', 'TYPE "#5:%s\\r"' % base]
    if keys:
        script.append('TYPE "%s"' % esc(keys))
    script.append('WAIT "Command:"')
    ok, tr, info = ps.run_script('\n'.join(script) + '\n', timeout)
    i = tr.find('#5:%s' % base)
    out = tr[i + len(base) + 4:] if i >= 0 else tr
    j = out.rfind('Command: E(dit')
    if j >= 0:
        out = out[:j]
    return ok, out.strip('\n'), ps, info


if __name__ == '__main__':
    ok, out, ps, info = run_c(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else '')
    print(out)
    if not ok:
        print('--- run did not complete:', info)
