#*****************************************************************************
#*
#*  CtagsNodeHandler.ps1
#*  Script to generate a TAGS file for a node, then recursively handle each
#*  descendant.
#*
#*  By Caleb McCombs (3/16/2013)
#*
#***

#*****************************************************************************
#*
#* File As Script
#*
#***

Param (
    [System.Object]$NodeData
)


#*****************************************************************************
#*
#* Script "Constants"
#*
#*
#***

## CTags (Also ECTags) Options
$CTAGS_APPEND     = "--append=yes"
$CTAGS_GEN_EMACS  = "-e"
$CTAGS_NO_STATICS = "--file-scope=no"
$CTAGS_RECURSE    = "--recurse=yes"


#*****************************************************************************
#*
#* Local Function(s)
#*
#***

#=============================================================================
function NodeHandler {
    Param (
        [String]$NodePath,
        [String[]]$NodeFilterList,
        [Int32]$IndentCount
    )

    [String]$DebugIndent = ""
    for ([Int32]$Index = 0; $IndentCount -gt $Index; ++$Index) {
        $DebugIndent += "`t"
    }

    Write-Debug ($DebugIndent + "Node name: <" + $NodePath + ">.")
    Write-Debug ($DebugIndent + "Debug Indent count: " + $Indentcount)

    # Skip filtered directories.
    foreach ($FilteredNodeName in $NodeFilterList) {
        if ($NodePath.Contains($FilteredNodeName)) {
            Write-Debug ($DebugIndent + "Filtered node <" + $NodePath + "> encountered. Skipping.")
            return
        }
    }

    Push-Location $NodePath
    Write-Host ("Processing directory <" + (Get-Location).Path + ">.")

    # Remove the old tags file if it exists.
    if (Test-Path "TAGS") {
        Write-Debug ($DebugIndent + "`tRemoving old TAGS file.")

        # Is the item a directory? If so, emit an error.
        if ((Get-ChildItem "tags").PSIsContainer) {
            Write-Error -Message "A directory named `"tags`" was found, skipping directory." -Category InvalidData -RecommendedAction "Rename the directory."
            return $False
        }
        Remove-Item -Force "TAGS"
    }

    Write-Debug ($DebugIndent + "`tGenerating new TAGS file.")
    & ectags $CTAGS_GEN_EMACS *

    # Determine the list of descendant directories to be processed for non-statics
    #   and process them.
    Get-ChildItem | Where-Object {
        if (!$_.PSIsContainer) {
            return $False
        }
        foreach ($FilteredNodeName in $NodeFilterList) {
            if ($_.FullName.Contains($FilteredNodeName)) {
                return $False
            }
        }
        return $True
    } | ForEach-Object {
        Write-Debug ($DebugIndent + "`t`tAppending non-static tags from descendant directory <" + $_.Name + ">.")
        & ectags $CTAGS_GEN_EMACS $CTAGS_APPEND $CTAGS_RECURSE $CTAGS_NO_STATICS $_.Name

        # Now dive into the child directory recursively and process it just like this node.
        Write-Debug ($DebugIndent + "`t`tRecursively handling node.")
        NodeHandler $_.Name ($IndentCount + 2)
    }

    ## Put things back the way they were.
    Pop-Location

}


#*****************************************************************************
#*
#* Script
#*
#***

## Just call the node handler.
NodeHandler $NodeData.Path $NodeData.Filter 0
