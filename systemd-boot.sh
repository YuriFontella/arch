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
options root=/dev/sda2 rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3 snd_hda_codec_hdmi.enable_silent_stream=0
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

pacman -S xorg-server xorg-xrandr xorg-xinit xorg-xclock xorg-xbacklight xorg-xrdb --noconfirm 

pacman -S plasma-desktop plasma-meta sddm sddm-kcm dolphin konsole ark gwenview okular spectacle elisa kate ktorrent partitionmanager breeze breeze-icons firefox firefox-i18n-pt-br --noconfirm

pacman -S sudo colord colord-kde fuse ntfs-3g fstrm packagekit-qt5 xdg-user-dirs --noconfirm

pacman -S libappindicator-gtk2 libappindicator-gtk3 --noconfirm

pacman -S linux-headers --noconfirm

# FONTES

pacman -S ttf-dejavu ttf-liberation --noconfirm

# BLUETOOTH

pacman -S bluez pulseaudio-bluetooth --noconfirm

# SERVIÇOS

systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable fstrim.timer

# DRIVERS INTEL

pacman -S intel-ucode libva-intel-driver libva-mesa-driver mesa vulkan-intel vulkan-tools xf86-input-evdev gst-libav --noconfirm

touch /etc/X11/xorg.conf.d/20-intel.conf

cat <<EOF > /etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
  Identifier "Intel Graphics"
  Driver "intel"
  Option "TearFree" "true"
EndSection
EOF

# KERNEL INITRD

mkinitcpio -P

# USUÁRIO

useradd -m -g users -G wheel,storage,power,video -s /bin/bash yuri

# XRESOURCES

touch ~/.Xresources

cat <<EOF > ~/.Xresources
Xft.dpi: 96

Xft.hintstyle: hintmedium
Xft.hinting: true
EOF

# XINIT

touch ~/.xinitrc

echo "exec startplasma-x11" > ~/.xinitrc
echo "[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources" >> ~/.xinitrc

# TEMA

sddm-greeter --theme /usr/share/sddm/themes

cat <<EOF > /etc/sddm.conf
[General]
EnableHiDPI=false

[Theme]
Current=breeze
CursorTheme=breeze_cursors
EOF

echo -e "yuri\nyuri" | passwd
echo -e "yuri\nyuri" | passwd yuri

sed -i -- 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

cd .. && rm -rf arch
