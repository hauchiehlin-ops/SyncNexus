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
    @State private var showingAddGroup = false
    @State private var editingGroup: SyncGroup?

    var body: some View {
        sectionHeader(loc("section_folders"), loc("folders_desc"))

        // Multi-folder Sync Groups Selector Bar
        SyncGroupTabBar(model: model, showingAddGroup: $showingAddGroup, editingGroup: $editingGroup)

        // Active Group Info Banner
        if let g = model.activeGroup {
            HStack(spacing: 8) {
                Image(systemName: g.icon).font(.system(size: 14)).foregroundStyle(Color.accentColor)
                Text(loc("group_active_banner", DisplayNames.group(g), model.snap.endpoints.count))
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button(action: { editingGroup = g }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text(loc("group_edit_title"))
                    }
                    .font(.system(size: 11))
                }
                .buttonStyle(QuietButton(kind: .plain, compact: true))
            }
            .padding(.horizontal, 4)
        }

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
        .sheet(isPresented: $showingAddGroup) { AddGroupSheet(model: model) { showingAddGroup = false } }
        .sheet(item: $editingGroup) { g in EditGroupSheet(model: model, group: g) { editingGroup = nil } }
    }

    private func startAdd() {
        guard let picked = pickFolder(message: loc("folders_add_button")) else { return }
        let d = EndpointValidator.describe(path: picked.path)
        let base: String
        switch d.kind {
        case .local: base = "Local"
        case .icloud: base = "iCloud"
        case .googleDrive: base = "GoogleDrive"
        case .external: base = d.volumeName ?? loc("kind_external")
        }
        let taken = Set(model.snap.endpoints.map(\.id))
        let name = taken.contains(base) ? ((2...9).map { "\(base)\($0)" }.first { !taken.contains($0) } ?? base) : base
        draft = AddDraft(path: picked.path, bookmarkData: picked.bookmarkData, name: name, removable: d.suggestRemovable, portable: d.suggestPortableNames, desc: d)
    }
}

struct SyncGroupTabBar: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @Binding var showingAddGroup: Bool
    @Binding var editingGroup: SyncGroup?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "folder.badge.gearshape")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.accentColor)
                Text(loc("group_selector_title"))
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Menu {
                    let backups = model.registry.listBackups()
                    if backups.isEmpty {
                        Text(loc("backup_none"))
                    } else {
                        ForEach(backups) { b in
                            Button("\(b.date.formatted(date: .abbreviated, time: .shortened))　\(b.groupNames.joined(separator: "、"))（\(b.endpointCount)）") {
                                model.restoreBackup(b)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text(loc("backup_restore_menu"))
                    }
                    .font(.system(size: 12, weight: .medium))
                }
                .menuStyle(.borderlessButton).fixedSize()
                Button(action: { model.importLegacySettings() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.down")
                        Text(loc("import_legacy_button"))
                    }
                    .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(QuietButton(kind: .secondary, compact: true))
                Button(action: { showingAddGroup = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text(loc("group_add_button"))
                    }
                    .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(QuietButton(kind: .secondary, compact: true))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(model.groups) { group in
                        let isActive = group.id == model.activeGroupId
                        let epCount = model.endpointCount(for: group.id)
                        Button(action: { model.selectGroup(id: group.id) }) {
                            HStack(spacing: 6) {
                                Image(systemName: group.icon)
                                    .font(.system(size: 13))
                                Text(DisplayNames.group(group))
                                    .font(.system(size: 13, weight: isActive ? .bold : .medium))
                                Text("\(epCount)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(isActive ? Color.white.opacity(0.25) : Theme.line, in: Capsule())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isActive ? Theme.accent : Theme.tile, in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(isActive ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(loc("group_edit_title")) {
                                editingGroup = group
                            }
                            if model.groups.count > 1 {
                                Button(role: .destructive) {
                                    confirmDelete(group: group)
                                } label: {
                                    Label(loc("group_delete_button"), systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.line, lineWidth: 1))
    }

    private func confirmDelete(group: SyncGroup) {
        let alert = NSAlert()
        alert.messageText = loc("group_delete_confirm_title", DisplayNames.group(group))
        alert.informativeText = loc("group_delete_confirm_desc")
        alert.addButton(withTitle: loc("group_delete_button"))
        alert.addButton(withTitle: loc("cancel"))
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            model.deleteGroup(id: group.id)
        }
    }
}

struct AddGroupSheet: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State private var name = ""
    @State private var selectedIcon = "folder"
    let close: () -> Void

    let availableIcons = [
        "folder", "briefcase", "doc.text", "camera", "graduationcap",
        "heart", "externaldrive", "building.2", "tag", "star"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc("group_add_title")).font(.system(size: 20, weight: .bold))
            Text(loc("group_add_desc"))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                Text(loc("group_name_label")).font(.system(size: 13, weight: .medium))
                TextField(loc("group_name_placeholder"), text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(loc("group_icon_label")).font(.system(size: 13, weight: .medium))
                HStack(spacing: 10) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .frame(width: 32, height: 32)
                                .background(selectedIcon == icon ? Theme.accent : Theme.tile, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundStyle(selectedIcon == icon ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack {
                Spacer()
                Button(loc("cancel")) { close() }
                    .buttonStyle(QuietButton(kind: .secondary))
                    .keyboardShortcut(.cancelAction)
                Button(loc("folders_btn_add")) {
                    model.createGroup(name: name, icon: selectedIcon)
                    close()
                }
                .buttonStyle(QuietButton(kind: .primary))
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(22)
        .frame(width: 480)
        .id(l10n.currentLanguage)
    }
}

struct EditGroupSheet: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    let group: SyncGroup
    @State private var name: String
    @State private var selectedIcon: String
    let close: () -> Void

    init(model: AppModel, group: SyncGroup, close: @escaping () -> Void) {
        self.model = model
        self.group = group
        self._name = State(initialValue: group.name)
        self._selectedIcon = State(initialValue: group.icon)
        self.close = close
    }

    let availableIcons = [
        "folder", "briefcase", "doc.text", "camera", "graduationcap",
        "heart", "externaldrive", "building.2", "tag", "star"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(loc("group_edit_title")).font(.system(size: 20, weight: .bold))

            VStack(alignment: .leading, spacing: 6) {
                Text(loc("group_name_label")).font(.system(size: 13, weight: .medium))
                TextField(loc("group_name_placeholder"), text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(loc("group_icon_label")).font(.system(size: 13, weight: .medium))
                HStack(spacing: 10) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .frame(width: 32, height: 32)
                                .background(selectedIcon == icon ? Theme.accent : Theme.tile, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundStyle(selectedIcon == icon ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack {
                if model.groups.count > 1 {
                    Button(role: .destructive) {
                        close()
                        confirmDelete()
                    } label: {
                        Text(loc("group_delete_button"))
                    }
                    .buttonStyle(QuietButton(kind: .secondary))
                }
                Spacer()
                Button(loc("cancel")) { close() }
                    .buttonStyle(QuietButton(kind: .secondary))
                    .keyboardShortcut(.cancelAction)
                Button(loc("save")) {
                    model.updateGroup(id: group.id, name: name, icon: selectedIcon)
                    close()
                }
                .buttonStyle(QuietButton(kind: .primary))
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(22)
        .frame(width: 480)
        .id(l10n.currentLanguage)
    }

    private func confirmDelete() {
        let alert = NSAlert()
        alert.messageText = loc("group_delete_confirm_title", DisplayNames.group(group))
        alert.informativeText = loc("group_delete_confirm_desc")
        alert.addButton(withTitle: loc("group_delete_button"))
        alert.addButton(withTitle: loc("cancel"))
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            model.deleteGroup(id: group.id)
        }
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
                        Text(DisplayNames.endpoint(ep.id)).font(.system(size: 15, weight: .bold))
                        Chip(text: ep.online ? loc("online") : loc("offline"), kind: ep.online ? .ok : .warn)
                        if ep.role == .archive { Chip(text: loc("archive_badge"), kind: .neutral) }
                        if ep.removable { Chip(text: loc("removable_badge"), kind: .neutral) }
                        if ep.portableNames { Chip(text: loc("portable_badge"), kind: .neutral) }
                    }
                    Text(shortPath(ep.root)).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                    if !ep.online {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ep.detail).font(.system(size: 12)).foregroundStyle(Theme.warn).fixedSize(horizontal: false, vertical: true)
                            if model.rawDetail(ep.id).contains("標記檔") || model.rawDetail(ep.id).contains("UUID") {
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
        guard let picked = pickFolder(message: loc("folders_change_prompt", DisplayNames.endpoint(ep.id))) else { return }
        let issues = model.validate(path: picked.path, name: ep.id, replacing: ep.id, portable: ep.portableNames)
        if let e = issues.first(where: \.isError) { let a = NSAlert(); a.messageText = loc("folders_cannot_use_title"); a.informativeText = e.message; a.runModal(); return }
        let a = NSAlert()
        a.messageText = loc("folders_relink_title", DisplayNames.endpoint(ep.id))
        a.informativeText = loc("folders_relink_desc") + issues.map(\.message).joined(separator: "\n")
        a.addButton(withTitle: loc("folders_btn_relink")); a.addButton(withTitle: loc("cancel"))
        if a.runModal() == .alertFirstButtonReturn { model.relink(id: ep.id, to: picked.path, bookmarkData: picked.bookmarkData) }
    }

    private func remove() {
        let a = NSAlert()
        a.messageText = loc("folders_remove_title", DisplayNames.endpoint(ep.id))
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
