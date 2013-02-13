: SALLOC-LIST ( a u -- addr )
  DUP 255 U> IF -18 THROW THEN
  DUP CELL+ 2 CHARS + ALLOCATE THROW ( a u a2 )
  \ memory should be zeroed (!)
  DUP >R  CELL+  2DUP C!  CHAR+       ( a u a3 )
  SWAP MOVE R>
  \ see also: ~pinka/lib/ext/alloc.f
;

: list-str+ ( a u list -- )
  >R SALLOC-LIST R> list+
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
  SALLOC-LIST FoldersList list+
;
: AddToSkip ( a u -- ) \ в список пропускаемых
  SALLOC-LIST hSkipList list+
;
