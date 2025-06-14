# windows-dotfiles

Stores my configs and setup for my windows developer environment.

## Usage

Run the following to run the `Update-Dotfiles.ps1` script. This will also add the `Update-Dotfiles` function to your PowerShell profile, allowing you to run `Update-Dotfiles` anywhere in PowerShell to execute the script. You must run this script as an administrator.

```pwsh
Invoke-Expression ((Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lexesj/windows-dotfiles/refs/heads/main/bin/Update-Dotfiles.ps1" -Method "GET").Content)
```

You may also need to set execution policy to allow running scripts. You can do this by running the following.

```pwsh
Set-ExecutionPolicy Unrestricted
```
