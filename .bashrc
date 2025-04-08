# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# direnv
eval "$(direnv hook bash)"

# starship
eval "$(starship init bash)"

# cd
cd ~

fzf-select-history() {
  local selected_command
  selected_command=$(history | cut -c 8- | fzf --tac --no-sort --reverse --query "$READLINE_LINE")
  if [ -n "$selected_command" ]; then
    READLINE_LINE="$selected_command"
    READLINE_POINT=${#READLINE_LINE}
  fi
}

bind -x '"\C-h": "fzf-select-history"'

fzf-cd-src() {
  local selected_dir
  selected_dir=$(ghq list -p | fzf --reverse --query "$READLINE_LINE")
  if [ -n "$selected_dir" ]; then
    cd "$selected_dir"
  fi
  clear
}

bind -x '"\C-k": "fzf-cd-src"'

fzf-gh() {
  local repo
  local ssh_url
  repo=$(gh repo list --json sshUrl,nameWithOwner --jq '.[] | "\(.sshUrl) \(.nameWithOwner)"' | fzf --reverse)
  ssh_url=$(echo "$repo" | cut -d' ' -f1)
  if [ -n "$ssh_url" ]; then
    READLINE_LINE="${READLINE_LINE}${ssh_url}"
    READLINE_POINT=${#READLINE_LINE}
  fi
}

bind -x '"\C-g": "fzf-gh"'

alias gst='git status'
export STARSHIP_CONFIG=~/.config/starship/starship.toml
