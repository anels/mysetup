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

# git config and wsl config
New-SoftLink -Source $PSScriptRoot\dotfiles\.gitconfig -Target $HOME\.gitconfig
New-SoftLink -Source $PSScriptRoot\dotfiles\.wslconfig -Target $HOME\.wslconfig

# oh-my-posh
if ($null -ne (Get-Command oh-my-posh).Name) {
  New-Item -ItemType Directory -Force -Path $HOME\.pwsh | Out-Null
  New-SoftLink -Source $PSScriptRoot\oh-my-posh\ohmyposhv3.json -Target $HOME\.pwsh\ohmyposhv3.json
  New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $HOME\.pwsh\Microsoft.PowerShell_profile.ps1 

  # $path = [Environment]::GetFolderPath("MyDocuments")+'\WindowsPowerShell'
  # New-Item -Path $path\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Value $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Force

  New-SoftLink -Source $PSScriptRoot\oh-my-posh\Microsoft.PowerShell_profile.ps1 -Target $PSHOME\Profile.ps1 
}

# cmder
if ($null -ne (Get-Command cmder).Name) {
  $CMDERHOME = (Get-Command cmder).Source | % { Split-Path -Path $_ }
  New-SoftLink -Source $PSScriptRoot\cmder\ConEmu.xml -Target $CMDERHOME\vendor\conemu-maximus5\ConEmu.xml 
}

# Powershell modules
if ($null -eq (Get-Module -ListAvailable -Name Terminal-Icons).Name) {
  Install-Module Terminal-Icons -Force
}

if ($null -eq (Get-Module -ListAvailable -Name PSReadLine).Name) {
  Install-Module PowershellGet -Force
  Install-Module PSReadLine -AllowPrerelease -Force
}

# VSCode
if ($null -ne (Get-Command code).Name) {
  code --install-extension aaron-bond.better-comments
  code --install-extension buster.ndjson-colorizer
  code --install-extension christian-kohler.path-intellisense
  code --install-extension DavidAnson.vscode-markdownlint
  code --install-extension DominicVonk.parameter-hints
  code --install-extension dongfg.vscode-beancount-formatter
  code --install-extension donjayamanne.githistory
  code --install-extension eamodio.gitlens
  code --install-extension EditorConfig.EditorConfig
  code --install-extension emmanuelbeziat.vscode-great-icons
  code --install-extension esbenp.prettier-vscode
  code --install-extension ex-codes.pine-script-syntax-highlighter
  code --install-extension formulahendry.code-runner
  code --install-extension formulahendry.docker-explorer
  code --install-extension foxundermoon.shell-format
  code --install-extension Fr43nk.seito-openfile
  code --install-extension GitHub.github-vscode-theme
  code --install-extension GitHub.vscode-pull-request-github
  code --install-extension IBM.output-colorizer
  code --install-extension jgclark.vscode-todo-highlight
  code --install-extension LeetCode.vscode-leetcode
  code --install-extension Lencerf.beancount
  code --install-extension mechatroner.rainbow-csv
  code --install-extension mhutchie.git-graph
  code --install-extension mqycn.huile8
  code --install-extension MS-CEINTL.vscode-language-pack-zh-hans
  code --install-extension ms-dotnettools.csharp
  code --install-extension ms-python.python
  code --install-extension ms-python.vscode-pylance
  code --install-extension ms-toolsai.jupyter
  code --install-extension ms-toolsai.jupyter-keymap
  code --install-extension ms-toolsai.jupyter-renderers
  code --install-extension ms-vscode-remote.remote-containers
  code --install-extension ms-vscode-remote.remote-wsl
  code --install-extension ms-vscode.powershell
  code --install-extension oderwat.indent-rainbow
  code --install-extension PKief.material-icon-theme
  code --install-extension pnp.polacode
  code --install-extension redhat.vscode-yaml
  code --install-extension saekiraku.rainbow-fart
  code --install-extension samghelms.jupyter-notebook-vscode
  code --install-extension sgoley.lookml-syntax-highlighter
  code --install-extension Shan.code-settings-sync
  code --install-extension shd101wyy.markdown-preview-enhanced
  code --install-extension SimonSiefke.prettier-vscode
  code --install-extension streetsidesoftware.code-spell-checker
  code --install-extension SumitSaha.learn-with-sumit-theme
  code --install-extension timonwong.shellcheck
  code --install-extension uctakeoff.vscode-counter
  code --install-extension usernamehw.errorlens
  code --install-extension vincaslt.highlight-matching-tag
  code --install-extension VisualStudioExptTeam.vscodeintellicode
  code --install-extension wangtao0101.debug-leetcode
  code --install-extension wayou.vscode-todo-highlight
  code --install-extension XavierCai.vscode-leetcode-cpp-debug
  code --install-extension yzhang.markdown-all-in-one
  code --install-extension zhuangtongfa.material-theme

  New-SoftLink -Source $PSScriptRoot\vscode\settings.json -Target $env:APPDATA\Code\User\settings.json
}