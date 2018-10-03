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


##############################################################################
#
#  Load External Scripts & Modules
#
####
function trySourceDirContents ([String]$dirPath) {
    if (Test-Path $dirPath) {
        foreach ($file in (Get-ChildItem -Path $dirPath -Filter "*.ps1")) {
            Write-Debug "Dot sourcing: $($file.FullName)"
            . $file.FullName
            Write-Debug "Dot sourcing of $($file.Name) complete."
        }
    }
}

## Dot source all scripts in the given directory.
[String]$profilePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. trySourceDirContents "$profilePath\ProfileAutoLoadScripts\"
. trySourceDirContents "$profilePath\ProfileAutoLoadProprietaryScripts\"
