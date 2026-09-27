#1 /home/user/UCSD-C/tests/strings.c
 

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

 



#3 /home/user/UCSD-C/tests/strings.c

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


#4 /home/user/UCSD-C/tests/strings.c

#1 /home/user/UCSD-C/tinyc/include/ctype.h
 


int isdigit(int c);
int isupper(int c);
int islower(int c);
int isalpha(int c);
int isalnum(int c);
int isxdigit(int c);
int isspace(int c);
int iscntrl(int c);
int isprint(int c);
int isgraph(int c);
int ispunct(int c);
int toupper(int c);
int tolower(int c);

#5 /home/user/UCSD-C/tests/strings.c






void reverse(char *s)
{
    int i;
    int j;
    char t;
    for (i = 0, j = strlen(s) - 1; i < j; i++, j--) {
        t = s[i];
        s[i] = s[j];
        s[j] = t;
    }
}

int main(void)
{
    char buf[80];
    char word[20];
    int a;
    int b;
    int myvar;
    char *p;
    strcpy(buf, "Hello");
    strcat(buf, ", Tiny-C");
    printf("%s (%d)\n", buf, (int)strlen(buf));
    reverse(buf);
    printf("%s\n", buf);
    printf("%d %d %d\n", strcmp("abc", "abd") < 0, strcmp("b", "a") > 0, strncmp("abcx", "abcy", 3));
    p = strchr("find the x here", 'x');
    printf("%s|%s\n", p, strstr("haystack needle hay", "needle"));
    sprintf(buf, "%d-%s-%c", 42, "str", 'z');
    printf("[%s]\n", buf);
    sscanf("17 29 word", "%d %d %s", &a, &b, word);
    printf("%d %s %d\n", a + b, word, ((a) > (b) ? (a) : (b)));
    printf("%d %s\n", ((a + 1) * (a + 1)), "hello world");
    myvar = 5;
    printf("%d\n", myvar);
    for (p = "MiXeD 123"; *p; p++)
        putchar(isupper(*p) ? tolower(*p) : toupper(*p));
    putchar('\n');
    return 0;
}
