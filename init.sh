#!/bin/zsh

dotfiles_root=$PWD

function ln_home_files () {
  for file in .*; do
    if [[ ! -d $file ]]; then
      ln ${PWD}/${file} ${HOME}
    fi
  done
}

function ln_dot_config () {
  for file in *; do
    if [[ -d $file ]]; then
      pushd $file
      ln_dot_config
      popd
    else 
      relative_path="${PWD#$dotfiles_root}"
      ln $PWD/$file $HOME$relative_path
    fi
  done
}

ln_home_files
cd ".config"
ln_dot_config