#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

#Установка необходимого ПО
yum install nfs-utils -y
#Создаем директории и назначаем права
mkdir -p /mnt/share
chown -R vagrant:vagrant /mnt/share/
#Правим fstab
echo "192.168.11.101:/mnt/nfs /mnt/share nfs noauto,x-systemd.automount,proto=udp,vers=3 0 0" >> /etc/fstab
#Хак для noauto,x-systemd.automount
systemctl restart remote-fs.target
#Добавляем в автозагрузку и запускаем необходимые сервесы
systemctl enable rpcbind firewalld
systemctl start rpcbind firewalld
#Настраиваем фаервол
firewall-cmd --permanent --zone=public --add-service=nfs3
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
#Перезагружаем
shutdown -r now