import Foundation

public let StringsTable: [String: [AppLanguage: String]] = [
    "app_name": [
        .en: "Sync-Nexus",
        .zhHant: "Sync-Nexus",
        .zhHans: "Sync-Nexus",
        .ja: "Sync-Nexus",
        .th: "Sync-Nexus",
        .ko: "Sync-Nexus"
    ],
    "menu_user_manual": [
        .en: "Manual",
        .zhHant: "操作手冊",
        .zhHans: "操作手册",
        .ja: "説明書",
        .th: "คู่มือ",
        .ko: "설명서"
    ],
    "privacy_policy_title": [
        .en: "Privacy",
        .zhHant: "隱私政策",
        .zhHans: "隐私政策",
        .ja: "プライバシー",
        .th: "ความเป็นส่วนตัว",
        .ko: "개인정보"
    ],
    "app_version_build": [
        .en: "Version %1$@ (build %2$@)",
        .zhHant: "版本 %1$@（build %2$@）",
        .zhHans: "版本 %1$@（build %2$@）",
        .ja: "バージョン %1$@ (ビルド %2$@)",
        .th: "เวอร์ชัน %1$@ (บิลด์ %2$@)",
        .ko: "버전 %1$@ (빌드 %2$@)"
    ],
    "archive_badge": [
        .en: "Archive: Receive Only",
        .zhHant: "備份：只接收",
        .zhHans: "备份：只接收",
        .ja: "アーカイブ：受信のみ",
        .th: "เก็บถาวร: รับเท่านั้น",
        .ko: "아카이브: 수신 전용"
    ],
    "archive_retention_desc": [
        .en: "Stored in .syncnexus-history inside each archive folder.",
        .zhHant: "存在各備份資料夾內的 .syncnexus-history。",
        .zhHans: "存在各备份文件夹内的 .syncnexus-history。",
        .ja: "各アーカイブフォルダ内の .syncnexus-history に保存。",
        .th: "จัดเก็บใน .syncnexus-history ภายในแต่ละโฟลเดอร์เก็บถาวร",
        .ko: "각 아카이브 폴더 내부의 .syncnexus-history에 저장됩니다."
    ],
    "archive_retention_label": [
        .en: "Archive History: Keep",
        .zhHant: "備份資料夾的歷史：保留",
        .zhHans: "备份文件夹的历史：保留",
        .ja: "アーカイブ履歴: 保持",
        .th: "ประวัติโฟลเดอร์เก็บถาวร: เก็บไว้",
        .ko: "아카이브 히스토리: 보관"
    ],
    "activity_all_groups": [
        .en: "All Groups",
        .zhHant: "全部群組",
        .zhHans: "全部群组",
        .ja: "すべてのグループ",
        .th: "ทุกกลุ่ม",
        .ko: "모든 그룹"
    ],
    "activity_clear_logs": [
        .en: "Clear Logs",
        .zhHant: "清除紀錄",
        .zhHans: "清除记录",
        .ja: "ログをクリア",
        .th: "ล้างบันทึก",
        .ko: "기록 지우기"
    ],
    "activity_export_logs": [
        .en: "Export Logs",
        .zhHant: "匯出紀錄",
        .zhHans: "导出记录",
        .ja: "ログを出力",
        .th: "ส่งออกบันทึก",
        .ko: "기록 내보내기"
    ],
    "activity_auto_scroll": [
        .en: "Auto-scroll to latest",
        .zhHant: "自動滾動至最新事件",
        .zhHans: "自动滚动至最新事件",
        .ja: "最新のイベントへ自動スクロール",
        .th: "เลื่อนไปยังเหตุการณ์ล่าสุดอัตโนมัติ",
        .ko: "최신 이벤트로 자동 스크롤"
    ],
    "activity_search_placeholder": [
        .en: "Search path, action, endpoint…",
        .zhHant: "搜尋檔案路徑、動作或端點…",
        .zhHans: "搜索文件路径、动作或端点…",
        .ja: "パス、アクション、エンドポイントを検索…",
        .th: "ค้นหาเส้นทาง การทำงาน หรือปลายทาง…",
        .ko: "경로, 동작, 엔드포인트 검색…"
    ],
    "activity_col_time": [
        .en: "Time",
        .zhHant: "時間",
        .zhHans: "时间",
        .ja: "時刻",
        .th: "เวลา",
        .ko: "시간"
    ],
    "activity_col_group": [
        .en: "Group",
        .zhHant: "群組",
        .zhHans: "群组",
        .ja: "グループ",
        .th: "กลุ่ม",
        .ko: "그룹"
    ],
    "activity_col_filename": [
        .en: "File Name",
        .zhHant: "傳輸檔名",
        .zhHans: "传输文件名",
        .ja: "ファイル名",
        .th: "ชื่อไฟล์",
        .ko: "파일명"
    ],
    "activity_col_direction": [
        .en: "Sync Direction",
        .zhHant: "同步方向",
        .zhHans: "同步方向",
        .ja: "同期方向",
        .th: "ทิศทางการซิงค์",
        .ko: "동기화 방향"
    ],
    "activity_col_action": [
        .en: "Action",
        .zhHant: "狀態 / 動作",
        .zhHans: "状态 / 动作",
        .ja: "アクション",
        .th: "การทำงาน",
        .ko: "동작"
    ],
    "activity_col_size": [
        .en: "Size",
        .zhHant: "大小",
        .zhHans: "大小",
        .ja: "サイズ",
        .th: "ขนาด",
        .ko: "크기"
    ],
    "activity_col_speed": [
        .en: "Speed",
        .zhHant: "傳輸速度",
        .zhHans: "传输速度",
        .ja: "転送速度",
        .th: "ความเร็ว",
        .ko: "속도"
    ],
    "activity_col_duration": [
        .en: "Duration",
        .zhHant: "耗時",
        .zhHans: "耗时",
        .ja: "所要時間",
        .th: "เวลาที่ใช้",
        .ko: "소요 시간"
    ],
    "activity_col_path": [
        .en: "Path",
        .zhHant: "檔案路徑",
        .zhHans: "文件路径",
        .ja: "パス",
        .th: "เส้นทางไฟล์",
        .ko: "파일 경로"
    ],
    "activity_empty_hint": [
        .en: "No sync events recorded yet. Activity will stream here live when files are synced.",
        .zhHant: "目前尚未有同步事件。檔案進行同步時，將在此處即時滾動顯示。",
        .zhHans: "目前尚未有同步事件。文件进行同步时，将在此处实时滚动显示。",
        .ja: "同期イベントはまだありません。ファイルが同期されると、ここにリアルタイムで表示されます。",
        .th: "ยังไม่มีประวัติการซิงค์ เมื่อเริ่มซิงค์ไฟล์ ข้อมูลจะแสดงที่นี่แบบเรียลไทม์",
        .ko: "아직 동기화 이벤트가 없습니다. 파일이 동기화되면 실시간으로 여기에 표시됩니다."
    ],
    "status_completed_tag": [
        .en: "Completed",
        .zhHant: "完成",
        .zhHans: "完成",
        .ja: "完了",
        .th: "เสร็จสมบูรณ์",
        .ko: "완료"
    ],
    "badge_recommended": [
        .en: "Recommended",
        .zhHant: "推薦",
        .zhHans: "推荐",
        .ja: "おすすめ",
        .th: "แนะนำ",
        .ko: "추천"
    ],
    "back": [
        .en: "Back",
        .zhHant: "上一步",
        .zhHans: "上一步",
        .ja: "戻る",
        .th: "ย้อนกลับ",
        .ko: "이전"
    ],
    "btn_reveal_in_finder": [
        .en: "Reveal in Finder",
        .zhHant: "在 Finder 顯示",
        .zhHans: "在访达中显示",
        .ja: "Finderで表示",
        .th: "แสดงใน Finder",
        .ko: "Finder에서 보기"
    ],
    "btn_review_confirm": [
        .en: "Review and confirm…",
        .zhHant: "查看預覽並確認…",
        .zhHans: "查看预览并确认…",
        .ja: "プレビューを確認…",
        .th: "ตรวจสอบและยืนยัน…",
        .ko: "미리보기 검토 및 확인…"
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
    "cancel": [
        .en: "Cancel",
        .zhHant: "取消",
        .zhHans: "取消",
        .ja: "キャンセル",
        .th: "ยกเลิก",
        .ko: "취소"
    ],
    "change_folder": [
        .en: "Change Folder…",
        .zhHant: "更換資料夾…",
        .zhHans: "更换文件夹…",
        .ja: "フォルダを変更…",
        .th: "เปลี่ยนโฟลเดอร์…",
        .ko: "폴더 변경…"
    ],
    "choose": [
        .en: "Choose",
        .zhHant: "選擇",
        .zhHans: "选择",
        .ja: "選択",
        .th: "เลือก",
        .ko: "선택"
    ],
    "close": [
        .en: "Close",
        .zhHant: "關閉",
        .zhHans: "关闭",
        .ja: "閉じる",
        .th: "ปิด",
        .ko: "닫기"
    ],
    "conflicts_consistent_note": [
        .en: "Consistent with other folders",
        .zhHant: "與其他資料夾一致",
        .zhHans: "与其他文件夹一致",
        .ja: "他のフォルダと一致",
        .th: "ตรงกับโฟลเดอร์อื่น",
        .ko: "다른 폴더와 일치"
    ],
    "conflicts_current_version": [
        .en: "Current Version",
        .zhHant: "目前的版本",
        .zhHans: "当前的版本",
        .ja: "現在のバージョン",
        .th: "เวอร์ชันปัจจุบัน",
        .ko: "현재 버전"
    ],
    "conflicts_duplicate_differs_from": [
        .en: "Differs from \"%1$@\" · %2$@",
        .zhHant: "與「%1$@」內容不同　· %2$@",
        .zhHans: "与“%1$@”内容不同　· %2$@",
        .ja: "「%1$@」と内容が異なります · %2$@",
        .th: "เนื้อหาต่างจาก \"%1$@\" · %2$@",
        .ko: "'%1$@'와 내용이 다름 · %2$@"
    ],
    "conflicts_duplicate_hints_desc": [
        .en: "When iCloud or Google Drive detects simultaneous edits on multiple devices, it creates copies like \"filename 2\" or \"filename (1)\". The files below appear to be cloud copies; they sync normally and are not deleted automatically. Please review and choose which to keep.",
        .zhHant: "iCloud 或 Google Drive 在兩台裝置都修改同一個檔案時，會自己產生「檔名 2」或「檔名 (1)」這樣的副本。以下檔案看起來像這種情況；它們會正常同步，不會自動刪除，請自己確認要留哪一個。",
        .zhHans: "iCloud 或 Google Drive 在两台设备都修改同一个文件时，会自己产生“文件名 2”或“文件名 (1)”这样的副本。以下文件看起来像这种情况；它们会正常同步，不会自动删除，请自己确认要留哪一个。",
        .ja: "iCloud や Google Drive は複数端末で同一ファイルが編集されると「ファイル名 2」や「ファイル名 (1)」のようなコピーを生成します。以下はそのようなファイルです。正常に同期され自動削除はされません。",
        .th: "เมื่อ iCloud หรือ Google Drive ตรวจพบการแก้ไขพร้อมกัน จะสร้างสำเนาเช่น \"ชื่อไฟล์ 2\" ไฟล์เหล่านี้จะซิงค์ตามปกติและไม่ถูกลบอัตโนมัติ โปรดตรวจสอบด้วยตนเอง",
        .ko: "iCloud 또는 Google Drive는 여러 기기에서 동시 수정 시 '파일명 2' 같은 사본을 만듭니다. 아래 파일들은 이에 해당하며 정상 동기화되고 자동 삭제되지 않습니다."
    ],
    "conflicts_duplicate_hints_title": [
        .en: "Possible Cloud Conflict Copies",
        .zhHant: "可能的雲端衝突副本",
        .zhHans: "可能的云端冲突副本",
        .ja: "クラウド競合コピーの可能性",
        .th: "สำเนาข้อขัดแย้งบนคลาวด์ที่อาจเกิดขึ้น",
        .ko: "클라우드 충돌 복사본 감지"
    ],
    "conflicts_empty_desc": [
        .en: "When a file is modified on both sides simultaneously, it will appear here for you to choose which copy to keep.",
        .zhHant: "兩邊都改過同一個檔案時，會出現在這裡，由你決定留哪一份。",
        .zhHans: "两边都改过同一个文件时，会出现在这里，由你决定留哪一份。",
        .ja: "双方で同じファイルが変更された場合、ここに表示されどちらを保持するか選択できます。",
        .th: "เมื่อมีการแก้ไขไฟล์เดียวกันทั้งสองฝั่ง จะปรากฏที่นี่เพื่อให้คุณเลือกว่าจะเก็บฉบับใด",
        .ko: "양쪽에서 동일한 파일이 수정되면 여기에 표시되며 어느 버전을 유지할지 결정할 수 있습니다."
    ],
    "conflicts_empty_title": [
        .en: "No Pending Conflicts",
        .zhHant: "沒有待處理的衝突",
        .zhHans: "没有待处理的冲突",
        .ja: "保留中の競合はありません",
        .th: "ไม่มีข้อขัดแย้งที่ค้างอยู่",
        .ko: "보류 중인 충돌이 없습니다"
    ],
    "conflicts_endpoint_offline": [
        .en: "\"%@\" is currently offline. Connect it to resolve.",
        .zhHant: "「%@」目前離線，接回後才能處理。",
        .zhHans: "“%@”目前离线，接回后才能处理。",
        .ja: "「%@」は現在オフラインです。再接続後に解決できます。",
        .th: "\"%@\" กำลังออฟไลน์ เชื่อมต่อกลับเพื่อจัดการ",
        .ko: "'%@'이(가) 현재 오프라인입니다. 연결 후 해결할 수 있습니다."
    ],
    "conflicts_happened_on": [
        .en: "%1$@ · Occurred on \"%2$@\"",
        .zhHant: "%1$@　· 發生在「%2$@」",
        .zhHans: "%1$@　· 发生在“%2$@”",
        .ja: "%1$@ ·「%2$@」で発生",
        .th: "%1$@ · เกิดขึ้นที่ \"%2$@\"",
        .ko: "%1$@ · '%2$@'에서 발생"
    ],
    "conflicts_keep_this": [
        .en: "Keep This Copy",
        .zhHant: "保留這一份",
        .zhHans: "保留这一份",
        .ja: "こちらを保持",
        .th: "เก็บฉบับนี้ไว้",
        .ko: "이 버전 유지"
    ],
    "conflicts_sync_in_progress_queued": [
        .en: "Sync in progress. Resolution will be applied automatically once current task finishes.",
        .zhHant: "正在同步中，將於當前作業完成後自動套用",
        .zhHans: "正在同步中，将于当前作业完成后自动应用",
        .ja: "同期中です。現在の処理が完了次第、自動的に適用されます",
        .th: "กำลังซิงค์อยู่ จะมีผลโดยอัตโนมัติเมื่องานปัจจุบันเสร็จสิ้น",
        .ko: "동기화 진행 중입니다. 현재 작업이 완료된 후 자동으로 적용됩니다."
    ],
    "conflicts_local_only_note": [
        .en: "Only in this folder",
        .zhHant: "只在這個資料夾",
        .zhHans: "只在这个文件夹",
        .ja: "このフォルダのみ",
        .th: "เฉพาะในโฟลเดอร์นี้",
        .ko: "이 폴더에만 존재"
    ],
    "conflicts_newer_badge": [
        .en: "Newer",
        .zhHant: "較新",
        .zhHans: "较新",
        .ja: "より新しい",
        .th: "ใหม่กว่า",
        .ko: "더 최신"
    ],
    "conflicts_section_desc": [
        .en: "The same file was modified in both places, so it wasn't overwritten automatically. Choose one to keep; the other moves to Trash and is saved in Old Versions.",
        .zhHant: "同一個檔案在兩個地方各被改了一次，所以沒有自動覆蓋。選一份留下，另一份會進垃圾桶，並在「舊版本」保留一份。",
        .zhHans: "同一个文件在两个地方各被改了一次，所以没有自动覆盖。选一份留下，另一份会进废纸篓，并在“旧版本”保留一份。",
        .ja: "同一ファイルが双方で変更されたため自動上書きされませんでした。保持する方を選択してください。もう一方はゴミ箱へ移動し以前のバージョンに保存されます。",
        .th: "ไฟล์เดียวกันถูกแก้ไขทั้งสองฝั่ง จึงไม่มีการเขียนทับโดยอัตโนมัติ เลือกฉบับที่ต้องการเก็บ อีกฉบับจะย้ายไปที่ถังขยะและเก็บไว้ในเวอร์ชันก่อนหน้า",
        .ko: "동일한 파일이 양쪽에서 수정되어 자동 덮어쓰기되지 않았습니다. 유지할 버전을 선택하세요. 다른 버전은 휴지통으로 이동하며 이전 버전에 보관됩니다."
    ],
    "conflicts_use_this": [
        .en: "Use This Copy",
        .zhHant: "改用這一份",
        .zhHans: "改用这一份",
        .ja: "こちらを採用",
        .th: "ใช้ฉบับนี้แทน",
        .ko: "이 버전으로 교체"
    ],
    "conflicts_version_on_endpoint": [
        .en: "Version on \"%@\"",
        .zhHant: "「%@」上的版本",
        .zhHans: "“%@”上的版本",
        .ja: "「%@」のバージョン",
        .th: "เวอร์ชันบน \"%@\"",
        .ko: "'%@'의 버전"
    ],
    "conflicts_batch_title": [
        .en: "One-Click Batch Resolution",
        .zhHant: "一鍵批次處理",
        .zhHans: "一键批量处理",
        .ja: "一括解決",
        .th: "แก้ไขข้อขัดแย้งแบบกลุ่ม",
        .ko: "원클릭 일괄 해결"
    ],
    "conflicts_batch_desc": [
        .en: "%d conflicts waiting for decision. Quickly resolve them using batch rules.",
        .zhHant: "共有 %d 個衝突待決定，可使用規則一鍵快速批次套用。",
        .zhHans: "共有 %d 个冲突待决定，可使用规则一键快速批量应用。",
        .ja: "%d 件の競合があります。ルールに従って一括で素早く適用できます。",
        .th: "มีข้อขัดแย้ง %d รายการที่รอการตัดสินใจ สามารถใช้กฎเพื่อแก้ไขเป็นกลุ่มได้อย่างรวดเร็ว",
        .ko: "%d개의 충돌이 대기 중입니다. 규칙을 사용하여 한 번에 빠르게 일괄 적용할 수 있습니다."
    ],
    "conflicts_batch_all_newer": [
        .en: "Keep All Newer Versions",
        .zhHant: "一鍵全部保留較新版本",
        .zhHans: "一键全部保留较新版本",
        .ja: "新しい方を一括保持",
        .th: "เก็บเวอร์ชันที่ใหม่กว่าทั้งหมดในคลิกเดียว",
        .ko: "더 최신 버전 모두 일괄 유지"
    ],
    "conflicts_batch_all_current": [
        .en: "Keep All Current Versions",
        .zhHant: "全部保留目前版本",
        .zhHans: "全部保留当前版本",
        .ja: "現在のバージョンを一括保持",
        .th: "เก็บเวอร์ชันปัจจุบันทั้งหมด",
        .ko: "현재 버전 모두 유지"
    ],
    "conflicts_batch_all_endpoint": [
        .en: "Use All Endpoint Versions",
        .zhHant: "全部改用各端點版本",
        .zhHans: "全部改用各端点版本",
        .ja: "各エンドポイントのバージョンを採用",
        .th: "ใช้เวอร์ชันปลายทางทั้งหมด",
        .ko: "엔드포인트 버전 모두 채택"
    ],
    "conflicts_batch_same_file_banner": [
        .en: "This file has conflicts across %d endpoints",
        .zhHant: "此檔案在 %d 個端點同時發生衝突",
        .zhHans: "此文件在 %d 个端点同时发生冲突",
        .ja: "このファイルは %d 箇所のエンドポイントで同時に競合しています",
        .th: "ไฟล์นี้เกิดข้อขัดแย้งพร้อมกันใน %d ปลายทาง",
        .ko: "이 파일은 %d개의 엔드포인트에서 동시에 충돌이 발생했습니다"
    ],
    "conflicts_batch_apply_same_file_main": [
        .en: "Keep Current for All (%d)",
        .zhHant: "全部保留目前版本 (%d)",
        .zhHans: "全部保留当前版本 (%d)",
        .ja: "すべて現在のバージョンを保持 (%d)",
        .th: "เก็บเวอร์ชันปัจจุบันทั้งหมด (%d)",
        .ko: "모든 엔드포인트 현재 버전 유지 (%d)"
    ],
    "conflicts_batch_apply_same_file_newer": [
        .en: "Keep Newer for All (%d)",
        .zhHant: "全部保留較新版本 (%d)",
        .zhHans: "全部保留较新版本 (%d)",
        .ja: "すべて新しい方を保持 (%d)",
        .th: "เก็บเวอร์ชันใหม่กว่าทั้งหมด (%d)",
        .ko: "모든 엔드포인트 최신 버전 유지 (%d)"
    ],
    "conflicts_batch_apply_same_file_extra": [
        .en: "Use Endpoint Copy for All (%d)",
        .zhHant: "全部改用此端點版本 (%d)",
        .zhHans: "全部改用此端点版本 (%d)",
        .ja: "すべてこちらを採用 (%d)",
        .th: "ใช้ฉบับนี้แทนทั้งหมด (%d)",
        .ko: "모두 이 버전으로 교체 (%d)"
    ],
    "conflicts_batch_apply_same_ext": [
        .en: "Apply to All .%@ Files (%d)",
        .zhHant: "套用至所有 .%@ 檔案 (%d)",
        .zhHans: "应用至所有 .%@ 文件 (%d)",
        .ja: "すべての .%@ ファイルに適用 (%d)",
        .th: "นำไปใช้กับไฟล์ .%@ ทั้งหมด (%d)",
        .ko: "모든 .%@ 파일에 적용 (%d)"
    ],
    "msg_conflicts_batch_resolved": [
        .en: "Successfully resolved %d conflicts",
        .zhHant: "已成功批次處理 %d 個衝突",
        .zhHans: "已成功批量处理 %d 个冲突",
        .ja: "%d 件の競合を一括解決しました",
        .th: "แก้ไขข้อขัดแย้งสำเร็จ %d รายการ",
        .ko: "%d개의 충돌을 일괄 해결했습니다"
    ],
    "conflicts_filter_all": [
        .en: "All (%d)",
        .zhHant: "全部 (%d)",
        .zhHans: "全部 (%d)",
        .ja: "すべて (%d)",
        .th: "ทั้งหมด (%d)",
        .ko: "전체 (%d)"
    ],
    "conflicts_filter_multi_endpoint": [
        .en: "Multi-endpoint Conflicts (%d)",
        .zhHant: "多端點同檔衝突 (%d)",
        .zhHans: "多端点同名冲突 (%d)",
        .ja: "複数エンドポイント競合 (%d)",
        .th: "ข้อขัดแย้งหลายปลายทาง (%d)",
        .ko: "다중 엔드포인트 충돌 (%d)"
    ],
    "days_count": [
        .en: "%d days",
        .zhHant: "%d 天",
        .zhHans: "%d 天",
        .ja: "%d 日",
        .th: "%d วัน",
        .ko: "%d일"
    ],
    "diff_items_count": [
        .en: "%d items:",
        .zhHant: "%d 個變更項目：",
        .zhHans: "%d 个变更项目：",
        .ja: "%d 件の変更項目:",
        .th: "%d รายการที่เปลี่ยนแปลง:",
        .ko: "%d개의 변경 항목:"
    ],
    "diff_no_changes": [
        .en: "All folders are perfectly in sync. No actions required.",
        .zhHant: "所有資料夾內容完全一致，無需執行任何同步操作。",
        .zhHans: "所有文件夹内容完全一致，无需执行任何同步操作。",
        .ja: "すべてのフォルダが同期されています。変更は不要です。",
        .th: "ทุกโฟลเดอร์ซิงค์ข้อมูลตรงกันเรียบร้อยแล้ว ไม่จำเป็นต้องดำเนินการใดๆ",
        .ko: "모든 폴더의 내용이 일치합니다. 동기화할 작업이 없습니다."
    ],
    "diff_preview_desc": [
        .en: "Perform a simulated trial run before modifying disk contents. Verify proposed file copies, moves, and deletions with zero risk.",
        .zhHant: "在正式寫入磁碟前執行模擬對帳試跑，檢視預計複製、改名與刪除的項目，零風險確認安全無虞。",
        .zhHans: "在正式写入磁盘前执行模拟对账试跑，检视预计复制、改名与删除的项目，零风险确认安全无虞。",
        .ja: "ディスクに変更を加える前にシミュレーションを実行し、コピー、名前変更、削除の安全性を確認します。",
        .th: "ดำเนินการทดลองรันจำลองก่อนแก้ไขข้อมูลจริงบนดิสก์ ตรวจสอบการคัดลอก ย้าย และลบได้โดยไม่มีความเสี่ยง",
        .ko: "디스크에 실제로 기록하기 전 시뮬레이션 시험 실행을 통해 복사, 변경, 삭제될 항목을 안전하게 사전 검토합니다."
    ],
    "diff_preview_title": [
        .en: "Visual Diff Trial Run",
        .zhHant: "智慧差異預覽（試跑）",
        .zhHans: "智能差异预览（试跑）",
        .ja: "差分プレビュー（テスト実行）",
        .th: "ดูตัวอย่างความแตกต่าง (ทดลองรัน)",
        .ko: "스마트 차이 미리보기 (시험 실행)"
    ],
    "done": [
        .en: "Done",
        .zhHant: "完成",
        .zhHans: "完成",
        .ja: "完了",
        .th: "เสร็จสิ้น",
        .ko: "완료"
    ],
    "endpoint_archive_suffix": [
        .en: " · Archive: Receive Only",
        .zhHant: "　· 備份：只接收",
        .zhHans: "　· 备份：只接收",
        .ja: "　· アーカイブ：受信のみ",
        .th: " · เก็บถาวร: รับเท่านั้น",
        .ko: " · 아카이브: 수신 전용"
    ],
    "endpoint_portable_suffix": [
        .en: " · exFAT/Windows compatible names",
        .zhHant: "　· 檔名相容 exFAT／Windows",
        .zhHans: "　· 文件名兼容 exFAT／Windows",
        .ja: "　· exFAT/Windows互換名",
        .th: " · ชื่อไฟล์เข้ากันได้กับ exFAT/Windows",
        .ko: " · exFAT/Windows 호환 파일명"
    ],
    "endpoint_reading_cloud": [
        .en: "Reading %d cloud files, will resume automatically",
        .zhHant: "正在讀取 %d 個雲端檔案，完成後自動繼續",
        .zhHans: "正在读取 %d 个云端文件，完成后自动继续",
        .ja: "%d 個のクラウドファイルを読み込み中、完了後に自動再開",
        .th: "กำลังอ่านไฟล์คลาวด์ %d ไฟล์ จะดำเนินการต่ออัตโนมัติ",
        .ko: "클라우드 파일 %d개 읽는 중, 완료 후 자동 재개"
    ],
    "endpoint_unplugged_sub": [
        .en: "Unplugged · Will reconcile automatically on reconnect",
        .zhHant: "已拔除　· 接回後自動對帳，不會被當成「檔案全被刪除」",
        .zhHans: "已拔除　· 接回后自动对账，不会被当成“文件全被删除”。",
        .ja: "取り外されました · 再接続時に自動照合されます",
        .th: "ถูกถอดออก · จะซิงค์ใหม่อัตโนมัติเมื่อเสียบกลับ",
        .ko: "분리됨 · 재연결 시 파일 삭제 없이 자동 대조됩니다"
    ],
    "folder_marker_help": [
        .en: "💡 How to resolve: If this folder or drive is indeed what you intend to sync, click \"Change Folder...\" on the right and re-select it (or remove and re-add) to safely pair its identifier and restore sync.",
        .zhHant: "💡 解法概要：若確定此資料夾或外接碟無誤，請點擊右側「更換資料夾...」重新選取此路徑（或「移除」後重新加入），即可安全重新配對識別標記並恢復正常同步。",
        .zhHans: "💡 解法概要：若确定此文件夹或移动硬盘无误，请点击右侧“更换文件夹...”重新选取此路径（或“移除”后重新添加），即可安全重新配对识别标记并恢复正常同步。",
        .ja: "💡 対処方法：このフォルダや外付けドライブが正しい場合は、右側の「フォルダを変更...」をクリックして再選択するか、一度削除して再追加することで、安全に識別マークを再ペアリングして同期を再開できます。",
        .th: "💡 วิธีแก้ไข: หากแน่ใจว่าโฟลเดอร์หรือไดรฟ์นี้ถูกต้อง ให้คลิก \"เปลี่ยนโฟลเดอร์...\" ทางด้านขวาแล้วเลือกโฟลเดอร์นี้อีกครั้ง (หรือลบแล้วเพิ่มใหม่) เพื่อจับคู่และกลับมาซิงค์ตามปกติอย่างปลอดภัย",
        .ko: "💡 해결 방법: 이 폴더나 외장 드라이브가 올바른 경우, 오른쪽의 '폴더 변경...'을 클릭하여 해당 폴더를 다시 선택(또는 삭제 후 다시 추가)하면 식별 마커를 안전하게 재페어링하고 동기화를 정상 재개할 수 있습니다."
    ],
    "folders_add_button": [
        .en: "Add Folder…",
        .zhHant: "加入資料夾…",
        .zhHans: "添加文件夹…",
        .ja: "フォルダを追加…",
        .th: "เพิ่มโฟลเดอร์…",
        .ko: "폴더 추가…"
    ],
    "folders_add_title": [
        .en: "Add Folder",
        .zhHant: "加入資料夾",
        .zhHans: "添加文件夹",
        .ja: "フォルダを追加",
        .th: "เพิ่มโฟลเดอร์",
        .ko: "폴더 추가"
    ],
    "folders_archive_hint": [
        .en: "Archive folders only receive updates from other folders: local changes will be reverted, deleted files from elsewhere are preserved, and replaced files are kept in .syncnexus-history.",
        .zhHant: "備份資料夾只會接收其他資料夾的內容：在這裡做的修改不會傳出去（會被還原）、其他資料夾刪除的檔案會保留，被取代的舊內容存在資料夾內的 .syncnexus-history。",
        .zhHans: "备份文件夹只会接收其他文件夹的内容：在这里做的修改不会传出去（会被还原）、其他文件夹删除的文件会保留，被取代的旧内容存在文件夹内的 .syncnexus-history。",
        .ja: "アーカイブフォルダは受信のみ行います。ここでの変更は破棄・復元され、他で削除されたファイルも保持されます。",
        .th: "โฟลเดอร์เก็บถาวรจะรับข้อมูลจากโฟลเดอร์อื่นเท่านั้น: การแก้ไขที่นี่จะไม่ส่งออกไป ไฟล์ที่ถูกลบจะยังคงอยู่",
        .ko: "아카이브 폴더는 수신 전용입니다. 여기서 수정한 내용은 되돌려지며 다른 곳에서 삭제된 파일도 보존됩니다."
    ],
    "folders_btn_add": [
        .en: "Add",
        .zhHant: "加入",
        .zhHans: "添加",
        .ja: "追加",
        .th: "เพิ่ม",
        .ko: "추가"
    ],
    "folders_btn_relink": [
        .en: "Relink",
        .zhHant: "更換",
        .zhHans: "更换",
        .ja: "変更",
        .th: "เปลี่ยน",
        .ko: "변경"
    ],
    "folders_cannot_use_title": [
        .en: "Cannot use this folder",
        .zhHant: "無法使用這個資料夾",
        .zhHans: "无法使用这个文件夹",
        .ja: "このフォルダは使用できません",
        .th: "ไม่สามารถใช้โฟลเดอร์นี้ได้",
        .ko: "이 폴더를 사용할 수 없습니다"
    ],
    "folders_change_prompt": [
        .en: "Select new folder for \"%@\"",
        .zhHant: "選擇「%@」要改指向的新資料夾",
        .zhHans: "选择“%@”要改指向的新文件夹",
        .ja: "「%@」の新しいフォルダを選択",
        .th: "เลือกโฟลเดอร์ใหม่สำหรับ \"%@\"",
        .ko: "'%@'의 새 대상 폴더 선택"
    ],
    "folders_desc": [
        .en: "These folders will stay synchronized: additions, edits, deletions, or renames will replicate across all. Deleted files move to Trash.",
        .zhHant: "這些資料夾會互相保持一致：任一個有新增、修改、刪除或改名，其他的都會跟著變。刪除的檔案先進垃圾桶。",
        .zhHans: "这些文件夹会互相保持一致：任一个有新增、修改、删除或改名，其他的都会跟着变。删除的文件先进废纸篓。",
        .ja: "これらのフォルダは同期されます。追加、変更、削除、名前変更はすべて反映されます。削除されたファイルはゴミ箱に移動します。",
        .th: "โฟลเดอร์เหล่านี้จะซิงค์ข้อมูลให้ตรงกัน: เมื่อมีการเพิ่ม แก้ไข ลบ หรือเปลี่ยนชื่อ ไฟล์อื่นๆ จะเปลี่ยนตาม ไฟล์ที่ถูกลบจะย้ายไปที่ถังขยะ",
        .ko: "이 폴더들은 동기화 상태를 유지합니다. 추가, 수정, 삭제, 이름 변경이 모두 반영됩니다. 삭제된 파일은 휴지통으로 이동합니다."
    ],
    "folders_detected": [
        .en: "Detected: %1$@",
        .zhHant: "偵測到：%1$@",
        .zhHans: "检测到：%1$@",
        .ja: "検出: %1$@",
        .th: "ตรวจพบ: %1$@",
        .ko: "감지됨: %1$@"
    ],
    "folders_empty_hint": [
        .en: "No folders added yet. Recommended sequence: Local folder, iCloud Drive folder, Google Drive folder, external drive folder.",
        .zhHant: "還沒有加入資料夾。建議依序加入：本機資料夾、iCloud 雲碟裡的資料夾、Google Drive 裡的資料夾、外接磁碟裡的資料夾。",
        .zhHans: "还没有添加文件夹。建议依序添加：本地文件夹、iCloud 云盘里的文件夹、Google Drive 里的文件夹、外接移动硬盘里的文件夹。",
        .ja: "フォルダが追加されていません。ローカル、iCloud Drive、Google Drive、外付けドライブの順に追加することをお勧めします。",
        .th: "ยังไม่ได้เพิ่มโฟลเดอร์ แนะนำให้เพิ่มตามลำดับ: โฟลเดอร์ในเครื่อง, โฟลเดอร์ใน iCloud Drive, Google Drive หรือไดรฟ์ภายนอก",
        .ko: "아직 추가된 폴더가 없습니다. 로컬 폴더, iCloud Drive 폴더, Google Drive 폴더, 외장 드라이브 폴더 순서로 추가하는 것을 권장합니다."
    ],
    "folders_minimum_warning": [
        .en: "At least two folders are required to start synchronization.",
        .zhHant: "至少需要兩個資料夾才會開始同步。",
        .zhHans: "至少需要两个文件夹才会开始同步。",
        .ja: "同期を開始するには少なくとも2つのフォルダが必要です。",
        .th: "ต้องมีอย่างน้อยสองโฟลเดอร์จึงจะเริ่มการซิงค์ได้",
        .ko: "동기화를 시작하려면 최소 2개의 폴더가 필요합니다."
    ],
    "folders_name_label": [
        .en: "Name",
        .zhHant: "名稱",
        .zhHans: "名称",
        .ja: "名前",
        .th: "ชื่อ",
        .ko: "이름"
    ],
    "folders_relink_desc": [
        .en: "The new folder will be treated as newly added: it will receive files from other endpoints and merge existing contents. Other endpoints' files will not be deleted even if it is empty. A preview will be shown before sync.\n\n",
        .zhHant: "新資料夾會被當成新加入的資料夾：它會先收到其他端點的檔案，原有的檔案也會被合併進來；不會因為它是空的就刪除其他端點的檔案。同步前會先給你看預覽。\n\n",
        .zhHans: "新文件夹会被当成新加入的文件夹：它会先收到其他端点的文件，原有的文件也会被合并进来；不会因为它是空的就删除其他端点的文件。同步前会先给你看预览。\n\n",
        .ja: "新しいフォルダは新規追加として扱われ、他端点からファイルを受信し既存ファイルと結合されます。空であっても他端点のファイルが削除されることはありません。\n\n",
        .th: "โฟลเดอร์ใหม่จะถือเป็นโฟลเดอร์ที่เพิ่มเข้ามาใหม่ โดยจะรับไฟล์และผสานเนื้อหาเดิม จะไม่มีการลบไฟล์จากที่อื่นแม้ว่าโฟลเดอร์จะว่างเปล่า\n\n",
        .ko: "새 폴더는 새로 추가된 것으로 처리되어 다른 엔드포인트의 파일을 수신하고 병합합니다. 비어 있더라도 다른 엔드포인트의 파일이 삭제되지 않습니다.\n\n"
    ],
    "folders_relink_title": [
        .en: "Relink \"%@\" to new folder?",
        .zhHant: "把「%@」改指向新資料夾？",
        .zhHans: "把“%@”改指向新文件夹？",
        .ja: "「%@」を新しいフォルダに関連付けますか？",
        .th: "เปลี่ยนปลายทาง \"%@\" ไปยังโฟลเดอร์ใหม่หรือไม่?",
        .ko: "'%@'을(를) 새 폴더로 변경하시겠습니까?"
    ],
    "folders_removable_hint": [
        .en: "When unplugged, this folder pauses syncing without treating files as deleted. Sync reconciles automatically on reconnect.",
        .zhHant: "磁碟被拔除時，這個資料夾會暫時停止同步，不會被當成「檔案全被刪除」；接回後會自動對帳。",
        .zhHans: "磁盘被拔除时，这个文件夹会暂时停止同步，不会被当成“文件全被删除”；接回后会自动对账。",
        .ja: "取り外し時、このフォルダは同期を停止し削除扱いにはなりません。再接続時に自動照合されます。",
        .th: "เมื่อถอดไดรฟ์ออก การซิงค์จะหยุดชั่วคราวโดยไม่ถือว่าไฟล์ถูกลบ และจะซิงค์ใหม่อัตโนมัติเมื่อเสียบกลับ",
        .ko: "드라이브가 분리되면 동기화가 일시 중지되며 삭제 처리되지 않고 재연결 시 자동 대조됩니다."
    ],
    "folders_remove_desc": [
        .en: "Files inside this folder will NOT be deleted or modified. Changes will simply no longer sync to other folders.",
        .zhHant: "資料夾裡的檔案完全不會被刪除或改動，只是之後它的變更不會再和其他資料夾同步。",
        .zhHans: "文件夹里的文件完全不会被删除或改动，只是之后它的变更不会再和其他文件夹同步。",
        .ja: "フォルダ内のファイルは削除・変更されません。今後の変更が他フォルダと同期されなくなるだけです。",
        .th: "ไฟล์ในโฟลเดอร์นี้จะไม่ถูกลบหรือเปลี่ยนแปลง เพียงแต่การเปลี่ยนแปลงจะไม่ซิงค์กับโฟลเดอร์อื่นอีกต่อไป",
        .ko: "폴더 내 파일은 전혀 삭제되거나 수정되지 않으며, 단지 이후 변경 사항이 다른 폴더와 동기화되지 않습니다."
    ],
    "folders_remove_title": [
        .en: "Stop syncing \"%@\"?",
        .zhHant: "不再同步「%@」？",
        .zhHans: "不再同步“%@”？",
        .ja: "「%@」の同期を停止しますか？",
        .th: "หยุดซิงค์ \"%@\" หรือไม่?",
        .ko: "'%@' 동기화를 중단하시겠습니까?"
    ],
    "folders_toggle_archive": [
        .en: "Archive mode (Receive only)",
        .zhHant: "當作備份（只接收）",
        .zhHans: "当作备份（只接收）",
        .ja: "アーカイブモード（受信のみ）",
        .th: "โหมดเก็บถาวร (รับอย่างเดียว)",
        .ko: "아카이브 모드 (수신 전용)"
    ],
    "folders_toggle_portable": [
        .en: "Names must be exFAT / Windows compatible",
        .zhHant: "檔名須相容 exFAT／Windows",
        .zhHans: "文件名须兼容 exFAT／Windows",
        .ja: "exFAT / Windows 互換のファイル名",
        .th: "ชื่อไฟล์ต้องเข้ากันได้กับ exFAT / Windows",
        .ko: "파일명 exFAT / Windows 호환 필요"
    ],
    "folders_toggle_removable": [
        .en: "Removable (External drive)",
        .zhHant: "可能被拔除（外接磁碟）",
        .zhHans: "可能被拔除（外接磁盘）",
        .ja: "取り外し可能（外付けドライブ）",
        .th: "อาจถูกถอดออก (ไดรฟ์ภายนอก)",
        .ko: "분리 가능 (외장 드라이브)"
    ],
    "kind_external": [
        .en: "External Drive",
        .zhHant: "外接磁碟",
        .zhHans: "外接磁盘",
        .ja: "外付けドライブ",
        .th: "ไดรฟ์ภายนอก",
        .ko: "외장 드라이브"
    ],
    "kind_gdrive": [
        .en: "Google Drive",
        .zhHant: "Google Drive",
        .zhHans: "Google Drive",
        .ja: "Google Drive",
        .th: "Google Drive",
        .ko: "Google Drive"
    ],
    "kind_icloud": [
        .en: "iCloud Drive",
        .zhHant: "iCloud 雲碟",
        .zhHans: "iCloud 云盘",
        .ja: "iCloud Drive",
        .th: "iCloud Drive",
        .ko: "iCloud Drive"
    ],
    "kind_local": [
        .en: "Local",
        .zhHant: "本機",
        .zhHans: "本地",
        .ja: "ローカル",
        .th: "ในเครื่อง",
        .ko: "로컬"
    ],
    "model_and_more_items": [
        .en: "\n…and %d more item(s)",
        .zhHant: "\n…另有 %d 項",
        .zhHans: "\n…另有 %d 项",
        .ja: "\n…他 %d 項目",
        .th: "\n…และอีก %d รายการ",
        .ko: "\n…외 %d개 항목"
    ],
    "model_btn_confirm_exec": [
        .en: "Confirm and Execute",
        .zhHant: "確認執行",
        .zhHans: "确认执行",
        .ja: "実行を確認",
        .th: "ยืนยันและดำเนินการ",
        .ko: "확인 및 실행"
    ],
    "model_error_prefix": [
        .en: "Error: %@",
        .zhHant: "錯誤：%@",
        .zhHans: "错误：%@",
        .ja: "エラー: %@",
        .th: "ข้อผิดพลาด: %@",
        .ko: "오류: %@"
    ],
    "model_synced_relative": [
        .en: "Synced · %@",
        .zhHant: "已同步 · %@",
        .zhHans: "已同步 · %@",
        .ja: "同期完了 · %@",
        .th: "ซิงค์แล้ว · %@",
        .ko: "동기화됨 · %@"
    ],
    "msg_accepted_current": [
        .en: "Accepted current content, will sync to other folders",
        .zhHant: "已接受現在的內容，會同步到其他資料夾",
        .zhHans: "已接受现在的内容，会同步到其他文件夹",
        .ja: "現在の内容を採用しました。他フォルダへ同期されます",
        .th: "ยอมรับเนื้อหาปัจจุบันแล้ว จะซิงค์ไปยังโฟลเดอร์อื่น",
        .ko: "현재 내용을 채택했습니다. 다른 폴더로 동기화됩니다."
    ],
    "msg_add_failed": [
        .en: "Add failed: %@",
        .zhHant: "新增失敗：%@",
        .zhHans: "添加失败：%@",
        .ja: "追加失敗: %@",
        .th: "การเพิ่มล้มเหลว: %@",
        .ko: "추가 실패: %@"
    ],
    "msg_archive_retention_updated": [
        .en: "Archive history retention updated",
        .zhHant: "備份歷史保留期限已更新",
        .zhHans: "备份历史保留期限已更新",
        .ja: "アーカイブ履歴の保持期間を更新しました",
        .th: "อัปเดตระยะเวลาเก็บประวัติแล้ว",
        .ko: "아카이브 히스토리 보존 기한이 업데이트되었습니다"
    ],
    "msg_conflict_kept_main": [
        .en: "Kept original file, other copy moved to Trash",
        .zhHant: "已保留原檔，另一份已移到垃圾桶",
        .zhHans: "已保留原文件，另一份已移至废纸篓",
        .ja: "元ファイルを保持し、複製をゴミ箱へ移動しました",
        .th: "เก็บไฟล์เดิมไว้ และย้ายอีกฉบับไปที่ถังขยะ",
        .ko: "원본을 유지하고 다른 사본은 휴지통으로 이동했습니다"
    ],
    "msg_conflict_policy_updated": [
        .en: "Conflict policy updated",
        .zhHant: "衝突策略已更新",
        .zhHans: "冲突策略已更新",
        .ja: "競合ポリシーを更新しました",
        .th: "อัปเดตกลยุทธ์ข้อขัดแย้งแล้ว",
        .ko: "충돌 처리 정책이 업데이트되었습니다"
    ],
    "msg_conflict_used_extra": [
        .en: "Adopted conflict copy, previous version stored in Old Versions, propagating now",
        .zhHant: "已改用衝突副本，舊版存入 Versions，正在傳到其他資料夾",
        .zhHans: "已改用冲突副本，旧版存入 Versions，正在传到其他文件夹",
        .ja: "競合コピーを採用しました。旧版は退避され、他フォルダへ同期中です",
        .th: "ใช้สำเนาข้อขัดแย้งแล้ว เวอร์ชันเดิมถูกเก็บไว้ และกำลังส่งไปยังโฟลเดอร์อื่น",
        .ko: "충돌 사본을 채택했습니다. 구버전은 보관되었으며 다른 폴더로 동기화 중입니다"
    ],
    "msg_endpoint_added": [
        .en: "Added \"%@\". A preview will be shown before first sync.",
        .zhHant: "已新增「%@」。首次同步前會先顯示預覽，等你確認。",
        .zhHans: "已添加“%@”。首次同步前会先显示预览，等你确认。",
        .ja: "「%@」を追加しました。初回同期前にプレビューが表示されます。",
        .th: "เพิ่ม \"%@\" แล้ว จะแสดงตัวอย่างก่อนการซิงค์ครั้งแรก",
        .ko: "'%@'이(가) 추가되었습니다. 첫 동기화 전 미리보기가 제공됩니다."
    ],
    "msg_excludes_updated": [
        .en: "Excluded items updated (synced files won't be deleted, only omitted going forward)",
        .zhHant: "排除項目已更新（已同步的檔案不會被刪除，只是不再同步）",
        .zhHans: "排除项目已更新（已同步的文件不会被删除，只是不再同步）",
        .ja: "除外項目を更新しました（既存ファイルは削除されず、今後の同期対象外となります）",
        .th: "อัปเดตรายการที่ยกเว้นแล้ว (ไฟล์ที่เคยซิงค์จะไม่ถูกลบ เพียงแต่จะไม่ซิงค์ต่อ)",
        .ko: "제외 항목이 업데이트되었습니다 (기존 파일은 유지되며 향후 동기화에서 제외됩니다)"
    ],
    "msg_login_approval_required": [
        .en: "Approval required in System Settings > General > Login Items",
        .zhHant: "需在「系統設定 > 一般 > 登入項目」允許",
        .zhHans: "需在“系统设置 > 通用 > 登录项”允许",
        .ja: "「システム設定 > 一般 > ログイン項目」で許可が必要です",
        .th: "ต้องอนุญาตในการตั้งค่าระบบ > ทั่วไป > รายการเข้าสู่ระบบ",
        .ko: "시스템 설정 > 일반 > 로그인 항목에서 허용이 필요합니다"
    ],
    "msg_login_config_failed": [
        .en: "Failed to configure launch at login: %@",
        .zhHant: "無法設定開機啟動：%@",
        .zhHans: "无法设置开机启动：%@",
        .ja: "ログイン項目の設定に失敗しました: %@",
        .th: "ไม่สามารถตั้งค่าการเปิดเมื่อเข้าสู่ระบบ: %@",
        .ko: "로그인 시 실행 설정 실패: %@"
    ],
    "msg_relink_failed": [
        .en: "Relink failed: %@",
        .zhHant: "更換失敗：%@",
        .zhHans: "更换失败：%@",
        .ja: "関連付け変更失敗: %@",
        .th: "การเปลี่ยนโฟลเดอร์ล้มเหลว: %@",
        .ko: "변경 실패: %@"
    ],
    "msg_relinked": [
        .en: "\"%@\" relinked to new folder; a preview will be shown before next sync.",
        .zhHant: "「%@」已改指向新資料夾，下次同步前會先顯示預覽。",
        .zhHans: "“%@”已改指向新文件夹，下次同步前会先显示预览。",
        .ja: "「%@」を新しいフォルダに関連付けました。次回同期前にプレビューが表示されます。",
        .th: "\"%@\" เปลี่ยนปลายทางแล้ว จะแสดงตัวอย่างก่อนการซิงค์ถัดไป",
        .ko: "'%@'의 새 대상 폴더가 연결되었습니다. 다음 동기화 전 미리보기가 표시됩니다."
    ],
    "msg_remove_failed": [
        .en: "Remove failed: %@",
        .zhHant: "移除失敗：%@",
        .zhHans: "移除失败：%@",
        .ja: "削除失敗: %@",
        .th: "การลบล้มเหลว: %@",
        .ko: "제거 실패: %@"
    ],
    "msg_removed": [
        .en: "Removed \"%@\"; files inside remain untouched.",
        .zhHant: "已移除「%@」，資料夾內的檔案完全沒有被動到。",
        .zhHans: "已移除“%@”，文件夹内的文件完全没有被动到。",
        .ja: "「%@」を削除しました。フォルダ内のファイルは保持されます。",
        .th: "ลบ \"%@\" แล้ว ไฟล์ภายในไม่ได้รับผลกระทบใดๆ",
        .ko: "'%@'을(를) 제거했습니다. 폴더 내 파일은 그대로 보존됩니다."
    ],
    "msg_repaired_from_others": [
        .en: "Repaired using other folder's version, damaged content saved to Old Versions",
        .zhHant: "已用其他資料夾的版本修復，損壞的內容保留在舊版本",
        .zhHans: "已用其他文件夹的版本修复，损坏的内容保留在旧版本",
        .ja: "他フォルダのバージョンで修復しました。破損内容は旧バージョンに保存されました",
        .th: "ซ่อมแซมจากโฟลเดอร์อื่นแล้ว ข้อมูลที่เสียหายถูกบันทึกในเวอร์ชันก่อนหน้า",
        .ko: "다른 폴더의 버전으로 복구되었습니다. 손상본은 이전 버전에 보관되었습니다."
    ],
    "msg_restore_failed": [
        .en: "Restore failed: %@",
        .zhHant: "還原失敗：%@",
        .zhHans: "还原失败：%@",
        .ja: "復元失敗: %@",
        .th: "การกู้คืนล้มเหลว: %@",
        .ko: "복원 실패: %@"
    ],
    "msg_retention_updated": [
        .en: "Old version retention updated",
        .zhHant: "舊版本保留期限已更新",
        .zhHans: "旧版本保留期限已更新",
        .ja: "旧バージョンの保持期間を更新しました",
        .th: "อัปเดตระยะเวลาเก็บรักษาเวอร์ชันก่อนหน้าแล้ว",
        .ko: "이전 버전 보존 기한이 업데이트되었습니다"
    ],
    "msg_trial_run_completed": [
        .en: "Trial run simulation completed",
        .zhHant: "已完成模擬試跑比對",
        .zhHans: "已完成模拟试跑比对",
        .ja: "シミュレーションテスト実行が完了しました",
        .th: "การจำลองทดลองรันเสร็จสมบูรณ์",
        .ko: "시뮬레이션 시험 실행 완료"
    ],
    "msg_trial_run_failed": [
        .en: "Trial run simulation failed",
        .zhHant: "模擬試跑失敗",
        .zhHans: "模拟试跑失败",
        .ja: "テスト実行に失敗しました",
        .th: "การจำลองทดลองรันล้มเหลว",
        .ko: "시뮬레이션 시험 실행 실패"
    ],
    "msg_version_restored": [
        .en: "Restored \"%@\", syncing to other folders",
        .zhHant: "已還原「%@」，正在同步到其他資料夾",
        .zhHans: "已还原“%@”，正在同步到其他文件夹",
        .ja: "「%@」を復元しました。他フォルダへ同期中です",
        .th: "กู้คืน \"%@\" แล้ว กำลังซิงค์ไปยังโฟลเดอร์อื่น",
        .ko: "'%@'이(가) 복원되었습니다. 다른 폴더로 동기화 중입니다"
    ],
    "msg_versions_purged": [
        .en: "Cleaned %1$d old version files, freed %2$@",
        .zhHant: "已清理 %1$d 個舊版本檔案，釋出 %2$@",
        .zhHans: "已清理 %1$d 个旧版本文件，释放 %2$@",
        .ja: "%1$d 件の旧ファイルを削除し、%2$@ を解放しました",
        .th: "ล้างไฟล์เก่าแล้ว %1$d ไฟล์ คืนพื้นที่ %2$@",
        .ko: "이전 버전 파일 %1$d개 정리 완료, %2$@ 공간 확보"
    ],
    "never": [
        .en: "Never",
        .zhHant: "尚未",
        .zhHans: "尚未",
        .ja: "未実行",
        .th: "ยังไม่มี",
        .ko: "아직 없음"
    ],
    "next": [
        .en: "Next",
        .zhHant: "下一步",
        .zhHans: "下一步",
        .ja: "次へ",
        .th: "ถัดไป",
        .ko: "다음"
    ],
    "no_anomalies": [
        .en: "No anomalies",
        .zhHant: "沒有異常",
        .zhHans: "没有异常",
        .ja: "異常なし",
        .th: "ไม่มีสิ่งผิดปกติ",
        .ko: "이상 없음"
    ],
    "offline": [
        .en: "Offline",
        .zhHant: "離線",
        .zhHans: "离线",
        .ja: "オフライン",
        .th: "ออฟไลน์",
        .ko: "오프라인"
    ],
    "ok": [
        .en: "OK",
        .zhHant: "好",
        .zhHans: "好",
        .ja: "OK",
        .th: "ตกลง",
        .ko: "확인"
    ],
    "onboarding_done_desc": [
        .en: "Sync-Nexus stays in your menu bar. The icon status indicates:",
        .zhHant: "Sync-Nexus 會留在選單列右上角，圖示的狀態代表：",
        .zhHans: "Sync-Nexus 会留在菜单栏右上角，图标的状态代表：",
        .ja: "Sync-Nexus はメニューバーに常駐します。アイコンの状態表示:",
        .th: "Sync-Nexus จะอยู่ในแถบเมนูด้านบนขวา สถานะของไอคอนหมายถึง:",
        .ko: "Sync-Nexus는 메뉴 막대에 상주합니다. 아이콘 상태의 의미:"
    ],
    "onboarding_done_footer": [
        .en: "Click the menu icon to inspect status, sync now, pause, or open Settings to manage folders, conflicts, and old versions.",
        .zhHant: "點選圖示可以查看狀態、立即同步、暫停，或打開「設定」管理資料夾、衝突和舊版本。",
        .zhHans: "点击图标可以查看状态、立即同步、暂停，或打开“设置”管理文件夹、冲突和旧版本。",
        .ja: "アイコンをクリックして状態確認、即時同期、一時停止、または「設定」を開いて管理できます。",
        .th: "คลิกไอคอนเพื่อดูสถานะ ซิงค์ทันที หยุดชั่วคราว หรือเปิดการตั้งค่าเพื่อจัดการ",
        .ko: "아이콘을 클릭하여 상태 확인, 즉시 동기화, 일시 정지하거나 '설정'을 열어 관리할 수 있습니다."
    ],
    "onboarding_done_title": [
        .en: "Setup Complete",
        .zhHant: "設定完成",
        .zhHans: "设置完成",
        .ja: "設定完了",
        .th: "การตั้งค่าเสร็จสมบูรณ์",
        .ko: "설정 완료"
    ],
    "onboarding_folder_external": [
        .en: "External Drive: create a folder on the external disk",
        .zhHant: "外接磁碟：在磁碟裡建立一個資料夾",
        .zhHans: "外接移动硬盘：在磁盘里建立一个文件夹",
        .ja: "外付けドライブ: ドライブ内にフォルダを作成",
        .th: "ไดรฟ์ภายนอก: สร้างโฟลเดอร์ในไดรฟ์ภายนอก",
        .ko: "외장 드라이브: 외장 디스크 내에 폴더 생성"
    ],
    "onboarding_folder_gdrive": [
        .en: "Google Drive: create a folder in My Drive",
        .zhHant: "Google Drive：在「我的雲端硬碟」裡建立一個資料夾",
        .zhHans: "Google Drive：在“我的云端硬盘”里建立一个文件夹",
        .ja: "Google Drive: マイドライブ内にフォルダを作成",
        .th: "Google Drive: สร้างโฟลเดอร์ในไดรฟ์ของฉัน",
        .ko: "Google Drive: 내 드라이브 내에 폴더 생성"
    ],
    "onboarding_folder_icloud": [
        .en: "iCloud Drive: create a folder in iCloud Drive in Finder",
        .zhHant: "iCloud 雲碟：在 Finder 的 iCloud 雲碟裡建立一個資料夾",
        .zhHans: "iCloud 云盘：在访达的 iCloud 云盘里建立一个文件夹",
        .ja: "iCloud Drive: FinderのiCloud Drive内にフォルダを作成",
        .th: "iCloud Drive: สร้างโฟลเดอร์ใน iCloud Drive ใน Finder",
        .ko: "iCloud Drive: Finder의 iCloud Drive 안에 폴더 생성"
    ],
    "onboarding_folder_local": [
        .en: "Local: e.g. a folder inside Documents",
        .zhHant: "本機：例如 文件 底下的一個資料夾",
        .zhHans: "本地：例如 文稿 文件夹底下的一个文件夹",
        .ja: "ローカル: 例 書類フォルダ内のフォルダ",
        .th: "ในเครื่อง: เช่น โฟลเดอร์ในเอกสาร",
        .ko: "로컬: 예: 문서 내의 특정 폴더"
    ],
    "onboarding_folders_current_count": [
        .en: "Currently added: %d",
        .zhHant: "目前已加入 %d 個",
        .zhHans: "目前已加入 %d 个",
        .ja: "現在追加済み: %d 個",
        .th: "เพิ่มแล้ว %d โฟลเดอร์",
        .ko: "현재 추가됨: %d개"
    ],
    "onboarding_folders_desc": [
        .en: "Recommended: create a dedicated folder at each location (e.g. named \"Sync\"), then add in order:",
        .zhHant: "建議為每一個地方各建立一個「專用資料夾」，例如都取名叫「同步用」，再依序加入：",
        .zhHans: "建议为每一个地方各建立一个“专用文件夹”，例如都取名叫“同步用”，再依序添加：",
        .ja: "各場所に専用フォルダ（例：「同期用」）を作成し、順番に追加することをお勧めします:",
        .th: "แนะนำให้สร้างโฟลเดอร์เฉพาะในแต่ละที่ (เช่น ชื่อ \"สำหรับซิงค์\") แล้วเพิ่มตามลำดับ:",
        .ko: "각 위치에 전용 폴더(예: '동기화')를 만든 후 순서대로 추가하는 것을 권장합니다:"
    ],
    "onboarding_folders_min_hint": [
        .en: "Sync begins once at least two folders are added. A preview is displayed before the first sync; nothing is copied or deleted until you confirm.",
        .zhHant: "至少加入兩個就會開始同步。第一次同步前會先列出預覽，確認後才會真的複製或刪除任何東西。",
        .zhHans: "至少加入两个就会开始同步。第一次同步前会先列出预览，确认后才会真的复制或删除任何东西。",
        .ja: "2つ以上追加すると同期が開始されます。初回収集前にプレビューが表示され、確認するまで変更されません。",
        .th: "จะเริ่มซิงค์เมื่อเพิ่มอย่างน้อย 2 โฟลเดอร์ จะมีตัวอย่างแสดงก่อนการซิงค์ครั้งแรก และจะไม่มีการคัดลอกหรือลบจนกว่าคุณจะยืนยัน",
        .ko: "2개 이상 추가하면 동기화가 활성화됩니다. 첫 동기화 전 미리보기가 제공되며 승인 전까지 실제 파일이 변경되지 않습니다."
    ],
    "onboarding_folders_test_tip": [
        .en: "Tip: Try a test folder with just a few files for a couple of days to confirm behavior before using important data.",
        .zhHant: "建議先拿檔案不多的資料夾試用幾天，確定符合預期再換成真正的資料。",
        .zhHans: "建议先拿文件不多的文件夹试用几天，确定符合预期再换成真正的数据。",
        .ja: "重要データを同期する前に、少数のファイルで数日間テスト運用することをお勧めします。",
        .th: "คำแนะนำ: ลองทดสอบกับโฟลเดอร์ที่มีไฟล์น้อยๆ สองสามวันเพื่อให้แน่ใจก่อนใช้กับข้อมูลจริง",
        .ko: "팁: 중요한 데이터 적용 전 소수의 파일로 며칠간 시험 사용해 볼 것을 권장합니다."
    ],
    "onboarding_folders_title": [
        .en: "Select Folders to Sync",
        .zhHant: "選擇要同步的資料夾",
        .zhHans: "选择要同步的文件夹",
        .ja: "同期するフォルダを選択",
        .th: "เลือกโฟลเดอร์ที่จะซิงค์",
        .ko: "동기화할 폴더 선택"
    ],
    "onboarding_icon_attention": [
        .en: "Action required: review preview, resolve conflicts, or error",
        .zhHant: "需要你處理：確認預覽、解決衝突，或發生錯誤",
        .zhHans: "需要你处理：确认预览、解决冲突，或发生错误",
        .ja: "対応が必要: プレビュー確認、競合解決、またはエラー",
        .th: "ต้องดำเนินการ: ตรวจสอบตัวอย่าง แก้ไขข้อขัดแย้ง หรือมีข้อผิดพลาด",
        .ko: "조치 필요: 미리보기 확인, 충돌 해결 또는 오류 발생"
    ],
    "onboarding_icon_ok": [
        .en: "Normal, automatic syncing",
        .zhHant: "正常，自動同步中",
        .zhHans: "正常，自动同步中",
        .ja: "正常、自動同期中",
        .th: "ปกติ กำลังซิงค์อัตโนมัติ",
        .ko: "정상, 자동 동기화 중"
    ],
    "onboarding_icon_partial": [
        .en: "A folder is offline (e.g. external disk unplugged), resumes on reconnect",
        .zhHant: "有資料夾離線（例如外接磁碟被拔除），接回後自動繼續",
        .zhHans: "有文件夹离线（例如外接磁盘被拔除），接回后自动继续",
        .ja: "オフラインのフォルダあり（外付けドライブ取り外し等）、再接続時に再開",
        .th: "มีโฟลเดอร์ออฟไลน์ (เช่น ถอดไดรฟ์ออก) จะทำงานต่อเมื่อเชื่อมต่อใหม่",
        .ko: "일부 폴더 오프라인(외장 디스크 분리 등), 재연결 시 자동 재개"
    ],
    "onboarding_icon_paused": [
        .en: "Paused",
        .zhHant: "已暫停",
        .zhHans: "已暂停",
        .ja: "一時停止中",
        .th: "หยุดชั่วคราว",
        .ko: "일시 중지됨"
    ],
    "onboarding_perm_btn_notifications": [
        .en: "Open Notification Settings",
        .zhHant: "開啟通知設定",
        .zhHans: "打开通知设置",
        .ja: "通知設定を開く",
        .th: "เปิดการตั้งค่าการแจ้งเตือน",
        .ko: "알림 설정 열기"
    ],
    "onboarding_perm_desc": [
        .en: "To read and write iCloud Drive, external drives, and move files to Trash, permissions are required in System Settings.",
        .zhHant: "為了能讀寫 iCloud 雲碟、外接磁碟並把檔案移到垃圾桶，需要你在系統設定裡授權。",
        .zhHans: "为了能读写 iCloud 云盘、外接磁盘并把文件移到废纸篓，需要你在系统设置里授权。",
        .ja: "iCloud Drive や外付けドライブの読み書き、ゴミ箱への移動のためにシステム設定での許可が必要です。",
        .th: "เพื่ออ่านและเขียน iCloud Drive ไดรฟ์ภายนอก และย้ายไฟล์ไปถังขยะ จำเป็นต้องได้รับอนุญาตในการตั้งค่าระบบ",
        .ko: "iCloud Drive, 외장 드라이브 읽기/쓰기 및 휴지통 이동을 위해 시스템 설정 권한이 필요합니다."
    ],
    "onboarding_perm_fda_hint": [
        .en: "When opening Full Disk Access, if Sync-Nexus is missing, click \"+\" and select ~/Applications/SyncNexus.app.",
        .zhHant: "打開「完整磁碟取用權限」時，清單裡找不到 Sync-Nexus 的話，按「+」選擇 ~/Applications/SyncNexus.app。",
        .zhHans: "打开“完全磁盘访问权限”时，清单里找不到 Sync-Nexus 的话，按“+”选择 ~/Applications/SyncNexus.app。",
        .ja: "フルディスクアクセスの一覧に Sync-Nexus がない場合は「+」を押して ~/Applications/SyncNexus.app を選択してください。",
        .th: "หากไม่พบ Sync-Nexus ในการเข้าถึงดิสก์เต็มรูปแบบ ให้คลิก \"+\" และเลือก ~/Applications/SyncNexus.app",
        .ko: "전체 디스크 접근 목록에 Sync-Nexus가 없다면 '+'를 누르고 ~/Applications/SyncNexus.app을 추가하세요."
    ],
    "onboarding_perm_launch_desc": [
        .en: "Recommended. Sync must run continuously in background to be effective.",
        .zhHant: "建議。同步要一直在背景執行才有用。",
        .zhHans: "建议。同步要一直在背景运行才有用。",
        .ja: "推奨。バックグラウンドで常に実行することで効果を発揮します。",
        .th: "แนะนำ การซิงค์ต้องทำงานในพื้นหลังอย่างต่อเนื่องจึงจะมีประสิทธิภาพ",
        .ko: "권장. 백그라운드에서 상시 실행되어야 실시간 동기화가 유지됩니다."
    ],
    "onboarding_perm_notifications": [
        .en: "Notifications",
        .zhHant: "通知",
        .zhHans: "通知",
        .ja: "通知",
        .th: "การแจ้งเตือน",
        .ko: "알림"
    ],
    "onboarding_perm_notifications_desc": [
        .en: "Recommended. Alerts you when conflicts arise or confirmations are needed.",
        .zhHant: "建議。有衝突或需要你確認時會提醒你。",
        .zhHans: "建议。有冲突或需要你确认时会提醒你。",
        .ja: "推奨。競合や確認が必要な際にお知らせします。",
        .th: "แนะนำ จะแจ้งเตือนเมื่อเกิดข้อขัดแย้งหรือต้องการการยืนยัน",
        .ko: "권장. 충돌 발생이나 사용자 확인이 필요한 경우 알림을 제공합니다."
    ],
    "onboarding_perm_title": [
        .en: "Required Permissions",
        .zhHant: "需要的授權",
        .zhHans: "需要的授权",
        .ja: "必要な権限",
        .th: "สิทธิ์ที่จำเป็น",
        .ko: "필요한 권한"
    ],
    "online": [
        .en: "Online",
        .zhHant: "在線",
        .zhHans: "在线",
        .ja: "オンライン",
        .th: "ออนไลน์",
        .ko: "온라인"
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
    ],
    "op_copy": [
        .en: "Updated",
        .zhHant: "已更新",
        .zhHans: "已更新",
        .ja: "更新済み",
        .th: "อัปเดตแล้ว",
        .ko: "업데이트됨"
    ],
    "op_mkdir": [
        .en: "Directory Created",
        .zhHant: "已建立資料夾",
        .zhHans: "已创建文件夹",
        .ja: "フォルダ作成済み",
        .th: "สร้างโฟลเดอร์แล้ว",
        .ko: "폴더 생성됨"
    ],
    "op_move": [
        .en: "Renamed",
        .zhHant: "已改名",
        .zhHans: "已改名",
        .ja: "名前変更済み",
        .th: "เปลี่ยนชื่อแล้ว",
        .ko: "이름 변경됨"
    ],
    "op_restore": [
        .en: "Restored Version",
        .zhHant: "已還原舊版本",
        .zhHans: "已还原旧版本",
        .ja: "旧バージョン復元済み",
        .th: "กู้คืนเวอร์ชันแล้ว",
        .ko: "이전 버전 복원됨"
    ],
    "op_trash": [
        .en: "Moved to Trash",
        .zhHant: "已移到垃圾桶",
        .zhHans: "已移至废纸篓",
        .ja: "ゴミ箱へ移動済み",
        .th: "ย้ายไปที่ถังขยะแล้ว",
        .ko: "휴지통으로 이동됨"
    ],
    "overview_sub_ok": [
        .en: "%d folders consistent, no pending errors.",
        .zhHant: "%d 個資料夾保持一致，沒有待處理的錯誤。",
        .zhHans: "%d 个文件夹保持一致，没有待处理的错误。",
        .ja: "%d 個のフォルダが同期され、保留中のエラーはありません。",
        .th: "%d โฟลเดอร์สอดคล้องกัน ไม่มีข้อผิดพลาดที่ค้างอยู่",
        .ko: "%d개 폴더가 일치하며 보류 중인 오류가 없습니다."
    ],
    "overview_sub_partial": [
        .en: "A folder is offline; others continue syncing. Offline folders reconcile automatically when reconnected without treating files as deleted.",
        .zhHant: "有資料夾離線；其餘的仍在互相同步，離線的接回後會自動對帳，不會被當成「檔案全被刪除」。",
        .zhHans: "有文件夹离线；其余的仍在互相同步，离线的接回后会自动对账，不会被当成“文件全被删除”。",
        .ja: "オフラインのフォルダがありますが他は同期中です。再接続時に自動照合され、全削除扱いにはなりません。",
        .th: "มีโฟลเดอร์ออฟไลน์ โฟลเดอร์ที่เหลือยังคงซิงค์กันอยู่ โฟลเดอร์ที่ออฟไลน์จะซิงค์ใหม่อัตโนมัติเมื่อเชื่อมต่ออีกครั้ง",
        .ko: "일부 폴더가 오프라인입니다. 나머지 폴더는 계속 동기화되며, 재연결 시 삭제 처리 없이 자동 대조됩니다."
    ],
    "p2p_empty_hint": [
        .en: "Open Sync-Nexus on another Mac or Android device on the same Wi-Fi to establish a direct local connection.",
        .zhHant: "在同一 Wi-Fi 開啟 Mac 或 Android 設備的 Sync-Nexus，將自動在此顯示並建立直連。",
        .zhHans: "在同一 Wi-Fi 开启 Mac 或 Android 设备的 Sync-Nexus，将自动在此显示并建立直连。",
        .ja: "同一 Wi-Fi 内で Mac または Android の Sync-Nexus を開くと、直接接続が確立されます。",
        .th: "เปิด Sync-Nexus บน Mac หรือ Android ในเครือข่าย Wi-Fi เดียวกันเพื่อสร้างการเชื่อมต่อโดยตรง",
        .ko: "동일한 Wi-Fi에서 Mac 또는 Android 기기의 Sync-Nexus를 실행하면 자동으로 감지되어 직접 연결됩니다."
    ],
    "p2p_found": [
        .en: "Found %d",
        .zhHant: "已發現 %d 台",
        .zhHans: "已发现 %d 台",
        .ja: "%d 台検出",
        .th: "พบ %d เครื่อง",
        .ko: "%d대 발견"
    ],
    "p2p_searching": [
        .en: "Searching…",
        .zhHant: "搜尋中…",
        .zhHans: "搜寻中…",
        .ja: "検索中…",
        .th: "กำลังค้นหา…",
        .ko: "검색 중…"
    ],
    "p2p_section_title": [
        .en: "Local Wi-Fi Devices (P2P Zero-Cloud)",
        .zhHant: "同 Wi-Fi 近端設備 (P2P 局域網直連)",
        .zhHans: "同 Wi-Fi 局域网近端设备 (P2P 直连)",
        .ja: "同一 Wi-Fi 近隣デバイス (P2P 直接接続)",
        .th: "อุปกรณ์ในเครือข่าย Wi-Fi เดียวกัน (P2P โดยตรง)",
        .ko: "동일 Wi-Fi 주변 기기 (P2P 직접 연결)"
    ],
    "permanent": [
        .en: "Permanent",
        .zhHant: "永久",
        .zhHans: "永久",
        .ja: "無期限",
        .th: "ถาวร",
        .ko: "영구"
    ],
    "permissions_authorized": [
        .en: "Authorized",
        .zhHant: "已授權",
        .zhHans: "已授权",
        .ja: "許可済み",
        .th: "ได้รับอนุญาตแล้ว",
        .ko: "승인됨"
    ],
    "permissions_btn_open_settings": [
        .en: "Open System Settings",
        .zhHant: "開啟系統設定",
        .zhHans: "打开系统设置",
        .ja: "システム設定を開く",
        .th: "เปิดการตั้งค่าระบบ",
        .ko: "시스템 설정 열기"
    ],
    "permissions_btn_relaunch": [
        .en: "Restart",
        .zhHant: "重新啟動",
        .zhHans: "重新启动",
        .ja: "再起動",
        .th: "รีสตาร์ต",
        .ko: "재시작"
    ],
    "permissions_full_disk_title": [
        .en: "Full Disk Access",
        .zhHant: "完整磁碟取用權限",
        .zhHans: "完全磁盘访问权限",
        .ja: "フルディスクアクセス",
        .th: "การเข้าถึงดิสก์เต็มรูปแบบ",
        .ko: "전체 디스크 접근 권한"
    ],
    "permissions_sandbox_desc": [
        .en: "Authorized: Persistent read/write access via macOS native Security-Scoped Bookmarks.",
        .zhHant: "已授權：透過 macOS 原生安全書籤（Security-Scoped Bookmarks）持久讀寫同步資料夾。",
        .zhHans: "已授权：通过 macOS 原生安全书签（Security-Scoped Bookmarks）持久读写同步文件夹。",
        .ja: "承認済み: macOS ネイティブの Security-Scoped Bookmarks により持続的な読み書きが可能です。",
        .th: "ได้รับอนุญาตแล้ว: อ่าน/เขียนโฟลเดอร์ที่ซิงค์อย่างถาวรผ่าน Security-Scoped Bookmarks ของ macOS",
        .ko: "승인됨: macOS 네이티브 보안 범위 북마크를 통해 동기화 폴더를 안전하게 읽고 씁니다."
    ],
    "permissions_sandbox_title": [
        .en: "File System Access Permission",
        .zhHant: "檔案系統安全存取權限",
        .zhHans: "文件系统安全访问权限",
        .ja: "ファイルシステムアクセス権限",
        .th: "สิทธิ์การเข้าถึงระบบไฟล์",
        .ko: "파일 시스템 접근 권한"
    ],
    "permissions_unauthorized_desc": [
        .en: "Unauthorized: Deletions in iCloud Drive will fail. Restart app after granting.",
        .zhHant: "未授權：iCloud 雲碟裡的刪除會失敗。授權後需要重新啟動 App。",
        .zhHans: "未授权：iCloud 云盘里的删除会失败。授权后需要重新启动 App。",
        .ja: "未承認: iCloud Drive 内の削除に失敗します。付与後にアプリを再起動してください。",
        .th: "ไม่ได้รับอนุญาต: การลบใน iCloud Drive จะล้มเหลว กรุณารีสตาร์ตแอปหลังจากอนุญาต",
        .ko: "미승인: iCloud Drive 내 삭제가 실패합니다. 권한 부여 후 앱을 재시작해야 합니다."
    ],
    "popover_activity_places": [
        .en: " (%d places)",
        .zhHant: "（%d 處）",
        .zhHans: "（%d 处）",
        .ja: "（%d か所）",
        .th: " (%d แห่ง)",
        .ko: " (%d곳)"
    ],
    "popover_btn_log": [
        .en: "Log",
        .zhHant: "紀錄",
        .zhHans: "日志",
        .ja: "ログ",
        .th: "บันทึก",
        .ko: "로그"
    ],
    "popover_btn_view": [
        .en: "Review",
        .zhHant: "查看",
        .zhHans: "查看",
        .ja: "確認",
        .th: "ดู",
        .ko: "확인"
    ],
    "popover_confirm_needed": [
        .en: "Confirmation Required",
        .zhHant: "需要你確認",
        .zhHans: "需要你确认",
        .ja: "確認が必要です",
        .th: "ต้องการการยืนยัน",
        .ko: "확인 필요"
    ],
    "popover_conflict_sub": [
        .en: "%@ · Modified on both sides",
        .zhHant: "%@　兩邊都被修改",
        .zhHans: "%@　两边都被修改",
        .ja: "%@ · 双方で変更されました",
        .th: "%@ · มีการแก้ไขทั้งสองฝั่ง",
        .ko: "%@ · 양쪽에서 모두 수정됨"
    ],
    "popover_corrupt_files": [
        .en: "%d files suspected corrupted",
        .zhHant: "%d 個檔案疑似損壞",
        .zhHans: "%d 个文件疑似损坏",
        .ja: "%d 件のファイル破損の疑い",
        .th: "สงสัยว่าไฟล์เสียหาย %d ไฟล์",
        .ko: "%d개 파일 손상 의심"
    ],
    "popover_corrupt_sub": [
        .en: "Content differs from hash, quarantined",
        .zhHant: "內容與紀錄不符，已隔離、不會傳播",
        .zhHans: "内容与记录不符，已隔离、不会传播",
        .ja: "ハッシュ不一致、隔離済みで伝播しません",
        .th: "เนื้อหาไม่ตรงกับแฮช ถูกแยกไว้แล้ว",
        .ko: "기록과 해시 불일치, 격리되어 전파 방지됨"
    ],
    "popover_instructions": [
        .en: "User Guide & Permissions…",
        .zhHant: "使用說明與授權檢查…",
        .zhHans: "使用说明与授权检查…",
        .ja: "使用ガイドと権限確認…",
        .th: "คู่มือการใช้งานและการตรวจสอบสิทธิ์…",
        .ko: "사용 설명 및 권한 확인…"
    ],
    "popover_more": [
        .en: "More",
        .zhHant: "更多",
        .zhHans: "更多",
        .ja: "詳細",
        .th: "เพิ่มเติม",
        .ko: "더보기"
    ],
    "popover_no_folders_hint": [
        .en: "No folders added yet. Open Settings to add at least two.",
        .zhHant: "還沒有加入資料夾。打開「設定」加入至少兩個。",
        .zhHans: "还没有添加文件夹。打开“设置”添加至少两个。",
        .ja: "フォルダが追加されていません。「設定」を開いて2つ以上追加してください。",
        .th: "ยังไม่ได้เพิ่มโฟลเดอร์ เปิดการตั้งค่าเพื่อเพิ่มอย่างน้อย 2 โฟลเดอร์",
        .ko: "아직 폴더가 추가되지 않았습니다. '설정'을 열어 2개 이상 추가하세요."
    ],
    "popover_pause_sync": [
        .en: "Pause Sync",
        .zhHant: "暫停同步",
        .zhHans: "暂停同步",
        .ja: "同期を一時停止",
        .th: "หยุดการซิงค์ชั่วคราว",
        .ko: "동기화 일시 정지"
    ],
    "popover_quit": [
        .en: "Quit Sync-Nexus",
        .zhHant: "結束 Sync-Nexus",
        .zhHans: "退出 Sync-Nexus",
        .ja: "Sync-Nexus を終了",
        .th: "ออกจาก Sync-Nexus",
        .ko: "Sync-Nexus 종료"
    ],
    "popover_quitting": [
        .en: "Quitting…",
        .zhHant: "正在結束…",
        .zhHans: "正在退出…",
        .ja: "終了しています…",
        .th: "กำลังออก…",
        .ko: "종료 중…"
    ],
    "popover_reading_cloud": [
        .en: "Reading %d cloud files",
        .zhHant: "正在讀取 %d 個雲端檔案",
        .zhHans: "正在读取 %d 个云端文件",
        .ja: "%d 個のクラウドファイルを読み込み中",
        .th: "กำลังอ่าน %d ไฟล์บนคลาวด์",
        .ko: "클라우드 파일 %d개 읽는 중"
    ],
    "popover_recent_activity": [
        .en: "Recent Activity",
        .zhHant: "最近活動",
        .zhHans: "最近活动",
        .ja: "最近のアクティビティ",
        .th: "กิจกรรมล่าสุด",
        .ko: "최근 활동"
    ],
    "popover_resume_sync": [
        .en: "Resume Sync",
        .zhHant: "繼續同步",
        .zhHans: "继续同步",
        .ja: "同期を再開",
        .th: "เล่นต่อการซิงค์",
        .ko: "동기화 재개"
    ],
    "popover_settings": [
        .en: "Settings…",
        .zhHant: "設定…",
        .zhHans: "设置…",
        .ja: "設定…",
        .th: "การตั้งค่า…",
        .ko: "설정…"
    ],
    "popover_sync_error": [
        .en: "Sync Error Occurred",
        .zhHant: "同步發生錯誤",
        .zhHans: "同步发生错误",
        .ja: "同期エラーが発生しました",
        .th: "เกิดข้อผิดพลาดในการซิงค์",
        .ko: "동기화 오류 발생"
    ],
    "popover_sync_now": [
        .en: "Sync Now",
        .zhHant: "立即同步",
        .zhHans: "立即同步",
        .ja: "今すぐ同期",
        .th: "ซิงค์ทันที",
        .ko: "지금 동기화"
    ],
    "popover_unplugged_sub": [
        .en: "Unplugged · Will reconcile on reconnect",
        .zhHant: "已拔除　· 接回後自動對帳",
        .zhHans: "已拔除　· 接回后自动对账",
        .ja: "取り外し済み · 再接続時に自動照合",
        .th: "ถูกถอดออก · จะซิงค์ใหม่อัตโนมัติเมื่อเสียบกลับ",
        .ko: "분리됨 · 재연결 시 자동 대조"
    ],
    "popover_verify_now": [
        .en: "Run Deep Verification Now (Re-read all files)",
        .zhHant: "立即完整驗證（重新讀取每個檔案）",
        .zhHans: "立即完整验证（重新读取每个文件）",
        .ja: "今すぐ完全検証を実行（全ファイル再読込）",
        .th: "ตรวจสอบเชิงลึกทันที (อ่านไฟล์ทั้งหมดใหม่)",
        .ko: "지금 정밀 검증 실행 (모든 파일 재검증)"
    ],
    "popover_version": [
        .en: "Version %@",
        .zhHant: "版本 %@",
        .zhHans: "版本 %@",
        .ja: "バージョン %@",
        .th: "เวอร์ชัน %@",
        .ko: "버전 %@"
    ],
    "portable_badge": [
        .en: "exFAT/Windows Compatible",
        .zhHant: "檔名相容 exFAT／Windows",
        .zhHans: "文件名兼容 exFAT／Windows",
        .ja: "exFAT/Windows 互換",
        .th: "เข้ากันได้กับ exFAT/Windows",
        .ko: "exFAT/Windows 호환 파일명"
    ],
    "preset_databases_title": [
        .en: "Database temporary files (-wal, -shm, -journal)",
        .zhHant: "資料庫暫存檔（-wal、-shm、-journal）",
        .zhHans: "数据库临时文件（-wal、-shm、-journal）",
        .ja: "データベース一時ファイル（-wal、-shm、-journal）",
        .th: "ไฟล์ชั่วคราวฐานข้อมูล (-wal, -shm, -journal)",
        .ko: "데이터베이스 임시 파일 (-wal, -shm, -journal)"
    ],
    "preset_databases_why": [
        .en: "Constantly changing while in use, syncing causes locked file errors.",
        .zhHant: "使用中隨時在變，同步容易引起鎖檔錯誤。",
        .zhHans: "使用中随时在变，同步容易引起锁文件错误。",
        .ja: "使用中に頻繁に変更され、同期するとロックエラーの原因になります。",
        .th: "มีการเปลี่ยนแปลงตลอดเวลาขณะใช้งาน การซิงค์อาจทำให้เกิดข้อผิดพลาดในการล็อกไฟล์",
        .ko: "사용 중 빈번히 변경되어 동기화 시 파일 잠금 오류를 유발할 수 있습니다."
    ],
    "preset_git_title": [
        .en: ".git (Version control metadata)",
        .zhHant: ".git（版本控制資料夾）",
        .zhHans: ".git（版本控制文件夹）",
        .ja: ".git（バージョン管理フォルダ）",
        .th: ".git (โฟลเดอร์การควบคุมเวอร์ชัน)",
        .ko: ".git (버전 관리 폴더)"
    ],
    "preset_git_why": [
        .en: "Recommended to use Git directly for codebases.",
        .zhHant: "程式專案建議直接用 Git 管理。",
        .zhHans: "程序项目建议直接用 Git 管理。",
        .ja: "ソースコードはGitでの直接管理を推奨します。",
        .th: "แนะนำให้จัดการโค้ดโปรเจกต์ด้วย Git โดยตรง",
        .ko: "코드 프로젝트는 Git으로 직접 관리하는 것을 권장합니다."
    ],
    "preset_node_modules_title": [
        .en: "node_modules (Package directories)",
        .zhHant: "node_modules（程式專案的套件資料夾）",
        .zhHans: "node_modules（程序项目的依赖包文件夹）",
        .ja: "node_modules（パッケージフォルダ）",
        .th: "node_modules (โฟลเดอร์แพ็กเกจ)",
        .ko: "node_modules (패키지 종속성 폴더)"
    ],
    "preset_node_modules_why": [
        .en: "Contains thousands of small files that can be easily reinstalled.",
        .zhHant: "檔案又多又瑣碎，可以隨時重新安裝。",
        .zhHans: "文件又多又琐碎，可以随时重新安装。",
        .ja: "ファイル数が多く、いつでも再インストール可能です。",
        .th: "มีไฟล์ย่อยจำนวนมากและสามารถติดตั้งใหม่ได้ตลอดเวลา",
        .ko: "파일 수가 매우 많고 언제든 다시 설치할 수 있습니다."
    ],
    "preset_build_caches_title": [
        .en: "Build Caches (.build, target, build, .gradle, DerivedData, Pods)",
        .zhHant: "專案編譯快取（.build、target、build、.gradle、DerivedData、Pods）",
        .zhHans: "项目编译缓存（.build、target、build、.gradle、DerivedData、Pods）",
        .ja: "ビルドキャッシュ（.build、target、build、.gradle、DerivedData、Pods）",
        .th: "แคชบิลด์โปรเจกต์ (.build, target, build, .gradle, DerivedData, Pods)",
        .ko: "프로젝트 빌드 캐시 (.build, target, build, .gradle, DerivedData, Pods)"
    ],
    "preset_build_caches_why": [
        .en: "Compiler outputs are fragmented and regenerable; syncing them wastes I/O and causes massive conflicts.",
        .zhHant: "編譯產物瑣碎且可隨時重新產生，同步會產生大量衝突並耗損傳輸效能。",
        .zhHans: "编译产物琐碎且可随时重新生成，同步会产生大量冲突并耗损传输效能。",
        .ja: "ビルド生成物は断片化しており再生成可能です。同期すると大量の競合と転送コストが発生します。",
        .th: "ผลลัพธ์จากการบิลด์มีไฟล์ย่อยมากและสร้างใหม่ได้ตลอด การซิงค์จะทำให้เกิดข้อขัดแย้งและเปลืองแบนด์วิดท์",
        .ko: "빌드 산출물은 언제든 재생성 가능하며 동기화 시 대량의 충돌과 전송 지연을 유발합니다."
    ],
    "preset_photos_title": [
        .en: "Photos Libraries (.photoslibrary)",
        .zhHant: "照片圖庫（.photoslibrary）",
        .zhHans: "照片图库（.photoslibrary）",
        .ja: "写真ライブラリ（.photoslibrary）",
        .th: "คลังรูปภาพ (.photoslibrary)",
        .ko: "사진 보관함 (.photoslibrary)"
    ],
    "preset_photos_why": [
        .en: "Package format with complex internal databases, syncing directly may corrupt library.",
        .zhHant: "包裝檔且內部有複雜資料庫，直接同步容易損壞圖庫。",
        .zhHans: "包装文件且内部有复杂数据库，直接同步容易损坏图库。",
        .ja: "内部に複雑なDBを持つパッケージ形式のため、直接同期すると破損の原因になります。",
        .th: "เป็นแพ็กเกจที่มีฐานข้อมูลซับซ้อนภายใน การซิงค์โดยตรงอาจทำให้คลังภาพเสียหาย",
        .ko: "복잡한 내부 DB가 포함된 패키지 형식으로 직접 동기화 시 손상될 수 있습니다."
    ],
    "preset_python_title": [
        .en: "Python Virtual Environments & Caches (venv, .venv, env, __pycache__, .pytest_cache)",
        .zhHant: "Python 虛擬環境與快取（venv、.venv、env、__pycache__、.pytest_cache、.mypy_cache、.tox）",
        .zhHans: "Python 虚拟环境与缓存（venv、.venv、env、__pycache__、.pytest_cache、.mypy_cache、.tox）",
        .ja: "Python 仮想環境とキャッシュ（venv、.venv、env、__pycache__、.pytest_cache、.mypy_cache、.tox）",
        .th: "สภาพแวดล้อมเสมือนและแคช Python (venv, .venv, env, __pycache__, .pytest_cache)",
        .ko: "Python 가상환경 및 캐시 (venv, .venv, env, __pycache__, .pytest_cache)"
    ],
    "preset_python_why": [
        .en: "Contains tens of thousands of platform-dependent small files with hardcoded paths that can be reinstalled via requirements.txt.",
        .zhHant: "包含數萬個平台相依且含硬編碼絕對路徑的小檔案，無法跨機器共用，隨時可透過 pip 重建。",
        .zhHans: "包含数万个平台相依且含硬编码绝对路径的小文件，无法跨机器共用，随时可通过 pip 重建。",
        .ja: "ハードコードされた絶対パスを含む無数のプラットフォーム依存ファイルであり、共有不可かついつでも再作成可能です。",
        .th: "มีไฟล์ขนาดเล็กที่ผูกกับเครื่องจำนวนมาก ไม่สามารถแชร์ข้ามเครื่องได้ และสร้างใหม่ได้ตลอดเวลา",
        .ko: "기기별 절대 경로가 포함된 수만 개의 파일로 구성되어 기기 간 호환되지 않으며 언제든 다시 생성할 수 있습니다."
    ],
    "removable_badge": [
        .en: "Removable",
        .zhHant: "可移除",
        .zhHans: "可移除",
        .ja: "取り外し可能",
        .th: "ถอดออกได้",
        .ko: "이동식"
    ],
    "remove": [
        .en: "Remove…",
        .zhHant: "移除…",
        .zhHans: "移除…",
        .ja: "削除…",
        .th: "ลบออก…",
        .ko: "제거…"
    ],
    "retention_days_sub": [
        .en: "Kept for %d days, restorable anytime",
        .zhHant: "保留 %d 天，可隨時還原",
        .zhHans: "保留 %d 天，可随时还原",
        .ja: "%d 日間保持、いつでも復元可能",
        .th: "เก็บไว้ %d วัน กู้คืนได้ตลอดเวลา",
        .ko: "%d일 보존, 언제든지 복원 가능"
    ],
    "retention_permanent_sub": [
        .en: "Kept permanently, restorable anytime",
        .zhHant: "永久保留，可隨時還原",
        .zhHans: "永久保留，可随时还原",
        .ja: "無期限保持、いつでも復元可能",
        .th: "เก็บถาวร สามารถกู้คืนได้ตลอดเวลา",
        .ko: "영구 보존, 언제든지 복원 가능"
    ],
    "safeguard_1": [
        .en: "SHA-256 verified on every copy; bypasses cache on external drive writes to re-read and compare",
        .zhHant: "每次複製都核對 SHA-256，外接磁碟寫入後繞過快取重新讀回比對",
        .zhHans: "每次复制都核对 SHA-256，外接磁盘写入后绕过缓存重新读回比对",
        .ja: "コピー毎にSHA-256を検証、外付けディスクへの書込後はキャッシュをバイパスして再読込照合",
        .th: "ตรวจสอบ SHA-256 ทุกครั้งที่คัดลอก และอ่านซ้ำข้ามแคชเมื่อเขียนลงไดรฟ์ภายนอก",
        .ko: "복사할 때마다 SHA-256 대조, 외장 드라이브 기록 후 캐시를 우회하여 재검증"
    ],
    "safeguard_2": [
        .en: "Saves to Old Versions before deletion or overwrite, then moves to Trash",
        .zhHant: "刪除與覆蓋前先存舊版本，再進垃圾桶",
        .zhHans: "删除与覆盖前先存旧版本，再进废纸篓",
        .ja: "削除や上書きの前に旧バージョンへ保存し、その後ゴミ箱へ移動",
        .th: "บันทึกลงเวอร์ชันก่อนหน้าก่อนที่จะลบหรือเขียนทับ แล้วจึงย้ายไปถังขยะ",
        .ko: "삭제 및 덮어쓰기 전 이전 버전에 저장한 후 휴지통으로 이동"
    ],
    "safeguard_3": [
        .en: "Halts and awaits confirmation if a folder disappears, disk changes, or >50% files vanish simultaneously, preventing accidental mass deletion",
        .zhHant: "資料夾消失、換碟、一半以上檔案同時消失時，停止並等你確認，不會傳播刪除",
        .zhHans: "文件夹消失、换盘、一半以上文件同时消失时，停止并等你确认，不会传播删除",
        .ja: "フォルダ消失、ディスク交換、または過半数のファイルが同時消失した場合は停止して確認を待機",
        .th: "หยุดและรอการยืนยันเมื่อโฟลเดอร์หายไป มีการเปลี่ยนไดรฟ์ หรือไฟล์หายไปเกินครึ่งพร้อมกัน",
        .ko: "폴더 소실, 디스크 교체, 50% 이상 파일 동시 삭제 시 전파를 멈추고 사용자 승인을 대기"
    ],
    "safeguard_4": [
        .en: "Sync state database is backed up daily (7 copies kept) and restored automatically if damaged",
        .zhHant: "同步狀態資料庫每天備份（保留 7 份），損壞時自動還原",
        .zhHans: "同步状态数据库每天备份（保留 7 份），损坏时自动还原",
        .ja: "同期状態データベースは毎日バックアップされ（7世代保持）、破損時は自動復元",
        .th: "สำรองข้อมูลฐานข้อมูลสถานะการซิงค์ทุกวัน (เก็บไว้ 7 ชุด) และกู้คืนอัตโนมัติหากเสียหาย",
        .ko: "동기화 상태 데이터베이스를 매일 백업(7개 유지)하며 손상 시 자동 복구"
    ],
    "section_conflicts": [
        .en: "Conflicts",
        .zhHant: "衝突",
        .zhHans: "冲突",
        .ja: "競合",
        .th: "ข้อขัดแย้ง",
        .ko: "충돌"
    ],
    "section_diff_preview": [
        .en: "Diff Preview",
        .zhHant: "差異預覽",
        .zhHans: "差异预览",
        .ja: "差分プレビュー",
        .th: "ดูตัวอย่างความแตกต่าง",
        .ko: "차이 미리보기"
    ],
    "section_activity": [
        .en: "Activity",
        .zhHant: "同步動態",
        .zhHans: "同步动态",
        .ja: "同期アクティビティ",
        .th: "กิจกรรมการซิงค์",
        .ko: "동기화 활동"
    ],
    "section_activity_desc": [
        .en: "Real-time sync stream, transfer speeds, directions, and file operations across groups.",
        .zhHant: "即時檔案傳輸串流、同步方向、傳輸速度、耗時與詳細作業歷程。",
        .zhHans: "实时文件传输流、同步方向、传输速度、耗时与详细作业历程。",
        .ja: "リアルタイムのファイル転送ストリーム、同期方向、転送速度、所要時間、および詳細な操作ログ。",
        .th: "สตรีมการถ่ายโอนไฟล์แบบเรียลไทม์ ทิศทางการซิงค์ ความเร็ว เวลาที่ใช้ และประวัติการทำงานโดยละเอียด",
        .ko: "실시간 파일 전송 스트림, 동기화 방향, 전송 속도, 소요 시간 및 상세 작업 기록입니다."
    ],
    "section_folders": [
        .en: "Folders",
        .zhHant: "資料夾",
        .zhHans: "文件夹",
        .ja: "フォルダ",
        .th: "โฟลเดอร์",
        .ko: "폴더"
    ],
    "section_overview": [
        .en: "Overview",
        .zhHant: "概覽",
        .zhHans: "概览",
        .ja: "概要",
        .th: "ภาพรวม",
        .ko: "개요"
    ],
    "section_settings": [
        .en: "Settings",
        .zhHant: "設定",
        .zhHans: "设置",
        .ja: "設定",
        .th: "การตั้งค่า",
        .ko: "설정"
    ],
    "section_verification": [
        .en: "Verification Log",
        .zhHant: "驗證紀錄",
        .zhHans: "验证记录",
        .ja: "検証ログ",
        .th: "บันทึกการตรวจสอบ",
        .ko: "검증 기록"
    ],
    "section_versions": [
        .en: "Old Versions",
        .zhHant: "舊版本",
        .zhHans: "旧版本",
        .ja: "以前のバージョン",
        .th: "เวอร์ชันก่อนหน้า",
        .ko: "이전 버전"
    ],
    "settings_apfs_snapshot": [
        .en: "APFS Snapshot Safety Guard",
        .zhHant: "APFS 快照安全防護",
        .zhHans: "APFS 快照安全防护",
        .ja: "APFS スナップショット保護",
        .th: "การป้องกันความปลอดภัยด้วย APFS Snapshot",
        .ko: "APFS 스냅샷 안전 보호"
    ],
    "msg_apfs_sandbox_active": [
        .en: "macOS Sandbox Active: System-level snapshots are restricted in sandbox mode. SyncNexus automatically safeguards all changes via built-in Version History (.syncnexus-history)!",
        .zhHant: "macOS 沙盒安全保護中：沙盒環境無法執行系統級快照，SyncNexus 已自動透過「版本歷史紀錄（.syncnexus-history）」全程守護檔案變更！",
        .zhHans: "macOS 沙盒安全保护中：沙盒环境无法执行系统级快照，SyncNexus 已自动通过“版本历史记录（.syncnexus-history）”全程守护文件变更！",
        .ja: "macOS サンドボックス保護中: サンドボックス環境ではシステムスナップショットを実行できません。SyncNexus は「バージョン履歴（.syncnexus-history）」でファイルを自動保護します！",
        .th: "ระบบ Sandbox ของ macOS กำลังปกป้อง: ไม่สามารถเรียกใช้สแนปช็อตระดับระบบได้ SyncNexus ปกป้องการเปลี่ยนแปลงทั้งหมดผ่าน 'ประวัติเวอร์ชัน (.syncnexus-history)' โดยอัตโนมัติ!",
        .ko: "macOS 샌드박스 보호 중: 샌드박스 환경에서는 시스템 스냅샷을 실행할 수 없습니다. SyncNexus가 '버전 기록(.syncnexus-history)'을 통해 모든 변경 사항을 자동 보호합니다!"
    ],
    "msg_apfs_success": [
        .en: "APFS local safety snapshot created successfully.",
        .zhHant: "已成功建立 APFS 本地安全快照。",
        .zhHans: "已成功建立 APFS 本地安全快照。",
        .ja: "APFS ローカル安全スナップショットが正常に作成されました。",
        .th: "สร้าง APFS สแนปช็อตความปลอดภัยสำเร็จ",
        .ko: "APFS 로컬 안전 스냅샷이 성공적으로 생성되었습니다."
    ],
    "msg_apfs_failed_fallback": [
        .en: "APFS snapshot creation failed (admin privileges may be required). Protected by built-in Version History.",
        .zhHant: "建立 APFS 快照失敗（可能需要系統管理員權限）。已自動以版本歷史機制守護。",
        .zhHans: "建立 APFS 快照失败（可能需要系统管理员权限）。已自动以版本历史机制守护。",
        .ja: "APFS スナップショットの作成に失敗しました（管理者権限が必要な場合があります）。バージョン履歴により保護されています。",
        .th: "การสร้างสแนปช็อต APFS ล้มเหลว (อาจต้องใช้สิทธิ์ผู้ดูแลระบบ) ปกป้องด้วยประวัติเวอร์ชันในตัว",
        .ko: "APFS 스냅샷 생성 실패(관리자 권한이 필요할 수 있습니다). 내장된 버전 기록으로 보호됩니다."
    ],
    "msg_apfs_unsupported": [
        .en: "APFS snapshots are not supported on this platform. Protected by built-in Version History.",
        .zhHant: "目前平台不支援 APFS 快照機制。已自動以版本歷史機制守護。",
        .zhHans: "目前平台不支援 APFS 快照机制。已自动以版本历史机制守护。",
        .ja: "このプラットフォームでは APFS スナップショットはサポートされていません。バージョン履歴で保護されています。",
        .th: "แพลตฟอร์มนี้ไม่รองรับสแนปช็อต APFS ปกป้องด้วยประวัติเวอร์ชันในตัว",
        .ko: "이 플랫폼에서는 APFS 스냅샷이 지원되지 않습니다. 내장된 버전 기록으로 보호됩니다."
    ],
    "settings_btn_instructions": [
        .en: "User Guide & Permissions",
        .zhHant: "使用說明與授權檢查",
        .zhHans: "使用说明与授权检查",
        .ja: "使用ガイドと権限確認",
        .th: "คู่มือการใช้งานและการตรวจสอบสิทธิ์",
        .ko: "사용 설명 및 권한 확인"
    ],
    "settings_btn_open_log": [
        .en: "Open Log File",
        .zhHant: "開啟紀錄檔",
        .zhHans: "打开日志文件",
        .ja: "ログファイルを開く",
        .th: "เปิดไฟล์บันทึก",
        .ko: "로그 파일 열기"
    ],
    "settings_conflict_desc_keep_both": [
        .en: "The original file stays consistent with other folders; the duplicate is marked \"(conflict …)\" and kept only in the conflicting folder without propagating, until you decide in Conflicts.",
        .zhHant: "原檔會和其他資料夾保持一致；另一份加上「(conflict …)」標記，只留在發生衝突的資料夾，不會再同步出去，直到你在「衝突」頁選擇。",
        .zhHans: "原文件会和其他文件夹保持一致；另一份加上“(conflict …)”标记，只留在发生冲突的文件夹，不会再同步出去，直到你在“冲突”页选择。",
        .ja: "元ファイルは他フォルダと同期され、複製には「(conflict …)」が付与されて競合フォルダ内にのみ保持されます。",
        .th: "ไฟล์เดิมจะซิงค์ตรงกับโฟลเดอร์อื่น ส่วนอีกฉบับจะมีคำว่า \"(conflict …)\" อยู่เฉพาะในโฟลเดอร์ที่เกิดข้อขัดแย้ง",
        .ko: "원본은 다른 폴더와 동기화되며, 충돌본은 '(conflict ...)' 표시가 붙어 해당 폴더에만 격리됩니다."
    ],
    "settings_conflict_desc_newer_wins": [
        .en: "Judged by file modification time. If timestamps differ by ≤2s or cannot be determined, both copies are still kept. Older versions are always stored in Old Versions and can be restored anytime.",
        .zhHant: "以檔案修改時間判斷。兩邊時間相差 2 秒內、或無法判斷時，仍會保留兩份。不同電腦的時鐘若不準，可能選錯；舊版一律存入舊版本，隨時可以還原。",
        .zhHans: "以文件修改时间判断。两边时间相差 2 秒内、或无法判断时，仍会保留两份。不同电脑的时钟若不准，可能选错；旧版一律存入旧版本，随时可以还原。",
        .ja: "更新日時で判定します。時間差が2秒以内または判定不能な場合は両方を保持します。古いバージョンは旧バージョンに保存されます。",
        .th: "ตัดสินจากเวลาแก้ไขไฟล์ หากต่างกันไม่เกิน 2 วินาทีจะเก็บไว้ทั้งสองฉบับ โดยฉบับเดิมจะบันทึกไว้ในเวอร์ชันก่อนหน้าเสมอ",
        .ko: "수정 시간 기준으로 판별합니다. 2초 이내이거나 판별 불가 시 양쪽 모두 보존되며 구버전은 언제든 복원 가능합니다."
    ],
    "settings_conflict_keep_both": [
        .en: "Keep both copies, let me choose (Default)",
        .zhHant: "保留兩份，由我挑選（預設）",
        .zhHans: "保留两份，由我挑选（默认）",
        .ja: "両方を保持して自分で選択（デフォルト）",
        .th: "เก็บทั้งสองฉบับ ให้ฉันเลือก (ค่าเริ่มต้น)",
        .ko: "양쪽 보존 후 직접 선택 (기본값)"
    ],
    "settings_conflict_newer_wins": [
        .en: "Automatically keep newer, save older to Old Versions",
        .zhHant: "自動採用較新的，舊的存進舊版本",
        .zhHans: "自动采用较新的，旧的存进旧版本",
        .ja: "新しい方を自動採用し、古い方を旧バージョンへ保存",
        .th: "ใช้ฉบับที่ใหม่กว่าโดยอัตโนมัติ และเก็บฉบับเดิมไว้ในเวอร์ชันก่อนหน้า",
        .ko: "최신 버전을 자동 적용하고 이전 버전에 구버전 보관"
    ],
    "settings_conflict_title": [
        .en: "When a file is modified on both sides simultaneously",
        .zhHant: "同一個檔案兩邊都被修改時",
        .zhHans: "同一个文件两边都被修改时",
        .ja: "同一ファイルが双方で同時に変更された場合",
        .th: "เมื่อไฟล์เดียวกันถูกแก้ไขทั้งสองฝั่งพร้อมกัน",
        .ko: "동일한 파일이 양쪽에서 동시에 수정된 경우"
    ],
    "settings_exclude_footer": [
        .en: "Excluded items remain untouched in all folders: previously synced files won't be deleted, but won't be synced going forward.",
        .zhHant: "被排除的項目在所有資料夾裡都原封不動：之前已經同步過的不會被刪除，之後也不再同步。",
        .zhHans: "被排除的项目在所有文件夹里都原封不动：之前已经同步过的不会被删除，之后也不再同步。",
        .ja: "除外された項目はすべてのフォルダで保持されます。過去に同期されたファイルは削除されず、今後の同期対象外となります。",
        .th: "รายการที่ยกเว้นจะไม่ถูกแตะต้องในทุกโฟลเดอร์ ไฟล์ที่เคยซิงค์แล้วจะไม่ถูกลบ และจะไม่ซิงค์อีกต่อไป",
        .ko: "제외된 항목은 모든 폴더에 그대로 유지됩니다. 기존 동기화된 파일은 삭제되지 않으며 이후 동기화에서 제외됩니다."
    ],
    "settings_exclude_desc": [
        .en: "Mandatory safety rules that prevent database, photo library, or repository corruption. They cannot be disabled.",
        .zhHant: "這些是強制安全原則，用來避免資料庫、照片圖庫或版本庫損壞，因此無法停用。",
        .zhHans: "这些是强制安全原则，用来避免数据库、照片图库或版本库损坏，因此无法停用。",
        .ja: "データベース、写真ライブラリ、リポジトリの破損を防ぐ必須の安全規則です。無効にはできません。",
        .th: "กฎความปลอดภัยเหล่านี้บังคับใช้เพื่อป้องกันฐานข้อมูล คลังรูปภาพ หรือที่เก็บโค้ดเสียหาย และไม่สามารถปิดได้",
        .ko: "데이터베이스, 사진 보관함 또는 저장소 손상을 방지하기 위한 필수 안전 규칙이며 비활성화할 수 없습니다."
    ],
    "settings_exclude_title": [
        .en: "Do Not Sync These Items",
        .zhHant: "不要同步這些項目",
        .zhHans: "不要同步这些项目",
        .ja: "これらを同期から除外",
        .th: "ไม่ต้องซิงค์รายการเหล่านี้",
        .ko: "다음 항목 동기화 제외"
    ],
    "switch_to_group": [
        .en: "Switch",
        .zhHant: "切換",
        .zhHans: "切换",
        .ja: "切り替え",
        .th: "สลับ",
        .ko: "전환"
    ],
    "switch_to_group_help": [
        .en: "Switch current view and settings to inspect and manage this sync group.",
        .zhHant: "切換主要檢視視窗至此群組，以管理其資料夾端點、同步動態與獨立設定。",
        .zhHans: "切换主要检视视窗至此群组，以管理其文件夹端点、同步动态与独立设定。",
        .ja: "メイン表示をこのグループに切り替え、フォルダや同期設定を管理します。",
        .th: "สลับมุมมองหลักมายังกลุ่มนี้เพื่อจัดการโฟลเดอร์และการตั้งค่า",
        .ko: "이 그룹으로 기본 보기를 전환하여 폴더 및 동기화 설정을 관리합니다."
    ],
    "export_settings_button": [
        .en: "Export Settings",
        .zhHant: "匯出設定",
        .zhHans: "导出设置",
        .ja: "設定を出力",
        .th: "ส่งออกการตั้งค่า",
        .ko: "설정 내보내기"
    ],
    "export_settings_prompt": [
        .en: "Choose a folder to export all sync groups and database configurations.",
        .zhHant: "請選取儲存目錄，以匯出所有同步群組與端點狀態設定檔。",
        .zhHans: "请选取保存目录，以导出所有同步群组与端点状态设定档。",
        .ja: "すべての同期グループと設定を書き出すフォルダを選択してください。",
        .th: "เลือกโฟลเดอร์สำหรับส่งออกการตั้งค่ากลุ่มและฐานข้อมูลทั้งหมด",
        .ko: "모든 동기화 그룹 및 설정 파일을 내보낼 폴더를 선택하세요."
    ],
    "export_settings_ok": [
        .en: "Settings successfully exported to '%@'.",
        .zhHant: "設定已成功匯出至「%@」！",
        .zhHans: "设定已成功导出至“%@”！",
        .ja: "設定を「%@」へ正常に出力しました。",
        .th: "ส่งออกการตั้งค่าไปยัง '%@' เรียบร้อยแล้ว",
        .ko: "설정을 '%@'으로 성공적으로 내보냈습니다."
    ],
    "export_settings_failed": [
        .en: "Export failed: %@",
        .zhHant: "匯出設定失敗：%@",
        .zhHans: "导出设定失败：%@",
        .ja: "設定の出力に失敗しました：%@",
        .th: "ส่งออกการตั้งค่าไม่สำเร็จ: %@",
        .ko: "설정 내보내기 실패: %@"
    ],
    "export_settings_desc": [
        .en: "Export all group profiles and state databases for backup or migration to another Mac.",
        .zhHant: "備份並匯出所有同步群組與端點狀態，可於其他裝置一鍵匯入。",
        .zhHans: "备份并导出所有同步群组与端点状态，可于其他装置一键导入。",
        .ja: "すべてのグループ設定とデータベースをバックアップ・移行用に出力します。",
        .th: "ส่งออกการตั้งค่ากลุ่มทั้งหมดเพื่อสำรองข้อมูลหรือย้ายไปยังเครื่องอื่น",
        .ko: "백업 또는 다른 기기로의 마이그레이션을 위해 모든 동기화 설정을 내보냅니다."
    ],
    "import_legacy_help_tooltip": [
        .en: "Import previously exported SyncNexus backup folders or legacy configs (contains groups.json and state.db).",
        .zhHant: "選取先前匯出的 SyncNexus 備份資料夾或舊版設定（內含 groups.json 與 state.db）進行匯入合併。",
        .zhHans: "选取先前导出的 SyncNexus 备份文件夹或旧版设定（内含 groups.json 与 state.db）进行导入合并。",
        .ja: "以前に出力したバックアップフォルダや旧設定（groups.json、state.db）を読み込みます。",
        .th: "นำเข้าโฟลเดอร์สำรองข้อมูลหรือการตั้งค่าเดิม (ที่มี groups.json และ state.db)",
        .ko: "이전에 내보낸 백업 폴더 또는 이전 설정(groups.json 및 state.db 포함)을 가져옵니다."
    ],
    "active_current": [
        .en: "Current",
        .zhHant: "目前",
        .zhHans: "当前",
        .ja: "現在",
        .th: "ปัจจุบัน",
        .ko: "현재"
    ],
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
    "settings_safe_delete": [
        .en: "Safe Deletion (Move to Trash)",
        .zhHant: "安全刪除（移至垃圾桶）",
        .zhHans: "安全删除（移至废纸篓）",
        .ja: "安全な削除（ゴミ箱へ移動）",
        .th: "ลบอย่างปลอดภัย (ย้ายไปถังขยะ)",
        .ko: "안전 삭제 (휴지통으로 이동)"
    ],
    "settings_sync_interval": [
        .en: "Sync Frequency",
        .zhHant: "同步頻率",
        .zhHans: "同步频率",
        .ja: "同期頻度",
        .th: "ความถี่ในการซิงค์",
        .ko: "동기화 주기"
    ],
    "show_history": [
        .en: "Show History",
        .zhHant: "顯示歷史",
        .zhHans: "显示历史",
        .ja: "履歴を表示",
        .th: "แสดงประวัติ",
        .ko: "히스토리 표시"
    ],
    "start_setup": [
        .en: "Start Setup",
        .zhHant: "開始設定",
        .zhHans: "开始设置",
        .ja: "設定を開始",
        .th: "เริ่มการตั้งค่า",
        .ko: "설정 시작"
    ],
    "stat_last_deep_verify": [
        .en: "Last Deep Verification",
        .zhHant: "最近完整驗證",
        .zhHans: "最近完整验证",
        .ja: "最近の完全検証",
        .th: "การตรวจสอบเชิงลึกครั้งล่าสุด",
        .ko: "최근 정밀 검증"
    ],
    "stat_old_versions": [
        .en: "Old Versions",
        .zhHant: "舊版本",
        .zhHans: "旧版本",
        .ja: "以前のバージョン",
        .th: "เวอร์ชันก่อนหน้า",
        .ko: "이전 버전"
    ],
    "stat_sub_sha256": [
        .en: "SHA-256 verified on copy",
        .zhHant: "每次複製都核對 SHA-256",
        .zhHans: "每次复制都核对 SHA-256",
        .ja: "コピー毎にSHA-256照合",
        .th: "ตรวจสอบ SHA-256 ทุกครั้งที่คัดลอก",
        .ko: "복사할 때마다 SHA-256 대조"
    ],
    "stat_tracked_files": [
        .en: "Tracked Files",
        .zhHant: "追蹤中的檔案",
        .zhHans: "跟踪中的文件",
        .ja: "追跡対象ファイル",
        .th: "ไฟล์ที่ติดตาม",
        .ko: "추적 중인 파일"
    ],
    "operation_stopping_group": [
        .en: "Safely stopping this sync group…",
        .zhHant: "正在安全停止此同步群組…",
        .zhHans: "正在安全停止此同步群组…",
        .ja: "同期グループを安全に停止中…",
        .th: "กำลังหยุดกลุ่มซิงค์อย่างปลอดภัย…",
        .ko: "동기화 그룹을 안전하게 중지 중…"
    ],
    "operation_stopping_services": [
        .en: "Safely stopping active sync operations…",
        .zhHant: "正在安全停止目前的同步作業…",
        .zhHans: "正在安全停止当前同步任务…",
        .ja: "実行中の同期を安全に停止中…",
        .th: "กำลังหยุดการซิงค์ที่ทำงานอยู่อย่างปลอดภัย…",
        .ko: "실행 중인 동기화를 안전하게 중지 중…"
    ],
    "operation_importing_settings": [
        .en: "Importing settings in the background…",
        .zhHant: "正在背景匯入設定…",
        .zhHans: "正在后台导入设置…",
        .ja: "バックグラウンドで設定を読み込み中…",
        .th: "กำลังนำเข้าการตั้งค่าในเบื้องหลัง…",
        .ko: "백그라운드에서 설정 가져오는 중…"
    ],
    "operation_creating_snapshot": [
        .en: "Creating an APFS safety snapshot…",
        .zhHant: "正在建立 APFS 安全快照…",
        .zhHans: "正在创建 APFS 安全快照…",
        .ja: "APFS セーフティスナップショットを作成中…",
        .th: "กำลังสร้างสแนปช็อตความปลอดภัย APFS…",
        .ko: "APFS 안전 스냅샷 생성 중…"
    ],
    "progress_cancel": [
        .en: "Cancel",
        .zhHant: "取消作業",
        .zhHans: "取消任务",
        .ja: "キャンセル",
        .th: "ยกเลิก",
        .ko: "취소"
    ],
    "progress_preparing": [
        .en: "Preparing",
        .zhHant: "正在準備",
        .zhHans: "正在准备",
        .ja: "準備中",
        .th: "กำลังเตรียม",
        .ko: "준비 중"
    ],
    "progress_scanning": [
        .en: "Scanning folders",
        .zhHant: "正在掃描資料夾",
        .zhHans: "正在扫描文件夹",
        .ja: "フォルダをスキャン中",
        .th: "กำลังสแกนโฟลเดอร์",
        .ko: "폴더 스캔 중"
    ],
    "progress_comparing": [
        .en: "Comparing files",
        .zhHant: "正在比對檔案",
        .zhHans: "正在比对文件",
        .ja: "ファイルを比較中",
        .th: "กำลังเปรียบเทียบไฟล์",
        .ko: "파일 비교 중"
    ],
    "progress_transferring": [
        .en: "Applying changes",
        .zhHant: "正在套用變更",
        .zhHans: "正在应用更改",
        .ja: "変更を適用中",
        .th: "กำลังใช้การเปลี่ยนแปลง",
        .ko: "변경 사항 적용 중"
    ],
    "progress_verifying": [
        .en: "Verifying file contents",
        .zhHant: "正在驗證檔案內容",
        .zhHans: "正在验证文件内容",
        .ja: "ファイル内容を検証中",
        .th: "กำลังตรวจสอบเนื้อหาไฟล์",
        .ko: "파일 내용 확인 중"
    ],
    "progress_finalizing": [
        .en: "Finishing",
        .zhHant: "正在完成作業",
        .zhHans: "正在完成任务",
        .ja: "完了処理中",
        .th: "กำลังดำเนินการให้เสร็จ",
        .ko: "마무리 중"
    ],
    "progress_cancelling": [
        .en: "Cancelling safely",
        .zhHant: "正在安全取消",
        .zhHans: "正在安全取消",
        .ja: "安全にキャンセル中",
        .th: "กำลังยกเลิกอย่างปลอดภัย",
        .ko: "안전하게 취소 중"
    ],
    "status_all_normal": [
        .en: "Everything is normal",
        .zhHant: "一切正常",
        .zhHans: "一切正常",
        .ja: "すべて正常",
        .th: "ทุกอย่างปกติ",
        .ko: "모두 정상"
    ],
    "status_conflicts_pending": [
        .en: "%d conflicts awaiting decision",
        .zhHant: "%d 個衝突等你決定",
        .zhHans: "%d 个冲突等你决定",
        .ja: "%d 件の競合の解決待ち",
        .th: "%d ข้อขัดแย้งรอการตัดสินใจ",
        .ko: "%d개의 충돌 해결 대기 중"
    ],
    "status_detail_paused": [
        .en: "Click Resume to restart automatic sync",
        .zhHant: "按「繼續」恢復自動同步",
        .zhHans: "按“继续”恢复自动同步",
        .ja: "「再開」をクリックして同期を再開",
        .th: "กดปุ่มเล่นต่อเพื่อดำเนินการซิงค์อัตโนมัติ",
        .ko: "'계속'을 눌러 자동 동기화 재개"
    ],
    "status_detail_syncing": [
        .en: "Comparing and updating folders",
        .zhHant: "正在比對並更新各個資料夾",
        .zhHans: "正在比对并更新各个文件夹",
        .ja: "フォルダを比較および更新中",
        .th: "กำลังเปรียบเทียบและอัปเดตโฟลเดอร์",
        .ko: "폴더 비교 및 업데이트 중"
    ],
    "status_error": [
        .en: "Sync error occurred",
        .zhHant: "同步發生錯誤",
        .zhHans: "同步发生错误",
        .ja: "同期エラーが発生しました",
        .th: "เกิดข้อผิดพลาดในการซิงค์",
        .ko: "동기화 오류 발생"
    ],
    "status_need_check": [
        .en: "Files require review",
        .zhHant: "有檔案需要檢查",
        .zhHans: "有文件需要检查",
        .ja: "確認が必要なファイルがあります",
        .th: "มีไฟล์ที่ต้องตรวจสอบ",
        .ko: "확인이 필요한 파일이 있습니다"
    ],
    "status_need_confirm": [
        .en: "Confirmation required",
        .zhHant: "需要你確認",
        .zhHans: "需要你确认",
        .ja: "確認が必要です",
        .th: "ต้องการการยืนยัน",
        .ko: "확인 필요"
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
    "status_paused": [
        .en: "Paused",
        .zhHant: "已暫停",
        .zhHans: "已暂停",
        .ja: "一時停止中",
        .th: "หยุดชั่วคราว",
        .ko: "일시 중지됨"
    ],
    "status_starting": [
        .en: "Starting up…",
        .zhHant: "正在啟動…",
        .zhHans: "正在启动…",
        .ja: "起動中…",
        .th: "กำลังเริ่มต้น…",
        .ko: "시작 중…"
    ],
    "status_syncing": [
        .en: "Syncing…",
        .zhHant: "同步中…",
        .zhHans: "同步中…",
        .ja: "同期中…",
        .th: "กำลังซิงค์…",
        .ko: "동기화 중…"
    ],
    "suspected_corrupted_count": [
        .en: "%d suspected corrupted",
        .zhHant: "%d 個疑似損壞",
        .zhHans: "%d 个疑似损坏",
        .ja: "%d 件の破損疑い",
        .th: "สงสัยว่าเสียหาย %d ไฟล์",
        .ko: "%d개 손상 의심"
    ],
    "verification_btn_accept_current": [
        .en: "Accept Current Content",
        .zhHant: "保留現在的內容",
        .zhHans: "保留现在的内容",
        .ja: "現在の内容を採用",
        .th: "ยอมรับเนื้อหาปัจจุบัน",
        .ko: "현재 내용 유지"
    ],
    "verification_btn_repair_others": [
        .en: "Repair from Other Folders",
        .zhHant: "用其他資料夾的版本修復",
        .zhHans: "用其他文件夹的版本修复",
        .ja: "他フォルダのバージョンで修復",
        .th: "ซ่อมแซมจากโฟลเดอร์อื่น",
        .ko: "다른 폴더의 버전으로 복구"
    ],
    "verification_btn_start": [
        .en: "Start Verification",
        .zhHant: "開始驗證",
        .zhHans: "开始验证",
        .ja: "検証を開始",
        .th: "เริ่มการตรวจสอบ",
        .ko: "검증 시작"
    ],
    "verification_header_desc": [
        .en: "Syncing's biggest danger is silent corruption. Review recent verification results here.",
        .zhHant: "同步最怕「看不出來的小錯」。這裡顯示最近一次驗證的結果。",
        .zhHans: "同步最怕“看不出来的小错”。这里显示最近一次验证的结果。",
        .ja: "同期における最大のリスクは見えない破損です。ここでは最近の検証結果を表示します。",
        .th: "ความเสี่ยงที่ใหญ่ที่สุดของการซิงค์คือข้อผิดพลาดที่มองไม่เห็น หน้านี้แสดงผลการตรวจสอบล่าสุด",
        .ko: "동기화의 가장 큰 위험은 눈에 띄지 않는 손상입니다. 여기에서 최근 검증 결과를 확인하세요."
    ],
    "verification_issue_desc": [
        .en: "These files are quarantined so corrupted data won't propagate to other folders. Other folders retain the correct version. \"Repair\" backs up the damaged file into Old Versions and restores the correct one.",
        .zhHant: "這些檔案已被隔離，壞掉的內容不會傳到其他資料夾；其他資料夾仍持有正確的版本。「修復」會把壞掉的內容存進舊版本，再放回正確的。",
        .zhHans: "这些文件已被隔离，损坏的内容不会传到其他文件夹；其他文件夹仍持有正确的版本。“修复”会把损坏的内容存进旧版本，再放回正确的。",
        .ja: "これらのファイルは隔離されているため破損データは他へ伝播しません。「修復」を選択すると破損ファイルを旧バージョンに退避し、正常なファイルを復元します。",
        .th: "ไฟล์เหล่านี้ถูกแยกไว้เพื่อไม่ให้ความเสียหายลามไปยังโฟลเดอร์อื่น \"ซ่อมแซม\" จะสำรองข้อมูลที่เสียหายไว้ในเวอร์ชันก่อนหน้าและนำไฟล์ที่ถูกต้องกลับมา",
        .ko: "이 파일들은 격리되어 손상된 데이터가 전파되지 않습니다. '복구'를 누르면 손상본을 이전 버전에 보관하고 올바른 버전을 복원합니다."
    ],
    "verification_issue_location": [
        .en: "%1$@ · On \"%2$@\"",
        .zhHant: "%1$@　· 在「%2$@」",
        .zhHans: "%1$@　· 在“%2$@”",
        .ja: "%1$@ ·「%2$@」上",
        .th: "%1$@ · บน \"%2$@\"",
        .ko: "%1$@ · '%2$@'에 위치"
    ],
    "verification_issue_title": [
        .en: "Content differs from record, but size and mtime are unchanged",
        .zhHant: "內容與紀錄不符，但大小與修改時間都沒變",
        .zhHans: "内容与记录不符，但大小与修改时间都没变",
        .ja: "内容は記録と異なりますが、サイズと変更日時は一致しています",
        .th: "เนื้อหาไม่ตรงกับบันทึก แต่ขนาดและเวลาแก้ไขไม่เปลี่ยนแปลง",
        .ko: "내용이 기록과 일치하지 않으나 크기와 수정 시간은 동일함"
    ],
    "verification_safeguards_title": [
        .en: "Safety Mechanisms",
        .zhHant: "保護機制",
        .zhHans: "保护机制",
        .ja: "保護メカニズム",
        .th: "กลไกความปลอดภัย",
        .ko: "보호 메커니즘"
    ],
    "verification_stat_clean_sub_none": [
        .en: "No runs without skipped items yet",
        .zhHant: "還沒有一輪沒有略過項目的同步",
        .zhHans: "还没有一轮没有略过项目的同步",
        .ja: "スキップなしの同期はまだありません",
        .th: "ยังไม่มีการซิงค์ที่ไม่มีการข้ามไฟล์",
        .ko: "건너뛴 항목이 없는 동기화 실행 이력 없음"
    ],
    "verification_stat_clean_sync": [
        .en: "Last Clean Sync",
        .zhHant: "最近一次完全無誤的同步",
        .zhHans: "最近一次完全无误的同步",
        .ja: "最新の正常同期",
        .th: "การซิงค์ที่สมบูรณ์ล่าสุด",
        .ko: "최근 무결성 동기화"
    ],
    "verification_stat_issues": [
        .en: "Suspected Corrupted",
        .zhHant: "疑似損壞",
        .zhHans: "疑似损坏",
        .ja: "破損の疑い",
        .th: "สงสัยว่าเสียหาย",
        .ko: "손상 의심"
    ],
    "verification_stat_quarantined": [
        .en: "Quarantined, will not propagate",
        .zhHant: "已隔離，不會傳播",
        .zhHans: "已隔离，不会传播",
        .ja: "隔離済み、伝播しません",
        .th: "แยกไว้แล้ว จะไม่แพร่กระจาย",
        .ko: "격리됨, 전파되지 않음"
    ],
    "verification_stat_verify_sub": [
        .en: "Runs weekly automatically",
        .zhHant: "每週自動進行一次",
        .zhHans: "每周自动进行一次",
        .ja: "毎週自動実行",
        .th: "ทำงานอัตโนมัติทุกสัปดาห์",
        .ko: "매주 자동 실행"
    ],
    "verification_verify_now_desc": [
        .en: "Re-reads every file and verifies SHA-256 hashes. May take some time for large file counts.",
        .zhHant: "重新讀取每一個檔案並核對 SHA-256。檔案很多時會花一些時間。",
        .zhHans: "重新读取每一个文件并核对 SHA-256。文件很多时会花一些时间。",
        .ja: "全ファイルを再読込してSHA-256を検証します。ファイル数が多いと時間がかかります。",
        .th: "อ่านไฟล์ทุกไฟล์ซ้ำและตรวจสอบ SHA-256 อาจใช้เวลาหากมีไฟล์จำนวนมาก",
        .ko: "모든 파일을 다시 읽어 SHA-256 해시를 대조합니다. 파일이 많은 경우 시간이 걸릴 수 있습니다."
    ],
    "verification_verify_now_title": [
        .en: "Run Deep Verification Now",
        .zhHant: "立即完整驗證",
        .zhHans: "立即完整验证",
        .ja: "今すぐ完全検証を実行",
        .th: "ตรวจสอบเชิงลึกทันที",
        .ko: "지금 정밀 검증 실행"
    ],
    "versions_alert_clear_confirm": [
        .en: "Delete All",
        .zhHant: "全部刪除",
        .zhHans: "全部删除",
        .ja: "すべて削除",
        .th: "ลบทั้งหมด",
        .ko: "모두 삭제"
    ],
    "versions_alert_clear_message": [
        .en: "These files will be erased directly without going to Trash, and cannot be undone. Active synced files are unaffected.",
        .zhHant: "這些檔案會直接刪除，不會進垃圾桶，無法復原。同步中的正式檔案不受影響。",
        .zhHans: "这些文件会直接删除，不会进废纸篓，无法复原。同步中的正式文件不受影响。",
        .ja: "これらのファイルはゴミ箱に入らず完全に削除され、元に戻せません。同期中のファイルには影響ありません。",
        .th: "ไฟล์เหล่านี้จะถูกลบโดยตรงโดยไม่ย้ายไปถังขยะและไม่สามารถกู้คืนได้ ไฟล์ที่กำลังซิงค์อยู่จะไม่ได้รับผลกระทบ",
        .ko: "이 파일들은 휴지통으로 이동하지 않고 즉시 영구 삭제되며 복구할 수 없습니다. 동기화 중인 정식 파일은 영향을 받지 않습니다."
    ],
    "versions_alert_clear_title": [
        .en: "Permanently delete all old versions?",
        .zhHant: "永久刪除所有舊版本？",
        .zhHans: "永久删除所有旧版本？",
        .ja: "すべての旧バージョンを完全に削除しますか？",
        .th: "ลบเวอร์ชันเก่าทั้งหมดอย่างถาวรหรือไม่?",
        .ko: "모든 이전 버전을 영구적으로 삭제하시겠습니까?"
    ],
    "versions_auto_clean_desc": [
        .en: "When total size exceeds 20 GB, oldest versions will also be pruned automatically.",
        .zhHant: "總量超過 20 GB 時，也會從最舊的開始清。",
        .zhHans: "总量超过 20 GB 时，也会从最旧的开始清。",
        .ja: "合計サイズが20 GBを超えると、最も古いものから自動削除されます。",
        .th: "เมื่อขนาดรวมเกิน 20 GB ระบบจะเริ่มลบเวอร์ชันเก่าที่สุดโดยอัตโนมัติ",
        .ko: "총 용량이 20GB를 초과하면 가장 오래된 버전부터 자동으로 정리됩니다."
    ],
    "versions_auto_clean_label": [
        .en: "Auto-cleanup: Keep",
        .zhHant: "自動清理：保留",
        .zhHans: "自动清理：保留",
        .ja: "自動クリーンアップ: 保持",
        .th: "ล้างอัตโนมัติ: เก็บไว้",
        .ko: "자동 정리: 보관"
    ],
    "versions_btn_clean_expired": [
        .en: "Purge Expired",
        .zhHant: "清理過期版本",
        .zhHans: "清理过期版本",
        .ja: "期限切れを削除",
        .th: "ล้างเวอร์ชันที่หมดอายุ",
        .ko: "만료된 버전 정리"
    ],
    "versions_btn_clear_all": [
        .en: "Clear All…",
        .zhHant: "全部清除…",
        .zhHans: "全部清除…",
        .ja: "すべて消去…",
        .th: "ล้างทั้งหมด…",
        .ko: "모두 지우기…"
    ],
    "versions_btn_restore": [
        .en: "Restore",
        .zhHant: "還原",
        .zhHans: "还原",
        .ja: "復元",
        .th: "กู้คืน",
        .ko: "복원"
    ],
    "versions_empty": [
        .en: "No old versions yet.",
        .zhHant: "目前沒有舊版本。",
        .zhHans: "目前没有旧版本。",
        .ja: "以前のバージョンはありません。",
        .th: "ยังไม่มีเวอร์ชันก่อนหน้า",
        .ko: "이전 버전이 없습니다."
    ],
    "versions_header_desc": [
        .en: "Before files are overwritten by newer versions, deleted, or restored, previous contents are safely saved here. Revert accidental changes or deletions with a single click.",
        .zhHant: "檔案被新版覆蓋、被刪除或被還原前，舊內容都會先存在這裡。改錯了、誤刪了，都可以一鍵還原。",
        .zhHans: "文件被新版覆盖、被删除或被还原前，旧内容都会先存在这里。改错了、误删了，都可以一键还原。",
        .ja: "新しいバージョンで上書き、削除、または復元される前に、以前の内容が安全に保存されます。ワンクリックで元に戻せます。",
        .th: "ก่อนที่ไฟล์จะถูกเขียนทับ ลบ หรือกู้คืน เนื้อหาเดิมจะถูกบันทึกไว้ที่นี่ สามารถกู้คืนได้ในคลิกเดียว",
        .ko: "파일이 새 버전으로 덮어쓰이거나 삭제, 복원되기 전에 이전 내용이 여기에 보관됩니다. 클릭 한 번으로 복원할 수 있습니다."
    ],
    "versions_no_matches": [
        .en: "No matching results.",
        .zhHant: "沒有符合的結果。",
        .zhHans: "没有符合的结果。",
        .ja: "一致する結果がありません。",
        .th: "ไม่พบผลลัพธ์ที่ตรงกัน",
        .ko: "일치하는 결과가 없습니다."
    ],
    "versions_restorable_title": [
        .en: "Restorable Versions",
        .zhHant: "可還原的版本",
        .zhHans: "可还原的版本",
        .ja: "復元可能なバージョン",
        .th: "เวอร์ชันที่กู้คืนได้",
        .ko: "복원 가능한 버전"
    ],
    "versions_search_placeholder": [
        .en: "Search filename or folder",
        .zhHant: "搜尋檔名或資料夾",
        .zhHans: "搜索文件名或文件夹",
        .ja: "ファイル名やフォルダを検索",
        .th: "ค้นหาชื่อไฟล์หรือโฟลเดอร์",
        .ko: "파일명 또는 폴더 검색"
    ],
    "versions_showing_100_hint": [
        .en: "Showing latest 100 items; refine with search.",
        .zhHant: "只顯示最新的 100 個；用搜尋縮小範圍。",
        .zhHans: "只显示最新的 100 个；用搜索缩小范围。",
        .ja: "最新100件を表示中。検索で絞り込んでください。",
        .th: "แสดง 100 รายการล่าสุด ใช้การค้นหาเพื่อจำกัดผลลัพธ์",
        .ko: "최신 100개만 표시 중입니다. 검색으로 범위를 좁히세요."
    ],
    "versions_stat_files_sub": [
        .en: "old version files",
        .zhHant: "個舊版本檔案",
        .zhHans: "个旧版本文件",
        .ja: "個の旧バージョンファイル",
        .th: "ไฟล์เวอร์ชันก่อนหน้า",
        .ko: "개의 이전 버전 파일"
    ],
    "versions_stat_none": [
        .en: "None currently",
        .zhHant: "目前沒有",
        .zhHans: "目前没有",
        .ja: "現在なし",
        .th: "ขณะนี้ไม่มี",
        .ko: "현재 없음"
    ],
    "versions_stat_oldest_from": [
        .en: "Oldest from %@",
        .zhHant: "最早從 %@",
        .zhHans: "最早从 %@",
        .ja: "最古: %@",
        .th: "เก่าที่สุดตั้งแต่ %@",
        .ko: "가장 오래된 항목: %@"
    ],
    "versions_stat_retained": [
        .en: "Retained",
        .zhHant: "已保留",
        .zhHans: "已保留",
        .ja: "保持済み",
        .th: "เก็บรักษาไว้",
        .ko: "보존됨"
    ],
    "versions_stat_storage": [
        .en: "Storage Used",
        .zhHant: "占用空間",
        .zhHans: "占用空间",
        .ja: "使用容量",
        .th: "พื้นที่ที่ใช้",
        .ko: "사용 용량"
    ],
    "welcome_bullet_1": [
        .en: "Any addition, edit, deletion, or rename in one folder instantly replicates across all others.",
        .zhHant: "任何一個資料夾有新增、修改、刪除或改名，其他的都會跟著變。",
        .zhHans: "任何一个文件夹有新增、修改、删除或改名，其他的都会跟着变。",
        .ja: "追加、編集、削除、名前変更はすべてのフォルダへ即座に反映されます。",
        .th: "การเพิ่ม แก้ไข ลบ หรือเปลี่ยนชื่อในโฟลเดอร์ใดๆ จะมีผลกับโฟลเดอร์อื่นทันที",
        .ko: "어느 폴더에서든 추가, 수정, 삭제, 이름 변경이 발생하면 다른 모든 폴더에 즉시 반영됩니다."
    ],
    "welcome_bullet_2": [
        .en: "External drives can be disconnected anytime; reconnecting reconciles automatically without mass deletions.",
        .zhHant: "外接磁碟可以隨時拔除、到別台電腦修改；接回來會自動對帳，不會被當成「檔案全被刪除」。",
        .zhHans: "外接移动硬盘可以随时拔除、到别台电脑修改；接回来会自动对账，不会被当成“文件全被删除”。",
        .ja: "外付けドライブはいつでも取り外し可能。再接続時に自動照合され、全削除扱いにはなりません。",
        .th: "สามารถถอดไดรฟ์ภายนอกออกได้ตลอดเวลา เมื่อเสียบกลับจะซิงค์ใหม่อัตโนมัติโดยไม่ลบไฟล์",
        .ko: "외장 드라이브를 언제든 분리할 수 있으며, 재연결 시 파일 삭제 없이 자동으로 대조됩니다."
    ],
    "welcome_bullet_3": [
        .en: "Deleted files move to Trash, overwritten versions are backed up in Old Versions, fully recoverable.",
        .zhHant: "刪除的檔案先進垃圾桶，被取代的舊版本另存一份，改錯了都能找回。",
        .zhHans: "删除的文件先进废纸篓，被取代的旧版本另存一份，改错了都能找回。",
        .ja: "削除ファイルはゴミ箱へ、上書きされた旧版はバックアップされいつでも復元可能です。",
        .th: "ไฟล์ที่ถูกลบจะย้ายไปที่ถังขยะ และสำรองเวอร์ชันก่อนหน้าไว้ กู้คืนได้เสมอหากเกิดข้อผิดพลาด",
        .ko: "삭제된 파일은 휴지통으로 이동하고 이전 버전은 별도 보관되어 언제든 되돌릴 수 있습니다."
    ],
    "welcome_bullet_4": [
        .en: "When a file is modified on both sides simultaneously, it will not be overwritten silently; you decide.",
        .zhHant: "同一個檔案兩邊都被修改時不會悄悄覆蓋，由你決定留哪一份。",
        .zhHans: "同一个文件两边都被修改时不会悄悄覆盖，由你决定留哪一份。",
        .ja: "双方で同時に変更された場合、勝手に上書きされることなく自分で選択できます。",
        .th: "เมื่อไฟล์เดียวกันถูกแก้ไขทั้งสองฝั่ง จะไม่มีการเขียนทับโดยไม่บอก คุณเป็นผู้ตัดสินใจ",
        .ko: "동일 파일이 양쪽에서 수정되었을 때 자동으로 덮어쓰지 않고 사용자가 결정하도록 합니다."
    ],
    "welcome_subtitle": [
        .en: "Keep your specified folders — Local, iCloud Drive, Google Drive, External Drives — perfectly in sync.",
        .zhHant: "讓你指定的幾個資料夾 —— 本機、iCloud 雲碟、Google Drive、外接磁碟 —— 互相保持一致。",
        .zhHans: "让你指定的几个文件夹 —— 本地、iCloud 云盘、Google Drive、外接移动硬盘 —— 互相保持一致。",
        .ja: "ローカル、iCloud Drive、Google Drive、外付けドライブなど、指定したフォルダを同期させます。",
        .th: "ทำให้โฟลเดอร์ที่คุณระบุ — ในเครื่อง, iCloud Drive, Google Drive, ไดรฟ์ภายนอก — สอดคล้องกันอย่างสมบูรณ์",
        .ko: "로컬, iCloud Drive, Google Drive, 외장 드라이브 등 지정한 폴더들을 완벽하게 동기화합니다."
    ],
    "welcome_title": [
        .en: "Welcome to Sync-Nexus",
        .zhHant: "歡迎使用 Sync-Nexus",
        .zhHans: "欢迎使用 Sync-Nexus",
        .ja: "Sync-Nexus へようこそ",
        .th: "ยินดีต้อนรับสู่ Sync-Nexus",
        .ko: "Sync-Nexus에 오신 것을 환영합니다"
    ],
    "window_popover_preview": [
        .en: "Popover Preview",
        .zhHant: "彈出視窗預覽",
        .zhHans: "弹出窗口预览",
        .ja: "ポップオーバープレビュー",
        .th: "ดูตัวอย่างป๊อปโอเวอร์",
        .ko: "팝오버 미리보기"
    ],
    "window_welcome_title": [
        .en: "Welcome to Sync-Nexus",
        .zhHant: "歡迎使用 Sync-Nexus",
        .zhHans: "欢迎使用 Sync-Nexus",
        .ja: "Sync-Nexus へようこそ",
        .th: "ยินดีต้อนรับสู่ Sync-Nexus",
        .ko: "Sync-Nexus 시작하기"
    ],
    "years_count": [
        .en: "%d year(s)",
        .zhHant: "%d 年",
        .zhHans: "%d 年",
        .ja: "%d 年",
        .th: "%d ปี",
        .ko: "%d년"
    ],
    "btn_close": [
        .en: "Close",
        .zhHant: "關閉",
        .zhHans: "关闭",
        .ja: "閉じる",
        .th: "ปิด",
        .ko: "닫기"
    ],
    "manual_inapp_title": [
        .en: "SyncNexus User Manual",
        .zhHant: "SyncNexus 操作使用手冊",
        .zhHans: "SyncNexus 操作使用手册",
        .ja: "SyncNexus 取扱説明書",
        .th: "คู่มือการใช้งาน SyncNexus",
        .ko: "SyncNexus 사용 설명서"
    ],
    "privacy_inapp_title": [
        .en: "SyncNexus Privacy Policy",
        .zhHant: "SyncNexus 隱私權保護政策",
        .zhHans: "SyncNexus 隐私保护政策",
        .ja: "SyncNexus プライバシーポリシー",
        .th: "นโยบายความเป็นส่วนตัว SyncNexus",
        .ko: "SyncNexus 개인정보 보호정책"
    ],
    "manual_inapp_subtitle": [
        .en: "Local-First Multi-Platform Smart Sync Guide",
        .zhHant: "本機優先 · 跨平台智慧同步指南",
        .zhHans: "本机优先 · 跨平台智能同步指南",
        .ja: "ローカルファースト・クロスプラットフォーム同期ガイド",
        .th: "คำแนะนำการซิงค์อัจฉริยะแบบเน้นโลคอลข้ามแพลตฟอร์ม",
        .ko: "로컬 우선 · 크로스 플랫폼 스마트 동기화 가이드"
    ],
    "manual_inapp_footer_note": [
        .en: "SyncNexus strictly complies with App Store and Sandbox security regulations. Zero telemetry.",
        .zhHant: "SyncNexus 嚴格遵循 App Store 沙盒安全標準，零追蹤、零伺服器備存。",
        .zhHans: "SyncNexus 严格遵循 App Store 沙盒安全标准，零追踪、零服务器备存。",
        .ja: "SyncNexus は App Store およびサンドボックスのセキュリティ基準に厳格に準拠しています。",
        .th: "SyncNexus ปฏิบัติตามมาตรฐานความปลอดภัย App Store และ Sandbox อย่างเคร่งครัด",
        .ko: "SyncNexus는 App Store 및 샌드박스 보안 규정을 엄격히 준수합니다. 원격 분석 제로."
    ],
    "manual_step1_title": [
        .en: "1. Quick Start: Select Folders",
        .zhHant: "1. 快速開始：加入同步資料夾",
        .zhHans: "1. 快速开始：添加同步文件夹",
        .ja: "1. クイックスタート: 同期フォルダを追加",
        .th: "1. เริ่มต้นอย่างรวดเร็ว: เพิ่มโฟลเดอร์ซิงค์",
        .ko: "1. 빠른 시작: 동기화 폴더 추가"
    ],
    "manual_step1_desc": [
        .en: "Click 'Add Folder...' below. You only need to pick 2 or more folders you want to keep identical. SyncNexus will handle all changes automatically!",
        .zhHant: "點擊下方的「加入資料夾...」按鈕。只要選取 2 個以上想要保持同步的資料夾，SyncNexus 就會自動保持兩邊檔案隨時完全一致！",
        .zhHans: "点击下方的“添加文件夹...”按钮。只要选取 2 个以上想要保持同步的文件夹，SyncNexus 就会自动保持两边文件随时完全一致！",
        .ja: "「フォルダを追加...」をクリックします。同期を保ちたいフォルダを2つ以上選択するだけで、SyncNexus が自動的にファイルを一致させます！",
        .th: "คลิกปุ่ม 'เพิ่มโฟลเดอร์...' ด้านล่าง เพียงเลือก 2 โฟลเดอร์ขึ้นไปที่คุณต้องการให้เหมือนกัน SyncNexus จะจัดการให้ตรงกันโดยอัตโนมัติ!",
        .ko: "'폴더 추가...' 버튼을 클릭합니다. 일치시키고 싶은 2개 이상의 폴더를 선택하기만 하면 SyncNexus가 항상 완전히 동일하게 유지합니다!"
    ],
    "manual_badge_quickstart": [
        .en: "Quick Start",
        .zhHant: "快速上手",
        .zhHans: "快速上手",
        .ja: "クイックスタート",
        .th: "เริ่มต้นเร็ว",
        .ko: "빠른 시작"
    ],
    "manual_local_title": [
        .en: "Computer Local Folder",
        .zhHant: "電腦本機資料夾",
        .zhHans: "电脑本机文件夹",
        .ja: "PC ローカルフォルダ",
        .th: "โฟลเดอร์ในเครื่องคอมพิวเตอร์",
        .ko: "컴퓨터 로컬 폴더"
    ],
    "manual_local_desc": [
        .en: "Open 'Finder', click 'Documents' or your home folder in the sidebar, and choose the folder you want to sync.",
        .zhHant: "點開「Finder（訪達）」，點選左側側邊欄的「文件」或您的個人專屬資料夾，選取準備要同步的目錄。",
        .zhHans: "打开“Finder（访达）”，点击左侧边栏的“文档”或您的个人专属文件夹，选取准备要同步的目录。",
        .ja: "「Finder」を開き、サイドバーの「書類」またはホームフォルダをクリックして、同期したいフォルダを選択します。",
        .th: "เปิด 'Finder' คลิก 'เอกสาร' หรือโฟลเดอร์ส่วนตัวของคุณในแถบด้านข้าง แล้วเลือกโฟลเดอร์ที่ต้องการซิงค์",
        .ko: "'Finder'를 열고 사이드바에서 '문서' 또는 사용자 홈 폴더를 클릭한 후 동기화할 폴더를 선택합니다."
    ],
    "manual_icloud_title": [
        .en: "iCloud Drive",
        .zhHant: "iCloud 雲碟",
        .zhHans: "iCloud 云盘",
        .ja: "iCloud Drive",
        .th: "iCloud Drive",
        .ko: "iCloud Drive"
    ],
    "manual_icloud_desc": [
        .en: "Open 'Finder', click 'iCloud Drive' in the left sidebar, and select the folder you want to sync. SyncNexus will automatically monitor changes.",
        .zhHant: "點開「Finder（訪達）」，點擊側邊欄的「iCloud 雲碟」後，選取準備要同步的目錄。SyncNexus 會自動偵測並同步。",
        .zhHans: "打开“Finder（访达）”，点击侧边栏的“iCloud 云盘”后，选取准备要同步的目录。SyncNexus 会自动检测并同步。",
        .ja: "「Finder」を開き、左側サイドバーの「iCloud Drive」をクリックし、同期するフォルダを選択します。",
        .th: "เปิด 'Finder' คลิก 'iCloud Drive' ในแถบด้านข้างซ้าย แล้วเลือกโฟลเดอร์ที่ต้องการซิงค์ SyncNexus จะตรวจหาและซิงค์โดยอัตโนมัติ",
        .ko: "'Finder'를 열고 왼쪽 사이드바에서 'iCloud Drive'를 클릭한 다음 동기화할 폴더를 선택합니다."
    ],
    "manual_gdrive_title": [
        .en: "Google Drive",
        .zhHant: "Google 雲端硬碟 (Google Drive)",
        .zhHans: "Google 云端硬盘 (Google Drive)",
        .ja: "Google ドライブ",
        .th: "Google ไดรฟ์ (Google Drive)",
        .ko: "Google 드라이브"
    ],
    "manual_gdrive_desc": [
        .en: "Open 'Finder', click 'Google Drive' in the left sidebar, click 'My Drive', and select the folder you want to sync.",
        .zhHant: "點開「Finder（訪達）」，點擊側邊欄的「Google Drive」、再點擊「我的雲端硬碟」後，選取準備要同步的目錄。",
        .zhHans: "打开“Finder（访达）”，点击侧边栏的“Google Drive”、再点击“我的云端硬盘”后，选取准备要同步的目录。",
        .ja: "「Finder」を開き、左側サイドバーの「Google Drive」をクリックし、「マイドライブ」をクリックして同期するフォルダを選択します。",
        .th: "เปิด 'Finder' คลิก 'Google Drive' ในแถบด้านข้างซ้าย จากนั้นคลิก 'ไดรฟ์ของฉัน' แล้วเลือกโฟลเดอร์ที่ต้องการซิงค์",
        .ko: "'Finder'를 열고 왼쪽 사이드바의 'Google Drive'를 클릭한 후 '내 드라이브'를 클릭하여 동기화할 폴더를 선택합니다."
    ],
    "manual_usb_title": [
        .en: "External USB Flash Drive / Portable Hard Drive",
        .zhHant: "外接式隨身碟 / 行動硬碟",
        .zhHans: "外接式 U 盘 / 移动硬盘",
        .ja: "外付け USB メモリ / ポータブル HDD",
        .th: "แฟลชไดรฟ์ USB / ฮาร์ดดิสก์พกพาภายนอก",
        .ko: "외장 USB 드라이브 / 외장 하드"
    ],
    "manual_usb_desc": [
        .en: "Plug in your USB drive, open 'Finder', click your drive name under 'Locations' in the sidebar, and select the folder. Formatting as ExFAT is recommended for sharing between Mac and Windows!",
        .zhHant: "插上隨身碟，點開「Finder（訪達）」，在左側「位置」下方點擊您的隨身碟名稱，選取準備要同步的目錄。格式建議為 ExFAT，方便在 Mac 與 Windows 之間通用！",
        .zhHans: "插入 U 盘，打开“Finder（访达）”，在左侧“位置”下方点击您的 U 盘名称，选取准备要同步的目录。格式建议为 ExFAT，方便在 Mac 与 Windows 之间通用！",
        .ja: "USB ドライブを接続し、「Finder」を開き、サイドバーの「場所」の下にあるドライブ名をクリックして同期するフォルダを選択します。Mac と Windows 間で共有するには ExFAT 形式が推奨されます！",
        .th: "เสียบแฟลชไดรฟ์ เปิด 'Finder' คลิกชื่อไดรฟ์ของคุณใต้ 'ตำแหน่ง' ในแถบด้านข้าง แล้วเลือกโฟลเดอร์ แนะนำให้ฟอร์แมตเป็น ExFAT เพื่อใช้ร่วมกันระหว่าง Mac และ Windows!",
        .ko: "USB 드라이브를 연결하고 'Finder'를 연 뒤 사이드바 '위치' 아래에서 드라이브 이름을 클릭하여 폴더를 선택합니다. Mac과 Windows 간 호환을 위해 ExFAT 포맷을 권장합니다!"
    ],
    "manual_sync_title": [
        .en: "Automatic Sync & Smart Diff Preview",
        .zhHant: "全自動對帳與智慧差異預覽",
        .zhHans: "全自动对账与智能差异预览",
        .ja: "完全自動同期とスマート差分プレビュー",
        .th: "ซิงค์อัตโนมัติสมบูรณ์แบบและการดูตัวอย่างความแตกต่างอัจฉริยะ",
        .ko: "완전 자동 동기화 및 스마트 차이점 미리보기"
    ],
    "manual_sync_desc": [
        .en: "No manual actions needed: changes in any folder sync within 2 seconds. Want to check changes first? Go to 'Diff Preview' and click 'Run Trial Simulation' to see what will change safely.",
        .zhHant: "平時完全無須手動操作：任一資料夾有新增、修改或刪除，2 秒內自動同步到其他所有資料夾。想先確認會動到哪些檔案？切換至「差異預覽」點擊「執行試跑模擬」，安全零風險！",
        .zhHans: "平时完全无需手动操作：任一文件夹有新增、修改或删除，2 秒内自动同步到其他所有文件夹。想先确认会动到哪些文件？切换至“差异预览”点击“执行试跑模拟”，安全零风险！",
        .ja: "普段は手動操作は一切不要です。いずれかのフォルダで変更があると、2秒以内に自動同期されます。「差分プレビュー」で「シミュレーション実行」をクリックすれば、事前に変更内容を確認できます。",
        .th: "ไม่จำเป็นต้องจัดการด้วยตนเอง: ไฟล์ที่เปลี่ยนแปลงจะซิงค์อัตโนมัติภายใน 2 วินาที หากต้องการตรวจสอบก่อน ให้ไปที่ 'ดูตัวอย่างความแตกต่าง' แล้วคลิก 'จำลองการทำงาน' ปลอดภัยไร้ความเสี่ยง!",
        .ko: "평소에는 수동 조작이 전혀 필요하지 않습니다. 폴더에 변경 사항이 생기면 2초 내에 자동 동기화됩니다. '차이점 미리보기'에서 '시뮬레이션 실행'을 클릭하여 안전하게 미리 확인하세요."
    ],
    "manual_badge_smart": [
        .en: "Smart Sync",
        .zhHant: "智慧同步",
        .zhHans: "智能同步",
        .ja: "スマート同期",
        .th: "ซิงค์อัจฉริยะ",
        .ko: "스마트 동기화"
    ],
    "manual_protection_title": [
        .en: "Conflict Safeguard & History Rollback",
        .zhHant: "防覆蓋衝突保護與歷史還原",
        .zhHans: "防覆盖冲突保护与历史还原",
        .ja: "競合保護と履歴復元",
        .th: "การป้องกันการทับซ้อนและการกู้คืนประวัติ",
        .ko: "덮어쓰기 방지 충돌 보호 및 히스토리 복원"
    ],
    "manual_protection_desc": [
        .en: "Simultaneous offline edits? SyncNexus keeps both versions by creating a conflict file. Deleted files go to Trash first, and older versions can be restored anytime from the 'Versions' tab!",
        .zhHant: "兩邊離線同時修改同一個檔案？SyncNexus 絕不覆蓋，會自動另存衝突備份檔，兩份完整保留！刪除的檔案優先進垃圾桶，舊版本也能隨時在「舊版本」分頁一鍵復原！",
        .zhHans: "两边离线同时修改同一个文件？SyncNexus 绝不覆盖，会自动另存冲突备份文件，两份完整保留！删除的文件优先进入废纸篓，旧版本也能随时在“旧版本”分页一键恢复！",
        .ja: "オフラインで両側が同時に同じファイルを変更した場合は、競合コピーとして保存し、上書きを防止します！削除ファイルはゴミ箱へ送られ、「旧バージョン」からいつでも復元可能です。",
        .th: "แก้ไขไฟล์เดียวกันขณะออฟไลน์ทั้งสองด้าน? SyncNexus จะไม่เขียนทับ แต่จะบันทึกสำเนาข้อขัดแย้งแยกไว้! ไฟล์ที่ถูกลบจะไปที่ถังขยะก่อน และสามารถกู้คืนเวอร์ชันเก่าได้ตลอดเวลาที่ 'ประวัติเวอร์ชัน'!",
        .ko: "오프라인에서 양쪽이 동시에 동일한 파일을 수정한 경우, 충돌 사본으로 자동 저장하여 덮어쓰기를 방지합니다! 삭제된 파일은 휴지통으로 이동하며 '이전 버전'에서 언제든 원클릭 복원할 수 있습니다."
    ],
    "manual_badge_safety": [
        .en: "Zero Risk",
        .zhHant: "零風險防護",
        .zhHans: "零风险防护",
        .ja: "ゼロリスク保護",
        .th: "ความปลอดภัยสูงสุด",
        .ko: "무위험 보호"
    ],
    "privacy_sec1_title": [
        .en: "1. 100% Local-First Architecture",
        .zhHant: "1. 100% 本機優先，無雲端中繼伺服器",
        .zhHans: "1. 100% 本机优先，无云端中继服务器",
        .ja: "1. 100% ローカルファースト、クラウド中継なし",
        .th: "1. โครงสร้างเน้นโลคอล 100% ไม่มีเซิร์ฟเวอร์คลาวด์ตัวกลาง",
        .ko: "1. 100% 로컬 우선, 클라우드 중계 서버 없음"
    ],
    "privacy_sec1_desc": [
        .en: "All file comparisons, transfers, and metadata calculations occur exclusively on your local devices. SyncNexus operates zero cloud storage and zero remote servers.",
        .zhHant: "所有檔案比對、同步傳輸與特徵碼比對皆完全在您的電腦本地執行。SyncNexus 沒有經營任何雲端伺服器，絕不會上傳您的檔案內容。",
        .zhHans: "所有文件比对、同步传输与特征码比对皆完全在您的电脑本地执行。SyncNexus 没有经营任何云端服务器，绝不会上传您的文件内容。",
        .ja: "すべてのファイル比較、同期、ハッシュ計算はお使いのコンピュータ上で完全にローカルに実行されます。ファイルが外部サーバーにアップロードされることは一切ありません。",
        .th: "การเปรียบเทียบไฟล์ การซิงค์ และการประมวลผลทั้งหมดทำงานในเครื่องคอมพิวเตอร์ของคุณเท่านั้น SyncNexus ไม่มีเซิร์ฟเวอร์ภายนอกและไม่เคยอัปโหลดเนื้อหาไฟล์ของคุณ",
        .ko: "모든 파일 비교, 동기화 전송 및 체크섬 계산은 컴퓨터 로컬에서 완전히 수행됩니다. SyncNexus는 외부 서버를 운영하지 않으며 파일 내용을 업로드하지 않습니다."
    ],
    "privacy_badge_local": [
        .en: "Local Only",
        .zhHant: "僅限本機",
        .zhHans: "仅限本机",
        .ja: "ローカル限定",
        .th: "ในเครื่องเท่านั้น",
        .ko: "로컬 전용"
    ],
    "privacy_sec2_title": [
        .en: "2. Strict App Sandbox & Least Privilege",
        .zhHant: "2. 嚴格遵循 macOS 沙盒與最小權限原則",
        .zhHans: "2. 严格遵循 macOS 沙盒与最小权限原则",
        .ja: "2. 厳格な App Sandbox と最小特権の原則",
        .th: "2. Sandbox ของ macOS ที่เข้มงวดและหลักสิทธิ์ขั้นต่ำ",
        .ko: "2. 엄격한 macOS 샌드박스 및 최소 권한 원칙"
    ],
    "privacy_sec2_desc": [
        .en: "SyncNexus strictly runs within the macOS App Sandbox. It only accesses folders you explicitly choose via the standard macOS picker window, secured via Security-Scoped Bookmarks.",
        .zhHant: "本軟體在 macOS 系統沙盒內隔離運行，僅能存取您在選取視窗中明確勾選的目錄（透過 Security-Scoped Bookmarks 安全授權），絕無法擅自存取您電腦中的其他私人檔案。",
        .zhHans: "本软件在 macOS 系统沙盒内隔离运行，仅能访问您在选取窗口中明确勾选的目录（通过 Security-Scoped Bookmarks 安全授权），绝无法擅自访问您电脑中的其他私人文件。",
        .ja: "本アプリは macOS のサンドボックス内で隔離されて動作し、ユーザーが明示的に選択したフォルダのみにアクセスします。他のプライベートファイルにアクセスすることはできません。",
        .th: "ซอฟต์แวร์นี้ทำงานใน Sandbox ของ macOS โดยเข้าถึงเฉพาะโฟลเดอร์ที่คุณเลือกอย่างชัดเจนเท่านั้น และไม่สามารถเข้าถึงไฟล์ส่วนตัวอื่นๆ ในเครื่องได้",
        .ko: "본 앱은 macOS 시스템 샌드박스 내에서 격리 실행되며, 사용자가 명시적으로 선택한 폴더에만 접근합니다. 다른 개인 파일에는 무단 접근할 수 없습니다."
    ],
    "privacy_badge_sandbox": [
        .en: "Sandboxed",
        .zhHant: "沙盒安全",
        .zhHans: "沙盒安全",
        .ja: "サンドボックス",
        .th: "ปลอดภัยด้วย Sandbox",
        .ko: "샌드박스 보호"
    ],
    "privacy_sec3_title": [
        .en: "3. Zero Telemetry & Zero Data Tracking",
        .zhHant: "3. 零診斷追蹤，零廣告，無任何資料收集",
        .zhHans: "3. 零诊断追踪，零广告，无任何数据收集",
        .ja: "3. テレメトリ・広告・データ収集ゼロ",
        .th: "3. ไม่มีการติดตาม ไม่มีการรวบรวมข้อมูลใดๆ ทั้งสิ้น",
        .ko: "3. 원격 분석·광고·데이터 수집 제로"
    ],
    "privacy_sec3_desc": [
        .en: "We do not collect names, paths, usage analytics, device identifiers, IP addresses, or crash logs. There are no analytics SDKs or third-party tracking libraries installed.",
        .zhHant: "我們不收集檔案清單、資料夾名稱、硬體序號、IP 位址或任何分析數據。程式內未植入任何廣告追蹤 SDK 或第三方數據分析工具。",
        .zhHans: "我们不收集文件清单、文件夹名称、硬件序列号、IP 地址或任何分析数据。程序内未植入任何广告追踪 SDK 或第三方数据分析工具。",
        .ja: "ファイル一覧、フォルダ名、デバイス情報、IP アドレスなどのデータを収集することはありません。サードパーティの追跡 SDK は一切含まれていません。",
        .th: "เราไม่รวบรวมรายชื่อไฟล์ ชื่อโฟลเดอร์ ข้อมูลอุปกรณ์ ที่อยู่ IP หรือข้อมูลการวิเคราะห์ใดๆ ไม่มี SDK โฆษณาหรือเครื่องมือติดตามของบุคคลที่สาม",
        .ko: "파일 목록, 폴더 이름, 기기 식별자, IP 주소 등의 데이터를 일체 수집하지 않습니다. 분석 SDK나 제3자 추적 도구가 전혀 포함되어 있지 않습니다."
    ],
    "privacy_badge_no_cloud": [
        .en: "No Telemetry",
        .zhHant: "零追蹤",
        .zhHans: "零追踪",
        .ja: "追跡なし",
        .th: "ไม่มีการติดตาม",
        .ko: "추적 없음"
    ],
    "privacy_sec4_title": [
        .en: "4. User-Controlled Deletions",
        .zhHant: "4. 安全刪除機制：優先移至系統垃圾桶",
        .zhHans: "4. 安全删除机制：优先移至系统废纸篓",
        .ja: "4. 安全な削除メカニズム: ゴミ箱へ優先移動",
        .th: "4. กลไกการลบที่ปลอดภัย: ย้ายไปที่ถังขยะก่อนเสมอ",
        .ko: "4. 안전한 삭제 메커니즘: 시스템 휴지통으로 우선 이동"
    ],
    "privacy_sec4_desc": [
        .en: "Deleted files are moved to the macOS Trash whenever possible, preventing irreversible loss. You can empty the Trash or restore files whenever you wish.",
        .zhHant: "在進行同步刪除時，檔案會優先移至 macOS 系統「垃圾桶」而非永久抹除，確保隨時可撤銷操作。您擁有資料處置的最高決定權。",
        .zhHans: "在进行同步删除时，文件会优先移至 macOS 系统“废纸篓”而非永久抹除，确保随时可撤销操作。您拥有数据处置的最高决定权。",
        .ja: "削除されたファイルは完全に消去されるのではなく、可能な限り macOS の「ゴミ箱」に移動されるため、いつでも復元可能です。",
        .th: "เมื่อซิงค์การลบ ไฟล์จะถูกย้ายไปที่ 'ถังขยะ' ของ macOS ก่อนเสมอแทนการลบถาวร เพื่อให้สามารถกู้คืนได้ตลอดเวลา คุณเป็นผู้ควบคุมข้อมูลของคุณอย่างแท้จริง",
        .ko: "동기화 삭제 시 파일이 완전히 지워지지 않고 우선 macOS '휴지통'으로 이동하므로 언제든 되돌릴 수 있습니다. 사용자가 모든 데이터 권한을 갖습니다."
    ],
    "privacy_badge_trash": [
        .en: "Recycle Bin Safe",
        .zhHant: "防誤刪",
        .zhHans: "防误删",
        .ja: "誤削除防止",
        .th: "ปลอดภัยจากการลบผิด",
        .ko: "오삭제 방지"
    ],
    // 7 大主題操作手冊專屬語系定義 (支援 6 大語系)
    "manual_badge_operations": [
        .en: "Step-by-Step Guide",
        .zhHant: "手把手教學",
        .zhHans: "手把手教学",
        .ja: "ステップ別手順",
        .th: "ขั้นตอนการใช้งาน",
        .ko: "단계별 가이드"
    ],
    "manual_badge_phenomena": [
        .en: "Outputs & Safeguards",
        .zhHant: "產出現象與防護",
        .zhHans: "产出现象与防护",
        .ja: "動作と安全保護",
        .th: "ผลลัพธ์และความปลอดภัย",
        .ko: "동작 현상 및 안전 보호"
    ],
    "manual_badge_tips": [
        .en: "Helpful Tips",
        .zhHant: "使用秘訣",
        .zhHans: "使用秘诀",
        .ja: "使い方のヒント",
        .th: "เคล็ดลับการใช้งาน",
        .ko: "사용 팁"
    ],
    // 1. Overview
    "manual_topic_overview_title": [
        .en: "Chapter 1: Overview — Health Dashboard",
        .zhHant: "第一章：概覽 (Overview) — 全局健康儀表板",
        .zhHans: "第一章：概览 (Overview) — 全局健康仪表板",
        .ja: "第1章：概要 (Overview) — 全体健全性ダッシュボード",
        .th: "บทที่ 1: ภาพรวม (Overview) — แดชบอร์ดสถานะสุขภาพระบบ",
        .ko: "제1장: 개요 (Overview) — 전체 건전성 대시보드"
    ],
    "manual_topic_overview_desc": [
        .en: "The Overview provides a bird's-eye view of your entire synchronization health. It unites the top header quick bar, global health badges, mass deletion protection, live tracked file counts, deep SHA-256 verification timestamps, historical version storage metrics, and LAN P2P direct discovery on the same Wi-Fi.",
        .zhHant: "「概覽」讓您一秒掌握全系統同步健康度。整合了首頁頁首快捷列、全局指示燈、異常大量刪除攔截卡片、追蹤檔案即時統計、上次深層驗證時間與舊版本佔用容量，並提供同 Wi-Fi 內 P2P 設備搜尋。",
        .zhHans: "“概览”让您一秒掌握全系统同步健康度。整合了首页页首快捷列、全局指示灯、异常大量删除拦截卡片、追踪文件即时统计、上次深层验证时间与旧版本占用容量，并提供同 Wi-Fi 内 P2P 设备搜索。",
        .ja: "「概要」では同期システム全体の健全性を一目で把握できます。ヘッダーのクイックバー、全体インジケーター、大量削除保護カード、監視ファイル統計、最終検証日時、履歴使用量、同一 Wi-Fi 内の P2P 探索状態を表示します。",
        .th: "หน้า 'ภาพรวม' ช่วยให้คุณเข้าใจสถานะสุขภาพของระบบซิงค์ไฟล์ได้ทันที รวมแถบเครื่องมือด่วนด้านบน ไฟสถานะโดยรวม การสกัดกั้นการลบจำนวนมาก จำนวนไฟล์ที่ติดตาม การตรวจสอบ SHA-256 พื้นที่ประวัติ และการค้นหาอุปกรณ์ P2P บน Wi-Fi เดียวกัน",
        .ko: "'개요'는 동기화 시스템의 전반적인 상태를 한눈에 파악할 수 있는 대시보드입니다. 상단 빠른 실행 바, 전체 상태 표시, 대량 삭제 차단 카드, 추적 파일 수, SHA-256 심층 검증 시간, 이전 버전 저장 용량 및 동일 Wi-Fi 내 P2P 기기 탐색 상태를 제공합니다."
    ],
    "manual_topic_overview_ops_title": [
        .en: "Zero-Foundation Tutorial: Health Dashboard & Top Bar",
        .zhHant: "零基礎教學：全局健康儀表板與頁首快捷列",
        .zhHans: "零基础教学：全局健康仪表板与页首快捷列",
        .ja: "入門チュートリアル：全体ダッシュボードとトップバー",
        .th: "คู่มือเริ่มต้น: แดชบอร์ดสถานะและแถบด้านบน",
        .ko: "초보자 가이드: 전체 대시보드 및 상단 바"
    ],
    "manual_topic_overview_ops_desc": [
        .en: "【Step 1: Top Header Bar】The top-right header features the Language Picker, 'User Manual 📖', and 'Privacy 🛡️' buttons. Click anytime to switch between 6 languages or open this in-app manual without browser redirects.\n【Step 2: Check Global Health Badge】Glance at the top-left badge: Green 'All Normal' means all systems are healthy; Yellow 'Warning' alerts you to offline folders, pending conflicts, or anomalous events.\n【Step 3: Handle Mass Deletion Safeguard】If >25 files or >25% of files are deleted at once, a safety banner pops up below the header and halts sync; click 'Review and Confirm' on the right to examine the file list and choose 'Confirm Deletion' or 'Cancel & Restore'.\n【Step 4: Check Endpoints & LAN P2P】The center grid shows online/offline status for all folders in the active group; nearby Macs or Android devices on the same Wi-Fi are automatically discovered and displayed as 'Online' P2P peers.",
        .zhHant: "【步驟 1：檢視頁首快捷列】主視窗最上方右側常駐「語系選單」、「操作手冊 📖」與「隱私政策 🛡️」按鈕，點擊可隨時切換 6 國語言或展開本原生手冊。\n【步驟 2：確認全局健康燈號】看一眼左上方健康徽章：綠燈「全部正常」代表一切就緒；若轉為黃燈「警告」，代表有端點離線、衝突或異常事件需要留意。\n【步驟 3：應對大量刪除攔截卡片】若單次刪除超過 25 個檔案或 25%，標題下方會自動彈出醒目的防護卡片並暫停同步；點擊右側「審核並確認」按鈕，在審核清單中點選「確認放行」或「取消並恢復」。\n【步驟 4：查看端點與同網 P2P】中央卡片列出目前同步群組的所有資料夾狀態；若同 Wi-Fi 內有其他執行 SyncNexus 的設備，下方 P2P 區塊會自動顯示「在線」直連。",
        .zhHans: "【步骤 1：检视页首快捷列】主视窗最上方右侧常驻“语系选单”、“操作手册 📖”与“隐私政策 🛡️”按钮，点击可随时切换 6 国语言或展开本原生手册。\n【步骤 2：确认全局健康灯号】看一眼左上方健康徽章：绿灯“全部正常”代表一切就绪；若转为黄灯“警告”，代表有端点离线、冲突或异常事件需要留意。\n【步骤 3：应对大量删除拦截卡片】若单次删除超过 25 个文件或 25%，标题下方会自动弹出醒目的防护卡片并暂停同步；点击右侧“审核并确认”按钮，在审核清单中点选“确认放行”或“取消并恢复”。\n【步骤 4：查看端点与同网 P2P】中央卡片列出目前同步群组的所有文件夹状态；若同 Wi-Fi 内有其他执行 SyncNexus 的设备，下方 P2P 区块会自动显示“在线”直连。",
        .ja: "【ステップ 1：トップバーの確認】右上には言語切り替え、「操作マニュアル 📖」、「プライバシー 🛡️」が常駐し、いつでも6言語の切り替えやマニュアル閲覧が可能です。\n【ステップ 2：全体ステータスの確認】左上の健全性バッジを確認：緑色の「すべて正常」なら順調、黄色の「警告」ならフォルダ切断や競合発生を示します。\n【ステップ 3：大量削除保護カードの対応】一度に25個または25%以上のファイルが削除された場合、上部に警告カードが表示され同期を一時停止します。右側の「確認して承認」を押し、削除を許可するか復元するかを選択します。\n【ステップ 4：フォルダとローカル P2P の確認】中央に現在のグループのフォルダ一覧が表示され、同一 Wi-Fi 内の他デバイスは下部 P2P エリアに「オンライン」として自動検出されます。",
        .th: "【ขั้นตอนที่ 1: แถบเครื่องมือด้านบน】มุมขวาบนมีเมนูภาษา ปุ่ม 'คู่มือ 📖' และ 'ความเป็นส่วนตัว 🛡️' คลิกเพื่อสลับภาษาหรือเปิดคู่มือได้ตลอดเวลา\n【ขั้นตอนที่ 2: ตรวจสอบสถานะโดยรวม】ดูที่ป้ายซ้ายบน: สีเขียว 'ปกติทั้งหมด' หมายถึงระบบพร้อมสมบูรณ์ หากเป็นสีเหลือง 'คำเตือน' หมายถึงมีโฟลเดอร์ออฟไลน์หรือมีข้อขัดแย้ง\n【ขั้นตอนที่ 3: รับมือกับการป้องกันการลบจำนวนมาก】หากมีการลบไฟล์ >25 ไฟล์หรือ >25% พร้อมกัน แถบเตือนจะปรากฏและหยุดการซิงค์ไว้ชั่วคราว คลิก 'ตรวจสอบและยืนยัน' ทางขวาเพื่อเลือกว่าจะอนุญาตหรือกู้คืน\n【ขั้นตอนที่ 4: ตรวจสอบโฟลเดอร์และ P2P】ส่วนกลางแสดงสถานะโฟลเดอร์ทั้งหมดในกลุ่มปัจจุบัน และอุปกรณ์ใน Wi-Fi เดียวกันจะแสดงในส่วน P2P ด้านล่างโดยอัตโนมัติ",
        .ko: "【1단계: 상단 툴바 확인】화면 우측 상단에 언어 메뉴, '사용 설명서 📖', '개인정보 보호 🛡️' 버튼이 항상 배치되어 있어 언제든 6개 언어 전환 및 설명서 열람이 가능합니다.\n【2단계: 전체 상태 배지 확인】좌측 상단의 배지를 확인하세요: 녹색 '모두 정상'은 완벽한 상태를 나타내며, 노란색 '경고'는 연결 끊김이나 충돌 등 주의가 필요함을 의미합니다.\n【3단계: 대량 삭제 보호 대처】한 번에 25개 이상 또는 25% 이상의 파일이 삭제되면 상단에 경고 카드가 나타나며 동기화가 일시 중단됩니다. 우측의 '검토 및 확인'을 클릭하여 허용할지 복원할지 결정하세요.\n【4단계: 폴더 및 로컬 P2P 확인】중앙에서 현재 그룹의 폴더 상태를 확인하고, 동일 Wi-Fi 내의 다른 기기는 하단 P2P 영역에 자동으로 '온라인' 직결 표시됩니다."
    ],
    "manual_topic_overview_safe_title": [
        .en: "Expected Phenomena, LAN P2P & Safety Shields",
        .zhHant: "產出現象、P2P 局域直連與防誤刪",
        .zhHans: "产出现象、P2P 局域直连与防误删",
        .ja: "動作現象、P2P ローカル直接接続と誤削除防止",
        .th: "ผลลัพธ์การทำงาน การเชื่อมต่อ P2P ในเครือข่าย และการป้องกัน",
        .ko: "동작 현상, 로컬 P2P 직결 및 오삭제 방지"
    ],
    "manual_topic_overview_safe_desc": [
        .en: "• Live Alerts: The status badge turns yellow immediately when an endpoint goes offline, disconnects, or marker UUID fails.\n• Local Wi-Fi P2P: Discovers nearby Macs or Android devices running SyncNexus automatically and displays them as 'Online' for point-to-point syncing.\n• Anti-Ransomware: Mass deletions are halted automatically, preventing accidental wipes from propagating.",
        .zhHant: "• 即時警示反饋：任一端點離線、拔除或標記檔不符時，燈號即時切換為黃燈警示。\n• 同 Wi-Fi P2P 局域直連：同網路內開啟 Mac 或 Android 版 SyncNexus，自動在此列出並顯示「在線」直連。\n• 防惡意清空保證：大量刪除時強制彈窗攔截，未經確認絕不傳播刪除；所有刪除操作均優先移入系統垃圾桶並封存於歷史版本。",
        .zhHans: "• 即时警示反馈：任一端点离线、拔除或标记档不符时，灯号即时切换为黄灯警示。\n• 同 Wi-Fi P2P 局域直连：同网络内开启 Mac 或 Android 版 SyncNexus，自动在此列出并显示“在线”直连。\n• 防恶意清空保证：大量删除时强制弹窗拦截，未经确认绝不传播删除；所有删除操作均优先移入系统废纸篓并封存于历史版本。",
        .ja: "• 即時アラート: 端点がオフライン、切断、またはマーカー不一致の際に即座に黄色警告へ切り替わります。\n• 同一 Wi-Fi P2P 直結: ネットワーク内の Mac や Android の SyncNexus を自動検知し、「オンライン」直結表示します。\n• 誤削除防止保証: 大量削除時は強制停止し、確認なしで削除が伝播することはありません。すべての削除はゴミ箱と履歴に優先退避されます。",
        .th: "• การแจ้งเตือนทันที: ไฟสถานะเปลี่ยนเป็นสีเหลืองทันทีเมื่อมีโฟลเดอร์ออฟไลน์ ถอดออก หรือมาร์กเกอร์ไม่ตรงกัน\n• P2P บน Wi-Fi เดียวกัน: ค้นหา Mac หรือ Android ที่เปิด SyncNexus บน Wi-Fi เดียวกันโดยอัตโนมัติและแสดงเป็น 'ออนไลน์'\n• ป้องกันการลบข้อมูลโดยไม่ตั้งใจ: ระงับการลบจำนวนมากโดยอัตโนมัติ ไม่แพร่กระจายการลบก่อนได้รับการยืนยัน ไฟล์ที่ถูกลบจะย้ายลงถังขยะและเก็บประวัติไว้เสมอ",
        .ko: "• 실시간 경고: 폴더가 오프라인이 되거나 마커가 일치하지 않으면 배지가 즉시 노란색으로 바뀝니다.\n• 동일 Wi-Fi P2P 직결: 동일 네트워크 내의 Mac 또는 Android SyncNexus를 자동 탐색하여 '온라인' 직결 표시합니다.\n• 데이터 보호: 대량 삭제 발생 시 자동으로 동기화가 중단되어 실수가 전파되지 않으며 모든 삭제는 휴지통 및 버전에 안전하게 보관됩니다."
    ],
    "manual_topic_overview_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_overview_tips_desc": [
        .en: "As long as the top badge shows green 'All Normal', all folders are in full sync. You never need to click any manual buttons during daily work.",
        .zhHant: "平時只要確認上方顯示綠燈「全部正常」，代表所有端點檔案隨時保持一致，您完全不需手動干預即可安心工作。",
        .zhHans: "平时只要确认上方显示绿灯“全部正常”，代表所有端点文件随时保持一致，您完全不需手动干预即可安心工作。",
        .ja: "上部に緑色の「すべて正常」が表示されていれば、すべてのフォルダが完全に同期されています。手動操作は一切不要で安心して作業できます。",
        .th: "ตราบใดที่ไฟด้านบนแสดงสีเขียว 'ปกติทั้งหมด' หมายความว่าทุกโฟลเดอร์ตรงกันอย่างสมบูรณ์ คุณสามารถทำงานได้โดยไม่ต้องกังวลหรือกดปุ่มใดๆ",
        .ko: "상단에 녹색 '모두 정상'이 표시되어 있다면 모든 폴더가 완벽히 동기화된 상태입니다. 일상 작업 중에는 별도의 수동 조작 없이 안심하고 작업하실 수 있습니다."
    ],

    // 2. Diff Preview
    "manual_topic_diff_title": [
        .en: "Chapter 2: Diff Preview — Dry-Run Simulation",
        .zhHant: "第二章：差異預覽 (Diff Preview) — 模擬對帳試跑",
        .zhHans: "第二章：差异预览 (Diff Preview) — 模拟对账试跑",
        .ja: "第2章：差分プレビュー (Diff Preview) — シミュレーション試行",
        .th: "บทที่ 2: ตัวอย่างความแตกต่าง (Diff Preview) — จำลองการซิงค์",
        .ko: "제2장: 차이 미리보기 (Diff Preview) — 시뮬레이션 테스트"
    ],
    "manual_topic_diff_desc": [
        .en: "Before writing any changes to disk, Diff Preview offers a risk-free Dry-Run simulation. It compares all endpoints and clearly lists scheduled copy (+), rename (➔), and deletion (−) actions with color-coded badges, enabling you to inspect changes before confirming.",
        .zhHant: "在正式將任何檔案寫入磁碟前，「差異預覽」為您提供零風險的「試跑模擬（Dry-Run）」。逐一比對各端點差異，列出預計複製、改名與刪除項目，確認無誤後再放行寫入。",
        .zhHans: "在正式将任何文件写入磁盘前，“差异预览”为您提供零风险的“试跑模拟（Dry-Run）”。逐一比对各端点差异，列出预计复制、改名与删除项目，确认无误后再放行写入。",
        .ja: "ディスクに変更を書き込む前に、差分プレビューで安全なドライランシミュレーションが実行できます。各端点間のすべての差分を照合し、コピー (+)、名前変更 (➔)、削除 (−) の予定を色分け表示して確認できます。",
        .th: "ก่อนเขียนไฟล์ลงดิสก์ ตัวอย่างความแตกต่างให้คุณจำลองการซิงค์โดยไม่มีความเสี่ยง เปรียบเทียบไฟล์ในทุกโฟลเดอร์ และแสดงรายการที่กำหนดจะคัดลอก (+) เปลี่ยนชื่อ (➔) หรือลบ (−) อย่างชัดเจน",
        .ko: "디스크에 실제로 변경 사항을 쓰기 전에, 차이 미리보기에서 안전한 시뮬레이션을 실행할 수 있습니다. 각 폴더 간의 모든 차이를 대조하여 복사(+), 이름 변경(➔), 삭제(−) 항목을 색상별로 명확하게 표시합니다."
    ],
    "manual_topic_diff_ops_title": [
        .en: "Zero-Foundation Tutorial: Dry-Run Simulation",
        .zhHant: "零基礎教學：模擬對帳試跑手把手步驟",
        .zhHans: "零基础教学：模拟对账试跑手把手步骤",
        .ja: "入門チュートリアル：シミュレーション試行手順",
        .th: "คู่มือเริ่มต้น: ขั้นตอนการจำลองการซิงค์",
        .ko: "초보자 가이드: 시뮬레이션 테스트 단계별 절차"
    ],
    "manual_topic_diff_ops_desc": [
        .en: "【Step 1: Click Run Trial Simulation】Click the blue 'Run Trial Simulation' button on the top-left card. The button changes to 'Simulating...' while calculating all differences in memory without altering any disk files.\n【Step 2: Create APFS Snapshot (Optional)】Before massive operations, click 'APFS Snapshot Safeguard' to create a macOS restore point; if sandboxed, a top floating Toast HUD confirms that Trash and Version archives remain fully active as backup shields.\n【Step 3: Review Change List & Symbols】A tree appears below: Green `+` for additions/copies; Blue `➔` for smart renames; Red `−` for deletions (marked Trash-first). If no differences exist, a green checkmark shows 'All endpoints are identical'.\n【Step 4: Click Confirm and Sync】After inspecting the operations, click the blue 'Confirm and Sync' button at the bottom right. Changes are written across all endpoints, and a top Toast HUD announces completion.",
        .zhHant: "【步驟 1：點擊執行試跑模擬】在頂部卡片左側，點擊藍色「執行試跑模擬」按鈕。按鈕立即轉為「模擬計算中...」，系統在背景深度比對各端點，不修改任何磁碟檔案。\n【步驟 2：建立 APFS 快照防線（選用）】在大規模同步前，可點擊「APFS 快照安全防護」建立系統還原點；若因系統限制無法建立，頂部會跳出快顯 Toast 提示說明系統已自動啟用垃圾桶與歷史庫雙重防線。\n【步驟 3：核對變更清單與符號】計算完成後下方展開變更清單：綠色 `+` 代表新增複製；藍色 `➔` 代表智慧更名；紅色 `−` 代表刪除（標註優先移入垃圾桶）。若無變動則顯示綠色勾勾「所有端點完全一致」。\n【步驟 4：點擊確定執行同步】確認變更項目無誤後，點擊清單右下角「確定執行同步」按鈕，系統將變更寫入各端點，完成後頂部彈出 Toast 提示「同步作業已完成」。",
        .zhHans: "【步骤 1：点击执行试跑模拟】在顶部卡片左侧，点击蓝色“执行试跑模拟”按钮。按钮立即转为“模拟计算中...”，系统在背景深度比对各端点，不修改任何磁盘文件。\n【步骤 2：建立 APFS 快照防线（选用）】在大规模同步前，可点击“APFS 快照安全防护”建立系统还原点；若因系统限制无法建立，顶部会跳出快显 Toast 提示说明系统已自动启用废纸篓与历史库双重防线。\n【步骤 3：核对变更清单与符号】计算完成后下方展开变更清单：绿色 `+` 代表新增复制；蓝色 `➔` 代表智慧更名；红色 `−` 代表删除（标注优先移入废纸篓）。若无变动则显示绿色勾勾“所有端点完全一致”。\n【步骤 4：点击确定执行同步】确认变更项目无误后，点击清单右下角“确定执行同步”按钮，系统将变更写入各端点，完成后顶部弹出 Toast 提示“同步作业已完成”。",
        .ja: "【ステップ 1：シミュレーション実行】上部カードの左側にある青い「シミュレーション実行」をクリック。「シミュレーション中...」となり、ディスクを一切変更せずに差分を計算します。\n【ステップ 2：APFS スナップショット作成（任意）】大規模な変更前に「APFS スナップショット保護」で復元ポイントを作成可能。制限で作成できない場合も上部トーストでゴミ箱と履歴による安全保護を案内します。\n【ステップ 3：差分リストの確認】計算完了後に変更一覧が表示されます：緑 `+` (新規/コピー)、青 `➔` (名前変更)、赤 `−` (ゴミ箱へ移動)。差分がなければ緑のチェックで「全フォルダ完全一致」と表示されます。\n【ステップ 4：同期実行をクリック】一覧を確認後、右下の青い「同期を実行」ボタンをクリック。変更が全端点に書き込まれ、上部トーストで完了が通知されます。",
        .th: "【ขั้นตอนที่ 1: คลิกดำเนินการจำลอง】คลิกปุ่มสีน้ำเงิน 'ดำเนินการจำลอง' ซ้ายบน ปุ่มจะเปลี่ยนเป็น 'กำลังจำลอง...' เพื่อคำนวณความแตกต่างโดยไม่แก้ไขไฟล์จริงในดิสก์\n【ขั้นตอนที่ 2: สร้างสแนปช็อต APFS (ทางเลือก)】คลิก 'การป้องกันด้วยสแนปช็อต APFS' เพื่อสร้างจุดคืนค่า หากระบบไม่อนุญาต จะมี Toast แจ้งว่าถังขยะและประวัติจะทำหน้าที่สำรองข้อมูลแทนอย่างปลอดภัย\n【ขั้นตอนที่ 3: ตรวจสอบรายการและสัญลักษณ์】รายการเปลี่ยนแปลงจะปรากฏ: สีเขียว `+` (เพิ่ม/คัดลอก), สีน้ำเงิน `➔` (เปลี่ยนชื่อ), สีแดง `−` (ลบลงถังขยะ) หากไม่มีความแตกต่างจะแสดงเครื่องหมายถูกสีเขียว\n【ขั้นตอนที่ 4: กดยืนยันและซิงค์】เมื่อตรวจสอบเรียบร้อยแล้ว ให้คลิกปุ่ม 'ยืนยันและซิงค์' ที่มุมขวาล่าง ข้อมูลจะถูกเขียนลงทุกโฟลเดอร์พร้อมข้อความแจ้งเตือนสำเร็จ",
        .ko: "【1단계: 시뮬레이션 실행 클릭】상단 좌측의 파란색 '시뮬레이션 실행' 버튼을 클릭하세요. 버튼이 '시뮬레이션 중...'으로 바뀌며 실제 파일 변경 없이 메모리에서만 차이를 계산합니다.\n【2단계: APFS 스냅샷 생성 (선택 사항)】대규모 동기화 전에 'APFS 스냅샷 보호'를 클릭하여 복원 지점을 생성할 수 있습니다. 샌드박스로 인해 불가한 경우 상단 토스트 알림으로 휴지통 및 버전 보관 기능이 안전하게 작동 중임을 안내합니다.\n【3단계: 변경 목록 및 기호 확인】계산이 끝나면 목록이 펼쳐집니다: 녹색 `+` (추가/복사), 파란색 `➔` (이름 변경), 빨간색 `−` (휴지통 이동). 차이가 없으면 녹색 체크표시 '모든 엔드포인트 일치'가 나타납니다.\n【4단계: 동기화 확인 클릭】내용을 확인한 후 우측 하단의 파란색 '동기화 확인' 버튼을 클릭하면 실제 파일 쓰기가 진행되고 상단 토스트 알림으로 완료를 알려줍니다."
    ],
    "manual_topic_diff_safe_title": [
        .en: "Preview Symbols, Consistency State & Toast HUD",
        .zhHant: "預覽符號、完全一致狀態與 Toast 提示",
        .zhHans: "预览符号、完全一致状态与 Toast 提示",
        .ja: "プレビュー記号、完全一致状態とトースト通知",
        .th: "สัญลักษณ์ตัวอย่าง สถานะตรงกันสมบูรณ์ และการแจ้งเตือน Toast",
        .ko: "미리보기 기호, 완전 일치 상태 및 토스트 알림"
    ],
    "manual_topic_diff_safe_desc": [
        .en: "• Symbols: Green '+' for additions/copies; Blue '➔' for local renames; Red '−' for deletions (moved to Trash first).\n• Up-to-Date State: If all endpoints match, shows green checkmark 'All endpoints are identical, no sync needed'.\n• Toast HUD: If APFS snapshot cannot be created due to sandbox restrictions, a top floating toast explains that Trash and Version archives remain fully active as backup shields.",
        .zhHant: "• 預覽項目標記：綠色加號 `+` 代表新增複製；藍色箭頭 `➔` 代表本機更名；紅色減號 `−` 代表刪除（一律優先移入垃圾桶）。\n• 完全一致狀態：若無變動，顯示綠色勾勾「所有端點檔案完全一致，無須同步」。\n• 快顯 Toast HUD：點擊 APFS 快照若因沙盒限制無法建立，頂部跳出快顯 Toast 提示，說明系統已自動啟用「垃圾桶保護與歷史版本庫」作為雙重安全防線。",
        .zhHans: "• 预览项目标记：绿色加号 `+` 代表新增复制；蓝色箭头 `➔` 代表本机更名；红色减号 `−` 代表删除（一律优先移入废纸篓）。\n• 完全一致状态：若无变动，显示绿色勾勾“所有端点文件完全一致，无须同步”。\n• 快显 Toast HUD：点击 APFS 快照若因沙盒限制无法建立，顶部跳出快显 Toast 提示，说明系统已自动启用“废纸篓保护与历史版本库”作为双重安全防线。",
        .ja: "• 記号: 緑 '+' (新規/コピー)、青 '➔' (名前変更)、赤 '−' (ゴミ箱へ移動)。\n• 完全一致状態: 差分がない場合、「すべてのフォルダが一致しており同期不要」を表示。\n• トースト HUD: サンドボックス制限で APFS スナップショットが作れない場合、上部トーストでゴミ箱と履歴アーカイブが安全防線として機能している旨を案内します。",
        .th: "• สัญลักษณ์: สีเขียว '+' (คัดลอก/เพิ่ม), สีน้ำเงิน '➔' (เปลี่ยนชื่อ), สีแดง '−' (ลบลงถังขยะ)\n• สถานะตรงกันสมบูรณ์: หากไม่มีการเปลี่ยนแปลง จะแสดงเครื่องหมายถูกสีเขียว 'ทุกโฟลเดอร์ตรงกันแล้ว ไม่จำเป็นต้องซิงค์'\n• การแจ้งเตือน Toast HUD: หากไม่สามารถสร้างสแนปช็อต APFS ได้ ระบบจะแสดง Toast ด้านบนเพื่อแจ้งว่าใช้ถังขยะและประวัติในการสำรองข้อมูลแทนอย่างปลอดภัย",
        .ko: "• 기호: 녹색 '+' (추가/복사), 파란색 '➔' (이름 변경), 빨간색 '−' (휴지통 이동).\n• 완전 일치 상태: 변경 사항이 없으면 녹색 체크표시 '모든 엔드포인트 파일이 일치합니다' 표시.\n• 토스트 HUD: 샌드박스 제한으로 APFS 스냅샷 생성이 불가능할 경우, 상단 토스트 알림으로 휴지통 및 버전 아카이브가 안전하게 보호 중임을 안내합니다."
    ],
    "manual_topic_diff_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_diff_tips_desc": [
        .en: "Before large project cleanups or bulk deletions, click 'Run Trial Simulation' to preview the change list and verify every operation with peace of mind.",
        .zhHant: "在整理重要大專案或批次刪除整理前，先至本頁點擊「執行試跑模擬」，核對清單確認安全後再同步，萬無一失。",
        .zhHans: "在整理重要大专案或批次删除整理前，先至本页点击“执行试跑模拟”，核对清单确认安全后再同步，万无一失。",
        .ja: "大きなプロジェクトの整理や一括削除の前には、まず「シミュレーション実行」をクリックして一覧を確認してから同期すると安心です。",
        .th: "ก่อนจัดระเบียบโปรเจกต์ใหญ่หรือลบไฟล์จำนวนมาก ให้คลิก 'ดำเนินการจำลอง' เพื่อตรวจสอบรายการให้มั่นใจก่อนซิงค์จริง",
        .ko: "중요한 대규모 프로젝트를 정리하거나 대량 파일을 삭제하기 전에, 먼저 '시뮬레이션 실행'을 클릭하여 변경 목록을 미리 확인하면 안전합니다."
    ],

    // 3. Folders
    "manual_topic_folders_title": [
        .en: "Chapter 3: Folders — Storage Endpoints Setup",
        .zhHant: "第三章：資料夾 (Folders) — 多端點同步配置",
        .zhHans: "第三章：文件夹 (Folders) — 多端点同步配置",
        .ja: "第3章：フォルダ (Folders) — 同期ストレージの設定",
        .th: "บทที่ 3: โฟลเดอร์ (Folders) — การตั้งค่าโฟลเดอร์ซิงค์",
        .ko: "제3장: 폴더 (Folders) — 동기화 폴더 설정"
    ],
    "manual_topic_folders_desc": [
        .en: "The Folders tab configures your synchronization mesh. SyncNexus supports multi-folder Sync Groups, allowing you to connect local Mac folders, iCloud Drive, Google Drive, and external USB/Type-C drives into an automatic synchronization mesh. Modifying files in any one location updates all other folders automatically within 2 seconds.",
        .zhHant: "「資料夾」是配置同步端點的核心基地。支援多群組獨立同步（Sync Groups），並可將 Mac 本機、iCloud 雲碟、Google Drive、外接隨身碟互相綁定，任一處變更，其他處在 2 秒內自動同步。",
        .zhHans: "“文件夹”是配置同步端点的核心基地。支持多群组独立同步（Sync Groups），并可将 Mac 本机、iCloud 云盘、Google Drive、外接随身碟互相绑定，任一处变更，其他处在 2 秒内自动同步。",
        .ja: "「フォルダ」は同期先を設定・管理する場所です。独立した同期グループ（Sync Groups）に対応し、Mac ローカル、iCloud Drive、Google Drive、外付け ExFAT ドライブ間でメッシュ同期を構築します。いずれかの場所で変更が生じると、2秒以内に他すべてに自動反映されます。",
        .th: "แท็บ 'โฟลเดอร์' ใช้สำหรับจัดการตำแหน่งซิงค์ รองรับกลุ่มการซิงค์แบบแยกอิสระ (Sync Groups) เชื่อมต่อโฟลเดอร์ใน Mac, iCloud Drive, Google Drive และแฟลชไดรฟ์ USB ExFAT เมื่อแก้ไขไฟล์ในโฟลเดอร์ใด โฟลเดอร์อื่นจะอัปเดตตรงกันโดยอัตโนมัติภายใน 2 วินาที",
        .ko: "'폴더'는 동기화 대상을 설정하는 곳입니다. 독립된 동기화 그룹(Sync Groups)을 지원하며 Mac 로컬, iCloud Drive, Google Drive, 외장 ExFAT 드라이브 간에 자동 동기화 네트워크를 구성합니다. 한 곳에서 파일을 변경하면 2초 내에 다른 모든 곳에 자동 반영됩니다."
    ],
    "manual_topic_folders_ops_title": [
        .en: "Zero-Foundation Tutorial: Sync Groups & 4 Storage Locations",
        .zhHant: "零基礎教學：同步群組與 4 大儲存位置操作指南",
        .zhHans: "零基础教学：同步群组与 4 大存储位置操作指南",
        .ja: "入門チュートリアル：同期グループと4つの保存先設定手順",
        .th: "คู่มือเริ่มต้น: กลุ่มการซิงค์และขั้นตอนการเพิ่ม 4 แหล่งข้อมูล",
        .ko: "초보자 가이드: 동기화 그룹 및 4대 저장 위치 설정 절차"
    ],
    "manual_topic_folders_ops_desc": [
        .en: "【Step 1: Create & Switch Sync Groups】Click '+ New Group' at the top, enter a name (e.g. Work Projects, Family Photos) and pick an icon; click the group chips to switch active groups; click 'Edit Sync Group' to rename or delete.\n【Step 2: Click Add Folder...】Click the blue 'Add Folder...' button at the bottom to open the Finder selection dialog (at least 2 folders required per group to establish a sync mesh).\n【Step 3: Pick from 4 Storage Locations】:\n1. Local Mac: Open Finder ➔ click 'Documents' or user folder in sidebar ➔ select target folder.\n2. iCloud Drive: Open Finder ➔ click 'iCloud Drive' in sidebar ➔ select target folder.\n3. Google Drive: Open Finder ➔ click 'Google Drive' ➔ 'My Drive' ➔ select target folder.\n4. External USB: Plug in USB drive ➔ Open Finder ➔ click drive under 'Locations' ➔ select folder (ExFAT format strongly recommended).\n【Step 4: Relink or Remove】If moved, click 'Change Folder...' on the card to update path; click 'Remove...' to unbind (unlinking never deletes physical files).",
        .zhHant: "【步驟 1：建立與切換同步群組】點擊頂部「＋ 新增群組」，輸入群組名稱（如：工作專案、家庭相片）並選擇代表圖示後儲存；點擊上方不同群組標籤（Chips）即可隨時切換；點擊「✎ 編輯同步群組」可重新命名或刪除群組。\n【步驟 2：點擊加入資料夾】點擊列表底部藍色「加入資料夾...」按鈕，打開系統訪達（Finder）選取對話框（每個群組至少需加入 2 個資料夾以建立同步網絡）。\n【步驟 3：依指引選取 4 大儲存位置】：\n1. 電腦本機：打開 Finder ➔ 點擊側邊欄「文件」或個人專屬目錄 ➔ 選取目標資料夾。\n2. iCloud 雲碟：打開 Finder ➔ 點擊側邊欄「iCloud 雲碟」➔ 選取目標資料夾。\n3. Google Drive：打開 Finder ➔ 點擊側邊欄「Google Drive」➔ 進入「我的雲端硬碟」➔ 選取目標資料夾。\n4. 外接隨身碟：插上隨身碟 ➔ 打開 Finder ➔ 側邊欄「位置」選取該隨身碟 ➔ 選取目標資料夾（強烈建議格式化為 ExFAT）。\n【步驟 4：更換或移除端點】路徑搬移時點擊端點卡片右側「更換資料夾...」；若要解除同步點擊「移除...」（僅解除關聯，絕不刪除實體檔案）。",
        .zhHans: "【步骤 1：建立与切换同步群组】点击顶部“＋ 新增群组”，输入群组名称（如：工作项目、家庭相片）并选择代表图标后保存；点击上方不同群组标签（Chips）即可随时切换；点击“✎ 编辑同步群组”可重新命名或删除群组。\n【步骤 2：点击加入文件夹】点击列表底部蓝色“加入文件夹...”按钮，打开系统访达（Finder）选取对话框（每个群组至少需加入 2 个文件夹以建立同步网络）。\n【步骤 3：依指引选取 4 大存储位置】：\n1. 电脑本机：打开 Finder ➔ 点击侧边栏“文稿”或个人专属目录 ➔ 选取目标文件夹。\n2. iCloud 云盘：打开 Finder ➔ 点击侧边栏“iCloud 云盘”➔ 选取目标文件夹。\n3. Google Drive：打开 Finder ➔ 点击侧边栏“Google Drive”➔ 进入“我的云端硬盘”➔ 选取目标文件夹。\n4. 外接随身碟：插上随身碟 ➔ 打开 Finder ➔ 侧边栏“位置”选取该随身碟 ➔ 选取目标文件夹（强烈建议格式化为 ExFAT）。\n【步骤 4：更换或移除端点】路径搬移时点击端点卡片右侧“更换文件夹...”；若要解除同步点击“移除...”（仅解除关联，绝不删除实体文件）。",
        .ja: "【ステップ 1：同期グループの作成と切り替え】上部の「＋ 新規グループ」から名前（仕事、写真など）とアイコンを設定して作成。チップをクリックして切り替え、「同期グループを編集」で名前変更や削除が可能です。\n【ステップ 2：フォルダの追加をクリック】下部の青い「フォルダを追加...」をクリックし、Finder のフォルダ選択画面を開きます（各グループ最低2つのフォルダが必要です）。\n【ステップ 3：4つの保存先の選択手順】：\n1. Mac ローカル: Finder を開き、サイドバーの「書類」または個人フォルダを選択。\n2. iCloud Drive: Finder を開き、サイドバーの「iCloud Drive」を選択。\n3. Google Drive: Finder を開き、サイドバーの「Google Drive」➔「マイドライブ」を選択。\n4. 外付け USB ドライブ: USB を挿入し、Finder サイドバー「場所」からドライブを選択（ExFAT 形式を強く推奨）。\n【ステップ 4：変更と解除】パス移動時はカード右側の「フォルダ変更...」をクリック。解除時は「削除...」をクリック（実際のファイルは保持されます）。",
        .th: "【ขั้นตอนที่ 1: สร้างและสลับกลุ่มการซิงค์】คลิก '+ กลุ่มใหม่' ด้านบน ตั้งชื่อ (เช่น งาน, รูปถ่าย) และเลือกไอคอน คลิกแท็บเพื่อสลับกลุ่ม และคลิก 'แก้ไขกลุ่ม' เพื่อเปลี่ยนชื่อหรือลบกลุ่ม\n【ขั้นตอนที่ 2: คลิกเพิ่มโฟลเดอร์...】คลิกปุ่มสีน้ำเงิน 'เพิ่มโฟลเดอร์...' ด้านล่างเพื่อเปิดหน้าต่างเลือกของ Finder (แต่ละกลุ่มต้องมีอย่างน้อย 2 โฟลเดอร์เพื่อซิงค์ข้อมูล)\n【ขั้นตอนที่ 3: เลือกจาก 4 แหล่งข้อมูล】：\n1. เครื่อง Mac: เปิด Finder ➔ คลิก 'Documents' ในแถบด้านข้าง ➔ เลือกโฟลเดอร์เป้าหมาย\n2. iCloud Drive: เปิด Finder ➔ คลิก 'iCloud Drive' ในแถบด้านข้าง ➔ เลือกโฟลเดอร์เป้าหมาย\n3. Google Drive: เปิด Finder ➔ คลิก 'Google Drive' ➔ 'My Drive' ➔ เลือกโฟลเดอร์\n4. แฟลชไดรฟ์ USB: เสียบแฟลชไดรฟ์ ➔ เปิด Finder ➔ คลิกชื่อไดรฟ์ใต้ 'Locations' ➔ เลือกโฟลเดอร์ (แนะนำฟอร์แมตเป็น ExFAT)\n【ขั้นตอนที่ 4: เปลี่ยนหรือลบโฟลเดอร์】หากย้ายที่อยู่ให้คลิก 'เปลี่ยนโฟลเดอร์...' หรือคลิก 'ลบ...' เพื่อยกเลิกการซิงค์ (ไม่ลบไฟล์จริง)",
        .ko: "【1단계: 동기화 그룹 생성 및 전환】상단의 '+ 새 그룹'을 클릭하여 이름(예: 업무 프로젝트, 가족 사진)과 아이콘을 설정하세요. 그룹 칩을 클릭하여 즉시 전환하고, '동기화 그룹 편집'에서 이름을 바꾸거나 삭제할 수 있습니다.\n【2단계: 폴더 추가 클릭】하단의 파란색 '폴더 추가...' 버튼을 클릭하여 Finder 선택 창을 엽니다 (그룹당 최소 2개 이상의 폴더가 필요합니다).\n【3단계: 4대 저장 위치 선택 절차】：\n1. Mac 로컬: Finder 실행 ➔ 사이드바 '문서' 또는 개인 폴더 ➔ 대상 폴더 선택.\n2. iCloud Drive: Finder 실행 ➔ 사이드바 'iCloud Drive' ➔ 대상 폴더 선택.\n3. Google Drive: Finder 실행 ➔ 사이드바 'Google Drive' ➔ '내 드라이브' ➔ 대상 폴더 선택.\n4. 외장 USB 드라이브: USB 연결 ➔ Finder 사이드바 '위치' 아래 드라이브 ➔ 대상 폴더 선택 (ExFAT 포맷 권장).\n【4단계: 변경 및 해제】경로 이동 시 카드 우측의 '폴더 변경...'을 클릭하고, 동기화 해제 시 '제거...'를 클릭하세요 (실제 파일은 안전하게 보존됩니다)."
    ],
    "manual_topic_folders_safe_title": [
        .en: "Marker Guard & Offline Detection",
        .zhHant: "防偽標記檔保護與離線現象",
        .zhHans: "防伪标记档保护与离线现象",
        .ja: "マーカー保護とオフライン検知",
        .th: "การป้องกันด้วยมาร์กเกอร์และสถานะออฟไลน์",
        .ko: "마커 파일 보호 및 오프라인 감지"
    ],
    "manual_topic_folders_safe_desc": [
        .en: "• Unique Marker: Automatically writes a `.syncnexus-endpoint` UUID file upon addition.\n• Wrong Drive Protection: If a different USB drive is inserted into the same mount path, syncing halts with yellow 'Offline' badge and warning 'Marker does not match, stopped propagating'.\n• Unplug Detection: Ejecting a drive marks it 'Offline (Unplugged)'; reinserting automatically restores syncing within 2 seconds.",
        .zhHant: "• 防偽標記：加入資料夾時自動寫入 `.syncnexus-endpoint` UUID 標記。\n• 插錯隨身碟防護：若隨身碟被替換或標記不符，端點顯示黃色「離線」並警告「標記檔不符，已停止傳播任何變更」，主動隔離保護！\n• 拔除離線現象：拔除外接隨身碟自動標記「離線（已拔除）」，插回後 2 秒內自動恢復同步。",
        .zhHans: "• 防伪标记：加入文件夹时自动写入 `.syncnexus-endpoint` UUID 标记。\n• 插错随身碟防护：若随身碟被替换或标记不符，端点显示黄色“离线”并警告“标记档不符，已停止传播任何变更”，主动隔离保护！\n• 拔除离线现象：拔除外接随身碟自动标记“离线（已拔除）”，插回后 2 秒内自动恢复同步。",
        .ja: "• マーカー保護: フォルダ追加時に `.syncnexus-endpoint` UUID ファイルを自動生成します。\n• 誤挿入保護: 別の USB が挿入された場合、「マーカー不一致」として黄色「オフライン」表示し、誤った上書きを防ぎます。\n• 取り外し検知: USB を抜くと自動的に「オフライン（取り外し済み）」となり、再度挿入すると2秒以内に自動復旧します。",
        .th: "• มาร์กเกอร์เฉพาะ: สร้างไฟล์ `.syncnexus-endpoint` UUID ในโฟลเดอร์โดยอัตโนมัติ\n• ป้องกันการเสียบผิดไดรฟ์: หากเสียบแฟลชไดรฟ์ผิดตัว ระบบจะหยุดซิงค์ทันที แสดงป้ายสีเหลือง 'ออฟไลน์' และเตือนมาร์กเกอร์ไม่ตรงกัน\n• ตรวจจับการถอด: เมื่อถอดแฟลชไดรฟ์จะแสดงเป็น 'ออฟไลน์ (ถอดออก)' และเมื่อเสียบกลับจะซิงค์ต่ออัตโนมัติใน 2 วินาที",
        .ko: "• 고유 마커: 폴더 추가 시 `.syncnexus-endpoint` UUID 파일이 자동 생성됩니다.\n• 잘못된 드라이브 보호: 다른 USB가 연결되면 '마커 불일치'로 노란색 '오프라인' 표시되며 동기화가 차단됩니다.\n• 분리 감지: 드라이브 분리 시 '오프라인 (분리됨)'으로 자동 표시되며 다시 연결하면 2초 내에 자동 재개됩니다."
    ],
    "manual_topic_folders_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_folders_tips_desc": [
        .en: "Formatting USB drives as ExFAT enables SyncNexus's automatic portable filename filters, guaranteeing flawless cross-platform sync across Mac and Windows.",
        .zhHant: "外接隨身碟格式化為 ExFAT，SyncNexus 會自動啟動「檔名相容 ExFAT / Windows」過濾，防止非法字元導致同步失敗。",
        .zhHans: "外接随身碟格式化为 ExFAT，SyncNexus 会自动启动“文件名相容 ExFAT / Windows”过滤，防止非法字元导致同步失败。",
        .ja: "外付けドライブを ExFAT でフォーマットすると、ExFAT/Windows 互換ファイル名フィルターが自動有効化され、Mac と Windows 間で安全に同期できます。",
        .th: "การฟอร์แมตแฟลชไดรฟ์เป็น ExFAT จะเปิดใช้งานตัวกรองชื่อไฟล์ที่เข้ากันได้กับ Windows โดยอัตโนมัติ ป้องกันปัญหาชื่อไฟล์ข้ามระบบ",
        .ko: "외장 USB 드라이브를 ExFAT으로 포맷하면 SyncNexus의 호환 파일명 필터가 자동 작동하여 Mac과 Windows 간에 오류 없이 동기화됩니다."
    ],

    // 4. Conflicts
    "manual_topic_conflicts_title": [
        .en: "Chapter 4: Conflicts — Dual-Version Arbitration",
        .zhHant: "第四章：衝突 (Conflicts) — 雙版本智慧保留與仲裁",
        .zhHans: "第四章：冲突 (Conflicts) — 双版本智慧保留与仲裁",
        .ja: "第4章：競合 (Conflicts) — 2バージョンの安全保持と裁定",
        .th: "บทที่ 4: ข้อขัดแย้ง (Conflicts) — การเก็บรักษาและการตัดสินสองเวอร์ชัน",
        .ko: "제4장: 충돌 (Conflicts) — 두 버전 보존 및 중재"
    ],
    "manual_topic_conflicts_desc": [
        .en: "When a file is modified independently on two offline endpoints, SyncNexus enforces a strict 'Zero-Overwrite' policy. Conflicting versions are preserved as `Filename (conflict ...)`, gathered here for side-by-side comparison and resolution.",
        .zhHant: "當兩端離線時同時修改了同一個檔案，SyncNexus 堅持「絕不覆蓋任何一方」。系統將另一份修改另存為衝突副本（例如 檔名 (conflict ...)），集中於本頁讓您自主比對與決定。",
        .zhHans: "当两端离线时同时修改了同一个文件，SyncNexus 坚持“绝不覆盖任何一方”。系统将另一份修改另存为冲突副本（例如 文件名 (conflict ...)），集中于本页让您自主比对与决定。",
        .ja: "オフライン時に両方で同じファイルが編集された場合、SyncNexus は一切上書きしません。競合バージョンを `ファイル名 (conflict ...)` として保持し、この画面で左右並べて比較・解決できます。",
        .th: "เมื่อไฟล์ถูกแก้ไขพร้อมกันในสองเครื่องขณะออฟไลน์ SyncNexus จะไม่เขียนทับฝ่ายใดทั้งสิ้น ระบบจะเก็บสำเนาข้อขัดแย้งไว้เป็น `ชื่อไฟล์ (conflict ...)` ให้คุณเปรียบเทียบและเลือกเวอร์ชันที่ต้องการในหน้านี้",
        .ko: "오프라인 상태에서 두 장치에서 동일한 파일이 수정된 경우, SyncNexus는 어느 한쪽도 덮어쓰지 않습니다. 충돌 파일을 `파일명 (conflict ...)`으로 안전하게 보존하여 이 화면에서 나란히 비교하고 해결할 수 있습니다."
    ],
    "manual_topic_conflicts_ops_title": [
        .en: "Zero-Foundation Tutorial: Dual-Version Conflict Resolution",
        .zhHant: "零基礎教學：雙版本衝突仲裁手把手步驟",
        .zhHans: "零基础教学：双版本冲突仲裁手把手步骤",
        .ja: "入門チュートリアル：2バージョン競合解決手順",
        .th: "คู่มือเริ่มต้น: ขั้นตอนการตัดสินข้อขัดแย้งสองเวอร์ชัน",
        .ko: "초보자 가이드: 두 버전 충돌 해결 단계별 절차"
    ],
    "manual_topic_conflicts_ops_desc": [
        .en: "【Step 1: Check Red Conflict Badge】When concurrent edits occur offline, a red count badge appears on the sidebar 'Conflicts' icon. Click to open the conflict resolver.\n【Step 2: Inspect Dual-Column Cards】The view presents side-by-side cards: the left card shows the 'Current Version', and the right card shows the 'Endpoint Version' (with a green 'Newer' badge), detailing sizes, modified timestamps, and folder sources.\n【Step 3: Reveal in Finder for Content Diff】To inspect line-by-line differences, click 'Reveal in Finder' in either card to highlight the files in Finder and compare them in your favorite editor.\n【Step 4: Choose Resolution Action】:\n- Click left 'Keep This Version': Keeps the primary file, pushes it to all endpoints, and archives the conflict copy.\n- Click right 'Use This Version': Promotes the conflict copy to official primary file, backing up previous primary to Versions.\nThe red badge clears to 0 and all endpoints align cleanly.",
        .zhHant: "【步驟 1：察看側欄衝突警示紅標】當離線時兩端同時編輯同個檔案，側邊欄「衝突」圖示會亮起紅色數字徽章，點擊進入衝突管理頁面。\n【步驟 2：左右並列對照兩份版本】中央呈現雙欄卡片：左欄為「目前主要版本」，右欄為「來自端點版本」（標註綠色「較新」標籤），清楚列出檔案大小、修改時間與來源端點。\n【步驟 3：在訪達中打開比對內容】若想詳細比對內文，點擊兩側卡片內的「在 Finder 中顯示」按鈕，系統自動在訪達中標出該檔案，方便以文字編輯器打開檢查。\n【步驟 4：點擊仲裁按鈕完成解決】：\n- 點擊左側「保留此版本」：以主要版本為標準推播至各端點，衝突副本安全歸檔。\n- 點擊右側「改用此版本」：採用衝突副本取代主要檔案，舊版本自動存入「舊版本庫」備份。\n完成後側欄紅標歸零，顯示「沒有未解決的衝突」。",
        .zhHans: "【步骤 1：察看侧栏冲突警示红标】当离线时两端同时编辑同个文件，侧边栏“冲突”图标会亮起红色数字徽章，点击进入冲突管理页面。\n【步骤 2：左右并列对照两份版本】中央呈现双栏卡片：左栏为“目前主要版本”，右栏为“来自端点版本”（标注绿色“较新”标签），清楚列出文件大小、修改时间与来源端点。\n【步骤 3：在访达中打开比对内容】若想详细比对内文，点击两侧卡片内的“在 Finder 中显示”按钮，系统自动在访达中标出该文件，方便以文本编辑器打开检查。\n【步骤 4：点击仲裁按钮完成解决】：\n- 点击左侧“保留此版本”：以主要版本为标准推播至各端点，冲突副本安全归档。\n- 点击右侧“改用此版本”：采用冲突副本取代主要文件，旧版本自动存入“旧版本库”备份。\n完成后侧栏红标归零，显示“没有未解决的冲突”。",
        .ja: "【ステップ 1：赤い未解決バッジの確認】オフライン時に同じファイルが両方で編集されると、サイドバーの「競合」に赤い数字バッジが表示されます。クリックして画面を開きます。\n【ステップ 2：左右並べてバージョン比較】左が「現在のバージョン」、右が「端点からのバージョン（緑の『新しい』バッジ付き）」として表示され、サイズ、更新日時、保存先を確認できます。\n【ステップ 3：Finder で開いて内容照合】テキストの内容を細かく比較したい場合は、「Finder で表示」をクリックしてエディタで開いて確認できます。\n【ステップ 4：解決ボタンをクリック】：\n- 左の「このバージョンを保持」: プライマリを正式採用して全端点に同期し、競合コピーを安全に退避。\n- 右の「このバージョンを採用」: 競合コピーを正とし、以前のファイルは履歴庫に安全にバックアップ。\n解決するとバッジは消え、「未解決の競合はありません」と表示されます。",
        .th: "【ขั้นตอนที่ 1: ตรวจสอบป้ายตัวเลขสีแดง】เมื่อมีการแก้ไขพร้อมกันขณะออฟไลน์ ตัวเลขสีแดงจะแสดงบนแท็บ 'ข้อขัดแย้ง' ให้คลิกเพื่อเข้าสู่หน้าจัดการ\n【ขั้นตอนที่ 2: เปรียบเทียบสองเวอร์ชันซ้ายขวา】หน้าจอแสดงการเปรียบเทียบ: ทางซ้ายคือ 'เวอร์ชันหลักปัจจุบัน' ทางขวาคือ 'เวอร์ชันจากโฟลเดอร์' (มีป้ายสีเขียว 'ใหม่กว่า') แสดงขนาด วันที่แก้ไข และแหล่งที่มา\n【ขั้นตอนที่ 3: เปิดใน Finder เพื่อดูเนื้อหา】หากต้องการตรวจดูเนื้อหาภายในไฟล์ ให้คลิก 'แสดงใน Finder' บนการ์ดเพื่อเปิดดูไฟล์ในโปรแกรมแก้ไขข้อความ\n【ขั้นตอนที่ 4: คลิกปุ่มตัดสิน】：\n- คลิกซ้าย 'เก็บเวอร์ชันนี้': ยึดเวอร์ชันหลักและซิงค์ไปยังทุกโฟลเดอร์ สำเนาขัดแย้งจะถูกเก็บถาวร\n- คลิกขวา 'ใช้เวอร์ชันนี้': นำสำเนาขัดแย้งมาใช้แทน โดยเวอร์ชันเดิมจะถูกสำรองไว้ในประวัติ\nเมื่อเสร็จสิ้น ตัวเลขสีแดงจะหายไปและแสดงว่าไม่มีข้อขัดแย้ง",
        .ko: "【1단계: 사이드바 빨간색 충돌 배지 확인】오프라인 상태에서 양쪽이 동시에 같은 파일을 수정하면 사이드바 '충돌' 아이콘에 빨간색 숫자 배지가 켜집니다. 클릭하여 화면으로 이동하세요.\n【2단계: 좌우 나란히 버전 대조】좌측은 '현재 기본 버전', 우측은 '엔드포인트 버전(녹색 최신 배지)'으로 파일 크기, 수정 일시, 출처 폴더가 상세히 표시됩니다.\n【3단계: Finder에서 열어 내용 확인】내용을 직접 비교하고 싶다면 카드 안의 'Finder에서 보기'를 클릭하여 텍스트 편집기 등으로 열어보세요.\n【4단계: 중재 버튼 클릭】：\n- 좌측 '이 버전 유지' 클릭: 기본 버전을 정식으로 채택하여 전파하고 충돌 사본은 안전 보관.\n- 우측 '이 버전 사용' 클릭: 충돌 사본을 기본 파일로 채택하고 기존 파일은 히스토리에 백업.\n해결 완료 시 배지가 사라지며 '미해결 충돌 없음'으로 전환됩니다."
    ],
    "manual_topic_conflicts_safe_title": [
        .en: "Expected Phenomena & Zero-Overwrite Guarantee",
        .zhHant: "產出現象與「零覆蓋」安全機制",
        .zhHans: "产出现象与“零覆盖”安全机制",
        .ja: "動作現象と「上書きゼロ」保護保証",
        .th: "ผลลัพธ์การทำงานและการรับประกันไม่เขียนทับข้อมูล",
        .ko: "동작 현상 및 '덮어쓰기 제로' 안전 보장"
    ],
    "manual_topic_conflicts_safe_desc": [
        .en: "• Conflict Backup: When two sides edit offline, a `Filename (conflict ...)` copy is created. Neither is overwritten.\n• Badge Notification: A red counter badge appears on the sidebar 'Conflicts' tab.\n• Post-Arbitration: After resolution, the counter clears to 0, conflict copies are safely pruned, and all endpoints align cleanly.",
        .zhHant: "• 衝突副本產生：兩端離線同時編輯時，自動另存為 `檔名 (conflict ...)` 副本，絕不覆蓋任何一方。\n• 衝突待處理警示：側欄「衝突」圖示會亮起紅色數字徽章。\n• 衝突解決反饋：點擊裁決後，側欄數字歸零，衝突副本自動歸檔清理，所有端點檔案恢復一致。",
        .zhHans: "• 冲突副本产生：两端离线同时编辑时，自动另存为 `文件名 (conflict ...)` 副本，绝不覆盖任何一方。\n• 冲突待处理警示：侧栏“冲突”图标会亮起红色数字徽章。\n• 冲突解决反馈：点击裁决后，侧栏数字归零，冲突副本自动归档清理，所有端点文件恢复一致。",
        .ja: "• 競合コピー生成: オフライン同時編集時、`ファイル名 (conflict ...)` コピーを自動生成。どちらも上書きされません。\n• バッジ通知: サイドバーの「競合」アイコンに赤い未解決数バッジが表示されます。\n• 解決後: 解決ボタンを押すとバッジは消去され、競合コピーはアーカイブ退避され、全端点が一致します。",
        .th: "• การสร้างสำเนาข้อขัดแย้ง: เมื่อแก้ไขพร้อมกันขณะออฟไลน์ จะบันทึกเป็น `ชื่อไฟล์ (conflict ...)` โดยไม่เขียนทับ\n• ป้ายแจ้งเตือน: แสดงตัวเลขสีแดงบนแถบด้านข้าง 'ข้อขัดแย้ง'\n• หลังการตัดสิน: เมื่อเลือกเวอร์ชันแล้ว ตัวเลขจะหายไป สำเนาขัดแย้งจะถูกเก็บถาวร และทุกโฟลเดอร์จะตรงกัน",
        .ko: "• 충돌 사본 생성: 오프라인 동시 수정 시 `파일명 (conflict ...)` 사본이 자동 생성되며 덮어쓰지 않습니다.\n• 배지 알림: 사이드바 '충돌' 탭에 빨간색 미해결 숫자 배지가 표시됩니다.\n• 해결 후: 결정 후에는 숫자가 사라지고 충돌 사본이 안전하게 정리되며 모든 폴더가 일치합니다."
    ],
    "manual_topic_conflicts_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_conflicts_tips_desc": [
        .en: "If changes from both versions are needed, click 'Reveal in Finder', merge the edits into the primary file using your text editor, and then click 'Keep This Version'.",
        .zhHant: "若內容互有取捨，可先點擊「在 Finder 中顯示」，將兩份檔案的修改手動合併至主檔後，再點擊「保留此版本」。",
        .zhHans: "若内容互有取舍，可先点击“在 Finder 中显示”，将两份文件的修改手动合并至主档后，再点击“保留此版本”。",
        .ja: "両方の変更を残したい場合は、まず「Finder で表示」をクリックしてエディタで内容をマージしてから、「このバージョンを保持」をクリックしてください。",
        .th: "หากต้องการรวมเนื้อหาจากทั้งสองฝ่าย ให้คลิก 'แสดงใน Finder' รวมการแก้ไขเข้ากับไฟล์หลักด้วยโปรแกรมแก้ไขข้อความ แล้วคลิก 'เก็บเวอร์ชันนี้'",
        .ko: "두 버전의 변경 내용을 모두 반영해야 하는 경우, 먼저 'Finder에서 보기'를 클릭하여 텍스트 편집기에서 수동으로 병합한 후 '이 버전 유지'를 클릭하세요."
    ],

    // 5. Versions
    "manual_topic_versions_title": [
        .en: "Chapter 5: Versions — History Time Machine",
        .zhHant: "第五章：舊版本 (Versions) — 歷史時光機與防手殘",
        .zhHans: "第五章：旧版本 (Versions) — 历史时光机与防手残",
        .ja: "第5章：履歴 (Versions) — タイムマシンと復元",
        .th: "บทที่ 5: เวอร์ชันเก่า (Versions) — ไทม์แมชชีนและการกู้คืน",
        .ko: "제5장: 이전 버전 (Versions) — 타임머신 및 복구 센터"
    ],
    "manual_topic_versions_desc": [
        .en: "Versions is your personal time machine. Whenever a file is overwritten or updated by sync, superseded iterations are preserved in `.syncnexus-history`. Even if you mistakenly overwrite important content, you can recover yesterday's revision with a single click.",
        .zhHant: "「舊版本」是您的個人資料時光機。每當檔案被修改覆寫或同步取代時，被替換的舊內容會完整封存於 `.syncnexus-history`。即使不小心儲存了錯誤內容，隨時可以在此找回昨天的版本並一鍵救回。",
        .zhHans: "“旧版本”是您的个人数据时光机。每当文件被修改覆写或同步取代时，被替换的旧内容会完整封存于 `.syncnexus-history`。即使不小心保存了错误内容，随时可以在此找回昨天的版本并一键救回。",
        .ja: "「履歴」はあなたのタイムマシンです。ファイルが更新または同期で上書きされるたびに、古い内容が `.syncnexus-history` に保存されます。誤って上書きしてしまっても、いつでもワンクリックで復元可能です。",
        .th: "หน้านี้คือไทม์แมชชีนของคุณ ทุกครั้งที่ไฟล์ถูกบันทึกทับหรือแก้ไขจากการซิงค์ เนื้อหาเดิมจะถูกเก็บไว้ใน `.syncnexus-history` ช่วยให้คุณกู้คืนเวอร์ชันของเมื่อวานได้ด้วยคลิกเดียว",
        .ko: "'이전 버전'은 파일 타임머신입니다. 파일이 수정되거나 동기화로 덮어씌워질 때마다 이전 내용이 `.syncnexus-history`에 안전하게 보관되어 언제든 클릭 한 번으로 이전 버전을 되살릴 수 있습니다."
    ],
    "manual_topic_versions_ops_title": [
        .en: "Zero-Foundation Tutorial: History Time Machine & Restoration",
        .zhHant: "零基礎教學：歷史時光機與一鍵還原手把手步驟",
        .zhHans: "零基础教学：历史时光机与一键还原手把手步骤",
        .ja: "入門チュートリアル：履歴タイムマシンと復元手順",
        .th: "คู่มือเริ่มต้น: ไทม์แมชชีนและการกู้คืนไฟล์ขั้นตอนต่อขั้นตอน",
        .ko: "초보자 가이드: 히스토리 타임머신 및 복구 단계별 절차"
    ],
    "manual_topic_versions_ops_desc": [
        .en: "【Step 1: Set Retention Policy】Choose retention duration (7 / 30 / 90 days or Permanent) in the top dropdown; outdated revisions are pruned automatically in the background to reclaim disk space.\n【Step 2: Search Target Revision】Type a filename or folder keyword into the search bar at the top right; the list instantly filters matching historical revisions.\n【Step 3: Click Restore to Recover File】Click the 'Restore' button on the revision card. The file is instantly recovered to your working directory, a top Toast HUD confirms success, and all other endpoints sync within 2 seconds.\n【Step 4: Storage Maintenance (Optional)】Click 'Clean Expired Now' to purge outdated backups, or click 'Clear All' to wipe historical archives after confirming the dialog (active working files are never affected).",
        .zhHant: "【步驟 1：設定歷史保留天數】在頂部卡片「歷史保留期限」下拉選單中，選取保留時間（7天 / 30天 / 90天 / 永久），系統會在背景自動清理逾期檔案以釋放空間。\n【步驟 2：搜尋目標歷史檔案】在右上角搜尋輸入框中，輸入檔名關鍵字或資料夾名稱，歷史清單即時過濾出匹配的修訂版本。\n【步驟 3：一鍵還原救回檔案】在歷史記錄項目右側，點擊「還原」按鈕；目標檔案立即被該歷史版本替換，頂部彈出成功 Toast 提示，且 2 秒內同步更新至所有其他端點。\n【步驟 4：手動空間清理（選用）】若磁碟空間不足，點擊「清理過期版本」立即釋放逾期容量；點擊「清空全部」則可在通過二次確認後清空歷史庫（絕不影響正在使用的正式檔案）。",
        .zhHans: "【步骤 1：设定历史保留天数】在顶部卡片“历史保留期限”下拉菜单中，选取保留时间（7天 / 30天 / 90天 / 永久），系统会在背景自动清理逾期文件以释放空间。\n【步骤 2：搜索目标历史文件】在右上角搜索输入框中，输入档名关键字或文件夹名称，历史清单即时过滤出匹配的修订版本。\n【步骤 3：一键还原救回文件】在历史记录项目右侧，点击“还原”按钮；目标文件立即被该历史版本替换，顶部弹出成功 Toast 提示，且 2 秒内同步更新至所有其他端点。\n【步骤 4：手动空间清理（选用）】若磁盘空间不足，点击“清理过期版本”立即释放逾期容量；点击“清空全部”则可在通过二次确认后清空历史库（绝不影响正在使用的正式文件）。",
        .ja: "【ステップ 1：保持期間の設定】上部の「保持期間」プルダウンから（7日 / 30日 / 90日 / 無期限）を選択。期限切れファイルは自動削除され空き容量を保ちます。\n【ステップ 2：過去ファイルの検索】右上の検索ボックスにファイル名やフォルダ名を入力すると、該当する履歴バージョンが即座に絞り込まれます。\n【ステップ 3：復元ボタンで一発救出】履歴項目の右側にある「復元」ボタンをクリック。対象ファイルが過去バージョンで置き換わり、上部トーストで通知され、2秒以内に全端点に同期されます。\n【ステップ 4：容量の手動整理（任意）】容量を空けたい時は「期限切れをクリーンアップ」をクリック。また「すべてクリア」で確認後に履歴全体を削除できます（作業中のファイルには一切影響しません）。",
        .th: "【ขั้นตอนที่ 1: กำหนดระยะเวลาเก็บรักษา】เลือกเวลาเก็บรักษา (7 / 30 / 90 วัน หรือถาวร) จากเมนูด้านบน ไฟล์ที่หมดอายุจะถูกลบในพื้นหลังโดยอัตโนมัติเพื่อคืนพื้นที่ดิสก์\n【ขั้นตอนที่ 2: ค้นหาไฟล์ประวัติที่ต้องการ】พิมพ์ชื่อไฟล์หรือชื่อโฟลเดอร์ในช่องค้นหามุมขวาบน รายการประวัติจะกรองตามคำค้นหาทันที\n【ขั้นตอนที่ 3: กู้คืนไฟล์ด้วยคลิกเดียว】คลิกปุ่ม 'กู้คืน' ทางขวาของรายการประวัติ ไฟล์จะถูกแทนที่ด้วยเวอร์ชันประวัตินั้นทันที มี Toast แจ้งสำเร็จ และซิงค์ไปยังทุกโฟลเดอร์ใน 2 วินาที\n【ขั้นตอนที่ 4: ล้างพื้นที่เก็บข้อมูล (ทางเลือก)】คลิก 'ล้างเวอร์ชันที่หมดอายุทันที' เพื่อลบไฟล์ที่เกินกำหนด หรือคลิก 'ล้างทั้งหมด' เพื่อล้างประวัติหลังยืนยัน (ไม่กระทบไฟล์ที่ใช้งานอยู่)",
        .ko: "【1단계: 보관 기간 설정】상단 카드의 '보관 기간' 메뉴에서 보관 기간(7일 / 30일 / 90일 / 영구 보관)을 선택하세요. 만료된 파일은 백그라운드에서 자동 정리됩니다.\n【2단계: 대상 이전 파일 검색】우측 상단 검색창에 파일명이나 폴더명을 입력하면 일치하는 과거 버전 목록이 즉시 필터링됩니다.\n【3단계: 원클릭 복구】목록 우측의 '복구' 버튼을 클릭하면 대상 파일이 즉시 해당 과거 버전으로 복원되며, 상단 성공 토스트 알림과 함께 2초 내에 모든 엔드포인트에 동기화됩니다.\n【4단계: 수동 용량 정리 (선택 사항)】디스크 공간이 부족하면 '만료된 버전 정리'를 클릭하거나, '모두 지우기'를 통해 확인 후 히스토리 전체를 비울 수 있습니다 (현재 작업 중인 파일에는 전혀 영향 없음)."
    ],
    "manual_topic_versions_safe_title": [
        .en: "Expected Phenomena & Automatic History Archival",
        .zhHant: "產出現象與歷史時光機防線",
        .zhHans: "产出现象与历史时光机防线",
        .ja: "動作現象と履歴タイムマシン保護",
        .th: "ผลลัพธ์การทำงานและการสำรองประวัติอัตโนมัติ",
        .ko: "동작 현상 및 히스토리 타임머신 보호"
    ],
    "manual_topic_versions_safe_desc": [
        .en: "• Automatic History: Whenever a file is overwritten or synced, superseded content is archived into `.syncnexus-history` automatically.\n• Restore Feedback: Clicking 'Restore' updates the file instantly, toast confirms success, and all endpoints update in 2 seconds.\n• Storage Safeguard: When history exceeds 20 GB, the oldest files are pruned first, ensuring disk stability.",
        .zhHant: "• 覆寫自動備份：每當檔案被修改覆寫或同步取代時，舊內容會自動封存至 `.syncnexus-history`。\n• 還原反饋：點擊「還原」後，目標檔案立即被歷史版本取代，上方彈出成功提示，各端點於 2 秒內同步更新。\n• 容量防爆：當舊版本總量超過 20 GB 時，系統會自動從最舊的開始清理，確保磁碟空間安全。",
        .zhHans: "• 覆写自动备份：每当文件被修改覆写或同步取代时，旧内容会自动封存至 `.syncnexus-history`。\n• 还原反馈：点击“还原”后，目标文件立即被历史版本取代，上方弹出成功提示，各端点于 2 秒内同步更新。\n• 容量防爆：当旧版本总量超过 20 GB 时，系统会自动从最旧的开始清理，确保磁盘空间安全。",
        .ja: "• 上書き自動退避: ファイルが更新または同期で置き換わるたびに、旧内容は `.syncnexus-history` に自動保存されます。\n• 復元フィードバック: 「復元」を押すと作業ファイルが即座に過去版で置き換わり、2秒以内に全端点に同期されます。\n• 容量上限保護: 履歴が 20 GB を超えると最も古いものから自動削除され、空き容量を圧迫しません。",
        .th: "• สำรองอัตโนมัติเมื่อถูกเขียนทับ: เนื้อหาเดิมจะถูกเก็บไว้ใน `.syncnexus-history` เสมอเมื่อไฟล์ถูกแก้ไขหรือซิงค์ทับ\n• ผลการกู้คืน: เมื่อคลิก 'กู้คืน' ไฟล์จะถูกแทนที่ด้วยเวอร์ชันประวัติทันที มีการแจ้งเตือนสำเร็จ และซิงค์ไปยังทุกโฟลเดอร์ใน 2 วินาที\n• การควบคุมขนาด: หากประวัติมีขนาดเกิน 20 GB ระบบจะเริ่มลบไฟล์ที่เก่าที่สุดก่อนโดยอัตโนมัติ",
        .ko: "• 덮어쓰기 자동 백업: 파일이 수정되거나 동기화로 대체될 때마다 이전 내용이 `.syncnexus-history`에 자동 보관됩니다.\n• 복구 피드백: '복구' 클릭 시 대상 파일이 즉시 과거 버전으로 교체되며 2초 내에 모든 엔드포인트에 동기화됩니다.\n• 용량 관리: 이전 버전 총 용량이 20 GB를 초과하면 가장 오래된 것부터 자동 정리되어 디스크를 보호합니다."
    ],
    "manual_topic_versions_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_versions_tips_desc": [
        .en: "If you accidentally delete or corrupt a document, open Versions, search for the filename, and click 'Restore'. Your work is recovered immediately!",
        .zhHant: "誤刪或改壞檔案時，先到「舊版本」頁面搜尋檔名，點一下「還原」，資料立刻失而復得！",
        .zhHans: "误删或改坏文件时，先到“旧版本”页面搜索档名，点一下“还原”，资料立刻失而复得！",
        .ja: "誤ってファイルを上書き・削除してしまった場合は、履歴画面でファイル名を検索して「復元」をクリックするだけで元通りになります！",
        .th: "หากลบหรือบันทึกไฟล์ทับโดยไม่ตั้งใจ ให้ไปที่หน้า 'เวอร์ชันเก่า' ค้นหาชื่อไฟล์ แล้วคลิก 'กู้คืน' ข้อมูลจะกลับมาทันที!",
        .ko: "실수로 파일을 덮어쓰거나 잘못 수정한 경우, '이전 버전' 페이지에서 파일명을 검색하고 '복구'를 클릭하면 즉시 되살릴 수 있습니다!"
    ],

    // 6. Verification
    "manual_topic_verification_title": [
        .en: "Chapter 6: Verification — SHA-256 Deep Integrity",
        .zhHant: "第六章：驗證紀錄 (Verification) — SHA-256 深度比對",
        .zhHans: "第六章：验证纪录 (Verification) — SHA-256 深度比对",
        .ja: "第6章：検証記録 (Verification) — SHA-256 完全性検証",
        .th: "บทที่ 6: บันทึกการตรวจสอบ (Verification) — ตรวจสอบ SHA-256 เชิงลึก",
        .ko: "제6장: 검증 기록 (Verification) — SHA-256 무결성 검증"
    ],
    "manual_topic_verification_desc": [
        .en: "To protect against silent bit-rot and transmission corruption, SyncNexus uses industrial-grade SHA-256 hashing to verify every byte across all endpoints, ensuring 100% data integrity.",
        .zhHant: "為防範硬碟壞軌導致的無聲資料損壞（Silent Bit-rot）或網路傳輸掉包，SyncNexus 採用工業級 SHA-256 雜湊技術，對所有端點的所有檔案進行逐 Byte 深度比對，確保每一份檔案都真實可靠。",
        .zhHans: "为防范硬盘坏道导致的无声数据损坏（Silent Bit-rot）或网络传输掉包，SyncNexus 采用工业级 SHA-256 哈希技术，对所有端点的所有文件进行逐 Byte 深度比对，确保每一份文件都真实可靠。",
        .ja: "サイレントビットロットやネットワーク転送エラーを防ぐため、工業規格の SHA-256 ハッシュを用いてすべての端点のファイルを1バイトずつ検証し、完全性を保証します。",
        .th: "เพื่อป้องกันข้อมูลเสียหายจากบิตดิสก์เสื่อมสภาพ (Bit-rot) หรือการส่งข้อมูลไม่สมบูรณ์ SyncNexus ใช้การแฮช SHA-256 ระดับอุตสาหกรรมตรวจสอบความถูกต้องของไฟล์แบบไบต์ต่อไบต์",
        .ko: "하드디스크 불량 섹터로 인한 사일런트 비트 로트(Silent Bit-rot)나 네트워크 전송 오류를 방지하기 위해, 산업 표준 SHA-256 해시를 사용하여 모든 엔드포인트의 파일을 바이트 단위로 검증합니다."
    ],
    "manual_topic_verification_ops_title": [
        .en: "Zero-Foundation Tutorial: SHA-256 Verification & Repair",
        .zhHant: "零基礎教學：SHA-256 完整驗證與自動修復手把手步驟",
        .zhHans: "零基础教学：SHA-256 完整验证与自动修复手把手步骤",
        .ja: "入門チュートリアル：SHA-256 完全検証と修復手順",
        .th: "คู่มือเริ่มต้น: การตรวจสอบ SHA-256 และการซ่อมแซมขั้นตอนต่อขั้นตอน",
        .ko: "초보자 가이드: SHA-256 무결성 검증 및 복구 단계별 절차"
    ],
    "manual_topic_verification_ops_desc": [
        .en: "【Step 1: Start Deep Verification】Click the blue 'Start Verification Now' button on the center card. SyncNexus computes cryptographic SHA-256 hashes across all files on all endpoints in the background.\n【Step 2: Review Verification Report】Upon completion, the 'Last Deep Verify' timestamp updates. A green badge indicates 'All Normal, No Anomalies'; if bit-rot or corruption is detected, affected files are listed.\n【Step 3: Repair Corrupted Files】:\n- Click 'Repair from Others': Downloads a pristine bit-accurate copy from a healthy endpoint to replace the damaged file (backing up the damaged file to history first).\n- Click 'Accept Current Content': If the change was intentional, recalculates baseline hash and clears the alert.\n【Step 4: Review Four Core Shields】The bottom card summarizes: SHA-256 verified on every copy, cache-bypass USB readback, auto-versioning before delete, and pause on mass deletions.",
        .zhHant: "【步驟 1：啟動深層完整驗證】在中央卡片右側，點擊藍色「立即執行完整驗證」按鈕。系統在背景逐一計算所有端點檔案的 SHA-256 雜湊值。\n【步驟 2：檢視驗證結果報告】驗證完成後，頂部更新「最近完整驗證」時間戳記。若所有檔案一致，顯示綠色徽章「全部正常，沒有異常」；若發現損毀或位元錯誤，條列受影響的檔案清單。\n【步驟 3：修復受損檔案】：\n- 點擊「從其他端點修復」：系統自動從健康的端點下載乾淨正確的副本覆蓋修復，受損檔案先備份進歷史庫後修復。\n- 點擊「接受目前內容」：若變更為有意修改，點擊重新計算基準雜湊值並解除警報。\n【步驟 4：了解四大內建防線】頁面底部卡片詳細列出：每次複製校驗雜湊、外接磁碟讀回雙重檢查、覆寫前存入舊版本、大量刪除攔截。",
        .zhHans: "【步骤 1：启动深层完整验证】在中央卡片右侧，点击蓝色“立即执行完整验证”按钮。系统在背景逐一计算所有端点文件的 SHA-256 哈希值。\n【步骤 2：检视验证结果报告】验证完成后，顶部更新“最近完整验证”时间戳记。若所有文件一致，显示绿色徽章“全部正常，没有异常”；若发现损毁或位元错误，条列受影响的文件清单。\n【步骤 3：修复受损文件】：\n- 点击“从其他端点修复”：系统自动从健康的端点下载干净正确的副本覆盖修复，受损文件先备份进历史库后修复。\n- 点击“接受目前内容”：若变更为有意修改，点击重新计算基准哈希值并解除警报。\n【步骤 4：了解四大内建防线】页面底部卡片详细列出：每次复制校验哈希、外接磁盘读回双重检查、覆写前存入旧版本、大量删除拦截。",
        .ja: "【ステップ 1：完全検証の開始】中央カード右側の青い「今すぐ完全検証を実行」をクリック。全端点のすべてのファイルに対してバックグラウンドで SHA-256 ハッシュを計算します。\n【ステップ 2：検証結果の確認】完了すると最終検証日時が更新されます。すべて一致していれば緑色の「異常なし」が表示され、破損やビット反転があれば問題ファイルが一覧表示されます。\n【ステップ 3：破損ファイルの修復】：\n- 「他の端点から修復」をクリック: 正常な端点から完全なファイルを自動ダウンロードして上書き修復（破損ファイルは事前に履歴庫に保存）。\n- 「現在の内容を受け入れる」をクリック: 意図した変更であれば、現在の内容を新たな基準ハッシュとして承認。\n【ステップ 4：4大安全防線の確認】下部カードで、コピー時ハッシュ照合、外付け再読込確認、履歴保存、大量削除停止の防線を確認できます。",
        .th: "【ขั้นตอนที่ 1: เริ่มการตรวจสอบเชิงลึก】คลิกปุ่มสีน้ำเงิน 'เริ่มการตรวจสอบทันที' ทางขวา ระบบจะคำนวณแฮช SHA-256 ของไฟล์ในทุกโฟลเดอร์ในพื้นหลัง\n【ขั้นตอนที่ 2: ตรวจสอบรายงานผล】เมื่อเสร็จสิ้น เวลาตรวจสอบล่าสุดจะได้รับการอัปเดต แสดงป้ายสีเขียว 'ปกติทั้งหมด ไม่มีสิ่งผิดปกติ' หากพบไฟล์เสียหายจะแสดงรายการไฟล์ที่ได้รับผลกระทบ\n【ขั้นตอนที่ 3: ซ่อมแซมไฟล์ที่เสียหาย】：\n- คลิก 'ซ่อมแซมจากโฟลเดอร์อื่น': ดาวน์โหลดสำเนาที่สมบูรณ์จากโฟลเดอร์ปกติมาทับซ่อมแซม (สำรองไฟล์เดิมไว้ในประวัติก่อน)\n- คลิก 'ยอมรับเนื้อหาปัจจุบัน': หากเป็นการแก้ไขที่ตั้งใจ คลิกเพื่อคำนวณค่าแฮชใหม่และยกเลิกการเตือน\n【ขั้นตอนที่ 4: เรียนรู้ 4 แนวป้องกัน】การ์ดด้านล่างสรุป: ตรวจสอบ SHA-256 ทุกครั้ง, อ่านซ้ำจาก USB, เก็บประวัติก่อนลบ และหยุดเมื่อไฟล์หายจำนวนมาก",
        .ko: "【1단계: 심층 무결성 검증 시작】중앙 카드 우측의 파란색 '지금 전체 검증 실행' 버튼을 클릭하세요. 백그라운드에서 모든 엔드포인트 파일의 SHA-256 해시를 바이트 단위로 계산합니다.\n【2단계: 검증 결과 보고서 확인】완료 후 '최근 심층 검증' 시간이 갱신됩니다. 모두 일치하면 녹색 배지 '모두 정상, 이상 없음'이 표시되며 손상 파일이 발견되면 목록이 나타납니다.\n【3단계: 손상 파일 복구】：\n- '다른 폴더에서 복구' 클릭: 정상적인 폴더에서 깨끗한 원본을 복사하여 복구 (손상 파일은 먼저 히스토리에 보관).\n- '현재 내용 수락' 클릭: 의도적인 변경인 경우 기준 해시를 새로 계산하여 경고 해제.\n【4단계: 4대 핵심 안전선 확인】하단 카드에서 복사 시 해시 검증, 외장 재판독, 덮어쓰기 전 버전 보관, 대량 삭제 중단 보호선을 확인할 수 있습니다."
    ],
    "manual_topic_verification_safe_title": [
        .en: "Expected Phenomena & Four Built-in Safeguards",
        .zhHant: "產出現象與四大防線",
        .zhHans: "产出现象与四大防线",
        .ja: "動作現象と4つの組み込み安全保護",
        .th: "ผลลัพธ์การทำงานและ 4 แนวป้องกันในตัว",
        .ko: "동작 현상 및 4대 안전 보호선"
    ],
    "manual_topic_verification_safe_desc": [
        .en: "• Verification Feedback: Displays 'Last Deep Verify' timestamp upon completion. Shows green 'No anomalies' or lists corrupted files.\n• Four Core Shields:\n  1. Every copy verified with SHA-256 hash.\n  2. External drives bypass cache and re-read after writing to confirm byte accuracy.\n  3. Overwrites and deletions archived to history before going to Trash.\n  4. Sync halts if directories vanish or mass deletions occur.",
        .zhHant: "• 驗證回饋：驗證完成後更新「最近完整驗證」時間；若無異常顯示綠色「沒有異常」，若有異常條列受損清單。\n• 四大內建防線：\n  1. 每次複製均核對 SHA-256 雜湊。\n  2. 外接磁碟寫入後繞過快取重新讀回比對。\n  3. 刪除與覆寫前先存舊版本，再進系統垃圾桶。\n  4. 資料夾消失、換碟、大量檔案同時消失時暫停同步。",
        .zhHans: "• 验证反馈：验证完成后更新“最近完整验证”时间；若无异常显示绿色“没有异常”，若有异常条列受损清单。\n• 四大内建防线：\n  1. 每次复制均核对 SHA-256 哈希。\n  2. 外接磁盘写入后绕过缓存重新读回比对。\n  3. 删除与覆写前先存旧版本，再进系统废纸篓。\n  4. 文件夹消失、换碟、大量文件同时消失时暂停同步。",
        .ja: "• 検証結果: 完了後に最終検証日時を更新。異常がなければ緑の「異常なし」、あれば破損リストを表示。\n• 4つの組み込み防線:\n  1. コピーのたびに SHA-256 ハッシュを検証。\n  2. 外付けドライブ書き込み後はキャッシュを迂回して再読み込み照合。\n  3. 削除や上書きの前にまず履歴に保存し、その後にゴミ箱へ移動。\n  4. フォルダ消失や大量ファイル消失時は同期を一時停止。",
        .th: "• ผลการตรวจสอบ: อัปเดตเวลาตรวจสอบล่าสุดเมื่อเสร็จสิ้น แสดงสีเขียว 'ไม่มีความผิดปกติ' หรือแสดงรายการไฟล์ที่เสียหาย\n• 4 แนวป้องกันหลัก:\n  1. ตรวจสอบแฮช SHA-256 ทุกครั้งที่มีการคัดลอก\n  2. อ่านข้อมูลกลับมาเปรียบเทียบซ้ำหลังจากเขียนลงแฟลชไดรฟ์\n  3. สำรองข้อมูลลงประวัติก่อน จากนั้นจึงย้ายไปถังขยะ\n  4. หยุดการซิงค์ทันทีเมื่อโฟลเดอร์หายหรือไฟล์จำนวนมากหายไป",
        .ko: "• 검증 피드백: 완료 후 '최근 심층 검증' 시간을 갱신하며, 이상이 없으면 녹색 '이상 없음', 이상 시 손상 파일 목록 표시.\n• 4대 핵심 안전선:\n  1. 모든 복사 시 SHA-256 해시 대조.\n  2. 외장 드라이브 쓰기 후 캐시를 우회하여 다시 읽어 일치 확인.\n  3. 삭제 및 덮어쓰기 전 항상 버전을 보관한 뒤 시스템 휴지통으로 이동.\n  4. 폴더 분실, 드라이브 교체, 대량 파일 소실 시 동기화 일시 중단."
    ],
    "manual_topic_verification_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_verification_tips_desc": [
        .en: "We recommend clicking 'Start Verification Now' once a month to perform a comprehensive health audit across all your backup drives.",
        .zhHant: "建議每個月點擊一次「立即驗證」，替所有備份硬碟做一次全面的健康檢查。",
        .zhHans: "建议每个月点击一次“立即验证”，替所有备份硬盘做一次全面的健康检查。",
        .ja: "月に1回「今すぐ検証」を実行して、すべてのバックアップドライブの健康診断を行うことを推奨します。",
        .th: "แนะนำให้คลิก 'ตรวจสอบทันที' เดือนละครั้งเพื่อตรวจสุขภาพความสมบูรณ์ของไฟล์ในทุกไดรฟ์สำรองข้อมูล",
        .ko: "한 달에 한 번 정도 '지금 검증'을 클릭하여 모든 백업 하드디스크의 무결성을 점검하는 것을 권장합니다."
    ],

    // 7. Settings
    "manual_topic_settings_title": [
        .en: "Chapter 7: Settings — Policies, Exclusions & Permissions",
        .zhHant: "第七章：設定 (Settings) — 衝突原則、排除規則與權限",
        .zhHans: "第七章：设置 (Settings) — 冲突原则、排除规则与权限",
        .ja: "第7章：設定 (Settings) — ポリシー、除外、権限",
        .th: "บทที่ 7: การตั้งค่า (Settings) — นโยบาย กฎการยกเว้น และสิทธิ์",
        .ko: "제7장: 설정 (Settings) — 정책, 제외 규칙 및 권한"
    ],
    "manual_topic_settings_desc": [
        .en: "Settings provides granular configuration for conflict arbitration, exclusion filters to protect databases and code projects, system auto-start, and macOS Full Disk Access guidance.",
        .zhHant: "「設定」提供個人化的同步偏好微調，讓您自由掌控衝突處理模式、排除可能干擾同步的暫存檔案，以及配置 macOS 系統權限與開機自啟動。",
        .zhHans: "“设置”提供个性化的同步偏好微调，让您自由掌控冲突处理模式、排除可能干扰同步的暂存文件，以及配置 macOS 系统权限与开机自启动。",
        .ja: "「設定」では、競合ポリシーの調整、不要な一時ファイルの除外ルール設定、macOS のフルディスクアクセス権限、ログイン時自動起動を設定できます。",
        .th: "หน้า 'การตั้งค่า' ให้คุณปรับแต่งนโยบายข้อขัดแย้ง กฎการยกเว้นไฟล์ชั่วคราว การเริ่มทำงานอัตโนมัติเมื่อเปิดเครื่อง และสิทธิ์การเข้าถึงดิสก์ของ macOS",
        .ko: "'설정'에서는 충돌 해결 모드 선택, 임시 파일 제외 규칙, 자동 실행 설정 및 macOS 전체 디스크 접근 권한 안내를 제공합니다."
    ],
    "manual_topic_settings_ops_title": [
        .en: "Zero-Foundation Tutorial: Policies, Exclusions & Permissions",
        .zhHant: "零基礎教學：衝突原則、排除規則與權限設定手把手步驟",
        .zhHans: "零基础教学：冲突原则、排除规则与权限设定手把手步骤",
        .ja: "入門チュートリアル：設定、除外ルールと権限設定手順",
        .th: "คู่มือเริ่มต้น: นโยบาย กฎการยกเว้น และการตั้งค่าสิทธิ์ขั้นตอนต่อขั้นตอน",
        .ko: "초보자 가이드: 충돌 정책, 제외 규칙 및 권한 설정 단계별 절차"
    ],
    "manual_topic_settings_ops_desc": [
        .en: "【Step 1: Choose Conflict Policy】In the first card, choose 'Keep both, let me choose (Recommended)' to create conflict copies for manual review, or 'Newer wins, old saved to versions' for automatic timestamp arbitration.\n【Step 2: Configure Exclusion Switches】In the second card, toggle exclusions for `node_modules`, `.git`, SQLite lock files (`-wal`, `-shm`), and Apple Photos (`.photoslibrary`). Excluded files are left untouched and never transferred.\n【Step 3: Set Language & Launch at Login】In the third card, select your preferred language from the 6 options; toggle 'Launch at Login' to have SyncNexus run quietly in your Mac menu bar upon startup.\n【Step 4: Grant Full Disk Access】In the permissions card, if marked yellow 'Unauthorized', click 'Open System Settings' to jump directly to macOS 'Privacy & Security ➔ Full Disk Access' and enable SyncNexus; click 'Open Log File' below for diagnostic logs.",
        .zhHant: "【步驟 1：挑選衝突處理原則】在第一張卡片中，單選「保留兩份，由我挑選（推薦，預設）」可在衝突時生成副本並由您決定；「自動採用較新，舊的存進舊版本」則自動以最新修改時間為準。\n【步驟 2：自訂排除規則開關】在第二張卡片中，開啟或關閉特定類型檔案排除開關（如 `node_modules` 程式庫、`.git` 版本庫、資料庫暫存檔 `-wal`/`-shm`、照片圖庫 `.photoslibrary`），被排除項目不會被同步傳輸。\n【步驟 3：設定語系與開機啟動】在第三張卡片中，使用下拉選單切換 6 國語言（繁體中文、簡體中文、English、日本語、한국어、ภาษาไทย）；切換開關設定「開機自動啟動」，登入 Mac 時自動於選單列後台守護。\n【步驟 4：檢查完全取用磁碟權限】在權限卡片中，若顯示黃燈「未授權」，點擊「開啟系統設定」按鈕直達 macOS「隱私權與安全性 ➔ 完全取用磁碟」，勾選 SyncNexus 即可獲取完整讀寫權限；下方另有「開啟日誌檔案」可調閱即時診斷記錄。",
        .zhHans: "【步骤 1：挑选冲突处理原则】在第一张卡片中，单选“保留两份，由我挑选（推荐，默认）”可在冲突时生成副本并由您决定；“自动采用较新，旧的存进旧版本”则自动以最新修改时间为准。\n【步骤 2：自订排除规则开关】在第二张卡片中，开启或关闭特定类型文件排除开关（如 `node_modules` 程序库、`.git` 版本库、数据库暂存文件 `-wal`/`-shm`、照片图库 `.photoslibrary`），被排除项目不会被同步传输。\n【步骤 3：设定语系与开机启动】在第三张卡片中，使用下拉菜单切换 6 国语言（繁体中文、简体中文、English、日本語、한국어、ภาษาไทย）；切换开关设定“开机自动启动”，登录 Mac 时自动于菜单栏后台守护。\n【步骤 4：检查完全磁盘访问权限】在权限卡片中，若显示黄灯“未授权”，点击“打开系统设置”按钮直达 macOS“隐私与安全性 ➔ 完全磁盘访问权限”，勾选 SyncNexus 即可获取完整读写权限；下方另有“打开日志文件”可调阅即时诊断记录。",
        .ja: "【ステップ 1：競合ポリシーの選択】第1カードで「両方保持して手動選択 (推奨)」または「新しい方を自動採用」を選択します。\n【ステップ 2：除外ルールの設定】第2カードで `node_modules`、`.git`、データベース一時ファイル (`-wal`, `-shm`)、写真ライブラリ (`.photoslibrary`) のスイッチを切り替え。除外された項目は転送されません。\n【ステップ 3：言語と自動起動の設定】第3カードで6言語から好みの言語を選択。「ログイン時に起動」をオンにすると Mac 起動時にメニューバーで待機します。\n【ステップ 4：フルディスクアクセスの確認】権限カードで「未認可」の場合、「システム設定を開く」をクリックして macOS の「プライバシーとセキュリティ ➔ フルディスクアクセス」で SyncNexus をオンにしてください。「ログファイルを開く」で詳細ログも確認できます。",
        .th: "【ขั้นตอนที่ 1: เลือกนโยบายข้อขัดแย้ง】ในการ์ดแรก เลือก 'เก็บทั้งสองเวอร์ชันและเลือกเอง (แนะนำ)' หรือ 'ใช้เวอร์ชันใหม่กว่าโดยอัตโนมัติ'\n【ขั้นตอนที่ 2: ตั้งค่ากฎการยกเว้น】ในการ์ดที่สอง เปิดหรือปิดการยกเว้นสำหรับ `node_modules`, `.git`, ไฟล์ชั่วคราวฐานข้อมูล (`-wal`, `-shm`) และคลังรูปภาพ Photos ไฟล์ที่ยกเว้นจะไม่ถูกซิงค์\n【ขั้นตอนที่ 3: ตั้งค่าภาษาและการเริ่มทำงาน】ในการ์ดที่สาม เลือกภาษาจาก 6 ภาษา และเปิดสวิตช์ 'เริ่มทำงานเมื่อเปิดเครื่อง' เพื่อให้โปรแกรมทำงานในแถบเมนูด้านบน\n【ขั้นตอนที่ 4: ตรวจสอบสิทธิ์เข้าถึงดิสก์】หากแสดงสีเหลือง 'ยังไม่ได้รับอนุญาต' ให้คลิก 'เปิดการตั้งค่าระบบ' เพื่อไปเปิดสิทธิ์ 'สิทธิ์เข้าถึงดิสก์เต็มรูปแบบ' ให้กับ SyncNexus คลิก 'เปิดไฟล์บันทึก' เพื่อดูบันทึกการทำงาน",
        .ko: "【1단계: 충돌 처리 원칙 선택】첫 번째 카드에서 '두 버전 모두 유지하고 수동 선택 (권장)' 또는 '새로운 버전 자동 채택' 중 선택하세요.\n【2단계: 제외 규칙 스위치 설정】두 번째 카드에서 `node_modules`, `.git`, 데이터베이스 잠금 파일(`-wal`, `-shm`), 사진 보관함(`.photoslibrary`) 제외 스위치를 켜거나 끕니다. 제외된 항목은 전송되지 않습니다.\n【3단계: 언어 및 자동 실행 설정】세 번째 카드에서 6개 언어 중 원하는 언어를 선택하고, '로그인 시 자동 실행' 스위치를 켜면 Mac 로그인 시 메뉴바에 자동 상주합니다.\n【4단계: 전체 디스크 접근 권한 확인】권한 카드에서 '권한 없음'으로 표시되면 '시스템 설정 열기'를 클릭하여 macOS '개인정보 보호 및 보안 ➔ 전체 디스크 접근 권한'에서 SyncNexus를 허용하세요. '로그 파일 열기'로 진단 로그도 확인할 수 있습니다."
    ],
    "manual_topic_settings_safe_title": [
        .en: "Expected Phenomena & System Protection",
        .zhHant: "產出現象與系統保護",
        .zhHans: "产出现象与系统保护",
        .ja: "動作現象とシステム保護",
        .th: "ผลลัพธ์การทำงานและการปกป้องระบบ",
        .ko: "동작 현상 및 시스템 보호"
    ],
    "manual_topic_settings_safe_desc": [
        .en: "• Exclusion Protection: Excluded directories remain completely untouched and are never synced, preventing live database locks from being corrupted.\n• Permission Indicator: Green 'Authorized' badge indicates full filesystem access; yellow 'Unauthorized' alerts you and offers a one-click button to open System Settings.",
        .zhHant: "• 排除保護：被排除的項目在所有資料夾中原封不動，不予傳播，避免同步鎖定的暫存檔損壞資料庫。\n• 權限指示：若磁碟授權完整顯示綠色「已授權」，權限受限時顯示黃色「未授權」並提供一鍵跳轉設定按鈕。",
        .zhHans: "• 排除保护：被排除的项目在所有文件夹中原封不动，不予传播，避免同步锁定的暂存文件损坏数据库。\n• 权限指示：若磁盘授权完整显示绿色“已授权”，权限受限时显示黄色“未授权”并提供一键跳转设定按钮。",
        .ja: "• 除外保護: 除外された項目はすべてのフォルダでそのまま維持され同期されないため、排他制御中のデータベース破損を防ぎます。\n• 権限表示: 完全な権限があれば緑の「認可済み」、制限があれば黄色の「未認可」と設定ジャンプボタンを表示します。",
        .th: "• การป้องกันการยกเว้น: โฟลเดอร์ที่ถูกยกเว้นจะไม่ถูกแตะต้องและไม่ถูกส่งต่อ ป้องกันฐานข้อมูลเสียหายจากการซิงค์ไฟล์ล็อก\n• ตัวบ่งชี้สิทธิ์: แสดงป้ายสีเขียว 'ได้รับอนุญาต' เมื่อมีสิทธิ์เข้าถึงดิสก์ครบถ้วน หรือสีเหลือง 'ยังไม่ได้รับอนุญาต' พร้อมปุ่มไปที่การตั้งค่า",
        .ko: "• 제외 보호: 제외된 항목은 모든 폴더에서 그대로 유지되고 전송되지 않아 사용 중인 데이터베이스 손상을 방지합니다.\n• 권한 표시: 완전한 디스크 권한이 있으면 녹색 '권한 있음', 부족하면 노란색 '권한 없음' 배지와 시스템 설정 이동 버튼을 표시합니다."
    ],
    "manual_topic_settings_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_settings_tips_desc": [
        .en: "Developers should always enable the `node_modules` exclusion switch. This saves tens of thousands of tiny files from transferring, dramatically boosting sync speed.",
        .zhHant: "寫程式的使用者強烈建議開啟 `node_modules` 排除開關，可節省數萬個碎小檔案的傳輸時間，大幅提升同步效率。",
        .zhHans: "写程序的使用者强烈建议开启 `node_modules` 排除开关，可节省数万个碎小文件的传输时间，大幅提升同步效率。",
        .ja: "開発者の方は `node_modules` 除外スイッチを有効にすることを強くお勧めします。数万個の細かなファイルの転送を回避でき、同期速度が劇的に向上します。",
        .th: "สำหรับนักพัฒนา แนะนำอย่างยิ่งให้เปิดการยกเว้น `node_modules` เพื่อประหยัดเวลาส่งไฟล์ขนาดเล็กนับหมื่นไฟล์ ช่วยให้การซิงค์เร็วขึ้นอย่างมาก",
        .ko: "개발자의 경우 `node_modules` 제외 스위치를 켜두는 것을 강력히 권장합니다. 수만 개의 자잘한 파일 전송을 건너뛰어 동기화 속도가 비약적으로 향상됩니다."
    ],
    "group_selector_title": [
        .en: "Sync Groups",
        .zhHant: "同步群組",
        .zhHans: "同步群组",
        .ja: "同期グループ",
        .th: "กลุ่มการซิงค์",
        .ko: "동기화 그룹"
    ],
    "group_add_button": [
        .en: "New Group",
        .zhHant: "新增群組",
        .zhHans: "新增群组",
        .ja: "新規グループ",
        .th: "กลุ่มใหม่",
        .ko: "새 그룹"
    ],
    "group_add_title": [
        .en: "Create Sync Group",
        .zhHant: "建立同步群組",
        .zhHans: "创建同步群组",
        .ja: "同期グループの作成",
        .th: "สร้างกลุ่มการซิงค์",
        .ko: "동기화 그룹 생성"
    ],
    "group_add_desc": [
        .en: "Sync groups allow you to keep separate sets of folders synchronized independently with isolated consensus and history.",
        .zhHant: "同步群組可讓您獨立管理不同資料夾集合，各群組擁有獨立的對帳、排程與歷史版本庫。",
        .zhHans: "同步群组可让您独立管理不同文件夹集合，各群组拥有独立的对账、排程与历史版本库。",
        .ja: "同期グループにより、異なるフォルダの組み合わせを完全に独立して同期・管理できます。",
        .th: "กลุ่มการซิงค์ช่วยให้คุณจัดการชุดโฟลเดอร์ที่แยกจากกันได้อย่างอิสระ พร้อมประวัติและการตรวจสอบที่แยกจากกัน",
        .ko: "동기화 그룹을 통해 여러 폴더 세트를 독립된 대사 엔진과 히스토리로 분리하여 관리할 수 있습니다."
    ],
    "group_edit_title": [
        .en: "Edit Sync Group",
        .zhHant: "編輯同步群組",
        .zhHans: "编辑同步群组",
        .ja: "同期グループを編集",
        .th: "แก้ไขกลุ่มการซิงค์",
        .ko: "동기화 그룹 편집"
    ],
    "group_delete_button": [
        .en: "Delete Group",
        .zhHant: "刪除群組",
        .zhHans: "删除群组",
        .ja: "グループを削除",
        .th: "ลบกลุ่ม",
        .ko: "그룹 삭제"
    ],
    "group_delete_confirm_title": [
        .en: "Delete sync group '%@'?",
        .zhHant: "確定要刪除同步群組「%@」？",
        .zhHans: "确定要删除同步群组“%@”？",
        .ja: "同期グループ「%@」を削除しますか？",
        .th: "ต้องการลบกลุ่มการซิงค์ '%@' หรือไม่?",
        .ko: "'%@' 동기화 그룹을 삭제하시겠습니까?"
    ],
    "group_delete_confirm_desc": [
        .en: "Files on all endpoints will remain intact on disk. Only sync schedules, consensus records, and metadata for this group will be removed.",
        .zhHant: "本機與各端點的實體檔案均會完整保留於磁碟中，僅移除本群組的同步排程、對帳紀錄與中繼資料。",
        .zhHans: "本机与各端点的实体文件均会完整保留于磁盘中，仅移除本群组的同步排程、对账记录与中继数据。",
        .ja: "各エンドポイントの実体ファイルはそのまま保持されます。このグループの同期スケジュールとメタデータのみが削除されます。",
        .th: "ไฟล์จริงในทุกปลายทางจะยังคงอยู่ในดิสก์ จะลบเฉพาะตารางเวลาและข้อมูลการซิงค์ของกลุ่มนี้เท่านั้น",
        .ko: "모든 엔드포인트의 실제 파일은 디스크에 그대로 유지됩니다. 이 그룹의 동기화 일정과 메타데이터만 제거됩니다."
    ],
    "group_cannot_delete_last": [
        .en: "Cannot delete the last remaining sync group.",
        .zhHant: "無法刪除最後一個同步群組。",
        .zhHans: "无法删除最后一个同步群组。",
        .ja: "最後の同期グループは削除できません。",
        .th: "ไม่สามารถลบกลุ่มการซิงค์สุดท้ายได้",
        .ko: "마지막 남은 동기화 그룹은 삭제할 수 없습니다."
    ],
    "group_name_label": [
        .en: "Group Name",
        .zhHant: "群組名稱",
        .zhHans: "群组名称",
        .ja: "グループ名",
        .th: "ชื่อกลุ่ม",
        .ko: "그룹 이름"
    ],
    "group_name_placeholder": [
        .en: "e.g. Work, Family Photos, Finance",
        .zhHant: "例如：工作專案、家庭相片、個人財務",
        .zhHans: "例如：工作项目、家庭相片、个人财务",
        .ja: "例: 仕事プロジェクト、家族写真",
        .th: "เช่น โปรเจกต์งาน, รูปครอบครัว, การเงิน",
        .ko: "예: 업무 프로젝트, 가족 사진, 재무"
    ],
    "group_icon_label": [
        .en: "Icon",
        .zhHant: "代表圖示",
        .zhHans: "代表图标",
        .ja: "アイコン",
        .th: "ไอคอน",
        .ko: "아이콘"
    ],
    "group_endpoints_count": [
        .en: "%d endpoints",
        .zhHant: "%d 個端點",
        .zhHans: "%d 个端点",
        .ja: "%d 個のエンドポイント",
        .th: "%d ปลายทาง",
        .ko: "%d개 엔드포인트"
    ],
    "group_created_toast": [
        .en: "Sync group '%@' created.",
        .zhHant: "已成功建立同步群組「%@」",
        .zhHans: "已成功建立同步群组“%@”",
        .ja: "同期グループ「%@」を作成しました。",
        .th: "สร้างกลุ่มการซิงค์ '%@' เรียบร้อยแล้ว",
        .ko: "'%@' 동기화 그룹이 생성되었습니다."
    ],
    "group_updated_toast": [
        .en: "Sync group '%@' updated.",
        .zhHant: "已更新同步群組「%@」",
        .zhHans: "已更新同步群组“%@”",
        .ja: "同期グループ「%@」を更新しました。",
        .th: "อัปเดตกลุ่มการซิงค์ '%@' เรียบร้อยแล้ว",
        .ko: "'%@' 동기화 그룹이 업데이트되었습니다."
    ],
    "import_legacy_button": [
        .en: "Import Old Settings",
        .zhHant: "匯入舊設定",
        .zhHans: "导入旧设置",
        .ja: "旧設定を読み込む",
        .th: "นำเข้าการตั้งค่าเดิม",
        .ko: "이전 설정 가져오기"
    ],
    "import_legacy_prompt": [
        .en: "Choose the old SyncNexus settings folder (the one containing groups.json and state.db), e.g. Library ▸ Application Support ▸ SyncNexus.",
        .zhHant: "請選取舊版 SyncNexus 設定資料夾（內含 groups.json 與 state.db），例如「資源庫 ▸ Application Support ▸ SyncNexus」。",
        .zhHans: "请选取旧版 SyncNexus 设置文件夹（内含 groups.json 与 state.db），例如“资源库 ▸ Application Support ▸ SyncNexus”。",
        .ja: "旧 SyncNexus の設定フォルダ（groups.json と state.db を含む）を選択してください。例：ライブラリ ▸ Application Support ▸ SyncNexus",
        .th: "เลือกโฟลเดอร์การตั้งค่า SyncNexus เดิม (ที่มี groups.json และ state.db) เช่น Library ▸ Application Support ▸ SyncNexus",
        .ko: "이전 SyncNexus 설정 폴더(groups.json과 state.db 포함)를 선택하세요. 예: 라이브러리 ▸ Application Support ▸ SyncNexus"
    ],
    "import_legacy_ok": [
        .en: "Imported %d group(s) with %d folder(s). Existing groups were not overwritten. If a folder shows offline, re-select it once to grant access.",
        .zhHant: "已匯入 %d 個群組、%d 個資料夾；既有群組不會被覆寫。若資料夾顯示離線，請重新選取一次以授權存取。",
        .zhHans: "已导入 %d 个群组、%d 个文件夹；既有群组不会被覆盖。若文件夹显示离线，请重新选取一次以授权访问。",
        .ja: "%d 個のグループ（フォルダ %d 件）を読み込みました。既存のグループは上書きされません。フォルダがオフラインの場合は、もう一度選択してアクセスを許可してください。",
        .th: "นำเข้า %d กลุ่ม %d โฟลเดอร์ กลุ่มที่มีอยู่จะไม่ถูกเขียนทับ หากโฟลเดอร์แสดงออฟไลน์ ให้เลือกใหม่หนึ่งครั้งเพื่ออนุญาตการเข้าถึง",
        .ko: "%d개 그룹(폴더 %d개)을 가져왔습니다. 기존 그룹은 덮어쓰지 않습니다. 폴더가 오프라인으로 표시되면 한 번 다시 선택해 접근을 허용하세요."
    ],
    "import_legacy_nothing_new": [
        .en: "Nothing to import: the groups in that folder are already configured here.",
        .zhHant: "沒有需要匯入的項目：該資料夾內的群組在此已設定完成。",
        .zhHans: "没有需要导入的项目：该文件夹内的群组在此已设置完成。",
        .ja: "読み込む項目がありません。そのフォルダのグループはすでに設定済みです。",
        .th: "ไม่มีรายการที่ต้องนำเข้า: กลุ่มในโฟลเดอร์นั้นถูกตั้งค่าไว้แล้ว",
        .ko: "가져올 항목이 없습니다. 해당 폴더의 그룹은 이미 설정되어 있습니다."
    ],
    "import_legacy_not_found": [
        .en: "No SyncNexus settings found in that folder (groups.json / state.db missing).",
        .zhHant: "在該資料夾中找不到 SyncNexus 設定（缺少 groups.json / state.db）。",
        .zhHans: "在该文件夹中找不到 SyncNexus 设置（缺少 groups.json / state.db）。",
        .ja: "そのフォルダに SyncNexus の設定が見つかりません（groups.json / state.db がありません）。",
        .th: "ไม่พบการตั้งค่า SyncNexus ในโฟลเดอร์นั้น (ไม่มี groups.json / state.db)",
        .ko: "해당 폴더에서 SyncNexus 설정을 찾을 수 없습니다(groups.json / state.db 없음)."
    ],
    "import_legacy_failed": [
        .en: "Import failed: %@",
        .zhHant: "匯入失敗：%@",
        .zhHans: "导入失败：%@",
        .ja: "読み込みに失敗しました：%@",
        .th: "นำเข้าไม่สำเร็จ: %@",
        .ko: "가져오기 실패: %@"
    ],
    "backup_restore_menu": [
        .en: "Restore Backup",
        .zhHant: "從備份還原",
        .zhHans: "从备份还原",
        .ja: "バックアップから復元",
        .th: "กู้คืนจากข้อมูลสำรอง",
        .ko: "백업에서 복원"
    ],
    "backup_none": [
        .en: "No backups yet",
        .zhHant: "尚無備份",
        .zhHans: "暂无备份",
        .ja: "バックアップはまだありません",
        .th: "ยังไม่มีข้อมูลสำรอง",
        .ko: "백업 없음"
    ],
    "backup_restore_button": [
        .en: "Restore",
        .zhHant: "還原",
        .zhHans: "还原",
        .ja: "復元",
        .th: "กู้คืน",
        .ko: "복원"
    ],
    "backup_restore_confirm_title": [
        .en: "Restore the backup from %@?",
        .zhHant: "要還原 %@ 的備份嗎？",
        .zhHans: "要还原 %@ 的备份吗？",
        .ja: "%@ のバックアップを復元しますか？",
        .th: "กู้คืนข้อมูลสำรองเมื่อ %@ หรือไม่?",
        .ko: "%@ 백업을 복원할까요?"
    ],
    "backup_restore_confirm_desc": [
        .en: "Groups and folder settings will return to that moment. The current state is backed up first, so you can switch back.",
        .zhHant: "群組與資料夾設定會回到當時的狀態。還原前會先備份目前狀態，之後仍可切換回來。",
        .zhHans: "群组与文件夹设置会回到当时的状态。还原前会先备份当前状态，之后仍可切换回来。",
        .ja: "グループとフォルダ設定がその時点に戻ります。復元前に現在の状態をバックアップするので、後で戻せます。",
        .th: "กลุ่มและการตั้งค่าโฟลเดอร์จะย้อนกลับไปยังขณะนั้น ระบบจะสำรองสถานะปัจจุบันก่อน จึงสามารถสลับกลับได้",
        .ko: "그룹과 폴더 설정이 해당 시점으로 돌아갑니다. 복원 전에 현재 상태를 먼저 백업하므로 다시 되돌릴 수 있습니다."
    ],
    "backup_restore_ok": [
        .en: "Restored %d group(s) with %d folder(s). If a folder shows offline, re-select it once to grant access.",
        .zhHant: "已還原 %d 個群組、%d 個資料夾。若資料夾顯示離線，請重新選取一次以授權存取。",
        .zhHans: "已还原 %d 个群组、%d 个文件夹。若文件夹显示离线，请重新选取一次以授权访问。",
        .ja: "%d 個のグループ（フォルダ %d 件）を復元しました。フォルダがオフラインの場合は、もう一度選択してアクセスを許可してください。",
        .th: "กู้คืน %d กลุ่ม %d โฟลเดอร์แล้ว หากโฟลเดอร์แสดงออฟไลน์ ให้เลือกใหม่หนึ่งครั้งเพื่ออนุญาตการเข้าถึง",
        .ko: "%d개 그룹(폴더 %d개)을 복원했습니다. 폴더가 오프라인으로 표시되면 한 번 다시 선택해 접근을 허용하세요."
    ],
    "backup_restore_stopping": [
        .en: "Safely stopping sync and any folder scan before restoring… You can cancel while waiting.",
        .zhHant: "正在安全停止同步與資料夾掃描，再開始還原⋯ 等待期間可以取消。",
        .zhHans: "正在安全停止同步与文件夹扫描，再开始还原… 等待期间可以取消。",
        .ja: "復元前に同期とフォルダースキャンを安全に停止しています… 待機中はキャンセルできます。",
        .th: "กำลังหยุดการซิงค์และการสแกนโฟลเดอร์อย่างปลอดภัยก่อนกู้คืน… ยกเลิกได้ระหว่างรอ",
        .ko: "복원 전에 동기화와 폴더 스캔을 안전하게 중지하는 중입니다… 기다리는 동안 취소할 수 있습니다."
    ],
    "backup_restore_cancelling": [
        .en: "Cancelling restore and restarting sync safely…",
        .zhHant: "正在取消還原並安全地重新啟動同步⋯",
        .zhHans: "正在取消还原并安全地重新启动同步…",
        .ja: "復元をキャンセルし、同期を安全に再起動しています…",
        .th: "กำลังยกเลิกการกู้คืนและเริ่มการซิงค์ใหม่อย่างปลอดภัย…",
        .ko: "복원을 취소하고 동기화를 안전하게 다시 시작하는 중입니다…"
    ],
    "backup_restore_cancelled": [
        .en: "Restore cancelled. Nothing was replaced.",
        .zhHant: "已取消還原，沒有替換任何資料。",
        .zhHans: "已取消还原，没有替换任何数据。",
        .ja: "復元をキャンセルしました。データは置き換えられていません。",
        .th: "ยกเลิกการกู้คืนแล้ว ไม่มีข้อมูลใดถูกแทนที่",
        .ko: "복원이 취소되었습니다. 어떤 데이터도 교체되지 않았습니다."
    ],
    "backup_restore_applying": [
        .en: "Sync stopped safely. Verifying and applying the backup…",
        .zhHant: "同步已安全停止，正在驗證並套用備份⋯",
        .zhHans: "同步已安全停止，正在验证并应用备份…",
        .ja: "同期を安全に停止しました。バックアップを検証して適用しています…",
        .th: "หยุดการซิงค์อย่างปลอดภัยแล้ว กำลังตรวจสอบและใช้ข้อมูลสำรอง…",
        .ko: "동기화가 안전하게 중지되었습니다. 백업을 확인하고 적용하는 중입니다…"
    ],
    "backup_restore_failed": [
        .en: "Restore failed: %@",
        .zhHant: "還原失敗：%@",
        .zhHans: "还原失败：%@",
        .ja: "復元に失敗しました：%@",
        .th: "กู้คืนไม่สำเร็จ: %@",
        .ko: "복원 실패: %@"
    ],
    "cloud_space_saving_title": [
        .en: "Cloud Space Saving Mode",
        .zhHant: "雲端節省空間模式",
        .zhHans: "云端节省空间模式",
        .ja: "クラウド容量節約モード",
        .th: "โหมดประหยัดพื้นที่คลาวด์",
        .ko: "클라우드 공간 절약 모드"
    ],
    "cloud_space_saving_desc": [
        .en: "After a cloud placeholder is downloaded or streamed for synchronization, ask iCloud or Google Drive to remove its local content again. The cloud copy remains available.",
        .zhHant: "雲端 placeholder 因同步而下載或串流完成後，要求 iCloud 或 Google Drive 再次移除其本機內容；雲端檔案仍會保留。",
        .zhHans: "云端 placeholder 因同步而下载或串流完成后，要求 iCloud 或 Google Drive 再次移除其本机内容；云端文件仍会保留。",
        .ja: "同期のためにダウンロードまたはストリーミングしたクラウドファイルを、完了後に iCloud または Google Drive へ再度ローカルから解放するよう依頼します。クラウド上のファイルは保持されます。",
        .th: "หลังดาวน์โหลดหรือสตรีมไฟล์คลาวด์เพื่อซิงค์แล้ว ระบบจะขอให้ iCloud หรือ Google Drive ลบเฉพาะเนื้อหาในเครื่อง โดยไฟล์บนคลาวด์ยังคงอยู่",
        .ko: "동기화를 위해 다운로드하거나 스트리밍한 클라우드 파일을 완료 후 iCloud 또는 Google Drive에 요청해 로컬 내용만 다시 제거합니다. 클라우드 파일은 유지됩니다."
    ],
    "cloud_space_saving_safety": [
        .en: "Only files that were already placeholders are released, and only after verified copies finish.",
        .zhHant: "只處理同步前原本就是 placeholder 的檔案，且必須等驗證複製完成後才釋放。",
        .zhHans: "只处理同步前原本就是 placeholder 的文件，且必须等验证复制完成后才释放。",
        .ja: "同期前からプレースホルダーだったファイルのみ、検証済みコピーの完了後に解放します。",
        .th: "ปล่อยเฉพาะไฟล์ที่เป็น placeholder อยู่ก่อนแล้ว และหลังจากยืนยันว่าคัดลอกสำเร็จเท่านั้น",
        .ko: "동기화 전부터 플레이스홀더였던 파일만 검증된 복사가 끝난 뒤 해제합니다."
    ],
    "cloud_space_saving_enabled": [
        .en: "Cloud Space Saving Mode enabled.",
        .zhHant: "已開啟雲端節省空間模式。",
        .zhHans: "已开启云端节省空间模式。",
        .ja: "クラウド容量節約モードを有効にしました。",
        .th: "เปิดโหมดประหยัดพื้นที่คลาวด์แล้ว",
        .ko: "클라우드 공간 절약 모드를 켰습니다."
    ],
    "cloud_space_saving_disabled": [
        .en: "Cloud Space Saving Mode disabled.",
        .zhHant: "已關閉雲端節省空間模式。",
        .zhHans: "已关闭云端节省空间模式。",
        .ja: "クラウド容量節約モードを無効にしました。",
        .th: "ปิดโหมดประหยัดพื้นที่คลาวด์แล้ว",
        .ko: "클라우드 공간 절약 모드를 껐습니다."
    ],
    "core_1d8b28b6": [
        .en: "Folder not found (is the external drive unmounted?)",
        .zhHant: "資料夾不存在（外接碟未掛載？）",
        .zhHans: "文件夹不存在（外接盘未挂载？）",
        .ja: "フォルダが見つかりません（外付けドライブが未接続？）",
        .th: "ไม่พบโฟลเดอร์ (ไดรฟ์ภายนอกยังไม่ได้เชื่อมต่อ?)",
        .ko: "폴더를 찾을 수 없습니다(외장 드라이브가 연결되지 않았나요?)"
    ],
    "core_0a0d5cdf": [
        .en: "Marker file does not match this endpoint (different folder or disk?). Stopped; no changes propagated.",
        .zhHant: "標記檔與此端點不符（換了另一個資料夾或磁碟？），已停止，不傳播任何變更",
        .zhHans: "标记文件与此端点不符（换了另一个文件夹或磁盘？），已停止，不传播任何变更",
        .ja: "マーカーファイルがこのエンドポイントと一致しません（別のフォルダやディスク？）。停止しました。変更は伝播しません。",
        .th: "ไฟล์มาร์กเกอร์ไม่ตรงกับปลายทางนี้ (เปลี่ยนโฟลเดอร์หรือดิสก์?) หยุดแล้ว ไม่เผยแพร่การเปลี่ยนแปลงใด ๆ",
        .ko: "마커 파일이 이 엔드포인트와 일치하지 않습니다(다른 폴더나 디스크?). 중지했으며 변경 사항을 전파하지 않습니다."
    ],
    "core_20b72caf": [
        .en: "Marker file is missing (wiped, reformatted or disk swapped?). Stopped; no deletions propagated.",
        .zhHant: "標記檔遺失（被清空、重新格式化或換碟？），已停止，不傳播任何刪除",
        .zhHans: "标记文件遗失（被清空、重新格式化或换盘？），已停止，不传播任何删除",
        .ja: "マーカーファイルがありません（消去・再フォーマット・ディスク交換？）。停止しました。削除は伝播しません。",
        .th: "ไฟล์มาร์กเกอร์หายไป (ถูกล้าง ฟอร์แมตใหม่ หรือเปลี่ยนดิสก์?) หยุดแล้ว ไม่เผยแพร่การลบใด ๆ",
        .ko: "마커 파일이 없습니다(비워짐, 재포맷 또는 디스크 교체?). 중지했으며 삭제를 전파하지 않습니다."
    ],
    "core_c4ac1bfc": [
        .en: "Volume UUID mismatch (not the original disk). Stopped.",
        .zhHant: "磁碟區 UUID 不符（不是原本那顆碟），已停止",
        .zhHans: "磁盘分区 UUID 不符（不是原本那块盘），已停止",
        .ja: "ボリューム UUID が一致しません（元のディスクではありません）。停止しました。",
        .th: "UUID ของวอลุ่มไม่ตรง (ไม่ใช่ดิสก์เดิม) หยุดแล้ว",
        .ko: "볼륨 UUID가 일치하지 않습니다(원래 디스크가 아님). 중지했습니다."
    ],
    "core_7f9cb039": [
        .en: "%@: could not be fully read; this endpoint was stopped (check file access in System Settings > Privacy & Security). %@",
        .zhHant: "%@：無法完整讀取，已停止此端點（請檢查「系統設定 > 隱私權與安全性」的檔案存取授權）。%@",
        .zhHans: "%@：无法完整读取，已停止此端点（请检查“系统设置 > 隐私与安全性”的文件访问授权）。%@",
        .ja: "%@：完全に読み取れないため、このエンドポイントを停止しました（「システム設定 > プライバシーとセキュリティ」のファイルアクセス許可を確認してください）。%@",
        .th: "%@: อ่านไม่ครบ จึงหยุดปลายทางนี้ (ตรวจสอบสิทธิ์การเข้าถึงไฟล์ใน การตั้งค่าระบบ > ความเป็นส่วนตัวและความปลอดภัย) %@",
        .ko: "%@: 완전히 읽을 수 없어 이 엔드포인트를 중지했습니다(시스템 설정 > 개인정보 보호 및 보안의 파일 접근 권한을 확인하세요). %@"
    ],
    "core_c3612616": [
        .en: "[%@] Removed leftover temp file from an interrupted run: %@",
        .zhHant: "[%@] 清除上次中斷的暫存檔 %@",
        .zhHans: "[%@] 清除上次中断的临时文件 %@",
        .ja: "[%@] 前回中断された一時ファイルを削除しました：%@",
        .th: "[%@] ลบไฟล์ชั่วคราวที่ค้างจากการหยุดครั้งก่อน %@",
        .ko: "[%@] 이전에 중단된 임시 파일 삭제: %@"
    ],
    "core_4d47d380": [
        .en: "[%@] %@: names differ only by letter case (this folder is case-sensitive, other endpoints are not). Skipped to avoid overwriting; please rename one of them.",
        .zhHant: "[%@] %@：有檔名只差大小寫的項目（此資料夾區分大小寫，其他端點不區分），為避免互相覆蓋已略過，請改名其中一個",
        .zhHans: "[%@] %@：有文件名只差大小写的项目（此文件夹区分大小写，其他端点不区分），为避免互相覆盖已略过，请改名其中一个",
        .ja: "[%@] %@：大文字・小文字だけが異なる名前があります（このフォルダは区別し、他のエンドポイントは区別しません）。上書きを避けるためスキップしました。どちらかの名前を変更してください。",
        .th: "[%@] %@: มีชื่อที่ต่างกันแค่ตัวพิมพ์เล็ก/ใหญ่ (โฟลเดอร์นี้แยกตัวพิมพ์ ปลายทางอื่นไม่แยก) ข้ามเพื่อป้องกันการเขียนทับ โปรดเปลี่ยนชื่อรายการใดรายการหนึ่ง",
        .ko: "[%@] %@: 대소문자만 다른 이름이 있습니다(이 폴더는 대소문자를 구분하고 다른 엔드포인트는 구분하지 않음). 덮어쓰기를 막기 위해 건너뛰었으니 하나의 이름을 바꾸세요."
    ],
    "core_89127a86": [
        .en: "Case-only name conflict; not handled for now",
        .zhHant: "大小寫衝突，暫不處理",
        .zhHans: "大小写冲突，暂不处理",
        .ja: "大文字・小文字の名前衝突のため、今回は処理しません",
        .th: "ชื่อซ้ำกันแค่ตัวพิมพ์เล็ก/ใหญ่ ยังไม่ดำเนินการ",
        .ko: "대소문자 이름 충돌로 지금은 처리하지 않습니다"
    ],
    "core_0c76f3e1": [
        .en: "Still being written (settling window)",
        .zhHant: "仍在寫入（穩定窗口）",
        .zhHans: "仍在写入（稳定窗口）",
        .ja: "書き込み中（安定待ち）",
        .th: "ยังเขียนอยู่ (รอให้คงที่)",
        .ko: "아직 쓰는 중(안정화 대기)"
    ],
    "core_6408f58b": [
        .en: "Content differs from the record but modified time and size are unchanged (possible corruption). Skipped and not propagated; other endpoints still hold the correct version.",
        .zhHant: "內容與紀錄不符，但修改時間與大小沒變（疑似損壞）。已略過，不會傳播；其他端點仍持有正確版本",
        .zhHans: "内容与记录不符，但修改时间与大小没变（疑似损坏）。已略过，不会传播；其他端点仍持有正确版本",
        .ja: "内容が記録と一致しませんが、更新日時とサイズは変わっていません（破損の疑い）。スキップし、伝播しません。他のエンドポイントに正しい版があります。",
        .th: "เนื้อหาไม่ตรงกับบันทึก แต่เวลาแก้ไขและขนาดไม่เปลี่ยน (สงสัยว่าเสียหาย) ข้ามและไม่เผยแพร่ ปลายทางอื่นยังมีเวอร์ชันที่ถูกต้อง",
        .ko: "내용이 기록과 다르지만 수정 시간과 크기는 그대로입니다(손상 의심). 건너뛰며 전파하지 않습니다. 다른 엔드포인트에 올바른 버전이 있습니다."
    ],
    "core_f622f208": [
        .en: "Cloud file %@ exceeds the auto-download limit; please download it manually in Finder",
        .zhHant: "雲端檔案 %@ 超過自動下載上限，請在 Finder 手動下載",
        .zhHans: "云端文件 %@ 超过自动下载上限，请在 Finder 手动下载",
        .ja: "クラウドファイル %@ は自動ダウンロードの上限を超えています。Finder で手動ダウンロードしてください",
        .th: "ไฟล์บนคลาวด์ %@ เกินขีดจำกัดการดาวน์โหลดอัตโนมัติ โปรดดาวน์โหลดเองใน Finder",
        .ko: "클라우드 파일 %@ 이(가) 자동 다운로드 한도를 초과했습니다. Finder에서 직접 다운로드하세요"
    ],
    "core_204d7ddf": [
        .en: "Not enough free disk space to download the cloud file",
        .zhHant: "磁碟可用空間不足，無法下載雲端檔案",
        .zhHans: "磁盘可用空间不足，无法下载云端文件",
        .ja: "ディスクの空き容量が不足しているため、クラウドファイルをダウンロードできません",
        .th: "พื้นที่ว่างบนดิสก์ไม่พอสำหรับดาวน์โหลดไฟล์คลาวด์",
        .ko: "디스크 여유 공간이 부족하여 클라우드 파일을 다운로드할 수 없습니다"
    ],
    "core_047f9d72": [
        .en: "Reading the cloud file; will continue automatically when done",
        .zhHant: "正在讀取雲端檔案內容，完成後自動繼續",
        .zhHans: "正在读取云端文件内容，完成后自动继续",
        .ja: "クラウドファイルを読み込み中です。完了後に自動で続行します",
        .th: "กำลังอ่านไฟล์จากคลาวด์ เสร็จแล้วจะดำเนินการต่ออัตโนมัติ",
        .ko: "클라우드 파일을 읽는 중입니다. 완료되면 자동으로 계속합니다"
    ],
    "core_d2cbf424": [
        .en: "%@ operation(s) were interrupted last time and have been safely re-evaluated (every action is idempotent)",
        .zhHant: "上次有 %@ 個操作中斷，已安全重新評估（每個動作皆冪等）",
        .zhHans: "上次有 %@ 个操作中断，已安全重新评估（每个动作皆幂等）",
        .ja: "前回 %@ 件の操作が中断されましたが、安全に再評価しました（各操作は冪等です）",
        .th: "ครั้งก่อนมี %@ การดำเนินการที่ถูกขัดจังหวะ ประเมินใหม่อย่างปลอดภัยแล้ว (ทุกการกระทำทำซ้ำได้อย่างปลอดภัย)",
        .ko: "지난번에 %@개 작업이 중단되어 안전하게 다시 평가했습니다(모든 작업은 멱등)"
    ],
    "core_6c48da56": [
        .en: "First sync: the changes below have not been applied. Please review the preview before running.",
        .zhHant: "首次同步：以下變更尚未執行，請確認預覽後再執行",
        .zhHans: "首次同步：以下变更尚未执行，请确认预览后再执行",
        .ja: "初回同期：以下の変更はまだ実行されていません。プレビューを確認してから実行してください",
        .th: "ซิงค์ครั้งแรก: การเปลี่ยนแปลงด้านล่างยังไม่ถูกดำเนินการ โปรดตรวจสอบตัวอย่างก่อนดำเนินการ",
        .ko: "첫 동기화: 아래 변경 사항은 아직 실행되지 않았습니다. 미리보기를 확인한 후 실행하세요"
    ],
    "core_3648c710": [
        .en: "New endpoint(s) (%@) added for the first time: the changes below have not been applied. Please review the preview before running.",
        .zhHant: "新端點（%@）首次加入：以下變更尚未執行，請確認預覽後再執行",
        .zhHans: "新端点（%@）首次加入：以下变更尚未执行，请确认预览后再执行",
        .ja: "新しいエンドポイント（%@）を初めて追加：以下の変更はまだ実行されていません。プレビューを確認してから実行してください",
        .th: "เพิ่มปลายทางใหม่ (%@) ครั้งแรก: การเปลี่ยนแปลงด้านล่างยังไม่ถูกดำเนินการ โปรดตรวจสอบตัวอย่างก่อนดำเนินการ",
        .ko: "새 엔드포인트(%@) 첫 추가: 아래 변경 사항은 아직 실행되지 않았습니다. 미리보기를 확인한 후 실행하세요"
    ],
    "core_f9669ea2": [
        .en: "\"%@\": %@ tracked files, %@ vanished at once (more than half). This may be an accidental deletion or a disk/folder problem. Confirm before continuing; the deletions will then propagate to other endpoints (old versions are saved first, and the Trash is used).",
        .zhHant: "「%@」的 %@ 個檔案中有 %@ 個同時消失（一半以上）。這可能是誤刪、磁碟或資料夾異常，請確認後再執行；確認後會把這些刪除傳到其他端點（先存入舊版本與垃圾桶）",
        .zhHans: "“%@”的 %@ 个文件中有 %@ 个同时消失（一半以上）。这可能是误删、磁盘或文件夹异常，请确认后再执行；确认后会把这些删除传到其他端点（先存入旧版本与废纸篓）",
        .ja: "「%@」の %@ 件のうち %@ 件が同時に消えました（半数以上）。誤削除やディスク・フォルダの異常の可能性があります。確認後に実行してください。確認すると削除は他のエンドポイントに伝播します（旧バージョンとゴミ箱に先に保存されます）。",
        .th: "“%@”: ไฟล์ที่ติดตาม %@ ไฟล์ หายไปพร้อมกัน %@ ไฟล์ (เกินครึ่ง) อาจเป็นการลบโดยไม่ตั้งใจ หรือดิสก์/โฟลเดอร์ผิดปกติ โปรดยืนยันก่อนดำเนินการ เมื่อยืนยันแล้วการลบจะส่งต่อไปยังปลายทางอื่น (บันทึกเวอร์ชันเก่าและใช้ถังขยะก่อน)",
        .ko: "“%@”: 추적 중인 %@개 파일 중 %@개가 동시에 사라졌습니다(절반 이상). 실수로 삭제했거나 디스크/폴더 이상일 수 있습니다. 확인 후 실행하세요. 확인하면 삭제가 다른 엔드포인트로 전파됩니다(이전 버전과 휴지통에 먼저 보관)."
    ],
    "core_01d4f55b": [
        .en: "About to delete %@ files (of %@ tracked), over the safety threshold. Please confirm before running.",
        .zhHant: "預計刪除 %@ 個檔案（共追蹤 %@ 個），超過安全門檻，請確認後再執行",
        .zhHans: "预计删除 %@ 个文件（共追踪 %@ 个），超过安全门槛，请确认后再执行",
        .ja: "%@ 件のファイルを削除する予定です（追跡中 %@ 件）。安全しきい値を超えています。確認してから実行してください",
        .th: "จะลบ %@ ไฟล์ (จากที่ติดตาม %@ ไฟล์) เกินเกณฑ์ความปลอดภัย โปรดยืนยันก่อนดำเนินการ",
        .ko: "%@개 파일을 삭제할 예정입니다(추적 중 %@개). 안전 임계값을 초과했습니다. 확인 후 실행하세요"
    ],
    "core_b7698c00": [
        .en: "[%@] Rename %@ → %@ (other endpoints rename directly, no re-transfer)",
        .zhHant: "[%@] 重新命名 %@ → %@（其他端點直接改名，不重新傳輸）",
        .zhHans: "[%@] 重新命名 %@ → %@（其他端点直接改名，不重新传输）",
        .ja: "[%@] 名前変更 %@ → %@（他のエンドポイントは名前だけ変更し、再転送しません）",
        .th: "[%@] เปลี่ยนชื่อ %@ → %@ (ปลายทางอื่นเปลี่ยนชื่อโดยตรง ไม่ส่งซ้ำ)",
        .ko: "[%@] 이름 변경 %@ → %@(다른 엔드포인트는 바로 이름만 변경하며 다시 전송하지 않음)"
    ],
    "core_9e8295c8": [
        .en: "[%@] Delete folder %@ (copies on %@ other endpoint(s) will be removed)",
        .zhHant: "[%@] 刪除資料夾 %@（將移除其他 %@ 端的副本）",
        .zhHans: "[%@] 删除文件夹 %@（将移除其他 %@ 端的副本）",
        .ja: "[%@] フォルダ削除 %@（他の %@ 台のコピーを削除します）",
        .th: "[%@] ลบโฟลเดอร์ %@ (จะลบสำเนาในปลายทางอื่น %@ แห่ง)",
        .ko: "[%@] 폴더 삭제 %@(다른 %@곳의 사본이 제거됨)"
    ],
    "core_0ab23570": [
        .en: "[%@] Delete %@ (copies on %@ other endpoint(s) will be removed)",
        .zhHant: "[%@] 刪除%@（將移除其他 %@ 端的副本）",
        .zhHans: "[%@] 删除%@（将移除其他 %@ 端的副本）",
        .ja: "[%@] 削除 %@（他の %@ 台のコピーを削除します）",
        .th: "[%@] ลบ %@ (จะลบสำเนาในปลายทางอื่น %@ แห่ง)",
        .ko: "[%@] 삭제 %@(다른 %@곳의 사본이 제거됨)"
    ],
    "core_e6d97e5a": [
        .en: "[%@] Add/modify folder %@ → other endpoints",
        .zhHant: "[%@] 新增/修改資料夾 %@ → 其他端點",
        .zhHans: "[%@] 新增/修改文件夹 %@ → 其他端点",
        .ja: "[%@] フォルダ追加/変更 %@ → 他のエンドポイント",
        .th: "[%@] เพิ่ม/แก้ไขโฟลเดอร์ %@ → ปลายทางอื่น",
        .ko: "[%@] 폴더 추가/수정 %@ → 다른 엔드포인트"
    ],
    "core_bb244601": [
        .en: "[%@] Add/modify %@ → other endpoints",
        .zhHant: "[%@] 新增/修改%@ → 其他端點",
        .zhHans: "[%@] 新增/修改%@ → 其他端点",
        .ja: "[%@] 追加/変更 %@ → 他のエンドポイント",
        .th: "[%@] เพิ่ม/แก้ไข %@ → ปลายทางอื่น",
        .ko: "[%@] 추가/수정 %@ → 다른 엔드포인트"
    ],
    "core_a31c5e3c": [
        .en: "[%@] Move to Trash: folder %@",
        .zhHant: "[%@] 移到垃圾桶 資料夾 %@",
        .zhHans: "[%@] 移到废纸篓 文件夹 %@",
        .ja: "[%@] ゴミ箱へ移動：フォルダ %@",
        .th: "[%@] ย้ายไปถังขยะ: โฟลเดอร์ %@",
        .ko: "[%@] 휴지통으로 이동: 폴더 %@"
    ],
    "core_c9c31b9c": [
        .en: "[%@] Move to Trash: %@",
        .zhHant: "[%@] 移到垃圾桶 %@",
        .zhHans: "[%@] 移到废纸篓 %@",
        .ja: "[%@] ゴミ箱へ移動：%@",
        .th: "[%@] ย้ายไปถังขยะ: %@",
        .ko: "[%@] 휴지통으로 이동: %@"
    ],
    "core_5cf0e9fc": [
        .en: "[%@] Receive folder %@",
        .zhHant: "[%@] 取得資料夾 %@",
        .zhHans: "[%@] 取得文件夹 %@",
        .ja: "[%@] フォルダ取得 %@",
        .th: "[%@] รับโฟลเดอร์ %@",
        .ko: "[%@] 폴더 받기 %@"
    ],
    "core_faabaa75": [
        .en: "[%@] Receive %@",
        .zhHant: "[%@] 取得%@",
        .zhHans: "[%@] 取得 %@",
        .ja: "[%@] 取得 %@",
        .th: "[%@] รับ %@",
        .ko: "[%@] 받기 %@"
    ],
    "core_dffe71f9": [
        .en: "[%@] Conflict %@",
        .zhHant: "[%@] 衝突 %@",
        .zhHans: "[%@] 冲突 %@",
        .ja: "[%@] 競合 %@",
        .th: "[%@] ขัดแย้ง %@",
        .ko: "[%@] 충돌 %@"
    ],
    "core_f66782fe": [
        .en: "[%@] %@: operation failed, will retry later (%@)",
        .zhHant: "[%@] %@：操作失敗，稍後重試（%@）",
        .zhHans: "[%@] %@：操作失败，稍后重试（%@）",
        .ja: "[%@] %@：操作に失敗しました。後で再試行します（%@）",
        .th: "[%@] %@: ดำเนินการไม่สำเร็จ จะลองใหม่ภายหลัง (%@)",
        .ko: "[%@] %@: 작업 실패, 나중에 다시 시도합니다(%@)"
    ],
    "core_7ee49c40": [
        .en: "[%@] %@: failed to delete folder, will retry later (%@)",
        .zhHant: "[%@] %@：刪除資料夾失敗，稍後重試（%@）",
        .zhHans: "[%@] %@：删除文件夹失败，稍后重试（%@）",
        .ja: "[%@] %@：フォルダの削除に失敗しました。後で再試行します（%@）",
        .th: "[%@] %@: ลบโฟลเดอร์ไม่สำเร็จ จะลองใหม่ภายหลัง (%@)",
        .ko: "[%@] %@: 폴더 삭제 실패, 나중에 다시 시도합니다(%@)"
    ],
    "core_43e9994c": [
        .en: "[%@] %@: the folder still contains unsynced items; not deleting for now",
        .zhHant: "[%@] %@：資料夾內還有尚未同步的項目，暫不刪除",
        .zhHans: "[%@] %@：文件夹内还有尚未同步的项目，暂不删除",
        .ja: "[%@] %@：フォルダ内に未同期の項目があるため、今回は削除しません",
        .th: "[%@] %@: ในโฟลเดอร์ยังมีรายการที่ยังไม่ซิงค์ ยังไม่ลบ",
        .ko: "[%@] %@: 폴더에 아직 동기화되지 않은 항목이 있어 지금은 삭제하지 않습니다"
    ],
    "core_7bfbbddd": [
        .en: "[%@] Move to Trash (folder) %@",
        .zhHant: "[%@] 移到垃圾桶（資料夾）%@",
        .zhHans: "[%@] 移到废纸篓（文件夹）%@",
        .ja: "[%@] ゴミ箱へ移動（フォルダ）%@",
        .th: "[%@] ย้ายไปถังขยะ (โฟลเดอร์) %@",
        .ko: "[%@] 휴지통으로 이동(폴더) %@"
    ],
    "core_fc8ca0de": [
        .en: "[%@] Detected rename %@ → %@",
        .zhHant: "[%@] 偵測到重新命名 %@ → %@",
        .zhHans: "[%@] 检测到重新命名 %@ → %@",
        .ja: "[%@] 名前の変更を検出 %@ → %@",
        .th: "[%@] ตรวจพบการเปลี่ยนชื่อ %@ → %@",
        .ko: "[%@] 이름 변경 감지 %@ → %@"
    ],
    "core_c667a3e7": [
        .en: "[%@] %@ → %@: rename failed, falling back to the normal flow (%@)",
        .zhHant: "[%@] %@ → %@：改名失敗，改用一般流程（%@）",
        .zhHans: "[%@] %@ → %@：改名失败，改用一般流程（%@）",
        .ja: "[%@] %@ → %@：名前変更に失敗したため通常の手順に切り替えます（%@）",
        .th: "[%@] %@ → %@: เปลี่ยนชื่อไม่สำเร็จ ใช้ขั้นตอนปกติแทน (%@)",
        .ko: "[%@] %@ → %@: 이름 변경 실패, 일반 절차로 전환합니다(%@)"
    ],
    "core_3d2b0ca6": [
        .en: "[%@] Rename %@ → %@ (not re-transferred)",
        .zhHant: "[%@] 改名 %@ → %@（未重新傳輸）",
        .zhHans: "[%@] 改名 %@ → %@（未重新传输）",
        .ja: "[%@] 名前変更 %@ → %@（再転送なし）",
        .th: "[%@] เปลี่ยนชื่อ %@ → %@ (ไม่ส่งซ้ำ)",
        .ko: "[%@] 이름 변경 %@ → %@(다시 전송하지 않음)"
    ],
    "core_28ac2331": [
        .en: "[%@] Deletion detected %@",
        .zhHant: "[%@] 偵測到刪除 %@",
        .zhHans: "[%@] 检测到删除 %@",
        .ja: "[%@] 削除を検出 %@",
        .th: "[%@] ตรวจพบการลบ %@",
        .ko: "[%@] 삭제 감지 %@"
    ],
    "core_c630a4b5": [
        .en: "[%@] Change detected %@",
        .zhHant: "[%@] 偵測到變更 %@",
        .zhHans: "[%@] 检测到变更 %@",
        .ja: "[%@] 変更を検出 %@",
        .th: "[%@] ตรวจพบการเปลี่ยนแปลง %@",
        .ko: "[%@] 변경 감지 %@"
    ],
    "core_01fbb1cb": [
        .en: "Name not compatible with exFAT/Windows: %@",
        .zhHant: "檔名不相容 exFAT/Windows %@",
        .zhHans: "文件名不兼容 exFAT/Windows %@",
        .ja: "exFAT/Windows 非互換のファイル名 %@",
        .th: "ชื่อไฟล์ไม่เข้ากันกับ exFAT/Windows %@",
        .ko: "exFAT/Windows와 호환되지 않는 파일 이름 %@"
    ],
    "core_02a600b1": [
        .en: "[%@] %@: this side is a file but other endpoints have a folder (type conflict); please handle manually",
        .zhHant: "[%@] %@：本端是檔案、其他端點是資料夾（類型衝突），請手動處理",
        .zhHans: "[%@] %@：本端是文件、其他端点是文件夹（类型冲突），请手动处理",
        .ja: "[%@] %@：こちらはファイル、他のエンドポイントはフォルダです（種類の衝突）。手動で対処してください",
        .th: "[%@] %@: ฝั่งนี้เป็นไฟล์ แต่ปลายทางอื่นเป็นโฟลเดอร์ (ชนิดขัดแย้ง) โปรดจัดการด้วยตนเอง",
        .ko: "[%@] %@: 이쪽은 파일이고 다른 엔드포인트는 폴더입니다(유형 충돌). 직접 처리하세요"
    ],
    "core_678aac1e": [
        .en: "[%@] Create folder %@",
        .zhHant: "[%@] 建立資料夾 %@",
        .zhHans: "[%@] 建立文件夹 %@",
        .ja: "[%@] フォルダ作成 %@",
        .th: "[%@] สร้างโฟลเดอร์ %@",
        .ko: "[%@] 폴더 생성 %@"
    ],
    "core_99a54234": [
        .en: "[%@] %@: this side is a folder but other endpoints have a file (type conflict); please handle manually",
        .zhHant: "[%@] %@：本端是資料夾、其他端點是檔案（類型衝突），請手動處理",
        .zhHans: "[%@] %@：本端是文件夹、其他端点是文件（类型冲突），请手动处理",
        .ja: "[%@] %@：こちらはフォルダ、他のエンドポイントはファイルです（種類の衝突）。手動で対処してください",
        .th: "[%@] %@: ฝั่งนี้เป็นโฟลเดอร์ แต่ปลายทางอื่นเป็นไฟล์ (ชนิดขัดแย้ง) โปรดจัดการด้วยตนเอง",
        .ko: "[%@] %@: 이쪽은 폴더이고 다른 엔드포인트는 파일입니다(유형 충돌). 직접 처리하세요"
    ],
    "core_b03f08dc": [
        .en: "[%@] %@: the file changed again before deletion; cancelled and will be re-evaluated next round",
        .zhHant: "[%@] %@：刪除前發現檔案又被改動，已取消，下一輪重新評估",
        .zhHans: "[%@] %@：删除前发现文件又被改动，已取消，下一轮重新评估",
        .ja: "[%@] %@：削除前にファイルが再度変更されたため中止しました。次回再評価します",
        .th: "[%@] %@: พบว่าไฟล์ถูกแก้ไขอีกก่อนลบ ยกเลิกแล้ว จะประเมินใหม่รอบถัดไป",
        .ko: "[%@] %@: 삭제 전에 파일이 다시 변경되어 취소했습니다. 다음 라운드에서 다시 평가합니다"
    ],
    "core_ba9334ce": [
        .en: "[%@] %@: no online endpoint currently holds this version; will retry later",
        .zhHant: "[%@] %@：目前沒有在線端點持有此版本內容，稍後重試",
        .zhHans: "[%@] %@：目前没有在线端点持有此版本内容，稍后重试",
        .ja: "[%@] %@：この版を持つオンラインのエンドポイントがありません。後で再試行します",
        .th: "[%@] %@: ขณะนี้ไม่มีปลายทางออนไลน์ที่มีเวอร์ชันนี้ จะลองใหม่ภายหลัง",
        .ko: "[%@] %@: 이 버전을 가진 온라인 엔드포인트가 없습니다. 나중에 다시 시도합니다"
    ],
    "core_3f0021e2": [
        .en: "[%@] %@: the target changed during preparation; will be re-evaluated next round",
        .zhHant: "[%@] %@：目標在準備期間被改動，下一輪重新評估",
        .zhHans: "[%@] %@：目标在准备期间被改动，下一轮重新评估",
        .ja: "[%@] %@：準備中に対象が変更されました。次回再評価します",
        .th: "[%@] %@: เป้าหมายถูกแก้ไขระหว่างเตรียมการ จะประเมินใหม่รอบถัดไป",
        .ko: "[%@] %@: 준비 중에 대상이 변경되었습니다. 다음 라운드에서 다시 평가합니다"
    ],
    "core_4b60acfc": [
        .en: "[%@] %@: failed %@ time(s) before; will retry automatically later",
        .zhHant: "[%@] %@：先前失敗 %@ 次，稍後自動重試",
        .zhHans: "[%@] %@：先前失败 %@ 次，稍后自动重试",
        .ja: "[%@] %@：これまでに %@ 回失敗しました。後で自動的に再試行します",
        .th: "[%@] %@: ก่อนหน้านี้ล้มเหลว %@ ครั้ง จะลองใหม่อัตโนมัติภายหลัง",
        .ko: "[%@] %@: 이전에 %@회 실패했습니다. 나중에 자동으로 다시 시도합니다"
    ],
    "core_6b48954a": [
        .en: "[%@] %@: not enough free disk space (needs %@)",
        .zhHant: "[%@] %@：磁碟可用空間不足（需要 %@）",
        .zhHans: "[%@] %@：磁盘可用空间不足（需要 %@）",
        .ja: "[%@] %@：ディスクの空き容量が不足しています（必要 %@）",
        .th: "[%@] %@: พื้นที่ว่างบนดิสก์ไม่พอ (ต้องการ %@)",
        .ko: "[%@] %@: 디스크 여유 공간이 부족합니다(필요 %@)"
    ],
    "core_322d0412": [
        .en: "[%@] %@: the source changed while copying; will retry later",
        .zhHant: "[%@] %@：來源在複製途中改變，稍後重試",
        .zhHans: "[%@] %@：来源在复制途中改变，稍后重试",
        .ja: "[%@] %@：コピー中に元ファイルが変更されました。後で再試行します",
        .th: "[%@] %@: ต้นทางเปลี่ยนระหว่างคัดลอก จะลองใหม่ภายหลัง",
        .ko: "[%@] %@: 복사 중에 원본이 변경되었습니다. 나중에 다시 시도합니다"
    ],
    "core_690da681": [
        .en: "[%@] %@: copy failed %@",
        .zhHant: "[%@] %@：複製失敗 %@",
        .zhHans: "[%@] %@：复制失败 %@",
        .ja: "[%@] %@：コピーに失敗しました %@",
        .th: "[%@] %@: คัดลอกไม่สำเร็จ %@",
        .ko: "[%@] %@: 복사 실패 %@"
    ],
    "core_faed6561": [
        .en: "[%@] Write %@",
        .zhHant: "[%@] 寫入 %@",
        .zhHans: "[%@] 写入 %@",
        .ja: "[%@] 書き込み %@",
        .th: "[%@] เขียน %@",
        .ko: "[%@] 쓰기 %@"
    ],
    "core_12977450": [
        .en: "[%@] %@: file/folder type conflict; please handle manually",
        .zhHant: "[%@] %@：檔案與資料夾的類型衝突，請手動處理",
        .zhHans: "[%@] %@：文件与文件夹的类型冲突，请手动处理",
        .ja: "[%@] %@：ファイルとフォルダの種類が衝突しています。手動で対処してください",
        .th: "[%@] %@: ชนิดไฟล์/โฟลเดอร์ขัดแย้งกัน โปรดจัดการด้วยตนเอง",
        .ko: "[%@] %@: 파일/폴더 유형이 충돌합니다. 직접 처리하세요"
    ],
    "core_b277c322": [
        .en: "[%@] %@: conflict, but no online endpoint currently holds the other version; will retry later",
        .zhHant: "[%@] %@：衝突，但目前沒有在線端點持有對方版本，稍後重試",
        .zhHans: "[%@] %@：冲突，但目前没有在线端点持有对方版本，稍后重试",
        .ja: "[%@] %@：競合していますが、相手の版を持つオンラインのエンドポイントがありません。後で再試行します",
        .th: "[%@] %@: ขัดแย้ง แต่ขณะนี้ไม่มีปลายทางออนไลน์ที่มีเวอร์ชันอีกฝั่ง จะลองใหม่ภายหลัง",
        .ko: "[%@] %@: 충돌했지만 상대 버전을 가진 온라인 엔드포인트가 없습니다. 나중에 다시 시도합니다"
    ],
    "core_8b68f393": [
        .en: "[%@] Conflict %@: this side is newer and was adopted; the older copies on other endpoints are saved to Versions",
        .zhHant: "[%@] 衝突 %@：本端版本較新，採用；其他端點的舊版會存入 Versions",
        .zhHans: "[%@] 冲突 %@：本端版本较新，采用；其他端点的旧版会存入 Versions",
        .ja: "[%@] 競合 %@：こちらの版が新しいため採用しました。他のエンドポイントの旧版は Versions に保存されます",
        .th: "[%@] ขัดแย้ง %@: ฝั่งนี้ใหม่กว่า จึงใช้ฝั่งนี้ เวอร์ชันเก่าของปลายทางอื่นจะถูกเก็บใน Versions",
        .ko: "[%@] 충돌 %@: 이쪽 버전이 더 최신이어서 채택했습니다. 다른 엔드포인트의 이전 버전은 Versions에 보관됩니다"
    ],
    "core_fbef8e4e": [
        .en: "[%@] Conflict %@: the other endpoint is newer and was adopted; this side's older copy was saved to Versions",
        .zhHant: "[%@] 衝突 %@：其他端點版本較新，採用；本端舊版已存入 Versions",
        .zhHans: "[%@] 冲突 %@：其他端点版本较新，采用；本端旧版已存入 Versions",
        .ja: "[%@] 競合 %@：他のエンドポイントの版が新しいため採用しました。こちらの旧版は Versions に保存しました",
        .th: "[%@] ขัดแย้ง %@: ปลายทางอื่นใหม่กว่า จึงใช้ฝั่งนั้น เวอร์ชันเก่าของฝั่งนี้ถูกเก็บใน Versions แล้ว",
        .ko: "[%@] 충돌 %@: 다른 엔드포인트 버전이 더 최신이어서 채택했습니다. 이쪽의 이전 버전은 Versions에 보관했습니다"
    ],
    "core_1549dd38": [
        .en: "[%@] %@: the file changed again before conflict handling; will be re-evaluated next round",
        .zhHant: "[%@] %@：處理衝突前發現檔案又被改動，下一輪重新評估",
        .zhHans: "[%@] %@：处理冲突前发现文件又被改动，下一轮重新评估",
        .ja: "[%@] %@：競合の処理前にファイルが再度変更されました。次回再評価します",
        .th: "[%@] %@: พบว่าไฟล์ถูกแก้ไขอีกก่อนจัดการความขัดแย้ง จะประเมินใหม่รอบถัดไป",
        .ko: "[%@] %@: 충돌 처리 전에 파일이 다시 변경되었습니다. 다음 라운드에서 다시 평가합니다"
    ],
    "core_9b72296c": [
        .en: "[%@] Conflict %@: this side's version was kept as \"%@\" and stays only on this endpoint",
        .zhHant: "[%@] 衝突 %@：本端版本保留為「%@」，只留在此端點",
        .zhHans: "[%@] 冲突 %@：本端版本保留为“%@”，只留在此端点",
        .ja: "[%@] 競合 %@：こちらの版は「%@」として保存し、このエンドポイントだけに残します",
        .th: "[%@] ขัดแย้ง %@: เก็บเวอร์ชันฝั่งนี้เป็น “%@” และอยู่เฉพาะปลายทางนี้",
        .ko: "[%@] 충돌 %@: 이쪽 버전을 “%@”(으)로 보관하며 이 엔드포인트에만 남습니다"
    ],
    "core_e83ee66c": [
        .en: "Endpoint \"%@\" no longer exists",
        .zhHant: "端點「%@」已不存在",
        .zhHans: "端点“%@”已不存在",
        .ja: "エンドポイント「%@」は存在しません",
        .th: "ไม่มีปลายทาง “%@” อีกแล้ว",
        .ko: "엔드포인트 “%@”이(가) 더 이상 없습니다"
    ],
    "core_faf05069": [
        .en: "Endpoint \"%@\" is offline: %@",
        .zhHant: "端點「%@」目前離線：%@",
        .zhHans: "端点“%@”目前离线：%@",
        .ja: "エンドポイント「%@」は現在オフラインです：%@",
        .th: "ปลายทาง “%@” ออฟไลน์อยู่: %@",
        .ko: "엔드포인트 “%@”은(는) 현재 오프라인입니다: %@"
    ],
    "core_952ff37f": [
        .en: "The file no longer exists",
        .zhHant: "檔案已不存在",
        .zhHans: "文件已不存在",
        .ja: "ファイルはもう存在しません",
        .th: "ไม่มีไฟล์นี้อีกแล้ว",
        .ko: "파일이 더 이상 없습니다"
    ],
    "core_48ff31a6": [
        .en: "The group no longer has a correct version of this file",
        .zhHant: "群組裡已沒有這個檔案的正確版本",
        .zhHans: "群组里已没有这个文件的正确版本",
        .ja: "グループにこのファイルの正しい版がありません",
        .th: "กลุ่มไม่มีเวอร์ชันที่ถูกต้องของไฟล์นี้แล้ว",
        .ko: "그룹에 이 파일의 올바른 버전이 더 이상 없습니다"
    ],
    "core_33239fda": [
        .en: "No other online folder holds the correct version",
        .zhHant: "目前沒有其他在線的資料夾持有正確版本",
        .zhHans: "目前没有其他在线的文件夹持有正确版本",
        .ja: "正しい版を持つ他のオンラインフォルダがありません",
        .th: "ขณะนี้ไม่มีโฟลเดอร์ออนไลน์อื่นที่มีเวอร์ชันที่ถูกต้อง",
        .ko: "올바른 버전을 가진 다른 온라인 폴더가 없습니다"
    ],
    "core_16259d1d": [
        .en: "Conflict record not found",
        .zhHant: "找不到這個衝突紀錄",
        .zhHans: "找不到这个冲突记录",
        .ja: "この競合の記録が見つかりません",
        .th: "ไม่พบบันทึกความขัดแย้งนี้",
        .ko: "이 충돌 기록을 찾을 수 없습니다"
    ],
    "core_f080ce5c": [
        .en: "Please enter an endpoint name",
        .zhHant: "請輸入端點名稱",
        .zhHans: "请输入端点名称",
        .ja: "エンドポイント名を入力してください",
        .th: "โปรดป้อนชื่อปลายทาง",
        .ko: "엔드포인트 이름을 입력하세요"
    ],
    "core_6a78154c": [
        .en: "An endpoint named \"%@\" already exists",
        .zhHant: "已有同名端點「%@」",
        .zhHans: "已有同名端点“%@”",
        .ja: "「%@」という名前のエンドポイントが既にあります",
        .th: "มีปลายทางชื่อ “%@” อยู่แล้ว",
        .ko: "“%@” 이름의 엔드포인트가 이미 있습니다"
    ],
    "core_ba9d0632": [
        .en: "The name cannot contain / \\ : * ? \" < > | (it appears in conflict file names)",
        .zhHant: "名稱不可含 / \\ : * ? \" < > | 等字元（會出現在衝突檔名裡）",
        .zhHans: "名称不可含 / \\ : * ? \" < > | 等字符（会出现在冲突文件名里）",
        .ja: "名前に / \\ : * ? \" < > | などの文字は使えません（競合ファイル名に使われます）",
        .th: "ชื่อห้ามมีอักขระ / \\ : * ? \" < > | (จะปรากฏในชื่อไฟล์ที่ขัดแย้ง)",
        .ko: "이름에는 / \\ : * ? \" < > | 등의 문자를 쓸 수 없습니다(충돌 파일 이름에 표시됨)"
    ],
    "core_56573965": [
        .en: "Folder not found",
        .zhHant: "找不到這個資料夾",
        .zhHans: "找不到这个文件夹",
        .ja: "フォルダが見つかりません",
        .th: "ไม่พบโฟลเดอร์นี้",
        .ko: "폴더를 찾을 수 없습니다"
    ],
    "core_4ad238ca": [
        .en: "Too broad. Choose a dedicated subfolder (not your home folder, a system folder or a whole disk).",
        .zhHant: "範圍太大，請選擇專用的子資料夾（不要選家目錄、系統資料夾或整個磁碟）",
        .zhHans: "范围太大，请选择专用的子文件夹（不要选主目录、系统文件夹或整个磁盘）",
        .ja: "範囲が広すぎます。専用のサブフォルダを選んでください（ホーム、システムフォルダ、ディスク全体は不可）。",
        .th: "กว้างเกินไป โปรดเลือกโฟลเดอร์ย่อยเฉพาะ (ไม่ใช่โฟลเดอร์โฮม โฟลเดอร์ระบบ หรือทั้งดิสก์)",
        .ko: "범위가 너무 넓습니다. 전용 하위 폴더를 선택하세요(홈 폴더, 시스템 폴더, 디스크 전체는 안 됨)."
    ],
    "core_0a0e2277": [
        .en: "This is the root of a whole disk; consider choosing a dedicated folder inside it",
        .zhHant: "這是整顆磁碟的根目錄，建議改選其中一個專用資料夾",
        .zhHans: "这是整块磁盘的根目录，建议改选其中一个专用文件夹",
        .ja: "ディスク全体のルートです。中の専用フォルダを選ぶことをおすすめします",
        .th: "นี่คือรากของทั้งดิสก์ แนะนำให้เลือกโฟลเดอร์เฉพาะภายใน",
        .ko: "디스크 전체의 루트입니다. 안의 전용 폴더를 선택하는 것을 권장합니다"
    ],
    "core_20999ae5": [
        .en: "This is the root of the whole cloud drive; choose a dedicated subfolder to avoid syncing a huge number of files",
        .zhHant: "這是整個雲端根目錄，建議改選其中一個專用子資料夾，避免同步大量檔案",
        .zhHans: "这是整个云端根目录，建议改选其中一个专用子文件夹，避免同步大量文件",
        .ja: "クラウド全体のルートです。大量のファイルの同期を避けるため、専用のサブフォルダを選んでください",
        .th: "นี่คือรากของคลาวด์ทั้งหมด แนะนำให้เลือกโฟลเดอร์ย่อยเฉพาะ เพื่อไม่ต้องซิงค์ไฟล์จำนวนมาก",
        .ko: "클라우드 전체의 루트입니다. 많은 파일이 동기화되지 않도록 전용 하위 폴더를 선택하세요"
    ],
    "core_aa6d4dd0": [
        .en: "No read/write permission (check the app's file access authorization)",
        .zhHant: "沒有讀寫權限（請確認 App 的檔案存取授權）",
        .zhHans: "没有读写权限（请确认 App 的文件访问授权）",
        .ja: "読み書きの権限がありません（アプリのファイルアクセス許可を確認してください）",
        .th: "ไม่มีสิทธิ์อ่าน/เขียน (ตรวจสอบสิทธิ์การเข้าถึงไฟล์ของแอป)",
        .ko: "읽기/쓰기 권한이 없습니다(앱의 파일 접근 권한을 확인하세요)"
    ],
    "core_d63b9fca": [
        .en: "Same folder as endpoint \"%@\"",
        .zhHant: "與端點「%@」是同一個資料夾",
        .zhHans: "与端点“%@”是同一个文件夹",
        .ja: "エンドポイント「%@」と同じフォルダです",
        .th: "เป็นโฟลเดอร์เดียวกับปลายทาง “%@”",
        .ko: "엔드포인트 “%@”과(와) 같은 폴더입니다"
    ],
    "core_502587eb": [
        .en: "Located inside endpoint \"%@\"'s folder; this would sync twice",
        .zhHant: "位於端點「%@」的資料夾內部，會造成重複同步",
        .zhHans: "位于端点“%@”的文件夹内部，会造成重复同步",
        .ja: "エンドポイント「%@」のフォルダ内にあり、二重に同期されます",
        .th: "อยู่ภายในโฟลเดอร์ของปลายทาง “%@” จะทำให้ซิงค์ซ้ำ",
        .ko: "엔드포인트 “%@”의 폴더 안에 있어 중복 동기화됩니다"
    ],
    "core_a55bcc32": [
        .en: "Contains endpoint \"%@\"'s folder; this would sync twice",
        .zhHant: "包含端點「%@」的資料夾，會造成重複同步",
        .zhHans: "包含端点“%@”的文件夹，会造成重复同步",
        .ja: "エンドポイント「%@」のフォルダを含んでおり、二重に同期されます",
        .th: "มีโฟลเดอร์ของปลายทาง “%@” อยู่ภายใน จะทำให้ซิงค์ซ้ำ",
        .ko: "엔드포인트 “%@”의 폴더를 포함하여 중복 동기화됩니다"
    ],
    "core_f2f479c7": [
        .en: "If iCloud \"Desktop & Documents\" is on, iCloud also syncs this folder itself, which may cause double syncing",
        .zhHant: "若已開啟 iCloud「桌面與文件」同步，這個資料夾也會被 iCloud 自己同步，可能造成雙重同步",
        .zhHans: "若已开启 iCloud“桌面与文稿”同步，这个文件夹也会被 iCloud 自己同步，可能造成双重同步",
        .ja: "iCloud の「デスクトップと書類」が有効な場合、このフォルダは iCloud 自身でも同期され、二重同期になる可能性があります",
        .th: "หากเปิด iCloud “เดสก์ท็อปและเอกสาร” โฟลเดอร์นี้จะถูก iCloud ซิงค์เองด้วย อาจเกิดการซิงค์ซ้ำซ้อน",
        .ko: "iCloud “데스크탑 및 문서”가 켜져 있으면 이 폴더도 iCloud가 자체 동기화하여 이중 동기화가 될 수 있습니다"
    ],
    "core_e28215ef": [
        .en: "This disk is %@ formatted; consider turning on \"Names must be exFAT / Windows compatible\"",
        .zhHant: "這顆碟是 %@ 格式，建議開啟「檔名須相容 exFAT / Windows」",
        .zhHans: "这块盘是 %@ 格式，建议开启“文件名须兼容 exFAT / Windows”",
        .ja: "このディスクは %@ 形式です。「ファイル名を exFAT / Windows 互換にする」を有効にすることをおすすめします",
        .th: "ดิสก์นี้เป็นรูปแบบ %@ แนะนำให้เปิด “ชื่อไฟล์ต้องเข้ากันกับ exFAT / Windows”",
        .ko: "이 디스크는 %@ 형식입니다. “파일 이름을 exFAT / Windows 호환으로” 옵션을 켜는 것을 권장합니다"
    ],
    "core_3319c590": [
        .en: "Another sync is already running (app or command line); please try again later",
        .zhHant: "另一個同步正在進行中（App 或指令列），請稍後再試",
        .zhHans: "另一个同步正在进行中（App 或命令行），请稍后再试",
        .ja: "別の同期が実行中です（アプリまたはコマンドライン）。後でもう一度お試しください",
        .th: "มีการซิงค์อื่นกำลังทำงานอยู่ (แอปหรือบรรทัดคำสั่ง) โปรดลองใหม่ภายหลัง",
        .ko: "다른 동기화가 진행 중입니다(앱 또는 명령줄). 잠시 후 다시 시도하세요"
    ],
    "core_38263a5b": [
        .en: "Cannot open the database: %@",
        .zhHant: "無法開啟資料庫：%@",
        .zhHans: "无法打开数据库：%@",
        .ja: "データベースを開けません：%@",
        .th: "ไม่สามารถเปิดฐานข้อมูล: %@",
        .ko: "데이터베이스를 열 수 없습니다: %@"
    ],
    "core_1d390411": [
        .en: "The state database was damaged. The damaged file was kept and restored from backup %@; the next sync will compare everything again (merge only, nothing is deleted).",
        .zhHant: "狀態資料庫損壞，已保留損壞檔並從備份 %@ 還原；下一輪同步會重新比對（只會合併，不會刪除）",
        .zhHans: "状态数据库损坏，已保留损坏文件并从备份 %@ 还原；下一轮同步会重新比对（只会合并，不会删除）",
        .ja: "状態データベースが破損していました。破損ファイルは保持し、バックアップ %@ から復元しました。次回の同期で再比較します（統合のみで削除はしません）。",
        .th: "ฐานข้อมูลสถานะเสียหาย เก็บไฟล์ที่เสียไว้และกู้คืนจากข้อมูลสำรอง %@ แล้ว การซิงค์รอบถัดไปจะเปรียบเทียบใหม่ (รวมเท่านั้น ไม่ลบ)",
        .ko: "상태 데이터베이스가 손상되어 손상된 파일은 보관하고 백업 %@ 에서 복원했습니다. 다음 동기화에서 다시 비교합니다(병합만 하며 삭제하지 않음)."
    ],
    "core_f4a87cda": [
        .en: "The state database was damaged and no usable backup exists; a new database was created. Endpoints must be added again, and afterwards only merging happens (nothing is deleted).",
        .zhHant: "狀態資料庫損壞且沒有可用備份，已建立新的資料庫；端點需要重新加入，加入後只會合併，不會刪除",
        .zhHans: "状态数据库损坏且没有可用备份，已建立新的数据库；端点需要重新加入，加入后只会合并，不会删除",
        .ja: "状態データベースが破損し、使えるバックアップもないため、新しいデータベースを作成しました。エンドポイントを再追加してください。追加後は統合のみで削除はしません。",
        .th: "ฐานข้อมูลสถานะเสียหายและไม่มีข้อมูลสำรองที่ใช้ได้ จึงสร้างฐานข้อมูลใหม่ ต้องเพิ่มปลายทางใหม่ หลังจากนั้นจะรวมเท่านั้น ไม่ลบ",
        .ko: "상태 데이터베이스가 손상되고 사용할 수 있는 백업도 없어 새 데이터베이스를 만들었습니다. 엔드포인트를 다시 추가해야 하며, 추가 후에는 병합만 하고 삭제하지 않습니다."
    ],
    "core_dce120f8": [
        .en: "Failed to back up the state database: %@",
        .zhHant: "備份狀態資料庫失敗：%@",
        .zhHans: "备份状态数据库失败：%@",
        .ja: "状態データベースのバックアップに失敗しました：%@",
        .th: "สำรองฐานข้อมูลสถานะไม่สำเร็จ: %@",
        .ko: "상태 데이터베이스 백업 실패: %@"
    ],
    "core_470fc59f": [
        .en: "The service has not started yet",
        .zhHant: "服務尚未啟動",
        .zhHans: "服务尚未启动",
        .ja: "サービスはまだ起動していません",
        .th: "บริการยังไม่เริ่มทำงาน",
        .ko: "서비스가 아직 시작되지 않았습니다"
    ],
    "core_94102725": [
        .en: "Full verification: %@ file(s) differ from the record (possible corruption): %@",
        .zhHant: "完整驗證：%@ 個檔案內容與紀錄不符（疑似損壞）：%@",
        .zhHans: "完整验证：%@ 个文件内容与记录不符（疑似损坏）：%@",
        .ja: "完全検証：%@ 件のファイルが記録と一致しません（破損の疑い）：%@",
        .th: "การตรวจสอบเต็มรูปแบบ: %@ ไฟล์ไม่ตรงกับบันทึก (สงสัยว่าเสียหาย): %@",
        .ko: "전체 검증: %@개 파일이 기록과 다릅니다(손상 의심): %@"
    ],
    "core_e0d22d8e": [
        .en: "Skipped %@",
        .zhHant: "略過 %@",
        .zhHans: "略过 %@",
        .ja: "スキップ %@",
        .th: "ข้าม %@",
        .ko: "건너뜀 %@"
    ],
    "core_289c3b00": [
        .en: "Offline %@",
        .zhHant: "離線 %@",
        .zhHans: "离线 %@",
        .ja: "オフライン %@",
        .th: "ออฟไลน์ %@",
        .ko: "오프라인 %@"
    ],
    "core_6958a385": [
        .en: "Another sync is in progress (app or command line); retrying in 5 seconds",
        .zhHant: "另一個同步正在進行（App 或指令列），5 秒後重試",
        .zhHans: "另一个同步正在进行（App 或命令行），5 秒后重试",
        .ja: "別の同期が進行中です（アプリまたはコマンドライン）。5 秒後に再試行します",
        .th: "มีการซิงค์อื่นกำลังทำงาน (แอปหรือบรรทัดคำสั่ง) จะลองใหม่ใน 5 วินาที",
        .ko: "다른 동기화가 진행 중입니다(앱 또는 명령줄). 5초 후 다시 시도합니다"
    ],
    "core_c70afc02": [
        .en: "Error: %@",
        .zhHant: "錯誤：%@",
        .zhHans: "错误：%@",
        .ja: "エラー：%@",
        .th: "ข้อผิดพลาด: %@",
        .ko: "오류: %@"
    ],
    "core_70cc3461": [
        .en: "Online",
        .zhHant: "在線",
        .zhHans: "在线",
        .ja: "オンライン",
        .th: "ออนไลน์",
        .ko: "온라인"
    ],
    "core_78108893": [
        .en: "Auto-cleanup of old versions: removed %@ file(s), freed %@",
        .zhHant: "自動清理舊版本：移除 %@ 個檔案，釋出 %@",
        .zhHans: "自动清理旧版本：移除 %@ 个文件，释出 %@",
        .ja: "旧バージョンの自動クリーンアップ：%@ 件を削除し、%@ を解放しました",
        .th: "ล้างเวอร์ชันเก่าอัตโนมัติ: ลบ %@ ไฟล์ ปล่อยพื้นที่ %@",
        .ko: "이전 버전 자동 정리: %@개 파일 제거, %@ 확보"
    ],
    "core_51e6e2c7": [
        .en: "Backup history of \"%@\": removed %@ file(s) older than %@ days",
        .zhHant: "備份「%@」的歷史：清除超過 %@ 天的 %@ 個檔案",
        .zhHans: "备份“%@”的历史：清除超过 %@ 天的 %@ 个文件",
        .ja: "バックアップ「%@」の履歴：%@ 日より古い %@ 件を削除しました",
        .th: "ประวัติสำรองของ “%@”: ลบไฟล์ที่เก่ากว่า %@ วัน จำนวน %@ ไฟล์",
        .ko: "“%@” 백업 기록: %@일 지난 파일 %@개 삭제"
    ],
    "core_1696752d": [
        .en: "Manual cleanup of old versions (all): removed %@ file(s), freed %@",
        .zhHant: "手動清理舊版本（全部）：移除 %@ 個檔案，釋出 %@",
        .zhHans: "手动清理旧版本（全部）：移除 %@ 个文件，释出 %@",
        .ja: "旧バージョンの手動クリーンアップ（すべて）：%@ 件を削除し、%@ を解放しました",
        .th: "ล้างเวอร์ชันเก่าด้วยตนเอง (ทั้งหมด): ลบ %@ ไฟล์ ปล่อยพื้นที่ %@",
        .ko: "이전 버전 수동 정리(전체): %@개 파일 제거, %@ 확보"
    ],
    "core_44682fa7": [
        .en: "Manual cleanup of old versions (expired): removed %@ file(s), freed %@",
        .zhHant: "手動清理舊版本（過期）：移除 %@ 個檔案，釋出 %@",
        .zhHans: "手动清理旧版本（过期）：移除 %@ 个文件，释出 %@",
        .ja: "旧バージョンの手動クリーンアップ（期限切れ）：%@ 件を削除し、%@ を解放しました",
        .th: "ล้างเวอร์ชันเก่าด้วยตนเอง (หมดอายุ): ลบ %@ ไฟล์ ปล่อยพื้นที่ %@",
        .ko: "이전 버전 수동 정리(만료): %@개 파일 제거, %@ 확보"
    ],
    "group_new_default_name": [
        .en: "New Group",
        .zhHant: "新增群組",
        .zhHans: "新增群组",
        .ja: "新規グループ",
        .th: "กลุ่มใหม่",
        .ko: "새 그룹"
    ],
    "folder_icons_title": [
        .en: "Folder icons follow the sync group",
        .zhHant: "資料夾圖示跟隨同步群組",
        .zhHans: "文件夹图标跟随同步群组",
        .ja: "フォルダのアイコンを同期グループに合わせる",
        .th: "ไอคอนโฟลเดอร์ตามกลุ่มการซิงค์",
        .ko: "폴더 아이콘을 동기화 그룹에 맞추기"
    ],
    "folder_icons_desc": [
        .en: "Synced folders show their group's icon in Finder. This adds a small hidden file to each folder; it is never synced. Groups with the plain folder icon are left alone. Turning this off restores the normal icons.",
        .zhHant: "被同步的資料夾會在 Finder 中顯示所屬群組的圖示。這會在每個資料夾內加入一個隱藏的小檔案（不會被同步）；使用一般資料夾圖示的群組不受影響。關閉後會還原為一般圖示。",
        .zhHans: "被同步的文件夹会在 Finder 中显示所属群组的图标。这会在每个文件夹内添加一个隐藏的小文件（不会被同步）；使用普通文件夹图标的群组不受影响。关闭后会还原为普通图标。",
        .ja: "同期中のフォルダに、所属グループのアイコンを Finder で表示します。各フォルダに小さな隠しファイルが追加されます（同期はされません）。通常のフォルダアイコンのグループは変更されません。オフにすると元のアイコンに戻ります。",
        .th: "โฟลเดอร์ที่ซิงค์จะแสดงไอคอนของกลุ่มใน Finder โดยจะเพิ่มไฟล์ซ่อนขนาดเล็กในแต่ละโฟลเดอร์ (ไม่ถูกซิงค์) กลุ่มที่ใช้ไอคอนโฟลเดอร์ปกติจะไม่ถูกเปลี่ยน เมื่อปิดจะคืนไอคอนปกติ",
        .ko: "동기화 중인 폴더가 Finder에서 소속 그룹의 아이콘으로 표시됩니다. 각 폴더에 작은 숨김 파일이 추가되며(동기화되지 않음), 기본 폴더 아이콘을 쓰는 그룹은 그대로입니다. 끄면 원래 아이콘으로 돌아갑니다."
    ],
    "group_deleted_toast": [
        .en: "Sync group '%@' deleted.",
        .zhHant: "已刪除同步群組「%@」",
        .zhHans: "已删除同步群组“%@”",
        .ja: "同期グループ「%@」を削除しました。",
        .th: "ลบกลุ่มการซิงค์ '%@' เรียบร้อยแล้ว",
        .ko: "'%@' 동기화 그룹이 삭제되었습니다."
    ],
    "folders_used_in_other_group": [
        .en: "Folder is already being synced by group '%@' (endpoint '%@'). Overlapping sync paths are prohibited.",
        .zhHant: "該資料夾已被同步群組「%@」（端點「%@」）同步中，禁止重複跨群組同步相同路徑。",
        .zhHans: "该文件夹已被同步群组“%@”（端点“%@”）同步中，禁止重复跨群组同步相同路径。",
        .ja: "このフォルダは既にグループ「%@」（エンドポイント「%@」）で同期されています。",
        .th: "โฟลเดอร์นี้ถูกซิงค์โดยกลุ่ม '%@' (ปลายทาง '%@') อยู่แล้ว",
        .ko: "해당 폴더는 이미 '%@' 그룹('%@' 엔드포인트)에서 동기화 중입니다."
    ],
    "folders_nested_in_other_group": [
        .en: "Nested within group '%@' (endpoint '%@'). Sub-group path will be automatically isolated and excluded from the parent group.",
        .zhHant: "與同步群組「%@」（端點「%@」）存在父子層巢狀關係，系統將自動於父群組排除該子路徑以避免衝突。",
        .zhHans: "与同步群组“%@”（端点“%@”）存在父子层嵌套关系，系统将自动于父群组排除该子路径以避免冲突。",
        .ja: "グループ「%@」（エンドポイント「%@」）と親子関係にあります。競合を防ぐため親グループから自動的に除外されます。",
        .th: "มีความสัมพันธ์แบบซ้อนกับกลุ่ม '%@' (ปลายทาง '%@') ระบบจะแยกและยกเว้นเส้นทางนี้ในกลุ่มหลักโดยอัตโนมัติ",
        .ko: "'%@' 그룹('%@' 엔드포인트)과 중첩 관계입니다. 충돌 방지를 위해 상위 그룹에서 자동으로 제외됩니다."
    ],
    "folders_nested_in_other_group_propagate": [
        .en: "Nested within group '%@' (endpoint '%@'). Parent group will propagate this folder across its endpoints.",
        .zhHant: "與同步群組「%@」（端點「%@」）存在父子層巢狀關係，父群組將穿透散播此資料夾至其他端點。",
        .zhHans: "与同步群组“%@”（端点“%@”）存在父子层嵌套关系，父群组将穿透散播此文件夹至其他端点。",
        .ja: "グループ「%@」（エンドポイント「%@」）と親子関係にあります。親グループ経由で他エンドポイントへ自動伝播されます。",
        .th: "มีความสัมพันธ์แบบซ้อนกับกลุ่ม '%@' (ปลายทาง '%@') กลุ่มหลักจะกระจายโฟลเดอร์นี้ไปยังปลายทางอื่นโดยอัตโนมัติ",
        .ko: "'%@' 그룹('%@' 엔드포인트)과 중첩 관계입니다. 상위 그룹을 통해 다른 엔드포인트로 자동 전파됩니다."
    ],
    "settings_auto_exclude_nested": [
        .en: "Auto-Exclude Nested Child Groups (Isolation Mode)",
        .zhHant: "自動排除子同步群組資料夾（完全隔離同步）",
        .zhHans: "自动排除子同步群组文件夹（完全隔离同步）",
        .ja: "ネストされた子グループを自動除外（分離同期）",
        .th: "ยกเว้นกลุ่มย่อยที่ซ้อนกันโดยอัตโนมัติ (โหมดแยกการซิงค์)",
        .ko: "중첩된 하위 그룹 자동 제외 (격리 모드)"
    ],
    "settings_nested_groups_desc": [
        .en: "When turned off (recommended), parent groups will naturally propagate nested child folders to other endpoints (e.g. iCloud, Google Drive). When turned on, parent groups strictly ignore nested child group folders.",
        .zhHant: "關閉時（推薦）：父群組會自動將子群組資料夾內容穿透散播至父群組的其他端點（如 iCloud、Google Drive）。開啟時：父群組將嚴格排除子群組資料夾，彼此完全隔離不傳播。",
        .zhHans: "关闭时（推荐）：父群组会自动将子群组文件夹内容穿透散播至父群组的其他端点（如 iCloud、Google Drive）。开启时：父群组将严格排除子群组文件夹，彼此完全隔离不传播。",
        .ja: "オフ（推奨）：親グループはネストされた子フォルダを他のエンドポイント（iCloud、Google Drive 等）へ自動伝播します。オン：親グループは子フォルダを厳格に除外します。",
        .th: "เมื่อปิด (แนะนำ): กลุ่มหลักจะกระจายโฟลเดอร์ย่อยไปยังปลายทางอื่น เช่น iCloud หรือ Google Drive ตามธรรมชาติ เมื่อเปิด: กลุ่มหลักจะแยกและยกเว้นโฟลเดอร์ย่อยโดยเด็ดขาด",
        .ko: "끄기(권장): 상위 그룹이 하위 폴더의 내용을 다른 엔드포인트(iCloud, Google Drive 등)로 자연스럽게 전파합니다. 켜기: 상위 그룹에서 하위 폴더를 엄격히 제외합니다."
    ],
    "conflicts_in_other_group_title": [
        .en: "Group '%@' has unresolved conflicts",
        .zhHant: "同步群組「%@」有待處理衝突",
        .zhHans: "同步群组“%@”有待处理冲突",
        .ja: "グループ「%@」に未解決の競合があります",
        .th: "กลุ่ม '%@' มีข้อขัดแย้งที่ยังไม่ได้รับการแก้ไข",
        .ko: "'%@' 그룹에 해결되지 않은 충돌이 있습니다"
    ],
    "conflicts_in_other_group_desc": [
        .en: "Click below to switch to this group and resolve conflicts.",
        .zhHant: "點擊下方按鈕切換至該群組並檢視與解決衝突。",
        .zhHans: "点击下方按钮切换至该群组并查看与解决冲突。",
        .ja: "下のボタンをクリックしてこのグループに切り替え、競合を解決してください。",
        .th: "คลิกด้านล่างเพื่อสลับไปยังกลุ่มนี้และแก้ไขข้อขัดแย้ง",
        .ko: "아래 버튼을 눌러 해당 그룹으로 전환하고 충돌을 해결하세요."
    ],
    "conflicts_switch_to_group_action": [
        .en: "Switch to '%@'",
        .zhHant: "切換至「%@」",
        .zhHans: "切换至“%@”",
        .ja: "「%@」に切り替え",
        .th: "สลับไปที่ '%@'",
        .ko: "'%@' (으)로 전환"
    ],
    "group_excludes_label": [
        .en: "Custom Exclude Paths / Folders:",
        .zhHant: "自訂排除路徑或資料夾：",
        .zhHans: "自定义排除路径或文件夹：",
        .ja: "カスタム除外パス / フォルダ:",
        .th: "เส้นทาง/โฟลเดอร์ที่ยกเว้นที่กำหนดเอง:",
        .ko: "사용자 지정 제외 경로/폴더:"
    ],
    "group_excludes_placeholder": [
        .en: "e.g. temp, cache, sub-project (comma-separated)",
        .zhHant: "例如：temp, cache, sub-project（以逗號或空格分隔）",
        .zhHans: "例如：temp, cache, sub-project（以逗号或空格分隔）",
        .ja: "例: temp, cache, sub-project (カンマ区切り)",
        .th: "เช่น temp, cache, sub-project (คั่นด้วยเครื่องหมายจุลภาค)",
        .ko: "예: temp, cache, sub-project (쉼표로 구분)"
    ],
    "group_excludes_hint": [
        .en: "Specified folder names or relative paths will be ignored during synchronization. Nested sub-groups are automatically excluded.",
        .zhHant: "此處設定的資料夾或相對路徑在同步時將被完全忽略。若有重疊的子群組，系統亦會自動排除。",
        .zhHans: "此处设置的文件夹或相对路径在同步时将被完全忽略。若有重叠的子群组，系统亦会自动排除。",
        .ja: "指定したフォルダ名または相対パスは同期から完全に除外されます。重なるサブグループは自動的に除外されます。",
        .th: "ชื่อโฟลเดอร์หรือเส้นทางสัมพัทธ์ที่ระบุจะถูกละเว้นระหว่างการซิงค์ กลุ่มย่อยที่ซ้อนกันจะได้รับการยกเว้นโดยอัตโนมัติ",
        .ko: "지정된 폴더 이름 또는 상대 경로는 동기화 시 완전히 무시됩니다. 중첩된 하위 그룹은 자동으로 제외됩니다."
    ],
    "group_active_banner": [
        .en: "Current Sync Group: %@ (%d endpoints)",
        .zhHant: "目前同步群組：%@（共 %d 個端點資料夾）",
        .zhHans: "当前同步群组：%@（共 %d 个端点文件夹）",
        .ja: "現在の同期グループ: %@ (%d 個のエンドポイント)",
        .th: "กลุ่มการซิงค์ปัจจุบัน: %@ (%d ปลายทาง)",
        .ko: "현재 동기화 그룹: %@ (%d개 엔드포인트)"
    ],
    // Activity Center Manual Strings
    "manual_topic_activity_title": [
        .en: "Chapter 4: Activity Center — Real-Time Stream, Speed & Directions",
        .zhHant: "第四章：同步動態 (Activity Center) — 即時傳輸串流、速度與方向",
        .zhHans: "第四章：同步动态 (Activity Center) — 实时传输串流、速度与方向",
        .ja: "第4章：同期動態 (Activity Center) — リアルタイム転送、速度、方向",
        .th: "บทที่ 4: ความเคลื่อนไหว (Activity Center) — กระแสการซิงค์ ความเร็ว และทิศทาง",
        .ko: "제4장: 동기화 활동 (Activity Center) — 실시간 스트림, 속도 및 방향"
    ],
    "manual_topic_activity_desc": [
        .en: "The Activity Center provides real-time streaming visibility into every file operation across all sync groups. Filter by group, inspect transfer direction, file size, duration, and speed, with one-click CSV export.",
        .zhHant: "「同步動態」提供專屬的滾動式即時串流視窗，記錄跨群組傳輸過程、同步方向（哪端到哪端）、檔案大小、傳輸速度與耗時，徹底告別傳統置頂無法追溯的痛點。",
        .zhHans: "“同步动态”提供专属的滚动式实时串流窗口，记录跨群组传输过程、同步方向（哪端到哪端）、文件大小、传输速度与耗时，彻底告别传统置顶无法追溯的痛点。",
        .ja: "「同期動態」では、全グループの同期履歴をスクロール表示する専用ウィンドウを提供。方向（どのフォルダからどこへ）、ファイルサイズ、転送速度、所要時間をリアルタイムで追跡できます。",
        .th: "หน้า 'ความเคลื่อนไหว' ให้มุมมองแบบสตรีมมิ่งสด แสดงประวัติการทำงานของทุกกลุ่ม ทิศทางการซิงค์ ขนาดไฟล์ ความเร็ว และเวลาที่ใช้ พร้อมส่งออกเป็น CSV ได้ทันที",
        .ko: "'동기화 활동'은 모든 그룹의 파일 전송 과정을 스크롤 스트림으로 보여주는 전용 화면입니다. 동기화 방향, 파일 크기, 속도, 소요 시간을 실시간으로 추적하고 CSV로 내보낼 수 있습니다."
    ],
    "manual_topic_activity_ops_title": [
        .en: "Zero-Foundation Tutorial: Monitoring Streams & Exporting Records",
        .zhHant: "零基礎教學：即時串流監控、群組篩選與日誌匯出手把手步驟",
        .zhHans: "零基础教学：实时串流监控、群组筛选与日志导出手把手步骤",
        .ja: "入門チュートリアル：リアルタイム監視、グループ絞り込み、CSV エクスポート手順",
        .th: "คู่มือเริ่มต้น: การติดตามความเคลื่อนไหว การกรองกลุ่ม และการส่งออกข้อมูล",
        .ko: "초보자 가이드: 실시간 모니터링, 그룹 필터링 및 로그 내보내기 단계별 절차"
    ],
    "manual_topic_activity_ops_desc": [
        .en: "【Step 1: Filter Groups】Use the top-left dropdown to view 'All Groups' or select a single sync group.\n【Step 2: Monitor Real-Time Direction & Speed】The table displays Time, Group, Direction (e.g. Local ➔ Mobil), Action (Copy/Move/Trash), Size, Speed (KB/s, MB/s), and Duration.\n【Step 3: Auto-Scroll Toggle】Keep 'Auto Scroll to Latest' checked to automatically keep the freshest events visible as sync executes.\n【Step 4: Export to CSV】Click 'Export CSV...' at top right to save the entire activity log for audits or performance analysis.",
        .zhHant: "【步驟 1：依群組篩選】點擊左上方下拉選單，可自由選擇觀看「全部群組」的匯總動態，或切換僅檢視特定單一群組。\n【步驟 2：即時掌握同步方向與速度】表格清楚列出時間、群組、同步方向（例如：本機 ➔ 外接隨身碟）、動作（複製/搬移/垃圾桶）、檔案大小、傳輸速度（KB/s、MB/s）與耗時。\n【步驟 3：自動置頂追蹤】勾選「自動滾動至最新事件」，新檔案寫入時清單自動捲動並聚焦於最新事件。\n【步驟 4：一鍵匯出 CSV】點擊右上角「匯出 CSV...」按鈕，可將完整操作日誌存檔，便於稽核與效能分析。",
        .zhHans: "【步骤 1：依群组筛选】点击左上方下拉菜单，可自由选择观看“全部群组”的汇总动态，或切换仅检视特定单一群组。\n【步骤 2：实时掌握同步方向与速度】表格清楚列出时间、群组、同步方向（例如：本机 ➔ 外接随身碟）、动作（复制/搬移/废纸篓）、文件大小、传输速度（KB/s、MB/s）与耗时。\n【步骤 3：自动置顶追踪】勾选“自动滚动至最新事件”，新文件写入时清单自动卷动并聚焦于最新事件。\n【步骤 4：一键导出 CSV】点击右上角“导出 CSV...”按钮，可将完整操作日志存盘，便于稽核与效能分析。",
        .ja: "【ステップ 1：グループで絞り込み】左上のドロップダウンで「すべてのグループ」または単一グループを選択。\n【ステップ 2：転送方向と速度を確認】日時、グループ、同期方向（例: Local ➔ Mobil）、アクション、サイズ、速度（KB/s, MB/s）、所要時間が一目で分かります。\n【ステップ 3：自動スクロール】「最新イベントへ自動スクロール」をオンにしておくと、常に最新の同期イベントが表示されます。\n【ステップ 4：CSV エクスポート】右上の「CSV エクスポート...」をクリックして、同期履歴を CSV ファイルとして保存できます。",
        .th: "【ขั้นตอนที่ 1: กรองตามกลุ่ม】ใช้เมนูดรอปดาวน์มุมซ้ายบนเพื่อดู 'ทุกกลุ่ม' หรือเลือกดูกลุ่มใดกลุ่มหนึ่งโดยเฉพาะ\n【ขั้นตอนที่ 2: ติดตามทิศทางและความเร็ว】ตารางแสดงเวลา กลุ่ม ทิศทางการซิงค์ (เช่น Local ➔ Mobil) การกระทำ ขนาด ความเร็ว และเวลาที่ใช้\n【ขั้นตอนที่ 3: เลื่อนอัตโนมัติ】เปิดใช้งาน 'เลื่อนไปยังรายการล่าสุดโดยอัตโนมัติ' เพื่อให้หน้าจอเลื่อนตามเหตุการณ์ล่าสุดเสมอ\n【ขั้นตอนที่ 4: ส่งออกเป็น CSV】คลิก 'ส่งออก CSV...' มุมขวาบนเพื่อบันทึกประวัติการซิงค์ทั้งหมดสำหรับการตรวจสอบ",
        .ko: "【1단계: 그룹별 필터링】좌측 상단 드롭다운에서 '모든 그룹'을 보거나 특정 단일 그룹만을 선택하여 조회할 수 있습니다.\n【2단계: 전송 방향 및 속도 모니터링】표에는 시간, 그룹, 동기화 방향(예: Local ➔ Mobil), 작업(복사/이동/휴지통), 파일 크기, 전송 속도(KB/s, MB/s), 소요 시간이 명확히 표시됩니다.\n【3단계: 최신 이벤트 자동 스크롤】'최신 이벤트로 자동 스크롤'을 켜두면 동기화 진행 시 최신 항목이 화면 상단에 자동으로 표시됩니다.\n【4단계: CSV 내보내기】우측 상단의 'CSV 내보내기...'를 클릭하여 전체 동기화 활동 기록을 CSV 파일로 저장할 수 있습니다."
    ],
    "manual_topic_activity_safe_title": [
        .en: "Transparent Pipeline & Atomic Verification",
        .zhHant: "透明串流與原子寫入雙重校驗",
        .zhHans: "透明串流与原子写入双重校验",
        .ja: "透明なパイプラインとアトミック検証",
        .th: "ความโปร่งใสของกระบวนการและการตรวจสอบเชิงอะตอมิก",
        .ko: "투명한 파이프라인 및 원자적 검증"
    ],
    "manual_topic_activity_safe_desc": [
        .en: "• Atomic Transfer: Every copy is written to `.syncnexus-tmp-*` and verified by SHA-256 before atomic rename.\n• Speed Analytics: Real-time throughput calculations reflect physical hardware capabilities without background blocking.\n• Non-Intrusive: Event logging uses in-memory ring buffers and background queues, guaranteeing zero lag on file transfers.",
        .zhHant: "• 原子性傳輸：所有檔案均在背景寫入暫存檔並驗證 SHA-256 雜湊無誤後才完成最終落盤。\n• 實時速率分析：根據實際傳輸位元數與耗時動態計算真實吞吐量，反映真實硬體表現。\n• 零阻塞架構：事件串流採用輕量內存循環佇列與非同步背景佇列，完全不拖慢同步引擎主幹速度。",
        .zhHans: "• 原子性传输：所有文件均在背景写入暂存文件并验证 SHA-256 哈希无误后才完成最终落盘。\n• 实时速率分析：根据实际传输位元数与耗时动态计算真实吞吐量，反映真实硬件表现。\n• 零阻塞架构：事件串流采用轻量内存循环队列与异步背景队列，完全不拖慢同步引擎主干速度。",
        .ja: "• アトミック転送: すべてのファイルは一時ファイルに書き込まれ、SHA-256 検証後に原子的にリネームされます。\n• リアルタイム速度計測: 転送サイズと所要時間から正確なスループットを動的に算出。\n• 負荷ゼロ設計: イベント記録はメモリ内リングバッファと非同期キューで行われ、同期処理本体を一切妨げません。",
        .th: "• การส่งข้อมูลแบบอะตอมิก: เขียนไฟล์ลงไฟล์ชั่วคราวก่อนและตรวจสอบ SHA-256 ก่อนบันทึกจริง\n• การคำนวณความเร็วเรียลไทม์: คำนวณความเร็วจริงตามปริมาณข้อมูลและเวลาที่ใช้โดยไม่ทำให้ระบบสะดุด\n• สถาปัตยกรรมประสิทธิภาพสูง: บันทึกข้อมูลผ่านคิวพื้นหลัง ไม่ส่งผลกระทบต่อความเร็วของเครื่อง",
        .ko: "• 원자적 전송: 모든 파일은 임시 파일에 기록되고 SHA-256 해시 검증을 거친 후 안전하게 교체됩니다.\n• 실시간 속도 계산: 실제 전송량과 소요 시간을 바탕으로 하드웨어의 실제 처리량을 즉시 표시합니다.\n• 무부하 비동기 구조: 이벤트 로깅은 경량 메모리 큐와 비동기 큐를 사용하여 동기화 엔진에 전혀 부하를 주지 않습니다."
    ],
    "manual_topic_activity_tips_title": [
        .en: "Best Practice",
        .zhHant: "日常使用秘訣",
        .zhHans: "日常使用秘诀",
        .ja: "日常の使い方のヒント",
        .th: "เคล็ดลับการใช้งานประจำวัน",
        .ko: "일상 사용 팁"
    ],
    "manual_topic_activity_tips_desc": [
        .en: "If a file transfer takes longer than expected, check the Speed column in Activity Center to determine if external drives or cloud sync bandwidth are throttling performance.",
        .zhHant: "若發現特定檔案同步時間較長，可在「同步動態」的「傳輸速度」欄位觀察實際速度，藉此判斷是否為隨身碟寫入瓶頸或雲端網路頻寬限制。",
        .zhHans: "若发现特定文件同步时间较长，可在“同步动态”的“传输速度”栏位观察实际速度，藉此判断是否为随身碟写入瓶颈或云端网络频宽限制。",
        .ja: "ファイルの同期が遅いと感じた場合、「同期動態」の「速度」列を確認することで、外付け USB の書き込み速度やクラウドの帯域制限が原因かどうかを即座に特定できます。",
        .th: "หากพบว่าไฟล์บางไฟล์ซิงค์ช้า สามารถดูคอลัมน์ 'ความเร็ว' เพื่อตรวจสอบได้ว่าเป็นข้อจำกัดของแฟลชไดรฟ์หรือความเร็วอินเทอร์เน็ตของคลาวด์",
        .ko: "특정 파일 동기화가 오래 걸리는 경우, '동기화 활동'의 '전송 속도' 열을 확인하여 외장 USB의 쓰기 속도 문제인지 클라우드 네트워크 대역폭 제한인지 바로 파악할 수 있습니다."
    ]
]
