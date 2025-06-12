### PowerShell template profile
### Version 1.03 - Tim Sneath <tim@sneath.org>
### From https://gist.github.com/timsneath/19867b12eee7fd5af2ba
###
### This file should be stored in $PROFILE.CurrentUserAllHosts
### If $PROFILE.CurrentUserAllHosts doesn't exist, you can make one with the following:
###    PS> New-Item $PROFILE.CurrentUserAllHosts -ItemType File -Force
### This will create the file and the containing subdirectory if it doesn't already
###
### As a reminder, to enable unsigned script execution of local scripts on client Windows,
### you need to run this line (or similar) from an elevated PowerShell prompt:
###   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
### This is the default policy on Windows Server 2012 R2 and above for server Windows. For
### more information about execution policies, run Get-Help about_Execution_Policies.

if ($host.Name -eq 'ConsoleHost') {
    # Early imports
    Import-Module posh-git

    # Find out if the current user identity is elevated (has admin rights)
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    # Useful shortcuts for traversing directories
    function cd... { Set-Location ..\.. }
    function cd.... { Set-Location ..\..\.. }

    # Compute file hashes - useful for checking successful downloads
    function md5 { Get-FileHash -Algorithm MD5 $args }
    function sha1 { Get-FileHash -Algorithm SHA1 $args }
    function sha256 { Get-FileHash -Algorithm SHA256 $args }

    # Quick shortcut to start notepad
    function n { notepad $args }

    # Drive shortcuts
    function HKLM: { Set-Location HKLM: }
    function HKCU: { Set-Location HKCU: }
    function Env: { Set-Location Env: }

    # Creates drive shortcut for OneDrive, if current user account is using it
    if (Test-Path HKCU:\SOFTWARE\Microsoft\OneDrive) {
        $onedrive = Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\OneDrive
        if ($onedrive.UserFolder -And (Test-Path $onedrive.UserFolder)) {
            New-PSDrive -Name OneDrive -PSProvider FileSystem -Root $onedrive.UserFolder -Description "OneDrive"
            function OneDrive: { Set-Location OneDrive: }
        }
        Remove-Variable onedrive
    }

    # Set up command prompt and window title. Use UNIX-style convention for identifying
    # whether user is elevated (root) or not. Window title shows current version of PowerShell
    # and appends [ADMIN] if appropriate for easy taskbar identification
    $GitPromptSettings.BeforePath = "["
    $GitPromptSettings.AfterPath = "]"
    if ($isAdmin) {
        $GitPromptSettings.DefaultPromptSuffix = " # "
    }
    else {
        $GitPromptSettings.DefaultPromptSuffix = " $ "
    }

    $Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
    if ($isAdmin) {
        $Host.UI.RawUI.WindowTitle += " [ADMIN]"
    }

    # Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
    function dirs {
        if ($args.Count -gt 0) {
            Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
        }
        else {
            Get-ChildItem -Recurse | Foreach-Object FullName
        }
    }

    # Simple function to start a new elevated process. If arguments are supplied then
    # a single command is started with admin rights; if not then a new admin instance
    # of PowerShell is started.
    function admin {
        if ($args.Count -gt 0) {
            $argList = "& '" + $args + "'"
            Start-Process "$psHome\pwsh.exe" -Verb runAs -ArgumentList $argList
        }
        else {
            Start-Process "$psHome\pwsh.exe" -Verb runAs
        }
    }

    # Set UNIX-like aliases for the admin command, so sudo <command> will run the command
    # with elevated rights.
    Set-Alias -Name su -Value admin
    Set-Alias -Name sudo -Value admin

    # Make it easy to edit this profile once it's installed
    function Edit-Profile {
        nvim $profile.CurrentUserAllHosts
    }

    # We don't need these any more; they were just temporary variables to get to $isAdmin.
    # Delete them to prevent cluttering up the user profile.
    Remove-Variable identity
    Remove-Variable principal

    # Vi mode
    Set-PSReadlineOption -EditMode vi
    Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

    # Imports
    Import-Module PSReadLine
    Import-Module PSFzf

    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

    # Fast Node Manager.
    if (Get-Command "fnm" -errorAction SilentlyContinue) {
        fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
    }

    # Zoxide.
    if (Get-Command "zoxide" -errorAction SilentlyContinue) {
        Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
    }

    # Neovim as main editor.
    $env:EDITOR = "nvim"

    # Set default shell as PowerShell.
    $env:SHELL = "pwsh"
}
