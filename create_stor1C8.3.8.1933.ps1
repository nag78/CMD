$Path = 'C:\Program Files (x86)\1cv8\8.3.8.1933\bin\crserver.exe'
$pathFull = $Path_1 + ' -srvc -port 1642 -range 1660:1691 -d D:\storage'

New-Service -Name 1C_Storage_8.3.8.1933 -BinaryPathName $pathFull_2 -StartupType Automatic -DisplayName "1C Хранилище (8.3.8.1933)"