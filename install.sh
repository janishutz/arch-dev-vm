echo "

 ___           _           ___                  __   __ __  __ 
/   \ _ _  __ | |_        |   \  ___ __ __      \ \ / /|  \/  |
| - || '_|/ _||   \       | |) |/ -_)\ V /       \   / | |\/| |
|_|_||_|  \__||_||_|      |___/ \___| \_/         \_/  |_|  |_|


----------------------------------------------------------------

Welcome to arch-dev-vm installation.
This installation script will automatically create a full ArchLinux Development Setup for VMs
for you. 

"

# List all drives connected
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

# Save drive name for future use
echo "${driveName}" > ~/arch-dev-vm/drive
chmod 777 ~/arch-dev-vm/drive

echo "

==> Please stand by as we install your OS.

"
sleep 2

# Unmount and wipe selected drive
umount -R /mnt

wipefs -a "/dev/$driveName"

sleep 2

# Format disk using fstab
echo -e "
g
n
1

+1M
n
2

+256M
n
3


t
1
4
w
q" | fdisk "/dev/$driveName"

echo "

==> Partitioning complete, formatting...

"

# Format & sync time
timedatectl

echo "y\n" | mkfs.ext4 "/dev/${driveName}3"
echo "y\n" | mkfs.fat -F 32 "/dev/${driveName}2"
mount "/dev/${driveName}3" /mnt
mkdir /mnt/boot
mount "/dev/${driveName}2" /mnt/boot


# Install packages
pacstrap -K /mnt base linux-zen linux-firmware nano networkmanager efibootmgr grub man git xfce4 base-devel fish sudo gdm plymouth neovim --noconfirm


echo "

==> Finished installing the base system, preparing for chroot

"

sleep 2

genfstab -U /mnt >> /mnt/etc/fstab

echo "

==> Entering chroot

"

sleep 2

mkdir /mnt/root
cp -rv ~/arch-dev-vm /mnt/root/arch-dev-vm/

arch-chroot /mnt /root/arch-dev-vm/chroot.sh

# Chroot is running

umount -R /mnt


echo "






 ___           _           ___                  __   __ __  __ 
/   \ _ _  __ | |_        |   \  ___ __ __      \ \ / /|  \/  |
| - || '_|/ _||   \       | |) |/ -_)\ V /       \   / | |\/| |
|_|_||_|  \__||_||_|      |___/ \___| \_/         \_/  |_|  |_|


----------------------------------------------------------------

DONE!
Congratulations, you now have a fully set up ArchLinux VM.

"

sleep 2