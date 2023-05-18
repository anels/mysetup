function Install-Apps($AppList, $GlobalInstall = $false) {
  $InstalledApps = $(scoop list 6>$null).Name
  foreach ($app in $AppList) {
    if ($app -in $InstalledApps) {
      Write-Host "${app} is already installed."
    }
    else {
      if ($GlobalInstall) {
        Write-Host "Installing ${app} globally..."
        scoop install -g $app
      }
      else {
        Write-Host "Installing ${app}..."
        scoop install $app
      }
    }
  }
}

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
  "eartrumpet"
  "everything"
  "fastcopy"
  "gitahead"
  "glary-utilities"
  "imageglass"
  "jid"
  "joplin"
  "jq"
  "less"
  "lsd"
  "macast"
  "marktext"
  "meld"
  "musicbee"
  "nexusfont"
  "oh-my-posh" # A prompt theme engine for any shell
  "onefetch"
  "openjdk"
  "posh-git" # A PowerShell environment for Git
  "psreadline"
  "pwsh"
  "python39"
  "scoop-completion"
  "snipaste-beta"
  "spacesniffer"
  "sumatrapdf"
  "sysinternals"
  "terminal-icons" # A PowerShell module to show file and folder icons in the terminal
  "tldr"
  "nano"
  "treesize-free"
  "twinkle-tray"
  "universal-ctags"
  "vim"
  "vscode"
  "wechat"
  "windirstat"
  "windows-terminal"
  "winfetch"
  "z" # A new cd command that helps you navigate faster by learning your habits
  # "potplayer"
  # "powertoys"
  # "extras/balabolka"
  # "extras/easy-context-menu"
  # "main/refreshenv" # included in Choco
  # "obsidian"
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
  # "CascadiaCode-NF"
  # "FiraMono-NF"
  # "Hack-NF"
  # "JetBrainsMono-NF"
  # "SourceCodePro-NF"
  # "VictorMono-NF"
)

Install-Apps $GlobalApps $true

# nerd-fonts
# Currently, on Windows 11 Version 22H2 (OS Build 22621) or later,
# Font installation only works when installing font for all users.
Install-Apps $Fonts $true

Install-Apps $CommonApps

# additional dev tools
# scoop install
#  helm
#  openlens
#  extras/lens
#  mremoteng
#  dbeaver
#  github
#  zoom
#  nodejs
#  azure-cli
#  posh-docker # Import-Module posh-docker
#  main/ctop # Top-like interface for container metrics.
#  hadolint
#  hyperfine # A command-line benchmarking tool.
#  wixtoolset


# scoop bucket add dorado https://github.com/chawyehsu/dorado
# scoop install dorado/qqmusic
# scoop install dorado/qqplayer

$RegItems = @(
  "$Home\scoop\apps\eartrumpet\current\add-startup.reg"
  "$Home\scoop\apps\python39\current\install-pep-514.reg"
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
