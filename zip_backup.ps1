$DirSource = 'C:\SQL'
$DirDestination = 'D:\Archive'

$Date = Get-Date -f {yyyyMMdd}

$file = $Date + '_' + 'sql' + '.zip'


Compress-Archive -Path $DirSource\ -DestinationPath \$DirDestination\$file -CompressionLevel NoCompression