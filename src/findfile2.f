\ RP, ~1999-2000
\ поиск и выполнение действий над файлами.
\ идея - findfile.txt by  AC

\ 21.09.2000
\ * в ForEach-FolderRecurse при рекурсивном вызове на стеке оставлялся параметр. исправлено.
\ + добавлено ForEach-FolderRecurse2
\ по хорошему, надо делать не xt EXECUTE ,а xt CATCH  :)

\ 12.10.2000
\ * исправлена ошибка в ForEach-Folder (и в ForEach-FolderRecurse), 
\   когда каталог не доступен (SetCurrentDirectory возвращет не успех).

\ 06.Oct.2001 Sat 18:54
\ + ForEach-FolderRecurse3 - вначале рекурсия, потом выполнение xt

\ 20.Oct.2001 Sat 23:12
\ * Fix MAX_PATH  - было 256. теперь 260. очень глубокий глюк.

\ 21.Oct.2001 Sun 15:46
\ * переписанно в findfile2.f
\ * locals.f вместо temps.f
\ * слова возвращают ior
\ * код xt "throw-забельный" (вызывается by CATCH а не EXECUTE )
\ * пофиксен лишний пропуск, т.к. в корне нету  '..' и '.'

REQUIRE {  ~ac\lib\locals.f
REQUIRE [UNDEFINED] lib\include\tools.f
REQUIRE ...         ScatColn.f
REQUIRE TUCK        tuck.f

\ =======================================
GET-CURRENT
TEMP-WORDLIST ALSO CONTEXT !  DEFINITIONS

: find_pre
  S" findfile2_pre.f" INCLUDED
; IMMEDIATE
: find_pst ( -- )
  S" findfile2_pst.f" INCLUDED
; IMMEDIATE
: find_skp ( -- flag )
  S" findfile2_skp.f" INCLUDED
; IMMEDIATE
: 1CATCH  ( x xt -- i*x 0 | ior )
  S" CATCH DUP IF NIP THEN" EVALUATE
; IMMEDIATE
: 2CATCH  ( x x xt -- i*x 0 | ior )
  S" CATCH DUP IF NIP NIP THEN" EVALUATE
; IMMEDIATE
: 3CATCH  ( x x x xt -- i*x 0 | ior )
  S" CATCH DUP IF NIP NIP NIP THEN" EVALUATE
; IMMEDIATE

SET-CURRENT

\ =======================================

WINAPI: FindFirstFileA       KERNEL32.DLL
WINAPI: FindNextFileA        KERNEL32.DLL
WINAPI: FindClose            KERNEL32.DLL
[UNDEFINED] GetFileAttributesA              [IF]
WINAPI: GetFileAttributesA   KERNEL32.DLL   [THEN]
[UNDEFINED] GetCurrentDirectory             [IF]
WINAPI: GetCurrentDirectoryA KERNEL32.DLL   [THEN]
[UNDEFINED] SetCurrentDirectoryA            [IF]
WINAPI: SetCurrentDirectoryA KERNEL32.DLL   [THEN]

: FindFirstFile  POSTPONE FindFirstFileA ; IMMEDIATE
: FindNextFile   POSTPONE FindNextFileA  ; IMMEDIATE
: SetCurrentDirectory  POSTPONE SetCurrentDirectoryA ; IMMEDIATE
: GetCurrentDirectory  POSTPONE GetCurrentDirectoryA ; IMMEDIATE

\ FindFirstFile ( win32_find_data-addr  FileName-addr  --  handle | -1 )
\ FindNextFile  ( win32_find_data-addr  handle  --  0 | 1 )
\ FindClose     ( handle  --  0 | 1 ) 
\ SetCurrentDirectory ( az -- 0 | 1 )       \ 1=succeeds
\ GetCurrentDirectory ( buf-a buf-u -- n )  \ 0=unsucceeds

[UNDEFINED] MAX_PATH  [IF]
260 CONSTANT MAX_PATH [THEN]

[UNDEFINED] INVALID_HANDLE_VALUE        [IF]
-1 CONSTANT INVALID_HANDLE_VALUE        [THEN]

[UNDEFINED] ERROR_NO_MORE_FILES         [IF]
18 CONSTANT ERROR_NO_MORE_FILES         [THEN]

[UNDEFINED] ERROR_FILE_NOT_FOUND        [IF]
02 CONSTANT ERROR_FILE_NOT_FOUND        [THEN]

[UNDEFINED] FILE_ATTRIBUTE_DIRECTORY    [IF]
16 CONSTANT FILE_ATTRIBUTE_DIRECTORY    [THEN]


VOCABULARY Support_WIN32_FIND_DATA
GET-CURRENT  ALSO Support_WIN32_FIND_DATA DEFINITIONS

  0
  4 -- dwFileAttributes
  8 -- ftCreationTime
  8 -- ftLastAccessTime
  8 -- ftLastWriteTime
  4 -- nFileSizeHigh
  4 -- nFileSizeLow
  4 -- dwReserved0
  4 -- dwReserved1
MAX_PATH -- cFileName     \ [ MAX_PATH ]
 14 -- cAlternateFileName \ [ 14 ]

SWAP SET-CURRENT

CONSTANT /WIN32_FIND_DATA

: FoundAttributes ( a-find_data -- u )
  dwFileAttributes @
;
: FoundName ( a-find_data -- a u )
  cFileName ASCIIZ>
;
: FoundCDate ( a-find_data -- t-lo t-hi )
  ftCreationTime 2@ SWAP
;
: FoundADate ( a-find_data -- t-lo t-hi )
  ftLastAccessTime 2@ SWAP
;
: FoundWDate ( a-find_data -- t-lo t-hi )
  ftLastWriteTime 2@ SWAP
;
: FoundSize ( a-find_data -- size-lo size-hi )
  DUP  nFileSizeLow  @
  SWAP nFileSizeHigh @
;
VECT FoundDate  ( -- tlo thi ) \ file time based on the Coordinated Universal Time (UTC)
' FoundWDate TO FoundDate

: IsFoundFolder ( a-find_data -- flag )
   FoundAttributes
   FILE_ATTRIBUTE_DIRECTORY AND  FILE_ATTRIBUTE_DIRECTORY =
;

PREVIOUS

: SetDir1 ( a u -- ior )
  DROP SetCurrentDirectoryA ERR
;
: SetDir ( a u -- ior )
  ...
  DROP SetCurrentDirectoryA ERR
;
: GetDir ( a u -- u1 ior )
  TUCK
  GetCurrentDirectoryA  DUP ERR >R
  TUCK U< IF DROP 0 THEN R>
;

: ThePath ( -- a u ) \ in the PAD
  0 0 \  GetDir <# HOLDS 0. #>
;
: FoundPathName ( fd -- a u ) \ in the PAD
  DROP 0 0 \ GetDir <# HOLDS 0. #>
;

CREATE MaskAll$  S" *"   S", 0 C,
CREATE UpDir$    S" .."  S", 0 C,
CREATE ItDir$    S" ."  S", 0 C,

: ItDir? ( a u -- flag )
  ItDir$ COUNT COMPARE 0= 
;
: UpDir? ( a u -- flag )
  UpDir$ COUNT COMPARE 0= 
;
: SpecName? ( a u -- flag )
  2DUP ItDir$ COUNT COMPARE IF
  UpDir$ COUNT COMPARE 0=   ELSE
  2DROP TRUE                THEN
;

USER __FileNameFilter-A
: FileNameFilter! ( addr u -- ) \ at addr+u must be 0x00
  DROP __FileNameFilter-A !
;
: __FileNameFilter ( -- a ) \ дает установленный только один раз.
  __FileNameFilter-A @ ?DUP IF
  __FileNameFilter-A 0!     ELSE
  MaskAll$ 1+               THEN
;
: ForEach-File ( xt -- ior )
\ выполнить xt над каждым файлом (не каталогом).
\ xt ( find_data -- )
   0 { xt cont \ find_data  hdl-search }
   find_pre                               BEGIN
   find_data IsFoundFolder 0=   IF
   find_data xt 1CATCH -> cont  THEN
   cont 0=                                WHILE
   find_data hdl-search FindNextFileA 0=  UNTIL THEN
   find_pst cont
;
: ForEach-Folder ( xt -- ior )
\ выполнить xt над каждым фолдером (каталогом).
\ Элементы "." и  ".." - пропускаются.
\ xt ( find_data -- )
   0 { xt cont \ find_data  hdl-search }
   find_pre                                     find_skp IF
                                             BEGIN
   find_data IsFoundFolder      IF
   find_data xt 1CATCH -> cont  THEN cont 0= WHILE
   find_data hdl-search FindNextFileA  0=    UNTIL THEN  THEN
   find_pst cont
;
: ForEach-Dir ( xt -- ior )
\ выполнить xt над каждым фолдером (каталогом).
\ Элементы "." и  ".." - НЕ пропускаются.
\ xt ( find_data -- )
   0 { xt cont \ find_data  hdl-search }
   find_pre                                  BEGIN
   find_data IsFoundFolder      IF
   find_data xt 1CATCH -> cont  THEN cont 0= WHILE
   find_data hdl-search FindNextFileA 0=     UNTIL THEN
   find_pst cont
;
: ForEach-FileRecord  ( xt -- ior )
\ выполнить xt над каждым файловой записью (файлом и каталогом).
\ Элементы "." и  ".." - НЕ пропускаются.
\ xt ( find_data -- ) 
   0 { xt cont \ find_data  hdl-search }
   find_pre                              BEGIN
   find_data xt 1CATCH  ?DUP 0=          WHILE
   find_data hdl-search FindNextFileA 0= UNTIL ELSE -> cont THEN
   find_pst cont
;
: InThe-Folder ( xt a u -- ior )
\ xt ( -- )
   SetDir ?DUP 0=            IF
   CATCH
   UpDir$ COUNT SetDir DROP  THEN
;
: InEach-FolderRecurse3  ( xt -- ior )
\ Выполнить xt в каждом каталоге (включая текущий) рекурсивно.
\ Если нет доступа - каталог пропускается.
\ Вначале - рекурсия, потом выполнение xt
\ xt ( -- )
   0 { xt cont \ find_data  hdl-search }
   find_pre                                     find_skp IF
                                         BEGIN
   find_data IsFoundFolder            IF
   find_data FoundName SetDir 0= IF
   xt RECURSE  ( ior ) -> cont
   UpDir$ COUNT SetDir DROP      THEN THEN
   cont   0=                             WHILE
   find_data hdl-search FindNextFileA 0= UNTIL THEN      THEN
   find_pst  cont ?DUP IF EXIT THEN  xt CATCH
;
VECT InEach-FolderRecurse
' InEach-FolderRecurse3 TO InEach-FolderRecurse

: FileExist ( addr u -- flag )
    DROP GetFileAttributesA -1 <>
;

CONTEXT @  PREVIOUS  FREE-WORDLIST
