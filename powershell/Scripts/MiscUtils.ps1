#*****************************************************************************
#*
#*  MiscUtils.ps1
#*  Miscellaneous utility commandlets.
#*
#*  By Caleb McCombs (7/12/2013)
#*
#***


#*****************************************************************************
#*
#*  Exported Methods
#*
#***


#=============================================================================
function FuzzyMatch-Strings {
    Param (
        [String]$name,
        [String[]]$candidates,
        [String]$promptTitle,
        [String]$promptMessage,
        [Int]$selectionCount    = 3,
        [Int]$distanceTolerance = 0,
        [Switch]$SelectSingle
    )

    Write-Debug ("`t`tFuzzy Matching")

    # Iterate through the products found.
    $candidateObjects = @()
    foreach ($candidate in $candidates) {
        Write-Debug ("`t`tChecking candidate: " + $candidate)

        $ld = Get-LD $name $candidate -IgnoreCase
        Write-Debug "`t`tCalculated Levenshtein Distance: $ld"

        $candidateObj = New-Object System.Object
        $candidateObj | Add-Member -MemberType NoteProperty -Name "Name" -Value $candidate
        $candidateObj | Add-Member -MemberType NoteProperty -Name "Distance" -Value $ld

        Write-Debug ("`t`tCandidateObject.Name: " + $candidateObj.Name)
        Write-Debug ("`t`tCandidateObject.Distance: " + $candidateObj.Distance)

        $candidateObjects += $candidateObj
    }

    # Detect that we have no matches.
    if (!$candidateObjects.Length) {
        return -1
    }

    $candidateObjects = @($candidateObjects | Sort-Object -Property Distance | Select-Object -First $selectionCount)
    if ($DebugPreference -eq "Continue") {
        foreach ($candidateObj in $candidateObjects) {
            Write-Debug ("`t`tSorted Object: " + $candidateObj.Name)
        }
    }

    # If we have one result and we're supposed to just take it, do so.
    if ($SelectSingle -and ($candidateObjects.Length -eq 1)) {
        return $candidateObjects[0].Name
    }

    # Look for an exact match.
    if ($candidateObjects[0].Distance -eq $distanceTolerance) {
        return $candidateObjects[0].Name
    }

    # Prompt for selected matches.
    [System.Management.Automation.Host.ChoiceDescription[]]$choices = @()
    for ($candidateIndex = 0; $candidateIndex -lt $candidateObjects.Length; $candidateIndex++) {
        $candidateObj = $candidateObjects[$candidateIndex]
        [String]$choiceTitle       = ("&" + ($candidateIndex + 1) + " - " + $candidateObj.Name)
        [String]$choiceDescription = ("Select " + $candidateObj.Name + ".")

        $choice  = New-Object System.Management.Automation.Host.ChoiceDescription $choiceTitle, $choiceDescription

        $choices += $choice
    }

    # Add an abort option
    $abortChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", "Abort the operation."
    $choices += $abortChoice

    [Int]$result = $Host.UI.PromptForChoice($promptTitle, $promptMessage, $choices, 0)
    Write-Debug ("`t`tUser selected: " + $candidateObjects[$result].Name)

    # Did the user select Quit?
    if ($result -eq ($choices.Length - 1)) {
        return 0
    }
    
    return $candidateObjects[$result].Name
}

#=============================================================================
# Levenshtein distance algorithm adapted from:
#   http://www.codeproject.com/Tips/102192/Levenshtein-Distance-in-Windows-PowerShell
# Levenshtein Distance is the # of edits it takes to get from 1 string to another
# This is one way of measuring the "similarity" of 2 strings
# Many useful purposes that can help in determining if 2 strings are similar possibly
# with different punctuation or misspellings/typos.
#
########################################################
function Get-LevenshteinDistance {
    Param(
        [String] $First,
        [String] $Second,
        [Switch] $IgnoreCase
    )

    # No NULL check needed, why is that?
    # PowerShell parameter handling converts Nulls into empty strings
    # so we will never get a NULL string but we may get empty strings(length = 0)
    #########################
    $len1 = $First.length
    $len2 = $Second.length

    # If either string has length of zero, the # of edits/distance between them
    # is simply the length of the other string
    #######################################
    if($len1 -eq 0) {
        return $len2
    }

    if($len2 -eq 0) {
        return $len1
    }

    # make everything lowercase if ignoreCase flag is set
    if($IgnoreCase -eq $true) {
        $First = $First.tolowerinvariant()
        $Second = $Second.tolowerinvariant()
    }

    # create 2d Array to store the "distances"
    $dist = new-object -type 'int[,]' -arg ($len1+1),($len2+1)

    # initialize the first row and first column which represent the 2
    # strings we're comparing
    for($i = 0; $i -le $len1; $i++) {
        $dist[$i,0] = $i
    }
    for($j = 0; $j -le $len2; $j++) {
        $dist[0,$j] = $j
    }

    $cost = 0

    for($i = 1; $i -le $len1;$i++) {
        for($j = 1; $j -le $len2;$j++) {
            if($Second[$j-1] -ceq $First[$i-1]) {
                $cost = 0
            }
            else {
                $cost = 1
            }

            # The value going into the cell is the min of 3 possibilities:
            # 1. The cell immediately above plus 1
            # 2. The cell immediately to the left plus 1
            # 3. The cell diagonally above and to the left plus the 'cost'
            ##############
            # I had to add lots of parentheses to "help" the Powershell parser
            # And I separated out the tempmin variable for readability
            $tempmin = [System.Math]::Min(([int]$dist[($i-1),$j]+1) , ([int]$dist[$i,($j-1)]+1))
            $dist[$i,$j] = [System.Math]::Min($tempmin, ([int]$dist[($i-1),($j-1)] + $cost))
        }
    }

    # the actual distance is stored in the bottom right cell
    return $dist[$len1, $len2];
}

#=============================================================================
function Get-NormalizedPath {
    Param (
        [String]$path
    )

    if ($path -like "*:*") {
        return [IO.Path]::GetFullPath($path)
    }
    else {
        return [IO.Path]::GetFullPath((Get-Location).Path + '\' + $path)
    }
}

#=============================================================================
# Calculate the checksum of some files.
# Taken from http://bradwilson.typepad.com/blog/2010/03/calculating-sha1-in-powershell.html
function Get-Sha1 {
    param([switch]$csv, [switch]$recurse)
    
    [Reflection.Assembly]::LoadWithPartialName("System.Security") | out-null
    $sha1 = new-Object System.Security.Cryptography.SHA1Managed
    $pathLength = (get-location).Path.Length + 1
    
    $args | %{
        if ($recurse) {
            $files = @(get-childitem -recurse -filter $_)
        }
        else {
            $files = @(get-childitem -filter $_)
        }
        Write-Debug ("Found " + $files.Length + " files with <$_>: $files")
        
        foreach ($file in $files) {
            $filename = $file.FullName
            $filenameDisplay = $filename.Substring($pathLength)
            Write-Debug "Processing file <$filenameDisplay>."
            
            if ($csv) {
                write-host -NoNewLine ($filenameDisplay + ",")
            } else {
                write-host $filenameDisplay
            }
            
            $fileObj = [System.IO.File]::Open($filename, "open", "read")
            $sha1.ComputeHash($fileObj) | %{
                write-host -NoNewLine $file.ToString("x2")
            }
            $fileObj.Dispose()
            
            write-host
            if ($csv -eq $false) {
                write-host
            }
        }
    }
}

#=============================================================================
## This is a script to give us a "Unixy" touch command within powershell.
## Unixy Touch command (from http://ss64.com/ps/syntax-touch.html)
function Set-FileTime{
  param(
    [string[]]$paths,
    [bool]$only_modification = $false,
    [bool]$only_access = $false
  );

  begin {
    function updateFileSystemInfo([System.IO.FileSystemInfo]$fsInfo) {
      $datetime = get-date
      if ( $only_access )
      {
         $fsInfo.LastAccessTime = $datetime
      }
      elseif ( $only_modification )
      {
         $fsInfo.LastWriteTime = $datetime
      }
      else
      {
         $fsInfo.CreationTime = $datetime
         $fsInfo.LastWriteTime = $datetime
         $fsInfo.LastAccessTime = $datetime
       }
    }
   
    function touchExistingFile($arg) {
      if ($arg -is [System.IO.FileSystemInfo]) {
        updateFileSystemInfo($arg)
      }
      else {
        $resolvedPaths = resolve-path $arg
        foreach ($rpath in $resolvedPaths) {
          if (test-path -type Container $rpath) {
            $fsInfo = new-object System.IO.DirectoryInfo($rpath)
          }
          else {
            $fsInfo = new-object System.IO.FileInfo($rpath)
          }
          updateFileSystemInfo($fsInfo)
        }
      }
    }
   
    function touchNewFile([string]$path) {
      #$null > $path
      Set-Content -Path $path -value $null;
    }
  }
 
  process {
    if ($_) {
      if (test-path $_) {
        touchExistingFile($_)
      }
      else {
        touchNewFile($_)
      }
    }
  }
 
  end {
    if ($paths) {
      foreach ($path in $paths) {
        if (test-path $path) {
          touchExistingFile($path)
        }
        else {
          touchNewFile($path)
        }
      }
    }
  }
}

#=============================================================================
function Write-Utf8File ([String]$fileName, [String]$data) {
    $utf8Encoding = New-Object System.Text.Utf8Encoding($False)
    $fileName = Get-NormalizedPath $fileName
    [System.IO.File]::WriteAllLines($fileName, $data, $utf8Encoding)
}

#*****************************************************************************
#*
#*  Aliases
#*
#***

Set-Alias touch Set-FileTime
Set-Alias Get-LD Get-LevenshteinDistance
