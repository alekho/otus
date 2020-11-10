#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

#Установка необходимого ПО
yum install nfs-utils -y
#Создаем директории и назначаем владельца и права
mkdir -p /mnt/nfs
chown -R vagrant:vagrant /mnt/nfs/
chmod  555 /mnt/nfs
mkdir -p /mnt/nfs/upload
chown -R vagrant:vagrant /mnt/nfs/upload/
chmod  777 /mnt/nfs/upload/
#Задаем шару со стороны сервера
echo "mnt/nfs    192.168.11.102(rw,nohide,sync,root_squash)" >> /etc/exports
#Добавляем в автозагрузку и запускаем необходимые сервесы
systemctl enable rpcbind nfs-server firewalld
systemctl start rpcbind nfs-server firewalld
#Настраиваем фаервол
firewall-cmd --permanent --zone=public --add-service=nfs3
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload