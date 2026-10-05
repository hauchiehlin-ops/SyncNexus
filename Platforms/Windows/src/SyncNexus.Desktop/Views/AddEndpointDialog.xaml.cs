using System.IO;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Win32;
using SyncNexus.Core.Engine;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Desktop.Localization;

namespace SyncNexus.Desktop.Views;

public partial class AddEndpointDialog : Window
{
    public EndpointConfig? ResultConfig { get; private set; }

    private readonly List<DiscoveredCloudEndpoint> _discovered;

    public AddEndpointDialog()
    {
        InitializeComponent();

        var loc = LocalizationService.Instance;
        Title = loc.Get("add_endpoint");
        TxtHeader.Text = loc.Get("dlg_add_header");
        LblName.Text = loc.Get("dlg_ep_name");
        LblPath.Text = loc.Get("dlg_ep_path");
        BtnBrowse.Content = loc.Get("dlg_browse");
        LblDiscovered.Text = loc.Get("dlg_discovered");
        ChkRemovable.Content = loc.Get("dlg_removable");
        ChkPortable.Content = loc.Get("dlg_portable");
        BtnCancel.Content = loc.Get("group_cancel");
        BtnConfirm.Content = loc.Get("dlg_confirm_add");

        _discovered = CloudProviderProbe.ProbeAll();
        CmbDiscovered.Items.Add(LocalizationService.Instance.Get("dlg_discovered_placeholder"));
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
            Title = LocalizationService.Instance.Get("dlg_pick_folder")
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
                TxtNotice.Text = string.Format(LocalizationService.Instance.Get("dlg_marker_notice"), uuid.Substring(0, Math.Min(8, uuid.Length)));
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
            MessageBox.Show(this, LocalizationService.Instance.Get("dlg_need_name"), LocalizationService.Instance.Get("dlg_hint_title"), MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        if (string.IsNullOrEmpty(path) || !Directory.Exists(path))
        {
            MessageBox.Show(this, LocalizationService.Instance.Get("dlg_need_path"), LocalizationService.Instance.Get("dlg_hint_title"), MessageBoxButton.OK, MessageBoxImage.Warning);
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
