import Foundation

/// 整合 macOS APFS 零成本本地快照功能（借鏡 Carbon Copy Cloner 與 ChronoSync）
/// 在進行大規模同步、刪除或關鍵變更前，快速產出系統還原點。
public final class APFSSnapshotManager: Sendable {
    public static let shared = APFSSnapshotManager()

    private init() {}

    #if os(macOS)
    public func createLocalSnapshot() -> (success: Bool, message: String, isSandbox: Bool) {
        // 檢查是否處於 macOS 沙盒環境
        let isSandboxed = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
        if isSandboxed {
            return (false, "macOS App Sandbox restricted", true)
        }

        let task = Process()
        task.launchPath = "/usr/bin/tmutil"
        task.arguments = ["localsnapshot"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let out = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if task.terminationStatus == 0 {
                return (true, out.isEmpty ? "APFS snapshot created" : out, false)
            } else {
                return (false, out, false)
            }
        } catch {
            return (false, error.localizedDescription, false)
        }
    }
    #else
    public func createLocalSnapshot() -> (success: Bool, message: String, isSandbox: Bool) {
        return (false, "Unsupported platform", false)
    }
    #endif
}
