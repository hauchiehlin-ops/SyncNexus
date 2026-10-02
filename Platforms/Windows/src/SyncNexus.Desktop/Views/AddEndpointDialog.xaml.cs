using System.IO;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Win32;
using SyncNexus.Core.Engine;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;

namespace SyncNexus.Desktop.Views;

public partial class AddEndpointDialog : Window
{
    public EndpointConfig? ResultConfig { get; private set; }

    private readonly List<DiscoveredCloudEndpoint> _discovered;

    public AddEndpointDialog()
    {
        InitializeComponent();

        _discovered = CloudProviderProbe.ProbeAll();
        CmbDiscovered.Items.Add("-- 請選擇或自行輸入 --");
        foreach (var d in _discovered)
        {
            CmbDiscovered.Items.Add($"{d.DisplayName} -> {d.Path}");
        }
        CmbDiscovered.SelectedIndex = 0;
    }

    private void CmbDiscovered_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (CmbDiscovered.SelectedIndex > 0 && CmbDiscovered.SelectedIndex <= _discovered.Count)
        {
            var selected = _discovered[CmbDiscovered.SelectedIndex - 1];
            TxtPath.Text = selected.Path;
            TxtEndpointId.Text = selected.Provider.ToLowerInvariant();
            CheckExistingMarker(selected.Path);
        }
    }

    private void BtnBrowse_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFolderDialog
        {
            Title = "選取同步資料夾"
        };
        if (dialog.ShowDialog(this) == true)
        {
            TxtPath.Text = dialog.FolderName;
            var dirName = Path.GetFileName(dialog.FolderName);
            if (!string.IsNullOrEmpty(dirName))
            {
                TxtEndpointId.Text = dirName.ToLowerInvariant().Replace(' ', '-');
            }
            CheckExistingMarker(dialog.FolderName);
        }
    }

    private void CheckExistingMarker(string folderPath)
    {
        if (string.IsNullOrEmpty(folderPath) || !Directory.Exists(folderPath)) return;

        var marker = Path.Combine(folderPath, SyncEngine.MarkerName);
        if (File.Exists(marker))
        {
            try
            {
                var uuid = File.ReadAllText(marker).Trim();
                TxtNotice.Text = $"💡 偵測到已有防偽標記碼（{uuid.Substring(0, Math.Min(8, uuid.Length))}...），加入後將直接認證並採用，無縫相容！";
            }
            catch { }
        }
        else
        {
            TxtNotice.Text = "";
        }
    }

    private void BtnConfirm_Click(object sender, RoutedEventArgs e)
    {
        var id = TxtEndpointId.Text.Trim();
        var path = TxtPath.Text.Trim();

        if (string.IsNullOrEmpty(id))
        {
            MessageBox.Show(this, "請輸入端點名稱", "提示", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        if (string.IsNullOrEmpty(path) || !Directory.Exists(path))
        {
            MessageBox.Show(this, "請選取有效的本機或雲端資料夾路徑", "提示", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        string uuid;
        var marker = Path.Combine(path, SyncEngine.MarkerName);
        if (File.Exists(marker))
        {
            uuid = File.ReadAllText(marker).Trim();
        }
        else
        {
            uuid = Guid.NewGuid().ToString().ToUpperInvariant();
        }

        string? volumeUuid = null;
        var isRemovable = ChkRemovable.IsChecked == true;
        if (isRemovable)
        {
            volumeUuid = WindowsVolumeHelper.GetVolumeSerialNumber(path);
        }

        ResultConfig = new EndpointConfig(
            id: id,
            root: path,
            removable: isRemovable,
            portableNames: ChkPortable.IsChecked == true,
            uuid: uuid,
            volumeUuid: volumeUuid
        );

        DialogResult = true;
        Close();
    }

    private void BtnCancel_Click(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
        Close();
    }
}
