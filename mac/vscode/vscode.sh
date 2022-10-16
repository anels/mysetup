#!/usr/bin/env bash
# VS Code extension installation script
# Must be sourced from setup.sh (requires command_exists, error helpers)

if ! type command_exists &>/dev/null; then
    echo "Error: vscode.sh must be sourced from setup.sh" >&2
    return 2>/dev/null || exit 1
fi

echo -e "\033[32mInstalling VS Code Extensions...\033[0m"

if ! command_exists code; then
    error "VS Code is not installed."
    return 0
fi

EXTENSIONS=(
    # "4ops.terraform"
    # "james-yu.latex-workshop"
    # "ms-azuretools.vscode-docker"
    # "ms-kubernetes-tools.vscode-kubernetes-tools"
    # "ms-vscode-remote.remote-containers"
    # "ms-vscode.powershell"
    # "tim-koehler.helm-intellisense"
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
    "evan-buss.font-switcher"
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
    "ms-python.python"
    "ms-python.vscode-pylance"
    "oderwat.indent-rainbow"
    "pkief.material-icon-theme"
    "pnp.polacode"
    "redhat.vscode-yaml"
    "shakram02.bash-beautify"
    "shardulm94.trailing-spaces"
    "shd101wyy.markdown-preview-enhanced"
    "streetsidesoftware.code-spell-checker"
    "timonwong.shellcheck"
    "uctakeoff.vscode-counter"
    "usernamehw.errorlens"
    "vincaslt.highlight-matching-tag"
    "waderyan.gitblame"
    "yzhang.markdown-all-in-one"
    "zhuangtongfa.material-theme"
)

INSTALLED_EXTENSIONS=$(code --list-extensions 2>/dev/null)

for ext in "${EXTENSIONS[@]}"; do
    if echo "$INSTALLED_EXTENSIONS" | grep -qi "^${ext}$"; then
        echo -e "  \033[90m$ext (already installed)\033[0m"
    else
        echo -ne "  Installing $ext..."
        if code --install-extension "$ext" --force &>/dev/null; then
            echo -e " \033[32mOK\033[0m"
        else
            echo -e " \033[31mFAILED\033[0m"
        fi
    fi
done
