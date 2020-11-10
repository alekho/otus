#!/bin/bash

mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh


#Устанавливаем необходимые пакеты
yum -y install epel-release
yum -y update
yum install vim mailx msmtp -y



#####################################
## ПОДГОТОВКА ПОЧТЫ
#####################################

# Переопределяем предпочтения на mailx
update-alternatives --install /usr/bin/mail mail /usr/bin/mailx 1
# Переопределяем предпочтения на msmtp
update-alternatives --install /usr/sbin/sendmail sendmail /usr/bin/msmtp 1
# Создаем директорию для логов и даем необходимые права
mkdir /var/log/msmtp
chmod 777 /var/log/msmtp
# Создаем конфиг для msmtp 
cat <<EOF > /etc/msmtprc
defaults
   account default
   host smtp.yandex.ru
   port 465
   auth on
   tls on
   tls_starttls off
   tls_certcheck off
   user mailf0rtest 
   password OtusLinuxAdmin
   from mailf0rtest@yandex.ru
   aliases /etc/mail_aliases
   logfile /var/log/msmtp/msmtp.log
EOF
# Делаем алиас
echo "otus: mailf0rtest@yandex.ru" > /etc/mail_aliases

# Делаем скрипт исполняемым
chmod +x /vagrant/parser/parser.sh

# Создаем необходимые директории, файлы, копируем необходимые файлы
mkdir -p /home/vagrant/parser
cp /vagrant/access-4560-644067.log /home/vagrant/parser/access.log
cp /vagrant/parser/parser.sh /opt/
cp /vagrant/parser/parser.service /etc/systemd/system
cp /vagrant/parser/parser.timer /etc/systemd/system

# Включаем автозапуск сервиса и стартуем
systemctl daemon-reload
systemctl enable  parser.timer 
systemctl start  parser.timer 