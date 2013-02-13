 /WIN32_FIND_DATA ALLOCATE THROW  -> find_data
 find_data __FileNameFilter  FindFirstFileA
 DUP INVALID_HANDLE_VALUE =                           IF
 DROP   GetLastError DUP
 ERROR_FILE_NOT_FOUND =
 IF DROP ELSE -> cont THEN                            ELSE
 -> hdl-search
