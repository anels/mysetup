#Requires -RunAsAdministrator

if ($null -eq (Get-Command choco).Name) {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

choco upgrade -yr --no-progress `
  eartrumpet `
  7zip `
  cmder `
  contextmenumanager `
  dismplusplus `
  ditto `
  duf `
  everything `
  geekuninstaller `
  git `
  imageglass `
  marktext `
  meld `
  musicbee `
  notepadplusplus `
  oh-my-posh `
  peazip `
  poshgit `
  powershell-core `
  powertoys `
  sumatrapdf `
  sysinternals `
  treesizefree `
  vim `
  windirstat `

# Fonts
choco upgrade -yr --no-progress `
  anonymouspro `
  cascadia-code-nerd-font `
  cascadiacode `
  FiraCode `
  firacodenf `
  hackfont `
  jetbrainsmono `
  jetbrainsmononf `
  nerdfont-hack `
  sourcecodepro `
