$DirSource = 'H:\Backups\month'
$DirDestination = '\\172.16.226.17\store\sql\'

$Date = Get-Date -f {yyyyMMdd}

$file = $Date + '_' + 'sql' + '.zip'


Compress-Archive -Path $DirSource\ -DestinationPath \$DirDestination\$file -CompressionLevel NoCompression