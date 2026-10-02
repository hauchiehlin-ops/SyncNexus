using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;

namespace SyncNexus.Desktop.Services;

public record DiscoveredPeer(string Name, string Host, int Port);

/// <summary>
/// Windows LAN Peer Discovery service (compatible with macOS Bonjour and Android NSD '_syncnexus._tcp').
/// Broadcasts presence and discovers nearby active SyncNexus nodes.
/// </summary>
public class LocalPeerDiscovery : IDisposable
{
    private const int DiscoveryPort = 53530;
    private const string ServiceType = "_syncnexus._tcp";

    private readonly UdpClient _udpClient;
    private readonly CancellationTokenSource _cts = new();
    private readonly ConcurrentDictionary<string, DiscoveredPeer> _peers = new();

    public event Action<List<DiscoveredPeer>>? OnPeersChanged;

    public LocalPeerDiscovery()
    {
        _udpClient = new UdpClient();
        _udpClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
        _udpClient.Client.Bind(new IPEndPoint(IPAddress.Any, DiscoveryPort));
    }

    public void Start(string? deviceName = null)
    {
        var name = deviceName ?? $"Windows-{Environment.MachineName}";

        // Start listening
        Task.Run(() => ListenLoopAsync(_cts.Token));

        // Start broadcasting presence every 10 seconds
        Task.Run(() => BroadcastLoopAsync(name, _cts.Token));
    }

    private async Task ListenLoopAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            try
            {
                var result = await _udpClient.ReceiveAsync(ct);
                var message = Encoding.UTF8.GetString(result.Buffer);

                if (message.StartsWith("SYNCNEXUS_BEACON:"))
                {
                    var json = message.Substring("SYNCNEXUS_BEACON:".Length);
                    var info = JsonSerializer.Deserialize<Dictionary<string, string>>(json);
                    if (info != null && info.TryGetValue("name", out var peerName))
                    {
                        var host = result.RemoteEndPoint.Address.ToString();
                        var peer = new DiscoveredPeer(peerName, host, DiscoveryPort);
                        var key = $"{peerName}@{host}";

                        if (_peers.TryAdd(key, peer) || _peers[key] != peer)
                        {
                            _peers[key] = peer;
                            OnPeersChanged?.Invoke(_peers.Values.ToList());
                        }
                    }
                }
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch
            {
                // Ignore transient network errors
            }
        }
    }

    private async Task BroadcastLoopAsync(string deviceName, CancellationToken ct)
    {
        var payload = JsonSerializer.Serialize(new Dictionary<string, string>
        {
            ["name"] = deviceName,
            ["service"] = ServiceType,
            ["platform"] = "windows"
        });
        var bytes = Encoding.UTF8.GetBytes($"SYNCNEXUS_BEACON:{payload}");
        var broadcastEp = new IPEndPoint(IPAddress.Broadcast, DiscoveryPort);

        while (!ct.IsCancellationRequested)
        {
            try
            {
                await _udpClient.SendAsync(bytes, bytes.Length, broadcastEp);
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

    public void Stop()
    {
        _cts.Cancel();
        _udpClient.Close();
    }

    public void Dispose()
    {
        Stop();
        _cts.Dispose();
        _udpClient.Dispose();
    }
}
