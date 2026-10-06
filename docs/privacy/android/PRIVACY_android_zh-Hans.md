# SyncNexus 隐私政策 — Android (Google Play 审核专用)

**生效日期**：2026 年 10 月 5 日  
**发行平台**：Google Play Store (Android)  
**开发团队**：SyncNexus Team  

SyncNexus 致力于最高标准的个人隐私保护与透明度。本政策严格遵循 **Google Play 开发者政策（包括用户数据政策 User Data Policy 及重要披露 Prominent Disclosure 要求）**，详细说明文件访问与系统权限的处理原则。

---

### 1. 核心隐私承诺：零服务器、无追踪
* **无远程服务器**：SyncNexus 没有架设任何后端服务器。您的所有文件内容、路径信息及 SHA-256 哈希值，**仅在您的设备本机及您明确选取的存储目录中处理**。
* **无第三方 SDK、无广告**：SyncNexus 不包含任何第三方追踪、分析、广告或崩溃遥测程序库。
* **无个人身份信息 (PII)**：无需登录、无账号，也不会收集或传输任何硬件标识符（如 IMEI、Android ID）。

---

### 2. 应用程序在您设备上保存的数据
为了提供差异预览、冲突、旧版本与验证记录功能，SyncNexus 会在 **App 的私有存储空间**中保存以下内容：
* 每个同步群组中，上次所有文件夹一致时各文件的哈希值与修改时间（用于判断是哪一端发生了变化）。
* 尚未处理的冲突列表。
* **版本归档**：被同步更新、冲突裁决或还原所替换的文件副本，保留 30 天（总量上限 1 GB，超过时先清除最旧的）。
* 验证记录（时间、文件数、结果）。

这些数据**只保留在您的设备上，绝不上传**。移除群组会一并删除其记录；卸载 App 或在 Android 设置中清除数据会删除全部内容。冲突副本存放在发生冲突的同步文件夹内，由您决定保留或丢弃。

---

### 3. Android 权限与重要披露 (Prominent Disclosure)
为了提供可靠的本地文件同步，SyncNexus 使用以下限定范围的权限：
1. **存储访问框架 (SAF)**：
   - SyncNexus 不会请求范围过大的 `MANAGE_EXTERNAL_STORAGE` 权限。用户通过系统文档树选择器（`takePersistableUriPermission`）明确授予特定文件夹的访问权。
2. **前台服务 (`FOREGROUND_SERVICE_DATA_SYNC`) 与通知 (`POST_NOTIFICATIONS`)**：
   - Android 要求以此在后台稳定运行同步。常驻通知会显示各同步群组的状态，让同步活动保持可见。
3. **网络权限 (`INTERNET`、`ACCESS_WIFI_STATE`、`CHANGE_WIFI_MULTICAST_STATE`) 与本地网络服务发现 (NSD / mDNS)**：
   - Android 要求具备这些权限才能使用 NSD。它们**仅用于在您的本地 Wi-Fi 网络内发现附近的 SyncNexus 设备（Mac / Windows）**。本 App 不会连接任何外部服务器，也不会上传或下载任何数据。
4. **USB 设备连接监听**：
   - 仅用于检测外接 USB OTG 存储设备的插入或拔出，以便即时掌握同步端点的状态。

---

### 4. 用户控制权
用户可随时在应用程序内移除已授权的文件夹、删除已归档的版本，或通过 Android 系统设置撤销权限并清除本地数据。

---

### 5. 联系方式
如有隐私方面的疑问或审核说明需求：  
项目仓库：[https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
