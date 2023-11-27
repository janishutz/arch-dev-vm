# This file will be executed automatically once in chroot

ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

cp /root/arch-dev-vm/locale.gen /etc/locale.gen

hwclock --systohc

locale-gen

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
echo "KEYMAP=de_CH.latin1" > /etc/vconsole.conf
echo "arch-dev-vm" > /etc/hostname

echo "

==> Finished configuring, creating initramfs

"

sleep 2

mkinitcpio -P
plymouth-set-default-theme -R script

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
grub-mkconfig -o /boot/grub/grub.cfg

echo "

==> Bootloader set up.

"

read -p "Do you want to have a barebone (b) or complete (c) install? " installType

if [[ "$installType" != "c" ]]; then
    yay -Syu --noconfirm nodejs npm rustup kate python-pip gcc
fi

yay -Syu --noconfirm vscodium

echo "

==> Creating new user, please choose a password once prompted!

"

read -p "Choose a password: " pwd

useradd -m arch-is-the-best
echo "$pwd" | passwd arch-is-the-best --stdin
usermod -aG wheel arch-is-the-best

echo "

==> New user created! Please enter the password for the new user to switch to it
to finish up setup

"

mv /root/arch-dev-vm/ /home/arch-is-best
chmod 777 /home/arch-is-best/vscode-extensions

su arch-is-best


echo "

==> Setup complete, adding config files to new user plus some other config

"

mkdir /home/arch-is-best/.config

mv /home/arch-is-best/arch-dev-vm/config/* /home/arch-is-best/.config

file="/home/arch-is-best/vscode-extensions"
while read line; do
    vscodium --install-extension "${line}"
done < "${file}"

echo "

==> We now need to change the shell to a more user-friendly one.
Please enter your password again

"

chsh -s /bin/fish

exit

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