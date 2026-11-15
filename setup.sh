#!/usr/bin/env bash
# dotfiles の初回セットアップ（WSL / Linux / macOS）
#
# 1. Nix をインストールする（マルチユーザー版）
# 2. flakes を有効にする
# 3. このリポジトリを ~/ghq/github.com/touka-aoi/dotfiles に置く
# 4. Home Manager で設定を反映する
# 5. Nix の zsh をログインシェルにする
#
# 終わっている手順は飛ばすので、何度実行してもよい。
# sudo が必要な手順ではパスワードを聞かれる。
set -euo pipefail

REPO_URL="https://github.com/touka-aoi/dotfiles.git"
REPO_DIR="$HOME/ghq/github.com/touka-aoi/dotfiles"
NIX_CONF="/etc/nix/nix.conf"
NIX_DAEMON_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
ZSH_PATH="$HOME/.nix-profile/bin/zsh"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
fail() { printf '\033[1;31mエラー: %s\033[0m\n' "$*" >&2; exit 1; }

# ---- 対象マシンの判定 ----
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) TARGET="touka@wsl" ;;
  Darwin-arm64) TARGET="touka@mac" ;;
  *) fail "未対応の環境です: $(uname -s) $(uname -m)（flake.nix に定義を追加してください）" ;;
esac
IS_WSL=false
if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
fi
info "対象: $TARGET"

# ---- 1. Nix ----
step "1/5 Nix のインストール"
if [[ -e "$NIX_DAEMON_PROFILE" ]]; then
  info "インストール済みなので飛ばします"
else
  if [[ "$(uname -s)" == Linux && "$(ps -p 1 -o comm= 2>/dev/null)" != systemd ]]; then
    if $IS_WSL; then
      fail "systemd が無効です。/etc/wsl.conf に [boot] systemd=true を書き、Windows 側で wsl --shutdown してから再実行してください"
    fi
    fail "systemd が動いていません。マルチユーザー版の Nix には systemd が必要です"
  fi
  installer="$(mktemp)"
  curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o "$installer"
  sh "$installer" --daemon
  rm -f "$installer"
fi
# このスクリプトの中で nix を使えるようにする
# shellcheck disable=SC1090
. "$NIX_DAEMON_PROFILE"

# ---- 2. flakes ----
step "2/5 flakes の有効化"
if grep -Eq '^\s*(extra-)?experimental-features\s*=.*flakes' "$NIX_CONF" 2>/dev/null; then
  info "有効化済みなので飛ばします"
else
  echo "experimental-features = nix-command flakes" | sudo tee -a "$NIX_CONF" >/dev/null
  if [[ "$(uname -s)" == Darwin ]]; then
    sudo launchctl kickstart -k system/org.nixos.nix-daemon
  else
    sudo systemctl restart nix-daemon
  fi
  info "$NIX_CONF に追記して nix-daemon を再起動しました"
fi

# ---- 3. リポジトリ ----
step "3/5 dotfiles の取得"
if [[ -d "$REPO_DIR/.git" ]]; then
  info "$REPO_DIR にあるので飛ばします"
else
  mkdir -p "$(dirname "$REPO_DIR")"
  if command -v git >/dev/null; then
    git clone "$REPO_URL" "$REPO_DIR"
  else
    nix shell nixpkgs#git -c git clone "$REPO_URL" "$REPO_DIR"
  fi
fi

# ---- 4. Home Manager ----
step "4/5 Home Manager で設定を反映"
if command -v home-manager >/dev/null; then
  home-manager switch --flake "$REPO_DIR#$TARGET" -b backup
else
  nix run home-manager/master -- switch --flake "$REPO_DIR#$TARGET" -b backup
fi

# ---- 5. ログインシェル ----
step "5/5 ログインシェルを zsh にする"
[[ -x "$ZSH_PATH" ]] || fail "$ZSH_PATH がありません（手順 4 が失敗していないか確認してください）"
if grep -qxF "$ZSH_PATH" /etc/shells; then
  info "/etc/shells に登録済みです"
else
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  info "/etc/shells に登録しました"
fi
if [[ "$(uname -s)" == Darwin ]]; then
  current_shell="$(dscl . -read "$HOME" UserShell | awk '{print $2}')"
else
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
fi
if [[ "$current_shell" == "$ZSH_PATH" ]]; then
  info "ログインシェルは zsh になっています"
else
  chsh -s "$ZSH_PATH"
  info "ログインシェルを $ZSH_PATH に変更しました"
fi

# ---- 完了 ----
step "完了"
if $IS_WSL; then
  info "Windows 側（PowerShell など）で wsl --shutdown を実行し、ターミナルを開き直してください"
else
  info "ターミナルを開き直してください"
fi
