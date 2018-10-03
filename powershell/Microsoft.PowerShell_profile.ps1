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

## Dot source all scripts in the given directory.
[String]$profilePath                    = Split-Path -Parent $MyInvocation.MyCommand.Definition
. trySourceDirContents "$profilePath\ProfileAutoLoadDefaultHostScripts\"
. trySourceDirContents "$profilePath\ProfileAutoLoadProprietaryDefaultHostScripts\"