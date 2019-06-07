REM Создание нескольких служб, разных версий хранилища конфигураций 1С.

sc create "1C_Storage_8.3.9.2233"  binPath= "C:\Program Files (x86)\1cv8\8.3.9.2233\bin\crserver.exe" -srvc -port 1542 -range 1560:1591 -d D:\storage\" start= auto displayname= "Сервер хранилища 1С (БГУ_ЗКБУ_СТИП)"
REM sc create "1C_Storage_8.3.11.2867"  binPath= "C:\Program Files (x86)\1cv8\8.3.11.2867\bin\crserver.exe" -srvc -port 1642 -range 1660:1691 -d D:\storage\" start= auto displayname= "Сервер хранилища 1С (8.3.11.2867)"
sc create "1C_Storage_8.3.8.1933"  binPath= "C:\Program Files (x86)\1cv8\8.3.8.1933\bin\crserver.exe" -srvc -port 1542 -range 1560:1591 -d D:\storage\" start= auto displayname= "Сервер хранилища 1С (АСУПК_ИАСУ)"