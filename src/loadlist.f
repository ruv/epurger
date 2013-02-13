: list-str+ ( a u list -- )
  HERE 0 , 2>R
  S", 0 C,
  R> R> list+
;
: SrcToList ( list -- )
  ParseFileName ROT list-str+
  POSTPONE \
;

VARIABLE _curlist

: SrcToCurrList _curlist @ SrcToList ;

: LoadList ( a-filename u-filename list -- )
  _curlist !
  ['] <PRE> BEHAVIOR >R
  ['] SrcToCurrList TO <PRE>
  ['] INCLUDED CATCH 
  R> TO <PRE>        THROW
;
: AddToDirs ( a u -- ) \ в список обрабатываемых
  HERE >R
  0 , S", 0 ,
  R> FoldersList list+
;
: AddToSkip ( a u -- ) \ в список пропускаемых
  HERE >R
  0 , S", 0 ,
  R> hSkipList list+
;
