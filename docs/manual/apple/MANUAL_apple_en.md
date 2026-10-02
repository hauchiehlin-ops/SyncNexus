# SyncNexus User Manual — Apple (macOS / iOS)

## 1. Introduction and Architecture
**SyncNexus for Apple** is a local-first, two-way real-time file synchronization and reconciliation utility built natively for macOS and iOS. It delivers serverless zero-cloud architecture, cryptographic integrity verification, and comprehensive App Sandbox privacy protection.

* **App Sandbox Architecture**: Strictly adheres to Apple App Store App Sandbox rules, persisting folder permissions through Security-Scoped Bookmarks.
* **Serverless & P2P Direct Connect**: Leverages Apple Bonjour (mDNS `_syncnexus._tcp`) to automatically discover other Mac, Windows, and Android nodes on the same Wi-Fi.
* **APFS Snapshot Protection**: Creates APFS snapshots on supported volumes prior to major sync runs for instant rollback.
* **Multi-Target Support**: Local folders, iCloud Drive, Google Drive with placeholder detection, and external ExFAT drives.

---

## 2. Quick Setup & Endpoint Management
1. **Launch and Grant Access**:
   - Open `SyncNexus.app`. When adding your first folder, choose the directory via the native `NSOpenPanel`.
   - The application automatically generates a Security-Scoped Bookmark and writes the identity marker `.syncnexus-endpoint`.
2. **Cloud and External Storage Configuration**:
   - **iCloud Drive**: Select your target folder under `~/Library/Mobile Documents/com~apple~CloudDocs/`.
   - **Google Drive**: Select Google Drive streaming or mirrored folders under CloudStorage.
   - **External Storage**: Connect an ExFAT drive and select your folder under `/Volumes/<VolumeName>`.
3. **Reconciliation & Real-Time Sync**:
   - Click "Sync Now" or rely on FSEvents for real-time monitoring (2-second debouncing).
   - Use "Diff Preview" to inspect pending file creations, edits, and deletions prior to execution.

---

## 3. Conflict Resolution & Version History
* **Non-Destructive Conflict Preservation**: Concurrent edits are never overwritten. Local conflicts are saved as `Filename (conflict Endpoint yyyy-MM-dd HH-mm).ext`.
* **Version History**: Replaced files are automatically archived and can be restored at any time.
* **Deletion Guard**: Halts automatically and requests explicit user confirmation whenever planned deletions exceed 25 files or 25% of tracked files.
