# SyncNexus Privacy Policy — Windows (Microsoft Store Review Standards)

**Effective Date**: October 3, 2026  
**Platform**: Microsoft Store / Windows Desktop Distribution  
**Developer**: SyncNexus Team  

SyncNexus operates with complete dedication to user privacy and transparency. This Privacy Policy strictly complies with **Microsoft Store App Certification Policies (specifically Section 10.5 Personal Information)**, describing our strictly local data processing and zero-telemetry architecture.

---

### 1. Personal Information Declaration
* **Zero Data Collection**: SyncNexus **does not collect, transmit, store, or share** any personal information, device identifiers, or usage telemetry.
* **No Remote Servers**: Synchronization operations occur exclusively between your local file system, locally mounted cloud filesystems (Google Drive / OneDrive), and external removable storage. File contents never leave your device environment.
* **No Third-Party Analytics**: Contains no third-party tracking, advertising, analytics, or behavioral monitoring SDKs.

---

### 2. Windows Capabilities & Transparency
1. **File System Access**:
   - Strictly utilized to read, compare, and synchronize folders explicitly selected by the user.
2. **Windows Cloud Files API Integration**:
   - Used solely to evaluate `FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS` placeholder attributes on Google Drive and OneDrive folders, safeguarding uncached files against unintended hydration.
3. **Local Peer Discovery (mDNS Multicast)**:
   - Broadcasts and listens on multicast IP `224.0.0.251:5353` for `_syncnexus._tcp.local` within your local Wi-Fi. **No connections are established to external Internet servers**.
4. **Startup Configuration (Windows Startup Registry)**:
   - When enabled by the user, registers an entry in `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` to launch the background sync guardian silently. This can be deactivated at any time via settings or Windows Task Manager.

---

### 3. Recycle Bin & Data Safety
* Deleted files are safely placed into the **genuine Windows Recycle Bin** using Win32 `SHFileOperationW`.
* Pre-deletion archiving in `.syncnexus-history` provides multi-tier data protection.

---

### 4. Contact Information
For privacy questions or Microsoft Store certification reviews:  
Repository: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
