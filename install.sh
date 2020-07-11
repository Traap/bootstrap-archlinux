#!/bin/bash
# {{{ setTheStage

setTheStage() {
  echo "" && echo "Setting the stage!"
  cd
  rm -rf ~/git
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

repos=(amber autodoc docbld dotfiles newdoc tmux vim ssh)
cloneMyRepos() {
  echo "" && echo "Cloning my repositories."
  arr=("$@")
  for r in "${arr[@]}"
  do
    src=https://github.com/Traap/$r.git
    dst=~/git/$r
    git clone --depth 1 $src $dst
  done
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBashGitPrompt

cloneBashGitPrompt() {
  echo "" && echo "Cloning bash-git-prompt."
  rm -rf ~/.bash-git-prompt
  src=https://github.com/magicmonty/bash-git-prompt
  dst=~/.bash-git-prompt
  git clone --depth 1 $src $dst
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBase16Colors
cloneBase16Colors () {
  echo "" && echo "Cloning Base16 colors."
  src=https://github.com/chriskempson/base16-shell
  dst=~/git/color/base16-shell
  git clone --depth 1 $src $dst
}

# -------------------------------------------------------------------------- }}}
# {{{ symLinks

symLinks() {
  echo "" && echo "Making symbolic links."
  ln -fsv ~/git/dotfiles/bash_logout  ~/.bash_logout
  ln -fsv ~/git/dotfiles/bashrc-personal ~/.bashrc-personal
  ln -fsv ~/git/dotfiles/config       ~/.config
  ln -fsv ~/git/dotfiles/dircolors    ~/.dircolors
  ln -fsv ~/git/dotfiles/inputrc      ~/.inputrc
  ln -fsv ~/git/dotfiles/latexmkrc    ~/.latexmkrc
  ln -fsv ~/git/ssh/config.vim        ~/.config.vim
  ln -fsv ~/git/ssh/gitconfig         ~/.gitconfig
  ln -fsv ~/git/ssh/gitignore_global  ~/.gitignore_global
  ln -fsv ~/git/ssh                   ~/.ssh
  ln -fsv ~/git/tmux                  ~/.tmux
  ln -fsv ~/git/tmux/tmux.conf        ~/.tmux.conf
  ln -fsv ~/git/vim                   ~/.vim
  ln -fsv ~/git/vim/vimrc_background  ~/.vimrc_background
  ln -fsv ~/git/vim/vimrc             ~/.vimrc
}

# -------------------------------------------------------------------------- }}}
# {{{ sshPermissions

sshPermissions() {
  echo "" && echo "Setting ssh permissions."
  chmod 600 ~/git/ssh/*
  chmod 644 ~/git/ssh/*.pub
}

# -------------------------------------------------------------------------- }}}
# {{{ main

main() {
  setTheStage
  cloneBashGitPrompt
  cloneBase16Colors
  cloneMyRepos ${repos[@]}
  sshPermissions
  symLinks
  vim
  source ~/.bashrc
}

# -------------------------------------------------------------------------- }}}
# The stage is set ... start the show!!!
main "$@"
