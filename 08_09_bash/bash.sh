#!/bin/bash

mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh

#Устанавливаем необходимые пакеты
yum -y update
yum install vim mailx -y

#Создаем необходимые директории, файлы, копируем необходимые файлы
mkdir -p /home/vagrant/log_parser
cp /vagrant/access-4560-644067.log /home/vagrant/log_parser/access.log


cat access.log | head -n 1 |awk -F" " '{print $4}' | cut -c 2-
cat access.log | tail -n 1 |awk -F" " '{print $4}' | cut -c 2-
cat access.log |awk '{print $1}' |sort |uniq -c |sort -rn| head
cat access.log |awk '{print $7}' |sort |uniq -c |sort -rn| head
cat access.log |awk '{print $9}' |egrep "^4|^5"|sort |uniq -c |sort -rn