\ 23.Nov.2001 Fri 11:51

VARIABLE cmdl  HERE S" cmdl" S", 0 C, cmdl !
: $cmdl cmdl @ COUNT ;

VECT MissingParams
\ ==========================
\ from forth_script\cgi.f by AC

: GetGetParams ( -- )
  S" QUERY_STRING" ENVIRONMENT?
  IF ?DUP IF GetParamsFromString
          ELSE DROP MissingParams
          THEN
  ELSE MissingParams THEN
;
10000000 CONSTANT MAX-COMMAND-LEN

: GetPostedBody { \ len mem }
  S" HTTP_CONTENT_LENGTH" ENVIRONMENT? IF EVALUATE ELSE 0 THEN
  -> len
  len 0= IF MissingParams EXIT THEN
  len MAX-COMMAND-LEN > ABORT" Too long command"
  len ALLOCATE THROW -> mem
  mem len H-STDIN \ [ VERSION 400005 > [IF] ] STREAM-FILE [ [THEN] ] \ commented: 19.Feb.2005
  READ-FILE THROW
  len <> ABORT" Content-length mismatch"
  mem len
;
: GetPostParams 
  GetPostedBody GetParamsFromString
;
\ ==========================

VECT HTTP-HEADER

VERSION 400000 U< 0= [IF]

: OPTIONS ( -> ) \ интерпретировать командную строку
  SAVE-SOURCE N>R
    GetCommandLineA ASCIIZ> TUCK
    HEAP-COPY DUP >R SWAP SOURCE!
    PeekChar [CHAR] " = IF [CHAR] " ELSE BL THEN
    WORD DROP \ имя программы
    1 PARSE
    \ <PRE> ['] INTERPRET CATCH ?DUP IF ERROR THEN
    ['] EVALUATE CATCH \ ?DUP IF NIP NIP ERROR THEN
    DUP IF DUP SAVE-ERR THEN
    R> FREE THROW
  NR> RESTORE-SOURCE
  DUP IF
   \ DUP ERROR
   StartLog
     ERR-STRING LogParam! 
     Log_ErrorInOptions  NOTSEEN-ERR
   StopLog
  THEN THROW
;

[THEN]

: EvalParams ( -- )
   ['] OPTIONS ERR-EXIT
   CGI? @ IF HTTP-HEADER CGICmd-A CGICmd-U ['] EVALUATE ERR-EXIT THEN
;

: TEXT
  ." Content-Type: text/plain" CR CR
;
: HTML
  ." Content-Type: text/html" CR CR
;

' TEXT TO HTTP-HEADER

: ?cgi_params ( -- )
  CGI? @   IF
  POST? @       IF
  GetPostParams ELSE
  GetGetParams  THEN

\  HTTP-HEADER

  ALSO PARAMS
   $cmdl IsSet IF $cmdl EVALUATE CGICmd! THEN
  PREVIOUS THEN
  EvalParams
;
