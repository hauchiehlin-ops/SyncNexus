import AppKit
import SwiftUI
import SyncCore

/// The menu bar popover: one glance answers "is my data safe and in sync?".
struct PopoverView: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow

    private func openMain(_ s: MainSection) {
        model.section = s
        openWindow(id: "settings")
        NSApp.activate(ignoringOtherApps: true)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            scrolling {
                VStack(alignment: .leading, spacing: 0) {
                    banners
                    sectionLabel("資料夾")
                    if model.snap.endpoints.isEmpty {
                        Text("還沒有加入資料夾。打開「設定」加入至少兩個。")
                            .font(.system(size: 13)).foregroundStyle(.secondary).padding(.horizontal, 20).padding(.vertical, 8)
                    }
                    ForEach(model.snap.endpoints, id: \.id) { ep in endpointRow(ep) }
                    if !model.snap.recent.isEmpty {
                        sectionLabel("最近活動").padding(.top, 8)
                        ForEach(groupedActivity.prefix(3)) { g in activityRow(g) }
                    }
                }
                .padding(.bottom, 8)
            }
            Divider()
            footer
        }
        .frame(width: 380)
    }

    /// Natural height for the usual case; scrolls only when there are unusually many rows.
    @ViewBuilder private func scrolling<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        if model.snap.endpoints.count > 6 { ScrollView { content() }.frame(height: 440) } else { content() }
    }

    // MARK: header

    private var header: some View {
        HStack(spacing: 14) {
            ring
            VStack(alignment: .leading, spacing: 3) {
                Text(model.overallTitle).font(.system(size: 18, weight: .bold)).tracking(-0.2)
                if !model.overallDetail.isEmpty {
                    Text(model.overallDetail).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(2)
                }
            }
            Spacer(minLength: 0)
            Button(action: model.togglePause) {
                Image(systemName: model.snap.phase == .paused ? "play.fill" : "pause.fill").font(.system(size: 13))
                    .frame(width: 34, height: 34)
                    .overlay(Circle().stroke(Theme.line, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .help(model.snap.phase == .paused ? "繼續同步" : "暫停同步")
            .accessibilityLabel(model.snap.phase == .paused ? "繼續同步" : "暫停同步")
        }
        .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 16)
    }

    private var ring: some View {
        let (symbol, fg, bg): (String?, Color, Color) = {
            switch model.overall {
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

    @ViewBuilder private var banners: some View {
        if let e = model.snap.error {
            banner(symbol: "xmark.octagon", tone: .bad, title: "同步發生錯誤", detail: e, action: "紀錄") { model.openLog() }
        }
        if model.snap.confirmation != nil {
            banner(symbol: "hand.raised", tone: .warn, title: "需要你確認", detail: model.snap.confirmation?.reason ?? "", action: "查看") { model.reviewConfirmation() }
        }
        if !model.snap.conflicts.isEmpty {
            banner(symbol: "exclamationmark.triangle", tone: .warn, title: "\(model.snap.conflicts.count) 個衝突等你決定",
                   detail: "\(model.snap.conflicts[0].path)　兩邊都被修改", action: "查看") { openMain(.conflicts) }
        }
        if !model.snap.integrityIssues.isEmpty {
            banner(symbol: "checkmark.shield", tone: .warn, title: "\(model.snap.integrityIssues.count) 個檔案疑似損壞",
                   detail: "內容與紀錄不符，已隔離、不會傳播", action: "查看") { openMain(.verification) }
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

    private func endpointRow(_ ep: SyncService.EndpointStatus) -> some View {
        let kind = EndpointValidator.describe(path: ep.root).kind
        return HStack(spacing: 12) {
            Image(systemName: kind.symbol).font(.system(size: 16)).frame(width: 34, height: 34)
                .background(Theme.tile, in: RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(ep.id).font(.system(size: 14, weight: .semibold))
                Text(ep.online ? shortPath(ep.root) : (ep.removable ? "已拔除　· 接回後自動對帳" : ep.detail))
                    .font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
            }
            Spacer(minLength: 0)
            Chip(text: ep.online ? "在線" : "離線", kind: ep.online ? .ok : .warn)
        }
        .padding(.horizontal, 20).padding(.vertical, 8)
    }

    /// The same change lands on several folders at once; show it once with a count.
    private struct ActivityGroup: Identifiable {
        var id: Int64; var time: Date; var op: String; var path: String; var count: Int; var ok: Bool
    }
    private var groupedActivity: [ActivityGroup] {
        var out: [ActivityGroup] = []
        for a in model.snap.recent {
            if let i = out.firstIndex(where: { $0.op == a.op && $0.path == a.path && abs($0.time.timeIntervalSince(a.time)) < 120 }) {
                out[i].count += 1; out[i].ok = out[i].ok && a.ok
            } else { out.append(ActivityGroup(id: a.id, time: a.time, op: a.op, path: a.path, count: 1, ok: a.ok)) }
        }
        return out
    }

    private func activityRow(_ a: ActivityGroup) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(a.time.formatted(date: .omitted, time: .shortened)).font(.system(size: 12)).foregroundStyle(.secondary).monospacedDigit().frame(width: 52, alignment: .leading)
            Text("\((a.path as NSString).lastPathComponent) \(friendlyOp(a.op))\(a.count > 1 ? "（\(a.count) 處）" : "")")
                .font(.system(size: 13)).foregroundStyle(a.ok ? Color.primary : Theme.bad).lineLimit(1).truncationMode(.middle)
        }
        .padding(.horizontal, 20).padding(.vertical, 3)
    }

    // MARK: footer

    private var footer: some View {
        HStack(spacing: 8) {
            Button("立即同步") { model.syncNow() }.buttonStyle(QuietButton(kind: .primary)).keyboardShortcut("r")
            Button("設定…") { openMain(.overview) }.buttonStyle(QuietButton(kind: .secondary)).keyboardShortcut(",")
            Spacer(minLength: 0)
            Text("版本 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")")
                .font(.system(size: 12)).foregroundStyle(.secondary)
            Menu {
                Button("立即完整驗證（重新讀取每個檔案）") { model.verifyNow() }
                Button("開啟紀錄檔") { model.openLog() }
                Button("使用說明與授權檢查…") { openWindow(id: "welcome"); NSApp.activate(ignoringOtherApps: true) }
                Divider()
                Button("結束 Sync-Nexus") { model.quit() }.keyboardShortcut("q")
            } label: { Image(systemName: "ellipsis").frame(width: 24, height: 24) }
            .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize()
            .accessibilityLabel("更多")
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
    }
}
