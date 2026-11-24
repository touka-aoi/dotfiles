# WSL では Windows 側の PATH（/mnt/c/...）が大量に入り、コマンドの検索などが遅くなる。
# 必要なものだけ残す。Windows のコマンドを追加で使いたいときは case にフォルダを足す（小文字で書く）。
if [[ -n $WSL_DISTRO_NAME ]]; then
  () {
    local p
    local -a kept
    for p in $path; do
      case ${p:l} in
        /mnt/*/windows | /mnt/*/windows/system32 | /mnt/*/windowspowershell/v1.0/ | */"microsoft vs code/bin")
          kept+=("$p") ;;
        /mnt/*) ;;
        *) kept+=("$p") ;;
      esac
    done
    path=("${kept[@]}")
  }
fi
