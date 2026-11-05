# chezmoi を Homebrew の PATH が通っていないシェルから実行しても動くようにする
if ! command -v brew >/dev/null 2>&1; then
  for prefix in /opt/homebrew /usr/local; do
    if [ -x "$prefix/bin/brew" ]; then
      eval "$("$prefix/bin/brew" shellenv)"
      break
    fi
  done
fi
