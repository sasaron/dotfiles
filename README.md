# dotfiles

macOS 用の個人設定ファイル。chezmoi でホームに設定ファイルを書き出し、
Homebrew のパッケージや VS Code の拡張機能などの導入も chezmoi のスクリプトで行う。

主な構成は次のとおり。

- シェル：zsh、antidote、Starship
- ターミナル：zellij、herdr、iTerm
- CLI：eza、bat、bottom、dust、duf、fzf
- AI ツール：Claude Code と Codex のスキル、Claude Code の MCP 設定

## セットアップ

新しい Mac では次の1行を実行する。git と Command Line Tools は事前に入れなくてよい。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sasaron/dotfiles/main/bootstrap.sh)"
```

リポジトリを tarball で `~/src/github.com/sasaron/dotfiles` に取得し、Homebrew を入れて
git の作業コピーに変えてから、`chezmoi init --apply` を実行する。途中で sudo の
パスワードを聞かれる。実行前に中身を読みたい場合は、ファイルに保存してから実行する。

```bash
curl -fsSLo /tmp/dotfiles-bootstrap.sh https://raw.githubusercontent.com/sasaron/dotfiles/main/bootstrap.sh
less /tmp/dotfiles-bootstrap.sh
bash /tmp/dotfiles-bootstrap.sh
```

## 日常の操作

設定は `chezmoi/` の下のファイルを編集して、`chezmoi apply` でホームへ反映する。
ホーム側のファイルを直接書き換えた場合は、`chezmoi re-add` でリポジトリに取り込む。

| コマンド | 内容 |
|---|---|
| `chezmoi diff` | ホームとリポジトリの差分を見る |
| `chezmoi apply` | 設定を反映し、変更のあった導入スクリプトを実行する |
| `chezmoi re-add` | ホーム側で編集したファイルをリポジトリに取り込む |
| `./bin/manage-apps.sh check` | Brewfile のうち未導入のアプリを確認する |
| `python3 bin/sync-claude-mcp.py --apply` | Claude Code の MCP 設定を反映する |
| `python3 ./bin/export-ai-settings.py` | Claude と Codex の設定を `local/` へ export する |

## ディレクトリ

| パス | 内容 |
|---|---|
| `chezmoi/` | chezmoi のソース。ホームに置く設定ファイルと導入スクリプト |
| `mac/` | Brewfile と npm パッケージ一覧 |
| `bin/` | 導入スクリプトから呼ぶ処理と、運用のスクリプト |
| `config/` | AI 設定と `environment.json` |
| `skills/` | Claude Code と Codex のスキル |
| `docs/` | 運用の詳細と設計メモ |

各コマンドの挙動と注意点は [docs/operations.md](docs/operations.md)、
管理方法の比較は [docs/environment-management.md](docs/environment-management.md)、
MCP の構成は [docs/claude-mcp.md](docs/claude-mcp.md) にある。
