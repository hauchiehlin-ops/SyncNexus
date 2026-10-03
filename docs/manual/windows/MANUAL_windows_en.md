# SyncNexus User Manual — Windows Edition

## 1. Overview & Highlights
**SyncNexus for Windows** is a local-first, zero-cloud-lock-in real-time synchronization utility built for Windows 10 and Windows 11. It synchronizes directories without third-party servers.

* **Fluent Windows Experience**: System tray support, minimize-to-tray, auto-start on boot, and native toast notifications.
* **Cross-Platform LAN Discovery**: Dual-stack mDNS (224.0.0.251:5353) and UDP beaconing to automatically connect with Macs and Android phones on the same Wi-Fi.
* **Complete Safety Shield**: Deletions go straight to Windows Recycle Bin via Win32 Shell API (`SHFileOperationW`), preventing accidental data loss.

---

## 2. Quick Start: Adding Sync Folders

Click "**Add Sync Endpoint...**" on the main window and choose your directories:

1. **Local Folders**:
   - Open **File Explorer**, navigate to "**Documents**" or your `C:` drive, and select the folder you want to sync.
2. **iCloud Drive**:
   - Open **File Explorer**, click the "**iCloud Drive**" icon in the left navigation pane, and pick your target folder.
3. **Google Drive**:
   - Open **File Explorer**, click "**Google Drive**" in the left navigation pane, click "**My Drive**", and select your folder.
4. **OneDrive**:
   - Open **File Explorer**, click "**OneDrive**" in the left sidebar, and pick your target folder.
5. **External USB Flash Drives / Portable Hard Drives**:
   - Plug in your USB drive, open **File Explorer**, click your drive letter under "**This PC**" (e.g. `D:` or `E:`), and select your folder. Formatting as **ExFAT** is recommended for cross-platform sharing with Mac!

---

## 3. Automatic Synchronization & Protection

* **Real-time Monitoring**: File changes trigger automatic reconciliation and copying within 2 seconds.
* **Conflict Safeguard**: Simultaneous edits preserve both versions by archiving a timestamped conflict copy.
* **Recycle Bin & History**: Deletions go to the Windows Recycle Bin, and previous versions can be restored anytime from the "Conflicts" window.
