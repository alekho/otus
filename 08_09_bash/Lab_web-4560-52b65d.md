## Оформление ответов по лабораторной работе
* Создать репозиторий на github.com или gitlab.com
* приложить в репозиторий  README.md с ответами и скриншотами экрана
* Задания отмеченные (*) являются дополнительными для самостоятельного разбора
* при необходимости используйте sudo
* все действия были проведены на Ubuntu 18.04.1

---

## Установим nginx, php, php-fpm
```bash
apt-get update
apt-get install nginx -y
apt-get install php -y
apt-get install php-fpm -y

```
---

## Установить mysql
- при установке будет запрошен пароль, задайте и запомните
- в разных версиях процедура с паролем может отличаться, смотрите документацию
```bash
apt-get install wget
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
percona-release setup ps57
sudo apt-get install percona-server-server-5.7
apt-get install php-mysql -y
```

---

## Создать базу для wordpress

```bash
mysql -u root -p<Пароль который задали при установке>
mysql> CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4;
mysql> GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;
```

---

## Установить wordpress

```bash
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz -C /var/www/
cd /var/www/wordpress/
cp wp-config-sample.php wp-config.php
chown -R www-data:www-data /var/www/wordpress/
find /var/www/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/wordpress/ -type f -exec chmod 640 {} \;

```
---

## Отредактируем конфигурационный файл wp-config.php
- получите список ключей
```bash
curl -s https://api.wordpress.org/secret-key/1.1/salt/
```
-  пропишите их в конфиге вместо
```bash
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
```

- пропишите доступы к БД

```bash
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'wordpressuser');

/** MySQL database password */
define('DB_PASSWORD', 'password');

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );
```

---

## Настроим php-fpm

- отредактируем /etc/php/7.2/fpm/pool.d/www.conf
    - `chdir = /var/www/wordpress`
- уточним имя сокета
    - `listen = /run/php/php7.2-fpm.sock`
- зарелоадим сервис
    - `systemctl reload php7.2-fpm.service`
    
---
## Настроим nginx
- создайте файл /etc/nginx/sites-enabled/wordpress
```bash
server {
  listen 8080;

  access_log /var/log/nginx/wordpress_access.log;
  error_log /var/log/nginx/wordpress_error.log;
    root   /var/www/wordpress;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
    error_page 404 /404.html;
    location = /50x.html {
        root /var/www/wordpress;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/run/php/php7.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

}
```
- создайте линк в /etc/nginx/sites-enabled
- сделайте релоад сервиса
- добавьте в README результат `ls -l /etc/nginx/sites-enabled`
---

## Включим расширение mysqli в /etc/php/7.2/fpm/php.ini
```bash
extension=mysqli
```
- релоад сервиса  php-fpm
- добавьте в README список все активных опций (без закомментированных) из /etc/php/7.2/fpm/php.ini
---

## Зайдем из броузера

- откройте в броузере http://<your_ip>:8080
- следуйте указаниям установите вордпресс
- создайте пост с вашей ФИО и номером группы
- скриншот добавьте в README


---

## Разделение по имени
- в файле /etc/hosts пропишите имя сервера <server_name> на ваш выбор
- в конфиге нжинкса испрвьте 
`  listen 8080;`
на 
```  
listen 8080;
server_name  <server_name>;
```
- сделайте релоад нжинкса
- зайдите из броузера по заданному имени сервиса
- скриншот добавить в README
---

## *) Включение SSL
- создайте самоподписанные сертификаты
- добавьте их в конфиг nginx
- cделайте перенаправление с http на https
- в README скриншот сертификата из броузера
---

## Установим yandex tank

```bash
apt-get install python-pip build-essential python-dev libffi-dev gfortran libssl-dev
sudo -H pip install --upgrade setuptools
sudo -H pip install https://api.github.com/repos/yandex/yandex-tank/tarball/master
sudo add-apt-repository ppa:yandex-load/main
apt-get update
apt-get install phantom phantom-ssl
```

--- 

## Создадим конфиг для yandex tank

```bash

mkdir /tmp/tank
cd /tmp/tank
```

- создадим файл конфига load.yaml
```yaml
phantom:
  address: <your_ip>:8080 # [Target's address]:[target's port]
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
```
- запустим тестирование
`yandex-tank -c load.yml`
- скриншот приложить в README

---

## Понаблюдать за статистикой
- в отдельном терминали проанализировать нагрузку
- написать свои выводы
- увеличить кол-во воркеров и сравнить тесты

