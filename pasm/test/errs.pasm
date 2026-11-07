; ERRS -- errors PASM must report (tools/pasmtest.py): each on its line, then no code file
        .PROGRAM ERRS
        .GLOBAL A, B
        .PROC   P
        .PARAM  X
        LDL     Y                       ; 6: not defined before it is used
        FOO     1                       ; 7: not an instruction
        SLDC    200                     ; 8: out of range
        UJP     NOWHERE
        LDL     X
        RNP     0
        .END                            ; 12: NOWHERE: label not defined
        .MAIN
        LSA     'abc                    ; 14: a string without its end
        CSP     300                     ; 15: out of range (0..255)
        LDO     A
        .BOGUS                          ; 17: no such directive
        RBP     0
        .END
