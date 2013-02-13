\ 21.Nov.2001 Wed 04:17 

findfile2.f

REQUIRE LAMBDA{ ~pinka\lib\lambda.f

: InEach-SubFolder ( xt -- ior )
\ xt ( -- )
  LAMBDA{ ( xt fd -- xt )
    OVER SWAP
    FoundName InThe-Folder DROP
  } ForEach-Folder  NIP
;
: InEach-FolderRecurse2  ( xt -- ior )
  DUP CATCH ?DUP IF NIP EXIT THEN
  LAMBDA{ ( xt -- xt )
    DUP RECURSE THROW
  } InEach-SubFolder
;
