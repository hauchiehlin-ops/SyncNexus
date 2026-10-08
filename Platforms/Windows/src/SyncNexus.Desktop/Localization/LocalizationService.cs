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
        ["folder_icons_title"] = new()
        {
            [AppLanguage.ZhHant] = "資料夾圖示跟隨同步群組",
            [AppLanguage.ZhHans] = "文件夹图标跟随同步群组",
            [AppLanguage.En] = "Folder icons follow the sync group",
            [AppLanguage.Ja] = "フォルダのアイコンを同期グループに合わせる",
            [AppLanguage.Ko] = "폴더 아이콘을 동기화 그룹에 맞추기",
            [AppLanguage.Th] = "ไอคอนโฟลเดอร์ตามกลุ่มการซิงค์",
        },
        ["folder_icons_desc"] = new()
        {
            [AppLanguage.ZhHant] = "被同步的資料夾會在檔案總管中顯示所屬群組的圖示。這會在每個資料夾內加入隱藏的 desktop.ini 與圖示檔（不會被同步）；使用一般資料夾圖示的群組不受影響。關閉後會還原為一般圖示。",
            [AppLanguage.ZhHans] = "被同步的文件夹会在文件资源管理器中显示所属群组的图标。这会在每个文件夹内添加隐藏的 desktop.ini 与图标文件（不会被同步）；使用普通文件夹图标的群组不受影响。关闭后会还原为普通图标。",
            [AppLanguage.En] = "Synced folders show their group's icon in File Explorer. This adds a hidden desktop.ini and an icon file to each folder; they are never synced. Groups with the plain folder icon are left alone. Turning this off restores the normal icons.",
            [AppLanguage.Ja] = "同期中のフォルダに、所属グループのアイコンをエクスプローラーで表示します。各フォルダに隠しファイル desktop.ini とアイコンファイルが追加されます（同期はされません）。通常のフォルダアイコンのグループは変更されません。オフにすると元のアイコンに戻ります。",
            [AppLanguage.Ko] = "동기화 중인 폴더가 파일 탐색기에서 소속 그룹의 아이콘으로 표시됩니다. 각 폴더에 숨김 desktop.ini와 아이콘 파일이 추가되며(동기화되지 않음), 기본 폴더 아이콘을 쓰는 그룹은 그대로입니다. 끄면 원래 아이콘으로 돌아갑니다.",
            [AppLanguage.Th] = "โฟลเดอร์ที่ซิงค์จะแสดงไอคอนของกลุ่มใน File Explorer โดยจะเพิ่ม desktop.ini ที่ซ่อนและไฟล์ไอคอนในแต่ละโฟลเดอร์ (ไม่ถูกซิงค์) กลุ่มที่ใช้ไอคอนโฟลเดอร์ปกติจะไม่ถูกเปลี่ยน เมื่อปิดจะคืนไอคอนปกติ",
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
        ["nav_overview"] = new()
        {
            [AppLanguage.ZhHant] = "概覽",
            [AppLanguage.ZhHans] = "概览",
            [AppLanguage.En] = "Overview",
            [AppLanguage.Ja] = "概要",
            [AppLanguage.Ko] = "개요",
            [AppLanguage.Th] = "ภาพรวม",
        },
        ["nav_activity"] = new()
        {
            [AppLanguage.ZhHant] = "同步動態",
            [AppLanguage.ZhHans] = "同步动态",
            [AppLanguage.En] = "Sync activity",
            [AppLanguage.Ja] = "同期アクティビティ",
            [AppLanguage.Ko] = "동기화 활동",
            [AppLanguage.Th] = "กิจกรรมการซิงค์",
        },
        ["nav_conflicts"] = new()
        {
            [AppLanguage.ZhHant] = "衝突管理",
            [AppLanguage.ZhHans] = "冲突管理",
            [AppLanguage.En] = "Conflicts",
            [AppLanguage.Ja] = "競合の管理",
            [AppLanguage.Ko] = "충돌 관리",
            [AppLanguage.Th] = "จัดการข้อขัดแย้ง",
        },
        ["nav_settings"] = new()
        {
            [AppLanguage.ZhHant] = "設定",
            [AppLanguage.ZhHans] = "设置",
            [AppLanguage.En] = "Settings",
            [AppLanguage.Ja] = "設定",
            [AppLanguage.Ko] = "설정",
            [AppLanguage.Th] = "การตั้งค่า",
        },
        ["nav_manual"] = new()
        {
            [AppLanguage.ZhHant] = "操作手冊",
            [AppLanguage.ZhHans] = "操作手册",
            [AppLanguage.En] = "User manual",
            [AppLanguage.Ja] = "ユーザーマニュアル",
            [AppLanguage.Ko] = "사용 설명서",
            [AppLanguage.Th] = "คู่มือการใช้งาน",
        },
        ["nav_privacy"] = new()
        {
            [AppLanguage.ZhHant] = "隱私政策",
            [AppLanguage.ZhHans] = "隐私政策",
            [AppLanguage.En] = "Privacy policy",
            [AppLanguage.Ja] = "プライバシーポリシー",
            [AppLanguage.Ko] = "개인정보 처리방침",
            [AppLanguage.Th] = "นโยบายความเป็นส่วนตัว",
        },
        ["app_subtitle"] = new()
        {
            [AppLanguage.ZhHant] = "跨平台即時同步中心 (Windows / macOS / Android)",
            [AppLanguage.ZhHans] = "跨平台实时同步中心 (Windows / macOS / Android)",
            [AppLanguage.En] = "Cross-platform real-time sync (Windows / macOS / Android)",
            [AppLanguage.Ja] = "クロスプラットフォーム リアルタイム同期 (Windows / macOS / Android)",
            [AppLanguage.Ko] = "크로스 플랫폼 실시간 동기화 (Windows / macOS / Android)",
            [AppLanguage.Th] = "ซิงค์แบบเรียลไทม์ข้ามแพลตฟอร์ม (Windows / macOS / Android)",
        },
        ["status_tracked_files"] = new()
        {
            [AppLanguage.ZhHant] = "追蹤中檔案：",
            [AppLanguage.ZhHans] = "跟踪中文件：",
            [AppLanguage.En] = "Tracked files: ",
            [AppLanguage.Ja] = "追跡中のファイル：",
            [AppLanguage.Ko] = "추적 중인 파일: ",
            [AppLanguage.Th] = "ไฟล์ที่ติดตาม: ",
        },
        ["status_lan_label"] = new()
        {
            [AppLanguage.ZhHant] = "區域網路探索：",
            [AppLanguage.ZhHans] = "局域网发现：",
            [AppLanguage.En] = "Local network discovery: ",
            [AppLanguage.Ja] = "ローカルネットワーク検出：",
            [AppLanguage.Ko] = "로컬 네트워크 검색: ",
            [AppLanguage.Th] = "การค้นหาในเครือข่ายท้องถิ่น: ",
        },
        ["status_lan_online"] = new()
        {
            [AppLanguage.ZhHant] = "在線（相容 Mac Bonjour / Android）",
            [AppLanguage.ZhHans] = "在线（兼容 Mac Bonjour / Android）",
            [AppLanguage.En] = "Online (compatible with Mac Bonjour / Android)",
            [AppLanguage.Ja] = "オンライン（Mac Bonjour / Android 対応）",
            [AppLanguage.Ko] = "온라인 (Mac Bonjour / Android 호환)",
            [AppLanguage.Th] = "ออนไลน์ (รองรับ Mac Bonjour / Android)",
        },
        ["endpoints_header"] = new()
        {
            [AppLanguage.ZhHant] = "同步端點 (本機 / Google Drive / OneDrive / 外接磁碟)",
            [AppLanguage.ZhHans] = "同步端点 (本机 / Google Drive / OneDrive / 外接磁盘)",
            [AppLanguage.En] = "Sync endpoints (local / Google Drive / OneDrive / external drives)",
            [AppLanguage.Ja] = "同期エンドポイント（ローカル / Google Drive / OneDrive / 外付けドライブ）",
            [AppLanguage.Ko] = "동기화 엔드포인트 (로컬 / Google Drive / OneDrive / 외장 드라이브)",
            [AppLanguage.Th] = "จุดซิงค์ (ในเครื่อง / Google Drive / OneDrive / ไดรฟ์ภายนอก)",
        },
        ["autostart_title"] = new()
        {
            [AppLanguage.ZhHant] = "開機時自動於背景啟動 SyncNexus",
            [AppLanguage.ZhHans] = "开机时自动在后台启动 SyncNexus",
            [AppLanguage.En] = "Start SyncNexus in the background at sign-in",
            [AppLanguage.Ja] = "サインイン時にバックグラウンドで SyncNexus を起動",
            [AppLanguage.Ko] = "로그인 시 백그라운드에서 SyncNexus 시작",
            [AppLanguage.Th] = "เริ่ม SyncNexus ในเบื้องหลังเมื่อลงชื่อเข้าใช้",
        },
        ["daemon_running"] = new()
        {
            [AppLanguage.ZhHant] = "守護行程常駐運行中",
            [AppLanguage.ZhHans] = "守护进程常驻运行中",
            [AppLanguage.En] = "Background service is running",
            [AppLanguage.Ja] = "バックグラウンドサービス稼働中",
            [AppLanguage.Ko] = "백그라운드 서비스 실행 중",
            [AppLanguage.Th] = "บริการเบื้องหลังกำลังทำงาน",
        },
        ["footer_status"] = new()
        {
            [AppLanguage.ZhHant] = "✅ 守護行程運作中 · 支援長路徑與雲端佔位符感應 · 系統匣就緒",
            [AppLanguage.ZhHans] = "✅ 守护进程运行中 · 支持长路径与云端占位符感应 · 系统托盘就绪",
            [AppLanguage.En] = "✅ Service running · long paths and cloud placeholders supported · tray ready",
            [AppLanguage.Ja] = "✅ サービス稼働中 · 長いパスとクラウドプレースホルダーに対応 · トレイ準備完了",
            [AppLanguage.Ko] = "✅ 서비스 실행 중 · 긴 경로 및 클라우드 자리 표시자 지원 · 트레이 준비됨",
            [AppLanguage.Th] = "✅ บริการกำลังทำงาน · รองรับพาธยาวและไฟล์ตัวแทนคลาวด์ · ถาดระบบพร้อม",
        },
        ["activity_empty"] = new()
        {
            [AppLanguage.ZhHant] = "尚無同步動態",
            [AppLanguage.ZhHans] = "暂无同步动态",
            [AppLanguage.En] = "No activity yet",
            [AppLanguage.Ja] = "アクティビティはまだありません",
            [AppLanguage.Ko] = "아직 활동이 없습니다",
            [AppLanguage.Th] = "ยังไม่มีกิจกรรม",
        },
        ["language_label"] = new()
        {
            [AppLanguage.ZhHant] = "語言",
            [AppLanguage.ZhHans] = "语言",
            [AppLanguage.En] = "Language",
            [AppLanguage.Ja] = "言語",
            [AppLanguage.Ko] = "언어",
            [AppLanguage.Th] = "ภาษา",
        },
        ["sync_running"] = new()
        {
            [AppLanguage.ZhHant] = "同步中...",
            [AppLanguage.ZhHans] = "同步中...",
            [AppLanguage.En] = "Syncing...",
            [AppLanguage.Ja] = "同期中...",
            [AppLanguage.Ko] = "동기화 중...",
            [AppLanguage.Th] = "กำลังซิงค์...",
        },
        ["sync_done"] = new()
        {
            [AppLanguage.ZhHant] = "同步完成（處理 {0} 項變更）",
            [AppLanguage.ZhHans] = "同步完成（处理 {0} 项更改）",
            [AppLanguage.En] = "Sync complete ({0} changes processed)",
            [AppLanguage.Ja] = "同期が完了しました（{0} 件の変更を処理）",
            [AppLanguage.Ko] = "동기화 완료 ({0}개 변경 처리)",
            [AppLanguage.Th] = "ซิงค์เสร็จสิ้น (ประมวลผล {0} รายการ)",
        },
        ["sync_done_partial"] = new()
        {
            [AppLanguage.ZhHant] = "同步完成（部分端點離線）",
            [AppLanguage.ZhHans] = "同步完成（部分端点离线）",
            [AppLanguage.En] = "Sync complete (some endpoints offline)",
            [AppLanguage.Ja] = "同期が完了しました（一部のエンドポイントがオフライン）",
            [AppLanguage.Ko] = "동기화 완료 (일부 엔드포인트 오프라인)",
            [AppLanguage.Th] = "ซิงค์เสร็จสิ้น (บางจุดออฟไลน์)",
        },
        ["sync_error"] = new()
        {
            [AppLanguage.ZhHant] = "同步錯誤：{0}",
            [AppLanguage.ZhHans] = "同步错误：{0}",
            [AppLanguage.En] = "Sync error: {0}",
            [AppLanguage.Ja] = "同期エラー：{0}",
            [AppLanguage.Ko] = "동기화 오류: {0}",
            [AppLanguage.Th] = "ข้อผิดพลาดในการซิงค์: {0}",
        },
        ["dlg_hint_title"] = new()
        {
            [AppLanguage.ZhHant] = "提示",
            [AppLanguage.ZhHans] = "提示",
            [AppLanguage.En] = "Notice",
            [AppLanguage.Ja] = "お知らせ",
            [AppLanguage.Ko] = "알림",
            [AppLanguage.Th] = "แจ้งเตือน",
        },
        ["dlg_add_header"] = new()
        {
            [AppLanguage.ZhHant] = "設定新同步資料夾",
            [AppLanguage.ZhHans] = "设置新同步文件夹",
            [AppLanguage.En] = "Set up a new sync folder",
            [AppLanguage.Ja] = "新しい同期フォルダの設定",
            [AppLanguage.Ko] = "새 동기화 폴더 설정",
            [AppLanguage.Th] = "ตั้งค่าโฟลเดอร์ซิงค์ใหม่",
        },
        ["dlg_ep_name"] = new()
        {
            [AppLanguage.ZhHant] = "端點名稱 (識別代號)：",
            [AppLanguage.ZhHans] = "端点名称 (标识代号)：",
            [AppLanguage.En] = "Endpoint name (ID):",
            [AppLanguage.Ja] = "エンドポイント名（ID）：",
            [AppLanguage.Ko] = "엔드포인트 이름 (ID):",
            [AppLanguage.Th] = "ชื่อจุดซิงค์ (ID):",
        },
        ["dlg_ep_path"] = new()
        {
            [AppLanguage.ZhHant] = "資料夾路徑：",
            [AppLanguage.ZhHans] = "文件夹路径：",
            [AppLanguage.En] = "Folder path:",
            [AppLanguage.Ja] = "フォルダのパス：",
            [AppLanguage.Ko] = "폴더 경로:",
            [AppLanguage.Th] = "เส้นทางโฟลเดอร์:",
        },
        ["dlg_browse"] = new()
        {
            [AppLanguage.ZhHant] = "瀏覽...",
            [AppLanguage.ZhHans] = "浏览...",
            [AppLanguage.En] = "Browse...",
            [AppLanguage.Ja] = "参照...",
            [AppLanguage.Ko] = "찾아보기...",
            [AppLanguage.Th] = "เรียกดู...",
        },
        ["dlg_discovered"] = new()
        {
            [AppLanguage.ZhHant] = "快速選取探測到的雲端路徑：",
            [AppLanguage.ZhHans] = "快速选择探测到的云端路径：",
            [AppLanguage.En] = "Quick pick from detected cloud folders:",
            [AppLanguage.Ja] = "検出されたクラウドフォルダから選択：",
            [AppLanguage.Ko] = "감지된 클라우드 폴더에서 빠르게 선택:",
            [AppLanguage.Th] = "เลือกด่วนจากโฟลเดอร์คลาวด์ที่ตรวจพบ:",
        },
        ["dlg_discovered_placeholder"] = new()
        {
            [AppLanguage.ZhHant] = "-- 請選擇或自行輸入 --",
            [AppLanguage.ZhHans] = "-- 请选择或自行输入 --",
            [AppLanguage.En] = "-- Choose, or type your own --",
            [AppLanguage.Ja] = "-- 選択または入力 --",
            [AppLanguage.Ko] = "-- 선택하거나 직접 입력 --",
            [AppLanguage.Th] = "-- เลือกหรือพิมพ์เอง --",
        },
        ["dlg_removable"] = new()
        {
            [AppLanguage.ZhHant] = "可移除式磁碟（USB 隨身碟 / 外接硬碟）",
            [AppLanguage.ZhHans] = "可移动磁盘（USB 闪存盘 / 外接硬盘）",
            [AppLanguage.En] = "Removable drive (USB stick / external disk)",
            [AppLanguage.Ja] = "リムーバブルドライブ（USB メモリ / 外付けディスク）",
            [AppLanguage.Ko] = "이동식 드라이브 (USB / 외장 하드)",
            [AppLanguage.Th] = "ไดรฟ์แบบถอดได้ (USB / ฮาร์ดดิสก์ภายนอก)",
        },
        ["dlg_portable"] = new()
        {
            [AppLanguage.ZhHant] = "嚴格相容命名規範（遵循 ExFAT/Windows 命名規則）",
            [AppLanguage.ZhHans] = "严格兼容命名规范（遵循 ExFAT/Windows 命名规则）",
            [AppLanguage.En] = "Strict portable names (follow ExFAT / Windows naming rules)",
            [AppLanguage.Ja] = "厳密な互換ファイル名（ExFAT / Windows の命名規則に従う）",
            [AppLanguage.Ko] = "엄격한 호환 이름 (ExFAT / Windows 이름 규칙 준수)",
            [AppLanguage.Th] = "ชื่อไฟล์แบบเข้ากันได้เคร่งครัด (ตามกฎ ExFAT / Windows)",
        },
        ["dlg_confirm_add"] = new()
        {
            [AppLanguage.ZhHant] = "確認加入",
            [AppLanguage.ZhHans] = "确认加入",
            [AppLanguage.En] = "Add",
            [AppLanguage.Ja] = "追加",
            [AppLanguage.Ko] = "추가",
            [AppLanguage.Th] = "เพิ่ม",
        },
        ["dlg_pick_folder"] = new()
        {
            [AppLanguage.ZhHant] = "選取同步資料夾",
            [AppLanguage.ZhHans] = "选择同步文件夹",
            [AppLanguage.En] = "Choose a folder to sync",
            [AppLanguage.Ja] = "同期するフォルダを選択",
            [AppLanguage.Ko] = "동기화할 폴더 선택",
            [AppLanguage.Th] = "เลือกโฟลเดอร์ที่จะซิงค์",
        },
        ["dlg_marker_notice"] = new()
        {
            [AppLanguage.ZhHant] = "💡 偵測到已有防偽標記碼（{0}...），加入後將直接認證並採用，無縫相容！",
            [AppLanguage.ZhHans] = "💡 检测到已有防伪标记码（{0}...），加入后将直接认证并采用，无缝兼容！",
            [AppLanguage.En] = "💡 An existing endpoint marker ({0}...) was found. It will be recognized and reused, so it stays compatible.",
            [AppLanguage.Ja] = "💡 既存のエンドポイントマーカー（{0}...）が見つかりました。そのまま認識して利用します。",
            [AppLanguage.Ko] = "💡 기존 엔드포인트 표식({0}...)이 발견되었습니다. 그대로 인식하여 사용합니다.",
            [AppLanguage.Th] = "💡 พบเครื่องหมายจุดซิงค์เดิม ({0}...) จะรับรองและใช้งานต่อได้ทันที",
        },
        ["dlg_need_name"] = new()
        {
            [AppLanguage.ZhHant] = "請輸入端點名稱",
            [AppLanguage.ZhHans] = "请输入端点名称",
            [AppLanguage.En] = "Please enter an endpoint name.",
            [AppLanguage.Ja] = "エンドポイント名を入力してください。",
            [AppLanguage.Ko] = "엔드포인트 이름을 입력하세요.",
            [AppLanguage.Th] = "โปรดกรอกชื่อจุดซิงค์",
        },
        ["dlg_need_path"] = new()
        {
            [AppLanguage.ZhHant] = "請選取有效的本機或雲端資料夾路徑",
            [AppLanguage.ZhHans] = "请选择有效的本机或云端文件夹路径",
            [AppLanguage.En] = "Please choose a valid local or cloud folder.",
            [AppLanguage.Ja] = "有効なローカルまたはクラウドのフォルダを選択してください。",
            [AppLanguage.Ko] = "유효한 로컬 또는 클라우드 폴더를 선택하세요.",
            [AppLanguage.Th] = "โปรดเลือกโฟลเดอร์ในเครื่องหรือคลาวด์ที่ถูกต้อง",
        },
        ["dlg_close"] = new()
        {
            [AppLanguage.ZhHant] = "關閉",
            [AppLanguage.ZhHans] = "关闭",
            [AppLanguage.En] = "Close",
            [AppLanguage.Ja] = "閉じる",
            [AppLanguage.Ko] = "닫기",
            [AppLanguage.Th] = "ปิด",
        },
        ["doc_window_title"] = new()
        {
            [AppLanguage.ZhHant] = "SyncNexus 文件檢視",
            [AppLanguage.ZhHans] = "SyncNexus 文档查看",
            [AppLanguage.En] = "SyncNexus document viewer",
            [AppLanguage.Ja] = "SyncNexus ドキュメントビューア",
            [AppLanguage.Ko] = "SyncNexus 문서 보기",
            [AppLanguage.Th] = "ตัวดูเอกสาร SyncNexus",
        },
        ["doc_subtitle"] = new()
        {
            [AppLanguage.ZhHant] = "SyncNexus 本地優先跨平台檔案同步中心",
            [AppLanguage.ZhHans] = "SyncNexus 本地优先跨平台文件同步中心",
            [AppLanguage.En] = "SyncNexus: local-first cross-platform file sync",
            [AppLanguage.Ja] = "SyncNexus：ローカル優先のクロスプラットフォーム ファイル同期",
            [AppLanguage.Ko] = "SyncNexus: 로컬 우선 크로스 플랫폼 파일 동기화",
            [AppLanguage.Th] = "SyncNexus ศูนย์ซิงค์ไฟล์ข้ามแพลตฟอร์มแบบเน้นในเครื่อง",
        },
        ["cf_header"] = new()
        {
            [AppLanguage.ZhHant] = "未解決的檔案衝突",
            [AppLanguage.ZhHans] = "未解决的文件冲突",
            [AppLanguage.En] = "Unresolved file conflicts",
            [AppLanguage.Ja] = "未解決のファイル競合",
            [AppLanguage.Ko] = "해결되지 않은 파일 충돌",
            [AppLanguage.Th] = "ข้อขัดแย้งของไฟล์ที่ยังไม่แก้ไข",
        },
        ["cf_desc"] = new()
        {
            [AppLanguage.ZhHant] = "當多個設備同時修改相同檔案時，SyncNexus 會保留雙方版本避免覆蓋。",
            [AppLanguage.ZhHans] = "当多个设备同时修改相同文件时，SyncNexus 会保留双方版本以避免覆盖。",
            [AppLanguage.En] = "When several devices change the same file, SyncNexus keeps both versions instead of overwriting.",
            [AppLanguage.Ja] = "複数の端末が同じファイルを変更した場合、SyncNexus は上書きせず両方の版を保持します。",
            [AppLanguage.Ko] = "여러 기기에서 같은 파일을 수정하면 SyncNexus는 덮어쓰지 않고 두 버전을 모두 보관합니다.",
            [AppLanguage.Th] = "เมื่อหลายอุปกรณ์แก้ไขไฟล์เดียวกัน SyncNexus จะเก็บทั้งสองเวอร์ชันแทนการเขียนทับ",
        },
        ["cf_col_endpoint"] = new()
        {
            [AppLanguage.ZhHant] = "端點",
            [AppLanguage.ZhHans] = "端点",
            [AppLanguage.En] = "Endpoint",
            [AppLanguage.Ja] = "エンドポイント",
            [AppLanguage.Ko] = "엔드포인트",
            [AppLanguage.Th] = "จุดซิงค์",
        },
        ["cf_col_original"] = new()
        {
            [AppLanguage.ZhHant] = "原始檔案",
            [AppLanguage.ZhHans] = "原始文件",
            [AppLanguage.En] = "Original file",
            [AppLanguage.Ja] = "元のファイル",
            [AppLanguage.Ko] = "원본 파일",
            [AppLanguage.Th] = "ไฟล์ต้นฉบับ",
        },
        ["cf_col_copy"] = new()
        {
            [AppLanguage.ZhHant] = "衝突複本",
            [AppLanguage.ZhHans] = "冲突副本",
            [AppLanguage.En] = "Conflict copy",
            [AppLanguage.Ja] = "競合コピー",
            [AppLanguage.Ko] = "충돌 사본",
            [AppLanguage.Th] = "สำเนาข้อขัดแย้ง",
        },
        ["cf_col_detected"] = new()
        {
            [AppLanguage.ZhHant] = "偵測時間",
            [AppLanguage.ZhHans] = "检测时间",
            [AppLanguage.En] = "Detected",
            [AppLanguage.Ja] = "検出日時",
            [AppLanguage.Ko] = "감지 시간",
            [AppLanguage.Th] = "ตรวจพบเมื่อ",
        },
        ["cf_keep_main_btn"] = new()
        {
            [AppLanguage.ZhHant] = "保留主要版本 (丟棄衝突複本)",
            [AppLanguage.ZhHans] = "保留主要版本 (丢弃冲突副本)",
            [AppLanguage.En] = "Keep main version (discard the copy)",
            [AppLanguage.Ja] = "メイン版を保持（コピーは破棄）",
            [AppLanguage.Ko] = "기본 버전 유지 (사본 삭제)",
            [AppLanguage.Th] = "เก็บเวอร์ชันหลัก (ทิ้งสำเนา)",
        },
        ["cf_keep_copy_btn"] = new()
        {
            [AppLanguage.ZhHant] = "保留衝突複本 (覆蓋為新主版本)",
            [AppLanguage.ZhHans] = "保留冲突副本 (覆盖为新主版本)",
            [AppLanguage.En] = "Keep the conflict copy (it becomes the main version)",
            [AppLanguage.Ja] = "競合コピーを保持（新しいメイン版にする）",
            [AppLanguage.Ko] = "충돌 사본 유지 (새 기본 버전으로)",
            [AppLanguage.Th] = "เก็บสำเนาข้อขัดแย้ง (ให้เป็นเวอร์ชันหลักใหม่)",
        },
        ["cf_select_first"] = new()
        {
            [AppLanguage.ZhHant] = "請先選擇一項衝突記錄",
            [AppLanguage.ZhHans] = "请先选择一项冲突记录",
            [AppLanguage.En] = "Select a conflict first.",
            [AppLanguage.Ja] = "先に競合を 1 件選択してください。",
            [AppLanguage.Ko] = "먼저 충돌 항목을 선택하세요.",
            [AppLanguage.Th] = "โปรดเลือกรายการข้อขัดแย้งก่อน",
        },
        ["status_ready"] = new()
        {
            [AppLanguage.ZhHant] = "就緒",
            [AppLanguage.ZhHans] = "就绪",
            [AppLanguage.En] = "Ready",
            [AppLanguage.Ja] = "準備完了",
            [AppLanguage.Ko] = "준비됨",
            [AppLanguage.Th] = "พร้อม",
        },
        ["status_partial_offline"] = new()
        {
            [AppLanguage.ZhHant] = "部分端點離線",
            [AppLanguage.ZhHans] = "部分端点离线",
            [AppLanguage.En] = "Some endpoints are offline",
            [AppLanguage.Ja] = "一部のエンドポイントがオフライン",
            [AppLanguage.Ko] = "일부 엔드포인트 오프라인",
            [AppLanguage.Th] = "บางจุดซิงค์ออฟไลน์",
        },
        ["sync_running_fmt"] = new()
        {
            [AppLanguage.ZhHant] = "同步中 ({0})...",
            [AppLanguage.ZhHans] = "同步中 ({0})...",
            [AppLanguage.En] = "Syncing ({0})...",
            [AppLanguage.Ja] = "同期中 ({0})...",
            [AppLanguage.Ko] = "동기화 중 ({0})...",
            [AppLanguage.Th] = "กำลังซิงค์ ({0})...",
        },
        ["trigger_periodic"] = new()
        {
            [AppLanguage.ZhHant] = "定時排程",
            [AppLanguage.ZhHans] = "定时计划",
            [AppLanguage.En] = "scheduled",
            [AppLanguage.Ja] = "定期実行",
            [AppLanguage.Ko] = "예약 실행",
            [AppLanguage.Th] = "ตามกำหนดเวลา",
        },
        ["trigger_drive"] = new()
        {
            [AppLanguage.ZhHant] = "外接磁碟變更",
            [AppLanguage.ZhHans] = "外接磁盘变化",
            [AppLanguage.En] = "drive change",
            [AppLanguage.Ja] = "ドライブの変更",
            [AppLanguage.Ko] = "드라이브 변경",
            [AppLanguage.Th] = "ไดรฟ์เปลี่ยนแปลง",
        },
        ["trigger_structure"] = new()
        {
            [AppLanguage.ZhHant] = "檔案結構異動",
            [AppLanguage.ZhHans] = "文件结构变动",
            [AppLanguage.En] = "folder structure changed",
            [AppLanguage.Ja] = "フォルダ構造の変更",
            [AppLanguage.Ko] = "폴더 구조 변경",
            [AppLanguage.Th] = "โครงสร้างโฟลเดอร์เปลี่ยน",
        },
        ["trigger_paths"] = new()
        {
            [AppLanguage.ZhHant] = "偵測到 {0} 處檔案變更",
            [AppLanguage.ZhHans] = "检测到 {0} 处文件变更",
            [AppLanguage.En] = "{0} change(s) detected",
            [AppLanguage.Ja] = "{0} 件の変更を検出",
            [AppLanguage.Ko] = "{0}건의 변경 감지",
            [AppLanguage.Th] = "ตรวจพบการเปลี่ยนแปลง {0} รายการ",
        },
        ["trigger_added"] = new()
        {
            [AppLanguage.ZhHant] = "新增端點",
            [AppLanguage.ZhHans] = "新增端点",
            [AppLanguage.En] = "endpoint added",
            [AppLanguage.Ja] = "エンドポイント追加",
            [AppLanguage.Ko] = "엔드포인트 추가",
            [AppLanguage.Th] = "เพิ่มจุดซิงค์",
        },
        ["trigger_manual"] = new()
        {
            [AppLanguage.ZhHant] = "手動觸發",
            [AppLanguage.ZhHans] = "手动触发",
            [AppLanguage.En] = "manual",
            [AppLanguage.Ja] = "手動実行",
            [AppLanguage.Ko] = "수동 실행",
            [AppLanguage.Th] = "สั่งด้วยตนเอง",
        },
        ["tray_minimized"] = new()
        {
            [AppLanguage.ZhHant] = "已最小化至系統匣，持續在背景進行檔案即時同步與對帳。",
            [AppLanguage.ZhHans] = "已最小化到系统托盘，持续在后台进行文件实时同步与对账。",
            [AppLanguage.En] = "Minimized to the system tray. Files keep syncing in the background.",
            [AppLanguage.Ja] = "システムトレイに最小化しました。バックグラウンドで同期を続けます。",
            [AppLanguage.Ko] = "시스템 트레이로 최소화되었습니다. 백그라운드에서 계속 동기화합니다.",
            [AppLanguage.Th] = "ย่อไปที่ถาดระบบแล้ว ไฟล์ยังซิงค์ต่อในเบื้องหลัง",
        },
        ["core_folder_missing"] = new()
        {
            [AppLanguage.ZhHant] = "資料夾不存在（外接碟未掛載？）",
            [AppLanguage.ZhHans] = "文件夹不存在（外接盘未挂载？）",
            [AppLanguage.En] = "The folder does not exist (is the external drive mounted?)",
            [AppLanguage.Ja] = "フォルダが存在しません（外付けドライブが接続されていませんか？）",
            [AppLanguage.Ko] = "폴더가 없습니다 (외장 드라이브가 연결되어 있나요?)",
            [AppLanguage.Th] = "ไม่พบโฟลเดอร์ (ไดรฟ์ภายนอกยังไม่ได้เชื่อมต่อหรือไม่)",
        },
        ["core_marker_mismatch"] = new()
        {
            [AppLanguage.ZhHant] = "標記檔與此端點不符（換了另一個資料夾或磁碟？），已停止，不傳播任何變更",
            [AppLanguage.ZhHans] = "标记文件与此端点不符（换了另一个文件夹或磁盘？），已停止，不传播任何更改",
            [AppLanguage.En] = "The marker file does not match this endpoint (a different folder or disk?). Stopped; nothing is propagated.",
            [AppLanguage.Ja] = "マーカーファイルがこのエンドポイントと一致しません（別のフォルダやディスクですか？）。停止しました。変更は伝播しません。",
            [AppLanguage.Ko] = "표식 파일이 이 엔드포인트와 일치하지 않습니다 (다른 폴더나 디스크인가요?). 중지되었으며 변경은 전파되지 않습니다.",
            [AppLanguage.Th] = "ไฟล์เครื่องหมายไม่ตรงกับจุดซิงค์นี้ (เปลี่ยนโฟลเดอร์หรือดิสก์หรือไม่) หยุดแล้ว ไม่ส่งการเปลี่ยนแปลงใด ๆ",
        },
        ["core_marker_read"] = new()
        {
            [AppLanguage.ZhHant] = "無法讀取標記檔：{0}",
            [AppLanguage.ZhHans] = "无法读取标记文件：{0}",
            [AppLanguage.En] = "Could not read the marker file: {0}",
            [AppLanguage.Ja] = "マーカーファイルを読み取れません：{0}",
            [AppLanguage.Ko] = "표식 파일을 읽을 수 없습니다: {0}",
            [AppLanguage.Th] = "อ่านไฟล์เครื่องหมายไม่ได้: {0}",
        },
        ["core_marker_lost"] = new()
        {
            [AppLanguage.ZhHant] = "標記檔遺失（被清空、重新格式化或換碟？），已停止，不傳播任何刪除",
            [AppLanguage.ZhHans] = "标记文件丢失（被清空、重新格式化或换盘？），已停止，不传播任何删除",
            [AppLanguage.En] = "The marker file is missing (emptied, reformatted, or a different disk?). Stopped; no deletions are propagated.",
            [AppLanguage.Ja] = "マーカーファイルがありません（消去・再フォーマット・別ディスク？）。停止しました。削除は伝播しません。",
            [AppLanguage.Ko] = "표식 파일이 없습니다 (비워졌거나 포맷되었거나 다른 디스크인가요?). 중지되었으며 삭제는 전파되지 않습니다.",
            [AppLanguage.Th] = "ไม่พบไฟล์เครื่องหมาย (ถูกล้าง ฟอร์แมต หรือเปลี่ยนดิสก์หรือไม่) หยุดแล้ว ไม่ส่งการลบใด ๆ",
        },
        ["core_marker_write"] = new()
        {
            [AppLanguage.ZhHant] = "無法寫入標記檔：{0}",
            [AppLanguage.ZhHans] = "无法写入标记文件：{0}",
            [AppLanguage.En] = "Could not write the marker file: {0}",
            [AppLanguage.Ja] = "マーカーファイルを書き込めません：{0}",
            [AppLanguage.Ko] = "표식 파일을 쓸 수 없습니다: {0}",
            [AppLanguage.Th] = "เขียนไฟล์เครื่องหมายไม่ได้: {0}",
        },
        ["core_volume_mismatch"] = new()
        {
            [AppLanguage.ZhHant] = "磁碟區識別碼不符（不是原本那顆磁碟），已停止",
            [AppLanguage.ZhHans] = "磁盘卷标识不符（不是原来那块磁盘），已停止",
            [AppLanguage.En] = "The volume ID does not match (not the original disk). Stopped.",
            [AppLanguage.Ja] = "ボリューム ID が一致しません（元のディスクではありません）。停止しました。",
            [AppLanguage.Ko] = "볼륨 ID가 일치하지 않습니다 (원래 디스크가 아닙니다). 중지되었습니다.",
            [AppLanguage.Th] = "รหัสวอลลุ่มไม่ตรงกัน (ไม่ใช่ดิสก์เดิม) หยุดแล้ว",
        },
        ["core_not_enough"] = new()
        {
            [AppLanguage.ZhHant] = "在線端點不足 2 個，略過同步。",
            [AppLanguage.ZhHans] = "在线端点不足 2 个，跳过同步。",
            [AppLanguage.En] = "Fewer than 2 endpoints are online; sync skipped.",
            [AppLanguage.Ja] = "オンラインのエンドポイントが 2 つ未満のため、同期をスキップしました。",
            [AppLanguage.Ko] = "온라인 엔드포인트가 2개 미만이라 동기화를 건너뜁니다.",
            [AppLanguage.Th] = "จุดซิงค์ออนไลน์น้อยกว่า 2 จุด ข้ามการซิงค์",
        },
        ["core_deletion_guard"] = new()
        {
            [AppLanguage.ZhHant] = "預計刪除 {0} 個檔案（共追蹤 {1} 個），超過安全防護門檻，已安全暫停，需使用者確認後方可執行。",
            [AppLanguage.ZhHans] = "预计删除 {0} 个文件（共跟踪 {1} 个），超过安全防护阈值，已安全暂停，需用户确认后方可执行。",
            [AppLanguage.En] = "{0} files would be deleted (of {1} tracked), above the safety threshold. Paused until you confirm.",
            [AppLanguage.Ja] = "{0} 個のファイルを削除予定（追跡中 {1} 個）。安全しきい値を超えたため一時停止しました。確認後に実行されます。",
            [AppLanguage.Ko] = "파일 {0}개를 삭제할 예정입니다 (추적 {1}개). 안전 기준을 초과하여 일시 중지했으며 확인 후 실행됩니다.",
            [AppLanguage.Th] = "จะลบไฟล์ {0} ไฟล์ (จากที่ติดตาม {1}) เกินเกณฑ์ความปลอดภัย หยุดชั่วคราวจนกว่าจะยืนยัน",
        },
        ["core_note_conflict"] = new()
        {
            [AppLanguage.ZhHant] = "[{0}] 衝突 {1}：本端版本保留為「{2}」",
            [AppLanguage.ZhHans] = "[{0}] 冲突 {1}：本端版本保留为“{2}”",
            [AppLanguage.En] = "[{0}] Conflict {1}: this endpoint's version was kept as \"{2}\"",
            [AppLanguage.Ja] = "[{0}] 競合 {1}：このエンドポイントの版を「{2}」として保持",
            [AppLanguage.Ko] = "[{0}] 충돌 {1}: 이 엔드포인트의 버전을 \"{2}\"(으)로 보관",
            [AppLanguage.Th] = "[{0}] ข้อขัดแย้ง {1}: เก็บเวอร์ชันของจุดนี้ไว้เป็น \"{2}\"",
        },
        ["core_note_changed"] = new()
        {
            [AppLanguage.ZhHant] = "[{0}] 新增/修改 {1}（版號 {2}）",
            [AppLanguage.ZhHans] = "[{0}] 新增/修改 {1}（版号 {2}）",
            [AppLanguage.En] = "[{0}] Added/changed {1} (revision {2})",
            [AppLanguage.Ja] = "[{0}] 追加/変更 {1}（リビジョン {2}）",
            [AppLanguage.Ko] = "[{0}] 추가/수정 {1} (리비전 {2})",
            [AppLanguage.Th] = "[{0}] เพิ่ม/แก้ไข {1} (รุ่น {2})",
        },
        ["core_note_deleted"] = new()
        {
            [AppLanguage.ZhHant] = "[{0}] 刪除 {1}（版號 {2}）",
            [AppLanguage.ZhHans] = "[{0}] 删除 {1}（版号 {2}）",
            [AppLanguage.En] = "[{0}] Deleted {1} (revision {2})",
            [AppLanguage.Ja] = "[{0}] 削除 {1}（リビジョン {2}）",
            [AppLanguage.Ko] = "[{0}] 삭제 {1} (리비전 {2})",
            [AppLanguage.Th] = "[{0}] ลบ {1} (รุ่น {2})",
        },
        ["core_note_trash"] = new()
        {
            [AppLanguage.ZhHant] = "[{0}] 移到資源回收筒 {1}",
            [AppLanguage.ZhHans] = "[{0}] 移到回收站 {1}",
            [AppLanguage.En] = "[{0}] Moved to the Recycle Bin: {1}",
            [AppLanguage.Ja] = "[{0}] ごみ箱へ移動 {1}",
            [AppLanguage.Ko] = "[{0}] 휴지통으로 이동 {1}",
            [AppLanguage.Th] = "[{0}] ย้ายไปถังขยะ {1}",
        },
        ["core_note_write"] = new()
        {
            [AppLanguage.ZhHant] = "[{0}] 寫入 {1}（來源：{2}）",
            [AppLanguage.ZhHans] = "[{0}] 写入 {1}（来源：{2}）",
            [AppLanguage.En] = "[{0}] Wrote {1} (from {2})",
            [AppLanguage.Ja] = "[{0}] 書き込み {1}（元：{2}）",
            [AppLanguage.Ko] = "[{0}] 쓰기 {1} (원본: {2})",
            [AppLanguage.Th] = "[{0}] เขียน {1} (จาก {2})",
        },
        ["core_note_nohost"] = new()
        {
            [AppLanguage.ZhHant] = "[{0}] {1}：目前無其他在線端點持有有效副本，稍後重試",
            [AppLanguage.ZhHans] = "[{0}] {1}：目前没有其他在线端点持有有效副本，稍后重试",
            [AppLanguage.En] = "[{0}] {1}: no other online endpoint holds a valid copy right now; will retry",
            [AppLanguage.Ja] = "[{0}] {1}：有効なコピーを持つオンラインのエンドポイントがないため、後で再試行します",
            [AppLanguage.Ko] = "[{0}] {1}: 유효한 사본을 가진 온라인 엔드포인트가 없어 나중에 다시 시도합니다",
            [AppLanguage.Th] = "[{0}] {1}: ตอนนี้ไม่มีจุดซิงค์ออนไลน์ที่มีสำเนาที่ใช้ได้ จะลองใหม่ภายหลัง",
        },
        ["core_lock_timeout"] = new()
        {
            [AppLanguage.ZhHant] = "無法獲取同步鎖定（{0}），可能已有另一個 SyncNexus 正在對帳中。",
            [AppLanguage.ZhHans] = "无法获取同步锁定（{0}），可能已有另一个 SyncNexus 正在对账中。",
            [AppLanguage.En] = "Could not take the sync lock ({0}); another SyncNexus may be syncing.",
            [AppLanguage.Ja] = "同期ロックを取得できません（{0}）。別の SyncNexus が同期中の可能性があります。",
            [AppLanguage.Ko] = "동기화 잠금을 얻을 수 없습니다 ({0}). 다른 SyncNexus가 동기화 중일 수 있습니다.",
            [AppLanguage.Th] = "ไม่สามารถล็อกการซิงค์ได้ ({0}) อาจมี SyncNexus อีกตัวกำลังซิงค์อยู่",
        },
        ["manual_title"] = new()
        {
            [AppLanguage.ZhHant] = "SyncNexus 操作使用手冊",
            [AppLanguage.ZhHans] = "SyncNexus 操作使用手册",
            [AppLanguage.En] = "SyncNexus User Manual",
            [AppLanguage.Ja] = "SyncNexus 操作マニュアル",
            [AppLanguage.Ko] = "SyncNexus 사용 설명서",
            [AppLanguage.Th] = "คู่มือการใช้งาน SyncNexus",
        },
        ["manual_body"] = new()
        {
            [AppLanguage.ZhHant] = "【快速上手：如何加入同步資料夾？】\n點擊主畫面「新增同步端點...」，選取您準備要同步的目錄：\n\n1. 電腦本機資料夾：\n   打開「檔案總管」，點擊左側側邊欄的「文件」或進入 C: 槽選取您想要同步的資料夾。\n\n2. iCloud 雲碟：\n   打開「檔案總管」，點擊左側側邊欄的「iCloud 雲碟」圖示，選取準備要同步的資料夾。\n\n3. Google 雲端硬碟 (Google Drive)：\n   打開「檔案總管」，點擊左側側邊欄的「Google Drive」，點擊「我的雲端硬碟」，選取準備要同步的資料夾。\n\n4. OneDrive 雲端硬碟：\n   打開「檔案總管」，點擊左側側邊欄的「OneDrive」，選取準備要同步的資料夾。\n\n5. 外接隨身碟 / 行動硬碟：\n   插上隨身碟，打開「檔案總管」，點擊左側「本機」下方的隨身硬碟磁碟機代號（如 D: 或 E:），選取準備要同步的資料夾。格式建議為 ExFAT，方便同時與 Mac 互相插拔共用！\n\n【全自動即時同步與保護】\n• 平時完全免手動：任一資料夾檔案變更，2 秒內自動同步到其他所有端點。\n• 衝突雙向保留：離線雙向修改時，自動另存衝突複本，絕不覆蓋您的檔案。\n• 安全刪除：同步刪除時優先移入 Windows 資源回收筒，安全防手殘。",
            [AppLanguage.ZhHans] = "【快速上手：如何添加同步文件夹？】\n点击主界面“新增同步端点...”，选择您准备要同步的目录：\n\n1. 电脑本机文件夹：\n   打开“文件资源管理器”，点击左侧边栏的“文档”或进入 C: 盘选择您想要同步的文件夹。\n\n2. iCloud 云盘：\n   打开“文件资源管理器”，点击左侧边栏的“iCloud 云盘”图标，选择准备要同步的文件夹。\n\n3. Google 云端硬盘 (Google Drive)：\n   打开“文件资源管理器”，点击左侧边栏的“Google Drive”，点击“我的云端硬盘”，选择准备要同步的文件夹。\n\n4. OneDrive 云端硬盘：\n   打开“文件资源管理器”，点击左侧边栏的“OneDrive”，选择准备要同步的文件夹。\n\n5. 外接 U 盘 / 移动硬盘：\n   插上 U 盘，打开“文件资源管理器”，点击左侧“此电脑”下方的盘符（如 D: 或 E:），选择准备要同步的文件夹。建议格式化为 ExFAT，方便与 Mac 互相插拔共用！\n\n【全自动实时同步与保护】\n• 平时完全免手动：任一文件夹中的文件变更，2 秒内自动同步到其他所有端点。\n• 冲突双向保留：离线双向修改时，自动另存冲突副本，绝不覆盖您的文件。\n• 安全删除：同步删除时优先移入 Windows 回收站，防止误删。",
            [AppLanguage.En] = "[Quick start: how to add a folder to sync]\nClick \"Add Sync Endpoint...\" on the main window and choose the folder you want to sync:\n\n1. A folder on this PC:\n   Open File Explorer, click \"Documents\" in the left sidebar or browse your C: drive, and pick the folder.\n\n2. iCloud Drive:\n   Open File Explorer, click the \"iCloud Drive\" icon in the left sidebar, and pick the folder.\n\n3. Google Drive:\n   Open File Explorer, click \"Google Drive\" in the left sidebar, open \"My Drive\", and pick the folder.\n\n4. OneDrive:\n   Open File Explorer, click \"OneDrive\" in the left sidebar, and pick the folder.\n\n5. USB stick / external drive:\n   Plug it in, open File Explorer, click its drive letter under \"This PC\" (for example D: or E:), and pick the folder. ExFAT is recommended so the drive can be moved between Windows and Mac.\n\n[Automatic, real-time sync and protection]\n• No manual work: when a file changes in any folder, it is synced to all other endpoints within 2 seconds.\n• Conflicts keep both sides: if two sides were edited while apart, the other version is saved as a conflict copy. Your files are never overwritten.\n• Safe deletion: deletions go to the Windows Recycle Bin first, so mistakes can be undone.",
            [AppLanguage.Ja] = "【クイックスタート：同期するフォルダの追加方法】\nメイン画面の「同期エンドポイントを追加...」をクリックし、同期したいフォルダを選びます。\n\n1. このPCのフォルダ：\n   エクスプローラーを開き、左のサイドバーの「ドキュメント」または C: ドライブから目的のフォルダを選びます。\n\n2. iCloud ドライブ：\n   エクスプローラーの左サイドバーにある「iCloud ドライブ」をクリックし、フォルダを選びます。\n\n3. Google ドライブ：\n   エクスプローラーの左サイドバーで「Google Drive」→「マイドライブ」を開き、フォルダを選びます。\n\n4. OneDrive：\n   エクスプローラーの左サイドバーで「OneDrive」をクリックし、フォルダを選びます。\n\n5. USB メモリ / 外付けドライブ：\n   接続してエクスプローラーを開き、「PC」の下のドライブ文字（D: や E: など）からフォルダを選びます。Mac と相互に使えるよう ExFAT 形式を推奨します。\n\n【全自動のリアルタイム同期と保護】\n• 手動操作は不要：いずれかのフォルダでファイルが変わると、2 秒以内に他のすべてのエンドポイントへ同期します。\n• 競合は両方を保持：離れた状態で双方が編集された場合、もう一方を競合コピーとして保存し、ファイルを上書きしません。\n• 安全な削除：削除はまず Windows のごみ箱に移動するため、取り消せます。",
            [AppLanguage.Ko] = "[빠른 시작: 동기화할 폴더 추가 방법]\n메인 화면에서 \"동기화 엔드포인트 추가...\"를 클릭하고 동기화할 폴더를 선택하세요.\n\n1. 이 PC의 폴더:\n   파일 탐색기를 열고 왼쪽 사이드바의 \"문서\" 또는 C: 드라이브에서 폴더를 선택합니다.\n\n2. iCloud 드라이브:\n   파일 탐색기 왼쪽 사이드바의 \"iCloud 드라이브\"를 클릭하고 폴더를 선택합니다.\n\n3. Google 드라이브:\n   파일 탐색기 왼쪽 사이드바에서 \"Google Drive\"를 클릭한 뒤 \"내 드라이브\"를 열어 폴더를 선택합니다.\n\n4. OneDrive:\n   파일 탐색기 왼쪽 사이드바에서 \"OneDrive\"를 클릭하고 폴더를 선택합니다.\n\n5. USB / 외장 하드:\n   연결한 뒤 파일 탐색기의 \"내 PC\" 아래 드라이브 문자(D: 또는 E: 등)에서 폴더를 선택합니다. Mac과 번갈아 사용하려면 ExFAT 형식을 권장합니다.\n\n[완전 자동 실시간 동기화 및 보호]\n• 수동 작업 불필요: 어느 폴더에서든 파일이 바뀌면 2초 안에 다른 모든 엔드포인트로 동기화됩니다.\n• 충돌 시 양쪽 보관: 떨어져 있는 동안 양쪽이 수정되면 다른 버전을 충돌 사본으로 저장하며 파일을 덮어쓰지 않습니다.\n• 안전한 삭제: 삭제는 먼저 Windows 휴지통으로 이동하므로 실수를 되돌릴 수 있습니다.",
            [AppLanguage.Th] = "[เริ่มต้นใช้งานอย่างรวดเร็ว: วิธีเพิ่มโฟลเดอร์ที่จะซิงค์]\nคลิก \"เพิ่มจุดซิงค์...\" ในหน้าหลัก แล้วเลือกโฟลเดอร์ที่ต้องการซิงค์\n\n1. โฟลเดอร์ในเครื่องนี้:\n   เปิดตัวสำรวจไฟล์ คลิก \"เอกสาร\" ที่แถบด้านซ้าย หรือเข้าไดรฟ์ C: แล้วเลือกโฟลเดอร์\n\n2. iCloud Drive:\n   เปิดตัวสำรวจไฟล์ คลิกไอคอน \"iCloud Drive\" ที่แถบด้านซ้าย แล้วเลือกโฟลเดอร์\n\n3. Google Drive:\n   เปิดตัวสำรวจไฟล์ คลิก \"Google Drive\" ที่แถบด้านซ้าย เปิด \"ไดรฟ์ของฉัน\" แล้วเลือกโฟลเดอร์\n\n4. OneDrive:\n   เปิดตัวสำรวจไฟล์ คลิก \"OneDrive\" ที่แถบด้านซ้าย แล้วเลือกโฟลเดอร์\n\n5. แฟลชไดรฟ์ USB / ฮาร์ดดิสก์ภายนอก:\n   เสียบอุปกรณ์ เปิดตัวสำรวจไฟล์ คลิกอักษรไดรฟ์ใต้ \"พีซีเครื่องนี้\" (เช่น D: หรือ E:) แล้วเลือกโฟลเดอร์ แนะนำให้ฟอร์แมตเป็น ExFAT เพื่อใช้สลับกับ Mac ได้\n\n[ซิงค์อัตโนมัติแบบเรียลไทม์และการปกป้อง]\n• ไม่ต้องทำเอง: เมื่อไฟล์ในโฟลเดอร์ใดเปลี่ยน จะซิงค์ไปยังจุดอื่นทั้งหมดภายใน 2 วินาที\n• เก็บทั้งสองฝั่งเมื่อขัดแย้ง: หากมีการแก้ไขทั้งสองฝั่งขณะแยกกัน จะบันทึกอีกเวอร์ชันเป็นสำเนาข้อขัดแย้ง ไม่เขียนทับไฟล์ของคุณ\n• ลบอย่างปลอดภัย: การลบจะย้ายไปถังขยะของ Windows ก่อน จึงกู้คืนได้",
        },
        ["privacy_title"] = new()
        {
            [AppLanguage.ZhHant] = "SyncNexus 隱私權保護政策",
            [AppLanguage.ZhHans] = "SyncNexus 隐私保护政策",
            [AppLanguage.En] = "SyncNexus Privacy Policy",
            [AppLanguage.Ja] = "SyncNexus プライバシーポリシー",
            [AppLanguage.Ko] = "SyncNexus 개인정보 처리방침",
            [AppLanguage.Th] = "นโยบายความเป็นส่วนตัวของ SyncNexus",
        },
        ["privacy_body"] = new()
        {
            [AppLanguage.ZhHant] = "【SyncNexus 隱私權承諾】\n\n1. 100% 本地優先，無雲端中繼伺服器：\n   所有檔案比對、同步傳輸與特徵碼比對皆完全在您的電腦本地執行。SyncNexus 沒有經營任何雲端伺服器，絕不會上傳您的檔案內容。\n\n2. 嚴格遵循微軟應用商店與系統最小權限原則：\n   本軟體僅存取您在選取視窗中明確指定的資料夾，絕無法擅自存取您電腦中的其他私人檔案。\n\n3. 零診斷追蹤，零廣告，無任何資料收集：\n   我們不收集檔案清單、資料夾名稱、硬體序號、IP 位址或任何分析數據。程式內未植入任何廣告追蹤 SDK 或第三方數據分析工具。\n\n4. 安全刪除機制：優先移至系統資源回收筒：\n   在進行同步刪除時，檔案會優先移至 Windows 系統「資源回收筒」而非永久抹除，確保隨時可撤銷操作。您擁有資料處置的最高決定權。",
            [AppLanguage.ZhHans] = "【SyncNexus 隐私承诺】\n\n1. 100% 本地优先，无云端中继服务器：\n   所有文件比对、同步传输与特征码比对均完全在您的电脑本地执行。SyncNexus 没有运营任何云端服务器，绝不会上传您的文件内容。\n\n2. 严格遵循微软应用商店与系统最小权限原则：\n   本软件仅访问您在选择窗口中明确指定的文件夹，绝不会擅自访问您电脑中的其他私人文件。\n\n3. 零诊断追踪，零广告，不收集任何数据：\n   我们不收集文件列表、文件夹名称、硬件序列号、IP 地址或任何分析数据。程序内未植入任何广告追踪 SDK 或第三方数据分析工具。\n\n4. 安全删除机制：优先移至系统回收站：\n   进行同步删除时，文件会优先移至 Windows 系统“回收站”而非永久删除，确保随时可以撤销操作。您拥有数据处置的最终决定权。",
            [AppLanguage.En] = "[SyncNexus Privacy Promise]\n\n1. 100% local-first, no cloud relay server:\n   All file comparison, transfer, and checksum work happens entirely on your computer. SyncNexus runs no cloud servers and never uploads the contents of your files.\n\n2. Least privilege, as the Microsoft Store requires:\n   The app only accesses the folders you explicitly choose in the picker. It cannot reach any other private files on your computer.\n\n3. No diagnostics, no ads, no data collection:\n   We do not collect file lists, folder names, hardware serial numbers, IP addresses, or any analytics. The app contains no advertising or third-party tracking SDKs.\n\n4. Safe deletion: the Recycle Bin comes first:\n   When a deletion is synced, files are moved to the Windows Recycle Bin instead of being erased, so the action can always be undone. You have the final say over your data.",
            [AppLanguage.Ja] = "【SyncNexus のプライバシーへの取り組み】\n\n1. 100% ローカル優先、クラウド中継サーバーなし：\n   ファイルの比較、転送、チェックサムの照合はすべてお使いのコンピューター上で行われます。SyncNexus はクラウドサーバーを運営しておらず、ファイルの内容をアップロードすることはありません。\n\n2. Microsoft Store の最小権限の原則に準拠：\n   本ソフトは、選択ダイアログで明示的に指定されたフォルダにのみアクセスします。コンピューター内のその他の個人ファイルには一切アクセスできません。\n\n3. 診断情報の収集なし、広告なし、データ収集なし：\n   ファイル一覧、フォルダ名、ハードウェアのシリアル番号、IP アドレス、分析データは収集しません。広告用トラッキング SDK やサードパーティの分析ツールも組み込まれていません。\n\n4. 安全な削除：まずごみ箱へ：\n   同期による削除では、ファイルを完全に消去せず Windows のごみ箱へ移動するため、いつでも元に戻せます。データの扱いを決めるのは常にあなたです。",
            [AppLanguage.Ko] = "[SyncNexus 개인정보 보호 약속]\n\n1. 100% 로컬 우선, 클라우드 중계 서버 없음:\n   모든 파일 비교, 전송, 체크섬 확인은 사용자의 컴퓨터에서만 수행됩니다. SyncNexus는 클라우드 서버를 운영하지 않으며 파일 내용을 업로드하지 않습니다.\n\n2. Microsoft Store 최소 권한 원칙 준수:\n   이 앱은 선택 창에서 사용자가 명시적으로 지정한 폴더에만 접근하며, 컴퓨터의 다른 개인 파일에는 접근할 수 없습니다.\n\n3. 진단 추적 없음, 광고 없음, 데이터 수집 없음:\n   파일 목록, 폴더 이름, 하드웨어 일련번호, IP 주소, 분석 데이터를 수집하지 않습니다. 광고 추적 SDK나 제3자 분석 도구도 포함되어 있지 않습니다.\n\n4. 안전한 삭제: 휴지통 우선:\n   동기화로 삭제할 때 파일을 영구 삭제하지 않고 Windows 휴지통으로 이동하므로 언제든 되돌릴 수 있습니다. 데이터에 대한 최종 결정권은 사용자에게 있습니다.",
            [AppLanguage.Th] = "[คำมั่นด้านความเป็นส่วนตัวของ SyncNexus]\n\n1. เน้นในเครื่อง 100% ไม่มีเซิร์ฟเวอร์คลาวด์คั่นกลาง:\n   การเปรียบเทียบไฟล์ การส่งไฟล์ และการตรวจค่าแฮชทั้งหมดทำบนคอมพิวเตอร์ของคุณเท่านั้น SyncNexus ไม่มีเซิร์ฟเวอร์คลาวด์ และจะไม่อัปโหลดเนื้อหาไฟล์ของคุณ\n\n2. ยึดหลักสิทธิ์ขั้นต่ำตามข้อกำหนดของ Microsoft Store:\n   แอปเข้าถึงเฉพาะโฟลเดอร์ที่คุณเลือกไว้อย่างชัดเจนในหน้าต่างเลือก และไม่สามารถเข้าถึงไฟล์ส่วนตัวอื่นในคอมพิวเตอร์ได้\n\n3. ไม่เก็บข้อมูลวินิจฉัย ไม่มีโฆษณา ไม่เก็บข้อมูลใด ๆ:\n   เราไม่เก็บรายชื่อไฟล์ ชื่อโฟลเดอร์ หมายเลขซีเรียลฮาร์ดแวร์ ที่อยู่ IP หรือข้อมูลวิเคราะห์ใด ๆ และไม่มี SDK ติดตามโฆษณาหรือเครื่องมือวิเคราะห์ของบุคคลที่สาม\n\n4. ลบอย่างปลอดภัย: ย้ายไปถังขยะก่อน:\n   เมื่อซิงค์การลบ ไฟล์จะถูกย้ายไปถังขยะของ Windows แทนการลบถาวร จึงเลิกทำได้เสมอ คุณมีสิทธิ์ตัดสินใจเรื่องข้อมูลของคุณ",
        },
        ["keep_conflict"] = new()
        {
            [AppLanguage.ZhHant] = "保留衝突複本",
            [AppLanguage.ZhHans] = "保留冲突副本",
            [AppLanguage.En] = "Keep Conflict Copy",
            [AppLanguage.Ja] = "競合コピーを保持",
            [AppLanguage.Ko] = "충돌 사본 유지",
            [AppLanguage.Th] = "เก็บสำเนาที่ขัดแย้ง",
        },
        ["nav_preview"] = new()
        {
            [AppLanguage.ZhHant] = "差異預覽",
            [AppLanguage.ZhHans] = "差异预览",
            [AppLanguage.En] = "Diff Preview",
            [AppLanguage.Ja] = "差分プレビュー",
            [AppLanguage.Ko] = "차이 미리보기",
            [AppLanguage.Th] = "ดูตัวอย่างความต่าง",
        },
        ["nav_folders"] = new()
        {
            [AppLanguage.ZhHant] = "資料夾",
            [AppLanguage.ZhHans] = "文件夹",
            [AppLanguage.En] = "Folders",
            [AppLanguage.Ja] = "フォルダ",
            [AppLanguage.Ko] = "폴더",
            [AppLanguage.Th] = "โฟลเดอร์",
        },
        ["nav_versions"] = new()
        {
            [AppLanguage.ZhHant] = "舊版本",
            [AppLanguage.ZhHans] = "旧版本",
            [AppLanguage.En] = "Versions",
            [AppLanguage.Ja] = "以前のバージョン",
            [AppLanguage.Ko] = "이전 버전",
            [AppLanguage.Th] = "เวอร์ชันก่อนหน้า",
        },
        ["nav_verify"] = new()
        {
            [AppLanguage.ZhHant] = "驗證紀錄",
            [AppLanguage.ZhHans] = "验证记录",
            [AppLanguage.En] = "Verification",
            [AppLanguage.Ja] = "検証ログ",
            [AppLanguage.Ko] = "검증 기록",
            [AppLanguage.Th] = "บันทึกการตรวจสอบ",
        },
        ["stat_tracked_files"] = new()
        {
            [AppLanguage.ZhHant] = "追蹤檔案",
            [AppLanguage.ZhHans] = "追踪文件",
            [AppLanguage.En] = "Tracked Files",
            [AppLanguage.Ja] = "追跡対象ファイル",
            [AppLanguage.Ko] = "추적 중인 파일",
            [AppLanguage.Th] = "ไฟล์ที่ติดตาม",
        },
        ["stat_sub_sha256"] = new()
        {
            [AppLanguage.ZhHant] = "SHA-256 比對",
            [AppLanguage.ZhHans] = "SHA-256 比对",
            [AppLanguage.En] = "SHA-256 Checksum",
            [AppLanguage.Ja] = "SHA-256 照合",
            [AppLanguage.Ko] = "SHA-256 대조",
            [AppLanguage.Th] = "การตรวจสอบ SHA-256",
        },
        ["stat_last_deep_verify"] = new()
        {
            [AppLanguage.ZhHant] = "最後深度驗證",
            [AppLanguage.ZhHans] = "最后深度验证",
            [AppLanguage.En] = "Last Deep Verify",
            [AppLanguage.Ja] = "最終詳細検証",
            [AppLanguage.Ko] = "최근 심층 검증",
            [AppLanguage.Th] = "การตรวจสอบเชิงลึกล่าสุด",
        },
        ["stat_old_versions"] = new()
        {
            [AppLanguage.ZhHant] = "舊版本",
            [AppLanguage.ZhHans] = "旧版本",
            [AppLanguage.En] = "Old Versions",
            [AppLanguage.Ja] = "以前のバージョン",
            [AppLanguage.Ko] = "이전 버전",
            [AppLanguage.Th] = "เวอร์ชันเดิม",
        },
        ["no_anomalies"] = new()
        {
            [AppLanguage.ZhHant] = "無異常",
            [AppLanguage.ZhHans] = "无异常",
            [AppLanguage.En] = "No anomalies",
            [AppLanguage.Ja] = "異常なし",
            [AppLanguage.Ko] = "이상 없음",
            [AppLanguage.Th] = "ไม่มีความผิดปกติ",
        },
        ["suspected_corrupted_count"] = new()
        {
            [AppLanguage.ZhHant] = "疑似損毀 {0} 項",
            [AppLanguage.ZhHans] = "疑似损坏 {0} 项",
            [AppLanguage.En] = "Suspected corrupted: {0}",
            [AppLanguage.Ja] = "破損の疑い {0} 件",
            [AppLanguage.Ko] = "손상 의심 {0}건",
            [AppLanguage.Th] = "สงสัยเสียหาย {0} รายการ",
        },
        ["never"] = new()
        {
            [AppLanguage.ZhHant] = "尚未驗證",
            [AppLanguage.ZhHans] = "尚未验证",
            [AppLanguage.En] = "Never verified",
            [AppLanguage.Ja] = "未検証",
            [AppLanguage.Ko] = "검증 안 됨",
            [AppLanguage.Th] = "ยังไม่เคยตรวจสอบ",
        },
        ["retention_permanent_sub"] = new()
        {
            [AppLanguage.ZhHant] = "永久保留",
            [AppLanguage.ZhHans] = "永久保留",
            [AppLanguage.En] = "Keep permanently",
            [AppLanguage.Ja] = "永久保持",
            [AppLanguage.Ko] = "영구 보관",
            [AppLanguage.Th] = "เก็บถาวร",
        },
        ["retention_days_sub"] = new()
        {
            [AppLanguage.ZhHant] = "保留 {0} 天",
            [AppLanguage.ZhHans] = "保留 {0} 天",
            [AppLanguage.En] = "Retained for {0} days",
            [AppLanguage.Ja] = "{0} 日間保持",
            [AppLanguage.Ko] = "{0}일간 보관",
            [AppLanguage.Th] = "เก็บไว้ {0} วัน",
        },
        ["confirm_queue_title"] = new()
        {
            [AppLanguage.ZhHant] = "{0} 個群組需要確認",
            [AppLanguage.ZhHans] = "{0} 个群组需要确认",
            [AppLanguage.En] = "{0} group(s) require confirmation",
            [AppLanguage.Ja] = "{0} 個のグループで確認が必要です",
            [AppLanguage.Ko] = "{0}개 그룹에 확인이 필요합니다",
            [AppLanguage.Th] = "{0} กลุ่มต้องการการยืนยัน",
        },
        ["confirm_queue_approve"] = new()
        {
            [AppLanguage.ZhHant] = "同意",
            [AppLanguage.ZhHans] = "同意",
            [AppLanguage.En] = "Approve",
            [AppLanguage.Ja] = "承認",
            [AppLanguage.Ko] = "승인",
            [AppLanguage.Th] = "อนุมัติ",
        },
        ["confirm_queue_decline"] = new()
        {
            [AppLanguage.ZhHant] = "取消",
            [AppLanguage.ZhHans] = "取消",
            [AppLanguage.En] = "Decline",
            [AppLanguage.Ja] = "拒否",
            [AppLanguage.Ko] = "거절",
            [AppLanguage.Th] = "ปฏิเสธ",
        },
        ["confirm_queue_approve_all"] = new()
        {
            [AppLanguage.ZhHant] = "全部同意",
            [AppLanguage.ZhHans] = "全部同意",
            [AppLanguage.En] = "Approve All",
            [AppLanguage.Ja] = "すべて承認",
            [AppLanguage.Ko] = "모두 승인",
            [AppLanguage.Th] = "อนุมัติทั้งหมด",
        },
        ["confirm_queue_hint"] = new()
        {
            [AppLanguage.ZhHant] = "已達安全保護門檻，需手動確認後方可執行變更。",
            [AppLanguage.ZhHans] = "已达安全保护门槛，需手动确认后方可执行变更。",
            [AppLanguage.En] = "Safety threshold reached. Manual confirmation required before applying changes.",
            [AppLanguage.Ja] = "安全保護のしきい値に達しました。変更を適用するには手動での確認が必要です。",
            [AppLanguage.Ko] = "안전 임계치에 도달했습니다. 변경을 적용하려면 수동 확인이 필요합니다.",
            [AppLanguage.Th] = "ถึงเกณฑ์ความปลอดภัยแล้ว ต้องยืนยันด้วยตนเองก่อนดำเนินการ",
        },
        ["status_paused"] = new()
        {
            [AppLanguage.ZhHant] = "已暫停",
            [AppLanguage.ZhHans] = "已暂停",
            [AppLanguage.En] = "Paused",
            [AppLanguage.Ja] = "一時停止中",
            [AppLanguage.Ko] = "일시정지됨",
            [AppLanguage.Th] = "หยุดชั่วคราว",
        },
        ["status_ok"] = new()
        {
            [AppLanguage.ZhHant] = "正常",
            [AppLanguage.ZhHans] = "正常",
            [AppLanguage.En] = "Normal",
            [AppLanguage.Ja] = "正常",
            [AppLanguage.Ko] = "정상",
            [AppLanguage.Th] = "ปกติ",
        },
        ["status_needs_confirm"] = new()
        {
            [AppLanguage.ZhHant] = "待確認",
            [AppLanguage.ZhHans] = "待确认",
            [AppLanguage.En] = "Needs confirmation",
            [AppLanguage.Ja] = "確認待ち",
            [AppLanguage.Ko] = "확인 대기",
            [AppLanguage.Th] = "รอยืนยัน",
        },
        ["btn_pause_sync"] = new()
        {
            [AppLanguage.ZhHant] = "暫停",
            [AppLanguage.ZhHans] = "暂停",
            [AppLanguage.En] = "Pause",
            [AppLanguage.Ja] = "一時停止",
            [AppLanguage.Ko] = "일시정지",
            [AppLanguage.Th] = "หยุดชั่วคราว",
        },
        ["btn_resume_sync"] = new()
        {
            [AppLanguage.ZhHant] = "恢復",
            [AppLanguage.ZhHans] = "恢复",
            [AppLanguage.En] = "Resume",
            [AppLanguage.Ja] = "再開",
            [AppLanguage.Ko] = "재개",
            [AppLanguage.Th] = "ทำงานต่อ",
        },
        ["preview_desc"] = new()
        {
            [AppLanguage.ZhHant] = "查看下一次同步會做哪些變更。僅試跑預覽，不會更動任何檔案。",
            [AppLanguage.ZhHans] = "查看下一次同步会做哪些变更。仅试跑预览，不会改动任何文件。",
            [AppLanguage.En] = "Preview changes that will happen in the next sync. Dry run only, no files changed.",
            [AppLanguage.Ja] = "次回の同期で行われる変更をプレビューします。ファイルは変更されません。",
            [AppLanguage.Ko] = "다음 동기화에서 수행될 변경 사항을 미리 봅니다. 파일은 변경되지 않습니다.",
            [AppLanguage.Th] = "ดูตัวอย่างการเปลี่ยนแปลงที่จะเกิดขึ้นในการซิงค์ครั้งถัดไป ไม่มีการแก้ไขไฟล์จริง",
        },
        ["preview_run"] = new()
        {
            [AppLanguage.ZhHant] = "立即試跑檢查",
            [AppLanguage.ZhHans] = "立即试跑检查",
            [AppLanguage.En] = "Run Preview",
            [AppLanguage.Ja] = "プレビュー実行",
            [AppLanguage.Ko] = "미리보기 실행",
            [AppLanguage.Th] = "เรียกดูตัวอย่าง",
        },
        ["preview_running"] = new()
        {
            [AppLanguage.ZhHant] = "檢查中…",
            [AppLanguage.ZhHans] = "检查中…",
            [AppLanguage.En] = "Checking…",
            [AppLanguage.Ja] = "確認中…",
            [AppLanguage.Ko] = "확인 중…",
            [AppLanguage.Th] = "กำลังตรวจสอบ…",
        },
        ["preview_sync_now"] = new()
        {
            [AppLanguage.ZhHant] = "立即執行同步",
            [AppLanguage.ZhHans] = "立即执行同步",
            [AppLanguage.En] = "Execute Sync Now",
            [AppLanguage.Ja] = "今すぐ同期を実行",
            [AppLanguage.Ko] = "지금 동기화 실행",
            [AppLanguage.Th] = "ดำเนินการซิงค์ทันที",
        },
        ["preview_empty"] = new()
        {
            [AppLanguage.ZhHant] = "全部已同步，沒有需要處理的項目。",
            [AppLanguage.ZhHans] = "全部已同步，没有需要处理的项目。",
            [AppLanguage.En] = "Everything is synchronized. Nothing to do.",
            [AppLanguage.Ja] = "すべて同期済みです。処理項目はありません。",
            [AppLanguage.Ko] = "모두 동기화되었습니다. 처리할 항목이 없습니다.",
            [AppLanguage.Th] = "ซิงค์ครบทั้งหมดแล้ว ไม่มีรายการที่ต้องจัดการ",
        },
        ["preview_more_items"] = new()
        {
            [AppLanguage.ZhHant] = "尚有 {0} 項未列出…",
            [AppLanguage.ZhHans] = "尚有 {0} 项未列出…",
            [AppLanguage.En] = "{0} more items not shown…",
            [AppLanguage.Ja] = "他 {0} 件は非表示…",
            [AppLanguage.Ko] = "외 {0}개 항목 생략됨…",
            [AppLanguage.Th] = "ยังมีอีก {0} รายการที่ไม่ได้แสดง…",
        },
        ["versions_retention_label"] = new()
        {
            [AppLanguage.ZhHant] = "版本保留天數：{0} 天",
            [AppLanguage.ZhHans] = "版本保留天数：{0} 天",
            [AppLanguage.En] = "Version Retention: {0} days",
            [AppLanguage.Ja] = "バージョン保持日数：{0} 日",
            [AppLanguage.Ko] = "버전 보관 일수: {0}일",
            [AppLanguage.Th] = "ระยะเวลาเก็บเวอร์ชัน: {0} วัน",
        },
        ["versions_btn_clean_expired"] = new()
        {
            [AppLanguage.ZhHant] = "清除已過期",
            [AppLanguage.ZhHans] = "清除已过期",
            [AppLanguage.En] = "Purge Expired",
            [AppLanguage.Ja] = "期限切れを削除",
            [AppLanguage.Ko] = "만료된 파일 삭제",
            [AppLanguage.Th] = "ลบที่หมดอายุ",
        },
        ["versions_btn_clear_all"] = new()
        {
            [AppLanguage.ZhHant] = "清除全部",
            [AppLanguage.ZhHans] = "清除全部",
            [AppLanguage.En] = "Clear All",
            [AppLanguage.Ja] = "すべて消去",
            [AppLanguage.Ko] = "모두 지우기",
            [AppLanguage.Th] = "ล้างทั้งหมด",
        },
        ["versions_restore"] = new()
        {
            [AppLanguage.ZhHant] = "還原",
            [AppLanguage.ZhHans] = "还原",
            [AppLanguage.En] = "Restore",
            [AppLanguage.Ja] = "復元",
            [AppLanguage.Ko] = "복원",
            [AppLanguage.Th] = "กู้คืน",
        },
        ["versions_delete"] = new()
        {
            [AppLanguage.ZhHant] = "刪除",
            [AppLanguage.ZhHans] = "删除",
            [AppLanguage.En] = "Delete",
            [AppLanguage.Ja] = "削除",
            [AppLanguage.Ko] = "삭제",
            [AppLanguage.Th] = "ลบ",
        },
        ["versions_empty"] = new()
        {
            [AppLanguage.ZhHant] = "目前沒有舊版本。",
            [AppLanguage.ZhHans] = "目前没有旧版本。",
            [AppLanguage.En] = "No previous versions available.",
            [AppLanguage.Ja] = "以前のバージョンはありません。",
            [AppLanguage.Ko] = "이전 버전이 없습니다.",
            [AppLanguage.Th] = "ไม่มีเวอร์ชันก่อนหน้า",
        },
        ["verify_desc"] = new()
        {
            [AppLanguage.ZhHant] = "重新讀取每個檔案，確認內容仍與紀錄相符，可發現無聲損毀。",
            [AppLanguage.ZhHans] = "重新读取每个文件，确认内容仍与记录相符，可发现无声损坏。",
            [AppLanguage.En] = "Re-reads every file to verify against database hashes, detecting silent bit-rot.",
            [AppLanguage.Ja] = "すべてのファイルを再読み込みしてハッシュ値と照合し、サイレント破損を検出します。",
            [AppLanguage.Ko] = "모든 파일을 다시 읽어 해시값과 대조하고 무음 손상을 감지합니다.",
            [AppLanguage.Th] = "อ่านไฟล์ทั้งหมดซ้ำเพื่อยืนยันกับแฮช และตรวจจับความเสียหายเงียบ",
        },
        ["verify_run"] = new()
        {
            [AppLanguage.ZhHant] = "立即驗證",
            [AppLanguage.ZhHans] = "立即验证",
            [AppLanguage.En] = "Verify Now",
            [AppLanguage.Ja] = "今すぐ検証",
            [AppLanguage.Ko] = "지금 검증",
            [AppLanguage.Th] = "ตรวจสอบทันที",
        },
        ["verify_running"] = new()
        {
            [AppLanguage.ZhHant] = "驗證中…",
            [AppLanguage.ZhHans] = "验证中…",
            [AppLanguage.En] = "Verifying…",
            [AppLanguage.Ja] = "検証中…",
            [AppLanguage.Ko] = "검증 중…",
            [AppLanguage.Th] = "กำลังตรวจสอบ…",
        },
        ["verify_issues_title"] = new()
        {
            [AppLanguage.ZhHant] = "疑似損毀清單",
            [AppLanguage.ZhHans] = "疑似损坏清单",
            [AppLanguage.En] = "Integrity Issues",
            [AppLanguage.Ja] = "破損疑い一覧",
            [AppLanguage.Ko] = "손상 의심 목록",
            [AppLanguage.Th] = "รายการที่สงสัยเสียหาย",
        },
        ["settings_conflict_title"] = new()
        {
            [AppLanguage.ZhHant] = "衝突策略",
            [AppLanguage.ZhHans] = "冲突策略",
            [AppLanguage.En] = "Conflict Policy",
            [AppLanguage.Ja] = "競合ポリシー",
            [AppLanguage.Ko] = "충돌 정책",
            [AppLanguage.Th] = "นโยบายความขัดแย้ง",
        },
        ["settings_conflict_keep_both"] = new()
        {
            [AppLanguage.ZhHant] = "保留兩份（預設）",
            [AppLanguage.ZhHans] = "保留两份（默认）",
            [AppLanguage.En] = "Keep Both (Default)",
            [AppLanguage.Ja] = "両方を保持（既定）",
            [AppLanguage.Ko] = "둘 다 유지(기본)",
            [AppLanguage.Th] = "เก็บทั้งสองไฟล์ (ค่าเริ่มต้น)",
        },
        ["settings_conflict_keep_both_desc"] = new()
        {
            [AppLanguage.ZhHant] = "發生衝突時保留兩份，額外複本留在本地。",
            [AppLanguage.ZhHans] = "发生冲突时保留两份，额外复本留在本地。",
            [AppLanguage.En] = "Keep both copies upon conflict, saving conflict copies locally.",
            [AppLanguage.Ja] = "競合時は両方を残し、ローカルにコピーを保存します。",
            [AppLanguage.Ko] = "충돌 시 양쪽을 모두 보존하고 로컬에 사본을 남깁니다.",
            [AppLanguage.Th] = "เมื่อเกิดความขัดแย้งจะเก็บทั้งสองไฟล์ไว้ โดยสร้างสำเนาในเครื่อง",
        },
        ["settings_conflict_newer_wins"] = new()
        {
            [AppLanguage.ZhHant] = "採用較新的",
            [AppLanguage.ZhHans] = "采用较新的",
            [AppLanguage.En] = "Newer Wins",
            [AppLanguage.Ja] = "新しい方を優先",
            [AppLanguage.Ko] = "최신 버전 우선",
            [AppLanguage.Th] = "ใช้ไฟล์ที่ใหม่กว่า",
        },
        ["settings_conflict_newer_wins_desc"] = new()
        {
            [AppLanguage.ZhHant] = "修改時間較新者勝出，較舊版本封存至舊版本。",
            [AppLanguage.ZhHans] = "修改时间较新者胜出，较旧版本归档至旧版本。",
            [AppLanguage.En] = "Newer modification time wins; older version archived to history.",
            [AppLanguage.Ja] = "更新日時が新しい方が優先され、古い方は履歴へアーカイブされます。",
            [AppLanguage.Ko] = "더 최근에 수정된 쪽이 우선되며 이전 버전은 기록으로 보관됩니다.",
            [AppLanguage.Th] = "ไฟล์ที่แก้ไขล่าสุดจะเป็นฝ่ายชนะ ไฟล์เดิมจะถูกเก็บในประวัติ",
        },
        ["settings_exclude_title"] = new()
        {
            [AppLanguage.ZhHant] = "排除規則",
            [AppLanguage.ZhHans] = "排除规则",
            [AppLanguage.En] = "Exclusion Rules",
            [AppLanguage.Ja] = "除外ルール",
            [AppLanguage.Ko] = "제외 규칙",
            [AppLanguage.Th] = "กฎการยกเว้น",
        },
        ["settings_exclude_desc"] = new()
        {
            [AppLanguage.ZhHant] = "預設排除項目，避免同步暫存檔與編譯快取。",
            [AppLanguage.ZhHans] = "预设排除项目，避免同步临时文件与编译缓存。",
            [AppLanguage.En] = "Exclude temporary files and build caches from synchronization.",
            [AppLanguage.Ja] = "一時ファイルやビルドキャッシュを同期から除外します。",
            [AppLanguage.Ko] = "임시 파일 및 빌드 캐시를 동기화에서 제외합니다.",
            [AppLanguage.Th] = "ยกเว้นไฟล์ชั่วคราวและแคชการสร้างจากการซิงค์",
        },
        ["settings_nested_groups_title"] = new()
        {
            [AppLanguage.ZhHant] = "巢狀群組自動排除",
            [AppLanguage.ZhHans] = "嵌套群组自动排除",
            [AppLanguage.En] = "Auto-Exclude Nested Groups",
            [AppLanguage.Ja] = "入れ子グループの自動除外",
            [AppLanguage.Ko] = "중첩 그룹 자동 제외",
            [AppLanguage.Th] = "ยกเว้นกลุ่มที่ซ้อนกันโดยอัตโนมัติ",
        },
        ["settings_cloud_space_saving_title"] = new()
        {
            [AppLanguage.ZhHant] = "雲端省空間",
            [AppLanguage.ZhHans] = "云端省空间",
            [AppLanguage.En] = "Cloud Space Saving",
            [AppLanguage.Ja] = "クラウドの容量節約",
            [AppLanguage.Ko] = "클라우드 공간 절약",
            [AppLanguage.Th] = "ประหยัดพื้นที่คลาวด์",
        },
        ["preset_node_modules"] = new()
        {
            [AppLanguage.ZhHant] = "node_modules（套件資料夾）",
            [AppLanguage.ZhHans] = "node_modules（包文件夹）",
            [AppLanguage.En] = "node_modules (Packages)",
            [AppLanguage.Ja] = "node_modules (パッケージ)",
            [AppLanguage.Ko] = "node_modules (패키지)",
            [AppLanguage.Th] = "node_modules (แพ็กเกจ)",
        },
        ["preset_git"] = new()
        {
            [AppLanguage.ZhHant] = ".git（版本控制資料夾）",
            [AppLanguage.ZhHans] = ".git（版本控制文件夹）",
            [AppLanguage.En] = ".git (Git Repository)",
            [AppLanguage.Ja] = ".git (バージョン管理)",
            [AppLanguage.Ko] = ".git (버전 관리)",
            [AppLanguage.Th] = ".git (การควบคุมเวอร์ชัน)",
        },
        ["preset_databases"] = new()
        {
            [AppLanguage.ZhHant] = "資料庫暫存檔（-wal、-shm、-journal）",
            [AppLanguage.ZhHans] = "数据库临时文件（-wal、-shm、-journal）",
            [AppLanguage.En] = "Database Temporary Files (-wal, -shm, -journal)",
            [AppLanguage.Ja] = "データベース一時ファイル (-wal, -shm, -journal)",
            [AppLanguage.Ko] = "데이터베이스 임시 파일 (-wal, -shm, -journal)",
            [AppLanguage.Th] = "ไฟล์ชั่วคราวของฐานข้อมูล (-wal, -shm, -journal)",
        },
        ["preset_photos"] = new()
        {
            [AppLanguage.ZhHant] = "照片圖庫（.photoslibrary）",
            [AppLanguage.ZhHans] = "照片图库（.photoslibrary）",
            [AppLanguage.En] = "Photos Library (.photoslibrary)",
            [AppLanguage.Ja] = "写真ライブラリ (.photoslibrary)",
            [AppLanguage.Ko] = "사진 보관함 (.photoslibrary)",
            [AppLanguage.Th] = "คลังรูปภาพ (.photoslibrary)",
        },
        ["preset_build_caches"] = new()
        {
            [AppLanguage.ZhHant] = "專案編譯快取（.build、build、target、bin、obj）",
            [AppLanguage.ZhHans] = "项目编译缓存（.build、build、target、bin、obj）",
            [AppLanguage.En] = "Build Caches (.build, build, target, bin, obj)",
            [AppLanguage.Ja] = "ビルドキャッシュ (.build, build, target, bin, obj)",
            [AppLanguage.Ko] = "빌드 캐시 (.build, build, target, bin, obj)",
            [AppLanguage.Th] = "แคชการสร้าง (.build, build, target, bin, obj)",
        },
        ["preset_python"] = new()
        {
            [AppLanguage.ZhHant] = "Python 虛擬環境與快取（venv、.venv、__pycache__）",
            [AppLanguage.ZhHans] = "Python 虚拟环境与缓存（venv、.venv、__pycache__）",
            [AppLanguage.En] = "Python Environments & Cache (venv, .venv, __pycache__)",
            [AppLanguage.Ja] = "Python 仮想環境・キャッシュ (venv, .venv, __pycache__)",
            [AppLanguage.Ko] = "Python 가상 환경 및 캐시 (venv, .venv, __pycache__)",
            [AppLanguage.Th] = "สภาพแวดล้อมและแคช Python (venv, .venv, __pycache__)",
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
