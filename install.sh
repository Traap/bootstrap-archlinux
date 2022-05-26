#!/bin/bash
# {{{ main

main() {
  sourceFiles
  removePersonalization

  updateOS
  loadOsExtras
  updateMirrorList

  installRuby
  installRubyGems

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
  addProgramsNeoVimInterfacesWith

  loadTmuxPlugins

  loadNeovimPlugins
  loadVimPlugins

  swapCapsLockAndEscKey

  [[ -f $HOME/.bashrc ]] && source $HOME/.bashrc
}

# -------------------------------------------------------------------------- }}}
# {{{ Source all configuration files

sourceFiles() {
  missingFile=0

  files=(config repos packages)
  for f in ${files[@]}
  do
    source $f
  done

  [[ $missingFile == 1 ]] && say 'Missing file(s) program exiting.' && exit

}

# -------------------------------------------------------------------------- }}}
# {{{ Source one configuraiton file.

sourceFile() {
  if [[ -f $1 ]]; then
    source $1
    [[ $echoConfigFlag == 1 ]] && sayAndDo cat $1
  else
    say $1 not found.
    missingFile=1
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ removePersonalization

removePersonalization() {
  if [[ $removePersonalizationFlag == 1 ]]; then
    say 'Removing personilization!'
    cd
    sudo rm -rf $cloneRoot
    mkdir -p $cloneRoot
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Update OS

updateOS() {
  [[ $osUpdateFlag == 1 ]] && sayAndDo 'sudo yay --noconfirm -Syu'
}

# -------------------------------------------------------------------------- }}}
# {{{ Personalize OS by loading extra packages.

loadOsExtras() {
  if [[ $osExtrasFlag == 1 ]]; then
    say 'Loading OS extras.'

    sudo pacman -S --noconfirm ${pacman_packages}

    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..

    yay -S --noconfirm ${yay_packages}
    pip install ${pip_packages}
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMySshRepo

cloneMySshRepo() {
  if [[ $mySshRepoFlag == 1 ]]; then
    say 'Cloning my ssh repo.'
    src=https://github.com/Traap/ssh.git
    dst=$cloneRoot/ssh
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {
  if [[ $mySshRepoFlag == 1 ]]; then
    say 'Setting ssh permissions.'
    chmod 600 $cloneRoot/ssh/*
    chmod 644 $cloneRoot/ssh/*.pub
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

cloneMyRepos() {
  if [[ $myReposFlag == 1 ]]; then
    say 'Cloning my repositories.'
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
  if [[ $gitBashPromptFlag == 1 ]]; then
    say 'Cloning bash-git-prompt.'
    rm -rf ~/.bash-git-prompt
    src=https://github.com/magicmonty/bash-git-prompt
    dst=~/.bash-git-prompt
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBase16Colors

cloneBase16Colors () {
  if [[ $base16ColorsFlag == 1 ]]; then
    say 'Cloning Base16 colors.'
    src=https://github.com/chriskempson/base16-shell
    dst=$cloneRoot/color/base16-shell
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneTmuxPlugins

cloneTmuxPlugins () {
  if [[ $tmuxPluginsFlag == 1 ]]; then
    say 'Cloning TMUX plugins.'
    src=https://github.com/tmux-plugins/tpm.git
    dst=$cloneRoot/tmux/plugins/tpm
    git clone  $src $dst
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ deleteSymLinks

deleteSymLinks() {
  if [[ $symlinksFlag == 1 ]]; then
    say 'Deleting symbolic links.'
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
      rm -fv ~/.config/bspwm/bspwm-monitor
      rm -fv ~/.config/bspwm/sxhkd/sxhkdrc
      rm -fv ~/.config/termite/config
    fi
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ createSymLinks

createSymLinks() {
  if [[ $symlinksFlag == 1 ]]; then
    say 'Creating symbolic links.'
    mkdir -p ~/.config
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
      ln -fsv $cloneRoot/dotfiles/bspwm/autostart.sh  ~/.config/bspwm/autostart.sh
      ln -fsv $cloneRoot/dotfiles/bspwm/bspwmrc       ~/.config/bspwm/bspwmrc
      ln -fsv $cloneRoot/dotfiles/bspwm/bspwm-monitor ~/.config/bspwm/bspwm-monitor
      ln -fsv $cloneRoot/dotfiles/bspwm/sxhkdrc       ~/.config/bspwm/sxhkd/sxhkdrc
      ln -fsv $cloneRoot/dotfiles/termite/config      ~/.config/termite/config
    fi
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ setSshPermissions

setSshPermissions() {

  if [[ $mySshRepoFlag == 1 ]]; then
    say 'Setting ssh permissions.'
    chmod 600 $cloneRoot/ssh/*
    chmod 644 $cloneRoot/ssh/*.pub
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Build KJV

buildKJV() {
  if [[ $kjvFlag == 1 ]]; then
    say 'Building Authorized KJV.'
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
  if [[ $neovimBuildFlag == 1 ]]; then
    say 'Remove neovim configuration.'
    sudo rm -rf ~/.cache/nvim
    sudo rm -rf ~/.config/nvim
    sudo rm -rf ~/.local/share/nvim

    say 'Acquire neovim dependencies.'
    sudo pacman -Syu --noconfirm \
      base-devel \
      cmake \
      ninja \
      tree-sitter \
      unzip

    say 'Building neovim.'
    src=https://github.com/neovim/neovim
    dst=$cloneRoot/neovim

    if [[ -d ${dst} ]]; then
      echo 'Update neovim sources.'
      cd ${dst}
      git pull
    else
      echo 'Clone neovim sources.'
      git clone  $src $dst
    fi

    echo 'Build neovim.'
    cd ${dst}
    sudo make CMANE_BUILD=Release install

    echo
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Add programs Neovim interfaces with.

addProgramsNeoVimInterfacesWith() {
  if [[ $neovimBuildFlag == 1 ]]; then
    say 'Add programs Neovim interfaces with.'
    gem install neovim
    sudo npm install -g neovim
    yarn global add neovim
    yay -S --noconfirm python-pip
    python3 -m pip install --user --upgrade pynvim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ updateMirrorList

updateMirrorList () {
  if [[ $mirroirFlag == 1 ]]; then
    say 'Updating mirror list.'

    sudo reflector -c "United States" \
      -f 12 -l 10 -n 12 \
      --save /etc/pacman.d/mirrorlist
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadNeovimlugins

loadNeovimPlugins() {
  if [[ $neovimPluginsFlag == 1 ]]; then
    say 'Loading neovim plugins.'
    nvim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadTmuxPlugins

loadTmuxPlugins() {
  if [[ $tmuxPluginsFlag == 1 ]]; then
    say 'Loading TMUX plugins.'
    ~/.tmux/plugins/tpm/bin/install_plugins
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadVimPlugins

loadVimPlugins() {
  if [[ $vimPluginsFlag == 1 ]]; then
    say 'Loading vim plugins.'
    vim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Ruby

installRuby() {
  if [[ $rbenvFlag == 1 ]]; then
    say 'Acquire Ruby dependencies.'
    yay -S --noconfirm \
      rbenv \
      ruby-build \

    say 'Build and install Ruby.'
    eval "$(rbenv init -)"
    rbenv install $rubyVersion
    rbenv global $rubyVersion

    echo 'Ruby installed.'
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

    echo 'Ruby Gems installed.'
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Swap CAPSLOCK with ESC key.

swapCapsLockAndEscKey() {
  setxkbmap -option caps:swapescape
}

# -------------------------------------------------------------------------- }}}
# {{{ Echo something with a separator line.

say() {
  echo
  echo '**********************'
  echo $@
}

# -------------------------------------------------------------------------- }}}
# {{{ Echo a command and then execute it.

sayAndDo() {
  say $@
  $@
  echo
}

# -------------------------------------------------------------------------- }}}
# {{{ The stage is set ... start the show!!!

main $@

# -------------------------------------------------------------------------- }}}
