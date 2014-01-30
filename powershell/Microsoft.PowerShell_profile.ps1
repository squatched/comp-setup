##############################################################################
#
#  Microsoft.PowerShell_profile.ps1
#  Customizes my instance of PowerShell (non-ISE).
#
#  By Caleb McCombs (7/28/2013)
#
###

[String]$profilePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

## Import PowerTab
#Import-Module PowerTab -Argumentlist ($profilePath + "\PowerTabConfig.xml")

## Import PSReadline - See https://github.com/lzybkr/PSReadLine
Import-Module PSReadLine
Set-PSReadlineOption -EditMode Emacs
