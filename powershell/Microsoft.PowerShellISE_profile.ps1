#############################################################################
#
# Microsoft.PowerShellISE_profile.ps1
# Customizes my instance of the PowerShell ISE.
#
# By Caleb McCombs (7/28/2013)
#
####

##############################################################################
#
#  Load External Scripts & Modules
#
####

## Dot source all scripts in the given directory.
[String]$profilePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. trySourceDirContents "$profilePath\PowerShellISE_Profile_AutoLoadScripts\"
. trySourceDirContents "$profilePath\PowerShellISE_Profile_AutoLoadScripts_Proprietary\"