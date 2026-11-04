# 運用の詳細

README の各コマンドについて、挙動と注意点をまとめる。

## 初回セットアップ

`bootstrap.sh` は Homebrew と Brewfile のパッケージ、シェル設定、エディター設定、
AI スキルを設定し、`install.sh` 内の macOS 設定も実行する。

Xcode Command Line Tools が未導入ならインストール画面を開いて終了する。
インストール後に `bash /tmp/dotfiles-bootstrap.sh` を再実行する。GitHub に接続できる
環境が必要。既定の取得先は `~/src/github.com/sasaron/dotfiles` で、変更する場合は
`DOTFILES_DIR=/path/to/dotfiles bash /tmp/dotfiles-bootstrap.sh` とする。

既存設定は `install.sh` のルールでバックアップし、同名の AI スキルは上書きしない。
既存の dotfiles チェックアウトは自動更新しないため、必要なら変更を確認してから
手動で更新する。AI の認証情報と MCP 設定は自動復元しない。

## アプリ管理

全体セットアップの `install.sh` と、日常のアプリ管理を分離している。
`mac/Brewfile` は導入したいアプリの一覧で、export は現在の PC の参考一覧。

```bash
./bin/manage-apps.sh check    # 未導入・未充足の確認
./bin/manage-apps.sh install  # 不足分を導入（既存パッケージは更新しない）
./bin/manage-apps.sh update   # Homebrew情報とBrewfile対象を更新
./bin/manage-apps.sh export   # local/apps/Brewfile.installed に現状を出力
```

export は管理用 Brewfile を上書きしないので、必要なアプリだけ一覧から取り込む。
削除と cleanup は自動実行しない。Brewfile は厳密なバージョン固定ではない。

Claude デスクトップと Claude Code CLI、ChatGPT と Codex CLI は別のアプリ。
Claude Code CLI は古い npm 固定版から Homebrew Cask 管理に変更した。既存の npm 版や
ネイティブ版がある場合は `type -a claude codex` と各ツールの診断結果を確認し、
利用中の導入経路との重複を解消してから install する。この変更だけでは既存の
インストールを削除しない。

## Claude と Codex の設定 export

```bash
python3 ./bin/export-ai-settings.py
```

`local/ai/<日時>/` に、Claude の `settings.json` と `CLAUDE.md`、Codex の `config.toml` と
`AGENTS.md` を、存在する分だけコピーする。Codex は `CODEX_HOME` があればそちらを参照する。

`local/` は Git 管理外。設定内の環境変数、MCP、hook に秘密が入る可能性があるため、
バックアップは秘密情報と同様に扱う（ファイル権限 600）。次のものは export しない。

- `auth.json`、`.credentials.json`、`.claude.json`
- Keychain
- 履歴、セッション、キャッシュ
- プラグイン本体と skills

`config/ai/claude/settings.json` には model、effortLevel、verbose だけを書き出す。
独自モデル名を含む可能性があるため、コミット前に差分を確認する。Codex の設定は
通知、デスクトップ、マーケットプレイス、プラグイン、MCP、apps の項目なので、
共有ファイルへ自動抽出せずローカルに export する。

既存設定を丸ごとシンボリックリンクにすると、アプリからの書き戻しで秘密や
マシン固有設定が Git へ混入し得る。そのため AI 設定には export 方式を採っている。
復元は対象ファイルを比較し、既存設定をバックアップしてから必要な項目を取り込む。
認証は各端末でやり直す。export ファイルの自動適用は行わない。

## Claude Code MCP

設定一覧は `config/ai/claude/mcp.json`、詳細は [claude-mcp.md](claude-mcp.md)。

```bash
python3 bin/sync-claude-mcp.py          # 差分の概要を確認
python3 bin/sync-claude-mcp.py --apply  # バックアップ後にユーザー設定へ反映
```

## AI スキル

`skills/` で `github-gh` と、設計資料向けの `write-docs` を管理する。
`./bin/install-ai-skills.sh` で Codex と Claude Code のユーザー用 skills にリンクする。
既存の同名スキルは上書きしない。リンクなので、リポジトリ側の変更はそのまま反映される。

`write-docs` は、プロジェクト固有の `AGENTS.md` や `CLAUDE.md` があればそちらの配置と
規則を優先する。hakomichi のプロジェクト内にも同名スキルが残っている場合は、
ツールのスキル優先順位によりプロジェクト側が使われることがある。

## 宣言した環境の確認と適用

`config/environment.json` に適用する構成要素を記載する。各要素の内容は
`mac/Brewfile`、`skills/`、`config/ai/claude/mcp.json` で管理する。

```bash
python3 bin/environment.py plan                    # 対象一覧（差分表示ではない）
python3 bin/environment.py apply                   # 全要素を適用
python3 bin/environment.py apply apps ai-skills    # 個別適用も可能
```

apps は Homebrew が必要で、不足パッケージを導入する。ai-skills は既存の同名を
上書きしない。claude-mcp は既存設定をバックアップして対象だけ統合する。
各ツールの未指定項目は削除せず、厳密なバージョン固定や OS 全体の管理ではない。

`install.sh` のシェルリンク、VS Code、npm、macOS 設定と、Codex 本体の設定は
この一覧の適用対象に含まれない。初回 bootstrap では別途 `install.sh` を実行する。
認証情報は宣言に含めず、各端末で認証する。

## Raycast と iTerm

両アプリは Brewfile でインストールできるが、設定データはアプリ本体と別で、
自動では適用されない。機密や端末固有の値を確認し、必要なものを選んで移行する。

Raycast は、アプリの Export Settings & Data で暗号化された `.rayconfig` を作り、
移行先で Import Settings & Data を使う。チャットや履歴も含み得るため、
Git 管理外の安全な場所へ保存する。

iTerm は、`./bin/export-iterm-settings.sh` で現在の preferences plist を `local/iterm/`
（Git 管理外）へバックアップできる。プロファイルや端末固有パスを確認してから、
iTerm の設定でカスタムフォルダの読み込みを設定する。iTerm の全データの完全な
バックアップではなく、アプリ起動中の変更は最新状態になっていない場合がある。

## chezmoi

Starship の設定は `chezmoi/dot_config/starship.toml` を正として管理する。
他の設定は引き続き `install.sh` が管理する。初回セットアップでは Brewfile で
chezmoi を導入して設定を適用する。Starship がシンボリックリンクの場合も、
適用によって通常ファイルに置き換わるので、変更前に差分を確認する。

```bash
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

コマンドはリポジトリのルートで実行する。`chezmoi/` の元ファイルを編集し、
`apply` でホームへ反映する。旧 `home/starship/starship.toml` は既存の変更を保つため
残しているが、管理対象ではない。`.zshrc` やスキルなどは今後一つずつ移行できる。
認証情報とローカルバックアップは chezmoi の対象外。
