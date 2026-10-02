# Sync-Nexus 操作使用手册 (Android 版)

## 1. 简介与总览
**Sync-Nexus for Android** 是一款专为 Android 手机与平板量身打造的离线点对点双向文件同步工具。支持内部存储空间目录、SD 卡、USB-OTG 闪存盘，并可通过同 Wi-Fi 局域网与您的 Mac 电脑直连同步。

![Sync-Nexus Android 操作界面](/Users/barretlin/.gemini/antigravity/brain/a78dbd7e-b8d4-4059-8ea4-510ecb66c712/android_screen_ui_1790946598473.jpg)

---

## 2. Android 核心专属特色
* **存储访问框架 (SAF)**：百分之百符合 Google Play 分区存储规范，无须申请高风险且易被拒审的 `MANAGE_EXTERNAL_STORAGE` 权限。
* **电量与充电智能感知**：电量低于 15% 且未充电时自动暂缓大传输，保护手机续航力。
* **OTG USB 闪存盘即时侦测**：插入 USB 闪存盘立即自动感应，一键加入同步目录。
* **前台守护服务 (Foreground Service)**：确保长时间大文件传输不会被 Android Doze 系统机制强行终止。
* **Wi-Fi 局域网直连 (P2P)**：通过 Android NSD 自动侦测同网络内的 Mac，建立直连通道。

---

## 3. 操作步骤说明

### 步骤 1：添加同步文件夹
1. 打开 **Sync-Nexus**。
2. 点击主界面上的 **添加文件夹…**。
3. 在系统目录选取窗口中选取文件夹（例如：`Documents` 或闪存盘内目录），点击“使用此文件夹”并允许授权。
4. 重复步骤至少添加两个文件夹。

### 步骤 2：立即对账与同步
1. 点击 **立即对账同步** 触发双向对账。
2. 检视即时同步进度、追踪文件数量与传输日志。

### 步骤 3：设备互联
* 检视 **同 Wi-Fi 局域网近端设备 (P2P 直连)** 卡片，确认与同网络内的 Mac 建立点对点直连。
