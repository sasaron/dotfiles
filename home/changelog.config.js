module.exports = {
  disableEmoji: false,
  format: '{type}: {subject}',
  list: ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert'],
  maxMessageLength: 50,
  minMessageLength: 3,
  questions: ['type', 'subject'],
  types: {
    chore: {
      description: 'ビルドプロセスや補助ツールの変更',
      value: 'chore'
    },
    ci: {
      description: 'CI関連の変更',
      value: 'ci'
    },
    docs: {
      description: 'ドキュメントのみの変更',
      value: 'docs'
    },
    feat: {
      description: '新機能の追加',
      value: 'feat'
    },
    fix: {
      description: 'バグ修正',
      value: 'fix'
    },
    perf: {
      description: 'パフォーマンスを改善するコード変更',
      value: 'perf'
    },
    refactor: {
      description: 'バグ修正や機能追加のないコードリファクタリング',
      value: 'refactor'
    },
    style: {
      description: 'マークアップ、空白、フォーマット、セミコロンなどの修正',
      value: 'style'
    },
    test: {
      description: 'テストの追加・修正',
      value: 'test'
    },
    build: {
      description: 'ビルドシステムに影響する変更',
      value: 'build'
    },
    revert: {
      description: '以前のコミットの取り消し',
      value: 'revert'
    }
  }
};