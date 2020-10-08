#!/bin/bash

mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
ssh-keygen -q -t rsa -f ~root/.ssh/id_rsa -N ''
ssh-keyscan 192.168.100.10 >> ~root/.ssh/known_hosts
yum install epel-release -y 
yum install borgbackup  -y
cp  /vagrant/borg/borgbackup.sh /opt/borgbackup.sh
chmod +x /opt/borgbackup.sh
cp /vagrant/borg/borgbackup.service /etc/systemd/system/borgbackup.service
cp /vagrant/borg/borgbackup.timer /etc/systemd/system/borgbackup.timer
systemctl daemon-reload
systemctl enable borgbackup.timer
systemctl start borgbackup.timer
