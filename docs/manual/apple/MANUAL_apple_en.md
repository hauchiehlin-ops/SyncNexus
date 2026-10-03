# SyncNexus User Manual — Apple (macOS / iOS) Edition

## 1. Overview & Key Highlights
**SyncNexus for Apple** is a local-first, zero-cloud-lock-in real-time file synchronization app designed for Mac and iPhone. It keeps your folders identical without third-party servers.

* **App Sandbox Protection**: Strictly adheres to Apple App Store sandbox requirements; never accesses unauthorized personal files.
* **Local Network P2P Direct Connect**: Utilizes Apple Bonjour to automatically discover other Macs, Windows PCs, and Android phones on the same Wi-Fi.
* **Safety First & Version History**: Changes are preserved in a built-in multi-version repository, with full macOS Trash integration for safe recovery.
* **Multiple Storage Targets**: Supports Mac local folders, iCloud Drive, Google Drive, and external USB flash drives / portable hard drives.

---

## 2. Quick Start: Adding Folders to Sync

Go to the "Folders" tab and click "**Add Folder...**" to choose at least two folders you want to keep in sync:

1. **Computer Local Folder**:
   - Open **Finder**, click "**Documents**" or your user home folder in the left sidebar, and select the folder you want to sync.
2. **iCloud Drive**:
   - Open **Finder**, click "**iCloud Drive**" in the left sidebar, and pick the folder you wish to keep in sync. SyncNexus will automatically track changes.
3. **Google Drive**:
   - Open **Finder**, click "**Google Drive**" in the left sidebar, then click "**My Drive**", and pick the target folder.
4. **External USB Flash Drive / Portable Hard Drive**:
   - Plug the external drive into your Mac. Open **Finder**, click your drive's name under "**Locations**" in the left sidebar, and choose your folder. Formatting as **ExFAT** is strongly recommended for cross-platform compatibility between Mac and Windows!

---

## 3. Automatic Synchronization & Smart Safety

* **Zero Manual Effort**:
  Whenever you add, modify, rename, or delete a file in any folder, SyncNexus automatically syncs the changes to all other endpoints within 2 seconds.
* **Smart Diff Preview (Trial Run)**:
  Before committing changes, visit the "Diff Preview" tab and click "Run Trial Simulation" to view an exact checklist of pending operations with zero risk.
* **Offline Conflict Protection**:
  If files are edited on two sides simultaneously while offline, SyncNexus never overwrites data. It saves a timestamped conflict copy (e.g. `Filename (conflict ...)`), safely keeping both versions.
* **History Versions & Deletion Guard**:
  - Deleted files go to the macOS Trash whenever possible.
  - Older overwritten versions can be restored with a single click in the "Versions" tab.
  - If more than 25 files or 25% of items are deleted at once, Deletion Guard automatically halts syncing and requests user confirmation to prevent accidental loss.
