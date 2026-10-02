# SyncNexus 操作使用手冊 — Apple (macOS / iOS) 篇

## 1. 簡介與架構特色
**SyncNexus for Apple** 是一款遵循「本機優先 (Local-First)」架構的雙向檔案即時對帳同步工具。具備強大的無伺服器架構、零雲端綁定、資料完整性驗證與完整沙盒隱私保護。

* **本機沙盒運行**：嚴格符合 Apple App Store 沙盒規範（App Sandbox），透過安全範圍書籤（Security-Scoped Bookmarks）持久化授權。
* **零伺服器與 P2P 直連**：支援 Apple Bonjour（mDNS `_syncnexus._tcp`），同 Wi-Fi 內自動發現其他 Mac、Windows 及 Android 設備。
* **APFS 快照防護**：在大規模同步前自動建立 APFS 快照，提供無損復原防護。
* **多端點支援**：本機目錄、iCloud Drive、Google Drive、隨選雲端佔位符辨識與外接 ExFAT 硬碟。

---

## 2. 快速上手與端點配置
1. **啟動與權限授予**：
   - 啟動 `SyncNexus.app`。首次加入資料夾時，系統將彈出標準檔案選取視窗（`NSOpenPanel`），由您主動選取欲同步之目錄。
   - 應用程式將自動為該目錄建立安全書籤並寫入專屬防偽標記檔 `.syncnexus-endpoint`。
2. **加入雲端與外接硬碟**：
   - **iCloud Drive**：選取位於 `~/Library/Mobile Documents/com~apple~CloudDocs/` 之目錄。
   - **Google Drive**：選取 CloudStorage 下之 Google Drive 鏡像或串流資料夾。
   - **外接式隨身硬碟**：格式化為 ExFAT，選取 `/Volumes/<磁碟名稱>` 下之目錄。
3. **對帳與即時監控**：
   - 點擊「立即對帳」或等待系統 FSEvents 即時監聽自動觸發（靜止防抖 2 秒）。
   - 點擊「差異預覽」可在檔案寫入前查看變更樹狀圖。

---

## 3. 衝突解決與歷史還原
* **衝突保留**：當兩端在離線狀態下同時修改同名檔案，SyncNexus 絕不覆蓋，自動將本端衝突版本命名為 `檔案名稱 (conflict 端點代號 yyyy-MM-dd HH-mm).副檔名`。
* **版本歷史（Versions）**：在取代或刪除檔案前，系統自動將舊版本備份至歷史庫，可隨時一鍵復原。
* **大量刪除防護（Deletion Guard）**：當單次刪除檔案超過 25 個或佔總檔案 25% 以上時，系統自動阻斷並要求使用者手動確認。
