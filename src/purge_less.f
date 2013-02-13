\ 16.08.03

0 VALUE vMaxFileSize

: -less  ( "size-in-bytes" -- )
 \  NextWord >NUM TO vMaxFileSize
 ParseFileName EVALUATE TO vMaxFileSize
;

..: (?RemoveFile)  ( a-finddata -- )
  vMaxFileSize    IF
  DUP  FoundSize IF 2DROP EXIT THEN
  vMaxFileSize U< 0= IF DROP EXIT THEN
  ( a-finddata )  THEN
;..

..: PurgeOR ( -- )
  vMaxFileSize  IF  \ если выполнится это, то до других не дойдет.
  ['] ?RemoveFile ScanFiles
  EXIT          THEN
;..
