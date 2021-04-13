#!/bin/bash
# {{{ setTheStage

setTheStage() {
  echo "" && echo "Setting the stage!"
  cd
  sudo rm -rf ~/git
}

# -------------------------------------------------------------------------- }}}
# {{{ main

main() {
  setTheStage

  loadYayExtras

  createSymLinks

  cloneMySshRepo
  setSshPermissions

  cloneBashGitPrompt
  cloneBase16Colors
  cloneMyRepos ${repos[@]}
  cloneTmuxPlugins


  loadTmuxPlugins
  loadVimPlugins

  source ~/.bashrc
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMySshRepo

cloneMySshRepo() {
  echo "" && echo "Cloning my ssh repo."
  src=https://github.com/Traap/ssh.git
  dst=~/git/ssh
  git clone  $src $dst
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {
  echo "" && echo "Setting ssh permissions."
  chmod 600 ~/git/ssh/*
  chmod 644 ~/git/ssh/*.pub
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

repos=( \
  amber \
  autodoc \
  debian-bootstrap \
  docbld \
  dotfiles \
  emend \
  emend-computer \
  newdoc \
  resume \
  tmux \
  TraapReset \
  vim \
  wiki \
)

cloneMyRepos() {
  echo "" && echo "Cloning my repositories."
  arr=("$@")
  for r in "${arr[@]}"
  do
    src=https://github.com/Traap/$r.git
    dst=~/git/$r
    git clone  $src $dst
    echo ""
  done
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBashGitPrompt

cloneBashGitPrompt() {
  echo "" && echo "Cloning bash-git-prompt."
  rm -rf ~/.bash-git-prompt
  src=https://github.com/magicmonty/bash-git-prompt
  dst=~/.bash-git-prompt
  git clone  $src $dst
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBase16Colors

cloneBase16Colors () {
  echo "" && echo "Cloning Base16 colors."
  src=https://github.com/chriskempson/base16-shell
  dst=~/git/color/base16-shell
  git clone  $src $dst
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneTmuxPlugins

cloneTmuxPlugins () {
  echo "" && echo "Cloning TMUX plugins."
  src=https://github.com/tmux-plugins/tpm.git
  dst=~/git/tmux/plugins/tpm
  git clone  $src $dst
}

# -------------------------------------------------------------------------- }}}
# {{{ createSymLinks

createSymLinks() {
  echo "" && echo "Creating symbolic links."
  ln -fsv ~/git/dotfiles/bash_logout      ~/.bash_logout
  ln -fsv ~/git/dotfiles/bashrc           ~/.bashrc
  ln -fsv ~/git/dotfiles/bashrc-personal  ~/.bashrc-personal
  ln -fsv ~/git/dotfiles/dircolors        ~/.dircolors
  ln -fsv ~/git/dotfiles/gitconfig        ~/.gitconfig
  ln -fsv ~/git/dotfiles/gitignore_global ~/.gitignore_global
  ln -fsv ~/git/dotfiles/inputrc          ~/.inputrc
  ln -fsv ~/git/dotfiles/latexmkrc        ~/.latexmkrc
  ln -fsv ~/git/dotfiles/minttyrc         ~/.minttyrc
  ln -fsv ~/git/dotfiles/mozilla          ~/.mozilla
  ln -fsv ~/git/ssh                       ~/.ssh
  ln -fsv ~/git/ssh/config.vim            ~/.config.vim
  ln -fsv ~/git/tmux                      ~/.tmux
  ln -fsv ~/git/tmux/tmux.conf            ~/.tmux.conf
  ln -fsv ~/git/vim                       ~/.vim
  ln -fsv ~/git/vim/coc-package.json     ~/.config/coc/extensions/package.json
  ln -fsv ~/git/vim/vimrc                 ~/.config/nvim/init.vim
  ln -fsv ~/git/vim/vimrc                 ~/.vimrc
  ln -fsv ~/git/vim/vimrc_background      ~/.vimrc_background

  if [[ $(uname -r) =~ 'arch' ]]; then
    ln -fsv ~/git/dotfiles/bspwm/autostart.sh ~/.config/bspwm/autostart.sh
    ln -fsv ~/git/dotfiles/bspwm/bspwmrc      ~/.config/bspwm/bspwmrc
    ln -fsv ~/git/dotfiles/bspwm/sxhkdrc      ~/.config/bspwm/sxhkd/sxhkdrc
    ln -fsv ~/git/dotfiles/termite/config     ~/.config/termite/config
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {
  echo "" && echo "Setting ssh permissions."
  chmod 600 ~/git/ssh/*
  chmod 644 ~/git/ssh/*.pub
}

# -------------------------------------------------------------------------- }}}
# {{{ loadYayExtras

loadYayExtras() {
  echo "" && echo "Loading yay extras."

  yay -S --noconfirm \
      neovim \
      npm \
      okular \
      pandoc \
      rbenv \
      ripgrep \
      ruby-build \
      texlive-bin \
      texlive-core \
      texlive-latexextra \
      texlive-music \
      texlive-pictures \
      texlive-publishers \
      texlive-science
}

# -------------------------------------------------------------------------- }}}
# {{{ loadTmuxPlugins

loadTmuxPlugins() {
  echo "" && echo "Loading TMUX plugins."
  ~/.tmux/plugins/tpm/bin/install_plugins
}

# -------------------------------------------------------------------------- }}}
# {{{ loadVimPlugins

loadVimPlugins() {
  echo "" && echo "Loading vim / neovim plugins."
  vim
}

# -------------------------------------------------------------------------- }}}
# {{{ The stage is set ... start the show!!!

main "$@"

# -------------------------------------------------------------------------- }}}
