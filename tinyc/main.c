/* main.c -- the Tiny-C driver: preprocess, compile, link.
 *
 * Host:      tc [-I dir] file.c [-o file.code]
 *            (temporary files: file.i and file.obj next to the output)
 * P-System:  X(ecute TC, then answer the prompts; the source NAME.TEXT
 *            becomes NAME.CODE, temporaries TCTEMP.TEXT and TCTEMP.OBJ.
 */
#include "tc.h"
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

static void banner(void)
{
    printf("Tiny-C compiler for UCSD Pascal II.0  [0.1]\n");
}

int main(int argc, char **argv)
{
    char src[200];
    char out[200];
    char tmpi[200];
    char tmpo[200];
    char prog[10];
    int i;
    int n;
    char *s;
    src[0] = 0;
    out[0] = 0;
    banner();
#ifdef __TINYC__
    printf("Compile what file? ");
    if (!fgets(src, MAXNAME, stdin))
        return 1;
    n = strlen(src);
    while (n > 0 && (src[n - 1] == '\n' || src[n - 1] == ' '))
        src[--n] = 0;
    if (n == 0)
        return 1;
    for (i = 0; i < n; i++)
        if (src[i] >= 'a' && src[i] <= 'z')
            src[i] = src[i] - 32;
    if (n < 5 || strcmp(src + n - 5, ".TEXT") != 0) {
        strcpy(out, src);
        strcat(src, ".TEXT");
    } else {
        strcpy(out, src);
        out[n - 5] = 0;
    }
    strcat(out, ".CODE");
    strcpy(tmpi, "TCTEMP.TEXT");
    strcpy(tmpo, "TCTEMP.OBJ");
    argc = 0;
    argv = 0;
#else
    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc)
            strcpy(out, argv[++i]);
        else if (strcmp(argv[i], "-I") == 0 && i + 1 < argc) {
            static char env[300];
            sprintf(env, "TINYC_INCLUDE=%s", argv[++i]);
            putenv(env);
        } else
            strcpy(src, argv[i]);
    }
    if (!src[0]) {
        printf("usage: tc [-I includedir] file.c [-o file.code]\n");
        return 1;
    }
    if (!out[0]) {
        strcpy(out, src);
        s = strrchr(out, '.');
        if (s)
            *s = 0;
        strcat(out, ".code");
    }
    strcpy(tmpi, out);
    s = strrchr(tmpi, '.');
    if (s)
        *s = 0;
    strcpy(tmpo, tmpi);
    strcat(tmpi, ".i");
    strcat(tmpo, ".obj");
#endif
    basename8(out, prog);
    printf("Preprocessing %s\n", src);
    if (!preprocess(src, tmpi))
        return 1;
    printf("Compiling\n");
    curfile = 0;
    if (!compile(tmpi, tmpo, prog))
        return 1;
    printf("Linking %s\n", out);
    curfile = 0;
    if (!link(tmpo, out, prog))
        return 1;
    printf("Done.\n");
    return 0;
}
