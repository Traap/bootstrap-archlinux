#!/bin/bash
# {{{ main

main() {
  loadConfig
  removePersonalization
exit

  updateOS
  loadOsExtras
  updateMirrorList

  deleteSymLinks
  createSymLinks

  cloneMySshRepo
  setSshPermissions

  cloneBashGitPrompt
  cloneBase16Colors
  cloneMyRepos ${repos[@]}
  cloneTmuxPlugins
  
  buildKJV
  buildNeovim 

  loadTmuxPlugins
  loadVimPlugins 

  installRuby
  installRubyGems
  
  source ~/.bashrc
}

# -------------------------------------------------------------------------- }}}
# {{{ Load configuraiton options.

loadConfig() {
  if [[ -f config ]]; then
    source config
    [[ $echoConfigFlag == 1 ]] && sayAndDo 'cat config'
  else
    echo "config not found."
    exit
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ removePersonalization

removePersonalization() {
  echo && echo "Removing personilization!"
  cd
  sudo rm -rf $cloneRoot 
  sudo rm -rf ~/.config/nvim
  sudo rm -rf ~/.local/share/nvim
  mkdir -p $cloneRoot
}

# -------------------------------------------------------------------------- }}}
# {{{ Update OS 

updateOS() {
  if [[ $osUpdateFlag == 1 ]]; then
    sudo pacman --noconfirm -Syyu
    sudo yay --noconfirm -Syu
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Personalize OS by loading extra packages. 

loadOsExtras() {
  if [[ $osExtrasFlag ]]; then
    echo "" && echo "Loading OS extras."

    pacman -S --noconfirm \
      base-devel \
      cmake \
      ninja \
      tree-sitter \
      unzip

    yay -S --noconfirm \
      bat \
      exa \
      graphaviz \
      jre-openjdk-headless \
      npm \
      okular \
      pandoc \
      python \
      poppler \
      rbenv \
      reflector \
      ruby-build \
      bexlive-bin \
      texlive-core \
      texlive-latexextra \
      texlive-music \
      texlive-pictures \
      texlive-publishers \
      texlive-science

    pip install \
      ueberzug \
      pynvim \
      neovim-remote

  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMySshRepo

cloneMySshRepo() {
  if [[ $mySshRepoFlag ]]; then
    echo "" && echo "Cloning my ssh repo."
    src=https://github.com/Traap/ssh.git
    dst=$cloneRoot/ssh
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {
  if [[ $mySshRepoFlag ]]; then
    echo "" && echo "Setting ssh permissions."
    chmod 600 $cloneRoot/ssh/*
    chmod 644 $cloneRoot/ssh/*.pub
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

source repos

cloneMyRepos() {
  if [[ myReposFlag ]]; then
    echo "" && echo "Cloning my repositories."
    arr=("$@")
    for r in "${arr[@]}"
    do
      src=https://github.com/Traap/$r.git
      dst=$cloneRoot/$r
      git clone  $src $dst
      echo ""
    done
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBashGitPrompt

cloneBashGitPrompt() {
  if [[ $gitBashPromptFlag ]]; then
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
  if [[ $base16ColorsFlag ]]; then
    echo "" && echo "Cloning Base16 colors."
    src=https://github.com/chriskempson/base16-shell
    dst=$cloneRoot/color/base16-shell
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneTmuxPlugins

cloneTmuxPlugins () {
  if [[ $tmuxPluginsFlag ]]; then
    echo "" && echo "Cloning TMUX plugins."
    src=https://github.com/tmux-plugins/tpm.git
    dst=$cloneRoot/tmux/plugins/tpm
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ deleteSymLinks

deleteSymLinks() {
  if [[ $symlinksFlag ]]; then
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
      rm -fv ~/.config/bspwm/bspwmrc-monitor
      rm -fv ~/.config/bspwm/sxhkd/sxhkdrc
      rm -fv ~/.config/termite/config
    fi
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ createSymLinks

createSymLinks() {
  if [[ $symlinksFlag ]]; then
    echo "" && echo "Creating symbolic links."
    ln -fsv $cloneRoot/dotfiles/bash_logout      ~/.bash_logout
    ln -fsv $cloneRoot/dotfiles/bashrc           ~/.bashrc
    ln -fsv $cloneRoot/dotfiles/bashrc-personal  ~/.bashrc-personal
    ln -fsv $cloneRoot/dotfiles/dircolors        ~/.dircolors
    ln -fsv $cloneRoot/dotfiles/gitconfig        ~/.gitconfig
    ln -fsv $cloneRoot/dotfiles/gitignore_global ~/.gitignore_global
    ln -fsv $cloneRoot/dotfiles/inputrc          ~/.inputrc
    ln -fsv $cloneRoot/dotfiles/latexmkrc        ~/.latexmkrc
    ln -fsv $cloneRoot/dotfiles/minttyrc         ~/.minttyrc
    ln -fsv $cloneRoot/ssh                       ~/.ssh
    ln -fsv $cloneRoot/ssh/config.vim            ~/.config.vim
    ln -fsv $cloneRoot/tmux                      ~/.tmux
    ln -fsv $cloneRoot/tmux/tmux.conf            ~/.tmux.conf
    ln -fsv $cloneRoot/vim                       ~/.vim
    ln -fsv $cloneRoot/vim/coc-package.json      ~/.config/coc/extensions/package.json
    ln -fsv $cloneRoot/vim/vimrc                 ~/.config/nvim/init.vim
    ln -fsv $cloneRoot/vim/vimrc                 ~/.vimrc
    ln -fsv $cloneRoot/vim/vimrc_background      ~/.vimrc_background

    if [[ $(uname -r) =~ 'arch' ]]; then
      ln -fsv $cloneRoot/dotfiles/bspwm/autostart.sh    ~/.config/bspwm/autostart.sh
      ln -fsv $cloneRoot/dotfiles/bspwm/bspwmrc         ~/.config/bspwm/bspwmrc
      ln -fsv $cloneRoot/dotfiles/bspwm/bspwmrc-monitor ~/.config/bspwm/bspwmrc
      ln -fsv $cloneRoot/dotfiles/bspwm/sxhkdrc         ~/.config/bspwm/sxhkd/sxhkdrc
      ln -fsv $cloneRoot/dotfiles/termite/config        ~/.config/termite/config
    fi 
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {
  if [[ $mySshRepoFlag ]]; then
    echo "" && echo "Setting ssh permissions."
    chmod 600 $cloneRoot/ssh/*
    chmod 644 $cloneRoot/ssh/*.pub
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Build KJV

buildKJV() {
  if [[ $kjvFlag ]]; then
    echo "" && echo "Building Authorized KJV."
    src=https://github.com/Traap/kjv.git
    dst=$cloneRoot/kjv
    git clone  $src $dst
    cd $dst
    git checkout kjv-01
    make
    sudo mv kjv /usr/local/bin/.
    echo ""
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Build Neovim

buildNeovim() {
  if [[ $neovimFlag ]]; then
    echo "" && echo "Building neovim."
    src=https://github.com/neovim/neovim
    dst=$cloneRoot/neovim

    if [[ -d ${dst} ]]; then
      echo "Update neovim sources."
      cd ${dst}
      git pull
    else
      echo "Clone neovim sources."
      git clone  $src $dst
    fi

    echo "Build neovim."
    cd ${dst}
    sudo make install

    echo ""
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ updateMirrorList

updateMirrorList () {
  if [[ $mirroirFlag ]]; then
    echo "" && echo "Updating mirror list."

    sudo reflector -c "United States" \
              -f 12 -l 10 -n 12 \
              --save /etc/pacman.d/mirrorlist
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadTmuxPlugins

loadTmuxPlugins() {
  if [[ $tmuxPluginsFlag ]]; then
    echo "" && echo "Loading TMUX plugins."
    ~/.tmux/plugins/tpm/bin/install_plugins
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadVimPlugins

loadVimPlugins() {
  if [[ $vimPluginsFlag ]]; then
    echo "" && echo "Loading vim / neovim plugins."
    vim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Ruby

installRuby() {
  if [[ $rbenvFlag == 1 ]]; then

    rbenv init
    rbenv install $rubyVersion
    rbenv global $rubyVersion

    echo "Ruby installed."
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Ruby Gems

installRubyGems() {
  if [[ $rbenvFlag == 1 ]]; then

    # Install Ruby Gems
    gem install \
        bundler \
        rake \
        rspec

    echo "Ruby Gems installed."
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Echo something with a separator line. 

say() {
  echo '**********************'
  echo "$@"
}

# -------------------------------------------------------------------------- }}}
# {{{ Echo a command and then execute it.

sayAndDo() {
  say "$@"
  $@
  echo
}

# -------------------------------------------------------------------------- }}}
# {{{ The stage is set ... start the show!!!

main "$@"

# -------------------------------------------------------------------------- }}}
