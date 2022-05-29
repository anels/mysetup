#Requires -RunAsAdministrator

Function New-SoftLink {
  param (
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Source,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Target
  )

  # remove target file if exists
  try {
    if (Test-Path $Target) {
      Remove-Item $Target
    }

    New-Item -Path $Target -ItemType SymbolicLink -Value $Source -Force
  }
  catch {
    Write-Host -ForegroundColor Red "Something went wrong..."
    Write-Host $_
  }
}

# install software
. $PSScriptRoot\chocolatey.ps1
. $PSScriptRoot\pip.ps1

# VSCode
if ($null -ne (Get-Command code).Name) {
  . $PSScriptRoot\pip.ps1
  New-SoftLink -Source $PSScriptRoot\vscode\settings.json -Target $env:APPDATA\Code\User\settings.json
}

# git config and wsl config
git config --global --add include.path $PSScriptRoot\dotfiles\.gitconfig
git config --global --add include.path $HOME\.gitconfig.local

New-SoftLink -Source $PSScriptRoot\dotfiles\.wslconfig -Target $HOME\.wslconfig

# Powershell modules
if ($null -eq (Get-Module -ListAvailable -Name Terminal-Icons).Name) {
  Install-Module Terminal-Icons -Force
}

if ($null -eq (Get-Module -ListAvailable -Name PSReadLine).Name) {
  Install-Module -Name PackageManagement -Repository PSGallery -Force -AllowClobber
  Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
  Install-Module PowershellGet -Force
  Install-Module PSReadLine -AllowPrerelease -Force
}

# oh-my-posh
if ($null -ne (Get-Command oh-my-posh).Name) {
  New-Item -ItemType Directory -Force -Path $HOME\.pwsh | Out-Null
  New-SoftLink -Source $PSScriptRoot\oh-my-posh\ohmyposhv3.json -Target $HOME\.pwsh\ohmyposhv3.json
  New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $HOME\.pwsh\Microsoft.PowerShell_profile.ps1

  # $path = [Environment]::GetFolderPath("MyDocuments")+'\WindowsPowerShell'
  # New-Item -Path $path\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Value $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Force

  New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $PSHOME\Profile.ps1
}