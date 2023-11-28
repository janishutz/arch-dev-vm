# This file will be executed automatically once in chroot

# Set time zone
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

driveName=cat /root/arch-dev-vm/drive

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
# cp /root/arch-dev-vm/mkinitcpio.conf /etc/mkinitcpio.conf
# TODO: plymouth-set-default-theme -R script

# Test boot mode (if efi or csm)
bootMode=cat /sys/firmware/efi/fw_platform_size

# Install grub (bootloader)
if [["$bootMode" == '64' ]]; then
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

"

echo "

==> Creating new user, please choose a password once prompted!

"

read -p "Choose a password: " pwd

# Create users
useradd -m arch-is-best
passwd arch-is-best << EOD
${pwd}
${pwd}
EOD
usermod -aG wheel arch-is-best

rm -rfv /home/arch-is-best/arch-dev-vm
mkdir --parent /home/arch-is-best/arch-dev-vm
ls /root/arch-dev-vm


mv -v /root/arch-dev-vm /home/arch-is-best/arch-dev-vm

sleep 2

ls /home/arch-is-best/arch-dev-vm

echo "

==> New user created! Please enter the password for the new user to switch to it
to finish up setup

"

# Head into userland with userland.sh script
chmod 777 /home/arch-is-best/arch-dev-vm/vscode-extensions
su arch-is-best -c /home/arch-is-best/arch-dev-vm/userland.sh



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

EDITOR=nano visudo

systemctl enable gdm.service


exit