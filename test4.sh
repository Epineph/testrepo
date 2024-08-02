#!/bin/bash

#set -e  # Exit immediately if a command exits with a non-zero status

# Enable multilib repository and parallel downloads
sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
sed -i 's/^#\(ParallelDownloads = 5\)/\1/' /etc/pacman.conf

# Synchronize time
timedatectl set-ntp true

# Update mirrors and package database
pacman -Syyy

# Install required utilities
pacman -S fzf lvm2 git mdadm --needed --noconfirm

# Disk Selection
selected_disk=$(lsblk -d -o NAME,SIZE,MODEL | grep -E '^sd|^nvme' | fzf -1 -0 | awk '{print "/dev/"$1}')

# Ensure a disk is selected
if [ -z "$selected_disk" ]; then
    echo "No disk selected for installation."
    exit 1
fi

# Wipe disk
wipefs --all --force $selected_disk

# Partition Disk
parted $selected_disk --script mklabel gpt
parted $selected_disk --script mkpart ESP fat32 1MiB 513MiB
parted $selected_disk --script set 1 esp on
parted $selected_disk --script mkpart primary 513MiB 100%

# Ensure partitions are recognized
partprobe

# Encrypt the primary partition using LUKS
echo -n "Enter passphrase for LUKS encryption: "
read -s LUKS_PASSPHRASE
echo
echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat ${selected_disk}p2 -
echo -n "$LUKS_PASSPHRASE" | cryptsetup open ${selected_disk}p2 cryptlvm -

# Set up LVM
pvcreate /dev/mapper/cryptlvm
vgcreate volgroup0 /dev/mapper/cryptlvm
lvcreate -L 32GB volgroup0 -n lv_swap
lvcreate -L 50GB volgroup0 -n lv_root
lvcreate -l 100%FREE volgroup0 -n lv_home

# Encrypt the logical volumes
echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat /dev/volgroup0/lv_root -
echo -n "$LUKS_PASSPHRASE" | cryptsetup open /dev/volgroup0/lv_root cryptroot -
echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat /dev/volgroup0/lv_swap -
echo -n "$LUKS_PASSPHRASE" | cryptsetup open /dev/volgroup0/lv_swap cryptswap -
echo -n "$LUKS_PASSPHRASE" | cryptsetup luksFormat /dev/volgroup0/lv_home -
echo -n "$LUKS_PASSPHRASE" | cryptsetup open /dev/volgroup0/lv_home crypthome -

# Format the logical volumes
mkfs.ext4 /dev/mapper/cryptroot
mkfs.ext4 /dev/mapper/crypthome
mkswap /dev/mapper/cryptswap

# Format the ESP partition
mkfs.fat -F32 ${selected_disk}p1

# Mount Partitions
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot/efi
mount ${selected_disk}p1 /mnt/boot/efi
mkdir /mnt/home
mount /dev/mapper/crypthome /mnt/home
swapon /dev/mapper/cryptswap

# Install essential packages
pacstrap /mnt base linux linux-firmware lvm2

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt /bin/bash <<EOF

# Set timezone
ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime
hwclock --systohc

# Localization
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Configure the network
echo "archlinux" > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOT

# Set the root password


# Install necessary packages
pacman -S grub efibootmgr networkmanager

# Configure mkinitcpio
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Configure GRUB
sed -i 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="cryptdevice=UUID=$(blkid -s UUID -o value ${selected_disk}p2):cryptlvm root=\/dev\/mapper\/cryptroot"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Add crypttab entries
echo "cryptswap /dev/volgroup0/lv_swap none luks,discard" > /etc/crypttab
echo "crypthome /dev/volgroup0/lv_home none luks,discard" >> /etc/crypttab

# Enable services
systemctl enable NetworkManager

EOF

# Unmount filesystems
umount -R /mnt
swapoff -a

# Reboot the system
reboot