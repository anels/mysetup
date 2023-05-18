# VSCode
Write-Host -ForegroundColor Green "Installing VSCode Extensions..."

if (!(Get-Command code -ErrorAction SilentlyContinue)) {
  Write-Host -ForegroundColor Red "VSCode is not installed."
  exit 0
}

$Extensions = @(
  #  4ops.terraform
  #  AntonReshetov.masscode-assistant
  #  buster.ndjson-colorizer
  #  DominicVonk.vscode-resx-editor
  #  hediet.debug-visualizer
  #  James-Yu.latex-workshop
  #  mathematic.vscode-latex
  #  ms-azure-devops.azure-pipelines
  #  ms-azuretools.vscode-azureresourcegroups
  #  ms-azuretools.vscode-azurevirtualmachines
  #  ms-azuretools.vscode-docker
  #  ms-kubernetes-tools.vscode-kubernetes-tools
  #  ms-vscode-remote.remote-containers
  #  ms-vscode-remote.remote-wsl
  #  ms-vscode.azure-account
  #  ms-vscode.powershell
  #  swyphcosmo.spellchecker
  #  TabNine.tabnine-vscode
  #  Tim-Koehler.helm-intellisense
  "aaron-bond.better-comments"
  "helgardrichard.helium-icon-theme"
  "christian-kohler.path-intellisense"
  "DavidAnson.vscode-markdownlint"
  "DominicVonk.parameter-hints"
  "dongfg.vscode-beancount-formatter"
  "donjayamanne.githistory"
  "eamodio.gitlens"
  "EditorConfig.EditorConfig"
  "emmanuelbeziat.vscode-great-icons"
  "esbenp.prettier-vscode"
  "eservice-online.vs-sharper"
  "evan-buss.font-switcher"
  "ex-codes.pine-script-syntax-highlighter"
  "exiasr.hadolint"
  "formulahendry.code-runner"
  "foxundermoon.shell-format"
  "Fr43nk.seito-openfile"
  "GitHub.github-vscode-theme"
  "GitHub.vscode-pull-request-github"
  "Gruntfuggly.todo-tree"
  "IBM.output-colorizer"
  # "iceworks-team.iceworks-time-master"
  "jeff-hykin.better-dockerfile-syntax"
  "jgclark.vscode-todo-highlight"
  "Lencerf.beancount"
  "leodevbro.blockman"
  "mechatroner.rainbow-csv"
  "mhutchie.git-graph"
  "mintlify.document"
  "MS-CEINTL.vscode-language-pack-zh-hans"
  "ms-dotnettools.csharp"
  "ms-python.python"
  "ms-python.vscode-pylance"
  "oderwat.indent-rainbow"
  "PKief.material-icon-theme"
  "pnp.polacode"
  "redhat.vscode-yaml"
  "romario-stankovic.insomnia-theme"
  "saekiraku.rainbow-fart"
  "sgoley.lookml-syntax-highlighter"
  "shakram02.bash-beautify"
  "shardulm94.trailing-spaces"
  "shd101wyy.markdown-preview-enhanced"
  "sourcery.sourcery"
  "streetsidesoftware.code-spell-checker"
  "znck.grammarly"
  "timonwong.shellcheck"
  "TylerLeonhardt.vscode-inline-values-powershell"
  "uctakeoff.vscode-counter"
  "usernamehw.errorlens"
  "vincaslt.highlight-matching-tag"
  "waderyan.gitblame"
  "yzhang.markdown-all-in-one"
  "zhuangtongfa.material-theme"
)

$InstalledExtensions = code --list-extensions

foreach ($extension in $Extensions) {
  if ($extension -in $InstalledExtensions) {
    Write-Host "${extension} is already installed."
  }
  else {
    Write-Host "Installing ${extension}..." -ForegroundColor Green
    code --install-extension $extension
  }
}




# Installing extension 'antonreshetov.masscode-assistant'...
# (node:11624) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
# (Use `Code --trace-deprecation ...` to show where the warning was created)
# Extension 'antonreshetov.masscode-assistant' v1.1.0 was successfully installed.
# Installing extensions...
# Installing extension 'hediet.debug-visualizer'...
# (node:10304) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
# (Use `Code --trace-deprecation ...` to show where the warning was created)
# Extension 'hediet.debug-visualizer' v2.3.1 was successfully installed.
# Installing extensions...
# Installing extension 'james-yu.latex-workshop'...
# (node:11252) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
# (Use `Code --trace-deprecation ...` to show where the warning was created)
# Extension 'james-yu.latex-workshop' v8.29.0 was successfully installed.
# Installing extensions...
# Installing extension 'mathematic.vscode-latex'...
# (node:31220) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
# (Use `Code --trace-deprecation ...` to show where the warning was created)
# Extension 'mathematic.vscode-latex' v1.2.0 was successfully installed.
