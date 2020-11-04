# PostgreSQL

Для запуска выполняем:
```console
vagrant up
```

Проверяем, а заработал ли наш бэкап:

```console
alekho@ubuntu2004:~/OTUS/41_postgresql$ vagrant ssh barman
Last login: Wed Nov  4 15:57:23 2020 from 10.0.2.2
[vagrant@barman ~]
-bash: ы: command not found
[vagrant@barman ~]$ 
[vagrant@barman ~]$ sudo -i
[root@barman ~]# barman check master
Server master:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: OK (no last_backup_maximum_age provided)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 0 backups, expected at least 0)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK (no system Id stored on disk)
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archive_mode: OK
        archive_command: OK
        archiver errors: OK
[root@barman ~]# barman replication-status master
Status of streaming clients for server 'master':
  Current LSN on master: 0/4000140
  Number of streaming clients: 2

  1. Async standby
     Application name: walreceiver
     Sync stage      : 5/5 Hot standby (max)
     Communication   : TCP/IP
     IP Address      : 192.168.100.20 / Port: 37108 / Host: -
     User name       : repl
     Current state   : streaming (async)
     Replication slot: slot
     WAL sender PID  : 8277
     Started at      : 2020-11-04 18:52:44.294704+03:00
     Sent LSN   : 0/4000140 (diff: 0 B)
     Write LSN  : 0/4000140 (diff: 0 B)
     Flush LSN  : 0/4000140 (diff: 0 B)
     Replay LSN : 0/4000140 (diff: 0 B)

  2. Async WAL streamer
     Application name: barman_receive_wal
     Sync stage      : 3/3 Remote write
     Communication   : TCP/IP
     IP Address      : 192.168.100.30 / Port: 38084 / Host: -
     User name       : barman
     Current state   : streaming (async)
     Replication slot: barman
     WAL sender PID  : 8315
     Started at      : 2020-11-04 18:57:22.503966+03:00
     Sent LSN   : 0/4000140 (diff: 0 B)
     Write LSN  : 0/4000140 (diff: 0 B)
     Flush LSN  : 0/4000000 (diff: -320 B)
[root@barman ~]# barman status master
Server master:
        Description: Master backup
        Active: True
        Disabled: False
        PostgreSQL version: 11.9
        Cluster state: in production
        pgespresso extension: Not available
        Current data size: 30.4 MiB
        PostgreSQL Data directory: /var/lib/pgsql/11/data
        Current WAL segment: 000000010000000000000004
        PostgreSQL 'archive_command' setting: barman-wal-archive barman master %p
        Last archived WAL: No WAL segment shipped yet
        Failures of WAL archiver: 40 (000000010000000000000001 at Wed Nov  4 19:05:42 2020)
        Passive node: False
        Retention policies: not enforced
        No. of available backups: 0
        First available backup: None
        Last available backup: None
        Minimum redundancy requirements: satisfied (0/0)
[root@barman ~]# logout
[vagrant@barman ~]$ logout
Connection to 127.0.0.1 closed.
```

Создадим тестовую базу на мастере чтобы проверить репликацию:

```console
[root@master ~]# sudo su postgres
bash-4.2$ psql
could not change directory to "/root": Permission denied
psql (11.9)
Type "help" for help.

postgres=# CREATE DATABASE "otus";
CREATE DATABASE

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 pgdb      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(5 rows)
```

Проверяем на слэйве:

```console
vagrant@slave ~]$ sudo -i
[root@slave ~]# sudo su postgres
bash-4.2$ psql
could not change directory to "/root": Permission denied
psql (11.9)
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 otus      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 pgdb      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(5 rows)

postgres=# 
```

Смотрим что изменения забэкапились:

```console
[root@barman ~]# barman status master
Server master:
        Description: Master backup
        Active: True
        Disabled: False
        PostgreSQL version: 11.9
        Cluster state: in production
        pgespresso extension: Not available
        Current data size: 37.9 MiB
        PostgreSQL Data directory: /var/lib/pgsql/11/data
        Current WAL segment: 000000010000000000000004
        PostgreSQL 'archive_command' setting: barman-wal-archive barman master %p
        Last archived WAL: No WAL segment shipped yet
        Failures of WAL archiver: 156 (000000010000000000000001 at Wed Nov  4 19:45:14 2020)
        Passive node: False
        Retention policies: not enforced
        No. of available backups: 0
        First available backup: None
        Last available backup: None
        Minimum redundancy requirements: satisfied (0/0)
```

Признаюсь, поставить поставил, но с POSTGRESQL практически не работал и как грамотно тюнить, не знаю, оставил конфиг mamonsu как есть...

```console
alekho@ubuntu2004:~/OTUS/41_postgresql$ vagrant ssh master
Last login: Wed Nov  4 15:48:09 2020 from 10.0.2.2
[vagrant@master ~]$ sudo -i
[root@master ~]# cat /etc/mamonsu/agent.conf
# This is a configuration file for mamonsu
# To get more information about mamonsu, visit https://postgrespro.ru/docs/postgrespro/12/mamonsu

#########  Connection parameters sections  ##############

# specify connection parameters for the Postgres cluster
# in the user, password, and database fields, you must specify the mamonsu_user, mamonsu_password,
# and the mamonsu_database used for bootstrap, respectively.
# if you skipped the bootstrap, specify a superuser credentials and the database to connect to.

[postgres]
enabled = True
user = postgres
password = None
database = postgres
host = localhost
port = 5432
application_name = mamonsu
query_timeout = 10

# the address field must point to the running Zabbix server, while the client field must provide the name of
# the Zabbix host. You can find the list of hosts available for your account in the Zabbix web
# interface under Configuration > Hosts.

[zabbix]
enabled = True
client = localhost
address = 127.0.0.1
port = 10051

#########  General parameters sections  ############

# enable or disable collection of system metrics.

[system]
enabled = True

# control the queue size of the data to be sent to the Zabbix server

[sender]
queue = 2048

# specify the location of mamonsu and whether it is allowed to access metrics from the command line

[agent]
enabled = True
host = 127.0.0.1
port = 10052

# specify custom plugins to be added for metrics collection

[plugins]
enabled = False
directory = /etc/mamonsu/plugins

# enable storing the collected metric data in text files locally.

[metric_log]
enabled = False
directory = /var/log/mamonsu
max_size_mb = 1024

# specify logging settings for mamonsu

[log]
file = None
level = INFO
format = [%(levelname)s] %(asctime)s - %(name)s -       %(message)s

#########  Individual Plugin Sections  ############

# to disable any plugin set the enabled option to False.
# modify collection interval for each plugin in the interval field.
# set customer parameters for some plugins in the individual section.
# below listed all available parameters for each plugin to modify.

[health]
max_memory_usage = 41943040
interval = 60

[bgwriter]
interval = 60

[connections]
percent_connections_tr = 90
interval = 60

[databases]
bloat_scale = 0.2
min_rows = 50
interval = 300

[pghealth]
uptime = 600
cache = 80
interval = 60

[instance]
interval = 60

[xlog]
lag_more_then_in_sec = 300
interval = 60

[pgstatstatement]
interval = 60

[pgbuffercache]
interval = 60

[pgwaitsampling]
interval = 60

[checkpoint]
max_checkpoint_by_wal_in_hour = 12
interval = 300

[oldest]
max_xid_age = 18000000
max_query_time = 18000
interval = 60

[pglocks]
interval = 60

[cfs]
force_enable = False
interval = 60

[archivecommand]
max_count_files = 2
interval = 60

[procstat]
interval = 60

[diskstats]
interval = 60

[disksizes]
vfs_percent_free = 10
vfs_inode_percent_free = 10
interval = 60

[memory]
interval = 60

[systemuptime]
up_time = 300
interval = 60

[openfiles]
interval = 60

[net]
interval = 60

[la]
interval = 60

[zbxsender]
interval = 10

[logsender]
interval = 2

[agentapi]
interval = 60

# Get age (in seconds) of the oldest running prepared transaction and number of all prepared transactions for two-phase commit.
# https://www.postgresql.org/docs/current/sql-prepare-transaction.html
# https://www.postgresql.org/docs/12/view-pg-prepared-xacts.html
# max_prepared_transaction_time - age of prepared transaction in seconds.
# If pgsql.prepared.oldest exceeds max_prepared_transaction_time the trigger fires.
[preparedtransaction]
max_prepared_transaction_time = 60
interval = 60

# Get size of backup catalogs stroring all WAL and backup files using pg_probackup
# (https://github.com/postgrespro/pg_probackup)
# Trigger fires if some backup has bad status e.g. (ERROR,CORRUPT,ORPHAN).
[pgprobackup]
enabled = False
interval = 300
backup_dirs = /backup_dir1,/backup_dir2
pg_probackup_path = /usr/bin/pg_probackup-11
```