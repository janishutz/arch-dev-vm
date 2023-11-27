# Arch-Dev-VM

This repo contains scripts to install a full Archlinux with Xfce install complete with the following additional packages:
- VSCodium (with custom settings)
- pip
- node & npm
- neovim & nano

# IMPORTANT: PLEASE ONLY INSTALL ON A VM OR ON A DEVICE WITH NO ADDITIONAL DATA ON IT YOU'D LIKE TO KEEP


# Running
First, [download](https://archlinux.org/download/) an ArchLinux ISO (scroll down to mirrors).

Then, set up a VM using for example VMWare Workstation Player 16

On a live-booted archlinux installer, run the following commands

```
    ls /usr/share/kbd/keymaps/**/*.map.gz
    loadkeys [IDENTIFIER HERE (find it in the output above)]
    pacman-key --init
    pacman -Sy git
    git clone https://github.com/simplePCBuilding/arch-dev-vm
    cd arch-dev-vm
    ./install.sh
```

and follow the on-screen prompts

## Editing the sudoers file
