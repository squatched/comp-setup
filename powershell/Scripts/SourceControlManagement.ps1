#*****************************************************************************
#*
#*  SourceControlManagement.ps1
#*  Utilities for interactions between perforce and git.
#*
#*  By Caleb McCombs (1/30/2014)
#*
#***


#*****************************************************************************
#*
#* Exported Methods
#*
#***

#=============================================================================
function Invoke-P4Command {
    Param (
        [String]$command
    )

    # Method that iterates through a list of strings, looking for the next string to
    #   start with "... ". Returns the size of the array if none found.
    function FindNextProperty {
        Param (
            [String[]]$data,
            [Int]     $currentIndex
        )

        $currentIndex++

        # Look for the next line beginning with "... "
        while ($currentIndex -lt $data.Length) {
            if ($data[$currentIndex].StartsWith("... ")) {
                break
            }

            $currentIndex++
        }

        # We've run off the end of the data, so bail.
        return $currentIndex
    }

    Write-Debug "Invoking expression: p4 -z tag $command"
    $rawResult = Invoke-Expression ("p4 -z tag " + $command)

    # Iterate over the results, each blank line indicates a new object
    #   and each line indicates a property on that object.
    [Int]            $resultIndex = 0
    [System.Object[]]$objects     = @()
    while ($resultIndex -lt $rawResult.Length) {
        # Skip blank lines
        if ($rawResult[$resultIndex].Length -eq 0) {
            Write-Debug "`tBlank line. Skipping."
            $resultIndex++
            continue
        }

        Write-Debug "`tNew object detected."
        [System.Object]$obj = New-Object System.Object
        do {
            Write-Debug ("`t`tProcessing line ${resultIndex}: " + $rawResult[$resultIndex])

            # Parse the output. It's of the form "... PropertyName PropertyValue"
            $lineResult = $rawResult[$resultIndex].Substring(4)
            $propName   = $lineResult.Split(" ")[0]
            $propValue  = $lineResult.Replace($propName, "").Trim()

            # Some values may be multi-line, so we must look ahead for the next
            #   property entry.
            [Int]$nextPropIndex = FindNextProperty $rawResult $resultIndex
            for ([Int]$valIndex = $resultIndex + 1; $valIndex -lt $nextPropIndex; $valIndex++) {
                # Skip blank lines just ahead of new objects.
                if (($valIndex -eq ($nextPropIndex - 1)) -and ($rawResult[$valIndex].Length -eq 0)) {
                    break
                }

                Write-Debug ("`t`t`tAppending line to value: " + $rawResult[$valIndex])
                $propValue += "`n" + $rawResult[$valIndex]
                $resultIndex++
            }
            $propValue = $propValue.Trim()

            # If we have a property with no value, set the value to $True so we can tell
            #   that the property exists easily.
            if (!$propValue) {
                $propValue = $True
            }


            Write-Debug "`t`tObject Property `"$propName`" Value: $propValue"
            $obj | Add-Member -MemberType NoteProperty -Name $propName -Value $propValue

            $resultIndex++
        } while ($rawResult[$resultIndex].Length -ne 0)
        $objects += $obj
    }

    return $objects
}

#=============================================================================
## Sync perforce and submit to git. Note that this relies on the fact that I don't work in my master
##   tree, it should always be a clean sync to perforce.
function Sync-GitToPerforce ([Switch]$PopStash) {
    # Ensure git is in the proper state.
    Push-Location (Get-GitRepositoryRoot)
    
    [Boolean]$IsInGit = Test-Path ".\.git"

    if ($IsInGit) {
        [String]$originalGitBranch = Get-GitBranch
        $gitStashResult = ""
        Write-Debug "Original Git Branch: [$originalGitBranch]"
        if ($originalGitBranch -ne "master") {
                Write-Debug "Stashing git..."
                $gitStashResult = git stash
                Write-Debug "Git Stash Result: $gitStashResult"
                Write-Debug "Checking out master git branch."
                git checkout master
        }

        Write-Debug "Checking to ensure that we're in master..."
        $newGitBranch = Get-GitBranch
        if ($newGitBranch -ne "master") {
                Write-Error "Unable to switch to master git branch. Deal with your working tree and try again."
                Pop-Location
                return
        }
    }
    
    # Sync Perforce
    Write-Debug "Syncing Perforce..."
    p4 sync .\...
    
    # Resolve (safe merge, conflicts skipped)
    p4 resolve -am
    
    if ($IsInGit) {
        # Extract the latest changelist number as a string.
        Write-Debug "Checking for latest Perforce change..."
        [String]$lastCLNumber = $(Invoke-P4Command "changes -m 1 -s submitted").change
        Write-Debug "Latest Perforce Change Result: $lastCLNumber"

        # Submit the freshly synced depot to git if necessary.
        Write-Debug "Checking git status..."
        $gitShortStatus = git status -s
        Write-Debug "Git Status: $gitShortStatus"
        if ($gitShortStatus) {
            Write-Debug "Adding changes to git..."
            git add . -A
            Write-Debug "Commiting git index with message `"P4 - $lastCLNumber`""
            [String]$p4Client = $(Invoke-P4Command "client -o").client
            git commit -m "P4:$p4Client - $lastCLNumber"
        }

        # Pop our working directory and git branch.
        if ($originalGitBranch -ne "master") {
            Write-Debug "Checking out git branch [$originalGitBranch]..."
            git checkout $originalGitBranch

            if ($gitStashResult -ne "No local changes to save") {
                if (!$PopStash) {
                    Write-Warning "Data is still in git stash. You are responsible for popping."                
                }
                else {
                    Write-Debug "Popping our stashed changes..."
                    git stash pop
                }
            }
        }
    }
    Pop-Location
}

#=============================================================================
function Sync-PerforceChangelistWithGitBranch ([String]$sourceBranch = "master") {
    if ((Get-GitBranch) -eq $sourceBranch) {
        Write-Error -Message "Source branch ($sourceBranch) may not be the current branch." -Category InvalidOperation -RecommendedAction "Switch to a different git branch."
        return
    }

    # Ensure we're browsing in the proper location.
    Push-Location (Get-GitRepositoryRoot)

    # Get the current branch's difference to source in a summarized output.
    $diffNameStatus = git diff --name-status $sourceBranch
    if (!$diffNameStatus) {
        Write-Output "No changes in this git branch to sync."
        return
    }

    Write-Output "Git status we're syncing perforce to:"
    git diff --stat $sourceBranch | ? {$_}

    # Determine the proper changelist description.
    $currentGitBranch = Get-GitBranch
    $clDescription = "Auto generated changelist from git branch `"$currentGitBranch`""
    $clNum = $NULL
    Write-Debug "`tGenerated changelist description: $clDescription"

    # List pending changelists.
    $pendingChangelists = Invoke-P4Command ("changes -u " + $Env:P4USER + " -c " + $Env:P4CLIENT + " -s pending -List" )
    $p4PendingFilesInCl = $NULL

    if ($pendingChangelists) {
        Write-Output "Pending changelists found, searching for a suitable changelist..."

        # If the changlist description matches our generated one, then we have a suitable changelist.
        foreach ($pendingCl in $pendingChangeLists) {
            Write-Debug ("`tChangelist Desc: " + $pendingCl.desc)
            if ($pendingCl.desc -eq $clDescription) {
                $clNum = $pendingCl.change
                Write-Output ("`tSuitable changelist found. Will use changelist #$clNum (" + $pendingCl.desc + ").")
            }
        }

        if (!$clNum) {
            Write-Output "No suitable changelist found, continuing."
        }
        else {
            # Changelist found, let's grab a list of all the files in it and filter our
            #  list of files down to ones not already in it.
            $p4OpenedInCl       = Invoke-P4Command "opened -c $clNum"
            $p4PendingFilesInCL = @()
            foreach ($p4OpenedFile in $p4OpenedInCl) {
                # First, determine the file's depot mapping.
                $localMapping = @(Invoke-P4Command ("where " + $p4OpenedFile.depotFile))
                if ($localMapping.Length -gt 1) {
                    # If more than one mapping, the first one is an "unmap" so ignore it.
                    Write-Debug ("`tDropping unmap: " + $localMapping[0])
                    $localMapping = $localMapping[1]
                }
                else {
                    $localMapping = $localMapping[0]
                }

                # Normalize any path that is going to be compared against a git produced path.
                $p4PendingFilesInCl += Get-NormalizedPath($localMapping.path)
            }
            Write-Debug "`tChangelist Files:"
            $p4PendingFilesInCl | % { Write-Debug "`t`t<$_>" }
        }
    }

    if (!$clNum) {

        Write-Output "Creating a new changelist."

        # Create a new changelist
        $changeDescription = p4 change -o

        # Edit the proper line to include a description of the current branch's name.
        $changeDescription[24] = (" " + $clDescription)

        # Remove all files from the changelist.
        $changeDescription = $changeDescription[0..26]

        # Create the changelist
        $changeSubmission = $changeDescription | p4 change -i

        # Check for error.
        if (!$changeSubmission) {
            Write-Error "Creation of changelist failed with message $changeSubmission"
            Pop-Location
            return
        }

        # Extract the changelist number.
        $clNum = $changeSubmission.Split(' ')[1]

        Write-Output "Created changelist #$clNum."
        Write-Output "Description: `"$clDescription`""
    }

    [String[]]$LocationExceptions = @((Get-CurrentBranchRoot) + "Art/")
    [String[]]$Replacements       = @("R:/")

    foreach ($Index in 0..($LocationExceptions.Length - 1)) {
        $LocationExceptions[$Index] = Get-NormalizedPath $LocationExceptions[$Index]
        $Replacements[$Index]       = Get-NormalizedPath $Replacements[$Index]
    }

    # Check out each file into the given changelist.
    foreach ($diffStatus in $diffNameStatus) {

        if (!$diffStatus) {
            continue
        }

        Write-Debug "`tHandling status `"$diffStatus`"."

        $gitStatus        = $diffStatus[0]
        $originalFileName = Get-NormalizedPath $diffStatus.Substring(1).Trim()
        $fileName         = $originalFileName

        # Carve out specific exceptions
        foreach ($Index in 0..$LocationExceptions.Length) {
            $fileName = $fileName.Replace($LocationExceptions[$Index], $Replacements[$Index])
        }
        Write-Debug "`tAltering file name: `"$originalFileName`" -> `"$fileName`""
        $p4Opened         = Invoke-P4Command "opened $fileName"
        $p4Action         = $p4Opened.action
        Write-Debug "`tHandling File `"$fileName`" with git status '$gitStatus'"
        Write-Debug "`t`tP4 status string: `"$p4Action`""

        Write-Debug "`tChecking if our list of pending files includes <$originalFileName>"
        if ($p4PendingFilesInCl -contains $originalFileName) {
            Write-Output "Skipping file <$fileName>, already in proper perforce changelist."
            continue
        }

        Write-Output "Handling file <$fileName>..."
        Write-Output "`tGit Status: $gitStatus"
        Write-Output "`tPerforce Status: $p4Action"

        function MoveFileToCl {
            Param (
                [String]$file,
                [String]$clNum
            )

            Write-Output "`tFile tracked in perforce. Moving to cl."
            $p4Res = p4 reopen -c $clNum $fileName

            Write-Debug "P4 result: $p4Res"
        }

        function AddNewFileToCl {
            Param (
                [String]$file,
                [String]$clNum
            )

            Write-Output "`tAdding file to perforce."
            $p4Res = p4 add -c $clNum $fileName

            Write-Debug "P4 result: $p4Res"
        }

        function OpenFileForDelete {
            Param (
                [String]$file,
                [String]$clNum
            )

            Write-Output "`tOpening file for delete."
            $p4Res = p4 delete -c $clNum $fileName

            Write-Debug "P4 result: $p4Res"
        }

        function OpenFileForEdit {
            Param (
                [String]$file,
                [String]$clNum
            )

            Write-Output "`tOpening file for edit."
            $p4Res = p4 edit -c $clNum $fileName

            Write-Debug "P4 result: $p4Res"
        }

        if ($p4Action) {
            MoveFileToCl $fileName $clNum
        }
        else {
            switch ($gitStatus) {
                'A' {
                    # Add if perforce isn't tracking this file.
                    AddNewFileToCl $fileName $clNum
                }

                'D' {
                    # File has been deleted. Open for delete.
                    OpenFileForDelete $fileName $clNum
                }

                'M' {
                    # File has been modified, open for edit.
                    OpenFileForEdit $fileName $clNum
                }

                default {
                    Write-Error "File $filename marked as '$gitStatus.' Not sure what to do, skipping."
                }
            }
        }
    }

    # Put us back to our original location.
    Pop-Location
}


#*****************************************************************************
#*
#* Aliases
#*
#*
#***

Set-Alias Sync-P4ToGit Sync-PerforceChangelistWithGitBranch
Set-Alias Sync-GitToP4 Sync-GitToPerforce
