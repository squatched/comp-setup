##############################################################################
#
#  Microsoft.PowerShell_profile.ps1
#  Customizes my instance of PowerShell (non-ISE).
#
#  By Caleb McCombs (7/28/2013)
#
###

[String]$profilePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Internal_Helper_Import_Module ([String]$moduleName) {
        if ( !( Get-Module -ListAvailable -Name $moduleName ) ) {
                Write-Debug "Module <$moduleName> is not installed. Skipping import."
                return $false
        }

        Import-Module PSReadLine
        return $true
}

## Import PowerTab
#Import-Module PowerTab -Argumentlist ($profilePath + "\PowerTabConfig.xml")

## Import PSReadline - See https://github.com/lzybkr/PSReadLine
if ( Internal_Helper_Import_Module( "PSReadLine" ) ) {
        Set-PSReadlineOption -EditMode Emacs
}

## Import posh-git - See https://github.com/dahlbyk/posh-git
if ( Internal_Helper_Import_Module( "posh-git" ) ) {
}
