#1 /home/user/UCSD-C/tests/control.c
 

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

 



#3 /home/user/UCSD-C/tests/control.c

char *name(int n)
{
    switch (n) {
    case 0: return "zero";
    case 1: return "one";
    case 2: return "two";
    case 3: return "three";
    case 4: return "four";
    case 10: return "ten";
    case -1: return "minus one";
    default: return "many";
    }
}

int sparse(int n)
{
    switch (n) {
    case 100: return 1;
    case 2000: return 2;
    case -30000: return 3;
    }
    return 0;
}

int main(void)
{
    int i;
    int j;
    int n;
    for (i = -1; i < 12; i++)
        printf("%d:%s ", i, name(i));
    printf("\n%d %d %d %d\n", sparse(100), sparse(2000), sparse(-30000), sparse(5));
    i = 0;
    do {
        i++;
        if (i == 3)
            continue;
        if (i > 6)
            break;
        printf("%d", i);
    } while (i < 100);
    printf("\n");
    n = 0;
again:
    n++;
    if (n < 5)
        goto again;
    printf("goto %d\n", n);
    for (i = 0, j = 10; i < j; i++, j--)
        ;
    printf("comma %d %d\n", i, j);
    printf("logic %d %d %d %d\n", 3 && 0, 3 || 0, !5, (i > 2) ? 7 : 8);
    return 0;
}
