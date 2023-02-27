if ($myProfileLoaded) {
  return
}

$start = (Get-Date)

Function Enable-Module ($moduleName) {
  if ($null -ne (Get-Module -ListAvailable -Name $moduleName).Name) {
    Import-Module -Name $moduleName
  }
}

# Modules
# Import-Module -Name PSFzf
Enable-Module Terminal-Icons
Enable-Module posh-git
Enable-Module posh-docker
Enable-Module scoop-completion
Enable-Module z

# gsudo
$GsudoModuleFilePath = "$Home\scoop\apps\gsudo\current\gsudoModule.psd1"
if (Test-Path $GsudoModuleFilePath -PathType Leaf) {
  Import-Module $GsudoModuleFilePath
}

if (($null -ne (Get-Module -ListAvailable -Name PSReadLine).Name) -And ($host.Name -eq 'ConsoleHost')) {
  Import-Module PSReadLine
  Set-PSReadLineOption -PredictionSource History
  $windowSize = (Get-Host).UI.RawUI.MaxWindowSize
  if ($windowSize.Width -ge 54 -and $windowSize.Height -ge 20) {
    Set-PSReadLineOption -PredictionViewStyle ListView
  }
  Set-PSReadLineOption -EditMode Windows
}

# Oh-my-posh themes
$myTheme = @(
  "bubblesline"
  "easy-term"
  "jandedobbeleer"
  "peru"
  "wopian"
  ###############
  "amro"
  "catppuccin_mocha"
  "catppuccin"
  "cobalt2"
  "dracula"
  "emodipt"
  "froczh"
  "gmay"
  "gruvbox"
  "half-life"
  "hotstick.minimal"
  "huvix"
  "json"
  "lambda"
  "larserikfinholt"
  "M365Princess"
  "marcduiker"
  "markbull"
  "material"
  "montys"
  "multiverse-neon"
  "pararussel"
  "powerline"
  "probua.minimal"
  "pure"
  "robbyrussell"
  "sorin"
  "space"
  "spaceship"
  "star"
  "stelbent-compact.minimal"
  "the-unnamed"
  "tokyonight_storm"
  "tonybaloney"
  "unicorn"
  "wholespace"
  "ys"
  "zash"
)

# Oh-my-posh themes
$myThemeForPS5 = @(
  "amro"
  "catppuccin_mocha"
  "darkblood"
  "half-life"
  "kali"
  "onehalf.minimal"
  "probua.minimal"
  "ys"
)

Function Set-OhMyPoshThemes {
  param (
    [string]$name
  )

  Write-Host "Applying theme '$name'..."

  $omhJsonFilePath = "$env:POSH_THEMES_PATH\$theme.omp.json"

  if (($null -ne (Get-Command oh-my-posh -ErrorAction:SilentlyContinue).Name) -And (Test-Path -Path $omhJsonFilePath -PathType Leaf)) {
    # oh-my-posh --init --shell pwsh --config $omhJsonFilePath | Invoke-Expression | Out-Null
    oh-my-posh init pwsh --config $omhJsonFilePath | Invoke-Expression
    return $true
  }
  return $false

}

if ( $PSVersionTable.PSVersion.Major -eq 5) {
  $theme = Get-Random -InputObject $myThemeForPS5
}
else {
  $theme = Get-Random -InputObject $myTheme
}

if (-Not (Set-OhMyPoshThemes $theme)) {
  Invoke-Expression (&starship init powershell)
}

if ((Get-Random -Minimum 0 -Maximum 1.0) -ge 0.1 -And $Host.UI.RawUI.WindowSize.Width -ge 120 -And $Host.UI.RawUI.WindowSize.Height -ge 32) {
  winfetch
}

Function Cleanup-GitBranch {
  if (-Not (git rev-parse --is-inside-work-tree)) {
    Write-Host "Not in a valid git repo. Please run this command inside a git repo."
    return
  }
  git checkout $($(git symbolic-ref refs/remotes/origin/HEAD) -replace "^refs/remotes/origin/", "")
  git pull
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

function Measure-Command2 ([ScriptBlock]$Expression, [int]$Samples = 1, [Switch]$Silent, [Switch]$Long) {
  <#
  .SYNOPSIS
    Runs the given script block and returns the execution duration.
    Discovered on StackOverflow. http://stackoverflow.com/questions/3513650/timing-a-commands-execution-in-powershell

  .EXAMPLE
    Measure-Command2 { ping -n 1 google.com }
  #>
  $timings = @()
  do {
    $sw = New-Object Diagnostics.Stopwatch
    if ($Silent) {
      $sw.Start()
      $null = & $Expression
      $sw.Stop()
      Write-Host "." -NoNewLine
    }
    else {
      $sw.Start()
      & $Expression
      $sw.Stop()
    }
    $timings += $sw.Elapsed

    $Samples--
  }
  while ($Samples -gt 0)

  Write-Host

  $stats = $timings | Measure-Object -Average -Minimum -Maximum -Property Ticks

  # Print the full time span if the $Long switch was given.
  if ($Long) {
    Write-Host "Avg: $((New-Object System.TimeSpan $stats.Average).ToString())"
    Write-Host "Min: $((New-Object System.TimeSpan $stats.Minimum).ToString())"
    Write-Host "Max: $((New-Object System.TimeSpan $stats.Maximum).ToString())"
  }
  else {
    # Otherwise just print the milliseconds which is easier to read.
    Write-Host "Avg: $((New-Object System.TimeSpan $stats.Average).TotalMilliseconds)ms"
    Write-Host "Min: $((New-Object System.TimeSpan $stats.Minimum).TotalMilliseconds)ms"
    Write-Host "Max: $((New-Object System.TimeSpan $stats.Maximum).TotalMilliseconds)ms"
  }
}
# e.g. time { 1..10 | ping -n 1 google.com } -Samples 10 -Silent
Set-Alias time Measure-Command2

Function Update-All {
  scoop update -q gsudo
  gsudo {
    Write-Host "`nUpdate scoop apps..." -ForegroundColor Green
    scoop update -ag
    scoop cleanup *
    scoop cache rm *
    # Write-Host "`nUpdate choco apps..." -ForegroundColor Green
    # cup all -y
    # Write-Host "`nUpdate pip packages..." -ForegroundColor Green
    # (pip list -lo --format json | ConvertFrom-Json).Name | % { pip install -qU $_ }
    Write-Host "`nUpdate tldr..." -ForegroundColor Green
    tldr -u
  }
}
Set-Alias upall Update-All

Function Open-PSHistory {
  vim -c "set ff=dos" "+set nowrap" "+normal G$" (Get-PSReadlineOption).HistorySavePath
  # notepad (Get-PSReadlineOption).HistorySavePath
}
Set-Alias ohis Open-PSHistory

Function Open-Hosts {
  # gsudo vi C:\Windows\System32\drivers\etc\hosts
  gsudo vim $env:windir\System32\drivers\etc\hosts
  # gsudo notepad $env:windir\System32\drivers\etc\hosts
}
Set-Alias ohos Open-Hosts

Function Get-EnvironmentVariables {
  Get-ChildItem env:* | sort-object name
}
Set-Alias printenv Get-EnvironmentVariables


Function Get-MyPublicIP {
  (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content | % { Set-Clipboard $_; Write-Output $_ }
}
Set-Alias wimi Get-MyPublicIP

function Restart-PowerShell {
  if ($host.Name -eq 'ConsoleHost') {
    clear
    $myProfileLoaded = $false
    .$profile
    # exit
  }
  else {
    Write-Warning 'Only usable while in the PowerShell console host'
  }
}
Set-Alias -Name 'reload' -Value 'Restart-PowerShell'

if ($null -ne (Get-Command gsudo -ErrorAction:SilentlyContinue).Name) {
  Set-Alias -Name 'sudo' -Value 'gsudo'
}

#########################################

$end = (Get-Date)

# Calculate elapsed time
Write-Host "Loaded $($MyInvocation.MyCommand.Path). Time: $($end - $start)"

$myProfileLoaded = $true

# Install-Module -Name WriteAscii -Scope CurrentUser -Force
# 'merry xmas!' | Write-Ascii -ForegroundColor Rainbow
