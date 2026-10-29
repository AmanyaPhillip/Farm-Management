param(
    [switch]$Android,
    [switch]$Windows,
    [switch]$All,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

if (-not ($Android -or $Windows -or $All)) {
    $All = $true
}

$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
Set-Location $ProjectRoot

# Helper function to execute external commands safely and fail immediately if they exit non-zero
function Invoke-FlutterCommand {
    param([string]$CmdDesc, [scriptblock]$Action)
    
    Write-Host "`n-> $CmdDesc..." -ForegroundColor Yellow
    & $Action
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE ($CmdDesc)"
    }
}

# ---------------------------------------------------------------------------
# Optional Clean
# ---------------------------------------------------------------------------
if ($Clean) {
    Write-Host "`nCleaning build artifacts..." -ForegroundColor Cyan
    Remove-Item -Recurse -Force "$ProjectRoot\build\windows" -ErrorAction SilentlyContinue
    
    # Try flutter clean gracefully (ignore file lock if Windows Explorer holds a folder)
    try {
        flutter clean
    } catch {
        Write-Host "Warning: Flutter clean encountered locked files, continuing..." -ForegroundColor DarkYellow
    }

    Invoke-FlutterCommand "Restoring dependencies (flutter pub get)" { flutter pub get }
}

# ---------------------------------------------------------------------------
# Android Builds
# ---------------------------------------------------------------------------
if ($Android -or $All) {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "  Building Android Packages (Universal + Per-ABI)" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    Invoke-FlutterCommand "Building Universal APK" { flutter build apk --release }
    Invoke-FlutterCommand "Building Per-ABI APKs (arm64, arm, x86_64)" { flutter build apk --release --split-per-abi }

    $ApkFolder = "$ProjectRoot\build\app\outputs\flutter-apk"
    Write-Host "`n[Android APKs successfully built at: $ApkFolder]" -ForegroundColor Green
    Get-ChildItem -Path $ApkFolder -Filter "*.apk" | ForEach-Object {
        $mb = [math]::Round($_.Length / 1048576, 2)
        Write-Host "    - $($_.Name) ($mb MB)" -ForegroundColor White
    }
}

# ---------------------------------------------------------------------------
# Windows Builds (Portable ZIP and Installer)
# ---------------------------------------------------------------------------
if ($Windows -or $All) {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host "  Building Windows Release, Portable ZIP and Installer" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan

    # Wipe old CMake cache if outdated target exists
    $OldVcxproj = "$ProjectRoot\build\windows\x64\runner\farm_management.vcxproj"
    if (Test-Path $OldVcxproj) {
        Write-Host "-> Removing outdated CMake target cache..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force "$ProjectRoot\build\windows" -ErrorAction SilentlyContinue
    }

    Invoke-FlutterCommand "Compiling Windows release binary" { flutter build windows --release }

    $ReleaseDir = "$ProjectRoot\build\windows\x64\runner\Release"
    $DistDir = "$ProjectRoot\build\dist"
    $InstallerDir = "$ProjectRoot\build\installer"

    if (-not (Test-Path $DistDir)) {
        New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
    }
    if (-not (Test-Path $InstallerDir)) {
        New-Item -ItemType Directory -Path $InstallerDir -Force | Out-Null
    }

    # 1. Windows Portable ZIP
    Write-Host "`n-> Packaging Windows Portable ZIP..." -ForegroundColor Yellow
    $ZipPath = "$DistDir\FarMan-Windows-Portable.zip"
    if (Test-Path $ZipPath) {
        Remove-Item $ZipPath -Force
    }
    Compress-Archive -Path "$ReleaseDir\*" -DestinationPath $ZipPath -Force
    $zipMb = [math]::Round((Get-Item $ZipPath).Length / 1048576, 2)
    Write-Host "[Windows Portable ZIP created: $ZipPath ($zipMb MB)]" -ForegroundColor Green

    # 2. Windows Installer (.exe) with Inno Setup
    Write-Host "`n-> Locating Inno Setup Compiler (ISCC)..." -ForegroundColor Yellow
    $CandidatePaths = @(
        "C:\Users\$env:USERNAME\AppData\Local\Programs\Inno Setup 6\ISCC.exe",
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files\Inno Setup 6\ISCC.exe"
    )

    $IsccExe = $null
    $cmd = Get-Command iscc -ErrorAction SilentlyContinue
    if ($cmd) {
        $IsccExe = $cmd.Source
    } else {
        foreach ($cand in $CandidatePaths) {
            if (Test-Path $cand) {
                $IsccExe = $cand
                break
            }
        }
    }

    if ($IsccExe) {
        Write-Host "Found ISCC compiler: $IsccExe" -ForegroundColor Gray
        Write-Host "-> Compiling Windows Setup Installer..." -ForegroundColor Yellow
        & $IsccExe "$ProjectRoot\windows\installer.iss"

        $InstallerExe = Get-ChildItem -Path $InstallerDir -Filter "FarMan-Setup*.exe" | Select-Object -First 1
        if ($InstallerExe) {
            $instMb = [math]::Round($InstallerExe.Length / 1048576, 2)
            Write-Host "[Windows Installer created: $($InstallerExe.FullName) ($instMb MB)]" -ForegroundColor Green
        }
    } else {
        Write-Host "`n[!] Inno Setup compiler (ISCC.exe) was not found." -ForegroundColor Yellow
        Write-Host "    Install it once via:" -ForegroundColor White
        Write-Host "    winget install JRSoftware.InnoSetup --accept-package-agreements --accept-source-agreements" -ForegroundColor Cyan
    }
}

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host "  All requested tasks finished successfully!" -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Green
