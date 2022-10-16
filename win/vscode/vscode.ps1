# VSCode
Import-Module "$PSScriptRoot\..\dotfiles\modules\PackageManager.psm1" -Force
Write-Host -ForegroundColor Green "Installing VSCode Extensions..."

if (!(Get-Command code -ErrorAction SilentlyContinue)) {
  Write-Host -ForegroundColor Red "VSCode is not installed."
  return
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
    #  Tim-Koehler.helm-intellisense
    # "iceworks-team.iceworks-time-master"
    "aaron-bond.better-comments"
    "christian-kohler.path-intellisense"
    "davidanson.vscode-markdownlint"
    "dominicvonk.parameter-hints"
    "dongfg.vscode-beancount-formatter"
    "donjayamanne.githistory"
    "eamodio.gitlens"
    "editorconfig.editorconfig"
    "emmanuelbeziat.vscode-great-icons"
    "esbenp.prettier-vscode"
    "eservice-online.vs-sharper"
    "evan-buss.font-switcher"
    "exiasr.hadolint"
    "formulahendry.code-runner"
    "foxundermoon.shell-format"
    "fr43nk.seito-openfile"
    "github.github-vscode-theme"
    "github.vscode-github-actions"
    "github.vscode-pull-request-github"
    "gruntfuggly.todo-tree"
    "helgardrichard.helium-icon-theme"
    "ibm.output-colorizer"
    "jeff-hykin.better-dockerfile-syntax"
    "lencerf.beancount"
    "mechatroner.rainbow-csv"
    "mhutchie.git-graph"
    "ms-azuretools.vscode-docker"
    "ms-ceintl.vscode-language-pack-zh-hans"
    "ms-dotnettools.csharp"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-vscode.powershell"
    "oderwat.indent-rainbow"
    "pkief.material-icon-theme"
    "pnp.polacode"
    "redhat.vscode-yaml"
    "romario-stankovic.insomnia-theme"
    "shakram02.bash-beautify"
    "shardulm94.trailing-spaces"
    "shd101wyy.markdown-preview-enhanced"
    "streetsidesoftware.code-spell-checker"
    "timonwong.shellcheck"
    "TylerLeonhardt.vscode-inline-values-powershell"
    "uctakeoff.vscode-counter"
    "usernamehw.errorlens"
    "vincaslt.highlight-matching-tag"
    "waderyan.gitblame"
    "yzhang.markdown-all-in-one"
    "zhuangtongfa.material-theme"
)

Install-Packages -PackageManager 'vscode' -Packages $Extensions




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
