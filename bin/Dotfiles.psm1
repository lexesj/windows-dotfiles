if ([string]::IsNullOrWhiteSpace($env:DOTFILES_PATH))
{
    $env:DOTFILES_PATH = "$HOME\.dotfiles"
}

Import-Module "$env:DOTFILES_PATH\bin\Installers.psm1" -Force

enum Tag
{
    Winget
    Git
    PowerShell
    Vim
    Terminal
    PowerToys
    CliTools
    SshKey
}

function Test-IsSubmoduleAuthenticated
{
    return git -C "$env:DOTFILES_PATH\unix-dotfiles" remote -v | Select-String -Pattern "git@github.com" -Quiet
}

function Test-IsSudoEnabled
{
    return !(sudo --help | Select-String -Pattern "Sudo is disabled" -Quiet)
}

function Update-Dotfiles
{
    param
    (
        [Tag[]]$Tags = [Tag].GetEnumValues()
    )

    if(!(Test-IsSudoEnabled))
    {
        sudo --help
        return
    }

    if (!(Test-Path -Path $env:DOTFILES_PATH))
    {
        Write-Host "Cloning dotfiles repository..."
        git clone --quiet --recurse-submodules https://github.com/lexesj/windows-dotfiles.git $env:DOTFILES_PATH
    } else
    {
        Write-Host "Updating dotfiles repository..."
        git -C $env:DOTFILES_PATH pull --quiet
        git -C $env:DOTFILES_PATH submodule update --remote
        git -C $env:DOTFILES_PATH diff --quiet "$env:DOTFILES_PATH\unix-dotfiles"

        $HasChanges = !$?
        if (Test-IsSubmoduleAuthenticated -and $HasChanges)
        {
            Write-Host "Updating unix-dotfiles submodule..."
            git -C $env:DOTFILES_PATH add "$env:DOTFILES_PATH\unix-dotfiles"
            git -C $env:DOTFILES_PATH commit --quiet -m "Update unix-dotfiles submodule"
            git -C $env:DOTFILES_PATH push --quiet
        }
    }

    foreach ($Tag in $Tags)
    {
        & (Get-Command -Name "Install-$Tag")
    }
}
