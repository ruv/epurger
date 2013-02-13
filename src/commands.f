
: weeks    604800  * + ;
: days     86400 * + ;
: hours    3600 * + ;
: minutes  60 * + ;
: seconds  1 * + ;

: KeepDays: ( "ccc" -- )
  0 NextWord EVALUATE
  days KeepSeconds !
;
: -p ( "ccc" -- )
  ParseFileName EVALUATE FilePause !
;
: -period ( "ccc" -- )
  ParseFileName EVALUATE FilePeriod !
;
: -HIGH
  HIGH_PRIORITY_CLASS ItsPriority!
;
: -NORMAL
  NORMAL_PRIORITY_CLASS ItsPriority!
;
: -IDLE
  IDLE_PRIORITY_CLASS ItsPriority!
;

: -r TRUE recursive ! ;

: -scan TRUE Scanner ! ;

: -size -scan TRUE ScaningSize ! ;
: -deep ParseFileName EVALUATE ShowDeep ! ;

: -purge TRUE Purger  ! ;

: -e TRUE EmptyFoldersDel ! ; 
: -ef ParseFileName EVALUATE EmptyFileSize ! ;
: -d KeepDays: ;
: -m ( "ccc" -- ) \ file mask
  ParseFileName     HERE FMask !  S", 0 ,
;
: -sl  ( "ccc" -- ) \ save list. файл со списком пропускаемых каталогов (можно по маске)
  ParseFileName hSkipList LoadList
;
: -dl  ( "ccc" -- ) \ directories list. файл со списком обрабатываемых каталогов
  ParseFileName FoldersList LoadList
;
: -dir ( "ccc" -- ) \ directory. обрабатываемый каталог
  ParseFileName AddToDirs
;
: -dir. ( -- ) \ текущий каталог
  PAD DUP MAX_PATH CurrDir@ THROW AddToDirs
;
: -cfg ( "ccc" -- ) \ configure. конфиг-файл
  ParseFileName 2DUP 2>R
  INCLUDE-PROBE  IF
  2R> +ModuleDirName INCLUDE-PROBE DROP  ELSE
  RDROP RDROP THEN
;
: -logstd  \ log to stdout
  TRUE LogStd !
;
: -log   ( "ccc" -- ) \ log  file
  HERE ParseFileName S", 0 C, LogFile !
;
: -l ( "ccc" -- ) \ log level
  ParseFileName EVALUATE LogLevel !
;
: -a
  ['] FoundADate TO FoundDate
;
: -c
  ['] FoundCDate TO FoundDate
;
: -w
  ['] FoundWDate TO FoundDate
;

: -force ( -- )
  TRUE ForceDel !
;

: -test ( -- )
  ['] Fake_DELETE-FILE   TO DeleteFile
  ['] Fake_DELETE-FOLDER TO DeleteFolder
;

: -skb 
  ParseFileName EVALUATE
  1024 * SummVolume !
;
: -smb
  ParseFileName EVALUATE
  1048576 * SummVolume !
;
: -akb 
  ParseFileName EVALUATE
  1024 * SummVolumeR !
;
: -amb
  ParseFileName EVALUATE
  1048576 * SummVolumeR !
;


CREATE helpfile  S" eachfile.txt" S", 0 C,
CREATE ExeName   S" eachfile.exe" S", 0 C,

MODULE: Support_Help

: PRE-TYPECR\
  SOURCE TYPE CR POSTPONE \
;

EXPORT

: -help
  ['] ANSI><OEM BEHAVIOR >R
  ['] <PRE> BEHAVIOR >R
  CGI? @ 0= IF ['] ANSI>OEM TO ANSI><OEM THEN
  ['] PRE-TYPECR\ TO <PRE>
  helpfile COUNT +ModuleDirName INCLUDE-PROBE IF
  helpfile COUNT INCLUDE-PROBE
  IF helpfile COUNT TYPE ."  -not found" CR THEN THEN
  R> TO <PRE>
  R> TO ANSI><OEM
;

: -h
  ." EPurger ver 1.2 "           CR
  " usage: {ExeName COUNT} <keys> "  STYPE CR
  " for help: {ExeName COUNT} -help |more " STYPE CR
  " See {helpfile COUNT} for details... " STYPE CR
;
: /h -h ;
: /? -h ; 

;MODULE
