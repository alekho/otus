# Iptables

Чтобы снизить нагрузку на ресурсы, выкинул все лишнее.
Оставил только необходимые роутеры и сервер с Nginx.

Проверка работы порт кнокинга:
```bash
[root@centralRouter ~]# ./knock.sh 192.168.255.1 8888 7777 6666

Starting Nmap 6.40 ( http://nmap.org ) at 2020-10-17 11:15 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00038s latency).
PORT     STATE    SERVICE
8888/tcp filtered sun-answerbook
MAC Address: 08:00:27:2F:57:6F (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.39 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2020-10-17 11:15 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00038s latency).
PORT     STATE    SERVICE
7777/tcp filtered cbt
MAC Address: 08:00:27:2F:57:6F (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.38 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2020-10-17 11:15 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00038s latency).
PORT     STATE    SERVICE
6666/tcp filtered irc
MAC Address: 08:00:27:2F:57:6F (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.38 seconds
[root@centralRouter ~]# ssh root@192.168.255.1
The authenticity of host '192.168.255.1 (192.168.255.1)' can't be established.
RSA key fingerprint is SHA256:iCf3jI/+gCNQ4PaoiWwRdA0MxlXKGQEetBhkuRYTHlw.
RSA key fingerprint is MD5:29:68:bd:97:52:46:58:23:fc:f9:f4:f6:b9:b7:dc:48.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.255.1' (RSA) to the list of known hosts.
root@192.168.255.1's password: 
[root@inetRouter ~]# 
```
Проверка доступности inetRouter2 с хостовой машины, и отдача Nginx с севера:
```bash
alekho@ubuntu2004:~/OTUS/28_firewalld_iptables$ ping 192.168.100.10
PING 192.168.100.10 (192.168.100.10) 56(84) bytes of data.
64 bytes from 192.168.100.10: icmp_seq=1 ttl=64 time=0.658 ms
64 bytes from 192.168.100.10: icmp_seq=2 ttl=64 time=0.347 ms
^C
--- 192.168.100.10 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1017ms
rtt min/avg/max/mdev = 0.347/0.502/0.658/0.155 ms
alekho@ubuntu2004:~/OTUS/28_firewalld_iptables$ curl -I http://192.168.100.10:8080
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Sat, 17 Oct 2020 11:13:51 GMT
Content-Type: text/html
Content-Length: 4833
Last-Modified: Fri, 16 May 2014 15:12:48 GMT
Connection: keep-alive
ETag: "53762af0-12e1"
Accept-Ranges: bytes
```

Убеждаемся что интернет доступен через inetRouter:
```bash
alekho@ubuntu2004:~/OTUS/28_firewalld_iptables$ vagrant ssh centralRouter
[vagrant@centralRouter ~]$ sudo -i
[root@centralRouter ~]# tracepath -n ya.ru
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.255.1                                         0.732ms 
 1:  192.168.255.1                                         0.560ms 
 2:  no reply
^C
[root@centralRouter ~]# ping  ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=61 time=19.6 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=61 time=18.5 ms
^C
--- ya.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 18.557/19.087/19.618/0.548 ms

```

**Описание:**
Добавляем правила из [iptables.rule](iptables.rule),  тем самым организовываем порт кнокинг.
Используем скриптик из материалов для проверки:
```bash
[root@centralRouter ~]# ./knock.sh 192.168.255.1 8888 7777 6666
```
Делаем проброс портов:
```bash
iptables -t nat -A PREROUTING  -p tcp --dport 8080 -j DNAT --to 192.168.0.2:80
```
Обратная подмена, чтобы работало без маскарадинга:
```bash
iptables -t nat -A POSTROUTING  -p tcp --dst 192.168.0.2 --dport 80 -j SNAT --to-source 192.168.254.1
```