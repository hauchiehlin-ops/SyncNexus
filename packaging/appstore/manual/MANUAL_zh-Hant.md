# Sync-Nexus 操作使用手冊 (macOS 版)

## 1. 簡介與總覽
**Sync-Nexus for Mac** 是一款專為 macOS 量身打造的「本機優先、點對點」雙向目錄同步系統。支援本機目錄、iCloud 雲碟、外接 USB-C / Thunderbolt 高速隨身碟，以及透過同 Wi-Fi 區域網路與 Android 設備直連同步。

![Sync-Nexus macOS 主介面](/Users/barretlin/.gemini/antigravity/brain/a78dbd7e-b8d4-4059-8ea4-510ecb66c712/macos_main_window_1790946573568.jpg)

---

## 2. macOS 專屬核心特色
* **App Sandbox 與安全範圍書籤 (Security-Scoped Bookmarks)**：完全符合 Mac App Store 審查規範。授權權限透過系統書籤安全加密儲存，重新啟動免重新選取。
* **APFS 快照防護機制**：在執行大型同步前，自動呼叫 APFS 建立寫入時複製快照，提供無損復原防線。
* **FSEvents 核心事件監聽**：閒置時完全零 CPU 負載，檔案有異動時毫秒級即時觸發。
* **差異預覽與試跑 (Visual Diff Trial Run)**：寫入磁碟前預先檢閱新增、改名與刪除清單。
* **Bonjour 區域網路直連 (P2P)**：同 Wi-Fi 下自動發現 Android 與其他 Mac 設備，不經任何雲端伺服器。

---

## 3. 操作步驟說明

### 步驟 1：新增同步端點
1. 開啟 **Sync-Nexus.app**。
2. 點擊工具列上的 **加入資料夾…** 或前往「資料夾」分頁。
3. 挑選欲同步的資料夾（例如：本機專案目錄、外接 SSD 或 iCloud 雲碟）。
4. 在 macOS 標準對話框中完成授權。

### 步驟 2：差異預覽與試跑
1. 點擊側邊欄的 **差異預覽** 分頁。
2. 點擊 **執行試跑模擬**。
3. 檢視即將變更的檔案清單。
4. 點擊 **立即套用並執行同步** 開始作業。

### 步驟 3：衝突排除
當兩端同時修改相同檔案時：
* Sync-Nexus 會自動保留雙方版本，絕不靜默覆蓋。
* 前往 **衝突** 分頁檢視差異，並自選保留哪一份版本。
