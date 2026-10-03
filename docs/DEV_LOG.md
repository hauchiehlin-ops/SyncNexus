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

### 5. 版本號控制規範 (Strict User-Controlled Versioning Rule)
* **嚴禁自動提升版本**：每次程式碼修正後，**嚴禁**自動增加或更新版本號（Git pre-commit 預設禁用自動 bump）。
* **由使用者自主決定**：版本升級與建置號碼提升，必須完全由使用者明確下達指令、或於執行正式發布打包時決定。

### 6. 說明手冊親和力規範 (Colloquial & Grounded Manual Writing Rule)
* 說明手冊嚴禁充斥抽象底層路徑（如 `~/Library/Mobile Documents/` 或 `CloudStorage` 等非使用者慣用語）。
* 必須使用最「接地氣」、最貼近終端使用者日常操作的白話指導：如「點開 Finder」、「點擊左側側邊欄的 iCloud 雲碟」、「點擊側邊欄 Google Drive ➔ 我的雲端硬碟」、「插上隨身碟」等。

### 7. 原生應用內文件瀏覽規範 (In-App Native Document Presentation Rule)
* 操作說明手冊與隱私權保護政策**嚴禁**呼叫外部瀏覽器跳轉至 GitHub 介面。
* 必須在 App 內以原生 Sheet / 視窗彈出，具備乾淨排版、關閉按鈕與離線閱讀能力，提供專業商用軟體之精緻體驗。

---

## 📜 歷史演進與問題修正紀錄表 (Changelog & Memory Archive)

### [2026-10-03] v1.0.12 (Build 20)
#### 1. 版本控制權限移交給使用者
* **修正內容**：修改 `.githooks/pre-commit`，移除每次 commit 自動執行 patch bump 的機制。未來版本號維持固定，僅在使用者明確要求打包更新時才升級。

#### 2. 原生應用內操作手冊與隱私權政策實作
* **修正內容**：
  - 建立 `InAppDocumentView.swift` 原生視窗元件。
  - 於 `MainWindowView.swift` 綁定 `.sheet(item: $activeDocument)`，點擊頂部「📖 操作手冊」與「🛡️ 隱私政策」時，直接於 App 內彈出精緻原生 Sheet，不再跳轉外部 GitHub 網頁。
  - 同步於 `StringsTable.swift` 補足 6 種語言之全量翻譯字典。

#### 3. 操作手冊內容全面「接地氣」化
* **修正內容**：
  - 徹底移除 `~/Library/...` 等生硬系統路徑。
  - 將 macOS、Windows、Android 手冊內容全面改寫為日常操作引導（如「點開 Finder」、「點擊側邊欄 iCloud 雲碟」、「點擊 Google Drive ➔ 我的雲端硬碟」等）。

#### 4. 多資料夾 / 多任務同步群組 (Multi-Folder Sync Groups) 架構評估
* **評估成果**：
  - 分析業界成熟方案（FreeFileSync 任務對模型 vs. Syncthing 資料夾群組模型）。
  - 確認 SyncNexus 演進路徑：採用「同步群組（Folder Groups）」模型，支援單機多任務獨立對帳、獨立排程、獨立版本庫。

---

### [2026-10-03] v1.0.11 (Build 19)
#### 1. APFS 沙盒快照權限診斷與友善化處理
* **問題現象**：使用者在「差異預覽」點擊「APFS 快照安全防護」時，彈出 `Command exited with status 73 (EX_CANTCREAT)`。
* **根本原因**：macOS App Store 沙盒（App Sandbox）限制非特權程序執行 `tmutil` 建立容器快照。
* **解決方案**：加入沙盒偵測與 6 語系友善說明，引導使用者依賴內建 `.syncnexus-history` 版本歷史庫。

#### 2. 移除頁尾固定提示列，全面升級為懸浮快顯 Toast HUD
* **解決方案**：移除底部頁尾條，改用 `.overlay(alignment: .top)` 實現頂級毛玻璃懸浮 Toast HUD。

#### 3. 首頁頁首頂部全域導覽列落地
* **解決方案**：將語系選擇、手冊與隱私入口移至視窗最頂端全域 Header Top Bar。

---

### [2026-10-02 ~ 2026-10-03] v1.0.10 (Build 18)
#### 1. Windows 平台架構擴展與核心對帳引擎落地
* 建立 .NET 9 WPF 應用程式與 `SyncNexus.Core` 核心對帳引擎。
* 產出零基礎手把手 Windows 打包程序書 (`docs/WINDOWS_PACKAGING_SOP.md`)。

#### 2. 各平台商店審查標準合規政策手冊
* 輸出 Apple 5.1.1、Google Play SAF、Microsoft Store 10.5 政策手冊。
