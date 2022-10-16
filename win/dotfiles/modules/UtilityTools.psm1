# UtilityTools Module - Contains utility functions for PowerShell

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

function Update-All {
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

function Open-PSHistory {
  vim -c "set ff=dos" "+set nowrap" "+normal G$" (Get-PSReadlineOption).HistorySavePath
  # notepad (Get-PSReadlineOption).HistorySavePath
}

function Open-Hosts {
  # gsudo vi C:\Windows\System32\drivers\etc\hosts
  gsudo vim $env:windir\System32\drivers\etc\hosts
  # gsudo notepad $env:windir\System32\drivers\etc\hosts
}

function Get-EnvironmentVariables {
  Get-ChildItem env:* | sort-object name
}

function Test-WebsiteStatus {
  <#
  .SYNOPSIS
    Continuously monitors a website's HTTP status code and tracks uptime.

  .DESCRIPTION
    Polls the specified URL every 5 seconds and displays the HTTP status code.
    When the status is 200 (OK), it shows the time elapsed since the last successful check.
    The function runs indefinitely until manually stopped (Ctrl+C).

  .PARAMETER Url
    The URL to monitor (e.g., "https://example.com").

  .EXAMPLE
    Test-WebsiteStatus -Url "https://google.com"
    Monitors Google's homepage and displays status updates every 5 seconds.

  .EXAMPLE
    Test-WebsiteStatus "https://api.example.com/health"
    Monitors an API health endpoint.

  .NOTES
    Use Ctrl+C to stop monitoring.
    This function is aliased as 'CheckStatus' for backward compatibility.
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Url
  )

  $prev200Time = Get-Date

  while ($true) {
    $curTime = Get-Date
    try {
      Write-Host "$curTime - " -NoNewline
      $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
      if ($response.StatusCode -eq 200) {
        $timeSpan = $curTime - $prev200Time
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

# Backward compatibility alias
Set-Alias -Name CheckStatus -Value Test-WebsiteStatus

function Get-MyPublicIP {
  (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content | % { Set-Clipboard $_; Write-Output $_ }
}

function Invoke-CleanScript {
  <#
  .SYNOPSIS
    Runs a PowerShell script with customizable execution parameters.

  .DESCRIPTION
    Executes a PowerShell script or scriptblock with options like -NoLogo, -NoProfile, -NonInteractive, etc.
    Useful for running scripts in a clean environment without loading profiles or displaying banners.

  .PARAMETER ScriptPath
    Path to the PowerShell script file to execute.

  .PARAMETER ScriptBlock
    A scriptblock to execute instead of a script file.

  .PARAMETER NoLogo
    Hides the copyright banner at startup.

  .PARAMETER NoProfile
    Does not load the PowerShell profile.

  .PARAMETER NonInteractive
    Does not present an interactive prompt to the user.

  .PARAMETER ExecutionPolicy
    Sets the execution policy for this script execution.

  .PARAMETER WindowStyle
    Sets the window style for the PowerShell process (Normal, Minimized, Maximized, Hidden).

  .PARAMETER ArgumentList
    Additional arguments to pass to the script.

  .EXAMPLE
    Invoke-CleanScript -ScriptPath "C:\Scripts\test.ps1" -NoLogo -NoProfile

  .EXAMPLE
    Invoke-CleanScript -ScriptBlock { Write-Host "Hello World" } -NoLogo -NoProfile -WindowStyle Hidden
  #>
  [CmdletBinding(DefaultParameterSetName = "ScriptPath")]
  param (
    [Parameter(ParameterSetName = "ScriptPath", Mandatory = $true, Position = 0)]
    [string]$ScriptPath,

    [Parameter(ParameterSetName = "ScriptBlock", Mandatory = $true)]
    [scriptblock]$ScriptBlock,

    [Parameter()]
    [switch]$NoLogo,

    [Parameter()]
    [switch]$NoProfile,

    [Parameter()]
    [switch]$NonInteractive,

    [Parameter()]
    [ValidateSet("Bypass", "Unrestricted", "RemoteSigned", "AllSigned", "Restricted")]
    [string]$ExecutionPolicy = "RemoteSigned",

    [Parameter()]
    [ValidateSet("Normal", "Minimized", "Maximized", "Hidden")]
    [string]$WindowStyle = "Normal",

    [Parameter()]
    [string[]]$ArgumentList
  )

  $pwshArgs = @()

  if ($NoLogo) {
    $pwshArgs += "-NoLogo"
  }

  if ($NoProfile) {
    $pwshArgs += "-NoProfile"
  }

  if ($NonInteractive) {
    $pwshArgs += "-NonInteractive"
  }

  $pwshArgs += "-ExecutionPolicy"
  $pwshArgs += $ExecutionPolicy

  if ($PSCmdlet.ParameterSetName -eq "ScriptPath") {
    $pwshArgs += "-File"
    $pwshArgs += $ScriptPath
    if ($ArgumentList) {
      $pwshArgs += $ArgumentList
    }
  }
  else {
    $tempScriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
    $ScriptBlock.ToString() | Out-File -FilePath $tempScriptPath -Encoding utf8
    $pwshArgs += "-File"
    $pwshArgs += $tempScriptPath
    if ($ArgumentList) {
      $pwshArgs += $ArgumentList
    }
  }

  $startProcessParams = @{
    FilePath = "pwsh"
    ArgumentList = $pwshArgs
    WindowStyle = $WindowStyle
    PassThru = $true
  }

  $process = Start-Process @startProcessParams
  $process.EnableRaisingEvents = $true

  if ($PSCmdlet.ParameterSetName -eq "ScriptBlock") {
    # Register the script for cleanup after it's done
    Register-ObjectEvent -InputObject $process -EventName Exited -MessageData $tempScriptPath -Action {
      $path = $Event.MessageData
      if (Test-Path $path) {
        Remove-Item -Path $path -Force
      }
      Unregister-Event -SourceIdentifier $eventSubscriber.Name
    } | Out-Null
  }

  return $process
}

function Restart-PowerShell {
  <#
  .SYNOPSIS
    Restarts the current PowerShell session by reloading the profile.

  .DESCRIPTION
    Clears the console, resets the myProfileLoaded variable to allow profile reloading,
    and then dots the profile script to reload it in the current session.

  .EXAMPLE
    Restart-PowerShell

  .NOTES
    This function is aliased as 'reload' in the profile.
  #>
  if ($host.Name -eq 'ConsoleHost') {
    clear
    $global:myProfileLoaded = $false
    .$profile
  }
  else {
    Write-Warning 'Only usable while in the PowerShell console host'
  }
}

function Test-Admin {
  <#
  .SYNOPSIS
    Checks if the current session is running with administrator privileges.

  .EXAMPLE
    Test-Admin

  .OUTPUTS
    Boolean. $true if running as admin, $false otherwise.
  #>
  $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ScriptDirectory {
  <#
  .SYNOPSIS
    Gets the directory path of the currently executing script.

  .DESCRIPTION
    Returns the directory containing the script that called this function.
    If run directly in the console, it might return $null or the current working directory
    depending on the PowerShell version and context ($PSScriptRoot is preferred).

  .EXAMPLE
    $scriptDir = Get-ScriptDirectory
    Write-Host "Script is running from: $scriptDir"

  .NOTES
    Relies on the automatic variable $PSScriptRoot.
  #>
  return $PSScriptRoot
}

function Show-Path {
  <#
  .SYNOPSIS
    Displays the PATH environment variable directories, one per line.

  .EXAMPLE
    Show-Path
  #>
  $env:Path -split ';' | Where-Object { $_ } | ForEach-Object { Write-Host $_ }
}

function Test-CommandInstalled {
  <#
  .SYNOPSIS
    检查指定的命令是否在系统中可用。

  .DESCRIPTION
    尝试通过 Get-Command 获取指定命令，判断该命令是否已安装并可在当前会话中使用。
    支持检查可执行文件、PowerShell cmdlet、函数、别名等。

  .PARAMETER Command
    要检查的命令名称（例如：'git'、'scoop'、'code'）。

  .EXAMPLE
    Test-CommandInstalled -Command 'git'
    # 返回 $true 如果 git 已安装，否则返回 $false

  .EXAMPLE
    if (Test-CommandInstalled 'python') {
      Write-Host "Python is installed"
    }

  .OUTPUTS
    Boolean. $true 如果命令存在，$false 如果命令不存在。
  #>
  [CmdletBinding()]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Command
  )

  try {
    Write-Verbose "Checking if command '$Command' is available..."
    $null = Get-Command -Name $Command -ErrorAction Stop
    Write-Verbose "Command '$Command' is installed."
    return $true
  }
  catch {
    Write-Verbose "Command '$Command' is NOT installed."
    return $false
  }
}

function Install-IfMissing {
  <#
  .SYNOPSIS
    检查命令是否存在，如果不存在则执行指定的安装脚本块。

  .DESCRIPTION
    首先使用 Test-CommandInstalled 检查命令是否可用。
    如果命令不存在，执行提供的 InstallBlock 脚本块进行安装。
    支持 -WhatIf 和 -Verbose 参数，提供详细的安装流程反馈。

  .PARAMETER Command
    要检查的命令名称。

  .PARAMETER InstallBlock
    当命令不存在时要执行的脚本块（例如：{ scoop install git }）。

  .PARAMETER Description
    可选的描述信息，用于日志输出（例如："Git version control"）。

  .EXAMPLE
    Install-IfMissing -Command 'git' -InstallBlock { scoop install git } -Description "Git version control"

  .EXAMPLE
    Install-IfMissing -Command 'code' -InstallBlock {
      scoop bucket add extras
      scoop install vscode
    } -WhatIf

  .OUTPUTS
    PSCustomObject. 包含命令名称、安装状态（AlreadyInstalled/Installed/Failed）和可选的错误信息。
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory = $true)]
    [string]$Command,

    [Parameter(Mandatory = $true)]
    [scriptblock]$InstallBlock,

    [Parameter()]
    [string]$Description = ""
  )

  $result = [PSCustomObject]@{
    Command = $Command
    Status  = ""
    Error   = $null
  }

  if (Test-CommandInstalled -Command $Command) {
    $result.Status = "AlreadyInstalled"
    Write-Verbose "$Command is already installed. Skipping."
    return $result
  }

  $displayName = if ($Description) { "$Command ($Description)" } else { $Command }

  if ($PSCmdlet.ShouldProcess($displayName, "Install")) {
    try {
      Write-Host "Installing $displayName..." -ForegroundColor Cyan
      & $InstallBlock

      if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
        throw "Installation command exited with code $LASTEXITCODE"
      }

      # 验证安装是否成功
      if (Test-CommandInstalled -Command $Command) {
        $result.Status = "Installed"
        Write-Host "$displayName installed successfully." -ForegroundColor Green
      }
      else {
        throw "Command '$Command' still not found after installation attempt."
      }
    }
    catch {
      $result.Status = "Failed"
      $result.Error = $_.Exception.Message
      Write-Error "Failed to install $displayName. Error: $($_.Exception.Message)"
    }
  }
  else {
    $result.Status = "Skipped"
    Write-Verbose "Installation of $displayName was skipped due to -WhatIf."
  }

  return $result
}

function Install-PackageBatch {
  <#
  .SYNOPSIS
    批量安装多个包，支持 scoop、pip 和 VS Code 扩展。

  .DESCRIPTION
    根据指定的包管理器类型（scoop/pip/vscode）批量安装包列表。
    自动跳过已安装的包，提供详细的安装进度和结果摘要。
    支持 -WhatIf 和 -Verbose 参数。

  .PARAMETER PackageManager
    包管理器类型，可选值：'scoop'、'pip'、'vscode'。

  .PARAMETER Packages
    要安装的包名称数组。

  .PARAMETER Force
    强制重新安装已存在的包（对 scoop 使用 --force，对 pip 使用 --force-reinstall）。

  .EXAMPLE
    Install-PackageBatch -PackageManager 'scoop' -Packages @('git', 'nodejs', 'python')

  .EXAMPLE
    Install-PackageBatch -PackageManager 'pip' -Packages @('requests', 'pandas', 'numpy') -Verbose

  .EXAMPLE
    Install-PackageBatch -PackageManager 'vscode' -Packages @('ms-python.python', 'esbenp.prettier-vscode')

  .EXAMPLE
    Install-PackageBatch -PackageManager 'scoop' -Packages @('git') -Force -WhatIf

  .OUTPUTS
    PSCustomObject. 包含安装摘要：总数、成功数、失败数、跳过数和详细结果列表。
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('scoop', 'pip', 'vscode')]
    [string]$PackageManager,

    [Parameter(Mandatory = $true)]
    [string[]]$Packages,

    [Parameter()]
    [switch]$Force
  )

  # 验证包管理器是否可用
  $managerCommand = switch ($PackageManager) {
    'scoop' { 'scoop' }
    'pip' { 'pip' }
    'vscode' { 'code' }
  }

  if (-not (Test-CommandInstalled -Command $managerCommand)) {
    throw "$PackageManager is not installed. Please install it first."
  }

  $results = @()
  $summary = [PSCustomObject]@{
    Total      = $Packages.Count
    Installed  = 0
    Failed     = 0
    Skipped    = 0
    Results    = @()
  }

  Write-Host "`nInstalling $($Packages.Count) packages using $PackageManager..." -ForegroundColor Cyan

  foreach ($package in $Packages) {
    $result = [PSCustomObject]@{
      Package = $package
      Status  = ""
      Error   = $null
    }

    # 检查包是否已安装（仅当不使用 -Force 时）
    $isInstalled = $false
    if (-not $Force) {
      switch ($PackageManager) {
        'scoop' {
          $scoopList = scoop list $package 2>$null
          $isInstalled = $scoopList -match $package
        }
        'pip' {
          $pipList = pip list --format=freeze 2>$null | Select-String "^$package=="
          $isInstalled = $null -ne $pipList
        }
        'vscode' {
          $codeList = code --list-extensions 2>$null | Select-String "^$package$"
          $isInstalled = $null -ne $codeList
        }
      }
    }

    if ($isInstalled) {
      $result.Status = "AlreadyInstalled"
      $summary.Skipped++
      Write-Verbose "$package is already installed. Skipping."
    }
    elseif ($PSCmdlet.ShouldProcess($package, "Install using $PackageManager")) {
      try {
        Write-Host "  Installing $package..." -NoNewline

        switch ($PackageManager) {
          'scoop' {
            $cmd = if ($Force) { "scoop install $package --force" } else { "scoop install $package" }
            Invoke-Expression $cmd 2>&1 | Out-Null
          }
          'pip' {
            $cmd = if ($Force) { "pip install --force-reinstall $package" } else { "pip install $package" }
            Invoke-Expression $cmd 2>&1 | Out-Null
          }
          'vscode' {
            $cmd = if ($Force) { "code --install-extension $package --force" } else { "code --install-extension $package" }
            Invoke-Expression $cmd 2>&1 | Out-Null
          }
        }

        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
          $result.Status = "Installed"
          $summary.Installed++
          Write-Host " OK" -ForegroundColor Green
        }
        else {
          throw "Installation command exited with code $LASTEXITCODE"
        }
      }
      catch {
        $result.Status = "Failed"
        $result.Error = $_.Exception.Message
        $summary.Failed++
        Write-Host " FAILED" -ForegroundColor Red
        Write-Verbose "Error: $($_.Exception.Message)"
      }
    }
    else {
      $result.Status = "WhatIf"
      $summary.Skipped++
    }

    $results += $result
  }

  $summary.Results = $results

  # 输出摘要
  Write-Host "`n=== Installation Summary ===" -ForegroundColor Cyan
  Write-Host "Total: $($summary.Total)" -ForegroundColor White
  Write-Host "Installed: $($summary.Installed)" -ForegroundColor Green
  Write-Host "Failed: $($summary.Failed)" -ForegroundColor Red
  Write-Host "Skipped: $($summary.Skipped)" -ForegroundColor Yellow

  return $summary
}

# Make sure to explicitly export the functions so they're available when imported
Export-ModuleMember -Function Measure-Command2, Update-All, Open-PSHistory, Open-Hosts, Get-EnvironmentVariables, Test-WebsiteStatus, Get-MyPublicIP, Invoke-CleanScript, Restart-PowerShell, Test-Admin, Get-ScriptDirectory, Show-Path, Test-CommandInstalled, Install-IfMissing, Install-PackageBatch
Export-ModuleMember -Alias CheckStatus
