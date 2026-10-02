using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using System.Text;

namespace SyncNexus.Desktop.Services;

public record DiscoveredPeer(string Name, string Host, int Port);

/// <summary>
/// Dual-Stack LAN Discovery Service:
/// 1. Standard Multicast DNS (mDNS) listening on 224.0.0.251:5353 for '_syncnexus._tcp.local' (macOS Bonjour & Android NSD).
/// 2. Direct UDP broadcast beacon on port 53530 for networks where IGMP multicast is filtered.
/// </summary>
public class LocalPeerDiscovery : IDisposable
{
    public const int MdnsPort = 5353;
    public const int FallbackPort = 53530;
    public const string ServiceName = "_syncnexus._tcp.local";

    private static readonly IPAddress MdnsMulticastAddress = IPAddress.Parse("224.0.0.251");

    private UdpClient? _mdnsClient;
    private UdpClient? _fallbackClient;
    private readonly CancellationTokenSource _cts = new();
    private readonly ConcurrentDictionary<string, DiscoveredPeer> _peers = new();

    public event Action<List<DiscoveredPeer>>? OnPeersChanged;

    public void Start(string? deviceName = null)
    {
        var myName = deviceName ?? $"Windows-{Environment.MachineName}";

        // 1. Initialize mDNS Socket (Port 5353)
        try
        {
            _mdnsClient = new UdpClient();
            _mdnsClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
            _mdnsClient.Client.Bind(new IPEndPoint(IPAddress.Any, MdnsPort));
            _mdnsClient.JoinMulticastGroup(MdnsMulticastAddress);

            Task.Run(() => MdnsListenLoopAsync(_cts.Token));
            Task.Run(() => MdnsAnnounceLoopAsync(myName, _cts.Token));
        }
        catch
        {
            // If another process occupies 5353 exclusively, fallback will handle it
        }

        // 2. Initialize Direct UDP Broadcast Socket (Port 53530)
        try
        {
            _fallbackClient = new UdpClient();
            _fallbackClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
            _fallbackClient.Client.Bind(new IPEndPoint(IPAddress.Any, FallbackPort));

            Task.Run(() => FallbackListenLoopAsync(_cts.Token));
            Task.Run(() => FallbackBroadcastLoopAsync(myName, _cts.Token));
        }
        catch
        {
            // Suppress fallback socket error
        }
    }

    private async Task MdnsListenLoopAsync(CancellationToken ct)
    {
        if (_mdnsClient == null) return;
        while (!ct.IsCancellationRequested)
        {
            try
            {
                var result = await _mdnsClient.ReceiveAsync(ct);
                var buffer = result.Buffer;
                var text = Encoding.UTF8.GetString(buffer);

                // Check for SyncNexus service string in mDNS payload
                if (text.Contains("_syncnexus._tcp"))
                {
                    var host = result.RemoteEndPoint.Address.ToString();
                    var peerName = ExtractDeviceName(text) ?? $"Peer-{host}";
                    AddOrUpdatePeer(peerName, host, MdnsPort);
                }
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch
            {
                // Transient socket read timeout/error
            }
        }
    }

    private async Task MdnsAnnounceLoopAsync(string deviceName, CancellationToken ct)
    {
        if (_mdnsClient == null) return;
        var packet = BuildMdnsAnnouncement(deviceName);
        var target = new IPEndPoint(MdnsMulticastAddress, MdnsPort);

        while (!ct.IsCancellationRequested)
        {
            try
            {
                await _mdnsClient.SendAsync(packet, packet.Length, target);
                await Task.Delay(TimeSpan.FromSeconds(15), ct);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch
            {
                await Task.Delay(TimeSpan.FromSeconds(10), ct);
            }
        }
    }

    private async Task FallbackListenLoopAsync(CancellationToken ct)
    {
        if (_fallbackClient == null) return;
        while (!ct.IsCancellationRequested)
        {
            try
            {
                var result = await _fallbackClient.ReceiveAsync(ct);
                var message = Encoding.UTF8.GetString(result.Buffer);

                if (message.StartsWith("SYNCNEXUS_BEACON:"))
                {
                    var host = result.RemoteEndPoint.Address.ToString();
                    var name = message.Substring("SYNCNEXUS_BEACON:".Length).Trim();
                    AddOrUpdatePeer(name, host, FallbackPort);
                }
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch
            {
                // Transient network error
            }
        }
    }

    private async Task FallbackBroadcastLoopAsync(string deviceName, CancellationToken ct)
    {
        if (_fallbackClient == null) return;
        var bytes = Encoding.UTF8.GetBytes($"SYNCNEXUS_BEACON:{deviceName}");
        var broadcastEp = new IPEndPoint(IPAddress.Broadcast, FallbackPort);

        while (!ct.IsCancellationRequested)
        {
            try
            {
                await _fallbackClient.SendAsync(bytes, bytes.Length, broadcastEp);
                await Task.Delay(TimeSpan.FromSeconds(10), ct);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch
            {
                await Task.Delay(TimeSpan.FromSeconds(5), ct);
            }
        }
    }

    private void AddOrUpdatePeer(string name, string host, int port)
    {
        var key = $"{name}@{host}";
        var peer = new DiscoveredPeer(name, host, port);
        if (_peers.TryAdd(key, peer) || _peers[key] != peer)
        {
            _peers[key] = peer;
            OnPeersChanged?.Invoke(_peers.Values.ToList());
        }
    }

    private static string? ExtractDeviceName(string text)
    {
        var idx = text.IndexOf("name=", StringComparison.OrdinalIgnoreCase);
        if (idx >= 0)
        {
            var end = text.IndexOfAny(new[] { '\0', '\n', '\r', ' ' }, idx);
            var raw = end > idx ? text[idx..end] : text[idx..];
            return raw.Replace("name=", "", StringComparison.OrdinalIgnoreCase);
        }
        return null;
    }

    /// <summary>
    /// Builds standard DNS-SD mDNS query/announcement packet containing _syncnexus._tcp.local.
    /// </summary>
    private static byte[] BuildMdnsAnnouncement(string deviceName)
    {
        using var ms = new MemoryStream();
        using var bw = new BinaryWriter(ms);

        // Header: ID=0, Flags=0x8400 (Authoritative Response), Questions=0, Answers=1
        bw.Write((ushort)0);
        bw.Write((ushort)0x8400);
        bw.Write((ushort)0);
        bw.Write((ushort)1);
        bw.Write((ushort)0);
        bw.Write((ushort)0);

        // Name: _syncnexus._tcp.local
        WriteDnsName(bw, "_syncnexus._tcp.local");

        // Type: PTR (12), Class: IN (1), TTL: 120s
        bw.Write((ushort)12);
        bw.Write((ushort)1);
        bw.Write((uint)120);

        // RDATA: deviceName._syncnexus._tcp.local
        var rdataStream = new MemoryStream();
        var rdataWriter = new BinaryWriter(rdataStream);
        WriteDnsName(rdataWriter, $"{deviceName}._syncnexus._tcp.local");
        var rdataBytes = rdataStream.ToArray();

        bw.Write((ushort)rdataBytes.Length);
        bw.Write(rdataBytes);

        return ms.ToArray();
    }

    private static void WriteDnsName(BinaryWriter bw, string fqdn)
    {
        var parts = fqdn.Split('.', StringSplitOptions.RemoveEmptyEntries);
        foreach (var p in parts)
        {
            var bytes = Encoding.UTF8.GetBytes(p);
            bw.Write((byte)bytes.Length);
            bw.Write(bytes);
        }
        bw.Write((byte)0);
    }

    public void Stop()
    {
        _cts.Cancel();
        _mdnsClient?.Close();
        _fallbackClient?.Close();
    }

    public void Dispose()
    {
        Stop();
        _cts.Dispose();
        _mdnsClient?.Dispose();
        _fallbackClient?.Dispose();
    }
}
