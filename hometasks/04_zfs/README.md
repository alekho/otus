# zfs

[Полный порядок выполнения ДЗ](hw4v3)

Сначало пришлось модифицировать **Vagranrfile**, чтобы корректно заработал образ Centos8

Затем собственно надо установить саму **zfs**

```bash
[root@lvm ~]# cat /etc/redhat-release 
CentOS Linux release 8.1.1911  (Core)
[root@lvm ~]# yum install http://download.zfsonlinux.org/epel/zfs-release.el8_1.noarch.rpm
[root@lvm ~]# gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
```

Отключаем **DKMS** и включаем **zfs-kmod**

```bash
[root@lvm ~]# vi /etc/yum.repos.d/zfs.repo
 [zfs]
 name=ZFS on Linux for EL 8 - dkms
 baseurl=http://download.zfsonlinux.org/epel/7/$basearch/
 enabled=0
 metadata_expire=7d
 gpgcheck=1
 gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

 [zfs-kmod]
 name=ZFS on Linux for EL 8 - kmod
 baseurl=http://download.zfsonlinux.org/epel/7/kmod/$basearch/
 enabled=1
 metadata_expire=7d
 gpgcheck=1
 gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
```

и наконец

```bash
[root@lvm ~]# yum install zfs
```

Загружаем модуль **zfs** и создаем **pool**

```bash
[root@lvm ~]# /sbin/modprobe zfs
[root@lvm ~]# zpool create zfspool sdb
```

## 1

Возможны следующие варианты сжатия 

```bash
'compression' must be one of 'on | off | lzjb | gzip | gzip-[1-9] | zle | lz4'
```

Создаем ФС

```bash
[root@lvm ~]# zfs create zfspool/fs1
[root@lvm ~]# zfs create zfspool/fs2
[root@lvm ~]# zfs create zfspool/fs3
[root@lvm ~]# zfs create zfspool/fs4
```

Включаем сжатие

```bash
[root@lvm ~]# zfs set compression=lzjb zfspool/fs1
[root@lvm ~]# zfs set compression=gzip zfspool/fs2
[root@lvm ~]# zfs set compression=zle zfspool/fs3
[root@lvm ~]# zfs set compression=lz4 zfspool/fs4
[root@lvm ~]# zfs list
NAME          USED  AVAIL     REFER  MOUNTPOINT
zfspool       222K  9.20G       28K  /zfspool
zfspool/fs1    24K  9.20G       24K  /zfspool/fs1
zfspool/fs2    24K  9.20G       24K  /zfspool/fs2
zfspool/fs3    24K  9.20G       24K  /zfspool/fs3
zfspool/fs4    24K  9.20G       24K  /zfspool/fs4
```

В каждую фс скачиваем  War_and_Peace.txt, смотим сжатие

```bash
[root@lvm ~]# zfs list
NAME          USED  AVAIL     REFER  MOUNTPOINT
zfspool      4.86M  9.20G       28K  /zfspool
zfspool/fs1  1.19M  9.20G     1.19M  /zfspool/fs1
zfspool/fs2  1.18M  9.20G     1.18M  /zfspool/fs2
zfspool/fs3  1.18M  9.20G     1.18M  /zfspool/fs3
zfspool/fs4  1.18M  9.20G     1.18M  /zfspool/fs4
```

## 2

Импортируем 

```bash
[root@lvm ~]# zpool import -d ./zpoolexport/
pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
[root@lvm ~]# zpool import -d ./zpoolexport/ otus
[root@lvm ~]# zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0
```

Пул  собран в зеркало.

Смотрим что и куда примонтировалось

```bash
[root@lvm ~]# mount
otus on /otus type zfs (rw,seclabel,xattr,noacl)
otus/hometask2 on /otus/hometask2 type zfs (rw,seclabel,xattr,noacl)
```

Выводим информацию в файл

```bash
[root@lvm ~]# zfs get all otus > zpool_export.txt
[root@lvm ~]# zfs get all otus/hometask2 >> zpool_export.txt
```

Информация о  recordsize, checksum и т.д. в [файле](zpool_export.txt)

## 3

Переносим снапшот, и откатываем его

```bash
[root@lvm ~]# zfs receive otus/storage@snap111 < otus_task2.file
[root@lvm ~]# zfs rollback otus/storage@snap111
```

Получили содержание

```bash
[root@lvm ~]# ll otus/storage/
total 2590
-rw-r--r--. 1 root    root          0 May 15 06:46 10M.file
-rw-r--r--. 1 root    root     727040 May 15 07:08 cinderella.tar
-rw-r--r--. 1 root    root         65 May 15 06:39 for_examaple.txt
-rw-r--r--. 1 root    root          0 May 15 06:39 homework4.txt
-rw-r--r--. 1 root    root     309987 May 15 06:39 Limbo.txt
-rw-r--r--. 1 root    root     509836 May 15 06:39 Moby_Dick.txt
drwxr-xr-x. 3 vagrant vagrant       4 Dec 18  2017 task1
-rw-r--r--. 1 root    root    1209374 May  6  2016 War_and_Peace.txt
-rw-r--r--. 1 root    root     398635 May 15 06:45 world.sql
```

Ищем наше секретное послание

```bash
[root@lvm ~]# ll otus/storage/task1/file_mess/ | grep secret_message
-rw-r--r--. 1 root    root    40 May 15 07:10 secret_message
[root@lvm ~]# cat otus/storage/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome

```

