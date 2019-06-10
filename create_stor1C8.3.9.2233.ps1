$Path = 'C:\Program Files (x86)\1cv8\8.3.9.2233\bin\crserver.exe'
$pathFull = $Path + ' -srvc -port 1542 -range 1560:1591 -d D:\storage' 

New-Service -Name 1C_Storage_8.3.9.2233 -BinaryPathName $pathFull -StartupType Automatic -DisplayName "1C Хранилище (8.3.9.2233)"