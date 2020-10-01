#!/bin/bash
yum install epel-release -y
yum install nginx net-tools setools-console policycoreutils-python -y
systemctl start nginx
systemctl status nginx
netstat -ntlpa | grep nginx

echo "Nginx запущен на стандартном порту, изменим его порт на 2080"
sed -i 's/listen       80 default_server/listen       2080 default_server/g' /etc/nginx/nginx.conf
# закоментируем для удобство ipv6
sed -i 's/listen       \[\:\:\]\:80 default_server/#listen       \[\:\:\]\:80 default_server/g' /etc/nginx/nginx.conf
sleep 10

# Способ с помощью  sebool
echo "Способ с помощью  sebool"
setsebool -P nis_enabled 1
systemctl restart nginx
netstat -ntlpa | grep nginx
echo "Nginx запущен на порту 2080 с помощью setbool"
sleep 10

echo "Вернем все в исходное состояние"
sed -i 's/listen       2080 default_server/listen       80 default_server/g' /etc/nginx/nginx.conf
setsebool -P nis_enabled 0
systemctl restart nginx

# Способ с добавлением порта в существующий тип
echo "Способ с добавлением порта в существующий тип"
sed -i 's/listen       80 default_server/listen       2080 default_server/g' /etc/nginx/nginx.conf
semanage port -a -t http_port_t -p tcp 2080
systemctl restart nginx
netstat -ntlpa | grep nginx
echo "Nginx запущен на порту 2080 с помощью добавления порта в существующий тип"
sleep 10

echo "Вернем все в исходное состояние"
sed -i 's/listen       2080 default_server/listen       80 default_server/g' /etc/nginx/nginx.conf
semanage port -d -t http_port_t -p tcp 2080
systemctl restart nginx

# Способ с установкой модуля
echo "Способ с установкой модуля"
sleep 10
sed -i 's/listen       80 default_server/listen       2080 default_server/g' /etc/nginx/nginx.conf
echo > /var/log/auditd/audit.log
setenforce 0
systemctl restart nginx
audit2why < /var/log/audit/audit.log
audit2allow -M httpd_add --debug < /var/log/audit/audit.log
semodule -i httpd_add.pp
setenforce 1
systemctl restart nginx
netstat -ntlpa | grep nginx

echo "Задание №1 выполнено."