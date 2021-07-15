# Подключение сетевой папки
$username = 'securityinstall@mai.ru'
$password = 'ek4c3nLeBcEQ'
$path = 'E:\change\'
$target = 'J:\'

New-SmbMapping -UserName $username -Password $password `
    -LocalPath 'J:' -RemotePath '\\172.16.0.216\change'

$file = Get-ChildItem -Path $path | Sort-Object LastWriteTime | Select-Object -Last 1
$fullpath = $path + $file.Name
Remove-Item $target 
Copy-Item -Path $fullpath -Destination $target



Net Use J: /delete