# 運用の詳細

README の各コマンドについて、挙動と注意点をまとめる。

## 初回セットアップ

`bootstrap.sh` はリポジトリを取得し、Homebrew を入れてから `chezmoi init --apply` を
実行する。GitHub に接続できる環境が必要。

新しい Mac には git がない。Command Line Tools が入るまで `/usr/bin/git` はインストールを
促すスタブなので、`git clone` から始めることはできない。そこで次の順に進める。

1. GitHub API で `main` の commit を調べ、その commit の tarball を取得先に展開する。
   取得した commit は `.bootstrap-commit` に記録する。
2. Homebrew を入れる。Homebrew のインストーラーが、sudo が使える場合に
   Command Line Tools を `softwareupdate` で入れる。
3. 取得先で `git init` し、`origin` を fetch して、記録した commit に `git reset` する。
   ファイルは tarball のまま、index だけが合う。最後に `.bootstrap-commit` を消す。
4. chezmoi がなければ `brew install chezmoi` で入れ、`chezmoi init --apply --source <取得先>`
   を実行する。設定ファイルの書き出しと導入スクリプトの実行は「chezmoi」の節を参照。

途中で失敗した場合は、同じコマンドを再実行する。`.bootstrap-commit` があれば
取得済みのファイルを使って続きから進める。手順 2 の後も git が使えないとき
（Homebrew だけが入っていて Command Line Tools がない Mac など）は、手順 3 で止まる。
`xcode-select --install` で Command Line Tools を入れてから再実行する。

`curl ... | bash` の形でも動く。その場合は標準入力が端末ではないため、Homebrew の
インストーラーが非対話モードになって sudo のパスワードを聞けない。これを避けるため、
Homebrew のインストーラーと chezmoi には `/dev/tty` をつないで実行する。ただし、端末から
`curl ... | bash` で起動する経路は実機で試していない（2026-11-05 時点）。README の
`/bin/bash -c "$(curl ...)"` は標準入力が端末のままなので、この問題が起きない。

取得方法は次の公開リポジトリを参考にした（2026-11-05 確認）。

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)：git を使わない
  インストールとして、tarball を `curl | tar` で展開する
- [Homebrew/install](https://github.com/Homebrew/install)：ワンライナーを
  `/bin/bash -c "$(curl -fsSL ...)"` の形にしている
- [chezmoi](https://www.chezmoi.io/install/)：`sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply`
  で取得と適用を1行で行う。この形は git での取得が前提なので、取得は tarball にし、
  適用だけを `chezmoi init --apply` にした

環境変数で次の値を変えられる。

| 変数 | 既定値 | 内容 |
|---|---|---|
| `DOTFILES_DIR` | `~/src/github.com/sasaron/dotfiles` | 取得先 |
| `DOTFILES_REF` | `main` | 取得するブランチ。作業ブランチを試すときに使う |

取得先がすでにあり、`origin` がこのリポジトリの git 作業コピーなら、そのまま使う。
それ以外のディレクトリがあれば何もせずに終了する。

同名の AI スキルは上書きしない。既存の dotfiles チェックアウトは自動更新しないため、
必要なら変更を確認してから手動で更新する。AI の認証情報と MCP 設定は自動復元しない。

## アプリ管理

`chezmoi apply` は Brewfile が変わったときに `manage-apps.sh install` を実行する。
日常の確認や更新は `manage-apps.sh` を直接使う。
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
`chezmoi apply` が `./bin/install-ai-skills.sh` を実行し、Codex と Claude Code の
ユーザー用 skills にリンクする。
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

VS Code の拡張機能、npm パッケージ、macOS の設定と、Codex 本体の設定は
この一覧の適用対象に含まれない。前の3つは `chezmoi apply` の導入スクリプトが扱う。
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

ホームに置く設定ファイルは `chezmoi/` の下にあり、`chezmoi apply` で実ファイルとして
書き出す。リポジトリの `.chezmoiroot` が `chezmoi/` を指している。

`chezmoi init --source <リポジトリ>` を一度実行すると、`chezmoi/.chezmoi.toml.tmpl` から
`~/.config/chezmoi/chezmoi.toml` が作られ、`sourceDir` がリポジトリの作業ツリーになる。
以後は `--source` なしで `chezmoi diff` や `chezmoi apply` を使える。

ホーム側のファイルは実ファイルなので、直接編集してもリポジトリには反映されない。
`chezmoi/` の元ファイルを編集して `chezmoi apply` するか、ホーム側を編集した後に
`chezmoi re-add` で取り込む。

### 管理するファイル

| ホーム | ソース |
|---|---|
| `~/.zshrc`、`~/.zsh_plugins.txt`、`~/.vimrc` | `chezmoi/dot_zshrc` など |
| `~/.config/starship.toml`、`zellij/`、`herdr/config.toml`、`commitlint/` | `chezmoi/dot_config/` |
| `~/.vscode/tasks.json` | `chezmoi/dot_vscode/tasks.json` |
| `~/changelog.config.js` | `chezmoi/changelog.config.js` |
| `~/bin/` の日常のコマンド | `chezmoi/bin/executable_*` |
| `~/.vim/autoload/plug.vim` | `chezmoi/.chezmoiexternal.toml`（vim-plug を取得し、168 時間ごとに取り直す） |

リポジトリの `bin/` に残したスクリプトは、導入スクリプトから呼ぶものと運用で使うもので、
`~/bin` には置かない。リポジトリから `./bin/...` で実行する。

VS Code の `settings.json`、`keybindings.json`、`snippets/` はリポジトリで管理していない。
グローバルの gitignore（`.vscode`）で除外され、GitHub にないためだ。

### 導入スクリプト

`chezmoi/.chezmoiscripts/` のスクリプトは、ホームにファイルを作らずに実行だけされる。
どれも `run_onchange_` で、レンダリング後の内容が変わったときだけ実行する。
対象ファイルのハッシュをコメントに埋めて、対象が変わったら再実行されるようにしている。

| スクリプト | 実行の契機 | 内容 |
|---|---|---|
| `before_10-brew-bundle` | `mac/Brewfile` の変更 | `bin/manage-apps.sh install`。設定ファイルより先に実行する |
| `after_20-vscode-extensions` | `bin/install-vscode-extensions.sh` の変更 | `code` があれば拡張機能を入れる |
| `after_30-npm-packages` | `mac/npm-packages.txt` の変更 | `npm` があればグローバルパッケージを入れる |
| `after_40-ai-skills` | `bin/install-ai-skills.sh` の変更 | `skills/` をリンクする。既存の同名は上書きしない |
| `after_50-macos-defaults` | スクリプト自身の変更 | スクリーンショットの保存先と `ghq.root` を設定する |

`install.sh` が入れていた oh-my-zsh は入れない。`.zshrc` は `oh-my-zsh.sh` を読み込んでおらず、
プラグインは antidote で読み込んでいるためだ。fzf は Brewfile に加えた。fzf の
`install --all` はシェルの設定ファイルに追記するので、実行しない。

### install.sh からの移行

`install.sh` で設定したマシンでは、ホームの設定ファイルがリポジトリへのシンボリックリンクに
なっていて、`~/bin` はリポジトリの `bin/` へのリンクになっている。`git pull` で元のファイルが
消えるとリンクが切れるので、次の手順を続けて実行する。

1. `brew install chezmoi` で chezmoi を入れる。`~/bin/chezmoi` は移行後に PATH から外れる
2. リポジトリで `git pull` する
3. `chezmoi init --source ~/src/github.com/sasaron/dotfiles` で設定を作る
4. `chezmoi diff` で差分を見る
5. `chezmoi apply` で反映する

隔離した HOME で、`install.sh` と同じリンクを張った状態から `chezmoi apply` を試した。
`~/bin` を含む全 9 か所のリンクが実ファイルか実ディレクトリに置き換わり、
リポジトリの `bin/` には書き込まれなかった（chezmoi v2.74.0、2026-11-05）。
このときの確認では、導入スクリプトは実行していない。

認証情報とローカルバックアップは chezmoi の対象外。
