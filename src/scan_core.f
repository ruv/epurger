\ 06.Oct.2001 Sat 17:44

VARIABLE FoldersList FoldersList 0! \ список обрабатываемых каталогов.
VARIABLE recursive  recursive 0! \ flag обрабатывать вложенные каталоги

VARIABLE FilePause   FilePause 0!   \  пауза после каждых FilePeriod файлов.
VARIABLE FilePeriod  1000 FilePeriod !
VARIABLE FMask       HERE FMask ! S" *" S", 0 C, 

VARIABLE Purger   Purger  0! 
VARIABLE Scanner  Scanner 0! 

: Purge? Purger  @ ;
: Scan?  Scanner @ ;
: Recurse?  recursive @ ;


MODULE: Support_ScannerCore

VARIABLE FileCount   FileCount 0!

EXPORT

CREATE NowTime 0 , 0 ,

: RefreshNowTime ( -- )
  NowFTime NowTime 2!
;
: NxtF ( -- )
  FilePause @ 0= IF EXIT THEN
  FileCount 1+!
  FileCount @ FilePeriod @ >  IF
  FileCount 0!
  FilePause @ PAUSE
  RefreshNowTime              THEN
;
: FileMask FMask @ COUNT ;

: SetCurrFolder ( a u -- )
  RefreshNowTime
  2DUP LogParam!
  SetDir ?DUP IF Log_NotFolderAccess THROW THEN
;

DEFINITIONS

USER aScanAction  \ xt ( a-fd -- )

: action ( -- xt )
  HERE MAX_PATH GetDir THROW HERE SWAP LogParam!
  Log_ProcessDir
  FileMask FileNameFilter!
  aScanAction @ 
;

: (ForFileRecords) ( -- )
  action  ForEach-FileRecord DROP NxtF
;
: (ForFiles) ( -- )
  action ForEach-File DROP NxtF
;
: (ForFolders) ( -- )
  action ForEach-Folder DROP NxtF
;

EXPORT
: InFolders ( xt -- ) \ xt ( -- ) \ Action in the each folder ( at them self), recurse or not
  Recurse?  IF
  InEach-FolderRecurse
  DROP      ELSE
  EXECUTE   THEN
;
: ScanFileRecords ( xt -- ) \ xt ( a-fd -- ) \ Action for each file-record
  aScanAction !
  ['] (ForFileRecords) InFolders
;
: ScanFiles ( xt -- ) \ xt ( a-fd -- ) \ Action for each file, recurse or not
  aScanAction !
  ['] (ForFiles) InFolders
;
: ScanFolders ( xt -- ) \ xt ( a-fd -- ) \ Action for each folder, recurse or not
  aScanAction !
  ['] (ForFolders) InFolders
;

: PurgeOR ( -- ) ... ;
: PurgeAND ( -- ) ... ;
: ScanAND ( -- ) ... ;

: ScanPath ( -- )
  Purge? IF PurgeOR PurgeAND THEN
  Scan?  IF ScanAND THEN
;
\ ================================================================
DEFINITIONS

: (ProcessListElement) ( node -- )
  CELL+ COUNT ['] SetCurrFolder CATCH IF 2DROP EXIT THEN
  ScanPath
;

CREATE SavedPath 260 ALLOT

EXPORT

: RESULT ... ;
: INIT_S ... RefreshNowTime ;

DEFINITIONS

: (Scan) ( -- )
  INIT_S
  FoldersList @ IF
  ['] (ProcessListElement) FoldersList  List-ForEach
  ELSE
    ScanPath
  THEN
  RESULT
;

EXPORT

: Scan ( -- )
  StartLog
   SavedPath 260 GetDir THROW >R
   \ SEEN-ERR
   ['] (Scan) CATCH ERROR
   SavedPath R> SetDir1 DROP
  StopLog
;

;MODULE
