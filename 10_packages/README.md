# Packages

В качестве пакета собираю **nginx** c модулем  **http_geoip_module**

Процесс сборке подробно закоментирован в [скрипте](packages.sh) 

После отработки провижинг по адресу http://192.168.11.101/repo будет доступен наш репозиторий, либо можно использовать прямо в ВМ.

```bash
curl http://192.168.11.101/repo/
```

 

Далее на основании нашего провижинга создали Dockerfile и создали образ:

```bash
[root@packages docker]# docker build -t otus_hw10 /root/docker/
Sending build context to Docker daemon   2.56kB
Step 1/14 : FROM centos:centos7
 ---> b5b4d78bc90c
Step 2/14 : MAINTAINER alekho
 ---> Running in d8d614a9bdf4
Removing intermediate container d8d614a9bdf4
 ---> f81e29270825
Step 3/14 : WORKDIR /root
 ---> Running in 6284c5aae896
Removing intermediate container 6284c5aae896
 ---> 7d75e350d46d
 
..........

Step 13/14 : EXPOSE 80
 ---> Running in cdea67a3c2a0
Removing intermediate container cdea67a3c2a0
 ---> 2c0ba68e656f
Step 14/14 : CMD ["nginx", "-g", "daemon off;"]
 ---> Running in 0310d29a777c
Removing intermediate container 0310d29a777c
 ---> ee665dac2f79
Successfully built ee665dac2f79
Successfully tagged otus_hw10:latest

```

Запустить наш Докер можно командой **docker run -d -p 80:80 otus_hw10**

Теперь разместим наш образ на hub.docker.com

```bash
[root@packages docker]# docker tag otus_hw10 alekho/otus_hw10
[root@packages docker]# docker push alekho/otus_hw10
The push refers to repository [docker.io/alekho/otus_hw10]
b1bf2de5ae4b: Pushed 
3236cfbfa202: Pushed 
a6c10360fd70: Pushed 
b08f3045b66e: Pushed 
2e8537f15cf1: Pushed 
0f27bb53490d: Pushed 
cb9487573b26: Pushed 
759bc390ecd7: Pushed 
a5406be4935e: Pushed 
edf3aa290fb3: Pushed 
latest: digest: sha256:22fecb2fa2f27705106beb7a83b912c8bac117d83dcc5c1a6a198e52ae57cedf size: 2422

```

https://hub.docker.com/r/alekho/otus_hw10