# Android SDK Setup Script
# Run this AFTER extracting command-line tools to the correct location

Write-Host "=== Android SDK Setup ===" -ForegroundColor Green
Write-Host ""

$sdkPath = "C:\Users\anjan\AppData\Local\Android\Sdk"
$sdkManager = "$sdkPath\cmdline-tools\latest\bin\sdkmanager.bat"

# Check if sdkmanager exists
if (-not (Test-Path $sdkManager)) {
    Write-Host "ERROR: SDK Manager not found!" -ForegroundColor Red
    Write-Host "Please download and extract command-line tools first:" -ForegroundColor Yellow
    Write-Host "https://developer.android.com/studio#command-line-tools-only"
    Write-Host ""
    Write-Host "Extract to: $sdkPath\cmdline-tools\latest" -ForegroundColor Yellow
    exit 1
}

# Set environment variables for current session
$env:ANDROID_HOME = $sdkPath
$env:ANDROID_SDK_ROOT = $sdkPath
$env:PATH = "$sdkPath\cmdline-tools\latest\bin;$sdkPath\platform-tools;$env:PATH"

Write-Host "Installing required SDK components..." -ForegroundColor Cyan

# Install required components
& $sdkManager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "cmdline-tools;latest"

Write-Host ""
Write-Host "Accepting licenses..." -ForegroundColor Cyan
& $sdkManager --licenses

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Now run:" -ForegroundColor Yellow
Write-Host "  flutter doctor --android-licenses"
Write-Host "  flutter doctor -v"
Write-Host "  flutter build apk --release"
