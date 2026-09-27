#1 /home/user/UCSD-C/tests/fcompare.c
 

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

 



#3 /home/user/UCSD-C/tests/fcompare.c

float v[9] = { -1000.0, -2.5, -1.0, -0.001, 0.0, 0.001, 1.0, 2.5, 1000.0 };

int main(void)
{
    int i;
    int j;
    int n[6];
    float z;
    for (i = 0; i < 6; i++)
        n[i] = 0;
    for (i = 0; i < 9; i++)
        for (j = 0; j < 9; j++) {
            if (v[i] < v[j]) n[0]++;
            if (v[i] <= v[j]) n[1]++;
            if (v[i] > v[j]) n[2]++;
            if (v[i] >= v[j]) n[3]++;
            if (v[i] == v[j]) n[4]++;
            if (v[i] != v[j]) n[5]++;
        }
    printf("< %d  <= %d  > %d  >= %d  == %d  != %d\n", n[0], n[1], n[2], n[3], n[4], n[5]);
    for (i = 0; i < 9; i++)
        printf("%d", (v[i] < 0.0) + 2 * (v[i] == 0.0) + 4 * (v[i] > 0.0));
    printf("\n");
    z = 0.0;
    printf("%d %d %d %d\n", !z, z ? 1 : 0, v[5] ? 1 : 0, 1.0e30 > 1.0e29);
    printf("%d %d\n", 1.0e-30 < 1.0e-29, -1.0e30 < 1.0e-30);
    return 0;
}
