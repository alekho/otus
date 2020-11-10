#!/bin/bash

# Source kernel
yum groupinstall -y "Development Tools"
yum install -y wget make gcc flex openssl-devel bc elfutils-libelf-devel ncurses-devel
cd ~
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.6.11.tar.xz
tar -xf linux-5.6.11.tar.xz
cd linux-5.6.11
cp -v /boot/config-$(uname -r) .config
make olddefconfig .config -j$(nproc)
make -j$(nproc)
make modules_install -j$(nproc)
make install -j$(nproc)


# Remove older kernels (Only for demo! Not Production!)
rm -f /boot/*3.10*
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
# Reboot VM
shutdown -r now