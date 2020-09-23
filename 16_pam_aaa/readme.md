# PAM
Провижинг осуществляется по средством [скрипта](pam.sh).

Добавляем пользователей и устанавливаем им пароли:
```bash
[root@pam]# useradd -m -s /bin/bash user1
[root@pam]# useradd -m -s /bin/bash user2
[root@pam]# echo "123"|sudo passwd --stdin user1 &&\
[root@pam]# echo "123" | sudo passwd --stdin user2
```

Создаем группу **adm_group** и добавляем в него пользователей, **user1** сможет заходить в выходные
```bash
[root@pam]# groupadd adm_group
[root@pam]# usermod -a -G adm_group user1
[root@pam]# usermod -a -G adm_group root
[root@pam]# usermod -a -G adm_group vagrant
```

Подключаем PAM-модуль для **sshd** и настраиваем **time.conf**:
```bash
[root@pam]# sed -i '8i\account required pam_time.so' /etc/pam.d/sshd
[root@pam]# sed -i '62a\*;*;!adm_group;Wd' /etc/security/time.conf
```
Так же чтобы проверить что пользователь может рестартить сервис, нам потребуется установить сам Docker и дать такую возможность для **user2**
```bash
[root@pam]# usermod -a -G docker user2
[root@pam]# touch /etc/sudoers.d/user2
[root@pam]# cat >> /etc/sudoers.d/user2 << EOF
Cmnd_Alias DOCKER_U2 = /usr/bin/systemctl stop docker, /usr/bin/systemctl start docker, /usr/bin/systemctl restart docker

user2 ALL= NOPASSWD: DOCKER_U2
EOF

[root@pam]# touch /etc/polkit-1/rules.d/01-systemd.rules
[root@pam]# cat >> /etc/polkit-1/rules.d/01-systemd.rules << EOF
polkit.addRule(function(action, subject) {
if (action.id.match("org.freedesktop.systemd1.manage-units") &&
subject.user === "user2") {
return polkit.Result.YES;
}
});
EOF
```