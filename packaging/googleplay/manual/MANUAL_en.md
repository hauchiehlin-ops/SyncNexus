# Sync-Nexus User Manual for Android

## 1. Introduction & Overview
**Sync-Nexus for Android** is an offline, peer-to-peer file synchronization tool tailored for Android smartphones and tablets (Android 14 & 15). It supports two-way background folder synchronization, SD cards, USB On-The-Go (OTG) flash drives, and direct local Wi-Fi peer synchronization with your Mac.

![Sync-Nexus Android Mobile UI](/Users/barretlin/.gemini/antigravity/brain/a78dbd7e-b8d4-4059-8ea4-510ecb66c712/android_screen_ui_1790946598473.jpg)

---

## 2. Android Core Capabilities
* **Storage Access Framework (SAF)**: 100% compliant with Google Play Scoped Storage policies. No intrusive `MANAGE_EXTERNAL_STORAGE` permission required.
* **Battery & Power Awareness**: Automatically pauses high-bandwidth replication when battery level drops below 15% and device is not charging.
* **USB OTG Instant Detection**: Plug in any USB flash drive or card reader and immediately add it as a synchronization endpoint.
* **Foreground Service with Doze Protection**: Keeps active sync operations alive during long background transfers without being killed by the Android system.
* **Local Peer Discovery (P2P)**: Discovers Macs on the same Wi-Fi using Android Network Service Discovery (NSD) with zero cloud accounts.

---

## 3. Step-by-Step Instructions

### Step 1: Add Folders via SAF
1. Open **Sync-Nexus** on your Android device.
2. Tap **Add Folder…** on the main screen.
3. Use the system document tree picker to choose a directory (e.g. `Documents` or a folder on your USB OTG drive).
4. Tap **Use this folder** and **Allow** when prompted. Repeat to add at least two folders.

### Step 2: Instant Reconciliation & Synchronization
1. Tap **Reconcile & Sync Now** to trigger an immediate two-way synchronization.
2. Monitor real-time status, tracked files count, and activity logs.

### Step 3: Peer Connectivity
* Check the **Local Wi-Fi Devices (P2P Direct)** card to verify connectivity with your Mac on the same network.
