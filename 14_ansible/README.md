# Ansible

Для старка необходимо на управляющей машине выполнить:
```bash
$ vagrant up
$ ansible-playbook -i inventories/production/ playbook/nginx.yml
```
По итогу, запускается две машины **nginx01** и **nginx02**

На них запускается NGINX на порту 8080, проверить можно так:

Для  **nginx01**
```bash
$ curl 192.168.11.150:8080
```
Для **nginx02**
```bash
$ curl 192.168.11.151:8080
```
 Переведем все в [role](../15_ansible_prt2)