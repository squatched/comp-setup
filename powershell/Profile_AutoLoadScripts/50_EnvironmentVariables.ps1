##############################################################################
#
#  EnvironmentVariables.ps1
#  
#
#  By Caleb McCombs (2018/10/03)
#
####

function Get-ProprietaryModulesPath {
    [String[]]$psModulePaths = $Env:PSModulePath.split(';')
    [String[]]$userModulePath = (
        $psModulePaths |
        Where-Object {
            $_.StartsWith($Env:USERPROFILE) -and $_.EndsWith('\Modules')
        }
    )

    if ($userModulePath.Length -eq 0) {
        [System.Text.StringBuilder]$sb = [System.Text.StringBuilder]::new()
        $sb.Append('Unable to find Modules folder in PSModulePath ')
        $sb.AppendFormat(
            "[{0}] that resides in the user's profile [{1}]",
            $Env:PSModulePath,
            $Env:USERPROFILE
        )
        throw $sb.ToString()
    }

    return $userModulePath[0] + "Proprietary"
}

[String]$proprietaryModulesPath = Get-ProprietaryModulesPath
if (Test-Path $proprietaryModulesPath) {
    Write-Debug (
        "Adding proprietary modules path to " +
            "PSModulePath: $proprietaryModulesPath"
    )
    $env:PSModulePath = "$(Get-ProprietaryModulesPath);$($Env:PSModulePath)"
}

##############################################################################
#
#  Cleanup local functions
#
####
Remove-Item Function:\Get-ProprietaryModulesPath
Remove-Item Variable:\proprietaryModulesPath
