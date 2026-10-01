#!/usr/bin/env python3
"""pcensus.py -- static P-code census for UCSD Pascal II.0 code files.

Walks every P-code procedure instruction by instruction (no byte matching)
and counts opcodes, with extra detail on the four that put data in the
instruction stream: LSA, LPA, LDC, XJP.  Useful for sizing the code/data
boundary (e.g. for a Harvard I/D-space machine).

    pcensus.py FILE.CODE [FILE2.CODE ...]        summary per file + total
    pcensus.py VOLUME.BLK                        every code-kind file on a volume
    options:
      --procs      per-procedure LSA/LPA/LDC/XJP counts
      --ops        full opcode histogram
      --consumers  what consumes each LSA/LPA pointer (first non-push user)
      --strings    list the LSA/LPA string literals
      --selfpatch  list Tiny-C indirect-call sites (LPA 0 .. STO, CXP)
      --check      validate: every jump target must be an instruction start
      --segments   per-segment lines

Format assumptions (Z80 / little-endian II.0 code files): block 0 holds
DISKINFO[16] (block, byte length), SEGNAME[16] (8 chars), SEGKIND[16];
a segment ends with (segnum, nprocs) and a table of self-relative JTAB
pointers; JTAB: +0 proc number (0 = assembly procedure, skipped), +1 lex
level, -2 ENTRIC, -4 EXITIC, -6 PARMSZ, -8 DATASZ, long-jump table below.
LSI-11 (byte-swapped) files are not supported.

The operand-format table was taken from the UCSD utility volume's
OPCODES.II.0 (the table DISASM itself uses).
"""
import sys, os
from collections import Counter, defaultdict

# ---- opcode tables (from OPCODES.II.0) -------------------------------------
# type per opcode: 0 SHORT 1 ONE(byte) 2 OPT(big) 3 TWO(2 bytes) 4 LOPT(byte,big)
# 5 WORDS(XJP) 6 CHRS(len,chars) 7 BLK(LDC) 8 CMPRSS(CSP) 9 CMPRSS2(compare) A WORD
TYPE_STR = (
    '0000000000000000000000000000000000000000000000000000000000000000'
    '0000000000000000000000000000000000000000000000000000000000000000'
    '0000000000000000000000000000048011222264221251199947994941001100'
    '3110002A00202311640112000000000000000000000000000000000000000000'
)

NAMES_128 = [
    'ABI', 'ABR', 'ADI', 'ADR', 'LAND', 'DIF', 'DVI', 'DVR', 'CHK', 'FLO', 'FLT', 'INN',
    'INT', 'LOR', 'MODI', 'MPI', 'MPR', 'NGI', 'NGR', 'LNOT', 'SRS', 'SBI', 'SBR', 'SGS',
    'SQI', 'SQR', 'STO', 'IXS', 'UNI', 'LDE', 'CSP', 'LDCN', 'ADJ', 'FJP', 'INC', 'IND',
    'IXA', 'LAO', 'LSA', 'LAE', 'MOV', 'LDO', 'SAS', 'SRO', 'XJP', 'RNP', 'CIP', 'EQU',
    'GEQ', 'GTR', 'LDA', 'LDC', 'LEQ', 'LES', 'LOD', 'NEQ', 'STR', 'UJP', 'LDP', 'STP',
    'LDM', 'STM', 'LDB', 'STB', 'IXP', 'RBP', 'CBP', 'EQUI', 'GEQI', 'GTRI', 'LLA', 'LDCI',
    'LEQI', 'LESI', 'LDL', 'NEQI', 'STL', 'CXP', 'CLP', 'CGP', 'LPA', 'STE', 'BYT', 'EFJ',
    'NFJ', 'BPT', 'XIT', 'NOP', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL',
    'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDL', 'SLDO', 'SLDO',
    'SLDO', 'SLDO', 'SLDO', 'SLDO', 'SLDO', 'SLDO', 'SLDO', 'SLDO', 'SLDO', 'SLDO', 'SLDO',
    'SLDO', 'SLDO', 'SLDO', 'SIND', 'SIND', 'SIND', 'SIND', 'SIND', 'SIND', 'SIND', 'SIND'
]

(SHORT, ONE, OPT, TWO, LOPT, WORDS, CHRS, BLK, CMPRSS, CMPRSS2, WORD) = range(11)
TYPES = [int(c, 16) for c in TYPE_STR] if False else [ord(c) - 48 if c <= '9' else 10 for c in ''.join(TYPE_STR)]
TERMINATORS = (173, 193, 214)            # RNP, RBP, XIT
LSA, LPA, LDC, XJP, CXP = 166, 208, 179, 172, 205
NAMES = {}
for i, n in enumerate(NAMES_128):
    NAMES[128 + i] = n

def opname(op):
    return 'SLDC' if op < 128 else NAMES.get(op, '?%d' % op)

def w16(b, o):
    return b[o] | (b[o + 1] << 8)

class WalkError(Exception):
    pass

def walk_proc(seg, start, limit):
    """Decode from start to the terminating RNP/RBP/XIT.
    Returns [(pos, op, length, info)]; info = string length / LDC words /
    XJP entries / compare flavour."""
    pos, out = start, []
    while True:
        if pos >= limit:
            raise WalkError('ran past procedure end')
        op, p0, pos, info = seg[pos], pos, pos + 1, None
        t = TYPES[op]
        if t == ONE:
            pos += 1
        elif t == OPT:
            pos += 2 if seg[pos] & 0x80 else 1
        elif t == TWO:
            pos += 2
        elif t == LOPT:
            pos += 1
            pos += 2 if seg[pos] & 0x80 else 1
        elif t == WORD:
            pos += 2
        elif t == CMPRSS:
            pos += 1
        elif t == CMPRSS2:
            info = seg[pos]
            pos += 1
            if info in (10, 12):
                pos += 2 if seg[pos] & 0x80 else 1
        elif t == CHRS:
            info = seg[pos]
            pos += 1 + info
        elif t == BLK:
            info = seg[pos]
            pos += 1
            pos += pos & 1                      # word-align
            pos += 2 * info
        elif t == WORDS:
            pos += pos & 1
            mn, mx = w16(seg, pos), w16(seg, pos + 2)
            mn -= 65536 if mn >= 32768 else 0
            mx -= 65536 if mx >= 32768 else 0
            info = mx - mn + 1
            if info < 0 or info > 4000:
                raise WalkError('bad XJP range')
            pos += 4 + 2 + 2 * info             # min, max, else-UJP, table
        if pos > limit:
            raise WalkError('operand past procedure end')
        out.append((p0, op, pos - p0, info))
        if op in TERMINATORS:
            return out

def procedures(seg):
    """Yield (procnum, entry, jtab, instrs) for every P-code procedure;
    (procnum, None, jtab, None) for assembly procedures; or an error tuple."""
    n = seg[len(seg) - 1]
    for i in range(1, n + 1):
        p = len(seg) - 2 - 2 * i
        if p < 0:
            yield (i, 'bad', None, None); continue
        j = p - w16(seg, p)
        if j < 8 or j >= len(seg) - 1:
            yield (i, 'bad', None, None); continue
        if seg[j] == 0:
            yield (i, 'asm', j, None); continue
        ent = (j - 2) - w16(seg, j - 2)
        try:
            yield (i, ent, j, walk_proc(seg, ent, j - 8))
        except (WalkError, IndexError):
            yield (i, 'bad', j, None)

# ---- volume / code-file access --------------------------------------------
def volume_codefiles(img):
    n = w16(img, 1024 + 16)
    for i in range(1, n + 1):
        o = 1024 + 26 * i
        first, last, kind = w16(img, o), w16(img, o + 2), w16(img, o + 4) & 15
        name = bytes(img[o + 7:o + 7 + img[o + 6]]).decode('latin1')
        if kind == 2 and last > first:
            yield name, img[first * 512:last * 512]

def segments(data):
    for s in range(16):
        ca, cl = w16(data, s * 4), w16(data, s * 4 + 2)
        if not cl or not ca:
            continue
        seg = data[ca * 512:ca * 512 + cl]
        if len(seg) < cl or cl < 4:
            continue
        yield s, bytes(data[64 + s * 8:64 + s * 8 + 8]).decode('latin1').strip(), seg

# ---- analysis ---------------------------------------------------------------
PUSH = {'SLDC', 'LDCI', 'LDL', 'LDO', 'SLDL', 'SLDO', 'LLA', 'LAO', 'LDA', 'NOP', 'LSA', 'LPA',
        'LOD', 'IXA', 'INC', 'LDC', 'LDB', 'SIND', 'IND', 'LDP', 'LDCN', 'ADI', 'SBI', 'MPI',
        'NGI', 'LAND', 'LOR', 'LNOT', 'FLT', 'IXP', 'LDE', 'LAE', 'ADJ', 'CHK'}
COPY = {'SAS', 'MOV', 'LDM', 'STB'}
CMP = {'EQU', 'NEQ', 'LES', 'LEQ', 'GTR', 'GEQ'}
CALL = {'CXP', 'CIP', 'CGP', 'CLP', 'CBP', 'CSP'}
STORE = {'STL', 'STR', 'SRO', 'STO', 'STM', 'STE'}

def consumer(ins, k):
    for q in range(k + 1, min(k + 14, len(ins))):
        n = opname(ins[q][1])
        if n in PUSH: continue
        if n in COPY: return 'copied (SAS/MOV/LDM)'
        if n in CMP: return 'compared'
        if n in CALL: return 'passed to call'
        if n in STORE: return 'stored (pointer retained)'
        return 'other:' + n
    return 'other'

def selfpatch_at(ins, k):
    """LPA 0 ; SLDC n ; ADI ; (SLDL|LDL) t ; STO ; CXP  -- Tiny-C indirect call"""
    N = [opname(i[1]) for i in ins[k:k + 6]]
    return (len(N) == 6 and ins[k][1] == LPA and ins[k][3] == 0 and N[1] == 'SLDC' and N[2] == 'ADI'
            and N[3] in ('SLDL', 'LDL') and N[4] == 'STO' and N[5] == 'CXP')

def check_jumps(seg, ent, j, ins):
    """Return (targets_checked, bad) using instruction starts."""
    starts = {p for p, _, _, _ in ins}
    end = ins[-1][0] + ins[-1][2]
    tot = bad = 0
    def test(t):
        nonlocal tot, bad
        tot += 1
        if t not in starts and t != end:
            bad += 1
    for p, op, ln, info in ins:
        if op in (161, 185, 211, 212):           # FJP UJP EFJ NFJ
            b = seg[p + 1]
            if b < 128:
                test(p + 2 + b)
            else:
                a = j + (b - 256)
                test((a - w16(seg, a)) & 0xFFFF)
        elif op == XJP:
            q = p + 1
            q += q & 1
            mn, mx = w16(seg, q), w16(seg, q + 2)
            mn -= 65536 if mn >= 32768 else 0
            mx -= 65536 if mx >= 32768 else 0
            base = q + 4
            for i in range(mx - mn + 1):
                a = base + 2 + 2 * i
                t = (a - w16(seg, a)) & 0xFFFF
                if t != base:                     # unused slots point at the else-UJP
                    test(t)
                else:
                    tot += 1
    return tot, bad

def analyse(title, data, opt, total):
    C = Counter()
    ops = Counter()
    print('== %s' % title)
    for s, sname, seg in segments(data):
        SC = Counter()
        for pn, ent, j, ins in procedures(seg):
            if ins is None:
                SC['asm' if ent == 'asm' else 'unparsed'] += 1
                continue
            SC['procs'] += 1
            SC['instr'] += len(ins)
            SC['codebytes'] += ins[-1][0] + ins[-1][2] - ent
            PC = Counter()
            for k, (p, op, ln, info) in enumerate(ins):
                nm = opname(op)
                ops[nm] += 1
                if op in (LSA, LPA, LDC, XJP):
                    SC[nm] += 1; SC[nm + '_bytes'] += ln; PC[nm] += 1
                    if op in (LSA, LPA):
                        SC['strchars'] += info
                        if opt['consumers']:
                            SC['cons:' + consumer(ins, k)] += 1
                        if opt['strings']:
                            print('    seg %d proc %d +%d %s %r' % (s, pn, p - ent, nm,
                                  bytes(seg[p + 2:p + 2 + info])))
                    if op == LDC: SC['LDC_words'] += info
                    if op == XJP: SC['XJP_entries'] += info
                if op == LPA and selfpatch_at(ins, k):
                    SC['selfpatch'] += 1
                    if opt['selfpatch']:
                        print('    seg %d proc %d +%d indirect call (self-patching CXP)' % (s, pn, p - ent))
            if opt['check']:
                t, b = check_jumps(seg, ent, j, ins)
                SC['jumps'] += t; SC['jumps_bad'] += b
            if opt['procs'] and PC:
                print('    seg %2d proc %3d  %s' % (s, pn, '  '.join('%s=%d' % kv for kv in sorted(PC.items()))))
        if opt['segments']:
            print('  seg %2d %-8s procs=%-4d instr=%-6d code=%-6d LSA=%d LPA=%d LDC=%d XJP=%d'
                  % (s, sname, SC['procs'], SC['instr'], SC['codebytes'], SC['LSA'], SC['LPA'], SC['LDC'], SC['XJP']))
        C.update(SC)
    summary(C)
    if opt['ops']:
        print('  opcode histogram:')
        for nm, n in ops.most_common():
            print('    %-6s %d' % (nm, n))
    total.update(C)

def summary(C):
    inline = C['LSA_bytes'] + C['LPA_bytes'] + C['LDC_bytes'] + C['XJP_bytes']
    print('  procs=%d instr=%d code=%dB  (asm procs skipped: %d, unparsed: %d)'
          % (C['procs'], C['instr'], C['codebytes'], C['asm'], C['unparsed']))
    print('  LSA=%d (%dB)  LPA=%d (%dB)  LDC=%d (%dB, %d words)  XJP=%d (%dB, %d entries)'
          % (C['LSA'], C['LSA_bytes'], C['LPA'], C['LPA_bytes'], C['LDC'], C['LDC_bytes'],
             C['LDC_words'], C['XJP'], C['XJP_bytes'], C['XJP_entries']))
    print('  inline constants/tables = %.1f%% of code bytes; string chars in LSA/LPA = %d; self-patching indirect calls = %d'
          % (100.0 * inline / max(1, C['codebytes']), C['strchars'], C['selfpatch']))
    cons = {k[5:]: v for k, v in C.items() if k.startswith('cons:')}
    if cons:
        print('  LSA/LPA pointer consumers: ' + ', '.join('%s=%d' % kv for kv in sorted(cons.items(), key=lambda x: -x[1])))
    if C['jumps']:
        print('  jump targets checked: %d, not on an instruction start: %d' % (C['jumps'], C['jumps_bad']))

def main(argv):
    flags = {a for a in argv if a.startswith('--')}
    paths = [a for a in argv if not a.startswith('--')]
    known = {'--procs', '--ops', '--consumers', '--strings', '--selfpatch', '--check', '--segments'}
    if not paths or flags - known:
        print(__doc__); return 2
    opt = {k[2:]: (k in flags) for k in known}
    total = Counter()
    nfiles = 0
    for path in paths:
        img = open(path, 'rb').read()
        if path.upper().endswith('.BLK'):
            for name, data in volume_codefiles(img):
                analyse('%s:%s' % (os.path.basename(path), name), data, opt, total); nfiles += 1
        else:
            analyse(os.path.basename(path), img, opt, total); nfiles += 1
    if nfiles > 1:
        print('== TOTAL (%d files)' % nfiles)
        summary(total)
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
