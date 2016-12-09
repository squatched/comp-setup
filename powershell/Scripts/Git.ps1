#*****************************************************************************
#*
#*  Git.ps1
#*  Some git utility functions.
#*
#***

#*****************************************************************************
#*
#*  Global Variables
#*
#*****************************************************************************
$global:gitStashCount = @(git stash list).Length 2> $NULL


#*****************************************************************************
#*
#*  Local Variables
#*
#*****************************************************************************

# This is a mapping of git commands to hook functions.
[Hashtable]$gitPostHooks = @{}


#*****************************************************************************
#*
#*  Internal Functions
#*
#*****************************************************************************

#=============================================================================
function GitHookStash ([String]$result) {

    if ($result -and !$result.StartsWith("No local changes to save")) {
        $global:gitStashCount += 1
    }

}

#=============================================================================
function GitHookStashPop ([String]$result) {

    if ($result -and !$result.StartsWith("No stash found.")) {
        $global:gitStashCount -= 1
    }

}

# Add the above methods to the hooks table.
$gitPostHooks.Add("stash",      $Function:GitHookStash)
$gitPostHooks.Add("stash save", $Function:GitHookStash)
$gitPostHooks.Add("stash pop",  $Function:GitHookStashPop)


#*****************************************************************************
#*
#*  Exported Functions
#*
#*****************************************************************************

#=============================================================================
## Retrieve the current location's git branch
function Get-GitBranch {
    Write-Debug "Calling `"git symbolic-ref -q HEAD`""
    [String]$gitSymbolicRef = (git symbolic-ref -q HEAD 2> $NULL)
    Write-Debug "Result: `"$gitSymbolicRef`""
    if ($gitSymbolicRef) {
        return ($gitSymbolicRef.Substring($gitSymbolicRef.LastIndexOf("/") + 1))
    }
    else {
        Write-Debug "Calling: `"git log -1 --oneline 2>`""
        [String]$gitLog = (git log -1 --oneline 2> $null)
        Write-Debug "Result: `"$gitLog`""
        if($gitLog) {
            return ($gitLog.SubString(0, $gitLog.IndexOf(" ")) + "...")
        }
    }
    
    return
}

#=============================================================================
## Retrieve the number of stashes on the stash.
function Get-GitStashCount {
    return $global:gitStashCount
}

#=============================================================================
## Retrieve the current git repos root
function Get-GitRepositoryRoot {
    return Get-NormalizedPath $(Invoke-Expression ("git rev-parse --show-toplevel"))
}

#=============================================================================
## Plugin to all git commands...
function Invoke-Git {

    # Cache off everything as one string.
    [String]$command = $args

    # First, process the command into a sanitary format.
    [String]$sanitizedCommand = $command.ToLower().Trim()

    # Invoke the git command.
    Write-Debug "Invoking git command: `"$command`""
    [String[]]$results = Invoke-Expression ("git " + $command)

    # Process post hooks.
    if ($gitPostHooks.ContainsKey($sanitizedCommand)) {
        Write-Debug "Post hook for command found."

        & $gitPostHooks.Item($sanitizedCommand) ($results | Out-String)
    }

    # Return the results.
    return $results

}

