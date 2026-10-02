using System.Globalization;

namespace SyncNexus.Desktop.Localization;

public enum AppLanguage
{
    ZhHant,
    ZhHans,
    En,
    Ja,
    Ko,
    Th
}

public class LocalizationService
{
    public static LocalizationService Instance { get; } = new();

    public AppLanguage CurrentLanguage { get; set; } = AppLanguage.ZhHant;

    private readonly Dictionary<string, Dictionary<AppLanguage, string>> _table = new()
    {
        ["app_name"] = new()
        {
            [AppLanguage.ZhHant] = "SyncNexus",
            [AppLanguage.ZhHans] = "SyncNexus",
            [AppLanguage.En] = "SyncNexus",
            [AppLanguage.Ja] = "SyncNexus",
            [AppLanguage.Ko] = "SyncNexus",
            [AppLanguage.Th] = "SyncNexus",
        },
        ["sync_now"] = new()
        {
            [AppLanguage.ZhHant] = "立即對帳",
            [AppLanguage.ZhHans] = "立即对账",
            [AppLanguage.En] = "Sync Now",
            [AppLanguage.Ja] = "今すぐ同期",
            [AppLanguage.Ko] = "지금 동기화",
            [AppLanguage.Th] = "ซิงค์ทันที",
        },
        ["online"] = new()
        {
            [AppLanguage.ZhHant] = "在線",
            [AppLanguage.ZhHans] = "在线",
            [AppLanguage.En] = "Online",
            [AppLanguage.Ja] = "オンライン",
            [AppLanguage.Ko] = "온라인",
            [AppLanguage.Th] = "ออนไลน์",
        },
        ["offline"] = new()
        {
            [AppLanguage.ZhHant] = "離線",
            [AppLanguage.ZhHans] = "离线",
            [AppLanguage.En] = "Offline",
            [AppLanguage.Ja] = "オフライン",
            [AppLanguage.Ko] = "오프라인",
            [AppLanguage.Th] = "ออฟไลน์",
        },
        ["add_endpoint"] = new()
        {
            [AppLanguage.ZhHant] = "新增同步端點",
            [AppLanguage.ZhHans] = "新增同步端点",
            [AppLanguage.En] = "Add Sync Endpoint",
            [AppLanguage.Ja] = "エンドポイント追加",
            [AppLanguage.Ko] = "동기화 끝점 추가",
            [AppLanguage.Th] = "เพิ่มโฟลเดอร์ซิงค์",
        },
        ["conflicts_title"] = new()
        {
            [AppLanguage.ZhHant] = "衝突記錄管理",
            [AppLanguage.ZhHans] = "冲突记录管理",
            [AppLanguage.En] = "Conflict Resolution",
            [AppLanguage.Ja] = "競合の解決",
            [AppLanguage.Ko] = "충돌 해결 관리",
            [AppLanguage.Th] = "จัดการข้อขัดแย้ง",
        },
        ["keep_main"] = new()
        {
            [AppLanguage.ZhHant] = "保留主要版本",
            [AppLanguage.ZhHans] = "保留主要版本",
            [AppLanguage.En] = "Keep Main Version",
            [AppLanguage.Ja] = "メイン版を保持",
            [AppLanguage.Ko] = "기본 버전 유지",
            [AppLanguage.Th] = "เก็บเวอร์ชันหลัก",
        },
        ["keep_conflict"] = new()
        {
            [AppLanguage.ZhHant] = "保留衝突複本",
            [AppLanguage.ZhHans] = "保留冲突副本",
            [AppLanguage.En] = "Keep Conflict Copy",
            [AppLanguage.Ja] = "競合コピーを保持",
            [AppLanguage.Ko] = "충돌 사본 유지",
            [AppLanguage.Th] = "เก็บสำเนาที่ขัดแย้ง",
        }
    };

    public LocalizationService()
    {
        var currentCulture = CultureInfo.CurrentUICulture.Name;
        if (currentCulture.StartsWith("zh-TW", StringComparison.OrdinalIgnoreCase) ||
            currentCulture.StartsWith("zh-HK", StringComparison.OrdinalIgnoreCase))
        {
            CurrentLanguage = AppLanguage.ZhHant;
        }
        else if (currentCulture.StartsWith("zh", StringComparison.OrdinalIgnoreCase))
        {
            CurrentLanguage = AppLanguage.ZhHans;
        }
        else if (currentCulture.StartsWith("ja", StringComparison.OrdinalIgnoreCase))
        {
            CurrentLanguage = AppLanguage.Ja;
        }
        else if (currentCulture.StartsWith("ko", StringComparison.OrdinalIgnoreCase))
        {
            CurrentLanguage = AppLanguage.Ko;
        }
        else if (currentCulture.StartsWith("th", StringComparison.OrdinalIgnoreCase))
        {
            CurrentLanguage = AppLanguage.Th;
        }
        else
        {
            CurrentLanguage = AppLanguage.En;
        }
    }

    public string Get(string key, string? defaultText = null)
    {
        if (_table.TryGetValue(key, out var dict) && dict.TryGetValue(CurrentLanguage, out var val))
        {
            return val;
        }
        return defaultText ?? key;
    }
}
