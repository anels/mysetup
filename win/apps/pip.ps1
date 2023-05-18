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
    $InstalledPackages = pip list -l --format json | ConvertFrom-Json | Select-Object -ExpandProperty name
    python -m pip install --upgrade pip
    foreach ($package in $Packages) {
        if ($package -in $InstalledPackages) {
            Write-Host "$package is already installed."
        }
        else {
            Write-Host "Installing $package..." -ForegroundColor Green
            pip install -U $package
        }
    }
}
else {
    Write-Error "Python is not installed."
}

# pip install git+https://github.com/beancount/beanprice.git
# pip install pricehist