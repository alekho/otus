#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install epel-release -y -q
yum install fish wget -y -q
# Install tools for building rpm
yum install rpmdevtools rpm-build -y -q
yum install tree yum-utils mc wget gcc vim git -y -q
# Install tools for building woth mock and make prepares    
yum install mock -y -q
usermod -a -G mock root
# Install tools for creating your own REPO
yum install createrepo -y -q
# Install docker-ce
sudo yum install -y -q yum-utils links \
device-mapper-persistent-data \
lvm2
sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-compose -y -q
systemctl start docker
docker run hello-world

# Переходим в рут
cd /root/
# Скачиваем src
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.8.1-1.el7.ngx.src.rpm
# Строим дерево
rpm -i nginx-1.8.1-1.el7.ngx.src.rpm
# Добавляем в spec файл необходимые зависимости, включаем модуль и прописываем в конфиге
sed -i '82a\BuildRequires: GeoIP-devel' /root/rpmbuild/SPECS/nginx.spec
sed -i '136a\        --with-http_geoip_module\\' /root/rpmbuild/SPECS/nginx.spec
sed -i '176a\        --with-http_geoip_module\\' /root/rpmbuild/SPECS/nginx.spec
# Устанавливаем необходимые зависимости, собираем rpm
yum-builddep rpmbuild/SPECS/nginx.spec -y 
rpmbuild -bb rpmbuild/SPECS/nginx.spec
# Устанавливаем собранный пакет
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.8.1-1.el7.ngx.x86_64.rpm
# Делаем директории для репы и копируем туда rpm
mkdir -p /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/* /usr/share/nginx/html/repo/
# Делаем конфиг нашей репы, с доступом по http
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
# Инициализируем репу
createrepo /usr/share/nginx/html/repo/
# Правим конфиг nginx чтобы убрать 403 ошибку
sed -i '8a\         autoindex on\;' /etc/nginx/conf.d/default.conf
systemctl start nginx
