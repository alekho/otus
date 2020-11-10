#!/bin/bash
#!/usr/bin/env python3

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh



#Установим необходимые пакеты
apt-get update
apt-get install debconf-utils nginx php php-fpm wget gnupg2 -y



#Устанавливаем Percona 5.7
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
apt-get update

#Задаем пароль для скуля, чтобы не вводить в интерактивном режиме
echo "percona-server-server-5.7	percona-server-server-5.7/re-root-pass password root_pass | debconf-set-selections"
echo "percona-server-server-5.7	percona-server-server-5.7/root-pass password root_pass | debconf-set-selections"

#Устанавливаем без интерактивного режима
DEBIAN_FRONTEND=noninteractive apt-get install percona-server-server-5.7 -y
apt-get install php-mysql -y

#Настраиваем скуль
mysql -u root -proot_pass <<EOF
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4;
GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';
FLUSH Privileges;
EOF

#Устанавливаем и настраиваем wordpress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz -C /var/www/
cd /var/www/wordpress/
WPSalts=$(wget https://api.wordpress.org/secret-key/1.1/salt/ -q -O -)

TablePrefx=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)_


cat <<EOF > wp-config-sample.php
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpressuser');
define('DB_PASSWORD', 'password');
define('DB_CHARSET', 'utf8mb4');

$WPSalts

\$table_prefix = '$TablePrefx';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF
cp wp-config-sample.php wp-config.php
chown -R www-data:www-data /var/www/wordpress/
find /var/www/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/wordpress/ -type f -exec chmod 640 {} \;
cd ~

#Настраеваем php-fpm
sed -i 's/;chdir = \/var\/www/chdir = \/var\/www\/wordpress/' /etc/php/7.2/fpm/pool.d/www.conf
systemctl reload php7.2-fpm.service

touch /etc/nginx/sites-available/wordpress
cat <<EOF > /etc/nginx/sites-available/wordpress
server {
  listen 8080 default_server;

  access_log /var/log/nginx/wordpress_access.log;
  error_log /var/log/nginx/wordpress_error.log;
    root   /var/www/wordpress;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
    error_page 404 /404.html;
    location = /50x.html {
        root /var/www/wordpress;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php/php7.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

}
EOF
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/



sed -i 's/;extension=mysqli/extension=mysqli/' /etc/php/7.2/fpm/php.ini
systemctl reload php7.2-fpm.service
systemctl restart php7.2-fpm.service

systemctl disable apache2.service
systemctl stop apache2.service

systemctl enable nginx.service
systemctl start nginx.service


rm /etc/nginx/sites-enabled/default 
systemctl restart nginx.service

apt-get install python-pip build-essential python-dev libffi-dev gfortran libssl-dev -y
sudo -H pip install --upgrade setuptools 
sudo -H pip install https://api.github.com/repos/yandex/yandex-tank/tarball/master 
add-apt-repository ppa:yandex-load/main -y
apt-get update
apt-get install phantom phantom-ssl -y
sudo pip install six==1.12.0 

mkdir /tmp/tank
cd /tmp/tank
cat <<EOF > load.yml
phantom:
  address: localhost:8080 # [Target's address]:[target's port]
  instances: 300
  uris:
    - /
  load_profile:
    load_type: rps # schedule load by defining requests per second
    schedule: step(20, 350, 15, 5) # starting from 1rps growing linearly to 10rps during 10 minutes
#    schedule: const(200, 300)
#    schedule: const(200, 20)
console:
  enabled: true # enable console output
telegraf:
  enabled: false # let's disable telegraf monitoring for the first time
EOF
yandex-tank -c load.yml
