import Foundation
import Network

public struct LocalPeer: Sendable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var host: String
    public var port: Int

    public init(id: String, name: String, host: String, port: Int) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
    }
}

/// 局域網點對點發現服務（借鏡 LocalSend 與 Syncthing 的 Zero-Config mDNS 發現）
/// 在同一個 Wi-Fi 區域網路內，自動尋找其他運行 Sync-Nexus 的 Mac 或 Android 設備。
public final class LocalPeerDiscovery: @unchecked Sendable {
    public static let shared = LocalPeerDiscovery()

    private let serviceType = "_syncnexus._tcp"
    private var browser: NWBrowser?
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "syncnexus.p2p.discovery")
    private let lock = NSLock()

    private var discoveredPeers: [String: LocalPeer] = [:]
    public var onPeersChanged: (@Sendable ([LocalPeer]) -> Void)?

    private init() {}

    public func start(deviceName: String = Host.current().localizedName ?? "Mac") {
        startListener(name: deviceName)
        startBrowser()
    }

    public func stop() {
        browser?.cancel()
        browser = nil
        listener?.cancel()
        listener = nil
        lock.lock()
        discoveredPeers.removeAll()
        lock.unlock()
    }

    private func startListener(name: String) {
        do {
            let params = NWParameters.tcp
            let l = try NWListener(service: .init(name: name, type: serviceType), using: params)
            l.stateUpdateHandler = { state in
                if case .failed(let err) = state {
                    print("[P2P] 監聽器錯誤：\(err)")
                }
            }
            l.start(queue: queue)
            self.listener = l
        } catch {
            print("[P2P] 無法啟動 Bonjour 服務監聽：\(error)")
        }
    }

    private func startBrowser() {
        let params = NWParameters()
        let b = NWBrowser(for: .bonjour(type: serviceType, domain: nil), using: params)
        b.browseResultsChangedHandler = { [weak self] results, changes in
            guard let self else { return }
            var peers: [String: LocalPeer] = [:]
            for res in results {
                if case let .service(name, _, _, _) = res.endpoint {
                    let peer = LocalPeer(id: name, name: name, host: "local", port: 53530)
                    peers[name] = peer
                }
            }
            self.lock.lock()
            self.discoveredPeers = peers
            let list = Array(peers.values)
            self.lock.unlock()
            self.onPeersChanged?(list)
        }
        b.start(queue: queue)
        self.browser = b
    }
}
