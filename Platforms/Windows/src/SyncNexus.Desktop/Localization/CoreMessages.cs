using System.Text.RegularExpressions;

namespace SyncNexus.Desktop.Localization;

/// <summary>
/// The engine (SyncNexus.Core) reports reasons and journal notes in Traditional Chinese. This turns the known messages into the
/// interface language; anything it does not recognise is shown unchanged.
/// </summary>
public static class CoreMessages
{
    private static readonly (Regex Pattern, string Key)[] Table =
    {
        (new Regex(@"^資料夾不存在（外接碟未掛載？）$"), "core_folder_missing"),
        (new Regex(@"^標記檔與此端點不符"), "core_marker_mismatch"),
        (new Regex(@"^無法讀取標記檔：(.*)$", RegexOptions.Singleline), "core_marker_read"),
        (new Regex(@"^標記檔遺失"), "core_marker_lost"),
        (new Regex(@"^無法寫入標記檔：(.*)$", RegexOptions.Singleline), "core_marker_write"),
        (new Regex(@"^磁碟區識別碼不符"), "core_volume_mismatch"),
        (new Regex(@"^在線端點不足 2 個"), "core_not_enough"),
        (new Regex(@"^預計刪除 (\d+) 個檔案（共追蹤 (\d+) 個）"), "core_deletion_guard"),
        (new Regex(@"^\[(.+?)\] 衝突 (.+)：本端版本保留為「(.+)」$"), "core_note_conflict"),
        (new Regex(@"^\[(.+?)\] 新增/修改 (.+)（版號 (\d+)）$"), "core_note_changed"),
        (new Regex(@"^\[(.+?)\] 刪除 (.+)（版號 (\d+)）$"), "core_note_deleted"),
        (new Regex(@"^\[(.+?)\] 移到資源回收筒 (.+)$"), "core_note_trash"),
        (new Regex(@"^\[(.+?)\] 寫入 (.+)（來源：(.+)）$"), "core_note_write"),
        (new Regex(@"^\[(.+?)\] (.+)：目前無其他在線端點持有有效副本，稍後重試$"), "core_note_nohost"),
        (new Regex(@"^無法獲取同步鎖定（(.+?)）"), "core_lock_timeout"),
    };

    public static string Localize(string? message)
    {
        if (string.IsNullOrEmpty(message)) return message ?? string.Empty;
        var loc = LocalizationService.Instance;
        foreach (var (pattern, key) in Table)
        {
            var m = pattern.Match(message);
            if (!m.Success) continue;
            var args = m.Groups.Cast<Group>().Skip(1).Select(g => (object)g.Value).ToArray();
            return string.Format(loc.Get(key), args);
        }
        return message;
    }
}
