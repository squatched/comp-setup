## Visual studio command prompt garbage.
$global:currentVsCmdVer = $NULL
$global:originalEnv     = $NULL

function Get-Env {
    Write-Debug "Retrieving the current Env set."
    [String[]]$retVal = @("Resetting environment.")
    $retVal += Invoke-Expression "cmd /C `"set`""
    $debugOutput = $retVal[0]
    Write-Debug "`tCurrent environment: <$debugOutput...>"
    return $retVal
}

function Clear-Env {
    Push-Location Env:
    Write-Debug "`tDeleting all the current environment variables for the local context."
    Remove-Item -Force -Path *
    Pop-Location
}

function Set-Env ($env) {
    if (!$env) {
        Write-Debug "No environment specified. Bailing."
        return
    }
    $debugOutput = $env[0]
    Write-Debug "Setting environment to: <$debugOutput...>"
    Write-Debug "`tIterating over each object in the given environment and setting them."
    $env | ForEach-Object {
        $p, $v = $_.Split('=')

        # Sometimes we have an empty value. Ignore those entries.
        if ($v) {
            $endIdx = $v.Length - 1
            if ($endIdx -gt 32) {
                $endIdx = 32
            }
            $displayV = $v.Substring(0, $endIdx)
            Write-Debug ("`t`tSetting <$p> to <" + $displayV + ">")
            Set-Item -path Env:$p -value $v
        }
    }
}

function Get-Batchfile ($file) {
    Write-Debug "Retrieving batch file <$file>."
    $fileNameStr = "```"$file```""
    $cmdParam    = "/C `"$fileNameStr & set`""
    Write-Debug "`tRunning command with the following parameter string: <cmd $cmdParam>"

    # Needs to invoke <cmd /C "`"FileName`" & set">
    $env = Invoke-Expression "cmd $cmdParam"
    Set-Env $env
}

function Reset-VSEnv ([String]$version) {
    Write-Debug "Altering the environment with VS Environment version <$version>."
    if ($global:currentVsCmdVer) {
        Write-Debug "`tCurrent VS setup detected. Resetting environment to original state."
        $global:currentVsCmdVer = $NULL
        Clear-Env
        Set-Env $global:originalEnv
    }

    if ($version) {
        Write-Debug "`tNew version <$version> requested. Backing up original environment."
        $global:currentVsCmdVer = $version
        $global:originalEnv     = Get-Env
    }
}

function Start-VSEnvSpecialCase_6 {
    # Have to special case this as it doesn't follow the conventions set forth by
    #   9 & 10.
    Write-Debug "Starting the Visual Studio 6.0 special case."
    $version = "6.0"
    $global:currentVsCmdVer = $version

    $key = "HKLM:SOFTWARE\Microsoft\VisualStudio\6.0\Setup\Microsoft Visual C++\"
    Write-Debug "`tVisual studio key location: <$key>"
    $VsKey = Get-ItemProperty $key
    $VsCppInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.ProductDir + '\')
    Write-Debug "`tVsCppInstallPath: <$VsCppInstallPath>"
    $VsBinDir= [System.IO.Path]::Combine($VsCppInstallPath, "Bin")
    Write-Debug "`tVsBinDir: <$VsBinDir>"
    $BatchFile = [System.IO.Path]::Combine($VsBinDir, "vcvars32.bat")
    Write-Debug "`tBatchFile: <$BatchFile>"
    Get-Batchfile $BatchFile
}

function Start-VSEnv ([String]$version = "14.0") {
    Write-Debug "Setting VSEnv to version <$version>."
    if (-1 -eq $version.IndexOf('.')) {
        $version = "$version.0"
        Write-Debug "`tDecorating version to <$version>."
    }

    if ($version -eq $global:currentVsCmdVer) {
        return
    }

    Reset-VSEnv $version

    # Special case 6.0
    if ("6.0" -eq $version) {
        Start-VSEnvSpecialCase_6
        return
    }

    $key = "HKLM:SOFTWARE\Microsoft\VisualStudio\" + $version
    Write-Debug "`tVisual studio key location: <$key>"
    $VsKey = Get-ItemProperty $key
    if ($VsKey -eq $null) {
        Write-Debug "`tVisual Studio Registry Entry not Found, looking for Wow64 version."
        $VsKey = Get-ItemProperty $($key -replace "SOFTWARE\\", "SOFTWARE\WOW6432Node\")
    }
    $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
    Write-Debug "`tVSInstallPath: <$VsInstallPath>"
    $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
    Write-Debug "`tVsToolsDir: <$VsToolsDir>"
    $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, "Tools")
    Write-Debug "`tVsToolsDir: <$VsToolsDir>"
    $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "vsvars32.bat")
    Write-Debug "`tBatchFile: <$BatchFile>"
    Get-Batchfile $BatchFile
}

function Stop-VSEnv {
    Reset-VSEnv
}
