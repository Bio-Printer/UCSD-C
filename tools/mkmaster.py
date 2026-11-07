#!/usr/bin/env python3
"""mkmaster.py -- build/MASTER.BLK, the volume MASTER: (with build/SOURCE.BLK, an empty volume
SOURCE:): one makefile that rebuilds everything -- what is new (Tiny-C, its tools, the demos
and tests, the OS in C, the Pascal compiler in C, BC and B2, PASM) and the original UCSD Pascal II.0
programs from their source disks:

  MAKEFILE.TEXT          MAKE -f MASTER:MAKEFILE: each part the MAKE of its own makefile,
                         the volume it needs mounted first (MOUNT: emulator 2.14)
  ORIG/MAKEFILE.TEXT     the original programs: each source disk mounted on #10 in turn
                         (U134.4, the OS, on #5: its $I names #5:), then the MAKE of
  ORIG/U132A.TEXT ...    its makefile, which compiles each program with PC (the Pascal
                         compiler in C, PASCALC:) into
  ORIG/CODE/             SYSTEM.COMPILER, SYSTEM.PASCAL, SYSTEM.FILER, SYSTEM.LINKER ...
  README.TEXT, FILES.TEXT

A makefile cannot look at the files of a disk not yet on line (MAKE decides everything before
the shell runs a recipe), so each disk's makefile is run by a recipe after the MOUNT.  The
images are looked for beside the one on the unit (UCSD-Pascal-Volumes' BLK_format holds them
all).  The source disks are read from UCSD-Pascal-Volumes ($VOLUMES, or beside this
repository) for the files each program includes ($I): its prerequisites."""
import os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from mkvolume import Dir, wrap

VOLUMES = os.environ.get('VOLUMES') or next((p for p in (os.path.join(os.path.dirname(ROOT), n)
                                                            for n in ('ucsd-pascal-volumes', 'UCSD-Pascal-Volumes'))
                                             if os.path.isdir(p)), os.path.join(os.path.dirname(ROOT), 'UCSD-Pascal-Volumes'))
BLK = os.path.join(VOLUMES, 'BLK_format')

# each source disk: its makefile's name, the image, the unit it goes on, the programs
# (the source, without .TEXT; the code file, its exact name), and what it is
ORIG = [
    ('U132A', 'U132.A_PASCAL_COMPILER_SOURCE_v1.08', 10, [('COMPILER', 'SYSTEM.COMPILER')], 'the Pascal compiler'),
    ('U132B', 'U132B.2_PASCAL_LINKER_SOURCE', 10, [('LINK', 'SYSTEM.LINKER')], 'the linker'),
    ('U128', 'U128_L2_YALOE_SOURCE_v1.06', 10, [('L2', 'L2.CODE')], 'L2, the line editor (YALOE in it)'),
    ('U126', 'U126_EDITOR_SOURCE', 10, [('EDITOR', 'SYSTEM.EDITOR')], 'the screen editor'),
    ('U130', 'U130.1_BASIC_SOURCE', 10, [('BASIC', 'BASIC.COMPILER'), ('BASICIO', 'BASICIO.CODE')], 'the BASIC compiler'),
    ('U136', 'U136.3_LONG_INTEGER_SOURCE', 10, [('PASCALIO', 'PASCALIO.CODE')], 'PASCALIO (long integers)'),
    ('U138', 'U138.3_UTILITY_SOURCE', 10, [(n, n + '.CODE') for n in
                                           ('COPYDUPDIR', 'DISASM.II', 'EDITTORT11', 'LIBMAP', 'MARKDUPDIR', 'RT11TOEDIT', 'SETUP')],
     'the utilities'),
    ('U123', 'U123.1_Z80_ASSEM_SOURCE', 10, [('ASMZ80', 'ASMZ80.CODE')], 'the Z80 assembler'),
    ('U124', 'U124.1_LSI-11_ASSEM_SOURCE', 10, [('ASM11', 'ASM11.CODE')], 'the LSI-11 assembler'),
    ('U134', 'U134.4_OS_SOURCE_v1.16', 5, [('SYSTEM', 'SYSTEM.PASCAL'), ('II.0.FILER', 'SYSTEM.FILER')],
     'the operating system and the Filer'),
]
CODEDIR = 'MASTER:/ORIG/CODE/'

README = """MASTER                                                volume MASTER:

One makefile that rebuilds everything: what is new -- Tiny-C (the compiler,
its library, its tools), the demos and tests, the operating system in C, the
Pascal compiler in C, BC and B2, PASM (the P-code assembler) -- and the original UCSD Pascal II.0 programs
from their source disks.  From the shell (S at the Command: prompt):

    MAKE -f MASTER:MAKEFILE              everything (what changed)
    MAKE -f MASTER:MAKEFILE ORIG         the original programs only
    MAKE -f MASTER:/ORIG/MAKEFILE U132A  one source disk's (as named below)

It needs emulator 2.14 or later (MOUNT: a program gives a unit another disk
image), P-Code mode with Options > Harvard Mode on (BC and B2 rebuilding
themselves need its memory), and every image in one folder on the PC, as UCSD-Pascal-Volumes'
BLK_format has them: BIGGY (Big_Disk.BLK) on #4, TINY-C on #5, MASTER on #9,
TOOLS on #11 (MAKE, MOUNT).  It mounts the others itself, by their names, from
the folder of the image on the unit: #12 TCEXTRA, TCTESTS, SYS-C, PASCAL-C,
U016.1_PCODE_ASSEM (PASM: it rebuilds itself) in turn, #13 BASIC, BASIC2 and SOURCE, #10 each source disk; for the operating
system's sources (their $I name #5:) U134.4_OS_SOURCE_v1.16 on #5, then TINY-C
again, and the prefix on it.  (If it stops there, MOUNT #5 TINY-C.)

THE ORIGINAL PROGRAMS are compiled with PC, the Pascal compiler in C
(PASCALC:), which makes the same code files as SYSTEM.COMPILER, into
MASTER:/ORIG/CODE:
%s
Each is compiled again when its source or a file it includes ($I) is newer
than its code file (MAKE -B: all of them).  The screen editor's $I names the
volume SOURCE:: its sources are copied onto SOURCE: (SOURCE.BLK, empty) first.
Not made here: the P-code interpreters and BIOSes (assembly: U120), which the
assembler and the linker make by answering their questions.

MASTER:/ORIG/MAKEFILE.TEXT mounts each disk and runs its makefile
(MASTER:/ORIG/U132A.TEXT ...: a makefile cannot look at the files of a disk not
yet on line -- MAKE decides everything before the shell runs a recipe).
"""


def disk_files(image):
    """the names on a source disk, and a reader of its text files"""
    v = ucsdvol.Volume(os.path.join(BLK, image + '.BLK'))
    names = {e[3].upper() for e in v.entries}
    return names, lambda n: ucsdvol.ucsd_to_text(v.read(n)[0])


def includes(name, names, read, seen=None):
    """the files a source includes ($I NAME, NAME.TEXT; a volume -- #5:, SOURCE: -- left off: they
    are on its disk), and theirs, in order"""
    seen = [] if seen is None else seen
    for m in re.finditer(r'[({]\*?\$I\s*([^*}+\-\s][^*}]*?)\s*\*?[)}]', read(name), re.I):
        n = m.group(1).strip().upper()
        n = n.split(':')[-1]
        for f in (n, n + '.TEXT'):
            if f in names:
                if f not in seen:
                    seen.append(f)
                    includes(f, names, read, seen)
                break
    return seen


def disk_makefile(key, image, unit, progs, what):
    names, read = disk_files(image)
    u = '#%d:' % unit
    out = ''.join('# %s\n' % l for l in (
        'MAKEFILE -- %s, from %s' % (what, image),
        'on %s: run by MASTER:/ORIG/MAKEFILE after it mounts that disk (MAKE -f' % u,
        'MASTER:/ORIG/%s alone: mount it first).  Each program is compiled by PC (PASCALC:)' % key,
        'when its source or a file it includes is newer than its code file in MASTER:/ORIG/CODE.'))
    out += 'S = %s\nC = %s\n\n' % (u, CODEDIR)
    out += wrap(['$(C)%s' % c for s, c in progs], 'all :') + '\n'
    for src, code in progs:
        deps = [src + '.TEXT'] + includes(src + '.TEXT', names, read)
        out += wrap(['$(S)' + d for d in deps], '$(C)%s :' % code)
        if key == 'U126':
            # its $I names SOURCE:HEAD ...: the disk's text files onto the volume SOURCE: first
            out += '\tCOPY $(S)*.TEXT SOURCE:\n\tCD SOURCE:\n'
        else:
            out += '\tCD $(S)\n'
        out += '\tPC %s $(C)%s.\n' % (src, code)
    return out + '\n.PHONY : all\n'


def orig_makefile():
    out = ''.join('# %s\n' % l for l in (
        'MAKEFILE -- the original UCSD Pascal II.0 programs, from their source disks: each',
        'disk mounted (MOUNT: emulator 2.14), then the MAKE of its makefile here, which',
        'compiles each program with PC (PASCALC: on #12) into MASTER:/ORIG/CODE.  From the',
        'shell: MAKE -f MASTER:/ORIG/MAKEFILE, or ... U132A for one disk\'s.  The images are',
        'looked for beside the one on the unit (UCSD-Pascal-Volumes\' BLK_format).')) + '\n'
    out += wrap([k for k, i, u, p, w in ORIG], 'all :') + '\n'
    for key, image, unit, progs, what in ORIG:
        out += '# %s: %s\n%s :\n' % (key, what, key)
        if key == 'U126':
            out += '\tMOUNT #13 SOURCE\n'
        out += '\tMOUNT #%d %s\n\t$(MAKE) -f MASTER:/ORIG/%s\n' % (unit, image, key)
        if unit == 5:
            out += '\tMOUNT #5 TINY-C\n\tCD TINY-C:\n'
    return out + '\n' + wrap([k for k, i, u, p, w in ORIG], '.PHONY : all')


MASTER = """# MAKEFILE -- everything: what is new and the original UCSD Pascal II.0 programs, each
# part the MAKE of its own makefile, its volume mounted first (MOUNT: emulator 2.14).
# From the shell, with BIGGY on #4, TINY-C on #5, MASTER on #9, TOOLS on #11 and the
# other images in the same folder on the PC: MAKE -f MASTER:MAKEFILE, or ... BASIC for
# one part (TINYC DEMOS TESTS SYSC PASCALC BASIC BASIC2 PASM ORIG).  MASTER:README.TEXT.
all : TINYC DEMOS TESTS SYSC PASCALC BASIC BASIC2 PASM ORIG

# Tiny-C: the compiler, its library, the tools
TINYC :
\t$(MAKE) -f TINY-C:/SRC/CC/MAKEFILE
\t$(MAKE) -f TINY-C:/SRC/LIB/MAKEFILE
\t$(MAKE) -f TOOLS:/SRC/MAKEFILE
DEMOS :
\tMOUNT #12 TCEXTRA
\t$(MAKE) -f TCEXTRA:MAKEFILE
TESTS :
\tMOUNT #12 TCTESTS
\t$(MAKE) -f TCTESTS:MAKEFILE
# the operating system in C
SYSC :
\tMOUNT #12 SYS-C
\t$(MAKE) -f SYS-C:MAKEFILE
# the Pascal compiler in C
PASCALC :
\tMOUNT #12 PASCAL-C
\t$(MAKE) -f PASCALC:/SRC/MAKEFILE
# BC and B2, the BASIC compilers
BASIC :
\tMOUNT #13 BASIC
\t$(MAKE) -f BASIC:MAKEFILE
BASIC2 :
\tMOUNT #13 BASIC2
\t$(MAKE) -f BASIC2:MAKEFILE
# PASM, the P-code assembler, rebuilt by itself (U016.1)
PASM :
\tMOUNT #12 U016.1_PCODE_ASSEM
\t$(MAKE) -f U016.1:MAKEFILE
# the original programs (PC on PASCALC:)
ORIG :
\tMOUNT #12 PASCAL-C
\t$(MAKE) -f MASTER:/ORIG/MAKEFILE

.PHONY : all TINYC DEMOS TESTS SYSC PASCALC BASIC BASIC2 PASM ORIG
"""


def main():
    m = Dir('MASTER')
    progs = ''.join('    %-6s %-35s %s\n' % (k, ', '.join(c for s, c in p), w) for k, i, u, p, w in ORIG)
    m.text('README.TEXT', README % progs, 'what MASTER: does, and what it needs')
    m.text('MAKEFILE.TEXT', MASTER, 'MAKE -f MASTER:MAKEFILE: everything, new and original')
    o = m.sub('ORIG', 'the original programs: their makefiles, and CODE/ for what they make')
    o.text('MAKEFILE.TEXT', orig_makefile(), 'MAKE -f MASTER:/ORIG/MAKEFILE: each source disk mounted, its makefile run')
    for key, image, unit, p, what in ORIG:
        o.text(key + '.TEXT', disk_makefile(key, image, unit, p, what), '%s: %s' % (key, what))
    o.sub('CODE', 'empty: the code files the makefiles make', 1600)
    m.finish()
    src = ucsdvol.Volume.new('SOURCE', 800)
    open(os.path.join(ROOT, 'build', 'SOURCE.BLK'), 'wb').write(src.image())
    print('SOURCE: empty (the screen editor\'s sources are copied here: its $I names SOURCE:)')


if __name__ == '__main__':
    main()
