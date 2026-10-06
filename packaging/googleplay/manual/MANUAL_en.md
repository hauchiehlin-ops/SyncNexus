# SyncNexus User Manual — Android Complete Guide

> **Applicable platform**: Android 8.0 and later (API 26+)  
> **Core design principles**: Local-first, LAN-only direct connection, SAF privacy sandbox

---

## Getting around

Tap **☰** (top left) to open the sidebar. It has 8 sections: **Overview, Diff preview, Folders, Sync activity, Conflicts, Old versions, Verification, Settings**, plus the user manual and the privacy policy. The number next to "Conflicts" is how many are waiting for you.

The **🌐** button in the top bar switches the interface language at any time (繁體中文, 简体中文, English, 日本語, 한국어, ภาษาไทย, or follow the system).

> Syncing only **adds or updates** files. It **never deletes** anything: a file deleted on one side comes back from the others on the next sync. Every file that gets replaced is archived under "Old versions" first.

---

## Chapter 1: Overview

### 1.1 What it shows
The state of the current sync group at a glance: number of folders, tracked files, recent transfers, last sync time, and other devices found on the same Wi-Fi (Macs / Windows PCs, found with Android NSD; **nothing goes to the Internet**). You can also switch, create, edit, and delete sync groups and manage backups here.

### 1.2 Steps
- **【Step 1】**: Tap "Add Folder…" and add at least two folders. Syncing needs two or more.
- **【Step 2】**: Tap "Reconcile & Sync Now" to sync immediately. The app also reconciles periodically in the background.
- **【Step 3】**: On the same Wi-Fi, nearby computers appear under "Local Wi-Fi Devices".

---

## Chapter 2: Diff preview

### 2.1 What it does
Shows what the next sync **would do**, before any file is touched. Looking changes nothing.

### 2.2 Steps
- **【Step 1】**: Open "Diff preview" and tap "Check now".
- **【Step 2】**: Each row shows the file path and the action:
  - Green: new on a folder, or an update of an older file there (the old version is archived).
  - Red: a conflict; that folder's own edit is kept as a conflict copy.
- **【Step 3】**: If it looks right, go back to "Overview" and tap "Reconcile & Sync Now".

---

## Chapter 3: Folders

### 3.1 Adding and removing folders
- **Add**: tap "Add Folder…", pick a folder in the Android picker, tap "Use this folder", and allow access.
  1. **Internal storage**: choose the target folder.
  2. **SD card / USB-C drive**: plug it in and select it in the picker's side menu (**ExFAT is recommended** so it works on Mac and Windows too).
- **A folder can only belong to one group**, and a group cannot contain folders that sit inside each other, so nothing is synced twice.
- **Remove**: tap "Remove" next to a folder. This **never deletes** the files.

---

## Chapter 4: Sync activity

Lists what the last sync did (copies, conflicts, failures and why), so you can check that every step succeeded.

---

## Chapter 5: Conflicts

### 5.1 When does a conflict happen?
The same file was changed in two places (for example on the phone and on the computer while apart) and the contents differ. SyncNexus **never overwrites silently**: the newer version becomes the main one, and the other folder's own edit is saved as "name (conflict endpoint date time).ext", **kept only in that folder** and never synced.

### 5.2 Steps
- **【Step 1】**: When a number appears next to "Conflicts" in the sidebar, open it.
- **【Step 2】**: Each entry shows the file, which folder it happened in, the time, and the conflict copy's name.
- **【Step 3】**: Choose one:
  - **Keep the synced version**: discards the conflict copy (it is archived under "Old versions" first).
  - **Use this copy instead**: the copy replaces the main file (the old main file is archived first) and spreads to the other folders right away.

---

## Chapter 6: Old versions

### 6.1 What it keeps
Files that get replaced (by a sync update, a conflict decision, a repair…) are first archived in the app's private storage and **kept for 30 days** (1 GB in total; beyond that the oldest go first).

### 6.2 Steps
- **【Step 1】**: Open "Old versions". Each entry shows the file, source folder, time, size, and why it was replaced.
- **【Step 2】**: Tap "Restore" to put the file back (the current file is archived first). The next sync spreads it to the other folders.
- **【Step 3】**: Tap "Delete" for versions you do not need.

---

## Chapter 7: Verification

### 7.1 What it does
Re-reads every file, computes SHA-256, and checks it still matches the record. This finds **silent corruption**: content that changed while size and modification time did not. A normal edit (which changes the modification time) is not treated as a problem.

### 7.2 Steps
- **【Step 1】**: Tap "Verify now". When it finishes, a new line appears under "History" (time, files, result).
- **【Step 2】**: For anything under "Needs a decision", choose:
  - **Restore the good copy**: fetches the correct content from another folder; the damaged file is archived under "Old versions".
  - **Accept this version**: treats it as a normal edit that spreads to the other folders.

---

## Chapter 8: Settings

- **Language**: switch between 6 languages or "Follow system"; applied immediately.
- **User manual / Privacy policy**: opens this guide and the privacy policy.
- **Background sync**: the app keeps a foreground service running, and Android schedules a reconcile every hour; the system defers it by itself when the battery is low.
