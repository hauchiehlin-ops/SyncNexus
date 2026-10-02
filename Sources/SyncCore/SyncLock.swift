import Foundation

public struct SyncBusy: Error, CustomStringConvertible {
    public var description: String { "另一個同步正在進行中（App 或指令列），請稍後再試" }
}

/// One mutating sync at a time per database, across processes (the menu bar app and the command line tool).
/// Two engines acting on the same folders at once could both apply the same decision twice.
final class SyncLock {
    private let fd: Int32

    static func acquire(path: String) throws -> SyncLock {
        let fd = open(path, O_CREAT | O_RDWR, 0o600)
        guard fd >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        guard flock(fd, LOCK_EX | LOCK_NB) == 0 else { close(fd); throw SyncBusy() }
        return SyncLock(fd: fd)
    }

    private init(fd: Int32) { self.fd = fd }
    deinit { flock(fd, LOCK_UN); close(fd) }
}
