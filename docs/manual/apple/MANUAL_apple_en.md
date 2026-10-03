# SyncNexus User Operation Manual — Apple (macOS) Complete Guide

> **Applicable Platform**: macOS 14.0 (Sonoma) and later  
> **Current Version**: 1.0.12 (build 20)  
> **Core Architecture**: Local-First, Zero-Cloud Server Binding, Absolute Data Protection (Trash-First & History-Protected)

---

## Top Navigation Header

At the very top of the main window, the global navigation header is arranged as follows:

```
[ Current Page Title ] ------------------------- [ Language Menu ▾ ] [ 📖 Manual ] [ 🛡️ Privacy ]
```

1. **Language Dropdown Picker**:
   - **Location**: Top-right corner of the header.
   - **Purpose**: Instantly switches between 6 interface languages (Traditional Chinese, Simplified Chinese, English, Japanese, Korean, Thai).
   - **How to Use**: Click to open the dropdown and pick your preferred language. The entire app switches instantly without restart.
2. **User Manual Button (📖 icon)**:
   - **Location**: Next to the language menu.
   - **Purpose**: Opens this complete user manual directly in a native in-app sheet. No internet connection required, no redirecting to external GitHub pages.
   - **How to Use**: Click to open. Press `Esc` or click "Close" to return to your work.
3. **Privacy Policy Button (🛡️ icon)**:
   - **Location**: Next to the manual button.
   - **Purpose**: Displays SyncNexus's zero-cloud privacy commitments and App Sandbox security guarantees.

---

## Chapter 1: Overview

![Overview Screen](../assets/01_overview.png)

### 1.1 Purpose and Objectives
The **Overview** is SyncNexus's **global health dashboard**. Without having to inspect individual files, you can see system health at a glance, monitor total tracked files, check the last deep verification timestamp, view history capacity, and verify storage endpoint statuses.

### 1.2 Buttons and Controls

| Control / Element | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Global Health Badge** | Top title area | Displays overall synchronization health status | Automatic continuous monitoring | Green shows "All Normal"; turns to yellow warning badge if an endpoint is offline, conflicts exist, or mass-deletion is intercepted. |
| **Mass Deletion Card** | Below top title (only when abnormal) | Safeguard against accidental deletions or ransomware | Click "**Review and Confirm**" on the card | Automatically intercepts and halts synchronization when >25 files or >25% of files are deleted in a single pass. |
| **Tracked Files Stat** | Stat Tile #1 | Displays total number of files tracked across endpoints | Read-only | Noted with "Real-time SHA-256 tracking", updating dynamically on every file change. |
| **Last Deep Verify Stat** | Stat Tile #2 | Shows when the last byte-by-byte SHA-256 integrity check ran | Read-only | Shows "No anomalies" or "X suspected corrupted" alerting you to take corrective action. |
| **Old Versions Stat** | Stat Tile #3 | Displays disk storage occupied by version archives and retention days | Read-only | Displays e.g. "24.5 MB · 30 days retention, restorable anytime". Manageable via "Versions" tab. |
| **Endpoint Status Cards** | Central grid area | Shows status, directory path, and filesystem attributes of each folder | View card info | Shows green "Online" or yellow "Offline" chip; external drives display "Removable / ExFAT". |
| **LAN P2P Direct Card** | Bottom network area | Automatically discovers peer Macs or Android devices running SyncNexus on the same Wi-Fi | Continuous discovery | Displays discovered peer device name with green "Online" chip for point-to-point direct syncing. |

---

## Chapter 2: Diff Preview

![Diff Preview Screen](../assets/02_diff_preview.png)

### 2.1 Purpose and Objectives
Before committing changes to disk, **Diff Preview** provides a **Dry-Run Simulation**. For developers and power users managing critical assets, this lets you inspect upcoming copies, renames, and deletions with zero risk.

### 2.2 Buttons and Controls

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Run Trial Simulation** | Main card top-left (Primary Blue button) | Simulates reconciliation across all endpoints without writing to disk | Click button; changes to "Simulating..." | Generates a detailed preview list below with total count (e.g., "3 items pending sync"). |
| **Confirm and Sync** | Bottom-right of preview list (after preview) | Executes verified changes across all endpoints | Click to confirm | Sync engine immediately applies changes; top floating toast confirms successful sync. |
| **APFS Snapshot Safeguard** | Next to "Run Trial Simulation" button | Invokes native macOS APFS snapshots for a reliable rollback point before large syncs | Click to create snapshot | On success, shows "APFS Snapshot Created"; if unprivileged or unsupported, displays top floating Toast HUD with sandbox explanation (see below). |

![Toast Notification](../assets/02_diff_preview_toast.png)

> **Preview Symbols**:
> - 🟢 **`+` (Green)**: File scheduled to be added or copied from another endpoint.
> - 🔵 **`➔` (Blue)**: File scheduled to be renamed locally (eliminating redundant re-downloads).
> - 🔴 **`−` (Red)**: File scheduled for deletion (**Guaranteed: Moved to macOS Trash first, never permanently wiped**).

---

## Chapter 3: Folders

![Folders Management](../assets/03_folders_endpoints.png)

### 3.1 Purpose and Objectives
The **Folders** tab manages synchronization targets. SyncNexus allows you to bind **multiple storage locations** (local Mac directories, iCloud Drive, Google Drive, and external USB disks) into a unified synchronization group. A change in one folder is automatically replicated across all others.

### 3.2 Grounded Guide to Adding Storage Endpoints

Click "**Add Folder...**" at the bottom of the page and select at least 2 directories you wish to keep in sync:

1. **Local Mac Directory**:
   - Open Finder, click "Documents" or your home folder on the left sidebar, and choose your folder.
2. **iCloud Drive**:
   - Open Finder, click "iCloud Drive" on the left sidebar, and select your target directory. SyncNexus automatically handles cloud placeholders to ensure local hydration.
3. **Google Drive**:
   - Open Finder, click "Google Drive" on the left sidebar, navigate to "My Drive", and pick your target directory.
4. **External USB Flash / Portable Drive**:
   - Plug your USB disk into your Mac, open Finder, click the disk name under "Locations" on the left sidebar, and pick your directory.
   - **Recommended Format**: Format the drive as **ExFAT**. SyncNexus automatically activates "ExFAT / Windows compatible filename" filters to guarantee cross-platform compatibility!

### 3.3 Buttons and Marker Safeguards

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Add Folder...** | Bottom primary blue button | Authorizes and adds a new folder into the mesh sync network | Click and select directory in Finder | Writes unique `.syncnexus-endpoint` UUID marker and establishes App Sandbox security bookmark. |
| **Change Folder...** | First button on each endpoint row | Re-links directory if moved or remounted | Click and select new path | Validates marker file and resumes syncing; alerts if invalid path. |
| **Remove...** | Second button on each endpoint row | Safely unbinds folder from sync network | Click and confirm in dialog | Detaches folder from sync engine; **never deletes your physical files**. |
| **Marker Mismatch Guard** | Endpoint card status area | Prevents data overwrite if a different drive is plugged into the same mount path | Automatic verification | Displays "Marker does not match endpoint... stopped, no changes propagated" (see below), isolating the endpoint safely! |

![Marker Guard Alert](../assets/03_folders_offline_marker.png)

---

## Chapter 4: Conflicts

![Conflicts Screen](../assets/04_conflicts.png)

### 4.1 Purpose and Objectives
When a file is modified independently on two offline endpoints (e.g. Mac edited line 5 while Windows edited line 10), typical tools blindly overwrite one copy. SyncNexus strictly adheres to the **"Zero-Overwrite" Rule**: conflicting versions are preserved as `Filename (conflict ...)`, gathered here for easy side-by-side arbitration.

### 4.2 Buttons and Dual-Version Resolution

Each conflict item is presented as a side-by-side dual-card:

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Keep This Version** | Left card ("Current Version") bottom | Keeps the current primary file as canonical | Click button | Primary file stays intact and propagates to other endpoints; conflict file is safely archived. |
| **Use This Version** | Right card ("Conflict Version" marked with green "Newer" badge) | Overwrites primary with the conflict copy | Click button | Conflict copy becomes the canonical file; previous primary is backed up into the Versions archive. |
| **Reveal in Finder** | Available on both cards | Directly navigates to the physical file in macOS Finder | Click button | Automatically opens Finder and highlights the file, enabling you to inspect contents in any text/diff editor. |
| **Zero-Conflict State** | Center when no conflicts | Confirms all endpoints are cleanly aligned | Read-only | Shows green checkmark with "No pending conflicts, all files identical". |

---

## Chapter 5: Versions (History)

![Versions Screen](../assets/05_versions.png)

### 5.1 Purpose and Objectives
**Versions** is your **time machine and recovery center**. Whenever a file is overwritten by sync or user edit, previous iterations are archived in `.syncnexus-history`, enabling one-click restoration of previous drafts or mistakenly replaced files.

### 5.2 Buttons and History Management

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Retention Policy Menu** | Top card "Auto Clean" dropdown | Configures automatic expiration period for archived files | Choose: 7 / 30 / 90 days / Permanent | Expired versions are pruned in the background, keeping disk usage under control. |
| **Clean Expired Now** | Next to retention menu | Manually triggers immediate removal of expired files | Click button | Immediately frees storage space occupied by outdated versions and refreshes capacity stats. |
| **Clear All** | Next to "Clean Expired" button | Wipes all historical versions (requires caution) | Click and confirm in modal dialog | Only deletes archived history copies; **never touches your current active files**. |
| **Search Filter** | Top right of versions list | Quickly filters history items by filename or endpoint | Type keywords to filter | Real-time filtering matching paths and extensions. |
| **Reveal in Finder** | Next to search filter | Reveals `.syncnexus-history` in Finder | Click button | Opens the local history storage folder in macOS Finder. |
| **Restore** | Right side of each history entry | Restores specific revision back to your working directory | Click "**Restore**" | Overwrites current file with selected historical version and syncs across all endpoints. |

---

## Chapter 6: Verification

![Verification Screen](../assets/06_verification.png)

### 6.1 Purpose and Objectives
Drives can suffer from silent bit-rot, and networks can drop fragments. SyncNexus uses industry-standard **SHA-256 hashes** to perform byte-by-byte verification across all storage endpoints, guaranteeing 100% data integrity.

### 6.2 Buttons and Integrity Operations

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Start Verification Now** | Central card right side | Launches deep SHA-256 integrity scan across all endpoints | Click "**Verify Now**" | Calculates hashes in background, updating "Last Deep Verify" timestamp and reporting corruptions. |
| **Repair from Others** | Appears when a corrupted file is detected (Primary) | Downloads pristine copy from a healthy endpoint to replace corrupt file | Click to repair | Fetches clean copy from healthy peer; damaged copy is safely archived first before overwriting. |
| **Accept Current Content** | Appears when corruption detected (Secondary) | Marks current file as intentional and updates baseline hash | Click to accept | Recomputes baseline hash in database, clearing integrity alert. |
| **Safeguards Checklist** | Bottom card | Summarizes SyncNexus's built-in multi-layered safety shields | Read-only | Outlines Trash-First, Marker Lock, Mass Deletion Interception, and SHA-256 Continuous Monitoring. |

---

## Chapter 7: Settings

![Settings Screen](../assets/07_settings.png)

### 7.1 Purpose and Objectives
**Settings** provides granular configuration for conflict policies, exclusion rules, system integration, and macOS Full Disk Access permissions.

### 7.2 Settings and Preferences

| Setting Item | UI Location | Purpose & Objective | Options & How to Use | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Conflict Policy** | Top card | Sets default arbitration rule when dual edits occur | Radio options:<br>1. **Keep both, let me choose** (Default & Recommended)<br>2. **Newer wins, old saved to versions** | Option 1 creates conflict copies for manual resolution. Option 2 automatically keeps newest modification time while backing up superseded copies to history. |
| **Exclude Presets** | Second card | Excludes ephemeral or volatile directories to prevent corruption | Toggle switches:<br>• `node_modules`<br>• `.git`<br>• Database journals (`-wal`, `-shm`)<br>• Photos libraries (`.photoslibrary`) | Excluded directories remain untouched across all endpoints, significantly saving bandwidth and disk I/O. |
| **Language** | Third card top | Configures application display language | Dropdown menu with 6 languages | Switches entire app language instantly. |
| **Launch at Login** | Switch below language menu | Launches SyncNexus daemon upon macOS login | Toggle switch ON / OFF | Runs quietly in menu bar upon login to maintain synchronization. |
| **Full Disk Access** | Permissions card | Verifies file read/write permissions | Displays "Authorized" (green) or "Unauthorized" (yellow) | If unauthorized, click "**Open System Settings**" to open macOS "Privacy & Security ➔ Full Disk Access" (see below), and toggle SyncNexus ON. |
| **Open Log File** | Bottom-left button | Inspects real-time diagnostic and sync events | Click button | Opens active log in Console or default text editor for troubleshooting. |
| **Show Instructions** | Next to "Open Log File" | Re-displays the initial onboarding walkthrough | Click button | Opens the Onboarding wizard to review initial quickstart steps. |

![macOS Full Disk Access Permissions](../assets/07_settings_permissions.png)

---

## Summary: Best Practices

1. **Set and Forget**: When all endpoints show "Online", any file saved or renamed will sync across all other folders within 2 seconds.
2. **Simulate First**: Before large reorganizations or deletions, visit **Diff Preview** and click "**Run Trial Simulation**".
3. **No Fear of Mistakes**: Check macOS **Trash** first; if emptied, go to **Versions** and click "**Restore**" — your files are always safeguarded!
