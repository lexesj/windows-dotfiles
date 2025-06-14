<#
.SYNOPSIS
    Script that downloads programs and configures dotfiles for a development environment.

.PARAMETER Tags
    Used to filter the installation of dotfiles and programs. If not specified, all dotfiles and programs are installed.
#>
param
(
    [string[]]$Tags
)

$DOTFILES_DIR = "$HOME\.windows-dotfiles"

function Test-IsAdmin
{
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return $isAdmin
}

function Install-Dependencies
{
    if (!(Get-Command git -errorAction SilentlyContinue))
    {
        Write-Host "Installing git..."
        winget install Git.Git
    }

    if (!(Get-Command pwsh -errorAction SilentlyContinue))
    {
        Write-Host "Installing PowerShell..."
        winget install Microsoft.PowerShell
    }
}

if (!(Test-IsAdmin))
{
    Write-Error "Please re-run this script as an administrator."
    exit 1
}

Install-Dependencies

if (!(Test-Path -Path $DOTFILES_DIR))
{
    Write-Host "Cloning dotfiles repository..."
    git clone --quiet https://github.com/lexesj/windows-dotfiles.git "$DOTFILES_DIR"
} else
{
    Write-Host "Updating dotfiles repository..."
    git -C "$DOTFILES_DIR" pull --quiet
}
