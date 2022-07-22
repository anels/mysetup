
# Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1'

if ($null -ne (Get-Module -ListAvailable -Name Terminal-Icons).Name) {
  Import-Module -Name Terminal-Icons
}

if (($null -ne (Get-Module -ListAvailable -Name PSReadLine).Name) -And ($host.Name -eq 'ConsoleHost')) {
  Import-Module PSReadLine
  Set-PSReadLineOption -PredictionSource History
  $windowSize = (Get-Host).UI.RawUI.MaxWindowSize
  if ($windowSize.Width -ge 54 -and $windowSize.Height -ge 15) {
    Set-PSReadLineOption -PredictionViewStyle ListView
  }
  Set-PSReadLineOption -EditMode Windows
}

#$omhJsonFilePath = "$HOME\.pwsh\ohmyposhv3.json"
$omhJsonFilePath = "$HOME\AppData\Local\Programs\oh-my-posh\themes\amro.omp.json"
#$omhJsonFilePath = "$HOME\AppData\Local\Programs\oh-my-posh\themes\peru.omp.json"
#$omhJsonFilePath = "$HOME\AppData\Local\Programs\oh-my-posh\themes\ys.omp.json"

if (($null -ne (Get-Command oh-my-posh).Name) -And (Test-Path -Path $omhJsonFilePath -PathType Leaf)) {
  # oh-my-posh --init --shell pwsh --config $omhJsonFilePath | Invoke-Expression | Out-Null
  oh-my-posh init pwsh --config $omhJsonFilePath | Invoke-Expression
}

# alias
# Set-Alias -Name history -Value code (Get-PSReadlineOption).HistorySavePath
