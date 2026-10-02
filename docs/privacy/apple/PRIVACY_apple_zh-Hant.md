# SyncNexus 隱私權政策 — Apple (App Store 審查專用)

**生效日期**：2026 年 10 月 3 日  
**發行平台**：Apple App Store (macOS / iOS / iPadOS)  
**開發團隊**：SyncNexus Team  

SyncNexus 始終堅持「隱私是基本人權」之理念。本隱私權政策嚴格遵循 **Apple App Store Review Guidelines (特別是 5.1.1 數據收集與儲存規範)**，明確說明本應用程式的無資料收集與本機運作原則。

---

### 1. 零資料收集與零遙測（No Data Collection）
* **無遠端資料傳輸**：SyncNexus 不具備任何遠端上傳伺服器。您的檔案內容、檔案名稱、路徑結構與 SHA-256 驗證雜湊值，**100% 僅儲存於您本機設備與您親自指定的同步資料夾中**。
* **無第三方 SDK / 無追蹤碼**：本應用程式完全不包含任何第三方數據統計、廣告投遞、分析（Analytics）或 Crashlytics 追蹤組件。
* **無帳號註冊要求**：使用 SyncNexus 無需註冊任何帳號、提供電子郵件或個人身分識別資訊。

---

### 2. Apple 系統沙盒與權限宣告（App Sandbox & Entitlements）
本應用程式完全運行於 Apple App Sandbox 環境中，僅請求實現雙向同步所不可或缺之最小權限：
1. **使用者選取之檔案與目錄（`com.apple.security.files.user-selected.read-write`）**：
   - 僅當使用者透過標準系統視窗（`NSOpenPanel`）主動挑選時，應用程式方能存取該特定目錄。
2. **安全範圍書籤（`com.apple.security.files.bookmarks.app-scope`）**：
   - 用於在沙盒中持久化保存您已授權資料夾的存取憑據，使應用程式重啟後能持續為您監聽並執行同步。
3. **區域網路通訊（`com.apple.security.network.client` / `network.server`）**：
   - 僅用於本機 Wi-Fi 內透過 Apple Bonjour（mDNS 多播協定）尋找您同網路內運行 SyncNexus 的其他 Mac、Windows 或 Android 設備進行區域直連。**絕不發送任何資料至網際網路外部伺服器**。

---

### 3. 資料安全與完整性維護
* **防誤刪機制（Deletion Guard）**：當偵測到大規模檔案刪除時，自動停止同步並請求授權，防止外接硬碟拔除引發誤刪。
* **版本歷史歸檔**：所有被覆蓋或移至廢紙簍之舊版檔案，皆先於本機或該端點保存歷史版本，供您隨時還原。

---

### 4. 聯絡方式
若您對本隱私權政策有任何疑問或審查垂詢，歡迎透過官方 GitHub 倉庫取得聯繫：  
專案儲存庫：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
