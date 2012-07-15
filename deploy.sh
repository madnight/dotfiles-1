#!/bin/sh

dotfiles=$PWD

die() {
  echo >&2 "$1" && exit 1
}

link() {
  [[ -z $2 ]] && target=".${1##*/}" \
              || target="${2:-$target}"

  [[ -e "$target" && ! -h "$target" ]] && die "$0: $target exists in filesystem"
  [[ -d "$target"                   ]] && rm "$target"

  ln -fs "$dotfiles/$1" "$target"
}

dotfiles_git() { link git/gitconfig; }
dotfiles_htop() { link htop .config/htop; }
dotfiles_ncmpcpp() { link ncmpcpp; }
dotfiles_python() { link python/pythonstartup; }
dotfiles_rtorrent() { link rtorrent/rtorrent.rc; }
dotfiles_subtle() { link subtle .config/subtle; }
dotfiles_wget() { link wget/wgetrc; }
dotfiles_zathura() { link zathura .config/zathura; }

dotfiles_X() {
  link X/Xresources
  link X/xinitrc
}

dotfiles_input() {
  link input/inputrc
  link input/speedswapper
}

dotfiles_pentadactyl() {
  link pentadactyl
  link pentadactyl/pentadactylrc
}

dotfiles_vim() {
  link vim
  link vim/vimrc
  link vim/gvimrc
}

dotfiles_zsh() {
  git submodule update --init --recursive
  link zsh/zlogin
  link zsh/zlogout
  link zsh/zprofile
  link zsh/zshenv
  link zsh/zshrc
  link zsh/oh-my-zsh
}

usage() {
  cat << HERE
Automated deploy function for dotfile synchronization.

SUPPORTED:
HERE

  for fun in $(compgen -A function dotfiles_); do
    echo "  ${fun#dotfiles_}"
  done
  exit ${1:-0}
}

deploy() {
  while (( $# )); do
    cd && dotfiles_${1#dotfiles_}
    if [[ $? == 127 ]]; then
      echo >&2 "Error: don't know how to deploy \"$1\""
      usage >&2 1
    fi
    shift
  done
}

if (( $# == 0 )); then
  deploy $(compgen -A function dotfiles_)
elif [[ "$1" == "--help" ]]; then
  usage 0
else
  deploy $*
fi
