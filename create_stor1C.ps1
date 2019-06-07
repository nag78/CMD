$Path_1 = 'C:\Program Files (x86)\1cv8\8.3.9.2233\bin\crserver.exe'
$pathFull_1 = $Path_1 + ' -srvc -port 1542 -range 1560:1591 -d D:\storage' 

$Path_2 = 'C:\Program Files (x86)\1cv8\8.3.8.1933\bin\crserver.exe'
$pathFull_2 = $Path_1 + ' -srvc -port 1642 -range 1660:1691 -d D:\storage'

$Path_3 = 'C:\Program Files (x86)\1cv8\8.3.11.2867\bin\crserver.exe'
$pathFull_3 = $Path_1 + ' -srvc -port 1742 -range 1760:1791 -d D:\storage'





New-Service -Name 1C_Storage_8.3.9.2233 -BinaryPathName $pathFull_1 -StartupType Automatic -DisplayName "1C Хранилище (8.3.9.2233)"

New-Service -Name 1C_Storage_8.3.8.1933 -BinaryPathName $pathFull_2 -StartupType Automatic -DisplayName "1C Хранилище (8.3.8.1933)"

New-Service -Name 1C_Storage_8.3.11.2867 -BinaryPathName $pathFull_3 -StartupType Automatic -DisplayName "1C Хранилище (8.3.11.2867)"