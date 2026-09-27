# Tiny-C Verify

A keyboard script in the Verify P-System format (`PSystemVerify.h`: WAIT /
TYPE) that checks Tiny-C on the P-System itself:

1. every test program in `tests/` is compiled with TINYC and run; each
   line of its expected output (`tests/NAME.expect`) must appear, in order
2. the compiler compiles its own 12 modules and links them to TINYC2.CODE;
   CMPCODE (a Tiny-C program, `cmpcode.c`) must report it IDENTICAL to
   TINYC.CODE (block 0's program-name bytes aside)
3. TINYC2 compiles and runs HANOI

If an expected text never appears, the run stops at the next prompt with
"expected ... but the system is waiting for input", like the P-code Verify.

| File | |
|---|---|
| `TCVERIFY.SCRIPT` | the script (generated) |
| `TCVERIFY.zip` | `TCVERIFY.BLK`, volume TINYCV:, which goes on unit #5 |
| `cmpcode.c` | the byte-compare program (on the volume as CMPCODE.CODE) |
| `rmfiles.c` | removes each test's .OBJ and .CODE after it runs (a UCSD directory holds 77 files) |

Both files are generated from the current sources by `tools/mkverify.py`.
On Linux, `tools/tcverify.py [native|z80]` runs the pack through
`build/run_verify`, the same engine and runner the GUI uses.

## Requirements

* **P-Code mode with the interpreter memory reclaimed.** Tiny-C needs
  that memory; without it the code generator stops with STK OFLOW.
* The 64-frame CXP fix (`repro/DEEPCXP.README.md`) is *not* needed today.
  The compiler used to hang in EXPR without it, but only because its
  16-bit wrap macro (W16) called the long-arithmetic helpers in segment 1
  from deep inside the parser. Since W16 became a no-op on the P-System,
  the pack passes on the unfixed engine too. Programs that recurse more
  than 64 deep and then call into another segment still need the fix.
* About 585 script steps; the whole run takes about 16 s in P-Code mode on Linux.

## Wiring it into the menu (a sketch)

The existing Verify uses `verify\SOURCE.BLK` (unit 5), `verify\COMPASM.BLK`
(unit 9), `verify\VERIFY.SCRIPT` and a P-code reference log. A
"Verify Tiny-C..." item can reuse the same machinery with:

* unit 5 = `verify\TCVERIFY.BLK`, script = `verify\TCVERIFY.SCRIPT`
  (unit 9 can be any volume: COMPASM.BLK is fine);
* no reference log: pass or fail comes from the script alone
  (`VerifyRunner` DONE vs FAILED). Skip `StartVerifyLog` and the
  `VerifyMismatch` checks;
* the reclaimed-memory settings: `SetNativePcodeOps(true)`,
  `SetPreserveZ80RegisterCompat(false)`, `SetReclaimInterpreterMemory(true)`.

A reference log could be recorded for it too, like the reclaimed-memory
P-code log, if you want instruction-level regression checking.
