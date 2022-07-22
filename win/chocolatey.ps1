#Requires -RunAsAdministrator

if ($null -eq (Get-Command choco).Name) {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

choco upgrade -yr --no-progress `
  7zip `
  bulk-crap-uninstaller `
  cmder `
  contextmenumanager `
  delta `
  dismplusplus `
  ditto `
  eartrumpet `
  everything `
  geekuninstaller `
  git `
  imageglass `
  joplin `
  marktext `
  meld `
  musicbee `
  notepadplusplus `
  oh-my-posh `
  peazip `
  poshgit `
  potplayer `
  powershell-core `
  powertoys `
  sumatrapdf `
  sysinternals `
  treesizefree `
  universal-ctags `
  vim `
  virtualbox `
  vscode `
  windirstat `
  winmerge `

# cmdlet
choco upgrade -yr --no-progress `
  bat `
  duf `

# devbox
# choco upgrade -yr --no-progress `
  # dbeaver `
  # fiddler `
  # mRemoteNG `

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
