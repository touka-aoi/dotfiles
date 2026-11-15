# プラグインは zsh-defer で遅延読み込みする（起動を速くするため）
# @名前@ は反映のときに Nix がパッケージの場所に置き換える（home.nix を参照）
source @zshDefer@/share/zsh-defer/zsh-defer.plugin.zsh
autoload -Uz compinit && zsh-defer compinit
zsh-defer source @fzfTab@/share/fzf-tab/fzf-tab.plugin.zsh
zsh-defer source @autosuggestions@/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
zsh-defer source @fastSyntaxHighlighting@/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
