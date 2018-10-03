##############################################################################
#
#  Prompt.ps1
#  Customizes my command prompt.
#
#  By Caleb McCombs (2018/10/03)
#
####

#*****************************************************************************
#*
#*  Classes
#*
#*****************************************************************************
class MyPromptSettings {
    [scriptblock]$GenerateMyPromptContents = $null

    #=========================================================================
    MyPromptSettings() {
        if (Get-Module "posh-git") {
            $this.setPromptPoshGit()
        } else {
            $this.setPromptDefault()
        }
    }

    #=========================================================================
    [String] getDebugTag() {
        if (Test-Path variable:\PSDebugContext) {
            return "[DBG]"
        }
        return ""
    }

    #=========================================================================
    [String] getGitTag() {
        [String]$branch = Get-GitBranch
        [String]$result = ""
        if ($branch) {
            $result = "[$branch"
            $gitAnnotation = Invoke-Git "config" "branch.$branch.prompt-annotation"
            if (![String]::IsNullOrWhiteSpace($gitAnnotation)) {
                $gitString += " ($gitAnnotation)"
            }
            $result += "]"
        }
    
        return $result
    }

    #=========================================================================
    [String] getLocation() {
        [String]$userHomeDir = $Env:HOMEDRIVE + $Env:HOMEPATH
        [String]$loc = $Global:ExecutionContext.SessionState.Path.CurrentLocation

        return $loc -Replace "^$([Regex]::Escape($userHomeDir))", "~"
    }
    
    #=========================================================================
    [String] getVsTag() {
        if ($Global:currentVsCmdVer) {
            return "[VS$Global:currentVsCmdVer]"
        }
        return ""
    }
    
    #=========================================================================
    [String] getSuffix() {
        [String]$result = "$(">" * ($NestedPromptLevel + 1)) "
    
        # Check for ConEmu existence and ANSI emulation enabled
        if ($Env:ConEmuANSI -eq "ON") {
            # Let ConEmu know when the prompt ends, to select typed
            # command properly with "Shift+Home", to change cursor
            # position in the prompt by simple mouse click, etc.
            $result += "$([char]27)]9;12$([char]7)"
    
            # And current working directory (FileSystem)
            # ConEmu may show full path or just current folder name
            # in the Tab label (check Tab templates)
            # Also this knowledge is crucial to process hyperlinks clicks
            # on files in the output from compilers and source control
            # systems (git, hg, ...)
            $location = $Global:ExecutionContext.SessionState.Path.CurrentFileSystemLocation
            if ($location.Provider.Name -eq "FileSystem") {
                $result += "$([char]27)]9;9;`"$($location.Path)`"$([char]7)"
            }
        }
    
        return $result
    }

    #=========================================================================
    [void] setPromptPoshGit() {
        Write-Debug "Setting up posh-git prompt."
        # Display "~\" instead of "C:\Users\<username>\"
        $Global:GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
    
        # Remove the extra space in front of the git status
        $Global:GitPromptSettings.BeforeText = "["
    
        $this.GenerateMyPromptContents = {
            param($settings)

            [String]$prompt = ""
            $prompt += Write-Prompt "[PS]" -ForegroundColor "Gray"
            $prompt += Write-Prompt $settings.getDebugTag() -ForegroundColor "Red"
            $prompt += Write-Prompt $settings.getVsTag() -ForegroundColor "DarkYellow"
            $prompt += Write-VcsStatus
            $prompt += Write-Prompt ":" -ForegroundColor "Gray"
            $prompt += Write-Prompt $settings.getLocation() -ForegroundColor "Blue"
            $prompt += $settings.getSuffix()
    
            return $prompt
        }
    }

    #=========================================================================
    [void] setPromptDefault() {
        Write-Debug "Setting up default prompt."
        $this.GenerateMyPromptContents = {
            param($settings)

            Write-Host "[PS]" -NoNewline -ForegroundColor "Gray"
            Write-Host $settings.getDebugTag() -NoNewline -ForegroundColor "Red"
            Write-Host $settings.getVsTag() -NoNewline -ForegroundColor "DarkYellow"
            Write-Host $settings.getGitTag() -NoNewline -ForegroundColor "Yellow"
            Write-Host ":" -NoNewline -ForegroundColor "Gray"
            Write-Host $settings.getLocation() -NoNewline -ForegroundColor "Blue"
            Write-Host $settings.getSuffix() -NoNewline -ForegroundColor "Gray"
    
            return " "
        }
    }
}

#*****************************************************************************
#*
#*  Script Actions
#*
#*****************************************************************************

$Global:MyPromptSettings = [MyPromptSettings]::new()

[scriptblock]$myPrompt = {
    $origDebugPreference = $DebugPreference
    $origLastExitCode = $LASTEXITCODE

    $DebugPreference = "SilentlyContinue"

    $promptContents = & $Global:MyPromptSettings.GenerateMyPromptContents $Global:MyPromptSettings

    $LASTEXITCODE = $origLastExitCode
    $DebugPreference = $origDebugPreference

    return $promptContents
}

Set-Item Function:\Prompt -Value $myPrompt
