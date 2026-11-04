# dotfiles

macOS 用の個人設定ファイル。Homebrew でアプリを入れ、`install.sh` で設定ファイルを
シンボリックリンクする。Starship の設定は chezmoi で管理する。

主な構成は次のとおり。

- シェル：zsh、oh-my-zsh、antidote、Starship
- ターミナル：zellij、herdr、iTerm
- CLI：eza、bat、bottom、dust、duf
- AI ツール：Claude Code と Codex のスキル、Claude Code の MCP 設定

## セットアップ

新しい Mac では、スクリプトを取得して内容を確認してから実行する。

```bash
curl -fsSLo /tmp/dotfiles-bootstrap.sh https://raw.githubusercontent.com/sasaron/dotfiles/main/bootstrap.sh
less /tmp/dotfiles-bootstrap.sh
bash /tmp/dotfiles-bootstrap.sh
```

クローン済みなら `./bootstrap.sh` を実行する。リポジトリを更新した後は `./install.sh` で
リンクを張り直す。

## 主なコマンド

| コマンド | 内容 |
|---|---|
| `./bin/manage-apps.sh check` | Brewfile のうち未導入のアプリを確認する |
| `./bin/manage-apps.sh install` | 不足しているアプリを入れる |
| `python3 bin/environment.py apply` | `config/environment.json` の構成要素を適用する |
| `python3 bin/sync-claude-mcp.py --apply` | Claude Code の MCP 設定を反映する |
| `./bin/install-ai-skills.sh` | `skills/` を Claude Code と Codex にリンクする |
| `python3 ./bin/export-ai-settings.py` | Claude と Codex の設定を `local/` へ export する |
| `chezmoi --source "$PWD" apply` | Starship の設定を反映する |

## ディレクトリ

| パス | 内容 |
|---|---|
| `config/` | `.zshrc`、`.vimrc`、VS Code、AI 設定 |
| `home/` | zellij、herdr、commitlint などのアプリ設定 |
| `chezmoi/` | chezmoi で管理する設定 |
| `mac/` | Brewfile と npm パッケージ一覧 |
| `bin/` | セットアップと運用のスクリプト |
| `skills/` | Claude Code と Codex のスキル |
| `docs/` | 運用の詳細と設計メモ |

各コマンドの挙動と注意点は [docs/operations.md](docs/operations.md)、
管理方法の比較は [docs/environment-management.md](docs/environment-management.md)、
MCP の構成は [docs/claude-mcp.md](docs/claude-mcp.md) にある。
