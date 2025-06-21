<#
.SYNOPSIS
    Script that installs the windows dotfiles repository and invokes the Update-Dotfiles method.

.PARAMETER DotfilesPath
    Used to specify the path where the dotfiles repository will be installed. Default is "$HOME\.windows-dotfiles".
#>
param
(
	[string]$DotfilesPath = "$HOME\.dotfiles"
)

$env:DOTFILES_PATH = $DotfilesPath

if (!(Get-Command git -ErrorAction SilentlyContinue))
{
	Write-Host "Installing git..."
	winget install Git.Git
}

if (!(Test-Path -Path $env:DOTFILES_PATH))
{
	Write-Host "Cloning dotfiles repository..."
	git clone --quiet --recurse-submodules https://github.com/lexesj/windows-dotfiles.git $env:DOTFILES_PATH
}

Import-Module "$env:DOTFILES_PATH\bin\Dotfiles.psm1" -Force

Update-Dotfiles
