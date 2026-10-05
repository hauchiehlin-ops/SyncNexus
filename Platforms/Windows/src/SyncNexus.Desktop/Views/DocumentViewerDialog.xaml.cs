using System.Windows;
using SyncNexus.Desktop.Localization;

namespace SyncNexus.Desktop.Views;

public partial class DocumentViewerDialog : Window
{
    public DocumentViewerDialog(string title, string content)
    {
        InitializeComponent();
        var loc = LocalizationService.Instance;
        Title = $"SyncNexus - {title}";
        TxtDocSub.Text = loc.Get("doc_subtitle");
        BtnClose.Content = loc.Get("dlg_close");
        TxtDocTitle.Text = title;
        TxtDocContent.Text = content;
    }

    private void BtnClose_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
