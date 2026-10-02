# 隱私權政策 (macOS 版)

**生效日期**：2026 年 10 月 2 日  
**應用程式**：Sync-Nexus for Mac (Mac App Store 版本)

Sync-Nexus 是一款專注於本機資料同步的工具應用程式。我們高度尊重並致力於保護使用者的個人隱私。

---

### 1. 資料收集與隱私原則
* **零伺服器、無帳號**：Sync-Nexus 完全不依賴任何雲端伺服器，使用者無須註冊任何帳號或提供個人識別資訊。
* **無遠端遙測與追蹤**：本應用程式不包含任何第三方數據統計、分析（Analytics）或遙測追蹤 SDK。
* **檔案內容不外流**：Sync-Nexus 僅在您指定的本地資料夾、外接儲存設備或同 Wi-Fi 局域網之設備間進行同步。您的所有檔案內容與檔名皆僅儲存在您本機設備與選定目錄中，絕不向外部網路傳輸。

---

### 2. Apple 沙盒機制與權限宣告說明
* **使用者選定之檔案讀寫 (`com.apple.security.files.user-selected.read-write`)**：僅用於存取您主動於系統選取視窗中選定的同步目錄。
* **安全範圍書籤 (`com.apple.security.files.bookmarks.app-scope`)**：用於在系統重啟後安全持久化保存您已授權資料夾的存取權杖。
* **外接設備存取 (`com.apple.security.files.volumes.read-write`)**：用於偵測並存取您插入的外接隨身碟或硬碟中的同步資料夾。
* **Bonjour 區域網路直連 (`_syncnexus._tcp`)**：僅用於同 Wi-Fi 局域網搜尋您的其他 Mac 或 Android 設備以建立點對點直連。

---

### 3. 聯絡我們
如果對本隱私權政策有任何疑問，請透過 GitHub Issue 與開發團隊聯絡：  
專案儲存庫：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
