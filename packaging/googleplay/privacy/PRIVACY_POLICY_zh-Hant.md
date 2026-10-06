# SyncNexus 隱私權政策 — Android (Google Play 審查專用)

**生效日期**：2026 年 10 月 5 日  
**發行平台**：Google Play Store (Android)  
**開發團隊**：SyncNexus Team  

SyncNexus 致力於最高規格的個人隱私保護。本政策嚴格遵循 **Google Play 開發人員政策（包括使用者資料政策 User Data Policy 及重要揭露 Prominent Disclosure 要求）**，詳細說明資料處理原則與權限用途。

---

### 1. 核心隱私承諾：零伺服器、無追蹤
* **無遠端伺服器**：SyncNexus 沒有架設任何接收使用者檔案內容的遠端伺服器。您的所有檔案、中繼資料（Metadata）及 SHA-256 完整性雜湊碼，**僅在您的裝置本機及您明確選取的儲存目錄中進行處理**。
* **無第三方 SDK 與無廣告**：不包含任何第三方數據統計、分析（Analytics）或行為追蹤 SDK。
* **無個人身分資料（PII）收集**：無需註冊、無需登入、不收集裝置識別碼（IMEI/Android ID）或電話號碼。

---

### 2. App 在您的裝置上保存哪些資料
為了提供「差異預覽、衝突、舊版本、驗證紀錄」，SyncNexus 會在 **App 的私有儲存空間**保存：
* 每個同步群組中各檔案「上次同步一致」的雜湊值與修改時間（用來判斷哪一邊有修改）。
* 未處理的衝突清單。
* **舊版本封存**：被同步更新、衝突裁決或還原動作取代的檔案副本，保留 30 天（總量上限 1 GB，超過時先清除最舊的）。
* 驗證紀錄（時間、檔案數、結果）。

這些資料**只存在您的裝置上，不會上傳**。移除群組時對應的紀錄一併清除；解除安裝 App 或在系統設定中清除資料，即可全部刪除。衝突複本則存放在發生衝突的同步資料夾內，由您決定保留或丟棄。

---

### 3. Android 系統權限與顯著揭露（Prominent Disclosure）
為提供檔案對帳同步服務，SyncNexus 僅請求以下符合最小權限原則之系統功能：
1. **分區儲存與目錄存取架構（Storage Access Framework - SAF）**：
   - 應用程式**不索取**寬鬆的 `MANAGE_EXTERNAL_STORAGE` 全磁碟權限，而是透過 Android 系統標準文件選擇器，由您明確挑選要同步的特定資料夾，並透過 `takePersistableUriPermission` 取得持續授權。
2. **前台服務權限（`FOREGROUND_SERVICE_DATA_SYNC`）與通知（`POST_NOTIFICATIONS`）**：
   - 背景同步時，Android 系統要求顯示前台服務通知。此通知僅用於告知使用者各同步群組的狀態，確保運作透明可見。
3. **網路權限（`INTERNET`、`ACCESS_WIFI_STATE`、`CHANGE_WIFI_MULTICAST_STATE`）與區域網路服務探索（`android.net.nsd.NsdManager`）**：
   - Android 規定使用 NSD 必須宣告此權限。**僅用於同 Wi-Fi 內透過 mDNS 協定搜尋其他運行 SyncNexus 的設備（Mac / Windows）**，App 不連線任何外部伺服器，也不上傳或下載任何資料。
4. **USB 裝置監聽（`android.hardware.usb.action.USB_DEVICE_ATTACHED`）**：
   - 僅用於感知 OTG 隨身碟插入或拔除，以便及時更新外接端點狀態。

---

### 4. 使用者控制權
使用者可隨時於 App 介面中移除已授權的資料夾、刪除舊版本封存，或透過 Android 系統設定撤回權限與清除本機資料。

---

### 5. 聯絡方式
如有任何隱私政策或 Google Play 審查相關問題：  
專案儲存庫：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
