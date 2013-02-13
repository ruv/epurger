\ 05.Nov.2001 Mon 03:47

VARIABLE FilesDeleted      FilesDeleted 0!   \ счетчик удаленных файлов
VARIABLE FoldersDeleted    FoldersDeleted 0! \ счетчик удаленных фолдеров
CREATE   SummDeleted 0 , 0 ,                 \ объем удаленных файлов

VECT DeleteFile      ' DELETE-FILE   TO DeleteFile
VECT DeleteFolder    ' DELETE-FOLDER TO DeleteFolder

: Fake_DELETE-FILE   ( a u -- ior ) \  заглушка
  LogParam!  Log_TestFileDelete
  0
;
: Fake_DELETE-FOLDER ( a u -- ior ) \  заглушка
  LogParam!  Log_TestFolderDelete
  1
;

: AddSummDeleted ( d -- )
  \ D>S SummDeleted +!
  SummDeleted 2@ D+ SummDeleted 2!
;
: DelFile ( a u -- ior )
  2DUP LogParam!   NxtF
  DeleteFile    DUP     IF
  Log_NotFileAccess     ELSE
  Log_FileDeleted       THEN
;
: DelFolder ( a u -- ior )
  2DUP LogParam!   NxtF
  DeleteFolder DUP 0= IF \ удаляет, если пустой
  Log_FolderDeleted   THEN
;

0 VALUE IsRemoved

: RemoveFile ( a-fd -- )
  DUP FoundName DelFile 0=
  DUP TO IsRemoved      IF
  DUP FoundSize AddSummDeleted
  FilesDeleted 1+!      THEN DROP
;
: RemoveFolder ( a-fd -- )
  FoundName DelFolder 0=
  DUP TO IsRemoved    IF
  FoldersDeleted 1+!  THEN
;
: (?RemoveFile) ( a-finddata -- a-finddata ) ... RemoveFile ;

: ?RemoveFile  ( a-finddata -- )
  FALSE TO IsRemoved    (?RemoveFile)  
;

..: INIT_S
  Purge?            IF
  FoldersDeleted 0!
  FilesDeleted 0!
  0. SummDeleted 2!
                    THEN
;..

..: RESULT
  Purge? IF
   SummDeleted  2@    0 UD$RS " ({s} bytes)" 
   FilesDeleted @ S>D 0 UD$RS " {s} " TUCK S+
   DUP STR@ LogParam! Log_TotalFilesDeleted STRFREE
  THEN
;..
