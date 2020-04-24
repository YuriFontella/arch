#!/bin/sh

## REFLECTOR

pacman -Sy
pacman -S reflector -y

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

ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --utc --systohc
timedatectl set-ntp true

# DESKTOP

pacman -S plasma-desktop plasma-meta sddm sddm-kcm dolphin konsole ark gwenview xdg-user-dirs

# SERVIÇOS

systemctl enable sddm
systemctl enable NetworkManager

# GRUB

pacman -S grub

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# USUÁRIO

useradd -m -g users -G wheel,storage,power,video -s /bin/bash yuri

echo -e "yuri\nyuri" | passwd yuri 
