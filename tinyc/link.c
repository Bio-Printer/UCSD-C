/* link.c -- the linker: object modules -> II.0 code file.
 *
 * Input: one or more object files, each holding one or more modules (a
 * library is simply modules one after another).  A module has procedures
 * (code + relocations), exported variables ('D': name, size, initialised
 * or common) and a block of static variables.
 *
 * The files are read sequentially several times (no seeks):
 *   1. names: procedures, variables, modules, segments
 *   2. relocations resolved to procedures/variables -> reference graph
 * Everything reachable from main (and exit) is kept: a module is linked
 * when any of its procedures or variables is used, and then its
 * initialisers run too.  Globals are laid out from word 3 of the startup
 * frame: each linked module's statics, then every used variable.
 * Segments are numbered (main's is 1, the others 7..15), procedures
 * within them, and block 0 plus the segments are written in one go.
 *
 * Segment 1 procedure 1 is the startup code generated here: zero the
 * globals, run the initialisers, call main, then exit(main's result).
 */
#include "tc.h"
#pragma segment LINK

#define MAXPROC 700
#define MAXDATA 400
#define MAXMOD  64
#define LHASH 128

struct LProc {
    char *name;
    int mod;
    int seg;                /* index into segnames */
    int flags;              /* 1 = initialiser */
    int parmsz;
    int rw;
    int codelen;
    int jtab;
    int nrel;
    int *rel;               /* >= 0 procedure, <= -2 variable -2-k, -1 none */
    int live;
    int procnum;
    struct LProc *hnext;
};

struct LData {
    char *name;
    int words;
    int strong;
    int mod;                /* defining module, -1 = none yet */
    int offset;
    int live;
    struct LData *hnext;
};

static struct LProc **procs;
static int nprocs;
static struct LData **datas;
static int ndatas;
static struct LProc *lhash[LHASH];
static struct LData *dhash[LHASH];
static int modstatic[MAXMOD];
static int modbase[MAXMOD];
static int modlive[MAXMOD];
static int nmods;
static char *segnames[24];
static int nsegs;
static int segnum[24];          /* segment index -> II.0 segment number */
static int globalwords;
static FILE *lin;
static unsigned char *lbuf;
static char **objfiles;
static int nobjfiles;
static int curfilei;
static int curmod;

static int rd(void)
{
    int c;
    c = getc(lin);
    if (c == EOF)
        fatal(103 /* object file truncated */, 0);
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

static int procindex(struct LProc *p)
{
    int i;
    for (i = 0; procs[i] != p; i++)
        ;
    return i;
}

static struct LData *finddata(char *name)
{
    struct LData *d;
    for (d = dhash[hashstr(name) & (LHASH - 1)]; d; d = d->hnext)
        if (strcmp(d->name, name) == 0)
            return d;
    return 0;
}

static int dataindex(struct LData *d)
{
    int i;
    for (i = 0; datas[i] != d; i++)
        ;
    return i;
}

static int segindex(char *name)
{
    int i;
    for (i = 0; i < nsegs; i++)
        if (strcmp(segnames[i], name) == 0)
            return i;
    if (nsegs >= 24)
        fatal(104 /* too many segments */, name);
    segnames[nsegs] = pstrdup(name);
    return nsegs++;
}

/* start reading the object files from the beginning */
static void rewindobjs(void)
{
    curfilei = -1;
    curmod = -1;
    lin = 0;
}

/* the next record over all files and modules: 0 at the very end */
static int nextrec(void)
{
    char magic[5];
    int c;
    int i;
    for (;;) {
        if (lin) {
            c = getc(lin);
            if (c == 'T') {             /* the next module in the same file */
                for (i = 1; i < 4; i++)
                    rd();
                continue;
            }
            if (c != EOF && c != 0)
                return c;
            fclose(lin);                /* end (binary files end in NULs) */
            lin = 0;
        }
        curfilei++;
        if (curfilei >= nobjfiles)
            return 0;
        lin = fopen(objfiles[curfilei], "rb");
        if (!lin)
            fatal(25 /* cannot open */, objfiles[curfilei]);
        for (i = 0; i < 4; i++)
            magic[i] = rd();
        magic[4] = 0;
        if (strcmp(magic, "TCOB") != 0)
            fatal(105 /* not a Tiny-C object file */, objfiles[curfilei]);
    }
}

/* read the rest of a record; a procedure's code goes to lbuf */
static void record(int c, char *name, char *seg, int *flags, int *parmsz, int *rw, int *codelen, int *jtab)
{
    int i;
    int n;
    if (c == 'M') {
        rds(name);
        curmod++;
        return;
    }
    if (c == 'G') {
        *codelen = rdw();
        return;
    }
    if (c == 'E')
        return;
    if (c == 'D') {
        *flags = rd();
        rds(name);
        *codelen = rdw();
        return;
    }
    if (c != 'P')
        fatal(106 /* bad object file record */, 0);
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
}

static void pass1(void)
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
    struct LData *d;
    rewindobjs();
    while ((c = nextrec()) != 0) {
        record(c, name, seg, &flags, &parmsz, &rw, &codelen, &jtab);
        if (c == 'M') {
            if (curmod >= MAXMOD)
                fatal(108 /* too many functions */, 0);
            modstatic[curmod] = 0;
            modlive[curmod] = 0;
            nmods = curmod + 1;
            continue;
        }
        if (c == 'G') {
            modstatic[curmod] = codelen;
            continue;
        }
        if (c == 'D') {
            d = finddata(name);
            if (!d) {
                if (ndatas >= MAXDATA)
                    fatal(108 /* too many functions */, 0);
                d = (struct LData *)palloc(sizeof(struct LData));
                d->name = pstrdup(name);
                d->mod = -1;
                h = hashstr(name) & (LHASH - 1);
                d->hnext = dhash[h];
                dhash[h] = d;
                datas[ndatas++] = d;
            }
            if (flags && d->strong)
                error(115 /* variable defined twice */, name);
            if (flags || d->mod < 0) {
                if (flags)
                    d->strong = 1;
                d->mod = curmod;
            }
            if (codelen > d->words)
                d->words = codelen;
            continue;
        }
        if (c != 'P')
            continue;
        n = rdw();
        for (i = 0; i < n; i++) {
            rdw();
            rd();
            rds(rname);
        }
        if (findproc(name))
            error(107 /* function defined twice */, name);
        if (nprocs >= MAXPROC)
            fatal(108 /* too many functions */, 0);
        p = (struct LProc *)palloc(sizeof(struct LProc));
        p->name = pstrdup(name);
        p->mod = curmod;
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
}

static void pass2(void)
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
    int type;
    struct LProc *p;
    struct LProc *t;
    struct LData *d;
    rewindobjs();
    k = 0;
    while ((c = nextrec()) != 0) {
        record(c, name, seg, &flags, &parmsz, &rw, &codelen, &jtab);
        if (c != 'P')
            continue;
        p = procs[k++];
        n = rdw();
        p->rel = (int *)palloc(n * sizeof(int) + 2);
        for (i = 0; i < n; i++) {
            rdw();
            type = rd();
            rds(rname);
            p->rel[i] = -1;
            if (type == 1 || type == 2) {
                t = findproc(rname);
                if (!t)
                    error(109 /* undefined function */, rname);
                else
                    p->rel[i] = procindex(t);
            } else if (type == 4) {
                d = finddata(rname);
                if (!d || d->mod < 0)
                    error(114 /* undefined variable */, rname);
                else
                    p->rel[i] = -2 - dataindex(d);
            }
        }
    }
}

/* mark everything reachable; linked modules bring their initialisers */
static void markall(void)
{
    int changed;
    int i;
    int j;
    int k;
    struct LProc *p;
    struct LData *d;
    do {
        changed = 0;
        for (i = 0; i < nprocs; i++) {
            p = procs[i];
            if (!p->live && (p->flags & 1) && modlive[p->mod]) {
                p->live = 1;
                changed = 1;
            }
            if (!p->live)
                continue;
            if (!modlive[p->mod]) {
                modlive[p->mod] = 1;
                changed = 1;
            }
            for (j = 0; j < p->nrel; j++) {
                k = p->rel[j];
                if (k >= 0 && !procs[k]->live) {
                    procs[k]->live = 1;
                    changed = 1;
                } else if (k <= -2 && !datas[-2 - k]->live) {
                    d = datas[-2 - k];
                    d->live = 1;
                    modlive[d->mod] = 1;
                    changed = 1;
                }
            }
        }
    } while (changed);
}

static void put16(unsigned char *b, int pos, int v)
{
    b[pos] = v & 255;
    b[pos + 1] = (v >> 8) & 255;
}

/* the startup procedure (segment 1, procedure 1, lex level 0) */
static int entrylen;
static unsigned char *entry;
static int entryjtab;

static void eb(int b)
{
    if (entrylen >= 600)
        fatal(108 /* too many functions */, 0);
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
    struct LData *d;
    int v;
    if (type == 3 || type == 4) {
        v = ((lbuf[pos] & 127) << 8) + lbuf[pos + 1];
        if (type == 3)
            v = v + modbase[p->mod];
        else {
            d = finddata(rname);
            if (!d)
                return;
            v = v + d->offset;
        }
        lbuf[pos] = 128 | ((v >> 8) & 127);
        lbuf[pos + 1] = v & 255;
        return;
    }
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

int link(char **objs, int nobjs, char *code, char *progname)
{
    struct LProc *mainp;
    struct LProc *exitp;
    struct LProc *p;
    FILE *out;
    int seglen[24];
    int segblk[24];
    int order[24];
    int pnum[24];
    int norder;
    int i;
    int j;
    int k;
    int s;
    int n;
    int blk;
    int pos;
    int len;
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
    int *jt;
    objfiles = objs;
    nobjfiles = nobjs;
    procs = (struct LProc **)malloc(MAXPROC * sizeof(struct LProc *));
    datas = (struct LData **)malloc(MAXDATA * sizeof(struct LData *));
    lbuf = (unsigned char *)malloc(MAXCODE + 16);
    entry = (unsigned char *)malloc(600);
    if (!lbuf || !procs || !datas || !entry)
        fatal(2 /* out of memory */, 0);
    memset(lhash, 0, sizeof(lhash));
    memset(dhash, 0, sizeof(dhash));
    nprocs = 0;
    ndatas = 0;
    nmods = 0;
    nsegs = 0;
    segindex("");
    pass1();
    pass2();
    if (nerrors)
        return 0;
    mainp = findproc("main");
    if (!mainp) {
        error(110 /* no main function */, 0);
        return 0;
    }
    mainp->live = 1;
    exitp = findproc("exit");
    if (exitp)
        exitp->live = 1;
    markall();
    /* globals: the linked modules' statics, then the used variables */
    globalwords = 3;
    for (i = 0; i < nmods; i++) {
        modbase[i] = globalwords;
        if (modlive[i])
            globalwords = globalwords + modstatic[i];
    }
    for (i = 0; i < ndatas; i++)
        if (datas[i]->live) {
            datas[i]->offset = globalwords;
            globalwords = globalwords + datas[i]->words;
        }
    if (globalwords > 16000 || globalwords < 0)
        fatal(34 /* too many global variables */, 0);
    /* segment numbers: main's segment is 1 */
    for (i = 0; i < 24; i++) {
        segnum[i] = 0;
        seglen[i] = 0;
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
            fatal(111 /* more than 10 segments */, segnames[p->seg]);
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
            fatal(112 /* more than 255 functions in segment */, segnames[s]);
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
        fatal(24 /* cannot create */, code);
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
    fwrite(blk0, 1, 512, out);
    jt = (int *)malloc(256 * sizeof(int));
    for (k = 0; k < norder; k++) {
        s = order[k];
        len = 0;
        if (segnum[s] == 1) {
            fwrite(entry, 1, entrylen, out);
            jt[1] = entryjtab;
            len = entrylen;
        }
        rewindobjs();
        i = 0;
        while ((c = nextrec()) != 0) {
            record(c, name, seg, &flags, &parmsz, &rw, &codelen, &jtab);
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
            fatal(113 /* internal: segment length */, segnames[s]);
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
    printf("  globals %d words\n", globalwords - 3);
    return nerrors == 0;
}
