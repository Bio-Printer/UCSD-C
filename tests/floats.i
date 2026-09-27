#1 /home/user/UCSD-C/tests/floats.c
 
 

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

 



#4 /home/user/UCSD-C/tests/floats.c

#1 /home/user/UCSD-C/tinyc/include/math.h
   
#4 /home/user/UCSD-C/tinyc/include/math.h







double sqrt(double x);
double sin(double x);
double cos(double x);
double atan(double x);
double log(double x);
double exp(double x);
double log10(double x);
double fabs(double x);
double tan(double x);

double atan2(double y, double x);

double asin(double x);
double acos(double x);

double floor(double x);

double ceil(double x);

double fmod(double x, double y);

double pow(double x, double y);

double sinh(double x);
double cosh(double x);
double tanh(double x);

double modf(double x, double *ip);

double ldexp(double x, int e);


#5 /home/user/UCSD-C/tests/floats.c

int main(void)
{
    float x;
    double y;
    int i;
    x = 1.0;
    for (i = 0; i < 10; i++)
        x = x * 1.5;
    printf("%.3f\n", x);
    y = sqrt(2.0);
    printf("%.5f %.5f\n", y, y * y);
    printf("%.4f %.4f %.4f\n", sin(0.5), cos(0.5), atan(1.0) * 4.0);
    printf("%.4f %.4f %.4f\n", exp(1.0), log(10.0), log10(1000.0));
    printf("%.3f %.3f %.3f %.3f\n", floor(2.7), ceil(2.1), fabs(-3.25), pow(2.0, 10.0));
    printf("%d %d %d\n", (int)3.99, (int)-3.99, (int)(0.1 + 0.2 == 0.3));
    printf("%e %g %g\n", 12345.678, 0.0001234, 123456789.0);
    for (i = 0; i <= 8; i++)
        printf("%6.2f", i * 0.25);
    printf("\n");
    return 0;
}
