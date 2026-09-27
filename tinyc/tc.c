/* tc.c -- the whole compiler as one translation unit (Tiny-C compiles a
   single file; the host build uses this too). */
#include "util.c"
#include "pp.c"
#include "lex.c"
#include "parse.c"
#include "gen.c"
#include "link.c"
#include "main.c"
