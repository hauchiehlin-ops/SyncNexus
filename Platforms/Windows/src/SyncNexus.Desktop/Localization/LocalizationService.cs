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
        ["group_default_name"] = new()
        {
            [AppLanguage.ZhHant] = "預設群組",
            [AppLanguage.ZhHans] = "默认群组",
            [AppLanguage.En] = "Default Group",
            [AppLanguage.Ja] = "デフォルトグループ",
            [AppLanguage.Ko] = "기본 그룹",
            [AppLanguage.Th] = "กลุ่มเริ่มต้น",
        },
        ["group_new_default_name"] = new()
        {
            [AppLanguage.ZhHant] = "新增群組",
            [AppLanguage.ZhHans] = "新增群组",
            [AppLanguage.En] = "New Group",
            [AppLanguage.Ja] = "新規グループ",
            [AppLanguage.Ko] = "새 그룹",
            [AppLanguage.Th] = "กลุ่มใหม่",
        },
        ["group_created_toast"] = new()
        {
            [AppLanguage.ZhHant] = "已建立同步群組「{0}」",
            [AppLanguage.ZhHans] = "已创建同步群组“{0}”",
            [AppLanguage.En] = "Sync group '{0}' created.",
            [AppLanguage.Ja] = "同期グループ「{0}」を作成しました。",
            [AppLanguage.Ko] = "'{0}' 동기화 그룹이 생성되었습니다.",
            [AppLanguage.Th] = "สร้างกลุ่มการซิงค์ '{0}' เรียบร้อยแล้ว",
        },
        ["group_deleted_toast"] = new()
        {
            [AppLanguage.ZhHant] = "已刪除同步群組「{0}」",
            [AppLanguage.ZhHans] = "已删除同步群组“{0}”",
            [AppLanguage.En] = "Sync group '{0}' deleted.",
            [AppLanguage.Ja] = "同期グループ「{0}」を削除しました。",
            [AppLanguage.Ko] = "'{0}' 동기화 그룹이 삭제되었습니다.",
            [AppLanguage.Th] = "ลบกลุ่มการซิงค์ '{0}' เรียบร้อยแล้ว",
        },
        ["group_cannot_delete_last"] = new()
        {
            [AppLanguage.ZhHant] = "無法刪除最後一個同步群組",
            [AppLanguage.ZhHans] = "无法删除最后一个同步群组",
            [AppLanguage.En] = "The last sync group cannot be deleted.",
            [AppLanguage.Ja] = "最後の同期グループは削除できません。",
            [AppLanguage.Ko] = "마지막 동기화 그룹은 삭제할 수 없습니다.",
            [AppLanguage.Th] = "ไม่สามารถลบกลุ่มการซิงค์สุดท้ายได้",
        },
        ["group_selector_title"] = new()
        {
            [AppLanguage.ZhHant] = "同步群組",
            [AppLanguage.ZhHans] = "同步群组",
            [AppLanguage.En] = "Sync groups",
            [AppLanguage.Ja] = "同期グループ",
            [AppLanguage.Ko] = "동기화 그룹",
            [AppLanguage.Th] = "กลุ่มการซิงค์",
        },
        ["group_add_button"] = new()
        {
            [AppLanguage.ZhHant] = "＋ 新增群組",
            [AppLanguage.ZhHans] = "＋ 新增群组",
            [AppLanguage.En] = "＋ New group",
            [AppLanguage.Ja] = "＋ 新規グループ",
            [AppLanguage.Ko] = "＋ 새 그룹",
            [AppLanguage.Th] = "＋ กลุ่มใหม่",
        },
        ["group_add_title"] = new()
        {
            [AppLanguage.ZhHant] = "新增同步群組",
            [AppLanguage.ZhHans] = "新增同步群组",
            [AppLanguage.En] = "New sync group",
            [AppLanguage.Ja] = "新しい同期グループ",
            [AppLanguage.Ko] = "새 동기화 그룹",
            [AppLanguage.Th] = "กลุ่มการซิงค์ใหม่",
        },
        ["group_edit_title"] = new()
        {
            [AppLanguage.ZhHant] = "編輯群組",
            [AppLanguage.ZhHans] = "编辑群组",
            [AppLanguage.En] = "Edit group",
            [AppLanguage.Ja] = "グループを編集",
            [AppLanguage.Ko] = "그룹 편집",
            [AppLanguage.Th] = "แก้ไขกลุ่ม",
        },
        ["group_delete_button"] = new()
        {
            [AppLanguage.ZhHant] = "刪除群組",
            [AppLanguage.ZhHans] = "删除群组",
            [AppLanguage.En] = "Delete group",
            [AppLanguage.Ja] = "グループを削除",
            [AppLanguage.Ko] = "그룹 삭제",
            [AppLanguage.Th] = "ลบกลุ่ม",
        },
        ["group_name_label"] = new()
        {
            [AppLanguage.ZhHant] = "群組名稱（留空則使用預設名稱）：",
            [AppLanguage.ZhHans] = "群组名称（留空则使用默认名称）：",
            [AppLanguage.En] = "Group name (leave empty for the default name):",
            [AppLanguage.Ja] = "グループ名（空欄なら既定の名前）：",
            [AppLanguage.Ko] = "그룹 이름(비우면 기본 이름 사용):",
            [AppLanguage.Th] = "ชื่อกลุ่ม (เว้นว่างเพื่อใช้ชื่อเริ่มต้น):",
        },
        ["group_icon_label"] = new()
        {
            [AppLanguage.ZhHant] = "代表圖示：",
            [AppLanguage.ZhHans] = "代表图标：",
            [AppLanguage.En] = "Icon:",
            [AppLanguage.Ja] = "アイコン：",
            [AppLanguage.Ko] = "아이콘:",
            [AppLanguage.Th] = "ไอคอน:",
        },
        ["group_save"] = new()
        {
            [AppLanguage.ZhHant] = "儲存",
            [AppLanguage.ZhHans] = "保存",
            [AppLanguage.En] = "Save",
            [AppLanguage.Ja] = "保存",
            [AppLanguage.Ko] = "저장",
            [AppLanguage.Th] = "บันทึก",
        },
        ["group_cancel"] = new()
        {
            [AppLanguage.ZhHant] = "取消",
            [AppLanguage.ZhHans] = "取消",
            [AppLanguage.En] = "Cancel",
            [AppLanguage.Ja] = "キャンセル",
            [AppLanguage.Ko] = "취소",
            [AppLanguage.Th] = "ยกเลิก",
        },
        ["group_delete_confirm_title"] = new()
        {
            [AppLanguage.ZhHant] = "要刪除同步群組「{0}」嗎？",
            [AppLanguage.ZhHans] = "要删除同步群组“{0}”吗？",
            [AppLanguage.En] = "Delete sync group '{0}'?",
            [AppLanguage.Ja] = "同期グループ「{0}」を削除しますか？",
            [AppLanguage.Ko] = "'{0}' 동기화 그룹을 삭제할까요?",
            [AppLanguage.Th] = "ลบกลุ่มการซิงค์ '{0}' หรือไม่?",
        },
        ["group_delete_confirm_desc"] = new()
        {
            [AppLanguage.ZhHant] = "資料夾內的實體檔案完整保留，僅移除本群組的設定。",
            [AppLanguage.ZhHans] = "文件夹内的实体文件完整保留，仅移除本群组的设置。",
            [AppLanguage.En] = "Files in the folders stay untouched. Only this group's settings are removed.",
            [AppLanguage.Ja] = "フォルダ内のファイルはそのまま残ります。このグループの設定だけが削除されます。",
            [AppLanguage.Ko] = "폴더 안의 파일은 그대로 유지되며 이 그룹의 설정만 삭제됩니다.",
            [AppLanguage.Th] = "ไฟล์ในโฟลเดอร์จะยังอยู่ครบ จะลบเฉพาะการตั้งค่าของกลุ่มนี้",
        },
        ["group_folder_in_use"] = new()
        {
            [AppLanguage.ZhHant] = "此資料夾已被群組「{0}」使用，同一個資料夾不能屬於兩個群組。",
            [AppLanguage.ZhHans] = "此文件夹已被群组“{0}”使用，同一个文件夹不能属于两个群组。",
            [AppLanguage.En] = "This folder is already used by group '{0}'. The same folder cannot belong to two groups.",
            [AppLanguage.Ja] = "このフォルダはすでにグループ「{0}」で使われています。同じフォルダを 2 つのグループに入れることはできません。",
            [AppLanguage.Ko] = "이 폴더는 이미 '{0}' 그룹에서 사용 중입니다. 같은 폴더를 두 그룹에 넣을 수 없습니다.",
            [AppLanguage.Th] = "โฟลเดอร์นี้ถูกใช้โดยกลุ่ม '{0}' แล้ว โฟลเดอร์เดียวกันอยู่ในสองกลุ่มไม่ได้",
        },
        ["backup_restore_menu"] = new()
        {
            [AppLanguage.ZhHant] = "從備份還原",
            [AppLanguage.ZhHans] = "从备份还原",
            [AppLanguage.En] = "Restore backup",
            [AppLanguage.Ja] = "バックアップから復元",
            [AppLanguage.Ko] = "백업에서 복원",
            [AppLanguage.Th] = "กู้คืนจากข้อมูลสำรอง",
        },
        ["backup_none"] = new()
        {
            [AppLanguage.ZhHant] = "尚無備份",
            [AppLanguage.ZhHans] = "暂无备份",
            [AppLanguage.En] = "No backups yet",
            [AppLanguage.Ja] = "バックアップはまだありません",
            [AppLanguage.Ko] = "백업 없음",
            [AppLanguage.Th] = "ยังไม่มีข้อมูลสำรอง",
        },
        ["backup_restore_confirm_title"] = new()
        {
            [AppLanguage.ZhHant] = "要還原 {0} 的備份嗎？",
            [AppLanguage.ZhHans] = "要还原 {0} 的备份吗？",
            [AppLanguage.En] = "Restore the backup from {0}?",
            [AppLanguage.Ja] = "{0} のバックアップを復元しますか？",
            [AppLanguage.Ko] = "{0} 백업을 복원할까요?",
            [AppLanguage.Th] = "กู้คืนข้อมูลสำรองเมื่อ {0} หรือไม่?",
        },
        ["backup_restore_confirm_desc"] = new()
        {
            [AppLanguage.ZhHant] = "群組與資料夾設定會回到當時的狀態。還原前會先備份目前狀態，之後仍可切換回來。",
            [AppLanguage.ZhHans] = "群组与文件夹设置会回到当时的状态。还原前会先备份当前状态，之后仍可切换回来。",
            [AppLanguage.En] = "Groups and folder settings will return to that moment. The current state is backed up first, so you can switch back.",
            [AppLanguage.Ja] = "グループとフォルダ設定がその時点に戻ります。復元前に現在の状態をバックアップするので、後で戻せます。",
            [AppLanguage.Ko] = "그룹과 폴더 설정이 해당 시점으로 돌아갑니다. 복원 전에 현재 상태를 먼저 백업하므로 다시 되돌릴 수 있습니다.",
            [AppLanguage.Th] = "กลุ่มและการตั้งค่าโฟลเดอร์จะย้อนกลับไปยังขณะนั้น ระบบจะสำรองสถานะปัจจุบันก่อน จึงสามารถสลับกลับได้",
        },
        ["backup_restore_ok"] = new()
        {
            [AppLanguage.ZhHant] = "已還原 {0} 個群組、{1} 個資料夾。",
            [AppLanguage.ZhHans] = "已还原 {0} 个群组、{1} 个文件夹。",
            [AppLanguage.En] = "Restored {0} group(s) with {1} folder(s).",
            [AppLanguage.Ja] = "{0} 個のグループ（フォルダ {1} 件）を復元しました。",
            [AppLanguage.Ko] = "{0}개 그룹(폴더 {1}개)을 복원했습니다.",
            [AppLanguage.Th] = "กู้คืน {0} กลุ่ม {1} โฟลเดอร์แล้ว",
        },
        ["import_legacy_button"] = new()
        {
            [AppLanguage.ZhHant] = "匯入舊設定",
            [AppLanguage.ZhHans] = "导入旧设置",
            [AppLanguage.En] = "Import old settings",
            [AppLanguage.Ja] = "旧設定を読み込む",
            [AppLanguage.Ko] = "이전 설정 가져오기",
            [AppLanguage.Th] = "นำเข้าการตั้งค่าเดิม",
        },
        ["import_legacy_prompt"] = new()
        {
            [AppLanguage.ZhHant] = "請選取舊版 SyncNexus 設定資料夾（內含 groups.json 與 state.db），例如 %LOCALAPPDATA%\\SyncNexus。",
            [AppLanguage.ZhHans] = "请选取旧版 SyncNexus 设置文件夹（内含 groups.json 与 state.db），例如 %LOCALAPPDATA%\\SyncNexus。",
            [AppLanguage.En] = "Choose the old SyncNexus settings folder (containing groups.json and state.db), e.g. %LOCALAPPDATA%\\SyncNexus.",
            [AppLanguage.Ja] = "旧 SyncNexus の設定フォルダ（groups.json と state.db を含む）を選択してください。例：%LOCALAPPDATA%\\SyncNexus",
            [AppLanguage.Ko] = "이전 SyncNexus 설정 폴더(groups.json과 state.db 포함)를 선택하세요. 예: %LOCALAPPDATA%\\SyncNexus",
            [AppLanguage.Th] = "เลือกโฟลเดอร์การตั้งค่า SyncNexus เดิม (ที่มี groups.json และ state.db) เช่น %LOCALAPPDATA%\\SyncNexus",
        },
        ["import_legacy_ok"] = new()
        {
            [AppLanguage.ZhHant] = "已匯入 {0} 個群組、{1} 個資料夾；既有群組不會被覆寫。",
            [AppLanguage.ZhHans] = "已导入 {0} 个群组、{1} 个文件夹；既有群组不会被覆盖。",
            [AppLanguage.En] = "Imported {0} group(s) with {1} folder(s). Existing groups were not overwritten.",
            [AppLanguage.Ja] = "{0} 個のグループ（フォルダ {1} 件）を読み込みました。既存のグループは上書きされません。",
            [AppLanguage.Ko] = "{0}개 그룹(폴더 {1}개)을 가져왔습니다. 기존 그룹은 덮어쓰지 않습니다.",
            [AppLanguage.Th] = "นำเข้า {0} กลุ่ม {1} โฟลเดอร์ กลุ่มที่มีอยู่จะไม่ถูกเขียนทับ",
        },
        ["import_legacy_nothing_new"] = new()
        {
            [AppLanguage.ZhHant] = "沒有需要匯入的項目：該資料夾內的群組在此已設定完成。",
            [AppLanguage.ZhHans] = "没有需要导入的项目：该文件夹内的群组在此已设置完成。",
            [AppLanguage.En] = "Nothing to import: the groups in that folder are already configured here.",
            [AppLanguage.Ja] = "読み込む項目がありません。そのフォルダのグループはすでに設定済みです。",
            [AppLanguage.Ko] = "가져올 항목이 없습니다. 해당 폴더의 그룹은 이미 설정되어 있습니다.",
            [AppLanguage.Th] = "ไม่มีรายการที่ต้องนำเข้า: กลุ่มในโฟลเดอร์นั้นถูกตั้งค่าไว้แล้ว",
        },
        ["import_legacy_not_found"] = new()
        {
            [AppLanguage.ZhHant] = "在該資料夾中找不到 SyncNexus 設定（缺少 groups.json / state.db）。",
            [AppLanguage.ZhHans] = "在该文件夹中找不到 SyncNexus 设置（缺少 groups.json / state.db）。",
            [AppLanguage.En] = "No SyncNexus settings found in that folder (groups.json / state.db missing).",
            [AppLanguage.Ja] = "そのフォルダに SyncNexus の設定が見つかりません（groups.json / state.db がありません）。",
            [AppLanguage.Ko] = "해당 폴더에서 SyncNexus 설정을 찾을 수 없습니다(groups.json / state.db 없음).",
            [AppLanguage.Th] = "ไม่พบการตั้งค่า SyncNexus ในโฟลเดอร์นั้น (ไม่มี groups.json / state.db)",
        },
        ["import_legacy_failed"] = new()
        {
            [AppLanguage.ZhHant] = "操作失敗：{0}",
            [AppLanguage.ZhHans] = "操作失败：{0}",
            [AppLanguage.En] = "Failed: {0}",
            [AppLanguage.Ja] = "失敗しました：{0}",
            [AppLanguage.Ko] = "실패: {0}",
            [AppLanguage.Th] = "ไม่สำเร็จ: {0}",
        },
        ["folder_nested_in_group"] = new()
        {
            [AppLanguage.ZhHant] = "此資料夾與本群組內另一個資料夾重疊（其中一個位於另一個的內部），會造成重複同步。",
            [AppLanguage.ZhHans] = "此文件夹与本群组内另一个文件夹重叠（其中一个位于另一个内部），会造成重复同步。",
            [AppLanguage.En] = "This folder overlaps with another folder of this group (one lies inside the other), which would sync twice.",
            [AppLanguage.Ja] = "このフォルダは、このグループ内の別のフォルダと重なっています（一方が他方の中にあります）。二重に同期されます。",
            [AppLanguage.Ko] = "이 폴더는 이 그룹의 다른 폴더와 겹칩니다(한쪽이 다른 쪽 안에 있음). 중복 동기화됩니다.",
            [AppLanguage.Th] = "โฟลเดอร์นี้ทับซ้อนกับอีกโฟลเดอร์ในกลุ่มนี้ (โฟลเดอร์หนึ่งอยู่ภายในอีกโฟลเดอร์) จะทำให้ซิงค์ซ้ำ",
        },
        ["tray_open_main"] = new()
        {
            [AppLanguage.ZhHant] = "開啟主視窗",
            [AppLanguage.ZhHans] = "打开主窗口",
            [AppLanguage.En] = "Open main window",
            [AppLanguage.Ja] = "メインウィンドウを開く",
            [AppLanguage.Ko] = "메인 창 열기",
            [AppLanguage.Th] = "เปิดหน้าต่างหลัก",
        },
        ["tray_sync_now"] = new()
        {
            [AppLanguage.ZhHant] = "立即對帳（所有群組）",
            [AppLanguage.ZhHans] = "立即对账（所有群组）",
            [AppLanguage.En] = "Sync now (all groups)",
            [AppLanguage.Ja] = "今すぐ同期（すべてのグループ）",
            [AppLanguage.Ko] = "지금 동기화(모든 그룹)",
            [AppLanguage.Th] = "ซิงค์ทันที (ทุกกลุ่ม)",
        },
        ["tray_exit"] = new()
        {
            [AppLanguage.ZhHant] = "結束 SyncNexus",
            [AppLanguage.ZhHans] = "退出 SyncNexus",
            [AppLanguage.En] = "Quit SyncNexus",
            [AppLanguage.Ja] = "SyncNexus を終了",
            [AppLanguage.Ko] = "SyncNexus 종료",
            [AppLanguage.Th] = "ออกจาก SyncNexus",
        },
        ["tray_open_group"] = new()
        {
            [AppLanguage.ZhHant] = "在主視窗檢視此群組",
            [AppLanguage.ZhHans] = "在主窗口查看此群组",
            [AppLanguage.En] = "View this group in the main window",
            [AppLanguage.Ja] = "メインウィンドウでこのグループを表示",
            [AppLanguage.Ko] = "메인 창에서 이 그룹 보기",
            [AppLanguage.Th] = "ดูกลุ่มนี้ในหน้าต่างหลัก",
        },
        ["tray_no_folders"] = new()
        {
            [AppLanguage.ZhHant] = "尚未加入資料夾",
            [AppLanguage.ZhHans] = "尚未添加文件夹",
            [AppLanguage.En] = "No folders yet",
            [AppLanguage.Ja] = "フォルダはまだありません",
            [AppLanguage.Ko] = "아직 폴더 없음",
            [AppLanguage.Th] = "ยังไม่มีโฟลเดอร์",
        },
        ["tray_status_ok"] = new()
        {
            [AppLanguage.ZhHant] = "全部已同步",
            [AppLanguage.ZhHans] = "全部已同步",
            [AppLanguage.En] = "All synchronized",
            [AppLanguage.Ja] = "すべて同期済み",
            [AppLanguage.Ko] = "모두 동기화됨",
            [AppLanguage.Th] = "ซิงค์ครบทั้งหมด",
        },
        ["tray_status_attention"] = new()
        {
            [AppLanguage.ZhHant] = "需要處理",
            [AppLanguage.ZhHans] = "需要处理",
            [AppLanguage.En] = "Needs attention",
            [AppLanguage.Ja] = "対応が必要",
            [AppLanguage.Ko] = "확인 필요",
            [AppLanguage.Th] = "ต้องตรวจสอบ",
        },
        ["tray_status_needs_folders"] = new()
        {
            [AppLanguage.ZhHant] = "至少加入 2 個資料夾才會開始同步",
            [AppLanguage.ZhHans] = "至少添加 2 个文件夹才会开始同步",
            [AppLanguage.En] = "Add at least 2 folders to start syncing",
            [AppLanguage.Ja] = "同期するにはフォルダを 2 つ以上追加してください",
            [AppLanguage.Ko] = "동기화하려면 폴더를 2개 이상 추가하세요",
            [AppLanguage.Th] = "เพิ่มโฟลเดอร์อย่างน้อย 2 โฟลเดอร์เพื่อเริ่มซิงค์",
        },
        ["tray_tip_attention"] = new()
        {
            [AppLanguage.ZhHant] = "{0} 個群組需要處理",
            [AppLanguage.ZhHans] = "{0} 个群组需要处理",
            [AppLanguage.En] = "{0} group(s) need attention",
            [AppLanguage.Ja] = "{0} 個のグループで対応が必要です",
            [AppLanguage.Ko] = "{0}개 그룹에 확인이 필요합니다",
            [AppLanguage.Th] = "{0} กลุ่มต้องการการตรวจสอบ",
        },
        ["tray_conflicts"] = new()
        {
            [AppLanguage.ZhHant] = "{0} 個衝突待處理",
            [AppLanguage.ZhHans] = "{0} 个冲突待处理",
            [AppLanguage.En] = "{0} conflict(s) to resolve",
            [AppLanguage.Ja] = "未解決の競合 {0} 件",
            [AppLanguage.Ko] = "해결할 충돌 {0}건",
            [AppLanguage.Th] = "ความขัดแย้งที่ต้องแก้ {0} รายการ",
        },
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

    /// <summary>Every language's text for a key (used to recognise names the app itself generated earlier).</summary>
    public IEnumerable<string> GetAllLanguages(string key) =>
        _table.TryGetValue(key, out var dict) ? dict.Values : Enumerable.Empty<string>();

    public string Get(string key, string? defaultText = null)
    {
        if (_table.TryGetValue(key, out var dict) && dict.TryGetValue(CurrentLanguage, out var val))
        {
            return val;
        }
        return defaultText ?? key;
    }
}
