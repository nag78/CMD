@echo off
set logfile="C:\adm\script\stopstartlog.txt"
echo %date% %time% >>%logfile%
net stop "1C:Enterprise 8.3 Server Agent (x86-64)" >>%logfile%
ping -n 16 localhost>Nul
echo %date% %time% >>%logfile%
net start "1C:Enterprise 8.3 Server Agent (x86-64)" >>%logfile%
ping -n 301 localhost>Nul
SetLocal EnableExtensions
Set ProcessName=1C:Enterprise 8.3 Server Agent (x86-64)
TaskList /FI "ImageName EQ %ProcessName%" | Find /I "%ProcessName%"
If %ErrorLevel% NEQ 0 net start "1C:Enterprise 8.3 Server Agent (x86-64)"
exit