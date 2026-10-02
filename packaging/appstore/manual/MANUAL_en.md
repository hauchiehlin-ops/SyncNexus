# Sync-Nexus User Manual for macOS

## 1. Introduction & Overview
**Sync-Nexus for Mac** is a local-first, peer-to-peer directory synchronization application designed specifically for macOS (Sonoma & Sequoia). It provides automatic bidirectional file reconciliation across your local folders, iCloud Drive, external USB-C/Thunderbolt drives, and nearby Android devices over local Wi-Fi.

![Sync-Nexus macOS Dashboard](/Users/barretlin/.gemini/antigravity/brain/a78dbd7e-b8d4-4059-8ea4-510ecb66c712/macos_main_window_1790946573568.jpg)

---

## 2. macOS Core Capabilities
* **App Sandbox & Security-Scoped Bookmarks**: Conforms strictly to Apple App Store review guidelines. Folder access permissions persist securely across reboots using cryptographic bookmark tokens.
* **APFS Snapshot Safety**: Takes instant copy-on-write APFS filesystem snapshots before executing large synchronizations, allowing rollbacks if needed.
* **FSEvents Kernel Monitoring**: Zero CPU idle polling. Changes are detected instantly via native macOS file system kernel events.
* **Visual Diff Trial Run**: Preview exactly which files will be copied, renamed, or deleted before committing changes.
* **Local Peer Discovery (P2P)**: Discovers nearby Android and Mac devices on the same Wi-Fi network via Bonjour / mDNS with zero cloud servers.

---

## 3. Step-by-Step Instructions

### Step 1: Add Sync Endpoints
1. Launch **Sync-Nexus.app**.
2. Click **Add Folder…** on the toolbar or navigate to the **Folders** section.
3. Select your directories (e.g., `~/Documents/Projects`, your external SSD, or iCloud Drive).
4. Grant permission via the standard macOS file open dialog.

### Step 2: Visual Diff & Trial Run
1. Go to the **Diff Preview** tab in the sidebar.
2. Click **Run Trial Simulation**.
3. Inspect pending file creations, modifications, and deletions.
4. Click **Apply & Sync Now** to execute.

### Step 3: Conflict Resolution
If a file was modified simultaneously in two locations:
* Sync-Nexus preserves both versions without data loss.
* Navigate to **Conflicts** to preview the difference and choose which version to retain.
