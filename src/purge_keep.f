\ 19.Feb.2005

REQUIRE /STRING    lib\include\string.f

\ REQUIRE enum-liste ~pinka\lib\list_ext_2.f 

[UNDEFINED] FILE_ATTRIBUTE_READONLY [IF]
1 CONSTANT FILE_ATTRIBUTE_READONLY  [THEN]

: IsFoundRO ( a-find_data -- flag )
  FoundAttributes
  FILE_ATTRIBUTE_READONLY AND 0<>
;
\ ---

VARIABLE uKeepList

: (KeepFile?) ( a u false node -- a u false true | a u true false )
  >R DROP 2DUP
  R> CELL+ COUNT
  WildCMP-U 0= IF TRUE FALSE ELSE FALSE TRUE THEN
;
: KeepFile? ( a u -- flag )
  0 ['] (KeepFile?)  uKeepList ?List-ForEach
  NIP NIP
;
: -keep  ( -- )  \ "file"
  ParseFileName DUP 0= IF 2DROP EXIT THEN
  OVER C@ [CHAR] @ = IF
    1 /STRING  uKeepList LoadList
  ELSE
    uKeepList list-str+
  THEN
;

\ ---

0 VALUE vKeepRO

: -keep-ro ( -- )
  \ не удалять R/O файлы
  TRUE TO vKeepRO
;

\ ---

..: (?RemoveFile)  ( a-finddata -- )
  vKeepRO  IF 
    DUP IsFoundRO IF DROP EXIT THEN
  THEN
  uKeepList @ IF
    DUP FoundName KeepFile?
    IF DROP EXIT THEN
  THEN
;..

