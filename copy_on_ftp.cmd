rem *****Отключаем вывод на экран******
echo off

rem *****Переменные******
set ftp_host = 172.16.10.17
set ftp_user = nag
set ftp_pass = 110878
set file_transport = transport.txt
set base_name = %1
set dir_from = %2
set dir_to = %3

rem *****Вычислим параметры текущей даты и имени файла*****
set year = %date%:~6%
set month = %date%:~3,-5%
set day = %date%:~0,-8%
set file_name = "%base_name%_backup_%year%_%month%_%day%_*.bak"
set file_name_on_ftp = "%base_name%_backup_%year%_%month%_%day%.bak"

rem*****Создаем файл с командами ftp****
echo open %ftp_host% > %file_transport%
echo user %ftp_user% >> %file_transport%
echo cd %dir_to% >> %file_transport%
echo lcd %dir_from% >> %file_transport%
echo put %file_name% %file_name_on_ftp% >> %file_transport%
echo bye >> %file_transport%

rem ***** Запускаем на исполнение ****
ftp -v -n -s:%file_transport%

rem ****** Удаляем файл с командами ftp******
rem del %file_transport%