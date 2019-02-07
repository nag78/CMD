param([string]$arg1)
$Dir = $arg1
$INN = '7712038455'
$DateS = '20190131'
$DD = "{0:dd}" -f [datetime]::Now
$MM = "{0:MM}" -f [datetime]::Now
$YYYY = "{0:yyyy}" -f [datetime]::Now
$DateF = $YYYY+$MM+$DD
$file = $INN + '_' + $DateS + '_' + $DateF + '_' + $arg1 + '.zip'

Compress-Archive -Path .\$Dir\*.* -DestinationPath $Dir\$file -CompressionLevel NoCompression