Import-Module "$PSScriptRoot\DefaultVariables.psm1"

function New-Link
{
    <#
    SYNOPSIS
        Creates a symbolic link in the Windows environment.

    .PARAMETER Path
        Path of the target file to link to.

    .PARAMETER Link
        Path of the symbolic link to create.
    #>
    param
    (
        [string]$Path,
        [string]$Link
    )

    gsudo { New-Item -ItemType SymbolicLink -Target $args[0] -Path $args[1] -Force } -args $Path,$Link
}

$InstalledPrograms = winget list | Out-String

function Install-Program
{
    <#
    .SYNOPSIS
        Installs a program using the Windows Package Manager (winget).

    .PARAMETER ProgramName
        The name of the program to be installed.

    .PARAMETER ShouldUpdate
        If the program is already installed, this parameter determines whether to update it. Default is $true.
    #>
    param
    (
        [string]$ProgramName,
        [bool]$ShouldUpdate = $true
    )

    if ($InstalledPrograms -notmatch $ProgramName)
    {
        Write-Host "Installing $ProgramName..."
        gsudo winget install $ProgramName
    } elseif ($ShouldUpdate)
    {
        Write-Host "Updating $ProgramName..."
        gsudo winget upgrade $ProgramName
    }
}

function Install-Git
{
    Install-Program Git.Git

    New-Link -Path "$env:DOTFILES_PATH\unix-dotfiles\roles\git\files\.gitconfig" -Link "$HOME\.gitconfig"
}

function Install-PowerShell
{
    Install-Program Microsoft.PowerShell

    foreach ($Module in @("PSReadLine", "PSFzf", "posh-git"))
    {
        if (!(Get-Module -ListAvailable -Name $Module))
        {
            Write-Host "Installing PowerShell module: $Module..."
            gsudo { Install-Module -Name $Module -Force }
        }
    }

    New-Link -Path "$env:DOTFILES_PATH\profile.ps1" -Link "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\profile.ps1"
}

function Install-Vim
{
    foreach ($Program in @("Neovim.Neovim", "zig.zig"))
    {
        Install-Program $Program
    }

    New-Link -Path "$env:DOTFILES_PATH\unix-dotfiles\roles\neovim\files\nvim" -Link "$env:LOCALAPPDATA\nvim"
    New-Link -Path "$env:DOTFILES_PATH\.vsvimrc" -Link "$HOME\.vsvimrc"
}

function Install-Terminal
{
    foreach ($Program in @("Microsoft.WindowsTerminal", "DEVCOM.JetBrainsMonoNerdFont"))
    {
        Install-Program $Program
    }

    New-Link -Path "$env:DOTFILES_PATH\windows-terminal\settings.json" -Link "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}

function Install-PowerToys
{
    Install-Program Microsoft.PowerToys

    New-Link -Path "$env:DOTFILES_PATH\powertoys\settings.json" -Link "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json"
    New-Link -Path "$env:DOTFILES_PATH\powertoys\keyboard\default.json" -Link "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager\default.json"
    New-Link -Path "$env:DOTFILES_PATH\powertoys\command-palette\settings.json" -Link "$env:LOCALAPPDATA\Packages\Microsoft.CommandPalette_8wekyb3d8bbwe\LocalState\settings.json"
}

function Install-CliTools
{
    foreach ($Program in @("junegunn.fzf", "JesseDuffield.lazygit", "Schniz.fnm", "BurntSushi.ripgrep.MSVC", "sharkdp.fd", "ajeetdsouza.zoxide", "tldr-pages.tlrc", "gerardog.gsudo"))
    {
        Install-Program $Program
    }
}

function Install-SshKey
{
    $SshKeyLocation = "$HOME\.ssh\id_ed25519"

    if (Test-Path -Path $SshKeyLocation -PathType Leaf)
    {
        Write-Host "SSH key already exists..."
        return
    }

    $HostName = [System.Net.Dns]::GetHostName()
    $UserName = $env:USERNAME
    $Comment = Read-Host -Prompt "SSH key comment [$UserName@$HostName-windows] "

    if ([string]::IsNullOrWhiteSpace($Comment))
    {
        $Comment = "$UserName@$HostName-windows"
    }

    New-Item -ItemType Directory -Force -Path "$HOME\.ssh"
    Write-Host "Generating SSH key at $SshKeyLocation with comment '$Comment'..."
    ssh-keygen -t ed25519 -C $Comment -f $SshKeyLocation

    Write-Host "Public key is: "
    ssh-keygen -y -f $SshKeyLocation
}

function Install-Winget
{
    Install-Program winget

    New-Link -Path "$env:DOTFILES_PATH\winget\settings.json" -Link "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
}
