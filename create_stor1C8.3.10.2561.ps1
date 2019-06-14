$Path = 'C:\Program Files (x86)\1cv8\8.3.10.2561\bin\crserver.exe'
$pathFull = $Path + ' -srvc -port 1742 -range 1760:1791 -d E:\storage'

New-Service -Name 1C_Storage_8.3.10.2561 -BinaryPathName $pathFull -StartupType Automatic -DisplayName "1C Хранилище (8.3.10.2561)"
