# 運用の詳細

このリポジトリは、`chezmoi apply` を何度実行しても同じ環境に収束するように作っている。
ここでは、その仕組みと、chezmoi の対象にしていないものを書く。

## chezmoi apply がすること

ホームに置く設定ファイルは `chezmoi/` の下にあり、実ファイルとして書き出す。
リポジトリの `.chezmoiroot` が `chezmoi/` を指している。`chezmoi/.chezmoi.toml.tmpl` が
`sourceDir` を作業ツリーに設定するので、一度 `chezmoi init` した後は `--source` を付けなくてよい。

ホーム側のファイルは実ファイルなので、直接編集してもリポジトリには反映されない。
`chezmoi/` の元ファイルを編集するか、ホーム側の変更を `chezmoi re-add` で取り込む。

導入手順は `chezmoi/.chezmoiscripts/` のスクリプトで、どれも `run_` にして apply のたびに
実行する。各スクリプトは今の状態を調べ、足りないものだけを入れる。

| スクリプト | 宣言の場所 | 状態の調べ方 |
|---|---|---|
| `before_10-homebrew` | `mac/Brewfile` | `brew bundle check --no-upgrade`。不足があれば `brew bundle install --no-upgrade` |
| `after_20-vscode-extensions` | `packages.yaml` の `vscode` | `code --list-extensions`（大文字と小文字を区別しない） |
| `after_30-npm-packages` | `packages.yaml` の `npm` | `npm ls -g`。`@` で版を指定したものは版も比べる |
| `after_35-mise-tools` | `config/mise/config.toml` と `mise.lock` | `mise install --locked`。導入済みなら何もしない |
| `after_40-ai-skills` | `skills/` | 各スキルへのリンクがあるか。別の内容を持つ同名は残す |
| `after_45-claude-mcp` | `config/ai/claude/mcp.json` | `bin/sync-claude-mcp.py` が差分を調べる。差分がなければ書き込まない |
| `after_50-macos-defaults` | スクリプト自身 | `defaults read` と `git config --get` の値 |

Homebrew のスクリプトは設定ファイルより先に実行し、starship や antidote などの依存を揃える。
`packages.yaml` は chezmoi の [declarative なパッケージ導入](https://www.chezmoi.io/user-guide/advanced/install-packages-declaratively/)
の形に倣った。ただし、そこで使われている `run_onchange_` は一度成功すると内容が変わるまで
再実行されない。コマンドがなかったときのスキップや一部の失敗が残るので、`run_` にした。

1つでも導入に失敗したスクリプトは終了コードを非ゼロにする。chezmoi はそこで apply を止めるので、
原因を直してもう一度 `chezmoi apply` を実行する。`code`、`npm`、`mise` がまだないときは
警告だけを出して先へ進み、次の apply で入れる。

導入済みのものを確かめるコマンドは apply のたびに動く。すべて揃っていても、
`brew bundle check`、`code --list-extensions`、`npm ls -g` の分だけ時間がかかる。

更新はしない。Homebrew は `--no-upgrade` で入れ、npm のパッケージも、入っていれば
版を上げない（版を指定したものを除く）。mise のツールは `mise.lock` の版で入る。削除もしないので、一覧から外したものは
手で消す。

## 開発ツールのバージョン管理

Go、開発で使う Node と Python、Go 製の開発ツールは mise で入れる。設定は
[config/mise/config.toml](../config/mise/config.toml) にあり、解決した版とチェックサムは
`config/mise/mise.lock` に残る。`chezmoi/dot_config/symlink_mise.tmpl` が `~/.config/mise` を
このディレクトリへのリンクにする。

```bash
mise install --locked     # mise.lock の版で入れる（chezmoi apply でも実行される）
mise lock --global        # config.toml にツールを足したあと lock を作り直す
mise upgrade --bump       # 更新する。mise.lock の差分を確認して commit する
```

ほかの設定ファイルと違って実ファイルにせずリンクにしたのは、mise が `mise.lock` を
`~/.config/mise/` に書き戻すため。実ファイルだと lock の更新がリポジトリに戻らない。
mise 2026.9.8 で、`config.toml` だけをリンクすると `mise lock --global` は lock をリンク先では
なく `~/.config/mise/` に書いた。グローバル設定に `lockfile = true` を書いても、
`mise install` は lock を作らなかった（2026-11-05 確認）。そのためディレクトリごとリンクする。

既存の Mac で `~/.config/mise` が通常のディレクトリになっていると、`chezmoi apply` は
それを削除してリンクに置き換える。隔離した HOME で `--no-tty` を付けて試すと、確認なしで
置き換わった（chezmoi v2.74.0、2026-11-05）。中の設定を残したいときは、apply の前に
`chezmoi diff` で確かめて退避する。

Homebrew の `node` と `uv` は残している。Claude デスクトップなどの GUI アプリは
`mise activate` を通らずに MCP サーバー（`npx`、`uvx`）を起動するため、その経路用の既定として使う。
シェルでは mise が PATH の先頭に入るので、`node` と `npx` は mise 版が見つかる。
グローバルの npm パッケージ（`packages.yaml` の `npm`）は、`after_30-npm-packages` が
Homebrew の Node に入れる。

`go:` バックエンドは `go install -mod=readonly` でビルドする。goplay は v1.0.0 の go.mod に
依存が足りずに失敗するため、一覧から外した。golangci-lint は以前と同じモジュールパスに
してあるので v1 系（v1.64.8）になる。

## 新しい Mac での bootstrap

`bootstrap.sh` は、git がない Mac でも動くように次の順に進める。再実行してもよい。

1. GitHub API で `main` の commit を調べ、その commit の tarball を
   `~/src/github.com/sasaron/dotfiles` に展開する。commit は `.bootstrap-commit` に記録する
2. Homebrew を入れる。Homebrew のインストーラーが、sudo が使える場合に
   Command Line Tools を `softwareupdate` で入れる
3. 取得先で `git init` し、`origin` を fetch して、記録した commit に `git reset` する。
   ファイルは tarball のまま index だけが合い、`.bootstrap-commit` を消す
4. `chezmoi init --apply --source <取得先>` を実行する

取得先がすでにこのリポジトリの作業コピーなら、手順 1 と 3 を飛ばす。git の状態は変えない。
`.bootstrap-commit` があれば、取得済みのファイルを使って続きから進める。
Homebrew だけが入っていて Command Line Tools がない Mac では手順 3 で止まるので、
`xcode-select --install` の後で再実行する。

`curl ... | bash` で起動すると標準入力が端末ではなく、Homebrew のインストーラーが sudo の
パスワードを聞けない。そのため Homebrew のインストーラーと chezmoi には `/dev/tty` をつなぐ。
この経路は実機で試していない（2026-11-05 時点）。README の `/bin/bash -c "$(curl ...)"` は
標準入力が端末のままなので、この問題が起きない。

`DOTFILES_DIR` で取得先を、`DOTFILES_REF` で取得するブランチを変えられる。

取得方法は [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) の git を使わない
インストールと、[Homebrew/install](https://github.com/Homebrew/install) のワンライナーの形に倣った
（2026-11-05 確認）。

## install.sh からの移行

`install.sh` で設定したマシンでは、ホームの設定ファイルと `~/bin` がリポジトリへの
シンボリックリンクになっている。`git pull` で元のファイルが消えるとリンクが切れるので、
pull したらすぐに bootstrap を再実行する。

`chezmoi apply` はリンクを実ファイルに置き換える。隔離した HOME で `install.sh` と同じリンクを
張って試したところ、`~/bin` を含む 9 か所が置き換わり、リポジトリの `bin/` には書き込まれ
なかった（chezmoi v2.74.0、2026-11-05）。リポジトリの `bin/` に置いていた chezmoi のバイナリは
PATH から外れるが、Brewfile の chezmoi が入るので困らない。

## chezmoi の対象にしていないもの

VS Code の `settings.json`、`keybindings.json`、`snippets/` は管理していない。グローバルの
gitignore（`.vscode`）で除外され、GitHub にないため。`bin/export-vscode-settings.sh` は
これらを Git 管理外の `config/.vscode/` にコピーする。

oh-my-zsh は入れない。`.zshrc` は `oh-my-zsh.sh` を読み込んでおらず、プラグインは antidote で
読み込んでいる。fzf は Brewfile で入れ、シェルの設定ファイルに追記する `install --all` は使わない。

### Claude と Codex の設定

`bin/export-ai-settings.py` は、`local/ai/<日時>/` に Claude の `settings.json` と `CLAUDE.md`、
Codex の `config.toml` と `AGENTS.md` を、存在する分だけコピーする。Codex は `CODEX_HOME` が
あればそちらを参照する。

`local/` は Git 管理外。設定内の環境変数、MCP、hook に秘密が入る可能性があるため、
バックアップは秘密情報と同様に扱う（ファイル権限 600）。次のものは export しない。

- `auth.json`、`.credentials.json`、`.claude.json`
- Keychain
- 履歴、セッション、キャッシュ
- プラグイン本体と skills

`config/ai/claude/settings.json` には model、effortLevel、verbose だけを書き出す。
独自モデル名を含む可能性があるため、コミット前に差分を確認する。

設定を丸ごと chezmoi で書き出すと、アプリからの書き戻しで秘密やマシン固有設定が Git へ
混入し得る。そのため AI 設定は export 方式にして、自動では適用しない。認証は各端末でやり直す。
MCP サーバーの定義だけは `mcp.json` から統合する。既存のサーバーの認証やヘッダーは残る。

### Raycast と iTerm

両アプリは Brewfile で入るが、設定データは自動では適用しない。機密や端末固有の値を確認し、
必要なものを選んで移行する。

Raycast は、アプリの Export Settings & Data で暗号化された `.rayconfig` を作り、
移行先で Import Settings & Data を使う。チャットや履歴も含み得るため、
Git 管理外の安全な場所へ保存する。

iTerm は、`bin/export-iterm-settings.sh` で現在の preferences plist を `local/iterm/`
（Git 管理外）へバックアップできる。iTerm の全データの完全なバックアップではなく、
アプリ起動中の変更は最新状態になっていない場合がある。
