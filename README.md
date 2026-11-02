# dotfiles

個人的な設定ファイル管理リポジトリです。

## 特徴

- Homebrewによるパッケージ管理
- oh-my-zshによるシェル環境
- starshipによるプロンプトカスタマイズ（現在のタスクを表示）
- zellijによる端末マルチプレクサ
- Alacrittyターミナルエミュレータ
- taskwarriorによるタスク管理
- モダンなコマンドラインツール（eza, bat, bottom, dust, duf）

## 新しいMacの初回セットアップ

この手順は、下記の `bootstrap.sh` と関連ファイルをGitHubのデフォルトブランチに
コミット・pushした後に使えます。公開リポジトリからスクリプトを取得します。
実行前に内容を確認してから、次のように実行します。

```bash
curl -fsSLo /tmp/dotfiles-bootstrap.sh https://raw.githubusercontent.com/sasaron/dotfiles/main/bootstrap.sh
less /tmp/dotfiles-bootstrap.sh
bash /tmp/dotfiles-bootstrap.sh
```

Xcode Command Line Toolsが未導入ならインストール画面を開いて終了します。
インストール後に最後の `bash` コマンドを再実行してください。GitHubに接続できる
環境が必要です。既定の取得先は `~/src/github.com/sasaron/dotfiles` です。
変更する場合は `DOTFILES_DIR=/path/to/dotfiles bash /tmp/dotfiles-bootstrap.sh`。

HomebrewとBrewfileのパッケージ、シェル設定、エディター設定、AIスキルを設定し、
`install.sh` 内のmacOS設定も実行します。既存設定はinstall.shのルールでバックアップし、
同名AIスキルは上書きしません。既存のdotfilesチェックアウトは自動更新しないため、
必要なら変更を確認してから手動で更新してください。AIの認証情報・MCP設定は自動復元しません。

すでにリポジトリをクローンしている場合は、`./bootstrap.sh` を実行できます。

## 含まれるもの

### パッケージ管理

- Homebrew - macOSのパッケージマネージャー

### シェル環境

- oh-my-zsh - Zshフレームワーク
- zsh-autosuggestions - コマンド候補の表示
- zsh-syntax-highlighting - シンタックスハイライト
- starship - カスタマイズ可能なプロンプト

### 開発ツール

- git, github - バージョン管理
- docker, docker-compose - コンテナ管理
- node, npm, yarn - JavaScript/Node.js開発
- golang - Go言語開発
- VSCode拡張機能（AWS, AWS CDK, Cline, TypeScript, ESLint等）

### ターミナル環境

- Alacritty - GPUアクセラレーションターミナル
- zellij - tmux代替のターミナルマルチプレクサ

### モダンなコマンドラインツール

- eza - ls代替
- bat - cat代替
- bottom (btm) - top代替
- dust - du代替
- duf - df代替
- taskwarrior - コマンドラインタスク管理

## カスタマイズ

各設定ファイルは以下の場所にあります：

- `.zshrc` - Zshの設定
- `home/alacritty/alacritty.toml` - Alacrittyの設定
- `chezmoi/dot_config/starship.toml` - Starshipの設定
- `home/zellij/config.kdl` - Zellijの設定
- `mac/Brewfile` - Homebrewでインストールするパッケージリスト

## 更新方法

リポジトリを更新した後、以下のコマンドを実行してください：

```bash
./install.sh
```

## アプリ管理（日常運用）

全体セットアップの `install.sh` と、日常のアプリ管理を分離します。
`mac/Brewfile` は導入したいアプリの一覧、exportは現在のPCの参考一覧です。

```bash
./bin/manage-apps.sh check    # 未導入・未充足の確認
./bin/manage-apps.sh install  # 不足分を導入（既存パッケージは更新しない）
./bin/manage-apps.sh update   # Homebrew情報とBrewfile対象を更新
./bin/manage-apps.sh export   # local/apps/Brewfile.installed に現状を出力
```

exportは管理用Brewfileを上書きしません。必要なアプリだけ一覧から取り込みます。
削除・cleanupは自動実行しません。Brewfileは厳密なバージョン固定ではありません。
ClaudeデスクトップとClaude Code CLI、ChatGPTとCodex CLIは別のアプリです。
Claude Code CLIは古いnpm固定版からHomebrew Cask管理に変更しました。
既存npm版・ネイティブ版がある場合は `type -a claude codex` と各ツールの
診断結果を確認し、利用中の導入経路との重複を解消してからinstallしてください。
この変更だけでは既存のインストールを削除しません。

## Claude / Codex の設定export

```bash
python3 ./bin/export-ai-settings.py
```

- `local/ai/<日時>/` にClaudeの `settings.json`, `CLAUDE.md`、
  Codexの `config.toml`, `AGENTS.md` を存在する分だけコピーします。
- Codexは `CODEX_HOME` があればそちらを参照します。
- `local/` はGit管理外です。設定内の環境変数・MCP・hookに秘密が入る可能性が
  あるため、バックアップは秘密情報と同様に扱ってください（ファイル権限600）。
- auth.json、.credentials.json、.claude.json、Keychain、履歴、セッション、
  キャッシュ、プラグイン本体、skillsはexportしません。
- `config/ai/claude/settings.json` にはmodel / effortLevel / verboseのみ書き出します。
  独自モデル名を含む可能性があるため、コミット前に差分を確認してください。
- 現在のCodex設定は通知・デスクトップ・マーケットプレイス・プラグイン・MCP・apps
  の項目のため、共有ファイルへの自動抽出は行いません。ローカルにexportします。

既存設定を丸ごとシンボリックリンクにすると、アプリからの書き戻しで秘密や
マシン固有設定がGitへ混入し得るため、AI設定にはexport方式を採用しています。
復元は対象ファイルを比較し、既存設定のバックアップ後に必要な項目を取り込んで
ください。認証は各端末でやり直します。exportファイルの自動適用は行いません。

管理方法の比較と移行方針は `docs/environment-management.md` を参照してください。

## Claude Code MCP

設定一覧は `config/ai/claude/mcp.json`、詳細は `docs/claude-mcp.md`。

```bash
python3 bin/sync-claude-mcp.py          # 差分の概要を確認
python3 bin/sync-claude-mcp.py --apply  # バックアップ後にユーザー設定へ反映
```

## AIスキルの移行

`skills/` に `github-gh` と、hakomichiから移した設計資料向け `write-docs` を管理します。
新しい端末でdotfilesをクローンした後、以下を実行するとCodexとClaude Codeの
ユーザー用skillsにリンクします。既存の同名スキルは上書きしません。

```bash
./bin/install-ai-skills.sh
```

`write-docs` は設計資料の書き方をまとめたスキルです。プロジェクト固有の
`AGENTS.md` / `CLAUDE.md` があればそちらの配置・規則を優先します。
hakomichiのプロジェクト内にも同名スキルが残っている場合は、そのツールの
スキル優先順位によりプロジェクト側が使われることがあります。
リポジトリ側のスキルを変更したときは、既存リンク先にも反映されます。

## 宣言した環境の確認と適用

`config/environment.json` に適用する構成要素を記載します。各要素の内容は
`mac/Brewfile`、`skills/`、`config/ai/claude/mcp.json` で管理します。

```bash
python3 bin/environment.py plan                    # 対象一覧（差分表示ではない）
python3 bin/environment.py apply                   # 全要素を適用
python3 bin/environment.py apply apps ai-skills    # 個別適用も可能
```

appsはHomebrewが必要で、不足パッケージを導入します。ai-skillsは既存同名を
上書きしません。claude-mcpは既存設定をバックアップして対象だけ統合します。
各ツールの未指定項目は削除せず、厳密なバージョン固定・OS全体の管理ではありません。
`install.sh` のシェルリンク・VS Code・npm・macOS設定やCodex本体の設定は
この一覧の適用対象には含まれません。初回bootstrapでは別途 `install.sh` を実行します。
認証情報は宣言に含めず、各端末で認証します。

### Raycast / iTerm

両アプリをBrewfileでインストールできます。設定データはアプリ本体と別です。

- Raycast：アプリの Export Settings & Data から暗号化された `.rayconfig` を作り、
  移行先で Import Settings & Data を使用します。チャットや履歴も含み得るため、
  Git管理外の安全な場所へ保存してください。
- iTerm：`./bin/export-iterm-settings.sh` で現在のpreferences plistを
  `local/iterm/`（Git管理外）へバックアップできます。プロファイルや端末固有パスを
  確認してから、iTermの設定でカスタムフォルダの読み込みを設定してください。
  iTermの全データの完全なバックアップではありません。アプリ起動中の変更は
  最新状態になっていない場合があります。

この2つの設定データは自動的には適用されません。機密や端末固有の値を確認し、
必要なものを選んで移行してください。

## chezmoi

Starship設定は `chezmoi/dot_config/starship.toml` を正として管理します。
他の既存設定は引き続きinstall.shが管理します。初回セットアップではBrewfileで
chezmoiを導入し、設定を適用します。すでにStarshipがシンボリックリンクの場合も、
適用によって通常ファイルに置き換わります。内容を変更する前に差分を確認してください。

```bash
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

コマンドはこのリポジトリのルートで実行します。`chezmoi/` の元ファイルを編集し、
`apply` でホームへ反映します。旧 `home/starship/starship.toml` は既存の変更を保つため
残していますが、これからは管理対象ではありません。`.zshrc` やスキルなどは今後
一つずつ移行できます。認証情報やローカルバックアップはchezmoiの対象外です。
