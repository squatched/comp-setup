##############################################################################
#
#  Providers.ps1
#  Customizes providers I care about.
#
#  By Caleb McCombs (2018/10/03)
#
####

## Add the HKEY_CLASSES_ROOT drive to the registry provider while suppressing output.
if (!(Test-Path "HKCR:")) {
    Write-Debug "Adding an HKEY_CLASSES_ROOT registry provider."
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT > $NULL
}