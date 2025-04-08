#!/bin/bash

dotfiles_root=$PWD

function ln_home_files () {
  for file in .*; do
    if [[ ! -d "$file" ]]; then
      ln -sf "$PWD/$file" "$HOME"
    fi
  done
}

function ln_dot_config () {
  for file in *; do
    if [[ -d "$file" ]]; then
      pushd "$file" || exit
      ln_dot_config
      popd || exit
    else 
      relative_path="${PWD#$dotfiles_root}"
      ln "$PWD/$file" "$HOME$relative_path"
    fi
  done
}

if [ -f "$HOME/.bashrc" ]; then
  mv "$HOME/.bashrc" "$HOME/.bashrc.backup"
  echo "mv: ~/.bashrc -> ~/.bashrc.backup"
fi

mkdir -p $HOME/.config/git
mkdir -p $HOME/.config/starship

ln_home_files
cd ".config" || exit
ln_dot_config
cd ..

# install other package 
sudo apt update 

# asdf
curl -OL https://github.com/asdf-vm/asdf/releases/download/v0.16.7/asdf-v0.16.7-linux-amd64.tar.gz
tar -zxvf asdf-v0.16.7-linux-amd64.tar.gz
sudo mv asdf /usr/local/bin/asdf

# fzf
sudo apt install fzf

# silver-searcher
sudo apt-get install silversearcher-ag

# starship
curl -sS https://starship.rs/install.sh | sh

# direnv
sudo apt install direnv

#unzip
sudo apt install unzip

#pipx
sudo apt install pipx
pipx ensurepath
sudo pipx ensurepath --global

# ghq
asdf plugin add ghq
asdf install ghq latest
asdf global ghq latest

# go
asdf plugin add golang
asdf install golang latest
asdf global golang latest

# python
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
