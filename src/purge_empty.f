\ 21.Oct.2001 Sun 03:00

MODULE: Support_PurgeEmpty  EXPORT

VARIABLE EmptyFoldersDel  EmptyFoldersDel 0! \ flag - удалять пустые каталоги
VARIABLE EmptyFileSize EmptyFileSize 0! \ удалить все файлы, которые менее заданного объема.

DEFINITIONS

: PurgeFilesAction ( a-find_data -- )
    DUP FoundSize EmptyFileSize @ S>D D<  IF
    DUP RemoveFile                        THEN
    DROP
;
: PurgeFoldersAction ( a-find_data -- )
    DUP IsFoundFolder  IF
    DUP RemoveFolder   THEN
    DROP 
;
: PurgeEmpty  ( -- )
  EmptyFileSize @   IF
  ['] PurgeFilesAction
  ScanFiles         THEN
  EmptyFoldersDel @ IF
  FMask @   MaskAll$ FMask !
  ['] PurgeFoldersAction ScanFileRecords
  FMask !           THEN
;

..: PurgeAND ( -- )  PurgeEmpty ;..

..: RESULT
  Purge? EmptyFoldersDel @ AND   IF
  FoldersDeleted @ S>D 0 UD$RS LogParam!
  Log_TotalFoldersDeleted        THEN
;..


;MODULE
