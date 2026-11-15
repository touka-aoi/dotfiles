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
    ansible
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    PNPM_HOME = "${homeDir}/.local/share/pnpm";
  };

  # pnpm でグローバルに入れたコマンドの置き場所
  home.sessionPath = [
    "${homeDir}/.local/share/pnpm/bin"
  ];

  # ---- zsh（中身は config/zsh/） ----
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # compinit は plugins.zsh で遅延実行する
    completionInit = "";
    envExtra = ''
      source ${./config/zsh/wsl-path.zsh}
    '';
    initContent = ''
      source ${./config/zsh/wsl-cd.zsh}
      source ${
        pkgs.replaceVars ./config/zsh/plugins.zsh {
          zshDefer = pkgs.zsh-defer;
          fzfTab = pkgs.zsh-fzf-tab;
          autosuggestions = pkgs.zsh-autosuggestions;
          fastSyntaxHighlighting = pkgs.zsh-fast-syntax-highlighting;
        }
      }
      source ${./config/zsh/functions.zsh}
    '';
  };

  # ---- starship（プロンプト） ----
  programs.starship.enable = true;

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
    "starship.toml".source = ./config/starship/starship.toml;
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
