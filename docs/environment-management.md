# 開発環境の管理方法（2026-11-02）

## 提案

当面はHomebrew＋既存dotfilesで整理し、複数端末の差分が増えたらchezmoi、
プロジェクトごとのNode/Go/Python切り替えが必要ならmiseを追加するのを推奨します。
開発環境を厳密に再現したいプロジェクトでNix devShellを試し、効果が確認できたら
Mac全体をnix-darwinへ広げる順序が、このリポジトリでは移行負荷を抑えられます。
以下の運用負荷は現在の構成を基にした判断です。

| 方法 | 主に管理するもの | 強み | 負荷・制約 | 向いている用途 |
|---|---|---|---|---|
| Homebrew＋シェル | Macアプリ、CLI、リンク | 現状を活用、GUIアプリを導入しやすい | バージョンの厳密な再現や端末差分は自前 | Mac中心で簡単に運用 |
| Homebrew＋GNU Stow | アプリ＋設定のリンク | リンク作成を標準ツールに任せられる | テンプレートや秘密管理は別途必要 | 端末差分が少ない設定 |
| Homebrew＋chezmoi | アプリ＋設定ファイル | 端末別テンプレート、差分確認、秘密管理との連携 | ファイル命名・テンプレートを学ぶ必要 | 複数Mac、仕事用と個人用 |
| Homebrew＋mise | GUIアプリ＋開発ツールのバージョン | プロジェクト単位でランタイムを切り替え | OS設定やdotfilesは別管理、バックエンド差あり | Node/Go/Pythonのバージョン共存 |
| Nix devShell＋Homebrew | 開発依存＋Macアプリ | lockで依存を固定し、プロジェクト環境を共有 | Nix学習と依存追加の作業、OS全体は対象外 | チーム・CIとの再現性 |
| Nix＋nix-darwin＋Home Manager | CLI、ユーザー設定、Macの一部設定 | 宣言的な構成を広範囲に適用 | 初期移行と保守が大きい。GUIはHomebrew併用も必要 | 環境構築自体をコード化したい |

NixでもGUIアプリ、ログイン情報、Keychain、アプリ内部状態まで全て同じになる
わけではありません。Homebrew連携部分はNixストア内の依存と同じ再現性ではありません。
また、Nixで管理するファイルと既存install.shのリンク作成を競合させない設計が必要です。

## このリポジトリで先に解消したい点

- インストール・更新・exportを分離する（今回追加）。
- Claude Codeの古いnpm固定版をHomebrew Cask一覧へ移す（今回変更）。
- AI設定は機密を含み得るローカルexportと共有対象を分ける（今回追加）。
- bin内にGoバイナリが存在する。今後はツール名とバージョンを一覧化し、
  バイナリ自体をコミットせず再生成する方式へ整理する。
  → Goツールは config/mise/config.toml と mise.lock へ移した（2026-11-05）。
- Brewfile内の直接必要なCLIと依存ライブラリを見直す。
  現時点では用途を確認せず削除しない。
- Node/Goをmiseへ移す場合は、BrewfileとPATHの管理元を同時に整理する。
  → 移行済み（2026-11-05）。詳細は operations.md の「開発ツールのバージョン管理」。
- skills・agents・hooksを共有する場合は内容と依存コマンドを確認して個別追加する。

## 参照

- Homebrew: https://docs.brew.sh/Brew-Bundle-and-Brewfile
- Stow: https://www.gnu.org/software/stow/
- chezmoi: https://www.chezmoi.io/why-use-chezmoi/
- mise: https://mise.jdx.dev/dev-tools/
- nix-darwin: https://github.com/nix-darwin/nix-darwin
- Home Manager: https://nix-community.github.io/home-manager/
- Claude settings: https://code.claude.com/docs/en/settings
- Codex configuration: https://learn.chatgpt.com/docs/config-file/config-reference
