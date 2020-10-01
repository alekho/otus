
# Selinux

Более подробно все описано в [скрипт](selinux.sh)

**Первая часть ДЗ**
Разрешим запуск **Nginx** на нестандартном порту 3 разными способами:

**Способ с помощью setsebool**
Сначала изменим стандартный порт Nginx на 2080, попробуем перезапустить, получаем ошибку, воспользуемся утилитой **audit2why**, в выхлопе selinux нам сам подсказывает что необходимо сделать.
```bash
[root@selinux ~]# sed -i 's/listen       80 default_server/listen       2080 default_server/g' /etc/nginx/nginx.conf

[root@selinux ~]# systemctl restart nginx.service 
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

[root@selinux ~]# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1601537230.186:1494): avc:  denied  { name_bind } for  pid=6538 comm="nginx" src=2080 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
```
Проверяем, все работает, возвращаем все в исходное состояние.

Теперь способ  с помощью добавления порта в существующий тип:

```bash
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 2080

[root@selinux ~]# systemctl restart nginx

[root@selinux ~]# netstat -ntlpa | grep nginx
tcp        0      0 0.0.0.0:2080            0.0.0.0:*               LISTEN      6620/nginx: master  
```
Проверяем, все работает, возвращаем все в исходное состояние.

Способ с установкой модуля:
```bash
[root@selinux ~]# echo > /var/log/auditd/audit.log
-bash: /var/log/auditd/audit.log: No such file or directory
[root@selinux ~]# sed -i 's/listen       80 default_server/listen       2080 default_server/g' /etc/nginx/nginx.conf
[root@selinux ~]# echo > /var/log/auditd/audit.log
-bash: /var/log/auditd/audit.log: No such file or directory
[root@selinux ~]# setenforce 0                                
[root@selinux ~]# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1601537230.186:1494): avc:  denied  { name_bind } for  pid=6538 comm="nginx" src=2080 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
type=AVC msg=audit(1601546561.808:1539): avc:  denied  { name_bind } for  pid=27612 comm="nginx" src=2080 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
[root@selinux ~]# audit2allow -M httpd_add --debug < /var/log/audit/audit.log
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i httpd_add.pp

[root@selinux ~]# semodule -i httpd_add.pp
```