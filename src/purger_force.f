\ 06.Oct.2001 Sat 17:44

VARIABLE ForceDel     ForceDel 0! \ форсированно удалять все файлы по маске

..: PurgeOR ( -- )
  ForceDel @    IF  \ если выполнится это, то до других не дойдет.
  ['] ?RemoveFile ScanFiles
  EXIT          THEN
;..
