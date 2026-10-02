# Sync-Nexus

Mac 選單列 App：讓你指定的幾個資料夾 —— **本機、iCloud 雲碟、Google Drive、外接磁碟** —— 互相保持一致。
全部在你自己的電腦上執行，沒有伺服器、沒有帳號、沒有遙測；只使用開源元件與系統 API。

- 任一資料夾的新增、修改、刪除、改名都會傳到其他資料夾（改名只是改名，不會重新傳檔案）。
- 空資料夾和資料夾刪除也會同步。
- 外接磁碟可隨時拔除、到別台電腦（Mac 或 Windows）修改，接回後自動對帳，不會被當成「檔案全被刪除」。
- 刪除的檔案先進垃圾桶；被取代的舊版本另存在 `Versions`（預設保留 30 天，可手動清理）。
- 同一檔案兩邊都被修改：預設保留兩份、由你在設定視窗挑選；也可選「自動採用較新的」。
- iCloud / Google Drive 尚未下載的檔案：在背景讀取、不會卡住同步。

## 安裝

詳見 [docs/INSTALL.md](docs/INSTALL.md)。最簡單的方式（需要 Xcode 命令列工具、macOS 14 以上）：

```bash
git clone https://github.com/hauchiehlin-ops/SyncNexus.git && cd SyncNexus
Scripts/build-app.sh --install
```

## 開發

```bash
swift test                      # 單元與整合測試
Scripts/stress.sh 30000 400     # 壓力測試（只用暫存資料夾）
.build/debug/syncnexus help     # 指令列工具
```

結構：`Sources/SyncCore`（引擎，純 Swift、無第三方依賴）、`Sources/syncnexus`（CLI）、`Sources/SyncNexusApp`（選單列 App）。
設計與實測紀錄：[docs/PLAN.md](docs/PLAN.md)、[docs/PHASE0-FINDINGS.md](docs/PHASE0-FINDINGS.md)。

版本號規則與 commit／push 前的自動提升：[docs/VERSIONING.md](docs/VERSIONING.md)。

授權：Apache-2.0。
