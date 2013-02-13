\ 23.Oct.2001 Tue 17:48

MODULE: Support_ScanningSize  EXPORT

VARIABLE ScaningSize     ScaningSize 0!
VARIABLE ShowDeep        ShowDeep 0!

VARIABLE FilesScanned      FilesScanned 0!   \ счетчик  файлов
VARIABLE FoldersScanned    FoldersScanned 0! \ счетчик  фолдеров
CREATE   SummScanned 0 , 0 ,                 \ объем  файлов

: AtScanSize ( fd -- fd ) ... ;

: +Path ( a u -- a1 u1 )
  <# 0 HOLD HOLDS [CHAR] " HOLD 0. #>
  OVER 1+ SWAP ExtFilePathName
  TUCK + [CHAR] " SWAP !
  2+
;

: SummScanned+ ( d -- )
  SummScanned 2@ D+ SummScanned 2!
;
: StoreStat ( a-find_data -- ) \ only for found file (not folder)
  FoundSize  SummScanned+
  FilesScanned  1+!
;

DEFINITIONS

: HandErr ( ior -- )
  \  THROW
  -1 = IF Log_SkipFolder ELSE Log_NotFolderAccess THEN
;

VARIABLE deep

CREATE buf MAX_PATH ALLOT 0 ,

: TotalStat ( -- )
  FoldersScanned @ S>D 0 UD$RS  LogParam! Log_TotalScannedFolders
  FilesScanned   @ S>D 0 UD$RS  LogParam! Log_TotalScannedFiles
  SummScanned   2@     0 UD$RS  LogParam! Log_TotalScannedSize
;

: ShowStat1 ( d -- d )
  buf DUP MAX_PATH CurrDir@ THROW LogParam! Log_TreeScanned
  FoldersScanned @ S>D 0 UD$RS LogParam! Log_TreeScannedFolders
  FilesScanned @   S>D 0 UD$RS LogParam! Log_TreeScannedFiles  
  2DUP                 0 UD$RS LogParam! Log_TreeScannedSize   
;

: add'\' ( a u -- a u1 | a u )
  2DUP + 1- C@ [CHAR] \ <>  IF
  2DUP + 1- C@ [CHAR] / <>  IF
  2DUP + [CHAR] \ SWAP ! 1+ THEN THEN
;

: ShowStat2 ( d -- d )
  buf DUP MAX_PATH CurrDir@ THROW ( a u )  add'\'
  2DUP FoldersScanned @ S>D 16 UD$RS " {s} at the {''}{s}{''}" DUP STR@ LogParam! Log_TreeScannedFolders STRFREE
  2DUP FilesScanned @   S>D 16 UD$RS " {s} at the {''}{s}{''}" DUP STR@ LogParam! Log_TreeScannedFiles   STRFREE
  2OVER                     16 UD$RS " {s} at the {''}{s}{''}" DUP STR@ LogParam! Log_TreeScannedSize    STRFREE
;
VECT ShowStat
' ShowStat2 TO ShowStat


: ScanBranch ( d-summ -- d-summ )
  buf DUP MAX_PATH GetDir THROW LogParam!  Log_ProcessDir
  FileMask FileNameFilter!
  LAMBDA{ ( d-summ fd -- d-summ ) NxtF
    AtScanSize
    FilesScanned 1+!
    FoundSize D+
  } ForEach-File IF Log_NotFolderAccess ELSE FoldersScanned 1+! THEN
  deep @ ShowDeep @ U< IF ShowStat THEN
;

VECT _ScanTree

: ScanTree ( d-summ -- d-summ )
  deep 1+!
  LAMBDA{ ( a-fd -- )  NxtF
    FoundName 
    2DUP +Path LogParam!
    SetDir ?DUP IF
    HandErr     ELSE
    FoldersScanned @ >R FoldersScanned 0!
    FilesScanned   @ >R FilesScanned 0!
    0. _ScanTree D+
    R> FilesScanned +!
    R> FoldersScanned +!
    UpDir$ COUNT SetDir
    DROP        THEN
  } ForEach-Folder DROP
  -1 deep +!
  ScanBranch
;
' ScanTree TO _ScanTree

: ScanSize ( -- )
  0. Recurse? IF ScanTree ELSE ScanBranch THEN SummScanned+
;

..: ScanAND ( -- )
  ScaningSize @ IF  ScanSize THEN
;..

..: INIT_S
  ScaningSize @         IF
  FoldersScanned 0!
  FilesScanned   0!
  0. SummScanned  2!    THEN
;..

..: RESULT
  ScaningSize @ IF
  TotalStat     THEN 
;..


;MODULE

\ ALSO Support_ScanningSize
\ 2 ShowDeep !