
# Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1'

if ($null -ne (Get-Module -ListAvailable -Name Terminal-Icons).Name) {
  Import-Module -Name Terminal-Icons
}

if (($null -ne (Get-Module -ListAvailable -Name PSReadLine).Name) -And ($host.Name -eq 'ConsoleHost'))
{
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
}

$omhJsonFilePath = "$HOME\.pwsh\ohmyposhv3.json"

if (($null -ne (Get-Command oh-my-posh).Name) -And (Test-Path -Path $omhJsonFilePath -PathType Leaf)) {
  oh-my-posh --init --shell pwsh --config $omhJsonFilePath | Invoke-Expression | Out-Null
}

# alias
# Set-Alias -Name history -Value code (Get-PSReadlineOption).HistorySavePath
