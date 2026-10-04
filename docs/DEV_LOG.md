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

### 8. 側欄大綱主題分頁手冊規範 (Sidebar-Aligned Dedicated Theme Pages Manual Standard)
* 操作說明手冊必須嚴格依照側欄 7 大功能大綱分章節撰寫：
  1. **概覽 (Overview)**
  2. **差異預覽 (Diff Preview)**
  3. **資料夾 (Folders)**
  4. **衝突 (Conflicts)**
  5. **舊版本 (Versions)**
  6. **驗證紀錄 (Verification)**
  7. **設定 (Settings)**
* 每個主題必須各自形成一頁獨立主題頁面，完整說明：
  - **功能用途與目標**：解決什麼問題、核心設計考量。
  - **功能按鈕實際位置與操作方式**：點擊哪裡、怎麼操作、引導步驟。
  - **產出之現象與安全機制**：點擊後會出現什麼現象、Toast 提示、狀態徽章變化、防手殘與安全防線。
  - **真實 UI 截圖展示**：整合真實操作介面截圖，標註控制元件實際位置。
* 原生應用內操作手冊（`InAppDocumentView.swift`）亦必須支援按 7 大主題獨立分頁切換瀏覽，具備內建高解析截圖展示與 6 語系完整對應。

---

## 📜 歷史演進與問題修正紀錄表 (Changelog & Memory Archive)

### [2026-10-03] 多資料夾同步群組 (Multi-Folder Sync Groups) 架構完全落地 (維持 v1.0.12 Build 20)
#### 1. 核心資料結構與持久化註冊表 (SyncGroup & SyncGroupRegistry)
* **實作內容**：
  - 新增 `SyncGroup` 模型與執行緒安全之 `SyncGroupRegistry`（`Sources/SyncCore/SyncGroup.swift`）。
  - 自動生成或維護 `groups.json`，開箱提供 `default` 預設群組（無縫繼承現有 `state.db`，既有同步配置 100% 零破壞相容）。
  - 每個群組擁有專屬目錄隔離（`Groups/<group_id>/state.db`、`Groups/<group_id>/Versions/` 與 `Logs/SyncNexus/syncnexus_<group_id>.log`）。
  - Windows (`SyncGroup.cs`) 與 Android (`SyncGroup` data class in `SyncEngine.kt`) 同步落地對等架構。

#### 2. 多引擎實例與全管線並行排程隔離 (Per-Group Independent Pipeline)
* **實作內容**：
  - `AppModel.swift` 升級為多群組協同排程架構，為每個群組維護獨立的 `SyncService` 實例與狀態快照。
  - 各群組獨立監聽檔案系統事件（FSEvents）與專屬排程 Timer，徹底解除單一全域 SQLite 鎖爭用。群組 A 同步大容量檔案時，群組 B 的小檔案變動完全不卡頓。
  - 強化跨群組目錄重複同步防護：於端點驗證器中加入跨群組路徑衝突診斷，防止不同群組誤選重疊目錄造成同步風暴。

#### 3. 雙層分頁群組 UI 與六國語系完整對稱
* **實作內容**：
  - 在「資料夾」頁面頂部新增 `SyncGroupTabBar`：支援標籤切換、即時顯示各群組端點數、右鍵選單與管理按鈕。
  - 實作「＋ 新增同步群組」視窗（`AddGroupSheet`）與「編輯群組」視窗（`EditGroupSheet`），提供群組名稱輸入與多款精選 SF Symbols 代表圖示。
  - 在「概覽」頁面加入群組快速切換膠囊按鈕，讓使用者隨時切換檢視不同群組健康狀態。
  - `StringsTable.swift` 對稱補齊繁中、簡中、英文、日文、泰文、韓文之 18 組全新同步群組本地化字典。
  - 操作說明手冊同步更新 Apple 繁中、英文章節。

#### 4. 單元測試覆蓋與品質保證
* **實作內容**：
  - 新增 `Tests/SyncCoreTests/SyncGroupTests.swift` 單元測試套件（4 項全通過）。
  - 全專案 99 項單元測試全數通過（18 個測試套件 100% 綠燈）。
  - 嚴格遵守版本規範，版本鎖定 `1.0.12 (build 20)`。

---

### [2026-10-03] 7 大側欄主題手冊與原生多主題導覽落地 (維持 v1.0.12 Build 20)
#### 1. 操作說明手冊全面重構為 7 大側欄主題專頁
* **實作內容**：
  - 依照側欄 7 大項目（概覽、差異預覽、資料夾、衝突、舊版本、驗證紀錄、設定）各自形成獨立章節主題頁面。
  - 擷取並整合全套 7 大真實 UI 截圖 (`docs/manual/assets/`)，包含差異預覽試跑、APFS快照Toast提示、多端點資料夾管理、標記檔UUID防偽警示、衝突雙版本仲裁、歷史時光機還原、SHA-256完整性校驗與系統完全取用磁碟權限設定。
  - 詳細列出每個按鈕的實際位置、點擊操作方式、產出現象與安全機制。
  - 同步輸出 Apple、Windows、Android 繁體中文與英文完整指南。

#### 2. 原生 App 內操作手冊全面升級為雙欄主題瀏覽器
* **實作內容**：
  - `InAppDocumentView.swift` 升級為左側主題導覽列、右側主題內容頁之雙欄結構。
  - 支援載入並即時展示真實 UI 截圖（自 App Resources `ManualAssets` 或本機目錄載入）。
  - `StringsTable.swift` 補齊 7 大主題專屬之全量多國語系文字（繁中、簡中、英文、日文、韓文、泰文）。

#### 3. 截圖對應修正與六語系卡片式手冊強化
* **問題根因**：先前自動化模擬截圖時，滑鼠點擊座標產生 3 列位移偏差，導致截圖與主題對應錯置（如差異預覽誤對應到概覽、衝突誤對應到資料夾等）。
* **解決方案**：
  - 改採 macOS 原生 `AXUIElement` Accessibility API 精準觸發側欄各導覽按鈕，並以 Vision OCR 逐張驗證 7 張截圖與對應功能完全 100% 精準吻合。
  - 同步更新 `Resources/ManualAssets/` 與 `docs/manual/assets/` 全套截圖。
  - `InAppDocumentView.swift` 升級為卡片式主題導覽（標題卡、UI 截圖、功能操作、產出現象與防護、日常使用秘訣），於視窗頂部提供即時語系切換器。
  - `StringsTable.swift` 對稱補齊繁中、簡中、英文、日文、泰文、韓文之全量卡片內容與徽章標籤。

#### 4. 建置流程與資源封裝強化
* **實作內容**：
  - 更新 `Scripts/build-app.sh`，在 codesign 簽名之前先自動清理 `@ea` 與 `com.apple.quarantine` 延伸屬性，杜絕 `resource fork, Finder information not allowed` 簽名失敗。
  - 將高解析度手冊截圖資源（`Resources/ManualAssets/`）自動封裝進 `SyncNexus.app/Contents/Resources/`。
  - 嚴格遵守版本號不自動升級規範，版本鎖定 `1.0.12 (build 20)`。
  - 95 項 Swift 單元測試全部通過。

---

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

---

### [2026-10-03] v1.2.0 (Build 22)
#### 1. 多資料夾 / 多任務同步群組 (Multi-Folder Sync Groups) 完整落地
* **架構實現**：
  - 新增 `SyncGroup.swift` 核心模型，支援名稱、圖示、獨立 UUID 與獨立端點清單。
  - 新增 `SyncGroupRegistry` 註冊表，支援多群組安全持久化與預設群組自動初始化。
  - 重構 `AppModel.swift`、`FolderViews.swift` 與 `MainWindowView.swift`，在資料夾頁面頂部提供同步群組選擇標籤列（Chips）、`[＋ 新增群組]`、`[✎ 編輯同步群組]` 彈窗。
  - 每個群組擁有獨立 SQLite 狀態庫、獨立檔案監聽管線與檔案鎖（SyncLock），多任務並行完全隔離不卡頓。

#### 2. 操作說明手冊全面重構 —「零基礎、手把手」教學程序與 6 語系對齊
* **深度功能掃描與 100% 對齊**：
  - 深入掃描目前全應用程式 7 大側欄主題（概覽、差異預覽、資料夾、衝突、舊版本、驗證紀錄、設定）。
  - 將所有章節全面改寫為【零基礎新手教學：手把手操作程序】（【步驟 1】➔ 【步驟 2】➔ 【步驟 3】...），詳細說明控制元件位置、點擊後產生的畫面現象（如按鈕轉為「模擬計算中...」、頂部彈出 Toast 提示、側欄紅色衝突數字徽章變化等）與安全防護機制。
  - 4 大儲存端點接地氣加入指南（Finder ➔ 文件/個人目錄、iCloud 雲碟、Google Drive ➔ 我的雲端硬碟、外接隨身碟 ExFAT 格式）。
* **六大語系與三大平台對等**：
  - `StringsTable.swift` 內建原生手冊 `manual_topic_*` 7 大主題全新升級為手把手教學格式，繁體中文、簡體中文、英文、日文、韓文、泰文 6 語系 100% 對稱。
  - `docs/manual/apple/`（繁中、英文、簡中、日文、韓文、泰文）、`docs/manual/windows/`、`docs/manual/android/` 外部文檔全面更新。
  - 版本號全面校準為使用者指定之 `1.2.0 (build 22)`。
* **測試驗證**：
  - 全數 99 項 Swift 單元測試於 18 個測試套件中 100% 通過（含多群組持久化、隔離性、收斂性、安全防護與回退測試）。

---

### [2026-10-03] 同步群組持久化診斷與跨環境（沙盒 / 本機）雙向無縫同步修復
#### 1. 問題現象診斷
* **使用者反饋**：新增同步群組（「第二次測試」）且修改原群組名稱（「預設群組」改為「測試群組」）後，更新版本後介面回到預設狀態（新增群組不見、群組名稱變回預設）。
* **根本原因診斷**：
  1. **沙盒容器（App Sandbox Container）與一般本機路徑隔離**：
     - 在 App Sandbox 環境下（如 App Store、TestFlight 或 `--sandbox` 測試），macOS 內核將 `Application Support` 隔離映射至容器目錄：
       `~/Library/Containers/com.syncnexus.app/Data/Library/Application Support/SyncNexus/groups.json`。使用者新增的「第二次測試」與重新命名的「測試群組」完整保存在此容器內。
     - 當本機執行非沙盒更新安裝時，應用程式讀取標準路徑：
       `~/Library/Application Support/SyncNexus/groups.json`。該路徑僅留存早期開發預設資料，導致使用者產生「更新後群組遺失回到預設」的錯覺。
  2. **註冊表防禦機制不足**：
     - 原 `SyncGroupRegistry.load()` 在解碼失敗時直接回退到 `[defaultGroup]` 並調用 `save()`，具潛在覆寫風險；且缺少缺少欄位的彈性解碼保護。

#### 2. 徹底修復與防禦方案落地
* **跨環境雙向資料自動遷移與同步 (`migrateFromContainerIfNeeded`)**：
  - `SyncGroupRegistry` 啟動時自動偵測沙盒容器與本機路徑；若本機為空白或預設，而沙盒容器擁有客製化群組（如多群組或改名），自動完整遷移 `groups.json`、`Groups/` 子目錄資料庫與 `state.db`。
  - 在寫入存檔時，自動將更新鏡像同步至沙盒容器，確保無論在任何模式下啟動，資料 100% 保持一致與最新。
* **非破壞性安全讀取機制**：
  - `SyncGroup` 實作自定義 `Decodable`，所有欄位均提供安全預設回退，即使未來版本新增屬性亦永不拋出解碼錯誤。
  - 若檔案損毀，自動備份為 `.corrupted` 檔案，**嚴禁**覆寫既有檔案。
* **資料 100% 即時復原與雙群組即時運作**：
  - 已自沙盒容器完整復原使用者的「測試群組」與「第二次測試」兩大同步群組，以及各群組下的 4 大儲存端點（Mobil、本機、iCloud、GoogleDrive）。
  - 兩大群組各自獨立的背景常駐對帳服務（`syncnexus.log` 與 `syncnexus_group_50faffa5.log`）均已啟動並正常同步中。

---

### [2026-10-03] 更正：沙盒版更新後第一群組端點遺失 — 改為「手動匯入舊設定」（版本號未動）
#### 1. 先前修復為何未落地（更正前述紀錄）
* 前述「跨環境雙向自動遷移與鏡像」**只在非沙盒執行時有效**：`migrateFromContainerIfNeeded()` 在沙盒版因路徑含 `/Containers/` 直接 return；鏡像只複製 `groups.json`，未含 `state.db`／`Groups/*/state.db`；沙盒版本來就讀不到 `~/Library/Application Support/SyncNexus/`。
* 實際執行的 `/Applications/SyncNexus.app` 為沙盒版（`com.apple.security.app-sandbox`），故第一群組（`default`，端點僅存於本機 state.db）在容器內為空，第二群組（在沙盒內建立）則保留。本機資料完整未遺失。
* 教訓：驗證必須以**實際發行的沙盒簽章版**進行，不可只驗檔案內容。

#### 2. 解法：使用者授權的手動匯入（App Store 合規）
* 資料夾頁「匯入舊設定」按鈕 → `NSOpenPanel` 由使用者選取舊設定資料夾（亦接受上一層 Application Support）→ `SyncGroupRegistry.importLegacySettings(from:)`。
* 規則：已設定且有端點的群組**絕不覆寫**；本機群組為空才以舊資料取代，被取代的檔案改名為 `.pre-import-<時間戳>` 備份；新群組直接加入。WAL 資料庫先複製到暫存並 checkpoint 後再落地，確保一致。
* 匯入前停止所有服務、匯入後重啟；Toast 回報結果（六語系）。若端點資料夾於沙盒內顯示離線，需重新選取一次以重新授權 bookmark。
* 新增 2 項單元測試（共 101 項全通過）。未匯入 `Versions/` 歷史庫。

### [2026-10-03] 啟動自動備份與一鍵還原（版本號未動）
* `SyncGroupRegistry.backupNow()`：每次啟動（及還原前）把 `groups.json` 與各群組 `state.db`（WAL checkpoint 後的一致性快照）備份到 `<App Support>/Backups/Registry/<時間戳>/`，附 `manifest.json`（群組名、端點數、指紋）。
* 防護：內容沒變就不重複備份；空白狀態（0 個端點）在已有備份時不備份，也不會擠掉最後一份含端點的備份；保留最新 10 份；同秒備份不會覆蓋既有備份。
* 「資料夾」頁新增「從備份還原」選單（列出時間、群組、端點數）→ 確認 → `restore()`：還原前先備份目前狀態，被取代檔案改名 `.pre-restore-<時間戳>`。六語系補齊。
* 因備份存於 App Support，沙盒版即位於容器內 `Backups/`。限制：與資料同處於容器，若整個容器被刪除則備份一併消失。
* 新增 1 項來回測試（共 102 項全通過）。

### [2026-10-03] 介面語系與內容不一致修正（版本號未動）
* **根因**：(1) 預設端點名稱（`loc("kind_local")`）與預設群組名稱建立當下的語系被「凍結」進資料庫／groups.json（如「本機」「預設群組」），之後切換語系不會變；(2) SyncCore 引擎、驗證器、服務層約 90 種使用者可見訊息（錯誤、略過原因、預覽、確認提示、端點離線原因…）寫死繁體中文，無本地化。
* **做法**（顯示層翻譯，不改同步邏輯，因引擎邏輯依賴這些字串）：
  - `CoreMessages.swift` + `CoreMessageTemplates.swift`：將引擎訊息樣板整句比對後以 `loc` 翻譯，參數遞迴翻譯；`StringsTable` 新增 90 組 `core_*` 六語系字典。
  - `AppModel.snap` 改為翻譯後快照（語系切換即時重算），原始快照保留給邏輯判斷（`pendingCloud`、`rawDetail`）。預覽、驗證訊息、錯誤 Toast 同步翻譯。
  - `DisplayNames`：App 自動產生的端點名（本機/Local/本地…）與預設群組名依目前語系顯示；新增本機端點改存中性 ID `Local`。
* **限制**：使用者自行輸入的群組／端點名稱（如「家庭相片」「第二次測試」）保持原樣，不會被翻譯。`.log` 檔本身仍為中文。

### [2026-10-03] 群組刪除入口與「預設群組名稱隨語系」（版本號未動）
* 「家庭相片」「工作專案」並非系統預設（僅出現在輸入框範例與手冊），是使用者端在沙盒內輸入建立的空群組。刪除入口原本只有標籤右鍵與「編輯」視窗，不易發現：現於群組橫幅「編輯」旁新增紅色「刪除群組」按鈕（先點選該群組標籤即可），統一走 `AppModel.confirmAndDeleteGroup` 確認後刪除（不刪實體檔案）。
* 新增群組未輸入名稱時，`groups.json` 儲存空字串，不再凍結成當下語系的文字；顯示時依語系呈現「新增群組 / New Group / 새 그룹…」，多個未命名群組自動編號（` 2`、` 3`）。使用者自行輸入的名稱維持原樣。僅 macOS 端；Windows／Android 的對等實作尚未同步。

### [2026-10-03] 「未命名群組名稱隨語系」同步至 Windows / Android（版本號未動）
* 與 macOS 相同規則：未命名群組存空字串、顯示時依語系呈現「新增群組 / New Group / 새 그룹…」並自動編號；內建預設群組（id `default`）以固定標記名儲存，顯示時依語系呈現；使用者自行輸入的名稱不變。
* **Windows**：`Core/Model/SyncGroupNaming.cs`（純邏輯）、`LocalizationService` 新增 5 組六語系字串與 `GetAllLanguages`、`MainViewModel` 的建立／刪除群組訊息改為本地化並新增 `GroupDisplayName`；`CoreTests` 新增 2 項測試。**此環境無 dotnet，Windows 端未編譯、未執行測試**，需在 Windows 開發機 `dotnet test` 驗證。
* **Android**：`SyncGroupNaming.kt`（純邏輯＋以各語系資源辨識預設名稱），六個 `strings.xml` 新增 `group_default_name`、`group_new_default_name`；`SyncGroupNamingTest` 3 項測試以 `gradle :app:testDebugUnitTest` 實測通過。
* 備註：上述備註已過時 — 群組切換 UI 已於下一則紀錄補齊。

### [2026-10-03] Windows / Android 同步群組完整落地：切換畫面、獨立資料與持久化（版本號未動）
* **Android**：`SyncNexusEngineBridge` 改為多群組（`groups`、`activeGroupId`、各群組獨立端點清單；預設群組沿用原 `endpoints_json` 鍵，既有安裝不遺失資料夾）；`SyncGroupOps`（純邏輯，含「同一資料夾不得屬於兩個群組」）；`MainActivity` 新增群組卡片（FilterChip 切換、新增／編輯／刪除對話框、emoji 圖示）；六語系字串補齊；背景對帳會逐一對帳所有群組。`gradle :app:testDebugUnitTest`（5 項）與 `compileDebugKotlin`、`processDebugResources` 實測通過。
* **Windows**：`SyncGroupRegistry`（groups.json，損毀檔另存 `.corrupted-*` 不覆寫；預設群組沿用 `state.db`，其餘 `Groups/<id>/state.db`）、`GroupManager`（每群組獨立 SqliteStore + SyncEngine）、`BackgroundSyncService` 與 `WindowsDeviceWatcher` 改為多群組（每群組獨立檔案監聽、逐群組對帳）、`MainViewModel` 群組清單／切換／新增／編輯／刪除、`MainWindow.xaml` 群組列、`GroupDialog`、六語系字串；`CoreTests` 新增 3 項註冊表測試。**此環境無 dotnet：Windows 端全部程式未編譯、未執行**，必須在 Windows 開發機執行 `dotnet build` 與 `dotnet test` 後才能視為完成。
* 上述「尚未同步」清單已於下一則紀錄補齊。

### [2026-10-03] macOS 功能移植至 Windows / Android：自動備份與還原、匯入舊設定、巢狀路徑檢查（版本號未動）
* **規則與 macOS 一致**：每次啟動自動備份（內容沒變不重備、空白狀態在已有備份時不備份且不擠掉最後一份含資料夾的備份、保留最新 10 份、同秒備份不覆蓋）；還原前先備份目前狀態；匯入時已設定的群組絕不覆寫、空群組補入、未知群組新增；資料夾不得同時屬於兩個群組，且「巢狀（一個在另一個裡面）」也視為重疊。
* **Android**（`GroupBackupLogic.kt`、`GroupBackupStore.kt`、`SyncGroupOps.kt`、`MainActivity` 的「備份」選單）：備份存於 `filesDir/Backups/Registry/<時間戳>/snapshot.json`；選單含「從備份還原」「匯出設定…」「匯入設定…」（以 SAF 檔案選擇器，由使用者授權選檔，符合 Google Play 規範）；SAF 樹 URI 以解碼後的 document id 判斷巢狀；同群組巢狀與跨群組重疊皆有提示。六語系字串補齊。單元測試共 10 項，`gradle :app:testDebugUnitTest` 實測通過。
* **Windows**（`GroupBackups.cs`、`LegacyImport.cs`、`GroupDatabaseFiles.cs`、`FolderOverlap.cs`、`GroupManager`、`MainWindow` 群組列新增「從備份還原」「匯入舊設定」按鈕）：SQLite 資料庫以「複製到暫存＋WAL checkpoint」取得一致快照；還原／匯入透過 `BackgroundSyncService.RunExclusiveAsync` 在無同步進行時執行，並先關閉資料庫；被取代檔案改名 `.pre-restore-*` / `.pre-import-*`。六語系字串補齊；`CoreTests` 新增 3 項。**此環境無 dotnet：Windows 端所有程式與測試均未編譯、未執行**，須在 Windows 開發機 `dotnet build` / `dotnet test` 驗證。
* 與 macOS 的差異：Windows／Android 無 Toast，結果以狀態列（Windows）或 Toast（Android）顯示；備份同樣存放於 App 資料夾內，若整個資料夾被刪除，備份會一併消失（Android 另提供「匯出設定」可存到容器之外）。

### [2026-10-03] 選單列彈出視窗改為「依同步群組」呈現（版本號未動）
* 原本彈出視窗只列出「目前選中群組」的資料夾，多群組時看不到其他群組。現改為：多於一個群組時，「同步群組」區塊逐群組顯示（群組圖示／名稱／資料夾數／該群組狀態晶片，其下縮排列出各端點）；點群組標題會切換到該群組並開啟「資料夾」頁。單一群組維持原本清單外觀。
* 頂部狀態環與標題改為**全群組彙總**（最需要注意者優先；全部暫停才顯示暫停；有多群組時訊息前綴群組名稱）；警示橫幅（錯誤／需確認／衝突／損毀）逐群組列出，按鈕先切換到該群組再處理；最近活動合併所有群組；「立即同步」與暫停／繼續改為作用於所有群組；選單列圖示也依最需要注意的群組顯示。
* `AppModel` 新增 `groupStates`、`popoverOverall/Title/Detail`、`allPaused`、`syncAllNow`；其他群組的快照更新也會觸發彈出視窗重繪。
* 僅 macOS（Windows 系統匣選單與 Android 通知目前不含逐群組清單）。

### [2026-10-03] 三平台對等補齊：Windows 系統匣選單／Android 通知改為逐群組呈現（版本號未動）
* 對應 macOS 選單列彈出視窗的規則：頂部狀態為全群組彙總（有需要處理者優先；只有「尚未加入 2 個資料夾」的新群組不影響「全部已同步」）；逐群組列出名稱、資料夾數與各自狀態。**教訓：新功能必須三平台同回合完成，不可只做 macOS 再事後補。**
* **Android**：`SyncNexusEngineBridge.groupStates`（每群組資料夾數、同步中、衝突數、錯誤）、`GroupStatusLogic`（純邏輯）；前台服務通知改為 InboxStyle：標題＝整體狀態，展開後每個群組一行「名稱 · n 個資料夾 · 狀態」，狀態變化即時更新。六語系字串補齊，單元測試共 11 項，`gradle :app:testDebugUnitTest` 實測通過。
* **Windows**：`GroupStatusLogic.cs`（純邏輯）；系統匣選單每次開啟時動態建立：開啟主視窗／立即對帳（所有群組）／每個群組一個項目（圖示、名稱、資料夾數、狀態），其子選單列出各資料夾的上線狀態並可「在主視窗檢視此群組」／結束；系統匣提示文字顯示全群組彙總。六語系字串補齊；`CoreTests` 新增 1 項。**此環境無 dotnet，Windows 端未編譯、未執行**，須在 Windows 開發機驗證。

### [2026-10-03] 被同步的資料夾在檔案管理員中顯示所屬群組圖示（三平台，版本號未動）
* **macOS**：`FolderIcon.swift` 以系統資料夾圖示疊上群組的 SF Symbol（`NSWorkspace.setIcon`）；`AppModel.refreshFolderIcons()` 以「期望 vs 已套用」差異比對，只在資料夾加入／移除、群組圖示變更、群組刪除、磁碟重新上線時動作；只移除自己套用的圖示（記錄於 UserDefaults）。群組維持預設的「folder」圖示則不改動資料夾。設定頁新增「資料夾圖示跟隨同步群組」開關（預設開，關閉即還原）。
* **Windows**：`FolderIconService`（WPF 繪製資料夾＋群組 emoji → 256px PNG 封裝成 `.syncnexus-icon.ico`，搭配隱藏的 `desktop.ini` 與資料夾唯讀旗標，`SHChangeNotify` 通知檔案總管重繪）；他人寫的 `desktop.ini` 絕不覆蓋。主視窗設定列新增同名開關。
* **Android**：作業系統不支援自訂資料夾圖示，無法實作；群組圖示僅顯示於 App 內。但為避免 Mac／Windows 產生的圖示檔被同步進來，三平台的忽略規則一併新增 `Icon\r`（含 `._Icon\r`）與 `.syncnexus-icon.ico`（`IgnoreRules` 共用於 Swift、C#、Kotlin 新增 `AndroidIgnoreRules`）。
* 順帶修正 Android 既有錯誤：忽略清單用「小寫名稱」比對，但清單內含大小寫混合項目（如 `.DS_Store`），導致永遠比對不到。
* 副作用須知：開啟後每個群組資料夾內會多一個隱藏小檔案（macOS：`Icon\r`；exFAT 磁碟另有 `._Icon\r`；Windows：`desktop.ini`＋`.syncnexus-icon.ico`）；iCloud／Google Drive 可能把它同步到您自己的其他裝置，不影響內容。
* 測試：Swift 104 項、Android 12 項實測通過；Windows 新增 1 項測試**未編譯執行（無 dotnet）**。

### [2026-10-03] 安全排除開關狀態同步修正、刪除群組入口常駐與設定頁管理
* **開關無法切換修正**：`AppModel.setExclude` 與 `setPolicy` 加入樂觀狀態更新；`SyncService.setExcludePresets` 與 `setConflictPolicy` 在寫入 SQLite 後立即更新快照並呼叫 `publish()`，修復開關點擊後立刻彈回原位的狀態問題；`SyncService.start()` 啟動時立即自資料庫載入最新設定。新增 1 項單元測試驗證持久化與發佈。
* **排除原則說明強化**：設定頁新增說明文案，闡明預設排除乃為了避免資料庫鎖檔與版本庫損壞，並保留開關給需要特定工作流程（如完整程式碼備份）的使用者手動微調。
* **刪除同步群組入口常駐**：
  - 「資料夾」橫幅與「編輯群組」彈窗的「刪除群組」按鈕改為常駐顯示（僅剩最後一個群組時呈現禁用並顯示提示「無法刪除最後一個同步群組」），解決只有 1 個群組時完全看不到刪除按鈕的問題。
  - 「總覽」頁面群組標籤新增右鍵選單（編輯／刪除）。
  - 「設定」頁面新增「同步群組」卡片，集中管理所有群組並提供切換、編輯與刪除入口。
* 測試：Swift 全套 109 項單元測試通過。

### [2026-10-04] 即時同步進度回報、協同取消作業、強制安全排除防護與生命週期強化（v1.6.0 Build 30）
* **版本號升級**：v1.6.0（Build 30），`VERSION`、`BUILD_NUMBER`、`Scripts/Info.plist`、`packaging/homebrew/syncnexus.rb`、`Platforms/Android/app/build.gradle.kts` 一致同步。
* **即時同步進度與協同取消**：
  - `Engine` 支援即時狀態發佈 `SyncProgress`（準備、掃描、比對、傳輸、驗證、完成、取消），包含傳輸檔案位元組進度、當前檔案路徑與所屬端點。
  - `SyncService` 支援非阻塞式取消當前同步任務 `cancelCurrentRun()`，並以最高 10Hz 節流發佈快照，階段轉換零遺漏。
  - `FileOps.copyAtomically` 與 `sha256` 支援協同中斷 `shouldCancel`，傳輸中斷時立即清除 `.nexus-part` 暫存檔，確保目標端點不留破碎檔案。
  - 主視窗與選單列 Popover 均常駐即時進度條、當前處理檔案路徑、總體百分比與「取消作業」按鈕。
* **強制安全排除原則（Hardened Exclusion Rules）**：
  - 將容易因同步造成損壞的活體資料（`.git` 版本庫、使用中的 SQLite 資料庫、macOS 照片圖庫、`node_modules`）固化為「強制安全排除原則」（`ExcludePreset.defaults = allCases`），杜絕因誤關閉開關導致版本庫或資料庫損毀。
  - 設定頁改以安全盾牌標章呈現，並更新六國語言說明；加入舊版設定遷移相容邏輯與單元測試。
* **異步生命週期與長耗時作業防護**：
  - 匯入舊設定（`importLegacySettings`）、建立 APFS 快照（`createAPFSSnapshot`）、還原備份與刪除群組等作業加入全域狀態指示橫幅（`appOperationStatus`），防止重複觸發。
  - 應用程式結束（`quit`）改用非同步優雅停止 `stopAndWait()` 確保 SQLite 與佇列安全收尾，並具備 12 秒緊急退出保護，避免遭雲端冷檔案卡死。
* **多語系完整覆蓋與測試驗證**：
  - `StringsTable.swift` 補充繁中、簡中、英文、日文、泰文、韓文六國語言之取消、進度階段、強制排除原則說明及狀態橫幅字串。
  - Swift 單元測試增至 111 項全數通過（新增進度單調性與中斷清理等單元測試）；Android 單元測試及 Release 打包驗證均成功。

### [2026-10-04] 大規模海量檔案同步極限加速：APFS 零拷貝、多核自適應雜湊與資料庫性能調優
* **APFS 寫入時複製（Copy-on-Write / `clonefile(2)`）零拷貝加速**：
  - 在 `FileOps.copyAtomically` 引入 macOS 原生 `clonefile` 支援。當同步來源與目的地處於相同 APFS 卷冊時，利用 Extents 引用共享實現零 I/O 實體拷貝，大檔與海量檔案複製從數分鐘縮短至毫秒級；非 APFS 或跨卷冊/抽取式儲存設備自動安全降級為串流寫入。
  - 新增單元測試 `apfsCloneOrAtomicCopyPreservesContentAndMetadata` 驗證內容一致性與時間戳元數據保留。
* **CPU 多核心自適應雜湊擴展（Prehash Scaling & Zero-Contention）**：
  - 解除原本固定的 4 worker 限制，改為依據 `ProcessInfo.activeProcessorCount` 動態分配（最高 16 workers），徹底發揮 Apple Silicon M 系列多核能力。
  - 工作執行緒改用各自獨立的局部字典收集雜湊結果，消除在海量檔案雜湊時的高頻 `NSLock` 競爭。
* **SQLite 核心記憶體調優（Cache Size & In-Memory Temp Store）**：
  - 啟用 `PRAGMA cache_size=-64000;`（64MB 快取池）與 `PRAGMA temp_store=MEMORY;`，確保在十萬至百萬筆檔案記錄的索引比對與 B-Tree 搜尋時完全駐留記憶體，免除頻繁磁碟換頁。
* **驗證結果**：
  - Swift 全套 19 個測試套件共 112 項測試全數通過（9.5 秒內完成）；Android 單元測試通過；官方憑證簽署建置成功。


