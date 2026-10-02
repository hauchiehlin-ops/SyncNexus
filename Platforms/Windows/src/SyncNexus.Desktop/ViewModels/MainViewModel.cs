using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;

namespace SyncNexus.Desktop.ViewModels;

public partial class EndpointItemViewModel : ObservableObject
{
    [ObservableProperty] private string _id = string.Empty;
    [ObservableProperty] private string _root = string.Empty;
    [ObservableProperty] private bool _isOnline;
    [ObservableProperty] private string _statusText = "離線";
    [ObservableProperty] private string _icon = "📁";
    [ObservableProperty] private bool _isRemovable;
    [ObservableProperty] private string? _volumeUuid;

    public EndpointConfig Config { get; set; }

    public EndpointItemViewModel(EndpointConfig cfg)
    {
        Config = cfg;
        Id = cfg.Id;
        Root = cfg.Root;
        IsRemovable = cfg.Removable;
        VolumeUuid = cfg.VolumeUuid;

        if (cfg.Removable) Icon = "💾";
        else if (cfg.Root.Contains("Google", StringComparison.OrdinalIgnoreCase)) Icon = "☁️";
        else if (cfg.Root.Contains("OneDrive", StringComparison.OrdinalIgnoreCase)) Icon = "⛅";
        else Icon = "📁";
    }

    public void UpdateStatus(IdentityCheckResult result)
    {
        IsOnline = result.Status == EndpointStatus.Online;
        StatusText = IsOnline ? "在線" : (result.Reason ?? "離線");
    }
}

public partial class MainViewModel : ObservableObject
{
    private readonly IStore _store;
    private readonly SyncEngine _engine;

    [ObservableProperty] private string _appTitle = "SyncNexus (Windows)";
    [ObservableProperty] private string _statusMessage = "就緒";
    [ObservableProperty] private int _trackedFilesCount = 0;
    [ObservableProperty] private bool _isSyncing = false;

    public ObservableCollection<EndpointItemViewModel> Endpoints { get; } = new();
    public ObservableCollection<string> RecentLogs { get; } = new();

    public MainViewModel(IStore store, SyncEngine engine)
    {
        _store = store;
        _engine = engine;
        LoadEndpoints();
    }

    public void LoadEndpoints()
    {
        Endpoints.Clear();
        var configs = _store.GetEndpoints();
        foreach (var cfg in configs)
        {
            var vm = new EndpointItemViewModel(cfg);
            var status = _engine.CheckIdentity(cfg, writeMarker: false);
            vm.UpdateStatus(status);
            Endpoints.Add(vm);
        }
        TrackedFilesCount = _store.GetAllConsensus().Count(c => c.Value.State != null);
    }

    [RelayCommand]
    public async Task TriggerSyncAsync()
    {
        if (IsSyncing) return;
        IsSyncing = true;
        StatusMessage = "同步中...";

        try
        {
            var report = await Task.Run(() => _engine.SyncAll());
            LoadEndpoints();
            StatusMessage = report.IsSuccess
                ? $"同步完成（處理 {report.Actions} 項變更）"
                : $"同步完成（部分端點離線）";

            foreach (var note in report.Notes)
            {
                RecentLogs.Insert(0, note);
            }
        }
        catch (Exception ex)
        {
            StatusMessage = $"同步錯誤：{ex.Message}";
        }
        finally
        {
            IsSyncing = false;
        }
    }
}
