#!/usr/bin/env python3
"""pasm.py -- PASM, the P-code assembler, on the host: the reference for PASM.CODE (pasm/,
written in PASM itself), which must make the same code file byte for byte.

  pasm.py SOURCE.TEXT CODE.CODE [-I DIR]      (SOURCE: a plain text file, or a UCSD text file)

The language is pasm/PASMDOC.TEXT's.  In short:

  [LABEL:] [MNEMONIC operands | .DIRECTIVE operands] [; comment]

  .PROGRAM NAME          the program (segment 1's name); first
  .SEGMENT NAME [N]      the procedures after it are segment N (7, 8 ... when not given)
  .MAIN ... .END         segment 1's procedure 1, lex level 0: the program's body
  .PROC NAME [LEX] ... .END   a procedure (numbered in its segment in order; lex level 1)
  .PARAM A[:W], B[:W]    its parameters, in the order they are pushed (the last at offset 1)
  .VAR A[:W], ...        its locals (after the parameters)
  .GLOBAL A[:W], ...     the program's globals (.MAIN's data, from offset 3: LDO, SRO, LAO)
  .EQU NAME, VALUE       a constant
  .EXIT                  the exit point is here (else the last RNP or RBP)
  .INCLUDE FILE          FILE.TEXT's lines here (from the main file only)

Operands are expressions: NUMBER, $HEX, 'C' (a character), NAME (a constant, a parameter or
local, a global, a procedure's number, a segment's number), joined by + and -; names are
significant to 8 characters and must be defined before they are used, but for labels (jumps
and XJP) and procedures (calls)."""
import os, re, struct, sys

# mnemonic: (opcode, operand format)  -- U byte, B big, !B, D db+big, S jump, W word, T compare
# type, A string, C word list, X case table, P two bytes, CXP, UB byte+big; L literal (LIT)
OPS = {
    'ABI': (0x80, ''), 'ABR': (0x81, ''), 'ADI': (0x82, ''), 'ADR': (0x83, ''), 'LAND': (0x84, ''),
    'DIF': (0x85, ''), 'DVI': (0x86, ''), 'DVR': (0x87, ''), 'CHK': (0x88, ''), 'FLO': (0x89, ''),
    'FLT': (0x8A, ''), 'INN': (0x8B, ''), 'INT': (0x8C, ''), 'LOR': (0x8D, ''), 'MODI': (0x8E, ''),
    'MPI': (0x8F, ''), 'MPR': (0x90, ''), 'NGI': (0x91, ''), 'NGR': (0x92, ''), 'LNOT': (0x93, ''),
    'SRS': (0x94, ''), 'SBI': (0x95, ''), 'SBR': (0x96, ''), 'SGS': (0x97, ''), 'SQI': (0x98, ''),
    'SQR': (0x99, ''), 'STO': (0x9A, ''), 'IXS': (0x9B, ''), 'UNI': (0x9C, ''), 'S2P': (0x9D, ''),
    'CSP': (0x9E, 'U'), 'LDCN': (0x9F, ''),
    'ADJ': (0xA0, 'U'), 'FJP': (0xA1, 'S'), 'INC': (0xA2, 'B'), 'IND': (0xA3, 'B'), 'IXA': (0xA4, 'B'),
    'LAO': (0xA5, 'B'), 'LSA': (0xA6, 'A'), 'LAE': (0xA7, 'UB'), 'MOV': (0xA8, 'B'), 'LDO': (0xA9, 'B'),
    'SAS': (0xAA, 'U'), 'SRO': (0xAB, 'B'), 'XJP': (0xAC, 'X'), 'RNP': (0xAD, 'U'), 'CIP': (0xAE, 'U'),
    'EQU': (0xAF, 'T'), 'GEQ': (0xB0, 'T'), 'GRT': (0xB1, 'T'), 'LDA': (0xB2, 'D'), 'LDC': (0xB3, 'C'),
    'LEQ': (0xB4, 'T'), 'LES': (0xB5, 'T'), 'LOD': (0xB6, 'D'), 'NEQ': (0xB7, 'T'), 'STR': (0xB8, 'D'),
    'UJP': (0xB9, 'S'), 'LDP': (0xBA, ''), 'STP': (0xBB, ''), 'LDM': (0xBC, 'U'), 'STM': (0xBD, 'U'),
    'LDB': (0xBE, ''), 'STB': (0xBF, ''), 'IXP': (0xC0, 'P'), 'RBP': (0xC1, 'U'), 'CBP': (0xC2, 'U'),
    'EQUI': (0xC3, ''), 'GEQI': (0xC4, ''), 'GRTI': (0xC5, ''), 'LLA': (0xC6, 'B'), 'LDCI': (0xC7, 'W'),
    'LEQI': (0xC8, ''), 'LESI': (0xC9, ''), 'LDL': (0xCA, 'B'), 'NEQI': (0xCB, ''), 'STL': (0xCC, 'B'),
    'CXP': (0xCD, 'CXP'), 'CLP': (0xCE, 'U'), 'CGP': (0xCF, 'U'), 'LPA': (0xD0, 'A'), 'STE': (0xD1, 'UB'),
    'EFJ': (0xD3, 'S'), 'NFJ': (0xD4, 'S'), 'BPT': (0xD5, 'B'), 'XIT': (0xD6, ''), 'NOP': (0xD7, ''),
    'SLDC': (0x00, 'K0'), 'SLDL': (0xD7, 'K1'), 'SLDO': (0xE7, 'K2'), 'SIND': (0xF8, 'K3'),
    'LIT': (0x00, 'L'),
}
KRANGE = {'K0': (0, 127), 'K1': (1, 16), 'K2': (1, 16), 'K3': (0, 7)}
CSPS = {'IOC': 0, 'NEW': 1, 'MVL': 2, 'MVR': 3, 'EXIT': 4, 'UREAD': 5, 'UWRITE': 6, 'IDS': 7, 'TRS': 8,
        'TIM': 9, 'FLC': 10, 'SCN': 11, 'GSEG': 21, 'RSEG': 22, 'TNC': 23, 'RND': 24, 'SIN': 25, 'COS': 26,
        'LOG': 27, 'ATAN': 28, 'LN': 29, 'EXP': 30, 'SQT': 31, 'MRK': 32, 'RLS': 33, 'IOR': 34, 'UBUSY': 35,
        'POT': 36, 'UWAIT': 37, 'UCLEAR': 38, 'HLT': 39, 'MEMA': 40}
CMPT = {'REAL': 2, 'STR': 4, 'BOOL': 6, 'SET': 8, 'BYTE': 10, 'WORD': 12}
DIRS = ('PROGRAM', 'SEGMENT', 'MAIN', 'PROC', 'END', 'PARAM', 'VAR', 'GLOBAL', 'EQU', 'EXIT', 'INCLUDE')
MAXCODE = 4000


class Err(Exception):
    pass


def key(name):
    return name.upper()[:8]


def lines_of(path):
    """a source file's lines: a UCSD text file (its 1 KB header, DLE indents, CR) or a plain one"""
    raw = open(path, 'rb').read()
    if raw[:1] == b'\0' or (len(raw) >= 1024 and raw[1024:1025] in (b'\x10',) and b'\r' in raw[1024:]):
        out, cur = [], bytearray()
        i = 1024
        while i < len(raw):
            c = raw[i]
            if c == 16 and i + 1 < len(raw):
                cur += b' ' * (raw[i + 1] - 32)
                i += 2
                continue
            if c == 13:
                out.append(cur.decode('latin1'))
                cur = bytearray()
            elif c != 0:
                cur.append(c)
            i += 1
        return out
    return raw.decode('latin1').replace('\r\n', '\n').split('\n')


class Tok:
    def __init__(self, s, line):
        self.toks = []
        i, n = 0, len(s)
        while i < n:
            c = s[i]
            if c in ' \t':
                i += 1
            elif c == ';':
                break
            elif c == "'":
                j, v = i + 1, ''
                while True:
                    if j >= n:
                        raise Err('a string without its end')
                    if s[j] == "'":
                        if j + 1 < n and s[j + 1] == "'":
                            v += "'"
                            j += 2
                            continue
                        break
                    v += s[j]
                    j += 1
                self.toks.append(('S', v))
                i = j + 1
            elif c.isalpha() or c == '.' and i + 1 < n and s[i + 1].isalpha():
                j = i + 1
                while j < n and (s[j].isalnum() or s[j] == '_'):
                    j += 1
                self.toks.append(('D' if c == '.' else 'I', s[i + (c == '.'):j].upper()))
                i = j
            elif c.isdigit():
                j = i
                while j < n and s[j].isdigit():
                    j += 1
                self.toks.append(('N', int(s[i:j])))
                i = j
            elif c == '$':
                j = i + 1
                while j < n and s[j] in '0123456789abcdefABCDEF':
                    j += 1
                if j == i + 1:
                    raise Err('$ without hex digits')
                self.toks.append(('N', int(s[i + 1:j], 16)))
                i = j
            elif c in ',:+-!':
                self.toks.append(('P', c))
                i += 1
            else:
                raise Err('a character that means nothing here: %s' % c)
        self.i = 0

    def peek(self):
        return self.toks[self.i] if self.i < len(self.toks) else ('E', None)

    def next(self):
        t = self.peek()
        self.i += 1
        return t

    def punct(self, c):
        if self.peek() == ('P', c):
            self.i += 1
            return True
        return False

    def need(self, c):
        if not self.punct(c):
            raise Err('%s expected' % c)

    def end(self):
        if self.peek()[0] != 'E':
            raise Err('more on the line than this needs')


class Asm:
    def __init__(self, src, incdir=None):
        self.src = src
        self.incdir = incdir or os.path.dirname(src)
        self.errors = []

    # ---- names
    def lookup(self, name):
        k = key(name)
        if self.proc and k in self.locals:
            kind, v = self.locals[k]
            if kind in ('PARAM', 'VAR'):
                self.freeze()
                return self.locals[k][1]
        if k in self.glob:
            kind, v, aux = self.glob[k]
            return v
        if self.pas == 2:
            raise Err('%s: not defined' % name)
        return None

    def expr(self, t, need=True):
        neg = t.punct('-')
        total, unknown = 0, False
        first = True
        while True:
            kind, v = t.next()
            if kind == 'N':
                val = v
            elif kind == 'S' and len(v) == 1:
                val = ord(v)
            elif kind == 'I':
                val = self.lookup(v)
                if val is None:
                    unknown, val = True, 0
            else:
                raise Err('a number or a name expected')
            total = total - val if neg else total + val
            if t.punct('+'):
                neg = False
            elif t.punct('-'):
                neg = True
            else:
                break
        if unknown:
            if need:
                raise Err('a name not defined before it is used')
            return None
        return total

    # ---- code
    def ob(self, b):
        if len(self.code) >= MAXCODE:
            raise Err('procedure too long')
        self.code.append(b & 255)

    def big(self, v, force=False):
        if v < 0 or v > 32767:
            raise Err('%d: out of range (0..32767)' % v)
        if v < 128 and not force:
            self.ob(v)
        else:
            self.ob(0x80 | (v >> 8))
            self.ob(v)

    def byte(self, v):
        if v < 0 or v > 255:
            raise Err('%d: out of range (0..255)' % v)
        self.ob(v)

    def word(self, v):
        if v < -32768 or v > 65535:
            raise Err('%d: out of range' % v)
        self.ob(v)
        self.ob(v >> 8)

    def align(self):
        if len(self.code) & 1:
            self.ob(0)

    def label_ref(self, name, kind):
        """a jump's byte (kind 'J') or a case table's word ('W') to a label: fixed at .END"""
        k = key(name)
        if k not in self.labels:
            self.labels[k] = -1
        self.fix.append((len(self.code), k, kind))
        self.ob(0)
        if kind == 'W':
            self.ob(0)

    def instr(self, name, t):
        op, fmt = OPS[name]
        self.freeze()
        fixed = self.pas == 2           # (a fixed-size operand may name what is defined later)
        if fmt.startswith('K'):
            v = self.expr(t, fixed)
            v = 0 if v is None else v
            lo, hi = KRANGE[fmt]
            if not lo <= v <= hi:
                raise Err('%s %d: out of range (%d..%d)' % (name, v, lo, hi))
            self.ob(op + v)
        elif fmt == 'L':
            v = self.expr(t)
            if 0 <= v <= 127:
                self.ob(v)
            else:
                self.ob(0xC7)
                self.word(v)
        elif fmt == '':
            self.ob(op)
        elif fmt == 'U':
            self.ob(op)
            if name == 'CSP' and t.peek()[0] == 'I' and t.peek()[1] in CSPS:
                self.ob(CSPS[t.next()[1]])
            else:
                v = self.expr(t, fixed)
                self.byte(v if v is not None else 0)
            if name in ('RNP', 'RBP'):
                self.lastret = len(self.code) - 2
        elif fmt == 'B':
            self.ob(op)
            force = t.punct('!')
            self.big(self.expr(t), force)
        elif fmt == 'D':
            self.ob(op)
            self.byte(self.expr(t, fixed) or 0)
            t.need(',')
            force = t.punct('!')
            self.big(self.expr(t), force)
        elif fmt == 'UB':
            self.ob(op)
            self.byte(self.expr(t, fixed) or 0)
            t.need(',')
            force = t.punct('!')
            self.big(self.expr(t), force)
        elif fmt == 'P':
            self.ob(op)
            self.byte(self.expr(t, fixed) or 0)
            t.need(',')
            self.byte(self.expr(t, fixed) or 0)
        elif fmt == 'W':
            self.ob(op)
            self.word(self.expr(t, fixed) or 0)
        elif fmt == 'S':
            self.ob(op)
            kind, v = t.next()
            if kind != 'I':
                raise Err('a label expected')
            self.label_ref(v, 'J')
        elif fmt == 'T':
            self.ob(op)
            kind, v = t.next()
            if kind != 'I' or v not in CMPT:
                raise Err('REAL, STR, BOOL, SET, BYTE or WORD expected')
            self.ob(CMPT[v])
            if v in ('BYTE', 'WORD'):
                t.need(',')
                force = t.punct('!')
                self.big(self.expr(t), force)
        elif fmt == 'A':
            kind, v = t.next()
            if kind != 'S':
                raise Err('a string expected')
            if len(v) > 255:
                raise Err('a string longer than 255')
            self.ob(op)
            self.ob(len(v))
            for c in v:
                self.ob(ord(c))
        elif fmt == 'C':
            ws = [self.expr(t, fixed) or 0]
            while t.punct(','):
                ws.append(self.expr(t, fixed) or 0)
            if len(ws) > 255:
                raise Err('more than 255 words')
            self.ob(op)
            self.ob(len(ws))
            self.align()
            for w in ws:
                self.word(w)
        elif fmt == 'X':
            lo = self.expr(t)
            t.need(',')
            hi = self.expr(t)
            t.need(',')
            kind, els = t.next()
            if kind != 'I':
                raise Err('the else label expected')
            labs = []
            while t.punct(','):
                kind, v = t.next()
                if kind != 'I':
                    raise Err('a label expected')
                labs.append(v)
            if len(labs) != hi - lo + 1 or hi < lo:
                raise Err('XJP %d..%d needs %d labels' % (lo, hi, hi - lo + 1))
            self.ob(op)
            self.align()
            self.word(lo)
            self.word(hi)
            self.ob(0xB9)
            self.label_ref(els, 'J')
            for l in labs:
                self.label_ref(l, 'W')
        elif fmt == 'CXP':
            self.ob(op)
            kind, v = t.peek()
            if kind == 'I' and key(v) in self.glob and self.glob[key(v)][0] == 'PROC':
                t.next()
                k, num, seg = self.glob[key(v)]
                self.byte(seg)
                self.byte(num)
            elif kind == 'I' and t.i + 1 == len(t.toks) and self.pas == 1:
                t.next()                        # (a procedure defined later)
                self.ob(0)
                self.ob(0)
            else:
                self.byte(self.expr(t, fixed) or 0)
                t.need(',')
                self.byte(self.expr(t, fixed) or 0)
        t.end()

    # ---- directives
    def namelist(self, t):
        out = []
        while True:
            kind, v = t.next()
            if kind != 'I':
                raise Err('a name expected')
            w = 1
            if t.punct(':'):
                w = self.expr(t)
                if w < 1:
                    raise Err('a size of at least 1')
            out.append((v, w))
            if not t.punct(','):
                break
        t.end()
        return out

    def defglob(self, name, kind, v, aux=0):
        k = key(name)
        if k in self.glob and (self.pas == 1 or self.glob[k][0] != kind):
            if self.pas == 1:
                raise Err('%s: defined twice' % name)
        self.glob[k] = (kind, v, aux)

    def freeze(self):
        """the parameters' and locals' offsets, once they are all declared"""
        if not self.proc or self.frozen:
            return
        self.frozen = True
        off = 1
        for name, w in reversed(self.params):
            self.locals[key(name)] = ('PARAM', off)
            off += w
        self.paramwords = off - 1
        for name, w in self.vars:
            self.locals[key(name)] = ('VAR', off)
            off += w
        self.varwords = off - 1 - self.paramwords

    def start_proc(self, name, lex, main):
        if self.proc:
            raise Err('.END of %s missing' % self.proc)
        if self.segname is None:
            raise Err('.PROGRAM first')
        if main:
            if self.segnum != 1:
                raise Err('.MAIN in segment 1 only')
            if self.hadmain:
                raise Err('.MAIN twice')
            self.hadmain = True
            num = 1
        else:
            if len(self.seg_procs) >= 255:
                raise Err('more than 255 procedures in a segment')
            self.nextproc += 1
            num = self.nextproc
            self.defglob(name, 'PROC', num, self.segnum)
        self.proc, self.procnum, self.lex, self.main = name, num, lex, main
        self.code, self.fix, self.labels, self.locals = bytearray(), [], {}, {}
        self.params, self.vars, self.frozen = ([('INPUT', 1), ('OUTPUT', 1)] if main else []), [], False
        self.lastret, self.exitpos = None, None

    def end_proc(self):
        try:
            self.end_proc1()
        finally:
            self.proc = None    # closed even after an error: no errors about it later

    def end_proc1(self):
        self.freeze()
        name = self.proc
        undef = [k for k, v in self.labels.items() if v < 0]
        if undef:
            raise Err('label not defined: %s' % ', '.join(sorted(undef)))
        exitpos = self.exitpos if self.exitpos is not None else self.lastret
        if exitpos is None:
            raise Err('%s: no RNP or RBP (or .EXIT)' % name)
        code = self.code
        longs = []
        for pos, k, kind in self.fix:
            t = self.labels[k]
            if kind == 'W':
                continue
            off = t - (pos + 1)
            if 0 <= off <= 127:
                code[pos] = off
                continue
            if t not in longs:
                longs.append(t)
            code[pos] = (256 - 10 - 2 * longs.index(t)) & 255
        if len(code) & 1:
            code.append(0)
        base = len(code)
        jtab = base + 2 * len(longs) + 8
        for kk in range(len(longs) - 1, -1, -1):
            pos = jtab - 10 - 2 * kk
            code += struct.pack('<H', (pos - longs[kk]) & 0xFFFF)
        datasz = 2 * (self.globalwords if self.main else self.varwords)
        code += struct.pack('<HHHH', datasz, 2 * self.paramwords, (jtab - 4 - exitpos) & 0xFFFF, jtab - 2)
        code.append(self.procnum)
        code.append(self.lex & 255)
        for pos, k, kind in self.fix:           # the case tables' words: self-relative
            if kind == 'W':
                struct.pack_into('<H', code, pos, (pos - self.labels[k]) & 0xFFFF)
        self.seg_procs.append((self.procnum, self.seglen + jtab))
        self.seglen += len(code)
        if self.pas == 2:
            self.out += code
        self.proc = None

    def start_seg(self, name, num):
        self.end_seg()
        if num is None:
            num = max([7] + [n + 1 for n in self.segsused if n >= 7])
        if not 1 <= num <= 15 or num in self.segsused:
            raise Err('segment number %d: taken or out of range' % num)
        self.segsused.append(num)
        self.segname, self.segnum = name, num
        if num != 1:
            self.defglob(name, 'SEGMENT', num)
        self.seg_procs, self.seglen = [], 0
        self.nextproc = 1 if num == 1 else 0
        if self.pas == 2:
            self.segstart = len(self.out)

    def end_seg(self):
        if self.segname is None:
            return
        if self.proc:
            raise Err('.END of %s missing' % self.proc)
        if self.segnum == 1 and not self.hadmain:
            raise Err('no .MAIN')
        n = len(self.seg_procs)
        jt = dict(self.seg_procs)
        dic = bytearray()
        for j in range(n, 0, -1):
            pos = self.seglen + len(dic)
            dic += struct.pack('<H', (pos - jt[j]) & 0xFFFF)
        dic += bytes([self.segnum, n])
        length = self.seglen + len(dic)
        if self.pas == 1:
            self.segs.append((self.segnum, self.segname, length))
        else:
            self.out += dic
            if len(self.out) - self.segstart != length:
                raise Err('internal: segment %s changed its length between the passes' % self.segname)
            self.out += bytes(-len(self.out) % 512)
        self.segname = None

    def line(self, s):
        t = Tok(s, self.lineno)
        kind, v = t.peek()
        if kind == 'I' and t.i + 1 < len(t.toks) and t.toks[t.i + 1] == ('P', ':'):
            t.next()
            t.next()
            if not self.proc:
                raise Err('a label outside a procedure')
            self.freeze()
            k = key(v)
            if self.labels.get(k, -1) >= 0:
                raise Err('label %s defined twice' % v)
            self.labels[k] = len(self.code)
            kind, v = t.peek()
        if kind == 'E':
            return
        t.next()
        if kind == 'D':
            self.directive(v, t)
        elif kind == 'I' and v in OPS:
            if not self.proc:
                raise Err('an instruction outside a procedure')
            self.instr(v, t)
        else:
            raise Err('%s: not an instruction' % v)

    def directive(self, d, t):
        if d not in DIRS:
            raise Err('.%s: no such directive' % d)
        if d == 'PROGRAM':
            kind, v = t.next()
            if kind != 'I' or self.progname is not None:
                raise Err('.PROGRAM NAME, once')
            t.end()
            self.progname = v[:8]
            self.start_seg(self.progname, 1)
        elif d == 'SEGMENT':
            kind, v = t.next()
            if kind != 'I':
                raise Err('.SEGMENT NAME [NUMBER]')
            num = None
            if t.peek()[0] != 'E':
                num = self.expr(t)
            t.end()
            if self.segname is None:
                raise Err('.PROGRAM first')
            self.start_seg(v[:8], num)
        elif d == 'MAIN':
            t.end()
            self.start_proc('MAIN', 0, True)
        elif d == 'PROC':
            kind, v = t.next()
            if kind != 'I':
                raise Err('.PROC NAME [LEX]')
            lex = 1
            if t.peek()[0] != 'E':
                lex = self.expr(t)
            t.end()
            self.start_proc(v, lex, False)
        elif d == 'END':
            t.end()
            if not self.proc:
                raise Err('.END without .PROC')
            self.end_proc()
        elif d in ('PARAM', 'VAR'):
            if not self.proc or self.frozen:
                raise Err('.%s: at the start of a procedure, before its code' % d)
            if d == 'VAR' and self.main:
                raise Err('.VAR in .MAIN: .GLOBAL')
            for name, w in self.namelist(t):
                if key(name) in [key(n) for n, w2 in self.params + self.vars]:
                    raise Err('%s: declared twice' % name)
                (self.params if d == 'PARAM' else self.vars).append((name, w))
        elif d == 'GLOBAL':
            if self.proc:
                raise Err('.GLOBAL outside procedures')
            for name, w in self.namelist(t):
                self.defglob(name, 'GLOBAL', self.gnext)
                self.gnext += w
        elif d == 'EQU':
            kind, v = t.next()
            if kind != 'I':
                raise Err('.EQU NAME, VALUE')
            t.need(',')
            val = self.expr(t)
            t.end()
            self.defglob(v, 'EQU', val)
        elif d == 'EXIT':
            t.end()
            if not self.proc:
                raise Err('.EXIT outside a procedure')
            self.freeze()
            self.exitpos = len(self.code)
        elif d == 'INCLUDE':
            kind, v = t.next()
            if kind != 'I':
                raise Err('.INCLUDE NAME')
            t.end()
            if self.including:
                raise Err('.INCLUDE in an included file')
            self.include(v)

    def include(self, name):
        path = None
        for cand in (name, name + '.TEXT', name.lower(), name.lower() + '.text', name.lower() + '.pasm'):
            p = os.path.join(self.incdir, cand)
            if os.path.exists(p):
                path = p
                break
        if path is None:
            raise Err('no file %s' % name)
        save = (self.file, self.lineno)
        self.including = True
        self.run_file(path)
        self.including = False
        self.file, self.lineno = save

    def run_file(self, path):
        self.file = os.path.basename(path)
        for no, s in enumerate(lines_of(path), 1):
            self.lineno = no
            try:
                if len(s) > 255:
                    raise Err('a line longer than 255 characters')
                self.line(s)
            except Err as e:
                if self.pas == 2 or not self.errors_pass1_only(e):
                    self.errors.append('%s %d: %s' % (self.file, no, e))
                if len(self.errors) > 50:
                    raise SystemExit('\n'.join(self.errors))

    def errors_pass1_only(self, e):
        return False

    def pass_(self, n):
        self.pas = n
        self.glob = self.glob if n == 2 else {}
        self.progname, self.segname, self.proc, self.hadmain = None, None, None, False
        self.gnext = 3
        self.including = False
        self.segsused = []
        if n == 2:
            self.out = bytearray()
            blk0 = bytearray(512)
            blk = 1
            for num, name, length in self.segs:
                struct.pack_into('<HH', blk0, 4 * num, blk, length)
                blk0[64 + 8 * num:72 + 8 * num] = name.ljust(8).encode('latin1')
                blk += (length + 511) // 512
            self.out += blk0
        else:
            self.segs = []
        self.run_file(self.src)
        try:
            if self.progname is None:
                raise Err('no .PROGRAM')
            self.end_seg()
        except Err as e:
            self.errors.append('%s: %s' % (os.path.basename(self.src), e))
        if n == 1:
            self.globalwords = self.gnext - 3

    def assemble(self):
        self.globalwords = 0
        self.pass_(1)
        if self.errors:
            return None
        self.pass_(2)
        return None if self.errors else bytes(self.out)


def main(a):
    if len(a) < 2:
        print('use: pasm.py SOURCE CODE [-I DIR]')
        return 2
    inc = a[a.index('-I') + 1] if '-I' in a else None
    asm = Asm(a[0], inc)
    code = asm.assemble()
    for e in asm.errors:
        print(e)
    if code is None:
        return 1
    open(a[1], 'wb').write(code)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
