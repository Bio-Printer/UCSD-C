#1 /home/user/UCSD-C/tests/queens.c
 

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

 



#3 /home/user/UCSD-C/tests/queens.c

int col[8];
int solutions;
int first[8];

int safe(int row, int c)
{
    int r;
    for (r = 0; r < row; r++) {
        int d;
        d = col[r] - c;
        if (d == 0 || d == row - r || d == r - row)
            return 0;
    }
    return 1;
}

void place(int row)
{
    int c;
    int i;
    if (row == 8) {
        if (solutions == 0)
            for (i = 0; i < 8; i++)
                first[i] = col[i];
        solutions++;
        return;
    }
    for (c = 0; c < 8; c++)
        if (safe(row, c)) {
            col[row] = c;
            place(row + 1);
        }
}

int main(void)
{
    int r;
    int c;
    place(0);
    printf("%d solutions\n", solutions);
    for (r = 0; r < 8; r++) {
        for (c = 0; c < 8; c++)
            putchar(first[r] == c ? 'Q' : '.');
        putchar('\n');
    }
    return 0;
}
