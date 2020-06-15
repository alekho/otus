# Bash, grep, sed, awk

Помимо основного задание, можно поднять **Яндекс-Танк**, по совету Алексей Цыкунова, но оказалось, что там можно только померить нагрузку, а лог **Nginx** для наших задач не подходит, все запросы идут с одного ip. Прикладываю работающий [Vagrantfile](ya-tank/Vagrantfile) по инструкции от Алексея.



### Основное задание

Вместо cron использую **Sysytemd**. Пишем **Unit** и **Timer**. Таймер запускается каждые 5 минут, решил что 30  минут для стенда ждать весьма долго.

```bash
[Unit]
Description=Nginx log parser service

[Service]
Type=oneshot
User=root
ExecStart=/bin/bash /opt/parser.sh

[Install]
 WantedBy=multi-user.target
```

```bash
[Unit]
Description=Load nginx log parser service every 30 second

[Timer]
OnUnitActiveSec=300
AccuracySec=1us
Unit=parser.service

[Install]
WantedBy=multi-user.target
```

Дальше подготавливаем почтовик, устанавливаем **mailx** и **msmtp**

```bash
# Переопределяем предпочтения на mailx
update-alternatives --install /usr/bin/mail mail /usr/bin/mailx 1
# Переопределяем предпочтения на msmtp
update-alternatives --install /usr/sbin/sendmail sendmail /usr/bin/msmtp 1
# Создаем директорию для логов и даем необходимые права
mkdir /var/log/msmtp
chmod 777 /var/log/msmtp
# Создаем конфиг для msmtp 
cat <<EOF > /etc/msmtprc
defaults
   account default
   host smtp.yandex.ru
   port 465
   auth on
   tls on
   tls_starttls off
   tls_certcheck off
   user mailf0rtest 
   password OtusLinuxAdmin
   from mailf0rtest@yandex.ru
   aliases /etc/mail_aliases
   logfile /var/log/msmtp/msmtp.log
EOF
# Делаем алиас
echo "otus: mailf0rtest@yandex.ru" > /etc/mail_aliases
```

Создаем необходимые директории,  копируем файлы.

##### Функционал скрипта

Основной функциона описан комментариями в самом скрипте, изложу суть.

После определения всех переменных, создаем две функции **clean** и **setvars**. Функция **clean** нужна для ловушки, и очищает временные файлы. Функция **setvars** проверяет существование файла с записанными переменными, если его нет, то он создается и переменным присваиваются изначальные данные, если есть, то значения пременным присваиваются из массива.

Дальше определяем необходимый нам диапазон лога и формируем на основе этого диапазона текст сообщения по заданным условиям.

Проверка от поторного запуска реализована с помощью файла блокировки, которые удаляется после завершения скрипта, с помощью ловушки.

Присваиваем переменным новые значения, для запуска именно с этого места, и записываем в файл.

Скрипт выходит с **exit 0**

В подтверждении работы скрипта прикладываю сохраненное [письмо](parser/yandex_email.eml) которое приходит на почту.