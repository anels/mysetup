#Requires -RunAsAdministrator

Write-Host ""
Write-Host "Installing Applications from Choco..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

choco upgrade -yr --no-progress `
peazip `
powertoys `
sumatrapdf `
teracopy `
  # contextmenumanager `
  # eartrumpet `
  # vscode `
  # treesizefree `
  # cmder `
  # chocolateygui `
  # delta `
  # dismplusplus `
  # ditto `
  # everything `
  # git `
  # imageglass `
  # joplin `
  # marktext `
  # meld `
  # musicbee `
  # notepadplusplus `
  # oh-my-posh `
  # poshgit `
  # potplayer `
  # powershell-core `
  # sysinternals `
  # universal-ctags `
  # vim `
  # volume2 `
  # 7zip `
  # bulk-crap-uninstaller `
  # windirstat `
  # winmerge `
  # greenshot `
  # geekuninstaller `
  # eartrumpet `
  # virtualbox `

# devbox
# choco upgrade -yr --no-progress `
# dbeaver `
# fiddler `
# mRemoteNG `

# Fonts
# choco uninstall -yr --no-progress `
#   anonymouspro `
#   cascadia-code-nerd-font `
#   cascadiacode `
#   FiraCode `
#   firacodenf `
#   hackfont `
#   jetbrainsmono `
#   jetbrainsmononf `
#   nerdfont-hack `
#   sourcecodepro `

RefreshEnv
