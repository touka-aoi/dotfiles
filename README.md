# dotfiles

Nix + Home Manager で管理する dotfiles。WSL（Ubuntu）と macOS（Apple Silicon）で共通。

## セットアップ

新しいマシンで次を実行する。

```sh
curl -fsSL https://raw.githubusercontent.com/touka-aoi/dotfiles/main/setup.sh | bash
```

リポジトリがすでに手元にある場合は、その中で `./setup.sh` を実行する。

`setup.sh` は次の手順を順に行う。終わっている手順は飛ばすので、何度実行してもよい。途中で sudo のパスワードを聞かれる。

1. Nix をインストールする（マルチユーザー版）
2. flakes を有効にする（`/etc/nix/nix.conf` に追記）
3. このリポジトリを `~/ghq/github.com/touka-aoi/dotfiles` に置く
4. Home Manager で設定を反映する（既存のファイルは `*.backup` に退避）
5. Nix の zsh を `/etc/shells` に登録し、ログインシェルにする

終わったら、ターミナルを開き直す。WSL の場合は、Windows 側で `wsl --shutdown` を実行してから開き直す。

### 前提

- WSL では systemd が有効になっていること（`/etc/wsl.conf` に `[boot]` `systemd=true`）
- `curl` が使えること

## 構成

| パス | 内容 |
| --- | --- |
| `flake.nix` | 対象マシンの定義（`touka@wsl` / `touka@mac`）と、許可する unfree パッケージ |
| `home.nix` | インストールするパッケージと設定 |
| `setup.sh` | 初回セットアップ |
| `config/` | 各ツールの設定ファイル本体 |

### 管理しているもの

| 種類 | 内容 |
| --- | --- |
| パッケージ | zsh、neovim、fzf、ghq、gh、git、nodejs、pnpm、claude-code、starship |
| zsh | プラグイン（fzf-tab、autosuggestions、fast-syntax-highlighting）を zsh-defer で遅延読み込み、fzf のキー割り当て（`config/zsh/functions.zsh`） |
| starship | プロンプト。ユーザー名、ディレクトリ、git、言語のバージョン、実行時間を文字だけで表示 |
| git | `user.name`、`user.email`（GitHub の noreply アドレス）、全体の ignore（`config/git/ignore`） |
| neovim | `config/nvim/init.lua`（jj で Esc、行番号、クリップボード共有など） |
| editorconfig | `~/.editorconfig` |
| Claude Code | `~/.claude/CLAUDE.md`（リポジトリ内のファイルへ直接リンクしているので、編集はそのままリポジトリに反映される） |
| Ghostty | `config/ghostty/config`（macOS のみ） |

### zsh のキー割り当て

| キー | 動作 |
| --- | --- |
| Ctrl+K | ghq で管理しているリポジトリを fzf で選んで cd |
| Ctrl+H | コマンド履歴を fzf で検索 |
| Ctrl+G | GitHub のリポジトリを fzf で選んで、SSH の URL を入力 |

## 日常の操作

```sh
cd ~/ghq/github.com/touka-aoi/dotfiles

home-manager switch --flake .#touka@wsl    # 設定を変えたら反映（macOS は .#touka@mac）
nix flake update                           # パッケージを最新にする（そのあと switch）
home-manager switch --flake .#touka@wsl --rollback   # 1つ前の状態に戻す
home-manager generations                   # 過去の状態の一覧
```

flake は git で追跡しているファイルしか読まない。新しいファイルを追加したら `git add` してから反映する。

### 言語のバージョンを変える

`home.nix` の `home.packages` のパッケージ名を書き換えて反映する。

```nix
nodejs        # 今の LTS。nodejs_22 / nodejs_26 などに書き換えられる
go_1_27       # go を入れる場合の例
```

nixpkgs で選べるのは、サポート中のメジャーバージョンだけ。サポートが終わったバージョンは削除される。

### パッケージを追加する

`home.nix` の `home.packages` に名前を足して反映する。名前は <https://search.nixos.org/packages> で探せる。unfree ライセンスのもの（claude-code など）は、`flake.nix` の `allowUnfreePredicate` にも名前を足す。

## WSL 固有の設定

- **Windows の PATH を絞る**：WSL は Windows 側の PATH（`/mnt/c/...`）を大量に引き継ぎ、コマンド検索が遅くなる。zsh では `C:\Windows`、`System32`、Windows PowerShell、VS Code だけを残している。Windows のコマンドを追加で使いたいときは、`home.nix` の `programs.zsh.envExtra` の `case` にフォルダを足す（小文字で書く）。
- **起動時にホームへ移動**：`wsl` で起動すると Windows のユーザーフォルダ（`/mnt/c/Users/<名前>`）から始まるので、その場合だけ `~` に移動する。
- **nvim のクリップボード**：コピーは OSC 52、ペーストは `powershell.exe` で Windows のクリップボードとやり取りする。

Windows 側のフォルダ（`/mnt/c`）での作業は遅いので、作業は WSL 側（`~` の下）で行う。
