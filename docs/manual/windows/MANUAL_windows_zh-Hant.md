# SyncNexus 操作使用手冊 — Windows 篇

## 1. 簡介與架構亮點
**SyncNexus for Windows** 是一款專為 Windows 10 及 Windows 11 打造的現代化本地優先雙向檔案同步工具。結合 .NET 9 高效能架構、Fluent Design 介面、系統匣（System Tray）常駐守護與完整跨平台對齊。

* **多端點互通**：本機資料夾、Google Drive 虛擬串流磁碟（`G:\`）或鏡像目錄、OneDrive 隨選資料夾、以及可與 Mac / Android 共用的 ExFAT 外接隨身碟。
* **雲端佔位符智慧感知**：自動辨識 Windows Cloud Files API 佔位屬性（`RECALL_ON_DATA_ACCESS` / `REPARSE_POINT`），避免引發未快取檔案的全量無謂下載。
* **外接磁碟代號自動重對齊**：即便隨身碟下次插入時代號由 `E:\` 變動為 `F:\`，系統透過磁碟卷標與序號自動追蹤校正。
* **長路徑支援 (Long Paths)**：預設宣告 `longPathAware`，突破傳統 Windows 260 字元限制。

---

## 2. 快速上手教學
1. **新增端點**：
   - 點擊首頁頁首的 **「+ 新增端點」**。
   - 瀏覽選取本機目錄，或由下拉選單選取自動探測到的 **Google Drive** 或 **OneDrive** 路徑。
   - 若為隨身碟，勾選「可移除式磁碟」以啟用序號動態鎖定。
   - 若資料夾內已有 Mac 或其他設備建立之 `.syncnexus-endpoint` 標記檔，SyncNexus 會自動辨識並直接認證，實現跨設備無縫接軌！
2. **即時自動同步與守護**：
   - 點擊「立即對帳」執行手動同步。
   - 檔案異動時，`WindowsFileWatcher` 具備 2 秒靜止防抖，批次自動執行對帳。
3. **系統匣運作**：
   - 關閉主視窗時自動縮小至 Windows 系統匣（Taskbar Tray），持續在背景維持即時監控。
   - 於托盤圖示點擊右鍵可快速開啟視窗、執行對帳或徹底退出。

---

## 3. 衝突管理與資源回收筒
* **衝突管理**：並行衝突檔案將自動保留為 `檔名 (conflict 端點 yyyy-MM-dd HH-mm).副檔名`。點擊頁首「⚡ 衝突管理」可自由決定保留主要版或採用衝突複本。
* **Windows 原生資源回收筒整合**：遠端刪除的檔案將安全移至 **Windows 系統真正的資源回收筒**，絕不永久滅失。
* **雙重版本保護**：重大變更前自動備份至 `.syncnexus-history`，提供防護。
