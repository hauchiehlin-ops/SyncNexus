# SyncNexus User Manual — Android

## 1. Introduction and Architecture
**SyncNexus for Android** is a local-first, two-way file synchronization tool crafted specifically for Android phones and tablets. It provides serverless operation, zero cloud lock-in, battery-aware execution, and USB storage support.

* **Storage Access Framework (SAF)**: Strictly complies with Google Play Scoped Storage guidelines; permissions are explicitly granted by users and securely persisted.
* **Smart Battery Throttling**: Automatically defers resource-intensive synchronization when battery level falls below 20% and the device is not charging.
* **USB OTG Hot-Plug Detection**: Instantly detects external USB flash drives connected via Type-C and integrates them as removable endpoints.
* **Cross-Platform LAN Discovery**: Employs Android Network Service Discovery (NSD) over mDNS to detect nearby Mac and Windows devices on the same Wi-Fi.

---

## 2. Quick Setup Guide
1. **Adding Folders**:
   - Tap **"+ Add Folder"**.
   - Select your target folder using Android's system file picker (SAF) and confirm permission via "Use this folder".
2. **Endpoint Diversity**:
   - **Internal Storage**: e.g., `Documents/SyncFolder`.
   - **Removable Media**: External SD card or USB OTG drive.
3. **Execution & Background Operation**:
   - Tap "Sync Now" for immediate reconciliation.
   - SyncNexus utilizes Android Foreground Services and WorkManager to maintain synchronization smoothly in the background while plugged into power.

---

## 3. Conflict Safety & Privacy
* **Conflict Preservation**: Concurrent edits are saved alongside the original file without silent overwrites.
* **Zero Cloud Telemetry**: File contents are processed strictly on device and never transferred to external servers.
