# SyncNexus User Operation Manual — Windows Complete Guide

> **Applicable Platform**: Windows 10 / Windows 11 (64-bit)  
> **Current Version**: 1.2.0 (build 22)  
> **Core Design Principles**: Local-First, Zero-Cloud Server Dependency, Recycle Bin First

---

## Top Navigation Header

At the very top of the Windows application window, the global navigation bar is arranged as follows:

```
[ Current Page Title ] ------------------------- [ Language Menu ▾ ] [ 📖 Manual ] [ 🛡️ Privacy ]
```

1. **Language Dropdown Menu**:
   - **Location**: Top-right corner of the header.
   - **Purpose**: Instantly switch between 6 interface languages (Traditional Chinese, Simplified Chinese, English, Japanese, Korean, Thai).
   - **How to Use**: Click to expand the menu, select your target language; the entire app changes language immediately without restarting.
2. **User Operation Manual Button (📖 icon)**:
   - **Location**: Right side of the language menu.
   - **Purpose**: Opens this manual directly inside an in-app dialog, requiring no internet connection and without opening an external browser.
   - **How to Use**: Click to open, browse anytime; press `Esc` or "Close" to return to your work.
3. **Privacy Policy Button (🛡️ icon)**:
   - **Location**: Right side of the manual button.
   - **Purpose**: Outlines our local-first synchronization privacy commitments and zero-cloud transmission protections.

---

## Chapter 1: Overview

### 1.1 Purpose and Objectives
The **Overview** is the global health dashboard for Windows users. It presents folder online/offline statuses, total tracked files, the last SHA-256 verification timestamp, historical version usage, and local network P2P discovery.

### 1.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1: Check Top Control Bar】**: Look at the top-right header for the Language Picker, 'User Manual 📖', and 'Privacy 🛡️' buttons. Click anytime to switch languages or consult the manual.
- **【Step 2: Check Global Health Status】**: The top-left health badge shows green "All Normal" when everything is healthy, or yellow "Warning" if folders are disconnected or conflicts are pending.
- **【Step 3: Respond to Mass Deletion Safeguard】**: If >25 files or >25% of files are deleted in a single pass, sync halts automatically and a "Review and Confirm" banner appears. Click to approve or restore.
- **【Step 4: Check Endpoints & LAN P2P】**: The center grid displays the status of all folders in the active group; nearby Mac and Android devices on the same Wi-Fi are automatically discovered via mDNS/UDP.

### 1.3 Controls, Locations & Safety Safeguards

| Control / Element | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Global Health Status** | Top title area | Overall synchronization health status | Automatic continuous monitoring | Green "All Normal"; turns to yellow "Warning" upon disconnections, conflicts, or mass deletions. |
| **Mass Deletion Safeguard** | Below top title (only when abnormal) | Protects against accidental wipes or ransomware | Click "**Review and Confirm**" | Intercepts and pauses sync when >25 files or >25% of files are deleted at once. |
| **Tracked Files Stat** | Stat Tile #1 | Total number of files tracked across endpoints | Read-only | Noted with "Real-time SHA-256 tracking", updating dynamically on file changes. |
| **Last Deep Verify Stat** | Stat Tile #2 | Timestamp of the last SHA-256 integrity check | Read-only | Shows "No anomalies" or "X suspected corrupted" alerting you to take action. |
| **Old Versions Stat** | Stat Tile #3 | Storage occupied by version archives | Read-only | Shows e.g. "24.5 MB · 30 days retention, restorable anytime". |
| **Endpoint Status Cards** | Central grid area | Status and path of each synchronized folder | View card info | Shows green "Online" or yellow "Offline"; external drives display "ExFAT". |
| **LAN P2P Direct Card** | Bottom network area | Discovers Macs, PCs, and Android devices on Wi-Fi | Continuous discovery | Displays discovered peer device name with green "Online" chip for direct P2P transfer. |

---

## Chapter 2: Diff Preview

### 2.1 Purpose and Objectives
Before committing changes to target disks, **Diff Preview** provides a risk-free **Dry-Run Simulation**, allowing you to preview pending copies, renames, and deletions.

### 2.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1: Click Run Trial Simulation】**: Click the blue "Run Trial Simulation" button on the top-left card. The button changes to "Simulating..." while calculating in-memory differences without touching disk files.
- **【Step 2: Inspect Preview Symbols】**: A list expands below: Green `+` (new copies), Blue `➔` (smart renames), Red `−` (deletions, moved to Recycle Bin first).
- **【Step 3: Click Confirm and Sync】**: After verifying the list, click "Confirm and Sync" at the bottom right to apply the changes to all disks; a top Toast notification confirms completion.

### 2.3 Controls, Locations & Safety Safeguards

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Run Trial Simulation** | Main card top-left (Blue button) | Simulates reconciliation across all endpoints | Click button | Changes to "Simulating...", then displays change preview list below. |
| **Confirm and Sync** | Bottom-right of preview list | Writes verified changes to target disks | Click to confirm | Launches sync engine; top floating toast confirms successful sync. |

> **Preview Symbols**:
> - 🟢 **`+` (Green)**: Files scheduled to be added or copied.
> - 🔵 **`➔` (Blue)**: Files scheduled to be renamed locally.
> - 🔴 **`−` (Red)**: Files scheduled for deletion (**Guaranteed: Moved to Windows Recycle Bin first, never permanently wiped**).

---

## Chapter 3: Folders

### 3.1 Purpose and Multi-Folder Sync Groups
The **Folders** tab configures and manages your synchronization mesh using the **Folder Groups architecture model**:
- **Multi-Task Independent Sync**: Create multiple independent Sync Groups simultaneously (e.g. Work, Family Photos, Personal Finance).
- **Isolated Pipelines & Consensuses**: Each group maintains its own folders and SQLite consensus store; large syncs in one group never freeze other groups!

### 3.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1: Create & Switch Sync Groups】**:
  1. Click "**+ New Group**" at the top, enter a name and pick an icon, then save.
  2. Click group chips to switch active groups.
  3. Click "**✎ Edit Sync Group**" to rename or delete the group (physical files remain on disk).
- **【Step 2: Click Add Folder...】**: Click "**Add Folder...**" at the bottom to open Windows File Explorer (at least 2 folders required per group).
- **【Step 3: Pick from 5 Storage Locations】**:
  1. **Local PC Folder**: Open File Explorer ➔ click "Documents" or navigate into `C:` drive ➔ select folder.
  2. **OneDrive Cloud Drive**: Open File Explorer ➔ click "OneDrive" in sidebar ➔ select folder.
  3. **Google Drive**: Open File Explorer ➔ click "Google Drive" ➔ "My Drive" ➔ select directory.
  4. **iCloud Drive (Windows)**: Open File Explorer ➔ click "iCloud Drive" in sidebar ➔ select directory.
  5. **External USB Flash / Portable Drive**: Plug in USB drive ➔ open File Explorer ➔ click drive letter (e.g. `D:` or `E:`) ➔ select folder (**ExFAT format strongly recommended**).
- **【Step 4: Relink or Remove】**: If moved, click "**Change Folder...**"; click "**Remove...**" to unbind (unlinking never deletes physical files).

### 3.3 Controls, Locations & Safety Safeguards

| Control / Element | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **+ New Group** | Top Sync Groups bar | Creates a new independent synchronization group | Click and enter name & icon | New group chip appears; automatically switches to empty state. |
| **✎ Edit Sync Group** | Right side of active group info | Renames, updates icon, or deletes group | Click to open edit sheet | Supports rename; deletion unlinks without touching physical files. |
| **Add Folder...** | Bottom of folder list (Blue button) | Adds directory to sync mesh | Click and select in Explorer | Writes unique `.syncnexus-endpoint` UUID marker file. |
| **Change Folder...** | Right side of each endpoint card | Relinks path if drive letter or path changed | Click and select new path | Verifies marker and restores connection automatically. |
| **Remove...** | Right side of each endpoint card | Unbinds folder from sync group | Click and confirm dialog | Unbinds folder from sync, **never deletes physical files**. |
| **Marker Safeguard** | Endpoint card status area | Protects against wrong USB drive insertions | Continuous automatic validation | If wrong drive is inserted, shows "Marker does not match, stopped propagating", isolating automatically! |

---

## Chapter 4: Conflicts

### 4.1 Purpose and Objectives
When concurrent edits occur offline on two devices, SyncNexus enforces a strict **Zero-Overwrite policy**, saving conflicting files as `Filename (conflict ...)`, gathered here for side-by-side comparison and resolution.

### 4.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1: Check Red Conflict Badge】**: When offline concurrent edits happen, a red badge appears on the sidebar "Conflicts" icon. Click to open.
- **【Step 2: Inspect Dual-Column Cards】**: The left card shows "Current Version" and the right card shows "Endpoint Version" (with a green "Newer" badge), detailing sizes, modified dates, and sources.
- **【Step 3: Reveal in File Explorer】**: Click "Reveal in File Explorer" to highlight the file and compare it in your text editor.
- **【Step 4: Choose Resolution Action】**:
  - Click left "**Keep This Version**": Keeps the primary file, pushes it to all endpoints, and archives the conflict copy.
  - Click right "**Use This Version**": Promotes the conflict copy to official primary file, backing up previous primary to Versions.

### 4.3 Controls, Locations & Safety Safeguards

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Keep This Version** | Bottom of left "Current Version" card | Resolves conflict by keeping primary file | Click button | Primary file stays canonical and propagates to other endpoints; conflict copy is safely archived. |
| **Use This Version** | Bottom of right "Endpoint Version" card | Resolves conflict by adopting incoming copy | Click button | Conflict copy becomes canonical file; former primary file is backed up to Versions. |
| **Reveal in File Explorer** | Inside both version cards | Reveals physical file in File Explorer | Click button | Opens File Explorer and highlights file for manual text inspection or diffing. |
| **No Conflicts State** | Empty state when all resolved | Confirms all files are aligned | Read-only | Displays green checkmark "No pending conflicts, all files are identical". |

---

## Chapter 5: Versions

### 5.1 Purpose and Objectives
Whenever a file is overwritten or synced, superseded iterations are archived in `.syncnexus-history`, enabling one-click rollback anytime.

### 5.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1: Set Retention Policy】**: Choose retention duration (7 / 30 / 90 days or Permanent) in the top dropdown; outdated files are pruned automatically in the background.
- **【Step 2: Search Target Revision】**: Type a filename keyword into the search bar at the top right to filter revisions immediately.
- **【Step 3: Click Restore to Recover File】**: Click "**Restore**" on the revision card. The file is instantly recovered to your working directory and syncs across all endpoints within 2 seconds.
- **【Step 4: Storage Maintenance (Optional)】**: Click "Clean Expired Now" to purge outdated backups, or click "Clear All" to wipe archives after confirmation (active files are never affected).

### 5.3 Controls, Locations & Safety Safeguards

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Retention Policy Menu** | Right of "Auto Cleanup" on top card | Configures maximum retention duration | Select: 7 / 30 / 90 days or Permanent | Files older than specified days are automatically pruned in the background. |
| **Clean Expired Now** | Next to retention menu | Manually purges expired revisions immediately | Click button | Immediately frees up disk space and updates top stats. |
| **Clear All** | Next to "Clean Expired Now" | Completely empties history archive | Click and confirm alert | Clears historical archive only; **never affects active files currently in use**. |
| **Search Filter** | Top-right of version list | Filters revisions by filename or endpoint | Type keywords | Instantly filters the list. |
| **Restore** | Right side of each version record | Recovers selected revision back to folder | Click "**Restore**" | Overwrites active file with selected revision and syncs across all endpoints. |

---

## Chapter 6: Verification

### 6.1 Purpose and Objectives
Using the **SHA-256 cryptographic hashing algorithm**, SyncNexus verifies every byte across all endpoints to prevent incomplete transfers and silent disk corruption (bit-rot).

### 6.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1: Start Deep Verification】**: Click the blue "Start Verification Now" button on the center card. The engine calculates SHA-256 hashes across all endpoints in the background.
- **【Step 2: Review Verification Report】**: Updates "Last Deep Verify" timestamp upon completion. Shows green badge "All Normal" when identical, or lists damaged files if corruption is detected.
- **【Step 3: Repair Corrupted Files】**:
  - Click "**Repair from Others**": Downloads a clean bit-accurate copy from a healthy endpoint to replace the damaged file (damaged file is backed up to history first).
  - Click "**Accept Current Content**": If the change was intentional, recalculates baseline hash and clears the alert.

### 6.3 Controls, Locations & Safety Safeguards

| Button / Control | UI Location | Purpose & Objective | How to Operate | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Start Verification Now** | Center card right side (Blue button) | Launches deep SHA-256 hash calculation | Click "**Start Verification Now**" | Background computation; updates timestamp and anomaly list when finished. |
| **Repair from Others** | Appears when corrupted files detected | Downloads correct file from healthy endpoint | Click to repair | Downloads pristine copy from healthy endpoint; superseded corrupt file is preserved in history. |
| **Accept Current Content** | Appears when corrupted files detected | Updates baseline hash if change was intentional | Click to accept | Recalculates baseline hash in consensus store; removes warning badge. |

---

## Chapter 7: Settings

### 7.1 Purpose and Objectives
Personalized sync preferences, exclusion filters, language switching, and launch at startup.

### 7.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1: Choose Conflict Policy】**: Select "Keep both, let me choose (Recommended)" or "Newer wins, old saved to versions".
- **【Step 2: Configure Exclusion Switches】**: Toggle exclusion switches for `node_modules`, `.git`, SQLite lock files (`-wal`, `-shm`). Excluded items are never transferred.
- **【Step 3: Set Language & Startup】**: Select from 6 interface languages; toggle "Launch at Login" to start quietly in the Windows system tray.
- **【Step 4: View Logs & Guide】**: Click "Open Log File" to view sync diagnostics in Notepad; click "Onboarding Guide" to review beginner walkthroughs.

### 7.3 Controls, Locations & Safety Safeguards

| Setting Item | UI Location | Purpose & Objective | Options & Operation | Expected Outcome & Safeguards |
| :--- | :--- | :--- | :--- | :--- |
| **Conflict Policy** | Top card | Sets arbitration behavior upon concurrent edits | Radio choice:<br>1. **Keep both, let me choose** (Default)<br>2. **Newer wins, old saved to versions** | Option 1 saves `.conflict` files; Option 2 automatically picks newest timestamp. |
| **Exclusion Switches** | Second card | Prevents unnecessary or volatile files from syncing | Toggle switches:<br>• `node_modules`<br>• `.git`<br>• Database locks (`-wal`, `-shm`) | When enabled, matching files are left intact and skipped during sync, saving bandwidth. |
| **Interface Language** | Top of third card | Configures display language | Dropdown menu with 6 languages | Switches entire application UI language instantly. |
| **Launch at Startup** | Below language picker | Sets whether SyncNexus starts with Windows | Toggle Switch | Runs in system tray quietly upon login, keeping sync always active. |
| **Open Log File** | Bottom-left button | Views real-time synchronization diagnostics | Click button | Opens live log in Notepad. |
| **Onboarding Guide** | Next to "Open Log File" | Re-opens initial welcome wizard | Click button | Pops up onboarding wizard for reviewing beginner walkthroughs. |

---

## Summary: Everyday Peace of Mind Rules

1. **Work Freely without Manual Clicks**: As long as folders show "Online", saving or renaming files syncs to all endpoints within 2 seconds.
2. **When in Doubt, Run Simulation**: Before bulk reorganizing or deleting files, visit "Diff Preview" and click "Run Trial Simulation".
3. **Never Panic Over Deleted Files**: First check the Windows Recycle Bin; if emptied, open "Versions", search for the file, and click "Restore". Your data is always safe!
