Import-Module Appx

Function Remove-UWP {
    param (
        [string]$name
    )

    Write-Host "Removing UWP $name..." -ForegroundColor Yellow
    Get-AppxPackage $name | Remove-AppxPackage
    Get-AppxPackage $name | Remove-AppxPackage -AllUsers
}

# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
    "*549981C3F5F10*"
    "4DF9E0F8.Netflix"
    "Fitbit.FitbitCoach"
    "king.com.CandyCrushSaga"
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MSPaint"
    "Microsoft.People"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.SkypeApp"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftTeams"
)

foreach ($uwp in $uwpRubbishApps) {
    Remove-UWP $uwp
}