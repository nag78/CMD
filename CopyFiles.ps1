# Подключение сетевой папки
$username = 'securityinstall@mai.ru'
$password = 'ek4c3nLeBcEQ'
$path = 'E:\change\'
$target = 'J:\'

New-SmbMapping -UserName $username -Password $password `
    -LocalPath 'J:' -RemotePath '\\172.16.0.216\change' 
#Получение имени последнего, самого свежего файла и добавление его в путь копирования
$file = Get-ChildItem -Path $path | Sort-Object LastWriteTime | Select-Object -Last 1
$fullpath = $path + $file.Name
#Удаление преведущего файла в месте назначения
Remove-Item $target 
#Копирование файла и отключение сетевого диска
if (Copy-Item -Path $fullpath -Destination $target -Verbose) {
    Net Use J: /delete
}



