# Android App Signing Setup Script
# Run this script to generate your upload keystore for Google Play

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Android App Signing Setup for Google Play" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if keytool is available
$keytoolPath = Get-Command keytool -ErrorAction SilentlyContinue

if (-not $keytoolPath) {
    Write-Host "ERROR: keytool not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "keytool comes with Java JDK. Please install Java JDK and try again." -ForegroundColor Yellow
    Write-Host "Download from: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ keytool found at: $($keytoolPath.Source)" -ForegroundColor Green
Write-Host ""

# Check if keystore already exists
$keystorePath = "android\app\upload-keystore.jks"
if (Test-Path $keystorePath) {
    Write-Host "WARNING: upload-keystore.jks already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (yes/no)"
    if ($overwrite -ne "yes") {
        Write-Host "Setup cancelled." -ForegroundColor Yellow
        exit 0
    }
    Remove-Item $keystorePath -Force
}

Write-Host "Generating upload keystore..." -ForegroundColor Cyan
Write-Host ""
Write-Host "You will be asked to enter:" -ForegroundColor Yellow
Write-Host "  1. A keystore password (SAVE THIS!)" -ForegroundColor Yellow
Write-Host "  2. A key password (can be same as keystore password)" -ForegroundColor Yellow
Write-Host "  3. Your name, organization, city, state, country code" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

# Generate the keystore
keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "   Keystore generated successfully!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Create android/key.properties file with:" -ForegroundColor White
    Write-Host ""
    Write-Host "   storePassword=YOUR_PASSWORD_HERE" -ForegroundColor Yellow
    Write-Host "   keyPassword=YOUR_PASSWORD_HERE" -ForegroundColor Yellow
    Write-Host "   keyAlias=upload" -ForegroundColor Yellow
    Write-Host "   storeFile=../app/upload-keystore.jks" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. BACKUP your keystore and passwords securely!" -ForegroundColor Red
    Write-Host "   Location: $keystorePath" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Build your release app bundle:" -ForegroundColor White
    Write-Host "   flutter clean" -ForegroundColor Yellow
    Write-Host "   flutter build appbundle --release" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ERROR: Keystore generation failed!" -ForegroundColor Red
    Write-Host "Please check the errors above and try again." -ForegroundColor Yellow
}
