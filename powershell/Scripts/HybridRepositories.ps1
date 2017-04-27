##############################################################################
#
#  HybridRepositories.ps1
#  Custom Routines for handling my hybrid P4/Git repos
#
#  By Caleb McCombs (4/27/2017)
#
####

# Expects $hybridRepositories to be an array of strings where each string is
#   the git root of a hybrid P4/Git repo
if ($hybridRepositories -eq $null) {
    return
}

#============================================================================
## Syncs a hybrid repo. Special consideration is needed since these are both
## P4 and Git. Since these can be done across multiple computers, I like to
## keep my master history linear.
function Sync-HybridRepositoryWithRemote ([String]$remote = "origin") {
    [String]$repoRoot = Get-GitRepositoryRoot
    if ($repoRoot -eq $null) {
        Write-Warning "Not in a git repository."
        return
    }

    Push-GitRepositoryRoot -Clean
    try {
        [String]$trunk = Get-GitTrunkBranch
        Invoke-Git "fetch $remote"
        Invoke-Git "merge --ff-only $remote/$trunk"
        Sync-GitToPerforce -PerforceSyncCommand "ted p4 sync -v"
        Invoke-Git "push $remote $trunk"
    }
    finally {
        Pop-GitRepositoryRoot
    }
}

#============================================================================
## Syncs all hybrid repos linearly.
function Sync-HybridRepositories {
    param (
        [Parameter(Mandatory = $False)]
        [Switch]$ContinueOnError
    )

    $hybridRepositories | ForEach-Object {
        [String]$path = $_
        Write-Output "========== Syncing $path =========="
        Push-Location $path
        try {
            Sync-HybridRepositoryWithRemote
        }
        catch {
            Write-Output "ERROR: Syncing repository $path failed with error:`n$(Out-String -InputObject $_)"
            if (!$ContinueOnError) {
                throw $_.Exception
            }
        }
        finally {
            Pop-Location
        }
        Write-Output "`n"
    }
}
