##############################################################################
#
#  TabCompletion.ps1
#  Enable tab completion for... Things.
#
#  By Caleb McCombs (2020/12/20)
#
####

if ((Test-Path -Path "Env:ChocolateyInstall") -and
    (Test-Path -Path "$Env:ChocolateyInstall\helpers\chocolateyProfile.psm1")) {
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -Force
}
