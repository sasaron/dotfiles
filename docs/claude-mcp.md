# Claude Code MCP

## 採用する構成

| 名前 | 用途 | 実行方式 |
|---|---|---|
| terraform | Terraform provider/resource/moduleドキュメントの検索 | HashiCorp公式Dockerイメージ1.4.1 |
| awslabs.aws-iac-mcp-server | CloudFormation検証、AWS IaC資料、障害調査 | uvx @latest |
| aws-documentation | AWS公式ドキュメント検索 | uvx @latest |
| context7 | フレームワーク・ライブラリのドキュメント | HTTP /mcp |
| chrome-devtools | Web UIのデバッグ | npx -y @latest |

旧awslabs.cdk-mcp-serverは除外し、後継AWS IaCを導入します。
AWS IaCはTerraform専用ではありません。Terraformのスキーマ・provider調査は
Terraform MCP、AWSサービス仕様はAWS Documentationで補完します。

## 導入・更新

```bash
python3 bin/sync-claude-mcp.py
python3 bin/sync-claude-mcp.py --apply
```

既存の別名サーバー、プロジェクト固有設定、既存ヘッダー・環境変数を保持し、
一覧内のサーバー定義を更新します。削除対象は旧CDK専用サーバーの2つの名前だけです。
既存認証や環境変数も保持されるので、別の環境で適用後は接続先を確認してください。
設定変更前の ~/.claude.json 全体は local/ai/<日時>/ に権限600でバックアップします。
これは機密ファイルとして扱ってください。同時更新を検出した場合は中止します。
途中失敗で .claude.json.dotfiles-tmp が残った場合は、実行中の処理がないことを
確認し、その一時ファイルを削除して再実行してください。
Claude Code再起動後、/mcpで接続状態を確認できます。

uv・NodeとDockerランタイムが必要です。brewのdocker CLIだけではDocker Engineは
起動しません。利用中のDocker Desktop等を起動してください。
Terraformイメージは公式READMEの1.4.1へ固定しており、更新時はタグを見直します。
HCP Terraformトークン・AWS認証情報・ホストディレクトリ・Dockerソケットは
Terraformコンテナへ渡していません。ENABLE_TF_OPERATIONS=falseを明示しています。
AWS IaCの実環境調査には端末側のAWS認証と必要な参照権限が別途必要です。
@latestは起動時の取得指定であり、接続・取得成功を保証するものではありません。

## export

python3 bin/export-ai-settings.py は ~/.claude.json からユーザー単位と
プロジェクト単位のmcpServersだけを claude-mcp.private.json へ抽出します。
ヘッダーや環境変数が含まれるためGit管理外です。アカウント情報は抽出しません。
config/ai/claude/mcp.json は共有用の明示的な一覧なのでexportでは上書きしません。

## 最近の開発に合わせた追加候補

- GitHub：github-ghスキルでPR・Actions・Issueを調査する。
- Go：既存のgopls LSPが有効。現時点では類似MCPの追加を見送る。
- DB：RDS/PostgreSQLへ接続するMCPは、対象DBと読み取り権限を決めて
  プロジェクト単位で追加する。全プロジェクト共通の接続先にはしない。
- AWSリモートMCP：hakomichi限定の既存定義は保持。SigV4/OAuthを含めて別途確認。

## 一次情報

- https://github.com/hashicorp/terraform-mcp-server
- https://awslabs.github.io/mcp/servers/aws-iac-mcp-server
- https://awslabs.github.io/mcp/servers/aws-documentation-mcp-server
- https://github.com/upstash/context7/blob/master/packages/mcp/README.md
- https://github.com/ChromeDevTools/chrome-devtools-mcp
- https://github.com/github/github-mcp-server/blob/main/docs/installation-guides/install-claude.md
- https://code.claude.com/docs/en/mcp

## GitHubはghスキルで管理

PAT方式のGitHub MCPは削除しました。`skills/github-gh/SKILL.md` を
Claude CodeとCodexのユーザーskillsディレクトリへシンボリックリンクしています。
新しい端末でも同じスキルフォルダを両方へリンクしてください。
`gh auth login --hostname github.com --web` でログインし、追加PATを設定せず利用します。
既存のGitHub MCPを明示的に解除するコマンド：

```bash
python3 bin/sync-claude-mcp.py --remove-github --apply
```

## Terraform MCPのDocker以外の選択肢

1. 公式配布バイナリをPATHへ置き `terraform-mcp-server stdio` で実行する。
2. Goでビルドする。例：
   `go install github.com/hashicorp/terraform-mcp-server/cmd/terraform-mcp-server@v1.4.1`
3. HashiCorpのリモートMCP `https://mcp.terraform.io/mcp` を使う。
   HCP Terraformのトークン等を要するため、ローカル版とは認証条件が異なる。

このMacではGoがあるため、Dockerを不要にしたい場合はローカルバイナリ方式が
候補です。切り替える際はインストール先をPATHへ追加し、共有設定のterraformを
以下に置き換えてsyncスクリプトで反映します。現時点ではDocker版を保持しています。

```json
{
  "type": "stdio",
  "command": "terraform-mcp-server",
  "args": ["stdio"],
  "env": {"ENABLE_TF_OPERATIONS": "false"}
}
```

公式手順：https://developer.hashicorp.com/terraform/mcp-server/deploy/local

## Dockerfileの作成支援

Dockerfileの記述・マルチステージビルドの設計はClaude Codeのファイル編集と
Docker公式ドキュメントで進められます。追加候補のDocker Hub公式MCPは
ベースイメージ・タグ・対応アーキテクチャの調査を補完します。
Dockerfileの静的検査にはhadolint、実際の検証にはdocker buildを使います。
Dockerfileを書く目的だけでコンテナ操作用MCPを追加する必要はありません。
Docker関連MCPは今回自動追加していません。
