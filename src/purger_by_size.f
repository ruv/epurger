\ 20.Oct.2001 Sat 19:46


MODULE: Support_PurgeBySize  EXPORT

VARIABLE SummVolume   SummVolume  0! \ суммарный объем файлов каждого каталога
VARIABLE SummVolumeR  SummVolumeR 0! \ суммарный объем файлов дерева

DEFINITIONS

0 \ node
4 -- link
/WIN32_FIND_DATA -- find_data
CONSTANT /node

VARIABLE CurrList
CREATE CurrVolume 0 , 0 ,

: CurrVolume+ ( d -- )
  CurrVolume 2@ D+   CurrVolume 2!
;
: CurrVolume- ( d -- )
  DNEGATE CurrVolume 2@ D+   CurrVolume 2!
;

: (StoreData) ( a -- )
  DUP FoundSize  CurrVolume+
  /node ALLOCATE THROW >R
  R@ find_data /WIN32_FIND_DATA MOVE
  R@ find_data FoundName ExtFilePathName 2DROP 
  R> CurrList list+
  NxtF
;
: ReadBranch ( -- ) \ читает ветку в текущий список файлов CurrList
  FileMask  FileNameFilter!
  ['] (StoreData) ForEach-File DROP
;
: ReadTree ( -- )
  ['] ReadBranch InEach-FolderRecurse DROP
;

: ListCount ( list -- count )
  >R 0
  LAMBDA{ ( count node -- count+1 ) DROP 1+ }
  R> List-ForEach
;

: ListToArray ( list -- ar n )
  DUP ListCount DUP >R
  CELLS ALLOCATE THROW DUP >R
  SWAP ( ar list )
  LAMBDA{ ( ar node -- ar' )
    OVER ! CELL+
  } ( ar list xt )
  SWAP List-ForEach
  DROP
  R> R>
;

\ ============================================================
\ Sort

\ ===============================
\ Доступ к линейным массивам с ячейками размером CELL
\ ( см. www.forth.org.ru\~mlg\CStyleIn\CStyleIndexing.html )

: []   ( i a-mas0 -- value ) 
  SWAP CELLS + @ 
;
: []!  ( value i a-mas0 -- )
  SWAP CELLS + !
;
: []^   ( i a-mas0 -- value ) 
  SWAP CELLS + 
;

\ ===============================

0 VALUE array
0 VALUE <N>

\ для универсальной реализации
: []exch[] { a b -- }
    a array []    b array []
    a array []!   b array []! 
;
: []>[]  { i j -- flag }
    i array [] find_data FoundDate
    j array [] find_data FoundDate
    DNEGATE D+ 0. D<
;
: []<[]  { i j -- flag }
    j array [] find_data FoundDate
    i array [] find_data FoundDate
    DNEGATE D+ 0. D<
;

S" QSORT.F" INCLUDED

: SortArray ( ar n -- )
\ вначале - более новые. более старые - в конце.
  SWAP TO array
  DUP TO <N>
  ?DUP IF 0 SWAP 1- quick_sort THEN
;

REQUIRE UD.RS  ~pinka\lib\print.f 

: .array  ( ar n -- )
  CELLS OVER + SWAP ?DO
    I @ find_data DUP
    FoundDate 30 UD.RS SPACE
    FoundName TYPE SPACE         CR
  [ 1 CELLS ] LITERAL
  +LOOP
;
: .arr ( -- ) array <N> .array ;

\ ============================================================

: ToArray ( -- )
  CurrList ListToArray  SortArray
;

: FreeCurrArray ( -- ) \ освобождает и список.
  array <N>
  OVER + SWAP ?DO
    I @ FREE THROW
  [ 1 CELLS ] LITERAL
  +LOOP
  array FREE THROW  0 TO array  0 TO <N>
  CurrList 0!
  0. CurrVolume 2!
;

: DeleteFiles ( -- )
  <N> 1-            BEGIN ( n )
  DUP -1 <>         WHILE ( n )
  SummVolume @ S>D
  CurrVolume 2@ D<  WHILE
  DUP array [] find_data
  DUP ?RemoveFile
  IsRemoved              IF ( n find_data )
  FoundSize CurrVolume-  ELSE
  2DROP EXIT             THEN
  1-                REPEAT
                    THEN DROP
;

: PurgeBranch ( -- )
  ReadBranch  ToArray
  DeleteFiles
  FreeCurrArray
;
: PurgeTree ( -- )
  ReadTree  ToArray
  DeleteFiles
  FreeCurrArray  
;

: PurgeBySize ( -- ) \ пуржит текущий каталог

  SummVolume @  IF  ['] PurgeBranch InFolders THEN

  SummVolumeR @   IF Recurse?  IF
  SummVolume @ >R SummVolumeR @  SummVolume !
   PurgeTree      
  R> SummVolume ! THEN         THEN
;

..: PurgeOR ( -- )
  SummVolume @ SummVolumeR @ OR IF \ если выполнится это, то до других не дойдет.
  PurgeBySize  EXIT             THEN
;..

;MODULE

\ ALSO Support_PurgeBySize
