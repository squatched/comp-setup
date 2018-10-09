##############################################################################
#
#  Modules.ps1
#  Load modules.
#
#  By Caleb McCombs (2018/10/03)
#
####

#*****************************************************************************
#*
#*  Internal Functions
#*
#*****************************************************************************

#=============================================================================
function tryImportModule ([String]$moduleName) {
    if ( !( Get-Module -ListAvailable -Name $moduleName ) ) {
            Write-Debug "Module <$moduleName> is not installed. Skipping import."
            return $false
    }
    Write-Debug "Module <$moduleName> is installed, importing..."
    Import-Module $moduleName
    return $true
}

#*****************************************************************************
#*
#*  Script Actions
#*
#*****************************************************************************

## Import PSReadline - See https://github.com/lzybkr/PSReadLine
if ( tryImportModule( "PSReadLine" ) ) {
    Set-PSReadlineOption -EditMode Emacs
}

## Import posh-git - See https://github.com/dahlbyk/posh-git
if ( tryImportModule( "posh-git" ) ) {}
