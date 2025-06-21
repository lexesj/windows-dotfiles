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

function Install-Dependencies
{
	if (!(Get-Command git -ErrorAction SilentlyContinue))
	{
		Write-Host "Installing git..."
		winget install Git.Git
	}

	if (!(Get-Command gsudo -ErrorAction SilentlyContinue))
	{
		Write-Host "Installing gsudo..."
		winget install gerardog.gsudo
	}

	if (!(Get-Command pwsh -ErrorAction SilentlyContinue))
	{
		Write-Host "Installing PowerShell..."
		winget install Microsoft.PowerShell
	}
}

function Update-Path
{
	$MachinePath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
	$UserPath = [System.Environment]::GetEnvironmentVariable("Path","User")
	$ExtraPath = $env:PATH.Replace($MachinePath, "").Replace($UserPath, "").Replace(";;", ";")
	$env:Path = $ExtraPath + ";" + $MachinePath + ";" + $UserPath
}

if (!(Test-Path -Path $env:DOTFILES_PATH))
{
	Write-Host "Cloning dotfiles repository..."
	git clone --quiet --recurse-submodules https://github.com/lexesj/windows-dotfiles.git $env:DOTFILES_PATH
}

Install-Dependencies
Update-Path
pwsh -NoLogo -NoProfile -Command { Import-Module "$env:DOTFILES_PATH\bin\Dotfiles.psm1" -Force; Update-Dotfiles }
