# SyncNexus for Windows

本目錄為 **SyncNexus** 的 Windows 原生平台實作（基於 **.NET 9 / C# / WPF + Fluent UI**），提供與 macOS 及 Android 完全相容的無伺服器多端點雙向即時對帳同步能力。

---

## 支援的同步對象與相容性

1. **本機資料夾**：
   - 支援任意本機 NTFS / ReFS 資料夾。
   - 透過 `app.manifest` 啟用 `longPathAware`，突破傳統 Windows 260 字元限制。
2. **Google Drive（與 Apple 平台互通）**：
   - 支援 Google Drive 電腦版虛擬串流磁碟（如 `G:\My Drive`）與本機鏡像目錄。
   - 透過 Win32 檔案屬性自動辨識 `FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS` 佔位符，避免在未快取時引發全量下載。
   - 自動過濾 `.gdoc`、`.gsheet` 等網頁指標檔。
3. **OneDrive（與 Apple 平台互通）**：
   - 支援隨選檔案（Files On-Demand，`IO_REPARSE_TAG_FILE_PLACEHOLDER`）。
   - 自動忽略 Office 鎖定暫存檔案（`~$*`）。
4. **外接式磁碟（ExFAT / FAT32 跨平台共用）**：
   - 支援格式化為 ExFAT 之隨身碟/外接硬碟於 macOS (`/Volumes/...`) 與 Windows (`D:\`, `E:\`...) 交叉插拔。
   - 透過 **磁碟卷標（Volume Label）** 與 **磁碟序號（Volume Serial Number）** 動態對齊磁碟機代號。
   - 讀取已存在之 `.syncnexus-endpoint` 安全標記碼，避免雙系統切換時誤觸離線防護。
   - 嚴格隔離兩造作業系統垃圾（`.DS_Store`、`._*` vs `Thumbs.db`、`$RECYCLE.BIN`、`desktop.ini`）。

---

## 專案結構

```
Platforms/Windows/
├── SyncNexus.sln                       # Visual Studio / dotnet 解決方案
├── src/
│   ├── SyncNexus.Core/                 # 核心領域模型、對帳演算法、SQLite 儲存庫
│   │   ├── Model/                      # EndpointConfig, FileState, Consensus, Report
│   │   ├── Engine/                     # Reconciler, PortableName, IgnoreRules, ConflictNaming, SyncEngine
│   │   ├── Storage/                    # SqliteStore (與 macOS state.db 完全相容)
│   │   └── IO/                         # FileOps, WindowsCloudPlaceholderDetector, WindowsVolumeHelper
│   └── SyncNexus.Desktop/              # Windows 桌面應用程式 (WPF / Fluent Design)
│       ├── ViewModels/                 # MainViewModel, EndpointItemViewModel
│       └── app.manifest                # 啟用長路徑與 PerMonitorV2 高解析度感知
└── tests/
    └── SyncNexus.Core.Tests/           # 核心規格與演算法單元測試 (xUnit)
```

---

## 建置與測試

### 需求環境
- Windows 10 (1809 以上) 或 Windows 11
- .NET 8.0 SDK 或 .NET 9.0 SDK
- Visual Studio 2022 (推薦) 或 VS Code / JetBrains Rider

### 編譯指令
```powershell
# 還原相依套件與建置
dotnet build Platforms/Windows/SyncNexus.sln -c Release

# 執行核心單元測試
dotnet test Platforms/Windows/tests/SyncNexus.Core.Tests/
```

### 發布獨立單一執行檔（Self-contained Single File）
```powershell
dotnet publish Platforms/Windows/src/SyncNexus.Desktop/SyncNexus.Desktop.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./publish/windows
```
