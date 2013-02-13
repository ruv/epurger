\ 06.Oct.2001 Sat 17:44

VARIABLE KeepSeconds KeepSeconds  0! \ не удалять файлы моложе заданного числа секунд.

..: (?RemoveFile)  ( a-finddata -- )
  KeepSeconds @   IF
  DUP  FoundDate
  NowTime 2@  diffsec
  KeepSeconds @ U<  IF DROP EXIT THEN
  ( a-finddata )  THEN
;..

..: PurgeOR ( -- )
  KeepSeconds @ IF  \ если выполнится это, то до других не дойдет.
  ['] ?RemoveFile ScanFiles
  EXIT          THEN
;..

