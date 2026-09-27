#1 /home/user/UCSD-C/tests/funcptr.c
 

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

 



#3 /home/user/UCSD-C/tests/funcptr.c

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


#4 /home/user/UCSD-C/tests/funcptr.c

int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }
int mul(int a, int b) { return a * b; }

int (*ops[3])(int, int) = { add, sub, mul };

int apply(int (*f)(int, int), int x, int y)
{
    return f(x, y);
}

int cmp(void *a, void *b)
{
    return *(int *)a - *(int *)b;
}

int main(void)
{
    int i;
    int v[10];
    int (*fp)(int, int);
    for (i = 0; i < 3; i++)
        printf("op%d: %d\n", i, ops[i](7, 3));
    fp = sub;
    printf("apply %d %d\n", apply(add, 20, 22), apply(fp, 20, 22));
    printf("same %d\n", fp == sub);
    for (i = 0; i < 10; i++)
        v[i] = (i * 7 + 3) % 10;
    qsort(v, 10, sizeof(int), cmp);
    for (i = 0; i < 10; i++)
        printf("%d ", v[i]);
    printf("\n");
    return 0;
}
