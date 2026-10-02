# Google Play (Android) 上架操作指南

本文件提供將 **Sync-Nexus (Android 版)** 提交至 Google Play Store 的完整準備、審查策略與打包指引。

---

## 1. 必備前置條件與審查要求
1. **Google Play Console 開發者帳號**：
   - 註冊網址：[https://play.google.com/console](https://play.google.com/console)
   - 費用：一次性註冊費 $25 美元。
2. **20 人 14 天封閉測試門檻（個人開發者帳號強制規定）**：
   - 自 2023 年 11 月起，所有新註冊的個人 Google Play 帳號，必須在**封閉測試 (Closed Testing)** 軌道招募至少 20 名測試人員連續測試 14 天後，方能申請發布至正式版。
   - **應對方案**：可邀請同事、社群開源志願者或利用內部測試群組完成 14 天測試打卡。

---

## 2. 核心權限宣告與審查應對 (All Files Access 策略)

Sync-Nexus 是雙向資料夾同步工具。若要同步使用者自選的任意系統目錄（如外接 SD 卡、Download、Documents 等），需要使用 `MANAGE_EXTERNAL_STORAGE` 或 Storage Access Framework (SAF)。

### 2.1 Google Play 政策宣告指南 (All Files Access Permission Declaration)
在 Play Console 的「應用程式內容 (App Content)」->「特殊應用程式存取權 (Special App Access)」中填寫：
* **核心功能類別 (Core Feature)**：選擇 **備份與還原 (Backup and Restore)** 或 **檔案管理 (File Management)**。
* **功能用途說明 (Purpose Declaration)**：
  > "Sync-Nexus is an offline bi-directional folder synchronization and backup utility. The core functionality allows users to designate arbitrary folders across internal and external storage to stay synchronized in real-time. Without direct file-level access across designated storage paths, the app cannot detect file changes, compute SHA-256 integrity checksums, or replicate file changes."
* **演示影片 (Demo Video URL)**：
  Google 政策規定宣告此權限時**必須提供一段 YouTube (不公開) 演示影片**。
  - 影片內容：展示開啟 App -> 點擊加入資料夾 -> 系統彈出授權對話框 -> 建立檔案 -> 自動對帳完成同步。

---

## 3. 資料安全性問卷 (Data Safety Section)
* **是否收集或分享任何使用者資料？**：選擇 **否 (No)**。
* **是否具備網路通訊？**：選擇 **否 (No)**。本應用程式未宣告 `android.permission.INTERNET`，零網路流量，極易通過資料安全審查。
* **隱私權政策 (Privacy Policy)**：提供本專案的 `packaging/appstore/PRIVACY_POLICY.md` 網址。

---

## 4. 本地編譯與打包 (Android App Bundle - .aab)
在 `Platforms/Android` 目錄下執行 Gradle 進行 Release 打包：

```bash
cd Platforms/Android

# 1. 產生 Release 簽名金鑰 (若尚未建立)
keytool -genkey -v -keystore release.keystore -alias syncnexus -keyalg RSA -keysize 2048 -validity 10000

# 2. 編譯 Android App Bundle (.aab)
./gradlew bundleRelease
```

編譯完成的檔案位於：  
`Platforms/Android/app/build/outputs/bundle/release/app-release.aab`

將該 `.aab` 檔案直接上傳至 Google Play Console 的封閉測試或正式版本軌道即可。
