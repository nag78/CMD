﻿<#
.SYNOPSIS
  Synchronises folders (and their contents) to target folders.  Uses a configuration XML file (default) or a pair of
  folders passed as parameters.
.DESCRIPTION
  Reads in the Configuration xml file (passed as a parameter or defaults to 
  Sync-FolderConfiguration.xml in the script folder.
.PARAMETER ConfigurationFile
    Holds the configuration the script uses to run.
.PARAMETER SourceFolder
    Which folder to synchronise.
.PARAMETER TargetFolder
    Where to sync the source folder to.
.PARAMETER Exceptions
    An array of path names to skip from synchronisation.  Accepts wild-cards (*.jpg, c:\temp\*.jpg etc).
.PARAMETER Filter
    An array of path names to only process via synchronisation.  Accepts wild-cards (*.jpg, c:\temp\*.jpg etc).
.PARAMETER LogFile
    A logfile to write to.  Defaults to LogFile.txt in the script's folder.
.PARAMETER LoggingLevel
    0=Only Errors and Warnings, 1=Changes made, 2=All Items
.PARAMETER LogToScreen
    If specified show the desired logs on the screen
.NOTES       
    1.0
        HerringsFishBait.com
        17/11/2015
    1.1
        Fixed path check to use LiteralPath
        Added returning status object throughout
    1.2 4/Aug/2016
        Added LiteralPath to the Get-ChildItem commands   
        Added totals to report on what was done 
    1.3 6/10/2016
        Added StrictMode
        Set $Changes to an empty collection on script run to reset statistics  
        Rewrote Statistics
        Added $Filter option 
    1.4 4/11/2016
        Added Get-PropertyExists function to make sure parts of the config XML are not missing.  
    1.5 13/01/2017
        Fixed Type in Tee-Object that was preventing statistics showing correctly    
    1.6 20/01/2017
        Fixed Filters not working if not specified in config file
        Fixed Exceptions not working in some cases in Exception file     
        Added Write-Verbose on all the passed parameters to Sync-OneFolder   
        Added first pass at WhatIf
    1.7  03/03/2017
        Added Write-Log function to write output to file
    1.8
        Fixed bug in copying matched files 
            "$MatchingSourceFile= $SourceFiles | Where-Object {$_.Name -eq $TargetFile.Name}"
        Made most logs not write to the file (for performance)
        Fixed a bug where not all the statistics were recorded when a configuration XML was used.
    1.9 09/05/2017
        Corrected bug where an error was generated if there were no Changes
        Added -PassThru switch to return objects
    1.10 22/10/2017
        Added "-Attributes !ReparsePoint" to Get-ChildItem lines to avoid traversing Symbolic Links
        (as per Scotts suggestion in the comments!)
        Added LiteralPath lines to the Test-Path commands to stop errors where the path has odd characters
        in it (as per Roberts suggestion in the comments)
        Added the ability to have multiple targets in the XML file or passing an array to $TargetFolders which
        allows the sync to happen to multiple targets
    1.11 17/04/2018
        Changed defaults so that only changes or errors are written to the screen or logs
    1.12 06/01/2020
        Changed verbs to recommended ones and removed comparisons that flag warnings (although they run correctly)
        Added a timestamp to the text log and has the script generate a new log each time it's run
        Made MissingFiles and MissingFolders start as an array no matter the result;  this will stop a single entry making them hold a single object and
        not a collection (making For-Each results odd)
        Cleaned up logging
        Added "LoggingLevel" parameter to control how much goes to the logs;  0= errors only, 1=errors and changes and 2 is everything
        Added LogToScreen 
        Added additional error-handling when the source and target folders were returned
.EXAMPLE
  Sync-Folder -configurationfile:"d:\temp\Config.xml"
.EXAMPLE
  Sync-Folder -SourceFolder:c:\temp -TargetFolder:d:\temp -Exceptions:"*.jpg"
#>
[CmdletBinding(DefaultParameterSetName="XMLFile")]
param
(
    [parameter(
        ParameterSetName="XMLFile")]
    [ValidateScript({Test-Path -LiteralPath $_ -PathType leaf})]
    [string]$ConfigurationFile=$PSScriptRoot+"\Sync-FolderConfiguration.xml",
    [parameter(
        Mandatory=$True,
        ValueFromPipelineByPropertyName=$True,
        ParameterSetName="FolderPair")]
    [string]$SourceFolder,
    [parameter(
        Mandatory=$True,
        ValueFromPipelineByPropertyName=$True,
        ParameterSetName="FolderPair")]
    [string[]]$TargetFolders,
    [parameter(
        ParameterSetName="FolderPair")]
    [string[]]$Exceptions=$Null,
    [parameter(
        ParameterSetName="FolderPair")]
    [string]$Filter="*",
    [ValidateScript({Test-Path -LiteralPath $_ -PathType leaf -IsValid})]
    [string]$LogFile=$PSScriptRoot+"\SyncFolderLog.txt",
    [int]$LoggingLevel=1,
    [switch]$LogToScreen=$false,
    [switch]$PassThru=$False,
    [switch]$Whatif=$False

)
set-strictmode -version Latest


<#
.SYNOPSIS
This writes verbose or error output while also logging to a text file.
.DESCRIPTION
This writes verbose or error output while also logging to a text file.
.PARAMETER Output
The string to write to the log file and Error / Verbose streams.
.PARAMETER IsError
If this switch is specified the $Output string is written to the Error stream instead 
of Verbose.
.PARAMETER Heading
Makes the passed string a heading (gives it a border)
.PARAMETER Emphasis
Puts an emphasis character on either side of the string to output.
.PARAMETER WriteHost
Writes the output to the host instead of the verbose stream
.PARAMETER NoFileWrite
Does not write this output to the files
#> 
function Write-Log
{
    [CmdletBinding()]
    param
    (
        [Parameter(
            ValueFromPipeline=$true)]
        [String]$Output="",
        [switch]$IsError=$False,  
        [switch]$IsWarning=$False,
        [switch]$Heading=$False,
        [switch]$Emphasis=$False,
        [switch]$WriteHost=$False,
        [switch]$NoFileWrite=$False,
        [switch]$IsInfo=$False
    )
    BEGIN
    {
        $TitleChar="*"
    }
    PROCESS
    {     
        if(($IsInfo -and $LoggingLevel -gt 0) -or $IsError -or $IsWarning)
        {       
            $FormattedOutput=@()
            if ($Heading)
            {
                $TitleBar=""
                #Builds a line for use in a banner
                for ($i=0;$i -lt ($Output.Length)+2; $i++)
                {
                    $TitleBar+=$TitleChar
                }
                $FormattedOutput=@($TitleBar,"$TitleChar$Output$TitleChar",$TitleBar,"")
            }elseif ($Emphasis)
            {
                $FormattedOutput+="","$TitleChar$Output$TitleChar",""
            }else
            {
                $FormattedOutput+=$Output
            }
            if ($IsError)
            {
                $PreviousFunction=(Get-PSCallStack)[1]
                $FormattedOutput+="Calling Function: $($PreviousFunction.Command) at line $($PreviousFunction.ScriptLineNumber)"
                $FormattedOutput=@($FormattedOutput | ForEach-Object {(Get-Date -Format HH:mm:ss.fff)+" : ERROR " + $_})
                $FormattedOutput | Write-Error
            }elseif ($IsWarning)
            {
                $FormattedOutput=@($FormattedOutput | ForEach-Object {(Get-Date -Format HH:mm:ss.fff)+" : WARNING " + $_})
                $FormattedOutput | Write-Warning            
            }else
            {
                $FormattedOutput=$FormattedOutput | ForEach-Object {(Get-Date -Format HH:mm:ss.fff)+" : " + $_}
                if ($WriteHost)
                {
                    $FormattedOutput | Write-Host
                }else
                {

                    $FormattedOutput | Write-Verbose
                }
            }
        
            if (!$NoFileWrite)
            {
                if (($Null -ne $Script:LogFileName) -and ($Script:LogFileName -ne ""))
                {
                    $FormattedOutput | Out-File -Append $Script:LogFileName
                }  

            }
        }
    }
    END
    {
    }
}


<#
.SYNOPSIS
  Checks a file doesn't match any of a passed array of exceptions.
.PARAMETER TestPath
    The full path to the file to compare to the exceptions list.
.PARAMETER PassedExceptions
    An array of all the exceptions passed to be checked.
#>
function Test-Exceptions
{
    param
    (
        [parameter(Mandatory=$True)]
        [ValidateScript({Test-Path -LiteralPath $_ -IsValid })]
        [string]$TestPath,
        [string[]]$PassedExceptions
    )
    $Result=$False
    $MatchingException=""
    if ($Null -eq $PassedExceptions)
    {
        Return $False
    }
    Write-Log "Checking $TestPath against exceptions" -IsInfo:($LoggingLevel -gt 1)
    foreach ($EnumeratedException in $PassedExceptions)
    {
        if($TestPath -like $EnumeratedException)
        {
            $Result=$True
            $MatchingException=$_          
        }
    }
    If ($Result)
    {
        Write-Log "Matched Exception : $MatchingException, skipping." -IsInfo -WriteHost:$LogToScreen
    }
    $Result
}

<#
.SYNOPSIS
  Creates an object to be used to report on the success of an action
#>
function New-ReportObject
{
    New-Object -typename PSObject| Add-Member NoteProperty "Successful" $False -PassThru |
    Add-Member NoteProperty "Process" "" -PassThru |
    Add-Member NoteProperty "Message" "" -PassThru    
}

<#
.SYNOPSIS
    Returns if a property of an object exists.
.PARAMETER Queryobject
    The object to check the property on.
.PARAMETER PropertyName
    The name of the property to check the existance of.
#>
function Get-PropertyExists
{
    param
    (
        [PSObject]$Queryobject,
        [string]$PropertyName
    )
    Return (($Queryobject | Get-Member -MemberType Property | Select-Object -ExpandProperty Name) -contains $PropertyName)
}
<#
.SYNOPSIS
  Synchronises the contents of one folder to another.  It recursively calls itself
  to do the same for sub-folders.  Each file and folder is checked to make sure
  it doesn't match any of the entries in the passed exception list.  if it does, 
  the item is skipped.
.PARAMETER SourceFolder
    The full path to the folder to be synchronised.
.PARAMETER SourceFolder
    The full path to the target folder that the source should be synched to.
.PARAMETER PassedExceptions
    An array of all the exceptions passed to be checked.
.PARAMETER Filter
    Only files matching this parameter will be synced.
#>
function Sync-OneFolder
{
    param
    (
        [parameter(Mandatory=$True)]
        [ValidateScript({Test-Path -LiteralPath $_ -PathType Container})]
        [string]$SourceFolder,
        [parameter(Mandatory=$True)]
        [ValidateScript({Test-Path -LiteralPath $_ -IsValid })]
        [string[]]$TargetFolders,
        [string[]]$PassedExceptions,
        [string]$Filter="*",
        [switch]$WhatIf=$False
 
    )
    Write-Log "Source Folder : $SourceFolder" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
    Write-Log "Target Folder : $TargetFolders" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
    Write-Log "Filter : $Filter" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
    if ($null -ne $PassedExceptions)
    {
        Write-Log "Exceptions:" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen 
        $PassedExceptions | ForEach-Object{Write-Log $_ -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen}
    }
    Foreach ($TargetFolder in $TargetFolders)
    {
        Write-Log "Checking For Folders to Create" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
        if (!(Test-Path -LiteralPath $TargetFolder -PathType Container))
        {
            $Output=New-ReportObject
            Write-Log "Creating Folder : $($TargetFolder)" -IsInfo -WriteHost:$LogToScreen
            $Output.Process="Create Folder"
            try
            {
                $Output.Message="Adding folder missing from Target : $TargetFolder"
                Write-Log $Output.Message -IsInfo -WriteHost:$LogToScreen
                New-Item $TargetFolder -ItemType "Directory" -WhatIf:$WhatIf > $null
                $Output.Successful=$True
            }
            catch
            {
                $Output.Message="Error adding folder $TargetFolder)"
                Write-Log $Output.Message -IsError -WriteHost:$LogToScreen
                Write-Log $_ -IsError
            }
            $Output
        }
        Write-Log "Getting File Lists" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
        $FilteredSourceFiles=$FilteredTargetFiles=$TargetList=@()
        $FilteredSourceFolders=$FilteredTargetFolders=@()
        try
        {
            $SourceList=Get-ChildItem -LiteralPath $SourceFolder -Attributes !ReparsePoint
        }
        catch
        {
            Write-Log "Error accessing $SourceFolder" -IsError
            Write-Log $_ -IsError
            $SourceList=@()
        }
        try
        {
            $TargetList=Get-ChildItem -LiteralPath $TargetFolder -Attributes !ReparsePoint
        }
        catch
        {
            Write-Log "Error accessing $TargetFolder" -IsError
            Write-Log $_ -IsError
            $SourceList=@()
        }
        $FilteredSourceFiles+=$SourceList | Where-Object {$_.PSIsContainer -eq $False -and $_.FullName -like $Filter -and
            !(Test-Exceptions $_.FullName $PassedExceptions)}
        $FilteredTargetFiles+=$TargetList | Where-Object {$_.PSIsContainer -eq $False -and $_.FullName -like $Filter -and
            !(Test-Exceptions $_.FullName $PassedExceptions)}
        $FilteredSourceFolders+=$SourceList | Where-Object {$_.PSIsContainer -eq $True -and !(Test-Exceptions $_.FullName $PassedExceptions)}
        $FilteredTargetFolders+=$TargetList | Where-Object {$_.PSIsContainer -eq $True -and !(Test-Exceptions $_.FullName $PassedExceptions)}
        $MissingFiles=@(Compare-Object $FilteredSourceFiles $FilteredTargetFiles -Property Name)
        $MissingFolders=@(Compare-Object $FilteredSourceFolders $FilteredTargetFolders -Property Name)
        Write-Log "Comparing Missing File Lists" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
        foreach ($MissingFile in $MissingFiles)
        {
            $Output=New-ReportObject
            if($MissingFile.SideIndicator -eq "<=")
            {
                $Output.Process="Copy File"
                try
                {          
                    $Output.Message="Copying missing file : $($TargetFolder+"\"+$MissingFile.Name)" 
                    Write-Log $Output.Message -IsInfo -WriteHost:$LogToScreen
                    Copy-Item -LiteralPath ($SourceFolder+"\"+$MissingFile.Name) -Destination ($TargetFolder+"\"+$MissingFile.Name) -WhatIf:$WhatIf
                    $Output.Successful=$True
                }
                catch
                {
                    $Output.Message="Error copying missing file $($TargetFolder+"\"+$MissingFile.Name)"
                    Write-Log $Output.Message -IsError -WriteHost:$LogToScreen
                    Write-Log $_ -IsError -WriteHost:$LogToScreen
                }
            }elseif ($MissingFile.SideIndicator="=>")
            {
                $Output.Process="Remove File"
                try
                {
                    $Output.Message="Removing file missing from Source : $($TargetFolder+"\"+$MissingFile.Name)"
                    Write-Log $Output.Message -IsInfo -WriteHost:$LogToScreen
                    Remove-Item -LiteralPath ($TargetFolder+"\"+$MissingFile.Name) -WhatIf:$WhatIf
                    $Output.Successful=$True
                }
                catch
                {
                    $Output.Message="Error removing file $($TargetFolder+"\"+$MissingFile.Name)"
                    Write-Log $Output.Message -IsError -WriteHost:$LogToScreen
                    Write-Log $_ -IsError -WriteHost:$LogToScreen
                }           
            }
            $Output
         
        }
        Write-Log "Comparing Missing Folder Lists" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
        foreach ($MissingFolder in $MissingFolders)
        {        
            if ($MissingFolder.SideIndicator -eq "=>")
            {
                $Output=New-ReportObject
                $Output.Process="Remove Folder"
                try
                {
                    $Output.Message="Removing folder missing from Source : $($TargetFolder+"\"+$MissingFolder.Name)"
                    Write-Log $Output.Message -IsInfo -WriteHost:$LogToScreen
                    Remove-Item -LiteralPath ($TargetFolder+"\"+$MissingFolder.Name) -Recurse -WhatIf:$WhatIf
                    $Output.Successful=$True
                }
                catch
                {
                    $Output.Message="Error removing folder $($TargetFolder+"\"+$MissingFolder.Name)"
                    Write-Log $Output.Message -IsError -WriteHost:$LogToScreen
                    Write-Log $_ -IsError -WriteHost:$LogToScreen
                }
                $Output
            }   
        }
        Write-Log "Copying Changed Files : $($FilteredTargetFiles.Count) to check" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
        ForEach ($TargetFile in $FilteredTargetFiles)
        {
            Write-Log "Getting Matching Files for $($TargetFile.Name)" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
            $MatchingSourceFile= $FilteredSourceFiles | Where-Object {$_.Name -eq $TargetFile.Name}
            If ($null -ne $MatchingSourceFile)
            {
                If ($MatchingSourceFile.LastWriteTime -gt $TargetFile.LastWriteTime)
                {
                    $Output=New-ReportObject
                    $Output.Process="Update File"
                    try
                    {
                        $Output.Message="Copying updated file : $($TargetFolder+"\"+$MatchingSourceFile.Name)" 
                        Write-Log $Output.Message -IsInfo -WriteHost:$LogToScreen
                        Copy-Item -LiteralPath ($SourceFolder+"\"+$MatchingSourceFile.Name) -Destination ($TargetFolder+"\"+$MatchingSourceFile.Name) -Force -WhatIf:$WhatIf
                        $Output.Successful=$True
                    }
                    catch
                    {
                        $Output.Message="Error copying updated file $($TargetFolder+"\"+$MatchingSourceFile.Name)"
                        Write-Log $Output.Message -IsError -WriteHost:$LogToScreen
                        Write-Log $_ -IsError -WriteHost:$LogToScreen
                    }
                    $Output
                }

            }      
        }
        Write-Log "Comparing Sub-Folders" -IsInfo:($LoggingLevel -gt 1) -WriteHost:$LogToScreen
        foreach($SingleFolder in $FilteredSourceFolders)
        {
            Sync-OneFolder -SourceFolder $SingleFolder.FullName -TargetFolder ($TargetFolder+"\"+$SingleFolder.Name) -PassedExceptions $PassedExceptions -Filter $Filter -WhatIf:$WhatIf #
        }
    }
}

<#Main Program Loop#>

#$Script:WriteInfo=-not $LogWarningsAndErrorsOnly
#Add a timestamp to the logfile
#Split off the suffix first
[string[]]$FileNameSplit=$LogFile.Split(".")
$Suffix=".txt"
if($FileNameSplit.Count -gt 1)
{
    $Suffix="."+$FileNameSplit[$FileNameSplit.Count-1]
}
$Script:LogFileName=$LogFile.Split(".")[0] + "-"+[string](Get-Date -Format "yyyy-MM-dd-HH-mm")
$LogFileNameCount=0
#Check the logfilename is unique, if not add a number from 1 to 9 to it
While($LogFileNameCount -lt 8 -and (Test-Path -LiteralPath ($Script:LogFileName+$Suffix) -PathType Leaf))
{
    $LogFileNameCount+=1;
    $Script:LogFileName=$LogFile.Split(".")[0] + "-"+[string](Get-Date -Format "yyyy-MM-dd-HH-mm")+"-"+[string]$LogFileNameCount
}
$Script:LogFileName+=$Suffix
#If the LogFileName is STILL not unique throw and error
if(Test-Path -LiteralPath $Script:LogFileName -PathType Leaf)
{
    Write-Log -IsError "Unable to create a unique LogFileName" 
}else
{
    Write-Log ("LogFile: " + $Script:LogFileName) -NoFileWrite -WriteHost -IsInfo
}


$ResultObjects=$Changes=$CurrentExceptions=@()
$CurrentFilter="*"
Write-Log "Running Sync-Folder Script" -NoFileWrite -IsInfo
If ($WhatIf)
{
    Write-Host "WhatIf Switch specified;  no changes will be made."
}
if ($PSBoundParameters.ContainsKey("SourceFolder"))
{
    Write-Log "Syncing folder pair passed as parameters." -IsInfo -WriteHost:$LogToScreen
    foreach ($TargetFolder in $TargetFolders)
    {
        $ResultObjects=Sync-OneFolder -SourceFolder $SourceFolder -TargetFolder $TargetFolder -PassedExceptions $Exceptions -Filter $Filter -WhatIf:$WhatIf | 
    Tee-Object -Variable Changes
    }
}else
{
    Write-Log "Running with Configuration File : $ConfigurationFile" -IsInfo
    $Config=[xml](Get-Content $ConfigurationFile)
    $FolderChanges=$Null
    foreach ($Pair in $Config.Configuration.SyncPair)
    {
        Write-Log "Processing Pair $($Pair.Source) $($Pair.Target)" -IsInfo -WriteHost:$LogToScreen
        $CurrentExceptions=$Null
        If(Get-PropertyExists -Queryobject $Pair -PropertyName ExceptionList)
        {
            $CurrentExceptions=@($Pair.ExceptionList.Exception)
        }
        If(Get-PropertyExists -Queryobject $Pair -PropertyName Filter)
        {
            if (($null -ne $Pair.Filter) -and ($Pair.Filter -ne ""))
            {
                $CurrentFilter=$Pair.Filter
            }
        }   
        foreach($Target in $Pair.Target)
        {
                $ResultObjects=Sync-OneFolder -SourceFolder $Pair.Source -TargetFolder $Target -PassedExceptions $CurrentExceptions -Filter $CurrentFilter -WhatIf:$WhatIf |
        Tee-Object -Variable FolderChanges  
        }

        if($FolderChanges -ne $Null)    
        {
            $Changes+=$FolderChanges
        }    
    }
    
}
$FolderCreations=$FileCopies=$FileRemovals=$FolderRemovals=$FileUpdates=0
Foreach ($Change in $Changes)
{
    switch ($Change.Process)
    {
        "Create Folder"
        {
            $FolderCreations+=1
        }
        "Copy File"
        {
            $FileCopies+=1
        }
        "Remove File"
        {
            $FileRemovals+=1
        }
        "Remove Folder"
        {
            $FolderRemovals+=1
        }
        "Update File"
        {
            $FileUpdates+=1
        }
    }
}
Write-Log "" -WriteHost -IsInfo
Write-Log "Statistics" -WriteHost -IsInfo
Write-Log "" -WriteHost -IsInfo
Write-Log "Folder Creations: `t$FolderCreations" -WriteHost -IsInfo
Write-Log "Folder Removals: `t$FolderRemovals" -WriteHost -IsInfo
Write-Log "File Copies: `t`t$FileCopies" -WriteHost -IsInfo
Write-Log "File Removals: `t`t$FileRemovals" -WriteHost -IsInfo
Write-Log "File Updates: `t`t$FileUpdates`n" -WriteHost -IsInfo
If ($PassThru)
{
    $ResultObjects
}