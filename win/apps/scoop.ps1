# Import PackageManager module
Import-Module "$PSScriptRoot\..\dotfiles\modules\PackageManager.psm1" -Force

Write-Host ""
Write-Host "Installing Applications from Scoop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$EnabledBuckets = $(scoop bucket list).Name
$Buckets = @(
  "extras"
  "nerd-fonts"
  "versions"
  "java"
)

foreach ($bucket in $Buckets) {
  if ($bucket -notin $EnabledBuckets) {
    scoop bucket add $bucket
  }
}

$GlobalApps = $(
  "vcredist2022"
)

$CommonApps = $(
  "7zip"
  "bat"
  "bitwarden"
  "bottom"
  "broot"
  "btop"
  "bulk-crap-uninstaller"
  "coreutils"
  "crystaldiskinfo"
  "delta"
  "dismplusplus"
  "ditto"
  "duf"
  "dust"
  "everything"
  "fastfetch"
  "gitahead"
  "imageglass"
  "jid"
  "joplin"
  "jq"
  "less"
  "lsd"
  "macast"
  "marktext"
  "musicbee"
  "nano"
  "nexusfont"
  "oh-my-posh" # A prompt theme engine for any shell
  "openjdk"
  "openssh"
  "posh-git" # A PowerShell environment for Git
  "psreadline"
  "picard"
  "pwsh"
  "python312"
  "quicklook"
  "scoop-completion"
  "screentogif"
  "snipaste"
  "spacesniffer"
  "sumatrapdf"
  "sysinternals"
  "terminal-icons" # A PowerShell module to show file and folder icons in the terminal
  "tldr"
  "treesize-free"
  "universal-ctags"
  "vim"
  "vscode"
  "wechat"
  "windirstat"
  "windows-terminal"
  "z" # A new cd command that helps you navigate faster by learning your habits
  # "extras/nilesoft-shell"
  # "eartrumpet"
  # "extras/balabolka"
  # "extras/easy-context-menu"
  # "main/refreshenv" # included in Choco
  # "obsidian"
  # "onefetch"
  # "potplayer"
  # "powertoys"
  # "twinkle-tray"
  # fzf - A command-line fuzzy finder
  # googlechrome
  # less
  # psfzf - A PowerShell wrapper around the fzf
  # winmerge
)

$Fonts = $(
  "AnonymousPro-NF-Mono"
  "CascadiaCode-NF-Mono"
  "FiraCode-NF-Mono"
  "Hack-NF-Mono"
  "JetBrainsMono-NF-Mono"
  "SourceCodePro-NF-Mono"
  "Maple-Mono-NF"
  # "CascadiaCode-NF"
  # "FiraMono-NF"
  # "Hack-NF"
  # "JetBrainsMono-NF"
  # "SourceCodePro-NF"
  # "VictorMono-NF"
)

Install-Packages -PackageManager 'scoop' -Packages $GlobalApps -GlobalInstall

# nerd-fonts
# Currently, on Windows 11 Version 22H2 (OS Build 22621) or later,
# Font installation only works when installing font for all users.
Install-Packages -PackageManager 'scoop' -Packages $Fonts -GlobalInstall

Install-Packages -PackageManager 'scoop' -Packages $CommonApps

# additional dev tools
# scoop install
#  helm
#  openlens
#  mremoteng
#  dbeaver
#  github
#  gh
#  zoom
#  nodejs
#  azure-cli
#  posh-docker # Import-Module posh-docker
#  main/ctop # Top-like interface for container metrics.
#  hadolint
#  hyperfine # A command-line benchmarking tool.
#  wixtoolset
#  extras/hoppscotch


# scoop bucket add dorado https://github.com/chawyehsu/dorado
# scoop install dorado/qqmusic
# scoop install dorado/qqplayer

$RegItems = @(
#   "$Home\scoop\apps\eartrumpet\current\add-startup.reg"
  "$Home\scoop\apps\python312\current\install-pep-514.reg"
  "$Home\scoop\apps\vscode\current\install-associations.reg"
  "$Home\scoop\apps\windows-terminal\current\install-context.reg"
  "$Home\scoop\apps\7zip\current\install-context.reg"
)

Write-Host "Importing Reg Items..."
foreach ($item in $RegItems) {
  if (Test-Path $item -PathType Leaf) {
    Write-Host  -NoNewline "Importing ${item}..."
    reg import $item >nul 2>&1
    Write-Host "Done!"
  }
}
