echo "

 ___           _           ___                  __   __ __  __ 
/   \ _ _  __ | |_        |   \  ___ __ __      \ \ / /|  \/  |
| - || '_|/ _||   \       | |) |/ -_)\ V /       \   / | |\/| |
|_|_||_|  \__||_||_|      |___/ \___| \_/         \_/  |_|  |_|


----------------------------------------------------------------

Welcome to arch-dev-vm installation.
This installation script will automatically create a full ArchLinux Development Setup for VMs
for you. 

==> PLEASE MAKE SURE TO HAVE UEFI CONFIGURED FOR YOUR VM! 
This script doesn't check for EFI compatibility yet

"
lsblk

echo "

==> We have listed all drives connected to your PC above.
"

read -p "Please select the VM's drive by typing the name shown (usually vda): " driveName

if [[ -z "$driveName" ]]; then
    echo "Your drive name is invalid."
    exit 1
fi

read -p "Do you really want to install (y/N) " doProceed

if [[ "$doProceed" != "y" ]]; then
    echo "Aborting..."
    exit 0
fi

echo "

==> Please stand by as we install your OS.

"
sleep 2


wipefs -a "/dev/$driveName"
sleep 2
echo -e "
g
n
1

+100M
n
2


w
q" | fdisk "/dev/$driveName"

echo "

==> Partitioning complete, formatting...

"

timedatectl

echo "y\n" | mkfs.ext4 "/dev/${driveName}2"
echo "y\n" | mkfs.fat -F 32 "/dev/${driveName}1"
mount "/dev/${driveName}2" /mnt
mkdir /mnt/boot
mount "/dev/${driveName}1" /mnt/boot

pacstrap -K /mnt base linux-zen linux-firmware nano networkmanager efibootmgr grub man python-pip git npm nodejs xfce4 base-devel gcc fish sudo gdm plymouth --noconfirm


echo "

==> Finished installing the base system, preparing for chroot

"

sleep 2

genfstab -U /mnt >> /mnt/etc/fstab

echo "

==> Entering chroot

"

sleep 2

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

cd /root

git clone https://github.com/simplePCBuilding/arch-dev-vm

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


echo "






 ___           _           ___                  __   __ __  __ 
/   \ _ _  __ | |_        |   \  ___ __ __      \ \ / /|  \/  |
| - || '_|/ _||   \       | |) |/ -_)\ V /       \   / | |\/| |
|_|_||_|  \__||_||_|      |___/ \___| \_/         \_/  |_|  |_|


----------------------------------------------------------------

DONE!
Congratulations, you now have a fully set up linux VM.

"

sleep 2