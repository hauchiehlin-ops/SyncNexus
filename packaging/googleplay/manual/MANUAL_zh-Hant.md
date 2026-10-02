# Sync-Nexus 操作使用手冊 (Android 版)

## 1. 簡介與總覽
**Sync-Nexus for Android** 是一款專為 Android 手機與平板量身打造的離線點對點雙向檔案同步工具。支援內部儲存空間目錄、SD 卡、USB-OTG 隨身碟，並可透過同 Wi-Fi 區域網路與您的 Mac 電腦直連同步。

![Sync-Nexus Android 操作介面](/Users/barretlin/.gemini/antigravity/brain/a78dbd7e-b8d4-4059-8ea4-510ecb66c712/android_screen_ui_1790946598473.jpg)

---

## 2. Android 核心專屬特色
* **儲存空間存取架構 (SAF)**：百分之百符合 Google Play 分區儲存規範，無須申請高風險且易被拒審的 `MANAGE_EXTERNAL_STORAGE` 權限。
* **電量與充電智慧感知**：電量低於 15% 且未充電時自動暫緩大傳輸，保護手機續航力。
* **OTG USB 隨身碟即時偵測**：插上 USB 隨身碟立即自動感應，一鍵加入同步目錄。
* **前台守護服務 (Foreground Service)**：確保長時間大檔案傳輸不會被 Android Doze 系統機制強行終止。
* **Wi-Fi 局域網直連 (P2P)**：透過 Android NSD 自動偵測同網路內的 Mac，建立直連通道。

---

## 3. 操作步驟說明

### 步驟 1：新增同步資料夾
1. 開啟 **Sync-Nexus**。
2. 點擊主畫面上的 **加入資料夾…**。
3. 在系統目錄選取視窗中選取資料夾（例如：`Documents` 或隨身碟內目錄），點擊「使用這個資料夾」並允許授權。
4. 重複步驟至少加入兩個資料夾。

### 步驟 2：立即對帳與同步
1. 點擊 **立即對帳同步** 觸發雙向對帳。
2. 檢視即時同步進度、追蹤檔案數量與傳輸日誌。

### 步驟 3：設備互聯
* 檢視 **同 Wi-Fi 近端設備 (P2P 局域網直連)** 卡片，確認與同網路內的 Mac 建立點對點直連。
