#!/bin/bash
# 新しい Mac の初回セットアップ。git がまだない状態でも動くように、リポジトリは
# tarball で取得する。Homebrew のインストーラーが Command Line Tools を入れた後で、
# 取得したディレクトリを git の作業コピーに変える。
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sasaron/dotfiles/main/bootstrap.sh)"
#
# curl ... | bash でも動くが、その場合は標準入力が端末ではないので、
# install.sh には /dev/tty をつなぐ。
set -euo pipefail

repository_slug="sasaron/dotfiles"
repository="https://github.com/${repository_slug}.git"
ref="${DOTFILES_REF:-main}"
destination="${DOTFILES_DIR:-$HOME/src/github.com/sasaron/dotfiles}"
# tarball で取得したことと、その commit を記録する。git の作業コピーに変えたら消す
marker=".bootstrap-commit"

is_expected_origin() {
  case "$1" in
    https://github.com/sasaron/dotfiles|https://github.com/sasaron/dotfiles.git) return 0 ;;
    git@github.com:sasaron/dotfiles|git@github.com:sasaron/dotfiles.git) return 0 ;;
    *) return 1 ;;
  esac
}

# Command Line Tools がない Mac の /usr/bin/git は、インストールを促すスタブなので使えない
has_git() {
  xcode-select -p >/dev/null 2>&1 && git --version >/dev/null 2>&1
}

download_tarball() {
  local commit tmp
  commit="$(curl -fsSL -H 'Accept: application/vnd.github.sha' \
    "https://api.github.com/repos/${repository_slug}/commits/${ref}")" || commit=""
  if ! [[ "$commit" =~ ^[0-9a-f]{40}$ ]]; then
    echo "Could not resolve ${ref} to a commit." >&2
    exit 1
  fi

  mkdir -p "$(dirname "$destination")"
  # 展開に失敗したときに途中のディレクトリを残さないよう、隣で展開してから移す
  tmp="$(mktemp -d "$(dirname "$destination")/.dotfiles.XXXXXX")"
  # tmp は関数のローカル変数なので、trap の設定時に展開しておく
  trap "rm -rf '$tmp'" EXIT
  echo "Downloading ${repository_slug}@${commit}"
  curl -fsSL "https://codeload.github.com/${repository_slug}/tar.gz/${commit}" |
    tar -xz -C "$tmp" --strip-components 1
  echo "$commit" >"$tmp/$marker"
  mv "$tmp" "$destination"
  trap - EXIT
}

prepare_destination() {
  if [ -f "$destination/$marker" ]; then
    echo "Resuming with the previously downloaded files: $destination"
    return
  fi

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    if ! has_git; then
      echo "Destination exists, but Git is unavailable to inspect it: $destination" >&2
      exit 1
    fi
    if ! git -C "$destination" rev-parse --show-toplevel >/dev/null 2>&1 ||
       [ "$(git -C "$destination" rev-parse --show-toplevel)" != "$(cd "$destination" && pwd -P)" ]; then
      echo "Destination exists but is not a repository root: $destination" >&2
      exit 1
    fi
    if ! is_expected_origin "$(git -C "$destination" remote get-url origin 2>/dev/null || true)"; then
      echo "Unexpected origin at $destination; refusing to run its installer." >&2
      exit 1
    fi
    echo "Using existing checkout without changing its Git state: $destination"
    return
  fi

  download_tarball
}

run_setup() {
  if [ ! -f "$destination/install.sh" ] || [ ! -f "$destination/bin/install-ai-skills.sh" ]; then
    echo "Setup files are missing. Update the checkout after reviewing its local changes." >&2
    exit 1
  fi

  echo "Running setup from $destination"
  # Homebrew のインストーラーは標準入力が端末でないと非対話モードになり、sudo の
  # パスワードを聞かずに失敗する。curl ... | bash で起動されたときは端末をつなぐ
  if [ ! -t 0 ] && (: </dev/tty) 2>/dev/null; then
    bash "$destination/install.sh" </dev/tty
  else
    bash "$destination/install.sh"
  fi
  bash "$destination/bin/install-ai-skills.sh"
}

# 取得した commit を HEAD にして、ファイルはそのまま index だけを合わせる
convert_to_checkout() {
  local commit
  [ -f "$destination/$marker" ] || return 0
  if ! has_git; then
    echo "Git is still unavailable. Rerun this script after installing Command Line Tools" \
      "to turn $destination into a Git checkout." >&2
    return 0
  fi

  commit="$(cat "$destination/$marker")"
  # 前回の変換が途中で止まっていても続きから進められるようにする
  [ -d "$destination/.git" ] || git -C "$destination" init -q -b "$ref"
  git -C "$destination" remote add origin "$repository" 2>/dev/null ||
    git -C "$destination" remote set-url origin "$repository"
  git -C "$destination" fetch -q origin
  git -C "$destination" cat-file -e "${commit}^{commit}" 2>/dev/null ||
    git -C "$destination" fetch -q origin "$commit"
  git -C "$destination" reset -q "$commit"
  git -C "$destination" branch -q --set-upstream-to "origin/$ref" 2>/dev/null || true
  rm -f "$destination/$marker"
  echo "Converted $destination into a Git checkout of ${ref}."
}

main() {
  if [ "$(uname -s)" != Darwin ]; then
    echo "This setup currently supports macOS only." >&2
    exit 1
  fi

  prepare_destination
  run_setup
  convert_to_checkout
  echo "Bootstrap complete. Restart your terminal."
}

# curl ... | bash では本文を読みながら実行するので、途中で切れたダウンロードを
# 実行しないよう、全体を読み終えてから main を呼ぶ
main "$@"
