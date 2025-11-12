# Google Play Release Readiness Checker

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Google Play Release Readiness Check" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: Package Name
Write-Host "1. Package Name (Application ID)..." -NoNewline
$buildGradle = Get-Content "android\app\build.gradle.kts" -Raw
if ($buildGradle -match 'applicationId\s*=\s*"com\.example\.') {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    Write-Host "   Still using com.example.* package name" -ForegroundColor Yellow
    Write-Host "   Update applicationId in android/app/build.gradle.kts" -ForegroundColor Yellow
    $allGood = $false
} elseif ($buildGradle -match 'applicationId\s*=\s*"([^"]+)"') {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "   Package: $($matches[1])" -ForegroundColor Gray
}

# Check 2: Target API Level
Write-Host "2. Target API Level (Android 15)..." -NoNewline
if ($buildGradle -match 'targetSdk\s*=\s*35') {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "   Targeting API 35 (Android 15)" -ForegroundColor Gray
} else {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    Write-Host "   Must target API 35 for Google Play 2025" -ForegroundColor Yellow
    $allGood = $false
}

# Check 3: App Version
Write-Host "3. App Version..." -NoNewline
$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match 'version:\s*([\d\.]+\+\d+)') {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "   Version: $($matches[1])" -ForegroundColor Gray
} else {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    Write-Host "   Version not found in pubspec.yaml" -ForegroundColor Yellow
    $allGood = $false
}

# Check 4: Signing Configuration
Write-Host "4. Signing Configuration..." -NoNewline
$keystoreExists = Test-Path "android\app\upload-keystore.jks"
$keyPropsExists = Test-Path "android\keystore.properties"

if ($keystoreExists -and $keyPropsExists) {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "   Keystore and keystore.properties found" -ForegroundColor Gray
} elseif (-not $keystoreExists -and -not $keyPropsExists) {
    Write-Host " ⚠ NOT SET UP" -ForegroundColor Yellow
    Write-Host "   Run: .\setup-signing.ps1 to create keystore" -ForegroundColor Yellow
} else {
    Write-Host " ⚠ INCOMPLETE" -ForegroundColor Yellow
    if (-not $keystoreExists) {
        Write-Host "   Missing: upload-keystore.jks" -ForegroundColor Yellow
    }
    if (-not $keyPropsExists) {
        Write-Host "   Missing: keystore.properties" -ForegroundColor Yellow
    }
}

# Check 5: ProGuard Rules
Write-Host "5. ProGuard Rules..." -NoNewline
if (Test-Path "android\app\proguard-rules.pro") {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "   ProGuard configuration found" -ForegroundColor Gray
} else {
    Write-Host " ❌ FAIL" -ForegroundColor Red
    Write-Host "   ProGuard rules missing" -ForegroundColor Yellow
    $allGood = $false
}

# Check 6: Permissions Review
Write-Host "6. Permissions Review..." -NoNewline
$manifest = Get-Content "android\app\src\main\AndroidManifest.xml" -Raw
$permissions = [regex]::Matches($manifest, '<uses-permission android:name="([^"]+)"')
Write-Host " ✓ INFO" -ForegroundColor Cyan
Write-Host "   Declared permissions:" -ForegroundColor Gray
foreach ($perm in $permissions) {
    Write-Host "   - $($perm.Groups[1].Value)" -ForegroundColor Gray
}

# Check 7: No Print Statements
Write-Host "7. Production Code Quality..." -NoNewline
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
$printFound = $false
foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match '\bprint\s*\(') {
        $printFound = $true
        break
    }
}
if (-not $printFound) {
    Write-Host " ✓ PASS" -ForegroundColor Green
    Write-Host "   No print statements found" -ForegroundColor Gray
} else {
    Write-Host " ⚠ WARNING" -ForegroundColor Yellow
    Write-Host "   Print statements found in code" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan

if ($allGood -and $keystoreExists -and $keyPropsExists) {
    Write-Host "   ✓ READY FOR RELEASE BUILD!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "1. flutter clean" -ForegroundColor Yellow
    Write-Host "2. flutter build appbundle --release" -ForegroundColor Yellow
    Write-Host "3. Upload: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Yellow
} elseif ($allGood) {
    Write-Host "   ⚠ ALMOST READY" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Complete signing setup first:" -ForegroundColor White
    Write-Host "Run: .\setup-signing.ps1" -ForegroundColor Yellow
} else {
    Write-Host "   ❌ NOT READY" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fix the issues above before building." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "For detailed guidance, see: PLAYSTORE_RELEASE_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
