import AppKit
import SwiftUI
import SyncCore

struct PickedFolder {
    let path: String
    let bookmarkData: Data?
}

func pickFolder(message: String) -> PickedFolder? {
    let p = NSOpenPanel()
    p.canChooseDirectories = true; p.canChooseFiles = false; p.canCreateDirectories = true; p.allowsMultipleSelection = false
    p.message = message; p.prompt = loc("choose")
    NSApp.activate(ignoringOtherApps: true)
    guard p.runModal() == .OK, let url = p.url else { return nil }
    let bookmark = SecurityScopeManager.shared.createBookmark(for: url)
    return PickedFolder(path: url.path, bookmarkData: bookmark)
}

struct AddDraft: Identifiable {
    let id = UUID()
    var path: String
    var bookmarkData: Data?
    var name: String
    var removable: Bool
    var portable: Bool
    var archive = false
    var desc: VolumeDescription
}

struct FoldersSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State private var draft: AddDraft?

    var body: some View {
        sectionHeader(loc("section_folders"), loc("folders_desc"))
        if model.snap.endpoints.isEmpty {
            Card { Text(loc("folders_empty_hint"))
                .font(.system(size: 14)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true) }
        }
        ForEach(model.snap.endpoints, id: \.id) { ep in FolderRow(model: model, ep: ep) }
        HStack {
            Button(loc("folders_add_button")) { startAdd() }.buttonStyle(QuietButton(kind: .primary))
            if model.snap.endpoints.count < 2 { Text(loc("folders_minimum_warning")).font(.system(size: 13)).foregroundStyle(Theme.warn) }
        }
        .sheet(item: $draft) { d in AddSheet(model: model, draft: d) { draft = nil } }
    }

    private func startAdd() {
        guard let picked = pickFolder(message: loc("folders_add_button")) else { return }
        let d = EndpointValidator.describe(path: picked.path)
        let base: String
        switch d.kind {
        case .local: base = loc("kind_local")
        case .icloud: base = "iCloud"
        case .googleDrive: base = "GoogleDrive"
        case .external: base = d.volumeName ?? loc("kind_external")
        }
        let taken = Set(model.snap.endpoints.map(\.id))
        let name = taken.contains(base) ? ((2...9).map { "\(base)\($0)" }.first { !taken.contains($0) } ?? base) : base
        draft = AddDraft(path: picked.path, bookmarkData: picked.bookmarkData, name: name, removable: d.suggestRemovable, portable: d.suggestPortableNames, desc: d)
    }
}

struct FolderRow: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    let ep: SyncService.EndpointStatus

    var body: some View {
        let kind = EndpointValidator.describe(path: ep.root).kind
        Card {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: kind.symbol).font(.system(size: 18)).frame(width: 36, height: 36).background(Theme.tile, in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(ep.id).font(.system(size: 15, weight: .bold))
                        Chip(text: ep.online ? loc("online") : loc("offline"), kind: ep.online ? .ok : .warn)
                        if ep.role == .archive { Chip(text: loc("archive_badge"), kind: .neutral) }
                        if ep.removable { Chip(text: loc("removable_badge"), kind: .neutral) }
                        if ep.portableNames { Chip(text: loc("portable_badge"), kind: .neutral) }
                    }
                    Text(shortPath(ep.root)).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                    if !ep.online {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ep.detail).font(.system(size: 12)).foregroundStyle(Theme.warn).fixedSize(horizontal: false, vertical: true)
                            if ep.detail.contains("標記檔") || ep.detail.contains("UUID") || ep.detail.contains("marker") {
                                Text(loc("folder_marker_help"))
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 2)
                            }
                        }
                    }
                }
                Spacer()
                if ep.role == .archive { Button(loc("show_history")) { model.reveal(ep.root + "/.syncnexus-history") }.buttonStyle(QuietButton(kind: .plain)) }
                Button(loc("change_folder")) { change() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                Button(loc("remove")) { remove() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
            }
        }
    }

    private func change() {
        guard let picked = pickFolder(message: loc("folders_change_prompt", ep.id)) else { return }
        let issues = model.validate(path: picked.path, name: ep.id, replacing: ep.id, portable: ep.portableNames)
        if let e = issues.first(where: \.isError) { let a = NSAlert(); a.messageText = loc("folders_cannot_use_title"); a.informativeText = e.message; a.runModal(); return }
        let a = NSAlert()
        a.messageText = loc("folders_relink_title", ep.id)
        a.informativeText = loc("folders_relink_desc") + issues.map(\.message).joined(separator: "\n")
        a.addButton(withTitle: loc("folders_btn_relink")); a.addButton(withTitle: loc("cancel"))
        if a.runModal() == .alertFirstButtonReturn { model.relink(id: ep.id, to: picked.path, bookmarkData: picked.bookmarkData) }
    }

    private func remove() {
        let a = NSAlert()
        a.messageText = loc("folders_remove_title", ep.id)
        a.informativeText = loc("folders_remove_desc")
        a.addButton(withTitle: loc("remove")); a.addButton(withTitle: loc("cancel"))
        if a.runModal() == .alertFirstButtonReturn { model.remove(id: ep.id) }
    }
}

struct AddSheet: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State var draft: AddDraft
    let close: () -> Void

    init(model: AppModel, draft: AddDraft, close: @escaping () -> Void) {
        self.model = model; self._draft = State(initialValue: draft); self.close = close
    }

    private var issues: [ValidationIssue] { model.validate(path: draft.path, name: draft.name, portable: draft.portable) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc("folders_add_title")).font(.system(size: 20, weight: .bold))
            Text(shortPath(draft.path)).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(2).truncationMode(.middle)
            HStack(spacing: 8) {
                Image(systemName: draft.desc.kind.symbol)
                Text(loc("folders_detected", "\(draft.desc.kind.label)\(draft.desc.format.map { "（\($0)）" } ?? "")")).font(.system(size: 13))
            }
            TextField(loc("folders_name_label"), text: $draft.name).textFieldStyle(.roundedBorder)
            Toggle(loc("folders_toggle_removable"), isOn: $draft.removable)
            Toggle(loc("folders_toggle_portable"), isOn: $draft.portable)
            Toggle(loc("folders_toggle_archive"), isOn: $draft.archive)
            if draft.archive {
                Text(loc("folders_archive_hint"))
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Text(loc("folders_removable_hint"))
                .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            ForEach(issues, id: \.message) { i in
                Label(i.message, systemImage: i.isError ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 13)).foregroundStyle(i.isError ? Theme.bad : Theme.warn).fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Spacer()
                Button(loc("cancel")) { close() }.buttonStyle(QuietButton(kind: .secondary)).keyboardShortcut(.cancelAction)
                Button(loc("folders_btn_add")) { model.addEndpoint(name: draft.name, path: draft.path, removable: draft.removable, portable: draft.portable, archive: draft.archive, bookmarkData: draft.bookmarkData); close() }
                    .buttonStyle(QuietButton(kind: .primary)).keyboardShortcut(.defaultAction).disabled(issues.contains(where: \.isError))
            }
        }
        .padding(22).frame(width: 480)
        .id(l10n.currentLanguage)
    }
}
