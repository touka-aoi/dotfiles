# omz settings
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  fzf-tab
  zsh-syntax-highlighting
  zsh-autosuggestions
)

zstyle ":completion:*:commands" rehash 1
bindkey '^ ' autosuggest-accept
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

source $ZSH/oh-my-zsh.sh

# asdf
. "$HOME/.asdf/asdf.sh"

# direnv
eval "$(direnv hook zsh)"

# starship
eval "$(starship init zsh)"

# eza 
alias e="eza --icons"
alias ee="eza --icons -T"
alias eee="eza -l --icons"

# fzf
# setting

# fzf history
function fzf-select-history() {
  BUFFER=$(
    history -n -r 1 | \
    fzf --query "$LBUFFER" --preview "man {}")
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N fzf-select-history
bindkey '^h' fzf-select-history

# fzf eza ls 
function fzf-command-ls-eza() {
  local buffer
  buffer=$(
    eza -a -r| \
    fzf --query "$LBUFFER" --preview "cat {}")
  BUFFER=" $buffer"
  CURSOR=0
  zle reset-prompt
}
zle -N fzf-command-ls-eza
bindkey '^l' fzf-command-ls-eza

# fzf code src
function fzf-code-src () {
  local selected_dir=$(
    ghq list -p |\
    fzf --query "$LBUFFER" --preview "eza -T {}")
  if [ -n "$selected_dir" ]; then
    BUFFER="code ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-code-src
bindkey "^u" fzf-code-src

# fzf cd src
function fzf-cd-src () {
  local selected_dir=$(
    ghq list -p |\
    fzf --query "$LBUFFER" --preview "eza -T {}")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-cd-src
bindkey "^k" fzf-cd-src

# zsh gh
function fzf-gh () {
  local buffer
  local repo
  buffer="$BUFFER"
  repo=$(
    gh repo list --json sshUrl,nameWithOwner --jq '.[] | "\(.sshUrl) \(.nameWithOwner)"' |\
    fzf --reverse
  )
  BUFFER="${buffer}$(echo $repo | cut -d' ' -f1)"
  CURSOR=$#BUFFER
}
zle -N fzf-gh
bindkey "[sg" fzf-gh

# measure time 
# zprof | less

. "$HOME/.local/bin/env"
