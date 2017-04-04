# Powershell Setup

This folder should be junctioned as:
```
%USERHOMEDIRECTORY%Documents/WindowsPowerShell

e.g. - C:/Users/cmccombs/Documents/WindowsPowerShell
```

## External Dependencies

Some of these scripts may rely on commandlets from the Powershell Community Extensions library (pscx). This is as easy as (if you're running a recent version of PowerShell):
```
PS> Install-Module pscx -AllowClobber
```
The "AllowClobber" flag is necessary as there is a built-in command that is duplicated and thus gets overridden by pscx (I don't remember which command specifically but it's one that I have never interacted with and don't believe I ever will so... who cares).
