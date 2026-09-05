# VSCode
Import-Module "$PSScriptRoot\..\dotfiles\modules\PackageManager.psm1" -Force
Write-Host -ForegroundColor Green "Installing VSCode Extensions..."

if (!(Get-Command code -ErrorAction SilentlyContinue)) {
  Write-Host -ForegroundColor Red "VSCode is not installed."
  return
}

# Extensions that only make sense on Windows; the rest are shared with macOS
$Extensions = @(
    "eservice-online.vs-sharper"
    "ms-dotnettools.csharp"
    "romario-stankovic.insomnia-theme"
    "tylerleonhardt.vscode-inline-values-powershell"
)

$sharedExtensionsFile = Join-Path $PSScriptRoot "..\..\common\vscode\extensions.txt"
if (Test-Path $sharedExtensionsFile) {
    $Extensions += Get-Content $sharedExtensionsFile |
        ForEach-Object { ($_ -replace '#.*$', '').Trim() } |
        Where-Object { $_ }
}
else {
    Write-Host -ForegroundColor Red "Shared extension list not found: $sharedExtensionsFile"
}

Install-Packages -PackageManager 'vscode' -Packages $Extensions
