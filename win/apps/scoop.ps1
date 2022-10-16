Write-Host ""
Write-Host "Installing Applications from Scoop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

scoop update *
scoop cleanup *

scoop install `
  7zip `
  bulk-crap-uninstaller `
  posh-git `
  delta `
  dismplusplus `
  bat `
  duf `
  dust `
  musicbee `
  universal-ctags `
  sysinternals `
  ditto `
  oh-my-posh `
  everything `
  vim `
  marktext `
  notepadplusplus `
  imageglass `
  meld `
  pwsh `
  sumatrapdf `
  potplayer `
  windirstat `
  winmerge `
  twinkle-tray `
  snipaste `
  terminal-icons `
  nexusfont `
  psreadline `
  less `
  jq `
  # z `
  # fzf `
  # psfzf `

# versions
scoop install `
  python39 `

# nerd-fonts
scoop install `
  FiraMono-NF `
  JetBrainsMono-NF `
  RobotoMono-NF `
  SourceCodePro-NF-Mono `
  UbuntuMono-NF `
  VictorMono-NF `
  # FiraMono-NF-Mono `
  # JetBrainsMono-NF-Mono `
  # UbuntuMono-NF-Mono `
  # FiraCode-NF-Mono `
  # Ubuntu-NF-Mono `
  # Ubuntu-NF `

# z - A new cd command that helps you navigate faster by learning your habits
# fzf - A command-line fuzzy finder
# psfzf - A PowerShell wrapper around the fzf
# posh-git - A PowerShell environment for Git
# oh-my-posh - A prompt theme engine for any shell
# terminal-icons - A PowerShell module to show file and folder icons in the terminal