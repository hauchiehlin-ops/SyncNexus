using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using System.Text.Json;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace SyncNexus.Desktop.Services;

/// <summary>
/// Gives each synced folder the icon of its sync group in Explorer: a folder with the group's symbol on it.
/// Windows shows it through a hidden desktop.ini plus a hidden icon file inside the folder; both are ignored by the
/// sync engine, so they never travel to other endpoints. A desktop.ini that this app did not write is never touched.
/// Groups with the plain folder icon leave their folders alone. Must be used from the UI thread (it draws the icon).
/// </summary>
public sealed class FolderIconService
{
    public const string IconFileName = ".syncnexus-icon.ico";

    private sealed class State
    {
        public bool Enabled { get; set; } = true;
        public Dictionary<string, string> Applied { get; set; } = new();   // folder -> symbol we put there
    }

    private readonly string _stateFile;
    private State _state = new();

    public FolderIconService(string baseDir)
    {
        _stateFile = Path.Combine(baseDir, "folder-icons.json");
        try
        {
            if (File.Exists(_stateFile))
            {
                _state = JsonSerializer.Deserialize<State>(File.ReadAllText(_stateFile)) ?? new State();
            }
        }
        catch (Exception)
        {
            _state = new State();
        }
    }

    public bool Enabled => _state.Enabled;

    public void SetEnabled(bool enabled)
    {
        _state.Enabled = enabled;
        Save();
    }

    /// <summary>
    /// Brings Explorer in line with <paramref name="desired"/> (folder path -> group symbol). Only touches what changed,
    /// and only removes icons that this app put there itself.
    /// </summary>
    public void Sync(IReadOnlyDictionary<string, string> desired)
    {
        var wanted = _state.Enabled ? desired : new Dictionary<string, string>();
        var now = new Dictionary<string, string>(_state.Applied, StringComparer.OrdinalIgnoreCase);
        var changed = false;

        foreach (var (folder, symbol) in wanted)
        {
            if (now.TryGetValue(folder, out var current) && current == symbol) continue;
            if (Apply(folder, symbol)) { now[folder] = symbol; changed = true; }
        }
        foreach (var folder in now.Keys.Where(f => !wanted.ContainsKey(f)).ToList())
        {
            Remove(folder);
            now.Remove(folder);
            changed = true;
        }

        if (changed)
        {
            _state.Applied = new Dictionary<string, string>(now);
            Save();
        }
    }

    private static bool IsOurs(string desktopIni)
    {
        try { return File.ReadAllText(desktopIni).Contains(IconFileName, StringComparison.OrdinalIgnoreCase); }
        catch (IOException) { return false; }
    }

    private static void WriteHiddenFile(string path, byte[] data)
    {
        if (File.Exists(path)) File.SetAttributes(path, FileAttributes.Normal);   // hidden / system files cannot be overwritten
        File.WriteAllBytes(path, data);
        File.SetAttributes(path, FileAttributes.Hidden | FileAttributes.System);
    }

    private static bool Apply(string folder, string emoji)
    {
        try
        {
            if (!Directory.Exists(folder)) return false;
            var ini = Path.Combine(folder, "desktop.ini");
            if (File.Exists(ini) && !IsOurs(ini)) return false;   // somebody else customised this folder

            WriteHiddenFile(Path.Combine(folder, IconFileName), RenderIco(emoji));
            WriteHiddenFile(ini, System.Text.Encoding.Unicode.GetBytes($"[.ShellClassInfo]\r\nIconResource={IconFileName},0\r\n"));
            // Explorer only honours desktop.ini on folders that are read-only or system
            File.SetAttributes(folder, File.GetAttributes(folder) | FileAttributes.ReadOnly);
            Notify(folder);
            return true;
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
        {
            return false;
        }
    }

    private static void Remove(string folder)
    {
        try
        {
            if (!Directory.Exists(folder)) return;
            var ini = Path.Combine(folder, "desktop.ini");
            if (File.Exists(ini) && IsOurs(ini))
            {
                File.SetAttributes(ini, FileAttributes.Normal);
                File.Delete(ini);
                File.SetAttributes(folder, File.GetAttributes(folder) & ~FileAttributes.ReadOnly);
            }
            var ico = Path.Combine(folder, IconFileName);
            if (File.Exists(ico))
            {
                File.SetAttributes(ico, FileAttributes.Normal);
                File.Delete(ico);
            }
            Notify(folder);
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
        {
            // best effort: a folder that cannot be cleaned simply keeps its icon
        }
    }

    /// <summary>A yellow folder with the group's symbol in its body, as a PNG-in-ICO file (256x256).</summary>
    private static byte[] RenderIco(string emoji)
    {
        const int size = 256;
        var visual = new DrawingVisual();
        using (var dc = visual.RenderOpen())
        {
            dc.DrawRoundedRectangle(new SolidColorBrush(Color.FromRgb(0xE0, 0xA8, 0x2E)), null, new Rect(16, 44, 104, 40), 10, 10);   // tab
            dc.DrawRoundedRectangle(new SolidColorBrush(Color.FromRgb(0xF4, 0xC1, 0x4E)), null, new Rect(16, 70, 224, 160), 14, 14);  // body
            var text = new FormattedText(emoji, CultureInfo.InvariantCulture, FlowDirection.LeftToRight,
                new Typeface("Segoe UI Emoji"), 96, new SolidColorBrush(Color.FromRgb(0x5A, 0x4A, 0x1E)), 1.0);
            dc.DrawText(text, new Point(size / 2.0 - text.Width / 2, 70 + (160 - text.Height) / 2));
        }
        var bitmap = new RenderTargetBitmap(size, size, 96, 96, PixelFormats.Pbgra32);
        bitmap.Render(visual);
        var encoder = new PngBitmapEncoder();
        encoder.Frames.Add(BitmapFrame.Create(bitmap));
        using var png = new MemoryStream();
        encoder.Save(png);

        using var ico = new MemoryStream();
        using (var w = new BinaryWriter(ico, System.Text.Encoding.UTF8, leaveOpen: true))
        {
            w.Write((short)0); w.Write((short)1); w.Write((short)1);                       // ICONDIR: one image
            w.Write((byte)0); w.Write((byte)0); w.Write((byte)0); w.Write((byte)0);       // 256 x 256 (stored as 0), no palette
            w.Write((short)1); w.Write((short)32);                                         // planes, bits per pixel
            w.Write((int)png.Length); w.Write(22);                                         // payload size, offset
            w.Write(png.ToArray());
        }
        return ico.ToArray();
    }

    [DllImport("shell32.dll")]
    private static extern void SHChangeNotify(int eventId, uint flags, IntPtr item1, IntPtr item2);

    /// <summary>Asks Explorer to redraw the folder (and its parent) so the new icon shows without a restart.</summary>
    private static void Notify(string folder)
    {
        const int SHCNE_UPDATEDIR = 0x00001000;
        const int SHCNE_UPDATEITEM = 0x00002000;
        const uint SHCNF_PATHW = 0x0005;
        foreach (var (evt, path) in new[] { (SHCNE_UPDATEITEM, folder), (SHCNE_UPDATEDIR, Path.GetDirectoryName(folder) ?? folder) })
        {
            var p = Marshal.StringToHGlobalUni(path);
            try { SHChangeNotify(evt, SHCNF_PATHW, p, IntPtr.Zero); }
            finally { Marshal.FreeHGlobal(p); }
        }
    }

    private void Save()
    {
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(_stateFile)!);
            File.WriteAllText(_stateFile, JsonSerializer.Serialize(_state));
        }
        catch (IOException) { /* the icons themselves are fine; the state is rebuilt on the next sync */ }
    }
}
