# SyncNexus Privacy Policy — Apple (App Store Review Standards)

**Effective Date**: October 3, 2026  
**Platform**: Apple App Store (macOS / iOS / iPadOS)  
**Developer**: SyncNexus Team  

SyncNexus is committed to the principle that privacy is a fundamental human right. This Privacy Policy strictly adheres to the **Apple App Store Review Guidelines (specifically Guideline 5.1.1 Data Collection and Storage)**, outlining our zero data collection and strictly local-first processing architecture.

---

### 1. Zero Data Collection & Zero Telemetry
* **No Remote Data Transmission**: SyncNexus operates without remote servers. Your file contents, filenames, folder hierarchies, and cryptographic checksums (SHA-256) are **strictly stored on your local devices and your chosen sync folders**.
* **No Third-Party SDKs / No Analytics**: SyncNexus contains no third-party tracking, advertising, analytics, or behavioral telemetry SDKs.
* **No Account Required**: Using SyncNexus requires no account creation, email registration, or personal identity disclosure.

---

### 2. Apple App Sandbox & Entitlements Compliance
SyncNexus runs entirely within the Apple App Sandbox environment and only requests the minimum entitlements required for local file synchronization:
1. **User-Selected Files & Folders (`com.apple.security.files.user-selected.read-write`)**:
   - Access is restricted exclusively to directories explicitly chosen by the user via the native `NSOpenPanel`.
2. **Security-Scoped Bookmarks (`com.apple.security.files.bookmarks.app-scope`)**:
   - Used within the sandbox to persist authorization tokens for user-selected folders across application restarts.
3. **Local Network Communication (`com.apple.security.network.client` / `network.server`)**:
   - Strictly utilized for Apple Bonjour (mDNS multicast) to discover other SyncNexus nodes (Mac, Windows, Android) on the same Wi-Fi network. **No data is ever transmitted to the public Internet**.

---

### 3. Data Integrity & Safeguards
* **Deletion Guard**: Automatically intercepts mass deletion events (>25 files or >25% of tracked items) to prevent accidental loss when removable media is disconnected.
* **Version History**: Automatically preserves replaced or trashed files in an archive directory for instant rollback.

---

### 4. Contact Information
For privacy inquiries or App Store review clarifications:  
Repository: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
