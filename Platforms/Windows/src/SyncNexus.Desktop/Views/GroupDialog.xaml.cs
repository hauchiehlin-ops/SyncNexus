using System.Windows;
using SyncNexus.Desktop.Localization;
using SyncNexus.Desktop.ViewModels;

namespace SyncNexus.Desktop.Views;

/// <summary>Create or edit a sync group: name (may stay empty for the language-aware default name) and icon.</summary>
public partial class GroupDialog : Window
{
    private readonly bool _allowEmptyName;

    public string ResultName { get; private set; } = string.Empty;
    public string ResultIcon { get; private set; } = "folder";

    public GroupDialog(string titleKey, string initialName, string initialIcon, bool allowEmptyName)
    {
        InitializeComponent();
        var loc = LocalizationService.Instance;
        _allowEmptyName = allowEmptyName;

        Title = loc.Get(titleKey);
        LblName.Text = loc.Get("group_name_label");
        LblIcon.Text = loc.Get("group_icon_label");
        BtnSave.Content = loc.Get("group_save");
        BtnCancel.Content = loc.Get("group_cancel");

        foreach (var key in GroupItemViewModel.IconKeys) CmbIcon.Items.Add(GroupItemViewModel.EmojiFor(key));
        var idx = GroupItemViewModel.IconKeys.ToList().IndexOf(initialIcon);
        CmbIcon.SelectedIndex = idx < 0 ? 0 : idx;
        TxtName.Text = initialName;
        TxtName.Focus();
    }

    private void BtnSave_Click(object sender, RoutedEventArgs e)
    {
        var name = TxtName.Text.Trim();
        if (name.Length == 0 && !_allowEmptyName) return;   // a named group needs text
        ResultName = name;
        ResultIcon = GroupItemViewModel.IconKeys[Math.Max(0, CmbIcon.SelectedIndex)];
        DialogResult = true;
    }

    private void BtnCancel_Click(object sender, RoutedEventArgs e) => DialogResult = false;
}
