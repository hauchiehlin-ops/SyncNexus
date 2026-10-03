# SyncNexus User Operation Manual — Android Complete Guide

> **Applicable Platform**: Android 10 and later (API 29+)  
> **Current Version**: 1.2.0 (build 22)  
> **Core Design Principles**: Local-First, Pure LAN Direct Connection, SAF Privacy Sandbox

---

## Top Navigation Header

On the Android top app bar:
- **Language Menu**: Instant switching across 6 languages.
- **User Operation Manual (📖)**: Opens this native in-app manual without launching external browsers.
- **Privacy Policy (🛡️)**: Outlines Android SAF storage sandbox access and zero-cloud commitments.

---

## Chapter 1: Overview

### 1.1 Purpose and Objectives
Overview gives you a fast snapshot of synchronization health between your mobile device and other endpoints.
- **Sync Status**: Green (Normal Sync) and Yellow (Offline / Pending).
- **Tracked Files**: Live count of files monitored on mobile storage.
- **LAN P2P Direct Connect**: Utilizes Android Network Service Discovery (NSD) to find Macs and Windows PCs on the same Wi-Fi, establishing high-speed point-to-point channels.

### 1.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1】**: Check top status badge; green indicates all endpoints are synced and ready.
- **【Step 2】**: Connect to the same Wi-Fi network; your computer appears in the P2P device list automatically.
- **【Step 3】**: If mass deletions occur, an alert dialog pauses sync until you explicitly authorize or reject it.

---

## Chapter 2: Diff Preview

### 2.1 Purpose and Objectives
Before writing files to mobile flash storage, simulate and preview pending incoming changes from your computer.

### 2.2 【Zero-Foundation Beginner Tutorial: Step-by-Step Instructions】
- **【Step 1】**: Tap "Run Trial Simulation"; the app computes differences in memory without altering storage.
- **【Step 2】**: Review change indicators: Green `+` (additions), Blue `➔` (renames), Red `−` (deletions, moved to Trash).
- **【Step 3】**: Once verified, tap "Confirm Sync" to write changes.

---

## Chapter 3: Folders

### 3.1 Sync Groups & Adding Storage Endpoints
SyncNexus supports independent multi-folder Sync Groups:
- **Sync Groups Management**: Tap "+ New Group" to create isolated sync tasks (e.g. Photo Backup, Documents), and tap chips to switch.
- **Adding Storage Endpoints**:
  1. **Internal Storage**: Tap "Add Folder...", select target folder in Android SAF picker ➔ tap "Use this folder" and grant access.
  2. **External SD Card / Type-C USB**: Plug in SD card or Type-C drive, select it from the sidebar picker, and authorize (**ExFAT format is strongly recommended** for easy cross-platform use on Mac and Windows).
  3. **Change or Remove**: Tap "Change Folder" or "Remove" on endpoint cards; removing never deletes physical files.

---

## Chapter 4: Conflicts

### 4.1 Dual-Version Arbitration & Zero-Overwrite Guarantee
When files are edited offline on both phone and computer:
- **【Step 1】**: A red indicator badge appears on the "Conflicts" tab. Tap to open.
- **【Step 2】**: Compare modified timestamps and sizes of both versions side-by-side.
- **【Step 3】**: Tap "Keep Primary Version" or "Use Conflict Version" to resolve and sync.

---

## Chapter 5: Versions

### 5.1 Historical Time Machine
- **【Step 1】**: Set retention duration (7 / 30 / 90 days or Permanent).
- **【Step 2】**: Search by filename to find previous revisions.
- **【Step 3】**: Tap "Restore" to recover any superseded file with one tap.

---

## Chapter 6: Verification

### 6.1 SHA-256 Deep Integrity
- **【Step 1】**: Tap "Start Verification Now"; computes SHA-256 hashes in background.
- **【Step 2】**: If corrupted files are flagged, tap "Repair from Others" to fetch a fresh bit-accurate copy from your computer.

---

## Chapter 7: Settings

### 7.1 Preferences & Permissions
- **Conflict Policy**: Choose "Keep both, let me choose" or "Newer wins".
- **Exclusion Filters**: Automatically excludes thumbnails and system cache directories.
- **Languages**: Instant switching between 6 languages.
- **Battery Awareness**: Pauses heavy sync tasks when battery is below 15% and unplugged.
