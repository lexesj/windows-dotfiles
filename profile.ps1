if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine

    Set-PSReadlineOption -EditMode vi
    Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

    Import-Module PSFzf

    Import-Module posh-git

    # Alias `cd` to change directory to home when no argument is passed.
    function ChangeDirectory {
        param(
            [parameter(Mandatory = $false)]
            $path
        )
        if ( $PSBoundParameters.ContainsKey('path') ) {
            Set-Location $path
        }
        else {
            Set-Location $home
        }
    }
    Remove-Item alias:\cd
    New-Alias cd ChangeDirectory
}