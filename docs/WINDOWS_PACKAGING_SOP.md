# SyncNexus Windows 平台打包作業標準程序書 (SOP)

本手冊專為**零基礎**使用者設計，提供最清晰、直觀、可直接複製貼上的終端機指令，引導您從零搭建環境，並將 **SyncNexus** 完整打包為：
1. **免安裝綠色單一執行檔（Portable Single-File `SyncNexus.exe`）**：雙擊即可在任何 Windows 10/11 電腦直接運行。
2. **官方標準安裝精靈（Windows Setup Installer `SyncNexus-Windows-Setup-1.0.10.exe`）**：具備桌面捷徑、開始功能表與自動反安裝程式。

---

## 一、 前置環境準備（僅需執行一次）

在 Windows 10 或 Windows 11 上，以鍵盤按下 **`Win + X`**，選擇 **「終端機 (系統管理員)」** 或 **「Windows PowerShell (以系統管理員身分執行)」**。

### 步驟 1.1：透過 Windows 內建包管工具 (winget) 一鍵安裝所需工具
複製並在 PowerShell 中貼上以下指令（按 Enter 執行）：

```powershell
winget install Microsoft.DotNet.SDK.8 --accept-source-agreements --accept-package-agreements
winget install Git.Git --accept-source-agreements --accept-package-agreements
winget install JRSoftware.InnoSetup --accept-source-agreements --accept-package-agreements
```

> [!TIP]
> 安裝完成後，請**關閉目前終端機並重新開啟一個新的 PowerShell 視窗**，以讓系統環境變數（PATH）生效。

### 步驟 1.2：驗證環境就緒
在新的 PowerShell 中輸入以下指令檢查：

```powershell
dotnet --version
git --version
```
* 當看到顯示類似 `8.0.xxx` 及 `git version 2.xx`，即代表開發與打包環境已 100% 準備完成！

---

## 二、 取得專案原始碼

若尚未下載專案代碼，請在 PowerShell 中執行：

```powershell
# 1. 建立並進入工作目錄（例如 D:\Projects 或 C:\Projects）
cd $HOME
git clone https://github.com/hauchiehlin-ops/SyncNexus.git

# 2. 進入專案根目錄
cd SyncNexus
```

---

## 三、 方法 A：一鍵全自動打包（最推薦，新手首選）

專案已內建全自動化腳本，會自動完成環境檢查、套件還原、單元測試、發布單一檔案與安裝包編譯：

在專案根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\Platforms\Windows\packaging\build-windows.ps1
```

執行完畢後，您將在以下路徑取得成品：
* **免安裝單一執行檔**：`.\publish\win-x64\SyncNexus.exe`
* **官方安裝程式**：`.\Platforms\Windows\packaging\Output\SyncNexus-Windows-Setup-1.0.10.exe`

---

## 四、 方法 B：手把手純終端機指令（手動分步操作）

若您希望親自掌控每一個步驟，請依序執行以下指令：

### 步驟 4.1：還原相依套件與單元測試
確保所有 SQLite、WinUI/WPF 及對帳演算法單元測試 100% 通過：

```powershell
# 還原 NuGet 套件
dotnet restore Platforms\Windows\SyncNexus.sln

# 執行 xUnit 核心單元測試
dotnet test Platforms\Windows\tests\SyncNexus.Core.Tests\ -c Release
```
*(看到 `已通過! - 失敗: 0，已通過: 8` 即代表代碼驗證成功)*

---

### 步驟 4.2：編譯並發布「免安裝單一執行檔 (Portable)」
此指令會將 .NET 執行階段、SQLite 原生庫及所有資源打包進單一 `SyncNexus.exe`：

```powershell
dotnet publish Platforms\Windows\src\SyncNexus.Desktop\SyncNexus.Desktop.csproj `
    -c Release `
    -r win-x64 `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -o publish\win-x64
```

> **產出驗證**：  
> 請打開檔案總管至 `publish\win-x64\`，直接雙擊 **`SyncNexus.exe`**，即可見到應用程式視窗啟動並在系統匣常駐運作！

---

### 步驟 4.3：製作「官方安裝精靈程式 (Setup.exe)」
調用 Inno Setup 編譯腳本以產出對外發行的安裝程式：

```powershell
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" Platforms\Windows\packaging\installer.iss
```
*(若 Inno Setup 安裝於 64 位元路徑，請改用 `& "C:\Program Files\Inno Setup 6\ISCC.exe" Platforms\Windows\packaging\installer.iss`)*

> **產出驗證**：  
> 完成後在 `Platforms\Windows\packaging\Output\` 目錄下會生成 **`SyncNexus-Windows-Setup-1.0.10.exe`**。  
> 執行此安裝檔可測試標準 Windows 安裝流程、建立桌面捷徑與開機自啟動設定。

---

## 五、 進階：打包 ARM64 架構版本（Surface Pro / Snapdragon X Elite 筆電）

針對採用高通處理器的次世代 Windows on ARM 裝置，可產出原生 ARM64 二進位檔：

```powershell
dotnet publish Platforms\Windows\src\SyncNexus.Desktop\SyncNexus.Desktop.csproj `
    -c Release `
    -r win-arm64 `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -o publish\win-arm64
```

---

## 六、 常見問題排除 (FAQ)

### Q1: 出現「檔案無法載入，因為這個系統上已停用指令碼執行」？
* **原因**：Windows 預設之 PowerShell 執行策略限制。
* **解法**：在終端機中執行：
  ```powershell
  Set-ExecutionPolicy -Scope Process Bypass
  ```
  然後再重新執行打包腳本即可。

### Q2: 雙擊 `SyncNexus.exe` 時 Windows Defender SmartScreen 出現警示？
* **原因**：因為此執行檔是您於本機剛編譯出的新檔案，尚未購買微軟商業代碼簽名證書（Code Signing Certificate）。
* **解法**：點擊提示視窗中的 **「其他資訊」** ➔ 選擇 **「仍要執行」** 即可。

### Q3: 想要清除之前的編譯快取重新建置？
* **指令**：
  ```powershell
  dotnet clean Platforms\Windows\SyncNexus.sln
  Remove-Item -Recurse -Force publish\, Platforms\Windows\packaging\Output\ -ErrorAction SilentlyContinue
  ```
