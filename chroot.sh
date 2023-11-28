# This file will be executed automatically once in chroot

# Set time zone
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

driveName=$(cat /root/arch-dev-vm/drive)

hwclock --systohc

# Generate locales
cp /root/arch-dev-vm/locale.gen /etc/locale.gen
locale-gen

# Configure locale, kb layout & hostname
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=de_CH-latin1" > /etc/vconsole.conf
echo "arch-dev-vm" > /etc/hostname

echo "

==> Finished configuring, creating initramfs

"

sleep 2

# Copy mkinitcpio config over to enable plymouth
cp /root/arch-dev-vm/mkinitcpio.conf /etc/mkinitcpio.conf
plymouth-set-default-theme -R script


# set up arch4edu
curl -O https://mirrors.tuna.tsinghua.edu.cn/arch4edu/any/arch4edu-keyring-20200805-1-any.pkg.tar.zst
pacman -U arch4edu-keyring-20200805-1-any.pkg.tar.zst --noconfirm

# FUTURE: Add sha256sum verification

# Test boot mode (if efi or csm)
bootMode=$(cat /sys/firmware/efi/fw_platform_size)

# Install grub (bootloader)
if [[ "$bootMode" == "64" ]]; then
    echo "
    
    ==> Detected EFI boot mode. Setting up accordingly.
    
    "
    mkdir /boot/EFI
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
else
    echo "
    
    ==> Detected CSM / BIOS boot mode. Setting up accordingly.
    
    "
    grub-install --target=i386-pc "/dev/${driveName}"
fi
grub-mkconfig -o /boot/grub/grub.cfg

echo "

==> Bootloader set up.

==> Creating new user, please choose a password once prompted!

"

read -p "Choose a password: " pwd

# Create users
useradd -m arch-is-best
sleep 2
passwd arch-is-best << EOD
${pwd}
${pwd}
EOD
usermod -aG wheel arch-is-best

rm -rfv /home/arch-is-best/arch-dev-vm

sleep 3

mkdir --parent /home/arch-is-best/arch-dev-vm
ls /root/arch-dev-vm


# Prepare for switching to new user
mv -v /root/arch-dev-vm /home/arch-is-best/

sleep 2

ls /home/arch-is-best/arch-dev-vm

echo "

==> New user created! Please enter the password for the new user to switch to it
to finish up setup

"

sleep 2

# Add additional packages
read -p "Do you want to have a barebone (b) or complete (c) install? " installType

if [[ "$installType" == "c" ]]; then
    pacman -Syu --noconfirm nodejs npm rustup kate python-pip gcc
fi

pacman -Syu --noconfirm vscodium

chmod -R 777 /home/arch-is-best/arch-dev-vm/config


# Head into userland with userland.sh script (run all operations requiring root before!)
chmod 777 /home/arch-is-best/arch-dev-vm/vscode-extensions
su arch-is-best -c /home/arch-is-best/arch-dev-vm/userland.sh


sleep 2

echo "

==> All config completed.


Now it is time to edit the sudoers file. What you need to do is the following
(also explained in my blogpost and the README):

Scroll down to the section towards the very bottom where it says the following:
\"## Uncomment to allow members of group wheel to execute any command\"

Remove the # in the subsequent line and hit Ctrl + S, then Ctrl + X.

This is on line 15 from the bottom usually.

Now, once you are ready, press enter to open the file

"

read

EDITOR=nano visudo

systemctl enable gdm.service


exit