#!/bin/sh

# SYSTEMD BOOT

bootctl install

cat <<EOF > /boot/loader/loader.conf
default arch
timeout 2
editor 1
console-mode max
EOF

touch /boot/loader/entries/arch.conf

cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3
EOF

## REFLECTOR

pacman -Sy
pacman -S reflector --noconfirm

reflector --score 5 --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

# CONFIGURAÇÃO

touch /etc/hostname
echo "emcasadormindo" > /etc/hostname

sed -i -- 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i -- 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

touch /etc/locale.conf

cat <<EOF > /etc/locale.conf
LANG=pt_BR.UTF-8
LANGUAGE=pt_BR
EOF

touch /etc/vconsole.conf
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

hwclock --utc --systohc
timedatectl set-ntp true

# DESKTOP

pacman -S xorg-server xorg-xrandr xorg-xinput xorg-xinit xorg-xclock xorg-xbacklight --noconfirm 

pacman -S plasma-desktop plasma-meta sddm sddm-kcm dolphin konsole ark gwenview okular spectacle elisa kate breeze breeze-icons firefox firefox-i18n-pt-br xdg-user-dirs --noconfirm

pacman -S colord colord-kde fuse ntfs-3g fstrm packagekit-qt5 sudo --noconfirm

pacman -S linux-headers --noconfirm

# FONTES

pacman -S ttf-dejavu ttf-liberation --noconfirm

sddm-greeter --theme /usr/share/sddm/themes/Breeze

# BLUETOOTH

pacman -S bluez pulseaudio-bluetooth --noconfirm

# SERVIÇOS

systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer

# DRIVERS

pacman -S intel-ucode xf86-video-intel libva-intel-driver libva-mesa-driver mesa vulkan-intel vulkan-radeon vulkan-tools xf86-input-libinput gst-libav --noconfirm

touch /etc/X11/xorg.conf.d/20-intel.conf

cat <<EOF > /etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
   Identifier "Intel Graphics"
   Driver "intel"
   Option "DRI" "3"
   Option "TearFree" "true"
EndSection
EOF

# KERNEL INITRD

mkinitcpio -P

# USUÁRIO

useradd -m -g users -G wheel,storage,power,video -s /bin/bash yuri

# XINIT

touch ~/.xinitrc

echo "exec startplasma-x11" > ~/.xinitrc

echo -e "yuri\nyuri" | passwd
echo -e "yuri\nyuri" | passwd yuri

sed -i -- 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

cd .. && rm -rf arch
