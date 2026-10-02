# SyncNexus User Manual — Windows

## 1. Introduction & Highlights
**SyncNexus for Windows** is a modern, local-first two-way file synchronization center built for Windows 10 and Windows 11. It blends high-performance .NET 9, Fluent Design UI, taskbar tray background guardianship, and cross-platform synergy with macOS and Android.

* **Universal Endpoints**: Local NTFS folders, Google Drive virtual streams (`G:\`) or mirror paths, OneDrive Files On-Demand, and shared ExFAT removable disks.
* **Smart Cloud Placeholder Handling**: Detects Windows Cloud Files API attributes (`RECALL_ON_DATA_ACCESS` / `REPARSE_POINT`) to prevent unintended hydration of uncached cloud files.
* **Dynamic Drive Letter Re-alignment**: Automatically re-aligns endpoints when an external drive letter shifts (e.g. from `E:\` to `F:\`) by tracking volume serial numbers.
* **Long Path Awareness**: Declares `longPathAware` in application manifest, removing the traditional 260-character Windows path limit.

---

## 2. Quick Setup
1. **Adding Sync Endpoints**:
   - Click **"+ Add Endpoint"** in the top header.
   - Browse for a local folder or choose auto-detected **Google Drive** or **OneDrive** paths from the dropdown.
   - For USB drives, check "Removable Disk" to enable serial number tracking.
   - If an existing `.syncnexus-endpoint` marker from macOS or Android is found, SyncNexus automatically certifies and adopts it.
2. **Real-Time Monitoring & Execution**:
   - Click "Sync Now" for immediate reconciliation.
   - `WindowsFileWatcher` monitors changes with a 2-second debounce interval.
3. **Taskbar Tray Operation**:
   - Closing the main window minimizes SyncNexus to the Windows system tray.
   - Right-click the tray icon to restore the window, force synchronization, or exit cleanly.

---

## 3. Conflict Resolution & Native Recycle Bin
* **Conflict Isolation**: Concurrent edits are saved with the pattern `name (conflict endpoint yyyy-MM-dd HH-mm).ext`. Resolve easily via "Conflict Management" in the header.
* **Native Recycle Bin**: Deleted items are dispatched into the genuine Windows Recycle Bin via Win32 Shell API (`SHFileOperationW`).
* **Version Archiving**: Replaced versions are archived to `.syncnexus-history` for instant rollback.
