# Mac App Store (Apple) 上架操作指南

本文件提供將 **Sync-Nexus** 提交至 Apple **Mac App Store (MAS)** 的完整準備與送審指引。

---

## 1. 必備前置條件
1. **Apple Developer Program 帳號**（個人或組織，年費 $99 美元）。
2. 在 [Apple Developer 憑證中心](https://developer.apple.com/account/resources/certificates/list) 建立以下兩張憑證：
   - **Apple Distribution**（用於代碼簽署 App 本體）
   - **Mac Installer Distribution**（用於簽署 `.pkg` 安裝檔）
3. 在 [Identifiers](https://developer.apple.com/account/resources/identifiers/list) 建立 App ID：
   - Bundle ID: `com.syncnexus.app` (或您在 Developer Account 中的專屬 ID)
   - 勾選 Capabilities: **App Sandbox**
4. 建立並下載 **Mac App Store provisioning profile**，App ID 選擇
   `com.syncnexus.app`，憑證選擇上述 Apple Distribution 憑證。Xcode 通常會將它安裝至
   `~/Library/Developer/Xcode/UserData/Provisioning Profiles/`。

---

## 2. 本地打包指令
執行專案提供之打包工具產出上架專用的 `.pkg` 安裝包：

```bash
# 1. 建立具有 App Sandbox 與 Security-Scoped Bookmarks 的 App
Scripts/build-app.sh --app-store

# 2. 封裝為 Mac App Store 專用安裝包 (.pkg)
# 請將憑證名稱換成您 Keychain 中的 Mac Installer Distribution 證書
Scripts/package-appstore.sh "3rd Party Mac Developer Installer: YOUR_NAME (TEAM_ID)"
```
Profile 也可以放在專案根目錄（Git 會忽略它）。若位於其他位置，可明確指定：

```bash
APP_PROVISIONING_PROFILE=/absolute/path/to/profile.provisionprofile \
  Scripts/package-appstore.sh "3rd Party Mac Developer Installer: YOUR_NAME (TEAM_ID)"
```

打包腳本會檢查 profile 的平台、Team/App ID、期限，並將它嵌入
`SyncNexus.app/Contents/embedded.provisionprofile`；缺少或不相符時會直接停止，避免再次上傳
無法用於 TestFlight 的 build。
產出的檔案為 `build/SyncNexus-<版本號>.pkg`。

---

## 3. 使用 Transporter 上傳至 App Store Connect

macOS 套件固定使用 Apple **Transporter** 傳送；專案腳本不接收 Apple ID、App 專用密碼，
也不提供 `--upload` 直接上傳模式。

1. 從 Mac App Store 安裝並開啟 **Transporter**。
2. 使用具備 App Manager、Developer 或 Admin 權限的 App Store Connect 帳號登入。
3. 將 `build/SyncNexus-<版本號>-b<Build號>.pkg` 拖入 Transporter。
4. 按下「傳送（Deliver）」並等待成功訊息。
5. 前往 App Store Connect 的 TestFlight 頁面，等待 Apple 完成建置處理。

Transporter 會執行 App Store Connect 的伺服器端驗證；若失敗，應依 Transporter 顯示的錯誤修正後，
遞增 `BUILD_NUMBER` 並重新產生套件。

---

## 4. App Store Connect 元數據與審查備註填寫建議

### 4.1 基本資訊
* **名稱 (Name)**: Sync-Nexus: 本機多資料夾雙向同步
* **副標題 (Subtitle)**: 本機、iCloud、Google Drive、外接磁碟秒級同步
* **類別 (Primary Category)**: 工具程式 (Utilities) / 生產力工具 (Productivity)
* **價格 (Pricing)**: 免費 (Free - Tier 0)

### 4.2 隱私權問卷 (App Privacy Questionnaire)
* **資料收集**: 選擇 **「否，我們不收集任何資料 (No, we do not collect data from this app)」**。
* **隱私政策網址 (Privacy Policy URL)**: 可託管 `packaging/appstore/PRIVACY_POLICY.md` 於 GitHub Pages。

### 4.3 審查備註 (Notes for Review) —— 關鍵通過技巧
因為 Sync-Nexus 是沙盒 App 且存取使用者目錄，Apple 審查員會特別測試資料夾授權流程。請在審查備註中填寫：

> **Demo Instructions for Reviewer:**
> 1. Sync-Nexus is a 100% offline, privacy-first folder synchronization utility. It runs entirely on the user's Mac and does not connect to any servers or transmit user files over the network.
> 2. To test the core functionality:
>    - Launch the app (an icon will appear in the macOS menu bar).
>    - Click the menu bar icon -> click "加入資料夾 (Add Folder)" or open Settings.
>    - Use the macOS file dialog (NSOpenPanel) to pick any test folder (e.g., in ~/Documents or Desktop).
>    - Pick a second test folder.
>    - Create or edit a file in Folder A; within 1-2 seconds, the change will replicate seamlessly to Folder B.
> 3. The app adopts macOS App Sandbox with Security-Scoped Bookmarks to persist user permission across restarts.
