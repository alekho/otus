
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
**Вторая часть ДЗ**
Проверим что не работает
```bash
###############################
### Welcome to the DNS lab! ###
###############################

- Use this client to test the enviroment
- with dig or nslookup. Ex:
    dig @192.168.50.10 ns01.dns.lab

- nsupdate is available in the ddns.lab zone. Ex:
    nsupdate -k /etc/named.zonetransfer.key
    server 192.168.50.10
    zone ddns.lab 
    update add www.ddns.lab. 60 A 192.168.50.15
    send

- rndc is also available to manage the servers
    rndc -c ~/rndc.conf reload

###############################
### Enjoy! ####################
###############################
[vagrant@client ~]$ dig @192.168.50.10 ns01.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> @192.168.50.10 ns01.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27734
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;ns01.dns.lab.                  IN      A

;; ANSWER SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; AUTHORITY SECTION:
dns.lab.                3600    IN      NS      ns01.dns.lab.

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Thu Oct 01 14:12:10 UTC 2020
;; MSG SIZE  rcvd: 71

[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab 
> update add www.ddns.lab. 60 A 192.168.50.15
> send        
> quit
```
Теперь на стороне **ns01** отключим Selinux:
```bash
[root@ns01 ~]# setenforce 0
```
Проверям, о чудо, все работает.
```bash
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
> quit
```
Переходим опять на **ns01**
```bash
[root@ns01 ~]# setenforce 1
[root@ns01 ~]# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1601562681.671:2345): avc:  denied  { create } for  pid=8064 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1601562955.557:2373): avc:  denied  { create } for  pid=8064 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1601562955.557:2373): avc:  denied  { write } for  pid=8064 comm="isc-worker0000" path="/etc/named/dynamic/named.ddns.lab.view1.jnl" dev="sda1" ino=67823202 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

[root@ns01 ~]# systemctl status named
● named.service - Berkeley Internet Name Domain (DNS)
   Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2020-10-01 13:47:13 UTC; 51min ago
  Process: 8062 ExecStart=/usr/sbin/named -u named -c ${NAMEDCONF} $OPTIONS (code=exited, status=0/SUCCESS)
  Process: 8060 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named-checkconf -z "$NAMEDCONF"; else echo "Checking of zone files is disabled"; fi (code=exited, status=0/SUCCESS)
 Main PID: 8064 (named)
   CGroup: /system.slice/named.service
           └─8064 /usr/sbin/named -u named -c /etc/named.conf

Oct 01 13:47:13 ns01 named[8064]: managed-keys-zone/default: Key 20326 for zone . acceptance timer complete: key now trusted
Oct 01 13:47:13 ns01 named[8064]: managed-keys-zone/view1: Key 20326 for zone . acceptance timer complete: key now trusted
Oct 01 13:47:13 ns01 named[8064]: resolver priming query complete
Oct 01 13:47:13 ns01 named[8064]: resolver priming query complete
Oct 01 14:31:21 ns01 named[8064]: client @0x7effc403c3e0 192.168.50.15#8471/key zonetransfer.key: view view1: signer "zonetransfer.key" approved
Oct 01 14:31:21 ns01 named[8064]: client @0x7effc403c3e0 192.168.50.15#8471/key zonetransfer.key: view view1: updating zone 'ddns.lab/IN': adding an RR at 'www.ddns.lab' A 192.168.50.15
Oct 01 14:31:21 ns01 named[8064]: /etc/named/dynamic/named.ddns.lab.view1.jnl: create: permission denied
Oct 01 14:31:21 ns01 named[8064]: client @0x7effc403c3e0 192.168.50.15#8471/key zonetransfer.key: view view1: updating zone 'ddns.lab/IN': error: journal open failed: unexpected error
Oct 01 14:35:55 ns01 named[8064]: client @0x7effc403c3e0 192.168.50.15#33651/key zonetransfer.key: view view1: signer "zonetransfer.key" approved
Oct 01 14:35:55 ns01 named[8064]: client @0x7effc403c3e0 192.168.50.15#33651/key zonetransfer.key: view view1: updating zone 'ddns.lab/IN': adding an RR at 'www.ddns.lab' A 192.168.50.15
```
```bash
[root@ns01 ~]# ll -Z /etc/named/dynamic/named.ddns.lab.view1
-rw-rw----. named named system_u:object_r:etc_t:s0       /etc/named/dynamic/named.ddns.lab.view1
```
Итого имеет, /etc/named/dynamic/named.ddns.lab.view1.jnl: create: permission denied, что-то не дает нам создать файл. Это вызвано типом **etc_t**, скорее всего этот тип унаследован от типа родительской директории.
Вот [тут](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/selinux_users_and_administrators_guide/index#sect-Managing_Confined_Services-BIND-Types) гугл подсказывает, что если все будет в корректной директории **/var/named/dynamic/**, то и работать все будет, с типом **named_cache_t**

Чтобы все работало модифицируем **/etc/named.conf**:

```bash
options {
    // network 
        listen-on port 53 { 192.168.50.10; };
        // listen-on-v6 port 53 { ::1; };

    // data
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";

    // server
        recursion yes;
        allow-query     { any; };
    allow-transfer { any; };
    
    // dnssec
        dnssec-enable yes;
        dnssec-validation yes;

    // others
        bindkeys-file "/etc/named.iscdlv.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

// RNDC Control for client
key "rndc-key" {
    algorithm hmac-md5;
    secret "GrtiE9kz16GK+OKKU/qJvQ==";
};

controls {
        inet 192.168.50.10 allow { 192.168.50.15; } keys { "rndc-key"; }; 
};

acl "view1" {
    192.168.50.15/32; // client
};

// ZONE TRANSFER WITH TSIG
include "/etc/named.zonetransfer.key"; 

view "view1" {
    match-clients { "view1"; };

    // root zone
    zone "." IN {
        type hint;
        file "named.ca";
    };

    // zones like localhost
    include "/etc/named.rfc1912.zones";
    // root DNSKEY
    include "/etc/named.root.key";

    // labs dns zone
    zone "dns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        file "/var/named/named.dns.lab.view1";
    };

    // labs ddns zone
    zone "ddns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        allow-update { key "zonetransfer.key"; };
        file "/var/named/dynamic/named.ddns.lab.view1";
    };

    // labs newdns zone
    zone "newdns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        file "/var/named/named.newdns.lab";
    };

    // labs zone reverse
    zone "50.168.192.in-addr.arpa" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        file "/var/named/named.50.168.192.rev";
    };
};

view "default" {
    match-clients { any; };

    // root zone
    zone "." IN {
        type hint;
        file "named.ca";
    };

    // zones like localhost
    include "/etc/named.rfc1912.zones";
    // root DNSKEY
    include "/etc/named.root.key";

    // labs dns zone
    zone "dns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        file "/etc/named/named.dns.lab";
    };

    // labs ddns zone
    zone "ddns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        allow-update { key "zonetransfer.key"; };
        file "/etc/named/dynamic/named.ddns.lab";
    };

    // labs newdns zone
    zone "newdns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        file "/etc/named/named.newdns.lab";
    };

    // labs zone reverse
    zone "50.168.192.in-addr.arpa" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        file "/etc/named/named.50.168.192.rev";
    };
};
```
Затем копируем необходимые файлы и даем права:
```bash
[root@ns01 named]# cp -R *.* /var/named/

[root@ns01 var]# chown named:named -R named/
```
Рестартим сервис **systemctl restart named**
Проверяем со стороны клиента, все работает.
```bash
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
> quit
```

На мой взгляд, это оптимальный вариант, так как права выставлены только на необходимые файлы. Как вариант тип можно было поменять и в директории **/etc/named/dynamic**
Возможно как-то собрать модуль или применить sebool, но традиционно, со временем туго :(