# The 8-byte `double` (CSP 100..137) in the Windows emulator

Tiny-C's `double` / `long double` need the engine's CSP 100..137.
**The Tiny-C compiler itself uses CSP 135** to build every double constant,
so an emulator without these CSPs will crash or hang (an unknown CSP
selector falls through to the Z80 CSPTRAP path, whose table entry is zero)
as soon as a program with `double` is compiled or run.

A double is 8 bytes (IEEE binary64). Until Tiny-C [0.4] it was 12 bytes
(`NativeFloat12.inc`); the engine, the compiler, the library and every
program using doubles must be of the same kind -- they do not mix.

## Updating from the 12-byte version (NativeFloat12.inc)

1. Delete `UCSDPascal\NativeFloat12.inc` (and remove it from the Visual
   Studio project if you added it there).
2. Copy `NativeDouble.inc` (this folder) into `UCSDPascal\`.
3. In `UCSDPascal\PSystemEngine.cpp` change the two lines
   ```cpp
                   // 12-byte floating point: CSP 100..137 (NativeFloat12.inc)
   #include "NativeFloat12.inc"
   ```
   to
   ```cpp
                   // 8-byte floating point (double): CSP 100..137 (NativeDouble.inc)
   #include "NativeDouble.inc"
   ```
4. Rebuild (Release). Use the new volumes (compiler banner `[0.4]`) and
   recompile any program of your own that uses `double`.

## Adding it to an emulator that has neither

1. Copy `NativeDouble.inc` into `UCSDPascal\`, next to `NativeCsp.inc` etc.
   (Adding it to the project is optional: it is `#include`d, not compiled on
   its own.)
2. In `UCSDPascal\PSystemEngine.cpp`:
   * with the other standard includes near the top, add
     `#include <climits>` and `#include <cstdlib>`;
   * in the `OP_CSP` case, directly **before** the line
     `if (procNum >= 25 && procNum <= 31) {`
     (after the comment block ending "...is a reasonable fallback."), add
     ```cpp
                     // 8-byte floating point (double): CSP 100..137 (NativeDouble.inc)
     #include "NativeDouble.inc"
     ```
   `PSystemEngine-double.patch` is the same change as a unified diff
   against the v1.88 you supplied (`patch -p1` in the
   `UCSD-Pascal---P-Machine_work` folder).
3. Rebuild and run in **P-Code mode** (native). Z80 mode will never have
   these CSPs.

`UCSD-Pascal---P-Machine_work-v1.88.zip` in the repository root is the
whole emulator with this change already made (plus the Linux runner used by
the tools).

What the CSPs do (format, stack effects): `docs/DOUBLES.md`.
Test: `tools/f12test.py` (51 checks).

Quick check after rebuilding: boot BIGGY, prefix TCEXTRA:, `X` `*TINYC`
(banner `[0.4]`), compile `DOUBLES`, then `X` `DOUBLES`: it prints `8` for
`sizeof(double)` and ends with `X=3.141592654 X=3.14159 X=3.1416`.
