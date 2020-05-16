# Дополнительное задание

Более подробно, иногда затянуто, иногда со смешными ошибками можно посмотреть [здесь](hw3_add)

Сначало необходимо установить **zfs**

```bash
[root@lvm ~]# car /etc/redhat-release 
CentOS Linux release 7.5.1804 (Core)
[root@lvm ~]# yum install http://download.zfsonlinux.org/epel/zfs-release.el7_5.noarch.rpm
[root@lvm ~]# gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
```

Отключаем **DKMS** и включаем **zfs-kmod**

```bash
[root@lvm ~]# vi /etc/yum.repos.d/zfs.repo
 [zfs]
 name=ZFS on Linux for EL 7 - dkms
 baseurl=http://download.zfsonlinux.org/epel/7/$basearch/
 enabled=0
 metadata_expire=7d
 gpgcheck=1
 gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

 [zfs-kmod]
 name=ZFS on Linux for EL 7 - kmod
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
[root@lvm ~]# zpool create zfspool sdc
```

Кэшируем чтение и запись

```bash
[root@lvm ~]# zpool add zfspool cache sdc
[root@lvm ~]# zpool add zfspool log sdc
```

Создаем ФС

```bash
[root@lvm ~]# zfs create zfspool/userdir
```

Так как в нашем случае **/opt** пустая, можем смонтировать туда наш **pool**

```bash
[root@lvm ~]# zfs set mountpoint=/opt /zfspool/userdir
```

Насколько я понял, в **fstab** прописывать **zfs** не нужно

Теперь делаем и откатывем снэпшот

```bash
[root@lvm ~]# zfs snapshot zfspool/userdir@snap_test
[root@lvm ~]# zfs rollback fspool/userdir@snap_test
```

