if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine

    Set-PSReadlineOption -EditMode vi
    Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

    Import-Module PSFzf
}