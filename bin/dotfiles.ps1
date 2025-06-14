<#
.SYNOPSIS
    Script that downloads programs and configures dotfiles for a development environment.

.PARAMETER Tags
    Used to filter the installation of dotfiles and programs. If not specified, all dotfiles and programs are installed.
#>
param
(
    [string[]]$Tags = @("PowerShell", "Vim", "Terminal", "PowerToys", "CliTools")
)

$DOTFILES_DIR = "$HOME\.windows-dotfiles"

function Test-IsAdmin
{
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return $isAdmin
}

$installedPrograms = winget list | Out-String

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

    if ($installedPrograms -notmatch $ProgramName)
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
    git clone --quiet https://github.com/lexesj/windows-dotfiles.git "$DOTFILES_DIR"
} else
{
    Write-Host "Updating dotfiles repository..."
    git -C "$DOTFILES_DIR" pull --quiet
}


function Install-PowerShell
{
    Install-Program Microsoft.PowerShell
    foreach ($module in @("PSReadLine", "PSFzf", "posh-git"))
    {
        if (!(Get-Module -ListAvailable -Name $module))
        {
            Write-Host "Installing PowerShell module: $module..."
            Install-Module -Name $module -Force
        }
    }

    New-Item -ItemType SymbolicLink -Path "$([Environment]::GetFolderPath("MyDocuments"))\PowerShell\profile.ps1" -Target "$DOTFILES_DIR\profile.ps1" -Force
}

function Install-Vim
{
    foreach ($program in @("Neovim.Neovim", "zig.zig"))
    {
        Install-Program $program
    }

    New-Item -ItemType SymbolicLink -Path "$HOME\.vsvimrc" -Target "$DOTFILES_DIR\.vsvimrc" -Force
}

function Install-Terminal
{
    foreach ($program in @("Microsoft.WindowsTerminal", "DEVCOM.JetBrainsMonoNerdFont"))
    {
        Install-Program $program
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
    foreach ($program in @("junegunn.fzf", "JesseDuffield.lazygit", "Schniz.fnm", "BurntSushi.ripgrep.MSVC", "sharkdp.fd"))
    {
        Install-Program $program
    }
}

foreach ($tag in $Tags)
{
    & (Get-Command -Name "Install-$tag")
}
