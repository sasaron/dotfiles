# dotfiles

macOS 用の個人設定。ホームに置く設定ファイルと、Homebrew のパッケージ、VS Code の拡張機能、
npm のパッケージ、AI スキル、Claude Code の MCP 設定を chezmoi で管理する。
Node、Go、Python、Go 製ツールと開発用の CLI の版は mise で固定する。

## 適用

新しい Mac では次の1行を実行する。git と Command Line Tools は事前に入れなくてよい。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sasaron/dotfiles/main/bootstrap.sh)"
```

その後は `chezmoi apply` で、リポジトリの内容を環境に反映する。何度実行してもよく、
足りないものだけを入れる。途中で失敗したものは、次の `chezmoi apply` でやり直される。

## 編集する場所

| 対象 | 場所 |
|---|---|
| ホームの設定ファイル | `chezmoi/`（`dot_zshrc` が `~/.zshrc` になる） |
| Homebrew のパッケージ | `mac/Brewfile` |
| VS Code の拡張機能、npm のパッケージ | `chezmoi/.chezmoidata/packages.yaml` |
| Node、Go、Python、Go 製ツール、開発用の CLI | `config/mise/config.toml` |
| AI スキル | `skills/` |
| Claude Code の MCP サーバー | `config/ai/claude/mcp.json` |

仕組みと注意点は [docs/operations.md](docs/operations.md) にある。
