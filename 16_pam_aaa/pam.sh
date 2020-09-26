#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

useradd -m -s /bin/bash user1
useradd -m -s /bin/bash user2
echo "123"|sudo passwd --stdin user1 &&\
echo "123" | sudo passwd --stdin user2

groupadd adm_group
usermod -a -G adm_group user1
usermod -a -G adm_group root
usermod -a -G adm_group vagrant

sed -i '8i\account    required     pam_exec.so /usr/local/bin/test_login.sh' /etc/pam.d/sshd

cp /vagrant/test_login.sh  /usr/local/bin
chmod 544 /usr/local/bin/test_login.sh

#cat >>/usr/local/bin/test_login.sh <<EOF; chmod 777 /usr/local/bin/test_login.sh
#!/bin/bash
#
#if getent group adm_group | grep &>/dev/null $PAM_USER; then

#    exit 0;
#fi

#if [ $(date +%u) -gt 5 ];then
#  exit 1;
#else
#  exit 0;
#fi
#EOF



yum install -y yum-utils
yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y 

usermod -a -G docker user2
touch /etc/sudoers.d/user2
cat >> /etc/sudoers.d/user2 << EOF
Cmnd_Alias DOCKER_U2 = /usr/bin/systemctl stop docker, /usr/bin/systemctl start docker, /usr/bin/systemctl restart docker

user2 ALL= NOPASSWD: DOCKER_U2
EOF

touch /etc/polkit-1/rules.d/01-systemd.rules
cat >> /etc/polkit-1/rules.d/01-systemd.rules << EOF
polkit.addRule(function(action, subject) {
if (action.id.match("org.freedesktop.systemd1.manage-units") &&
subject.user === "user2") {
return polkit.Result.YES;
}
});
EOF
