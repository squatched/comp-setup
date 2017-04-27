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
        Write-Debug "Not in a git repository, bailing."
        return
    }
    Push-Location $repoRoot
    [String]$branchCache = Get-GitBranch

    try {
        [String]$trunk = Get-GitTrunkBranch
        if ($branchCache -ne $trunk) {
            Invoke-Git "checkout $trunk"
        }
        Invoke-Git "fetch $remote"
        Invoke-Git "merge --ff-only $remote/$trunk"
        Sync-GitToPerforce
        Invoke-Git "push $remote $trunk"
    }
    finally {
        if ($branchCache -ne $trunk) {
            Invoke-Git "checkout $branchCache"
        }
        Pop-Location
    }
}

#============================================================================
## Syncs all hybrid repos linearly.
function Sync-HybridRepositories {
    $hybridRepositories | ForEach-Object {
        Write-Output "========== Syncing $_ =========="
        Push-Location $_
        try {
            Sync-HybridRepositoryWithRemote
        }
        finally {
            Pop-Location
        }
        Write-Output "`n"
    }
}
