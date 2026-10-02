import AppKit
import SwiftUI
import SyncCore

func bytes(_ n: Int64) -> String { ByteCountFormatter.string(fromByteCount: n, countStyle: .file) }

struct MainWindowView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch model.section {
                        case .overview: OverviewSection(model: model)
                        case .folders: FoldersSection(model: model)
                        case .conflicts: ConflictsSection(model: model)
                        case .versions: VersionsSection(model: model)
                        case .verification: VerificationSection(model: model)
                        case .settings: SettingsSection(model: model)
                        }
                    }
                    .padding(.horizontal, 36).padding(.vertical, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let m = model.settingsMessage {
                    HStack {
                        Image(systemName: "info.circle").foregroundStyle(.secondary)
                        Text(m).font(.system(size: 13))
                        Spacer()
                        Button("好") { model.settingsMessage = nil }.buttonStyle(QuietButton(kind: .plain))
                    }
                    .padding(.horizontal, 36).padding(.vertical, 10)
                    .background(Theme.tile)
                }
            }
        }
        .frame(minWidth: 940, minHeight: 620)
        .task(id: model.settingsMessage) {
            guard model.settingsMessage != nil else { return }
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            model.settingsMessage = nil
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 10) {
                Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 30, height: 30)
                Text("Sync-Nexus").font(.system(size: 15, weight: .bold))
            }
            .padding(.horizontal, 10).padding(.bottom, 18).padding(.top, 6)
            ForEach(MainSection.allCases) { s in
                Button { model.section = s } label: {
                    HStack(spacing: 10) {
                        Image(systemName: s.symbol).font(.system(size: 15)).frame(width: 20)
                        Text(s.title).font(.system(size: 14, weight: model.section == s ? .semibold : .medium))
                        Spacer(minLength: 0)
                        if s == .conflicts && !model.snap.conflicts.isEmpty {
                            Text("\(model.snap.conflicts.count)").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                                .padding(.horizontal, 6).frame(minWidth: 18, minHeight: 18)
                                .background(Theme.warn, in: Capsule())
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(model.section == s ? Color.primary.opacity(0.09) : .clear, in: RoundedRectangle(cornerRadius: 8))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Text("版本 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")（build \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")）")
                .font(.system(size: 11)).foregroundStyle(.secondary).padding(.horizontal, 10)
        }
        .padding(.horizontal, 12).padding(.vertical, 16)
        .frame(width: 224)
        .background(Theme.sidebar)
    }
}

func sectionHeader(_ title: String, _ subtitle: String? = nil) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title).font(.system(size: 30, weight: .bold)).tracking(-0.5)
        if let subtitle { Text(subtitle).font(.system(size: 15)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true) }
    }
}

// MARK: overview

struct OverviewSection: View {
    @ObservedObject var model: AppModel

    var body: some View {
        sectionHeader(model.overall == .ok ? "一切正常" : model.overallTitle, overviewSubtitle)
        if model.snap.confirmation != nil {
            Card {
                HStack(spacing: 12) {
                    Image(systemName: "hand.raised").foregroundStyle(Theme.warn)
                    Text(model.snap.confirmation?.reason ?? "").font(.system(size: 13)).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Button("查看預覽並確認…") { model.reviewConfirmation() }.buttonStyle(QuietButton(kind: .dark))
                }
            }
        }
        HStack(spacing: 14) {
            StatTile(label: "追蹤中的檔案", value: model.snap.trackedFiles.formatted(), sub: "每次複製都核對 SHA-256")
            StatTile(label: "最近完整驗證", value: model.snap.lastDeepVerify?.formatted(date: .omitted, time: .shortened) ?? "尚未", sub: model.snap.integrityIssues.isEmpty ? "沒有異常" : "\(model.snap.integrityIssues.count) 個疑似損壞")
            StatTile(label: "舊版本", value: bytes(model.snap.versions.bytes), sub: model.snap.versionsRetentionDays == 0 ? "永久保留，可隨時還原" : "保留 \(model.snap.versionsRetentionDays) 天，可隨時還原")
        }
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            ForEach(model.snap.endpoints, id: \.id) { ep in EndpointCard(model: model, ep: ep) }
        }
        if model.snap.endpoints.count < 2 {
            Card { HStack { Image(systemName: "folder.badge.plus").foregroundStyle(Color.accentColor)
                Text("至少加入兩個資料夾才會開始同步。").font(.system(size: 14))
                Spacer(); Button("加入資料夾") { model.section = .folders }.buttonStyle(QuietButton(kind: .primary)) } }
        }
    }

    private var overviewSubtitle: String {
        switch model.overall {
        case .ok: "\(model.snap.endpoints.count) 個資料夾保持一致，沒有待處理的錯誤。"
        case .partial: "有資料夾離線；其餘的仍在互相同步，離線的接回後會自動對帳，不會被當成「檔案全被刪除」。"
        default: model.overallDetail
        }
    }
}

struct EndpointCard: View {
    @ObservedObject var model: AppModel
    let ep: SyncService.EndpointStatus
    var body: some View {
        let kind = EndpointValidator.describe(path: ep.root).kind
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: kind.symbol).font(.system(size: 17))
                    Text(ep.id).font(.system(size: 15, weight: .bold))
                    Spacer()
                    Chip(text: ep.online ? "在線" : "離線", kind: ep.online ? .ok : .warn)
                }
                Text(shortPath(ep.root)).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(2).truncationMode(.middle)
                Text(ep.online ? (model.pendingCloud(ep.id) > 0 ? "正在讀取 \(model.pendingCloud(ep.id)) 個雲端檔案，完成後自動繼續" : kind.label + (ep.portableNames ? "　· 檔名相容 exFAT／Windows" : "") + (ep.role == .archive ? "　· 備份：只接收" : ""))
                     : (ep.removable ? "已拔除　· 接回後自動對帳，不會被當成「檔案全被刪除」" : ep.detail))
                    .font(.system(size: 13)).foregroundStyle(ep.online ? Color.primary : Theme.warn).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: conflicts

struct ConflictsSection: View {
    @ObservedObject var model: AppModel
    var body: some View {
        sectionHeader("衝突", model.snap.conflicts.isEmpty ? nil : "同一個檔案在兩個地方各被改了一次，所以沒有自動覆蓋。選一份留下，另一份會進垃圾桶，並在「舊版本」保留一份。")
        if model.snap.conflicts.isEmpty {
            Card(padding: 28) {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle").font(.system(size: 34)).foregroundStyle(Theme.ok)
                    Text("沒有待處理的衝突").font(.system(size: 16, weight: .semibold))
                    Text("兩邊都改過同一個檔案時，會出現在這裡，由你決定留哪一份。").font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        ForEach(model.snap.conflicts) { c in ConflictCard(model: model, c: c) }
        if !model.snap.duplicateHints.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("可能的雲端衝突副本").font(.system(size: 16, weight: .bold))
                Text("iCloud 或 Google Drive 在兩台裝置都修改同一個檔案時，會自己產生「檔名 2」或「檔名 (1)」這樣的副本。以下檔案看起來像這種情況；它們會正常同步，不會自動刪除，請自己確認要留哪一個。")
                    .font(.system(size: 13)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                Card(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(model.snap.duplicateHints.prefix(30).enumerated()), id: \.element.id) { i, h in
                            if i > 0 { Divider() }
                            HStack {
                                Image(systemName: "doc.on.doc").foregroundStyle(.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text((h.path as NSString).lastPathComponent).font(.system(size: 14, weight: .semibold))
                                    Text("與「\((h.basePath as NSString).lastPathComponent)」內容不同　· \(h.endpoint)").font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("在 Finder 顯示") { model.revealInEndpoint(h.endpoint, h.path) }.buttonStyle(QuietButton(kind: .plain))
                            }
                            .padding(.horizontal, 16).padding(.vertical, 10)
                        }
                    }
                }
            }
        }
    }
}

struct ConflictCard: View {
    @ObservedObject var model: AppModel
    let c: SyncService.ConflictItem
    private func date(_ d: Date?) -> String { d?.formatted(date: .abbreviated, time: .shortened) ?? "—" }
    private var extraNewer: Bool { (c.extraModified ?? .distantPast) > (c.mainModified ?? .distantPast) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text((c.path as NSString).lastPathComponent).font(.system(size: 22, weight: .bold)).tracking(-0.3)
                Text("\(c.path)　· 發生在「\(c.endpoint)」").font(.system(size: 13)).foregroundStyle(.secondary)
            }
            HStack(alignment: .top, spacing: 16) {
                version(title: "目前的版本", note: "與其他資料夾一致", size: c.mainSize, modified: c.mainModified, newer: !extraNewer,
                        path: c.mainPath, keep: "保留這一份", primary: true) { model.resolve(c, keep: .main) }
                version(title: "「\(c.endpoint)」上的版本", note: "只在這個資料夾", size: c.extraSize, modified: c.extraModified, newer: extraNewer,
                        path: c.extraPath, keep: "改用這一份", primary: false) { model.resolve(c, keep: .conflict) }
            }
            if !c.endpointOnline {
                Label("「\(c.endpoint)」目前離線，接回後才能處理。", systemImage: "externaldrive.badge.xmark").font(.system(size: 13)).foregroundStyle(Theme.warn)
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
    }

    private func version(title: String, note: String, size: Int64?, modified: Date?, newer: Bool, path: String,
                         keep: String, primary: Bool, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 14, weight: .bold))
                if newer { Chip(text: "較新", kind: .ok) }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("\(size.map(bytes) ?? "—")　· \(date(modified))").font(.system(size: 13)).monospacedDigit()
                Text(note).font(.system(size: 12)).foregroundStyle(.secondary)
            }
            HStack {
                Button(keep, action: action).buttonStyle(QuietButton(kind: primary ? .primary : .secondary)).disabled(!c.endpointOnline)
                Button("在 Finder 顯示") { model.reveal(path) }.buttonStyle(QuietButton(kind: .plain))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.tile, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: versions

struct VersionsSection: View {
    @ObservedObject var model: AppModel
    @State private var query = ""
    @State private var confirmClear = false

    private var filtered: [VersionItem] {
        let q = query.trimmingCharacters(in: .whitespaces)
        return q.isEmpty ? model.versionItems : model.versionItems.filter { $0.path.localizedCaseInsensitiveContains(q) || $0.endpoint.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        sectionHeader("舊版本", "檔案被新版覆蓋、被刪除或被還原前，舊內容都會先存在這裡。改錯了、誤刪了，都可以一鍵還原。")
        let u = model.snap.versions
        HStack(spacing: 14) {
            StatTile(label: "已保留", value: "\(u.files)", sub: "個舊版本檔案")
            StatTile(label: "占用空間", value: bytes(u.bytes), sub: u.oldest.map { "最早從 \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "目前沒有")
        }
        Card {
            HStack(spacing: 14) {
                Text("自動清理：保留").font(.system(size: 14))
                Picker("", selection: Binding(get: { model.snap.versionsRetentionDays }, set: { model.setRetention(days: $0) })) {
                    Text("7 天").tag(7); Text("30 天").tag(30); Text("90 天").tag(90); Text("永久").tag(0)
                }
                .labelsHidden().frame(width: 100)
                Text("總量超過 20 GB 時，也會從最舊的開始清。").font(.system(size: 12)).foregroundStyle(.secondary)
                Spacer()
                Button("清理過期版本") { model.purgeVersions(.expired); model.loadVersions() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                Button("全部清除…") { confirmClear = true }.buttonStyle(QuietButton(kind: .secondary, compact: true)).disabled(u.files == 0)
            }
        }
        if model.snap.endpoints.contains(where: { $0.role == .archive }) {
            Card {
                HStack(spacing: 14) {
                    Text("備份資料夾的歷史：保留").font(.system(size: 14))
                    Picker("", selection: Binding(get: { model.snap.archiveRetentionDays }, set: { model.setArchiveRetention(days: $0) })) {
                        Text("90 天").tag(90); Text("1 年").tag(365); Text("3 年").tag(1095); Text("永久").tag(0)
                    }
                    .labelsHidden().frame(width: 100)
                    Text("存在各備份資料夾內的 .syncnexus-history。").font(.system(size: 12)).foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        HStack {
            Text("可還原的版本").font(.system(size: 16, weight: .bold))
            Spacer()
            TextField("搜尋檔名或資料夾", text: $query).textFieldStyle(.roundedBorder).frame(width: 220)
            Button("在 Finder 顯示") { model.revealVersionsFolder() }.buttonStyle(QuietButton(kind: .plain))
        }
        if filtered.isEmpty {
            Card(padding: 24) { Text(model.versionItems.isEmpty ? "目前沒有舊版本。" : "沒有符合的結果。").font(.system(size: 13)).foregroundStyle(.secondary).frame(maxWidth: .infinity) }
        } else {
            Card(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(filtered.prefix(100).enumerated()), id: \.element.id) { i, item in
                        if i > 0 { Divider() }
                        HStack(spacing: 12) {
                            Image(systemName: "doc").frame(width: 24).foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text((item.path as NSString).lastPathComponent).font(.system(size: 14, weight: .semibold)).lineLimit(1)
                                Text("\(item.endpoint)　· \(item.path)").font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                            }
                            Spacer()
                            Text("\(bytes(item.size))　\(item.stamp.formatted(date: .abbreviated, time: .shortened))").font(.system(size: 12)).foregroundStyle(.secondary).monospacedDigit()
                            Button("還原") { model.restore(item) }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }
                }
            }
            if filtered.count > 100 { Text("只顯示最新的 100 個；用搜尋縮小範圍。").font(.system(size: 12)).foregroundStyle(.secondary) }
        }
        Color.clear.frame(height: 0)
            .onAppear { model.loadVersions(); model.refreshVersions() }
            .alert("永久刪除所有舊版本？", isPresented: $confirmClear) {
                Button("全部刪除", role: .destructive) { model.purgeVersions(.all); model.loadVersions() }
                Button("取消", role: .cancel) {}
            } message: { Text("這些檔案會直接刪除，不會進垃圾桶，無法復原。同步中的正式檔案不受影響。") }
    }
}

// MARK: verification

struct VerificationSection: View {
    @ObservedObject var model: AppModel
    var body: some View {
        sectionHeader("驗證紀錄", "同步最怕「看不出來的小錯」。這裡顯示最近一次驗證的結果。")
        HStack(spacing: 14) {
            StatTile(label: "最近一次完全無誤的同步", value: model.snap.lastCleanSync?.formatted(date: .omitted, time: .shortened) ?? "尚未", sub: model.snap.lastCleanSync?.formatted(date: .abbreviated, time: .omitted) ?? "還沒有一輪沒有略過項目的同步")
            StatTile(label: "最近完整驗證", value: model.snap.lastDeepVerify?.formatted(date: .omitted, time: .shortened) ?? "尚未", sub: model.snap.lastDeepVerify?.formatted(date: .abbreviated, time: .omitted) ?? "每週自動進行一次")
            StatTile(label: "疑似損壞", value: "\(model.snap.integrityIssues.count)", sub: model.snap.integrityIssues.isEmpty ? "沒有異常" : "已隔離，不會傳播")
        }
        if !model.snap.integrityIssues.isEmpty {
            Card {
                VStack(alignment: .leading, spacing: 8) {
                    Label("內容與紀錄不符，但大小與修改時間都沒變", systemImage: "exclamationmark.triangle").font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.warn)
                    ForEach(model.snap.integrityIssues) { issue in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(issue.path)　· 在「\(issue.endpoint)」").font(.system(size: 13, weight: .semibold)).textSelection(.enabled)
                            HStack {
                                Button("用其他資料夾的版本修復") { model.repair(issue, action: .restoreFromOthers) }.buttonStyle(QuietButton(kind: .primary, compact: true))
                                Button("保留現在的內容") { model.repair(issue, action: .acceptCurrent) }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                            }
                        }
                        .padding(12).frame(maxWidth: .infinity, alignment: .leading).background(Theme.tile, in: RoundedRectangle(cornerRadius: 10))
                    }
                    Text("這些檔案已被隔離，壞掉的內容不會傳到其他資料夾；其他資料夾仍持有正確的版本。「修復」會把壞掉的內容存進舊版本，再放回正確的。").font(.system(size: 12)).foregroundStyle(.secondary)
                }
            }
        }
        Card {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("立即完整驗證").font(.system(size: 14, weight: .bold))
                    Text("重新讀取每一個檔案並核對 SHA-256。檔案很多時會花一些時間。").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                Button("開始驗證") { model.verifyNow() }.buttonStyle(QuietButton(kind: .primary))
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("保護機制").font(.system(size: 14, weight: .bold))
                ForEach(["每次複製都核對 SHA-256，外接磁碟寫入後繞過快取重新讀回比對", "刪除與覆蓋前先存舊版本，再進垃圾桶", "資料夾消失、換碟、一半以上檔案同時消失時，停止並等你確認，不會傳播刪除",
                         "同步狀態資料庫每天備份（保留 7 份），損壞時自動還原"], id: \.self) { t in
                    Label { Text(t).font(.system(size: 13)) } icon: { Image(systemName: "checkmark").foregroundStyle(Theme.ok) }
                }
            }
        }
    }
}

// MARK: settings

struct SettingsSection: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @State private var fullDisk = Permissions.hasFullDiskAccess()

    var body: some View {
        sectionHeader("設定")
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("同一個檔案兩邊都被修改時").font(.system(size: 15, weight: .bold))
                Picker("", selection: Binding(get: { model.snap.conflictPolicy }, set: { model.setPolicy($0) })) {
                    Text("保留兩份，由我挑選（預設）").tag(ConflictPolicy.keepBoth)
                    Text("自動採用較新的，舊的存進舊版本").tag(ConflictPolicy.newerWins)
                }
                .pickerStyle(.radioGroup).labelsHidden()
                Text(model.snap.conflictPolicy == .keepBoth
                     ? "原檔會和其他資料夾保持一致；另一份加上「(conflict …)」標記，只留在發生衝突的資料夾，不會再同步出去，直到你在「衝突」頁選擇。"
                     : "以檔案修改時間判斷。兩邊時間相差 2 秒內、或無法判斷時，仍會保留兩份。不同電腦的時鐘若不準，可能選錯；舊版一律存入舊版本，隨時可以還原。")
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("不要同步這些項目").font(.system(size: 15, weight: .bold))
                ForEach(ExcludePreset.allCases) { p in
                    Toggle(isOn: Binding(get: { model.snap.excludePresets.contains(p) }, set: { model.setExclude(p, on: $0) })) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.title).font(.system(size: 13, weight: .semibold))
                            Text(p.why).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(.switch)
                }
                Text("被排除的項目在所有資料夾裡都原封不動：之前已經同步過的不會被刪除，之後也不再同步。").font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Toggle("開機自動啟動", isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) })).toggleStyle(.switch)
                if let n = model.loginNote { Text(n).font(.system(size: 12)).foregroundStyle(Theme.warn) }
                Divider()
                HStack {
                    Image(systemName: fullDisk ? "checkmark.circle.fill" : "exclamationmark.circle.fill").foregroundStyle(fullDisk ? Theme.ok : Theme.warn)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("完整磁碟取用權限").font(.system(size: 14, weight: .semibold))
                        Text(fullDisk ? "已授權" : "未授權：iCloud 雲碟裡的刪除會失敗。授權後需要重新啟動 App。").font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !fullDisk {
                        Button("開啟系統設定") { Permissions.openFullDiskAccessSettings() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                        Button("重新啟動") { Permissions.relaunch() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                    }
                }
            }
        }
        Card {
            HStack(spacing: 18) {
                Button("開啟紀錄檔") { model.openLog() }.buttonStyle(QuietButton(kind: .plain))
                Button("使用說明與授權檢查") { openWindow(id: "welcome"); NSApp.activate(ignoringOtherApps: true) }.buttonStyle(QuietButton(kind: .plain))
                Spacer()
                Text("Sync-Nexus　© B&B Co.　Apache-2.0").font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
        Color.clear.frame(height: 0).onAppear { fullDisk = Permissions.hasFullDiskAccess() }
    }
}
