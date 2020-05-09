#!/bin/bash

#Устанавливаем необходимые пакеты
yum install -y mdadm smartmontools hdparm gdisk

#Зануляем и создаем RAID5 на 4 дисках
mdadm --zero-superblock --force /dev/sd[b-g]
mdadm --create --verbose /dev/md0 -l 5 -n 4 /dev/sd[b-e]

#Создаем конфигурацию mdadm для надежности
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

#Создаем таблицу разделов GPT и 5 партиций
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

#Создаем файловую систему и монтируем в директории
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount -v /dev/md0p$i /raid/part$i; done