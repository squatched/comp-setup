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
[String]$profileScriptsSCMgmt        = $profileScriptsPath + "SourceControlManagement.ps1"       # Routines for handling common source control tasks.
[String]$profileScriptsGit           = $profileScriptsPath + "Git.ps1"                           # Custom routines that give us interaction with git.
[String]$profileScriptsCtags         = $profileScriptsPath + "CtagsGeneration.ps1"               # Routines to generate TAGS files in a hierarchy.

## Dot source personal scripts.
Write-Debug "Dot sourcing: $profileScriptsMiscUtils"
. $profileScriptsMiscUtils
Write-Debug "Dot sourcing: $profileScriptsVsVars"
. $profileScriptsVsVars
Write-Debug "Dot sourcing: $profileScriptsSCMgmt"
. $profileScriptsSCMgmt
Write-Debug "Dot sourcing: $profileScriptsGit"
. $profileScriptsGit
Write-Debug "Dot sourcing: $profileScriptsCtags"
. $profileScriptsCtags
Write-Debug "Dot sourcing complete."

## Load my dev profile stuff if it exists on this machine.
[String]$devProfilePath             = $profilePath + "\DevScripts\Profile.ps1"
if (Test-Path $devProfilePath) {
    Write-Debug "Dot sourcing: $devProfilePath"
    . $devProfilePath
    Write-Debug "Dot sourcing complete for: $devProfilePath"
}


##############################################################################
#
#  Customization
#
###

## Notepad Alias
Set-Alias np "C:\emacs\bin\emacsclientw.exe"

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
    [String]$location = Get-Location
    [String]$gitstring = Get-GitBranch
    [String]$vsString = $currentVsCmdVer
    [String]$p4CliString = ""
    [String]$p4CliBranchString = ""
    [String]$suffix = ">"

    if ($gitstring) {
        $stashCount = 0#Get-GitStashCount
        if ($stashCount) {
            $gitstring = "[${gitstring}:$stashCount]"
        }
        else {
            $gitString = "[$gitString]"
        }
    }

    if ($vsString) {
        $vsString = "[VS$vsString]"
    }

    if (Test-Path variable:/PSDebugContext) {
        $prefix += "[DBG]: "
    }

    if ($nestedpromptlevel -ge 1) {
        $suffix = ">>"
    }

    Write-Host $prefix -nonewline -foregroundcolor Red
    Write-Host $vsString -nonewline -foregroundcolor Blue

    DevPrompt()

    Write-Host $gitstring -nonewline -foregroundcolor DarkYellow
    Write-Host $location -nonewline -foregroundcolor Yellow
    Write-Host $suffix -nonewline -foregroundcolor Gray

    $DebugPreference = $oldDebugPreference

    return " "
}
Write-Debug "Prompt handler: End"
