# 8-byte floating point (`double`)

## The engine side (done): CSP 100..137

`NativeDouble.inc` in the emulator (inside `UCSD-Pascal---P-Machine_work-v1.88.zip`,
included by `PSystemEngine.cpp`'s CSP case; on its own in `emulator/`).
Native P-Code mode only; the Z80 interpreter will never have it (a CSP 100+
there jumps through a table it does not have).

**Format**: IEEE-754 binary64, 8 bytes = 4 words, little-endian, lowest
address first, exactly as `LDM 4` / `STM 4` move a value and as it lies on
the stack from SP up. (Until Tiny-C [0.4] a double was 12 bytes: these 8
plus 4 reserved zero bytes. They were never used and were removed; programs
compiled for the 12-byte engine must be recompiled, and the 12-byte and
8-byte engines and compilers do not mix. `triple` went with them.)

Why binary64: the arithmetic and every function then come from the host's
IEEE hardware and C runtime -- the most tested floating point there is, the
same under MSVC and gcc. 16 significant digits instead of a float's 7,
exponent range 1e±308 instead of 1e±38.

Arguments are pushed first to last; results replace them. D = 8-byte value,
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
| 135 | ATODM | A buf, A dst → I chars used; the value is stored at dst (8 bytes) |
| 136 / 137 | ULTOD / DTOUL | L (unsigned) → D / D → L (unsigned; truncates, saturates at 0 and 4294967295) |

No traps: 1/0 is an infinity, sqrt(-1) a NaN, as in C.

Test: `tools/f12test.py` (51 of 51 pass). `repro/float12/gen.py` writes `f12test.c` + `.expect` (51 checks,
expected values from IEEE doubles); run it with the host compiler on the
P-System in P-Code mode (`tools/tcrun.py` / `runtests.py` style).

## The Tiny-C side (done)

* **Types**: `float` is the 4-byte REAL (works in Z80 mode too); `double`
  and `long double` are the 8-byte type. `sizeof(double)` is 8.
* **Constants**: an unsuffixed constant (`1.5`, `1e10`) is a float; with `L`
  (`1.5L`, `1e300L`) a double. A float constant that meets a double
  (`double d = 0.1;`, `d * 2.5`, `sqrt(d)`'s other arguments) becomes a double
  made from its text, so it is exact to double precision, not a widened
  float. The compiler makes a double's image with CSP 135 on the P-System
  (so compiling double constants needs P-Code mode, like running them) and
  with `strtod` on the host: both give the same bits (the cross-check is
  identical). Integer constants meeting a double become double constants.
* **Code**: loads, stores, arguments, results, arrays and struct members are
  4-word values (LDM/STM 4); constants are LDC 4; `+ - * /` and negation
  are CSP 100..104; comparisons and zero tests CSP 105 with the relation;
  conversions CSP 106..111, 136, 137 (unsigned long: ULTOD/DTOUL; unsigned
  int goes through LTOD/DTOL). `++`, `--` and `+= -= *= /=` work on doubles.
  `__cspd(n, ...)` is an intrinsic for a CSP that leaves a double.
* **Library**: `printf` prints a double with `%lf %le %lg %LE ...` (l or L; with no
  precision given `%lg` shows 10 significant digits, `%lf` / `%le` 6 decimals;
  in the library plain `%f` is a float, as float arguments stay 4 bytes).
  With a literal format the compiler matches the arguments as in standard
  C: a double meeting `%f %e %g` gets the `l` inserted (`printf("%g", d)`
  works), a float meeting `%lf` is widened, and `scanf("%f", &d)` of a
  double becomes `%lf` (printf, fprintf, sprintf, scanf, fscanf, sscanf).
  A format that is not a literal needs the `l` written. The math.h
  functions are declared for float; called with a double first argument
  they become the CSPs directly (sqrt sin cos tan asin acos atan atan2 exp
  log log10 pow floor ceil fabs fmod sinh cosh tanh ldexp frexp).
* **Reading doubles**: `scanf("%lf", &d)` (or `%Lf`, `%le` ...) stores a
  double (the characters read go through CSP 135); `strtold` and `atold`
  (C99 names, in `<stdlib.h>`) return a double. `strtod` and `atof` stay
  float, so programs using them still run in Z80 mode.
* **Tests**: `tests/doubles.c` (P-Code mode only), `tools/f12test.py` (the
  CSPs themselves). The double-capable compiler still rebuilds itself in
  Z80 mode (`@BUILD`), identical to the host build.
