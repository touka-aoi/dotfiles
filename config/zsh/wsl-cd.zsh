# WSL を `wsl` で起動すると Windows のユーザーフォルダ（/mnt/c/Users/<名前>）から始まる。
# Windows 側は遅いので、その場合だけホームに移動する（別のフォルダで開いたときはそのまま）。
if [[ -o login && -n $WSL_DISTRO_NAME && $PWD == /mnt/[a-z]/Users/* && $PWD != /mnt/[a-z]/Users/*/* ]]; then
  cd ~
fi
