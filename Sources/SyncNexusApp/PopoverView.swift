import AppKit
import SwiftUI
import SyncCore

/// The menu bar popover: one glance answers "is my data safe and in sync?".
struct PopoverView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.openWindow) private var openWindow

    private func openMain(_ s: MainSection) {
        model.section = s
        openWindow(id: "settings")
        NSApp.activate(ignoringOtherApps: true)
    }

    private var totalEndpoints: Int { model.groupStates.reduce(0) { $0 + $1.snap.endpoints.count } }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            scrolling {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(model.groupStates, id: \.group.id) { state in banners(for: state) }
                    foldersByGroup
                    if !allRecent.isEmpty {
                        sectionLabel(loc("popover_recent_activity")).padding(.top, 8)
                        ForEach(groupedActivity.prefix(3)) { g in activityRow(g) }
                    }
                }
                .padding(.bottom, 8)
            }
            Divider()
            footer
        }
        .frame(width: 380)
        .id(l10n.currentLanguage)
    }

    /// Natural height for the usual case; scrolls only when there are unusually many rows.
    @ViewBuilder private func scrolling<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        if totalEndpoints + model.groups.count > 7 { ScrollView { content() }.frame(height: 440) } else { content() }
    }

    // MARK: folders, grouped by sync group

    /// With several groups every group gets its own block (so each can be reviewed here); a single group keeps the plain list.
    @ViewBuilder private var foldersByGroup: some View {
        let states = model.groupStates
        if states.count > 1 {
            sectionLabel(loc("group_selector_title"))
            ForEach(states, id: \.group.id) { state in
                groupHeader(state)
                if state.snap.endpoints.isEmpty {
                    Text(loc("popover_no_folders_hint"))
                        .font(.system(size: 12)).foregroundStyle(.secondary).padding(.horizontal, 20).padding(.leading, 28).padding(.vertical, 4)
                }
                ForEach(state.snap.endpoints, id: \.id) { ep in endpointRow(ep, group: state.group.id).padding(.leading, 18) }
            }
        } else if let state = states.first {
            sectionLabel(loc("section_folders"))
            if state.snap.endpoints.isEmpty {
                Text(loc("popover_no_folders_hint"))
                    .font(.system(size: 13)).foregroundStyle(.secondary).padding(.horizontal, 20).padding(.vertical, 8)
            }
            ForEach(state.snap.endpoints, id: \.id) { ep in endpointRow(ep, group: state.group.id) }
        }
    }

    /// Group title with its own state; click to open that group on the Folders page.
    private func groupHeader(_ state: (group: SyncGroup, snap: SyncService.Snapshot, overall: Overall)) -> some View {
        let (chipText, chipKind): (String, Chip.Kind) = {
            switch state.overall {
            case .ok: (loc("online"), .ok)
            case .attention: (AppModel.title(of: state.snap, .attention), .warn)
            case .partial: (loc("status_partial"), .warn)
            case .paused: (loc("status_paused"), .warn)
            case .syncing: (loc("status_syncing"), .ok)
            case .starting: (loc("status_starting"), .ok)
            }
        }()
        return Button {
            model.selectGroup(id: state.group.id)
            openMain(.folders)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: state.group.icon).font(.system(size: 13)).foregroundStyle(Color.accentColor).frame(width: 20)
                Text(model.groupName(state.group)).font(.system(size: 13, weight: .bold)).lineLimit(1)
                Text("\(state.snap.endpoints.count)")
                    .font(.system(size: 10, weight: .semibold)).padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Theme.line, in: Capsule())
                Spacer(minLength: 0)
                Chip(text: chipText, kind: chipKind)
                Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20).padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
        .help(loc("group_edit_title"))
    }

    // MARK: header

    private var header: some View {
        HStack(spacing: 14) {
            ring
            VStack(alignment: .leading, spacing: 3) {
                Text(model.popoverTitle).font(.system(size: 18, weight: .bold)).tracking(-0.2)
                if !model.popoverDetail.isEmpty {
                    Text(model.popoverDetail).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(2)
                }
            }
            Spacer(minLength: 0)
            Button(action: model.togglePause) {
                Image(systemName: model.allPaused ? "play.fill" : "pause.fill").font(.system(size: 13))
                    .frame(width: 34, height: 34)
                    .overlay(Circle().stroke(Theme.line, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .help(model.allPaused ? loc("popover_resume_sync") : loc("popover_pause_sync"))
            .accessibilityLabel(model.allPaused ? loc("popover_resume_sync") : loc("popover_pause_sync"))
        }
        .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 16)
    }

    private var ring: some View {
        let (symbol, fg, bg): (String?, Color, Color) = {
            switch model.popoverOverall {
            case .ok: ("checkmark", Theme.ok, Theme.okFill)
            case .partial: ("minus", Theme.warn, Theme.warnFill)
            case .attention: ("exclamationmark", Theme.warn, Theme.warnFill)
            case .paused: ("pause.fill", .secondary, Theme.tile)
            case .syncing, .starting: (nil, .accentColor, Theme.tile)
            }
        }()
        return ZStack {
            Circle().fill(bg)
            if let symbol { Image(systemName: symbol).font(.system(size: 20, weight: .bold)).foregroundStyle(fg) }
            else { ProgressView().controlSize(.small) }
        }
        .frame(width: 48, height: 48)
    }

    // MARK: content

    @ViewBuilder private func banners(for state: (group: SyncGroup, snap: SyncService.Snapshot, overall: Overall)) -> some View {
        let gid = state.group.id
        let s = state.snap
        // several groups: say which group a message is about
        let who = model.groups.count > 1 ? model.groupName(state.group) + "：" : ""
        if let e = s.error {
            banner(symbol: "xmark.octagon", tone: .bad, title: loc("popover_sync_error"), detail: who + e, action: loc("popover_btn_log")) { model.selectGroup(id: gid); model.openLog() }
        }
        if s.confirmation != nil {
            banner(symbol: "hand.raised", tone: .warn, title: loc("popover_confirm_needed"), detail: who + (s.confirmation?.reason ?? ""), action: loc("popover_btn_view")) { model.reviewConfirmation(group: gid) }
        }
        if !s.conflicts.isEmpty {
            banner(symbol: "exclamationmark.triangle", tone: .warn, title: loc("status_conflicts_pending", s.conflicts.count),
                   detail: who + loc("popover_conflict_sub", (s.conflicts[0].path as NSString).lastPathComponent), action: loc("popover_btn_view")) { model.selectGroup(id: gid); openMain(.conflicts) }
        }
        if !s.integrityIssues.isEmpty {
            banner(symbol: "checkmark.shield", tone: .warn, title: loc("popover_corrupt_files", s.integrityIssues.count),
                   detail: who + loc("popover_corrupt_sub"), action: loc("popover_btn_view")) { model.selectGroup(id: gid); openMain(.verification) }
        }
    }

    private func banner(symbol: String, tone: Chip.Kind, title: String, detail: String, action: String, perform: @escaping () -> Void) -> some View {
        let fg = tone == .bad ? Theme.bad : Theme.warn, bg = tone == .bad ? Theme.badFill : Theme.warnFill
        return HStack(spacing: 12) {
            Image(systemName: symbol).font(.system(size: 17)).foregroundStyle(fg)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .bold))
                Text(detail).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer(minLength: 0)
            Button(action, action: perform).buttonStyle(QuietButton(kind: .dark, compact: true))
        }
        .padding(12)
        .background(bg, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20).padding(.top, 12)
    }

    private func sectionLabel(_ t: String) -> some View {
        Text(t).font(.system(size: 12, weight: .semibold)).tracking(0.4).foregroundStyle(.secondary)
            .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 4)
    }

    private func endpointRow(_ ep: SyncService.EndpointStatus, group: String) -> some View {
        let kind = EndpointValidator.describe(path: ep.root).kind
        return HStack(spacing: 12) {
            Image(systemName: kind.symbol).font(.system(size: 16)).frame(width: 34, height: 34)
                .background(Theme.tile, in: RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(DisplayNames.endpoint(ep.id)).font(.system(size: 14, weight: .semibold))
                Text(ep.online ? (model.pendingCloud(ep.id, group: group) > 0 ? loc("popover_reading_cloud", model.pendingCloud(ep.id, group: group)) : shortPath(ep.root)) : ((ep.removable && !FileManager.default.fileExists(atPath: ep.root)) ? loc("popover_unplugged_sub") : ep.detail))
                    .font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
            }
            Spacer(minLength: 0)
            Chip(text: ep.online ? loc("online") : loc("offline"), kind: ep.online ? .ok : .warn)
        }
        .padding(.horizontal, 20).padding(.vertical, 8)
    }

    /// The same change lands on several folders at once; show it once with a count.
    private struct ActivityGroup: Identifiable {
        var id: Int64; var time: Date; var op: String; var path: String; var count: Int; var ok: Bool
    }
    /// Recent changes of every group, newest first.
    private var allRecent: [SyncService.Activity] {
        model.groupStates.flatMap { $0.snap.recent }.sorted { $0.time > $1.time }
    }
    private var groupedActivity: [ActivityGroup] {
        var out: [ActivityGroup] = []
        for a in allRecent {
            if let i = out.firstIndex(where: { $0.op == a.op && $0.path == a.path && abs($0.time.timeIntervalSince(a.time)) < 120 }) {
                out[i].count += 1; out[i].ok = out[i].ok && a.ok
            } else { out.append(ActivityGroup(id: Int64(out.count), time: a.time, op: a.op, path: a.path, count: 1, ok: a.ok)) }
        }
        return out
    }

    private func activityRow(_ a: ActivityGroup) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(a.time.formatted(date: .omitted, time: .shortened)).font(.system(size: 12)).foregroundStyle(.secondary).monospacedDigit().frame(width: 52, alignment: .leading)
            Text("\((a.path as NSString).lastPathComponent) \(friendlyOp(a.op))\(a.count > 1 ? loc("popover_activity_places", a.count) : "")")
                .font(.system(size: 13)).foregroundStyle(a.ok ? Color.primary : Theme.bad).lineLimit(1).truncationMode(.middle)
        }
        .padding(.horizontal, 20).padding(.vertical, 3)
    }

    // MARK: footer

    private var footer: some View {
        HStack(spacing: 8) {
            Button(loc("popover_sync_now")) { model.syncAllNow() }.buttonStyle(QuietButton(kind: .primary)).keyboardShortcut("r")
            Button(loc("popover_settings")) { openMain(.overview) }.buttonStyle(QuietButton(kind: .secondary)).keyboardShortcut(",")
            Spacer(minLength: 0)
            Text(loc("popover_version", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"))
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Menu {
                Button(loc("popover_verify_now")) { model.verifyNow() }
                Button(loc("settings_btn_open_log")) { model.openLog() }
                Button(loc("popover_instructions")) { openWindow(id: "welcome"); NSApp.activate(ignoringOtherApps: true) }
                Divider()
                Button(loc("popover_quit")) { model.quit() }.keyboardShortcut("q")
            } label: { Image(systemName: "ellipsis").frame(width: 24, height: 24) }
            .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize()
            .accessibilityLabel(loc("popover_more"))
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
    }
}
