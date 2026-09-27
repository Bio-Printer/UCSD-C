/* link.c -- pass 3: object file -> II.0 code file.
 *
 * Reads the object file several times, sequentially (no seeks, so the
 * P-System version needs nothing but getc):
 *   1. procedure names, segments and sizes
 *   2. relocations, resolved to procedures -> the call graph
 * then keeps only procedures reachable from main (and the initialisers),
 * numbers segments (1, then 7..15) and procedures, and writes block 0
 * followed by every segment -- the sizes are all known beforehand.
 *
 * Segment 1 procedure 1 is the startup code generated here: zero the
 * globals, run the initialisers, call main, then exit(main's result).
 */
#include "tc.h"
#pragma segment LINK

#define MAXPROC 700
#define LHASH 128

struct LProc {
    char *name;
    int seg;                /* index into segnames */
    int flags;
    int parmsz;
    int rw;
    int codelen;
    int jtab;
    int nrel;
    int *rel;               /* target procedure indexes */
    int live;
    int procnum;
    struct LProc *hnext;
};

static struct LProc *procs[MAXPROC];
static int nprocs;
static struct LProc *lhash[LHASH];
static char *segnames[24];
static int nsegs;
static int segnum[24];          /* segment index -> II.0 segment number */
static int globalwords;
static FILE *lin;
static unsigned char *lbuf;

static int rd(void)
{
    int c;
    c = getc(lin);
    if (c == EOF)
        fatal("object file truncated", 0);
    return c;
}

static int rdw(void)
{
    int lo;
    lo = rd();
    return W16(lo + rd() * 256);
}

static void rds(char *s)
{
    int n;
    int i;
    n = rd();
    for (i = 0; i < n; i++)
        s[i] = rd();
    s[n] = 0;
}

static struct LProc *findproc(char *name)
{
    struct LProc *p;
    for (p = lhash[hashstr(name) & (LHASH - 1)]; p; p = p->hnext)
        if (strcmp(p->name, name) == 0)
            return p;
    return 0;
}

static int segindex(char *name)
{
    int i;
    for (i = 0; i < nsegs; i++)
        if (strcmp(segnames[i], name) == 0)
            return i;
    if (nsegs >= 24)
        fatal("too many segments", name);
    segnames[nsegs] = pstrdup(name);
    return nsegs++;
}

static void openobj(char *obj)
{
    char magic[5];
    int i;
    lin = fopen(obj, "rb");
    if (!lin)
        fatal("cannot open", obj);
    for (i = 0; i < 4; i++)
        magic[i] = rd();
    magic[4] = 0;
    if (strcmp(magic, "TCOB") != 0)
        fatal("not a Tiny-C object file", obj);
}

/* read one record; the procedure's code goes to lbuf. returns the record type */
static int record(char *name, char *seg, int *flags, int *parmsz, int *rw, int *codelen, int *jtab)
{
    int c;
    int i;
    int n;
    c = rd();
    if (c == 'M') {
        rds(name);
        return c;
    }
    if (c == 'G') {
        globalwords = rdw();
        return c;
    }
    if (c == 'E')
        return c;
    if (c != 'P')
        fatal("bad object file record", 0);
    *flags = rd();
    rds(name);
    rds(seg);
    *parmsz = rdw();
    *rw = rd();
    n = rdw();
    *codelen = n;
    *jtab = rdw();
    for (i = 0; i < n; i++)
        lbuf[i] = rd();
    return c;
}

static void pass1(char *obj)
{
    char name[MAXNAME];
    char seg[MAXNAME];
    char rname[MAXNAME];
    int flags;
    int parmsz;
    int rw;
    int codelen;
    int jtab;
    int c;
    int n;
    int i;
    int h;
    struct LProc *p;
    openobj(obj);
    for (;;) {
        c = record(name, seg, &flags, &parmsz, &rw, &codelen, &jtab);
        if (c == 'E')
            break;
        if (c != 'P')
            continue;
        n = rdw();
        for (i = 0; i < n; i++) {
            rdw();
            rd();
            rds(rname);
        }
        if (findproc(name))
            fatal("function defined twice", name);
        if (nprocs >= MAXPROC)
            fatal("too many functions", 0);
        p = (struct LProc *)palloc(sizeof(struct LProc));
        p->name = pstrdup(name);
        p->seg = segindex(seg);
        p->flags = flags;
        p->parmsz = parmsz;
        p->rw = rw;
        p->codelen = codelen;
        p->jtab = jtab;
        p->nrel = n;
        h = hashstr(name) & (LHASH - 1);
        p->hnext = lhash[h];
        lhash[h] = p;
        procs[nprocs++] = p;
    }
    fclose(lin);
}

static void pass2(char *obj)
{
    char name[MAXNAME];
    char seg[MAXNAME];
    char rname[MAXNAME];
    int flags;
    int parmsz;
    int rw;
    int codelen;
    int jtab;
    int c;
    int n;
    int i;
    int k;
    struct LProc *p;
    struct LProc *t;
    openobj(obj);
    k = 0;
    for (;;) {
        c = record(name, seg, &flags, &parmsz, &rw, &codelen, &jtab);
        if (c == 'E')
            break;
        if (c != 'P')
            continue;
        p = procs[k++];
        n = rdw();
        p->rel = (int *)palloc(n * sizeof(int) + 2);
        for (i = 0; i < n; i++) {
            rdw();
            rd();
            rds(rname);
            t = findproc(rname);
            if (!t) {
                error("undefined function", rname);
                p->rel[i] = -1;
            } else {
                for (c = 0; procs[c] != t; c++)
                    ;
                p->rel[i] = c;
            }
        }
    }
    fclose(lin);
}

static void mark(int root)
{
    int stack[MAXPROC];
    int sp;
    int i;
    int k;
    struct LProc *p;
    sp = 0;
    if (procs[root]->live)
        return;
    procs[root]->live = 1;
    stack[sp++] = root;
    while (sp > 0) {
        p = procs[stack[--sp]];
        for (i = 0; i < p->nrel; i++) {
            k = p->rel[i];
            if (k >= 0 && !procs[k]->live) {
                procs[k]->live = 1;
                stack[sp++] = k;
            }
        }
    }
}

static void put16(unsigned char *b, int pos, int v)
{
    b[pos] = v & 255;
    b[pos + 1] = (v >> 8) & 255;
}

/* the startup procedure (segment 1, procedure 1, lex level 0) */
static int entrylen;
static unsigned char entry[200];
static int entryjtab;

static void eb(int b)
{
    entry[entrylen++] = b;
}

static void ecall(struct LProc *p)
{
    if (segnum[p->seg] == 1) {
        eb(0xCF);               /* CGP */
        eb(p->procnum);
        eb(0xD7);
    } else {
        eb(0xCD);               /* CXP */
        eb(segnum[p->seg]);
        eb(p->procnum);
    }
}

static void makeentry(struct LProc *mainp, struct LProc *exitp)
{
    int i;
    int g;
    int exitpos;
    entrylen = 0;
    g = (globalwords - 3) * 2;
    if (g > 0) {                        /* FILLCHAR(globals, 0, bytes, 0) */
        eb(0xA5);
        eb(3);
        eb(0);
        eb(0xC7);
        eb(g & 255);
        eb((g >> 8) & 255);
        eb(0);
        eb(0x9E);
        eb(10);
    }
    for (i = 0; i < nprocs; i++)
        if (procs[i]->live && (procs[i]->flags & 1))
            ecall(procs[i]);
    for (i = 0; i < mainp->parmsz / 2; i++)
        eb(0);
    ecall(mainp);
    if (exitp) {
        if (mainp->rw == 0)
            eb(0);
        ecall(exitp);
    }
    exitpos = entrylen;
    eb(0xC1);                           /* RBP 0 */
    eb(0);
    if (entrylen & 1)
        eb(0);
    entryjtab = entrylen + 8;
    g = g < 0 ? 0 : g;
    eb(g & 255);
    eb((g >> 8) & 255);                 /* DATASZ */
    eb(4);
    eb(0);                              /* PARMSZ: INPUT, OUTPUT */
    put16(entry, entrylen, entryjtab - 4 - exitpos);
    entrylen += 2;
    put16(entry, entrylen, entryjtab - 2);
    entrylen += 2;
    eb(1);                              /* procedure 1 */
    eb(0);                              /* lex level 0 */
}

static void patchproc(struct LProc *p, int pos, int type, char *rname)
{
    struct LProc *t;
    t = findproc(rname);
    if (!t)
        return;
    if (type == 1) {
        if (t->seg == p->seg) {
            lbuf[pos] = 0xCF;
            lbuf[pos + 1] = t->procnum;
            lbuf[pos + 2] = 0xD7;
        } else {
            lbuf[pos] = 0xCD;
            lbuf[pos + 1] = segnum[t->seg];
            lbuf[pos + 2] = t->procnum;
        }
    } else if (type == 2) {
        lbuf[pos + 1] = segnum[t->seg];
        lbuf[pos + 2] = t->procnum;
    }
}

int link(char *obj, char *code, char *progname)
{
    struct LProc *mainp;
    struct LProc *exitp;
    struct LProc *p;
    FILE *out;
    int seglen[24];
    int segnp[24];
    int segblk[24];
    int order[24];
    int norder;
    int i;
    int j;
    int k;
    int s;
    int n;
    int blk;
    int pos;
    int len;
    int total;
    unsigned char *blk0;
    char name[MAXNAME];
    char seg[MAXNAME];
    char rname[MAXNAME];
    int flags;
    int parmsz;
    int rw;
    int codelen;
    int jtab;
    int c;
    int rpos;
    int rtype;
    int pnum[24];
    int *jt;
    lbuf = (unsigned char *)malloc(MAXCODE + 16);
    if (!lbuf)
        fatal("out of memory", 0);
    nprocs = 0;
    nsegs = 0;
    segindex("");
    pass1(obj);
    pass2(obj);
    if (nerrors)
        return 0;
    mainp = findproc("main");
    if (!mainp) {
        error("no main function", 0);
        return 0;
    }
    for (i = 0; procs[i] != mainp; i++)
        ;
    mark(i);
    for (i = 0; i < nprocs; i++)
        if (procs[i]->flags & 1)
            mark(i);
    exitp = findproc("exit");
    if (exitp) {
        for (i = 0; procs[i] != exitp; i++)
            ;
        mark(i);
    }
    /* segment numbers: main's segment is 1 */
    for (i = 0; i < 24; i++) {
        segnum[i] = 0;
        seglen[i] = 0;
        segnp[i] = 0;
        pnum[i] = 0;
    }
    norder = 0;
    order[norder++] = mainp->seg;
    segnum[mainp->seg] = 1;
    for (i = 0; i < nprocs; i++) {
        p = procs[i];
        if (!p->live || segnum[p->seg])
            continue;
        if (norder >= 10)
            fatal("more than 10 segments", segnames[p->seg]);
        segnum[p->seg] = norder + 6;
        order[norder++] = p->seg;
    }
    /* procedure numbers and segment lengths */
    pnum[mainp->seg] = 1;
    for (i = 0; i < nprocs; i++) {
        p = procs[i];
        if (!p->live)
            continue;
        s = p->seg;
        p->procnum = ++pnum[s];
        if (p->procnum > 255)
            fatal("more than 255 functions in segment", segnames[s]);
        seglen[s] = seglen[s] + ((p->codelen + 1) & ~1);
    }
    makeentry(mainp, exitp);
    seglen[mainp->seg] = seglen[mainp->seg] + entrylen;
    blk = 1;
    for (k = 0; k < norder; k++) {
        s = order[k];
        seglen[s] = seglen[s] + 2 * pnum[s] + 2;
        segblk[s] = blk;
        blk = blk + (seglen[s] + 511) / 512;
    }
    out = fopen(code, "wb");
    if (!out)
        fatal("cannot create", code);
    blk0 = (unsigned char *)malloc(512);
    memset(blk0, 0, 512);
    for (k = 0; k < norder; k++) {
        s = order[k];
        n = segnum[s];
        put16(blk0, 4 * n, segblk[s]);
        put16(blk0, 4 * n + 2, seglen[s]);
        for (j = 0; j < 8; j++)
            blk0[64 + 8 * n + j] = ' ';
        if (n == 1) {
            for (j = 0; j < 8 && progname[j]; j++)
                blk0[64 + 8 * n + j] = progname[j] >= 'a' && progname[j] <= 'z' ? progname[j] - 32 : progname[j];
        } else {
            for (j = 0; j < 8 && segnames[s][j]; j++)
                blk0[64 + 8 * n + j] = segnames[s][j];
        }
    }
    for (i = 0; i < 16; i++)
        if (!blk0[64 + 8 * i])
            for (j = 0; j < 8; j++)
                blk0[64 + 8 * i + j] = 0;
    fwrite(blk0, 1, 512, out);
    total = 512;
    jt = (int *)malloc(256 * sizeof(int));
    for (k = 0; k < norder; k++) {
        s = order[k];
        len = 0;
        if (segnum[s] == 1) {
            fwrite(entry, 1, entrylen, out);
            jt[1] = entryjtab;
            len = entrylen;
        }
        openobj(obj);
        i = 0;
        for (;;) {
            c = record(name, seg, &flags, &parmsz, &rw, &codelen, &jtab);
            if (c == 'E')
                break;
            if (c != 'P')
                continue;
            p = procs[i++];
            n = rdw();
            for (j = 0; j < n; j++) {
                rpos = rdw();
                rtype = rd();
                rds(rname);
                if (p->live && p->seg == s)
                    patchproc(p, rpos, rtype, rname);
            }
            if (!p->live || p->seg != s)
                continue;
            lbuf[jtab] = p->procnum;
            if (codelen & 1)
                lbuf[codelen++] = 0;
            fwrite(lbuf, 1, codelen, out);
            jt[p->procnum] = len + jtab;
            len = len + codelen;
        }
        fclose(lin);
        /* procedure dictionary: self-relative pointers, highest number first */
        for (j = pnum[s]; j >= 1; j--) {
            pos = len;
            putc((pos - jt[j]) & 255, out);
            putc(((pos - jt[j]) >> 8) & 255, out);
            len = len + 2;
        }
        putc(segnum[s], out);
        putc(pnum[s], out);
        len = len + 2;
        if (len != seglen[s])
            fatal("internal: segment length", segnames[s]);
        while (len & 511) {
            putc(0, out);
            len++;
        }
    }
    fclose(out);
    for (k = 0; k < norder; k++) {
        s = order[k];
        printf("  segment %2d %-8s %5d bytes %3d procedures\n", segnum[s], segnum[s] == 1 ? progname : segnames[s], seglen[s], pnum[s]);
    }
    return nerrors == 0;
}
