##############################################################################
#
#  Microsoft.PowerShell_profile.ps1
#  Customizes my instance of PowerShell (non-ISE). Is loaded after
#  Profile.ps1.
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
[String]$profilePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. trySourceDirContents "$profilePath\PowerShell_Profile_AutoLoadScripts\"
. trySourceDirContents "$profilePath\PowerShell_Profile_ProprietaryAutoLoadScripts\"
