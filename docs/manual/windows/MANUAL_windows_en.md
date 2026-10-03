# SyncNexus User Operation Manual — Windows Complete Guide

> **Applicable Platform**: Windows 10 / Windows 11 (64-bit)  
> **Core Architecture**: Local-First, Zero-Cloud Server Binding, Recycle Bin First

---

## Top Navigation Header

At the top of the Windows application window:
- **Language Dropdown**: Instantly switches between 6 interface languages.
- **User Manual (📖)**: Opens this manual directly inside an in-app dialog. No external browser redirection.
- **Privacy Policy (🛡️)**: Outlines the zero-cloud, local-first privacy commitments.

---

## Chapter 1: Overview

### 1.1 Purpose and Objectives
The **Overview** is your central health dashboard on Windows, displaying endpoint connectivity, total tracked files, the last SHA-256 verification timestamp, and version storage metrics.

### 1.2 Buttons and Controls
- **Global Health Status**: Green "All Normal" or yellow "Warning / Offline / Conflicts".
- **Mass Deletion Interception**: Intercepts deletions exceeding 25 files or 25% of total volume, prompting with a "Review and Confirm" card.
- **Tracked Files Stat**: Live count of files monitored across all endpoints.
- **Last Deep Verify Stat**: Shows when byte-by-byte integrity was last verified.
- **Old Versions Stat**: Disk space occupied by archived historical revisions.
- **Endpoint Status Cards**: Shows online status for local folders, OneDrive, Google Drive, iCloud, and USB drives (e.g. `D:`).
- **LAN P2P Direct**: Automatically discovers peers on the same Wi-Fi using standard mDNS and UDP broadcasts.

---

## Chapter 2: Diff Preview

### 2.1 Purpose and Objectives
Provides a risk-free Dry-Run simulation before committing file writes to disk, displaying additions, renames, and deletions.

### 2.2 Buttons and Controls
- **Run Trial Simulation**: Generates a detailed preview list with color-coded additions (+), renames (➔), and deletions (−).
- **Confirm and Sync**: Applies verified changes across all endpoints upon confirmation.
- **Floating Toast Alerts**: Alerts you at the top of the window when simulations finish or errors occur.

---

## Chapter 3: Folders

### 3.1 Purpose and Objectives
Manages the folders participating in synchronization (requires at least 2 folders to start).

### 3.2 Grounded Guide to Adding Storage Endpoints
Click "**Add Folder...**" and select your directories using Windows File Explorer:
1. **Local Windows Directory**: Open File Explorer, click "Documents" or navigate into `C:` to pick your directory.
2. **OneDrive**: Open File Explorer, click "OneDrive" on the left sidebar, and pick your folder.
3. **Google Drive**: Open File Explorer, click "Google Drive" ➔ "My Drive", and choose your folder.
4. **iCloud Drive (for Windows)**: Open File Explorer, click "iCloud Drive", and choose your folder.
5. **External USB Flash / Portable Drive**: Plug in your USB drive, open File Explorer, click your drive letter under "This PC" (e.g. `D:` or `E:`), and select your directory. **Format as ExFAT** for seamless plug-and-play with Macs!

### 3.3 Buttons and Marker Safeguards
- **Add Folder...**: Adds a new directory, writing a unique `.syncnexus-endpoint` UUID marker.
- **Change Folder...**: Rebinds paths when drive letters change or folders are relocated.
- **Remove...**: Unbinds the folder from the sync network; **never deletes your physical files**.
- **Marker Guard**: Halts syncing if an incorrect USB drive is inserted into the same mount path.

---

## Chapter 4: Conflicts

### 4.1 Purpose and Objectives
When a file is modified simultaneously on two offline machines, SyncNexus creates a `Filename (conflict ...)` copy for side-by-side comparison without overwriting.

### 4.2 Buttons and Controls
- **Keep This Version**: Retains the primary version and propagates it; archives the conflict copy.
- **Use This Version**: Adopts the conflict copy as canonical, archiving the previous version to history.
- **Reveal in File Explorer**: Opens Windows File Explorer and selects the file for diffing.

---

## Chapter 5: Versions (History)

### 5.1 Purpose and Objectives
Every replaced or deleted file is preserved in `.syncnexus-history`, enabling one-click restoration.

### 5.2 Buttons and Controls
- **Retention Period**: Choose 7 / 30 / 90 days or Permanent.
- **Clean Expired**: Purges outdated revisions to reclaim disk storage.
- **Clear All**: Clears version archives without touching active working files.
- **Search Filter**: Filters versions by filename or endpoint.
- **Restore**: Recovers selected version and syncs across all folders.

---

## Chapter 6: Verification

### 6.1 Purpose and Objectives
Byte-by-byte SHA-256 integrity verification across all endpoints to prevent file corruption.

### 6.2 Buttons and Controls
- **Start Verification Now**: Runs deep hash computation on all endpoints.
- **Repair from Others**: Overwrites corrupted file with a verified clean copy from a healthy endpoint.
- **Accept Current Content**: Updates the hash baseline if the modification was intentional.

---

## Chapter 7: Settings

### 7.1 Purpose and Objectives
Customize conflict policies, exclusions, and Windows system preferences.

### 7.2 Buttons and Controls
- **Conflict Policy**: "Keep both, let me choose" vs "Newer wins, old saved to versions".
- **Exclude Presets**: Toggle exclusion for `node_modules`, `.git`, and database journals (`-wal`, `-shm`).
- **Language**: Switch between 6 supported languages.
- **Launch at Login**: Minimizes to Windows System Tray on startup.
- **Open Log File**: Opens active log in Notepad.
