# bootstrap-archlinux

I use this repository to bootstrap ArchLinux installation both on the metal and
WSL2.

# bootstrap-archlinux does NOT.
1. Install the operating system.
2. Does not perform any sanity or error checking.

# bootstrap-archlinux DOES:
1. Installs packages.
1. Clones repositories used daily.
2. Recreates symbolic links.
3. Configures VIM and plugins.

# Disclaimers done.  Usage:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Traap/bootstrap-archlinux/master/install.sh)"
```

# config
List flags you can set
1. false && true ... Duh!
2. Options are listed alphabetically only because I scan them faster.
3. A few other options.

# Pacages to install.
aaa_pacages is an arry of packages to install.  Replace aaa_ in the list below.

1. pacman_packages
2. pip_packages
3. tex_packages
4. yay_packages
