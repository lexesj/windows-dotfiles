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
		[string]$ProgramName,
		[bool]$Update = $true
	)

	if ($InstalledPrograms -notmatch $ProgramName)
	{
		Write-Host "Installing $ProgramName..."
		winget install $ProgramName
	} elseif ($Update)
	{
		Write-Host "Updating $ProgramName..."
		winget upgrade $ProgramName
	}
}

function Install-Git
{
	Install-Program Git.Git
	New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$DOTFILES_DIR\unix-dotfiles\roles\git\files\.gitconfig" -Force
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
	foreach ($Program in @("junegunn.fzf", "JesseDuffield.lazygit", "Schniz.fnm", "BurntSushi.ripgrep.MSVC", "sharkdp.fd", "ajeetdsouza.zoxide"))
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
	New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json" -Target "$DOTFILES_DIR\winget\settings.json" -Force
	winget update winget
}
