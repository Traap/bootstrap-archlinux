# TraapReset

I use a bash script resetTraap to reset my environment.  I use this scripts
from Arch Linux, ArcoLinux, msys, WSL1 and WSL2 Linux machines.


### resetTraap does NOT.
1. Install or update the operating system.
2. Does not perform any sanity or error checking.

### resetTraap DOES:
1. Clones repositories I use daily.
2. Recreates symbolic links.
3. Configures VIM and my plugins.

### Disclaimers done.  Usage:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Traap/TraapReset/master/install.sh)"
```
