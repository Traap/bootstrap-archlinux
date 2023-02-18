#!/bin/bash
# {{{ main

main() {
  # Save current working directory.
  cwd=$(pwd)

  # Source configuration files and clean when necessary.
  sourceFiles

  # Update operating system and keys.
  updateOSKeys
  updateOS

  # Install packages.
  installPacmanPackages
  installYayPackages
  installPipPackages
  installTexPackages

  # Update mirrors.
  updateMirrorList

  # Install programming languages.
  installRuby
  installRubyGems
  installRust

  # Setup symlinks.
  deleteSymLinks
  createSymLinks

  # Configure /etc/ and /.ssh directories.
  stopWslAutogeneration
  installSshDir
  generateSshHostKey
  setSshPermissions

  # Clone different repositories needed for personalization.
  cloneBashGitPrompt
  cloneBase16Colors
  cloneMyRepos
  cloneTmuxPlugins

  # Build applications from source code.
  buildKJV
  buildNeovim
  addProgramsNeoVimInterfacesWith

  # Install editors and terminal multiplexers.
  installLunarVim
  loadTmuxPlugins
  loadNeovimPlugins
  loadVimPlugins

  # Install desktop applications.
  installDesktopApps
  installOtherApps

  # Final personalization.
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
# {{{ Update OS Keys

updateOSKeys() {
  if [[ $osUpdateKeysFlag == 1 ]]; then
    say 'Update keys'
    sudo pacman-key --init
    sudo pacman-key --populate
    sudo pacman-key --refresh-keys
    sudo pacman -Sy archlinux-keyring --noconfirm
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Update OS

updateOS() {
  [[ $osUpdateFlag == 1 ]] && sayAndDo 'sudo pacman -Syyu --noconfirm'
}

# -------------------------------------------------------------------------- }}}
# {{{ Install desktop applications.

installDesktopApps() {
  if [[ $desktopAppsFlag == 1 ]]; then
    say 'Installing desktop applications.'
    sudo yay -Syyu --noconfirm ${desktop_packages[@]}
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install pacman packages.

installPacmanPackages() {
  if [[ $pacmanPackagesFlag == 1 ]]; then
    say 'Installing pacman packages.'
    sudo pacman -Syyu --noconfirm ${pacman_packages[@]}
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install other applications.

installOtherApps() {
  if [[ $otherAppsFlag == 1 ]]; then
    say 'Installing other applications.'
    sudo yay -Syyu --noconfirm ${other_packages[@]}
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install yay packages.

installYayPackages() {
  if [[ $yayPackagesFlag == 1 ]]; then
    say 'Installing yay packages.'

    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..

    yay -Syu --noconfirm ${yay_packages[@]}
    libtool --finish /usr/lib/libfakeroot
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install pip packages.

installPipPackages() {
  if [[ $pipPackagesFlag == 1 ]]; then
    say 'Installing pip packages.'
    pip install ${pip_packages[@]}
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install tex packages.

installTexPackages() {
  if [[ $texPackagesFlag == 1 ]]; then
    say 'Installing tex packages.'
    yay -S --noconfirm ${tex_packages[@]}
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

cloneMyRepos() {
  if [[ $myReposFlag == 1 ]]; then
    say 'Cloning my repositories.'
    for r in "${repos[@]}"
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
    echo "Deleting symbolic links."
    # Symlinks at .config
#    rm -rfv ~/.config/Thunar
    rm -rfv ~/.bash_logout
    rm -rfv ~/.config/alacritty
    rm -rfv ~/.config/awesome
    rm -rfv ~/.config/bspwm
    rm -rfv ~/.config/dconf
    rm -rfv ~/.config/dunst
    rm -rfv ~/.config/kitty
    rm -rfv ~/.config/lvim
    rm -rfv ~/.config/nvim
    rm -rfv ~/.config/picom
    rm -rfv ~/.config/polybar
    rm -rfv ~/.config/ranger
    rm -rfv ~/.config/remmina
    rm -rfv ~/.config/rofi
    rm -rfv ~/.config/screenkey.json
    rm -rfv ~/.config/sxhkd
    rm -rfv ~/.config/volumeicon
    rm -rfv ~/.config/wallpaper

    # Symlinks at $HOME
    rm -rfv ~/.bash_logout
    rm -rfv ~/.bash_profile
    rm -rfv ~/.bashrc
    rm -rfv ~/.bashrc-personal
    rm -rfv ~/.config.vim
    rm -rfv ~/.dircolors
    rm -rfv ~/.gitconfig
    rm -rfv ~/.gitignore_global
    rm -rfv ~/.inputrc
    rm -rfv ~/.latexmkrc
    rm -rfv ~/.mailcap
    rm -rfv ~/.muttrc
    rm -rfv ~/.ssh
    rm -rfv ~/.tmux
    rm -rfv ~/.tmux.conf
    rm -rfv ~/.vim
    rm -rfv ~/.vimrc
    rm -rfv ~/.vimrc_background
    rm -rrf ~/.xinitrc
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ createSymLinks

createSymLinks() {
  if [[ $symlinksFlag == 1 ]]; then
    say 'Creating symbolic links.'
    mkdir -p ~/.config/bspwm
    mkdir -p ~/.config/sxhkd
    mkdir -p ~/.config/ranger
    # Symlinks at .config
    ln -fsv ~/git/dotfiles/alacritty             ~/.config/alacritty
    ln -fsv ~/git/dotfiles/awesome               ~/.config/awesome
    ln -fsv ~/git/dotfiles/bspwm                 ~/.config/bspwm
    ln -fsv ~/git/dotfiles/dconf                 ~/.config/dconf
    ln -fsv ~/git/dotfiles/dunst                 ~/.config/dunst
    ln -fsv ~/git/dotfiles/kitty                 ~/.config/kitty
    ln -fsv ~/git/dotfiles/picom                 ~/.config/picom
    ln -fsv ~/git/dotfiles/polybar               ~/.config/polybar
    ln -fsv ~/git/dotfiles/ranger                ~/.config/ranger
    ln -fsv ~/git/dotfiles/remmina               ~/.config/remmina
    ln -fsv ~/git/dotfiles/rofi                  ~/.config/rofi
    ln -fsv ~/git/dotfiles/sk/screenkey.json     ~/.config/screenkey.json
    ln -fsv ~/git/dotfiles/sxhkd                 ~/.config/sxhkd
    ln -fsv ~/git/dotfiles/volumeicon            ~/.config/volumeicon
    ln -fsv ~/git/dotfiles/wallpaper             ~/.config/wallpaper
    ln -fsv ~/git/lvim.traap                     ~/.config/lvim
    ln -fsv ~/git/nvim.traap	                 ~/.config/nvim

    # Symlinks at $HOME
    ln -fsv ~/git/dotfiles/bash/bash_logout      ~/.bash_logout
    ln -fsv ~/git/dotfiles/bash/bash_profile     ~/.bash_profile
    ln -fsv ~/git/dotfiles/bash/bashrc           ~/.bashrc
    ln -fsv ~/git/dotfiles/bash/bashrc-personal  ~/.bashrc-personal
    ln -fsv ~/git/dotfiles/bash/dircolors        ~/.dircolors
    ln -fsv ~/git/dotfiles/bash/inputrc          ~/.inputrc
    ln -fsv ~/git/dotfiles/bash/xinitrc          ~/.xinitrc
    ln -fsv ~/git/dotfiles/git/gitconfig         ~/.gitconfig
    ln -fsv ~/git/dotfiles/git/gitignore_global  ~/.gitignore_global
    ln -fsv ~/git/dotfiles/latex/latexmkrc       ~/.latexmkrc
    ln -fsv ~/git/mutt/mailcap                   ~/.mailcap
    ln -fsv ~/git/mutt/muttrc                    ~/.muttrc
    ln -fsv ~/git/ssh                            ~/.ssh
    ln -fsv ~/git/ssh/config.vim                 ~/.config.vim
    ln -fsv ~/git/tmux                           ~/.tmux
    ln -fsv ~/git/tmux/tmux.conf                 ~/.tmux.conf
    ln -fsv ~/git/vim                            ~/.vim
    ln -fsv ~/git/vim/vimrc                      ~/.vimrc
    ln -fsv ~/git/vim/vimrc_background           ~/.vimrc_background
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
# {{{ Install LunarVim

installLunarVim() {
  if [[ $lunarVimFlag == 1 ]]; then
    say 'Install LunarVim.'
    local release='release-1.2/neovim-0.8'
    local cmdUrl='https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh'
    LV_BRANCH=$release bash <(curl -s $cmdUrl)
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Update mirror list with reflector

updateMirrorList () {
  if [[ $mirroirFlag == 1 ]]; then
    say 'Updating mirror list.'

    sudo reflector -c "United States" \
      -f 12 -l 10 -n 12 \
      --save /etc/pacman.d/mirrorlist
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadNeovimluginsconf

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

    say 'Installing ruby-build dependencies.'
    sudo pacman -Syu --noconfirm ${ruby_build_packages[@]}

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
      rspec \
      neovim

    echo 'Ruby Gems installed.'
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Rust

installRust() {
  if [[ $rustFlag == 1 ]]; then

    # Install Rust
    curl --proto '=https' --tlsv1.2 -sFf https://sh.rustup.rs | sh
    echo 'Rust installed.'
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Swap CAPSLOCK with ESC key.

swapCapsLockAndEscKey() {
  [[ $swapKeysFlag == 1 ]] && sayAndDo 'setxkbmap -option caps:swapescape'
}

# -------------------------------------------------------------------------- }}}
# {{{ Stop WSL Autogeneration

stopWslAutogeneration () {
  if [[ $wslFlag == 1 ]]; then
    say 'Stop WSL autogeneration'
    cd $cwd

    # Copy host and resolv.conf to /etc.
    sudo cp -v hosts /etc/.

    # TODO: Not supported yet.
    # sudo cp -v resolv.conf /etc/.

    # Create wsl.conf from template.
    template=wsl-template.conf
    conf=/etc/wsl.conf
    sudo cp -v $template $conf

    # Replace wsl-template.conf/WSL-[HOST|USER]-Name with
    #         bootstrap-archlinux/config/$wsl[Host|User]Name
    sudo sed -i "s/WSL-HOST-NAME/$wslHostName/g" $conf
    sudo sed -i "s/WSL-USER-NAME/$wslUserName/g" $conf
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Make and configure ssh directory.

installSshDir() {
  if [[ $sshDirFlag == 1 ]]; then
    say 'Initialize .ssh/config.'
    mkdir -p $cloneRoot/ssh

    # Create ssh/config from template.
    template=ssh-config-template
    config=$cloneRoot/ssh/config
    cp -v $template $config

    # Repace ssh-config-template/GIT-USER-NAME with
    #        bootstrap-archlinux/config/$gitUserName
    sed -i "s/GIT-USER-NAME/$gitUserName/g" $config

    # Repace ssh-config-template/WSL-HOST-NAME with
    #        bootstrap-archlinux/config/$wslHostName
    sed -i "s/WSL-HOST-NAME/$wslHostName/g" $config

    say 'Initialize .ssh/config.vim'
    touch $cloneRoot/ssh/config.vim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Generate sshkey for this host

generateSshHostKey () {
  if [[ $sshHostKeyFlag == 1 ]]; then
    say 'Generate ssh host key.'
    mkdir -p $cloneRoot/ssh
    ssh-keygen -f $cloneRoot/ssh/$wslHostName
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Set sshkey permissions

setSshPermissions() {

  if [[ $sshHostKeyFlag == 1 ]]; then
    say 'Setting ssh permissions.'
    chmod 600 $cloneRoot/ssh/*
    chmod 644 $cloneRoot/ssh/*.pub
    # chmod 700 $cloneRoot/ssh/.git
  fi
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
