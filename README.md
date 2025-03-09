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

## インストール方法

```bash
git clone https://github.com/sasaron/dotfiles.git
cd dotfiles
./install.sh
```

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
- `home/alacritty/alacritty.yml` - Alacrittyの設定
- `home/starship/starship.toml` - Starshipの設定
- `home/zellij/config.kdl` - Zellijの設定
- `mac/Brewfile` - Homebrewでインストールするパッケージリスト

## 更新方法

リポジトリを更新した後、以下のコマンドを実行してください：

```bash
./install.sh
