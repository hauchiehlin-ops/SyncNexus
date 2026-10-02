# Privacy Policy for macOS (Sync-Nexus)

**Effective Date**: October 2, 2026  
**Application**: Sync-Nexus for Mac (Apple App Store Edition)

Sync-Nexus is a local-first peer-to-peer file synchronization utility. We operate under a strict zero-server, zero-telemetry privacy model.

---

### 1. Data Collection & Privacy Principles
* **Zero Backend Servers & No Accounts**: Sync-Nexus does not run or connect to any cloud servers. No account creation or personal identity information is required.
* **No Analytics or Tracking**: We do not integrate any third-party telemetry, crash-reporting SDKs, advertising IDs, or usage metrics.
* **Local Data Quarantine**: Files and folder contents are never exfiltrated. Synchronization operates entirely on your Mac, connected drives, or directly between your devices over local Wi-Fi.

---

### 2. Apple App Store Entitlements & Permissions
* **User-Selected Files (`com.apple.security.files.user-selected.read-write`)**: Allows Sync-Nexus to access only directories explicitly selected by you through standard macOS file pickers.
* **Security-Scoped Bookmarks (`com.apple.security.files.bookmarks.app-scope`)**: Retains permission to access your chosen folders across app launches without re-prompting.
* **Removable Storage Volumes (`com.apple.security.files.volumes.read-write`)**: Enables synchronization with external USB-C, flash drives, and memory cards.
* **Local Network Discovery (Bonjour `_syncnexus._tcp`)**: Detects nearby peer devices within your local Wi-Fi subnet. No internet access is required or initiated.

---

### 3. Contact Us
For privacy questions, please open an issue on our GitHub repository:  
Repository: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
