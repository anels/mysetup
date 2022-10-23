Write-Host ""
Write-Host "Installing Applications from Scoop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$EnabledBuckets = $(scoop bucket list).Name
$Buckets = @(
  "extras"
  "nerd-fonts"
  "versions"
)

foreach ($bucket in $Buckets) {
  if ($bucket -notin $EnabledBuckets) {
    scoop bucket add $bucket
  }
}

# scoop update *
# scoop cleanup *

scoop install `
  7zip `
  bat `
  bulk-crap-uninstaller `
  delta `
  dismplusplus `
  ditto `
  duf `
  dust `
  everything `
  imageglass `
  jq `
  coreutils `
  marktext `
  meld `
  musicbee `
  nexusfont `
  notepadplusplus `
  oh-my-posh `
  posh-git `
  potplayer `
  psreadline `
  pwsh `
  scoop-completion `
  snipaste `
  sysinternals `
  terminal-icons `
  twinkle-tray `
  universal-ctags `
  vim `
  windirstat `
  winmerge `
  tldr `
  z `
  winfetch `
  #neofetch `
  # fzf `
  # psfzf `
  # less `

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