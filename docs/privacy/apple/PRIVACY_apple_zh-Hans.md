# SyncNexus 隐私政策 — Apple (App Store 审核标准)

**生效日期**：2026 年 10 月 3 日  
**发行平台**：Apple App Store (macOS / iOS / iPadOS)  
**开发团队**：SyncNexus Team  

SyncNexus 秉持“隐私是基本人权”的原则。本隐私政策严格遵循 **Apple App Store 审核指南（特别是准则 5.1.1 数据收集与存储）**，说明我们零数据收集、完全本机优先的处理架构。

---

### 1. 零数据收集与零遥测
* **无远程数据传输**：SyncNexus 没有任何远程服务器。您的文件内容、文件名、文件夹层级与加密校验值 (SHA-256)，**仅存储在您的本机设备与您选择的同步文件夹中**。
* **无第三方 SDK / 无分析**：SyncNexus 不包含任何第三方追踪、广告、分析或行为遥测 SDK。
* **无需账号**：使用 SyncNexus 无需创建账号、注册电子邮件或披露个人身份。

---

### 2. 遵循 Apple App Sandbox 与权限 (Entitlements)
SyncNexus 完全在 Apple App Sandbox 环境内运行，仅请求本地文件同步所需的最少权限：
1. **用户选择的文件与文件夹 (`com.apple.security.files.user-selected.read-write`)**：
   - 访问范围严格限于用户通过原生 `NSOpenPanel` 明确选取的目录。
2. **安全范围书签 (`com.apple.security.files.bookmarks.app-scope`)**：
   - 在沙盒内使用，用于在应用程序重新启动后保留用户所选文件夹的授权凭据。
3. **本地网络通信 (`com.apple.security.network.client` / `network.server`)**：
   - 仅用于 Apple Bonjour (mDNS 多播)，在同一 Wi-Fi 网络中发现其他 SyncNexus 节点（Mac、Windows、Android）。**绝不会向公共互联网传输任何数据**。

---

### 3. 数据完整性与防护
* **删除保护**：自动拦截大量删除事件（超过 25 个文件或超过 25% 的已跟踪项目），避免因可移动存储设备断开而造成意外丢失。
* **版本历史**：自动将被替换或移入垃圾桶的文件保存在归档目录中，可立即回滚。

---

### 4. 联系方式
如有隐私方面的疑问或 App Store 审核说明需求：  
项目仓库：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
