#!/bin/bash

set -e

# Variables
DISK1="/dev/nvme1n1"
DISK2="/dev/nvme0n1"
RAID_DEV="/dev/md0"
CRYPT_DEV="lvmraid"
VG_NAME="vg0"
ROOT_SIZE="110G"
SWAP_SIZE="32G"

# Partition the disks (GPT)
parted --script $DISK1 mklabel gpt
parted --script $DISK2 mklabel gpt

parted --script $DISK1 mkpart primary 1MiB 512MiB
parted --script $DISK1 set 1 boot on
parted --script $DISK1 mkpart primary 512MiB 200GB
parted --script $DISK1 mkpart primary 200GB 100%
parted --script $DISK2 mkpart primary 1MiB 512MiB
parted --script $DISK2 mkpart primary 512MiB 100%

# Create RAID-0 array using the third partition on nvme1n1 and the second partition on nvme0n1
mdadm --create --verbose $RAID_DEV --level=0 --raid-devices=2 ${DISK1}p3 ${DISK2}p2

# Encrypt the RAID array
cryptsetup luksFormat $RAID_DEV
cryptsetup open $RAID_DEV $CRYPT_DEV

# Create LVM on the encrypted RAID
pvcreate /dev/mapper/$CRYPT_DEV
vgcreate $VG_NAME /dev/mapper/$CRYPT_DEV

# Create logical volumes
lvcreate -L $SWAP_SIZE $VG_NAME -n swap
lvcreate -L $ROOT_SIZE $VG_NAME -n root
lvcreate -l 100%FREE $VG_NAME -n home

# Format the filesystems
mkfs.ext4 /dev/$VG_NAME/root
mkfs.ext4 /dev/$VG_NAME/home
mkswap /dev/$VG_NAME/swap

# Mount the filesystems
mount /dev/$VG_NAME/root /mnt
mkdir /mnt/home
mount /dev/$VG_NAME/home /mnt/home
swapon /dev/$VG_NAME/swap

# Mount the EFI partitions
mkfs.fat -F32 ${DISK1}p1
mkfs.fat -F32 ${DISK2}p1
mkdir /mnt/boot
mount ${DISK1}p1 /mnt/boot

# Install the base system
pacstrap /mnt base linux linux-firmware lvm2

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt /bin/bash <<EOF

# Set up time zone and localization
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set up hostname
echo "myhostname" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   myhostname.localdomain myhostname" >> /etc/hosts

# Set root password
echo "Enter root password:"
passwd

# Install necessary packages
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

# Configure mkinitcpio
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block mdadm_udev keyboard keymap encrypt lvm2 filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Configure GRUB for encrypted LVM
UUID=$(blkid -s UUID -o value $RAID_DEV)
sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$UUID:$CRYPT_DEV root=/dev/$VG_NAME/root\"|" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

EOF

# Unmount all partitions and reboot
#umount -R /mnt
#just any settings, such as the timezone and hostname, to match your preferences before running it.