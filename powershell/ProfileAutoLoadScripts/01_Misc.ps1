##############################################################################
#
#  Misc.ps1
#  Misc methods I like to use quite a lot.
#
#  By Caleb McCombs (2018/10/03)
#
####

#=============================================================================
## A simple assert function.  Verifies that $condition
## is true.  If not, outputs the specified error message.
function assert ( 
    [bool]$condition,
    [string] $message = "Test failed."
) {
    if(!$condition) {
        Write-Host -ForegroundColor Yellow "ASSERTION FAILED: $message"
    }
}

#=============================================================================
## Call emacsclient
function np ([String]$file) {
    & "$Env:ProgramFiles\Emacs\bin\emacsclientw.exe" --alternate-editor="" --create-frame $file
}

#=============================================================================
## Generate a standard timestamp.
function Get-TimeStamp ([DateTime]$time = $(Get-Date)) {
    return $time.ToString("yyyyMMddHHmmss")
}

#=============================================================================
## Edit profile script.
function Edit-Profile {np $profile}
