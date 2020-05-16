# Домашнее задание №1

### Базовое ДЗ  

##### Подготовка окужения для работы.

- В качестве хоста выбрана Ubuntu 20.04

- Установлен VirtualBox

  ```bash
  sudo apt update
  sudo apt install virtualbox
  ```

- Устанавливаем Vagrant

  ```bash
  wget https://releases.hashicorp.com/vagrant/2.2.8/vagrant_2.2.8_x86_64.deb && \
  sudo dpkg -i vagrant_2.2.6_x86_64.deb
  ```

- Устанавливаем Packer

  ```bash
  wget https://https://releases.hashicorp.com/packer/1.5.6/packer_1.5.6_linux_amd64.zip
  unzip packer_1.5.6_linux_amd64.zip
  sudo mv packer /usr/local/bin/
  sudo chmod +x /usr/local/bin/packer
  ```

- Устанавливаем git 

- Регистрируемся на GitHub и  Vagrant Cloud



##### Форк и клонирование репозитория.

В своем аккаунте GitHub делаем форк https://github.com/dmitry-lyutenko/manual_kernel_update

Клонируем репозиторий  

```bash
git clone https://github.com/alekho/manual_kernel_update.git
```



##### Запускаем Vagrant и обновляем ядро из репозитория.

```bash
vagrant up
vagrant ssh
```

смотрим версию ядра внутри VM

```bash
[vagrant@kernel-update ~]$ uname -r
3.10.0-957.12.2.el7.x86_64
```

Подключаем репозиторий и ставим последнее ядро

```bash
sudo yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum --enablerepo elrepo-kernel install kernel-ml -y
```



Обновляем конфигурацию GRUB и ставим по умолчанию новое ядро

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-set-default 0
```

 

Перезагружаем виртуальную машину:

```bash
sudo reboot
```

После перезагрузки виртуальной машины (3-4 минуты, зависит от мощности хостовой машины) заходим в нее и выполняем:

```bash
vagrant ssh
[vagrant@kernel-update ~]$ uname -r
5.6.11-1.el7.elrepo.x86_64
```

Видим что ядро в нашей VM обновлено, и загрузка произведена именно с него.



##### Создание своего образа системы, с уже установленым ядром 5й версии.

Правим **centos.json**, так как он содержит в конфигурации неактуальный дистрибутив.

Следующие секции:

```json
{
  "variables": {
    "artifact_description": "CentOS 7.8 with kernel 5.x",
    "artifact_version": "7.8.2003",
    "image_name": "centos-7.8"
  }
```

```json
"iso_url": "http://mirror.yandex.ru/centos/7.8.2003/isos/x86_64/CentOS-7-x86_64-Minimal-2003.iso",
"iso_checksum": "659691c28a0e672558b003d223f83938f254b39875ee7559d1a4a14c79173193",
"iso_checksum_type": "sha256"
```



##### Проверка скриптов.

Во втором скрипте находим строчку которая по умолчанию ставит загрузчиком старое ядро, исправляем ее.

```bash
grub2-set-default 0
# hmm.. suspicious
echo "###   Hi from secone stage" >> /boot/grub2/grub.cfg
```



##### Сборка образа.

```bash
packer build centos.json
```



##### Тестирование.

Импортируем полученный образ в Vagrant присваивая ему имя **centos-7-5**

```bash
vagrant box add --name centos-7-5 centos-7.8.2003-kernel-5-x86_64-Minimal.box
```

Проверяем, появился ли образ в списке

```bash
vagrant box list
centos-7-5            (virtualbox, 0)
```

Создадим новый Vagrantfile

```bash
mkdir kernel-update && cd kernel-update
vagrant init centos-7-5
```



Запускаем наш образ и проверяем версию ядра.

```bash
vagrant up
vagrant ssh
[vagrant@kernel-update ~]$ uname -r
5.6.11-1.el7.elrepo.x86_64
```

Если все в порядке, удалим тестовый образ из локального хранилища:

```bash
vagrant box remove centos-7-5
```



##### VagrantCloud

Логинимся в `vagrant cloud`, указывая e-mail, пароль и описание выданого токена (можно оставить по-умолчанию)

```
vagrant cloud auth login
Vagrant Cloud username or email: <user_email>
Password (will be hidden): 
Token description (Defaults to "Vagrant login from alekho"):
You are now logged in.
```

Теперь публикуем полученный бокс:

```bash
vagrant cloud publish --release <username>/centos-7-5 1.0 virtualbox \
        centos-7.8.2003-kernel-5-x86_64-Minimal.box
```



##### Еще один тест

Правим исходный Vagrantfile и проверям правильность работы образа из облака.

Часть кода:

```ruby
MACHINES = {
  # VM name "kernel update"
  :"otusVM" => {
              # VM box
               :box_name => "alekho/centos-7-5",
              # VM CPU count
               :cpus => 2,
              # VM RAM size (Mb)
               :memory => 1024,
              # networks
               :net => [],
              # forwarded ports
               :forwarded_port => []
             }
}
```

```bash
vagrant up
vagrant ssh
[vagrant@otusVM ~]$ uname -r
5.6.11-1.el7.elrepo.x86_64
```



Видим что все отработало верно.



### Задание со *

Сборка ядра ресурсоемкий процесс, изменяем конфигурации VM, увеличиваем количество ядер и оперативной памяти.

```bash
MACHINES = {
  # VM name "kernel update"
  :"otusVMsource" => {
              # VM box
              :box_name => "centos-7-5-s",
              # VM CPU count
              :cpus => 4,
              # VM RAM size (Mb)
              :memory => 4096,
              # networks
              :net => [],
              # forwarded ports
              :forwarded_port => []
            }
}

```

 Дополнительно необходимо увеличить объем виртуального жесткого диска до 25ГБ.

```json
"boot_wait": "10s",
"disk_size": "25480",
"guest_os_type": "RedHat_64",
"http_directory": "http",
```

Далее аналогично базовому заданию собираем  образ с помощью **Packer**, предварительно сконфигурировав первый скрипт.

```bash
# Source kernel
yum groupinstall -y "Development Tools" #Установка библиотек разработчика
yum install -y wget make gcc flex openssl-devel bc elfutils-libelf-devel ncurses-devel # Установка необходимых пакетов
cd ~
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.6.11.tar.xz # Скачиваем стабильное ядро
tar -xf linux-5.6.11.tar.xz # Разархивируем
cd linux-5.6.11
cp -v /boot/config-$(uname -r) .config # Копируем конфиги из рабочего ядра
make olddefconfig .config -j$(nproc) # Конвертируем старую конфигурацию
make -j$(nproc) # Собираем
make modules_install -j$(nproc) # Устанавливаем модули
make install -j$(nproc) # Устанавливаем ядро
```

##### Тестирование.

Импортируем полученный образ в Vagrant присваивая ему имя **centos-7-5-s**

```bash
vagrant box add --name centos-7-5-s centos-7.8.2003-kernel-5-x86_64-Minimal.box
```

Проверяем, появился ли образ в списке

```bash
vagrant box list
centos-7-5            (virtualbox, 0)
```

Изменяем имя образа в **Vagrantfile**

```ruby
:box_name => "alekho/centos-7-5-s"
```

Запускаем, проверяем

```bash
vagrant up
vagrant ssh
[vagrant@otusVM ~]$ uname -r
5.6.11
```

