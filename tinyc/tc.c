/* tc.c -- the whole compiler as one translation unit (Tiny-C compiles a
   single file; the host build uses this too). */
#include "util.c"
#include "types.c"
#include "pp.c"
#include "lex.c"
#include "parse.c"
#include "ir.c"
#include "gen.c"
#include "link.c"
#include "main.c"
