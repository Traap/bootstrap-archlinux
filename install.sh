#!/bin/bash
# {{{ main

main() {
  source config

  setTheStage

  loadYayExtras

  deleteSymLinks
  createSymLinks

  cloneMySshRepo
  setSshPermissions

  cloneBashGitPrompt
  cloneBase16Colors
  cloneMyRepos ${repos[@]}
  cloneTmuxPlugins

  loadNeovimExtras
  loadTmuxPlugins
  loadVimPlugins

  source ~/.bashrc
}

# -------------------------------------------------------------------------- }}}
# {{{ setTheStage

setTheStage() {
  echo "" && echo "Setting the stage!"
  cd
  sudo rm -rf ~/git
  sudo rm -rf ~/.config
  sudo rm -rf ~/.local/share/nvim
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMySshRepo

cloneMySshRepo() {
  if [[ mySshRepoFlag ]]; then
    echo "" && echo "Cloning my ssh repo."
    src=https://github.com/Traap/ssh.git
    dst=~/git/ssh
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {
  if [[ mySshRepoFlag ]]; then
    echo "" && echo "Setting ssh permissions."
    chmod 600 ~/git/ssh/*
    chmod 644 ~/git/ssh/*.pub
  fi
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
)nvi

cloneMyRepos() {
  if [[ myReposFlag ]]; then
    echo "" && echo "Cloning my repositories."
    arr=("$@")
    for r in "${arr[@]}"
    do
      src=https://github.com/Traap/$r.git
      dst=~/git/$r
      git clone  $src $dst
      echo ""
    done
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBashGitPrompt

cloneBashGitPrompt() {
  if [[ gitBashPromptFlag ]]; then
    echo "" && echo "Cloning bash-git-prompt."
    rm -rf ~/.bash-git-prompt
    src=https://github.com/magicmonty/bash-git-prompt
    dst=~/.bash-git-prompt
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBase16Colors

cloneBase16Colors () {
  if [[ base16ColorsFlag ]]; then
    echo "" && echo "Cloning Base16 colors."
    src=https://github.com/chriskempson/base16-shell
    dst=~/git/color/base16-shell
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneTmuxPlugins

cloneTmuxPlugins () {
  if [[ tmuxPluginsFlag ]]; then
    echo "" && echo "Cloning TMUX plugins."
    src=https://github.com/tmux-plugins/tpm.git
    dst=~/git/tmux/plugins/tpm
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ deleteSymLinks

deleteSymLinks() {
  if [[ symlinksFlag ]]; then
    echo "" && echo "Deleting symbolic links."
    rm -fv ~/.bash_logout
    rm -fv ~/.bashrc
    rm -fv ~/.bashrc-personal
    rm -fv ~/.dircolors
    rm -fv ~/.gitconfig
    rm -fv ~/.gitignore_global
    rm -fv ~/.inputrc
    rm -fv ~/.latexmkrc
    rm -fv ~/.minttyrc
    rm -fv ~/.mozilla
    rm -fv ~/.ssh
    rm -fv ~/.config.vim
    rm -fv ~/.tmux
    rm -fv ~/.tmux.conf
    rm -fv ~/.vim
    rm -fv ~/.config/coc/extensions/package.json
    rm -fv ~/.config/nvim/init.vim
    rm -fv ~/.vimrc
    rm -fv ~/.vimrc_background

    if [[ $(uname -r) =~ 'arch' ]]; then
      rm -fv ~/.config/bspwm/autostart.sh
      rm -fv ~/.config/bspwm/bspwmrc
      rm -fv ~/.config/bspwm/sxhkd/sxhkdrc
      rm -fv ~/.config/termite/config
    fi
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ createSymLinks

createSymLinks() {
  if [[ symlinksFlag ]]; then
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
    ln -fsv ~/git/vim/coc-package.json      ~/.config/coc/extensions/package.json
    ln -fsv ~/git/vim/vimrc                 ~/.config/nvim/init.vim
    ln -fsv ~/git/vim/vimrc                 ~/.vimrc
    ln -fsv ~/git/vim/vimrc_background      ~/.vimrc_background

    if [[ $(uname -r) =~ 'arch' ]]; then
      ln -fsv ~/git/dotfiles/bspwm/autostart.sh ~/.config/bspwm/autostart.sh
      ln -fsv ~/git/dotfiles/bspwm/bspwmrc      ~/.config/bspwm/bspwmrc
      ln -fsv ~/git/dotfiles/bspwm/sxhkdrc      ~/.config/bspwm/sxhkd/sxhkdrc
      ln -fsv ~/git/dotfiles/termite/config     ~/.config/termite/config
    fi
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {
  if [[ mySshRepoFlag ]]; then
    echo "" && echo "Setting ssh permissions."
    chmod 600 ~/git/ssh/*
    chmod 644 ~/git/ssh/*.pub
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadYayExtras

loadYayExtras() {
  if [[ yayExtrasFlag ]]; then
  echo "" && echo "Loading yay extras."

  yay -S --noconfirm \
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
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadNeovimExtras

loadNeovimExtras() {
  if [[ neovimExtrasFlag ]]; then
    echo "" && echo "Loading neovim extras."
    sudo \
      pacman -S --noconfirm \
        base-devel \
        cmake \
        ninja \
        tree-sitter \
        unzip
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadTmuxPlugins

loadTmuxPlugins() {
  if [[ tmuxPluginsFlag ]]; then
    echo "" && echo "Loading TMUX plugins."
    ~/.tmux/plugins/tpm/bin/install_plugins
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadVimPlugins

loadVimPlugins() {
  if [[ vimPluginsFlag ]]; then
    echo "" && echo "Loading vim / neovim plugins."
    vim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ The stage is set ... start the show!!!

main "$@"

# -------------------------------------------------------------------------- }}}
