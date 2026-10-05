# SyncNexus Privacy Policy — Android (Google Play Review Standards)

**Effective Date**: October 5, 2026  
**Platform**: Google Play Store (Android)  
**Developer**: SyncNexus Team  

SyncNexus adheres to the highest standards of data privacy and transparency. This policy complies strictly with **Google Play Developer Policies, User Data Policies, and Prominent Disclosure mandates**, detailing how file access and system permissions are handled.

---

### 1. Core Commitment: Zero Server & Zero Telemetry
* **No Remote Servers**: SyncNexus operates without back-end servers. All file contents, path information, and SHA-256 hashes are processed strictly on your local device and user-selected storage directories.
* **No Third-Party SDKs & No Ads**: SyncNexus includes no third-party tracking, analytics, advertising, or crash telemetry libraries.
* **No Personally Identifiable Information (PII)**: No login, no accounts, and no hardware identifiers (e.g., IMEI, Android ID) are collected or transmitted.

---

### 2. What the App Stores on Your Device
To provide Diff preview, Conflicts, Old versions, and Verification, SyncNexus keeps the following in the **app's private storage**:
* For each sync group, the hash and modification time of each file as of the last time all folders agreed (used to tell which side changed).
* The list of unresolved conflicts.
* **A version archive**: copies of files replaced by a sync update, a conflict decision, or a restore, kept for 30 days (1 GB in total; the oldest are removed first beyond that).
* A verification history (time, number of files, result).

This data **stays on your device and is never uploaded**. Removing a group removes its records; uninstalling the app or clearing its data in Android settings deletes everything. Conflict copies are stored inside the synced folder where the conflict happened, and you decide whether to keep or discard them.

---

### 3. Android Permissions & Prominent Disclosure
To deliver reliable local file synchronization, SyncNexus utilizes the following scoped permissions:
1. **Storage Access Framework (SAF)**:
   - SyncNexus does not request broad `MANAGE_EXTERNAL_STORAGE` access. Instead, users explicitly grant access to specific folders via the system document tree picker (`takePersistableUriPermission`).
2. **Foreground Service (`FOREGROUND_SERVICE_DATA_SYNC`) and Notifications (`POST_NOTIFICATIONS`)**:
   - Required by Android to run background synchronization reliably. A persistent notification shows the state of each sync group so the activity stays visible.
3. **Network permissions (`INTERNET`, `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`) and Local Network Service Discovery (NSD / mDNS)**:
   - Android requires these permissions to use NSD. They are used **solely within your local Wi-Fi network to detect nearby SyncNexus devices (Mac / Windows)**. The app connects to no external servers and uploads or downloads no data.
4. **USB Device Attachment Listener**:
   - Used exclusively to detect connection or disconnection of external USB OTG drives for immediate sync endpoint awareness.

---

### 4. User Control
Users can remove authorized folders and delete archived versions within the application, or revoke permissions and clear local data via Android system settings, at any time.

---

### 5. Contact
For privacy inquiries or review clarifications:  
Repository: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
