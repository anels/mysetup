Write-Host ""
Write-Host "Installing Applications from Pip..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$Packages = @(
  "wheel"
  "setuptools"
  "windows-curses"
  "glances"
  "git-fame"
  "fava"
)

if ($null -ne (Get-Command pip -ErrorAction:SilentlyContinue).Name) {
  $InstalledPackages = pip list -l --format json | jq -r .[].name
  python -m pip install --upgrade pip
  foreach ($package in $Packages) {
    if ($package -in $InstalledPackages) {
      Write-Host "${package} is already installed."
    }
    else {
      Write-Host "Installing ${package}..." -ForegroundColor Green
      pip install -U $package
    }
  }
}
else {
  Write-Host -ForegroundColor Red "Python is not installed."
}
