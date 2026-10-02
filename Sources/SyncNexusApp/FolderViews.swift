import AppKit
import SwiftUI
import SyncCore

func pickFolder(message: String) -> String? {
    let p = NSOpenPanel()
    p.canChooseDirectories = true; p.canChooseFiles = false; p.canCreateDirectories = true; p.allowsMultipleSelection = false
    p.message = message; p.prompt = "選擇"
    NSApp.activate(ignoringOtherApps: true)
    return p.runModal() == .OK ? p.url?.path : nil
}

struct AddDraft: Identifiable {
    let id = UUID()
    var path: String
    var name: String
    var removable: Bool
    var portable: Bool
    var archive = false
    var desc: VolumeDescription
}

struct FoldersSection: View {
    @ObservedObject var model: AppModel
    @State private var draft: AddDraft?

    var body: some View {
        sectionHeader("資料夾", "這些資料夾會互相保持一致：任一個有新增、修改、刪除或改名，其他的都會跟著變。刪除的檔案先進垃圾桶。")
        if model.snap.endpoints.isEmpty {
            Card { Text("還沒有加入資料夾。建議依序加入：本機資料夾、iCloud 雲碟裡的資料夾、Google Drive 裡的資料夾、外接磁碟裡的資料夾。")
                .font(.system(size: 14)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true) }
        }
        ForEach(model.snap.endpoints, id: \.id) { ep in FolderRow(model: model, ep: ep) }
        HStack {
            Button("加入資料夾…") { startAdd() }.buttonStyle(QuietButton(kind: .primary))
            if model.snap.endpoints.count < 2 { Text("至少需要兩個資料夾才會開始同步。").font(.system(size: 13)).foregroundStyle(Theme.warn) }
        }
        .sheet(item: $draft) { d in AddSheet(model: model, draft: d) { draft = nil } }
    }

    private func startAdd() {
        guard let path = pickFolder(message: "選擇要加入同步的資料夾") else { return }
        let d = EndpointValidator.describe(path: path)
        let base: String
        switch d.kind {
        case .local: base = "本機"
        case .icloud: base = "iCloud"
        case .googleDrive: base = "GoogleDrive"
        case .external: base = d.volumeName ?? "外接碟"
        }
        let taken = Set(model.snap.endpoints.map(\.id))
        let name = taken.contains(base) ? ((2...9).map { "\(base)\($0)" }.first { !taken.contains($0) } ?? base) : base
        draft = AddDraft(path: path, name: name, removable: d.suggestRemovable, portable: d.suggestPortableNames, desc: d)
    }
}

struct FolderRow: View {
    @ObservedObject var model: AppModel
    let ep: SyncService.EndpointStatus

    var body: some View {
        let kind = EndpointValidator.describe(path: ep.root).kind
        Card {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: kind.symbol).font(.system(size: 18)).frame(width: 36, height: 36).background(Theme.tile, in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(ep.id).font(.system(size: 15, weight: .bold))
                        Chip(text: ep.online ? "在線" : "離線", kind: ep.online ? .ok : .warn)
                        if ep.role == .archive { Chip(text: "備份：只接收", kind: .neutral) }
                        if ep.removable { Chip(text: "可移除", kind: .neutral) }
                        if ep.portableNames { Chip(text: "檔名相容 exFAT／Windows", kind: .neutral) }
                    }
                    Text(shortPath(ep.root)).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                    if !ep.online { Text(ep.detail).font(.system(size: 12)).foregroundStyle(Theme.warn).fixedSize(horizontal: false, vertical: true) }
                }
                Spacer()
                if ep.role == .archive { Button("顯示歷史") { model.reveal(ep.root + "/.syncnexus-history") }.buttonStyle(QuietButton(kind: .plain)) }
                Button("更換資料夾…") { change() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                Button("移除…") { remove() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
            }
        }
    }

    private func change() {
        guard let path = pickFolder(message: "選擇「\(ep.id)」要改指向的新資料夾") else { return }
        let issues = model.validate(path: path, name: ep.id, replacing: ep.id, portable: ep.portableNames)
        if let e = issues.first(where: \.isError) { let a = NSAlert(); a.messageText = "無法使用這個資料夾"; a.informativeText = e.message; a.runModal(); return }
        let a = NSAlert()
        a.messageText = "把「\(ep.id)」改指向新資料夾？"
        a.informativeText = "新資料夾會被當成新加入的資料夾：它會先收到其他端點的檔案，原有的檔案也會被合併進來；不會因為它是空的就刪除其他端點的檔案。同步前會先給你看預覽。\n\n" + issues.map(\.message).joined(separator: "\n")
        a.addButton(withTitle: "更換"); a.addButton(withTitle: "取消")
        if a.runModal() == .alertFirstButtonReturn { model.relink(id: ep.id, to: path) }
    }

    private func remove() {
        let a = NSAlert()
        a.messageText = "不再同步「\(ep.id)」？"
        a.informativeText = "資料夾裡的檔案完全不會被刪除或改動，只是之後它的變更不會再和其他資料夾同步。"
        a.addButton(withTitle: "移除"); a.addButton(withTitle: "取消")
        if a.runModal() == .alertFirstButtonReturn { model.remove(id: ep.id) }
    }
}

struct AddSheet: View {
    @ObservedObject var model: AppModel
    @State var draft: AddDraft
    let close: () -> Void

    init(model: AppModel, draft: AddDraft, close: @escaping () -> Void) {
        self.model = model; self._draft = State(initialValue: draft); self.close = close
    }

    private var issues: [ValidationIssue] { model.validate(path: draft.path, name: draft.name, portable: draft.portable) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("加入資料夾").font(.system(size: 20, weight: .bold))
            Text(shortPath(draft.path)).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(2).truncationMode(.middle)
            HStack(spacing: 8) {
                Image(systemName: draft.desc.kind.symbol)
                Text("偵測到：\(draft.desc.kind.label)\(draft.desc.format.map { "（\($0)）" } ?? "")").font(.system(size: 13))
            }
            TextField("名稱", text: $draft.name).textFieldStyle(.roundedBorder)
            Toggle("可能被拔除（外接磁碟）", isOn: $draft.removable)
            Toggle("檔名須相容 exFAT／Windows", isOn: $draft.portable)
            Toggle("當作備份（只接收）", isOn: $draft.archive)
            if draft.archive {
                Text("備份資料夾只會接收其他資料夾的內容：在這裡做的修改不會傳出去（會被還原）、其他資料夾刪除的檔案會保留，被取代的舊內容存在資料夾內的 .syncnexus-history。")
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Text("磁碟被拔除時，這個資料夾會暫時停止同步，不會被當成「檔案全被刪除」；接回後會自動對帳。")
                .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            ForEach(issues, id: \.message) { i in
                Label(i.message, systemImage: i.isError ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 13)).foregroundStyle(i.isError ? Theme.bad : Theme.warn).fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Spacer()
                Button("取消") { close() }.buttonStyle(QuietButton(kind: .secondary)).keyboardShortcut(.cancelAction)
                Button("加入") { model.addEndpoint(name: draft.name, path: draft.path, removable: draft.removable, portable: draft.portable, archive: draft.archive); close() }
                    .buttonStyle(QuietButton(kind: .primary)).keyboardShortcut(.defaultAction).disabled(issues.contains(where: \.isError))
            }
        }
        .padding(22).frame(width: 480)
    }
}
