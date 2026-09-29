# 12-byte floating point ("double" / "triple")

## The engine side (done): CSP 100..134

`NativeFloat12.inc` in the emulator (inside `UCSD-Pascal---P-Machine_work-v1.88.zip`,
included by `PSystemEngine.cpp`'s CSP case). Native P-Code mode only; the Z80
interpreter will never have it (a CSP 100+ there jumps through a table it
does not have).

**Format**: 12 bytes = 6 words, lowest address first, exactly as `LDM 6` /
`STM 6` move a value and as it lies on the stack from SP up:

| bytes | |
|---|---|
| 0..7 | IEEE-754 binary64, little-endian |
| 8..11 | 0 (reserved) |

Why binary64 rather than a true 12-byte format: the arithmetic and every
function then come from the host's IEEE hardware and C runtime — the most
tested floating point there is, the same under MSVC and gcc. (MSVC has no
80-bit `long double`; x87 extended in 12 bytes would need a software library
such as Berkeley SoftFloat, which has no sin/cos/exp/log.) 16 significant
digits instead of 7, exponent range 1e±308 instead of 1e±38. The reserved 4
bytes let a wider format replace it later (programs would be recompiled).

Arguments are pushed first to last; results replace them. D = 12-byte value,
F = 4-byte UCSD real, I = word, L = long (low word on top), A = address.

| CSP | name | stack in → out |
|---|---|---|
| 100..103 | DADD DSUB DMUL DDIV | D a, D b → D |
| 104 | DNEG | D → D |
| 105 | DCMP | D a, D b, I rel → I 1 if a rel b holds, else 0; rel 0 == 1 != 2 < 3 <= 4 > 5 >=, +8 negates (with a NaN only != holds) |
| 106 / 107 | FTOD / DTOF | F → D / D → F (saturates; tiny → 0.0) |
| 108 / 109 | ITOD / DTOI | I → D / D → I (truncates, saturates) |
| 110 / 111 | LTOD / DTOL | L → D / D → L (truncates, saturates) |
| 112..118 | DSQRT DSIN DCOS DTAN DASIN DACOS DATAN | D → D |
| 119 | DATAN2 | D y, D x → D |
| 120..122 | DEXP DLN DLOG10 | D → D |
| 123 | DPOW | D x, D y → D |
| 124..126 | DFLOOR DCEIL DFABS | D → D |
| 127 | DFMOD | D x, D y → D |
| 128..130 | DSINH DCOSH DTANH | D → D |
| 131 | DLDEXP | D x, I n → D |
| 132 | DFREXP | D x, A ^int → D |
| 133 | DTOA | D x, I fmt ('e' 'f' 'g'), I prec (0..17), A buf → (none); buf := text, ≤ 40 chars |
| 134 | ATOD | A buf → D x, I chars used (C's strtod; 0 = no number) |
| 135 | ATODM | A buf, A dst → I chars used; the value is stored at dst (12 bytes) |

No traps: 1/0 is an infinity, sqrt(-1) a NaN, as in C.

Test: `tools/f12test.py` (36 of 36 pass). `repro/float12/gen.py` writes `f12test.c` + `.expect` (36 checks,
expected values from IEEE doubles); run it with the host compiler on the
P-System in P-Code mode (`tools/tcrun.py` / `runtests.py` style).

## The Tiny-C side (to do)

**Types.** Today `float`, `double` and `long double` are all the 4-byte real
(`TY_FLOAT`, `TY_DOUBLE`, `TY_LDOUBLE`, size 4). Proposal:

* `float` stays 4 bytes (the P-machine's REAL: works in Z80 mode too).
* `double` and a new keyword `triple` are the 12-byte type (size 12, 6 words);
  `long double` the same.
* Unsuffixed floating constants stay `float` unless a `#pragma double` (or
  the `L` suffix / a `double` context) says otherwise — so existing programs
  keep running in Z80 mode. (Strict C would make `1.0` a double; that would
  put every float program on the CSPs.)

**Compiler work** (roughly in order):

1. lex.c: `triple` keyword; floating literals keep their text so a 12-byte
   image can be made. The compiler runs on the P-System, where it has only
   4-byte reals: the image for a `double` constant comes from CSP 134 (ATOD)
   at compile time (host build: `strtod`), so building double constants
   needs P-Code mode — fine, running them needs it anyway.
2. types / psym: TY_DOUBLE size 12, `isfloatty` split into "real" (4) and
   "double" (12); usual arithmetic conversions: int/long/float → double
   when the other operand is double.
3. expr.c: casts and conversions call ITOD/LTOD/FTOD/DTOI/DTOL/DTOF;
   comparisons use DCMP + a compare of its word with 0.
4. gen.c: a double value is 6 words: loads/stores with LDM 6 / STM 6 (as
   structs of 12 bytes are moved today); + - * / neg are CSP 100..104;
   constants via LDC 6 words (or a 12-byte literal in the code + LDM);
   parameters and results of 6 words (the frame layout already handles
   multi-word values: longs and structs).
5. lib: math.h `double` functions → CSP 112..132 (sqrt, sin, cos, tan,
   asin, acos, atan, atan2, exp, log, log10, pow, floor, ceil, fabs, fmod,
   sinh, cosh, tanh, ldexp, frexp); printf `%f %e %g` for doubles → DTOA;
   scanf/strtod/atof → ATOD. The current 4-byte versions stay for float
   (`sqrtf` ... or chosen by argument type).
6. Tests: a doubles test (P-Code mode only; Tiny-C Verify skips it in Z80).

Memory: the new code goes mostly into GEN and PARSE; Z80 mode had ~165
words to spare in code generation (plus the driver's 1 KB since), so the
additions should stay compact, or the conversions can be table-driven.
