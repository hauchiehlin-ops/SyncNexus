# 隐私权政策 (macOS 版)

**生效日期**：2026 年 10 月 2 日  
**应用程序**：Sync-Nexus for Mac (Mac App Store 版本)

Sync-Nexus 是一款专注于本地数据同步的工具应用程序。我们高度尊重并致力于保护用户的个人隐私。

---

### 1. 数据收集与隐私原则
* **零服务器、无账号**：Sync-Nexus 完全不依赖任何云端服务器，用户无须注册任何账号或提供个人识别信息。
* **无远端遥测与追踪**：本应用程序不包含任何第三方数据统计、分析（Analytics）或遥测追踪 SDK。
* **文件内容不外流**：Sync-Nexus 仅在您指定的本地文件夹、外接存储设备或同 Wi-Fi 局域网之设备间进行同步。您的所有文件内容与文件名皆仅保存在您本地设备与选定目录中，绝不向外部网络传输。

---

### 2. Apple 沙盒机制与权限声明说明
* **用户选定之文件读写 (`com.apple.security.files.user-selected.read-write`)**：仅用于访问您主动于系统选取窗口中选定的同步目录。
* **安全作用域书签 (`com.apple.security.files.bookmarks.app-scope`)**：用于在系统重启后安全持久化保存您已授权文件夹的访问令牌。
* **外接设备访问 (`com.apple.security.files.volumes.read-write`)**：用于侦测并访问您插入的外接闪存盘或硬盘中的同步文件夹。
* **Bonjour 局域网直连 (`_syncnexus._tcp`)**：仅用于同 Wi-Fi 局域网搜寻您的其他 Mac 或 Android 设备以建立点对点直连。

---

### 3. 联系我们
如果对本隐私权政策有任何疑问，请通过 GitHub Issue 与开发团队联系：  
项目仓库：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
