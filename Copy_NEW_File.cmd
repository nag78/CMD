@echo off
for /F %%A in ('G:\ /B /O-D asupk_z_*.bak') do echo %%A & goto exit
:exit

rem robocopy %%A "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\asupk_z\asupk.bak" 