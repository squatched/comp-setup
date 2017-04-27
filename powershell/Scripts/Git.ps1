#*****************************************************************************
#*
#*  Git.ps1
#*  Some git utility functions.
#*
#***

#*****************************************************************************
#*
#*  Script Variables
#*
#*****************************************************************************
$script:gitStashCount = @(git stash list).Length 2> $NULL
$script:gitRootStash = New-Object System.Collections.Generic.Stack[Object]


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
function FormatObjectKeyValues ([Object]$obj, [String]$preamble = "") {
    [String]$result = ""

    $obj.Keys | ForEach-Object {
        $result += "$preamble$_ = $($obj[$_])`n"
    }

    return $result
}

#=============================================================================
function GitHookStash ([String]$result) {

    if ($result -and !$result.StartsWith("No local changes to save")) {
        $script:gitStashCount += 1
    }

}

#=============================================================================
function GitHookStashPop ([String]$result) {

    if ($result -and !$result.StartsWith("No stash found.")) {
        $script:gitStashCount -= 1
    }
}

# Add the above methods to the hooks table.
$gitPostHooks.Add("stash",      $Function:GitHookStash)
$gitPostHooks.Add("stash save", $Function:GitHookStash)
$gitPostHooks.Add("stash pop",  $Function:GitHookStashPop)

#=============================================================================
function GitLocationState () {
    if ($NULL -eq (Get-GitBranch)) {
        throw "Not in a git repo"
    }

    [Object]$state = @{
        "Path" = $(Get-Location).Path;
        "Branch" = $(Get-GitBranch);
        "IndexIsDirty" = ![String]::IsNullOrWhiteSpace((Invoke-Git status --short));
        "StashHash" = $NULL;
    }

    Write-Debug "Current git location state:"
    Write-Debug (FormatObjectKeyValues $state "  ")

    return $state
}


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
## Retrieve the current git repo's root
function Get-GitRepositoryRoot {
    param (
        [Parameter(Mandatory = $false)]
        [Switch]$Stack
    )

    if ($Stack) {
        return $script:gitRootStash.ToArray()
    }

    [String]$root = Invoke-Git rev-parse --show-toplevel

    if (Test-Path $root) {
        return Get-NormalizedPath $root
    }
    return $null
}

#=============================================================================
## Retrieve the number of stashes on the stash.
function Get-GitStashCount {
    return $script:gitStashCount
}

#============================================================================
## Retrieve the current repo's trunk branch. Defaults to master.
function Get-GitTrunkBranch {
    [String]$gitTrunkBranch = (Invoke-Git config trunk.branch)
    if ([String]::IsNullOrEmpty($gitTrunkBranch)) {
        Write-Debug "No trunk.branch config setting found. Defaulting to `"master`"."
        $gitTrunkBranch = "master"
    }
    return $gitTrunkBranch
}

#=============================================================================
## Plugin to all git commands...
function Invoke-Git {

    # Cache off everything as one string but escape double quotes for passing
    #   them to the command line.
    [String]$command = $args

    # Invoke the git command as a cmd.exe command because git has this habbit of
    #   using stderr for informational reasons and it makes the output of
    #   powershell ugly... Note, this is not very portable.
    Write-Debug "Invoking git command: $command"
    [String[]]$results = Invoke-Expression "cmd.exe /Q /C `"git $command 2>&1`""

    # Sometimes a git command returns nothing (e.g. - git config non-existent-config)
    if ($results.Count -eq 0) {
        return $null
    }

    # Test for failure and form an exception object based off it.
    if ($results[0] -like "fatal*" -or $results[0] -like "error*") {
        throw "Git command `"$command`" failed with error text: $results"
    }

    # Process post hooks.
    [String]$sanitizedCommand = $command.ToLower().Trim()
    if ($gitPostHooks.ContainsKey($sanitizedCommand)) {
        Write-Debug "Post hook for command found."

        & $gitPostHooks.Item($sanitizedCommand) ($results | Out-String)
    }

    # Return the results.
    return $results
}

#=============================================================================
## Restore from pushing to git repo root.
function Pop-GitRepositoryRoot {
    [Object]$currentState = GitLocationState
    [Object]$stashedState = $script:gitRootStash.Peek()

    # If we will be dirtying the index and checking out a branch or stash, then bail.
    # I don't want to have to reconcile that...
    if ($currentState.IndexIsDirty -and ($currentState.Branch -ne $stashedState.Branch -or ![String]::IsNullOrWhiteSpace($stashedState.StashHash))) {
        throw "Working index is dirty."
    }

    try {
        Write-Debug "Restoring from stashed state:"
        $stashedState.Keys | ForEach-Object {
            Write-Debug "  $_ = $($stashedState[$_])"
        }

        if ($currentState.Branch -ne $stashedState.Branch) {
            Write-Debug "Current branch $($currentState.Branch) does not mach stashed branch"
            Invoke-Git checkout $stashedState.Branch
        }

        if (![String]::IsNullOrWhitespace($stashedState.StashHash)) {
            Write-Debug "Stash detected, attempting to pop"
            # Find the stash in the list of stashes.
            [String]$stashHash = Invoke-Git stash list | ForEach-Object {
                $_ -Replace ":.*", ""
            } | Where-Object {
                [String]$hash = Invoke-Git rev-parse $_;
                return $hash -eq $stashedState.StashHash
            }

            if ([String]::IsNullOrWhiteSpace($stashHash)) {
                Write-Warning "Stashed hash missing from git stash. Attempting to apply hash $($stashedState.StashHash) manually"
                Invoke-Git stash apply $stashedState.StashHash
            }
            else {
                Write-Debug "Stash $stashHash matches our given commit id ($($stashedState.StashHash))"
                Invoke-Git stash pop $stashHash
            }
        }

        if ($currentState.Path -ne $stashedState.Path) {
            Write-Debug "Current location and stashed location ($($stashedState.Path)) do not match, setting location"
            Set-Location $stashedState.Path
        }
    }
    catch {
        Write-Warning "Failure detected when restoring stashed git repo root state:"
        Write-Warning (FormatObjectKeyValues $stashedState "  ")
        throw $_.Exception
    }
    finally {
        $script:gitRootStash.Pop() >$NULL
    }
}

#=============================================================================
## Get to the git repository root, in a specified branch if desired. If -Clean
## is specified, then you get to the root, in the trunk branch, with a clean
## working index (changes stashed using git stash).
function Push-GitRepositoryRoot {
    param (
        [Parameter(Mandatory = $false)]
        [Switch]$Clean,

        [Parameter(Mandatory = $false)]
        [String]$Branch
    )

    [String]$gitRoot = Get-GitRepositoryRoot
    [Object]$currentState = GitLocationState
    [String]$targetBranch = $Branch

    # If -Clean, then we need to get the trunk branch, otherwise current branch
    # is fine if specified.
    if ($Clean) {
        $targetBranch = Get-GitTrunkBranch
        Write-Debug "-Clean specified so setting Branch to $targetBranch"
    }
    elseif ([String]::IsNullOrEmpty($Branch)) {
        $targetBranch = $currentState.Branch
        Write-Debug "No branch specified so setting it to current: $targetBranch"
    }

    if ($gitRoot -ne $currentState.Path) {
        Write-Debug "Current location is not root so setting location to root ($gitRoot)"
        Set-Location $gitRoot
    }
    if ($targetBranch -ne $currentState.Branch) {
        Write-Debug "Specified branch `"$targetBranch`" is not the current branch ($($currentState.Branch))."
        if ($currentState.IndexIsDirty) {
            Write-Debug "Index is dirty. Stashing."
            Invoke-Git stash save --include-untracked "Auto-generated stash from Push-GitRepositoryRoot (PowerShell)"
            $currentState.StashHash = Invoke-Git rev-parse "stash@{0}"
        }

        Invoke-Git checkout $targetBranch
    }

    $script:gitRootStash.Push($currentState)
}