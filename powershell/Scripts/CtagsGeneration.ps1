#*****************************************************************************
#*
#*  CtagsGeneration.ps1
#*  Handles TAGS generation for large projects.
#*
#*  By Caleb McCombs (1/2/2013)
#*
#***

#*****************************************************************************
#*
#* Local Constants
#*
#***

## CTags (Also ECTags) Options
$CTAGS_APPEND     = "--append=yes"
$CTAGS_GEN_EMACS  = "-e"
$CTAGS_NO_STATICS = "--file-scope=no"
$CTAGS_RECURSE    = "--recurse=yes"

## The node handler script
$SCRIPT_FOLDER    = Split-Path $MyInvocation.MyCommand.Definition
$SCRIPT_NODE_PROC = $SCRIPT_FOLDER + "\CtagsNodeHandler.ps1"

## Node Filter List
$NODE_FILTER_LIST = @(".git", "tags")


#*****************************************************************************
#*
#* Exported Functions
#*
#***

#=============================================================================
# Generate all tags in this folder and all subdirectories.
function Generate-Tags {
    Param (
        [String[]]$Leaves = @()
    )

    #*************************************************************************
    #*
    #* Local Functions
    #*
    #***

    #=========================================================================
    function GenerateJobObject {
        Param (
            [String]$Path,
            [String[]]$FilterList
        )

        [System.Object]$Object = New-Object System.Object

        $Object | Add-Member -MemberType NoteProperty -Name Path   -Value $Path
        $Object | Add-Member -MemberType NoteProperty -Name Filter -Value $FilterList

        return $Object
    }

    # Populate our leaves list if necessary.
    if ($Leaves.Length -eq 0) {
        Write-Host "No leaves specified. Using all descendant directories."
        $Leaves = Get-ChildItem | Where-Object {
            if (!$_.PSIsContainer) {
                return $False
            }
            foreach ($NodeName in $NODE_FILTER_LIST) {
                if ($_.FullName.Contains($NodeName)) {
                    return $False
                }
            }
            return $True
        } | ForEach-Object {
            Write-Debug ("`tAdding <" + $_.Name + ">.")
            $_.Name
        }
    }

    [System.Management.Automation.PSRemotingJob[]]$Jobs = @()
    foreach ($Leaf in $Leaves) {
        if (!(Test-Path $Leaf)) {
            Write-Debug ("Specified project root <" + $Leaf + "> is a bad path. Skipping.")
            continue
        }

        Write-Debug ("Processing project root <" + $Leaf + ">.")

        # Generate TAGS files for every given leaf.
        [String]$LeafPath      = (Get-Location).Path + '\' + $Leaf
        [System.Object]$JobObj = GenerateJobObject $LeafPath $NODE_FILTER_LIST
        $Job = Start-Job -FilePath $SCRIPT_NODE_PROC -ArgumentList $JobObj
        if ($Job) {
            $Jobs += $Job
        }
    }

    if ($Jobs.Length -ne 0) {
        # Wait for the jobs to finish.
        [Int32]$JobsWorking = $Jobs.Length
        while ($JobsWorking -ne 0) {
            # Tally up the number of jobs still going on.
            $JobsWorking = 0
            foreach ($Job in $Jobs) {
                if ($Job.State -eq "Running") {
                    ++$JobsWorking
                }
            }

            # Display a progress bar.
            [String]$Activity = "Processing lead nodes."
            [String]$Status   = "Children running: ($JobsWorking/" + $Jobs.Length + ")"
            [Int32] $Percent  = (($Jobs.Length - $JobsWorking) / $Jobs.Length) * 100
            Write-Progress -Activity $Activity -Status $Status -PercentComplete $Percent

            # Don't want to work this to death.
            Start-Sleep -Milliseconds 500
        }

        $Jobs | Receive-Job
        $Jobs | Stop-Job
        $Jobs | Remove-Job
        Write-Host "Leaf tag generation complete."
    }

    # Remove the root TAGS file.
    if (Test-Path "TAGS") {
        Write-Debug "Removing root TAGS file."
        Remove-Item -Force "TAGS"
    }

    # Generate the root TAGS file.
    Write-Host "Generating root TAGS file."
    & ectags $CTAGS_NO_STATICS $CTAGS_RECURSE $CTAGS_GEN_EMACS
    Write-Host "Success!"

}
Set-Alias Gen-Tags Generate-Tags
