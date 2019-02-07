param([string]$arg1)
$Dir = $arg1
$INN = '7712038455'
$DateS = '20190131'
$DateF = Get-date -f {yyyyMMdd}
$file = $INN + '_' + $DateS + '_' + $DateF + '_' + $arg1 + '.zip'

Compress-Archive -Path .\$Dir\*.* -DestinationPath $Dir\$file -CompressionLevel NoCompression