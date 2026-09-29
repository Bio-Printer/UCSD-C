# Adding 12-byte floating point (CSP 100..137) to the Windows emulator

Tiny-C's `double` / `triple` / `long double` need the engine's CSP 100..137.
**The Tiny-C compiler itself uses CSP 135** to build every double constant,
so an emulator without these CSPs will crash or hang (an unknown CSP
selector falls through to the Z80 CSPTRAP path, whose table entry is zero)
as soon as a program with `double` is compiled or run.

The change is one new file and four lines in one existing file:

1. Copy `NativeFloat12.inc` (this folder) into `UCSDPascal\`, next to
   `NativeCsp.inc` etc.  (Adding it to the Visual Studio project is optional:
   it is `#include`d, not compiled on its own.)
2. In `UCSDPascal\PSystemEngine.cpp`:
   * with the other standard includes near the top, add
     ```cpp
     #include <climits>
     #include <cstdlib>
     ```
     (`<cstdio>`, `<cstring>`, `<cmath>` are already there);
   * in the `OP_CSP` case, directly **before** the line
     `if (procNum >= 25 && procNum <= 31) {`
     (after the comment block ending "...is a reasonable fallback."), add
     ```cpp
                     // 12-byte floating point: CSP 100..137 (NativeFloat12.inc)
     #include "NativeFloat12.inc"
     ```
   `PSystemEngine-float12.patch` is the same change as a unified diff
   (against the v1.88 you supplied); `git apply` or `patch -p1` applies it
   in the `UCSD-Pascal---P-Machine_work` folder.
3. Rebuild (Release) and run in **P-Code mode** (native). Z80 mode will
   never have these CSPs.

`UCSD-Pascal---P-Machine_work-v1.88.zip` in the repository root is the
whole emulator with this change already made (plus the Linux runner used by
the tools); `build/pm/...` is where `tools/setup.sh` unpacks it.

What the CSPs do (format, stack effects): `docs/FLOAT12.md`.
Test: `tools/f12test.py` (51 checks).

Quick check after rebuilding: boot BIGGY, prefix TCEXTRA:, `X` `*TINYC`,
compile `DOUBLES`, then `X` `DOUBLES`: the last line is
`3.1415926535897931 [xyz] 1e+301`.
