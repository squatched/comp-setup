##############################################################################
#
#  Microsoft.PowerShell_profile.ps1
#  Customizes my instance of PowerShell (non-ISE).
#
#  By Caleb McCombs (7/28/2013)
#
###

##############################################################################
#
#  Load External Scripts & Modules
#
####
function trySourceDirContents ([String]$dirPath) {
    if (Test-Path $dirPath) {
        foreach ($file in (Get-ChildItem -Path $dirPath)) {
            Write-Debug "Dot sourcing: $($file.FullName)"
            . $file.FullName
            Write-Debug "Dot sourcing of $($file.Name) complete."
        }
    }
}

## Dot source all scripts in the given directory.
[String]$profilePath                    = Split-Path -Parent $MyInvocation.MyCommand.Definition
. trySourceDirContents "$profilePath\ProfileAutoLoadDefaultHostScripts\"
. trySourceDirContents "$profilePath\ProfileAutoLoadProprietaryDefaultHostScripts\"