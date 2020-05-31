#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

#1 часть
#Делаем скрипт исполняемым
chmod +x /vagrant/watcher/watcher.sh

#Копируем необходимые файлы
cp /vagrant/watcher/watcher.conf /etc/sysconfig
cp /vagrant/watcher/test.log /var/log
cp /vagrant/watcher/watcher.sh /opt/
cp /vagrant/watcher/watcher.service /etc/systemd/system
cp /vagrant/watcher/watcher.timer /etc/systemd/system

#Включаем автозапуск сервиса и стартуем
systemctl daemon-reload
systemctl enable watcher.service watcher.timer
systemctl start watcher.service watcher.timer

#2 часть
#Устанавливаем необходимое spawn-fcgi - используется для запуска
#процессов FastCGI, поэтому ставим приложение которое поддерживает данный интерфейс
#в нашем случаи это httpd с модулем mod_fcgid
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
#Кривенько разкоменнитруем конфиг spawn-fcgi
grep \#SOCKET  /etc/sysconfig/spawn-fcgi | cut -c 2- >> /etc/sysconfig/spawn-fcgi 
grep \#OPTION  /etc/sysconfig/spawn-fcgi | cut -c 2- >> /etc/sysconfig/spawn-fcgi 
#Копируем файл юнита
cp /vagrant/spawn-fcgi/spawn-fcgi.service /etc/systemd/system

systemctl daemon-reload
systemctl enable spawn-fcgi.service
systemctl start spawn-fcgi.service