
$path = 'E:\change'
$target = 'E:\CSV'

Remove-Item $target\* -Recurse
#
Copy-Item -Path $path\* -Destination $target -Verbose -Force 



