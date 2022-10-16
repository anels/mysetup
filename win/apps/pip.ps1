Import-Module (Join-Path $PSScriptRoot "..\dotfiles\modules\PackageManager.psm1") -Force

Write-Host ""
Write-Host "Installing Applications from Pip..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$Packages = @(
    "wheel"
    "setuptools"
    "glances"
    "git-fame"
    "fava"
    "git-playback" # https://github.com/jianli/git-playback
)

 if (Get-Command pip -ErrorAction SilentlyContinue) {
    python -m pip install --upgrade pip
    Install-Packages -Packages $Packages -PackageManager 'pip'
 }
else {
    Write-Error "Python is not installed."
}

# pip install git+https://github.com/beancount/beanprice.git
# pip install pricehist