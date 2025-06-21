if ([string]::IsNullOrWhiteSpace($env:DOTFILES_PATH))
{
    $env:DOTFILES_PATH = "$HOME\.dotfiles"
}
