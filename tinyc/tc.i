#1 /home/user/UCSD-C/tinyc/tc.c
  
#3 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/util.c
       
#8 !/home/user/UCSD-C/tinyc/util.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h







#1 !/home/user/UCSD-C/tinyc/include/stdio.h
               
#16 !/home/user/UCSD-C/tinyc/include/stdio.h



#1 !/home/user/UCSD-C/tinyc/include/stddef.h
 





typedef unsigned size_t;
typedef int ptrdiff_t;
typedef char wchar_t;


#19 !/home/user/UCSD-C/tinyc/include/stdio.h

#1 !/home/user/UCSD-C/tinyc/include/stdarg.h
    
#5 !/home/user/UCSD-C/tinyc/include/stdarg.h


typedef char *va_list;






#20 !/home/user/UCSD-C/tinyc/include/stdio.h


















typedef struct __file {
    int flags;
    int blk;                     
    int pos;                     
    int len;                     
    int ungot;                   
    int dle;                     
    int linestart;               
    int bufsize;                 
    unsigned char *buf;
    char *fib;                   
} FILE;

extern FILE __files[6 + 3];




int fflush(FILE *f);
int fputc(int c, FILE *f);
int fgetc(FILE *f);

 






 

 




 

FILE *fopen(char *name, char *mode);


int fgetc(FILE *f);

int fputc(int c, FILE *f);

int fflush(FILE *f);

int fclose(FILE *f);

int remove(char *name);

int feof(FILE *f);

int ferror(FILE *f);

void clearerr(FILE *f);

int ungetc(int c, FILE *f);

int fseek(FILE *f, long off, int whence);

long ftell(FILE *f);

void rewind(FILE *f);

size_t fread(void *p, size_t size, size_t n, FILE *f);

size_t fwrite(void *p, size_t size, size_t n, FILE *f);

int getc(FILE *f);

int putc(int c, FILE *f);

int getchar(void);

int putchar(int c);

char *fgets(char *s, int n, FILE *f);

char *gets(char *s);

int fputs(char *s, FILE *f);

int puts(char *s);

void perror(char *s);


 

 



 








int vfprintf(FILE *f, char *fmt, va_list ap);

int vsprintf(char *s, char *fmt, va_list ap);

int printf(char *fmt, ...);

int fprintf(FILE *f, char *fmt, ...);

int sprintf(char *s, char *fmt, ...);

 





int vfscanf(FILE *f, char *fmt, va_list ap);

int scanf(char *fmt, ...);

int fscanf(FILE *f, char *fmt, ...);

int sscanf(char *s, char *fmt, ...);

 



#15 !/home/user/UCSD-C/tinyc/tc.h

#1 !/home/user/UCSD-C/tinyc/include/stdlib.h
    
#5 !/home/user/UCSD-C/tinyc/include/stdlib.h



#1 !/home/user/UCSD-C/tinyc/include/stddef.h
 










#8 !/home/user/UCSD-C/tinyc/include/stdlib.h





typedef struct { int quot; int rem; } div_t;
typedef struct { long quot; long rem; } ldiv_t;

 

void *malloc(size_t n);

void free(void *v);

void *calloc(size_t n, size_t size);

void *realloc(void *v, size_t n);

int abs(int x);

long labs(long x);

div_t div(int a, int b);


int rand(void);

void srand(unsigned seed);

long strtol(char *s, char **end, int base);

unsigned long strtoul(char *s, char **end, int base);

int atoi(char *s);

long atol(char *s);

double strtod(char *s, char **end);

double atof(char *s);

char *getenv(char *name);


void qsort(void *base, size_t n, size_t size, int (*cmp)(void *, void *));

void *bsearch(void *key, void *base, size_t n, size_t size, int (*cmp)(void *, void *));

 

void __heapsave(void);

void __heaprestore(void);


void exit(int status);

void abort(void);


#16 !/home/user/UCSD-C/tinyc/tc.h

#1 !/home/user/UCSD-C/tinyc/include/string.h
 



#1 !/home/user/UCSD-C/tinyc/include/stddef.h
 










#5 !/home/user/UCSD-C/tinyc/include/string.h

size_t strlen(char *s);

char *strcpy(char *d, char *s);

char *strncpy(char *d, char *s, size_t n);

char *strcat(char *d, char *s);

char *strncat(char *d, char *s, size_t n);

int strcmp(char *a, char *b);

int strncmp(char *a, char *b, size_t n);

char *strchr(char *s, int c);

char *strrchr(char *s, int c);

char *strstr(char *s, char *t);

void *memcpy(void *d, void *s, size_t n);

void *memmove(void *d, void *s, size_t n);

void *memset(void *d, int c, size_t n);

int memcmp(void *a, void *b, size_t n);

void *memchr(void *s, int c, size_t n);

size_t strspn(char *s, char *set);

size_t strcspn(char *s, char *set);

char *strpbrk(char *s, char *set);

extern char *__strtok;

char *strtok(char *s, char *delim);


char *strdup(char *s);


#17 !/home/user/UCSD-C/tinyc/tc.h



 












 




























 



































 
















struct Field {
    char *name;
    struct Type *type;
    int offset;              
    struct Field *next;
};

struct Param {
    char *name;
    struct Type *type;
    struct Param *next;
};

struct Type {
    int kind;
    int size;                
    int align;
    struct Type *base;       
    int len;                 
    struct Field *fields;    
    struct Param *params;    
    int variadic;
    int oldstyle;            
    char *tag;
    struct Type *ptrto;      
};

 








struct Sym {
    char *name;
    int kind;
    struct Type *type;
    int offset;              
    int level;               
    int isstatic;
    int defined;             
    char *lname;             
    struct Sym *next;        
    struct Sym *scopenext;   
};

 











































struct Node {
    int op;
    struct Type *type;
    struct Node *a;
    struct Node *b;
    struct Node *c;
    struct Node *next;       
    struct Sym *sym;
    int val;
    int val2;
    char *str;
    int slen;
    unsigned char *fimg;
};

 
extern int nerrors;
extern char *curfile;
extern int curline;

 
void error(int n, char *arg);
void fatal(int n, char *arg);
void memfail(int n);
void warn(int n, char *arg);
char *palloc(int n);             
char *falloc(int n);             
char *xalloc(int n);             
void freset(void);
int xmark(void);
void xrelease(int m);
char *pstrdup(char *s);
void resetpools(void);
void xsetsize(int n);
int hashstr(char *s);

 
extern int tok;
extern int insys;
extern int tokval;
extern int tokval2;
extern int toklong;
extern char tokname[64];
extern char *tokstr;
extern int toklen;
extern unsigned char tokreal[4];
void lexinit(FILE *fp);
void next(void);
int peek(void);
char *peekname(void);

 
extern struct Type *ty_void;
extern struct Type *ty_char;
extern struct Type *ty_uchar;
extern struct Type *ty_int;
extern struct Type *ty_uint;
extern struct Type *ty_long;
extern struct Type *ty_ulong;
extern struct Type *ty_float;
extern struct Type *ty_double;
extern struct Type *ty_ldouble;
struct Type *ptrto(struct Type *t);
int isintegral(struct Type *t);
int isfloatty(struct Type *t);
int islongty(struct Type *t);
int isunsignedty(struct Type *t);
int isword(struct Type *t);
int isptrlike(struct Type *t);
int isscalar(struct Type *t);
int isaggregate(struct Type *t);
int twords(struct Type *t);
int retwords(struct Type *ft);

 


extern int curlocal;
extern int maxlocal;
extern int nparamwords;
extern int scratch;
extern char *cursegname;
extern FILE *objout;
int newlabel(void);
void setlabel(int l);
void jump(int l);
void branch(struct Node *n, int l, int jumpif);
void gen_value(struct Node *n);
void gen_discard(struct Node *n);
void gen_return(struct Node *n, struct Type *ft, int sretoff);
int newtemp(int words);
void gen_funcbegin(void);
void gen_funcend(char *name, struct Type *ft, int exitlabel, int isstatic, char *seg);
void gen_initbegin(void);
void gen_initend(void);
void gen_initflush(void);
void gen_switch(int tempoff, int *vals, int *labs, int n, int deflab);
void gen_stl(int off);
void gen_objheader(char *modname);
void gen_objend(int globalwords);

 
void ir_open(char *name, char *modname);
void ir_close(int globalwords);
void ir_funcbegin(void);
int ir_newlabel(void);
void ir_setlabel(int l);
void ir_jump(int l);
void ir_branch(struct Node *n, int l, int jumpif);
void ir_discard(struct Node *n);
void ir_valuestl(struct Node *n, int t);
void ir_return(struct Node *n, struct Type *ft, int sretoff);
void ir_switch(int t, int *vals, int *labs, int n, int deflab);
void ir_funcend(char *name, struct Type *ft, int exitlab, int isstatic, char *seg);
void ir_initbegin(void);
void ir_initend(void);
void ir_initflush(void);
int gencode(char *ir, char *obj);
void ir_data(char *name, int words, int strong);
void gen_objdata(char *name, int words, int strong);
void ir_use(char *name);
void gen_objuse(char *name);

 
int preprocess(char *src, char *out);
int compile(char *src, char *obj, char *modname);
int link(char **objs, int nobjs, char *code, char *progname);


#9 !/home/user/UCSD-C/tinyc/util.c
#pragma segment MAIN

int nerrors;
int curlocal;                    
int maxlocal;
int nparamwords;
int scratch;
char *cursegname;
FILE *objout;
char *curfile;
int curline;

   
#24 !/home/user/UCSD-C/tinyc/util.c
static void message(int n)
{
    FILE *fp;
    int c;
    int line;
    char path[200];
    char *dir;
    fp = 0;

    if (n != 2) {                    
        fp = fopen("TCMSGS.TEXT", "r");
        if (!fp)
            fp = fopen("*TCMSGS.TEXT", "r");
    }








    if (!fp) {
        printf(n == 2 ? "out of memory" : "message #%d", n);
        return;
    }
    line = 1;
    while (line < n && (c = getc(fp)) != (-1))
        if (c == '\n')
            line++;
    while ((c = getc(fp)) != (-1) && c != '\n')
        putchar(c);
    fclose(fp);
}

static void report(char *kind, int n, char *arg)
{
    if (curfile)
        printf("%s:%d: ", curfile, curline);
    printf("%s", kind);
    message(n);
    if (arg)
        printf(" '%s'", arg);
    printf("\n");
}

void error(int n, char *arg)
{
    report("error: ", n, arg);
    nerrors++;
    if (nerrors >= 20)
        fatal(1  , 0);
}

void warn(int n, char *arg)
{
    report("warning: ", n, arg);
}

void memfail(int n)
{

    printf("(asked for %d bytes, %d words free)\n", n, __cspi(40));

    fatal(2  , 0);
}

void fatal(int n, char *arg)
{
    report("fatal: ", n, arg);
    exit(2);
}


static char *pcur;
static int pleft;

char *palloc(int n)
{
    char *p;
    n = (n + 1) & ~1;
    if (n > pleft) {
        if (n > 1024 / 2) {
            p = (char *)malloc(n);
            if (!p)
                memfail(n);
            memset(p, 0, n);
            return p;
        }
        pcur = (char *)malloc(1024);
        if (!pcur)
            memfail(1024);
        pleft = 1024;
    }
    p = pcur;
    pcur += n;
    pleft -= n;
    memset(p, 0, n);
    return p;
}

 
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
            sz = n > 1024 ? n : 1024;
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

static char *xbuf;
static int xused;
static int xsize;

  
#177 !/home/user/UCSD-C/tinyc/util.c
void xsetsize(int n)
{

    xsize = n;



}

char *xalloc(int n)
{
    char *p;
    if (!xbuf) {
        if (xsize == 0)
            xsetsize(3000);
        xbuf = (char *)malloc(xsize);
        if (!xbuf)
            memfail(xsize);
    }
    n = (n + 1) & ~1;
    if (xused + n > xsize)
        fatal(3  , 0);
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

 
void resetpools(void)
{
    pcur = 0;
    pleft = 0;
    ffirst = 0;
    fchunk = 0;
    fused = 0;
    xbuf = 0;
    xused = 0;
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
#4 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/types.c
  
#3 !/home/user/UCSD-C/tinyc/types.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#4 !/home/user/UCSD-C/tinyc/types.c
#pragma segment MAIN

int isintegral(struct Type *t)
{
    return t->kind >= 1 && t->kind <= 6;
}

int isfloatty(struct Type *t)
{
    return t->kind >= 7 && t->kind <= 9;
}

int islongty(struct Type *t)
{
    return t->kind == 5 || t->kind == 6;
}

int isunsignedty(struct Type *t)
{
    return t->kind == 2 || t->kind == 4 || t->kind == 6;
}

int isword(struct Type *t)
{
    return (t->kind >= 1 && t->kind <= 4) || t->kind == 10;
}

int isptrlike(struct Type *t)
{
    return t->kind == 10;
}

int isscalar(struct Type *t)
{
    return isintegral(t) || isfloatty(t) || t->kind == 10;
}

int isaggregate(struct Type *t)
{
    return t->kind == 12 || t->kind == 13 || t->kind == 11;
}

int twords(struct Type *t)
{
    if (t->kind == 1 || t->kind == 2)
        return 1;
    return (t->size + 1) / 2;
}

int retwords(struct Type *ft)
{
    struct Type *r;
    r = ft->base;
    if (r->kind == 0)
        return 0;
    if (r->kind == 12 || r->kind == 13)
        return 1;
    return twords(r);
}

#5 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/pp.c
           
#12 !/home/user/UCSD-C/tinyc/pp.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#13 !/home/user/UCSD-C/tinyc/pp.c
#pragma segment PP

struct Macro {
    char *name;
    int nparams;             
    char *body;              
    struct Macro *next;
};


static struct Macro **mtab;

struct Incl {
    FILE *fp;
    char *name;
    int line;
    int sys;                     
};
static struct Incl *istack;
static int idepth;
static FILE *ppout;
static int incomment;
static int ifstate[32];       
static int ifparent[32];
static int iflevel;
static int active;
static struct Macro *expanding[32];
static int nexpanding;
static int outline;              
static char *outfile;
static char *incdir;
static char openedpath[200];

static char *line;               
static char *ebuf;

static int isid1(int c)
{
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

static int isidc(int c)
{
    return isid1(c) || (c >= '0' && c <= '9');
}

static struct Macro *mlookup(char *name, int n)
{
    struct Macro *m;
    int h;
    int i;
    h = 0;
    for (i = 0; i < n; i++)
        h = (h * 3 + name[i]) & 1023;
    for (m = mtab[h & (128 - 1)]; m; m = m->next)
        if ((int)strlen(m->name) == n && strncmp(m->name, name, n) == 0)
            return m;
    return 0;
}

static void mundef(char *name, int n)
{
    struct Macro *m;
    struct Macro **pp;
    int h;
    int i;
    h = 0;
    for (i = 0; i < n; i++)
        h = (h * 3 + name[i]) & 1023;
    pp = &mtab[h & (128 - 1)];
    for (m = *pp; m; m = m->next) {
        if ((int)strlen(m->name) == n && strncmp(m->name, name, n) == 0) {
            *pp = m->next;
            return;
        }
        pp = &m->next;
    }
}

static struct Macro *mdefine(char *name, int n, int nparams, char *body)
{
    struct Macro *m;
    int h;
    int i;
    mundef(name, n);
    m = (struct Macro *)palloc(sizeof(struct Macro));
    m->name = palloc(n + 1);
    memcpy(m->name, name, n);
    m->name[n] = 0;
    m->nparams = nparams;
    m->body = pstrdup(body);
    h = 0;
    for (i = 0; i < n; i++)
        h = (h * 3 + name[i]) & 1023;
    m->next = mtab[h & (128 - 1)];
    mtab[h & (128 - 1)] = m;
    return m;
}

 
static char *skiplit(char *s)
{
    int q;
    q = *s++;
    while (*s && *s != q) {
        if (*s == '\\' && s[1])
            s++;
        s++;
    }
    if (*s)
        s++;
    return s;
}

 

static FILE *openinc(char *name, int sys)
{
    FILE *fp;
    char path[200];
    char *p;

      
#137 !/home/user/UCSD-C/tinyc/pp.c
    int i;
    for (i = 0; name[i] && i < 64; i++) {
        path[i] = name[i];
        if (path[i] >= 'a' && path[i] <= 'z')
            path[i] = path[i] - 32;
    }
    path[i] = 0;
    strcat(path, ".TEXT");
    fp = fopen(path, "r");
    if (!fp && sys) {
        for (i = strlen(path); i >= 0; i--)
            path[i + 1] = path[i];
        path[0] = '*';
        fp = fopen(path, "r");
    }
    strcpy(openedpath, path);
    p = 0;
    return fp;

































}

static char *outname;             
static int startline;            
static char pragbuf[512];
static int crtdone;

 
static int rawline(char *buf, int max)
{
    int c;
    int n;
    FILE *fp;
    fp = istack[idepth - 1].fp;
    n = 0;
    c = getc(fp);
    if (c == (-1))
        return 0;
    while (c != (-1) && c != '\n') {
        if (c != '\r' && n < max - 1)
            buf[n++] = c;
        c = getc(fp);
    }
    buf[n] = 0;
    istack[idepth - 1].line++;
    return 1;
}

 
static void uncomment(char *buf)
{
    char *s;
    char *d;
    char *e;
    s = buf;
    d = buf;
    while (*s) {
        if (incomment) {
            if (s[0] == '*' && s[1] == '/') {
                incomment = 0;
                s += 2;
                *d++ = ' ';
            } else
                s++;
        } else if (*s == '"' || *s == '\'') {
            e = skiplit(s);
            while (s < e)
                *d++ = *s++;
        } else if (s[0] == '/' && s[1] == '*') {
            incomment = 1;
            s += 2;
        } else if (s[0] == '/' && s[1] == '/') {
            break;
        } else
            *d++ = *s++;
    }
    *d = 0;
}

 
static int balance(char *s)
{
    int b;
    b = 0;
    while (*s) {
        if (*s == '"' || *s == '\'') {
            s = skiplit(s);
            continue;
        }
        if (*s == '(')
            b++;
        else if (*s == ')')
            b--;
        s++;
    }
    return b;
}

  
#268 !/home/user/UCSD-C/tinyc/pp.c
static int ppgetline(void)
{
    char tmp[512];
    int n;
    int joined;
    char *s;
    joined = 0;
    if (!rawline(line, 512))
        return 0;
    startline = istack[idepth - 1].line;
    n = strlen(line);
    while (n > 0 && line[n - 1] == '\\') {
        line[n - 1] = 0;
        if (!rawline(tmp, 512))
            break;
        if (n + (int)strlen(tmp) >= 1024 - 2)
            fatal(4  , 0);
        strcat(line, tmp);
        n = strlen(line);
        joined = 1;
    }
    uncomment(line);
    s = line;
    while (*s == ' ' || *s == '\t')
        s++;
    if (*s != '#' && active) {
        while (balance(line) > 0 || incomment) {
            if (!rawline(tmp, 512))
                break;
            uncomment(tmp);
            n = strlen(line);
            if (n + (int)strlen(tmp) >= 1024 - 2)
                fatal(4  , 0);
            line[n] = ' ';
            strcpy(line + n + 1, tmp);
            joined = 1;
        }
    }
    return joined ? 2 : 1;
}

 

static char *outp;
static char *outend;

static void put(char *s, int n)
{
    if (outp + n >= outend)
        fatal(5  , 0);
    memcpy(outp, s, n);
    outp += n;
}

static int isexpanding(struct Macro *m)
{
    int i;
    for (i = 0; i < nexpanding; i++)
        if (expanding[i] == m)
            return 1;
    return 0;
}

static void expand(char *s);

 
static char *expandcopy(char *s, int n)
{
    char *save;
    char *saveend;
    char *buf;
    char *src;
    int len;
    int xm;
    src = xalloc(n + 1);
    memcpy(src, s, n);
    src[n] = 0;
    buf = xalloc(1024);
    save = outp;
    xm = xmark();
    saveend = outend;
    outp = buf;
    outend = buf + 1024;
    expand(src);
    *outp = 0;
    len = outp - buf;
    outp = save;
    outend = saveend;
    buf[len] = 0;
    return buf;
}

 
static void stringify(char *s, int n)
{
    char c;
    int i;
    int inlit;
    put("\"", 1);
    inlit = 0;
    for (i = 0; i < n; i++) {
        c = s[i];
        if (c == '"' || (c == '\\' && inlit))
            put("\\", 1);
        if (c == '"' || c == '\'')
            inlit = !inlit;
        put(&c, 1);
    }
    put("\"", 1);
}

static char *trim(char *s, int *n)
{
    while (*n > 0 && (*s == ' ' || *s == '\t')) {
        s++;
        (*n)--;
    }
    while (*n > 0 && (s[*n - 1] == ' ' || s[*n - 1] == '\t'))
        (*n)--;
    return s;
}

 
static char *expandcall(struct Macro *m, char *p)
{
    char *args[32];
    int alen[32];
    char *aexp[32];
    int nargs;
    int depth;
    char *q;
    char *body;
    char *start;
    char *rstart;
    char *res;
    char *saveout;
    char *saveend;
    char *b;
    int idx;
    int n;
    int paste;
    int xm;
    q = p;
    while (*q == ' ' || *q == '\t')
        q++;
    if (*q != '(')
        return 0;
    q++;
    nargs = 0;
    depth = 0;
    start = q;
    for (;;) {
        if (*q == 0)
            fatal(6  , m->name);
        if (*q == '"' || *q == '\'') {
            q = skiplit(q);
            continue;
        }
        if (*q == '(')
            depth++;
        else if ((*q == ',' || *q == ')') && depth == 0) {
            if (nargs >= 32)
                fatal(7  , m->name);
            n = q - start;
            args[nargs] = trim(start, &n);
            alen[nargs] = n;
            aexp[nargs] = 0;
            nargs++;
            if (*q == ')') {
                q++;
                break;
            }
            start = q + 1;
        } else if (*q == ')')
            depth--;
        q++;
    }
    if (nargs == 1 && alen[0] == 0 && m->nparams == 0)
        nargs = 0;
    if (nargs != m->nparams)
        error(8  , m->name);
     
    xm = xmark();
    res = xalloc(1024);
    saveout = outp;
    saveend = outend;
    outp = res;
    outend = res + 1024;
    for (b = m->body; *b; ) {
        if (*b == '#' && b[1] == '#') {
             
            while (outp > res && (outp[-1] == ' ' || outp[-1] == '\t'))
                outp--;
            b += 2;
            while (*b == ' ' || *b == '\t')
                b++;
            if (*b == 1) {
                idx = b[1] - 1;
                if (idx < nargs)
                    put(args[idx], alen[idx]);
                b += 2;
            }
            continue;
        }
        if (*b == '#' && b[1] != '#') {
            char *t;
            t = b + 1;
            while (*t == ' ')
                t++;
            if (*t == 1) {
                idx = t[1] - 1;
                if (idx < nargs)
                    stringify(args[idx], alen[idx]);
                b = t + 2;
                continue;
            }
        }
        if (*b == 1) {
            idx = b[1] - 1;
            b += 2;
             
            paste = 0;
            {
                char *t;
                t = b;
                while (*t == ' ' || *t == '\t')
                    t++;
                if (t[0] == '#' && t[1] == '#')
                    paste = 1;
            }
            if (idx < nargs) {
                if (paste)
                    put(args[idx], alen[idx]);
                else {
                    if (!aexp[idx])
                        aexp[idx] = expandcopy(args[idx], alen[idx]);
                    put(aexp[idx], strlen(aexp[idx]));
                }
            }
            continue;
        }
        if (*b == '"' || *b == '\'') {
            char *e;
            e = skiplit(b);
            put(b, e - b);
            b = e;
            continue;
        }
        put(b, 1);
        b++;
    }
    *outp = 0;
    outp = saveout;
    outend = saveend;
    expanding[nexpanding++] = m;
    expand(res);
    nexpanding--;
    xrelease(xm);
    return q;
}

static void expand(char *s)
{
    char *p;
    char *e;
    struct Macro *m;
    char num[8];
    while (*s) {
        if (*s == '"' || *s == '\'') {
            e = skiplit(s);
            put(s, e - s);
            s = e;
        } else if (isid1(*s)) {
            p = s;
            while (isidc(*p))
                p++;
            m = mlookup(s, p - s);
            if (m && !isexpanding(m)) {
                if (m->nparams < 0) {
                    if (nexpanding >= 30)
                        fatal(9  , m->name);
                    expanding[nexpanding++] = m;
                    expand(m->body);
                    nexpanding--;
                    s = p;
                    continue;
                }
                e = expandcall(m, p);
                if (e) {
                    s = e;
                    continue;
                }
            }
            if (p - s == 8 && strncmp(s, "__LINE__", 8) == 0) {
                sprintf(num, "%d", istack[idepth - 1].line);
                put(num, strlen(num));
            } else if (p - s == 8 && strncmp(s, "__FILE__", 8) == 0) {
                put("\"", 1);
                put(istack[idepth - 1].name, strlen(istack[idepth - 1].name));
                put("\"", 1);
            } else
                put(s, p - s);
            s = p;
        } else if (*s >= '0' && *s <= '9') {
            p = s;
            while (isidc(*p) || *p == '.' || ((*p == '+' || *p == '-') && (p[-1] == 'e' || p[-1] == 'E')))
                p++;
            put(s, p - s);
            s = p;
        } else {
            put(s, 1);
            s++;
        }
    }
}

 

static char *ep;

static void eskip(void)
{
    while (*ep == ' ' || *ep == '\t')
        ep++;
}

static int ecomma(void);

static int eprimary(void)
{
    int v;
    int base;
    int d;
    eskip();
    if (*ep == '(') {
        ep++;
        v = ecomma();
        eskip();
        if (*ep == ')')
            ep++;
        return v;
    }
    if (*ep == '!') {
        ep++;
        return !eprimary();
    }
    if (*ep == '~') {
        ep++;
        return ~eprimary();
    }
    if (*ep == '-') {
        ep++;
        return -eprimary();
    }
    if (*ep == '+') {
        ep++;
        return eprimary();
    }
    if (*ep == '\'') {
        ep++;
        v = *ep++;
        if (v == '\\') {
            v = *ep++;
            if (v == 'n')
                v = 10;
            else if (v == 't')
                v = 9;
            else if (v == '0')
                v = 0;
        }
        if (*ep == '\'')
            ep++;
        return v;
    }
    if (*ep >= '0' && *ep <= '9') {
        v = 0;
        base = 10;
        if (*ep == '0') {
            base = 8;
            ep++;
            if (*ep == 'x' || *ep == 'X') {
                base = 16;
                ep++;
            }
        }
        for (;;) {
            if (*ep >= '0' && *ep <= '9')
                d = *ep - '0';
            else if (*ep >= 'a' && *ep <= 'f')
                d = *ep - 'a' + 10;
            else if (*ep >= 'A' && *ep <= 'F')
                d = *ep - 'A' + 10;
            else
                break;
            if (d >= base)
                break;
            v = ((((v * base + d) & 65535) ^ 32768) - 32768);
            ep++;
        }
        while (*ep == 'u' || *ep == 'U' || *ep == 'l' || *ep == 'L')
            ep++;
        return v;
    }
    if (isid1(*ep)) {            
        while (isidc(*ep))
            ep++;
        return 0;
    }
    error(10  , 0);
    return 0;
}

static int emul(void)
{
    int v;
    int r;
    v = eprimary();
    for (;;) {
        eskip();
        if (*ep == '*') {
            ep++;
            v = ((((v * eprimary()) & 65535) ^ 32768) - 32768);
        } else if (*ep == '/' || *ep == '%') {
            int op;
            op = *ep++;
            r = eprimary();
            if (r == 0)
                error(11  , 0);
            else if (op == '/')
                v = v / r;
            else
                v = v % r;
        } else
            return v;
    }
}

static int eadd(void)
{
    int v;
    v = emul();
    for (;;) {
        eskip();
        if (*ep == '+') {
            ep++;
            v = ((((v + emul()) & 65535) ^ 32768) - 32768);
        } else if (*ep == '-') {
            ep++;
            v = ((((v - emul()) & 65535) ^ 32768) - 32768);
        } else
            return v;
    }
}

static int eshift(void)
{
    int v;
    v = eadd();
    for (;;) {
        eskip();
        if (ep[0] == '<' && ep[1] == '<') {
            ep += 2;
            v = ((((v << eadd()) & 65535) ^ 32768) - 32768);
        } else if (ep[0] == '>' && ep[1] == '>') {
            ep += 2;
            v = v >> eadd();
        } else
            return v;
    }
}

static int erel(void)
{
    int v;
    v = eshift();
    for (;;) {
        eskip();
        if (ep[0] == '<' && ep[1] == '=') {
            ep += 2;
            v = v <= eshift();
        } else if (ep[0] == '>' && ep[1] == '=') {
            ep += 2;
            v = v >= eshift();
        } else if (ep[0] == '<') {
            ep++;
            v = v < eshift();
        } else if (ep[0] == '>') {
            ep++;
            v = v > eshift();
        } else
            return v;
    }
}

static int eeq(void)
{
    int v;
    v = erel();
    for (;;) {
        eskip();
        if (ep[0] == '=' && ep[1] == '=') {
            ep += 2;
            v = v == erel();
        } else if (ep[0] == '!' && ep[1] == '=') {
            ep += 2;
            v = v != erel();
        } else
            return v;
    }
}

static int eband(void)
{
    int v;
    v = eeq();
    for (;;) {
        eskip();
        if (ep[0] == '&' && ep[1] != '&') {
            ep++;
            v = v & eeq();
        } else
            return v;
    }
}

static int exor(void)
{
    int v;
    v = eband();
    for (;;) {
        eskip();
        if (ep[0] == '^') {
            ep++;
            v = v ^ eband();
        } else
            return v;
    }
}

static int ebor(void)
{
    int v;
    v = exor();
    for (;;) {
        eskip();
        if (ep[0] == '|' && ep[1] != '|') {
            ep++;
            v = v | exor();
        } else
            return v;
    }
}

static int eland(void)
{
    int v;
    int r;
    v = ebor();
    for (;;) {
        eskip();
        if (ep[0] == '&' && ep[1] == '&') {
            ep += 2;
            r = ebor();
            v = v && r;
        } else
            return v;
    }
}

static int elor(void)
{
    int v;
    int r;
    v = eland();
    for (;;) {
        eskip();
        if (ep[0] == '|' && ep[1] == '|') {
            ep += 2;
            r = eland();
            v = v || r;
        } else
            return v;
    }
}

static int econd(void)
{
    int v;
    int a;
    int b;
    v = elor();
    eskip();
    if (*ep == '?') {
        ep++;
        a = ecomma();
        eskip();
        if (*ep == ':')
            ep++;
        b = econd();
        return v ? a : b;
    }
    return v;
}

static int ecomma(void)
{
    return econd();
}

 
static int ifexpr(char *s)
{
    char *buf;
    char *d;
    char *p;
    int paren;
    int v;
    buf = xalloc(1024);
    d = buf;
    while (*s) {
        if (isid1(*s)) {
            p = s;
            while (isidc(*p))
                p++;
            if (p - s == 7 && strncmp(s, "defined", 7) == 0) {
                s = p;
                while (*s == ' ')
                    s++;
                paren = 0;
                if (*s == '(') {
                    paren = 1;
                    s++;
                }
                while (*s == ' ')
                    s++;
                p = s;
                while (isidc(*p))
                    p++;
                *d++ = mlookup(s, p - s) ? '1' : '0';
                s = p;
                while (*s == ' ')
                    s++;
                if (paren && *s == ')')
                    s++;
                continue;
            }
            while (s < p)
                *d++ = *s++;
            continue;
        }
        *d++ = *s++;
    }
    *d = 0;
    outp = ebuf;
    outend = ebuf + 1024;
    expand(buf);
    *outp = 0;
    ep = ebuf;
    v = ecomma();
    return v;
}

 

static char *word(char *s, char *w, int max)
{
    int n;
    while (*s == ' ' || *s == '\t')
        s++;
    n = 0;
    while (isidc(*s)) {
        if (n < max - 1)
            w[n++] = *s;
        s++;
    }
    w[n] = 0;
    return s;
}

static void dodefine(char *s)
{
    char name[64];
    char pnames[32][64];
    int np;
    int i;
    int n;
    char *body;
    char *d;
    char *p;
    s = word(s, name, 64);
    if (!name[0]) {
        error(12  , 0);
        return;
    }
    np = -1;
    if (*s == '(') {
        np = 0;
        s++;
        for (;;) {
            while (*s == ' ' || *s == '\t')
                s++;
            if (*s == ')') {
                s++;
                break;
            }
            if (np >= 32)
                fatal(13  , name);
            s = word(s, pnames[np], 64);
            np++;
            while (*s == ' ' || *s == '\t')
                s++;
            if (*s == ',')
                s++;
            else if (*s == ')') {
                s++;
                break;
            } else {
                error(14  , name);
                return;
            }
        }
    }
    while (*s == ' ' || *s == '\t')
        s++;
    body = xalloc(1024);
    d = body;
    while (*s) {
        if (*s == '"' || *s == '\'') {
            p = skiplit(s);
            while (s < p)
                *d++ = *s++;
            continue;
        }
        if (isid1(*s)) {
            p = s;
            while (isidc(*p))
                p++;
            n = p - s;
            for (i = 0; i < np; i++)
                if ((int)strlen(pnames[i]) == n && strncmp(pnames[i], s, n) == 0)
                    break;
            if (i < np) {
                *d++ = 1;
                *d++ = i + 1;
            } else
                while (s < p)
                    *d++ = *s++;
            s = p;
            continue;
        }
        *d++ = *s++;
    }
    while (d > body && (d[-1] == ' ' || d[-1] == '\t'))
        d--;
    *d = 0;
    mdefine(name, strlen(name), np, body);
}

static void doinclude(char *s)
{
    char name[64];
    int n;
    int sys;
    int close;
    FILE *fp;
    while (*s == ' ' || *s == '\t')
        s++;
    if (*s != '"' && *s != '<') {
        outp = ebuf;
        outend = ebuf + 1024;
        expand(s);
        *outp = 0;
        s = ebuf;
        while (*s == ' ')
            s++;
    }
    sys = *s == '<';
    close = sys ? '>' : '"';
    if (*s != '"' && *s != '<') {
        error(15  , 0);
        return;
    }
    s++;
    n = 0;
    while (*s && *s != close && n < 64 - 1)
        name[n++] = *s++;
    name[n] = 0;
    if (idepth >= 8)
        fatal(16  , name);
    fp = openinc(name, sys);
    if (!fp) {
        error(17  , name);
        return;
    }
    istack[idepth].fp = fp;
    istack[idepth].name = pstrdup(openedpath);
    istack[idepth].line = 0;
    istack[idepth].sys = sys || istack[idepth - 1].sys;
    idepth++;
}

static void ppdirective(char *s)
{
    char w[16];
    int v;
    s++;                             
    s = word(s, w, 16);
    if (strcmp(w, "ifdef") == 0 || strcmp(w, "ifndef") == 0 || strcmp(w, "if") == 0) {
        char name[64];
        if (iflevel >= 32)
            fatal(18  , 0);
        ifparent[iflevel] = active;
        if (!active)
            v = 0;
        else if (w[2] == 'd') {
            word(s, name, 64);
            v = mlookup(name, strlen(name)) != 0;
        } else if (w[2] == 'n') {
            word(s, name, 64);
            v = mlookup(name, strlen(name)) == 0;
        } else
            v = ifexpr(s) != 0;
        ifstate[iflevel] = v ? 1 : 0;
        iflevel++;
        active = active && v;
        return;
    }
    if (strcmp(w, "elif") == 0) {
        if (iflevel == 0) {
            error(19  , 0);
            return;
        }
        if (ifstate[iflevel - 1] != 0 || !ifparent[iflevel - 1]) {
            ifstate[iflevel - 1] = 2;
            active = 0;
        } else {
            v = ifexpr(s) != 0;
            ifstate[iflevel - 1] = v ? 1 : 0;
            active = v;
        }
        return;
    }
    if (strcmp(w, "else") == 0) {
        if (iflevel == 0) {
            error(20  , 0);
            return;
        }
        if (ifstate[iflevel - 1] == 0 && ifparent[iflevel - 1]) {
            ifstate[iflevel - 1] = 1;
            active = 1;
        } else {
            ifstate[iflevel - 1] = 2;
            active = 0;
        }
        return;
    }
    if (strcmp(w, "endif") == 0) {
        if (iflevel == 0) {
            error(21  , 0);
            return;
        }
        iflevel--;
        active = ifparent[iflevel];
        return;
    }
    if (!active)
        return;
    if (strcmp(w, "define") == 0)
        dodefine(s);
    else if (strcmp(w, "undef") == 0) {
        char name[64];
        word(s, name, 64);
        mundef(name, strlen(name));
    } else if (strcmp(w, "include") == 0)
        doinclude(s);
    else if (strcmp(w, "error") == 0)
        error(22  , s);
    else if (strcmp(w, "pragma") == 0) {
        strcpy(pragbuf, "#pragma");
        strcat(pragbuf, s);
    }
    else if (strcmp(w, "line") == 0 || w[0] == 0)
        ;
    else
        error(23  , w);
}

int preprocess(char *src, char *out)
{
    int r;
    int m;
    char *s;
    line = malloc(1024);
    ebuf = malloc(1024);
    mtab = (struct Macro **)calloc(128, sizeof(struct Macro *));
    istack = (struct Incl *)calloc(8, sizeof(struct Incl));
    if (!line || !ebuf || !mtab || !istack)
        fatal(2  , 0);
    ppout = fopen(out, "w");
    if (!ppout)
        fatal(24  , out);
    incdir = getenv("TINYC_INCLUDE");
    mdefine("__TINYC__", 9, -1, "1");
    mdefine("__UCSD__", 8, -1, "1");
    istack[0].fp = fopen(src, "r");
    if (!istack[0].fp)
        fatal(25  , src);
    istack[0].name = pstrdup(src);
    istack[0].line = 0;
    istack[0].sys = 0;
    idepth = 1;
    active = 1;
    iflevel = 0;
    outline = 0;
    outname = 0;
    for (;;) {
        m = xmark();
        r = ppgetline();
        if (r == 0) {
            fclose(istack[idepth - 1].fp);
            idepth--;
            xrelease(m);
            if (idepth == 0)
                break;
            continue;
        }
        curfile = istack[idepth - 1].name;
        curline = startline;
        if (outline != startline || outname != curfile) {
             
            fprintf(ppout, "#%d %s%s\n", startline, idepth > 1 ? "!" : "", curfile);
            outname = curfile;
        }
        outline = startline + 1;
        s = line;
        while (*s == ' ' || *s == '\t')
            s++;
        if (*s == '#') {
            pragbuf[0] = 0;
            ppdirective(s);
            fputs(pragbuf, ppout);
        } else if (active) {
            outp = ebuf;
            outend = ebuf + 1024;
            nexpanding = 0;
            expand(line);
            *outp = 0;
            fputs(ebuf, ppout);
        }
        fputc('\n', ppout);
        xrelease(m);
    }
    if (iflevel)
        error(26  , 0);
    fclose(ppout);
    return nerrors == 0;
}
#6 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/lex.c
      
#7 !/home/user/UCSD-C/tinyc/lex.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#8 !/home/user/UCSD-C/tinyc/lex.c
#pragma segment PARSE

int tok;                         
int insys;                       
int tokval;                      
int tokval2;                     
int toklong;                     
char tokname[64];           
char *tokstr;                    
int toklen;                      
unsigned char tokreal[4];        

static FILE *lexin;
static int ch;                   
static int atbol;

 
static int ptok;
static int pval;
static int pval2;
static int plong;
static char pname[64];
static int havepeek;

static char *strbufs[2];
static int strslot;

void pragma(char *s);

static char *kwtab[] = {
    "auto", "break", "case", "char", "const", "continue", "default", "do",
    "double", "else", "enum", "extern", "float", "for", "goto", "if",
    "int", "long", "register", "return", "short", "signed", "sizeof", "static",
    "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while"
};

static void nextch(void)
{
    ch = getc(lexin);
}

void lexinit(FILE *fp)
{
    strbufs[0] = malloc(260);
    strbufs[1] = malloc(260);
    if (!strbufs[0] || !strbufs[1])
        fatal(2  , 0);
    lexin = fp;
    atbol = 1;
    havepeek = 0;
    nextch();
}

static void lexdirective(void)
{
    char buf[512];
    int n;
    int v;
    char *s;
    n = 0;
    nextch();
    while (ch != '\n' && ch != (-1)) {
        if (n < 512 - 1)
            buf[n++] = ch;
        nextch();
    }
    buf[n] = 0;
    if (buf[0] >= '0' && buf[0] <= '9') {
        v = 0;
        s = buf;
        while (*s >= '0' && *s <= '9')
            v = v * 10 + *s++ - '0';
        while (*s == ' ')
            s++;
        curline = v - 1;          
        insys = *s == '!';
        if (insys)
            s++;
        if (!curfile || strcmp(curfile, s) != 0)
            curfile = pstrdup(s);
    } else if (strncmp(buf, "pragma", 6) == 0)
        pragma(buf + 6);
}

static int escape(void)
{
    int v;
    int n;
    nextch();
    v = ch;
    switch (ch) {
    case 'n': v = 10; break;
    case 't': v = 9; break;
    case 'r': v = 13; break;
    case 'b': v = 8; break;
    case 'f': v = 12; break;
    case 'v': v = 11; break;
    case 'a': v = 7; break;
    case 'x':
        v = 0;
        nextch();
        for (;;) {
            if (ch >= '0' && ch <= '9')
                v = v * 16 + ch - '0';
            else if (ch >= 'a' && ch <= 'f')
                v = v * 16 + ch - 'a' + 10;
            else if (ch >= 'A' && ch <= 'F')
                v = v * 16 + ch - 'A' + 10;
            else
                return v & 255;
            v = v & 4095;
            nextch();
        }
    default:
        if (ch >= '0' && ch <= '7') {
            v = 0;
            n = 0;
            while (ch >= '0' && ch <= '7' && n < 3) {
                v = v * 8 + ch - '0';
                n++;
                nextch();
            }
            return v & 255;
        }
    }
    nextch();
    return v;
}

 

 
static int mac(unsigned char *acc, int base, int d)
{
    int i;
    int v;
    for (i = 0; i < 4; i++) {
        v = acc[i] * base + d;
        acc[i] = v & 255;
        d = (v >> 8) & 255;
    }
    return d != 0;
}

  
#154 !/home/user/UCSD-C/tinyc/lex.c
#pragma segment REALLIT


static int bitlen(unsigned char *a)
{
    int i;
    int b;
    for (i = 48 - 1; i >= 0; i--)
        if (a[i]) {
            b = 8;
            while (!(a[i] & (1 << (b - 1))))
                b--;
            return i * 8 + b;
        }
    return 0;
}

static int getbit(unsigned char *a, int n)
{
    if (n < 0 || n >= 48 * 8)
        return 0;
    return (a[n >> 3] >> (n & 7)) & 1;
}

static void bigmul(unsigned char *a, int m)
{
    int i;
    int c;
    int v;
    c = 0;
    for (i = 0; i < 48; i++) {
        v = a[i] * m + c;
        a[i] = v & 255;
        c = (v >> 8) & 255;
    }
    if (c)
        error(27  , 0);
}

static void bigshl(unsigned char *a)
{
    int i;
    int c;
    int v;
    c = 0;
    for (i = 0; i < 48; i++) {
        v = a[i] * 2 + c;
        a[i] = v & 255;
        c = v >> 8;
    }
}

static int bigcmp(unsigned char *a, unsigned char *b)
{
    int i;
    for (i = 48 - 1; i >= 0; i--)
        if (a[i] != b[i])
            return a[i] < b[i] ? -1 : 1;
    return 0;
}

static void bigsub(unsigned char *a, unsigned char *b)
{
    int i;
    int bw;
    int v;
    bw = 0;
    for (i = 0; i < 48; i++) {
        v = a[i] - b[i] - bw;
        bw = v < 0;
        a[i] = v & 255;
    }
}

 
static void makereal(unsigned char *digits, int nd, int exp10, unsigned char *out)
{
    unsigned char num[48];
    unsigned char den[48];
    unsigned char q[48];
    int i;
    int k;
    int bl;
    int e2;
    int round;
    int sticky;
    int m1;
    int m2;
    int m3;
    int top;
    memset(num, 0, 48);
    memset(den, 0, 48);
    for (i = 0; i < nd; i++) {
        int j;
        int c;
        int v;
        bigmul(num, 10);
        c = digits[i];
        for (j = 0; j < 48 && c; j++) {
            v = num[j] + c;
            num[j] = v & 255;
            c = v >> 8;
        }
    }
    for (i = 0; i < 4; i++)
        out[i] = 0;
    if (bitlen(num) == 0)
        return;
    den[0] = 1;
    k = 0;
    if (exp10 >= 0) {
        while (exp10-- > 0)
            bigmul(num, 10);
    } else {
        while (exp10++ < 0)
            bigmul(den, 10);
    }
     
    while (bitlen(num) < bitlen(den) + 27) {
        bigshl(num);
        k++;
    }
     
    memset(q, 0, 48);
    bl = bitlen(num) - bitlen(den);
    for (i = 0; i < bl; i++)
        bigshl(den);
    for (i = bl; i >= 0; i--) {
        bigshl(q);
        if (bigcmp(num, den) >= 0) {
            bigsub(num, den);
            q[0] = q[0] | 1;
        }
         
        {
            int j;
            int c;
            c = 0;
            for (j = 48 - 1; j >= 0; j--) {
                int v;
                v = den[j];
                den[j] = (v >> 1) | (c << 7);
                c = v & 1;
            }
        }
    }
    sticky = bitlen(num) != 0;
    top = bitlen(q);                     
     
    m1 = 0;
    m2 = 0;
    m3 = 0;
    for (i = 0; i < 8; i++) {
        m1 = m1 * 2 + getbit(q, top - 1 - i);
        m2 = m2 * 2 + getbit(q, top - 9 - i);
        m3 = m3 * 2 + getbit(q, top - 17 - i);
    }
    round = getbit(q, top - 25);
    e2 = top - k;                        
    if (round) {
        m3++;
        if (m3 == 256) {
            m3 = 0;
            m2++;
            if (m2 == 256) {
                m2 = 0;
                m1++;
                if (m1 == 256) {
                    m1 = 128;
                    e2++;
                }
            }
        }
    }
    if (e2 + 128 > 255) {
        error(27  , 0);
        return;
    }
    if (e2 + 128 < 1)
        return;                          
    out[0] = e2 + 128;
    out[1] = m1 & 127;
    out[2] = m2;
    out[3] = m3;
}

#pragma segment PARSE

static void number(void)
{
    unsigned char acc[4];
    unsigned char digits[24];
    int nd;
    int base;
    int d;
    int ovf;
    int isfloat;
    int exp10;
    int esign;
    int ev;
    int isunsigned;
    int islong;
    memset(acc, 0, 4);
    ovf = 0;
    base = 10;
    isfloat = 0;
    nd = 0;
    exp10 = 0;
    if (ch == '0') {
        nextch();
        if (ch == 'x' || ch == 'X') {
            base = 16;
            nextch();
        } else
            base = 8;
    }
    for (;;) {
        if (ch >= '0' && ch <= '9')
            d = ch - '0';
        else if (base == 16 && ch >= 'a' && ch <= 'f')
            d = ch - 'a' + 10;
        else if (base == 16 && ch >= 'A' && ch <= 'F')
            d = ch - 'A' + 10;
        else
            break;
        if (base != 16 && (nd > 0 || d > 0)) {
            if (nd < 24)
                digits[nd++] = d;
            else
                exp10++;
        }
        ovf = ovf | mac(acc, base == 8 ? 10 : base, d);
        nextch();
    }
    if (base != 16 && (ch == '.' || ch == 'e' || ch == 'E')) {
        isfloat = 1;
        if (ch == '.') {
            nextch();
            while (ch >= '0' && ch <= '9') {
                if (nd > 0 || ch != '0') {
                    if (nd < 24) {
                        digits[nd++] = ch - '0';
                        exp10--;
                    }
                } else
                    exp10--;
                nextch();
            }
        }
        if (ch == 'e' || ch == 'E') {
            nextch();
            esign = 1;
            if (ch == '-') {
                esign = -1;
                nextch();
            } else if (ch == '+')
                nextch();
            ev = 0;
            while (ch >= '0' && ch <= '9') {
                if (ev < 1000)
                    ev = ev * 10 + ch - '0';
                nextch();
            }
            exp10 = exp10 + esign * ev;
        }
        if (exp10 + nd > 40)
            error(27  , 0);
        while (ch == 'f' || ch == 'F' || ch == 'l' || ch == 'L')
            nextch();
        if (exp10 + nd < -40)
            nd = 0;
        makereal(digits, nd, exp10, tokreal);
        tok = 258;
        return;
    }
    if (base == 8) {                     
        int i;
        memset(acc, 0, 4);
        ovf = 0;
        for (i = 0; i < nd; i++)
            ovf = ovf | mac(acc, 8, digits[i]);
    }
    isunsigned = 0;
    islong = 0;
    for (;;) {
        if (ch == 'u' || ch == 'U')
            isunsigned = 1;
        else if (ch == 'l' || ch == 'L')
            islong = 1;
        else
            break;
        nextch();
    }
    if (ovf)
        error(28  , 0);
    tokval = ((((acc[0] + acc[1] * 256) & 65535) ^ 32768) - 32768);
    tokval2 = ((((acc[2] + acc[3] * 256) & 65535) ^ 32768) - 32768);
    if (acc[2] || acc[3])
        islong = 1;
    if (!islong && (acc[1] & 128)) {
        if (base == 10 && !isunsigned)
            islong = 1;
        else
            isunsigned = 1;
    }
    if (islong && !isunsigned && (acc[3] & 128) && base != 10)
        isunsigned = 1;
    toklong = islong + isunsigned * 2;
    tok = 257;
}

static void rawnext(void)
{
    int n;
    int c;
    char *buf;
    int cap;
    for (;;) {
        if (ch == '\n') {
            curline++;
            atbol = 1;
            nextch();
            continue;
        }
        if (ch == ' ' || ch == '\t' || ch == '\r' || ch == 12) {
            nextch();
            continue;
        }
        if (ch == '#' && atbol) {
            lexdirective();
            continue;
        }
        break;
    }
    atbol = 0;
    if (ch == (-1)) {
        tok = 0;
        return;
    }
    if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_') {
        int lo;
        int hi;
        int mid;
        int r;
        n = 0;
        while ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_' || (ch >= '0' && ch <= '9')) {
            if (n < 64 - 1)
                tokname[n++] = ch;
            nextch();
        }
        tokname[n] = 0;
        lo = 0;
        hi = 331 - 300;
        while (lo <= hi) {
            mid = (lo + hi) / 2;
            r = strcmp(tokname, kwtab[mid]);
            if (r == 0) {
                tok = 300 + mid;
                return;
            }
            if (r < 0)
                hi = mid - 1;
            else
                lo = mid + 1;
        }
        tok = 256;
        return;
    }
    if (ch >= '0' && ch <= '9') {
        number();
        return;
    }
    if (ch == '\'') {
        nextch();
        if (ch == '\\')
            tokval = escape();
        else {
            tokval = ch;
            nextch();
        }
        if (ch != '\'')
            error(29  , 0);
        nextch();
        tokval = tokval & 255;
        if (tokval > 127)
            tokval = tokval - 256;
        tokval2 = 0;
        toklong = 0;
        tok = 257;
        return;
    }
    if (ch == '"') {
         
        strslot = !strslot;
        buf = strbufs[strslot];
        cap = 260;
        n = 0;
        for (;;) {
            nextch();
            while (ch != '"') {
                if (ch == '\n' || ch == (-1)) {
                    error(30  , 0);
                    break;
                }
                if (ch == '\\')
                    c = escape();
                else {
                    c = ch;
                    nextch();
                }
                if (n >= cap - 1) {
                    error(31  , 0);
                    n = 0;
                }
                buf[n++] = c;
            }
            nextch();
             
            while (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
                if (ch == '\n')
                    curline++;
                nextch();
            }
            if (ch != '"')
                break;
        }
        buf[n++] = 0;
        tokstr = buf;
        toklen = n;
        tok = 259;
        return;
    }
    c = ch;
    nextch();
    switch (c) {
    case '-':
        if (ch == '>') { nextch(); tok = 261; return; }
        if (ch == '-') { nextch(); tok = 263; return; }
        if (ch == '=') { nextch(); tok = 273; return; }
        break;
    case '+':
        if (ch == '+') { nextch(); tok = 262; return; }
        if (ch == '=') { nextch(); tok = 272; return; }
        break;
    case '*':
        if (ch == '=') { nextch(); tok = 274; return; }
        break;
    case '/':
        if (ch == '=') { nextch(); tok = 275; return; }
        break;
    case '%':
        if (ch == '=') { nextch(); tok = 276; return; }
        break;
    case '&':
        if (ch == '&') { nextch(); tok = 270; return; }
        if (ch == '=') { nextch(); tok = 277; return; }
        break;
    case '|':
        if (ch == '|') { nextch(); tok = 271; return; }
        if (ch == '=') { nextch(); tok = 278; return; }
        break;
    case '^':
        if (ch == '=') { nextch(); tok = 279; return; }
        break;
    case '<':
        if (ch == '<') {
            nextch();
            if (ch == '=') { nextch(); tok = 280; return; }
            tok = 264;
            return;
        }
        if (ch == '=') { nextch(); tok = 266; return; }
        break;
    case '>':
        if (ch == '>') {
            nextch();
            if (ch == '=') { nextch(); tok = 281; return; }
            tok = 265;
            return;
        }
        if (ch == '=') { nextch(); tok = 267; return; }
        break;
    case '=':
        if (ch == '=') { nextch(); tok = 268; return; }
        break;
    case '!':
        if (ch == '=') { nextch(); tok = 269; return; }
        break;
    case '.':
        if (ch == '.') {
            nextch();
            if (ch == '.') { nextch(); tok = 282; return; }
            error(32  , 0);
        }
        break;
    }
    tok = c;
}

void next(void)
{
    if (havepeek) {
        havepeek = 0;
        tok = ptok;
        tokval = pval;
        tokval2 = pval2;
        toklong = plong;
        strcpy(tokname, pname);
        return;
    }
    rawnext();
}

 
int peek(void)
{
    int t;
    int v;
    int v2;
    int l;
    char name[64];
    if (havepeek)
        return ptok;
    t = tok;
    v = tokval;
    v2 = tokval2;
    l = toklong;
    strcpy(name, tokname);
    rawnext();
    ptok = tok;
    pval = tokval;
    pval2 = tokval2;
    plong = toklong;
    strcpy(pname, tokname);
    havepeek = 1;
    tok = t;
    tokval = v;
    tokval2 = v2;
    toklong = l;
    strcpy(tokname, name);
    return ptok;
}

char *peekname(void)
{
    return pname;
}
#7 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/parse.c
       
#8 !/home/user/UCSD-C/tinyc/parse.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#9 !/home/user/UCSD-C/tinyc/parse.c
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


static struct Sym *htab[128];
static struct Sym *ttab[128];
static struct Sym *scopes[40];
static int level;
static struct Sym *labels;
int globoff;                     
static char *modname;
static int usesfloat;           
static int nofltused;

 
static struct Sym *curfn;
static struct Type *curft;
static int exitlab;
static int sretoff;
static int vaoff;

 
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

 












static char *intrnames[] = {
    "", "__dvi", "__mdi", "__va_start", "__cspv", "__cspi", "__cspf",
    "__cxp0v", "__cxp0i", "__osvar", "__exitprog", "__osvaraddr", 0
};

 

  
#80 !/home/user/UCSD-C/tinyc/parse.c
static int tentative;

static struct Type *mktype(int kind, int size, int align)
{
    struct Type *t;
    if (tentative && (kind == 10 || kind == 11 || kind == 14)) {
        t = (struct Type *)xalloc(sizeof(struct Type));
        t->align = -1;               
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

 
#pragma segment CINIT

void typeinit(void)
{
    ty_void = mktype(0, 1, 1);
    ty_char = mktype(1, 1, 1);
    ty_uchar = mktype(2, 1, 1);
    ty_int = mktype(3, 2, 2);
    ty_uint = mktype(4, 2, 2);
    ty_long = mktype(5, 4, 2);
    ty_ulong = mktype(6, 4, 2);
    ty_float = mktype(7, 4, 2);
    ty_double = mktype(8, 4, 2);
    ty_ldouble = mktype(9, 4, 2);
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
        p = mktype(10, 2, 2);    
        p->base = t;
        return p;
    }
    p = mktype(10, 2, 2);
    p->base = t;
    t->ptrto = p;
    return p;
}

static struct Type *arrayof(struct Type *t, int n)
{
    struct Type *a;
    a = mktype(11, n < 0 ? -1 : ((((n * t->size) & 65535) ^ 32768) - 32768), t->align);
    a->base = t;
    a->len = n;
    return a;
}

 
static struct Type *permtype(struct Type *t)
{
    struct Type *n;
    struct Param *p;
    struct Param *q;
    struct Param *last;
    if (t->align != -1)
        return t;
    if (t->kind == 10)
        return ptrto(permtype(t->base));
    if (t->kind == 11)
        return arrayof(permtype(t->base), t->len);
    n = mktype(14, 2, 2);
    n->base = permtype(t->base);
    n->variadic = t->variadic;
    n->oldstyle = t->oldstyle;
    last = 0;
    for (p = t->params; p; p = p->next) {
        q = (struct Param *)palloc(sizeof(struct Param));
        q->type = permtype(p->type);
        q->name = p->name;           
        if (last)
            last->next = q;
        else
            n->params = q;
        last = q;
    }
    return n;
}

   
#181 !/home/user/UCSD-C/tinyc/parse.c

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
    if (a->kind == 10 || a->kind == 11)
        return sametype(a->base, b->base);
    return a->kind != 12 && a->kind != 13 && a->kind != 14;
}

 

static struct Sym *lookup(char *name)
{
    struct Sym *s;
    for (s = htab[hashstr(name) & (128 - 1)]; s; s = s->next)
        if (strcmp(s->name, name) == 0)
            return s;
    return 0;
}

static struct Sym *lookuptag(char *name)
{
    struct Sym *s;
    for (s = ttab[hashstr(name) & (128 - 1)]; s; s = s->next)
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
    h = hashstr(name) & (128 - 1);
    if (kind == 6) {
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
        fatal(33  , 0);
    scopes[level] = 0;
}

static void popscope(void)
{
    struct Sym *s;
    int h;
    for (s = scopes[level]; s; s = s->scopenext) {
        h = hashstr(s->name) & (128 - 1);
        if (s->kind == 6)
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
        fatal(34  , 0);
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
        fatal(35  , 0);
    return curlocal - w + 1;
}

 

static void expect(int t, char *what)
{
    if (tok != t) {
        error(36  , what);
        return;
    }
    next();
}

static int istypename(void)
{
    struct Sym *s;
    if (tok >= 300 && tok <= 331) {
        switch (tok) {
        case 303: case 304: case 308: case 310: case 311:
        case 312: case 316: case 317: case 318: case 320:
        case 321: case 323: case 324: case 326: case 327:
        case 328: case 329: case 330: case 300:
            return 1;
        }
        return 0;
    }
    if (tok == 256) {
        s = lookup(tokname);
        return s && s->kind == 4;
    }
    return 0;
}

 

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
    n = mknode(1, t, 0, 0);
    n->val = ((((v) & 65535) ^ 32768) - 32768);
    if (islongty(t))
        n->val2 = (n->val < 0 && t->kind == 5) ? -1 : 0;
    return n;
}

static int isconst(struct Node *n)
{
    return n->op == 1 && !islongty(n->type);
}

static int islvalue(struct Node *n)
{
    return n->op == 4 || n->op == 8 || n->op == 9;
}

  
#377 !/home/user/UCSD-C/tinyc/parse.c
static int globinit;
static int allocglobal(struct Type *t);

 
static struct Node *decay(struct Node *n)
{
    if (n->op == 3 && globinit) {
        n->op = 44;           
        n->type = ptrto(ty_char);
        return n;
    }
    if (n->type->kind == 11)
        return mknode(10, ptrto(n->type->base), n, 0);
    if (n->type->kind == 14)
        return mknode(10, ptrto(n->type), n, 0);
    return n;
}

static struct Sym *helper(char *name)
{
    struct Sym *s;
    s = lookup(name);
    if (!s || s->kind != 3)
        fatal(37  , name);
    return s;
}

static struct Node *call1(char *name, struct Node *a, struct Node *b)
{
    struct Sym *s;
    struct Node *n;
    struct Node *f;
    struct Param *p;
    s = helper(name);
    f = mknode(5, s->type, 0, 0);
    f->sym = s;
    n = mknode(6, s->type->base, f, 0);
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

 
struct Node *cast(struct Node *n, struct Type *t)
{
    struct Type *f;
    int fk;
    int tk;
    n = decay(n);
    f = n->type;
    fk = f->kind;
    tk = t->kind;
    if (tk == 0) {
        n = mknode(14, t, n, 0);
        return n;
    }
    if (f == t || (fk == tk && fk != 12 && fk != 13 && fk != 11))
        return fk == tk && f != t ? mknode(14, t, n, 0) : n;
    if (tk == 12 || tk == 13 || tk == 11 || tk == 14) {
        if (fk != tk)
            error(38  , 0);
        return n;
    }
    if (!isscalar(f)) {
        error(38  , 0);
        return n;
    }
     
    if (islongty(t) && !islongty(f)) {
        if (isfloatty(f))
            return call1(tk == 5 ? "__ftol" : "__ftoul", n, 0);
        if (n->op == 1) {
            struct Node *c;
            c = mknum(n->val, t);
            if (isunsignedty(f) || f->kind == 10)
                c->val2 = 0;
            else
                c->val2 = n->val < 0 ? -1 : 0;
            return c;
        }
        if (isunsignedty(f) || fk == 10)
            return mknode(14, t, call1("__utol", mknode(14, ty_uint, n, 0), 0), 0);
        return mknode(14, t, call1("__itol", mknode(14, ty_int, n, 0), 0), 0);
    }
    if (islongty(f) && !islongty(t)) {
        if (isfloatty(t))
            return mknode(14, t, call1(fk == 5 ? "__ltof" : "__ultof", n, 0), 0);
        if (n->op == 1)
            return cast(mknum(n->val, isunsignedty(f) ? ty_uint : ty_int), t);
        return cast(call1("__ltoi", n, 0), t);
    }
    if (islongty(f) && islongty(t))
        return mknode(14, t, n, 0);
     
    if (n->op == 1 && !isfloatty(t) && !isfloatty(f)) {
        int v;
        v = n->val;
        if (tk == 1) {
            v = v & 255;
            if (v > 127)
                v = v - 256;
        } else if (tk == 2)
            v = v & 255;
        return mknum(v, t);
    }
    if (isfloatty(t) && isunsignedty(f))
        return mknode(14, t, call1("__utof", mknode(14, ty_uint, n, 0), 0), 0);
    if (isunsignedty(t) && isfloatty(f) && tk != 2)
        return call1("__ftou", n, 0);
    return mknode(14, t, n, 0);
}

static struct Type *arith(struct Type *a, struct Type *b)
{
    if (a->kind == 9 || b->kind == 9)
        return ty_ldouble;
    if (a->kind == 8 || b->kind == 8)
        return ty_double;
    if (a->kind == 7 || b->kind == 7)
        return ty_float;
    if (a->kind == 6 || b->kind == 6)
        return ty_ulong;
    if (a->kind == 5 || b->kind == 5)
        return ty_long;
    if (a->kind == 4 || b->kind == 4)
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
    case 23: return ((((a + b) & 65535) ^ 32768) - 32768);
    case 24: return ((((a - b) & 65535) ^ 32768) - 32768);
    case 25: return ((((a * b) & 65535) ^ 32768) - 32768);
    case 26: return uns ? ((((ua / ub) & 65535) ^ 32768) - 32768) : ((((a / b) & 65535) ^ 32768) - 32768);
    case 27: return uns ? ((((ua % ub) & 65535) ^ 32768) - 32768) : ((((a % b) & 65535) ^ 32768) - 32768);
    case 28: return a & b;
    case 29: return a | b;
    case 30: return a ^ b;
    case 31: return ((((a << (b & 15)) & 65535) ^ 32768) - 32768);
    case 32: return uns ? ((((ua >> (b & 15)) & 65535) ^ 32768) - 32768) : ((((a >> (b & 15)) & 65535) ^ 32768) - 32768);
    case 33: return a == b;
    case 34: return a != b;
    case 35: return uns ? ua < ub : a < b;
    case 36: return uns ? ua <= ub : a <= b;
    case 37: return uns ? ua > ub : a > b;
    case 38: return uns ? ua >= ub : a >= b;
    }
    return 0;
}

static char *lhelper(int op, int uns)
{
    switch (op) {
    case 23: return "__ladd";
    case 24: return "__lsub";
    case 25: return "__lmul";
    case 26: return uns ? "__uldiv" : "__ldiv";
    case 27: return uns ? "__ulmod" : "__lmod";
    case 28: return "__land";
    case 29: return "__lor";
    case 30: return "__lxor";
    case 31: return "__lshl";
    case 32: return uns ? "__ulshr" : "__lshr";
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
     
    if ((op == 23 || op == 24) && at->kind == 10 && isintegral(bt)) {
        size = at->base->size;
        if (size < 1)
            size = 1;
        b = cast(b, ty_int);
        if (isconst(b))
            b = mknum(((((b->val * size) & 65535) ^ 32768) - 32768), ty_int);
        else if (size != 1)
            b = mknode(25, ty_int, b, mknum(size, ty_int));
        n = mknode(op, at, a, b);
        if (isconst(a) && isconst(b))
            return mknum(fold(op, a->val, b->val, 0), at);
        return n;
    }
    if (op == 23 && isintegral(at) && bt->kind == 10)
        return binop(op, b, a);
    if (op == 24 && at->kind == 10 && bt->kind == 10) {
        size = at->base->size;
        n = mknode(24, ty_int, a, b);
        if (size > 1)
            n = binop(26, n, mknum(size, ty_int));
        return n;
    }
    if (op >= 33 && op <= 38) {
        if (at->kind == 10 || bt->kind == 10) {
            n = mknode(op, ty_int, cast(a, ty_uint), cast(b, ty_uint));
            return n;
        }
        if (!isscalar(at) || !isscalar(bt)) {
            error(39  , 0);
            return mknum(0, ty_int);
        }
        t = arith(at, bt);
        a = cast(a, t);
        b = cast(b, t);
        if (islongty(t))
            return mknode(op, ty_int, call1(t->kind == 6 ? "__ulcmp" : "__lcmp", a, b), mknum(0, ty_int));
        if (isconst(a) && isconst(b) && !isfloatty(t))
            return mknum(fold(op, a->val, b->val, isunsignedty(t)), ty_int);
        return mknode(op, ty_int, a, b);
    }
    if (!isscalar(at) || !isscalar(bt) || at->kind == 10 || bt->kind == 10) {
        error(40  , 0);
        return mknum(0, ty_int);
    }
    if (op == 31 || op == 32) {
        t = arith(at, ty_int);
        if (!isintegral(t) || !isintegral(bt)) {
            error(41  , 0);
            return mknum(0, ty_int);
        }
        a = cast(a, t);
        b = cast(b, ty_int);
        if (islongty(t))
            return call1(lhelper(op, isunsignedty(t)), a, b);
        if (isconst(a) && isconst(b))
            return mknum(fold(op, a->val, b->val, isunsignedty(t)), t);
        if (op == 31 && isconst(b) && b->val >= 0 && b->val < 15)
            return mknode(25, t, a, mknum(1 << b->val, ty_int));
        if (op == 31)
            return mknode(14, t, call1("__shl", cast(a, ty_int), b), 0);
        if (isunsignedty(t))
            return call1("__ushr", a, b);
        return call1("__shr", a, b);
    }
    t = arith(at, bt);
    if ((op == 27 || op == 28 || op == 29 || op == 30) && isfloatty(t)) {
        error(40  , 0);
        return mknum(0, ty_int);
    }
    a = cast(a, t);
    b = cast(b, t);
    uns = isunsignedty(t);
    if (islongty(t))
        return mknode(14, t, call1(lhelper(op, uns), a, b), 0);
    if (isconst(a) && isconst(b) && !isfloatty(t)) {
        if ((op == 26 || op == 27) && b->val == 0)
            error(42  , 0);
        else
            return mknum(fold(op, a->val, b->val, uns), t);
    }
    if (!isfloatty(t)) {
        if (op == 26)
            return mknode(14, t, call1(uns ? "__udiv" : "__divi", a, b), 0);
        if (op == 27)
            return mknode(14, t, call1(uns ? "__umod" : "__modi", a, b), 0);
        if (op == 30)
            return mknode(14, t, call1("__xor", cast(a, ty_int), cast(b, ty_int)), 0);
    }
    return mknode(op, t, a, b);
}

 
static struct Node *fzero(void)
{
    struct Node *n;
    n = mknode(2, ty_double, 0, 0);
    n->fimg = (unsigned char *)xalloc(4);
    return n;
}

static struct Node *cond(struct Node *n)
{
    n = decay(n);
    if (!isscalar(n->type))
        error(43  , 0);
    if (isfloatty(n->type))
        n = binop(34, n, fzero());
    return n;
}

 

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
    while (tok != ')' && tok != 0) {
        a = assign();
        if (ft) {
            if (p) {
                a = cast(a, p->type);
                p = p->next;
            } else {
                if (!ft->variadic && !ft->oldstyle)
                    error(44  , 0);
                a = decay(a);
                if (a->type->kind == 1 || a->type->kind == 2)
                    a = cast(a, ty_int);
                else if (a->type->kind == 7)
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
        error(45  , 0);
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
    n = mknode(41, ty_int, 0, 0);
    n->val = code;
    n->a = arglist(0, &na);
    if (code == 3) {
        if (!curft || !curft->variadic)
            error(46  , 0);
        n->val2 = vaoff;
        n->type = ty_charp;
    } else if (code == 4 || code == 7 || code == 10)
        n->type = ty_void;
    else if (code == 6)
        n->type = ty_float;
    else if (code == 11)
        n->type = ptrto(ty_int);
    if ((code >= 4 && code <= 8) || code == 9 || code == 11) {
        if (!n->a || !isconst(n->a))
            error(47  , intrnames[code]);
    }
    return n;
}

static struct Node *primary(void)
{
    struct Node *n;
    struct Sym *s;
    int i;
    switch (tok) {
    case 257:
        if (toklong & 1) {
            n = mknode(1, (toklong & 2) ? ty_ulong : ty_long, 0, 0);
            n->val = tokval;
            n->val2 = tokval2;
        } else
            n = mknum(tokval, (toklong & 2) ? ty_uint : ty_int);
        next();
        return n;
    case 258:
        if (!insys)
            usesfloat = 1;
        n = mknode(2, ty_double, 0, 0);
        n->fimg = (unsigned char *)xalloc(4);
        memcpy(n->fimg, tokreal, 4);
        next();
        return n;
    case 259:
        {
             
            struct Type *st;
            st = (struct Type *)xalloc(sizeof(struct Type));
            st->kind = 11;
            st->size = toklen;
            st->align = 1;
            st->base = ty_char;
            st->len = toklen;
            n = mknode(3, st, 0, 0);
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
    case 256:
        s = lookup(tokname);
        if (!s && tokname[0] == '_' && tokname[1] == '_') {
            for (i = 1; intrnames[i]; i++)
                if (strcmp(tokname, intrnames[i]) == 0)
                    return intrinsic(i);
        }
        if (!s) {
            error(48  , tokname);
            next();
            return mknum(0, ty_int);
        }
        next();
        if (s->kind == 5)
            return mknum(s->offset, ty_int);
        if (s->kind == 3) {
            n = mknode(5, s->type, 0, 0);
            n->sym = s;
            return n;
        }
        if (s->kind == 4) {
            error(49  , s->name);
            return mknum(0, ty_int);
        }
        n = mknode(4, s->type, 0, 0);
        n->sym = s;
        return n;
    }
    error(50  , 0);
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
        if (!f->name && (f->type->kind == 12 || f->type->kind == 13)) {
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
    if (n->type->kind != 12 && n->type->kind != 13) {
        error(51  , name);
        return n;
    }
    if (n->type->size < 0)
        error(52  , n->type->tag);
    f = findfield(n->type, name, &off);
    if (!f) {
        error(53  , name);
        return n;
    }
    m = mknode(8, f->type, n, 0);
    m->val = off;
    return m;
}

static struct Node *deref(struct Node *n)
{
    n = decay(n);
    if (n->type->kind != 10) {
        error(54  , 0);
        return n;
    }
    if (n->type->base->kind == 14)
        return n;                
    return mknode(9, n->type->base, n, 0);
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
            n = deref(binop(23, n, c));
        } else if (tok == '(') {
            next();
            ft = 0;
            if (n->type->kind == 14)
                ft = n->type;
            else if (n->type->kind == 10 && n->type->base->kind == 14) {
                ft = n->type->base;
            } else
                error(55  , 0);
            c = mknode(6, ft ? ft->base : ty_int, n, 0);
            c->b = arglist(ft, &na);
            c->val = na;
            n = c;
        } else if (tok == '.') {
            next();
            if (tok != 256)
                error(56  , 0);
            n = member(n, tokname);
            next();
        } else if (tok == 261) {
            next();
            if (tok != 256)
                error(56  , 0);
            n = member(deref(n), tokname);
            next();
        } else if (tok == 262 || tok == 263) {
            struct Node *u;
            if (!islvalue(n))
                error(57  , 0);
            u = mknode(43, n->type, 0, 0);
            u = cast(binop(tok == 262 ? 23 : 24, u, mknum(1, ty_int)), n->type);
            n = mknode(18, n->type, n, u);
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
        if (n->op == 2) {
            n->fimg[1] = n->fimg[1] ^ 128;
            if (n->fimg[0] == 0)
                n->fimg[1] = 0;
            return n;
        }
        if (islongty(n->type))
            return mknode(14, n->type, call1("__lneg", n, 0), 0);
        if (!isintegral(n->type) && !isfloatty(n->type))
            error(58  , 0);
        t = isfloatty(n->type) ? n->type : arith(n->type, ty_int);
        return mknode(11, t, cast(n, t), 0);
    case '+':
        next();
        n = castexpr();
        return cast(n, isfloatty(n->type) || islongty(n->type) ? n->type : arith(n->type, ty_int));
    case '~':
        next();
        n = castexpr();
        if (!isintegral(n->type))
            error(58  , 0);
        if (islongty(n->type))
            return mknode(14, n->type, call1("__lnot", n, 0), 0);
        t = arith(n->type, ty_int);
        if (isconst(n))
            return mknum(~n->val, t);
        return mknode(13, t, cast(n, t), 0);
    case '!':
        next();
        n = cond(castexpr());
        if (isconst(n))
            return mknum(!n->val, ty_int);
        return mknode(12, ty_int, n, 0);
    case '*':
        next();
        return deref(castexpr());
    case '&':
        next();
        n = castexpr();
        if (n->op == 5)
            return mknode(10, ptrto(n->type), n, 0);
        if (!islvalue(n))
            error(57  , 0);
        return mknode(10, ptrto(n->type), n, 0);
    case 262:
    case 263:
        op = tok == 262 ? 23 : 24;
        next();
        n = unary();
        if (!islvalue(n))
            error(57  , 0);
        u = mknode(43, n->type, 0, 0);
        u = cast(binop(op, u, mknum(1, ty_int)), n->type);
        return mknode(16, n->type, n, u);
    case 322:
        next();
        if (tok == '(' && (peek() >= 300 || (peek() == 256 && lookup(peekname()) && lookup(peekname())->kind == 4))) {
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
            error(59  , 0);
        return mknum(t->size, ty_uint);
    }
    return postfix();
}

static struct Node *castexpr(void)
{
    struct Type *t;
    struct Node *n;
    if (tok == '(' && (peek() >= 300 || (peek() == 256 && lookup(peekname()) && lookup(peekname())->kind == 4))) {
        next();
        if (istypename()) {
            t = typename();
            expect(')', ")");
            n = castexpr();
            return cast(n, t);
        }
        n = expr();
        expect(')', ")");
         
        for (;;) {
            if (tok == '[') {
                struct Node *c;
                next();
                c = expr();
                expect(']', "]");
                n = deref(binop(23, n, c));
            } else if (tok == '.') {
                next();
                n = member(n, tokname);
                next();
            } else if (tok == 261) {
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
    case '*': *op = 25; return 10;
    case '/': *op = 26; return 10;
    case '%': *op = 27; return 10;
    case '+': *op = 23; return 9;
    case '-': *op = 24; return 9;
    case 264: *op = 31; return 8;
    case 265: *op = 32; return 8;
    case '<': *op = 35; return 7;
    case '>': *op = 37; return 7;
    case 266: *op = 36; return 7;
    case 267: *op = 38; return 7;
    case 268: *op = 33; return 6;
    case 269: *op = 34; return 6;
    case '&': *op = 28; return 5;
    case '^': *op = 30; return 4;
    case '|': *op = 29; return 3;
    case 270: *op = 21; return 2;
    case 271: *op = 22; return 1;
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
        if (op == 21 || op == 22) {
            a = cond(a);
            b = cond(b);
            if (isconst(a) && isconst(b))
                a = mknum(op == 21 ? (a->val && b->val) : (a->val || b->val), ty_int);
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
    if (isscalar(a->type) && isscalar(b->type) && a->type->kind != 10 && b->type->kind != 10) {
        t = arith(a->type, b->type);
        a = cast(a, t);
        b = cast(b, t);
    } else if (a->type->kind == 10)
        t = a->type;
    else
        t = b->type;
    if (isconst(c))
        return c->val ? a : b;
    n = mknode(19, t, c, a);
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
        if (!islvalue(a) || a->type->kind == 11)
            error(57  , 0);
        if (a->type->kind == 12 || a->type->kind == 13) {
            if (!sametype(a->type, b->type) || a->type != b->type)
                if (a->type != b->type)
                    error(60  , 0);
            return mknode(15, a->type, a, b);
        }
        return mknode(15, a->type, a, cast(b, a->type));
    }
    if (tok >= 272 && tok <= 281) {
        switch (tok) {
        case 272: op = 23; break;
        case 273: op = 24; break;
        case 274: op = 25; break;
        case 275: op = 26; break;
        case 276: op = 27; break;
        case 277: op = 28; break;
        case 278: op = 29; break;
        case 279: op = 30; break;
        case 280: op = 31; break;
        default: op = 32; break;
        }
        next();
        b = assign();
        if (!islvalue(a))
            error(57  , 0);
        u = mknode(43, a->type, 0, 0);
        u = cast(binop(op, u, b), a->type);
        return mknode(16, a->type, a, u);
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
        a = mknode(20, b->type, a, b);
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
        if (n->op == 1)
            return n->val;
        error(61  , 0);
        xrelease(m);
        return 0;
    }
    xrelease(m);
    return n->val;
}

 

struct Dcl {
    int n;
    int kind[12];
    int len[12];
    struct Type *ft[12];
    char name[64];
};

static struct Param *paramlist(int *variadic, int *oldstyle);

static int isnested(void)
{
    int p;
    struct Sym *s;
    p = peek();
    if (p == '*' || p == '(')
        return 1;
    if (p == 256) {
        s = lookup(peekname());
        return !(s && s->kind == 4);
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
    while (tok == '*' || tok == 304 || tok == 330) {
        if (tok == '*')
            nstars++;
        next();
    }
    if (tok == '(' && isnested()) {
        next();
        dcl(d);
        expect(')', ")");
    } else if (tok == 256) {
        strcpy(d->name, tokname);
        next();
    }
    for (;;) {
        if (tok == '[') {
            next();
            if (d->n >= 12)
                fatal(62  , 0);
            d->kind[d->n] = 11;
            d->len[d->n] = -1;
            if (tok != ']')
                d->len[d->n] = constexpr();
            expect(']', "]");
            d->n++;
        } else if (tok == '(') {
            next();
            pl = paramlist(&variadic, &oldstyle);
            ft = mktype(14, 2, 2);
            ft->params = pl;
            ft->variadic = variadic;
            ft->oldstyle = oldstyle;
            if (d->n >= 12)
                fatal(62  , 0);
            d->kind[d->n] = 14;
            d->ft[d->n] = ft;
            d->n++;
        } else
            break;
    }
    for (i = 0; i < nstars; i++) {
        if (d->n >= 12)
            fatal(62  , 0);
        d->kind[d->n++] = 10;
    }
}

static struct Type *applydcl(struct Type *t, struct Dcl *d)
{
    int i;
    struct Type *f;
    for (i = d->n - 1; i >= 0; i--) {
        if (d->kind[i] == 10)
            t = ptrto(t);
        else if (d->kind[i] == 11) {
            if (t->kind == 14)
                error(63  , 0);
            t = arrayof(t, d->len[i]);
        } else {
            f = d->ft[i];
            if (t->kind == 14 || t->kind == 11)
                error(64  , 0);
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
    char name[64];
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
    char name[64];
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
    if (tok == 329 && peek() == ')') {
        next();
        next();
        return 0;
    }
    for (;;) {
        if (tok == 282) {
            next();
            *variadic = 1;
            break;
        }
        t = declspec(&sc);
        t = declarator(t, name);
        if (t->kind == 11)
            t = ptrto(t->base);
        else if (t->kind == 14)
            t = ptrto(t);
        if (tentative) {
            p = (struct Param *)xalloc(sizeof(struct Param));
            p->name = 0;
            if (name[0]) {           
                p->name = xalloc(strlen(name) + 1);
                strcpy(p->name, name);
            }
        } else {
            p = (struct Param *)palloc(sizeof(struct Param));
            p->name = 0;
            if (name[0]) {           
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
    char tag[64];
    char name[64];
    int off;
    int size;
    int sc;
    next();
    tag[0] = 0;
    if (tok == 256) {
        strcpy(tag, tokname);
        next();
    }
    t = 0;
    if (tok != '{') {
        if (!tag[0]) {
            error(65  , 0);
            return ty_int;
        }
        s = lookuptag(tag);
        if (s)
            return s->type;
        t = mktype(isunion ? 13 : 12, -1, 2);
        t->tag = pstrdup(tag);
        s = addsym(tag, 6, t);
        return t;
    }
    if (tag[0]) {
        s = lookuptag(tag);
        if (s && s->level == level && s->type->size < 0)
            t = s->type;
        else if (s && s->level == level)
            error(66  , tag);
    }
    if (!t) {
        t = mktype(isunion ? 13 : 12, -1, 2);
        if (tag[0]) {
            t->tag = pstrdup(tag);
            addsym(tag, 6, t);
        }
    }
    next();
    off = 0;
    size = 0;
    last = 0;
    while (tok != '}' && tok != 0) {
        base = declspec(&sc);
        if (tok == ';') {                
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
            if (ft->size < 0 || ft->kind == 14)
                error(67  , name);
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
    if (tok == 256) {
        s = lookuptag(tokname);
        if (!s)
            addsym(tokname, 6, ty_int);
        next();
    }
    if (tok != '{')
        return ty_int;
    next();
    v = 0;
    while (tok == 256) {
        s = addsym(tokname, 5, ty_int);
        next();
        if (tok == '=') {
            next();
            v = constexpr();
        }
        s->offset = v;
        v = ((((v + 1) & 65535) ^ 32768) - 32768);
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
        case 326: case 311: case 323:
            *sclass = tok;
            next();
            continue;
        case 300: case 318: case 304: case 330:
            next();
            continue;
        case 329: case 303: case 316: case 312: case 308:
            base = tok;
            next();
            continue;
        case 317:
            nlong++;
            next();
            continue;
        case 320:
            nshort++;
            next();
            continue;
        case 328:
            uns = 1;
            next();
            continue;
        case 321:
            sgn = 1;
            next();
            continue;
        case 324:
        case 327:
            t = structspec(tok == 327);
            continue;
        case 310:
            t = enumspec();
            continue;
        case 256:
            if (!t && !base && !nlong && !nshort && !uns && !sgn) {
                s = lookup(tokname);
                if (s && s->kind == 4) {
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
    case 329: return ty_void;
    case 303: return uns ? ty_uchar : ty_char;
    case 312:
        if (!insys)
            usesfloat = 1;
        return ty_float;
    case 308:
        if (!insys)
            usesfloat = 1;
        return nlong ? ty_ldouble : ty_double;
    }
    if (nlong)
        return uns ? ty_ulong : ty_long;
    return uns ? ty_uint : ty_int;
}

 

static struct Node *elem(struct Node *lv, int off, struct Type *t)
{
    struct Node *m;
    m = mknode(8, t, lv, 0);
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
    if (t->kind == 11) {
        if (tok == 259 && (t->base->kind == 1 || t->base->kind == 2)) {
            m = xmark();
            n = primary();
            if (t->len < 0) {
                t->len = n->slen;
                t->size = n->slen;
            } else if (n->slen - 1 > t->len)
                error(68  , 0);
            ir_discard(mknode(15, t, lv, n));
            xrelease(m);
            return;
        }
        if (tok != '{') {
            error(69  , 0);
            return;
        }
        next();
        i = 0;
        while (tok != '}' && tok != 0) {
            if (t->len >= 0 && i >= t->len)
                error(70  , 0);
            init1(elem(lv, ((((i * t->base->size) & 65535) ^ 32768) - 32768), t->base), t->base, global);
            i++;
            if (tok != ',')
                break;
            next();
        }
        expect('}', "}");
        if (t->len < 0) {
            t->len = i;
            t->size = ((((i * t->base->size) & 65535) ^ 32768) - 32768);
        }
        return;
    }
    if (t->kind == 12 || t->kind == 13) {
        if (tok != '{') {
            m = xmark();
            n = assign();
            ir_discard(mknode(15, t, lv, n));
            xrelease(m);
            return;
        }
        next();
        f = t->fields;
        while (tok != '}' && tok != 0) {
            if (!f) {
                error(70  , 0);
                break;
            }
            init1(elem(lv, f->offset, f->type), f->type, global);
            f = t->kind == 13 ? 0 : f->next;
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
    ir_discard(mknode(15, t, lv, cast(n, t)));
    xrelease(m);
    if (brace)
        expect('}', "}");
}

 

static struct Sym *label(char *name)
{
    struct Sym *s;
    for (s = labels; s; s = s->next)
        if (strcmp(s->name, name) == 0)
            return s;
    s = (struct Sym *)falloc(sizeof(struct Sym));
    s->name = falloc(strlen(name) + 1);
    strcpy(s->name, name);
    s->kind = 7;
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
    char name[64];
    int sc;
    base = declspec(&sc);
    if (tok == ';') {
        next();
        return;
    }
    for (;;) {
        t = declarator(base, name);
        if (!name[0])
            error(71  , 0);
        if (sc == 326)
            addsym(name, 4, t);
        else if (t->kind == 14 || sc == 311) {
            s = lookup(name);
            if (!s || s->level != 0) {
                int save;
                save = level;
                level = 0;
                s = addsym(name, t->kind == 14 ? 3 : 1, t);
                level = save;
                if (t->kind != 14)
                    s->offset = -1;      
            }
        } else if (sc == 323) {
            s = addsym(name, 1, t);
            s->isstatic = 1;
            if (tok == '=') {
                next();
                if (t->kind == 11 && t->len < 0 && tok == 259) {
                    t->len = toklen;
                    t->size = toklen;
                }
                s->offset = t->size >= 0 ? allocglobal(t) : 0;
                lv = mknode(4, t, 0, 0);
                lv->sym = s;
                ir_initbegin();
                initializer(lv, t, 1);
                ir_initend();
                if (s->offset == 0)
                    s->offset = allocglobal(t);
            } else
                s->offset = allocglobal(t);
        } else {
            if (tok == '=' && t->kind == 11 && t->len < 0) {
                next();
                if (tok != 259)
                    error(72  , name);
                else {
                    t->len = toklen;
                    t->size = toklen;
                }
                s = addsym(name, 2, t);
                s->offset = alloclocal(t);
                lv = mknode(4, t, 0, 0);
                lv->sym = s;
                initializer(lv, t, 0);
            } else {
                if (t->size < 0)
                    error(73  , name);
                s = addsym(name, 2, t);
                s->offset = alloclocal(t);
                if (tok == '=') {
                    next();
                    lv = mknode(4, t, 0, 0);
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
    while (tok != '}' && tok != 0) {
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
    case 315:
        next();
        n = condparen();
        l1 = ir_newlabel();
        ir_branch(n, l1, 0);
        xrelease(m);
        curlocal = save;
        statement(brk, cont);
        if (tok == 309) {
            next();
            l2 = ir_newlabel();
            ir_jump(l2);
            ir_setlabel(l1);
            statement(brk, cont);
            ir_setlabel(l2);
        } else
            ir_setlabel(l1);
        break;
    case 331:
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
    case 307:
        next();
        l1 = ir_newlabel();
        l2 = ir_newlabel();
        l3 = ir_newlabel();
        ir_setlabel(l1);
        statement(l3, l2);
        ir_setlabel(l2);
        if (tok != 331)
            error(74  , 0);
        next();
        n = condparen();
        ir_branch(n, l1, 1);
        ir_setlabel(l3);
        expect(';', ";");
        break;
    case 313:
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
    case 325:
        next();
        expect('(', "(");
        n = expr();
        expect(')', ")");
        n = decay(n);
        if (!isintegral(n->type) || islongty(n->type)) {
            if (islongty(n->type))
                n = cast(n, ty_int);
            else
                error(75  , 0);
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
    case 302:
        next();
        t = constexpr();
        expect(':', ":");
        if (!swvals)
            error(76  , 0);
        else {
            int i;
            for (i = 0; i < swn; i++)
                if (swvals[i] == t)
                    error(77  , 0);
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
    case 306:
        next();
        expect(':', ":");
        if (!swvals)
            error(78  , 0);
        else {
            swdef = ir_newlabel();
            ir_setlabel(swdef);
        }
        statement(brk, cont);
        break;
    case 301:
        next();
        if (brk < 0)
            error(79  , 0);
        else
            ir_jump(brk);
        expect(';', ";");
        break;
    case 305:
        next();
        if (cont < 0)
            error(80  , 0);
        else
            ir_jump(cont);
        expect(';', ";");
        break;
    case 319:
        next();
        n = 0;
        if (tok != ';') {
            n = expr();
            if (curft->base->kind == 0)
                error(81  , 0);
            else if (curft->base->kind != 12 && curft->base->kind != 13)
                n = cast(n, curft->base);
        }
        ir_return(n, curft, sretoff);
        ir_jump(exitlab);
        expect(';', ";");
        break;
    case 314:
        next();
        if (tok != 256)
            error(82  , 0);
        else {
            s = label(tokname);
            ir_jump(s->offset);
            next();
        }
        expect(';', ";");
        break;
    default:
        if (tok == 256 && peek() == ':') {
            s = label(tokname);
            if (s->defined)
                error(83  , tokname);
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
    seg = cursegname;            
    ft = fs->type;
    if (fs->defined)
        error(84  , fs->name);
    fs->defined = 1;
    curfn = fs;
    curft = ft;
    labels = 0;
    pushscope();
    np = 0;
    pw = 0;
    for (p = ft->params; p; p = p->next) {
        if (np >= 32)
            fatal(85  , fs->name);
        pv[np++] = p;
        pw = pw + twords(p->type);
    }
    if (ft->variadic)
        pw++;
    sretoff = 0;
    if (ft->base->kind == 12 || ft->base->kind == 13)
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
            s = addsym(p->name, 2, p->type);
            s->offset = off;
        } else if (!ft->oldstyle)
            error(86  , fs->name);
        off = off + twords(p->type);
    }
    if (ft->base->kind == 12 || ft->base->kind == 13) {
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
            error(87  , s->name);
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
    char name[64];
    int sc;
    int m;
    m = xmark();
    base = declspec(&sc);
    if (tok == ';') {
        next();
        return;
    }
    for (;;) {
        sysdecl = insys && sc != 326;
        tentative = sysdecl;
        t = declarator(base, name);
        tentative = 0;
        if (!name[0]) {
            error(71  , 0);
            next();
            return;
        }
        if (sysdecl) {
            if ((sc == 311 || (t->kind == 14 && tok != '{')) && !isref(name)) {
                if (tok != ',')
                    break;               
                next();
                continue;
            }
            t = permtype(t);
        }
        if (sc == 326) {
            addsym(name, 4, t);
        } else if (t->kind == 14) {
            s = lookup(name);
            if (s && s->kind != 3) {
                error(88  , name);
                s = 0;
            }
            if (!s)
                s = addsym(name, 3, t);
            else if (!s->defined && t->params)
                s->type = t;
            if (sc == 323 && !s->isstatic) {
                s->isstatic = 1;
                s->lname = palloc(strlen(modname) + strlen(name) + 2);
                strcpy(s->lname, modname);
                strcat(s->lname, "'");
                strcat(s->lname, name);
            }
            if (tok == '{') {
                if (t != s->type)
                    s->type = t;
                funcdef(s, sc == 323);
                xrelease(m);
                return;
            }
        } else {
            s = lookup(name);
            if (s && (s->kind != 1 || s->level != 0)) {
                error(88  , name);
                s = 0;
            }
            if (!s) {
                s = addsym(name, 1, t);
                s->offset = -1;
                if (sc == 323) {
                    s->isstatic = 1;
                    if (t->size >= 0)
                        s->offset = allocglobal(t);
                }
            } else if (s->type->kind == 11 && s->type->len < 0 && t->len >= 0)
                s->type = t;
            if (sc != 311 && !s->defined)
                s->defined = 1;              
            if (tok == '=') {
                next();
                if (t->kind == 11 && t->len < 0 && tok == 259) {
                    t->len = toklen;
                    t->size = toklen;
                }
                if (s->defined == 2)
                    error(88  , name);
                s->defined = 2;
                s->type = t;
                lv = mknode(4, t, 0, 0);
                lv->sym = s;
                if (s->isstatic && s->offset < 0) {
                     
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

    
#2304 !/home/user/UCSD-C/tinyc/parse.c
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
    char name[64];
    fp = fopen(src, "r");
    if (!fp)
        fatal(25  , src);
    refbits = (unsigned char *)palloc(4096 / 8);
    sys = 0;
    bol = 1;
    depth = 0;
    c = getc(fp);
    while (c != (-1)) {
        if (bol && c == '#') {
             
            while (c != (-1) && c != ' ' && c != '\n')
                c = getc(fp);
            if (c == ' ') {
                c = getc(fp);
                sys = c == '!';
            }
            while (c != (-1) && c != '\n')
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
            while (c != (-1) && c != q && c != '\n') {
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
                if (n < 64 - 1)
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

 
static void declhelper(char *name, struct Type *ret, struct Type *a, struct Type *b)
{
    struct Type *ft;
    struct Param *p;
    struct Sym *s;
    ft = mktype(14, 2, 2);
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
    s = addsym(name, 3, ft);
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
    char name[64];
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
        nofltused = 1;               
}

int compile(char *src, char *ir, char *mod)
{
    FILE *fp;
    modname = mod;
    usesfloat = 0;
    nofltused = 0;
    fp = fopen(src, "r");
    if (!fp)
        fatal(25  , src);
    ir_open(ir, modname);
    scanrefs(src);
    typeinit();
    helpers();
    cursegname = "";
    lexinit(fp);
    next();
    while (tok != 0) {
        external();
    }
    ir_initflush();
    {
         
        struct Sym *g;
        int h;
        for (h = 0; h < 128; h++)
            for (g = htab[h]; g; g = g->next)
                if (g->kind == 1 && !g->isstatic && g->defined) {
                    if (g->type->size < 0)
                        error(73  , g->name);
                    ir_data(g->name, (g->type->size + 1) / 2, g->defined == 2);
                }
    }
    if (usesfloat && !nofltused)
        ir_use("__fltused");
    ir_close(globoff);
    fclose(fp);
    return nerrors == 0;
}
#8 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/ir.c
                    
#21 !/home/user/UCSD-C/tinyc/ir.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#22 !/home/user/UCSD-C/tinyc/ir.c

 
#pragma segment PARSE

static FILE *irout;
static int irlabels;
static int irinit;

 

static struct Type *tseen[64];
static int ntseen;

static void irb(int b)
{
    putc(b & 255, irout);
}

static void irw(int w)
{
    putc(w & 255, irout);
    putc((w >> 8) & 255, irout);
}

static void irs(char *s)
{
    irb(strlen(s));
    while (*s)
        irb(*s++);
}

static void irtype(struct Type *t)
{
    struct Param *p;
    int n;
    for (n = 0; n < ntseen; n++)
        if (tseen[n] == t) {
            irb(255);
            irb(n);
            return;
        }
    if (ntseen < 64)
        tseen[ntseen++] = t;
    irb(t->kind);
    irw(t->size);
    if (t->kind == 10 || t->kind == 11) {
        irw(t->len);
        irtype(t->base);
    } else if (t->kind == 14) {
        irb(t->variadic + 2 * t->oldstyle);
        irtype(t->base);
        n = 0;
        for (p = t->params; p; p = p->next)
            n++;
        irb(n);
        for (p = t->params; p; p = p->next)
            irtype(p->type);
    }
}

static void irnode(struct Node *n)
{
    int mask;
    int i;
    mask = 0;
    if (n->a)
        mask = mask | 1;
    if (n->b)
        mask = mask | 2;
    if (n->c)
        mask = mask | 4;
    if (n->next)
        mask = mask | 8;
    if (n->val)
        mask = mask | 16;
    if (n->val2)
        mask = mask | 32;
    if (n->sym)
        mask = mask | 64;
    irb(n->op);
    irtype(n->type);
    irb(mask);
    if (mask & 16)
        irw(n->val);
    if (mask & 32)
        irw(n->val2);
    if (mask & 64) {
        irb(n->sym->kind);
        irw(n->sym->offset);
        if (n->sym->kind == 3)
            irs(n->sym->lname ? n->sym->lname : n->sym->name);
        else
            irs(n->sym->offset < 0 ? n->sym->name : "");    
    }
    if (n->op == 3 || n->op == 44) {
        irw(n->slen);
        for (i = 0; i < n->slen; i++)
            irb(n->str[i]);
    } else if (n->op == 2) {
        for (i = 0; i < 4; i++)
            irb(n->fimg[i]);
    }
    if (mask & 1)
        irnode(n->a);
    if (mask & 2)
        irnode(n->b);
    if (mask & 4)
        irnode(n->c);
    if (mask & 8)
        irnode(n->next);
}

static void ircur(void)
{
    ntseen = 0;
    irw(irinit ? -1 : curlocal);
}

void ir_open(char *name, char *modname)
{
    irout = fopen(name, "wb");
    if (!irout)
        fatal(24  , name);
    fputs("TCIR", irout);
    irb('H');
    irs(modname);
}

void ir_close(int globalwords)
{
    irb('G');
    irw(globalwords);
    irb('Q');
    fclose(irout);
}

void ir_data(char *name, int words, int strong)
{
    irb('d');
    irb(strong);
    irs(name);
    irw(words);
}

void ir_use(char *name)
{
    irb('u');
    irs(name);
}

void ir_funcbegin(void)
{
    irlabels = 0;
    irb('F');
    irw(nparamwords);
    irw(scratch);
}

int ir_newlabel(void)
{
    if (irlabels >= 300)
        fatal(89  , 0);
    return irlabels++;
}

void ir_setlabel(int l)
{
    irb('L');
    irw(l);
}

void ir_jump(int l)
{
    irb('J');
    irw(l);
}

void ir_branch(struct Node *n, int l, int jumpif)
{
    irb('B');
    ircur();
    irb(jumpif);
    irw(l);
    irnode(n);
}

void ir_discard(struct Node *n)
{
    irb('D');
    ircur();
    irnode(n);
}

void ir_valuestl(struct Node *n, int t)
{
    irb('V');
    ircur();
    irw(t);
    irnode(n);
}

void ir_return(struct Node *n, struct Type *ft, int sretoff)
{
    ntseen = 0;
    irb('R');
    ircur();
    irw(sretoff);
    irtype(ft);
    irb(n != 0);
    if (n)
        irnode(n);
}

void ir_switch(int t, int *vals, int *labs, int n, int deflab)
{
    int i;
    irb('S');
    irw(t);
    irw(n);
    for (i = 0; i < n; i++) {
        irw(vals[i]);
        irw(labs[i]);
    }
    irw(deflab);
}

void ir_funcend(char *name, struct Type *ft, int exitlab, int isstatic, char *seg)
{
    ntseen = 0;
    irb('E');
    irw(maxlocal);
    irb(isstatic);
    irs(name);
    irs(seg);
    irw(exitlab);
    irtype(ft);
}

void ir_initbegin(void)
{
    if (irinit++ == 0)
        irb('I');
}

void ir_initend(void)
{
    if (--irinit == 0)
        irb('i');
}

void ir_initflush(void)
{
    irb('Z');
}

 
#pragma segment GEN

static FILE *irin;
static struct Type *rseen[64];
static int nrseen;
static int *lmap;
static int nlmap;

static int rb(void)
{
    int c;
    c = getc(irin);
    if (c == (-1))
        fatal(90  , 0);
    return c;
}

static int rw(void)
{
    int lo;
    lo = rb();
    return ((((lo + rb() * 256) & 65535) ^ 32768) - 32768);
}

static char *rstr(void)
{
    int n;
    int i;
    char *s;
    n = rb();
    s = xalloc(n + 1);
    for (i = 0; i < n; i++)
        s[i] = rb();
    s[n] = 0;
    return s;
}

static struct Type *rtype(void)
{
    struct Type *t;
    struct Param *p;
    struct Param *last;
    int n;
    int i;
    int f;
    n = rb();
    if (n == 255)
        return rseen[rb()];
    t = (struct Type *)xalloc(sizeof(struct Type));
    if (nrseen < 64)
        rseen[nrseen++] = t;
    t->kind = n;
    t->size = rw();
    t->len = -1;
    t->align = t->kind == 1 || t->kind == 2 ? 1 : 2;
    if (t->kind == 10 || t->kind == 11) {
        t->len = rw();
        t->base = rtype();
    } else if (t->kind == 14) {
        f = rb();
        t->variadic = f & 1;
        t->oldstyle = (f >> 1) & 1;
        t->base = rtype();
        n = rb();
        last = 0;
        for (i = 0; i < n; i++) {
            p = (struct Param *)xalloc(sizeof(struct Param));
            p->type = rtype();
            if (last)
                last->next = p;
            else
                t->params = p;
            last = p;
        }
    }
    return t;
}

static struct Node *rnode(void)
{
    struct Node *n;
    struct Sym *s;
    int mask;
    int i;
    n = (struct Node *)xalloc(sizeof(struct Node));
    n->op = rb();
    n->type = rtype();
    mask = rb();
    if (mask & 16)
        n->val = rw();
    if (mask & 32)
        n->val2 = rw();
    if (mask & 64) {
        s = (struct Sym *)xalloc(sizeof(struct Sym));
        s->kind = rb();
        s->offset = rw();
        s->name = rstr();
        n->sym = s;
    }
    if (n->op == 3 || n->op == 44) {
        n->slen = rw();
        n->str = xalloc(n->slen + 1);
        for (i = 0; i < n->slen; i++)
            n->str[i] = rb();
    } else if (n->op == 2) {
        n->fimg = (unsigned char *)xalloc(4);
        for (i = 0; i < 4; i++)
            n->fimg[i] = rb();
    }
    if (mask & 1)
        n->a = rnode();
    if (mask & 2)
        n->b = rnode();
    if (mask & 4)
        n->c = rnode();
    if (mask & 8)
        n->next = rnode();
    return n;
}

 
static int lab(int l)
{
    if (l < 0 || l >= nlmap)
        fatal(91  , 0);
    if (lmap[l] < 0)
        lmap[l] = newlabel();
    return lmap[l];
}

static void setcur(void)
{
    int c;
    c = rw();
    if (c >= 0) {
        curlocal = c;
        if (curlocal > maxlocal)
            maxlocal = curlocal;
    }
}

int gencode(char *irname, char *obj)
{
    char magic[5];
    char *modname;
    char *name;
    char *seg;
    int c;
    int i;
    int m;
    int t;
    int n;
    int l;
    int jumpif;
    int ml;
    int st;
    int *vals;
    int *labs;
    struct Node *e;
    struct Type *ft;
    irin = fopen(irname, "rb");
    if (!irin)
        fatal(25  , irname);
    for (i = 0; i < 4; i++)
        magic[i] = rb();
    magic[4] = 0;
    if (strcmp(magic, "TCIR") != 0 || rb() != 'H')
        fatal(92  , irname);
    objout = fopen(obj, "wb");
    if (!objout)
        fatal(24  , obj);
    nlmap = 300;
    lmap = (int *)malloc(nlmap * sizeof(int));
    vals = (int *)malloc(1024 * sizeof(int));
    labs = (int *)malloc(1024 * sizeof(int));
    if (!lmap || !vals || !labs)
        fatal(2  , 0);
    m = xmark();
    modname = pstrdup(rstr());
    xrelease(m);
    gen_objheader(modname);
    for (;;) {
        m = xmark();
        nrseen = 0;
        c = rb();
        switch (c) {
        case 'F':
            gen_funcbegin();
            nparamwords = rw();
            scratch = rw();
            curlocal = scratch;
            maxlocal = scratch;
            for (i = 0; i < nlmap; i++)
                lmap[i] = -1;
            break;
        case 'L':
            setlabel(lab(rw()));
            break;
        case 'J':
            jump(lab(rw()));
            break;
        case 'B':
            setcur();
            jumpif = rb();
            l = lab(rw());
            branch(rnode(), l, jumpif);
            break;
        case 'D':
            setcur();
            gen_discard(rnode());
            break;
        case 'V':
            setcur();
            t = rw();
            gen_value(rnode());
            gen_stl(t);
            break;
        case 'R':
            setcur();
            st = rw();
            ft = rtype();
            e = rb() ? rnode() : 0;
            gen_return(e, ft, st);
            break;
        case 'S':
            t = rw();
            n = rw();
            if (n > 1024)
                fatal(93  , 0);
            for (i = 0; i < n; i++) {
                vals[i] = rw();
                labs[i] = lab(rw());
            }
            gen_switch(t, vals, labs, n, lab(rw()));
            break;
        case 'E':
            ml = rw();
            if (ml > maxlocal)
                maxlocal = ml;
            st = rb();
            name = rstr();
            seg = rstr();
            l = lab(rw());
            ft = rtype();
            gen_funcend(name, ft, l, st, seg);
            break;
        case 'I':
            gen_initbegin();
            break;
        case 'i':
            gen_initend();
            break;
        case 'Z':
            gen_initflush();
            break;
        case 'd':
            st = rb();
            name = rstr();
            gen_objdata(name, rw(), st);
            break;
        case 'u':
            gen_objuse(rstr());
            break;
        case 'G':
            gen_objend(rw());
            break;
        case 'Q':
            fclose(irin);
            fclose(objout);
            return nerrors == 0;
        default:
            fatal(94  , 0);
        }
        xrelease(m);
    }
}
#9 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/gen.c
           
#12 !/home/user/UCSD-C/tinyc/gen.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#13 !/home/user/UCSD-C/tinyc/gen.c
#pragma segment GEN

 





























































 





struct Emit {
    unsigned char *code;
    int max;
    int pc;
    int *labpos;
    int maxlab;
    int nlab;
    int *fixpos;
    int *fixlab;
    int maxfix;
    int nfix;
    int *relpos;
    int *reltype;
    char **relname;
    int maxrel;
    int nrel;
    int curlocal;
    int maxlocal;
    int nparam;
    int scratch;
};

static struct Emit fe;           
static struct Emit ie;           
static struct Emit *E;
static int ninit;
static int ininit;


static int lvtemp;               
static struct Node *lvnode;      

static void setupemit(struct Emit *e, int max, int maxlab, int maxfix, int maxrel)
{
    e->max = max;
    e->code = (unsigned char *)malloc(max);
    e->maxlab = maxlab;
    e->labpos = (int *)malloc(maxlab * sizeof(int));
    e->maxfix = maxfix;
    e->fixpos = (int *)malloc(maxfix * sizeof(int));
    e->fixlab = (int *)malloc(maxfix * sizeof(int));
    e->maxrel = maxrel;
    e->relpos = (int *)malloc(maxrel * sizeof(int));
    e->reltype = (int *)malloc(maxrel * sizeof(int));
    e->relname = (char **)malloc(maxrel * sizeof(char *));
    if (!e->code || !e->labpos || !e->fixlab || !e->relname)
        fatal(2  , 0);
    e->pc = 0;
    e->nlab = 0;
    e->nfix = 0;
    e->nrel = 0;
}

 
static void saveframe(void)
{
    E->curlocal = curlocal;
    E->maxlocal = maxlocal;
    E->nparam = nparamwords;
    E->scratch = scratch;
}

static void loadframe(void)
{
    curlocal = E->curlocal;
    maxlocal = E->maxlocal;
    nparamwords = E->nparam;
    scratch = E->scratch;
}

 

static void ob(int b)
{
    if (E->pc >= E->max)
        fatal(95  , 0);
    E->code[E->pc++] = b & 255;
}

static void big(int v)
{
    if (v >= 0 && v < 128)
        ob(v);
    else {
        ob(128 | ((v >> 8) & 127));
        ob(v & 255);
    }
}

static void opbig(int op, int v)
{
    ob(op);
    big(v);
}

static void ldc(int v)
{
    v = ((((v) & 65535) ^ 32768) - 32768);
    if (v >= 0 && v < 128)
        ob(v);
    else if (v < 0 && v > -128) {
        ob(-v);
        ob(0x91);
    } else {
        ob(0xC7);
        ob(v & 255);
        ob((v >> 8) & 255);
    }
}

static void ldl(int off)
{
    if (off >= 1 && off <= 16)
        ob(0xD7 + off);
    else
        opbig(0xCA, off);
}

void gen_stl(int off)
{
    opbig(0xCC, off);
}

static void lla(int off)
{
    opbig(0xC6, off);
}

static void ldo(int off)
{
    if (off >= 1 && off <= 16)
        ob(0xE7 + off);
    else
        opbig(0xA9, off);
}

static void sro(int off)
{
    opbig(0xAB, off);
}

static void lao(int off)
{
    opbig(0xA5, off);
}

static void ind(int k)
{
    if (k == 0)
        ob(0xF8);
    else if (k > 0 && k < 8)
        ob(0xF8 + k);
    else
        opbig(0xA3, k);
}

static void addconst(int bytes)
{
    if (bytes == 0)
        return;
    if (bytes > 0 && (bytes & 1) == 0)
        opbig(0xA2, bytes / 2);
    else {
        ldc(bytes);
        ob(0x82);
    }
}

static void csp(int n)
{
    ob(0x9E);
    ob(n);
}

 

struct Name {
    char *s;
    struct Name *next;
};
static struct Name *names[64];

static char *intern(char *s)
{
    struct Name *n;
    int h;
    h = hashstr(s) & (64 - 1);
    for (n = names[h]; n; n = n->next)
        if (strcmp(n->s, s) == 0)
            return n->s;
    n = (struct Name *)palloc(sizeof(struct Name));
    n->s = pstrdup(s);
    n->next = names[h];
    names[h] = n;
    return n->s;
}

static void reloc(int type, char *name)
{
    name = intern(name);
    if (E->nrel >= E->maxrel)
        fatal(96  , 0);
    E->relpos[E->nrel] = E->pc;
    E->reltype[E->nrel] = type;
    E->relname[E->nrel] = name;
    E->nrel++;
}

int newtemp(int words)
{
    curlocal = curlocal + words;
    if (curlocal > maxlocal)
        maxlocal = curlocal;
    return curlocal - words + 1;
}

 
static void drop(int n)
{
    while (n-- > 0)
        gen_stl(scratch);
}

 

int newlabel(void)
{
    if (E->nlab >= E->maxlab)
        fatal(89  , 0);
    E->labpos[E->nlab] = -1;
    return E->nlab++;
}

void setlabel(int l)
{
    E->labpos[l] = E->pc;
}

static void jmpop(int op, int l)
{
    ob(op);
    if (E->nfix >= E->maxfix)
        fatal(97  , 0);
    E->fixpos[E->nfix] = E->pc;
    E->fixlab[E->nfix] = l;
    E->nfix++;
    ob(0);
}

void jump(int l)
{
    jmpop(0xB9, l);
}

 
static void caseword(int l)
{
    if (E->nfix >= E->maxfix)
        fatal(97  , 0);
    E->fixpos[E->nfix] = E->pc;
    E->fixlab[E->nfix] = -2 - l;
    E->nfix++;
    ob(0);
    ob(0);
}

 

static int valwords(struct Type *t)
{
    if (t->kind == 12 || t->kind == 13 || t->kind == 11)
        return 1;            
    if (t->kind == 0)
        return 0;
    return twords(t);
}

static int ischar(struct Type *t)
{
    return t->kind == 1 || t->kind == 2;
}

static int ismulti(struct Type *t)
{
    return isfloatty(t) || islongty(t);
}

 





struct LV {
    int kind;
    int off;                     
    int boff;                    
    struct Node *ptr;            
    char *name;                  
};

   
#387 !/home/user/UCSD-C/tinyc/gen.c
static void gglob(int op, struct LV *lv, int add)
{
    int v;
    ob(op);
    if (lv->name) {
        reloc(4, lv->name);
        v = add;
    } else {
        reloc(3, "");
        v = lv->off + add;
    }
    ob(128 | ((v >> 8) & 127));
    ob(v & 255);
}

static void lvinfo(struct Node *n, struct LV *lv)
{
    struct Node *p;
    lv->name = 0;
    if (n->op == 4) {
        lv->kind = n->sym->kind == 2 ? 1 : 2;
        lv->off = n->sym->offset;
        lv->boff = 0;
        lv->ptr = 0;
        lv->name = lv->kind == 2 && lv->off < 0 ? n->sym->name : 0;
        return;
    }
    if (n->op == 8) {
        lvinfo(n->a, lv);
        lv->boff = ((((lv->boff + n->val) & 65535) ^ 32768) - 32768);
        return;
    }
    if (n->op == 9) {
        p = n->a;
        lv->kind = 3;
        lv->off = 0;
        lv->boff = 0;
        lv->ptr = p;
        if (p->op == 23 && p->b->op == 1 && p->type->kind == 10) {
            lv->ptr = p->a;
            lv->boff = p->b->val;
        }
        return;
    }
    if (n->op == 6 || n->op == 15 || n->op == 19 || n->op == 20) {
         
        lv->kind = 3;
        lv->off = 0;
        lv->boff = 0;
        lv->ptr = n;
        return;
    }
    error(57  , 0);
    lv->kind = 1;
    lv->off = scratch;
    lv->boff = 0;
    lv->ptr = 0;
}

static void gen_ptrvalue(struct Node *p)
{
    if (p->type->kind == 12 || p->type->kind == 13)
        gen_value(p);            
    else
        gen_value(p);
}

 
static void gen_addr(struct Node *n)
{
    struct LV lv;
    if (n->op == 3 || n->op == 5) {
        gen_value(n);
        return;
    }
    lvinfo(n, &lv);
    if (lv.kind == 1) {
        lla(lv.off + (lv.boff >> 1));
        addconst(lv.boff & 1);
    } else if (lv.kind == 2) {
        gglob(0xA5, &lv, lv.boff >> 1);
        addconst(lv.boff & 1);
    } else {
        gen_ptrvalue(lv.ptr);
        addconst(lv.boff);
    }
}

 
static void gen_byteaddr(struct Node *n)
{
    struct LV lv;
    struct Node *p;
    lvinfo(n, &lv);
    if (lv.kind == 1) {
        lla(lv.off + (lv.boff >> 1));
        ldc(lv.boff & 1);
    } else if (lv.kind == 2) {
        gglob(0xA5, &lv, lv.boff >> 1);
        ldc(lv.boff & 1);
    } else {
        p = lv.ptr;
        if (lv.boff == 0 && p->op == 23 && p->type->kind == 10 && ischar(p->type->base)) {
            gen_value(p->a);
            gen_value(p->b);
        } else {
            gen_ptrvalue(p);
            ldc(lv.boff);
        }
    }
}

static void signext(void)
{
    reloc(1, "__sx");
    ob(0xCD);
    ob(0);
    ob(0);
}

static void loadchar(struct Type *t)
{
    ob(0xBE);
    if (t->kind == 1)
        signext();
}

static int islv(struct Node *n)
{
    return n->op == 4 || n->op == 8 || n->op == 9;
}

  
#521 !/home/user/UCSD-C/tinyc/gen.c
static void gen_lowbyte(struct Node *n)
{
    while (n->op == 14 && isword(n->type) && isword(n->a->type))
        n = n->a;
    if (islv(n) && ischar(n->type)) {
        gen_byteaddr(n);
        ob(0xBE);
    } else
        gen_value(n);
}

 
static void gen_load(struct Node *n)
{
    struct LV lv;
    struct Type *t;
    int w;
    t = n->type;
    if (t->kind == 11 || t->kind == 12 || t->kind == 13) {
        gen_addr(n);
        return;
    }
    if (ischar(t)) {
        gen_byteaddr(n);
        loadchar(t);
        return;
    }
    lvinfo(n, &lv);
    w = twords(t);
    if (w == 1) {
        if (lv.kind == 1 && !(lv.boff & 1))
            ldl(lv.off + lv.boff / 2);
        else if (lv.kind == 2 && !(lv.boff & 1))
            gglob(0xA9, &lv, lv.boff / 2);
        else if (lv.kind == 3 && !(lv.boff & 1) && lv.boff >= 0) {
            gen_ptrvalue(lv.ptr);
            ind(lv.boff / 2);
        } else {
            gen_addr(n);
            ind(0);
        }
        return;
    }
    gen_addr(n);
    ob(0xBC);
    ob(w);
}

 
static void storepre(struct Node *n)
{
    struct LV lv;
    struct Type *t;
    t = n->type;
    if (ischar(t)) {
        gen_byteaddr(n);
        return;
    }
    lvinfo(n, &lv);
    if (twords(t) == 1 && (lv.kind == 1 || lv.kind == 2) && !(lv.boff & 1))
        return;
    gen_addr(n);
}

 
static void storepost(struct Node *n)
{
    struct LV lv;
    struct Type *t;
    t = n->type;
    if (ischar(t)) {
        ob(0xBF);
        return;
    }
    lvinfo(n, &lv);
    if (twords(t) == 1) {
        if (lv.kind == 1 && !(lv.boff & 1))
            gen_stl(lv.off + lv.boff / 2);
        else if (lv.kind == 2 && !(lv.boff & 1))
            gglob(0xAB, &lv, lv.boff / 2);
        else
            ob(0x9A);
        return;
    }
    ob(0xBD);
    ob(twords(t));
}

static int simplelv(struct Node *n)
{
    struct LV lv;
    lvinfo(n, &lv);
    return lv.kind != 3;
}

 
static void loadvia(int ta, struct Type *t)
{
    ldl(ta);
    if (ischar(t)) {
        ldc(0);
        loadchar(t);
    } else if (twords(t) == 1)
        ind(0);
    else {
        ob(0xBC);
        ob(twords(t));
    }
}

static void storeviapre(int ta, struct Type *t)
{
    ldl(ta);
    if (ischar(t))
        ldc(0);
}

static void storeviapost(struct Type *t)
{
    if (ischar(t))
        ob(0xBF);
    else if (twords(t) == 1)
        ob(0x9A);
    else {
        ob(0xBD);
        ob(twords(t));
    }
}

 

static void gen_cast(struct Node *n)
{
    struct Type *t;
    int fk;
    t = n->type;
    fk = n->a->type->kind;
    if (t->kind == 0) {
        gen_discard(n->a);
        return;
    }
    gen_value(n->a);
    if (isfloatty(t) && !isfloatty(n->a->type)) {
        if (!islongty(n->a->type))
            ob(0x8A);
        return;
    }
    if (!isfloatty(t) && isfloatty(n->a->type)) {
        csp(23);
        fk = 3;
    }
    if (t->kind == 2 && fk != 2) {
        ldc(255);
        ob(0x84);
    } else if (t->kind == 1 && fk != 1)
        signext();
}

 

static void gen_call(struct Node *n, int want)
{
    struct Type *ft;
    struct Node *a;
    struct Param *p;
    struct Sym *fs;
    int pw;
    int rw;
    int sret;
    int blk;
    int bw;
    int pos;
    int t;
    int L;
    int A;
    ft = n->a->type;
    if (ft->kind == 10)
        ft = ft->base;
    fs = n->a->op == 5 ? n->a->sym : 0;
    rw = retwords(ft);
    sret = 0;
    pw = 0;
    if (ft->base->kind == 12 || ft->base->kind == 13) {
        sret = newtemp((ft->base->size + 1) / 2);
        lla(sret);
        pw++;
    }
     
    blk = 0;
    if (ft->variadic) {
        p = ft->params;
        a = n->b;
        while (p && a) {
            p = p->next;
            a = a->next;
        }
        bw = 0;
        for (pos = 0; a; a = a->next)
            bw = bw + (a->type->kind == 12 || a->type->kind == 13 ? (a->type->size + 1) / 2 : twords(a->type));
        blk = newtemp(bw > 0 ? bw : 1);
        p = ft->params;
        a = n->b;
        while (p && a) {
            p = p->next;
            a = a->next;
        }
        pos = blk;
        for (; a; a = a->next) {
            if (a->type->kind == 12 || a->type->kind == 13) {
                lla(pos);
                gen_value(a);
                opbig(0xA8, (a->type->size + 1) / 2);
                pos = pos + (a->type->size + 1) / 2;
            } else if (twords(a->type) == 1) {
                gen_value(a);
                gen_stl(pos);
                pos++;
            } else {
                lla(pos);
                gen_value(a);
                ob(0xBD);
                ob(twords(a->type));
                pos = pos + twords(a->type);
            }
        }
    }
    p = ft->params;
    for (a = n->b; a; a = a->next) {
        if (ft->variadic && !p)
            break;
        if (a->type->kind == 12 || a->type->kind == 13) {
            gen_value(a);
            ob(0xBC);
            ob((a->type->size + 1) / 2);
            pw = pw + (a->type->size + 1) / 2;
        } else {
            gen_value(a);
            pw = pw + twords(a->type);
        }
        if (p)
            p = p->next;
    }
    if (ft->variadic) {
        lla(blk);
        pw++;
    }
    while (pw < rw) {
        ldc(0);
        pw++;
    }
    if (fs) {
        reloc(1, fs->name);
        ob(0xCD);
        ob(0);
        ob(0);
    } else {
         
        gen_value(n->a);
        t = newtemp(1);
        gen_stl(t);
        ob(0xD0);
        ob(0);
        A = E->pc;
        L = t <= 16 ? 1 : (t < 128 ? 2 : 3);
        ldc(4 + L);
        ob(0x82);
        ldl(t);
        ob(0x9A);
        if (E->pc != A + 3 + L)
            fatal(98  , 0);
        ob(0xCD);
        ob(0);
        ob(0);
    }
    if (!want)
        drop(rw);
}

 

static void gen_intrinsic(struct Node *n, int want)
{
    struct Node *a;
    int code;
    int num;
    code = n->val;
    a = n->a;
    if (code == 3) {             
        ldl(n->val2);
        if (!want)
            drop(1);
        return;
    }
    if (code == 10) {            
        ldc(1);
        ldc(1);
        csp(4);
        return;
    }
    if (code == 9 || code == 11) {   
        ob(code == 9 ? 0xB6 : 0xB2);
        ob(2);
        big(a->val);
        if (!want)
            drop(1);
        return;
    }
    num = 0;
    if (code >= 4) {
        num = a->val;
        a = a->next;
    }
    for (; a; a = a->next)
        gen_value(a);
    switch (code) {
    case 1: ob(0x86); break;
    case 2: ob(0x8E); break;
    case 4: case 5: case 6: csp(num); break;
    case 7: case 8:
        ob(0xCD);
        ob(0);
        ob(num);
        break;
    }
    if (!want)
        drop(valwords(n->type));
}

 

static int isfconst(struct Node *n)
{
    return n->op == 2;
}

static void gen_fconst(unsigned char *f)
{
    ob(0xB3);
    ob(2);
    if ((E->pc & 1) == 1)
        ob(0);
    ob(f[2]);
    ob(f[3]);
    ob(f[0]);
    ob(f[1]);
}

static void gen_str(struct Node *n)
{
    int i;
    if (n->slen > 255)
        error(99  , 0);
    ob(0xD0);
    ob(n->slen);
    for (i = 0; i < n->slen; i++)
        ob(n->str[i]);
}

static int relop(int op, int isfloat, int invert)
{
    if (invert) {
        switch (op) {
        case 33: op = 34; break;
        case 34: op = 33; break;
        case 35: op = 38; break;
        case 36: op = 37; break;
        case 37: op = 36; break;
        case 38: op = 35; break;
        }
    }
    switch (op) {
    case 33: return isfloat ? 0xAF : 0xC3;
    case 34: return isfloat ? 0xB7 : 0xCB;
    case 35: return isfloat ? 0xB5 : 0xC9;
    case 36: return isfloat ? 0xB4 : 0xC8;
    case 37: return isfloat ? 0xB1 : 0xC5;
    }
    return isfloat ? 0xB0 : 0xC4;
}

 
static int charsafe(struct Node *n, struct Node *c)
{
    while (n->op == 14 && isword(n->a->type))
        n = n->a;
    return n->type->kind == 1 && c->op == 1 && c->val >= 0 && c->val < 128;
}

 
static void gen_cmpops(struct Node *n)
{
    int uns;
    int eq;
    struct Node *a;
    struct Node *b;
    a = n->a;
    b = n->b;
    eq = n->op == 33 || n->op == 34;
    uns = !eq && (isunsignedty(a->type) || a->type->kind == 10);
    if (eq && charsafe(a, b))
        gen_lowbyte(a);
    else
        gen_value(a);
    if (uns) {
        ldc(-32768);
        ob(0x82);
    }
    if (uns && b->op == 1)
        ldc(b->val ^ -32768);
    else {
        if (eq && charsafe(b, a))
            gen_lowbyte(b);
        else
            gen_value(b);
        if (uns) {
            ldc(-32768);
            ob(0x82);
        }
    }
}

static void emitrelop(int op, struct Type *t, int invert)
{
    int o;
    o = relop(op, isfloatty(t), invert);
    ob(o);
    if (isfloatty(t))
        ob(2);
}

void branch(struct Node *n, int l, int jumpif)
{
    int skip;
    struct Type *t;
    switch (n->op) {
    case 1:
        if (!islongty(n->type)) {
            if ((n->val != 0) == (jumpif != 0))
                jump(l);
            return;
        }
        break;
    case 12:
        branch(n->a, l, !jumpif);
        return;
    case 21:
        if (!jumpif) {
            branch(n->a, l, 0);
            branch(n->b, l, 0);
        } else {
            skip = newlabel();
            branch(n->a, skip, 0);
            branch(n->b, l, 1);
            setlabel(skip);
        }
        return;
    case 22:
        if (jumpif) {
            branch(n->a, l, 1);
            branch(n->b, l, 1);
        } else {
            skip = newlabel();
            branch(n->a, skip, 1);
            branch(n->b, l, 0);
            setlabel(skip);
        }
        return;
    case 33:
    case 34:
        t = n->a->type;
        if (!isfloatty(t)) {
            gen_cmpops(n);
             
            if ((n->op == 33) != (jumpif != 0))
                jmpop(0xD3, l);
            else
                jmpop(0xD4, l);
            return;
        }
        gen_cmpops(n);
        emitrelop(n->op, t, jumpif);
        jmpop(0xA1, l);
        return;
    case 35:
    case 36:
    case 37:
    case 38:
        gen_cmpops(n);
        emitrelop(n->op, n->a->type, jumpif);
        jmpop(0xA1, l);
        return;
    }
    t = n->type;
    if (isfloatty(t)) {
        gen_value(n);
        gen_fconst((unsigned char *)"\0\0\0\0");
        ob(jumpif ? 0xAF : 0xB7);
        ob(2);
        jmpop(0xA1, l);
        return;
    }
    if (islongty(t)) {
        gen_value(n);
        ob(0x8D);
    } else
        gen_lowbyte(n);
    ldc(0);
    jmpop(jumpif ? 0xD3 : 0xD4, l);
}

 
static void gen_assign(struct Node *n, int want)
{
    struct Node *lhs;
    struct Node *rhs;
    struct Type *t;
    int ta;
    int w;
    int savet;
    struct Node *saven;
    lhs = n->a;
    rhs = n->b;
    t = lhs->type;
    if (n->op == 15 && (t->kind == 12 || t->kind == 13 || t->kind == 11)) {
        if (t->kind == 11) {          
            gen_value(rhs);
            ldc(0);
            gen_addr(lhs);
            ldc(0);
            ldc(rhs->slen < t->size ? rhs->slen : t->size);
            csp(2);
            return;
        }
        gen_addr(lhs);
        gen_value(rhs);
        opbig(0xA8, (t->size + 1) / 2);
        if (want)
            gen_addr(lhs);
        return;
    }
    w = twords(t);
    savet = lvtemp;
    saven = lvnode;
    if (simplelv(lhs)) {
        lvtemp = 0;
        lvnode = lhs;
        if (n->op == 18 && want)
            gen_load(lhs);
        storepre(lhs);
        if (ischar(t))
            gen_lowbyte(rhs);
        else
            gen_value(rhs);
        storepost(lhs);
        if (want && n->op != 18)
            gen_load(lhs);
    } else {
        ta = newtemp(1);
        gen_addr(lhs);
        gen_stl(ta);
        lvtemp = ta;
        lvnode = lhs;
        if (n->op == 18 && want)
            loadvia(ta, t);
        storeviapre(ta, t);
        if (ischar(t))
            gen_lowbyte(rhs);
        else
            gen_value(rhs);
        storeviapost(t);
        if (want && n->op != 18)
            loadvia(ta, t);
    }
    lvtemp = savet;
    lvnode = saven;
    w = w;
}

void gen_value(struct Node *n)
{
    int l1;
    int l2;
    struct Type *t;
    t = n->type;
    switch (n->op) {
    case 1:
        if (islongty(t)) {
            ldc(n->val2);
            ldc(n->val);
        } else
            ldc(n->val);
        return;
    case 2:
        gen_fconst(n->fimg);
        return;
    case 3:
        gen_str(n);
        return;
    case 44:
        {
            int t;
            t = newtemp(1);
            lla(t);
            ldc((n->slen + 1) / 2);
            csp(1);                      
            n->op = 3;
            gen_str(n);
            ldc(0);
            ldl(t);
            ldc(0);
            ldc(n->slen);
            csp(2);
            ldl(t);
        }
        return;
    case 4:
    case 8:
    case 9:
        gen_load(n);
        return;
    case 43:
        if (lvtemp)
            loadvia(lvtemp, lvnode->type);
        else
            gen_load(lvnode);
        return;
    case 5:
        ob(0xC7);
        reloc(2, n->sym->name);
        E->relpos[E->nrel - 1] = E->pc - 1;
        ob(0);
        ob(0);
        return;
    case 10:
        if (n->a->op == 5) {
            gen_value(n->a);
            return;
        }
        gen_addr(n->a);
        return;
    case 14:
        gen_cast(n);
        return;
    case 11:
        gen_value(n->a);
        ob(isfloatty(t) ? 0x92 : 0x91);
        return;
    case 13:
        gen_value(n->a);
        ob(0x93);
        return;
    case 12:
    case 21:
    case 22:
        l1 = newlabel();
        l2 = newlabel();
        branch(n, l1, 0);
        ldc(1);
        jump(l2);
        setlabel(l1);
        ldc(0);
        setlabel(l2);
        return;
    case 33:
    case 34:
    case 35:
    case 36:
    case 37:
    case 38:
        gen_cmpops(n);
        emitrelop(n->op, n->a->type, 0);
        return;
    case 19:
        l1 = newlabel();
        l2 = newlabel();
        branch(n->a, l1, 0);
        gen_value(n->b);
        jump(l2);
        setlabel(l1);
        gen_value(n->c);
        setlabel(l2);
        return;
    case 20:
        gen_discard(n->a);
        gen_value(n->b);
        return;
    case 15:
    case 16:
    case 18:
        gen_assign(n, 1);
        return;
    case 6:
        gen_call(n, 1);
        return;
    case 41:
        gen_intrinsic(n, 1);
        return;
    case 23:
    case 24:
    case 25:
        gen_value(n->a);
        if (n->op == 23 && n->b->op == 1 && !isfloatty(t) && n->b->val > 0 && !(n->b->val & 1) && n->b->val < 256) {
            opbig(0xA2, n->b->val / 2);
            return;
        }
        gen_value(n->b);
        if (isfloatty(t))
            ob(n->op == 23 ? 0x83 : (n->op == 24 ? 0x96 : 0x90));
        else
            ob(n->op == 23 ? 0x82 : (n->op == 24 ? 0x95 : 0x8F));
        return;
    case 26:
        gen_value(n->a);
        gen_value(n->b);
        ob(0x87);
        return;
    case 28:
        gen_value(n->a);
        gen_value(n->b);
        ob(0x84);
        return;
    case 29:
        gen_value(n->a);
        gen_value(n->b);
        ob(0x8D);
        return;
    }
    error(100  , 0);
}

void gen_discard(struct Node *n)
{
    switch (n->op) {
    case 15:
    case 16:
    case 18:
        gen_assign(n, 0);
        return;
    case 6:
        gen_call(n, 0);
        return;
    case 41:
        gen_intrinsic(n, 0);
        return;
    case 20:
        gen_discard(n->a);
        gen_discard(n->b);
        return;
    case 14:
        if (n->type->kind == 0) {
            gen_discard(n->a);
            return;
        }
        break;
    case 19:
        {
            int l1;
            int l2;
            l1 = newlabel();
            l2 = newlabel();
            branch(n->a, l1, 0);
            gen_discard(n->b);
            jump(l2);
            setlabel(l1);
            gen_discard(n->c);
            setlabel(l2);
        }
        return;
    case 1:
    case 4:
        return;
    }
    gen_value(n);
    drop(valwords(n->type));
}

void gen_return(struct Node *n, struct Type *ft, int sretoff)
{
    int rw;
    struct Type *t;
    if (!n)
        return;
    t = ft->base;
    if (t->kind == 12 || t->kind == 13) {
        ldl(sretoff);
        gen_value(n);
        opbig(0xA8, (t->size + 1) / 2);
        ldl(sretoff);
        gen_stl(1);
        return;
    }
    rw = retwords(ft);
    if (rw == 1) {
        gen_value(n);
        gen_stl(1);
    } else {
        lla(1);
        gen_value(n);
        ob(0xBD);
        ob(rw);
    }
}

void gen_switch(int t, int *vals, int *labs, int n, int deflab)
{
    int lo;
    int hi;
    int i;
    int v;
    int range;
    if (n == 0) {
        jump(deflab);
        return;
    }
    lo = vals[0];
    hi = vals[0];
    for (i = 1; i < n; i++) {
        if (vals[i] < lo)
            lo = vals[i];
        if (vals[i] > hi)
            hi = vals[i];
    }
    range = hi - lo + 1;
    if (n >= 4 && range > 0 && range <= 3 * n + 6 && range < 1000) {
        ldl(t);
        ob(0xAC);
        if (E->pc & 1)
            ob(0);
        ob(lo & 255);
        ob((lo >> 8) & 255);
        ob(hi & 255);
        ob((hi >> 8) & 255);
        jump(deflab);
        for (v = lo; v <= hi; v++) {
            for (i = 0; i < n; i++)
                if (vals[i] == v)
                    break;
            caseword(i < n ? labs[i] : deflab);
        }
        return;
    }
    for (i = 0; i < n; i++) {
        ldl(t);
        ldc(vals[i]);
        jmpop(0xD4, labs[i]);
    }
    jump(deflab);
}

 

static void outw(int w)
{
    putc(w & 255, objout);
    putc((w >> 8) & 255, objout);
}

static void outs(char *s)
{
    int n;
    n = strlen(s);
    putc(n, objout);
    while (*s)
        putc(*s++, objout);
}

static char *genmod;

void gen_objheader(char *modname)
{
    genmod = modname;
    memset(names, 0, sizeof(names));
    setupemit(&fe, 5000, 300, 500, 500);
    setupemit(&ie, 1600, 40, 80, 300);
    E = &fe;
    fputs("TCOB", objout);
    putc('M', objout);
    outs(modname);
}

void gen_objdata(char *name, int words, int strong)
{
    putc('D', objout);
    putc(strong, objout);
    outs(name);
    outw(words);
}

void gen_objuse(char *name)
{
    putc('U', objout);
    outs(name);
}

void gen_objend(int staticwords)
{
    putc('G', objout);
    outw(staticwords);
    putc('E', objout);
}

 
static void endproc(char *name, char *seg, int exitlab, int rw, int flags)
{
    int longlab[60];
    int nlong;
    int i;
    int k;
    int t;
    int pos;
    int off;
    int jtab;
    int exitpos;
    int base;
    exitpos = E->labpos[exitlab];
     
    nlong = 0;
    for (i = 0; i < E->nfix; i++) {
        pos = E->fixpos[i];
        if (E->fixlab[i] <= -2)
            continue;
        t = E->labpos[E->fixlab[i]];
        if (t < 0) {
            error(101  , name);
            continue;
        }
        off = t - (pos + 1);
        if (off >= 0 && off <= 127) {
            E->code[pos] = off;
            continue;
        }
        for (k = 0; k < nlong; k++)
            if (longlab[k] == t)
                break;
        if (k == nlong) {
            if (nlong >= 60)
                fatal(102  , name);
            longlab[nlong++] = t;
        }
        E->code[pos] = (256 - 10 - 2 * k) & 255;
    }
    if (E->pc & 1)
        ob(0);
    base = E->pc;
    jtab = base + 2 * nlong + 8;
    for (k = nlong - 1; k >= 0; k--) {
        pos = jtab - 10 - 2 * k;
        ob(pos - longlab[k]);
        ob((pos - longlab[k]) >> 8);
    }
    ob((maxlocal - nparamwords) * 2);
    ob(((maxlocal - nparamwords) * 2) >> 8);
    ob(nparamwords * 2);
    ob((nparamwords * 2) >> 8);
    ob(jtab - 4 - exitpos);
    ob((jtab - 4 - exitpos) >> 8);
    ob(jtab - 2);
    ob((jtab - 2) >> 8);
    ob(0);                           
    ob(1);                           
     
    for (i = 0; i < E->nfix; i++) {
        if (E->fixlab[i] > -2)
            continue;
        pos = E->fixpos[i];
        t = E->labpos[-2 - E->fixlab[i]];
        E->code[pos] = (pos - t) & 255;
        E->code[pos + 1] = ((pos - t) >> 8) & 255;
    }
    putc('P', objout);
    putc(flags, objout);
    outs(name);
    outs(seg);
    outw(nparamwords * 2);
    putc(rw, objout);
    outw(E->pc);
    outw(jtab);
    for (i = 0; i < E->pc; i++)
        putc(E->code[i], objout);
    outw(E->nrel);
    for (i = 0; i < E->nrel; i++) {
        outw(E->relpos[i]);
        putc(E->reltype[i], objout);
        outs(E->relname[i]);
    }
}

void gen_funcbegin(void)
{
    E = &fe;
    E->pc = 0;
    E->nlab = 0;
    E->nfix = 0;
    E->nrel = 0;
    lvtemp = 0;
}

void gen_funcend(char *name, struct Type *ft, int exitlab, int isstatic, char *seg)
{
    int rw;
    rw = retwords(ft);
    setlabel(exitlab);
    ob(0xAD);
    ob(rw);
    endproc(name, seg, exitlab, rw, isstatic ? 2 : 0);
}

 

static int initexit;

static void initstart(void)
{
    E->pc = 0;
    E->nlab = 0;
    E->nfix = 0;
    E->nrel = 0;
    curlocal = 0;
    scratch = 1;
    curlocal = 1;
    maxlocal = 1;
    nparamwords = 0;
    initexit = newlabel();
}

void gen_initflush(void)
{
    char name[40];
    struct Emit *save;
    save = E;
    saveframe();
    E = &ie;
    if (ininit == 0 && E->pc > 0) {
        loadframe();
        setlabel(initexit);
        ob(0xAD);
        ob(0);
        sprintf(name, "%s'init%d", genmod, ninit);
        ninit++;
        endproc(name, "INIT", initexit, 0, 1);
        E->pc = 0;
    }
    E = save;
    loadframe();
}

void gen_initbegin(void)
{
    if (ininit++)
        return;
    saveframe();
    E = &ie;
    if (E->pc == 0)
        initstart();
    else
        loadframe();
}

void gen_initend(void)
{
    if (--ininit)
        return;
    saveframe();
    E = &fe;
    loadframe();
    if (ie.pc > ie.max - 500 || ie.nrel > ie.maxrel - 60)
        gen_initflush();
}
#10 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/link.c
                    
#21 !/home/user/UCSD-C/tinyc/link.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#22 !/home/user/UCSD-C/tinyc/link.c
#pragma segment LINK






struct LProc {
    char *name;
    int mod;
    int seg;                 
    int flags;               
    int parmsz;
    int rw;
    int codelen;
    int jtab;
    int nrel;
    int *rel;                
    int live;
    int procnum;
    struct LProc *hnext;
};

struct LData {
    char *name;
    int words;
    int strong;
    int mod;                 
    int offset;
    int live;
    struct LData *hnext;
};

static struct LProc **procs;
static int nprocs;
static struct LData **datas;
static int ndatas;
static struct LProc **lhash;
static struct LData **dhash;
static int *modstatic;
static int *modbase;
static int *modlive;

static int *usemod;              
static int *usedata;
static int nuses;
static int nmods;
static char *segnames[24];
static int nsegs;
static int segnum[24];           
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
    if (c == (-1))
        fatal(103  , 0);
    return c;
}

static int rdw(void)
{
    int lo;
    lo = rd();
    return ((((lo + rd() * 256) & 65535) ^ 32768) - 32768);
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
    for (p = lhash[hashstr(name) & (128 - 1)]; p; p = p->hnext)
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
    for (d = dhash[hashstr(name) & (128 - 1)]; d; d = d->hnext)
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
        fatal(104  , name);
    segnames[nsegs] = pstrdup(name);
    return nsegs++;
}

 
static void rewindobjs(void)
{
    curfilei = -1;
    curmod = -1;
    lin = 0;
}

 
static int nextrec(void)
{
    char magic[5];
    int c;
    int i;
    for (;;) {
        if (lin) {
            c = getc(lin);
            if (c == 'T') {              
                for (i = 1; i < 4; i++)
                    rd();
                continue;
            }
            if (c != (-1) && c != 0)
                return c;
            fclose(lin);                 
            lin = 0;
        }
        curfilei++;
        if (curfilei >= nobjfiles)
            return 0;
        lin = fopen(objfiles[curfilei], "rb");
        if (!lin)
            fatal(25  , objfiles[curfilei]);
        for (i = 0; i < 4; i++)
            magic[i] = rd();
        magic[4] = 0;
        if (strcmp(magic, "TCOB") != 0)
            fatal(105  , objfiles[curfilei]);
    }
}

 
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
    if (c == 'U') {
        rds(name);
        return;
    }
    if (c != 'P')
        fatal(106  , 0);
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
    char name[64];
    char seg[64];
    char rname[64];
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
            if (curmod >= 64)
                fatal(108  , 0);
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
                if (ndatas >= 400)
                    fatal(108  , 0);
                d = (struct LData *)palloc(sizeof(struct LData));
                d->name = pstrdup(name);
                d->mod = -1;
                h = hashstr(name) & (128 - 1);
                d->hnext = dhash[h];
                dhash[h] = d;
                datas[ndatas++] = d;
            }
            if (flags && d->strong)
                error(115  , name);
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
            error(107  , name);
        if (nprocs >= 700)
            fatal(108  , 0);
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
        h = hashstr(name) & (128 - 1);
        p->hnext = lhash[h];
        lhash[h] = p;
        procs[nprocs++] = p;
    }
}

static void pass2(void)
{
    char name[64];
    char seg[64];
    char rname[64];
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
    nuses = 0;
    while ((c = nextrec()) != 0) {
        record(c, name, seg, &flags, &parmsz, &rw, &codelen, &jtab);
        if (c == 'U') {
            d = finddata(name);
            if (!d || d->mod < 0)
                error(114  , name);
            else if (nuses < 64) {
                usemod[nuses] = curmod;
                usedata[nuses] = dataindex(d);
                nuses++;
            }
            continue;
        }
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
                    error(109  , rname);
                else
                    p->rel[i] = procindex(t);
            } else if (type == 4) {
                d = finddata(rname);
                if (!d || d->mod < 0)
                    error(114  , rname);
                else
                    p->rel[i] = -2 - dataindex(d);
            }
        }
    }
}

 
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
        for (i = 0; i < nuses; i++) {
            d = datas[usedata[i]];
            if (modlive[usemod[i]] && !d->live) {
                d->live = 1;
                modlive[d->mod] = 1;
                changed = 1;
            }
        }
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

 
static int entrylen;
static unsigned char *entry;
static int entryjtab;

static void eb(int b)
{
    if (entrylen >= 600)
        fatal(108  , 0);
    entry[entrylen++] = b;
}

static void ecall(struct LProc *p)
{
    if (segnum[p->seg] == 1) {
        eb(0xCF);                
        eb(p->procnum);
        eb(0xD7);
    } else {
        eb(0xCD);                
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
    if (g > 0) {                         
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
    eb(0xC1);                            
    eb(0);
    if (entrylen & 1)
        eb(0);
    entryjtab = entrylen + 8;
    g = g < 0 ? 0 : g;
    eb(g & 255);
    eb((g >> 8) & 255);                  
    eb(4);
    eb(0);                               
    put16(entry, entrylen, entryjtab - 4 - exitpos);
    entrylen += 2;
    put16(entry, entrylen, entryjtab - 2);
    entrylen += 2;
    eb(1);                               
    eb(0);                               
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
    char name[64];
    char seg[64];
    char rname[64];
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
    procs = (struct LProc **)malloc(700 * sizeof(struct LProc *));
    datas = (struct LData **)malloc(400 * sizeof(struct LData *));
    lbuf = (unsigned char *)malloc(5000 + 16);
    entry = (unsigned char *)malloc(600);
    if (!lbuf || !procs || !datas || !entry)
        fatal(2  , 0);
    lhash = (struct LProc **)calloc(128, sizeof(struct LProc *));
    dhash = (struct LData **)calloc(128, sizeof(struct LData *));
    modstatic = (int *)malloc(64 * sizeof(int));
    modbase = (int *)malloc(64 * sizeof(int));
    modlive = (int *)malloc(64 * sizeof(int));
    usemod = (int *)malloc(64 * sizeof(int));
    usedata = (int *)malloc(64 * sizeof(int));
    if (!lhash || !dhash || !modstatic || !modbase || !modlive || !usemod || !usedata)
        fatal(2  , 0);
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
        error(110  , 0);
        return 0;
    }
    mainp->live = 1;
    exitp = findproc("exit");
    if (exitp)
        exitp->live = 1;
    markall();
     
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
        fatal(34  , 0);
     
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
            fatal(111  , segnames[p->seg]);
        segnum[p->seg] = norder + 6;
        order[norder++] = p->seg;
    }
     
    pnum[mainp->seg] = 1;
    for (i = 0; i < nprocs; i++) {
        p = procs[i];
        if (!p->live)
            continue;
        s = p->seg;
        p->procnum = ++pnum[s];
        if (p->procnum > 255)
            fatal(112  , segnames[s]);
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
        fatal(24  , code);
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
            fatal(113  , segnames[s]);
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
#11 /home/user/UCSD-C/tinyc/tc.c

#1 !/home/user/UCSD-C/tinyc/main.c
           
#12 !/home/user/UCSD-C/tinyc/main.c

#1 !/home/user/UCSD-C/tinyc/tc.h
       
#8 !/home/user/UCSD-C/tinyc/tc.h









































































































































































































































































































































#13 !/home/user/UCSD-C/tinyc/main.c
#pragma segment MAIN



static void basename8(char *path, char *out)
{
    char *s;
    char *b;
    int n;
    b = path;
    for (s = path; *s; s++)
        if (*s == '/' || *s == '\\' || *s == ':')
            b = s + 1;
    n = 0;
    while (b[n] && b[n] != '.' && n < 8) {
        out[n] = b[n] >= 'a' && b[n] <= 'z' ? b[n] - 32 : b[n];
        n++;
    }
    out[n] = 0;
}

  
#36 !/home/user/UCSD-C/tinyc/main.c
static void passbegin(int xsize)
{
    curfile = 0;

    __heapsave();

    xsetsize(xsize);
}

static void passend(void)
{

    printf("  (%d words free)\n", __cspi(40));
    __heaprestore();

    resetpools();
}

 
static int compileone(char *src, char *tmpi, char *tmpr, char *obj)
{
    char mod[10];
    basename8(src, mod);
    printf("Preprocessing %s\n", src);
    passbegin(8000);
    if (!preprocess(src, tmpi))
        return 0;
    passend();
    printf("Compiling\n");
    passbegin(2000);
    if (!compile(tmpi, tmpr, mod))
        return 0;
    passend();
    printf("Generating code %s\n", obj);
    passbegin(2400);
    if (!gencode(tmpr, obj))
        return 0;
    passend();
    return 1;
}

static int linkall(char **objs, int n, char *out)
{
    char prog[10];
    int r;
    basename8(out, prog);
    printf("Linking %s\n", out);
    passbegin(1000);
    r = link(objs, n, out, prog);
    passend();
    return r;
}

static int exists(char *name)
{
    FILE *f;
    f = fopen(name, "rb");
    if (!f)
        return 0;
    fclose(f);
    return 1;
}

static void upper(char *s)
{
    for (; *s; s++)
        if (*s >= 'a' && *s <= 'z')
            *s = *s - 32;
}

int main(int argc, char **argv)
{
    char *objs[24];
    int nobjs;
    char out[200];
    char src[200];
    char tmpi[200];
    char tmpr[200];
    char obj[200];
    char lib[200];
    char line[200];
    char *s;
    char *t;
    int i;
    int n;
    int conly;
    printf("Tiny-C compiler for UCSD Pascal II.0  [0.2]\n");
    nobjs = 0;
    conly = 0;
    out[0] = 0;
    lib[0] = 0;

    printf("Compile what file? ");
    if (!fgets(line, 180, (&__files[0])))
        return 1;
    n = strlen(line);
    while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == ' '))
        line[--n] = 0;
    upper(line);
    s = line;
    while (*s == ' ')
        s++;
    if (!*s)
        return 1;
    strcpy(lib, "TCLIB.OBJ");
    if (!exists(lib))
        strcpy(lib, "*TCLIB.OBJ");
    if (s[0] == '/' && s[1] == 'L') {
         
        s = s + 2;
        while (*s == ' ')
            s++;
        t = strchr(s, '=');
        if (!t) {
            printf("use: /L OUT=A,B,...\n");
            return 1;
        }
        *t++ = 0;
        strcpy(out, s);
        strcat(out, ".CODE");
        while (*t) {
            s = t;
            while (*t && *t != ',')
                t++;
            if (*t)
                *t++ = 0;
            if (nobjs >= 24 - 1)
                break;
            objs[nobjs] = (char *)malloc(strlen(s) + 5);
            strcpy(objs[nobjs], s);
            strcat(objs[nobjs], ".OBJ");
            nobjs++;
        }
    } else {
        if (s[0] == '/' && s[1] == 'C') {
            conly = 1;
            s = s + 2;
            while (*s == ' ')
                s++;
        }
        n = strlen(s);
        if (n > 5 && strcmp(s + n - 5, ".TEXT") == 0)
            s[n - 5] = 0;
        strcpy(src, s);
        strcat(src, ".TEXT");
        strcpy(obj, s);
        strcat(obj, ".OBJ");
        strcpy(out, s);
        strcat(out, ".CODE");
        if (!compileone(src, "TCTEMP.TEXT", "TCTEMP.IR", obj))
            return 1;
        objs[nobjs++] = obj;
    }
    argc = 0;
    argv = 0;


































































    if (conly) {
        printf("Done.\n");
        return 0;
    }
    if (lib[0] && exists(lib))
        objs[nobjs++] = lib;
    if (!linkall(objs, nobjs, out))
        return 1;
    printf("Done.\n");
    return 0;
}
