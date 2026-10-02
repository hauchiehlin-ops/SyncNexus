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

---

## 2. 本地打包指令
執行專案提供之打包工具產出上架專用的 `.pkg` 安裝包：

```bash
# 1. 建立具有 App Sandbox 與 Security-Scoped Bookmarks 的 App
Scripts/build-app.sh --sandbox

# 2. 封裝為 Mac App Store 專用安裝包 (.pkg)
# 請將憑證名稱換成您 Keychain 中的 Mac Installer Distribution 證書
Scripts/package-appstore.sh "3rd Party Mac Developer Installer: YOUR_NAME (TEAM_ID)"
```
產出的檔案為 `build/SyncNexus-<版本號>.pkg`。

---

## 3. 上傳至 App Store Connect
推薦使用 Apple 官方命令列工具上傳（或使用 Transporter App）：
```bash
xcrun altool --validate-app -f "build/SyncNexus-0.1.5.pkg" -t macos --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
xcrun altool --upload-app -f "build/SyncNexus-0.1.5.pkg" -t macos --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
```

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
