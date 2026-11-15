{
  config,
  pkgs,
  lib,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  homeDir = if isDarwin then "/Users/touka" else "/home/touka";
  # このリポジトリの置き場所（ghq の配置）
  repoDir = "${homeDir}/ghq/github.com/touka-aoi/dotfiles";
in
{
  home.username = "touka";
  home.homeDirectory = homeDir;
  # 初回導入時の Home Manager のリリース。後から変更しないこと。
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fzf
    ghq
    gh
    neovim
    # バージョンを変えるときは nodejs_22 / nodejs_26 などに書き換える
    nodejs
    pnpm
    claude-code
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    PNPM_HOME = "${homeDir}/.local/share/pnpm";
  };

  # pnpm でグローバルに入れたコマンドの置き場所
  home.sessionPath = [
    "${homeDir}/.local/share/pnpm/bin"
  ];

  # ---- zsh ----
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # compinit は下の initContent で遅延実行する
    completionInit = "";
    # WSL では Windows 側の PATH（/mnt/c/...）が大量に入り、mise などが毎回走査して重くなる。
    # 必要なものだけ残す。
    envExtra = ''
      if [[ -n $WSL_DISTRO_NAME ]]; then
        () {
          local p
          local -a kept
          for p in $path; do
            case ''${p:l} in
              /mnt/*/windows | /mnt/*/windows/system32 | /mnt/*/windowspowershell/v1.0/ | */"microsoft vs code/bin")
                kept+=("$p") ;;
              /mnt/*) ;;
              *) kept+=("$p") ;;
            esac
          done
          path=("''${kept[@]}")
        }
      fi
    '';
    # プラグインは zsh-defer で遅延読み込みする（起動を速くするため）
    initContent = ''
      # WSL を `wsl` で起動すると Windows のユーザーフォルダ（/mnt/c/Users/<名前>）から始まる。
      # Windows 側は遅いので、その場合だけホームに移動する（別のフォルダで開いたときはそのまま）。
      if [[ -o login && -n $WSL_DISTRO_NAME && $PWD == /mnt/[a-z]/Users/* && $PWD != /mnt/[a-z]/Users/*/* ]]; then
        cd ~
      fi

      source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
      autoload -Uz compinit && zsh-defer compinit
      zsh-defer source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zsh-defer source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
      zsh-defer source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

    ''
    + builtins.readFile ./config/zsh/functions.zsh;
  };

  # ---- starship（プロンプト） ----
  # アイコンは使わず文字だけで表示する（Nerd Font が不要）
  programs.starship = {
    enable = true;
    settings = {
      # 1行目に情報、2行目に入力欄
      format = lib.concatStrings [
        "$username"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nodejs"
        "$golang"
        "$python"
        "$rust"
        "$deno"
        "$java"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      add_newline = true;
      # フォルダの走査やコマンドの実行に時間がかかっても、これ以上は待たない（ミリ秒）
      scan_timeout = 30;
      command_timeout = 300;

      username = {
        show_always = true;
        format = "[$user]($style) ";
      };
      directory = {
        truncation_length = 4;
        truncation_symbol = "…/";
        read_only = " ro";
      };
      git_branch = {
        symbol = "";
        format = "on [$branch]($style) ";
      };
      git_status.format = "([\\[$all_status$ahead_behind\\]]($style) )";
      cmd_duration.format = "took [$duration]($style) ";

      # 言語のバージョン（該当するファイルがあるフォルダでだけ表示）
      nodejs = {
        symbol = "node ";
        format = "via [$symbol($version)]($style) ";
      };
      golang = {
        symbol = "go ";
        format = "via [$symbol($version)]($style) ";
      };
      python = {
        symbol = "py ";
        format = "via [$symbol$pyenv_prefix($version)( \\($virtualenv\\))]($style) ";
      };
      rust = {
        symbol = "rs ";
        format = "via [$symbol($version)]($style) ";
      };
      deno = {
        symbol = "deno ";
        format = "via [$symbol($version)]($style) ";
      };
      java = {
        symbol = "java ";
        format = "via [$symbol($version)]($style) ";
      };
    };
  };

  # ---- git ----
  programs.git = {
    enable = true;
    settings.user = {
      name = "touka-aoi";
      # GitHub の noreply アドレス（コミットに本来のメールアドレスを残さないため）
      email = "58030947+touka-aoi@users.noreply.github.com";
    };
  };

  # ---- 設定ファイル ----
  xdg.configFile = {
    "nvim/init.lua".source = ./config/nvim/init.lua;
    "git/ignore".source = ./config/git/ignore;
  }
  // lib.optionalAttrs isDarwin {
    # Ghostty は Mac でのみ使用
    "ghostty/config".source = ./config/ghostty/config;
  };

  # エディタはホーム直下の .editorconfig を探すので、ここに置く
  home.file.".editorconfig".source = ./config/editorconfig/.editorconfig;

  # Claude Code がこのファイルを書き換えることがあるため、
  # /nix/store の読み取り専用コピーではなくリポジトリ内のファイルを直接リンクする
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/config/claude/CLAUDE.md";
}
