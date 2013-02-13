( -- flag )
   find_data FoundName SpecName?      IF
   find_data hdl-search FindNextFileA IF
   find_data FoundName SpecName?      IF
   find_data hdl-search FindNextFileA ELSE TRUE  THEN
                                      ELSE FALSE THEN
                                      ELSE TRUE  THEN