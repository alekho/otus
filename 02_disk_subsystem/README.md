# Дисковая подсистема

- Итоговый скрипт базового ДЗ [make_raid.sh](make_raid.sh) 
- [Доп. задание со *](add) 

### Запускаем VM

В **Vagrantfile** добавляем дополнительные диски для создания RAID

```ruby
:sata5 => {
        :dfile => './vdi/sata5.vdi',
        :size => 250, # Megabytes
        :port => 5
           },
 :sata6 => {
         :dfile => './vdi/sata6.vdi',
         :size => 250, # Megabytes
         :port => 6
            }
```

Запускаем VM и подкючаемся к ней

```bash
vagrant up
vagrant ssh
```

### Собираем RAID5

Проверяем наши блочные устройства

```bash
[vagrant@alekhoVM ~]$ sudo lsblk -l
NAME MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda    8:0    0   40G  0 disk 
sda1   8:1    0   40G  0 part /
sdb    8:16   0  250M  0 disk 
sdc    8:32   0  250M  0 disk 
sdd    8:48   0  250M  0 disk 
sde    8:64   0  250M  0 disk 
sdf    8:80   0  250M  0 disk 
sdg    8:96   0  250M  0 disk 
```

Зануляем суперблоки 

```bash
[vagrant@alekhoVM ~]$ sudo mdadm --zero-superblock --force /dev/sd[b-g]
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf
mdadm: Unrecognised md component device - /dev/sdg
```

Собираем RAID5 на 4 дисках

```bash
[vagrant@alekhoVM ~]$ sudo mdadm --create --verbose /dev/md0 -l 5 -n 4 /dev/sd[b-e]      
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

Проверяем 

```bash
[vagrant@alekhoVM ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sde[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
      
unused devices: <none>
```

```bash
[vagrant@alekhoVM ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sat May  9 17:49:04 2020
        Raid Level : raid5
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Sat May  9 17:49:13 2020
             State : clean 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : alekhoVM:0  (local to host alekhoVM)
              UUID : 7b20c852:d6a919cd:d888a839:bd261b3b
            Events : 18

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       4       8       64        3      active sync   /dev/sde

```

Создаем **mdadm.conf** 

```bash
[vagrant@alekhoVM ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid5 num-devices=4 metadata=1.2 name=alekhoVM:0 UUID=7b20c852:d6a919cd:d888a839:bd261b3b
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde
[vagrant@alekhoVM ~]$ sudo -i
[root@alekhoVM ~]# mkdir /etc/mdadm/
[root@alekhoVM ~]# touch mdadm.conf
[root@alekhoVM ~]# echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[root@alekhoVM ~]# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf 
```

### Ломаем/Чиним

Для тестирования "фэйлим"  **/dev/sdd** 

```bash
[root@alekhoVM ~]# mdadm /dev/md0 --fail /dev/sdd
mdadm: set /dev/sdd faulty in /dev/md0
[root@alekhoVM ~]#  cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sde[4] sdd[2](F) sdc[1] sdb[0]
      761856 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [UU_U]
      
unused devices: <none>
[root@alekhoVM ~]# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sat May  9 17:49:04 2020
        Raid Level : raid5
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Sat May  9 18:13:36 2020
             State : clean, degraded 
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : alekhoVM:0  (local to host alekhoVM)
              UUID : 7b20c852:d6a919cd:d888a839:bd261b3b
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       -       0        0        2      removed
       4       8       64        3      active sync   /dev/sde

       2       8       48        -      faulty   /dev/sdd

```

Первым делом удаляем сбойный диск, затем добавляем новый. Проверяем состояние ребилда.

```bash
[root@alekhoVM ~]# mdadm /dev/md0 --remove /dev/sdd
mdadm: hot removed /dev/sdd from /dev/md0
[root@alekhoVM ~]# mdadm /dev/md0 --add /dev/sdf
mdadm: added /dev/sdf
[root@alekhoVM ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[4] sdc[1] sdb[0]
      761856 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/3] [UU_U]
      [=>...................]  recovery =  6.2% (15876/253952) finish=0.2min speed=15876K/sec
      
unused devices: <none>
[root@alekhoVM ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdf[5] sde[4] sdc[1] sdb[0]
      761856 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
      
unused devices: <none>

```

### Создаем таблицу разделов GPT  на 5 партиций, и монтируем их на диск

Создаем GPT

```bash
[root@alekhoVM ~]# parted -s /dev/md0 mklabel gpt
```

Создаем партиции

```bash
[root@alekhoVM ~]# parted /dev/md0 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.

[root@alekhoVM ~]# parted /dev/md0 mkpart primary ext4 20% 40%             
Information: You may need to update /etc/fstab.

[root@alekhoVM ~]# parted /dev/md0 mkpart primary ext4 40% 60%        
Information: You may need to update /etc/fstab.

[root@alekhoVM ~]# parted /dev/md0 mkpart primary ext4 60% 80%        
Information: You may need to update /etc/fstab.

[root@alekhoVM ~]# parted /dev/md0 mkpart primary ext4 80% 100%       
Information: You may need to update /etc/fstab.

```

Создаем файловую систему и монтируем их по каталогам

```bash
[root@alekhoVM ~]# for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done 
[root@alekhoVM ~]#mkdir -p /raid/part{1,2,3,4,5} 
[root@alekhoVM ~]# for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
```



```bash
[root@alekhoVM ~]# fdisk -l

Disk /dev/sda: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x0009ef88

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048    83886079    41942016   83  Linux

Disk /dev/sdb: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdf: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdg: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.

Disk /dev/md0: 780 MB, 780140544 bytes, 1523712 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 524288 bytes / 1572864 bytes
Disk label type: gpt
Disk identifier: B47D0D86-6046-4BAA-A526-80F995306AEE


#         Start          End    Size  Type            Name
 1         3072       304127    147M  Microsoft basic primary
 2       304128       608255  148.5M  Microsoft basic primary
 3       608256       915455    150M  Microsoft basic primary
 4       915456      1219583  148.5M  Microsoft basic primary
 5      1219584      1520639    147M  Microsoft basic primary

```

Собираем все в скрипт [make_raid.sh](make_raid.sh) 
