if ($global:myProfileLoaded) { return }
$global:myProfileLoaded = $true

$profileLoadStart = Get-Date

# Helper function for module loading
Function Enable-Module ($moduleName) {
    if ($null -ne (Get-Module -ListAvailable -Name $moduleName).Name) {
        Import-Module -Name $moduleName
    }
}

# Lazy loading function
function Import-ModuleOnDemand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        [string]$Command
    )

    if ([string]::IsNullOrEmpty($Command)) {
        $Command = $ModuleName
    }

    if (!(Get-Command $Command -ErrorAction SilentlyContinue)) {
        Enable-Module $ModuleName
    }
}

# Create lazy-loading functions for modules
${function:Get-Icon} = { Import-ModuleOnDemand 'Terminal-Icons'; Get-Icon @args }
${function:Get-GitStatus} = { Import-ModuleOnDemand 'posh-git'; Get-GitStatus @args }
${function:Get-DockerCompletion} = { Import-ModuleOnDemand 'posh-docker'; Get-DockerCompletion @args }
${function:Get-ScoopCompletion} = { Import-ModuleOnDemand 'scoop-completion'; Get-ScoopCompletion @args }
${function:z} = { Import-ModuleOnDemand 'z' 'z'; z @args }

# Load gsudo only when needed
$GsudoModuleFilePath = "$Home\scoop\apps\gsudo\current\gsudoModule.psd1"
if (Test-Path $GsudoModuleFilePath -PathType Leaf) {
    ${function:gsudo} = { Import-Module $GsudoModuleFilePath; gsudo @args }
}

# Optimize PSReadLine loading
if ($host.Name -eq 'ConsoleHost' -and (Get-Module -ListAvailable -Name PSReadLine)) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History -EditMode Windows
    if ((Get-Host).UI.RawUI.MaxWindowSize.Width -ge 54) {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
}

# Oh-my-posh themes - moved to variables for faster access
$myTheme = @(
    "avit", "bubblesline", "easy-term", "jandedobbeleer", "peru", "wopian",
    "amro", "catppuccin_mocha", "catppuccin", "cobalt2", "dracula", "emodipt",
    "froczh", "gmay", "gruvbox", "half-life", "hotstick.minimal", "huvix",
    "json", "lambda", "larserikfinholt", "M365Princess", "marcduiker", "material",
    "montys", "multiverse-neon", "illusi0n", "negligible", "pararussel", "powerline",
    "probua.minimal", "pure", "robbyrussell", "sorin", "space", "spaceship",
    "star", "stelbent-compact.minimal", "the-unnamed", "tokyonight_storm",
    "tonybaloney", "unicorn", "wholespace", "ys", "zash"
)

$myThemeForPS5 = @(
    "darkblood", "half-life", "kali", "material", "onehalf.minimal",
    "probua.minimal", "pure", "xtoy", "ys"
)

Function Set-OhMyPoshThemes {
    param ([string]$name)

    $omhJsonFilePath = "$env:POSH_THEMES_PATH\$name.omp.json"
    if (($null -ne (Get-Command oh-my-posh -ErrorAction:SilentlyContinue)) -And (Test-Path -Path $omhJsonFilePath -PathType Leaf)) {
        oh-my-posh init pwsh --config $omhJsonFilePath | Invoke-Expression
        return $true
    }
    return $false
}

# Set theme in background job
$null = Start-Job -ScriptBlock {
    $theme = if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-Random -InputObject $myThemeForPS5
    } else {
        Get-Random -InputObject $myTheme
    }

    if (-Not (Set-OhMyPoshThemes $theme) -and (Get-Command "starship" -ErrorAction SilentlyContinue)) {
        Invoke-Expression (&starship init powershell)
    }
}

# Move fastfetch to separate function
function Show-SystemInfo {
    if ((Get-Random -Minimum 0 -Maximum 1.0) -ge 0.1 -And
        $Host.UI.RawUI.WindowSize.Width -ge 120 -And
        $Host.UI.RawUI.WindowSize.Height -ge 32) {
        fastfetch
    }
}

# Keep existing functions but optimize their loading
# ... [keeping your existing functions unchanged] ...

# Aliases
if ($null -ne (Get-Command gsudo -ErrorAction:SilentlyContinue).Name) {
    Set-Alias -Name 'sudo' -Value 'gsudo'
}

if ($null -ne (Get-Command kubectl -ErrorAction:SilentlyContinue).Name) {
    Set-Alias -Name 'k' -Value 'kubectl'
}

Set-Alias cugb Cleanup-GitBranch
Set-Alias ccppr Create-CherryPickPR
Set-Alias time Measure-Command2
Set-Alias upall Update-All
Set-Alias ohis Open-PSHistory
Set-Alias ohos Open-Hosts
Set-Alias printenv Get-EnvironmentVariables
Set-Alias chst CheckStatus
Set-Alias wimi Get-MyPublicIP
Set-Alias -Name 'reload' -Value 'Restart-PowerShell'



Write-Host "Profile loaded in $((Get-Date) - $profileLoadStart)"

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
  "avit"
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
  "material"
  "montys"
  "multiverse-neon"
  "illusi0n"
  "negligible"
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
  #   "markbull"
)

# Oh-my-posh themes
$myThemeForPS5 = @(
  "darkblood"
  "half-life"
  "kali"
  "material"
  "onehalf.minimal"
  "probua.minimal"
  "pure"
  "xtoy"
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

if (-Not (Set-OhMyPoshThemes $theme) -and (Get-Command "starship" -ErrorAction SilentlyContinue)) {
  Invoke-Expression (&starship init powershell)
}

if ((Get-Random -Minimum 0 -Maximum 1.0) -ge 0.1 -And $Host.UI.RawUI.WindowSize.Width -ge 120 -And $Host.UI.RawUI.WindowSize.Height -ge 32) {
  fastfetch
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

function Create-CherryPickPR {
    param(
        [Parameter(Mandatory=$true)][string]$commitToCherryPick,
        [Parameter(Mandatory=$true)][string]$destinationBranch
    )

    try {
        # Get new commits
        git fetch --all

        # Get current branch name
        $currentBranch = git rev-parse --abbrev-ref HEAD
        Write-Output "You are currently on branch $currentBranch"

        # Take only first 7 characters of commit hash
        $commitToCherryPick = $commitToCherryPick.substring(0,7)

        # Get commit message
        $commitMessage = (git log --format=%B -n 1 $commitToCherryPick).Split("`n")[0]

        # Remove all special characters from $destinationBranch except "_", and ".".
        $destinationBranchName = $destinationBranch -replace '[^a-zA-Z0-9._]', ''

        # Generate new branch name based on commit hash and destinationBranch
        $newBranchName = "cp/$commitToCherryPick-to-$destinationBranchName"

        # Create a Pull Request against the destination branch using GitHub CLI 'gh'.
        $prTitle = "Cherry-Pick: $commitMessage -> $destinationBranch"
        Write-Output "Title: '$prTitle'"

        # Cherry-pick commit to new branch
        git checkout $destinationBranch
        git pull
        git checkout -b $newBranchName
        git cherry-pick -x $commitToCherryPick

        # Check if the cherry-pick command was successful
        if ($LASTEXITCODE -ne 0) {
            Write-Output "Conflict occurred during cherry-pick. Resolve the conflict and then commit the cherry-pick changes."
            Write-Output "----------------------------------------------------------------------"
            Write-Output "    git cherry-pick --continue"
            Write-Output "----------------------------------------------------------------------"
            Write-Output "Then, you can push the branch to github and create PR manually by:"
            Write-Output "----------------------------------------------------------------------"
            Write-Output "    git push origin $newBranchName --force && gh pr create --base $destinationBranch --title '$prTitle' --fill"
            Write-Output "----------------------------------------------------------------------"
            return
        }

        # Push the new branch
        git push origin $newBranchName --force

        Write-Output "Create PR by 'gh pr create --base $destinationBranch --title $prTitle --fill'"
        gh pr create --base $destinationBranch --title $prTitle --fill
        # gh pr create --base $destinationBranch' --title '$prTitle' --body 'Cherry-pick from $commitToCherryPick: $commitMessage'

        # Switch back to the initial branch
        git checkout $currentBranch
    }
    catch {
        Write-Output $_.Exception.Message
    }
}
# CreateCherryPickPR -commitToCherryPick "574c6c5ae5ae198e24fd9de38f52f48c38ad5eeb" -destinationBranch "release/v2022.10.8"
Set-Alias ccppr Create-CherryPickPR
# ccppr 574c6c5 release/v2022.10.8



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


function CheckStatus($url) {
    $prev200Time = Get-Date

    while ($true) {
        $curTime = Get-Date
        try {
            Write-Host "$curTime - " -NoNewline
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                $timeSpan = $curTime - $prev200Time
                # Write-Host "$curTime - Status code: $($response.StatusCode). Time since last 200 code: $($timeSpan.TotalSeconds) seconds." -ForegroundColor Green
                Write-Host "Status code: $($response.StatusCode)" -NoNewline -ForegroundColor Green
                Write-Host " -- Time since last 200 code: $($timeSpan.TotalSeconds) seconds."
                $prev200Time = $curTime
            } else {
                Write-Host "Status code: $($response.StatusCode)"
            }
        } catch {
            if ($_.Exception.Response -is [System.Net.WebResponse]) {
                Write-Host "Status code: $($_.Exception.Response.StatusCode.value__) (from exception)" -ForegroundColor Red
            } else {
                Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }

        Start-Sleep -Seconds 5 # delay between requests
    }
}

#Simply call the function with url:
# CheckStatus -url "https://insights-looker-alpha.gov.uipath-dev.com/alive"
Set-Alias chst CheckStatus


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

if ($null -ne (Get-Command kubectl -ErrorAction:SilentlyContinue).Name) {
  Set-Alias -Name 'k' -Value 'kubectl'
}

#########################################

$end = (Get-Date)

# Calculate elapsed time
# Write-Host "Loaded $($MyInvocation.MyCommand.Path). Time: $($end - $start)"

$myProfileLoaded = $true

# Install-Module -Name WriteAscii -Scope CurrentUser -Force
# 'merry xmas!' | Write-Ascii -ForegroundColor Rainbow