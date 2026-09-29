# Tiny-C for UCSD Pascal II.0

A C compiler (a practical subset of C) that runs **on** the UCSD Pascal
II.0 P-System and produces P-code `.CODE` files. It is written in the same
subset, so it compiles itself: the P-System-built compiler is byte-identical
to the host-built one.

Start here when picking the project up in a new session.

## Repository layout

| Path | What |
|---|---|
| `tinyc/*.c`, `tc.h`, `parse.h` | the compiler: `main` (driver, `@FILE` batches), `util`, `types`, `pp` (preprocessor), `lex`, `psym`/`expr`/`decl`/`stmt` (parser), `ir` (intermediate file), `gen` (P-code), `link` (linker, `/J` join) |
| `tinyc/lib/*.c`, `libint.h` | the C library (joined into `TCLIB.OBJ`) |
| `tinyc/include/*.h` | headers; `tcmsgs.txt` = the compiler's messages (TCMSGS.TEXT) |
| `tests/NAME.c` + `.expect` (+ `.keys`, `.wait`) | test/demo programs and their expected output |
| `volumes/` | **TINY-C.zip** (compiler, library, headers, all sources, BUILD/LIBS scripts) **TCEXTRA.zip** (tests/demos, CMPCODE) and **BIGGY.zip** (boot disk `Big_Disk.BLK` with Tiny-C ready to use; doubles need the v1.88 emulator's CSP 100..135); `*.txt` = file listings |
| `verify/` | Tiny-C Verify pack: `TCVERIFY.SCRIPT` + `TCVERIFY.zip`, `cmpcode.c`, `rmfiles.c`, README |
| `repro/` | engine bug repros (REAL compare, DEEPCXP: both fixed in the engine) |
| `tools/` | host tools (below) |
| `UCSD-Pascal---P-Machine_work-v1.88.zip` | the emulator (engine, Linux runner `verify/run_verify.cpp`) |
| `Usefull_System_Disk_Images.zip`, `pascal.bin` | boot disk images, the Z80 loader |

## Tools (Linux; `tools/setup.sh` unpacks the zips into `build/` and builds `build/run_verify`)

| Tool | Does |
|---|---|
| `runtests.py [name]` | compile each test with the host compiler, run it on the P-System, compare with `.expect` |
| `crosscheck.py` | compile each test **on the P-System** too; the code files must be identical |
| `selfcompile.py [module]` | compile the compiler's modules on the P-System, link TINYC2.CODE, compare with the host build |
| `buildtc.py` | host build of TINYC.CODE from the modules (`build/tcmod/`) |
| `mkvolume.py` | build `volumes/` (TINY-C, TCEXTRA) with FILES.TEXT listings |
| `mkbiggy.py` | build `volumes/BIGGY.zip`: the emulator's `Big_Disk.BLK` (boot volume BIGGY:) with TINYC.CODE, TCLIB.OBJ, TCMSGS.TEXT and the headers added |
| `voltest.py` | on the volumes: `@LIBS`, `@BUILD`, `@DEMOS`, CMPCODE checks; reports least free memory |
| `mkverify.py`, `tcverify.py [native\|z80]` | build / run the Tiny-C Verify pack (`TCV_MAX=seconds` for Z80 mode) |
| `modes.py prog.c` | run a program in Z80 and P-Code mode and compare (engine bug hunting) |
| `pdis.py FILE.CODE` | P-code disassembler |
| `f12test.py` | test the 12-byte floating point CSPs 100..134 (P-Code mode; see `docs/FLOAT12.md`) |
| `ucsdvol.py` | read/write UCSD volume images (`ls`, `get`, `put`, `rm`, `new`) |
| `psys.py`, `tcrun.py`, `selfhost.py` | library code used by the above |

Host compiler: `build/tc [-c] [-I dir] [-L lib.obj] [-o out] files` (built from
`tinyc/tc.c` by `tcrun.build_tc()`). Environment: `PSYS_MODE=z80|native`,
`VERIFY_RECLAIM=1` (P-Code mode with the Z80 interpreter's memory reclaimed),
`TINYC_MAP=1` (linker prints procedure addresses).

Before committing a compiler change, run: `runtests.py`, `crosscheck.py`,
`selfcompile.py`, `mkvolume.py` + `voltest.py`, `mkverify.py` + `tcverify.py`.

## On the P-System

`X(ecute TINYC`, then at "Compile what file?":
`NAME` (compile NAME.C, or NAME.TEXT, and link), `/C NAME`, `/L OUT=A,B`,
`/J LIB=A,B` (join objects into a library), `@FILE` (commands from FILE.TEXT).
Sources are `NAME.C`, headers `NAME.H` (UCSD text format, text kind).
`@BUILD` rebuilds the compiler (TINYC2.CODE), `@LIBS` the library (TCLIB2.OBJ),
`@DEMOS` (on TCEXTRA:) every program there.

## Status (September 2026)

* Self-hosting, byte-identical, in P-Code mode and in **Z80 mode** (Z80 mode
  has 3,915 words less memory; tightest: code generation of STMT/GEN, ~165
  words to spare — the driver's 1 KB stack saving since then adds to that).
* The Z80 interpreter on the boot disk has no SIN/COS/EXP/ATAN/SQT/LOG/LN
  (assembled with NOFPT): `math.h` functions stop there with "Unimplemented
  instruction"; P-Code mode has them.
* Memory techniques in use: per-pass heap (MARK/RELEASE, free list set aside
  across a pass), pass-only tables allocated per pass, shared function types,
  parameter names kept apart (`pnames`), header declarations kept only when
  used (`scanrefs` Bloom filter), prototypes declared under `#pragma segment`
  so calls within a segment are 2-byte CGPs (linker checks: message 116).
* Limits: 10 segments per program (1 + 7..15), 77 files per UCSD directory.
* **12-byte doubles** (`double`, `triple`, `long double`; P-Code mode only):
  IEEE binary64 via the engine's CSP 100..135 — see `docs/FLOAT12.md`.
  `float` stays the 4-byte REAL; unsuffixed constants are float, `1.5L` double.

## Ideas not done yet

* More code-size work in the code generator (e.g. 1-byte global operands).
* A "Verify Tiny-C" item in the emulator's menu (sketch in `verify/README.md`).
* Doubles: scanf/strtod/atof for doubles, `++`/`--` on a double (see
  `docs/FLOAT12.md`).
