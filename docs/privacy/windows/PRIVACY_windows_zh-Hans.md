# SyncNexus 隐私政策 — Windows (Microsoft Store 审核标准)

**生效日期**：2026 年 10 月 3 日  
**发行平台**：Microsoft Store / Windows 桌面分发  
**开发团队**：SyncNexus Team  

SyncNexus 全力致力于用户隐私与透明度。本隐私政策严格遵循 **Microsoft Store 应用认证政策（特别是第 10.5 节“个人信息”）**，说明我们完全在本机处理数据、零遥测的架构。

---

### 1. 个人信息声明
* **零数据收集**：SyncNexus **不会收集、传输、存储或共享**任何个人信息、设备标识符或使用遥测数据。
* **无远程服务器**：同步操作仅发生在您的本机文件系统、本机挂载的云端文件系统（Google Drive / OneDrive）与外接可移动存储之间。文件内容绝不会离开您的设备环境。
* **无第三方分析**：不包含任何第三方追踪、广告、分析或行为监控 SDK。

---

### 2. Windows 功能与透明度
1. **文件系统访问**：
   - 仅用于读取、比较并同步用户明确选择的文件夹。
2. **Windows Cloud Files API 集成**：
   - 仅用于评估 Google Drive 与 OneDrive 文件夹上的 `FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS` 占位符属性，避免未缓存的文件被意外下载（hydration）。
3. **本地设备发现（mDNS 多播）**：
   - 在您的本地 Wi-Fi 内，通过多播 IP `224.0.0.251:5353` 广播并监听 `_syncnexus._tcp.local`。**不会与外部互联网服务器建立任何连接**。
4. **启动配置（Windows 启动注册表）**：
   - 当用户启用时，会在 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` 注册一项，以静默启动后台同步守护程序。您可随时通过设置或 Windows 任务管理器停用。

---

### 3. 回收站与数据安全
* 被删除的文件会通过 Win32 `SHFileOperationW` 安全地放入**真正的 Windows 回收站**。
* 删除前先归档到 `.syncnexus-history`，提供多层数据保护。

---

### 4. 联系方式
如有隐私方面的疑问或 Microsoft Store 认证审核需求：  
项目仓库：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
