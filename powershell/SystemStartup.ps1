# If no client is setup, then bloody-well set it up!
if (!(Test-Path "U:")) {
    Restore-ClientSpec -Force
}
