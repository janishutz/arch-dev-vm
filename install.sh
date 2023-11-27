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

umount -R /mnt

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

pacstrap -K /mnt base linux-zen linux-firmware nano networkmanager efibootmgr grub man git xfce4 base-devel fish sudo gdm plymouth --noconfirm


echo "

==> Finished installing the base system, preparing for chroot

"

sleep 2

genfstab -U /mnt >> /mnt/etc/fstab

echo "

==> Entering chroot

"

sleep 2

cp ~/arch-dev-vm /mnt/root/arch-dev-vm/

arch-chroot /mnt /root/chroot.sh

# Chroot is running

umount -R /mnt


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