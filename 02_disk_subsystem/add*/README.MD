Правим секцию **Vagrantfile**

```ruby
box.vm.provision "shell", inline: <<-SHELL
	      mkdir -p ~root/.ssh
              cp ~vagrant/.ssh/auth* ~root/.ssh
	      yum install -y mdadm smartmontools hdparm gdisk
              mdadm --zero-superblock --force /dev/sd[b-g]
	      mdadm --create --verbose /dev/md0 -l 5 -n 4 /dev/sd[b-e]
	      mkdir /etc/mdadm
	      echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
	      mdadm --detail --scan | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
	      parted -s /dev/md0 mklabel gpt
	      parted /dev/md0 mkpart primary ext4 0% 20%
	      parted /dev/md0 mkpart primary ext4 20% 40%
	      parted /dev/md0 mkpart primary ext4 40% 60%
	      parted /dev/md0 mkpart primary ext4 60% 80%
	      parted /dev/md0 mkpart primary ext4 80% 100%
	      for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
	      mkdir -p /raid/part{1,2,3,4,5}
	      for i in $(seq 1 5); do mount -v /dev/md0p$i /raid/part$i; done
  	  SHELL
```

По сути здесь используются [скрипт](../make_raid.sh) который у нас получился по итогу первого задания.

Но, при перезагрузки райд не монтируется в нужные нам папки, чтобы этого исправить необходимо поправить **fstab** следующим образом.

```bash
for i in $(seq 1 5); do uuid_temp=$(sudo blkid | grep md0p$i | awk '{print $2}'); echo "$uuid_temp /raid/part$i ext4 defaults 0 0">> /etc/fstab; done
```

