# dotfiles

Nix + Home Manager で管理する dotfiles。WSL（Ubuntu）と macOS（Apple Silicon）で共通。

## セットアップ

新しいマシンで次を実行する。

```sh
curl -fsSL https://raw.githubusercontent.com/touka-aoi/dotfiles/main/setup.sh | bash
```

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
| zsh | `config/zsh/` |
| starship | `config/starship/starship.toml` |
| git | `user.name`、`user.email` `config/git/ignore` |
| neovim | `config/nvim/init.lua`|
| editorconfig | `~/.editorconfig` |
| Claude Code | `~/.claude/CLAUDE.md` |
| Ghostty | `config/ghostty/config`（macOS のみ） |
| Keychron Q11 | `config/keychron/q11.json`（Keychron Launcher で読み込む） |

### zsh のキー割り当て

| キー | 動作 |
| --- | --- |
| Ctrl+K | ghq で管理しているリポジトリを fzf で選んで cd |
| Ctrl+H | コマンド履歴を fzf で検索 |
| Ctrl+G | GitHub のリポジトリを fzf で選んで、SSH の URL を入力 |

## 運用コマンド

```sh
cd ~/ghq/github.com/touka-aoi/dotfiles

home-manager switch --flake .#touka@wsl    # 設定を変えたら反映（macOS は .#touka@mac）
nix flake update                           # パッケージを最新にする（そのあと switch）
home-manager switch --flake .#touka@wsl --rollback   # 1つ前の状態に戻す
home-manager generations                   # 過去の状態の一覧
```