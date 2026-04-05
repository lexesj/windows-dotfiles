Import-Module "$PSScriptRoot\DefaultVariables.psm1"

enum Tag
{
    Winget
    Git
    PowerShell
    Terminal
    PowerToys
    CliTools
    SshKey
}

function Update-Dotfiles
{
    param
    (
        [Tag[]]$Tags = [Tag].GetEnumValues()
    )

    Import-Module "$env:DOTFILES_PATH\bin\Installers.psm1" -Force

    gsudo cache on

    foreach ($Tag in $Tags)
    {
        & (Get-Command -Name "Install-$Tag")
    }

    gsudo cache off
}
