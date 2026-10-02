# Sync-Nexus User Manual (English)

## 1. Introduction
**Sync-Nexus** is a local-first, peer-to-peer file synchronization system designed for macOS and Android. It ensures two-way directory synchronization with strict data integrity guarantees, zero cloud lock-in, and zero external tracking.

---

## 2. Key Features
* **Zero-Cloud Architecture**: All file reconciliation and synchronization operate entirely locally on your devices or directly between devices over local Wi-Fi (mDNS / P2P).
* **Local Peer Discovery (P2P)**: Automatically detects nearby Macs and Android devices on the same Wi-Fi network without requiring server registration.
* **Smart Reconciliation & Visual Diff Trial Run**: Preview exactly what will change (new, modified, deleted files) before applying modifications.
* **APFS Snapshot Protection (macOS)**: Takes local APFS safety snapshots before destructive operations on supported filesystems.
* **Battery & Power Awareness (Android)**: Intelligently postpones heavy background transfers when the device is on low battery (<15%) and not connected to a charger.
* **OTG USB Drive Auto-Detection (Android)**: Instantly detects when USB external drives are connected.
* **Conflict Isolation & Safety**: Conflicting edits are preserved side-by-side without data loss.

---

## 3. Getting Started

### macOS
1. Launch **Sync-Nexus.app**.
2. Click **Add Folder** to select two or more directories (Local folder, iCloud Drive, external USB, etc.).
3. When prompted, grant folder permissions via macOS standard open dialogs (Security-Scoped Bookmarks).
4. View real-time synchronization status in the menu bar popover or the main window.
5. Use **Diff Preview** to perform a trial run before synchronizing large batches of changes.

### Android
1. Open **Sync-Nexus** on your Android smartphone or tablet.
2. Grant Storage Access Framework (SAF) folder permissions by tapping **Add Folder**.
3. Select at least two folders (e.g. internal storage documents and an SD card / OTG drive).
4. Tap **Reconcile & Sync Now** or allow background sync to run automatically.
5. In the **Local Nearby Devices** card, verify peer connectivity with your Mac on the same Wi-Fi.

---

## 4. Conflict Handling
When a file is modified simultaneously across different endpoints:
* Sync-Nexus never silently overwrites your data.
* A conflict file is created (e.g. `document.conflict-copy.txt`) alongside the original.
* You can resolve conflicts directly inside the **Conflicts** tab by selecting which version to keep.

---

## 5. Security & Privacy
* No telemetry, no ads, no trackers.
* Network communications are restricted to local peer discovery via mDNS.
