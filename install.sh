#!/bin/bash
# {{{ Notes

# Disable variable referenced but not assigned.
#shellcheck disable=SC2154

# Disable cant follow non-constant source.
#shellcheck disable=SC1090

# Disable not following file.  file does not exist.
#shellcheck disable=SC1091

# -- ----------------------------------------------------------------------- }}}
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
  installBashGitPrompt
  installPacmanPackages
  installYayPackages
  installPipPackages
  installLuarocksPackages
  installTexPackages

  # Update mirrors.
  updateMirrorList

  # Install tools tools
  installGits
  installNvims

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
  cloneBase16Colors
  cloneMyRepos
  cloneTmuxPlugins

  # Build applications from source code.
  buildKJV
  buildNeovim
  addProgramsNeoVimInterfacesWith

  # Install editors and terminal multiplexers.
  installNodeJs
  loadTmuxPlugins
  loadNeovimPlugins
  loadVimPlugins

  # Install desktop applications.
  installBspwm
  installHyrpland
  installMsWindowsApps
  installHeyMail

  # Final personalization.
  swapCapsLockAndEscKey
  setTimezone

  # Source bashrc for kicks ... :)
  [[ -f $HOME/.bashrc ]] && source "$HOME/.bashrc"
}

# -------------------------------------------------------------------------- }}}
# {{{ Tell them what is about to happen.

say() {
  echo '********************'
  echo "${1}"
}

# -------------------------------------------------------------------------- }}}
# {{{ Source all configuration files

sourceFiles() {
  missingFile=false

  files=(config repos packages)
  for f in "${files[@]}"
  do
    if [[ -f $f ]]; then
      source "$f"
    else
      missingFile=true
      echo "Configuration file $f is missing."
    fi
  done

  [[ $missingFile == true ]] && echo 'Missing file(s) program exiting.' && exit

}

# -------------------------------------------------------------------------- }}}
# {{{ Update OS Keys

updateOSKeys() {
  if [[ $osUpdateKeysFlag == true ]]; then
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
  [[ $osUpdateFlag == true ]] && sayAndDo 'sudo pacman -Syyu --noconfirm'
}

# -------------------------------------------------------------------------- }}}
# {{{ Install bspwm

installBspwm() {
  if [[ $desktopAppsFlag == true ]]; then
    say 'Installing BSPWM applications.'
    sudo yay -Syyu --noconfirm "${bspwm_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install BashGitPrompt

installBashGitPrompt() {
  if [[ $gitBashPromptFlag == true ]]; then
    say 'Cloning bash-git-prompt.'
    rm -rf ~/.bash-git-prompt
    src=https://github.com/magicmonty/bash-git-prompt
    dst=~/.bash-git-prompt
    git clone "$sr$dst"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Gits

installGits() {
  if [[ $gitsFlag == true ]]; then
    say 'Installing Gits.'
    url="https://raw.githubusercontent.com/Traap/gits/master/install.sh"
    /bin/bash -c "$(curl -fsSL $url)"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install HeyMail

installHeyMail() {
  if [[ $heyMailFlag == true ]]; then
    say 'Installing Hey Mail.'

    # Install Hey Mail
    git clone https://aur.archlinux.org/snapd.git
    cd snapd
    makepkg -si

    sudo systemctl enable --now snapd.socket

    sudo ln -s /var/lib/snapd/snap /snap

    # Next step is done after logout or reboot. Rats!
    # sudo snap install hey-mail
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Hyprland

installHyprland() {
  if [[ $hyprlandFlag == true ]]; then
    say 'Installing Hyprland applications.'
    sudo yay -Syyu --noconfirm "${hyprland_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install pacman packages.

installPacmanPackages() {
  if [[ $pacmanPackagesFlag == true ]]; then
    say 'Installing pacman packages.'
    sudo pacman -Syyu --noconfirm "${pacman_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Ruby

installRuby() {
  if [[ $rbenvFlag == true ]]; then

    say 'Installing ruby-build dependencies.'
    sudo pacman -Syu --noconfirm "${ruby_build_packages[@]}"

    say 'Acquire Ruby dependencies.'
    yay -S --noconfirm \
      rbenv \
      ruby-build \

    say 'Build and install Ruby.'
    eval "$(rbenv init -)"
    rbenv install "$rubyVersion"
    rbenv global "$rubyVersion"

    echo 'Ruby installed.'
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Ruby Gems

installRubyGems() {
  if [[ $rbenvFlag == true ]]; then

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
  if [[ $rustFlag == true ]]; then
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sFf https://sh.rustup.rs | sh
    echo 'Rust installed.'
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install other applications.

installMsWindowsApps() {
  if [[ $msWindowsAppsFlag == true ]]; then
    say 'Installing MS Windows applications.'
    sudo yay -Syyu --noconfirm "${ms_windows_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install node packages.

installNodeJs() {
  if [[ $nodeJsFlag == true ]]; then
    say 'Installing NodeJs packages .'
    sudo npm install -g "${nodejs_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install Nvims

installNvims() {
  if [[ $NvimsFlag == true ]]; then
    say 'Installing Nvims.'
    url="https://raw.githubusercontent.com/Traap/nvims/master/install.sh"
    /bin/bash -c "$(curl -fsSL $url)"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install yay packages.

installYayPackages() {
  if [[ $yayPackagesFlag == true ]]; then
    say 'Installing yay packages.'

    if [[ ! $(which yay) ]]; then
      say 'Building yay'
      git clone https://aur.archlinux.org/yay.git
      cd yay || exit
      makepkg -si
      cd ..
    fi

    yay -Syu --noconfirm "${yay_packages[@]}"
    libtool --finish /usr/lib/libfakeroot
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install pip packages.

installPipPackages() {
  if [[ $pipPackagesFlag == true ]]; then
    say 'Installing pip packages.'
    pip install "${pip_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install luarocks packages.

installLuarocksPackages() {
  if [[ $luarocksPackagesFlag == true ]]; then
    say 'Installing luarocks packages.'
    pip install "${luarocks_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Install tex packages.

installTexPackages() {
  if [[ $texPackagesFlag == true ]]; then
    say 'Installing tex packages.'
    yay -S --noconfirm "${tex_packages[@]}"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneMyRepos

cloneMyRepos() {
  if [[ $myReposFlag == true ]]; then
    say 'Cloning my repositories.'
    gits clone -r git
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneBase16Colors

cloneBase16Colors () {
  if [[ $base16ColorsFlag == true ]]; then
    say 'Cloning Base16 colors.'
    src=https://github.com/chriskempson/base16-shell
    dst=$cloneRoot/color/base16-shell
    git clone "$src" "$dst"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ cloneTmuxPlugins


cloneTmuxPlugins () {
  if [[ $tmuxPluginsFlag == true ]]; then
    say 'Cloning TMUX plugins.'
    src=https://github.com/tmux-plugins/tpm.git
    dst=$cloneRoot/tmux/plugins/tpm
    git clone "$src" "$dst"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Delete symbolic links

deleteSymLinks() {
  if [[ $deleteSymLinksFlag == 1 ]]; then
    echo "Deleting symbolic links."

    # Symlinks at .config
    rm -rfv ~/.config/Thunar
    rm -rfv ~/.config/alacritty
    rm -rfv ~/.config/autostart
    rm -rfv ~/.config/bspwm
    rm -rfv ~/.config/dconf
    rm -rfv ~/.config/dunst
    rm -rfv ~/.config/foot
    rm -rfv ~/.config/ghostty
    rm -rfv ~/.config/hypr
    rm -rfv ~/.config/kitty
    rm -rfv ~/.config/nvim
    rm -rfv ~/.config/neofetch
    rm -rfv ~/.config/picom
    rm -rfv ~/.config/polybar
    rm -rfv ~/.config/remmina
    rm -rfv ~/.config/rofi
    rm -rfv ~/.config/screenkey.json
    rm -rfv ~/.config/sxhkd
    rm -rfv ~/.config/volumeicon
    rm -rfv ~/.config/wallpaper
    rm -rfv ~/.config/waybar
    rm -rfv ~/.config/wayfire
    rm -rfv ~/.config/wayfire.ini
    rm -rfv ~/.config/wezterm
    rm -rfv ~/.config/wlogout
    rm -rfv ~/.config/wofi
    rm -rfv ~/.config/wofifull
    rm -rfv ~/.config/swaylock

    # Symlinks at $HOME
    rm -rfv ~/.bash_logout
    rm -rfv ~/.bash_profile
    rm -rfv ~/.bashrc
    rm -rfv ~/.bashrc_personal
    rm -rfv ~/.config.vim
    rm -rfv ~/.dircolors
    rm -rfv ~/.gitconfig
    rm -rfv ~/.gitignore_global
    rm -rfv ~/.inputrc
    rm -rfv ~/.latexmkrc
    # rm -rfv ~/.mailcap
    # rm -rfv ~/.muttrc
    rm -rfv ~/.ssh
    rm -rfv ~/.tmux
    rm -rfv ~/.tmux.conf
    rm -rfv ~/.vim
    rm -rfv ~/.vimrc
    rm -rfv ~/.xinitrc
    rm -rfv ~/.zshrc
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Create symbolic links
createSymLinks() {
  if [[ $createSymLinksFlag == 1 ]]; then
    echo "Creating symbolic links."
    mkdir -p ~/.config

    # Symlinks at .config
    ln -fsv ~/git/dotfiles/Thunar                ~/.config/Thunar
    ln -fsv ~/git/dotfiles/alacritty             ~/.config/alacritty
    ln -fsv ~/git/dotfiles/autostart             ~/.config/autostart
    ln -fsv ~/git/dotfiles/bspwm                 ~/.config/bspwm
    ln -fsv ~/git/dotfiles/dconf                 ~/.config/dconf
    ln -fsv ~/git/dotfiles/foot                  ~/.config/foot
    ln -fsv ~/git/dotfiles/dunst                 ~/.config/dunst
    ln -fsv ~/git/dotfiles/ghostty               ~/.config/ghostty
    ln -fsv ~/git/dotfiles/hypr                  ~/.config/hypr
    ln -fsv ~/git/dotfiles/kitty                 ~/.config/kitty
    ln -fsv ~/git/dotfiles/neofetch              ~/.config/neofetch
    ln -fsv ~/git/dotfiles/picom                 ~/.config/picom
    ln -fsv ~/git/dotfiles/polybar               ~/.config/polybar
    ln -fsv ~/git/dotfiles/remmina               ~/.config/remmina
    ln -fsv ~/git/dotfiles/rofi                  ~/.config/rofi
    ln -fsv ~/git/dotfiles/sk/screenkey.json     ~/.config/screenkey.json
    ln -fsv ~/git/dotfiles/sxhkd                 ~/.config/sxhkd
    ln -fsv ~/git/dotfiles/volumeicon            ~/.config/volumeicon
    ln -fsv ~/git/dotfiles/wallpaper             ~/.config/wallpaper
    ln -fsv ~/git/dotfiles/waybar                ~/.config/waybar
    ln -fsv ~/git/dotfiles/wayfire               ~/.config/wayfire
    ln -fsv ~/git/dotfiles/wayfire/wayfire.ini   ~/.config/wayfire.ini
    ln -fsv ~/git/dotfiles/wayfire/wf-shell.ini  ~/.config/wf-shell.ini
    ln -fsv ~/git/dotfiles/wezterm               ~/.config/wezterm
    ln -fsv ~/git/dotfiles/wlogout               ~/.config/wlogout
    ln -fsv ~/git/dotfiles/wofi                  ~/.config/wofi
    ln -fsv ~/git/dotfiles/wofifull              ~/.config/wofifull
    ln -fsv ~/git/dotfiles/swaylock              ~/.config/swaylock
    ln -fsv ~/git/nvim.traap                     ~/.config/nvim

    # Symlinks at $HOME
    ln -fsv ~/git/dotfiles/bash/bash_logout      ~/.bash_logout
    ln -fsv ~/git/dotfiles/bash/bash_profile     ~/.bash_profile
    ln -fsv ~/git/dotfiles/bash/bashrc           ~/.bashrc
    ln -fsv ~/git/dotfiles/bash/bashrc_personal  ~/.bashrc_personal
    ln -fsv ~/git/dotfiles/bash/dircolors        ~/.dircolors
    ln -fsv ~/git/dotfiles/bash/inputrc          ~/.inputrc
    ln -fsv ~/git/dotfiles/bash/xinitrc          ~/.xinitrc
    ln -fsv ~/git/dotfiles/git/gitconfig         ~/.gitconfig
    ln -fsv ~/git/dotfiles/git/gitignore_global  ~/.gitignore_global
    ln -fsv ~/git/dotfiles/latex/latexmkrc       ~/.latexmkrc
    # ln -fsv ~/git/mutt/mailcap                   ~/.mailcap
    # ln -fsv ~/git/mutt/muttrc                    ~/.muttrc
    ln -fsv ~/git/ssh                            ~/.ssh
    ln -fsv ~/git/ssh/config.vim                 ~/.config.vim
    ln -fsv ~/git/tmux                           ~/.tmux
    ln -fsv ~/git/tmux/tmux.conf                 ~/.tmux.conf
    ln -fsv ~/git/vim                            ~/.vim
    ln -fsv ~/git/vim/vimrc                      ~/.vimrc
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Build KJV

buildKJV() {
  if [[ $kjvFlag == true ]]; then
    say 'Building Authorized KJV.'
    src=https://github.com/Traap/kjv.git
    dst=$cloneRoot/kjv
    git clone "$src" "$dst"
    cd "$dst" || exit
    git checkout kjv-01
    make
    sudo mv kjv /usr/local/bin/.
    echo ""
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Build Neovim

buildNeovim() {
  if [[ $neovimBuildFlag == true ]]; then
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
      cd "${dst}" || exit
      git pull
    else
      echo 'Clone neovim sources.'
      git clone "$src" "$dst"
    fi

    echo 'Build neovim.'
    cd "${dst}" || exit
    sudo make CMANE_BUILD=Release install

    echo
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Add programs Neovim interfaces with.

addProgramsNeoVimInterfacesWith() {
  if [[ $neovimBuildFlag == true ]]; then
    say 'Add programs Neovim interfaces with.'
    gem install neovim
    sudo npm install -g neovim
    yarn global add neovim
    yay -S --noconfirm python-pip
    python3 -m pip install --user --upgrade pynvim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Update mirror list with reflector

updateMirrorList () {
  if [[ $mirrorFlag == true ]]; then
    say 'Updating mirror list.'

    sudo reflector -c "$reflectorLocation" \
      -f 12 -l 10 -n 12 \
      --save /etc/pacman.d/mirrorlist
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadNeovimluginsconf

loadNeovimPlugins() {
  if [[ $neovimPluginsFlag == true ]]; then
    say 'Loading neovim plugins.'
    nvim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadTmuxPlugins

loadTmuxPlugins() {
  if [[ $tmuxPluginsFlag == true ]]; then
    say 'Loading TMUX plugins.'
    ~/.tmux/plugins/tpm/bin/install_plugins
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ loadVimPlugins

loadVimPlugins() {
  if [[ $vimPluginsFlag == true ]]; then
    say 'Loading vim plugins.'
    vim
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Set timezone

setTimezone() {
  if [[ $timezoneFlag == true ]]; then
    say 'Setting timezone and ntp sync.'
    sudo timedatectl set-timezone $timezone
    sudo timedatectl set-ntp true
    sudo systemctl restart systemd-timesyncd
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Swap CAPSLOCK with ESC key.

swapCapsLockAndEscKey() {
  [[ $swapKeysFlag == true ]] && sayAndDo 'setxkbmap -option caps:swapescape'
}

# -------------------------------------------------------------------------- }}}
# {{{ Stop WSL Autogeneration

stopWslAutogeneration () {
  if [[ $wslFlag == true ]]; then
    say 'Stop WSL autogeneration'
    cd "$cwd" || exit

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
  if [[ $sshDirFlag == true ]]; then
    say 'Initialize .ssh/config.'
    mkdir -p "$cloneRoot/ssh"

    # Create ssh/config from template.
    template=ssh-config-template
    config=$cloneRoot/ssh/config
    cp -v "$template" "$config"

    # Repace ssh-config-template/GIT-USER-NAME with
    #        bootstrap-archlinux/config/$gitUserName
    sed -i "s/GIT-USER-NAME/$gitUserName/g" "$config"

    # Repace ssh-config-template/WSL-HOST-NAME with
    #        bootstrap-archlinux/config/$wslHostName
    sed -i "s/WSL-HOST-NAME/$wslHostName/g" "$config"

    say 'Initialize .ssh/config.vim'
    touch "$cloneRoot/ssh/config.vim"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Generate sshkey for this host

generateSshHostKey () {
  if [[ $sshHostKeyFlag == true ]]; then
    say 'Generate ssh host key.'
    mkdir -p "$cloneRoot/ssh"
    ssh-keygen -f "$cloneRoot/ssh/$wslHostName"
  fi
}

# -------------------------------------------------------------------------- }}}
# {{{ Set sshkey permissions

setSshPermissions() {

  if [[ $sshHostKeyFlag == true ]]; then
    say 'Setting ssh permissions.'
    chmod 600 "$cloneRoot/ssh/$wslHostName"
    chmod 644 "$cloneRoot/ssh/$wslHostName.pub"
  fi
  # chmod 700 $cloneRoot/ssh/.git
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
