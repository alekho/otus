# Logs

К сожалению абсолютно не успеваю с ДЗ, поэтому часть задания со *  не выполнена полность...

Собираем стенд из 3 машин: log, web, elk. На машине web установлен Nginx, с нее собирается критические логи через journald на машину log, так же настроен лог аудита. С Nginx у меня не получилось передавать логи через journald поэтому использовал rsyslog. Получился некий "Франкенштейн" )))

Запускается все это чудо следующими командами:
```bash
vagrant up
```
После того как поднимуться виртуалки:
```bash
ansible-playbook -i production/ logging.yml
```
Для проверки можно сделать следующие действия:
Сгененрируем критическую ошибку
```bash
[root@web ~]# logger -p crit test critical error
```
Получаем выхлоп сервере логов:
```bash
[root@log ~]# journalctl -D /var/log/journal/remote --follow
-- Logs begin at Tue 2020-10-06 05:45:57 UTC. --
Oct 06 06:17:23 web polkitd[334]: Registered Authentication Agent for unix-process:7427:188476 (system bus name :1.99 [/usr/bin/pkttyagent --notify-fd 5 --fallback], object path /org/freedesktop/PolicyKit1/AuthenticationAgent, locale C)
Oct 06 06:17:23 web systemd[1]: Reloading.
Oct 06 06:17:23 web polkitd[334]: Unregistered Authentication Agent for unix-process:7427:188476 (system bus name :1.99, object path /org/freedesktop/PolicyKit1/AuthenticationAgent, locale C) (disconnected from bus)
Oct 06 06:17:23 web polkitd[334]: Registered Authentication Agent for unix-process:7446:188495 (system bus name :1.100 [/usr/bin/pkttyagent --notify-fd 5 --fallback], object path /org/freedesktop/PolicyKit1/AuthenticationAgent, locale C)
Oct 06 06:17:23 web systemd[1]: Stopped Flush Journal to Persistent Storage.
Oct 06 06:17:23 web systemd[1]: Stopping Flush Journal to Persistent Storage...
Oct 06 06:17:23 web systemd-journal[230]: Journal stopped
Oct 06 06:17:23 web systemd-journal[7453]: Runtime journal is using 4.0M (max allowed 24.3M, trying to leave 36.5M free of 238.9M available → current limit 24.3M).
Oct 06 06:17:23 web systemd-journal[7453]: Journal started
Oct 06 06:24:39 web vagrant[8653]: test critical error
```
Проверим сбор удаленных логов с Nginx, именно он собирается Rsyslog:
```bash
[root@log ~]#  curl -I http://192.168.100.10
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Tue, 06 Oct 2020 06:35:22 GMT
Content-Type: text/html
Content-Length: 4833
Last-Modified: Fri, 16 May 2014 15:12:48 GMT
Connection: keep-alive
ETag: "53762af0-12e1"
Accept-Ranges: bytes

[root@log ~]#  curl -I http://192.168.100.10/ав
HTTP/1.1 404 Not Found
Server: nginx/1.16.1
Date: Tue, 06 Oct 2020 06:37:22 GMT
Content-Type: text/html
Content-Length: 3650
Connection: keep-alive
ETag: "5edd15a5-e42"

[root@log ~]# tail /var/log/web/nginx.log 
Oct  6 06:35:22 web nginx: 192.168.100.11 - - [06/Oct/2020:06:35:22 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
Oct  6 06:37:22 web nginx: 2020/10/06 06:37:22 [error] 8472#0: *2 open() "/usr/share/nginx/html/ав" failed (2: No such file or directory), client: 192.168.100.11, server: _, request: "HEAD /ав HTTP/1.1", host: "192.168.100.10"
Oct  6 06:37:22 web nginx: 192.168.100.11 - - [06/Oct/2020:06:37:22 +0000] "HEAD /\xD0\xB0\xD0\xB2 HTTP/1.1" 404 0 "-" "curl/7.29.0" "-"
```
Теперь проверим аудит:
```bash
[root@web ~]# vi /etc/nginx/nginx.conf
```
Выхлоп на логах:
```bash
[root@log ~]# ausearch -i -k ngnix-config-modified
----
node=web type=CONFIG_CHANGE msg=audit(10/06/2020 06:17:56.901:2420) : auid=unset ses=unset subj=system_u:system_r:unconfined_service_t:s0 op=add_rule key=ngnix-config-modified list=exit res=yes 
----
node=web type=PROCTITLE msg=audit(10/06/2020 06:42:37.318:2468) : proctitle=vi /etc/nginx/nginx.conf 
node=web type=PATH msg=audit(10/06/2020 06:42:37.318:2468) : item=0 name=/etc/nginx/.nginx.conf.swp inode=11566 dev=08:01 mode=file,600 ouid=root ogid=root rdev=00:00 obj=unconfined_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=none cap_fi=none cap_fe=0 cap_fver=0 
node=web type=CWD msg=audit(10/06/2020 06:42:37.318:2468) :  cwd=/root 
node=web type=SYSCALL msg=audit(10/06/2020 06:42:37.318:2468) : arch=x86_64 syscall=chmod success=yes exit=0 a0=0x19a2cc0 a1=0644 a2=0x199e440 a3=0x7ffee09d73a0 items=1 ppid=8636 pid=8687 auid=vagrant uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=pts0 ses=6 comm=vi exe=/usr/bin/vi subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=ngnix-config-modified
```
По ELK, поднята машина, установленно ПО, сделан шаблон конфига для filebeat.