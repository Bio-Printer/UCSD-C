# Unix tools for TOOLS: -- what to add, what not

The plan for bringing the common Unix/Linux tools to the P-System, kept so the
ideas can be discussed and investigated one at a time.  The reference was the
toolkits usually installed on Windows (Git for Windows / MSYS2, Cygwin,
GnuWin32): GNU coreutils with findutils, diffutils, grep, sed, gawk, tar and
gzip.  BusyBox (and BusyBox-w32) has small versions of nearly all of them and is
where vi came from: the natural source when a tool is ported rather than
written.

Status: **done** (on TOOLS:), **next** (agreed, not started), **investigate**
(worth a closer look first), **later**, **no** (too big, or impossible here).

## What limits the choice

* **Memory**: a program has a few tens of KB; even a tiny tool's code file is
  about 26 blocks because of the library.  A tool that would hold a whole file
  needs a fallback (temporary files, or reading a named file twice).
* **Pipes run one stage at a time**: `A | B` runs A to its end into a
  temporary file, then B.  No endless producer (`yes`), and `head` cannot stop
  the program before it.
* **One program at a time**: no processes, signals or job control.  A program
  starts another only by ending (pexec), or by writing a batch file for the shell.
* **The command line**: at most 80 characters, split at blanks, no quotes.
  Tools that need a blank or a special character in an argument take escapes
  (`\040`, `\t`, `\s` ...).
* **No users or permissions**; no links; directories of at most 77 files
  (sub-volumes for more).
* **Dates and times**: a file's date is a DATEREC (two-digit years: 00-69 the 2000s,
  70-99 the 1900s); since BIGGY 1.34 (OS source 1.16, emulator 2.13) its entry has
  the time of day as well (below).
* **Text files** are UCSD text (1 KB pages, DLE blanks, CR): stdio converts, so a
  line is at most 1023 characters.

## Already there

vi, grep, cat, hexdump, objcopy, more, less, sed, diff, patch, wc, lc, krunch,
grow, shrink, man, binderc; the shell's CD, DIR (ls), TYPE, DELETE (rm), COPY
(cp), MOVE (mv), RENAME, MKDIR, RMDIR, PWD, WHEREIS, VOLUMES (df), MEM, `>`,
`>>`, `<` and `|`.

## Tier 1: small filters, immediately useful

| Tool | Status | Notes |
|---|---|---|
| head | **done** | `-n [-]N`, `-c [-]N`, `-N`, `-q`, `-v`; all but the last N: a named file is read twice, the standard input through memory |
| tail | **done** | `-n [+]N`, `-c [+]N`, `-N`, `+N`, `-q`, `-v`; the same two ways; `-f` impossible |
| sort | **done** | `-b -d -f -n -r -u -s -c -t C -k KEY -o FILE`; in memory, else sorted runs merged through temporary files |
| uniq | **done** | `-c -d -D -u -i -f N -s N -w N`, `[INPUT [OUTPUT]]` |
| tr | **done** | `-c -d -s -t`, ranges, `\` escapes, `[:class:]`, `[c*n]` |
| cut | **done** | `-b`, `-c`, `-f LIST`, `-d C`, `-s`, `--complement`, `--output-delimiter=S` |
| echo | **done** | `-n -e -E` and the `-e` escapes |
| tee | **done** | `-a`, `-i` (ignored), several files |
| find | next | `-name`, `-type`, `-newer`, `-size` into sub-volumes, the names into a pipe; WHEREIS finds names only |
| xargs | next | cannot start the programs itself: writes a batch file for the shell (`@FILE`) and runs it |
| cmp | next | any two files byte by byte (CMPCODE compares code files only) |
| mount | **done** | `MOUNT [#n IMAGE \| -u #n]`: a unit gets another disk image by name (emulator 2.14, CSP 140/141), so a makefile brings each volume on line in turn (MASTER:) |
| touch, date | **done** | `TOUCH [-c] [-d DATE\|-t STAMP\|-r FILE]`, `DATE [-r FILE] [+FORMAT]`: dates and times of day (below) |
| cksum, sum | next | CRC-32 with longs: cheap; checks copies and transfers |

## Tier 2: useful, more work

| Tool | Status | Notes |
|---|---|---|
| nl, fold, expand, unexpand, rev, paste, join, comm, split, strings | later | small; best done as one batch |
| tar | investigate | one file for a whole tree (transfers, backups); 512-byte records match UCSD blocks, sub-volumes map to tar's directories |
| du | later | the blocks of sub-volume trees |
| cal, seq | later | tiny |
| sleep, time | investigate | only if the emulator keeps SYSCOM's clock running |
| dc | later | RPN calculator, arbitrary precision, about 1000 lines |
| bc | later | much bigger than dc; after it, if at all |
| ctags | later | only once vi has `:tag` / `^]` (the BusyBox vi we have does not) |

## Tier 3: possible but too big, or not worth it

| Tool | Status | Notes |
|---|---|---|
| awk | investigate | the most valuable here.  one-true-awk or BusyBox awk: 3000-6000 lines, regular expressions, hashes, floats (UCSD-C's are 32-bit).  Maybe a cut-down awk in code segments; sed covers part of it |
| gzip, zip | no | deflate wants a 32 KB window and tables |
| compress | investigate | 12-bit LZW might just fit; an LZSS packer certainly would |
| make | **done** | files now have a time of day, to the second (below); the recipes run as a shell batch after MAKE ends |
| perl, python, bash, vim, emacs, git, groff, info | no | far too big |

## Impossible or meaningless here

| Tools | Why |
|---|---|
| ps, kill, top, jobs, bg, fg, nohup, nice, timeout, watch, cron, at, `tail -f` | one program at a time, no processes or signals |
| chmod, chown, chgrp, umask, id, whoami, who, su, sudo, passwd, login | no users, no permissions |
| ln, readlink, mkfifo, mount, stty, tty | no links, devices or terminals to set |
| ping, curl, wget, ssh, ftp | no network |
| yes | endless output into a pipe that runs one stage at a time |
| od, xxd; df; ls; which | there already: hexdump/objcopy; VOLUMES; DIR and lc; WHEREIS |

## Files' times of day (BIGGY 1.34, emulator 2.13)

A UCSD directory entry has no field for a time, but two have room: DFKIND's word uses
4 bits (FILLER2 is bits 4..14, the Filer's STATUS bit 15) and DLASTBYTE 10 of its 16.
The time -- seconds since midnight + 1, 0: none -- has its low 11 bits in word 2's bits
4..14 and its high 6 in word 11's bits 10..15.  The OS (SYSTEM.C and SYSTEM.PASCAL,
OS source 1.16) writes it when it closes a file it wrote, with the date, from TIME's
answers of the emulator (25611: the time's parts, 25612: today's date, which THEDATE
follows past midnight); the library writes it for files in sub-volumes; DIR shows it;
MAKE, TOUCH and DATE use it (`<dirs.h>`: entstamp, filetime, setfiletime, pcnow).

* **Older systems and this.**  An older SYSTEM.C (BIGGY 1.27-1.33) checks DLASTBYTE
  when it sees a new disk and *deletes* entries it thinks bad: one whose word 11 is over
  512, i.e. a file written after 00:34:07 by a 1.16 system.  Do not boot an older
  BIGGY with disks written by 1.34 (SYSTEM.PASCAL, any version, reads the 10-bit field
  and is safe).  Host tools that read DLASTBYTE whole need `& 1023` (ucsdvol.py,
  extract_all.py, UCSD-SYSTEM-C's filertest.py and the emulator are changed).
* **Copies.**  The shell's COPY keeps a file's time; the Filer's T(ransfer keeps the
  date but not the time (its own copy of the entry); Import gives a file the Windows
  file's time, Export the other way round.
* **Without the clock** (Options > PC date and time off, and every Verify run without
  `VERIFY_HOSTCLOCK`) files get no time and MAKE compares dates (a file without a time
  is the start of its day).

## To decide

* **Two new files on one disk.**  The P-System gives a new file the largest free
  area of its disk until it is closed, so while a program's output goes into a new
  file (`>FILE`, or the shell's pipe files `#4:PIPE1.TEXT`, `PIPE2.TEXT`) no other
  new file can be made on that disk: `DIR | TEE DIR.TEXT | GREP X` fails with the
  prefix on #4, and so do SORT's `-o FILE` and temporary files and UNIQ's OUTPUT
  there.  The tools say so, and the FILE on another disk works (SORT `-T VOL`).
  A name `NAME[*]` asks the OS for half the largest area (or the second largest):
  `>FILE[*]` leaves room (stdio now takes `NAME.TEXT[*]` as a text file).  Should
  the shell's pipe files, and the library's `>FILE`, always be opened with `[*]`?
  Then they would hold at most half the free area -- a limit they do not have now.

## Notes from doing it

* MAKE cannot run a program and wait for it (one program at a time): it decides
  everything first, writes the recipes into `#4:MAKEn.TEXT` and adds that file to the
  shell's batch files (`#4:SYSTEM.BATCH`, the innermost); the shell runs it after MAKE
  ends and stops at the first recipe that fails (the shell now takes `-COMMAND` in a
  batch file: its status does not stop it).  So `$(shell ...)` is not possible, and a
  recipe's CD stays for the lines after it.  A recipe longer than the shell's 79
  characters is run as `PROG @#4:MAKEnRk` (its arguments in that file, a command a line:
  CC's, BC's and B2's batch files); every volume is rebuilt with makefiles now
  (`MAKE -f UCSD-C:MAKEFILE`: everything).

* **The first batch** (head, tail, sort, uniq, tr, cut, echo, tee) share the
  library's `forfiles()` (ucsdc/lib/fileargs.c, `<dirs.h>`): a FILE argument as it
  is, or each file its wildcards match (`*.C`, `#5:*.TEXT`, `A/*.H`), handed to a
  function of the tool's (a call through a function pointer).  `tools/texttest.py`
  checks them against the host's tools, in both modes.
* The tools are built with `-z`, as all of TOOLS: is (calls through function
  pointers that work in both modes); texttest builds them so.  Built without it,
  HEAD stopped in the test harness's P-Code mode at its first call through a
  pointer.
* SORT keeps its lines in one block of memory, MEMAVAIL less about 7 KB: the
  library's `malloc` gives a freed block back whole (it does not split it), so
  memory set aside and freed would all go to the first small request.
