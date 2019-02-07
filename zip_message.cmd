REM Входные данные:
REM INN - инн организации
REM DateS - Дата составления
REM DateF - Дата формирования
REM x - порядковый номер дня

SET INN = 7712038455
SET DateS = 20180207
set dd=%DATE:~0,2%
set mm=%DATE:~3,2%
set yyyy=%DATE:~6,4%
set DateF=%yyyy%%mm%%dd%


IF NOT EXIST %1
    SET x = 1
ELSE SET x = %1



