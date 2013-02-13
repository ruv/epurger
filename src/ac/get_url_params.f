( Простая библиотека для преобразования строки параметров
  в набор форт-слов. Например, выполнение
  S" error_code=10060&from=http://10.1.1.11/" GetParamsFromString
  приведет к тому, что в словаре PARAMS появятся слова
  error_code и from, которые при выполнении будут возвращать
  строку addr u со значением этого параметра.
)
REQUIRE {             ~ac/lib/locals.f
REQUIRE "             ~ac/lib/str2.f

: CONVERT { a u c1 c2 -- }
  u 0 ?DO a I + C@ c1 = IF c2 a I + C! THEN LOOP
;
: CONVERT% { a u \ a2 u2 i -- a2 u2 }
  a u [CHAR] + BL CONVERT
\  a u [CHAR] & 1  CONVERT
\  a u [CHAR] = BL CONVERT
  u ALLOCATE THROW -> a2
  0 -> u2  0 -> i  HEX
  BEGIN
    i u U<
  WHILE
    a i + C@ DUP [CHAR] % =
    IF DROP 0 0 a i + CHAR+ 2 >NUMBER 2DROP D>S i 2+ -> i THEN
    a2 u2 + C!
    i 1+ -> i
    u2 1+ -> u2
  REPEAT DECIMAL
  a2 u2
;
VOCABULARY PARAMS

: STR@DOES
  DOES>  @ STR@ (") STR@
;
: 'STR@DOES
  DOES>  @ STR@
;
: STR-LIT { \ s }
  "" -> s 1 PARSE CONVERT% s STR! s
;
: STRING:
  CREATE 
  STR-LIT ,
  STR@DOES
;
: Name:Value
  2DUP [CHAR] = BL CONVERT
  ['] STRING: EVALUATE-WITH
;
: AllocParams
  GET-CURRENT ALSO PARAMS DEFINITIONS
  BEGIN
    1 PARSE DUP
  WHILE
    Name:Value
  REPEAT 2DROP
  PREVIOUS SET-CURRENT
;
: GetParamsFromString ( addr u -- )
  2DUP [CHAR] & 1  CONVERT
  ( CONVERT%) ['] AllocParams EVALUATE-WITH
;
: ForEachParam { xt -- }
  ALSO PARAMS 
  CONTEXT @ @
  BEGIN
    DUP
  WHILE
    DUP DUP COUNT ROT
        NAME> EXECUTE xt EXECUTE
    CDR
  REPEAT DROP
  PREVIOUS
;
: DumpParam { na nu va vu -- }
  na nu TYPE ." =="
  [CHAR] " EMIT va vu TYPE [CHAR] " EMIT CR CR
;
: DumpParams
  ['] DumpParam ForEachParam
;
USER uSParams

: ShowParam ( na nu va vu -- )
  2SWAP " <tr><td>{s}</td><td>{s}</td>{CRLF}"
  uSParams @ S+
;
: ShowParams ( -- addr u )
  S" <table border=1>" uSParams S!
  ['] ShowParam ForEachParam
  S" </table>" uSParams @ STR+
  uSParams @ STR@
;
: IsSet ( addr u -- flag )
  ALSO PARAMS CONTEXT @ PREVIOUS SEARCH-WORDLIST
  IF DROP TRUE ELSE FALSE THEN
;
: SetParam ( va vu pa pu -- )
  GET-CURRENT >R ALSO PARAMS DEFINITIONS
  2DUP CONTEXT @ SEARCH-WORDLIST
  IF NIP NIP >BODY S!
  ELSE
    " {s} {s}" STR@ Name:Value
  THEN
  PREVIOUS R> SET-CURRENT
;
