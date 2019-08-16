$path = "G:\"
$target = "C:\asupk_bak\asupk.bak"
$file = Get-ChildItem -Path $path | Sort-Object LastWriteTime | Select-Object -Last 1
$fullpath = $path + $file.Name
Remove-Item $target 
Copy-Item -Path $fullpath -Destination $target 