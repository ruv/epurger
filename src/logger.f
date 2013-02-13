REQUIRE [UNDEFINED]     lib\include\tools.f
REQUIRE TOEND-FILE      ~pinka\lib\FileExt.f
REQUIRE DateTime#       ~ac\lib\win\date\date-int.f 

[UNDEFINED] CRLF [IF]
: CRLF LT LTL @ ;
                [THEN]

VARIABLE LogStd LogStd 0!
: LogStd? LogStd @ ;

\ ==========================================================
0 VALUE CGICmd-A
0 VALUE CGICmd-U
: CGICmd! ( a u -- )
  TO CGICmd-U TO CGICmd-A
;
\ ==========================================================

VARIABLE LogLevel  5 LogLevel !
VARIABLE LogFile  HERE S" epurger.log" S", 0 , LogFile !

0 VALUE  H-LOG
\ ==========================================================

: 2LOG1  { a u -- }
  H-LOG IF a u H-LOG WRITE-FILE THROW THEN
  LogStd @ IF a u TYPE THEN
;
VECT 2LOG  ' 2LOG1 TO 2LOG

: CRLOG ( -- ) LT LTL @ 2LOG ;

: StartLog ( -- )
  LogLevel @ 0= IF EXIT THEN
  LogFile @ IF
   LogFile @ COUNT W/O OPEN-FILE-SHARED IF DROP
   LogFile @ COUNT W/O CREATE-FILE-SHARED
   DUP IF ." cant open logfile" CR THEN THROW  THEN
   TO H-LOG  H-LOG TOEND-FILE DROP
  THEN
  CRLOG
  S" <30>Log started: " 2LOG
  <<# CurrentDateTime#Z #> 2LOG CRLOG
  S" - CommandLine: " 2LOG GetCommandLineA ASCIIZ> 2LOG CRLOG
  CGI? @ IF
   S" - CGI " 2LOG
   POST? @ IF S" (POST) " ELSE S" (GET) " THEN 2LOG
   S" cmdl= " 2LOG CGICmd-A CGICmd-U 2LOG   CRLOG
  THEN
;

: StopLog
  LogLevel @ 0= IF EXIT THEN
  S" <30>Log stoped: " 2LOG
  <<# CurrentDateTime#Z #> 2LOG CRLOG
   H-LOG IF H-LOG CLOSE-FILE THROW 0 TO H-LOG THEN
;


\ ==========================================================

: LogStr: ( level "ccc" -- )
  CREATE
  , HERE 0 , :NONAME SWAP !
  DOES> ( -- )
    ( addr )
    H-LOG 0= IF DROP EXIT THEN
    DUP @ LogLevel @ U< IF CELL+ @ EXECUTE EXIT THEN
    DROP
;

VARIABLE logparam-a
VARIABLE logparam-u
: LogParam! ( a u -- ) logparam-u ! logparam-a ! ;
: LogParam ( -- a u ) logparam-a @ logparam-u @ ;
: .LogParam ( a1 u1 -- ) 2LOG LogParam 2LOG CRLOG ;

1 LogStr: Log_ErrorInOptions
  S" - Error, " .LogParam
;
1 LogStr: Log_TestFileDelete
  S" - Test, file delete: " .LogParam
;
1 LogStr: Log_TestFolderDelete
  S" - Test, check for delete folder: " .LogParam
;
1 LogStr: Log_TotalFoldersDeleted
  S" - total deleted folders: " .LogParam
;
1 LogStr: Log_TotalFilesDeleted
  S" - total deleted files:   " .LogParam
;
1 LogStr: Log_TotalScannedFolders
  S" - scan: total stayed folders: " .LogParam
;
1 LogStr: Log_TotalScannedFiles
  S" - scan: total stayed files: " .LogParam
;
1 LogStr: Log_TotalScannedSize
  S" - scan: total stayed size: " .LogParam
;
2 LogStr: Log_TreeScanned
  S" - tree scanned: " .LogParam
;
2 LogStr: Log_TreeScannedFolders
  S" - tree scanned folders:" .LogParam
;
2 LogStr: Log_TreeScannedFiles
  S" - tree scanned files:  " .LogParam
;
2 LogStr: Log_TreeScannedSize
  S" - tree scanned size:   " .LogParam
;
3 LogStr: Log_NotFolderAccess
  S" - can't access to folder:                      " .LogParam
;
3 LogStr: Log_NotFileAccess
  S" - can't delete file: " .LogParam
;
5 LogStr: Log_ProcessDir
  S" - process directory: " .LogParam
;
10 LogStr: Log_FolderDeleted
  S" - deleted empty folder: "  .LogParam
;
11 LogStr: Log_FileDeleted
  S" - deleted file: "  .LogParam
;
15 LogStr: Log_SkipFolder
  S" - skiped folder:                               " .LogParam
;
