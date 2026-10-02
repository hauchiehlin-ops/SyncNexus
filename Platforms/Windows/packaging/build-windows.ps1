# ==============================================================================
# SyncNexus for Windows 一鍵全自動建置與打包腳本
# ==============================================================================
param(
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64",
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🚀 SyncNexus for Windows 官方建置與打包作業開始 " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. 檢查目前目錄與定位倉庫根目錄
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path "$scriptDir\..\..\..\"
Set-Location $repoRoot

Write-Host "[1/5] 目前工作目錄: $repoRoot" -ForegroundColor Yellow

# 2. 檢查 .NET SDK
Write-Host "[2/5] 檢查 .NET SDK 開發環境..." -ForegroundColor Yellow
if (-not (Get-Command "dotnet" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 錯誤: 系統未偵測到 'dotnet' 指令！" -ForegroundColor Red
    Write-Host "請先執行: winget install Microsoft.DotNet.SDK.8" -ForegroundColor Red
    exit 1
}
$dotnetVer = dotnet --version
Write-Host "✔ 已安裝 .NET SDK 版本: $dotnetVer" -ForegroundColor Green

# 3. 還原相依套件與單元測試
Write-Host "[3/5] 還原 NuGet 相依套件..." -ForegroundColor Yellow
dotnet restore Platforms\Windows\SyncNexus.sln

if (-not $SkipTests) {
    Write-Host "✔ 執行核心單元測試 (xUnit)..." -ForegroundColor Yellow
    dotnet test Platforms\Windows\tests\SyncNexus.Core.Tests\ -c $Configuration --no-restore --verbosity minimal
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 單元測試未通過，終止建置！" -ForegroundColor Red
        exit 1
    }
    Write-Host "✔ 核心單元測試全數通過！" -ForegroundColor Green
} else {
    Write-Host "⚠ 已跳過單元測試。" -ForegroundColor DarkGray
}

# 4. 發布免安裝單一執行檔 (Self-Contained Single File)
$outputDir = "$repoRoot\publish\$Runtime"
Write-Host "[4/5] 發布獨立單一執行檔至: $outputDir" -ForegroundColor Yellow

dotnet publish Platforms\Windows\src\SyncNexus.Desktop\SyncNexus.Desktop.csproj `
    -c $Configuration `
    -r $Runtime `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -o $outputDir

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 發布失敗！" -ForegroundColor Red
    exit 1
}

$exePath = "$outputDir\SyncNexus.exe"
if (Test-Path $exePath) {
    $sizeMB = [math]::Round((Get-Item $exePath).Length / 1MB, 2)
    Write-Host "✔ 免安裝單一執行檔建置成功: $exePath ($sizeMB MB)" -ForegroundColor Green
} else {
    Write-Host "❌ 找不到產生的執行檔: $exePath" -ForegroundColor Red
    exit 1
}

# 5. 封裝 Windows 官方安裝檔 (Inno Setup)
Write-Host "[5/5] 檢查 Inno Setup 6 打包工具..." -ForegroundColor Yellow
$isccPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
)

$isccExe = $isccPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($isccExe) {
    Write-Host "✔ 偵測到 Inno Setup: $isccExe，正在編譯安裝包..." -ForegroundColor Yellow
    $issFile = "$repoRoot\Platforms\Windows\packaging\installer.iss"
    & "$isccExe" "$issFile"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🎉 恭喜！官方安裝程式建置完成：" -ForegroundColor Green
        Get-ChildItem "$repoRoot\Platforms\Windows\packaging\Output\*.exe" | ForEach-Object {
            Write-Host "   👉 $($_.FullName)" -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "ℹ 未偵測到 Inno Setup 6（若需產生安裝精靈 .exe，請執行: winget install JRSoftware.InnoSetup）" -ForegroundColor Cyan
    Write-Host "   目前免安裝版 $exePath 已可直接於任何 Windows 10/11 電腦獨立雙擊運行！" -ForegroundColor Green
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " ✅ SyncNexus Windows 平台打包作業圓滿完成！ " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
