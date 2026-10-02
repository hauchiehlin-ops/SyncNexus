import AppKit
import ServiceManagement
import SwiftUI
import SyncCore
import UserNotifications

enum Permissions {
    /// Full Disk Access cannot be queried directly; reading a folder only it can open is the usual probe.
    static func hasFullDiskAccess() -> Bool {
        let home = NSHomeDirectory()
        for dir in ["/Library/Safari", "/Library/Mail", "/Library/Messages"] {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: home + dir, isDirectory: &isDir), isDir.boolValue {
                return (try? FileManager.default.contentsOfDirectory(atPath: home + dir)) != nil
            }
        }
        return false
    }

    static func openFullDiskAccessSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
    }

    static func relaunch() {
        let path = Bundle.main.bundlePath
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/sh")
        p.arguments = ["-c", "sleep 1; /usr/bin/open -n \"\(path)\""]
        try? p.run()
        NSApp.terminate(nil)
    }
}

struct OnboardingView: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var fullDisk = Permissions.hasFullDiskAccess()
    @State private var notifications: UNAuthorizationStatus = .notDetermined
    private let last = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                ForEach(0...last, id: \.self) { i in
                    Capsule().fill(i <= step ? Color.accentColor : Color.secondary.opacity(0.25)).frame(height: 4)
                }
            }
            Group {
                switch step {
                case 0: welcome
                case 1: permissions
                case 2: folders
                default: done
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
            HStack {
                if step > 0 { Button("上一步") { step -= 1 } }
                Spacer()
                if step < last { Button(step == 0 ? "開始設定" : "下一步") { step += 1 }.keyboardShortcut(.defaultAction) }
                else { Button("完成") { finish() }.keyboardShortcut(.defaultAction) }
            }
        }
        .padding(24)
        .frame(width: 560, height: 470)
        .onAppear { refresh() }
        .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in refresh() }
    }

    private func refresh() {
        fullDisk = Permissions.hasFullDiskAccess()
        UNUserNotificationCenter.current().getNotificationSettings { s in
            DispatchQueue.main.async { notifications = s.authorizationStatus }
        }
        model.refreshLoginState()
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "onboardingDone")
        dismiss()
    }

    // MARK: pages

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 72, height: 72)
            Text("歡迎使用 Sync-Nexus").font(.title.bold())
            Text("讓你指定的幾個資料夾 —— 本機、iCloud 雲碟、Google Drive、外接磁碟 —— 互相保持一致。")
            VStack(alignment: .leading, spacing: 8) {
                bullet("arrow.left.arrow.right", "任何一個資料夾有新增、修改、刪除或改名，其他的都會跟著變。")
                bullet("externaldrive", "外接磁碟可以隨時拔除、到別台電腦修改；接回來會自動對帳，不會被當成「檔案全被刪除」。")
                bullet("trash", "刪除的檔案先進垃圾桶，被取代的舊版本另存一份，改錯了都能找回。")
                bullet("exclamationmark.triangle", "同一個檔案兩邊都被修改時不會悄悄覆蓋，由你決定留哪一份。")
            }
            .font(.callout)
        }
    }

    private var permissions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("需要的授權").font(.title2.bold())
            Text("為了能讀寫 iCloud 雲碟、外接磁碟並把檔案移到垃圾桶，需要你在系統設定裡授權。")
                .font(.callout).foregroundStyle(.secondary)
            permissionRow(ok: fullDisk, title: "完整磁碟取用權限", detail: "必要。沒有它就無法處理 iCloud 雲碟裡的刪除。授權後需要重新啟動 App。") {
                HStack {
                    Button("開啟系統設定") { Permissions.openFullDiskAccessSettings() }
                    if !fullDisk { Button("已授權，重新啟動") { Permissions.relaunch() } }
                }
            }
            permissionRow(ok: notifications == .authorized, title: "通知", detail: "建議。有衝突或需要你確認時會提醒你。") {
                if notifications == .denied { Button("開啟通知設定") { NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension")!) } }
            }
            permissionRow(ok: model.launchAtLogin, title: "開機自動啟動", detail: "建議。同步要一直在背景執行才有用。") {
                Toggle("", isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) })).labelsHidden()
            }
            Text("打開「完整磁碟取用權限」時，清單裡找不到 Sync-Nexus 的話，按「+」選擇 ~/Applications/SyncNexus.app。")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var folders: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("選擇要同步的資料夾").font(.title2.bold())
            Text("建議為每一個地方各建立一個「專用資料夾」，例如都取名叫「同步用」，再依序加入：")
            VStack(alignment: .leading, spacing: 6) {
                bullet("laptopcomputer", "本機：例如 文件 底下的一個資料夾")
                bullet("icloud", "iCloud 雲碟：在 Finder 的 iCloud 雲碟裡建立一個資料夾")
                bullet("externaldrive.badge.icloud", "Google Drive：在「我的雲端硬碟」裡建立一個資料夾")
                bullet("externaldrive", "外接磁碟：在磁碟裡建立一個資料夾")
            }
            .font(.callout)
            Text("至少加入兩個就會開始同步。第一次同步前會先列出預覽，確認後才會真的複製或刪除任何東西。")
                .font(.callout).foregroundStyle(.secondary)
            HStack {
                Button("加入資料夾…") { openWindow(id: "settings"); NSApp.activate(ignoringOtherApps: true) }
                Text("目前已加入 \(model.snap.endpoints.count) 個").foregroundStyle(.secondary)
            }
            Text("建議先拿檔案不多的資料夾試用幾天，確定符合預期再換成真正的資料。").font(.callout).foregroundStyle(.orange)
        }
    }

    private var done: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("設定完成").font(.title2.bold())
            Text("Sync-Nexus 會留在選單列右上角，圖示的狀態代表：")
            VStack(alignment: .leading, spacing: 6) {
                bullet("arrow.triangle.2.circlepath", "正常，自動同步中")
                bullet("pause.circle", "已暫停")
                bullet("exclamationmark.arrow.triangle.2.circlepath", "需要你處理：確認預覽、解決衝突，或發生錯誤")
                bullet("arrow.triangle.2.circlepath.circle", "有資料夾離線（例如外接磁碟被拔除），接回後自動繼續")
            }
            .font(.callout)
            Text("點選圖示可以查看狀態、立即同步、暫停，或打開「設定端點」管理資料夾、衝突和舊版本。")
                .font(.callout).foregroundStyle(.secondary)
        }
    }

    private func bullet(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol).frame(width: 20).foregroundStyle(Color.accentColor)
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func permissionRow<Trailing: View>(ok: Bool, title: String, detail: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: ok ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(ok ? Color.green : Color.orange).font(.title3)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                trailing()
            }
            Spacer()
        }
        .padding(10)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }
}
