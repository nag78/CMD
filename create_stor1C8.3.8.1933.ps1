﻿$Path = 'C:\Program Files (x86)\1cv8\8.3.8.1933\bin\crserver.exe'
$pathFull = $Path + ' -srvc -port 1642 -range 1660:1691 -d E:\storage'

New-Service -Name 1C_Storage_8.3.8.1933 -BinaryPathName $pathFull -StartupType Automatic -DisplayName "1C Хранилище (8.3.8.1933)"