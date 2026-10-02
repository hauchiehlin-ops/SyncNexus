import Foundation

/// 整合 macOS APFS 零成本本地快照功能（借鏡 Carbon Copy Cloner 與 ChronoSync）
/// 在進行大規模同步、刪除或關鍵變更前，快速產出系統還原點。
public final class APFSSnapshotManager: Sendable {
    public static let shared = APFSSnapshotManager()

    private init() {}

    #if os(macOS)
    public func createLocalSnapshot() -> (success: Bool, message: String) {
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
                return (true, out.isEmpty ? "已成功建立 APFS 本地安全快照" : out)
            } else {
                return (false, "建立快照失敗（可能需要系統管理員權限）：\(out)")
            }
        } catch {
            return (false, "無法啟動快照程序：\(error.localizedDescription)")
        }
    }
    #else
    public func createLocalSnapshot() -> (success: Bool, message: String) {
        return (false, "目前平台不支援 APFS 快照機制")
    }
    #endif
}
