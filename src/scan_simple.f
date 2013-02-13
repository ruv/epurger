\ 27.Jan.2002 Sun 02:53
\ предложенно ~ac

MODULE: Support_ScanSimple

FALSE VALUE ScanSimpleYes

VECT vProcessFile    ( fd -- )   ' DROP TO vProcessFile  
VECT vProcessFolder  ( fd -- )   ' DROP TO vProcessFolder

EXPORT

: -xtf '  TO vProcessFile   TRUE TO ScanSimpleYes TRUE Scanner ! ;
: -xtd '  TO vProcessFolder TRUE TO ScanSimpleYes TRUE Scanner ! ;

DEFINITIONS 

: ProcessFolder1 ( fd -- )
  DUP FoundName SpecName? IF DROP EXIT THEN
  vProcessFolder
;
VECT ProcessFolder  ' ProcessFolder1 TO ProcessFolder

: ProcessFileRecord ( fd -- )
  DUP IsFoundFolder IF ProcessFolder ELSE vProcessFile THEN
;
: ScanSimple ( -- )
  FileMask FileNameFilter!
  ['] ProcessFileRecord  ForEach-FileRecord DROP
;

..: ScanAND
    ScanSimpleYes IF ['] ScanSimple InFolders THEN
;..

;MODULE
