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

read -p "Please select the VM's drive by typing the name shown: " driveName

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
echo -e "g
n
1

+100M
n
2


a
1
w
q"

echo "

==> Partitioning complete, formatting...

"

timedatectl

mkfs.ext4 "/dev/${driveName}2"
mkfs.fat -F 32 "/dev/${driveName}1"
mount "/dev/${driveName}2" /mnt
mkdir /mnt/boot
mount "/dev/${driveName}1" /mnt/boot

pacstrap -K /mnt base linux-zen linux-firmware nano networkmanager efibootgmr grub man python-pip git npm node xfce4


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

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
grub-mkconfig -o /boot/grub/grub.cfg