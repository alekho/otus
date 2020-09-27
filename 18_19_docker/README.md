# Docker
Образ, собранный из **Dockerfile**, размещене на докер хабе [alekho/hw18-nginx:0.2](https://hub.docker.com/repository/docker/alekho/hw18-nginx).

Для запуска:
```bash
docker run -d -p 80:80 alekho/hw18-nginx:0.2
```
Выводится стартовая страничка Nginx с измененным приветствием: **Welcome OTUS!**

Во второй части с помощью **docker-compose** соединим nginx и php.
У нас добавляется образ **PHP** [alekho/hw18-php:0.2](https://hub.docker.com/repository/docker/alekho/hw18-php).
```yml
version: "3.7"

services:
  nginx:
    image: alekho/hw18-nginx:0.2
    volumes:
      - ./www/default.conf:/etc/nginx/conf.d/default.conf
      - ./www/index.php:/usr/share/nginx/html/index.php
    ports:
      - "80:80"
    networks:
      - web
    depends_on:
      - php
  php:
    image: alekho/hw18-php:0.2
    volumes:
        - ./www/index.php:/usr/share/nginx/html/index.php
    networks:
      - web
networks:
  web:
```

**Ответы на вопросы:** 
+ Kонтейнер и образ это просто разные сущности, образ это исходник, из него запускается контейнер.Основное различие между образом и контейнером — в доступном для записи верхнем слое.
+ Собрать ядро можно доставив все окружение, наверное ))) Но докер все равно использует хостовое ядро. Так что думаю это будет не совсем то ядро, которое нам нужно.