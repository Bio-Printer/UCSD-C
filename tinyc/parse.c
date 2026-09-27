/* parse.c -- pass 2 front end: declarations, types, expressions, statements.
 *
 * Expressions are parsed into typed trees (allocated per statement) and
 * handed to gen.c; statements are compiled as they are parsed.  Operations
 * the P-machine has no instruction for (32-bit long arithmetic, C-style
 * signed division, shifts, xor) become calls to helpers in tcrt.h.
 */
#include "tc.h"
#pragma segment PARSE

struct Type *ty_void;
struct Type *ty_char;
struct Type *ty_uchar;
struct Type *ty_int;
struct Type *ty_uint;
struct Type *ty_long;
struct Type *ty_ulong;
struct Type *ty_float;
struct Type *ty_double;
struct Type *ty_ldouble;
static struct Type *ty_charp;

#define HSIZE 128
static struct Sym *htab[HSIZE];
static struct Sym *ttab[HSIZE];
static struct Sym *scopes[40];
static int level;
static struct Sym *labels;
int globoff;                    /* next free word of the module's static variables */
static char *modname;
static int usesfloat;          /* the module uses floating point (links printf's %f) */
static int nofltused;

/* current function */
static struct Sym *curfn;
static struct Type *curft;
static int exitlab;
static int sretoff;
static int vaoff;

/* current switch */
static int *swvals;
static int *swlabs;
static int swn;
static int swmax;
static int swdef;

static struct Node *expr(void);
static struct Node *assign(void);
static struct Node *condexpr(void);
static struct Node *castexpr(void);
static void statement(int brk, int cont);
static struct Type *declspec(int *sclass);
static struct Type *typename(void);
static void initializer(struct Node *lv, struct Type *t, int global);
static void init1(struct Node *lv, struct Type *t, int global);

/* ---- intrinsic functions ---- */
#define I_DVI     1
#define I_MDI     2
#define I_VASTART 3
#define I_CSPV    4
#define I_CSPI    5
#define I_CSPF    6
#define I_CXP0V   7
#define I_CXP0I   8
#define I_OSVAR   9
#define I_EXITP   10
#define I_OSVARA  11

static char *intrnames[] = {
    "", "__dvi", "__mdi", "__va_start", "__cspv", "__cspi", "__cspf",
    "__cxp0v", "__cxp0i", "__osvar", "__exitprog", "__osvaraddr", 0
};

/* ---- types ---- */

/* while a declarator from a system header is parsed, derived types go to
   the statement pool: most such declarations are dropped (see isref) */
static int tentative;

static struct Type *mktype(int kind, int size, int align)
{
    struct Type *t;
    if (tentative && (kind == TY_PTR || kind == TY_ARRAY || kind == TY_FUNC)) {
        t = (struct Type *)xalloc(sizeof(struct Type));
        t->align = -1;              /* marks a temporary type */
        t->kind = kind;
        t->size = size;
        t->len = -1;
        return t;
    }
    t = (struct Type *)palloc(sizeof(struct Type));
    t->kind = kind;
    t->size = size;
    t->align = align;
    t->len = -1;
    return t;
}

/* set-up code runs once per compile: a segment of its own */
#pragma segment CINIT

void typeinit(void)
{
    ty_void = mktype(TY_VOID, 1, 1);
    ty_char = mktype(TY_CHAR, 1, 1);
    ty_uchar = mktype(TY_UCHAR, 1, 1);
    ty_int = mktype(TY_INT, 2, 2);
    ty_uint = mktype(TY_UINT, 2, 2);
    ty_long = mktype(TY_LONG, 4, 2);
    ty_ulong = mktype(TY_ULONG, 4, 2);
    ty_float = mktype(TY_FLOAT, 4, 2);
    ty_double = mktype(TY_DOUBLE, 4, 2);
    ty_ldouble = mktype(TY_LDOUBLE, 4, 2);
    ty_charp = ptrto(ty_char);
    globoff = 0;
}

#pragma segment PARSE

struct Type *ptrto(struct Type *t)
{
    struct Type *p;
    if (t->ptrto)
        return t->ptrto;
    if (tentative) {
        p = mktype(TY_PTR, 2, 2);   /* temporary: not cached */
        p->base = t;
        return p;
    }
    p = mktype(TY_PTR, 2, 2);
    p->base = t;
    t->ptrto = p;
    return p;
}

static struct Type *arrayof(struct Type *t, int n)
{
    struct Type *a;
    a = mktype(TY_ARRAY, n < 0 ? -1 : W16(n * t->size), t->align);
    a->base = t;
    a->len = n;
    return a;
}

/* a permanent copy of a type built tentatively */
static struct Type *permtype(struct Type *t)
{
    struct Type *n;
    struct Param *p;
    struct Param *q;
    struct Param *last;
    if (t->align != -1)
        return t;
    if (t->kind == TY_PTR)
        return ptrto(permtype(t->base));
    if (t->kind == TY_ARRAY)
        return arrayof(permtype(t->base), t->len);
    n = mktype(TY_FUNC, 2, 2);
    n->base = permtype(t->base);
    n->variadic = t->variadic;
    n->oldstyle = t->oldstyle;
    last = 0;
    for (p = t->params; p; p = p->next) {
        q = (struct Param *)palloc(sizeof(struct Param));
        q->type = permtype(p->type);
        q->name = p->name;          /* used only by an immediately following body */
        if (last)
            last->next = q;
        else
            n->params = q;
        last = q;
    }
    return n;
}

/* ---- the names the program itself uses (see scanrefs) ----
   A Bloom filter: 4096 bits, two hash functions.  A false positive only
   keeps a declaration that was not needed. */
#define RBITS 4096
static unsigned char *refbits;

static int refhash2(char *s)
{
    int h;
    h = 7;
    while (*s)
        h = (h * 31 + *s++) & 4095;
    return h;
}

static int isref(char *name)
{
    int a;
    int b;
    a = (hashstr(name) * 2 + 1) & 4095;
    b = refhash2(name);
    return (refbits[a >> 3] & (1 << (a & 7))) && (refbits[b >> 3] & (1 << (b & 7)));
}

static int sametype(struct Type *a, struct Type *b)
{
    if (a == b)
        return 1;
    if (a->kind != b->kind)
        return 0;
    if (a->kind == TY_PTR || a->kind == TY_ARRAY)
        return sametype(a->base, b->base);
    return a->kind != TY_STRUCT && a->kind != TY_UNION && a->kind != TY_FUNC;
}

/* ---- symbols ---- */

static struct Sym *lookup(char *name)
{
    struct Sym *s;
    for (s = htab[hashstr(name) & (HSIZE - 1)]; s; s = s->next)
        if (strcmp(s->name, name) == 0)
            return s;
    return 0;
}

static struct Sym *lookuptag(char *name)
{
    struct Sym *s;
    for (s = ttab[hashstr(name) & (HSIZE - 1)]; s; s = s->next)
        if (strcmp(s->name, name) == 0)
            return s;
    return 0;
}

static struct Sym *addsym(char *name, int kind, struct Type *t)
{
    struct Sym *s;
    int h;
    if (level == 0) {
        s = (struct Sym *)palloc(sizeof(struct Sym));
        s->name = pstrdup(name);
    } else {
        s = (struct Sym *)falloc(sizeof(struct Sym));
        s->name = falloc(strlen(name) + 1);
        strcpy(s->name, name);
    }
    s->kind = kind;
    s->type = t;
    s->level = level;
    h = hashstr(name) & (HSIZE - 1);
    if (kind == S_TAG) {
        s->next = ttab[h];
        ttab[h] = s;
    } else {
        s->next = htab[h];
        htab[h] = s;
    }
    s->scopenext = scopes[level];
    scopes[level] = s;
    return s;
}

static void pushscope(void)
{
    level++;
    if (level >= 40)
        fatal(33 /* blocks nested too deeply */, 0);
    scopes[level] = 0;
}

static void popscope(void)
{
    struct Sym *s;
    int h;
    for (s = scopes[level]; s; s = s->scopenext) {
        h = hashstr(s->name) & (HSIZE - 1);
        if (s->kind == S_TAG)
            ttab[h] = s->next;
        else
            htab[h] = s->next;
    }
    level--;
}

static int allocglobal(struct Type *t)
{
    int off;
    int w;
    off = globoff;
    w = (t->size + 1) / 2;
    if (w <= 0)
        w = 1;
    globoff = globoff + w;
    if (globoff > 16000 || globoff < 0)
        fatal(34 /* too many global variables */, 0);
    return off;
}

static int alloclocal(struct Type *t)
{
    int w;
    w = (t->size + 1) / 2;
    if (w <= 0)
        w = 1;
    curlocal = curlocal + w;
    if (curlocal > maxlocal)
        maxlocal = curlocal;
    if (curlocal > 12000)
        fatal(35 /* local variables too large */, 0);
    return curlocal - w + 1;
}

/* ---- tokens ---- */

static void expect(int t, char *what)
{
    if (tok != t) {
        error(36 /* expected */, what);
        return;
    }
    next();
}

static int istypename(void)
{
    struct Sym *s;
    if (tok >= K_FIRST && tok <= K_LAST) {
        switch (tok) {
        case K_CHAR: case K_CONST: case K_DOUBLE: case K_ENUM: case K_EXTERN:
        case K_FLOAT: case K_INT: case K_LONG: case K_REGISTER: case K_SHORT:
        case K_SIGNED: case K_STATIC: case K_STRUCT: case K_TYPEDEF: case K_UNION:
        case K_UNSIGNED: case K_VOID: case K_VOLATILE: case K_AUTO:
            return 1;
        }
        return 0;
    }
    if (tok == T_ID) {
        s = lookup(tokname);
        return s && s->kind == S_TYPEDEF;
    }
    return 0;
}

/* ---- nodes ---- */

static struct Node *mknode(int op, struct Type *t, struct Node *a, struct Node *b)
{
    struct Node *n;
    n = (struct Node *)xalloc(sizeof(struct Node));
    n->op = op;
    n->type = t;
    n->a = a;
    n->b = b;
    return n;
}

static struct Node *mknum(int v, struct Type *t)
{
    struct Node *n;
    n = mknode(N_NUM, t, 0, 0);
    n->val = W16(v);
    if (islongty(t))
        n->val2 = (n->val < 0 && t->kind == TY_LONG) ? -1 : 0;
    return n;
}

static int isconst(struct Node *n)
{
    return n->op == N_NUM && !islongty(n->type);
}

static int islvalue(struct Node *n)
{
    return n->op == N_VAR || n->op == N_MEMBER || n->op == N_DEREF;
}

/* in global initialisers a string literal would point into the INIT
   segment, which is gone once the program runs: copy it to a global */
static int globinit;
static int allocglobal(struct Type *t);

/* array -> pointer to first element, function -> function pointer */
static struct Node *decay(struct Node *n)
{
    if (n->op == N_STR && globinit) {
        n->op = N_HEAPSTR;          /* copied to the heap at startup */
        n->type = ptrto(ty_char);
        return n;
    }
    if (n->type->kind == TY_ARRAY)
        return mknode(N_ADDR, ptrto(n->type->base), n, 0);
    if (n->type->kind == TY_FUNC)
        return mknode(N_ADDR, ptrto(n->type), n, 0);
    return n;
}

static struct Sym *helper(char *name)
{
    struct Sym *s;
    s = lookup(name);
    if (!s || s->kind != S_FUNC)
        fatal(37 /* runtime helper not declared (tcrt.h) */, name);
    return s;
}

static struct Node *call1(char *name, struct Node *a, struct Node *b)
{
    struct Sym *s;
    struct Node *n;
    struct Node *f;
    struct Param *p;
    s = helper(name);
    f = mknode(N_FUNC, s->type, 0, 0);
    f->sym = s;
    n = mknode(N_CALL, s->type->base, f, 0);
    p = s->type->params;
    n->b = a;
    if (b)
        a->next = b;
    return n;
}

struct Node *cast(struct Node *n, struct Type *t);

static struct Node *helpercall(char *name, struct Node *a, struct Node *b)
{
    struct Sym *s;
    struct Param *p;
    s = helper(name);
    p = s->type->params;
    a = cast(a, p->type);
    if (b)
        b = cast(b, p->next->type);
    return call1(name, a, b);
}

/* conversions between scalar types */
struct Node *cast(struct Node *n, struct Type *t)
{
    struct Type *f;
    int fk;
    int tk;
    n = decay(n);
    f = n->type;
    fk = f->kind;
    tk = t->kind;
    if (tk == TY_VOID) {
        n = mknode(N_CAST, t, n, 0);
        return n;
    }
    if (f == t || (fk == tk && fk != TY_STRUCT && fk != TY_UNION && fk != TY_ARRAY))
        return fk == tk && f != t ? mknode(N_CAST, t, n, 0) : n;
    if (tk == TY_STRUCT || tk == TY_UNION || tk == TY_ARRAY || tk == TY_FUNC) {
        if (fk != tk)
            error(38 /* invalid conversion */, 0);
        return n;
    }
    if (!isscalar(f)) {
        error(38 /* invalid conversion */, 0);
        return n;
    }
    /* long <-> others go through helpers */
    if (islongty(t) && !islongty(f)) {
        if (isfloatty(f))
            return call1(tk == TY_LONG ? "__ftol" : "__ftoul", n, 0);
        if (n->op == N_NUM) {
            struct Node *c;
            c = mknum(n->val, t);
            if (isunsignedty(f) || f->kind == TY_PTR)
                c->val2 = 0;
            else
                c->val2 = n->val < 0 ? -1 : 0;
            return c;
        }
        if (isunsignedty(f) || fk == TY_PTR)
            return mknode(N_CAST, t, call1("__utol", mknode(N_CAST, ty_uint, n, 0), 0), 0);
        return mknode(N_CAST, t, call1("__itol", mknode(N_CAST, ty_int, n, 0), 0), 0);
    }
    if (islongty(f) && !islongty(t)) {
        if (isfloatty(t))
            return mknode(N_CAST, t, call1(fk == TY_LONG ? "__ltof" : "__ultof", n, 0), 0);
        if (n->op == N_NUM)
            return cast(mknum(n->val, isunsignedty(f) ? ty_uint : ty_int), t);
        return cast(call1("__ltoi", n, 0), t);
    }
    if (islongty(f) && islongty(t))
        return mknode(N_CAST, t, n, 0);
    /* word and float */
    if (n->op == N_NUM && !isfloatty(t) && !isfloatty(f)) {
        int v;
        v = n->val;
        if (tk == TY_CHAR) {
            v = v & 255;
            if (v > 127)
                v = v - 256;
        } else if (tk == TY_UCHAR)
            v = v & 255;
        return mknum(v, t);
    }
    if (isfloatty(t) && isunsignedty(f))
        return mknode(N_CAST, t, call1("__utof", mknode(N_CAST, ty_uint, n, 0), 0), 0);
    if (isunsignedty(t) && isfloatty(f) && tk != TY_UCHAR)
        return call1("__ftou", n, 0);
    return mknode(N_CAST, t, n, 0);
}

static struct Type *arith(struct Type *a, struct Type *b)
{
    if (a->kind == TY_LDOUBLE || b->kind == TY_LDOUBLE)
        return ty_ldouble;
    if (a->kind == TY_DOUBLE || b->kind == TY_DOUBLE)
        return ty_double;
    if (a->kind == TY_FLOAT || b->kind == TY_FLOAT)
        return ty_float;
    if (a->kind == TY_ULONG || b->kind == TY_ULONG)
        return ty_ulong;
    if (a->kind == TY_LONG || b->kind == TY_LONG)
        return ty_long;
    if (a->kind == TY_UINT || b->kind == TY_UINT)
        return ty_uint;
    return ty_int;
}

static int fold(int op, int a, int b, int uns)
{
    unsigned ua;
    unsigned ub;
    ua = a & 65535;
    ub = b & 65535;
    switch (op) {
    case N_ADD: return W16(a + b);
    case N_SUB: return W16(a - b);
    case N_MUL: return W16(a * b);
    case N_DIV: return uns ? W16(ua / ub) : W16(a / b);
    case N_MOD: return uns ? W16(ua % ub) : W16(a % b);
    case N_AND: return a & b;
    case N_OR: return a | b;
    case N_XOR: return a ^ b;
    case N_SHL: return W16(a << (b & 15));
    case N_SHR: return uns ? W16(ua >> (b & 15)) : W16(a >> (b & 15));
    case N_EQ: return a == b;
    case N_NE: return a != b;
    case N_LT: return uns ? ua < ub : a < b;
    case N_LE: return uns ? ua <= ub : a <= b;
    case N_GT: return uns ? ua > ub : a > b;
    case N_GE: return uns ? ua >= ub : a >= b;
    }
    return 0;
}

static char *lhelper(int op, int uns)
{
    switch (op) {
    case N_ADD: return "__ladd";
    case N_SUB: return "__lsub";
    case N_MUL: return "__lmul";
    case N_DIV: return uns ? "__uldiv" : "__ldiv";
    case N_MOD: return uns ? "__ulmod" : "__lmod";
    case N_AND: return "__land";
    case N_OR: return "__lor";
    case N_XOR: return "__lxor";
    case N_SHL: return "__lshl";
    case N_SHR: return uns ? "__ulshr" : "__lshr";
    }
    return 0;
}

static struct Node *binop(int op, struct Node *a, struct Node *b)
{
    struct Type *t;
    struct Type *at;
    struct Type *bt;
    struct Node *n;
    int size;
    int uns;
    a = decay(a);
    b = decay(b);
    at = a->type;
    bt = b->type;
    /* pointer arithmetic */
    if ((op == N_ADD || op == N_SUB) && at->kind == TY_PTR && isintegral(bt)) {
        size = at->base->size;
        if (size < 1)
            size = 1;
        b = cast(b, ty_int);
        if (isconst(b))
            b = mknum(W16(b->val * size), ty_int);
        else if (size != 1)
            b = mknode(N_MUL, ty_int, b, mknum(size, ty_int));
        n = mknode(op, at, a, b);
        if (isconst(a) && isconst(b))
            return mknum(fold(op, a->val, b->val, 0), at);
        return n;
    }
    if (op == N_ADD && isintegral(at) && bt->kind == TY_PTR)
        return binop(op, b, a);
    if (op == N_SUB && at->kind == TY_PTR && bt->kind == TY_PTR) {
        size = at->base->size;
        n = mknode(N_SUB, ty_int, a, b);
        if (size > 1)
            n = binop(N_DIV, n, mknum(size, ty_int));
        return n;
    }
    if (op >= N_EQ && op <= N_GE) {
        if (at->kind == TY_PTR || bt->kind == TY_PTR) {
            n = mknode(op, ty_int, cast(a, ty_uint), cast(b, ty_uint));
            return n;
        }
        if (!isscalar(at) || !isscalar(bt)) {
            error(39 /* invalid comparison */, 0);
            return mknum(0, ty_int);
        }
        t = arith(at, bt);
        a = cast(a, t);
        b = cast(b, t);
        if (islongty(t))
            return mknode(op, ty_int, call1(t->kind == TY_ULONG ? "__ulcmp" : "__lcmp", a, b), mknum(0, ty_int));
        if (isconst(a) && isconst(b) && !isfloatty(t))
            return mknum(fold(op, a->val, b->val, isunsignedty(t)), ty_int);
        return mknode(op, ty_int, a, b);
    }
    if (!isscalar(at) || !isscalar(bt) || at->kind == TY_PTR || bt->kind == TY_PTR) {
        error(40 /* invalid operands */, 0);
        return mknum(0, ty_int);
    }
    if (op == N_SHL || op == N_SHR) {
        t = arith(at, ty_int);
        if (!isintegral(t) || !isintegral(bt)) {
            error(41 /* invalid shift */, 0);
            return mknum(0, ty_int);
        }
        a = cast(a, t);
        b = cast(b, ty_int);
        if (islongty(t))
            return call1(lhelper(op, isunsignedty(t)), a, b);
        if (isconst(a) && isconst(b))
            return mknum(fold(op, a->val, b->val, isunsignedty(t)), t);
        if (op == N_SHL && isconst(b) && b->val >= 0 && b->val < 15)
            return mknode(N_MUL, t, a, mknum(1 << b->val, ty_int));
        if (op == N_SHL)
            return mknode(N_CAST, t, call1("__shl", cast(a, ty_int), b), 0);
        if (isunsignedty(t))
            return call1("__ushr", a, b);
        return call1("__shr", a, b);
    }
    t = arith(at, bt);
    if ((op == N_MOD || op == N_AND || op == N_OR || op == N_XOR) && isfloatty(t)) {
        error(40 /* invalid operands */, 0);
        return mknum(0, ty_int);
    }
    a = cast(a, t);
    b = cast(b, t);
    uns = isunsignedty(t);
    if (islongty(t))
        return mknode(N_CAST, t, call1(lhelper(op, uns), a, b), 0);
    if (isconst(a) && isconst(b) && !isfloatty(t)) {
        if ((op == N_DIV || op == N_MOD) && b->val == 0)
            error(42 /* division by zero */, 0);
        else
            return mknum(fold(op, a->val, b->val, uns), t);
    }
    if (!isfloatty(t)) {
        if (op == N_DIV)
            return mknode(N_CAST, t, call1(uns ? "__udiv" : "__divi", a, b), 0);
        if (op == N_MOD)
            return mknode(N_CAST, t, call1(uns ? "__umod" : "__modi", a, b), 0);
        if (op == N_XOR)
            return mknode(N_CAST, t, call1("__xor", cast(a, ty_int), cast(b, ty_int)), 0);
    }
    return mknode(op, t, a, b);
}

/* value of a condition as int 0/1 is produced by gen; this checks type */
static struct Node *fzero(void)
{
    struct Node *n;
    n = mknode(N_FNUM, ty_double, 0, 0);
    n->fimg = (unsigned char *)xalloc(4);
    return n;
}

static struct Node *cond(struct Node *n)
{
    n = decay(n);
    if (!isscalar(n->type))
        error(43 /* scalar required */, 0);
    if (isfloatty(n->type))
        n = binop(N_NE, n, fzero());
    return n;
}

/* ---- expressions ---- */

static struct Node *arglist(struct Type *ft, int *nargs)
{
    struct Node *first;
    struct Node *last;
    struct Node *a;
    struct Param *p;
    int n;
    first = 0;
    last = 0;
    n = 0;
    p = ft ? ft->params : 0;
    while (tok != ')' && tok != T_EOF) {
        a = assign();
        if (ft) {
            if (p) {
                a = cast(a, p->type);
                p = p->next;
            } else {
                if (!ft->variadic && !ft->oldstyle)
                    error(44 /* too many arguments */, 0);
                a = decay(a);
                if (a->type->kind == TY_CHAR || a->type->kind == TY_UCHAR)
                    a = cast(a, ty_int);
                else if (a->type->kind == TY_FLOAT)
                    a = cast(a, ty_double);
            }
        }
        a->next = 0;
        if (last)
            last->next = a;
        else
            first = a;
        last = a;
        n++;
        if (tok != ',')
            break;
        next();
    }
    if (ft && p)
        error(45 /* too few arguments */, 0);
    expect(')', ")");
    *nargs = n;
    return first;
}

static struct Node *intrinsic(int code)
{
    struct Node *n;
    int na;
    next();
    expect('(', "(");
    n = mknode(N_INTRIN, ty_int, 0, 0);
    n->val = code;
    n->a = arglist(0, &na);
    if (code == I_VASTART) {
        if (!curft || !curft->variadic)
            error(46 /* __va_start outside a variadic function */, 0);
        n->val2 = vaoff;
        n->type = ty_charp;
    } else if (code == I_CSPV || code == I_CXP0V || code == I_EXITP)
        n->type = ty_void;
    else if (code == I_CSPF)
        n->type = ty_float;
    else if (code == I_OSVARA)
        n->type = ptrto(ty_int);
    if ((code >= I_CSPV && code <= I_CXP0I) || code == I_OSVAR || code == I_OSVARA) {
        if (!n->a || !isconst(n->a))
            error(47 /* constant expected */, intrnames[code]);
    }
    return n;
}

static struct Node *primary(void)
{
    struct Node *n;
    struct Sym *s;
    int i;
    switch (tok) {
    case T_NUM:
        if (toklong & 1) {
            n = mknode(N_NUM, (toklong & 2) ? ty_ulong : ty_long, 0, 0);
            n->val = tokval;
            n->val2 = tokval2;
        } else
            n = mknum(tokval, (toklong & 2) ? ty_uint : ty_int);
        next();
        return n;
    case T_FNUM:
        if (!insys)
            usesfloat = 1;
        n = mknode(N_FNUM, ty_double, 0, 0);
        n->fimg = (unsigned char *)xalloc(4);
        memcpy(n->fimg, tokreal, 4);
        next();
        return n;
    case T_STR:
        {
            /* the literal's array type lives as long as the statement */
            struct Type *st;
            st = (struct Type *)xalloc(sizeof(struct Type));
            st->kind = TY_ARRAY;
            st->size = toklen;
            st->align = 1;
            st->base = ty_char;
            st->len = toklen;
            n = mknode(N_STR, st, 0, 0);
        }
        n->str = xalloc(toklen);
        memcpy(n->str, tokstr, toklen);
        n->slen = toklen;
        next();
        return n;
    case '(':
        next();
        n = expr();
        expect(')', ")");
        return n;
    case T_ID:
        s = lookup(tokname);
        if (!s && tokname[0] == '_' && tokname[1] == '_') {
            for (i = 1; intrnames[i]; i++)
                if (strcmp(tokname, intrnames[i]) == 0)
                    return intrinsic(i);
        }
        if (!s) {
            error(48 /* undeclared identifier */, tokname);
            next();
            return mknum(0, ty_int);
        }
        next();
        if (s->kind == S_ENUMC)
            return mknum(s->offset, ty_int);
        if (s->kind == S_FUNC) {
            n = mknode(N_FUNC, s->type, 0, 0);
            n->sym = s;
            return n;
        }
        if (s->kind == S_TYPEDEF) {
            error(49 /* unexpected type name */, s->name);
            return mknum(0, ty_int);
        }
        n = mknode(N_VAR, s->type, 0, 0);
        n->sym = s;
        return n;
    }
    error(50 /* expression expected */, 0);
    next();
    return mknum(0, ty_int);
}

static struct Field *findfield(struct Type *t, char *name, int *off)
{
    struct Field *f;
    struct Field *r;
    int o;
    for (f = t->fields; f; f = f->next) {
        if (f->name && strcmp(f->name, name) == 0) {
            *off = f->offset;
            return f;
        }
        if (!f->name && (f->type->kind == TY_STRUCT || f->type->kind == TY_UNION)) {
            r = findfield(f->type, name, &o);
            if (r) {
                *off = f->offset + o;
                return r;
            }
        }
    }
    return 0;
}

static struct Node *member(struct Node *n, char *name)
{
    struct Field *f;
    struct Node *m;
    int off;
    if (n->type->kind != TY_STRUCT && n->type->kind != TY_UNION) {
        error(51 /* not a structure */, name);
        return n;
    }
    if (n->type->size < 0)
        error(52 /* incomplete structure */, n->type->tag);
    f = findfield(n->type, name, &off);
    if (!f) {
        error(53 /* no such member */, name);
        return n;
    }
    m = mknode(N_MEMBER, f->type, n, 0);
    m->val = off;
    return m;
}

static struct Node *deref(struct Node *n)
{
    n = decay(n);
    if (n->type->kind != TY_PTR) {
        error(54 /* pointer required */, 0);
        return n;
    }
    if (n->type->base->kind == TY_FUNC)
        return n;               /* *fp is the function itself */
    return mknode(N_DEREF, n->type->base, n, 0);
}

static struct Node *postfix(void)
{
    struct Node *n;
    struct Node *c;
    struct Type *ft;
    int na;
    n = primary();
    for (;;) {
        if (tok == '[') {
            next();
            c = expr();
            expect(']', "]");
            n = deref(binop(N_ADD, n, c));
        } else if (tok == '(') {
            next();
            ft = 0;
            if (n->type->kind == TY_FUNC)
                ft = n->type;
            else if (n->type->kind == TY_PTR && n->type->base->kind == TY_FUNC) {
                ft = n->type->base;
            } else
                error(55 /* not a function */, 0);
            c = mknode(N_CALL, ft ? ft->base : ty_int, n, 0);
            c->b = arglist(ft, &na);
            c->val = na;
            n = c;
        } else if (tok == '.') {
            next();
            if (tok != T_ID)
                error(56 /* member name expected */, 0);
            n = member(n, tokname);
            next();
        } else if (tok == T_ARROW) {
            next();
            if (tok != T_ID)
                error(56 /* member name expected */, 0);
            n = member(deref(n), tokname);
            next();
        } else if (tok == T_INC || tok == T_DEC) {
            struct Node *u;
            if (!islvalue(n))
                error(57 /* lvalue required */, 0);
            u = mknode(N_LVREF, n->type, 0, 0);
            u = cast(binop(tok == T_INC ? N_ADD : N_SUB, u, mknum(1, ty_int)), n->type);
            n = mknode(N_POSTINC, n->type, n, u);
            next();
        } else
            return n;
    }
}

static struct Node *unary(void)
{
    struct Node *n;
    struct Node *u;
    struct Type *t;
    int op;
    switch (tok) {
    case '-':
        next();
        n = castexpr();
        n = decay(n);
        if (isconst(n))
            return mknum(-n->val, arith(n->type, ty_int));
        if (n->op == N_FNUM) {
            n->fimg[1] = n->fimg[1] ^ 128;
            if (n->fimg[0] == 0)
                n->fimg[1] = 0;
            return n;
        }
        if (islongty(n->type))
            return mknode(N_CAST, n->type, call1("__lneg", n, 0), 0);
        if (!isintegral(n->type) && !isfloatty(n->type))
            error(58 /* invalid operand */, 0);
        t = isfloatty(n->type) ? n->type : arith(n->type, ty_int);
        return mknode(N_NEG, t, cast(n, t), 0);
    case '+':
        next();
        n = castexpr();
        return cast(n, isfloatty(n->type) || islongty(n->type) ? n->type : arith(n->type, ty_int));
    case '~':
        next();
        n = castexpr();
        if (!isintegral(n->type))
            error(58 /* invalid operand */, 0);
        if (islongty(n->type))
            return mknode(N_CAST, n->type, call1("__lnot", n, 0), 0);
        t = arith(n->type, ty_int);
        if (isconst(n))
            return mknum(~n->val, t);
        return mknode(N_BNOT, t, cast(n, t), 0);
    case '!':
        next();
        n = cond(castexpr());
        if (isconst(n))
            return mknum(!n->val, ty_int);
        return mknode(N_NOT, ty_int, n, 0);
    case '*':
        next();
        return deref(castexpr());
    case '&':
        next();
        n = castexpr();
        if (n->op == N_FUNC)
            return mknode(N_ADDR, ptrto(n->type), n, 0);
        if (!islvalue(n))
            error(57 /* lvalue required */, 0);
        return mknode(N_ADDR, ptrto(n->type), n, 0);
    case T_INC:
    case T_DEC:
        op = tok == T_INC ? N_ADD : N_SUB;
        next();
        n = unary();
        if (!islvalue(n))
            error(57 /* lvalue required */, 0);
        u = mknode(N_LVREF, n->type, 0, 0);
        u = cast(binop(op, u, mknum(1, ty_int)), n->type);
        return mknode(N_OPASSIGN, n->type, n, u);
    case K_SIZEOF:
        next();
        if (tok == '(' && (peek() >= K_FIRST || (peek() == T_ID && lookup(peekname()) && lookup(peekname())->kind == S_TYPEDEF))) {
            next();
            if (istypename()) {
                t = typename();
                expect(')', ")");
            } else {
                n = expr();
                expect(')', ")");
                t = n->type;
            }
        } else {
            n = unary();
            t = n->type;
        }
        if (t->size < 0)
            error(59 /* sizeof incomplete type */, 0);
        return mknum(t->size, ty_uint);
    }
    return postfix();
}

static struct Node *castexpr(void)
{
    struct Type *t;
    struct Node *n;
    if (tok == '(' && (peek() >= K_FIRST || (peek() == T_ID && lookup(peekname()) && lookup(peekname())->kind == S_TYPEDEF))) {
        next();
        if (istypename()) {
            t = typename();
            expect(')', ")");
            n = castexpr();
            return cast(n, t);
        }
        n = expr();
        expect(')', ")");
        /* continue as a postfix expression */
        for (;;) {
            if (tok == '[') {
                struct Node *c;
                next();
                c = expr();
                expect(']', "]");
                n = deref(binop(N_ADD, n, c));
            } else if (tok == '.') {
                next();
                n = member(n, tokname);
                next();
            } else if (tok == T_ARROW) {
                next();
                n = member(deref(n), tokname);
                next();
            } else
                return n;
        }
    }
    return unary();
}

static int binprec(int t, int *op)
{
    switch (t) {
    case '*': *op = N_MUL; return 10;
    case '/': *op = N_DIV; return 10;
    case '%': *op = N_MOD; return 10;
    case '+': *op = N_ADD; return 9;
    case '-': *op = N_SUB; return 9;
    case T_SHL: *op = N_SHL; return 8;
    case T_SHR: *op = N_SHR; return 8;
    case '<': *op = N_LT; return 7;
    case '>': *op = N_GT; return 7;
    case T_LE: *op = N_LE; return 7;
    case T_GE: *op = N_GE; return 7;
    case T_EQ: *op = N_EQ; return 6;
    case T_NE: *op = N_NE; return 6;
    case '&': *op = N_AND; return 5;
    case '^': *op = N_XOR; return 4;
    case '|': *op = N_OR; return 3;
    case T_ANDAND: *op = N_ANDAND; return 2;
    case T_OROR: *op = N_OROR; return 1;
    }
    return 0;
}

static struct Node *binexpr(int minprec)
{
    struct Node *a;
    struct Node *b;
    int p;
    int op;
    a = castexpr();
    for (;;) {
        p = binprec(tok, &op);
        if (p == 0 || p < minprec)
            return a;
        next();
        b = binexpr(p + 1);
        if (op == N_ANDAND || op == N_OROR) {
            a = cond(a);
            b = cond(b);
            if (isconst(a) && isconst(b))
                a = mknum(op == N_ANDAND ? (a->val && b->val) : (a->val || b->val), ty_int);
            else
                a = mknode(op, ty_int, a, b);
        } else
            a = binop(op, a, b);
    }
}

static struct Node *condexpr(void)
{
    struct Node *c;
    struct Node *a;
    struct Node *b;
    struct Node *n;
    struct Type *t;
    c = binexpr(1);
    if (tok != '?')
        return c;
    next();
    c = cond(c);
    a = decay(expr());
    expect(':', ":");
    b = decay(condexpr());
    if (isscalar(a->type) && isscalar(b->type) && a->type->kind != TY_PTR && b->type->kind != TY_PTR) {
        t = arith(a->type, b->type);
        a = cast(a, t);
        b = cast(b, t);
    } else if (a->type->kind == TY_PTR)
        t = a->type;
    else
        t = b->type;
    if (isconst(c))
        return c->val ? a : b;
    n = mknode(N_COND, t, c, a);
    n->c = b;
    return n;
}

static struct Node *assign(void)
{
    struct Node *a;
    struct Node *b;
    struct Node *u;
    int op;
    a = condexpr();
    if (tok == '=') {
        next();
        b = assign();
        if (!islvalue(a) || a->type->kind == TY_ARRAY)
            error(57 /* lvalue required */, 0);
        if (a->type->kind == TY_STRUCT || a->type->kind == TY_UNION) {
            if (!sametype(a->type, b->type) || a->type != b->type)
                if (a->type != b->type)
                    error(60 /* incompatible structure assignment */, 0);
            return mknode(N_ASSIGN, a->type, a, b);
        }
        return mknode(N_ASSIGN, a->type, a, cast(b, a->type));
    }
    if (tok >= T_ADDA && tok <= T_SHRA) {
        switch (tok) {
        case T_ADDA: op = N_ADD; break;
        case T_SUBA: op = N_SUB; break;
        case T_MULA: op = N_MUL; break;
        case T_DIVA: op = N_DIV; break;
        case T_MODA: op = N_MOD; break;
        case T_ANDA: op = N_AND; break;
        case T_ORA: op = N_OR; break;
        case T_XORA: op = N_XOR; break;
        case T_SHLA: op = N_SHL; break;
        default: op = N_SHR; break;
        }
        next();
        b = assign();
        if (!islvalue(a))
            error(57 /* lvalue required */, 0);
        u = mknode(N_LVREF, a->type, 0, 0);
        u = cast(binop(op, u, b), a->type);
        return mknode(N_OPASSIGN, a->type, a, u);
    }
    return a;
}

static struct Node *expr(void)
{
    struct Node *a;
    struct Node *b;
    a = assign();
    while (tok == ',') {
        next();
        b = assign();
        a = mknode(N_COMMA, b->type, a, b);
    }
    return a;
}

static int constexpr(void)
{
    struct Node *n;
    int m;
    m = xmark();
    n = condexpr();
    if (!isconst(n)) {
        if (n->op == N_NUM)
            return n->val;
        error(61 /* constant expression required */, 0);
        xrelease(m);
        return 0;
    }
    xrelease(m);
    return n->val;
}

/* ---- declarations ---- */

struct Dcl {
    int n;
    int kind[12];
    int len[12];
    struct Type *ft[12];
    char name[MAXNAME];
};

static struct Param *paramlist(int *variadic, int *oldstyle);

static int isnested(void)
{
    int p;
    struct Sym *s;
    p = peek();
    if (p == '*' || p == '(')
        return 1;
    if (p == T_ID) {
        s = lookup(peekname());
        return !(s && s->kind == S_TYPEDEF);
    }
    return 0;
}

static void dcl(struct Dcl *d)
{
    int nstars;
    int i;
    int variadic;
    int oldstyle;
    struct Type *ft;
    struct Param *pl;
    nstars = 0;
    while (tok == '*' || tok == K_CONST || tok == K_VOLATILE) {
        if (tok == '*')
            nstars++;
        next();
    }
    if (tok == '(' && isnested()) {
        next();
        dcl(d);
        expect(')', ")");
    } else if (tok == T_ID) {
        strcpy(d->name, tokname);
        next();
    }
    for (;;) {
        if (tok == '[') {
            next();
            if (d->n >= 12)
                fatal(62 /* declarator too complex */, 0);
            d->kind[d->n] = TY_ARRAY;
            d->len[d->n] = -1;
            if (tok != ']')
                d->len[d->n] = constexpr();
            expect(']', "]");
            d->n++;
        } else if (tok == '(') {
            next();
            pl = paramlist(&variadic, &oldstyle);
            ft = mktype(TY_FUNC, 2, 2);
            ft->params = pl;
            ft->variadic = variadic;
            ft->oldstyle = oldstyle;
            if (d->n >= 12)
                fatal(62 /* declarator too complex */, 0);
            d->kind[d->n] = TY_FUNC;
            d->ft[d->n] = ft;
            d->n++;
        } else
            break;
    }
    for (i = 0; i < nstars; i++) {
        if (d->n >= 12)
            fatal(62 /* declarator too complex */, 0);
        d->kind[d->n++] = TY_PTR;
    }
}

static struct Type *applydcl(struct Type *t, struct Dcl *d)
{
    int i;
    struct Type *f;
    for (i = d->n - 1; i >= 0; i--) {
        if (d->kind[i] == TY_PTR)
            t = ptrto(t);
        else if (d->kind[i] == TY_ARRAY) {
            if (t->kind == TY_FUNC)
                error(63 /* array of functions */, 0);
            t = arrayof(t, d->len[i]);
        } else {
            f = d->ft[i];
            if (t->kind == TY_FUNC || t->kind == TY_ARRAY)
                error(64 /* function returning an array or function */, 0);
            f->base = t;
            t = f;
        }
    }
    return t;
}

static struct Type *declarator(struct Type *base, char *name)
{
    struct Dcl d;
    d.n = 0;
    d.name[0] = 0;
    dcl(&d);
    strcpy(name, d.name);
    return applydcl(base, &d);
}

static struct Type *typename(void)
{
    struct Type *t;
    char name[MAXNAME];
    int sc;
    t = declspec(&sc);
    return declarator(t, name);
}

static struct Param *paramlist(int *variadic, int *oldstyle)
{
    struct Param *first;
    struct Param *last;
    struct Param *p;
    struct Type *t;
    char name[MAXNAME];
    int sc;
    *variadic = 0;
    *oldstyle = 0;
    first = 0;
    last = 0;
    if (tok == ')') {
        next();
        *oldstyle = 1;
        return 0;
    }
    if (tok == K_VOID && peek() == ')') {
        next();
        next();
        return 0;
    }
    for (;;) {
        if (tok == T_ELLIPSIS) {
            next();
            *variadic = 1;
            break;
        }
        t = declspec(&sc);
        t = declarator(t, name);
        if (t->kind == TY_ARRAY)
            t = ptrto(t->base);
        else if (t->kind == TY_FUNC)
            t = ptrto(t);
        if (tentative) {
            p = (struct Param *)xalloc(sizeof(struct Param));
            p->name = 0;
            if (name[0]) {          /* a definition in a header needs its names */
                p->name = xalloc(strlen(name) + 1);
                strcpy(p->name, name);
            }
        } else {
            p = (struct Param *)palloc(sizeof(struct Param));
            p->name = 0;
            if (name[0]) {          /* only needed while the function body is compiled */
                p->name = falloc(strlen(name) + 1);
                strcpy(p->name, name);
            }
        }
        p->type = t;
        if (last)
            last->next = p;
        else
            first = p;
        last = p;
        if (tok != ',')
            break;
        next();
    }
    expect(')', ")");
    return first;
}

static struct Type *structspec(int isunion)
{
    struct Sym *s;
    struct Type *t;
    struct Type *ft;
    struct Type *base;
    struct Field *f;
    struct Field *last;
    char tag[MAXNAME];
    char name[MAXNAME];
    int off;
    int size;
    int sc;
    next();
    tag[0] = 0;
    if (tok == T_ID) {
        strcpy(tag, tokname);
        next();
    }
    t = 0;
    if (tok != '{') {
        if (!tag[0]) {
            error(65 /* structure tag expected */, 0);
            return ty_int;
        }
        s = lookuptag(tag);
        if (s)
            return s->type;
        t = mktype(isunion ? TY_UNION : TY_STRUCT, -1, 2);
        t->tag = pstrdup(tag);
        s = addsym(tag, S_TAG, t);
        return t;
    }
    if (tag[0]) {
        s = lookuptag(tag);
        if (s && s->level == level && s->type->size < 0)
            t = s->type;
        else if (s && s->level == level)
            error(66 /* structure redefined */, tag);
    }
    if (!t) {
        t = mktype(isunion ? TY_UNION : TY_STRUCT, -1, 2);
        if (tag[0]) {
            t->tag = pstrdup(tag);
            addsym(tag, S_TAG, t);
        }
    }
    next();
    off = 0;
    size = 0;
    last = 0;
    while (tok != '}' && tok != T_EOF) {
        base = declspec(&sc);
        if (tok == ';') {               /* anonymous struct/union member */
            f = (struct Field *)palloc(sizeof(struct Field));
            f->type = base;
            if (!isunion) {
                off = (off + 1) & ~1;
                f->offset = off;
                off = off + base->size;
            }
            if (last)
                last->next = f;
            else
                t->fields = f;
            last = f;
            next();
            continue;
        }
        for (;;) {
            ft = declarator(base, name);
            if (ft->size < 0 || ft->kind == TY_FUNC)
                error(67 /* invalid member type */, name);
            f = (struct Field *)palloc(sizeof(struct Field));
            f->name = pstrdup(name);
            f->type = ft;
            if (isunion) {
                f->offset = 0;
                if (ft->size > size)
                    size = ft->size;
            } else {
                if (ft->align > 1)
                    off = (off + 1) & ~1;
                f->offset = off;
                off = off + ft->size;
            }
            if (last)
                last->next = f;
            else
                t->fields = f;
            last = f;
            if (tok != ',')
                break;
            next();
        }
        expect(';', ";");
    }
    expect('}', "}");
    if (!isunion)
        size = off;
    t->size = (size + 1) & ~1;
    if (t->size == 0)
        t->size = 2;
    return t;
}

static struct Type *enumspec(void)
{
    struct Sym *s;
    int v;
    next();
    if (tok == T_ID) {
        s = lookuptag(tokname);
        if (!s)
            addsym(tokname, S_TAG, ty_int);
        next();
    }
    if (tok != '{')
        return ty_int;
    next();
    v = 0;
    while (tok == T_ID) {
        s = addsym(tokname, S_ENUMC, ty_int);
        next();
        if (tok == '=') {
            next();
            v = constexpr();
        }
        s->offset = v;
        v = W16(v + 1);
        if (tok != ',')
            break;
        next();
    }
    expect('}', "}");
    return ty_int;
}

static struct Type *declspec(int *sclass)
{
    int nlong;
    int nshort;
    int uns;
    int sgn;
    int base;
    struct Type *t;
    struct Sym *s;
    nlong = 0;
    nshort = 0;
    uns = 0;
    sgn = 0;
    base = 0;
    t = 0;
    *sclass = 0;
    for (;;) {
        switch (tok) {
        case K_TYPEDEF: case K_EXTERN: case K_STATIC:
            *sclass = tok;
            next();
            continue;
        case K_AUTO: case K_REGISTER: case K_CONST: case K_VOLATILE:
            next();
            continue;
        case K_VOID: case K_CHAR: case K_INT: case K_FLOAT: case K_DOUBLE:
            base = tok;
            next();
            continue;
        case K_LONG:
            nlong++;
            next();
            continue;
        case K_SHORT:
            nshort++;
            next();
            continue;
        case K_UNSIGNED:
            uns = 1;
            next();
            continue;
        case K_SIGNED:
            sgn = 1;
            next();
            continue;
        case K_STRUCT:
        case K_UNION:
            t = structspec(tok == K_UNION);
            continue;
        case K_ENUM:
            t = enumspec();
            continue;
        case T_ID:
            if (!t && !base && !nlong && !nshort && !uns && !sgn) {
                s = lookup(tokname);
                if (s && s->kind == S_TYPEDEF) {
                    t = s->type;
                    next();
                    continue;
                }
            }
            break;
        }
        break;
    }
    if (t)
        return t;
    switch (base) {
    case K_VOID: return ty_void;
    case K_CHAR: return uns ? ty_uchar : ty_char;
    case K_FLOAT:
        if (!insys)
            usesfloat = 1;
        return ty_float;
    case K_DOUBLE:
        if (!insys)
            usesfloat = 1;
        return nlong ? ty_ldouble : ty_double;
    }
    if (nlong)
        return uns ? ty_ulong : ty_long;
    return uns ? ty_uint : ty_int;
}

/* ---- initializers ---- */

static struct Node *elem(struct Node *lv, int off, struct Type *t)
{
    struct Node *m;
    m = mknode(N_MEMBER, t, lv, 0);
    m->val = off;
    return m;
}

static void initializer(struct Node *lv, struct Type *t, int global)
{
    struct Node *n;
    struct Field *f;
    int i;
    int m;
    int brace;
    int save;
    save = globinit;
    globinit = global;
    init1(lv, t, global);
    globinit = save;
}

static void init1(struct Node *lv, struct Type *t, int global)
{
    struct Node *n;
    struct Field *f;
    int i;
    int m;
    int brace;
    if (t->kind == TY_ARRAY) {
        if (tok == T_STR && (t->base->kind == TY_CHAR || t->base->kind == TY_UCHAR)) {
            m = xmark();
            n = primary();
            if (t->len < 0) {
                t->len = n->slen;
                t->size = n->slen;
            } else if (n->slen - 1 > t->len)
                error(68 /* initializer string too long */, 0);
            ir_discard(mknode(N_ASSIGN, t, lv, n));
            xrelease(m);
            return;
        }
        if (tok != '{') {
            error(69 /* { expected */, 0);
            return;
        }
        next();
        i = 0;
        while (tok != '}' && tok != T_EOF) {
            if (t->len >= 0 && i >= t->len)
                error(70 /* too many initializers */, 0);
            init1(elem(lv, W16(i * t->base->size), t->base), t->base, global);
            i++;
            if (tok != ',')
                break;
            next();
        }
        expect('}', "}");
        if (t->len < 0) {
            t->len = i;
            t->size = W16(i * t->base->size);
        }
        return;
    }
    if (t->kind == TY_STRUCT || t->kind == TY_UNION) {
        if (tok != '{') {
            m = xmark();
            n = assign();
            ir_discard(mknode(N_ASSIGN, t, lv, n));
            xrelease(m);
            return;
        }
        next();
        f = t->fields;
        while (tok != '}' && tok != T_EOF) {
            if (!f) {
                error(70 /* too many initializers */, 0);
                break;
            }
            init1(elem(lv, f->offset, f->type), f->type, global);
            f = t->kind == TY_UNION ? 0 : f->next;
            if (tok != ',')
                break;
            next();
        }
        expect('}', "}");
        return;
    }
    brace = 0;
    if (tok == '{') {
        brace = 1;
        next();
    }
    m = xmark();
    n = assign();
    ir_discard(mknode(N_ASSIGN, t, lv, cast(n, t)));
    xrelease(m);
    if (brace)
        expect('}', "}");
}

/* ---- statements ---- */

static struct Sym *label(char *name)
{
    struct Sym *s;
    for (s = labels; s; s = s->next)
        if (strcmp(s->name, name) == 0)
            return s;
    s = (struct Sym *)falloc(sizeof(struct Sym));
    s->name = falloc(strlen(name) + 1);
    strcpy(s->name, name);
    s->kind = S_LABEL;
    s->offset = ir_newlabel();
    s->next = labels;
    labels = s;
    return s;
}

static void localdecl(void)
{
    struct Type *base;
    struct Type *t;
    struct Sym *s;
    struct Node *lv;
    char name[MAXNAME];
    int sc;
    base = declspec(&sc);
    if (tok == ';') {
        next();
        return;
    }
    for (;;) {
        t = declarator(base, name);
        if (!name[0])
            error(71 /* name expected */, 0);
        if (sc == K_TYPEDEF)
            addsym(name, S_TYPEDEF, t);
        else if (t->kind == TY_FUNC || sc == K_EXTERN) {
            s = lookup(name);
            if (!s || s->level != 0) {
                int save;
                save = level;
                level = 0;
                s = addsym(name, t->kind == TY_FUNC ? S_FUNC : S_GLOBAL, t);
                level = save;
                if (t->kind != TY_FUNC)
                    s->offset = -1;     /* by name: defined in some module */
            }
        } else if (sc == K_STATIC) {
            s = addsym(name, S_GLOBAL, t);
            s->isstatic = 1;
            if (tok == '=') {
                next();
                if (t->kind == TY_ARRAY && t->len < 0 && tok == T_STR) {
                    t->len = toklen;
                    t->size = toklen;
                }
                s->offset = t->size >= 0 ? allocglobal(t) : 0;
                lv = mknode(N_VAR, t, 0, 0);
                lv->sym = s;
                ir_initbegin();
                initializer(lv, t, 1);
                ir_initend();
                if (s->offset == 0)
                    s->offset = allocglobal(t);
            } else
                s->offset = allocglobal(t);
        } else {
            if (tok == '=' && t->kind == TY_ARRAY && t->len < 0) {
                next();
                if (tok != T_STR)
                    error(72 /* array size required */, name);
                else {
                    t->len = toklen;
                    t->size = toklen;
                }
                s = addsym(name, S_LOCAL, t);
                s->offset = alloclocal(t);
                lv = mknode(N_VAR, t, 0, 0);
                lv->sym = s;
                initializer(lv, t, 0);
            } else {
                if (t->size < 0)
                    error(73 /* incomplete type */, name);
                s = addsym(name, S_LOCAL, t);
                s->offset = alloclocal(t);
                if (tok == '=') {
                    next();
                    lv = mknode(N_VAR, t, 0, 0);
                    lv->sym = s;
                    initializer(lv, t, 0);
                }
            }
        }
        if (tok != ',')
            break;
        next();
    }
    expect(';', ";");
}

static void compound(int brk, int cont)
{
    int save;
    next();
    pushscope();
    save = curlocal;
    while (tok != '}' && tok != T_EOF) {
        if (istypename())
            localdecl();
        else
            statement(brk, cont);
    }
    expect('}', "}");
    curlocal = save;
    popscope();
}

static struct Node *condparen(void)
{
    struct Node *n;
    expect('(', "(");
    n = cond(expr());
    expect(')', ")");
    return n;
}

static void statement(int brk, int cont)
{
    struct Node *n;
    struct Node *inc;
    struct Sym *s;
    int m;
    int save;
    int l1;
    int l2;
    int l3;
    int *sv;
    int *sl;
    int sn;
    int smax;
    int sdef;
    int t;
    m = xmark();
    save = curlocal;
    switch (tok) {
    case '{':
        compound(brk, cont);
        break;
    case ';':
        next();
        break;
    case K_IF:
        next();
        n = condparen();
        l1 = ir_newlabel();
        ir_branch(n, l1, 0);
        xrelease(m);
        curlocal = save;
        statement(brk, cont);
        if (tok == K_ELSE) {
            next();
            l2 = ir_newlabel();
            ir_jump(l2);
            ir_setlabel(l1);
            statement(brk, cont);
            ir_setlabel(l2);
        } else
            ir_setlabel(l1);
        break;
    case K_WHILE:
        next();
        l1 = ir_newlabel();
        l2 = ir_newlabel();
        ir_setlabel(l1);
        n = condparen();
        ir_branch(n, l2, 0);
        xrelease(m);
        curlocal = save;
        statement(l2, l1);
        ir_jump(l1);
        ir_setlabel(l2);
        break;
    case K_DO:
        next();
        l1 = ir_newlabel();
        l2 = ir_newlabel();
        l3 = ir_newlabel();
        ir_setlabel(l1);
        statement(l3, l2);
        ir_setlabel(l2);
        if (tok != K_WHILE)
            error(74 /* while expected */, 0);
        next();
        n = condparen();
        ir_branch(n, l1, 1);
        ir_setlabel(l3);
        expect(';', ";");
        break;
    case K_FOR:
        next();
        expect('(', "(");
        pushscope();
        if (istypename())
            localdecl();
        else {
            if (tok != ';')
                ir_discard(expr());
            expect(';', ";");
        }
        l1 = ir_newlabel();
        l2 = ir_newlabel();
        l3 = ir_newlabel();
        ir_setlabel(l1);
        if (tok != ';')
            ir_branch(cond(expr()), l3, 0);
        expect(';', ";");
        inc = 0;
        if (tok != ')')
            inc = expr();
        expect(')', ")");
        statement(l3, l2);
        ir_setlabel(l2);
        if (inc)
            ir_discard(inc);
        ir_jump(l1);
        ir_setlabel(l3);
        popscope();
        break;
    case K_SWITCH:
        next();
        expect('(', "(");
        n = expr();
        expect(')', ")");
        n = decay(n);
        if (!isintegral(n->type) || islongty(n->type)) {
            if (islongty(n->type))
                n = cast(n, ty_int);
            else
                error(75 /* integer required */, 0);
        }
        t = alloclocal(ty_int);
        ir_valuestl(cast(n, ty_int), t);
        sv = swvals;
        sl = swlabs;
        sn = swn;
        smax = swmax;
        sdef = swdef;
        swmax = 64;
        swvals = (int *)falloc(swmax * sizeof(int));
        swlabs = (int *)falloc(swmax * sizeof(int));
        swn = 0;
        swdef = -1;
        l1 = ir_newlabel();
        l2 = ir_newlabel();
        ir_jump(l1);
        xrelease(m);
        statement(l2, cont);
        ir_jump(l2);
        ir_setlabel(l1);
        ir_switch(t, swvals, swlabs, swn, swdef >= 0 ? swdef : l2);
        ir_setlabel(l2);
        swvals = sv;
        swlabs = sl;
        swn = sn;
        swmax = smax;
        swdef = sdef;
        break;
    case K_CASE:
        next();
        t = constexpr();
        expect(':', ":");
        if (!swvals)
            error(76 /* case outside switch */, 0);
        else {
            int i;
            for (i = 0; i < swn; i++)
                if (swvals[i] == t)
                    error(77 /* duplicate case */, 0);
            if (swn >= swmax) {
                int *nv;
                int *nl;
                nv = (int *)falloc(swmax * 2 * sizeof(int));
                nl = (int *)falloc(swmax * 2 * sizeof(int));
                memcpy(nv, swvals, swmax * sizeof(int));
                memcpy(nl, swlabs, swmax * sizeof(int));
                swvals = nv;
                swlabs = nl;
                swmax = swmax * 2;
            }
            swvals[swn] = t;
            swlabs[swn] = ir_newlabel();
            ir_setlabel(swlabs[swn]);
            swn++;
        }
        statement(brk, cont);
        break;
    case K_DEFAULT:
        next();
        expect(':', ":");
        if (!swvals)
            error(78 /* default outside switch */, 0);
        else {
            swdef = ir_newlabel();
            ir_setlabel(swdef);
        }
        statement(brk, cont);
        break;
    case K_BREAK:
        next();
        if (brk < 0)
            error(79 /* break outside loop or switch */, 0);
        else
            ir_jump(brk);
        expect(';', ";");
        break;
    case K_CONTINUE:
        next();
        if (cont < 0)
            error(80 /* continue outside loop */, 0);
        else
            ir_jump(cont);
        expect(';', ";");
        break;
    case K_RETURN:
        next();
        n = 0;
        if (tok != ';') {
            n = expr();
            if (curft->base->kind == TY_VOID)
                error(81 /* void function returns a value */, 0);
            else if (curft->base->kind != TY_STRUCT && curft->base->kind != TY_UNION)
                n = cast(n, curft->base);
        }
        ir_return(n, curft, sretoff);
        ir_jump(exitlab);
        expect(';', ";");
        break;
    case K_GOTO:
        next();
        if (tok != T_ID)
            error(82 /* label expected */, 0);
        else {
            s = label(tokname);
            ir_jump(s->offset);
            next();
        }
        expect(';', ";");
        break;
    default:
        if (tok == T_ID && peek() == ':') {
            s = label(tokname);
            if (s->defined)
                error(83 /* label redefined */, tokname);
            s->defined = 1;
            ir_setlabel(s->offset);
            next();
            next();
            statement(brk, cont);
            break;
        }
        n = expr();
        ir_discard(n);
        expect(';', ";");
        break;
    }
    xrelease(m);
    curlocal = save;
}

/* ---- functions and external declarations ---- */

static void funcdef(struct Sym *fs, int isstatic)
{
    struct Type *ft;
    struct Param *p;
    struct Param *pv[32];
    struct Sym *s;
    int np;
    int pw;
    int rw;
    int pad;
    int off;
    int i;
    char *seg;
    seg = cursegname;           /* a #pragma read as lookahead belongs to the next function */
    ft = fs->type;
    if (fs->defined)
        error(84 /* function redefined */, fs->name);
    fs->defined = 1;
    curfn = fs;
    curft = ft;
    labels = 0;
    pushscope();
    np = 0;
    pw = 0;
    for (p = ft->params; p; p = p->next) {
        if (np >= 32)
            fatal(85 /* too many parameters */, fs->name);
        pv[np++] = p;
        pw = pw + twords(p->type);
    }
    if (ft->variadic)
        pw++;
    sretoff = 0;
    if (ft->base->kind == TY_STRUCT || ft->base->kind == TY_UNION)
        pw++;
    rw = retwords(ft);
    pad = rw > pw ? rw - pw : 0;
    off = pad + 1;
    vaoff = 0;
    if (ft->variadic) {
        vaoff = off;
        off++;
    }
    for (i = np - 1; i >= 0; i--) {
        p = pv[i];
        if (p->name) {
            s = addsym(p->name, S_LOCAL, p->type);
            s->offset = off;
        } else if (!ft->oldstyle)
            error(86 /* parameter name missing */, fs->name);
        off = off + twords(p->type);
    }
    if (ft->base->kind == TY_STRUCT || ft->base->kind == TY_UNION) {
        sretoff = off;
        off++;
    }
    nparamwords = off - 1;
    curlocal = nparamwords;
    scratch = ++curlocal;
    maxlocal = curlocal;
    ir_funcbegin();
    exitlab = ir_newlabel();
    compound(-1, -1);
    for (s = labels; s; s = s->next)
        if (!s->defined)
            error(87 /* undefined label */, s->name);
    ir_funcend(fs->lname ? fs->lname : fs->name, ft, exitlab, isstatic, seg);
    popscope();
    curfn = 0;
    curft = 0;
    freset();
}

static void external(void)
{
    int sysdecl;
    struct Type *base;
    struct Type *t;
    struct Sym *s;
    struct Node *lv;
    char name[MAXNAME];
    int sc;
    int m;
    m = xmark();
    base = declspec(&sc);
    if (tok == ';') {
        next();
        return;
    }
    for (;;) {
        sysdecl = insys && sc != K_TYPEDEF;
        tentative = sysdecl;
        t = declarator(base, name);
        tentative = 0;
        if (!name[0]) {
            error(71 /* name expected */, 0);
            next();
            return;
        }
        if (sysdecl) {
            if ((sc == K_EXTERN || (t->kind == TY_FUNC && tok != '{')) && !isref(name)) {
                if (tok != ',')
                    break;              /* not used by the program: not kept */
                next();
                continue;
            }
            t = permtype(t);
        }
        if (sc == K_TYPEDEF) {
            addsym(name, S_TYPEDEF, t);
        } else if (t->kind == TY_FUNC) {
            s = lookup(name);
            if (s && s->kind != S_FUNC) {
                error(88 /* redeclared */, name);
                s = 0;
            }
            if (!s)
                s = addsym(name, S_FUNC, t);
            else if (!s->defined && t->params)
                s->type = t;
            if (sc == K_STATIC && !s->isstatic) {
                s->isstatic = 1;
                s->lname = palloc(strlen(modname) + strlen(name) + 2);
                strcpy(s->lname, modname);
                strcat(s->lname, "'");
                strcat(s->lname, name);
            }
            if (tok == '{') {
                if (t != s->type)
                    s->type = t;
                funcdef(s, sc == K_STATIC);
                xrelease(m);
                return;
            }
        } else {
            s = lookup(name);
            if (s && (s->kind != S_GLOBAL || s->level != 0)) {
                error(88 /* redeclared */, name);
                s = 0;
            }
            if (!s) {
                s = addsym(name, S_GLOBAL, t);
                s->offset = -1;
                if (sc == K_STATIC) {
                    s->isstatic = 1;
                    if (t->size >= 0)
                        s->offset = allocglobal(t);
                }
            } else if (s->type->kind == TY_ARRAY && s->type->len < 0 && t->len >= 0)
                s->type = t;
            if (sc != K_EXTERN && !s->defined)
                s->defined = 1;             /* a tentative (common) definition */
            if (tok == '=') {
                next();
                if (t->kind == TY_ARRAY && t->len < 0 && tok == T_STR) {
                    t->len = toklen;
                    t->size = toklen;
                }
                if (s->defined == 2)
                    error(88 /* redeclared */, name);
                s->defined = 2;
                s->type = t;
                lv = mknode(N_VAR, t, 0, 0);
                lv->sym = s;
                if (s->isstatic && s->offset < 0) {
                    /* static array of unknown size: allocate after the initializer */
                    s->offset = globoff;
                    ir_initbegin();
                    initializer(lv, t, 1);
                    ir_initend();
                    globoff = s->offset;
                    s->offset = allocglobal(t);
                } else {
                    ir_initbegin();
                    initializer(lv, t, 1);
                    ir_initend();
                }
            } else if (s->isstatic && s->offset < 0 && t->size >= 0)
                s->offset = allocglobal(t);
        }
        if (tok != ',')
            break;
        next();
    }
    expect(';', ";");
    xrelease(m);
}

#pragma segment REFSCAN

/* Collect every identifier the program itself uses: everything in the
   main file, and whatever is inside braces (function bodies, structures,
   initialisers) in included files.  Top-level declarations in included
   files of names never mentioned are then not kept at all. */
static void addref(char *name)
{
    int a;
    int b;
    a = (hashstr(name) * 2 + 1) & 4095;
    b = refhash2(name);
    refbits[a >> 3] = refbits[a >> 3] | (1 << (a & 7));
    refbits[b >> 3] = refbits[b >> 3] | (1 << (b & 7));
}

static void scanrefs(char *src)
{
    FILE *fp;
    int c;
    int q;
    int n;
    int sys;
    int bol;
    int depth;
    char name[MAXNAME];
    fp = fopen(src, "r");
    if (!fp)
        fatal(25 /* cannot open */, src);
    refbits = (unsigned char *)palloc(RBITS / 8);
    sys = 0;
    bol = 1;
    depth = 0;
    c = getc(fp);
    while (c != EOF) {
        if (bol && c == '#') {
            /* "#<line> [!]file": '!' = system header */
            while (c != EOF && c != ' ' && c != '\n')
                c = getc(fp);
            if (c == ' ') {
                c = getc(fp);
                sys = c == '!';
            }
            while (c != EOF && c != '\n')
                c = getc(fp);
            continue;
        }
        if (c == '\n') {
            bol = 1;
            c = getc(fp);
            continue;
        }
        bol = 0;
        if (c == '{')
            depth++;
        else if (c == '}')
            depth--;
        if (c == '"' || c == '\'') {
            q = c;
            c = getc(fp);
            while (c != EOF && c != q && c != '\n') {
                if (c == '\\')
                    c = getc(fp);
                c = getc(fp);
            }
            c = getc(fp);
            continue;
        }
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_') {
            n = 0;
            while ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' || (c >= '0' && c <= '9')) {
                if (n < MAXNAME - 1)
                    name[n++] = c;
                c = getc(fp);
            }
            name[n] = 0;
            if (!sys || depth > 0)
                addref(name);
            continue;
        }
        if (c >= '0' && c <= '9') {
            while ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '.' || c == '_')
                c = getc(fp);
            continue;
        }
        c = getc(fp);
    }
    fclose(fp);
}

#pragma segment CINIT

/* declare the runtime helpers the code generator calls (defined in tcrt.h) */
static void declhelper(char *name, struct Type *ret, struct Type *a, struct Type *b)
{
    struct Type *ft;
    struct Param *p;
    struct Sym *s;
    ft = mktype(TY_FUNC, 2, 2);
    ft->base = ret;
    if (a) {
        p = (struct Param *)palloc(sizeof(struct Param));
        p->name = "a";
        p->type = a;
        ft->params = p;
        if (b) {
            p->next = (struct Param *)palloc(sizeof(struct Param));
            p->next->name = "b";
            p->next->type = b;
        }
    }
    s = addsym(name, S_FUNC, ft);
}

static void helpers(void)
{
    declhelper("__divi", ty_int, ty_int, ty_int);
    declhelper("__modi", ty_int, ty_int, ty_int);
    declhelper("__udiv", ty_uint, ty_uint, ty_uint);
    declhelper("__umod", ty_uint, ty_uint, ty_uint);
    declhelper("__shl", ty_int, ty_int, ty_int);
    declhelper("__shr", ty_int, ty_int, ty_int);
    declhelper("__ushr", ty_uint, ty_uint, ty_int);
    declhelper("__xor", ty_int, ty_int, ty_int);
    declhelper("__sx", ty_int, ty_int, 0);
    declhelper("__utof", ty_double, ty_uint, 0);
    declhelper("__ftou", ty_uint, ty_double, 0);
    declhelper("__ladd", ty_long, ty_long, ty_long);
    declhelper("__lsub", ty_long, ty_long, ty_long);
    declhelper("__lmul", ty_long, ty_long, ty_long);
    declhelper("__ldiv", ty_long, ty_long, ty_long);
    declhelper("__lmod", ty_long, ty_long, ty_long);
    declhelper("__uldiv", ty_ulong, ty_ulong, ty_ulong);
    declhelper("__ulmod", ty_ulong, ty_ulong, ty_ulong);
    declhelper("__land", ty_long, ty_long, ty_long);
    declhelper("__lor", ty_long, ty_long, ty_long);
    declhelper("__lxor", ty_long, ty_long, ty_long);
    declhelper("__lshl", ty_long, ty_long, ty_int);
    declhelper("__lshr", ty_long, ty_long, ty_int);
    declhelper("__ulshr", ty_ulong, ty_ulong, ty_int);
    declhelper("__lneg", ty_long, ty_long, 0);
    declhelper("__lnot", ty_long, ty_long, 0);
    declhelper("__lcmp", ty_int, ty_long, ty_long);
    declhelper("__ulcmp", ty_int, ty_ulong, ty_ulong);
    declhelper("__itol", ty_long, ty_int, 0);
    declhelper("__utol", ty_long, ty_uint, 0);
    declhelper("__ltoi", ty_int, ty_long, 0);
    declhelper("__ltof", ty_double, ty_long, 0);
    declhelper("__ultof", ty_double, ty_ulong, 0);
    declhelper("__ftol", ty_long, ty_double, 0);
    declhelper("__ftoul", ty_ulong, ty_double, 0);
}

#pragma segment PARSE

void pragma(char *s)
{
    char name[MAXNAME];
    int n;
    while (*s == ' ' || *s == '\t')
        s++;
    if (strncmp(s, "segment", 7) == 0) {
        s = s + 7;
        while (*s == ' ' || *s == '\t')
            s++;
        n = 0;
        while (*s && *s != ' ' && *s != '\t' && n < 8) {
            name[n] = *s >= 'a' && *s <= 'z' ? *s - 32 : *s;
            n++;
            s++;
        }
        name[n] = 0;
        if (strcmp(name, "MAIN") == 0)
            name[0] = 0;
        cursegname = pstrdup(name);
    } else if (strncmp(s, "nofltused", 9) == 0)
        nofltused = 1;              /* library modules: float use does not link %f */
}

int compile(char *src, char *ir, char *mod)
{
    FILE *fp;
    modname = mod;
    usesfloat = 0;
    nofltused = 0;
    fp = fopen(src, "r");
    if (!fp)
        fatal(25 /* cannot open */, src);
    ir_open(ir, modname);
    scanrefs(src);
    typeinit();
    helpers();
    cursegname = "";
    lexinit(fp);
    next();
    while (tok != T_EOF) {
        external();
    }
    ir_initflush();
    {
        /* the module's exported variables: name, size, initialised or common */
        struct Sym *g;
        int h;
        for (h = 0; h < HSIZE; h++)
            for (g = htab[h]; g; g = g->next)
                if (g->kind == S_GLOBAL && !g->isstatic && g->defined) {
                    if (g->type->size < 0)
                        error(73 /* incomplete type */, g->name);
                    ir_data(g->name, (g->type->size + 1) / 2, g->defined == 2);
                }
    }
    if (usesfloat && !nofltused)
        ir_use("__fltused");
    ir_close(globoff);
    fclose(fp);
    return nerrors == 0;
}
