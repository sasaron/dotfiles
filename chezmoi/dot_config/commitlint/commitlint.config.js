// Conventional Commits の規約。リポジトリの .githooks/commit-msg がこのファイルを
// --config で指定して呼ぶ。commitlint は ~/.config を探さないうえ、extends は
// 設定ファイルの場所から解決され @commitlint/config-conventional が見つからないので、
// extends を使わず規則をすべてここに書く。
module.exports = {
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'build',
        'chore',
        'ci',
        'docs',
        'feat',
        'fix',
        'perf',
        'refactor',
        'revert',
        'style',
        'test'
      ]
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    // 先頭を大文字にしない。Neovim や Mermaid のような固有名詞は途中なら使える
    'subject-case': [2, 'never', ['sentence-case', 'start-case', 'pascal-case', 'upper-case']],
    'header-max-length': [2, 'always', 72],
    'body-leading-blank': [2, 'always'],
    'footer-leading-blank': [2, 'always']
  }
};
