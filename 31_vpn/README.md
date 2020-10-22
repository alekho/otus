# VPN

Итак у нас 3 папки, в каждой лежит Vagrantfile, все делалось по инструкции, отклонения минимальные.
После сборки необходимо руками выполнить следующие манипуляции:
### TAP
Замерим скорость в туннеле в режиме TAP.
На openvpn сервере запускаем iperf3 в режиме сервера
```console
iperf3 -s &
```
На openvpn клиенте запускаем iperf3 в режиме клиента
```console
iperf3 -c 10.10.10.1 -t 40 -i 5
```
Выхлоп:
```console
[root@server ~]# iperf3 -s &
[1] 6855
[root@server ~]# -----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.10.10.2, port 52016
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 52018
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  10.1 MBytes  84.3 Mbits/sec                  
[  5]   1.00-2.00   sec  12.4 MBytes   104 Mbits/sec                  
[  5]   2.00-3.00   sec  13.4 MBytes   113 Mbits/sec                  
[  5]   3.00-4.00   sec  13.2 MBytes   111 Mbits/sec                  
[  5]   4.00-5.00   sec  13.1 MBytes   110 Mbits/sec                  
[  5]   5.00-6.00   sec  12.6 MBytes   106 Mbits/sec                  
[  5]   6.00-7.01   sec  13.9 MBytes   116 Mbits/sec                  
[  5]   7.01-8.00   sec  12.6 MBytes   106 Mbits/sec                  
[  5]   8.00-9.00   sec  13.5 MBytes   113 Mbits/sec                  
[  5]   9.00-10.00  sec  13.6 MBytes   114 Mbits/sec                  
[  5]  10.00-11.01  sec  12.7 MBytes   106 Mbits/sec                  
[  5]  11.01-12.00  sec  11.9 MBytes   101 Mbits/sec                  
[  5]  12.00-13.00  sec  11.7 MBytes  98.0 Mbits/sec                  
[  5]  13.00-14.00  sec  12.4 MBytes   104 Mbits/sec                  
[  5]  14.00-15.00  sec  13.1 MBytes   110 Mbits/sec                  
[  5]  15.00-16.00  sec  12.1 MBytes   101 Mbits/sec                  
[  5]  16.00-17.00  sec  12.3 MBytes   103 Mbits/sec                  
[  5]  17.00-18.00  sec  13.7 MBytes   115 Mbits/sec                  
[  5]  18.00-19.00  sec  12.9 MBytes   108 Mbits/sec                  
[  5]  19.00-20.00  sec  12.6 MBytes   106 Mbits/sec                  
[  5]  20.00-21.00  sec  12.9 MBytes   108 Mbits/sec                  
[  5]  21.00-22.00  sec  12.1 MBytes   102 Mbits/sec                  
[  5]  22.00-23.00  sec  13.7 MBytes   115 Mbits/sec                  
[  5]  23.00-24.00  sec  12.8 MBytes   108 Mbits/sec                  
[  5]  24.00-25.00  sec  12.6 MBytes   105 Mbits/sec                  
[  5]  25.00-26.00  sec  12.3 MBytes   104 Mbits/sec                  
[  5]  26.00-27.00  sec  12.5 MBytes   105 Mbits/sec                  
[  5]  27.00-28.00  sec  12.6 MBytes   106 Mbits/sec                  
[  5]  28.00-29.00  sec  12.0 MBytes   101 Mbits/sec                  
[  5]  29.00-30.00  sec  12.4 MBytes   104 Mbits/sec                  
[  5]  30.00-31.01  sec  13.1 MBytes   109 Mbits/sec                  
[  5]  31.01-32.00  sec  12.6 MBytes   107 Mbits/sec                  
[  5]  32.00-33.00  sec  13.8 MBytes   115 Mbits/sec                  
[  5]  33.00-34.00  sec  12.7 MBytes   106 Mbits/sec                  
[  5]  34.00-35.00  sec  12.5 MBytes   105 Mbits/sec                  
[  5]  35.00-36.00  sec  12.2 MBytes   102 Mbits/sec                  
[  5]  36.00-37.00  sec  12.9 MBytes   109 Mbits/sec                  
[  5]  37.00-38.01  sec  12.0 MBytes   100 Mbits/sec                  
[  5]  38.01-39.00  sec  13.3 MBytes   112 Mbits/sec                  
[  5]  39.00-40.00  sec  12.1 MBytes   101 Mbits/sec                  
[  5]  40.00-40.09  sec   986 KBytes  90.1 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-40.09  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-40.09  sec   508 MBytes   106 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

```console
[root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 52018 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  64.8 MBytes   109 Mbits/sec  149    302 KBytes       
[  4]   5.00-10.00  sec  65.9 MBytes   111 Mbits/sec    3    346 KBytes       
[  4]  10.00-15.00  sec  62.0 MBytes   104 Mbits/sec    1    363 KBytes       
[  4]  15.00-20.00  sec  63.8 MBytes   107 Mbits/sec   11    276 KBytes       
[  4]  20.00-25.00  sec  63.5 MBytes   107 Mbits/sec    2    312 KBytes       
[  4]  25.00-30.00  sec  62.3 MBytes   104 Mbits/sec   16    275 KBytes       
[  4]  30.00-35.00  sec  64.4 MBytes   108 Mbits/sec    7    328 KBytes       
[  4]  35.00-40.00  sec  62.8 MBytes   105 Mbits/sec   14    254 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec   510 MBytes   107 Mbits/sec  203             sender
[  4]   0.00-40.00  sec   508 MBytes   107 Mbits/sec                  receiver

iperf Done.
```
### TUN
Замерим скорость в туннеле в режиме TUN.

Выхлоп:
```console
[root@server ~]# iperf3 -s &
[1] 6849
[root@server ~]# -----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.10.10.2, port 40440
[  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 40442
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-1.00   sec  10.3 MBytes  86.4 Mbits/sec                  
[  5]   1.00-2.00   sec  11.4 MBytes  95.1 Mbits/sec                  
[  5]   2.00-3.00   sec  11.6 MBytes  98.1 Mbits/sec                  
[  5]   3.00-4.00   sec  12.8 MBytes   107 Mbits/sec                  
[  5]   4.00-5.00   sec  12.0 MBytes   101 Mbits/sec                  
[  5]   5.00-6.00   sec  12.9 MBytes   109 Mbits/sec                  
[  5]   6.00-7.00   sec  11.9 MBytes  99.5 Mbits/sec                  
[  5]   7.00-8.00   sec  13.2 MBytes   111 Mbits/sec                  
[  5]   8.00-9.00   sec  13.7 MBytes   115 Mbits/sec                  
[  5]   9.00-10.00  sec  12.2 MBytes   102 Mbits/sec                  
[  5]  10.00-11.01  sec  13.2 MBytes   110 Mbits/sec                  
[  5]  11.01-12.00  sec  11.8 MBytes  99.5 Mbits/sec                  
[  5]  12.00-13.00  sec  12.9 MBytes   109 Mbits/sec                  
[  5]  13.00-14.00  sec  12.9 MBytes   108 Mbits/sec                  
[  5]  14.00-15.00  sec  13.0 MBytes   109 Mbits/sec                  
[  5]  15.00-16.00  sec  12.3 MBytes   103 Mbits/sec                  
[  5]  16.00-17.00  sec  14.2 MBytes   119 Mbits/sec                  
[  5]  17.00-18.00  sec  13.6 MBytes   114 Mbits/sec                  
[  5]  18.00-19.00  sec  12.8 MBytes   107 Mbits/sec                  
[  5]  19.00-20.00  sec  13.1 MBytes   110 Mbits/sec                  
[  5]  20.00-21.00  sec  12.2 MBytes   103 Mbits/sec                  
[  5]  21.00-22.00  sec  12.5 MBytes   105 Mbits/sec                  
[  5]  22.00-23.00  sec  12.3 MBytes   103 Mbits/sec                  
[  5]  23.00-24.00  sec  13.1 MBytes   110 Mbits/sec                  
[  5]  24.00-25.00  sec  12.3 MBytes   103 Mbits/sec                  
[  5]  25.00-26.00  sec  12.1 MBytes   102 Mbits/sec                  
[  5]  26.00-27.00  sec  14.2 MBytes   119 Mbits/sec                  
[  5]  27.00-28.01  sec  13.0 MBytes   108 Mbits/sec                  
[  5]  28.01-29.00  sec  13.4 MBytes   113 Mbits/sec                  
[  5]  29.00-30.00  sec  12.6 MBytes   106 Mbits/sec                  
[  5]  30.00-31.01  sec  13.2 MBytes   109 Mbits/sec                  
[  5]  31.01-32.00  sec  13.0 MBytes   110 Mbits/sec                  
[  5]  32.00-33.01  sec  13.5 MBytes   112 Mbits/sec                  
[  5]  33.01-34.00  sec  12.2 MBytes   104 Mbits/sec                  
[  5]  34.00-35.00  sec  12.7 MBytes   107 Mbits/sec                  
[  5]  35.00-36.00  sec  13.5 MBytes   113 Mbits/sec                  
[  5]  36.00-37.00  sec  12.7 MBytes   106 Mbits/sec                  
[  5]  37.00-38.00  sec  11.9 MBytes  99.9 Mbits/sec                  
[  5]  38.00-39.00  sec  12.1 MBytes   102 Mbits/sec                  
[  5]  39.00-40.00  sec  13.5 MBytes   113 Mbits/sec                  
[  5]  40.00-40.09  sec  1.20 MBytes   117 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth
[  5]   0.00-40.09  sec  0.00 Bytes  0.00 bits/sec                  sender
[  5]   0.00-40.09  sec   509 MBytes   107 Mbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

```console
[root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 40442 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.01   sec  60.3 MBytes   101 Mbits/sec   45    179 KBytes       
[  4]   5.01-10.00  sec  63.9 MBytes   107 Mbits/sec    0    350 KBytes       
[  4]  10.00-15.00  sec  63.9 MBytes   107 Mbits/sec    3    370 KBytes       
[  4]  15.00-20.00  sec  65.7 MBytes   110 Mbits/sec    5    281 KBytes       
[  4]  20.00-25.00  sec  62.4 MBytes   105 Mbits/sec    2    355 KBytes       
[  4]  25.00-30.00  sec  65.7 MBytes   110 Mbits/sec   28    227 KBytes       
[  4]  30.00-35.01  sec  64.8 MBytes   109 Mbits/sec   58    299 KBytes       
[  4]  35.01-40.01  sec  63.8 MBytes   107 Mbits/sec   11    262 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.01  sec   511 MBytes   107 Mbits/sec  152             sender
[  4]   0.00-40.01  sec   509 MBytes   107 Mbits/sec                  receiver

iperf Done.
```

### RAS
С режимом RAS все немного сложнее, на хостовой машине выполняем следующие команды (пароль: vagrant):
<code>
ssh-keyscan -H 192.168.10.10 >> ~/.ssh/known_hosts
scp root@192.168.10.10:/etc/openvpn/pki/ca.crt ./
scp root@192.168.10.10:/etc/openvpn/pki/issued/client.crt ./
scp root@192.168.10.10:/etc/openvpn/pki/private/client.key ./
sudo openvpn  --config client.conf
</code>

Теперь проверяем:
```console
alekho@ubuntu2004:~/OTUS$ ip r
default via 192.168.201.1 dev wlx6cfdb9e6668f proto static metric 600 
10.10.10.1 via 10.10.10.5 dev tun0 
10.10.10.5 dev tun0 proto kernel scope link src 10.10.10.6 
169.254.0.0/16 dev wlx6cfdb9e6668f scope link metric 1000 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
192.168.10.0/24 dev vboxnet7 proto kernel scope link src 192.168.10.1 
192.168.201.0/24 dev wlx6cfdb9e6668f proto kernel scope link src 192.168.201.7 metric 600 
alekho@ubuntu2004:~/OTUS$ ping  -c 4 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.809 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.771 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.797 ms
64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.758 ms

--- 10.10.10.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3056ms
rtt min/avg/max/mdev = 0.758/0.783/0.809/0.020 ms
```

Видим что поднялся **10.10.10.1 via 10.10.10.5 dev tun0 ** и пинги идут.