# Privacy Policy for Android (Sync-Nexus)

**Effective Date**: October 2, 2026  
**Application**: Sync-Nexus for Android (Google Play Store Edition)

Sync-Nexus is a local-first peer-to-peer file synchronization utility. We operate under a strict zero-server, zero-telemetry privacy model.

---

### 1. Data Collection & Privacy Principles
* **Zero Backend Servers & No Accounts**: Sync-Nexus does not run or connect to any cloud servers. No account creation or personal identity information is required.
* **No Analytics or Tracking**: We do not integrate any third-party telemetry, crash-reporting SDKs, advertising IDs (AAID), or usage metrics.
* **Local Data Quarantine**: Files and folder contents are never uploaded to the internet. Synchronization operates entirely on your Android device, connected storage, or directly between your devices over local Wi-Fi.

---

### 2. Google Play Storage & System Permissions
* **Storage Access Framework (SAF)**: Adheres strictly to Google Play Scoped Storage policies. We request access only to directories you specifically pick in the Android SAF document picker. We **do not** require or use the dangerous `MANAGE_EXTERNAL_STORAGE` permission.
* **Foreground Service (`FOREGROUND_SERVICE_DATA_SYNC`)**: Keeps data replication active during background operations without interruption, showing an ongoing persistent status notification.
* **Local Network Discovery (NSD / mDNS)**: Uses Android Network Service Discovery to find nearby Mac devices on the same Wi-Fi subnet.

---

### 3. Contact Us
For privacy questions, please open an issue on our GitHub repository:  
Repository: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
