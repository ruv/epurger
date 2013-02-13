MODULE: SkipFolders_Support EXPORT

VARIABLE hSkipList hSkipList 0! \ список пропускаемых имен фолдеров при пуржинге

DEFINITIONS
\ ==================
\ vars for local use
VARIABLE NAME-A
VARIABLE NAME-U
VARIABLE SkipIt

: CheckName ( node -- flag )
  CELL+ COUNT
  NAME-A @ NAME-U @ 2SWAP
  WildCMP-U 0= IF  TRUE SkipIt !  FALSE ELSE TRUE THEN
;
: SkipFolder? ( a u -- flag )
  NAME-U ! NAME-A !
  SkipIt 0!
  ['] CheckName  hSkipList ?List-ForEach
  SkipIt @ DUP IF NAME-A @ NAME-U @ LogParam! Log_SkipFolder THEN
;
..: SetDir ( a u -- ior )
  2DUP SkipFolder? IF 2DROP -1 EXIT THEN
  ( a u )
;..

;MODULE
