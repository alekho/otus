#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

#Делаем скрипт исполняемым
chmod +x /vagrant/watcher/watcher.sh

cp /vagrant/watcher/watcher.conf /etc/sysconfig
cp /vagrant/watcher/test.log /var/log
cp /vagrant/watcher/watcher.sh /opt/
cp /vagrant/watcher/watcher.service /usr/lib/systemd/system
cp /vagrant/watcher/watcher.timer /usr/lib/systemd/system

sudo systemctl daemon-reload
sudo systemctl enable watcher.service watcher.timer
sudo systemctl start watcher.service watcher.timer
