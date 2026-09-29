/* doubles (12 bytes: IEEE binary64, CSP 100..; P-Code mode only) */
#include <stdio.h>

char buf[48];

void show(double d)
{
    __cspv(133, d, 'g', 17, buf);       /* DTOA: %.17g */
    printf("%s\n", buf);
}

double half(double x)
{
    return x / 2.0;
}

struct P {
    int k;
    double v;
};

int main(void)
{
    double a;
    double b;
    triple t;
    float f;
    int i;
    long l;
    unsigned u;
    double arr[3];
    struct P p;
    a = 0.1;
    b = 0.2;
    show(a + b);
    show(a * 3.0);
    show(1.0L / 3.0);
    show(-a);
    t = 1e300L;
    show(t * 10.0);
    f = 0.1;
    a = f;
    show(a);
    f = a * 2.0;
    printf("%d\n", (int)(f * 10));
    i = 7;
    a = i;
    show(a / 2);
    i = a * 3.0;
    printf("%d\n", i);
    l = 100000L;
    a = l;
    show(a);
    l = a * 3.0;
    printf("%ld\n", l);
    u = 50000;
    a = u;
    show(a);
    u = a + 1.0;
    printf("%u\n", u);
    a = 2.0;
    b = 3.0;
    printf("%d %d %d %d %d %d\n", a < b, a <= b, a > b, a >= b, a == b, a != b);
    if (a)
        printf("nonzero\n");
    a = 0.0;
    if (!a)
        printf("zero\n");
    show(half(5.0));
    a = 1.5;
    a += 2.25;
    show(a);
    a *= 2.0;
    show(a);
    arr[1] = 1.25;
    arr[2] = arr[1] * 4.0;
    show(arr[2]);
    p.v = 9.5;
    show(p.v - 0.5);
    printf("%d\n", (int)sizeof(double));
    return 0;
}
