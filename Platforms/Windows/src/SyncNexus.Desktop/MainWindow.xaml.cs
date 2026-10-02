using System.Windows;
using SyncNexus.Desktop.ViewModels;

namespace SyncNexus.Desktop;

public partial class MainWindow : Window
{
    public MainWindow(MainViewModel viewModel)
    {
        InitializeComponent();
        DataContext = viewModel;
    }
}
