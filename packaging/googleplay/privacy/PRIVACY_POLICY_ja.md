# プライバシーポリシー (Android 版)

**発効日**: 2026年10月2日  
**アプリケーション**: Sync-Nexus for Android (Google Play Store 版)

Sync-Nexus は、ローカルファーストのファイル同期ツールです。ユーザーのプライバシー保護を徹底しています。

---

### 1. データ収集方針
* **サーバーレス・アカウント不要**: クラウドサーバーを持たず、アカウント登録や個人情報の収集は行いません。
* **テレメトリなし**: 外部解析ツール（Analytics）や広告 ID (AAID) などの追跡は一切行いません。
* **ローカル環境完結**: ファイル内容は外部サーバーへ送信されず、端末内およびローカル Wi-Fi 内でのみ同期されます。

---

### 2. Google Play ストレージおよび権限説明
* **Storage Access Framework (SAF) 準拠**: Google Play の Scoped Storage ポリシーを厳格に遵守。ユーザーが明示的に選択したフォルダのみにアクセスし、拒否リスクの高い `MANAGE_EXTERNAL_STORAGE` 権限は一切使用しません。
* **フォアグラウンドサービス (`FOREGROUND_SERVICE_DATA_SYNC`)**: バックグラウンドでの同期を安全に継続し、通知バーで実行状況を表示します。
* **ローカルネットワーク検出 (NSD / mDNS)**: 同一 Wi-Fi 内の Mac と直接接続するために使用します。

---

### 3. お問い合わせ
リポジトリ: [https://github.com/hauchiehlin-ops/SyncNexus](https://github.com/hauchiehlin-ops/SyncNexus)
