# Sync-Nexus 操作使用手册 (macOS 版)

## 1. 简介与总览
**Sync-Nexus for Mac** 是一款专为 macOS 量身打造的“本地优先、点对点”双向目录同步系统。支持本地目录、iCloud 云盘、外接 USB-C / Thunderbolt 高速移动硬盘，以及通过同 Wi-Fi 局域网与 Android 设备直连同步。

![Sync-Nexus macOS 主界面](/Users/barretlin/.gemini/antigravity/brain/a78dbd7e-b8d4-4059-8ea4-510ecb66c712/macos_main_window_1790946573568.jpg)

---

## 2. macOS 专属核心特色
* **App Sandbox 与安全作用域书签 (Security-Scoped Bookmarks)**：完全符合 Mac App Store 审查规范。授权权限通过系统书签安全加密保存，重新启动免重新选取。
* **APFS 快照防护机制**：在执行大型同步前，自动调用 APFS 建立写时复制快照，提供无损恢复防线。
* **FSEvents 内核事件监听**：闲置时完全零 CPU 负载，文件有变动时毫秒级即时触发。
* **差异预览与试跑 (Visual Diff Trial Run)**：写入磁盘前预先检阅新增、改名与删除清单。
* **Bonjour 局域网直连 (P2P)**：同 Wi-Fi 下自动发现 Android 与其他 Mac 设备，不经任何云端服务器。

---

## 3. 操作步骤说明

### 步骤 1：添加同步端点
1. 打开 **Sync-Nexus.app**。
2. 点击工具栏上的 **添加文件夹…** 或前往“文件夹”选项卡。
3. 挑选欲同步的文件夹（例如：本地项目目录、外接 SSD 或 iCloud 云盘）。
4. 在 macOS 标准对话框中完成授权。

### 步骤 2：差异预览与试跑
1. 点击侧边栏的 **差异预览** 选项卡。
2. 点击 **执行试跑模拟**。
3. 检视即将变更的文件清单。
4. 点击 **立即套用并执行同步** 开始作业。

### 步骤 3：冲突排除
当两端同时修改相同文件时：
* Sync-Nexus 会自动保留双方版本，绝不静默覆盖。
* 前往 **冲突** 选项卡检视差异，并自选保留哪一份版本。
