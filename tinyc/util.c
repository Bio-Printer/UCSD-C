/* util.c -- errors and memory pools.
 *
 * Three pools, all bump allocators:
 *   perm  -- lives for the whole pass (types, globals, macros)
 *   func  -- reset at the end of every function definition
 *   expr  -- mark/release around every statement and every source line
 */
#include "tc.h"
#pragma segment MAIN

int nerrors;
char *curfile;
int curline;

void error(char *msg, char *arg)
{
    if (curfile)
        printf("%s:%d: ", curfile, curline);
    printf("error: %s", msg);
    if (arg)
        printf(" '%s'", arg);
    printf("\n");
    nerrors++;
    if (nerrors >= 20)
        fatal("too many errors", 0);
}

void warn(char *msg, char *arg)
{
    if (curfile)
        printf("%s:%d: ", curfile, curline);
    printf("warning: %s", msg);
    if (arg)
        printf(" '%s'", arg);
    printf("\n");
}

void memfail(int n)
{
#ifdef __TINYC__
    printf("(asked for %d bytes, %d words free)\n", n, __cspi(40));
#endif
    fatal("out of memory", 0);
}

void fatal(char *msg, char *arg)
{
    if (curfile)
        printf("%s:%d: ", curfile, curline);
    printf("fatal: %s", msg);
    if (arg)
        printf(" '%s'", arg);
    printf("\n");
    exit(2);
}

#define PCHUNK 2048
static char *pcur;
static int pleft;

char *palloc(int n)
{
    char *p;
    n = (n + 1) & ~1;
    if (n > pleft) {
        if (n > PCHUNK / 2) {
            p = (char *)malloc(n);
            if (!p)
                memfail(n);
            memset(p, 0, n);
            return p;
        }
        pcur = (char *)malloc(PCHUNK);
        if (!pcur)
            memfail(PCHUNK);
        pleft = PCHUNK;
    }
    p = pcur;
    pcur += n;
    pleft -= n;
    memset(p, 0, n);
    return p;
}

/* the function pool: a chain of chunks reused for every function */
struct Chunk {
    struct Chunk *next;
    int size;
};
static struct Chunk *ffirst;
static struct Chunk *fchunk;
static int fused;

char *falloc(int n)
{
    char *p;
    struct Chunk *c;
    n = (n + 1) & ~1;
    if (!fchunk || fused + n > fchunk->size) {
        c = fchunk ? fchunk->next : ffirst;
        if (!c || c->size < n) {
            int sz;
            sz = n > PCHUNK ? n : PCHUNK;
            c = (struct Chunk *)malloc(sizeof(struct Chunk) + sz);
            if (!c)
                memfail(sz);
            c->size = sz;
            if (fchunk) {
                c->next = fchunk->next;
                fchunk->next = c;
            } else {
                c->next = ffirst;
                ffirst = c;
            }
        }
        fchunk = c;
        fused = 0;
    }
    p = (char *)(fchunk + 1) + fused;
    fused += n;
    memset(p, 0, n);
    return p;
}

void freset(void)
{
    fchunk = 0;
    fused = 0;
}

#define XSIZE 8000
static char *xbuf;
static int xused;

char *xalloc(int n)
{
    char *p;
    if (!xbuf) {
        xbuf = (char *)malloc(XSIZE);
        if (!xbuf)
            memfail(XSIZE);
    }
    n = (n + 1) & ~1;
    if (xused + n > XSIZE)
        fatal("expression too complex", 0);
    p = xbuf + xused;
    xused += n;
    memset(p, 0, n);
    return p;
}

int xmark(void)
{
    return xused;
}

void xrelease(int m)
{
    xused = m;
}

char *pstrdup(char *s)
{
    char *p;
    p = palloc(strlen(s) + 1);
    strcpy(p, s);
    return p;
}

int hashstr(char *s)
{
    int h;
    h = 0;
    while (*s)
        h = (h * 5 + *s++) & 2047;
    return h;
}
