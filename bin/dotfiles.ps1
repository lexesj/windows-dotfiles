<#
.SYNOPSIS
    Script that downloads programs and configures dotfiles for a development environment.

.PARAMETER Tags
    Used to filter the installation of dotfiles and programs. If not specified, all dotfiles and programs are installed.
#>
param
(
    [string[]]$Tags = @("PowerShell", "Vim", "Terminal", "PowerToys", "CliTools", "SshKey")
)

$DOTFILES_DIR = "$HOME\.windows-dotfiles"

function Test-IsAdmin
{
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal $Identity
    $IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return $isAdmin
}

$InstalledPrograms = winget list | Out-String

function Install-Program
{
    <#
    .SYNOPSIS
        Installs a program using the Windows Package Manager (winget).

    .PARAMETER ProgramName
        The name of the program to be installed.
    #>
    param
    (
        [string]$ProgramName
    )

    if ($InstalledPrograms -notmatch $ProgramName)
    {
        Write-Host "Installing $ProgramName..."
        winget install $ProgramName
    } else
    {
        Write-Host "Updating $ProgramName..."
        winget upgrade $ProgramName
    }
}

if (!(Test-IsAdmin))
{
    Write-Error "Please re-run this script as an administrator."
    exit 1
}

function Install-Git
{
    Install-Program Git.Git
    New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$DOTFILES_DIR\.gitconfig" -Force
}

Install-Git

if (!(Test-Path -Path $DOTFILES_DIR))
{
    Write-Host "Cloning dotfiles repository..."
    git clone --quiet --recurse-submodules https://github.com/lexesj/windows-dotfiles.git "$DOTFILES_DIR"
} else
{
    Write-Host "Updating dotfiles repository..."
    git -C "$DOTFILES_DIR" pull --quiet --recurse-submodules
}


function Install-PowerShell
{
    Install-Program Microsoft.PowerShell
    foreach ($Module in @("PSReadLine", "PSFzf", "posh-git"))
    {
        if (!(Get-Module -ListAvailable -Name $Module))
        {
            Write-Host "Installing PowerShell module: $Module..."
            Install-Module -Name $Module -Force
        }
    }

    New-Item -ItemType SymbolicLink -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\profile.ps1" -Target "$DOTFILES_DIR\profile.ps1" -Force
}

function Install-Vim
{
    foreach ($Program in @("Neovim.Neovim", "zig.zig"))
    {
        Install-Program $Program
    }

    New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$DOTFILES_DIR\unix-dotfiles\roles\neovim\files\nvim" -Force
    New-Item -ItemType SymbolicLink -Path "$HOME\.vsvimrc" -Target "$DOTFILES_DIR\.vsvimrc" -Force
}

function Install-Terminal
{
    foreach ($Program in @("Microsoft.WindowsTerminal", "DEVCOM.JetBrainsMonoNerdFont"))
    {
        Install-Program $Program
    }

    New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Target "$DOTFILES_DIR\windows-terminal\settings.json" -Force
}

function Install-PowerToys
{
    Install-Program Microsoft.PowerToys

    New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager\default.json" -Target "$DOTFILES_DIR\powertoys\keyboard\default.json" -Force
}

function Install-CliTools
{
    foreach ($Program in @("junegunn.fzf", "JesseDuffield.lazygit", "Schniz.fnm", "BurntSushi.ripgrep.MSVC", "sharkdp.fd"))
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

foreach ($Tag in $Tags)
{
    & (Get-Command -Name "Install-$Tag")
}
