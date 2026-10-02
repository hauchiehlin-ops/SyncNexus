# 版本號規則與自動提升

- `VERSION`：對外版本 `x.y.z`（CFBundleShortVersionString）。
- `BUILD_NUMBER`：整數 bundle number（CFBundleVersion），**每次提升版本都 +1**，永遠遞增。
- 這兩個檔案是唯一來源；`Scripts/Info.plist` 和 Homebrew cask 的版本會由腳本同步。App 選單最下方會顯示目前版本。

## 啟用（每個 clone 一次）

```bash
Scripts/install-hooks.sh        # 需要先 git init 或 git clone
```

## 平常怎麼用

照常 `git add` + `git commit`。只要這次 commit 動到 App（`Sources/`、`Scripts/`、`Package.swift`、`Resources/`、`packaging/`），
commit 前就會**自動提升 patch**（0.1.0 → 0.1.1，build +1），並把版本檔一起放進同一個 commit。

| 情況 | 結果 |
|---|---|
| 一般修正 | 自動 patch +1 |
| 只改文件或測試 | 不提升 |
| `BUMP=minor git commit …` | 提升 minor，patch 歸零（0.1.7 → 0.2.0） |
| `BUMP=major git commit …` | 提升 major（0.4.2 → 1.0.0） |
| 先執行 `Scripts/bump-version.sh minor`（或 major）再 commit | 沿用你提升的版本，不會再自動 +1 |
| `BUMP=none` 或 `SKIP_BUMP=1` | 這次不提升 |
| `git commit --amend`、merge、rebase、cherry-pick | 不重複提升 |

要不要升 minor 或 major 由你決定；不指定就是 patch。

## push 前檢查

`git push` 時會檢查：只要推送內容包含 App 變更，版本與 build number 就必須高於遠端目前的。
否則會擋下並提示修正方式：

```bash
Scripts/bump-version.sh patch && git add -A && git commit --amend --no-edit
```

臨時略過一次：`SKIP_BUMP=1 git push`。

## 注意

- 請用 `git add` 後 `git commit`（或 `git commit -a`）；`git commit <檔案路徑>` 會繞過 hook 修改的暫存區，版本檔不會進這個 commit。
- 手動查看／同步：`Scripts/bump-version.sh --show`、`Scripts/bump-version.sh --sync`。
