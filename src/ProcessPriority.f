\ 13.Nov.2001 Tue 17:13

REQUIRE [UNDEFINED] lib\include\tools.f


[UNDEFINED] GetCurrentProcess           [IF]
WINAPI: GetCurrentProcess KERNEL32.DLL  [THEN]

[UNDEFINED] SetPriorityClass            [IF]
WINAPI: SetPriorityClass  KERNEL32.DLL  [THEN]

( SetPriorityClass (
    DWORD dwPriorityClass   // priority class value
    HANDLE hProcess,    // handle to the process  
  -- BOOL )
 
: ItsPriority! ( dwPriorityClass -- )
  GetCurrentProcess SetPriorityClass ERR THROW
;

0x00000020 CONSTANT NORMAL_PRIORITY_CLASS
0x00000040 CONSTANT IDLE_PRIORITY_CLASS
0x00000080 CONSTANT HIGH_PRIORITY_CLASS
0x00000100 CONSTANT REALTIME_PRIORITY_CLASS
