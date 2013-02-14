\ FALSE TO ?C-JMP 

WARNING DUP @ SWAP 0!
REQUIRE DateTime#      ~ac\lib\win\date\date-int.f
WARNING !

REQUIRE FINE-HEAD      ~pinka/samples/2005/lib/split-white.f
REQUIRE {              ~ac\lib\locals.f
REQUIRE STR@           ~ac\lib\str2.f 
REQUIRE UD.RS          ~pinka\lib\print.f 
REQUIRE list+          ~pinka\lib\list.f
REQUIRE LAMBDA{        ~pinka\lib\lambda.f 
REQUIRE WildCMP-U      ~pinka\lib\mask.f
REQUIRE ParseFileName  ~pinka\lib\parse.f
REQUIRE CONVERT%       ac\get_url_params.f  \ GetParamsFromString

REQUIRE TUCK           tuck.f
REQUIRE MODULE:        spf_modules.f
REQUIRE ForEach-File   findfile2.f
REQUIRE DELETE-FOLDER  FileExt.f
REQUIRE diffsec        ftime.f 
REQUIRE ItsPriority!   ProcessPriority.f

REQUIRE LOG             logger.f
REQUIRE hSkipList       skipfolder.f
REQUIRE ScanFiles       scan_core.f
REQUIRE LoadList        loadlist.f
REQUIRE RemoveFile      purge_core.f
REQUIRE SummVolume      purger_by_size.f
REQUIRE KeepSeconds     purger_by_time.f
REQUIRE ForceDel        purger_force.f
REQUIRE EmptyFoldersDel purge_empty.f
REQUIRE vMaxFileSize    purge_less.f
REQUIRE uKeepList       purge_keep.f
REQUIRE FilesScanned    scan_size.f
REQUIRE -xtf            scan_simple.f
REQUIRE -force          commands.f
REQUIRE ?cgi_params     cgisupport.f

\ -cfg config1.txt
\ -test