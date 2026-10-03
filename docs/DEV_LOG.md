# 📘 SyncNexus 跨平台開發日誌與記憶日誌 (Development & Memory Log)

本文件為 **SyncNexus** 專案的永久核心架構與演進記憶檔案。  
**任何後續開發、功能新增、介面編輯、Bug 修正，均必須嚴格遵循本文件規範，並於文末追加紀錄。**

---

## 🏛️ 核心開發與設計強制準則 (Core Architectural Mandates)

### 1. 三平台對等原則 (Tri-Platform Parity Rule)
所有核心功能、防護機制、設定選項均必須同步考量並落地於三大目標平台，禁止任一平台功能缺漏或虛偽實作：
* **Apple macOS**: Swift 5.10 / SwiftUI + AppKit、App Sandbox 安全沙盒、Security-Scoped Bookmarks。
* **Google Android**: Kotlin 2.0 / Jetpack Compose、Scoped Storage (Storage Access Framework)、Foreground Service (`FOREGROUND_SERVICE_DATA_SYNC`)。
* **Microsoft Windows**: C# 12 / .NET 9 WPF、Win32 Shell API（資源回收筒 `SHFileOperationW`）、Cloud Files API 佔位符相容、Registry 開機啟動。

### 2. 六語系對等原則 (Hexa-Lingual Parity Rule)
任何新增的 UI 文字、錯誤提示、警告對話框、說明手冊與隱私政策，必須同時支援以下 6 種語系，禁止硬編碼單一語言：
1. **繁體中文 (`zh-Hant`)**：台灣、香港等正體中文用語習慣。
2. **簡體中文 (`zh-Hans`)**：中國大陸通用術語。
3. **英文 (`en`)**：國際通用與 App Store / Google Play 審查基準。
4. **日文 (`ja`)**：日本市場本土化用語。
5. **韓文 (`ko`)**：韓國市場本土化用語。
6. **泰文 (`th`)**：泰國市場本土化用語。

### 3. 無侵入式快顯提示規範 (Non-Intrusive Floating Toast UX)
* **禁止放置於頁尾 (Footer)**：任何操作狀態反饋、錯誤告警、試跑結果、權限限制訊息，**一律嚴禁**置於視窗底部或頁尾固定列，避免遮擋資訊或產生破版視覺。
* **快顯提示 (Floating Toast HUD)**：所有提示必須以懸浮卡片（Floating Toast / HUD / Snackbar）形式，由頂部滑入或浮動於主要視窗上方，具備毛玻璃材質（Material）、陰影、清楚關閉按鈕，並於 5~7 秒內平滑自動淡出。

### 4. 首頁頁首入口規範 (Top Header Navigation)
* 視窗頂部導覽列（Top Header）必須常駐提供：
  1. **介面語系下拉選單** (`Language Selector`)：即時切換即刻生效。
  2. **操作說明手冊按鈕** (`📖 User Manual`)：點擊開啟對應平台與語言之手冊。
  3. **隱私權政策按鈕** (`🛡️ Privacy Policy`)：點擊開啟對應平台與語言之隱私權條款。
* 無論使用者切換至「概覽」、「差異預覽」、「資料夾」或任何子分頁，頁首導覽均應清晰可見。

---

## 📜 歷史演進與問題修正紀錄表 (Changelog & Memory Archive)

### [2026-10-03] v1.0.11 (Build 19)
#### 1. APFS 沙盒快照權限診斷與友善化處理
* **問題現象**：使用者在「差異預覽」點擊「APFS 快照安全防護」時，彈出 `建立快照失敗（可能需要系統管理員權限）：Failed to create local snapshot NOTE: local snapshots are considered purgeable... Command exited with status 73 (EX_CANTCREAT)`。
* **根本原因**：macOS App Store 發行版本必須啟用 App Sandbox (`com.apple.security.app-sandbox`)。在沙盒限制下，應用程式無法直接調用系統底層 root 權限的 `/usr/bin/tmutil` 建立整機 APFS 快照容器，導致回傳 73 號錯誤。
* **解決方案**：
  - 在 `APFSSnapshotManager.swift` 內加入沙盒環境偵測（`APP_SANDBOX_CONTAINER_ID`）。
  - 當處於沙盒環境時，不丟擲底層 Unix 錯誤，而是顯示友善的多國語系安全說明（告知使用者沙盒限制，並說明 SyncNexus 已透過內建的 `.syncnexus-history` 多版本歷史機制全程守護）。
  - 同步補充 6 種語系翻譯（`msg_apfs_sandbox_active`, `msg_apfs_success`, `msg_apfs_failed_fallback`, `msg_apfs_unsupported`）。

#### 2. 移除頁尾固定提示列，全面升級為懸浮快顯 Toast HUD
* **問題現象**：舊版錯誤訊息出現在視窗最底部的頁尾長條列，造成視覺擁擠與干擾。
* **解決方案**：
  - 徹底移除 `MainWindowView.swift` 頁尾底欄。
  - 改用 `.overlay(alignment: .top)` 實現頂級毛玻璃懸浮 Toast HUD（動態淡入、彈簧動畫、陰影與關閉按鈕，並在 7 秒後自動平滑消失）。

#### 3. 首頁頁首頂部全域導覽列落地
* **問題現象**：前版僅將語系與手冊按鈕加在「概覽」捲軸內，切換到其他分頁（如差異預覽）時即消失，且舊編譯版本尚未替換。
* **解決方案**：
  - 將「語系下拉選單」、「操作說明手冊」及「隱私權政策」移至 `MainWindowView` 右側內容區最頂端的常駐導覽列（Header Top Bar）。
  - 所有子分頁（概覽、差異預覽、資料夾、衝突、舊版本、驗證紀錄、設定）均統一擁有頂部入口。

---

### [2026-10-02 ~ 2026-10-03] v1.0.10 (Build 18)
#### 1. Windows 平台架構擴展與核心對帳引擎落地
* **需求**：擴展 Windows 10/11 平台，支援本機資料夾、Google Drive、OneDrive、跨平台 ExFAT 外接磁碟。
* **實作內容**：
  - 建立 .NET 9 WPF 應用程式與 `SyncNexus.Core` 核心對帳引擎。
  - 實作 Win32 安全刪除至資源回收筒（`SHFileOperationW`）。
  - 雙棧區域網路設備發現（mDNS `224.0.0.251:5353` 與 UDP Beacon）。
  - 撰寫 Inno Setup 6 打包腳本與自動化編譯腳本 `build-windows.ps1`。
  - 產出零基礎手把手 Windows 打包程序書 (`docs/WINDOWS_PACKAGING_SOP.md`)。

#### 2. 各平台應用程式商店審查標準合規文件
* **實作內容**：
  - Apple App Store Review Guidelines 5.1.1、沙盒與安全性書籤政策手冊。
  - Google Play User Data Policy、SAF 儲存空間與前台服務揭露說明手冊。
  - Microsoft Store Certification Policy 10.5 隱私權政策與開機啟動說明手冊。

#### 3. Windows CI 建置錯誤修正
* **問題現象**：GitHub Actions Windows .NET Build 報錯 `TaskbarIcon does not exist in XML namespace http://hardcodet.net/taskbar` 以及缺少 `System.IO`、`SyncNexus.Core.Model`。
* **解決方案**：修正 XAML 命名空間為 `xmlns:tb="clr-namespace:H.NotifyIcon;assembly=H.NotifyIcon.Wpf"` 並補齊服務層引用，達成全平台 CI 100% 綠燈。

---

### [2026-10-02] v1.0.9 (Build 17)
#### 1. 6 國語系深度在地化
* 涵蓋 `StringsTable.swift` 超過 2000 行鍵值對，全面覆蓋所有卡片、對話框、快顯訊息。
#### 2. 外接磁碟與離線偵測精準化
* 區分「硬體拔除（Unplugged）」與「磁碟錯誤（Offline）」，避免外接資料夾被誤判。
