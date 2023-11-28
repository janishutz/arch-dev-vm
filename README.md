# Arch-Dev-VM

This repo contains scripts to install a full Archlinux System with Xfce complete with the following additional packages:
- VSCodium (with custom settings)
- GDM (Gnome Display Manager)
- AUR helper YAY
- pip (optional)
- node & npm (optional)
- rustup (optional)
- neovim & nano 

You also get a fully configured Sudo user

# IMPORTANT: PLEASE ONLY INSTALL ON A VM OR ON A DEVICE WITH NO ADDITIONAL DATA ON IT YOU'D LIKE TO KEEP


# Running
First, [download](https://archlinux.org/download/) an ArchLinux ISO (scroll down to mirrors).

Then, set up a VM using for example VMWare Workstation Player 16

On a live-booted archlinux installer, run the following commands

```
    ls /usr/share/kbd/keymaps/**/*.map.gz
    loadkeys [IDENTIFIER HERE (find it in the output above), usually of form de_CH-latin1, refer to blog for more instructions]
    pacman-key --init
    pacman -Sy git
    git clone https://github.com/simplePCBuilding/arch-dev-vm
    cd arch-dev-vm
    ./install.sh
```

and follow the on-screen prompts

## Editing the sudoers file
In the sudoers file, you need to uncomment the 15th line from the botton, just below the line that says
"## Uncomment to allow members of group wheel to execute any command"

Remove the # in the subsequent line and hit Ctrl + S, then Ctrl + X. This will allow all members
of the user group "wheel" to execute any command. 