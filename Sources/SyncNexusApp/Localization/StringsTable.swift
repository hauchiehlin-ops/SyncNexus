import Foundation

public let StringsTable: [String: [AppLanguage: String]] = [
    // App info & common
    "app_name": [
        .en: "Sync-Nexus",
        .zhHant: "Sync-Nexus",
        .zhHans: "Sync-Nexus",
        .ja: "Sync-Nexus",
        .th: "Sync-Nexus",
        .ko: "Sync-Nexus"
    ],
    "ok": [
        .en: "OK",
        .zhHant: "好",
        .zhHans: "好",
        .ja: "OK",
        .th: "ตกลง",
        .ko: "확인"
    ],
    "cancel": [
        .en: "Cancel",
        .zhHant: "取消",
        .zhHans: "取消",
        .ja: "キャンセル",
        .th: "ยกเลิก",
        .ko: "취소"
    ],
    "done": [
        .en: "Done",
        .zhHant: "完成",
        .zhHans: "完成",
        .ja: "完了",
        .th: "เสร็จสิ้น",
        .ko: "완료"
    ],
    "next": [
        .en: "Next",
        .zhHant: "下一步",
        .zhHans: "下一步",
        .ja: "次へ",
        .th: "ถัดไป",
        .ko: "다음"
    ],
    "back": [
        .en: "Back",
        .zhHant: "上一步",
        .zhHans: "上一步",
        .ja: "戻る",
        .th: "ย้อนกลับ",
        .ko: "이전"
    ],
    "start_setup": [
        .en: "Start Setup",
        .zhHant: "開始設定",
        .zhHans: "开始设置",
        .ja: "設定を開始",
        .th: "เริ่มการตั้งค่า",
        .ko: "설정 시작"
    ],
    "choose": [
        .en: "Choose",
        .zhHant: "選擇",
        .zhHans: "选择",
        .ja: "選択",
        .th: "เลือก",
        .ko: "선택"
    ],
    "remove": [
        .en: "Remove…",
        .zhHant: "移除…",
        .zhHans: "移除…",
        .ja: "削除…",
        .th: "ลบออก…",
        .ko: "제거…"
    ],
    "change_folder": [
        .en: "Change Folder…",
        .zhHant: "更換資料夾…",
        .zhHans: "更换文件夹…",
        .ja: "フォルダを変更…",
        .th: "เปลี่ยนโฟลเดอร์…",
        .ko: "폴더 변경…"
    ],
    "show_history": [
        .en: "Show History",
        .zhHant: "顯示歷史",
        .zhHans: "显示历史",
        .ja: "履歴を表示",
        .th: "แสดงประวัติ",
        .ko: "히스토리 표시"
    ],

    // Sections
    "section_overview": [
        .en: "Overview",
        .zhHant: "概覽",
        .zhHans: "概览",
        .ja: "概要",
        .th: "ภาพรวม",
        .ko: "개요"
    ],
    "section_diff_preview": [
        .en: "Diff Preview",
        .zhHant: "差異預覽",
        .zhHans: "差异预览",
        .ja: "差分プレビュー",
        .th: "ดูตัวอย่างความแตกต่าง",
        .ko: "차이 미리보기"
    ],
    "section_folders": [
        .en: "Folders",
        .zhHant: "資料夾",
        .zhHans: "文件夹",
        .ja: "フォルダ",
        .th: "โฟลเดอร์",
        .ko: "폴더"
    ],
    "section_conflicts": [
        .en: "Conflicts",
        .zhHant: "衝突",
        .zhHans: "冲突",
        .ja: "競合",
        .th: "ข้อขัดแย้ง",
        .ko: "충돌"
    ],
    "section_versions": [
        .en: "Old Versions",
        .zhHant: "舊版本",
        .zhHans: "旧版本",
        .ja: "以前のバージョン",
        .th: "เวอร์ชันก่อนหน้า",
        .ko: "이전 버전"
    ],
    "section_verification": [
        .en: "Verification Log",
        .zhHant: "驗證紀錄",
        .zhHans: "验证记录",
        .ja: "検証ログ",
        .th: "บันทึกการตรวจสอบ",
        .ko: "검증 기록"
    ],
    "section_settings": [
        .en: "Settings",
        .zhHant: "設定",
        .zhHans: "设置",
        .ja: "設定",
        .th: "การตั้งค่า",
        .ko: "설정"
    ],

    // Status titles & details
    "status_starting": [
        .en: "Starting up…",
        .zhHant: "正在啟動…",
        .zhHans: "正在启动…",
        .ja: "起動中…",
        .th: "กำลังเริ่มต้น…",
        .ko: "시작 중…"
    ],
    "status_ok": [
        .en: "All in sync",
        .zhHant: "全部已同步",
        .zhHans: "全部已同步",
        .ja: "すべて同期済み",
        .th: "ซิงค์ทั้งหมดเรียบร้อย",
        .ko: "모두 동기화됨"
    ],
    "status_partial": [
        .en: "Some folders offline",
        .zhHant: "部分資料夾離線",
        .zhHans: "部分文件夹离线",
        .ja: "一部のフォルダがオフライン",
        .th: "โฟลเดอร์บางส่วนออฟไลน์",
        .ko: "일부 폴더 오프라인"
    ],
    "status_syncing": [
        .en: "Syncing…",
        .zhHant: "同步中…",
        .zhHans: "同步中…",
        .ja: "同期中…",
        .th: "กำลังซิงค์…",
        .ko: "동기화 중…"
    ],
    "status_paused": [
        .en: "Paused",
        .zhHant: "已暫停",
        .zhHans: "已暂停",
        .ja: "一時停止中",
        .th: "หยุดชั่วคราว",
        .ko: "일시 중지됨"
    ],
    "status_error": [
        .en: "Sync error occurred",
        .zhHant: "同步發生錯誤",
        .zhHans: "同步发生错误",
        .ja: "同期エラーが発生しました",
        .th: "เกิดข้อผิดพลาดในการซิงค์",
        .ko: "동기화 오류 발생"
    ],
    "status_need_confirm": [
        .en: "Confirmation required",
        .zhHant: "需要你確認",
        .zhHans: "需要你确认",
        .ja: "確認が必要です",
        .th: "ต้องการการยืนยัน",
        .ko: "확인 필요"
    ],
    "status_conflicts_pending": [
        .en: "%d conflicts awaiting decision",
        .zhHant: "%d 個衝突等你決定",
        .zhHans: "%d 个冲突等你决定",
        .ja: "%d 件の競合の解決待ち",
        .th: "%d ข้อขัดแย้งรอการตัดสินใจ",
        .ko: "%d개의 충돌 해결 대기 중"
    ],
    "status_need_check": [
        .en: "Files require review",
        .zhHant: "有檔案需要檢查",
        .zhHans: "有文件需要检查",
        .ja: "確認が必要なファイルがあります",
        .th: "มีไฟล์ที่ต้องตรวจสอบ",
        .ko: "확인이 필요한 파일이 있습니다"
    ],
    "status_detail_syncing": [
        .en: "Comparing and updating folders",
        .zhHant: "正在比對並更新各個資料夾",
        .zhHans: "正在比对并更新各个文件夹",
        .ja: "フォルダを比較および更新中",
        .th: "กำลังเปรียบเทียบและอัปเดตโฟลเดอร์",
        .ko: "폴더 비교 및 업데이트 중"
    ],
    "status_detail_paused": [
        .en: "Click Resume to restart automatic sync",
        .zhHant: "按「繼續」恢復自動同步",
        .zhHans: "按“继续”恢复自动同步",
        .ja: "「再開」をクリックして同期を再開",
        .th: "กดปุ่มเล่นต่อเพื่อดำเนินการซิงค์อัตโนมัติ",
        .ko: "'계속'을 눌러 자동 동기화 재개"
    ],

    // P2P & Peer Discovery
    "p2p_section_title": [
        .en: "Local Wi-Fi Devices (P2P Zero-Cloud)",
        .zhHant: "同 Wi-Fi 近端設備 (P2P 局域網直連)",
        .zhHans: "同 Wi-Fi 局域网近端设备 (P2P 直连)",
        .ja: "同一 Wi-Fi 近隣デバイス (P2P 直接接続)",
        .th: "อุปกรณ์ในเครือข่าย Wi-Fi เดียวกัน (P2P โดยตรง)",
        .ko: "동일 Wi-Fi 주변 기기 (P2P 직접 연결)"
    ],
    "p2p_empty_hint": [
        .en: "Open Sync-Nexus on another Mac or Android device on the same Wi-Fi to establish a direct local connection.",
        .zhHant: "在同一 Wi-Fi 開啟 Mac 或 Android 設備的 Sync-Nexus，將自動在此顯示並建立直連。",
        .zhHans: "在同一 Wi-Fi 开启 Mac 或 Android 设备的 Sync-Nexus，将自动在此显示并建立直连。",
        .ja: "同一 Wi-Fi 内で Mac または Android の Sync-Nexus を開くと、直接接続が確立されます。",
        .th: "เปิด Sync-Nexus บน Mac หรือ Android ในเครือข่าย Wi-Fi เดียวกันเพื่อสร้างการเชื่อมต่อโดยตรง",
        .ko: "동일한 Wi-Fi에서 Mac 또는 Android 기기의 Sync-Nexus를 실행하면 자동으로 감지되어 직접 연결됩니다."
    ],
    "p2p_searching": [
        .en: "Searching…",
        .zhHant: "搜尋中…",
        .zhHans: "搜寻中…",
        .ja: "検索中…",
        .th: "กำลังค้นหา…",
        .ko: "검색 중…"
    ],
    "p2p_found": [
        .en: "Found %d",
        .zhHant: "已發現 %d 台",
        .zhHans: "已发现 %d 台",
        .ja: "%d 台検出",
        .th: "พบ %d เครื่อง",
        .ko: "%d대 발견"
    ],

    // Folders
    "folders_desc": [
        .en: "These folders will stay synchronized: additions, edits, deletions, or renames will replicate across all. Deleted files move to Trash.",
        .zhHant: "這些資料夾會互相保持一致：任一個有新增、修改、刪除或改名，其他的都會跟著變。刪除的檔案先進垃圾桶。",
        .zhHans: "这些文件夹会互相保持一致：任一个有新增、修改、删除或改名，其他的都会跟着变。删除的文件先进废纸篓。",
        .ja: "これらのフォルダは同期されます。追加、変更、削除、名前変更はすべて反映されます。削除されたファイルはゴミ箱に移動します。",
        .th: "โฟลเดอร์เหล่านี้จะซิงค์ข้อมูลให้ตรงกัน: เมื่อมีการเพิ่ม แก้ไข ลบ หรือเปลี่ยนชื่อ ไฟล์อื่นๆ จะเปลี่ยนตาม ไฟล์ที่ถูกลบจะย้ายไปที่ถังขยะ",
        .ko: "이 폴더들은 동기화 상태를 유지합니다. 추가, 수정, 삭제, 이름 변경이 모두 반영됩니다. 삭제된 파일은 휴지통으로 이동합니다."
    ],
    "folders_empty_hint": [
        .en: "No folders added yet. Recommended sequence: Local folder, iCloud Drive folder, Google Drive folder, external drive folder.",
        .zhHant: "還沒有加入資料夾。建議依序加入：本機資料夾、iCloud 雲碟裡的資料夾、Google Drive 裡的資料夾、外接磁碟裡的資料夾。",
        .zhHans: "还没有添加文件夹。建议依序添加：本地文件夹、iCloud 云盘里的文件夹、Google Drive 里的文件夹、外接移动硬盘里的文件夹。",
        .ja: "フォルダが追加されていません。ローカル、iCloud Drive、Google Drive、外付けドライブの順に追加することをお勧めします。",
        .th: "ยังไม่ได้เพิ่มโฟลเดอร์ แนะนำให้เพิ่มตามลำดับ: โฟลเดอร์ในเครื่อง, โฟลเดอร์ใน iCloud Drive, Google Drive หรือไดรฟ์ภายนอก",
        .ko: "아직 추가된 폴더가 없습니다. 로컬 폴더, iCloud Drive 폴더, Google Drive 폴더, 외장 드라이브 폴더 순서로 추가하는 것을 권장합니다."
    ],
    "folders_add_button": [
        .en: "Add Folder…",
        .zhHant: "加入資料夾…",
        .zhHans: "添加文件夹…",
        .ja: "フォルダを追加…",
        .th: "เพิ่มโฟลเดอร์…",
        .ko: "폴더 추가…"
    ],
    "folders_minimum_warning": [
        .en: "At least two folders are required to start synchronization.",
        .zhHant: "至少需要兩個資料夾才會開始同步。",
        .zhHans: "至少需要两个文件夹才会开始同步。",
        .ja: "同期を開始するには少なくとも2つのフォルダが必要です。",
        .th: "ต้องมีอย่างน้อยสองโฟลเดอร์จึงจะเริ่มการซิงค์ได้",
        .ko: "동기화를 시작하려면 최소 2개의 폴더가 필요합니다."
    ],

    // Endpoint badges
    "online": [
        .en: "Online",
        .zhHant: "在線",
        .zhHans: "在线",
        .ja: "オンライン",
        .th: "ออนไลน์",
        .ko: "온라인"
    ],
    "offline": [
        .en: "Offline",
        .zhHant: "離線",
        .zhHans: "离线",
        .ja: "オフライン",
        .th: "ออฟไลน์",
        .ko: "오프라인"
    ],
    "archive_badge": [
        .en: "Archive: Receive Only",
        .zhHant: "備份：只接收",
        .zhHans: "备份：只接收",
        .ja: "アーカイブ：受信のみ",
        .th: "เก็บถาวร: รับเท่านั้น",
        .ko: "아카이브: 수신 전용"
    ],
    "removable_badge": [
        .en: "Removable",
        .zhHant: "可移除",
        .zhHans: "可移除",
        .ja: "取り外し可能",
        .th: "ถอดออกได้",
        .ko: "이동식"
    ],
    "portable_badge": [
        .en: "exFAT/Windows Compatible",
        .zhHant: "檔名相容 exFAT／Windows",
        .zhHans: "文件名兼容 exFAT／Windows",
        .ja: "exFAT/Windows 互換",
        .th: "เข้ากันได้กับ exFAT/Windows",
        .ko: "exFAT/Windows 호환 파일명"
    ],

    // Endpoint Kinds
    "kind_local": [
        .en: "Local",
        .zhHant: "本機",
        .zhHans: "本地",
        .ja: "ローカル",
        .th: "ในเครื่อง",
        .ko: "로컬"
    ],
    "kind_icloud": [
        .en: "iCloud Drive",
        .zhHant: "iCloud 雲碟",
        .zhHans: "iCloud 云盘",
        .ja: "iCloud Drive",
        .th: "iCloud Drive",
        .ko: "iCloud Drive"
    ],
    "kind_gdrive": [
        .en: "Google Drive",
        .zhHant: "Google Drive",
        .zhHans: "Google Drive",
        .ja: "Google Drive",
        .th: "Google Drive",
        .ko: "Google Drive"
    ],
    "kind_external": [
        .en: "External Drive",
        .zhHant: "外接磁碟",
        .zhHans: "外接磁盘",
        .ja: "外付けドライブ",
        .th: "ไดรฟ์ภายนอก",
        .ko: "외장 드라이브"
    ],

    // Diff preview & Trial Run
    "diff_preview_title": [
        .en: "Visual Diff Trial Run",
        .zhHant: "智慧差異預覽（試跑）",
        .zhHans: "智能差异预览（试跑）",
        .ja: "差分プレビュー（テスト実行）",
        .th: "ดูตัวอย่างความแตกต่าง (ทดลองรัน)",
        .ko: "스마트 차이 미리보기 (시험 실행)"
    ],
    "diff_preview_desc": [
        .en: "Perform a simulated trial run before modifying disk contents. Verify proposed file copies, moves, and deletions with zero risk.",
        .zhHant: "在正式寫入磁碟前執行模擬對帳試跑，檢視預計複製、改名與刪除的項目，零風險確認安全無虞。",
        .zhHans: "在正式写入磁盘前执行模拟对账试跑，检视预计复制、改名与删除的项目，零风险确认安全无虞。",
        .ja: "ディスクに変更を加える前にシミュレーションを実行し、コピー、名前変更、削除の安全性を確認します。",
        .th: "ดำเนินการทดลองรันจำลองก่อนแก้ไขข้อมูลจริงบนดิสก์ ตรวจสอบการคัดลอก ย้าย และลบได้โดยไม่มีความเสี่ยง",
        .ko: "디스크에 실제로 기록하기 전 시뮬레이션 시험 실행을 통해 복사, 변경, 삭제될 항목을 안전하게 사전 검토합니다."
    ],
    "btn_run_trial": [
        .en: "Run Trial Simulation",
        .zhHant: "執行試跑模擬",
        .zhHans: "执行试跑模拟",
        .ja: "テスト実行を開始",
        .th: "เริ่มการจำลองทดลองรัน",
        .ko: "시험 실행 시뮬레이션 시작"
    ],
    "btn_running_trial": [
        .en: "Analyzing Differences…",
        .zhHant: "正在分析差異…",
        .zhHans: "正在分析差异…",
        .ja: "差分を分析中…",
        .th: "กำลังวิเคราะห์ความแตกต่าง…",
        .ko: "차이 분석 중…"
    ],
    "diff_no_changes": [
        .en: "All folders are perfectly in sync. No actions required.",
        .zhHant: "所有資料夾內容完全一致，無需執行任何同步操作。",
        .zhHans: "所有文件夹内容完全一致，无需执行任何同步操作。",
        .ja: "すべてのフォルダが同期されています。変更は不要です。",
        .th: "ทุกโฟลเดอร์ซิงค์ข้อมูลตรงกันเรียบร้อยแล้ว ไม่จำเป็นต้องดำเนินการใดๆ",
        .ko: "모든 폴더의 내용이 일치합니다. 동기화할 작업이 없습니다."
    ],

    // Settings
    "settings_language": [
        .en: "Language",
        .zhHant: "介面語系",
        .zhHans: "界面语言",
        .ja: "言語",
        .th: "ภาษา",
        .ko: "언어"
    ],
    "settings_launch_at_login": [
        .en: "Start at Login",
        .zhHant: "開機自動啟動",
        .zhHans: "开机自动启动",
        .ja: "ログイン時に起動",
        .th: "เปิดอัตโนมัติเมื่อเข้าสู่ระบบ",
        .ko: "로그인 시 자동 실행"
    ],
    "settings_sync_interval": [
        .en: "Sync Frequency",
        .zhHant: "同步頻率",
        .zhHans: "同步频率",
        .ja: "同期頻度",
        .th: "ความถี่ในการซิงค์",
        .ko: "동기화 주기"
    ],
    "settings_safe_delete": [
        .en: "Safe Deletion (Move to Trash)",
        .zhHant: "安全刪除（移至垃圾桶）",
        .zhHans: "安全删除（移至废纸篓）",
        .ja: "安全な削除（ゴミ箱へ移動）",
        .th: "ลบอย่างปลอดภัย (ย้ายไปถังขยะ)",
        .ko: "안전 삭제 (휴지통으로 이동)"
    ],
    "settings_apfs_snapshot": [
        .en: "APFS Snapshot Safety Guard",
        .zhHant: "APFS 快照安全防護",
        .zhHans: "APFS 快照安全防护",
        .ja: "APFS スナップショット保護",
        .th: "การป้องกันความปลอดภัยด้วย APFS Snapshot",
        .ko: "APFS 스냅샷 안전 보호"
    ],

    // Operations
    "op_copy": [
        .en: "Updated",
        .zhHant: "已更新",
        .zhHans: "已更新",
        .ja: "更新済み",
        .th: "อัปเดตแล้ว",
        .ko: "업데이트됨"
    ],
    "op_move": [
        .en: "Renamed",
        .zhHant: "已改名",
        .zhHans: "已改名",
        .ja: "名前変更済み",
        .th: "เปลี่ยนชื่อแล้ว",
        .ko: "이름 변경됨"
    ],
    "op_trash": [
        .en: "Moved to Trash",
        .zhHant: "已移到垃圾桶",
        .zhHans: "已移至废纸篓",
        .ja: "ゴミ箱へ移動済み",
        .th: "ย้ายไปที่ถังขยะแล้ว",
        .ko: "휴지통으로 이동됨"
    ],
    "op_mkdir": [
        .en: "Directory Created",
        .zhHant: "已建立資料夾",
        .zhHans: "已创建文件夹",
        .ja: "フォルダ作成済み",
        .th: "สร้างโฟลเดอร์แล้ว",
        .ko: "폴더 생성됨"
    ],
    "op_restore": [
        .en: "Restored Version",
        .zhHant: "已還原舊版本",
        .zhHans: "已还原旧版本",
        .ja: "旧バージョン復元済み",
        .th: "กู้คืนเวอร์ชันแล้ว",
        .ko: "이전 버전 복원됨"
    ],
    "op_conflict_rename": [
        .en: "Conflict - Kept Both Copies",
        .zhHant: "衝突，已保留兩份",
        .zhHans: "冲突，已保留两份",
        .ja: "競合、両方を保持",
        .th: "ข้อขัดแย้ง - เก็บทั้งสองฉบับ",
        .ko: "충돌 발생 - 양쪽 버전 보존"
    ],
    "op_conflict_resolved": [
        .en: "Conflict Resolved",
        .zhHant: "衝突已處理",
        .zhHans: "冲突已处理",
        .ja: "競合解決済み",
        .th: "แก้ไขข้อขัดแย้งแล้ว",
        .ko: "충돌 해결됨"
    ]
]
