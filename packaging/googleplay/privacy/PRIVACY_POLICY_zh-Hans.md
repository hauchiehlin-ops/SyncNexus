# 隐私权政策 (Android 版)

**生效日期**：2026 年 10 月 2 日  
**应用程序**：Sync-Nexus for Android (Google Play Store 版本)

Sync-Nexus 是一款专注于本地数据同步的工具应用程序。我们高度尊重并致力于保护用户的个人隐私。

---

### 1. 数据收集与隐私原则
* **零服务器、无账号**：Sync-Nexus 完全不依赖任何云端服务器，用户无须注册任何账号或提供个人识别信息。
* **无远端遥测与追踪**：本应用程序不包含任何第三方数据统计、分析（Analytics）或广告跟踪标识符 (AAID)。
* **文件内容不外流**：Sync-Nexus 仅在您指定的内部文件夹、外接存储设备或同 Wi-Fi 局域网之设备间进行同步，绝不向外部网络传输。

---

### 2. Google Play 权限与存储规范说明
* **存储访问框架 (SAF)**：完全遵循 Google Play 分区存储 (Scoped Storage) 规范。仅访问您于 SAF 目录选择器中明确授权的特定文件夹，**绝不**申请或使用容易导致拒审的 `MANAGE_EXTERNAL_STORAGE` 高风险权限。
* **前台数据同步服务 (`FOREGROUND_SERVICE_DATA_SYNC`)**：在后台传输文件时维持稳定运作，避免遭系统终止，并于通知栏显示进行中的服务状态。
* **局域网设备发现 (NSD / mDNS)**：通过 Android 网络服务探索搜寻同 Wi-Fi 下的 Mac 设备，不发送外部互联网连接。

---

### 3. 联系我们
如果对本隐私权政策有任何疑问，请通过 GitHub Issue 与开发团队联系：  
项目仓库：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
