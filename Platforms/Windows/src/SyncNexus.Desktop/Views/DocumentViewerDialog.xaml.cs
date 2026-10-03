using System.Windows;

namespace SyncNexus.Desktop.Views;

public partial class DocumentViewerDialog : Window
{
    public DocumentViewerDialog(string title, string content)
    {
        InitializeComponent();
        Title = $"SyncNexus - {title}";
        TxtDocTitle.Text = title;
        TxtDocContent.Text = content;
    }

    private void BtnClose_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
