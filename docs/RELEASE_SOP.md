# Sync-Nexus 一鍵式通用標準發行指令體系 (Release SOP Manual)

本文件為 **Sync-Nexus** 跨平台（Apple App Store / macOS / Android）標準發行管線的官方規範說明書。本套發行體系具備**全通用、標準化、高強健性、防呆檢核**之特性，無論日常快速產出分享檔，或正式升版發行至 App Store / Google Play，皆可透過單一指令自動完成。

---

## 核心設定與版本單一真相來源 (Single Source of Truth)

專案嚴格維持以下檔案為全局版本與識別碼之單一來源：
* **`VERSION`**：語意化版本號（如 `0.1.5`，對應行銷版本號 `CFBundleShortVersionString`、`versionName`）。
* **`BUILD_NUMBER`**：單調遞增整數（如 `6`，對應 Bundle 號 `CFBundleVersion`、`versionCode`）。
* **`Bundle Identifier`**：`com.syncnexus.app`（Apple Developer 與 Android 統一識別碼）。
* **`Team ID`**：`6UJ8GS752W`。

---

## 一、一鍵發行指令速查清單 (Cheat Sheet)

### 1. 全自動正式發行（最常用、最核心指令）
執行完整的 5 階段自動化流程：
```bash
./Scripts/release.sh patch
```
> **支援參數**：
> * `./Scripts/release.sh patch`：升級修訂版號（如 `0.1.5` $\rightarrow$ `0.1.6`，build 號 +1）。
> * `./Scripts/release.sh minor`：升級次版號（如 `0.1.5` $\rightarrow$ `0.2.0`，build 號 +1）。
> * `./Scripts/release.sh major`：升級主版號（如 `0.1.5` $\rightarrow$ `1.0.0`，build 號 +1）。
> 
> **執行完成後只需一步**：
> ```bash
> git push && git push --tags
> ```

---

### 2. 獨立發行檔產出（免上架、直接分享給他人體驗）
無論是透過通訊軟體傳送給朋友、或是放在官網供用戶下載，使用 `dist.sh`：
```bash
# 同時產生 macOS DMG 與 Android APK/AAB
./Scripts/dist.sh --mac --android

# 僅產出 macOS 獨立 DMG 安裝檔
./Scripts/dist.sh --mac

# 僅產出 Android 正式簽章 APK 與 AAB
./Scripts/dist.sh --android
```

產出物將自動集結於 `build/dist/v<版本號>-b<Build號>/`：
* `SyncNexus-<版本號>-mac.dmg`：macOS 拖曳安裝映像檔（內建 Applications 捷徑）。
* `SyncNexus-<版本號>-android.apk`：**已通過 Release 金鑰簽章**，任何 Android 手機/平板可直接點擊安裝體驗。
* `SyncNexus-<版本號>-android.aab`：已簽章之 Google Play Store 正式發行套件。
* `安裝說明.txt`：自動生成的繁體中文安裝指引。

---

### 3. 子任務與分段發行（依平台單獨處理）

| 需求場景 | 終端機指令 | 說明 |
|---|---|---|
| **只升級版本號** | `./Scripts/release.sh bump [patch\|minor\|major]` | 僅更新 `VERSION`、`BUILD_NUMBER` 與雙端配置，不打包 |
| **只打包 Apple App Store** | `./Scripts/release.sh apple` | 檢查 i18n 後建置沙盒、生成 `.pkg` 並驗證 |
| **直接上傳 App Store** | `./Scripts/package_macos_app_store.sh --upload` | 完成打包後直接上傳至 App Store Connect |
| **只打包 Android** | `./Scripts/release.sh android` | 檢查 i18n 後執行 Gradle 生成正式簽名 APK 與 AAB |
| **手動校驗 6 國語系** | `./Scripts/check_i18n.sh` | 檢查 Android 與說明文件 6 國語言覆蓋率 |

---

## 二、一鍵式全自動發行流程圖解 (Pipeline Architecture)

當您執行 `./Scripts/release.sh patch` 時，背後自動串聯執行的 5 大關卡如下：

```mermaid
flowchart TD
    Start["執行 ./Scripts/release.sh patch"] --> Step1["步驟 1: 升版本號與 Bundle 號\n(更新 VERSION, BUILD_NUMBER, Info.plist, build.gradle.kts)"]
    Step1 --> Step2["步驟 2: i18n 與版本一致性檢核\n(驗證 Android 6 國 strings.xml 及雙平台 6 國手冊)"]
    Step2 --> Step3["步驟 3: macOS App Store 上架打包\n(編譯沙盒 App, 生成 PKG, altool 預檢驗證)"]
    Step3 --> Step4["步驟 4: Android 發行打包\n(Gradle 簽署產出 AAB, APK, macOS DMG 至 dist)"]
    Step4 --> Step5["步驟 5: 建立 Git 版本提交與 Tag\n(chore(release): commit 與 git tag)"]
    Step5 --> Finish["🎉 發布完成！提示執行 git push && git push --tags"]
```

---

## 三、各腳本模組職責說明

專案內的 `Scripts/` 目錄已進行標準模組化劃分，各腳本皆具備獨立執行與組合調用能力：

```
Scripts/
├── release.sh                  <-- [主控樞紐] 一鍵全流程發行 SOP 指令
├── dist.sh                     <-- [整合發行] 產出官網與分享用 DMG、APK、AAB 及安裝說明
├── check_i18n.sh               <-- [品質把關] 驗證 Android 與獨立文檔 6 國語言完整性
├── bump-version.sh             <-- [版本控制] 單一來源版號遞增器
├── package_macos_app_store.sh  <-- [Apple 專用] 沙盒建置、PKG 封裝、證書簽名、altool 驗證/上傳
├── package_macos_dmg.sh        <-- [Apple 專用] 製作高相容性 UDZO 壓縮 DMG
├── package_android.sh          <-- [Android 專用] 綁定 release-key.jks 產出已簽名 APK/AAB
└── build-app.sh                <-- [底層編譯] macOS AppKit/SwiftUI 編譯與代碼簽名器
```

---

## 四、免上架分享 APK 與日後上架 Google Play 之無縫銜接

1. **分享體驗免上架**：
   * 專案內建專屬金鑰庫 `Platforms/Android/release-key.jks`（有效期限至 2054 年）。
   * `package_android.sh` 編譯出的 `dist/SyncNexus-<版本號>-android.apk` 已經過 **APK Signature Scheme v2** 認證。
   * **任何人拿到此 APK 均可直接安裝於 Android 8.0 至 Android 15 設備上，無任何權限阻礙或未簽名錯誤**。
2. **日後上架 Google Play**：
   * 同批次生成的 `dist/SyncNexus-<版本號>-android.aab` 使用同一把金鑰簽署，完全相容 Google Play 要求。
   * 日後若要在 Google Play 上架，直接將該 `.aab` 拖曳上傳至 Google Play Console 即可，代碼與金鑰完全不需要更動。
