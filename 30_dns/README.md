# DNS

A Bind's DNS lab with Vagrant and Ansible, based on CentOS 7.

# Playground

<code>
    vagrant ssh client
</code>

  * zones: dns.lab, reverse dns.lab and ddns.lab
  * ns01 (192.168.50.10)
    * master, recursive, allows update to ddns.lab
  * ns02 (192.168.50.11)
    * slave, recursive
  * client (192.168.50.15)
    * used to test the env, runs rndc and nsupdate
  * zone transfer: TSIG key

Итак по порядку. Selinux. По докам достаточно раскидать но нужным директориям:
```bash
 - /var/named/ для master;
 - /var/named/slaves/ для slave
```
Дальше два дня убил на то, чтобы понять какого не идет репликация... Пересмотрел лекцию, и наконец-то услышал важное, он сказал, что нужно 2 ключа ))) Делал на виртуалке, потому как на хостовой Ubunte не работатает команда из лекции.

```bash
  [root@client2 ~]# dnssec-keygen -a HMAC-MD5 -b 128 -n HOST -r /dev/urandom zonetransfer2.key
Kzonetransfer2.key.+157+43066
[root@client2 ~]# ll
total 24
-rw-------. 1 root root   61 Oct 21 18:10 Kzonetransfer2.key.+157+43066.key
-rw-------. 1 root root  165 Oct 21 18:10 Kzonetransfer2.key.+157+43066.private
-rw-------. 1 root root 5570 Apr 30 22:09 anaconda-ks.cfg
-rw-------. 1 root root 5300 Apr 30 22:09 original-ks.cfg
[root@client2 ~]# cat Kzonetransfer2.key.+157+43066.key 
zonetransfer2.key. IN KEY 512 3 157 PV4NR7c5+PTfPl19mmrQog==
```
 Клиент1 должен видеть обе зоны, но в зоне dns.lab только web1:
```bash
Last login: Wed Oct 21 19:31:31 2020 from 10.0.2.2
### Welcome to the DNS lab! ###

- Use this client to test the enviroment, with dig or nslookup.
    dig @192.168.50.10 ns01.dns.lab
    dig @192.168.50.11 -x 192.168.50.10

- nsupdate is available in the ddns.lab zone. Ex:
    nsupdate -k /etc/named.zonetransfer.key
    server 192.168.50.10
    zone ddns.lab 
    update add www.ddns.lab. 60 A 192.168.50.15
    send

- rndc is also available to manage the servers
    rndc -c ~/rndc.conf reload

Enjoy!
[vagrant@client ~]$ sudo -i
[root@client ~]# dig www.newdns.lab +short
192.168.50.16
192.168.50.15

[root@client ~]# dig -x 192.168.50.15 +short
web1.dns.lab.
www.newdns.lab.

[root@client ~]# dig -x 192.168.50.16 +short
www.newdns.lab.

[root@client ~]# dig web1.dns.lab +short
192.168.50.15
```

Клиент2 видит только зону dns.lab:   

```bash
[root@client2 ~]# dig -x 192.168.50.15 +short
web1.dns.lab.
[root@client2 ~]# dig -x 192.168.50.16 +short
web2.dns.lab.

[root@client2 ~]# dig web1.dns.lab +short
192.168.50.15
[root@client2 ~]# dig web2.dns.lab +short
192.168.50.16
```