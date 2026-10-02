# SyncNexus 隱私權政策 — Android (Google Play 審查專用)

**生效日期**：2026 年 10 月 3 日  
**發行平台**：Google Play Store (Android)  
**開發團隊**：SyncNexus Team  

SyncNexus 致力於最高規格的個人隱私保護。本政策嚴格遵循 **Google Play 開發人員政策（包括使用者資料政策 User Data Policy 及重要揭露 Prominent Disclosure 要求）**，詳細說明資料處理原則與權限用途。

---

### 1. 核心隱私承諾：零伺服器、無追蹤
* **無遠端伺服器**：SyncNexus 沒有架設任何接收使用者檔案內容的遠端伺服器。您的所有檔案、中繼資料（Metadata）及 SHA-256 完整性雜湊碼，**僅在您的裝置本機及您明確選取的儲存目錄中進行處理**。
* **無第三方 SDK 與無廣告**：不包含任何第三方數據統計、分析（Analytics）或行為追蹤 SDK。
* **無個人身分資料（PII）收集**：無需註冊、無需登入、不收集裝置識別碼（IMEI/Android ID）或電話號碼。

---

### 2. Android 系統權限與顯著揭露（Prominent Disclosure）
為提供檔案對帳同步服務，SyncNexus 僅請求以下符合最小權限原則之系統功能：
1. **分區儲存與目錄存取架構（Storage Access Framework - SAF）**：
   - 應用程式**不索取**寬鬆的 `MANAGE_EXTERNAL_STORAGE` 全磁碟權限，而是透過 Android 系統標準文件選擇器，由您明確挑選要同步的特定資料夾，並透過 `takePersistableUriPermission` 取得持續授權。
2. **前台服務權限（`FOREGROUND_SERVICE_DATA_SYNC`）**：
   - 當您啟動背景同步時，Android 系統要求必須顯示前台服務通知。此通知僅用於告知使用者檔案正在同步中，確保運作透明可見。
3. **區域網路服務探索（`android.net.nsd.NsdManager`）**：
   - 僅用於同 Wi-Fi 內透過 mDNS 協定搜尋其他運行 SyncNexus 的設備（Mac / Windows），**絕不發送封包至網際網路**。
4. **USB 裝置監聽（`android.hardware.usb.action.USB_DEVICE_ATTACHED`）**：
   - 僅用於感知 OTG 隨身碟插入或拔除，以便及時更新外接端點狀態。

---

### 3. 使用者控制權
使用者可隨時於 App 介面中移除已授權的資料夾，或透過 Android 系統設定撤回權限與清除本機資料。

---

### 4. 聯絡方式
如有任何隱私政策或 Google Play 審查相關問題：  
專案儲存庫：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
