# 安裝與第一次使用

需求：macOS 14 (Sonoma) 以上。

## 方式一：從原始碼安裝（免費、不需要 Apple 開發者帳號）

需要 Xcode 命令列工具（`xcode-select --install`）。

```bash
git clone <this repo> && cd SyncNexus
Scripts/build-app.sh --install
```

這會：
1. 編譯 App。
2. 第一次執行時在 `~/.syncnexus-signing/` 建立一把**本機專用的自簽憑證**（不會動到你的登入鑰匙圈），之後每次都用同一把簽章，
   這樣 macOS 的隱私授權（完整磁碟取用權限）重新編譯後仍然有效。
3. 安裝到 `~/Applications/SyncNexus.app` 並啟動。

## 方式二：Homebrew（需要先把 App 發佈到你自己的 GitHub）

App 沒有經過 Apple 公證（需要付費的開發者帳號），所以用個人 tap 發佈：

1. `Scripts/package.sh` 產生 `build/SyncNexus-<版本>.zip` 與 sha256。
2. 把 zip 上傳到 GitHub Release（標籤 `v<版本>`）。
3. 建立名為 `homebrew-syncnexus` 的 GitHub 倉庫，把 `packaging/homebrew/syncnexus.rb` 放在 `Casks/syncnexus.rb`，
   填入 OWNER、版本與 sha256。
4. 使用者安裝：

```bash
brew tap OWNER/syncnexus
brew install --cask syncnexus
```

Cask 會在安裝後移除下載隔離標記，否則第一次開啟會被 Gatekeeper 擋下。若手動安裝 zip，請在終端機執行：

```bash
xattr -dr com.apple.quarantine /Applications/SyncNexus.app
```

或在 Finder 對 App 按右鍵 → 開啟。

## 第一次使用

第一次開啟會出現引導視窗，依序完成：

1. **授權**：到「系統設定 > 隱私權與安全性 > 完整磁碟取用權限」加入 Sync-Nexus 並打開開關，然後重新啟動 App。
   （沒有它就無法處理 iCloud 雲碟裡的刪除。）
2. **通知**：允許通知，有衝突或需要確認時才會提醒你。
3. **開機自動啟動**：預設開啟，可在選單裡關閉。
4. **加入資料夾**：選單列圖示 → 「設定端點…」→ 「加入資料夾…」。
   建議每個地方各建一個專用資料夾（例如都叫「同步用」），先拿檔案不多的資料夾試用幾天。

第一次同步前會先列出預覽，按「確認」才會真的複製或刪除。

## 移除

```bash
brew uninstall --cask --zap syncnexus     # Homebrew 安裝
rm -rf ~/Applications/SyncNexus.app ~/Library/Application\ Support/SyncNexus ~/Library/Logs/SyncNexus
```

同步資料夾裡的檔案不會被動到；每個資料夾根目錄各有一個隱藏的 `.syncnexus-endpoint` 標記檔，可自行刪除。

## 疑難排解

| 現象 | 原因與處理 |
|---|---|
| iCloud 資料夾的刪除一直失敗（日誌出現 "don't have permission"） | 完整磁碟取用權限未生效。在清單移除 Sync-Nexus 後重新加入，再重新啟動 App。 |
| 外接碟顯示離線 | 碟被拔除或標記檔遺失；接回原本那顆碟會自動繼續。換了新碟請用「更換資料夾」。 |
| iCloud 檔案一直沒同步 | 檔案還在雲端，正在背景讀取；iCloud 下載小檔案也可能要數十秒。超過 500 MB 的雲端檔案需手動在 Finder 下載。 |
| 紀錄檔 | 選單 →「開啟紀錄檔」（`~/Library/Logs/SyncNexus/syncnexus.log`）。 |
