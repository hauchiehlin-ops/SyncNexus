# SyncNexus 隱私權政策 — Windows (Microsoft Store 審查專用)

**生效日期**：2026 年 10 月 3 日  
**發行平台**：Microsoft Store / Windows 桌面發行版  
**開發團隊**：SyncNexus Team  

SyncNexus 堅守透明、誠信與零資料收集原則。本政策嚴格遵循 **Microsoft Store 應用程式認證原則（Microsoft Store App Certification Policies - 特別是第 10.5 條個人資訊規定）**，闡明本應用程式如何在本機安全處理檔案與維護隱私。

---

### 1. 個人資訊與資料收集宣告（Personal Information Declaration）
* **零資料收集（Zero Data Collection）**：SyncNexus **不收集、不傳輸、不儲存、不分享**使用者的任何個人資料、裝置標識碼或瀏覽行為。
* **無遠端中繼伺服器**：同步作業僅發生於您本機檔案系統、本機掛載之雲端磁碟（Google Drive / OneDrive）或外接儲存媒體之間。檔案內容絕對不離開您的裝置。
* **零遙測與第三方 SDK**：不包含任何第三方數據統計、分析（Analytics）或行為追蹤組件。

---

### 2. Windows 平台功能宣告與用途說明（Capabilities & Features）
1. **本機檔案系統存取（BroadFileSystemAccess / RunFullTrust）**：
   - 僅用於讀取、比對與同步您明確選定與加入之同步資料夾。
2. **Windows 雲端檔案整合（Windows Cloud Files API）**：
   - 僅用於檢測 Google Drive 虛擬磁碟與 OneDrive 隨選檔案之 `FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS` 佔位符屬性，保護檔案未快取時不被強制下載。
3. **區域網路點對點探索（mDNS 多播通訊）**：
   - 僅於本地 Wi-Fi 網路內廣播與監聽 `_syncnexus._tcp.local`（通訊埠 5353），用於與同網路內運行 SyncNexus 的 Mac 或 Android 設備建立點對點直連。**絕不向網際網路發送外部請求**。
4. **開機自動啟動設定（Windows Startup Registry）**：
   - 若使用者勾選「開機時自動啟動」，應用程式僅寫入 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` 註冊表項目以在背景啟動守護行程，使用者可隨時取消勾選或於 Windows 工作管理員中停用。

---

### 3. 資源回收筒與資料保護承諾
* 透過 Win32 Shell API（`SHFileOperationW`）將遠端刪除之檔案安全移送至 **Windows 系統真正的資源回收筒**，確保使用者可隨時復原。
* 刪除前自動備份至 `.syncnexus-history`，杜絕任何意外遺失風險。

---

### 4. 聯絡我們
如有任何問題或 Microsoft Store 審查詢問：  
專案儲存庫：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
