using System.IO;
using System.Windows;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;
using SyncNexus.Desktop.Localization;

namespace SyncNexus.Desktop.Views;

public partial class ConflictsWindow : Window
{
    private readonly IStore _store;

    public ConflictsWindow(IStore store)
    {
        InitializeComponent();
        _store = store;
        var loc = LocalizationService.Instance;
        Title = loc.Get("conflicts_title");
        TxtHeader.Text = loc.Get("cf_header");
        TxtDesc.Text = loc.Get("cf_desc");
        ColEndpoint.Header = loc.Get("cf_col_endpoint");
        ColOriginal.Header = loc.Get("cf_col_original");
        ColCopy.Header = loc.Get("cf_col_copy");
        ColDetected.Header = loc.Get("cf_col_detected");
        BtnKeepMain.Content = loc.Get("cf_keep_main_btn");
        BtnKeepConflict.Content = loc.Get("cf_keep_copy_btn");
        LoadConflicts();
    }

    private void LoadConflicts()
    {
        var conflicts = _store.GetOpenConflicts();
        ListConflicts.ItemsSource = conflicts;
    }

    private void BtnKeepMain_Click(object sender, RoutedEventArgs e)
    {
        if (ListConflicts.SelectedItem is not ConflictRecord selected)
        {
            MessageBox.Show(this, LocalizationService.Instance.Get("cf_select_first"), LocalizationService.Instance.Get("dlg_hint_title"), MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        var ep = _store.GetEndpoints().FirstOrDefault(x => x.Id == selected.Endpoint);
        if (ep != null)
        {
            var conflictFull = Path.Combine(ep.Root, selected.ConflictPath);
            if (File.Exists(conflictFull))
            {
                FileOps.MoveToTrash(conflictFull);
            }
        }

        _store.CloseConflict(selected.Id, "resolved_main");
        _store.RecordJournal("conflict-keep-main", selected.Endpoint, selected.Path, null, "done");
        LoadConflicts();
    }

    private void BtnKeepConflict_Click(object sender, RoutedEventArgs e)
    {
        if (ListConflicts.SelectedItem is not ConflictRecord selected)
        {
            MessageBox.Show(this, LocalizationService.Instance.Get("cf_select_first"), LocalizationService.Instance.Get("dlg_hint_title"), MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }

        var ep = _store.GetEndpoints().FirstOrDefault(x => x.Id == selected.Endpoint);
        if (ep != null)
        {
            var mainFull = Path.Combine(ep.Root, selected.Path);
            var conflictFull = Path.Combine(ep.Root, selected.ConflictPath);

            if (File.Exists(conflictFull))
            {
                FileOps.CopyAtomically(conflictFull, mainFull);
                FileOps.MoveToTrash(conflictFull);
            }
        }

        _store.CloseConflict(selected.Id, "resolved_conflict");
        _store.RecordJournal("conflict-keep-copy", selected.Endpoint, selected.Path, null, "done");
        LoadConflicts();
    }
}
