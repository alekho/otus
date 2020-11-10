# Systemd

С Systemd было примерно понятно, а вот с башем у меня пробел, поэтому ссылки на то, что помогло:

https://habr.com/ru/company/ruvds/blog/326328/

http://rus-linux.net/nlib.php?name=/MyLDP/consol/HuMan/logger-ru.html

https://wiki.enchtex.info/doc/bash/redirectes

https://habr.com/ru/company/ruvds/blog/327530/

Все операции закомментированы в провижинге. Отмечу несколько моментов которые вызвали затруднения, или считаю что о них стоит упомянуть.

### 1 часть

Сделали наш тестовый лог, написали скрипт который с помощью **logger** дописывает в **/var/log/message** результат своей работы, если находит ключевое слово из заданного лога. Ключевое слово и файл лога задается в **/etc/sysconfig/watcher.conf**. Пишем сервис и таймер который запускается каждые 30 сек. Изменили "аккуратность" запуска таймера, так как по умолчанию там стояла 1 мин.



### 2 часть

Устанавливаем необходимое **spawn-fcgi** - используется для запуска процессов **FastCGI**, поэтому ставим приложение которое поддерживает данный интерфейс, в нашем случаи это **httpd** с модулем **mod_fcgid**

Посмотев в  **/etc/init.d/spawn-fcgi** видим, что есть некий конфиг

```bash
exec="/usr/bin/spawn-fcgi"
prog="spawn-fcgi"
config="/etc/sysconfig/spawn-fcgi"

```

Надо в нем раскомментировать настройки, чтобы сервис работал.

Проверяем

```bash
[vagrant@systemdVM ~]$ sudo systemctl status spawn-fcgi.service 
● spawn-fcgi.service - spawn-fcgi service
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-06-02 14:19:50 UTC; 54min ago
 Main PID: 6513 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─6513 /usr/bin/php-cgi
           ├─6528 /usr/bin/php-cgi
           ├─6529 /usr/bin/php-cgi
           ├─6530 /usr/bin/php-cgi
           ├─6531 /usr/bin/php-cgi
           ├─6532 /usr/bin/php-cgi
           ├─6533 /usr/bin/php-cgi
           ├─6534 /usr/bin/php-cgi
           ├─6535 /usr/bin/php-cgi
           ├─6536 /usr/bin/php-cgi
           ├─6537 /usr/bin/php-cgi
           ├─6538 /usr/bin/php-cgi
           ├─6539 /usr/bin/php-cgi
           ├─6540 /usr/bin/php-cgi
           ├─6541 /usr/bin/php-cgi
           ├─6542 /usr/bin/php-cgi
           ├─6543 /usr/bin/php-cgi
           ├─6544 /usr/bin/php-cgi
           ├─6545 /usr/bin/php-cgi
           ├─6546 /usr/bin/php-cgi
           ├─6547 /usr/bin/php-cgi
           ├─6548 /usr/bin/php-cgi
           ├─6549 /usr/bin/php-cgi
           ├─6550 /usr/bin/php-cgi
           ├─6551 /usr/bin/php-cgi
           ├─6552 /usr/bin/php-cgi
           ├─6553 /usr/bin/php-cgi
           ├─6554 /usr/bin/php-cgi
           ├─6555 /usr/bin/php-cgi
           ├─6556 /usr/bin/php-cgi
           ├─6557 /usr/bin/php-cgi
           ├─6558 /usr/bin/php-cgi
           └─6559 /usr/bin/php-cgi

Jun 02 14:19:50 systemdVM systemd[1]: Started spawn-fcgi service.

```

### 3 часть

Пришлось гуглить по **sed**, без него никак... Создали два конфига для самого Apache2, в конфиге Апача замечаем, что если нам надо запустить 2 инcтанса, то необходимо минимум сделать два разных PidFile.

```bash
# same ServerRoot for multiple httpd daemons, you will need to change at
# least PidFile.
```

Отличия в конфигурациях сделал самое простое что пришло в голову, поменял порт у второй копии.

Добавляем в **/etc/sysconfig/** 2 конфига httpd. Релоудим, запускаем, проверяем.

```bash
[vagrant@systemdVM ~]$ sudo ss -tulpn | grep :80
tcp    LISTEN     0      128    [::]:8080               [::]:*                   users:(("httpd",pid=6629,fd=4),("httpd",pid=6628,fd=4),("httpd",pid=6627,fd=4),("httpd",pid=6626,fd=4),("httpd",pid=6625,fd=4),("httpd",pid=6624,fd=4),("httpd",pid=6623,fd=4))
tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("httpd",pid=6622,fd=4),("httpd",pid=6621,fd=4),("httpd",pid=6620,fd=4),("httpd",pid=6619,fd=4),("httpd",pid=6618,fd=4),("httpd",pid=6616,fd=4),("httpd",pid=6615,fd=4))

```

