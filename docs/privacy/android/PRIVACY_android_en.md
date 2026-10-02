# SyncNexus Privacy Policy — Android (Google Play Review Standards)

**Effective Date**: October 3, 2026  
**Platform**: Google Play Store (Android)  
**Developer**: SyncNexus Team  

SyncNexus adheres to the highest standards of data privacy and transparency. This policy complies strictly with **Google Play Developer Policies, User Data Policies, and Prominent Disclosure mandates**, detailing how file access and system permissions are handled.

---

### 1. Core Commitment: Zero Server & Zero Telemetry
* **No Remote Servers**: SyncNexus operates without back-end servers. All file contents, path information, and SHA-256 hashes are processed strictly on your local device and user-selected storage directories.
* **No Third-Party SDKs & No Ads**: SyncNexus includes no third-party tracking, analytics, advertising, or crash telemetry libraries.
* **No Personally Identifiable Information (PII)**: No login, no accounts, and no hardware identifiers (e.g., IMEI, Android ID) are collected or transmitted.

---

### 2. Android Permissions & Prominent Disclosure
To deliver reliable local file synchronization, SyncNexus utilizes the following scoped permissions:
1. **Storage Access Framework (SAF)**:
   - SyncNexus does not request broad `MANAGE_EXTERNAL_STORAGE` access. Instead, users explicitly grant access to specific folders via the system document tree picker (`takePersistableUriPermission`).
2. **Foreground Service (`FOREGROUND_SERVICE_DATA_SYNC`)**:
   - Required by Android to execute background synchronization reliably. A persistent notification is displayed exclusively while syncing is active to ensure user visibility.
3. **Local Network Service Discovery (NSD / mDNS)**:
   - Utilized solely within your local Wi-Fi network to detect nearby SyncNexus nodes (Mac / Windows). No packets are routed to the public Internet.
4. **USB Device Attachment Listener**:
   - Used exclusively to detect connection or disconnection of external USB OTG drives for immediate sync endpoint awareness.

---

### 3. User Control
Users can revoke folder permissions at any time within the application or via Android system settings.

---

### 4. Contact
For privacy inquiries or review clarifications:  
Repository: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
