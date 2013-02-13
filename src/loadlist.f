
: SrcToList ( list -- )
  HERE 0 ,
  ParseFileName S", 0 C, POSTPONE \
  SWAP list+
;

VARIABLE _curlist

: SrcToCurrList _curlist @ SrcToList ;

: LoadList ( a-filename u-filename list -- )
  _curlist !
  ['] <PRE> BEHAVIOR >R
  ['] SrcToCurrList TO <PRE>
  INCLUDED
  R> TO <PRE>
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
