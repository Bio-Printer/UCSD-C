#!/usr/bin/env python3
"""mkpasm.py -- build/U016.1_PCODE_ASSEM.BLK, the system disk U016.1: PASM, the P-code
assembler (pasm/: written in PASM itself), assembled by the host's tools/pasm.py; its
sources, its language (PASMDOC.TEXT), the examples, and a makefile with which PASM rebuilds
itself on the P-System (MAKE -f U016.1:MAKEFILE)."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import ucsdvol
from mkvolume import Dir
import pasm

VOLUME, IMAGE, BLOCKS = 'U016.1', 'U016.1_PCODE_ASSEM', 400
PASMDIR = os.path.join(ROOT, 'pasm')
SOURCES = [('PASM', 'the assembler: its tables, MAIN'),
           ('PASMIO', 'the console, the files, the shell\'s command line'),
           ('PASMLEX', 'lines, tokens, names, expressions'),
           ('PASMGEN', 'instructions, directives, procedures, segments, the code file')]
EXAMPLES = [('HELLO', 'the least program'),
            ('PTEST', 'procedures, functions, globals, LDC, XJP, a second segment')]

MAKEFILE = """# MAKEFILE -- PASM rebuilt by itself, and the examples: MAKE -f U016.1:MAKEFILE
# (MAKE is on TOOLS:).  PASM's .INCLUDE files are on the prefix volume: CD U016.1:.
V = U016.1:

all : $(V)PASM.CODE $(V)HELLO.CODE $(V)PTEST.CODE

$(V)PASM.CODE : $(V)PASM.TEXT $(V)PASMIO.TEXT $(V)PASMLEX.TEXT $(V)PASMGEN.TEXT
\tCD $(V)
\t$(V)PASM PASM
$(V)HELLO.CODE : $(V)HELLO.TEXT $(V)PASM.CODE
\tCD $(V)
\t$(V)PASM HELLO
$(V)PTEST.CODE : $(V)PTEST.TEXT $(V)PASM.CODE
\tCD $(V)
\t$(V)PASM PTEST

.PHONY : all
"""


def assemble(src, incdir=PASMDIR):
    """the code file the host's assembler makes of src"""
    a = pasm.Asm(src, incdir)
    data = a.assemble()
    if data is None:
        raise SystemExit('\n'.join(a.errors))
    return data


def main():
    d = Dir(VOLUME, BLOCKS)
    d.textfile('PASMDOC.TEXT', os.path.join(PASMDIR, 'PASMDOC.TEXT'), 'PASM\'s language: start here')
    d.binary('PASM.CODE', assemble(os.path.join(PASMDIR, 'pasm.pasm')), 'PASM, the P-code assembler')
    for n, what in SOURCES:
        d.textfile(n + '.TEXT', os.path.join(PASMDIR, n.lower() + '.pasm'), 'PASM\'s source: ' + what)
    for n, what in EXAMPLES:
        src = os.path.join(PASMDIR, 'test', n.lower() + '.pasm')
        d.textfile(n + '.TEXT', src, 'an example: ' + what)
        d.binary(n + '.CODE', assemble(src), n + '.TEXT assembled')
    d.text('MAKEFILE.TEXT', MAKEFILE, 'MAKE -f U016.1:MAKEFILE: PASM rebuilt by itself, the examples')
    d.finish(IMAGE)


if __name__ == '__main__':
    main()
