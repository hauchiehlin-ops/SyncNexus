using System.IO;
using System.Windows;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;

namespace SyncNexus.Desktop.Views;

public partial class ConflictsWindow : Window
{
    private readonly IStore _store;

    public ConflictsWindow(IStore store)
    {
        InitializeComponent();
        _store = store;
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
            MessageBox.Show(this, "請先選擇一項衝突記錄", "提示", MessageBoxButton.OK, MessageBoxImage.Information);
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
            MessageBox.Show(this, "請先選擇一項衝突記錄", "提示", MessageBoxButton.OK, MessageBoxImage.Information);
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
