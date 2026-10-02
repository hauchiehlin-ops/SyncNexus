import AppKit
import SwiftUI
import SyncCore

private func pickFolder(message: String) -> String? {
    let p = NSOpenPanel()
    p.canChooseDirectories = true
    p.canChooseFiles = false
    p.canCreateDirectories = true
    p.allowsMultipleSelection = false
    p.message = message
    p.prompt = "選擇"
    NSApp.activate(ignoringOtherApps: true)
    return p.runModal() == .OK ? p.url?.path : nil
}

private func label(_ k: EndpointKind) -> String {
    switch k { case .local: "本機"; case .icloud: "iCloud 雲碟"; case .googleDrive: "Google Drive"; case .external: "外接磁碟" }
}

struct SettingsView: View {
    @ObservedObject var model: AppModel
    @State private var draft: AddDraft?

    var body: some View {
        ScrollView {
            content.padding(20)
        }
        .frame(width: 660)
        .frame(maxHeight: 720)
        .sheet(item: $draft) { d in AddSheet(model: model, draft: d) { draft = nil } }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !model.snap.conflicts.isEmpty { conflictSection }
            Text("同步資料夾").font(.title2.bold())
            Text("這些資料夾會互相保持一致：任一個有新增、修改或刪除，其他也會跟著變。刪除的檔案會先進垃圾桶。")
                .font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)

            if model.snap.endpoints.isEmpty {
                Text("尚未加入任何資料夾。建議依序加入：本機資料夾、iCloud 內的資料夾、Google Drive 內的資料夾、外接磁碟內的資料夾。")
                    .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }
            ForEach(model.snap.endpoints, id: \.id) { ep in EndpointRow(model: model, ep: ep) }

            HStack {
                Button("加入資料夾…") { startAdd() }
                Spacer()
                if let m = model.settingsMessage { Text(m).font(.callout).foregroundStyle(.secondary) }
            }
            if model.snap.endpoints.count < 2 {
                Text("至少需要兩個資料夾才會開始同步。").font(.callout).foregroundStyle(.orange)
            }

            Divider().padding(.vertical, 4)
            Text("同一個檔案兩邊都被修改時").font(.title3.bold())
            Picker("", selection: Binding(get: { model.snap.conflictPolicy }, set: { model.setPolicy($0) })) {
                Text("保留兩份，由我挑選（預設）").tag(ConflictPolicy.keepBoth)
                Text("自動採用較新的，舊的存進 Versions").tag(ConflictPolicy.newerWins)
            }
            .pickerStyle(.radioGroup).labelsHidden()
            Text(model.snap.conflictPolicy == .keepBoth
                 ? "原檔會和其他資料夾保持一致；另一份會加上「(conflict …)」標記，只留在發生衝突的資料夾，不會再同步出去，也不會被刪除，直到你在這裡選擇。"
                 : "以檔案修改時間判斷。兩邊時間相差 2 秒內、或無法判斷時，仍會保留兩份。不同電腦的時鐘若不準，可能選錯；舊版一律存入 Versions，隨時可以找回。")
                .font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)

            Divider().padding(.vertical, 4)
            versionsSection
        }
        .onAppear { model.refreshVersions() }
    }

    private var versionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("舊版本").font(.title3.bold())
            let u = model.snap.versions
            Text(u.files == 0 ? "目前沒有保留任何舊版本。"
                 : "已保留 \(u.files) 個舊版本，共 \(ByteCountFormatter.string(fromByteCount: u.bytes, countStyle: .file))"
                   + (u.oldest.map { "，最早從 \($0.formatted(date: .abbreviated, time: .omitted))" } ?? ""))
                .font(.callout)
            Text("檔案被其他資料夾的新版覆蓋或取代前，舊內容會先存在這裡，萬一改錯可以找回。")
                .font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("自動清理：保留")
                Picker("", selection: Binding(get: { model.snap.versionsRetentionDays }, set: { model.setRetention(days: $0) })) {
                    Text("7 天").tag(7); Text("30 天").tag(30); Text("90 天").tag(90); Text("永久").tag(0)
                }
                .labelsHidden().frame(width: 100)
                Text("（總量超過 20 GB 時也會從最舊的開始清）").font(.callout).foregroundStyle(.secondary)
            }
            HStack {
                Button("立即清理過期版本") { model.purgeVersions(.expired) }
                Button("全部清除…", role: .destructive) { clearAll() }.disabled(model.snap.versions.files == 0)
                Button("在 Finder 顯示") { model.revealVersionsFolder() }
            }
        }
    }

    private func clearAll() {
        let a = NSAlert()
        a.messageText = "永久刪除所有舊版本？"
        a.informativeText = "這些檔案會直接刪除，不會進垃圾桶，無法復原。同步中的正式檔案不受影響。"
        a.addButton(withTitle: "全部刪除"); a.addButton(withTitle: "取消")
        a.buttons.first?.hasDestructiveAction = true
        if a.runModal() == .alertFirstButtonReturn { model.purgeVersions(.all) }
    }

    private var conflictSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("待處理的衝突（\(model.snap.conflicts.count)）", systemImage: "exclamationmark.triangle.fill")
                .font(.title3.bold()).foregroundStyle(.orange)
            Text("選擇要保留哪一份，另一份會自動移到垃圾桶（可從垃圾桶放回）。")
                .font(.callout).foregroundStyle(.secondary)
            ForEach(model.snap.conflicts) { c in ConflictRow(model: model, c: c) }
            Divider().padding(.vertical, 4)
        }
    }

    private func startAdd() {
        guard let path = pickFolder(message: "選擇要加入同步的資料夾") else { return }
        let d = EndpointValidator.describe(path: path)
        let suggestedName: String = {
            let base: String
            switch d.kind {
            case .local: base = "本機"
            case .icloud: base = "iCloud"
            case .googleDrive: base = "GoogleDrive"
            case .external: base = d.volumeName ?? "外接碟"
            }
            let taken = Set(model.snap.endpoints.map(\.id))
            if !taken.contains(base) { return base }
            return (2...9).map { "\(base)\($0)" }.first { !taken.contains($0) } ?? base
        }()
        draft = AddDraft(path: path, name: suggestedName, removable: d.suggestRemovable, portable: d.suggestPortableNames, desc: d)
    }
}

struct ConflictRow: View {
    @ObservedObject var model: AppModel
    let c: SyncService.ConflictItem

    private func size(_ n: Int64?) -> String { n.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) } ?? "—" }
    private func date(_ d: Date?) -> String { d.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? "—" }
    private var extraIsNewer: Bool { (c.extraModified ?? .distantPast) > (c.mainModified ?? .distantPast) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(c.path).font(.headline)
            Text("發生在「\(c.endpoint)」").font(.caption).foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 10) {
                version(title: "原檔（與其他資料夾一致）", size: c.mainSize, date: c.mainModified, newer: !extraIsNewer,
                        path: c.mainPath, keepTitle: "保留原檔") { model.resolve(c, keep: .main) }
                version(title: "衝突副本（只在「\(c.endpoint)」）", size: c.extraSize, date: c.extraModified, newer: extraIsNewer,
                        path: c.extraPath, keepTitle: "改用這份") { model.resolve(c, keep: .conflict) }
            }
            if !c.endpointOnline { Text("「\(c.endpoint)」目前離線，接回後才能處理。").font(.callout).foregroundStyle(.orange) }
        }
        .padding(10)
        .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
    }

    private func version(title: String, size s: Int64?, date d: Date?, newer: Bool, path: String,
                         keepTitle: String, keep: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack { Text(title).font(.callout.bold()); if newer { Text("較新").font(.caption2).padding(.horizontal, 5).background(.green.opacity(0.25), in: Capsule()) } }
            Text("\(size(s))　\(date(d))").font(.callout).foregroundStyle(.secondary)
            HStack {
                Button(keepTitle, action: keep).disabled(!c.endpointOnline)
                Button("在 Finder 顯示") { model.reveal(path) }
            }
        }
        .padding(8).frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
    }
}

struct AddDraft: Identifiable {
    let id = UUID()
    var path: String
    var name: String
    var removable: Bool
    var portable: Bool
    var desc: VolumeDescription
}

struct EndpointRow: View {
    @ObservedObject var model: AppModel
    let ep: SyncService.EndpointStatus

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(ep.online ? Color.green : Color.orange).frame(width: 10, height: 10).padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(ep.id).font(.headline)
                    if ep.removable { tag("可移除") }
                    if ep.portableNames { tag("檔名相容 exFAT/Windows") }
                }
                Text(ep.root).font(.callout).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                if !ep.online { Text(ep.detail).font(.callout).foregroundStyle(.orange).fixedSize(horizontal: false, vertical: true) }
            }
            Spacer()
            Button("更換資料夾…") { change() }
            Button("移除…", role: .destructive) { remove() }
        }
        .padding(10)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }

    private func tag(_ t: String) -> some View {
        Text(t).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
            .background(.tint.opacity(0.18), in: Capsule())
    }

    private func change() {
        guard let path = pickFolder(message: "選擇「\(ep.id)」要改指向的新資料夾") else { return }
        let issues = model.validate(path: path, name: ep.id, replacing: ep.id, portable: ep.portableNames)
        if let e = issues.first(where: \.isError) { alert("無法使用這個資料夾", e.message); return }
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

    private func alert(_ title: String, _ text: String) {
        let a = NSAlert(); a.messageText = title; a.informativeText = text; a.runModal()
    }
}

struct AddSheet: View {
    @ObservedObject var model: AppModel
    @State var draft: AddDraft
    let close: () -> Void

    init(model: AppModel, draft: AddDraft, close: @escaping () -> Void) {
        self.model = model; self._draft = State(initialValue: draft); self.close = close
    }

    var issues: [ValidationIssue] { model.validate(path: draft.path, name: draft.name, portable: draft.portable) }
    var blocked: Bool { issues.contains(where: \.isError) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("加入資料夾").font(.title3.bold())
            Text(draft.path).font(.callout).foregroundStyle(.secondary).lineLimit(2).truncationMode(.middle)
            Text("偵測到：\(label(draft.desc.kind))\(draft.desc.format.map { "（\($0)）" } ?? "")").font(.callout)
            TextField("名稱", text: $draft.name)
            Toggle("可能被拔除（外接磁碟）", isOn: $draft.removable)
            Toggle("檔名須相容 exFAT / Windows", isOn: $draft.portable)
            Text("磁碟被拔除時，這個資料夾會暫時停止同步，不會被當成「檔案全被刪除」；接回後會自動對帳。")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            ForEach(issues, id: \.message) { i in
                Label(i.message, systemImage: i.isError ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(i.isError ? .red : .orange).font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Spacer()
                Button("取消") { close() }.keyboardShortcut(.cancelAction)
                Button("加入") {
                    model.addEndpoint(name: draft.name, path: draft.path, removable: draft.removable, portable: draft.portable)
                    close()
                }
                .keyboardShortcut(.defaultAction).disabled(blocked)
            }
        }
        .padding(20).frame(width: 480)
    }
}
