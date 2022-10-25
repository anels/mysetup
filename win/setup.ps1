[bool]$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
  Write-Host "Please run this script in non-admin"
  exit 0
}

# if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Function Check-Command($cmdname) {
  return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Function Write-Info($msg) {
  Write-Host ""
  Write-Host "$msg" -ForegroundColor Green
  Write-Host "------------------------------------" -ForegroundColor Green
}

Function Sync-EnvVariables() {
  $Env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Function New-SoftLink {
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Source,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Target
  )

  # remove target file if exists
  try {
    if (Test-Path $Target) {
      gsudo Remove-Item $Target
    }

    gsudo New-Item -Path $Target -ItemType SymbolicLink -Value $Source -Force | Out-Null
    Write-Host "Created Soft link: $Target -> $Source"
  }
  catch {
    Write-Host -ForegroundColor Red "Something went wrong..."
    Write-Host $_
  }
}

Function Enable-RemoteDesktop() {
  Write-Info "Enable Remote Desktop..."
  gsudo {
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
  }
}

Function Disable-ACPowerSleep() {
  Write-Info "Disable Sleep on AC Power..."
  Powercfg /Change monitor-timeout-ac 20
  Powercfg /Change standby-timeout-ac 0
}

Function Install-Choco-Apps() {
  if (-Not (Check-Command -cmdname 'choco')) {
    Write-Info "Installing Chocolate for Windows..."
    gsudo { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) }
    Sync-EnvVariables
  }

  gsudo . $PSScriptRoot\apps\chocolatey.ps1
}

Function Install-Scoop-Apps() {
  if (-Not (Check-Command -cmdname 'scoop')) {
    Write-Info "Installing Scoop for Windows..."
    # Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    irm get.scoop.sh | iex
    scoop install aria2
    scoop config show_update_log $false
    scoop config cat_style auto
    scoop config aria2-enabled true
    scoop config aria2-split 32
    scoop config aria2-max-connection-per-server 16
    scoop config aria2-min-split-size 1M
    scoop config aria2-warning-enabled false
    scoop config aria2-options -q
    scoop install git
    scoop install gsudo
    Sync-EnvVariables
  }

  . $PSScriptRoot\apps\scoop.ps1
}


$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"

$ScriptVersion = "1.0"
$CurrentTimestamp = $(get-date -f yyyyMMddhhmmss)
$sLogName = "mysetup_$CurrentTimestamp.log"
$sLogFile = Join-Path -Path $PSScriptRoot -ChildPath $sLogName

Start-Transcript -path $sLogFile


Write-Info "My Setup $ScriptVersion"

# -----------------------------------------------------------------------------
# Start App installation
# -----------------------------------------------------------------------------
Install-Scoop-Apps

gsudo config LogLevel "Error" | Out-Null
gsudo cache on

Install-Choco-Apps

. $PSScriptRoot\apps\pip.ps1

if (Check-Command -cmdname 'code') {
  Write-Info "Setting up VS Code..."
  . $PSScriptRoot\vscode\vscode.ps1
  New-SoftLink -Source $PSScriptRoot\vscode\settings.json -Target $env:APPDATA\Code\User\settings.json
}

Write-Info "Setting up Git..."
$ExistingIncludePaths = (git config --global --get-all include.path)
if (($null -eq $ExistingIncludePaths) -Or (-not $ExistingIncludePaths.Contains("$PSScriptRoot\dotfiles\.gitconfig"))) {
  Write-Host "Adding my config to include path..."
  git config --global --add include.path $PSScriptRoot\dotfiles\.gitconfig
}
if (($null -eq $ExistingIncludePaths) -Or (-not $ExistingIncludePaths.Contains("$HOME\.gitconfig.local"))) {
  Write-Host "Adding local config to include path..."
  git config --global --add include.path $HOME\.gitconfig.local
}
# git config --global --add safe.directory *
git config --global credential.helper manager-core

# # Powershell modules
# Write-Info "Installing Powershell modules..."
# if ($null -eq (Get-Module -ListAvailable -Name Terminal-Icons).Name) {
#   Install-Module Terminal-Icons -Force
# }

# if ($null -eq (Get-Module -ListAvailable -Name PSReadLine).Name) {
#   Install-Module -Name PackageManagement -Repository PSGallery -Force -AllowClobber
#   Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
#   Install-Module PowershellGet -Force
#   Install-Module PSReadLine -AllowPrerelease -Force
# }

# oh-my-posh
Write-Info "Setting up oh-my-posh..."
if (Check-Command -cmdname "oh-my-posh") {
  New-Item -ItemType Directory -Force -Path $HOME\.pwsh | Out-Null
  New-SoftLink -Source $PSScriptRoot\oh-my-posh\ohmyposhv3.json -Target $HOME\.pwsh\ohmyposhv3.json
  New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $HOME\.pwsh\Microsoft.PowerShell_profile.ps1
  # New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $PSHOME\Profile.ps1 # All Users, All Hosts
  # New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $PSHOME\Microsoft.PowerShell_profile.ps1 # All Users, Current Host
  # New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $Home\Documents\PowerShell\Profile.ps1 # Current User, All Hosts
  # New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $Home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 # Current user, Current Host

  $MyDocuments = [Environment]::GetFolderPath("MyDocuments")
  # New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $MyDocuments\PowerShell\Profile.ps1 # Current User, All Hosts
  New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $MyDocuments\PowerShell\Microsoft.PowerShell_profile.ps1 # Current user, Current Host

  # $path = [Environment]::GetFolderPath("MyDocuments")+'\WindowsPowerShell'
  # New-Item -Path $path\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Value $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Force

}

# cmder
Write-Info "Setting up cmder..."
if (Check-Command -cmdname "cmder") {
  $CMDERHOME = (Get-Command cmder).Source | ForEach-Object { Split-Path -Path $_ }
  Write-Host "Copying template ConEmu.xml to $CMDERHOME\vendor\conemu-maximus5 ..."
  Copy-Item $PSScriptRoot\cmder\ConEmu.xml -Destination $CMDERHOME\vendor\conemu-maximus5 -Force
}

Write-Info "Creating links for WSL config..."
New-SoftLink -Source $PSScriptRoot\dotfiles\.wslconfig -Target $HOME\.wslconfig

Write-Info "Applying file explorer settings..."
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v AutoCheckSelect /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f"

Disable-ACPowerSleep
# Enable-RemoteDesktop

gsudo cache off
gsudo config LogLevel "Info" | Out-Null



Stop-Transcript