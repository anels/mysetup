if ($null -ne (Get-Module -ListAvailable -Name Terminal-Icons).Name) {
  Import-Module -Name Terminal-Icons
}

# Modules
# Import-Module -Name PSReadLine
# Import-Module -Name PSFzf
Import-Module -Name posh-git
Import-Module -Name scoop-completion
# Import-Module -name z


if (($null -ne (Get-Module -ListAvailable -Name PSReadLine).Name) -And ($host.Name -eq 'ConsoleHost')) {
  Import-Module PSReadLine
  Set-PSReadLineOption -PredictionSource History
  $windowSize = (Get-Host).UI.RawUI.MaxWindowSize
  if ($windowSize.Width -ge 54 -and $windowSize.Height -ge 15) {
    Set-PSReadLineOption -PredictionViewStyle ListView
  }
  Set-PSReadLineOption -EditMode Windows
}

# $omhJsonFilePath = "$HOME\.pwsh\ohmyposhv3.json"
$omhJsonFilePath = "$env:POSH_THEMES_PATH\amro.omp.json"
# $omhJsonFilePath = "$env:POSH_THEMES_PATH\peru.omp.json"
# $omhJsonFilePath = "$env:POSH_THEMES_PATH\ys.omp.json"
# $omhJsonFilePath = "$env:POSH_THEMES_PATH\kali.omp.json"
# $omhJsonFilePath = "$env:POSH_THEMES_PATH\wopian.omp.json"

if (($null -ne (Get-Command oh-my-posh -ErrorAction:SilentlyContinue).Name) -And (Test-Path -Path $omhJsonFilePath -PathType Leaf)) {
  # oh-my-posh --init --shell pwsh --config $omhJsonFilePath | Invoke-Expression | Out-Null
  oh-my-posh init pwsh --config $omhJsonFilePath | Invoke-Expression
}

# alias
# Set-Alias -Name cmdhistory -Value (notepad++ (Get-PSReadlineOption).HistorySavePath)

Function Cleanup-GitBranch {
  if (-Not (git rev-parse --is-inside-work-tree)) {
    Write-Host "Not in a valid git repo. Please run this command inside a git repo."
    return
  }
  # do actual thing
  git branch | % { $_.Trim() } | ? { $_ -notmatch '^\*|(develop|main|master)$' } | % { git branch -D $_ }
  # see https://gitbetter.substack.com/p/how-to-clean-up-the-git-repo-and
  # git remote prune origin
  git repack
  git prune-packed
  git reflog expire --expire=1.month.ago
  git gc --aggressive
}
Set-Alias cugb Cleanup-GitBranch

Function Update-All {
  gsudo {
    scoop update *
    scoop cleanup *
    cup all -y
  }
}
Set-Alias upall Update-All
