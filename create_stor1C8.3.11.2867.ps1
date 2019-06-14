$Path = 'C:\Program Files (x86)\1cv8\8.3.11.2867\bin\crserver.exe'
$pathFull = $Path + ' -srvc -port 1742 -range 1760:1791 -d E:\storage'

New-Service -Name 1C_Storage_8.3.11.2867 -BinaryPathName $pathFull -StartupType Automatic -DisplayName "1C Хранилище (8.3.11.2867)"
