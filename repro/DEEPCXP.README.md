# CXP more than 64 frames deep (P-Code mode only)

`deepcxp.pas` / `DEEPCXP.CODE` (Pascal, 3 blocks) and `deepc.c` /
`DEEPC.CODE` (Tiny-C) do the same thing: a recursive function goes N deep
and then calls a function in another segment (CXP).

| mode   | DOWN(60) | DOWN(70) |
|--------|----------|----------|
| Z80    | 1        | 1        |
| P-Code | 1        | hangs (Z80 PC=137F..1384) |

## Cause (linux-harness, NativeCxp.inc; same pattern in the native CIP in harness.cpp)

For a callee at lex level >= 1, CIPXNL searches the dynamic chain for the
first frame whose lex level is one less. The native code gives up after 64
frames:

```cpp
for (int iter = 0; iter < 64; iter++) { ... }
if (!found) {                             // same bail-out as native CIP
    PM_CPU.r.setBC(examine);
    PM_CPU.r.PC = 0x137F;
    break;
}
```

It then continues at CIPXNL's `$10` loop in Z80 code. That loop expects two
things the native path never sets up:

* **A = the target lex level** (`CP (HL)`). In the trace A was D5.
* **The IPC pushed on the Z80 stack.** `CIPXNL: PUSH BC` saves it, and the
  loop's exit does `POP DE ; get IPC` / `POP HL ; junk old stat link`.

With memory reclaimed, the Z80 code at 137F isn't there at all (it reads as
00 00 00).

Every Tiny-C function is lex level 1 and the target is the lex-0 program
frame, so any cross-segment call made more than about 64 calls deep hits
this. A recursive-descent compiler does that all the time.

Suggested fix: make the search unbounded, as the Z80 loop is, or at least
much larger (the chain always ends at the lex-0 frame). If a bail-out is
kept, it has to push the IPC and set A = target before jumping to 137F.

## The fix

Fixed in `UCSD-Pascal---P-Machine_work-v1.84.zip` (the search runs to
30000 frames; regression tests in its verify/errtest). The tools here
build `run_verify` from that zip; the repro gives the same output in
Z80 and P-Code mode. `deepcxp-engine.patch` is the diff as first tested.
