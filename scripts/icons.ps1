param(
    [ValidateSet("light", "dark")]
    [string]$Theme = "light",
    [switch]$SkipPubGet
)

# Regenerates the launcher icons from the light or dark artwork.
#
#   .\scripts\icons.ps1 light   # uses assets/icon/Light.png
#   .\scripts\icons.ps1 dark    # uses assets/icon/Dark.png

$ErrorActionPreference = "Stop"

$ProjectRoot = (Get-Item $PSScriptRoot).Parent.FullName
Set-Location $ProjectRoot

$ConfigFile = if ($Theme -eq "dark") { "flutter_launcher_icons_dark.yaml" } else { "flutter_launcher_icons.yaml" }

if (-not (Test-Path $ConfigFile)) {
    throw "Config file not found: $ConfigFile"
}

# flutter_launcher_icons stretches non-square sources to a square, so flag them.
Add-Type -AssemblyName System.Drawing
$Sources = Select-String -Path $ConfigFile -Pattern '^\s*image_path(?:_[a-z_]+)?\s*:\s*"?([^"#]+?)"?\s*$' |
    ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() } |
    Select-Object -Unique

foreach ($Src in $Sources) {
    if (-not (Test-Path $Src)) {
        throw "Icon source not found: $Src"
    }
    $Image = [System.Drawing.Image]::FromFile((Resolve-Path $Src).ProviderPath)
    try {
        if ($Image.Width -ne $Image.Height) {
            Write-Host "Warning: $Src is $($Image.Width)x$($Image.Height) and will be stretched to a square." -ForegroundColor DarkYellow
            Write-Host "         Export a 1024x1024 square source for undistorted icons." -ForegroundColor DarkYellow
        }
    } finally {
        $Image.Dispose()
    }
}

if (-not $SkipPubGet) {
    Write-Host "`n-> Resolving dependencies (flutter pub get)..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get failed with exit code $LASTEXITCODE"
    }
}

Write-Host "`n-> Generating $Theme launcher icons from $ConfigFile..." -ForegroundColor Yellow
dart run flutter_launcher_icons -f $ConfigFile
if ($LASTEXITCODE -ne 0) {
    throw "Icon generation failed with exit code $LASTEXITCODE"
}

Write-Host "`n[Launcher icons regenerated from $Theme artwork]" -ForegroundColor Green
