# Получение аргументом названия каталога и порядкового номера
param([string]$arg1)
$Dir = $arg1

# Задание параметров ИНН ДатаСоставления
$INN = '7712038455'
$DateS = '20190131'

# Получение сегодняшней ДатаФормирования
$DateF = Get-date -f {yyyyMMdd}

# Формирование имени zip - файла ИНН_ДатаСоставления_ДатаФормирования_порядковый номер.zip
$file = $INN + '_' + $DateS + '_' + $DateF + '_' + $arg1 + '.zip'

# Добавление файлов в архив без компрессии
Compress-Archive -Path .\$Dir\*.* -DestinationPath $Dir\$file -CompressionLevel NoCompression