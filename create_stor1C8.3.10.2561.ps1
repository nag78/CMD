$Path = 'C:\Program Files\1cv8\8.3.10.2561\bin\crserver.exe'
$pathFull = $Path + ' -srvc -port 1842 -range 1860:1891 -d E:\storage'

New-Service -Name 1C_Storage_8.3.10.2561 -BinaryPathName $pathFull -StartupType Automatic -DisplayName "1C Хранилище (8.3.10.2561)"
