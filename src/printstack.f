: .S ( -- )
    SP@ S0 @
    ." S: "   2DUP  SWAP - 4 / 64 SWAP U< IF ." stack underflow ! " BYE THEN
    BEGIN  2DUP <>  WHILE
        1 CELLS -  DUP @ .
    REPEAT 2DROP
;
