#!/bin/sh

# Installation partition is /dev/sda2

# SYSTEMD BOOT

bootctl install

cat <<EOF > /boot/loader/loader.conf
default arch
timeout 2
editor 1
console-mode max
EOF

cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=/dev/sda2 rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3 snd_hda_codec_hdmi.enable_silent_stream=0
EOF

## REFLECTOR

# pacman -Sy
# pacman -S reflector --noconfirm

# reflector --score 5 --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

# CONFIGURATION

echo "arch" > /etc/hostname

sed -i -- 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i -- 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

cat <<EOF > /etc/locale.conf
LANG=pt_BR.UTF-8
LC_ADDRESS=pt_BR.UTF-8
LC_IDENTIFICATION=pt_BR.UTF-8
LC_MEASUREMENT=pt_BR.UTF-8
LC_MONETARY=pt_BR.UTF-8
LC_NAME=pt_BR.UTF-8
LC_NUMERIC=pt_BR.UTF-8
LC_PAPER=pt_BR.UTF-8
LC_TELEPHONE=pt_BR.UTF-8
LC_TIME=pt_BR.UTF-8
EOF

echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

hwclock --utc --systohc

timedatectl set-ntp true

# DESKTOP

pacman -S xorg-server xorg-xrandr xorg-xinit xorg-xclock xorg-xbacklight xorg-xrdb xorg-xrefresh xorg-xkill xorg-xgamma --noconfirm 

pacman -S plasma-desktop plasma-meta sddm sddm-kcm dolphin konsole ark gwenview okular spectacle elisa kate kcalc ktorrent partitionmanager breeze breeze-icons firefox firefox-i18n-pt-br --noconfirm

pacman -S sudo nano bash-completion colord colord-kde fuse ntfs-3g fstrm packagekit-qt5 xdg-user-dirs --noconfirm

pacman -S libappindicator-gtk2 libappindicator-gtk3 --noconfirm

pacman -S linux-headers --noconfirm

# FONTS

pacman -S ttf-dejavu ttf-liberation --noconfirm

# BLUETOOTH

# pacman -S bluez pulseaudio-bluetooth --noconfirm

# SERVICES

systemctl enable sddm
systemctl enable NetworkManager
# systemctl enable bluetooth
systemctl enable fstrim.timer

# BALOO

balooctl disable

# DRIVERS INTEL

pacman -S intel-ucode libva-intel-driver lib32-libva-intel-driver libva-mesa-driver lib32-libva-mesa-driver mesa lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-tools virtualgl lib32-virtualgl gst-libav --noconfirm

pacman -S xf86-input-libinput xf86-video-fbdev xf86-video-vesa --noconfirm

# KERNEL INITRD

mkinitcpio -P

# FASTBOOT

echo "options i915 fastboot=1" > /etc/modprobe.d/i915.conf

# THEME

sddm-greeter --theme /usr/share/sddm/themes

cat <<EOF > /etc/sddm.conf
[General]
EnableHiDPI=false

[Theme]
Current=breeze
CursorTheme=breeze_cursors
EOF

# DISK NAME

e2label /dev/sda2 'Arch Linux'

# USER

useradd -m -g users -G wheel,storage,power,video -s /bin/bash yuri

# PASSWORD

echo -e "root\root" | passwd
echo -e "yuri\nyuri" | passwd yuri

# SUDO

sed -i -- 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
