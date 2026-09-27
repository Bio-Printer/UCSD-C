/* conio.h -- Tiny-C console I/O (unbuffered, P-System console) */
#ifndef __CONIO_H
#define __CONIO_H
#include <stdio.h>

int getch(void)
{
    return __conrawgetc();
}

int getche(void)
{
    int c;
    char b;
    c = __conrawgetc();
    b = c;
    __cspv(6, 1, &b, 0, 1, 0, 0);
    return c;
}

int putch(int c)
{
    char b;
    __conflush();
    b = c;
    __cspv(6, 1, &b, 0, 1, 0, 0);
    return c;
}

int cputs(char *s)
{
    while (*s)
        putch(*s++);
    return 0;
}

/* a key is waiting (UNITBUSY on the console) */
int kbhit(void)
{
    __conflush();
    return __cspi(35, 2) != 0;
}

/* the operating system's FGOTOXY and CLEARSCREEN */
void gotoxy(int x, int y)
{
    __conflush();
    __cxp0v(29, x, y);
}

void clrscr(void)
{
    __conflush();
    __cxp0v(37);
}

#endif
