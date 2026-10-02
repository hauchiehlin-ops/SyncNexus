# プライバシーポリシー (macOS 版)

**発効日**: 2026年10月2日  
**アプリケーション**: Sync-Nexus for Mac (Mac App Store 版)

Sync-Nexus は、ローカルファーストのファイル同期ツールです。ユーザーのプライバシー保護を徹底しています。

---

### 1. データ収集方針
* **サーバーレス・アカウント不要**: クラウドサーバーを持たず、アカウント登録や個人情報の収集は行いません。
* **テレメトリなし**: 外部解析ツール（Analytics）や広告 ID などの追跡は一切行いません。
* **ローカル環境完結**: ファイル内容は外部サーバーへ送信されず、端末内およびローカル Wi-Fi 内でのみ同期されます。

---

### 2. Apple App Store 権限・サンドボックス説明
* **ユーザー選択ファイルへのアクセス (`com.apple.security.files.user-selected.read-write`)**: ユーザーがダイアログで指定したフォルダのみにアクセスします。
* **セキュリティスコープブックマーク (`com.apple.security.files.bookmarks.app-scope`)**: 許可されたフォルダの権限を次回起動時にも安全に保持します。
* **リムーバブルボリューム (`com.apple.security.files.volumes.read-write`)**: 外付けストレージの検出・同期に使用します。
* **Bonjour ローカル検出 (`_syncnexus._tcp`)**: 同一 Wi-Fi 内の端末と P2P 接続を確立するために使用します。

---

### 3. お問い合わせ
リポジトリ: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
