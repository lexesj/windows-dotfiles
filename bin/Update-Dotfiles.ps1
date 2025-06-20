<#
.SYNOPSIS
    Script that downloads programs and configures dotfiles for a development environment.

.PARAMETER Tags
    Used to filter the installation of dotfiles and programs. If not specified, all dotfiles and programs are installed.
#>
param
(
    [string[]]$Tags = @("Winget", "Git", "PowerShell", "Vim", "Terminal", "PowerToys", "CliTools", "SshKey")
)

function Install-Dependencies
{
    if (!(Get-Command git -ErrorAction SilentlyContinue))
    {
        Write-Host "Installing git..."
        winget install Git.Git
    }

    if (!(Get-Command pwsh -ErrorAction SilentlyContinue))
    {
        Write-Host "Installing PowerShell..."
        winget install Microsoft.PowerShell
    }

    if (!(Get-Command wt -ErrorAction SilentlyContinue))
    {
        Write-Host "Installing Windows Terminal..."
        winget install Microsoft.WindowsTerminal
    }
}

Install-Dependencies

$DOTFILES_DIR = "$HOME\.windows-dotfiles"

if (!(Test-Path -Path $DOTFILES_DIR))
{
    Write-Host "Cloning dotfiles repository..."
    git clone --quiet --recurse-submodules https://github.com/lexesj/windows-dotfiles.git $DOTFILES_DIR
}

function Test-IsAdmin
{
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal $Identity
    $IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return $isAdmin
}

if (!(Test-IsAdmin))
{
    Write-Host "Running script as administrator..."
    Start-Process wt -Verb runAs -ArgumentList "-- pwsh -NoExit -Command `". $DOTFILES_DIR\bin\Update-Dotfiles.ps1 -Tags $($Tags -join ",")`""
    return
}

function Test-IsAuthenticated
{
    return git -C "$DOTFILES_DIR\unix-dotfiles" remote -v | Select-String -Pattern "git@github.com" -Quiet
}

if (Test-Path -Path $DOTFILES_DIR)
{
    Write-Host "Updating dotfiles repository..."
    git -C $DOTFILES_DIR pull --quiet
    git -C $DOTFILES_DIR submodule update --remote
    git -C $DOTFILES_DIR diff --quiet "$DOTFILES_DIR\unix-dotfiles"

    $HasChanges = !$?
    if (Test-IsAuthenticated -and $HasChanges)
    {
        Write-Host "Updating unix-dotfiles submodule..."
        git -C $DOTFILES_DIR add "$DOTFILES_DIR\unix-dotfiles"
        git -C $DOTFILES_DIR commit --quiet -m "Update unix-dotfiles submodule"
        git -C $DOTFILES_DIR push --quiet
    }
}

Import-Module "$DOTFILES_DIR\bin\Installers.psm1"

foreach ($Tag in $Tags)
{
    & (Get-Command -Name "Install-$Tag")
}
