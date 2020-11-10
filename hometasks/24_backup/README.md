# Backup

Для запуска стенда традиционно делаем **vagrant up**

После запуска стенда необходимо скопировать публичный ключ с клиента, на сервер:
```bash
[root@borgcl ~]# cat ~root/.ssh/id_rsa.pub | ssh root@192.168.100.10 'cat >> ~root/.ssh/authorized_keys'
```
Затем необходимо иничиализировать репозиторий:

```bash
root@192.168.100.10's password: 
[root@borgcl ~]# borg init -e repokey root@192.168.100.10:/var/backup 
Enter new passphrase: 
Enter same passphrase again: 
Do you want your passphrase to be displayed for verification? [yN]: y
Your passphrase (between double-quotes): "123456"
Make sure the passphrase displayed above is exactly what you wanted.

By default repositories initialized with this version will produce security
errors if written to with an older version (up to and including Borg 1.0.8).

If you want to use these older versions, you can disable the check by running:
borg upgrade --disable-tam ssh://root@192.168.100.10/var/backup

See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.

IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!
Use "borg key export" to export the key, optionally in printable format.
Write down the passphrase. Store both at safe place(s). 
```
Таймер настроен на 5 минут, так что именно через 5 минут можно смотреть логи:
```bash
[root@borgcl ~]# tail -f /var/log/borg_backup.log

U /etc/vmware-tools/vgauth.conf
d /etc/vmware-tools
U /etc/audit/rules.d/audit.rules
d /etc/audit/rules.d
U /etc/audit/audit.rules
U /etc/audit/audit-stop.rules
U /etc/audit/auditd.conf
d /etc/audit
U /etc/sudoers.d/vagrant
d /etc/sudoers.d
d /etc
------------------------------------------------------------------------------
Archive name: etc-borgcl-2020-10-08_08:12:00
Archive fingerprint: c4a295571d2bec42d1bf5b80c7d9ae3ac372ccb6478e25275e6e24f18c0c6ee3
Time (start): Thu, 2020-10-08 08:12:01
Time (end):   Thu, 2020-10-08 08:12:03
Duration: 1.37 seconds
Number of files: 1705
Utilization of max. archive size: 0%
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:               28.44 MB             13.50 MB            126.79 kB
All archives:               56.87 MB             26.99 MB             11.97 MB

                       Unique chunks         Total chunks
Chunk index:                    1294                 3404
------------------------------------------------------------------------------
Keeping archive: etc-borgcl-2020-10-08_08:12:00       Thu, 2020-10-08 08:12:01 [c4a295571d2bec42d1bf5b80c7d9ae3ac372ccb6478e25275e6e24f18c0c6ee3]
Pruning archive: etc-borgcl-2020-10-08_08:06:00       Thu, 2020-10-08 08:06:02 [6af4053417791d6be1fab1cd70e9c76501d2c6f4e59a3ab002ea11415cfa665b] (1/1)
```
Просмотреть бэкапы можно:
```bash
[root@borgcl ~]# borg list root@192.168.100.10:/var/backup/
```
Восстановаить бэкапы можно:
```bash
[root@borgcl ~]#  borg extract root@192.168.100.10:/var/backup/::etc-borgcl-2020-10-08_08:12:00
```