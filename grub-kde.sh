#!/bin/sh

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

pacman -S plasma-desktop plasma-meta sddm sddm-kcm xdg-user-dirs sudo dolphin konsole ark gwenview okular kcalc spectacle elisa kwrite kate partitionmanager kolourpaint vlc firefox --noconfirm

# sddm-greeter --theme /usr/share/sddm/themes/breeze

# BLUETOOTH

pacman -S bluez pulseaudio-bluetooth --noconfirm

# SERVIÇOS

systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth

# GRUB

pacman -S grub --noconfirm

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# DRIVERS

pacman -S intel-ucode mesa libva-intel-driver libva-mesa-driver vulkan-intel --noconfirm

# USUÁRIO

useradd -m -g users -G wheel,storage,power,network,video -s /bin/bash yuri

echo -e "yuri\nyuri" | passwd
echo -e "yuri\nyuri" | passwd yuri

sed -i -- 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

cd ..
rm -rf arch
