$Folder1Path = 'H:\actual_backup'
$Folder2Path = 'H:\change_backup'
$folder1Files = Get-ChildItem -Recurse -path $Folder1Path
$folder2Files = Get-ChildItem -Recurse -path $Folder2Path
$file_Diffs = Compare-Object -ReferenceObject $folder1Files -DifferenceObject $folder2Files
$file_Diffs | 
  ForEach-Object {
     $copyParams = @{'Path' = $_.InputObject.FullName}
     if($_.SideIndicator -eq '<=' )
     { 
         $copyParams.Destination = $_.InputObject.FullName -replace [regex]::Escape($Folder1Path),$Folder2Path
     }
     copy-Item @copyParams -force
}