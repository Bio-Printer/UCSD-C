#1 /home/user/UCSD-C/tests/structs.c
 

#1 /home/user/UCSD-C/tinyc/include/stdio.h
               
#16 /home/user/UCSD-C/tinyc/include/stdio.h



#1 /home/user/UCSD-C/tinyc/include/stddef.h
 





typedef unsigned size_t;
typedef int ptrdiff_t;
typedef char wchar_t;


#19 /home/user/UCSD-C/tinyc/include/stdio.h

#1 /home/user/UCSD-C/tinyc/include/stdarg.h
    
#5 /home/user/UCSD-C/tinyc/include/stdarg.h


typedef char *va_list;






#20 /home/user/UCSD-C/tinyc/include/stdio.h


















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
    char fib[80];                
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

 



#3 /home/user/UCSD-C/tests/structs.c

#1 /home/user/UCSD-C/tinyc/include/stdlib.h
    
#5 /home/user/UCSD-C/tinyc/include/stdlib.h



#1 /home/user/UCSD-C/tinyc/include/stddef.h
 










#8 /home/user/UCSD-C/tinyc/include/stdlib.h





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


#4 /home/user/UCSD-C/tests/structs.c

#1 /home/user/UCSD-C/tinyc/include/string.h
 



#1 /home/user/UCSD-C/tinyc/include/stddef.h
 










#5 /home/user/UCSD-C/tinyc/include/string.h

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


#5 /home/user/UCSD-C/tests/structs.c

typedef struct node {
    int value;
    char name[10];
    struct node *next;
} Node;

enum color { RED, GREEN = 5, BLUE };

union word {
    unsigned w;
    unsigned char b[2];
};

struct pair { int a; long b; float c; };

struct pair makepair(int a)
{
    struct pair p;
    p.a = a;
    p.b = a * 1000L;
    p.c = a / 2.0;
    return p;
}

Node *push(Node *list, int v, char *name)
{
    Node *n;
    n = malloc(sizeof(Node));
    n->value = v;
    strcpy(n->name, name);
    n->next = list;
    return n;
}

int main(void)
{
    Node *list;
    Node *p;
    union word u;
    struct pair q;
    struct pair r;
    int total;
    list = ((void *)0);
    list = push(list, 1, "one");
    list = push(list, 2, "two");
    list = push(list, 3, "three");
    total = 0;
    for (p = list; p; p = p->next) {
        printf("%d %s\n", p->value, p->name);
        total += p->value;
    }
    printf("total %d sizeof(Node) %d\n", total, (int)sizeof(Node));
    printf("colors %d %d %d\n", RED, GREEN, BLUE);
    u.w = 0x1234;
    printf("union %x %x\n", u.b[0], u.b[1]);
    q = makepair(7);
    r = q;
    r.a++;
    printf("pair %d %ld %.1f / %d\n", q.a, q.b, q.c, r.a);
    return 0;
}
