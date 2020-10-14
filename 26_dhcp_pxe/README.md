# DHCP, PXE

Сначала надо необходимо запустить сервер:
```bash
vagrant up pxeserver
```
После полной загрузки сервера, необходимо запустить клиента:
```bash
vagrant up pxeclient
```
Собственно делал все делал по [инструкции](https://docs.centos.org/en-US/8-docs/advanced-install/assembly_preparing-for-a-network-install/), конечно немного подогнав под свои параметры.

Добавляем пункт меню загрузки с **kickstat:**
```bash
LABEL ks
  menu label ^Install system with KS
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img ramdisk_size=128000 ip=dhcp inst.repo=http://10.0.0.20/ devfs=nomount ks=http://10.0.0.20/ks.cfg
```
![menu](img/1.png)

На клиенте пришлось увеличить объем оперативки до 4ГБ, иначе не загружалось.

![boot](img/2.png)

З. Ы.: Долго стартует из-за скачивания образа, можно скопировать локальный, если есть под рукой (8.2.2004)