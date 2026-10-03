# SyncNexus User Operation Manual — Android Complete Guide

> **Applicable Platform**: Android 10 and later (API 29+)  
> **Core Architecture**: Local-First, Direct LAN P2P Sync, SAF Privacy Sandbox

---

## Top Navigation Header

At the top of the Android screen:
- **Language Picker**: Select between 6 supported interface languages.
- **User Manual (📖)**: Opens this manual directly inside an in-app bottom sheet.
- **Privacy Policy (🛡️)**: Reviews Android SAF storage scopes and zero-cloud principles.

---

## Chapter 1: Overview
- **Health Badge**: Green (Syncing normally) and yellow (Offline/Action required).
- **Tracked Files Stat**: Live count of files monitored on the device.
- **LAN P2P Direct**: Discovers nearby Macs and Windows PCs via Android Network Service Discovery (NSD) for high-speed local transfers.

---

## Chapter 2: Diff Preview
- **Trial Simulation**: Simulates file transfers before writing to device storage.
- **Confirm Sync**: Applies verified changes with a single tap.

---

## Chapter 3: Folders

### 3.1 Grounded Guide to Adding Folders
Tap "**Add Folder...**" and grant access via the Android Storage Access Framework (SAF):
1. **Internal Storage**: Tap the hamburger menu in the file picker, select "Internal Storage", choose your folder, and tap "Use this folder".
2. **SD Card / Type-C USB Drive**: Plug in your SD card or USB-C drive, select it from the sidebar, choose your directory, and authorize access. **Format as ExFAT** for multi-platform interchange with Mac and Windows!
3. **Change & Remove**: Re-link paths or detach folders safely without deleting physical files.

---

## Chapter 4: Conflicts
- **Zero-Overwrite**: Files edited on both sides generate `(conflict ...)` copies.
- **Side-by-Side Resolution**: Compare file size and timestamps to "Keep Primary" or "Use Conflict Copy".

---

## Chapter 5: Versions (History)
- **Archive Storage**: Superseded files are preserved in `.syncnexus-history`.
- **Retention & Restore**: Set retention duration or tap "Restore" anytime to recover earlier revisions.

---

## Chapter 6: Verification
- **SHA-256 Verification**: Verifies transmission integrity byte by byte.
- **Automatic Repair**: Recovers corrupted files from computer endpoints.

---

## Chapter 7: Settings
- **Conflict Policy**: Manual arbitration vs newer wins.
- **Exclude Rules**: Ignores system caches and thumbnails.
- **Battery Optimization**: Set to "Unrestricted" to allow background foreground synchronization when screen is off.
