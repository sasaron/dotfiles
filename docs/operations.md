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
| `after_15-git-hooks` | `.githooks/` | `core.hooksPath` がリポジトリの `.githooks` か。違うときだけ書き、hook の実行ビットも確かめる |
| `after_20-vscode-extensions` | `packages.yaml` の `vscode` | `code --list-extensions`（大文字と小文字を区別しない） |
| `after_25-claude-code` | スクリプト自身 | `~/.local/bin/claude` があるか。なければ公式の `install.sh` を実行する。更新は Claude Code の自動更新に任せる |
| `after_30-npm-packages` | `packages.yaml` の `npm` | `npm ls -g`。`@` で版を指定したものは版も比べる |
| `after_35-mise-tools` | `config/mise/config.toml` と `mise.lock` | `mise install --locked`。導入済みなら何もしない。buf と gitleaks の補完は毎回書き出す |
| `after_40-ai-skills` | `skills/` | 各スキルへのリンクがあるか。別の内容を持つ同名は残す |
| `after_45-claude-mcp` | `config/ai/claude/mcp.json` | `bin/sync-claude-mcp.py` が差分を調べる。差分がなければ書き込まない |
| `after_46-claude-settings` | `config/ai/claude/settings.json` の `permissions.ask`、`permissions.deny`、`hooks` | `bin/sync-claude-settings.py` が足りない規則とフックを調べる。差分がなければ書き込まない |
| `after_50-macos-defaults` | スクリプト自身 | `defaults read` と `git config --get` の値 |

Homebrew のスクリプトは設定ファイルより先に実行し、antidote などの依存を揃える。
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

### Homebrew で入れない cask

別の手段で入れて管理しているアプリは、`HOMEBREW_BUNDLE_CASK_SKIP` に cask 名を空白区切りで
挙げると飛ばせる。`brew bundle` の `check` と `install` がこの環境変数を読む
（Homebrew 7.0.12 の `Library/Homebrew/bundle/skipper.rb`、2026-11-05 確認）。
`check` が飛ばした cask を不足と数えないことは、未導入の cask を挙げて実行して確かめた。

`chezmoi init` のときにこの環境変数があれば、値を `~/.config/chezmoi/chezmoi.toml` の
`data.brewCaskSkip` に書く。環境変数なしで init し直しても前回の値を残す。
`before_10-homebrew` は、実行時に環境変数がなければこの値を使う。後から変えるときは
`chezmoi.toml` を直接書き換える。

```bash
# 新しい Mac で、Chrome、Slack、Claude を Homebrew で入れない
HOMEBREW_BUNDLE_CASK_SKIP="google-chrome slack claude" \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sasaron/dotfiles/main/bootstrap.sh)"
```

`curl ... | bash` の形では、環境変数を `bash` の側に付ける
（`curl ... | HOMEBREW_BUNDLE_CASK_SKIP="..." bash`）。

## 開発ツールのバージョン管理

Go、開発で使う Node と Python、Go 製の開発ツールと、開発用の CLI（awscli、buf、cmake、
gitleaks、grpcurl、protobuf）は mise で入れる。CLI は aqua バックエンドでビルド済みの
バイナリを落とす。設定は
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

Homebrew で入れていたときは、awscli、buf、gitleaks の zsh 補完が Homebrew の site-functions に
置かれていた。mise は補完を置かないので、次のように補う。buf と gitleaks は、
`after_35-mise-tools` が `~/.local/share/zsh/site-functions/` に書き出し、`.zshrc` がそこを
`fpath` に足す。起動のたびに `gitleaks completion zsh` を実行すると、シェルの起動が
0.11 秒から 0.30 秒に延びたため（2026-11-05 計測）。awscli は bash 形式の `aws_completer` を
`complete -C` で登録する。`compinit -C` はダンプが 24 時間以内なら作り直さないので、
初回は補完が出ないことがある。そのときは `rm ~/.zcompdump` してシェルを開き直す。

`go:` バックエンドは `go install -mod=readonly` でビルドする。goplay は v1.0.0 の go.mod に
依存が足りずに失敗するため、一覧から外した。deno は `pdf-viewer` が aqua.yaml で版を固定しているので、グローバルには
入れていない。golangci-lint は以前と同じモジュールパスに
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

export は `config/ai/claude/settings.json` の model、effortLevel、verbose だけを書き換える。
独自モデル名を含む可能性があるため、コミット前に差分を確認する。

設定を丸ごと chezmoi で書き出すと、アプリからの書き戻しで秘密やマシン固有設定が Git へ
混入し得る。そのため AI 設定は export 方式にして、自動では適用しない。認証は各端末でやり直す。
次のものだけは共有の宣言から統合する。どちらも足りないものを足すだけで、手元の設定は消さない。

- MCP サーバーの定義（`mcp.json`）。既存のサーバーの認証やヘッダーは残る
- 権限の `ask` と `deny`、フック（`settings.json`）。手で書き、export では書き換えない。
  `allow` は端末とリポジトリごとに違い、手元のパスを含むので共有しない

`deny` は、Claude が使わなくてよいものに限る。秘密の置き場所（`~/.ssh`、AWS と gh と
Docker の認証、`~/.npmrc` など）の読み取り、`sudo`、ホームとルートの `rm -rf`、ディスクの消去、
GitHub への公開（gist、issue、リポジトリの削除）を入れた。使うことはあるが取り返しにくいもの
（`rm -rf`、force push、`git reset --hard`、PR のマージ、`terraform apply`、AWS の削除など）と、
`.env` や鍵のファイルの読み取りは `ask` にした。

規則は deny、ask、allow の順に照合され、allow で deny や ask の例外は作れない
（[Configure permissions](https://code.claude.com/docs/en/permissions.md)）。
ask は auto mode でも確認を求める。Bash の規則はコマンドの文面で照合するので、
`/bin/rm` や `bash -c` で包んだ形は止まらない。`Read` の deny は Claude の道具と `cat` などの
コマンドには効くが、スクリプトが自分で開くファイルには効かない。どちらも防御の境界ではない。

フックは WebSearch の後に `web-grounding` スキルの手順を会話に入れる。

### Raycast と iTerm

両アプリは Brewfile で入るが、設定データは自動では適用しない。機密や端末固有の値を確認し、
必要なものを選んで移行する。

Raycast は、アプリの Export Settings & Data で暗号化された `.rayconfig` を作り、
移行先で Import Settings & Data を使う。チャットや履歴も含み得るため、
Git 管理外の安全な場所へ保存する。

iTerm は、`bin/export-iterm-settings.sh` で現在の preferences plist を `local/iterm/`
（Git 管理外）へバックアップできる。iTerm の全データの完全なバックアップではなく、
アプリ起動中の変更は最新状態になっていない場合がある。

### iTerm から nvim でファイルを開く

`~/bin/nvim-open <path> [line]` は、ファイルを iTerm の右側の分割ペインの nvim で開く。
Claude Code が表示したファイルパス（`src/a.ts:42` の形を含む）を Cmd+クリックして
nvim で開くために使う。右ペインの nvim は `~/.cache/nvim-open/nvim.sock` で待ち受け、
2 回目以降のクリックは同じ nvim で開いてペインにフォーカスを移す（ペインは増えない）。
右ペインの nvim を閉じるとペインも閉じ、次のクリックで分割し直す。
nvim は Brewfile で入り、`EDITOR` と `VISUAL` も nvim になるので、Claude Code の
Ctrl+G（入力欄を外部エディタで編集）も nvim で開く。

iTerm の設定は自動では適用しない（設定の実体は plist で、機密を含むためリポジトリに入れない。
後述の「iTerm の設定の export と import」を参照）。デフォルトのプロファイルに、
Settings の Profiles、Advanced、Semantic History で次のとおり設定する。日本語 UI では
「設定」の「プロファイル」、プロファイル内のタブ「詳細」、「セマンティック履歴」にある
（「設定」直下のタブ「詳細設定」は別物）。

1. 左のプルダウンを「Run command...」にする（日本語 UI では「コマンドを実行…」）
2. 右の欄に次を入れる。`~` は展開されない可能性があるため、絶対パスにする

   ```text
   /Users/<user>/bin/nvim-open "\1" "\2"
   ```

   `\1` がファイル名、`\2` が行番号。iTerm 3.7.7 の画面上の説明で確認した
3. 初回は、iTerm が Automation（iTerm の操作）の許可を求める場合がある

差分は `git difftool -t nvimdiff` で nvim の diff モードで見られる。

確認済みなのは、既存の nvim サーバーへ開く側（スペースと単引用符を含むパスで、行番号まで
移動する。2026-11-19、headless の nvim）。iTerm を分割する側と、Cmd+クリックからの呼び出しは
未確認。実機では、右に分割されること、2 回目で同じペインに開くことを確認する。

### nvim で Mermaid、Go、TypeScript を見る

設定は `config/nvim/init.lua` にあり、chezmoi が `~/.config/nvim` へリンクする。
プラグインは lazy.nvim で入れ、版は `config/nvim/lazy-lock.json` で固定する。
更新は nvim で `:Lazy update` を実行し、lazy-lock.json の差分を commit する。

| 用途 | 手段 | 外部コマンドの入れ先 |
|---|---|---|
| Mermaid、画像のインライン表示 | snacks.nvim の image。mermaid は `mmdc` で PNG にする | `imagemagick` は Brewfile、`@mermaid-js/mermaid-cli` は packages.yaml の npm |
| Go | gopls（`gd` で定義、`gr` で参照） | mise（config/mise/config.toml） |
| TypeScript | `tsc --lsp`（TypeScript 7 以降） | packages.yaml の npm の `typescript` |
| 文字列検索とジャンプ | snacks.nvim の picker（`git_grep`）。`<leader>/` で入力しながら検索、`<leader>*` でカーソル下の単語を検索 | `git` |
| 構文解析 | nvim-treesitter（初回起動時にパーサをコンパイルする） | `tree-sitter-cli` は Brewfile |

TypeScript の LSP に typescript-language-server を使わないのは、TypeScript 7.0.2 の
`lib` に `tsserver.js` がなく、server 6.1.0 が「Could not find a valid TypeScript
installation」で初期化に失敗したため（2026-11-19、この Mac で確認）。

snacks.nvim の対応端末は kitty、ghostty、wezterm で、iTerm は自動では認識されない
（ソースの `lua/snacks/image/terminal.lua`、2026-11-19 確認）。iTerm 3.7.7 は kitty
graphics protocol に対応しているため、init.lua は iTerm のときだけ `SNACKS_KITTY=true`
を設定して kitty として扱わせる。tmux の中では設定しない。

`mmd-show file.mmd` は、mermaid を PNG にして iTerm の OSC 1337 で表示する。nvim の
インライン表示が使えないときの代替で、tmux の中では表示されない。

確認済みなのは、headless の nvim で gopls と `tsc --lsp` が attach して定義ジャンプが
1 件返ること、Markdown の mermaid ブロックが snacks 経由で PNG になること、
`mmd-show` が OSC 1337 を出力すること。実機の iTerm 上の見た目は未確認で、
次を確かめる。herdr の中で画像が通るかも未確認。

1. mermaid の fenced block が、インライン画像として表示される
2. 表示されなければ `:checkhealth snacks` を見る

picker は git grep のためだけに有効にしている。`git grep` は追跡しているファイルだけを見るので、
node_modules や生成物が混ざらない。snacks の `git_grep` が `git grep --line-number --column
--no-color -I` を実行することは、ソース（`lua/snacks/picker/source/git.lua`、2026-11-20）で確認した。
headless の nvim で、`search` を渡すと結果が返ることまで試した。対話の見た目は未確認。
git の追跡外のファイルは対象外で、大文字小文字を区別する。

ImageMagick は外せない。snacks の変換は、PNG を作ったあとに `magick identify` で大きさを調べる。
`magick` がないとこの工程が `No command available` で失敗し、Mermaid も表示されない
（2026-11-20、snacks.nvim で確認）。ImageMagick は脆弱性の報告が多いので、`brew upgrade imagemagick`
で最新に保つ。信頼できない画像は nvim で開かない。

`:` から呼ぶ短いコマンドと、`<leader>`（スペース）のショートカットを用意している。
`/` は buffer 内検索なので上書きしていない。

| 操作 | コマンド | ショートカット |
| --- | --- | --- |
| git grep（引数なしなら入力しながら） | `:Gg [語]` | `<leader>/` |
| カーソル下の単語を git grep | | `<leader>*` |
| 追跡ファイルを探す | `:Gf` | `<leader>p` |
| 開いているバッファ | `:Gb` | `<leader>b` |

新しい Mac では mmdc が使う Chrome が必要になる。mermaid-cli の puppeteer は postinstall
で Chrome を取得するが、npm の `allowScripts` に止められた場合は
`npx puppeteer browsers install chrome-headless-shell` で入れる。

Markdown 本体は整形せず、そのまま表示する。render-markdown.nvim は一度入れたが、
表や見出しの整形表示が見にくく、2026-11-20 に外した。

### iTerm の設定の export と import

この Mac の iTerm は、Settings の General → Settings で「Load settings from a custom
folder」が有効で、`~/Documents/iTerm2` の plist を読み書きしている（2026-11-19 確認）。
別の Mac へ移すときは、同じ設定でフォルダを指定すれば、プロファイルを含む全設定が入る。
このフォルダの plist には本番環境のホスト名やトリガーが入るため、リポジトリ（PUBLIC）には
入れない。このフォルダが iCloud などで同期されているかは未確認。移すときは、手でコピーするか別の安全な場所に置く。

Semantic History などの設定は、この plist に保存される。変更したら
`bin/export-iterm-settings.sh` で `local/iterm/`（Git 管理外）にバックアップする。

### コミットの規約と hook

コミットメッセージは Conventional Commits にする。`type(scope): subject` の形で、`scope` は省略できる。
規則は `chezmoi/dot_config/commitlint/commitlint.config.js` にある。

- type は `build`、`chore`、`ci`、`docs`、`feat`、`fix`、`perf`、`refactor`、`revert`、`style`、`test`
- subject は空にせず、先頭を大文字にせず、末尾にピリオドを付けない。`Neovim` のような固有名詞は途中なら使える。日本語でもよい
- 1 行目は 72 文字まで。本文と脚注の前は空行を空ける

hook は `.githooks/` にあり、`after_15-git-hooks` が `core.hooksPath` で有効にする。

| hook | 内容 |
|---|---|
| `pre-commit` | git-secrets でステージした内容を調べる |
| `prepare-commit-msg` | git-secrets |
| `commit-msg` | git-secrets と commitlint。commitlint がなければ警告して通す |

`core.hooksPath` を使うと `.git/hooks` の中身は呼ばれなくなる。以前の `.git/hooks` は git-secrets の
3 つだけで、`.githooks` に移してある。GitHub のマージコミット（`Merge pull request ...`）は
commitlint の既定で対象外になる。

規則は 2026-11-20 に commitlint 19.8.0 で試した。`feat(nvim): add a Neovim config` は通り、
`Add a Neovim config`（type なし）、`docs: Update operations`（先頭が大文字）、末尾のピリオド、
73 文字以上の 1 行目は拒否される。それ以前の履歴は英語の命令形で type がなく、書き換えない。

config の `extends: ['@commitlint/config-conventional']` は使わない。commitlint は extends を
設定ファイルの場所から解決し、`~/.config/commitlint` からは見つからず、設定が読めないまま
規約が効いていなかったため、規則をすべて書いた。
