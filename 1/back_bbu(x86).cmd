if not exist R:\ net use R: \\172.16.10.116\1c-backup\ /YES

set YY=%date:~6,4%
set DT=%date%
set filename = R:\“\%YY%\%date%_bgu.dt
set logfile = R:\LOG\bgu_backup.log
set exe = "C:\Program Files\1cv8\8.3.9.2233\bin\1cv8.exe"
set srv = "1cserever\bgu"
set user = "Nag"
set pass = "3edCVfr4"

IF NOT EXIST R:\“\%YY% MKDIR R:\“\%YY%
if exist %filename% EXIT

echo %DT% >> %logfile%

%exe% CONFIG /S%srv%/N%user% /P%pass% /DumpIB%filename% /OUT%logfile% -NoTruncateif 

EXIT
