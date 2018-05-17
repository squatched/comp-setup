##############################################################################
#
#  Profile.ps1
#  Customizes all my instances of PowerShell.
#
#  By Caleb McCombs (1/2/2013)
#
####

##############################################################################
#
#  Debug Helpers
#
####

## Uncomment the following line to get debug spew.
#$DebugPreference = "Continue"

#=============================================================================
## A simple assert function.  Verifies that $condition
## is true.  If not, outputs the specified error message.
function assert ( 
    [bool]$condition,
    [string] $message = "Test failed."
) {
    if(!$condition) {
        Write-Host -ForegroundColor Yellow "ASSERTION FAILED: $message"
    }
}


##############################################################################
#
#  Load External Scripts & Modules
#
####

## Profile stuff.
[String]$profilePath                 = Split-Path -Parent $MyInvocation.MyCommand.Definition
[String]$profileScriptsPath          = $profilePath + "\Scripts\"
[String]$profileScriptsMiscUtils     = $profileScriptsPath + "MiscUtils.ps1"
[String]$profileScriptsVsVars        = $profileScriptsPath + "VsVars.ps1"                        # Routines for handling visual studio commandline.
#[String]$profileScriptsSCMgmt        = $profileScriptsPath + "SourceControlManagement.ps1"       # Routines for handling common source control tasks.
[String]$profileScriptsGit           = $profileScriptsPath + "Git.ps1"                           # Custom routines that give us interaction with git.
#[String]$profileScriptsCtags         = $profileScriptsPath + "CtagsGeneration.ps1"               # Routines to generate TAGS files in a hierarchy.
#[String]$profileScriptsHybridRepos   = $profileScriptsPath + "HybridRepositories.ps1"            # Routines to manage P4/Git hybrid repos.

## Dot source personal scripts.
Write-Debug "Dot sourcing: $profileScriptsMiscUtils"
. $profileScriptsMiscUtils
Write-Debug "Dot sourcing: $profileScriptsVsVars"
. $profileScriptsVsVars
#Write-Debug "Dot sourcing: $profileScriptsSCMgmt"
#. $profileScriptsSCMgmt
Write-Debug "Dot sourcing: $profileScriptsGit"
. $profileScriptsGit
#Write-Debug "Dot sourcing: $profileScriptsCtags"
#. $profileScriptsCtags

## Load my dev profile stuff if it exists on this machine.
[String] $devProfilePath             = $profilePath + "\DevScripts\Profile.ps1"
[Boolean]$usingDevProfile            = Test-Path $devProfilePath
if ($usingDevProfile) {
    Write-Debug "Dot sourcing: $devProfilePath"
    . $devProfilePath
    Write-Debug "Dot sourcing complete for: $devProfilePath"
}

## This requires devProfile to define some things.
#. $profileScriptsHybridRepos
Write-Debug "Dot sourcing complete."


##############################################################################
#
#  Customization
#
###

## Notepad Alias
function np ([String]$file) {
    & "$Env:ProgramFiles\Emacs\bin\emacsclientw.exe" --alternate-editor="" --create-frame $file
}

## Timestamp
function Get-TimeStamp { Get-Date -UFormat "%Y%m%d%H%M%S" }

#=============================================================================
## Alias to edit this profile.
function Edit-Profile {np $profile}

## Add the HKEY_CLASSES_ROOT drive to the registry provider while suppressing output.
if (!(Test-Path "HKCR:")) {
    Write-Debug "Adding an HKEY_CLASSES_ROOT registry provider."
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT > $NULL
}

Write-Debug "Prompt handler: Begin"
#=============================================================================
## Adjust the command prompt.
function prompt {
    [String]$oldDebugPreference = $DebugPreference
    $DebugPreference = "SilentlyContinue"

    [String]$prefix = ""
    [String]$rootPrompt = $Env:USERNAME + "@" + $Env:COMPUTERNAME
    [String]$separator = ":"
    [String]$location = Get-Location
    [String]$gitString = ""
    [String]$vsString = $currentVsCmdVer
    [String]$p4CliString = ""
    [String]$p4CliBranchString = ""
    [String]$suffix = ">"

    [String]$gitBranch = Get-GitBranch
    if ($gitBranch) {
        $gitString = "[${gitBranch}"
        $jira = Invoke-Git config branch.${gitBranch}.jira
        if (![String]::IsNullOrWhiteSpace($jira)) {
            $gitString += " (${jira})"
        }

        $stashCount = 0#Get-GitStashCount
        if ($stashCount) {
            $gitString += ":${stashCount}"
        }

        $gitString += "]"
    }

    if ($vsString) {
        $vsString = "[VS$vsString]"
    }

    if (Test-Path variable:/PSDebugContext) {
        $prefix += "[DBG]: "
    }

    if ($nestedpromptlevel -ge 1) {
        $suffix += ">"
    }

    Write-Host $prefix -nonewline -foregroundcolor Red
    Write-Host $vsString -nonewline -foregroundcolor DarkYellow

    if ($usingDevProfile -and (Get-Command -CommandType Function -Name DevPrompt -ErrorAction SilentlyContinue)) {
        DevPrompt
    }

    Write-Host $gitstring -nonewline -foregroundcolor Yellow
    Write-Host $rootPrompt -nonewline -foregroundcolor Green
    Write-Host $separator -nonewline -foregroundcolor Gray
    Write-Host $location -foregroundcolor Blue

    # Check for ConEmu existance and ANSI emulation enabled
    if ($Env:ConEmuANSI -eq "ON") {
        # Let ConEmu know when the prompt ends, to select typed
        # command properly with "Shift+Home", to change cursor
        # position in the prompt by simple mouse click, etc.
        $suffix += "$([char]27)]9;12$([char]7)"

        # And current working directory (FileSystem)
        # ConEmu may show full path or just current folder name
        # in the Tab label (check Tab templates)
        # Also this knowledge is crucial to process hyperlinks clicks
        # on files in the output from compilers and source control
        # systems (git, hg, ...)
        if ($location.Provider.Name -eq "FileSystem") {
            $suffix += "$([char]27)]9;9;`"$($location.Path)`"$([char]7)"
        }
    }

    $DebugPreference = $oldDebugPreference

    return $suffix + ' '
}
Write-Debug "Prompt handler: End"
