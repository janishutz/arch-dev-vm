# This file will be executed automatically once in chroot

ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

cp /root/arch-dev-vm/locale.gen /etc/locale.gen

hwclock --systohc

locale-gen

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=de_CH-latin1" > /etc/vconsole.conf
echo "arch-dev-vm" > /etc/hostname

echo "

==> Finished configuring, creating initramfs

"

sleep 2

mkinitcpio -P
plymouth-set-default-theme -R script

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
grub-mkconfig -o /boot/grub/grub.cfg

echo "

==> Bootloader set up.

"

echo "

==> Creating new user, please choose a password once prompted!

"

read -p "Choose a password: " pwd

useradd -m arch-is-best
passwd arch-is-best << EOD
${pwd}
${pwd}
EOD
usermod -aG wheel arch-is-best

rm -rf /home/arch-is-best/arch-dev-vm
mv /root/arch-dev-vm/* /home/arch-is-best/arch-dev-vm

echo "

==> New user created! Please enter the password for the new user to switch to it
to finish up setup

"

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

visudo

systemctl enable gdm.service


exit