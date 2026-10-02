import Foundation

public enum EndpointKind: String, Sendable { case local, icloud, googleDrive, external }

public struct VolumeDescription: Sendable {
    public var kind: EndpointKind
    public var volumeName: String?
    public var format: String?
    /// Suggested settings for the add-endpoint form.
    public var suggestRemovable: Bool
    public var suggestPortableNames: Bool
}

public struct ValidationIssue: Sendable, Equatable {
    public var isError: Bool
    public var message: String
}

public enum EndpointValidator {
    static func resolved(_ path: String) -> String {
        var p = URL(fileURLWithPath: path).resolvingSymlinksInPath().standardized.path
        while p.count > 1 && p.hasSuffix("/") { p.removeLast() }
        return p
    }

    public static func describe(path: String) -> VolumeDescription {
        let p = resolved(path)
        let url = URL(fileURLWithPath: p)
        let v = try? url.resourceValues(forKeys: [.volumeNameKey, .volumeLocalizedFormatDescriptionKey, .volumeIsInternalKey])
        let format = v?.volumeLocalizedFormatDescription
        let lower = (format ?? "").lowercased()
        let external = p.hasPrefix("/Volumes/") && (v?.volumeIsInternal == false)
        let kind: EndpointKind
        if p.contains("/Library/Mobile Documents/com~apple~CloudDocs") { kind = .icloud }
        else if p.contains("/Library/CloudStorage/GoogleDrive-") { kind = .googleDrive }
        else if external { kind = .external }
        else { kind = .local }
        let windowsFormat = ["fat", "exfat", "ntfs"].contains { lower.contains($0) }
        return VolumeDescription(kind: kind, volumeName: v?.volumeName, format: format,
                                 suggestRemovable: external, suggestPortableNames: external && windowsFormat)
    }

    /// Checks a folder before it becomes (or replaces) an endpoint. Errors block; warnings are shown but allowed.
    public static func validate(path: String, name: String, replacing id: String? = nil,
                                existing: [EndpointConfig], portableNames: Bool = false) -> [ValidationIssue] {
        var out: [ValidationIssue] = []
        func err(_ m: String) { out.append(.init(isError: true, message: m)) }
        func warn(_ m: String) { out.append(.init(isError: false, message: m)) }

        if id == nil {
            let n = name.trimmingCharacters(in: .whitespaces)
            if n.isEmpty { err("請輸入端點名稱") }
            else if existing.contains(where: { $0.id == n }) { err("已有同名端點「\(n)」") }
            else if !PortableName.problems(inComponent: n).isEmpty { err("名稱不可含 / \\ : * ? \" < > | 等字元（會出現在衝突檔名裡）") }
        }

        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue else {
            err("找不到這個資料夾"); return out
        }
        let p = resolved(path)
        let home = resolved(NSHomeDirectory())
        let tooBroad: Set<String> = ["/", "/Users", "/Volumes", "/System", "/Library", "/Applications", home,
                                      home + "/Library", home + "/Library/Mobile Documents", home + "/Library/CloudStorage"]
        if tooBroad.contains(p) { err("範圍太大，請選擇專用的子資料夾（不要選家目錄、系統資料夾或整個磁碟）") }
        if p.hasPrefix("/Volumes/") && p.split(separator: "/").count == 2 { warn("這是整顆磁碟的根目錄，建議改選其中一個專用資料夾") }
        if p.hasSuffix("/com~apple~CloudDocs") || (p.contains("/Library/CloudStorage/GoogleDrive-") && p.split(separator: "/").count <= 6) {
            warn("這是整個雲端根目錄，建議改選其中一個專用子資料夾，避免同步大量檔案")
        }
        if !FileManager.default.isReadableFile(atPath: p) || !FileManager.default.isWritableFile(atPath: p) {
            err("沒有讀寫權限（請確認 App 的檔案存取授權）")
        }

        for other in existing where other.id != id {
            let o = resolved(other.root)
            if p == o { err("與端點「\(other.id)」是同一個資料夾") }
            else if p.hasPrefix(o + "/") { err("位於端點「\(other.id)」的資料夾內部，會造成重複同步") }
            else if o.hasPrefix(p + "/") { err("包含端點「\(other.id)」的資料夾，會造成重複同步") }
        }

        let d = describe(path: p)
        if d.kind == .local && (p.hasPrefix(home + "/Desktop") || p.hasPrefix(home + "/Documents")) {
            warn("若已開啟 iCloud「桌面與文件」同步，這個資料夾也會被 iCloud 自己同步，可能造成雙重同步")
        }
        if d.suggestPortableNames && !portableNames {
            warn("這顆碟是 \(d.format ?? "FAT 系列") 格式，建議開啟「檔名須相容 exFAT / Windows」")
        }
        return out
    }
}
