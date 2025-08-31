# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# direnv
eval "$(direnv hook bash)"

# starship
if command -v starship > /dev/null; then
  eval "$(starship init bash)"
fi

fzf-select-history() {
  local selected_command
  selected_command=$(history | cut -c 8- | fzf --tac --reverse --query "$READLINE_LINE")
  if [ -n "$selected_command" ]; then
    READLINE_LINE="$selected_command"
    READLINE_POINT=${#READLINE_LINE}
  fi
}

fzf-cd-src() {
  local selected_dir
  selected_dir=$(ghq list -p | fzf --reverse --query "$READLINE_LINE")
  if [ -n "$selected_dir" ]; then
    cd "$selected_dir"
  fi
  clear
}

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

if [[ $- == *i* ]]; then
bind -x '"\C-g": "fzf-gh"'
bind -x '"\C-k": "fzf-cd-src"'
bind -x '"\C-h": "fzf-select-history"'
fi

alias gst='git status'
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Created by `pipx` on 2025-06-07 11:23:35
export PATH="$PATH:/home/touka_aoi/.local/bin"

. "$HOME/.local/bin/env"

if command -v kubectl > /dev/null; then
  export GPG_TTY=$(tty)
  source <(kubectl completion bash)

  alias k=kubectl
  complete -o default -F __start_kubectl k
fi

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export KUBECTX_IGNORE_FZF=1
